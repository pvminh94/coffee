-- =========================================================================
-- ĐỒ ÁN MÔN HỌC: IE103 - QUẢN LÝ THÔNG TIN
-- ĐỀ TÀI 2: HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
-- PHẦN 3: CÀI ĐẶT CÁC TRIGGER (ĐẶC BIỆT: TỰ ĐỘNG TRỪ TỒN KHO NGUYÊN LIỆU)
-- =========================================================================

USE QuanLyQuanCafe;
GO

-- =========================================================================
-- TRIGGER 1 (YÊU CẦU CỐT LÕI CỦA ĐỀ TÀI):
-- TỰ ĐỘNG KIỂM TRA VÀ TRỪ TỒN KHO NGUYÊN LIỆU KHI HÓA ĐƠN ĐƯỢC THANH TOÁN
-- Nếu nguyên liệu không đủ tồn kho: Ném lỗi (RAISERROR) và ROLLBACK giao tác!
-- Nếu đủ tồn kho: Trừ trực tiếp vào NguyenLieu.SoLuongTon và ghi log LichSuKho!
-- =========================================================================
IF OBJECT_ID('dbo.trg_HoaDon_TruKhoNguyenLieuKhiThanhToan', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_HoaDon_TruKhoNguyenLieuKhiThanhToan;
GO

CREATE TRIGGER trg_HoaDon_TruKhoNguyenLieuKhiThanhToan
ON HoaDon
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ xử lý khi trạng thái chuyển từ khác 'DaThanhToan' sang 'DaThanhToan'
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN deleted d ON i.MaHD = d.MaHD
        WHERE i.TrangThai = N'DaThanhToan' AND d.TrangThai <> N'DaThanhToan'
    )
    BEGIN
        -- Bảng tạm chứa tổng nhu cầu nguyên liệu cho các hóa đơn vừa thanh toán
        DECLARE @TieuHao TABLE (
            MaHD NVARCHAR(30),
            MaNL NVARCHAR(20),
            TenNL NVARCHAR(100),
            SoLuongCan DECIMAL(18, 3),
            SoLuongTon DECIMAL(18, 3)
        );

        INSERT INTO @TieuHao (MaHD, MaNL, TenNL, SoLuongCan, SoLuongTon)
        SELECT 
            ct.MaHD,
            dl.MaNL,
            nl.TenNL,
            SUM(ct.SoLuong * dl.SoLuongCan) AS SoLuongCan,
            nl.SoLuongTon
        FROM inserted i
        JOIN deleted d ON i.MaHD = d.MaHD
        JOIN ChiTietHoaDon ct ON ct.MaHD = i.MaHD
        JOIN DinhLuong dl ON dl.MaSP = ct.MaSP AND dl.MaSize = ct.MaSize
        JOIN NguyenLieu nl ON nl.MaNL = dl.MaNL
        WHERE i.TrangThai = N'DaThanhToan' AND d.TrangThai <> N'DaThanhToan'
        GROUP BY ct.MaHD, dl.MaNL, nl.TenNL, nl.SoLuongTon;

        -- 1. KIỂM TRA XEM CÓ NGUYÊN LIỆU NÀO BỊ THIẾU TỒN KHO HAY KHÔNG
        IF EXISTS (SELECT 1 FROM @TieuHao WHERE SoLuongTon < SoLuongCan)
        BEGIN
            DECLARE @ThongBaoLoi NVARCHAR(1000);
            SELECT TOP 1 @ThongBaoLoi = N'LỖI TRỪ KHO: Nguyên liệu [' + TenNL + N'] không đủ để pha chế! Tồn kho hiện có: ' 
                                      + CAST(SoLuongTon AS NVARCHAR(30)) + N', Cần tiêu hao: ' 
                                      + CAST(SoLuongCan AS NVARCHAR(30)) + N'.'
            FROM @TieuHao
            WHERE SoLuongTon < SoLuongCan;

            RAISERROR(@ThongBaoLoi, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. NẾU ĐỦ TỒN KHO: TIẾN HÀNH TRỪ TRỰC TIẾP VÀO BẢNG NguyenLieu
        UPDATE nl
        SET nl.SoLuongTon = nl.SoLuongTon - th.TongCan
        FROM NguyenLieu nl
        JOIN (
            SELECT MaNL, SUM(SoLuongCan) AS TongCan
            FROM @TieuHao
            GROUP BY MaNL
        ) th ON nl.MaNL = th.MaNL;

        -- 3. GHI NHẬN VÀO BẢNG LỊCH SỬ KHO (LichSuKho) ĐỂ THEO DÕI
        INSERT INTO LichSuKho (MaNL, LoaiGiaoDich, SoLuongThayDoi, SoLuongTonSauDo, MaChungTu, GhiChu)
        SELECT 
            th.MaNL,
            N'BanHang',
            -th.SoLuongCan,
            nl.SoLuongTon,
            th.MaHD,
            N'Trừ kho tự động khi thanh toán hóa đơn ' + th.MaHD
        FROM @TieuHao th
        JOIN NguyenLieu nl ON nl.MaNL = th.MaNL;

        -- 4. CẬP NHẬT TRẠNG THÁI BÀN SANG TRỐNG NẾU LÀ ĐƠN TẠI CHỖ
        UPDATE b
        SET b.TrangThai = N'Trong'
        FROM Ban b
        JOIN inserted i ON b.MaBan = i.MaBan
        WHERE i.TrangThai = N'DaThanhToan';
    END
END
GO

-- =========================================================================
-- TRIGGER 2: TỰ ĐỘNG HOÀN TRẢ TỒN KHO NGUYÊN LIỆU KHI HÓA ĐƠN BỊ HỦY
-- Nếu hóa đơn đã được thanh toán (đã trừ kho) mà chuyển sang 'DaHuy'
-- =========================================================================
IF OBJECT_ID('dbo.trg_HoaDon_HoanKhoNguyenLieuKhiHuy', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_HoaDon_HoanKhoNguyenLieuKhiHuy;
GO

CREATE TRIGGER trg_HoaDon_HoanKhoNguyenLieuKhiHuy
ON HoaDon
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Xử lý khi đơn hàng chuyển từ 'DaThanhToan' sang 'DaHuy'
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN deleted d ON i.MaHD = d.MaHD
        WHERE i.TrangThai = N'DaHuy' AND d.TrangThai = N'DaThanhToan'
    )
    BEGIN
        DECLARE @HoanKho TABLE (
            MaHD NVARCHAR(30),
            MaNL NVARCHAR(20),
            SoLuongHoan DECIMAL(18, 3)
        );

        INSERT INTO @HoanKho (MaHD, MaNL, SoLuongHoan)
        SELECT 
            ct.MaHD,
            dl.MaNL,
            SUM(ct.SoLuong * dl.SoLuongCan)
        FROM inserted i
        JOIN deleted d ON i.MaHD = d.MaHD
        JOIN ChiTietHoaDon ct ON ct.MaHD = i.MaHD
        JOIN DinhLuong dl ON dl.MaSP = ct.MaSP AND dl.MaSize = ct.MaSize
        WHERE i.TrangThai = N'DaHuy' AND d.TrangThai = N'DaThanhToan'
        GROUP BY ct.MaHD, dl.MaNL;

        -- Hoàn trả số lượng vào kho
        UPDATE nl
        SET nl.SoLuongTon = nl.SoLuongTon + hk.TongHoan
        FROM NguyenLieu nl
        JOIN (
            SELECT MaNL, SUM(SoLuongHoan) AS TongHoan
            FROM @HoanKho
            GROUP BY MaNL
        ) hk ON nl.MaNL = hk.MaNL;

        -- Ghi log lịch sử hoàn kho
        INSERT INTO LichSuKho (MaNL, LoaiGiaoDich, SoLuongThayDoi, SoLuongTonSauDo, MaChungTu, GhiChu)
        SELECT 
            hk.MaNL,
            N'HoanKho',
            hk.SoLuongHoan,
            nl.SoLuongTon,
            hk.MaHD,
            N'Hoàn kho do hủy hóa đơn đã thanh toán ' + hk.MaHD
        FROM @HoanKho hk
        JOIN NguyenLieu nl ON nl.MaNL = hk.MaNL;
    END
END
GO

-- =========================================================================
-- TRIGGER 3: TỰ ĐỘNG CẬP NHẬT TỔNG TIỀN HÓA ĐƠN
-- Khi thêm, sửa, xóa món trong ChiTietHoaDon
-- =========================================================================
IF OBJECT_ID('dbo.trg_ChiTietHoaDon_CapNhatTongTien', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_ChiTietHoaDon_CapNhatTongTien;
GO

CREATE TRIGGER trg_ChiTietHoaDon_CapNhatTongTien
ON ChiTietHoaDon
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy danh sách các mã hóa đơn bị ảnh hưởng
    DECLARE @AffectedInvoices TABLE (MaHD NVARCHAR(30) PRIMARY KEY);

    INSERT INTO @AffectedInvoices (MaHD)
    SELECT DISTINCT MaHD FROM inserted
    UNION
    SELECT DISTINCT MaHD FROM deleted;

    -- Cập nhật lại Tổng tiền hàng và Tổng thanh toán cho các hóa đơn đó
    UPDATE hd
    SET 
        hd.TongTienHang = ISNULL(t.TongTien, 0),
        hd.TongThanhToan = CASE 
            WHEN (ISNULL(t.TongTien, 0) - hd.GiamGia + hd.PhuThu) < 0 THEN 0
            ELSE (ISNULL(t.TongTien, 0) - hd.GiamGia + hd.PhuThu)
        END
    FROM HoaDon hd
    JOIN @AffectedInvoices a ON hd.MaHD = a.MaHD
    LEFT JOIN (
        SELECT MaHD, SUM(ThanhTien) AS TongTien
        FROM ChiTietHoaDon
        GROUP BY MaHD
    ) t ON hd.MaHD = t.MaHD;
END
GO

-- =========================================================================
-- TRIGGER 4: TỰ ĐỘNG CẬP NHẬT TỒN KHO VÀ ĐƠN GIÁ BÌNH QUÂN KHI NHẬP KHO
-- Khi thêm chi tiết phiếu nhập
-- =========================================================================
IF OBJECT_ID('dbo.trg_ChiTietPhieuNhap_CapNhatTonKho', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_ChiTietPhieuNhap_CapNhatTonKho;
GO

CREATE TRIGGER trg_ChiTietPhieuNhap_CapNhatTonKho
ON ChiTietPhieuNhap
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật số lượng tồn kho và tính đơn giá nhập bình quân gia quyền
    UPDATE nl
    SET 
        nl.DonGiaNhapBinhQuan = CASE 
            WHEN (nl.SoLuongTon + i.SoLuongNhap) > 0 THEN 
                ((nl.SoLuongTon * nl.DonGiaNhapBinhQuan) + (i.SoLuongNhap * i.DonGiaNhap)) / (nl.SoLuongTon + i.SoLuongNhap)
            ELSE i.DonGiaNhap
        END,
        nl.SoLuongTon = nl.SoLuongTon + i.SoLuongNhap
    FROM NguyenLieu nl
    JOIN inserted i ON nl.MaNL = i.MaNL;

    -- Ghi lịch sử nhập kho
    INSERT INTO LichSuKho (MaNL, LoaiGiaoDich, SoLuongThayDoi, SoLuongTonSauDo, MaChungTu, GhiChu)
    SELECT 
        i.MaNL,
        N'NhapKho',
        i.SoLuongNhap,
        nl.SoLuongTon,
        i.MaPN,
        N'Cập nhật tự động từ phiếu nhập ' + i.MaPN
    FROM inserted i
    JOIN NguyenLieu nl ON nl.MaNL = i.MaNL;

    -- Cập nhật tổng tiền nhập trong bảng PhieuNhapKho
    UPDATE pn
    SET pn.TongTienNhap = ISNULL((SELECT SUM(ThanhTien) FROM ChiTietPhieuNhap WHERE MaPN = pn.MaPN), 0)
    FROM PhieuNhapKho pn
    WHERE pn.MaPN IN (SELECT DISTINCT MaPN FROM inserted);
END
GO

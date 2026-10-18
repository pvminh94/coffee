-- =========================================================================
-- ĐỒ ÁN MÔN HỌC: IE103 - QUẢN LÝ THÔNG TIN
-- ĐỀ TÀI 2: HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
-- PHẦN 4: CÀI ĐẶT CÁC HÀM (FUNCTIONS) VÀ THỦ TỤC LƯU TRỮ (STORED PROCEDURES)
-- =========================================================================

USE QuanLyQuanCafe;
GO

-- =========================================================================
-- 1. FUNCTION TÍNH TỔNG DOANH THU THEO NGÀY (YÊU CẦU CỐT LÕI CỦA ĐỀ TÀI)
-- Input: @Ngay DATE
-- Output: Tổng doanh thu (DECIMAL(18,2)) của các hóa đơn đã thanh toán
-- =========================================================================
IF OBJECT_ID('dbo.fn_TinhDoanhThuTheoNgay', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhDoanhThuTheoNgay;
GO

CREATE FUNCTION dbo.fn_TinhDoanhThuTheoNgay
(
    @Ngay DATE
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongDoanhThu DECIMAL(18, 2);

    SELECT @TongDoanhThu = ISNULL(SUM(TongThanhToan), 0)
    FROM HoaDon
    WHERE CAST(NgayTao AS DATE) = @Ngay
      AND TrangThai = N'DaThanhToan';

    RETURN @TongDoanhThu;
END;
GO

-- =========================================================================
-- 2. FUNCTION TÍNH TỔNG DOANH THU THEO THÁNG/NĂM (YÊU CẦU CỐT LÕI CỦA ĐỀ TÀI)
-- Input: @Thang INT, @Nam INT
-- Output: Tổng doanh thu (DECIMAL(18,2)) của tháng và năm chỉ định
-- =========================================================================
IF OBJECT_ID('dbo.fn_TinhDoanhThuTheoThang', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhDoanhThuTheoThang;
GO

CREATE FUNCTION dbo.fn_TinhDoanhThuTheoThang
(
    @Thang INT,
    @Nam INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongDoanhThu DECIMAL(18, 2);

    SELECT @TongDoanhThu = ISNULL(SUM(TongThanhToan), 0)
    FROM HoaDon
    WHERE MONTH(NgayTao) = @Thang
      AND YEAR(NgayTao) = @Nam
      AND TrangThai = N'DaThanhToan';

    RETURN @TongDoanhThu;
END;
GO

-- =========================================================================
-- 3. FUNCTION TÍNH DOANH THU TRONG KHOẢNG THỜI GIAN (NÂNG CAO)
-- =========================================================================
IF OBJECT_ID('dbo.fn_DoanhThuKhoangThoiGian', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DoanhThuKhoangThoiGian;
GO

CREATE FUNCTION dbo.fn_DoanhThuKhoangThoiGian
(
    @TuNgay DATE,
    @DenNgay DATE
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongDoanhThu DECIMAL(18, 2);

    SELECT @TongDoanhThu = ISNULL(SUM(TongThanhToan), 0)
    FROM HoaDon
    WHERE CAST(NgayTao AS DATE) BETWEEN @TuNgay AND @DenNgay
      AND TrangThai = N'DaThanhToan';

    RETURN @TongDoanhThu;
END;
GO

-- =========================================================================
-- 4. TABLE-VALUED FUNCTION: THỐNG KÊ TOP MÓN BÁN CHẠY NHẤT
-- =========================================================================
IF OBJECT_ID('dbo.fn_ThongKeMonBanChay', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_ThongKeMonBanChay;
GO

CREATE FUNCTION dbo.fn_ThongKeMonBanChay
(
    @TuNgay DATE,
    @DenNgay DATE,
    @TopN INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (@TopN)
        sp.MaSP,
        sp.TenSP,
        dm.TenDM,
        ct.MaSize,
        SUM(ct.SoLuong) AS TongSoLuongBan,
        SUM(ct.ThanhTien) AS TongDoanhThu
    FROM ChiTietHoaDon ct
    JOIN HoaDon hd ON ct.MaHD = hd.MaHD
    JOIN SanPham sp ON ct.MaSP = sp.MaSP
    JOIN DanhMuc dm ON sp.MaDM = dm.MaDM
    WHERE CAST(hd.NgayTao AS DATE) BETWEEN @TuNgay AND @DenNgay
      AND hd.TrangThai = N'DaThanhToan'
    GROUP BY sp.MaSP, sp.TenSP, dm.TenDM, ct.MaSize
    ORDER BY TongSoLuongBan DESC
);
GO

-- =========================================================================
-- 5. TABLE-VALUED FUNCTION: CẢNH BÁO NGUYÊN LIỆU DƯỚI ĐỊNH MỨC TỒN KHO
-- =========================================================================
IF OBJECT_ID('dbo.fn_CanhBaoNguyenLieuSapHet', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_CanhBaoNguyenLieuSapHet;
GO

CREATE FUNCTION dbo.fn_CanhBaoNguyenLieuSapHet()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        MaNL,
        TenNL,
        DonViTinh,
        SoLuongTon,
        NguongToiThieu,
        (NguongToiThieu - SoLuongTon) AS SoLuongThieuHut,
        CASE 
            WHEN SoLuongTon = 0 THEN N'HẾT HÀNG'
            WHEN SoLuongTon < NguongToiThieu THEN N'CẦN NHẬP GẤP'
            ELSE N'BÌNH THƯỜNG'
        END AS MucDoCanhBao
    FROM NguyenLieu
    WHERE SoLuongTon <= NguongToiThieu AND TrangThai = 1
);
GO

-- =========================================================================
-- 6. STORED PROCEDURE: TẠO HÓA ĐƠN MỚI
-- =========================================================================
IF OBJECT_ID('dbo.sp_TaoHoaDon', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TaoHoaDon;
GO

CREATE PROCEDURE dbo.sp_TaoHoaDon
    @MaHD NVARCHAR(30),
    @MaBan NVARCHAR(20) = NULL,
    @MaNV NVARCHAR(20),
    @MaKH NVARCHAR(20) = NULL,
    @LoaiDon NVARCHAR(30) = N'TaiCho',
    @GhiChu NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Kiểm tra nhân viên tồn tại
        IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV AND TrangThai = N'DangLamViec')
        BEGIN
            RAISERROR(N'Nhân viên không hợp lệ hoặc đã nghỉ việc!', 16, 1);
            RETURN;
        END

        INSERT INTO HoaDon (MaHD, MaBan, MaNV, MaKH, LoaiDon, TrangThai, GhiChu)
        VALUES (@MaHD, @MaBan, @MaNV, @MaKH, @LoaiDon, N'ChoThanhToan', @GhiChu);

        -- Cập nhật trạng thái bàn nếu là đơn tại chỗ
        IF @MaBan IS NOT NULL AND @LoaiDon = N'TaiCho'
        BEGIN
            UPDATE Ban SET TrangThai = N'CoKhach' WHERE MaBan = @MaBan;
        END

        SELECT * FROM HoaDon WHERE MaHD = @MaHD;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- =========================================================================
-- 7. STORED PROCEDURE: THANH TOÁN HÓA ĐƠN VÀ KÍCH HOẠT TRỪ KHO
-- =========================================================================
IF OBJECT_ID('dbo.sp_ThanhToanHoaDon', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ThanhToanHoaDon;
GO

CREATE PROCEDURE dbo.sp_ThanhToanHoaDon
    @MaHD NVARCHAR(30),
    @PhuongThucTT NVARCHAR(50),
    @GiamGia DECIMAL(18, 2) = 0,
    @TienKhachDua DECIMAL(18, 2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM HoaDon WHERE MaHD = @MaHD AND TrangThai = N'ChoThanhToan')
        BEGIN
            RAISERROR(N'Hóa đơn không tồn tại hoặc đã được thanh toán/hủy trước đó!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Tính tiền thối lại
        DECLARE @TongThanhToan DECIMAL(18, 2);
        SELECT @TongThanhToan = (TongTienHang - @GiamGia + PhuThu) FROM HoaDon WHERE MaHD = @MaHD;
        IF @TongThanhToan < 0 SET @TongThanhToan = 0;

        DECLARE @TienThoiLai DECIMAL(18, 2) = 0;
        IF @PhuongThucTT = N'TienMat' AND @TienKhachDua >= @TongThanhToan
        BEGIN
            SET @TienThoiLai = @TienKhachDua - @TongThanhToan;
        END

        -- Cập nhật hóa đơn -> Trạng thái 'DaThanhToan' sẽ kích hoạt TRIGGER trg_HoaDon_TruKhoNguyenLieuKhiThanhToan
        UPDATE HoaDon
        SET 
            GiamGia = @GiamGia,
            TongThanhToan = @TongThanhToan,
            PhuongThucTT = @PhuongThucTT,
            TienKhachDua = @TienKhachDua,
            TienThoiLai = @TienThoiLai,
            TrangThai = N'DaThanhToan'
        WHERE MaHD = @MaHD;

        COMMIT TRANSACTION;

        SELECT N'Thanh toán thành công và đã trừ tồn kho nguyên liệu!' AS ThongBao, @MaHD AS MaHD;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END;
GO

-- =========================================================================
-- 8. STORED PROCEDURE: BÁO CÁO DOANH THU TỔNG QUAN
-- =========================================================================
IF OBJECT_ID('dbo.sp_BaoCaoDoanhThuTongQuan', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_BaoCaoDoanhThuTongQuan;
GO

CREATE PROCEDURE dbo.sp_BaoCaoDoanhThuTongQuan
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Tổng quát
    SELECT 
        COUNT(MaHD) AS TongSoDon,
        ISNULL(SUM(TongTienHang), 0) AS TongTienHang,
        ISNULL(SUM(GiamGia), 0) AS TongGiamGia,
        ISNULL(SUM(TongThanhToan), 0) AS DoanhThuThucTe,
        ISNULL(AVG(TongThanhToan), 0) AS GiaTriTrungBinhDon
    FROM HoaDon
    WHERE CAST(NgayTao AS DATE) BETWEEN @TuNgay AND @DenNgay
      AND TrangThai = N'DaThanhToan';

    -- 2. Theo phương thức thanh toán
    SELECT 
        PhuongThucTT,
        COUNT(MaHD) AS SoHoaDon,
        SUM(TongThanhToan) AS TongTien
    FROM HoaDon
    WHERE CAST(NgayTao AS DATE) BETWEEN @TuNgay AND @DenNgay
      AND TrangThai = N'DaThanhToan'
    GROUP BY PhuongThucTT;
END;
GO

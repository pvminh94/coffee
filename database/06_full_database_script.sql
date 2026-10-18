-- =========================================================================
-- ĐỒ ÁN MÔN HỌC: IE103 - QUẢN LÝ THÔNG TIN
-- ĐỀ TÀI 2: HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
-- PHẦN 1: TẠO CƠ SỞ DỮ LIỆU VÀ HỆ THỐNG CÁC BẢNG (TABLES)
-- Hệ quản trị CSDL: Microsoft SQL Server (T-SQL)
-- =========================================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyQuanCafe')
BEGIN
    ALTER DATABASE QuanLyQuanCafe SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyQuanCafe;
END
GO

CREATE DATABASE QuanLyQuanCafe
COLLATE Vietnamese_CI_AS;
GO

USE QuanLyQuanCafe;
GO

-- 1. BẢNG VAI TRÒ (Phân quyền người dùng)
CREATE TABLE VaiTro (
    MaVaiTro NVARCHAR(20) NOT NULL PRIMARY KEY,
    TenVaiTro NVARCHAR(50) NOT NULL,
    MoTa NVARCHAR(255) NULL
);
GO

-- 2. BẢNG NHÂN VIÊN
CREATE TABLE NhanVien (
    MaNV NVARCHAR(20) NOT NULL PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai NVARCHAR(15) NULL,
    Email NVARCHAR(100) NULL,
    TenDangNhap NVARCHAR(50) NOT NULL UNIQUE,
    MatKhauHash NVARCHAR(255) NOT NULL,
    MaVaiTro NVARCHAR(20) NOT NULL,
    NgayVaoLam DATE DEFAULT CAST(GETDATE() AS DATE),
    TrangThai NVARCHAR(20) DEFAULT N'DangLamViec', -- 'DangLamViec', 'NghiViec'
    CONSTRAINT FK_NhanVien_VaiTro FOREIGN KEY (MaVaiTro) REFERENCES VaiTro(MaVaiTro)
);
GO

-- 3. BẢNG DANH MỤC MÓN (Category)
CREATE TABLE DanhMuc (
    MaDM NVARCHAR(20) NOT NULL PRIMARY KEY,
    TenDM NVARCHAR(100) NOT NULL,
    HinhAnh NVARCHAR(255) NULL,
    ThuTuHienThi INT DEFAULT 0,
    TrangThai BIT DEFAULT 1 -- 1: Đang bán, 0: Tạm ẩn
);
GO

-- 4. BẢNG SIZE MÓN (Kích cỡ ly: S, M, L)
CREATE TABLE SizeMon (
    MaSize NVARCHAR(10) NOT NULL PRIMARY KEY,
    TenSize NVARCHAR(30) NOT NULL,
    MoTa NVARCHAR(100) NULL
);
GO

-- 5. BẢNG SẢN PHẨM / MÓN
CREATE TABLE SanPham (
    MaSP NVARCHAR(20) NOT NULL PRIMARY KEY,
    TenSP NVARCHAR(150) NOT NULL,
    MaDM NVARCHAR(20) NOT NULL,
    MoTa NVARCHAR(500) NULL,
    HinhAnh NVARCHAR(255) NULL,
    TrangThai BIT DEFAULT 1, -- 1: Hoạt động, 0: Ngừng kinh doanh
    CONSTRAINT FK_SanPham_DanhMuc FOREIGN KEY (MaDM) REFERENCES DanhMuc(MaDM)
);
GO

-- 6. BẢNG GIÁ BÁN THEO SIZE (Mỗi sản phẩm có giá cho từng Size)
CREATE TABLE SanPham_Size (
    MaSP NVARCHAR(20) NOT NULL,
    MaSize NVARCHAR(10) NOT NULL,
    GiaBan DECIMAL(18, 2) NOT NULL,
    TrangThai BIT DEFAULT 1,
    CONSTRAINT PK_SanPham_Size PRIMARY KEY (MaSP, MaSize),
    CONSTRAINT FK_SanPhamSize_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP) ON DELETE CASCADE,
    CONSTRAINT FK_SanPhamSize_SizeMon FOREIGN KEY (MaSize) REFERENCES SizeMon(MaSize)
);
GO

-- 7. BẢNG KHO NGUYÊN LIỆU (Quản lý tồn kho)
CREATE TABLE NguyenLieu (
    MaNL NVARCHAR(20) NOT NULL PRIMARY KEY,
    TenNL NVARCHAR(100) NOT NULL,
    DonViTinh NVARCHAR(30) NOT NULL, -- 'g', 'ml', 'cai', 'hop'
    SoLuongTon DECIMAL(18, 3) NOT NULL DEFAULT 0,
    NguongToiThieu DECIMAL(18, 3) NOT NULL DEFAULT 10, -- Cảnh báo khi tồn kho <= ngưỡng
    DonGiaNhapBinhQuan DECIMAL(18, 2) DEFAULT 0,
    TrangThai BIT DEFAULT 1
);
GO

-- 8. BẢNG ĐỊNH LƯỢNG NGUYÊN LIỆU / CÔNG THỨC PHA CHẾ (Recipe)
-- Xác định 1 món với 1 Size cụ thể tiêu hao bao nhiêu nguyên liệu
CREATE TABLE DinhLuong (
    MaSP NVARCHAR(20) NOT NULL,
    MaSize NVARCHAR(10) NOT NULL,
    MaNL NVARCHAR(20) NOT NULL,
    SoLuongCan DECIMAL(18, 3) NOT NULL, -- Lượng nguyên liệu tiêu hao cho 1 đơn vị món
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT PK_DinhLuong PRIMARY KEY (MaSP, MaSize, MaNL),
    CONSTRAINT FK_DinhLuong_SanPhamSize FOREIGN KEY (MaSP, MaSize) REFERENCES SanPham_Size(MaSP, MaSize) ON DELETE CASCADE,
    CONSTRAINT FK_DinhLuong_NguyenLieu FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL)
);
GO

-- 9. BẢNG BÀN CỦA QUÁN
CREATE TABLE Ban (
    MaBan NVARCHAR(20) NOT NULL PRIMARY KEY,
    TenBan NVARCHAR(50) NOT NULL,
    KhuVuc NVARCHAR(50) NULL, -- 'Tang 1', 'Tang 2', 'Ngoai Troi'
    TrangThai NVARCHAR(30) DEFAULT N'Trong' -- 'Trong', 'CoKhach', 'DatTruoc'
);
GO

-- 10. BẢNG KHÁCH HÀNG (Khách hàng thân thiết / Tích điểm)
CREATE TABLE KhachHang (
    MaKH NVARCHAR(20) NOT NULL PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai NVARCHAR(15) NOT NULL UNIQUE,
    DiemTichLuy INT DEFAULT 0,
    HangThanhVien NVARCHAR(30) DEFAULT N'Dong', -- 'Dong', 'Bac', 'Vang', 'KimCuong'
    NgayDangKy DATE DEFAULT CAST(GETDATE() AS DATE)
);
GO

-- 11. BẢNG HÓA ĐƠN
CREATE TABLE HoaDon (
    MaHD NVARCHAR(30) NOT NULL PRIMARY KEY,
    MaBan NVARCHAR(20) NULL,
    MaNV NVARCHAR(20) NOT NULL,
    MaKH NVARCHAR(20) NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    TongTienHang DECIMAL(18, 2) DEFAULT 0,
    GiamGia DECIMAL(18, 2) DEFAULT 0,
    PhuThu DECIMAL(18, 2) DEFAULT 0,
    TongThanhToan DECIMAL(18, 2) DEFAULT 0,
    PhuongThucTT NVARCHAR(50) DEFAULT N'TienMat', -- 'TienMat', 'ChuyenKhoan', 'The'
    TienKhachDua DECIMAL(18, 2) DEFAULT 0,
    TienThoiLai DECIMAL(18, 2) DEFAULT 0,
    TrangThai NVARCHAR(30) DEFAULT N'ChoThanhToan', -- 'ChoThanhToan', 'DaThanhToan', 'DaHuy'
    LoaiDon NVARCHAR(30) DEFAULT N'TaiCho', -- 'TaiCho', 'MangVe'
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT FK_HoaDon_Ban FOREIGN KEY (MaBan) REFERENCES Ban(MaBan),
    CONSTRAINT FK_HoaDon_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_HoaDon_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);
GO

-- 12. BẢNG CHI TIẾT HÓA ĐƠN
CREATE TABLE ChiTietHoaDon (
    MaCTHD INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    MaHD NVARCHAR(30) NOT NULL,
    MaSP NVARCHAR(20) NOT NULL,
    MaSize NVARCHAR(10) NOT NULL,
    SoLuong INT NOT NULL,
    DonGia DECIMAL(18, 2) NOT NULL,
    ThanhTien AS (SoLuong * DonGia) PERSISTED,
    GhiChu NVARCHAR(255) NULL, -- 'Ít ngọt 50%', 'Không đá', v.v.
    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD) ON DELETE CASCADE,
    CONSTRAINT FK_CTHD_SanPhamSize FOREIGN KEY (MaSP, MaSize) REFERENCES SanPham_Size(MaSP, MaSize)
);
GO

-- 13. BẢNG PHIẾU NHẬP KHO NGUYÊN LIỆU
CREATE TABLE PhieuNhapKho (
    MaPN NVARCHAR(30) NOT NULL PRIMARY KEY,
    MaNV NVARCHAR(20) NOT NULL,
    NgayNhap DATETIME DEFAULT GETDATE(),
    NhaCungCap NVARCHAR(150) NULL,
    TongTienNhap DECIMAL(18, 2) DEFAULT 0,
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT FK_PhieuNhap_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

-- 14. BẢNG CHI TIẾT PHIẾU NHẬP KHO
CREATE TABLE ChiTietPhieuNhap (
    MaCTPN INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    MaPN NVARCHAR(30) NOT NULL,
    MaNL NVARCHAR(20) NOT NULL,
    SoLuongNhap DECIMAL(18, 3) NOT NULL,
    DonGiaNhap DECIMAL(18, 2) NOT NULL,
    ThanhTien AS (SoLuongNhap * DonGiaNhap) PERSISTED,
    CONSTRAINT FK_CTPN_PhieuNhap FOREIGN KEY (MaPN) REFERENCES PhieuNhapKho(MaPN) ON DELETE CASCADE,
    CONSTRAINT FK_CTPN_NguyenLieu FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL)
);
GO

-- 15. BẢNG LỊCH SỬ BIẾN ĐỘNG KHO (Audit trail)
CREATE TABLE LichSuKho (
    MaLS INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    MaNL NVARCHAR(20) NOT NULL,
    LoaiGiaoDich NVARCHAR(50) NOT NULL, -- 'BanHang', 'NhapKho', 'HoanKho', 'KiemKe'
    SoLuongThayDoi DECIMAL(18, 3) NOT NULL,
    SoLuongTonSauDo DECIMAL(18, 3) NOT NULL,
    MaChungTu NVARCHAR(50) NULL, -- Mã HD hoặc Mã PN
    NgayThucHien DATETIME DEFAULT GETDATE(),
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT FK_LichSuKho_NguyenLieu FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL)
);
GO


-- =========================================================================
-- ĐỒ ÁN MÔN HỌC: IE103 - QUẢN LÝ THÔNG TIN
-- ĐỀ TÀI 2: HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
-- PHẦN 2: CÁC RÀNG BUỘC TOÀN VẸN (CONSTRAINTS) VÀ CHỈ MỤC (INDEXES)
-- =========================================================================

USE QuanLyQuanCafe;
GO

-- 1. RÀNG BUỘC CHECK TRÊN BẢNG SanPham_Size
ALTER TABLE SanPham_Size
ADD CONSTRAINT CK_SanPhamSize_GiaBan CHECK (GiaBan >= 0);
GO

-- 2. RÀNG BUỘC CHECK TRÊN BẢNG NguyenLieu
ALTER TABLE NguyenLieu
ADD CONSTRAINT CK_NguyenLieu_SoLuongTon CHECK (SoLuongTon >= 0),
    CONSTRAINT CK_NguyenLieu_NguongToiThieu CHECK (NguongToiThieu >= 0),
    CONSTRAINT CK_NguyenLieu_DonGiaNhap CHECK (DonGiaNhapBinhQuan >= 0);
GO

-- 3. RÀNG BUỘC CHECK TRÊN BẢNG DinhLuong
ALTER TABLE DinhLuong
ADD CONSTRAINT CK_DinhLuong_SoLuongCan CHECK (SoLuongCan > 0);
GO

-- 4. RÀNG BUỘC CHECK TRÊN BẢNG ChiTietHoaDon
ALTER TABLE ChiTietHoaDon
ADD CONSTRAINT CK_CTHD_SoLuong CHECK (SoLuong > 0),
    CONSTRAINT CK_CTHD_DonGia CHECK (DonGia >= 0);
GO

-- 5. RÀNG BUỘC CHECK TRÊN BẢNG HoaDon
ALTER TABLE HoaDon
ADD CONSTRAINT CK_HoaDon_TongTienHang CHECK (TongTienHang >= 0),
    CONSTRAINT CK_HoaDon_GiamGia CHECK (GiamGia >= 0),
    CONSTRAINT CK_HoaDon_TongThanhToan CHECK (TongThanhToan >= 0),
    CONSTRAINT CK_HoaDon_TrangThai CHECK (TrangThai IN (N'ChoThanhToan', N'DaThanhToan', N'DaHuy')),
    CONSTRAINT CK_HoaDon_LoaiDon CHECK (LoaiDon IN (N'TaiCho', N'MangVe')),
    CONSTRAINT CK_HoaDon_PhuongThuc CHECK (PhuongThucTT IN (N'TienMat', N'ChuyenKhoan', N'The'));
GO

-- 6. RÀNG BUỘC CHECK TRÊN BẢNG ChiTietPhieuNhap
ALTER TABLE ChiTietPhieuNhap
ADD CONSTRAINT CK_CTPN_SoLuongNhap CHECK (SoLuongNhap > 0),
    CONSTRAINT CK_CTPN_DonGiaNhap CHECK (DonGiaNhap >= 0);
GO

-- =========================================================================
-- CHỈ MỤC (INDEXES) TỐI ƯU HÓA HIỆU NĂNG TRUY VẤN
-- =========================================================================

-- Tối ưu hóa truy vấn tính doanh thu theo ngày / tháng trên bảng HoaDon
CREATE NONCLUSTERED INDEX IX_HoaDon_NgayTao_TrangThai
ON HoaDon (NgayTao, TrangThai)
INCLUDE (TongThanhToan, MaNV, MaBan);
GO

-- Tối ưu hóa truy vấn chi tiết hóa đơn theo mã hóa đơn
CREATE NONCLUSTERED INDEX IX_ChiTietHoaDon_MaHD
ON ChiTietHoaDon (MaHD)
INCLUDE (MaSP, MaSize, SoLuong, DonGia, ThanhTien);
GO

-- Tối ưu hóa tra cứu định lượng nguyên liệu theo món và size
CREATE NONCLUSTERED INDEX IX_DinhLuong_MaSP_MaSize
ON DinhLuong (MaSP, MaSize)
INCLUDE (MaNL, SoLuongCan);
GO

-- Tối ưu hóa cảnh báo tồn kho nguyên liệu sắp hết
CREATE NONCLUSTERED INDEX IX_NguyenLieu_SoLuongTon
ON NguyenLieu (SoLuongTon, NguongToiThieu)
INCLUDE (TenNL, DonViTinh);
GO

-- Tối ưu hóa tra cứu khách hàng theo số điện thoại
CREATE NONCLUSTERED INDEX IX_KhachHang_SoDienThoai
ON KhachHang (SoDienThoai)
INCLUDE (HoTen, DiemTichLuy, HangThanhVien);
GO


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


-- =========================================================================
-- ĐỒ ÁN MÔN HỌC: IE103 - QUẢN LÝ THÔNG TIN
-- ĐỀ TÀI 2: HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
-- PHẦN 5: DỮ LIỆU MẪU ĐẦY ĐỦ (SAMPLE DATA)
-- =========================================================================

USE QuanLyQuanCafe;
GO

-- 1. BẢNG VAI TRÒ (Roles)
INSERT INTO VaiTro (MaVaiTro, TenVaiTro, MoTa) VALUES
('VT01', N'Quản Lý', N'Toàn quyền quản trị hệ thống, menu, kho và doanh thu'),
('VT02', N'Thu Ngân', N'Tạo đơn hàng, thanh toán và in hóa đơn tại quầy');
GO

-- 2. BẢNG NHÂN VIÊN (Tài khoản đăng nhập demo)
-- Mật khẩu mặc định: '123456'
INSERT INTO NhanVien (MaNV, HoTen, SoDienThoai, Email, TenDangNhap, MatKhauHash, MaVaiTro, TrangThai) VALUES
('NV01', N'Nguyễn Văn Quản Lý', '0901234567', 'quanly@coffee.vn', 'quanly', '123456', 'VT01', N'DangLamViec'),
('NV02', N'Trần Thị Thu Ngân', '0902345678', 'thungan1@coffee.vn', 'thungan', '123456', 'VT02', N'DangLamViec'),
('NV03', N'Lê Hoàng Nam', '0903456789', 'thungan2@coffee.vn', 'thungan2', '123456', 'VT02', N'DangLamViec');
GO

-- 3. BẢNG DANH MỤC (Categories)
INSERT INTO DanhMuc (MaDM, TenDM, HinhAnh, ThuTuHienThi) VALUES
('DM01', N'Cà Phê Truyền Thống', 'coffee.png', 1),
('DM02', N'Trà Sữa & Macchiato', 'milktea.png', 2),
('DM03', N'Trà Trái Cây Tươi', 'fruittea.png', 3),
('DM04', N'Đá Xay & Freeze', 'freeze.png', 4),
('DM05', N'Bánh Ngọt & Tráng Miệng', 'bakery.png', 5);
GO

-- 4. BẢNG SIZE MÓN
INSERT INTO SizeMon (MaSize, TenSize, MoTa) VALUES
('S', N'Size Nhỏ (S)', N'Ly 350ml / Tiêu chuẩn'),
('M', N'Size Vừa (M)', N'Ly 500ml / Phổ biến'),
('L', N'Size Lớn (L)', N'Ly 700ml / Siêu to');
GO

-- 5. BẢNG SẢN PHẨM / MÓN (20 món phong phú)
INSERT INTO SanPham (MaSP, TenSP, MaDM, MoTa) VALUES
-- Cà phê
('SP01', N'Cà Phê Đen Đá', 'DM01', N'Cà phê Robusta Đắk Lắk đậm đà nguyên bản'),
('SP02', N'Cà Phê Sữa Đá', 'DM01', N'Cà phê đậm vị hòa quyện sữa đặc thơm béo'),
('SP03', N'Bạc Xỉu Sữa Tươi', 'DM01', N'Nhiều sữa ít cà phê, vị béo ngọt thanh tao'),
('SP04', N'Cà Phê Muối Xứ Huế', 'DM01', N'Cà phê thơm nồng kết hợp lớp kem mặn béo ngậy'),
-- Trà sữa
('SP05', N'Trà Sữa Oolong Nướng', 'DM02', N'Trà Oolong rang thơm nồng đậm, sữa béo ngậy'),
('SP06', N'Trà Sữa Truyền Thống Trân Châu', 'DM02', N'Hồng trà kết hợp sữa béo và trân châu đen dẻo'),
('SP07', N'Trà Sữa Matcha Nhật Bản', 'DM02', N'Matcha Uji thơm mát chuẩn phong cách Nhật'),
('SP08', N'Hồng Trà Macchiato', 'DM02', N'Hồng trà thanh khiết phủ lớp kem cheese béo mặn'),
-- Trà trái cây
('SP09', N'Trà Đào Cam Sả', 'DM03', N'Vị đào thơm lừng kết hợp cam vàng và sả tươi thanh mát'),
('SP10', N'Trà Vải Lài Thơm', 'DM03', N'Trà lài ngát hương kèm thịt vải giòn ngọt'),
('SP11', N'Trà Ổi Hồng Sen Vàng', 'DM03', N'Ổi hồng thanh ngọt kết hợp hạt sen bùi béo'),
-- Đá xay
('SP12', N'Caramel Freeze Đá Xay', 'DM04', N'Cà phê đá xay phủ sốt caramel và kem tươi'),
('SP13', N'Matcha Freeze Tuyết Trắng', 'DM04', N'Matcha tuyết phủ whipped cream hảo hạng'),
-- Bánh ngọt
('SP14', N'Bánh Tiramisu Cacao', 'DM05', N'Bánh Tiramisu mềm mịn thơm mùi rượu cà phê'),
('SP15', N'Bánh Croissant Bơ Tỏi', 'DM05', N'Bánh sừng bò ngàn lớp thơm lừng bơ Pháp'),
('SP16', N'Cheesecake Chanh Dây', 'DM05', N'Bánh phô mai sốt chanh dây chua ngọt tươi mát');
GO

-- 6. BẢNG GIÁ BÁN THEO SIZE (SanPham_Size)
INSERT INTO SanPham_Size (MaSP, MaSize, GiaBan) VALUES
-- Cà phê đen
('SP01', 'S', 25000), ('SP01', 'M', 29000), ('SP01', 'L', 35000),
-- Cà phê sữa đá
('SP02', 'S', 29000), ('SP02', 'M', 35000), ('SP02', 'L', 42000),
-- Bạc xỉu
('SP03', 'S', 32000), ('SP03', 'M', 38000), ('SP03', 'L', 45000),
-- Cà phê muối
('SP04', 'S', 35000), ('SP04', 'M', 42000), ('SP04', 'L', 49000),
-- Trà sữa Oolong nướng
('SP05', 'S', 38000), ('SP05', 'M', 45000), ('SP05', 'L', 52000),
-- Trà sữa truyền thống
('SP06', 'S', 35000), ('SP06', 'M', 42000), ('SP06', 'L', 49000),
-- Trà sữa Matcha
('SP07', 'S', 40000), ('SP07', 'M', 48000), ('SP07', 'L', 55000),
-- Hồng trà Macchiato
('SP08', 'S', 38000), ('SP08', 'M', 45000), ('SP08', 'L', 52000),
-- Trà đào cam sả
('SP09', 'S', 42000), ('SP09', 'M', 49000), ('SP09', 'L', 56000),
-- Trà vải lài
('SP10', 'S', 42000), ('SP10', 'M', 49000), ('SP10', 'L', 56000),
-- Trà ổi hồng
('SP11', 'S', 45000), ('SP11', 'M', 52000), ('SP11', 'L', 59000),
-- Freeze Caramel
('SP12', 'M', 55000), ('SP12', 'L', 65000),
-- Matcha Freeze
('SP13', 'M', 55000), ('SP13', 'L', 65000),
-- Bánh ngọt (Mặc định Size M)
('SP14', 'M', 39000),
('SP15', 'M', 35000),
('SP16', 'M', 45000);
GO

-- 7. BẢNG NGUYÊN LIỆU (Nguyên liệu thực tế trong quán Cà phê & Trà sữa)
INSERT INTO NguyenLieu (MaNL, TenNL, DonViTinh, SoLuongTon, NguongToiThieu, DonGiaNhapBinhQuan) VALUES
('NL01', N'Cà Phê Robusta Hạt/Bột', 'g', 15000.0, 2000.0, 180),
('NL02', N'Cà Phê Arabica Hạt/Bột', 'g', 8000.0, 1000.0, 250),
('NL03', N'Trà Oolong Cao Cấp', 'g', 5000.0, 1000.0, 320),
('NL04', N'Trà Đen Phúc Long', 'g', 6000.0, 1000.0, 220),
('NL05', N'Trà Lài Ướp Hoa', 'g', 4500.0, 800.0, 280),
('NL06', N'Bột Sữa Béo Kievit', 'g', 20000.0, 3000.0, 120),
('NL07', N'Sữa Đặc Ngôi Sao', 'ml', 18000.0, 2500.0, 65),
('NL08', N'Sữa Tươi Tiệt Trùng DalatMilk', 'ml', 25000.0, 4000.0, 38),
('NL09', N'Nước Đường Mía Nấu', 'ml', 30000.0, 5000.0, 25),
('NL10', N'Trân Châu Đen Gia Uy', 'g', 12000.0, 2000.0, 75),
('NL11', N'Syrup Đào Monin', 'ml', 4000.0, 500.0, 350),
('NL12', N'Syrup Ổi Hồng', 'ml', 3500.0, 500.0, 340),
('NL13', N'Đào Miếng Ngâm Kronos', 'mieng', 250.0, 30.0, 3500),
('NL14', N'Kem Béo Thực Vật Whipping', 'ml', 5000.0, 800.0, 150),
('NL15', N'Bột Matcha Uji Nhật', 'g', 2500.0, 400.0, 850),
('NL16', N'Ly Nhựa & Nắp Cầu/Bằng', 'cai', 2000.0, 300.0, 800);
GO

-- 8. BẢNG ĐỊNH LƯỢNG NGUYÊN LIỆU (Recipe)
-- Công thức định lượng tiêu hao nguyên liệu cho từng món và từng size
INSERT INTO DinhLuong (MaSP, MaSize, MaNL, SoLuongCan, GhiChu) VALUES
-- SP01: Cà Phê Đen Đá (Size S, M, L)
('SP01', 'S', 'NL01', 20.0, N'20g bột cà phê'),
('SP01', 'S', 'NL09', 15.0, N'15ml nước đường'),
('SP01', 'S', 'NL16', 1.0, N'1 ly nhựa'),
('SP01', 'M', 'NL01', 25.0, N'25g bột cà phê'),
('SP01', 'M', 'NL09', 20.0, N'20ml nước đường'),
('SP01', 'M', 'NL16', 1.0, N'1 ly nhựa'),
('SP01', 'L', 'NL01', 30.0, N'30g bột cà phê'),
('SP01', 'L', 'NL09', 25.0, N'25ml nước đường'),
('SP01', 'L', 'NL16', 1.0, N'1 ly nhựa'),

-- SP02: Cà Phê Sữa Đá (Size S, M, L)
('SP02', 'S', 'NL01', 20.0, N'20g bột cà phê'),
('SP02', 'S', 'NL07', 30.0, N'30ml sữa đặc'),
('SP02', 'S', 'NL16', 1.0, N'1 ly nhựa'),
('SP02', 'M', 'NL01', 25.0, N'25g bột cà phê'),
('SP02', 'M', 'NL07', 40.0, N'40ml sữa đặc'),
('SP02', 'M', 'NL16', 1.0, N'1 ly nhựa'),
('SP02', 'L', 'NL01', 30.0, N'30g bột cà phê'),
('SP02', 'L', 'NL07', 50.0, N'50ml sữa đặc'),
('SP02', 'L', 'NL16', 1.0, N'1 ly nhựa'),

-- SP05: Trà Sữa Oolong Nướng (Size S, M, L)
('SP05', 'S', 'NL03', 12.0, N'12g trà Oolong'),
('SP05', 'S', 'NL06', 25.0, N'25g bột sữa béo'),
('SP05', 'S', 'NL09', 20.0, N'20ml nước đường'),
('SP05', 'S', 'NL10', 30.0, N'30g trân châu'),
('SP05', 'S', 'NL16', 1.0, N'1 ly nhựa'),

('SP05', 'M', 'NL03', 15.0, N'15g trà Oolong'),
('SP05', 'M', 'NL06', 30.0, N'30g bột sữa béo'),
('SP05', 'M', 'NL09', 25.0, N'25ml nước đường'),
('SP05', 'M', 'NL10', 40.0, N'40g trân châu'),
('SP05', 'M', 'NL16', 1.0, N'1 ly nhựa'),

('SP05', 'L', 'NL03', 20.0, N'20g trà Oolong'),
('SP05', 'L', 'NL06', 40.0, N'40g bột sữa béo'),
('SP05', 'L', 'NL09', 35.0, N'35ml nước đường'),
('SP05', 'L', 'NL10', 50.0, N'50g trân châu'),
('SP05', 'L', 'NL16', 1.0, N'1 ly nhựa'),

-- SP09: Trà Đào Cam Sả (Size M)
('SP09', 'M', 'NL04', 12.0, N'12g trà đen cốt'),
('SP09', 'M', 'NL11', 25.0, N'25ml syrup đào'),
('SP09', 'M', 'NL09', 20.0, N'20ml nước đường'),
('SP09', 'M', 'NL13', 2.0, N'2 miếng đào'),
('SP09', 'M', 'NL16', 1.0, N'1 ly nhựa');
GO

-- 9. BẢNG BÀN
INSERT INTO Ban (MaBan, TenBan, KhuVuc, TrangThai) VALUES
('B01', N'Bàn 01 (Cửa sổ)', N'Tầng 1', N'Trong'),
('B02', N'Bàn 02 (Sofa)', N'Tầng 1', N'Trong'),
('B03', N'Bàn 03', N'Tầng 1', N'Trong'),
('B04', N'Bàn 04 (Nhóm)', N'Tầng 1', N'Trong'),
('B05', N'Bàn 05 (Ban công)', N'Tầng 2', N'Trong'),
('B06', N'Bàn 06 (Làm việc)', N'Tầng 2', N'Trong'),
('B07', N'Bàn 07', N'Tầng 2', N'Trong'),
('B08', N'Bàn Ngoài Trời 01', N'Sân Vườn', N'Trong');
GO

-- 10. BẢNG KHÁCH HÀNG
INSERT INTO KhachHang (MaKH, HoTen, SoDienThoai, DiemTichLuy, HangThanhVien) VALUES
('KH01', N'Phạm Văn Minh', '0918123456', 150, N'Vang'),
('KH02', N'Trần Thị Mai', '0987654321', 45, N'Dong'),
('KH03', N'Nguyễn Đức Huy', '0933221100', 80, N'Bac');
GO

-- 11. BẢNG HÓA ĐƠN VÀ CHI TIẾT HÓA ĐƠN MẪU (Để kiểm thử Function tính doanh thu ngày/tháng)
-- Hóa đơn 1 (Đã thanh toán)
INSERT INTO HoaDon (MaHD, MaBan, MaNV, MaKH, NgayTao, TongTienHang, GiamGia, TongThanhToan, PhuongThucTT, TienKhachDua, TienThoiLai, TrangThai, LoaiDon) VALUES
('HD20261018001', 'B01', 'NV02', 'KH01', '2026-10-18 08:30:00', 80000, 0, 80000, N'TienMat', 100000, 20000, N'DaThanhToan', N'TaiCho');

INSERT INTO ChiTietHoaDon (MaHD, MaSP, MaSize, SoLuong, DonGia) VALUES
('HD20261018001', 'SP02', 'M', 1, 35000),
('HD20261018001', 'SP05', 'M', 1, 45000);

-- Hóa đơn 2 (Đã thanh toán)
INSERT INTO HoaDon (MaHD, MaBan, MaNV, MaKH, NgayTao, TongTienHang, GiamGia, TongThanhToan, PhuongThucTT, TienKhachDua, TienThoiLai, TrangThai, LoaiDon) VALUES
('HD20261018002', 'B02', 'NV02', NULL, '2026-10-18 09:15:00', 98000, 0, 98000, N'ChuyenKhoan', 98000, 0, N'DaThanhToan', N'TaiCho');

INSERT INTO ChiTietHoaDon (MaHD, MaSP, MaSize, SoLuong, DonGia) VALUES
('HD20261018002', 'SP09', 'M', 2, 49000);

-- Hóa đơn 3 (Mang về, Đã thanh toán)
INSERT INTO HoaDon (MaHD, MaBan, MaNV, MaKH, NgayTao, TongTienHang, GiamGia, TongThanhToan, PhuongThucTT, TienKhachDua, TienThoiLai, TrangThai, LoaiDon) VALUES
('HD20261018003', NULL, 'NV03', 'KH02', '2026-10-18 10:00:00', 74000, 5000, 69000, N'TienMat', 70000, 1000, N'DaThanhToan', N'MangVe');

INSERT INTO ChiTietHoaDon (MaHD, MaSP, MaSize, SoLuong, DonGia) VALUES
('HD20261018003', 'SP01', 'M', 1, 29000),
('HD20261018003', 'SP05', 'M', 1, 45000);

-- Hóa đơn các ngày trước trong tháng 10/2026 (Để test Function tính theo tháng)
INSERT INTO HoaDon (MaHD, MaBan, MaNV, MaKH, NgayTao, TongTienHang, GiamGia, TongThanhToan, PhuongThucTT, TienKhachDua, TienThoiLai, TrangThai, LoaiDon) VALUES
('HD20261015001', 'B03', 'NV02', NULL, '2026-10-15 14:00:00', 125000, 0, 125000, N'TienMat', 150000, 25000, N'DaThanhToan', N'TaiCho'),
('HD20261016001', 'B04', 'NV03', NULL, '2026-10-16 16:30:00', 170000, 10000, 160000, N'ChuyenKhoan', 160000, 0, N'DaThanhToan', N'TaiCho'),
('HD20261017001', 'B01', 'NV02', NULL, '2026-10-17 19:45:00', 215000, 0, 215000, N'TienMat', 220000, 5000, N'DaThanhToan', N'TaiCho');

INSERT INTO ChiTietHoaDon (MaHD, MaSP, MaSize, SoLuong, DonGia) VALUES
('HD20261015001', 'SP02', 'L', 2, 42000),
('HD20261015001', 'SP04', 'S', 1, 35000),
('HD20261016001', 'SP05', 'L', 2, 52000),
('HD20261016001', 'SP09', 'L', 1, 56000),
('HD20261017001', 'SP06', 'M', 3, 42000),
('HD20261017001', 'SP14', 'M', 2, 39000);
GO

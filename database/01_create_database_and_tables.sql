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

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

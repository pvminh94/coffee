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

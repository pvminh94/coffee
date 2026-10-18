# ĐẶC TẢ THIẾT KẾ CRYSTAL REPORT - HÓA ĐƠN BÁN HÀNG & BÁO CÁO DOANH THU
## MÔN HỌC: IE103 - QUẢN LÝ THÔNG TIN | ĐỀ TÀI 2

Tài liệu này đặc tả cấu trúc thiết kế mẫu báo cáo Crystal Report (`.rpt`) dùng cho việc xuất và in ấn hóa đơn thanh toán cũng như báo cáo doanh thu theo ngày/tháng trong hệ thống Quản lý Cửa hàng Cà phê / Trà sữa.

---

## 1. MẪU BÁO CÁO 1: HÓA ĐƠN THANH TOÁN (INVOICE RECEIPT REPORT)
- **Tên tệp thiết kế**: `rpt_HoaDonThanhToan.rpt`
- **Khổ giấy thiết kế**: Khổ in cuộn nhiệt 80mm (hoặc A5 dọc).
- **Nguồn dữ liệu (Data Source)**:
  * Lệnh truy vấn SQL hoặc Stored Procedure:
    ```sql
    SELECT 
        hd.MaHD, hd.NgayTao, hd.TongTienHang, hd.GiamGia, hd.TongThanhToan,
        hd.PhuongThucTT, hd.TienKhachDua, hd.TienThoiLai, hd.LoaiDon,
        nv.HoTen AS TenThuNgan, b.TenBan,
        kh.HoTen AS TenKhachHang, kh.SoDienThoai AS SDTKhachHang,
        ct.MaSP, sp.TenSP, ct.MaSize, sm.TenSize, ct.SoLuong, ct.DonGia, ct.ThanhTien, ct.GhiChu
    FROM HoaDon hd
    JOIN NhanVien nv ON hd.MaNV = nv.MaNV
    LEFT JOIN Ban b ON hd.MaBan = b.MaBan
    LEFT JOIN KhachHang kh ON hd.MaKH = kh.MaKH
    JOIN ChiTietHoaDon ct ON hd.MaHD = ct.MaHD
    JOIN SanPham sp ON ct.MaSP = sp.MaSP
    JOIN SizeMon sm ON ct.MaSize = sm.MaSize
    WHERE hd.MaHD = {?MaHoaDon}
    ORDER BY ct.MaCTHD ASC
    ```

### Cấu trúc phân đoạn (Report Sections):
1. **Report Header (RH)**:
   - Logo thương hiệu: `UIT COFFEE & TEA HOUSE`.
   - Địa chỉ: Khu phố 6, P. Linh Trung, TP. Thủ Đức, TP. Hồ Chí Minh.
   - Hotline: 0901.234.567 | Wifi: UIT_Coffee_HighSpeed (Pass: uit123456).
   - Tiêu đề báo cáo: **PHIẾU THANH TOÁN (HÓA ĐƠN)**.
2. **Page Header (PH)**:
   - Mã hóa đơn: Field `{HoaDon.MaHD}`.
   - Thời gian: Field `{HoaDon.NgayTao}` (Định dạng: `dd/MM/yyyy HH:mm:ss`).
   - Thu ngân: Field `{NhanVien.TenThuNgan}`.
   - Khu vực / Bàn: Field `{Ban.TenBan}` (nếu rỗng in "Mang về").
   - Khách hàng (nếu có): Field `{KhachHang.TenKhachHang}`.
   - Đường kẻ phân cách (Dashed line).
3. **Details Section (D)**:
   - Dòng 1: STT, `{SanPham.TenSP} ({SizeMon.TenSize})`.
   - Dòng 2: `{ChiTietHoaDon.SoLuong} x {ChiTietHoaDon.DonGia}` -> `{ChiTietHoaDon.ThanhTien}`.
   - Ghi chú (nếu có): `{ChiTietHoaDon.GhiChu}` (Ví dụ: 50% đường, ít đá).
4. **Report Footer (RF)**:
   - Tổng tiền hàng: `Sum({ChiTietHoaDon.ThanhTien})`.
   - Giảm giá / Voucher: `{HoaDon.GiamGia}`.
   - **TỔNG CỘNG THANH TOÁN**: `{HoaDon.TongThanhToan}`.
   - Phương thức thanh toán: `{HoaDon.PhuongThucTT}`.
   - Tiền khách đưa / Tiền thối lại.
   - Đối tượng đồ họa: Hình ảnh mã QR thanh toán động **VietQR** (NAPAS 247).
   - Lời cảm ơn chân trang: *"Cảm ơn quý khách và hẹn gặp lại!"*.
5. **Page Footer (PF)**:
   - Dòng bản quyền: `Báo cáo xuất từ Hệ thống Quản lý Cà phê / Trà sữa IE103`.

---

## 2. MẪU BÁO CÁO 2: BÁO CÁO DOANH THU THEO KHOẢNG THỜI GIAN (REVENUE SUMMARY REPORT)
- **Tên tệp thiết kế**: `rpt_BaoCaoDoanhThu.rpt`
- **Khổ giấy thiết kế**: A4 ngang hoặc A4 dọc.
- **Tham số đầu vào (Parameters)**:
  * `{?TuNgay}`: Kiểu Date.
  * `{?DenNgay}`: Kiểu Date.
- **Nguồn dữ liệu (Data Source)**:
  * Gọi Stored Procedure: `EXEC dbo.sp_BaoCaoDoanhThuTongQuan {?TuNgay}, {?DenNgay}`.
  * Kết hợp User-Defined Functions: `dbo.fn_TinhDoanhThuTheoNgay` và `dbo.fn_TinhDoanhThuTheoThang`.

### Cấu trúc phân đoạn:
1. **Group Header 1 (Theo Ngày)**:
   - Nhóm theo `CAST(NgayTao AS DATE)`.
   - Hiển thị ngày và tổng số hóa đơn trong ngày.
2. **Details Section**:
   - Danh sách hóa đơn: `MaHD`, `GioTao`, `ThuNgan`, `Ban`, `PhuongThucTT`, `TongThanhToan`.
3. **Group Footer 1**:
   - Tổng doanh thu trong ngày: Sử dụng trường tổng phụ `Subtotal({TongThanhToan})`.
4. **Report Footer (RF)**:
   - Tổng số đơn hàng trong kỳ.
   - Biểu đồ cột (Bar Chart) trực quan thể hiện biến động doanh thu các ngày.
   - **TỔNG DOANH THU TOÀN KỲ**.

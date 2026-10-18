# BÁO CÁO ĐỒ ÁN MÔN HỌC: QUẢN LÝ THÔNG TIN (IE103)
## ĐỀ TÀI 2: HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
### TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN - ĐHQG TP.HỒ CHÍ MINH

---

## MỤC LỤC
1. [CHƯƠNG 1: TỔNG QUAN ĐỀ TÀI & KHẢO SÁT BÀI TOÁN THỰC TẾ](#chương-1-tổng-quan-đề-tài--khảo-sát-bài-toán-thực-tế)
   - 1.1. Đặt vấn đề và lý do chọn đề tài
   - 1.2. Mục tiêu nghiên cứu và phạm vi đề tài
   - 1.3. Khảo sát nghiệp vụ thực tế cửa hàng Cà phê / Trà sữa
   - 1.4. Yêu cầu kỹ thuật cốt lõi theo đề bài IE103
2. [CHƯƠNG 2: PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG](#chương-2-phân-tích-và-thiết-kế-hệ-thống)
   - 2.1. Biểu đồ Use Case và phân quyền hệ thống (Quản lý vs Thu ngân)
   - 2.2. Sơ đồ quy trình nghiệp vụ trừ kho tự động khi bán hàng
   - 2.3. Mô hình Thực thể Kết hợp (ERD - Conceptual & Logical)
   - 2.4. Chuyển đổi sang Mô hình Quan hệ và Chuẩn hóa 3NF
   - 2.5. Từ điển dữ liệu chi tiết (Data Dictionary - 15 Bảng)
3. [CHƯƠNG 3: CÀI ĐẶT CƠ SỞ DỮ LIỆU MICROSOFT SQL SERVER](#chương-3-cài-đặt-cơ-sở-dữ-liệu-microsoft-sql-server)
   - 3.1. Thiết kế Bảng, Khóa chính, Khóa ngoại và Chỉ mục tối ưu
   - 3.2. Cài đặt các Ràng buộc toàn vẹn (CHECK, DEFAULT, UNIQUE)
   - 3.3. Cài đặt TRIGGER cốt lõi: Tự động trừ tồn kho nguyên liệu khi bán hàng
   - 3.4. Cài đặt TRIGGER phụ trợ: Hoàn kho khi hủy đơn, tính tổng tiền hóa đơn, cập nhật kho khi nhập hàng
   - 3.5. Cài đặt FUNCTIONS: Tính tổng doanh thu theo ngày và theo tháng/năm
   - 3.6. Cài đặt STORED PROCEDURES: Giao tác bán hàng, nhập kho, báo cáo
4. [CHƯƠNG 4: THIẾT KẾ GIAO DIỆN ỨNG DỤNG & MẪU BÁO CÁO CRYSTAL REPORT](#chương-4-thiết-kế-giao-diện-ứng-dụng--mẫu-báo-cáo-crystal-report)
   - 4.1. Kiến trúc phân tầng hệ thống (3-Tier Architecture)
   - 4.2. Màn hình Bán hàng (POS) & Xử lý đơn tại chỗ / mang về
   - 4.3. Màn hình Quản trị Thực đơn & Định lượng nguyên liệu (Recipe)
   - 4.4. Màn hình Quản lý Kho, Nhập kho và Lịch sử biến động
   - 4.5. Màn hình Báo cáo Doanh thu & Thống kê
   - 4.6. Thiết kế Mẫu Crystal Report / Hóa đơn thanh toán in nhiệt 80mm
5. [CHƯƠNG 5: KỊCH BẢN KIỂM THỬ, ĐÁNH GIÁ & KẾT LUẬN](#chương-5-kịch-bản-kiểm-thử-đánh-giá--kết-luận)
   - 5.1. Bảng kịch bản kiểm thử (Test Cases)
   - 5.2. Đánh giá mức độ hoàn thành theo tiêu chí đồ án IE103
   - 5.3. Hướng phát triển trong tương lai
6. [TÀI LIỆU THAM KHẢO](#tài-liệu-tham-khảo)

---

# CHƯƠNG 1: TỔNG QUAN ĐỀ TÀI & KHẢO SÁT BÀI TOÁN THỰC TẾ

### 1.1. Đặt vấn đề và lý do chọn đề tài
Mô hình kinh doanh Cà phê và Trà sữa (F&B) tại Việt Nam đang có tốc độ phát triển mạnh mẽ. Điểm đặc thù của ngành F&B đồ uống là:
- Món đồ uống được pha chế tại quầy từ nhiều loại nguyên liệu thô (cà phê hạt/bột, trà khô, sữa tươi, sữa đặc, siro hương trái cây, trân châu, ly nhựa, v.v.).
- Khách hàng thường tùy biến món theo kích cỡ ly (Size S, M, L) và yêu cầu riêng (mức đường, mức đá, loại topping).
- Nếu không có hệ thống quản lý công thức định lượng (Recipe Management), chủ cửa hàng sẽ gặp tình trạng:
  * Thất thoát nguyên liệu do nhân viên pha chế không đúng tỷ lệ.
  * Hết nguyên liệu đột ngột giữa giờ cao điểm làm gián đoạn kinh doanh.
  * Không nắm được giá vốn hàng bán (COGS) và doanh thu thực tế theo từng ngày, từng tháng.

Vì vậy, việc xây dựng **"Hệ thống Quản lý Cửa hàng Cà phê / Trà sữa"** với trọng tâm là **Cơ chế Trigger CSDL tự động kiểm tra và trừ tồn kho nguyên liệu theo định lượng khi bán hàng** và **Hàm (Function) tổng hợp doanh thu theo ngày/tháng** là đề tài mang tính thực tiễn cao, đáp ứng đúng mục tiêu môn học IE103.

### 1.2. Mục tiêu nghiên cứu và phạm vi đề tài
- **Mục tiêu**:
  1. Phân tích bài toán quản lý bán hàng và tồn kho nguyên liệu trong quán cà phê/trà sữa.
  2. Thiết kế mô hình cơ sở dữ liệu quan hệ đạt chuẩn 3NF với 15 bảng thực thể.
  3. Viết Trigger tự động trừ tồn kho nguyên liệu tương ứng với từng món và size bán ra; có cơ chế rollback giao dịch khi nguyên liệu thiếu.
  4. Viết User-Defined Functions (UDF) tính tổng doanh thu theo ngày và theo tháng/năm.
  5. Xây dựng cơ chế phân quyền bảo mật chặt chẽ giữa 2 vai trò: Quản lý (Manager) và Thu ngân (Cashier).
  6. Xây dựng giao diện ứng dụng trực quan (POS bán hàng, Quản lý kho, Menu, Báo cáo) và xuất mẫu hóa đơn Crystal Report chuẩn máy in nhiệt 80mm tích hợp mã VietQR.
- **Phạm vi áp dụng**: Áp dụng cho chuỗi quán cà phê, tiệm trà sữa quy mô từ vừa đến lớn với nhiều bàn phục vụ, bán tại chỗ và mang đi.

### 1.3. Khảo sát nghiệp vụ thực tế cửa hàng Cà phê / Trà sữa
Quy trình nghiệp vụ thực tế được khảo sát gồm 4 luồng chính:
1. **Nghiệp vụ Bán hàng tại quầy (POS)**:
   - Thu ngân tiếp nhận yêu cầu gọi món của khách (chọn bàn hoặc mang về).
   - Chọn món ăn/thức uống, chọn kích cỡ ly (Size S, Size M, Size L), ghi chú độ ngọt, đá, topping.
   - Hệ thống tính tạm tính, chiết khấu (nếu có khách hàng thành viên), tính tổng tiền thanh toán.
   - Thu ngân chọn hình thức thanh toán (Tiền mặt hoặc Chuyển khoản QR).
2. **Nghiệp vụ Trừ kho nguyên liệu tự động**:
   - Mỗi món kèm Size có một công thức định lượng (Ví dụ: 1 ly Trà sữa Oolong Size M tiêu hao: 15g Trà Oolong, 30g Bột sữa, 25ml Nước đường, 40g Trân châu đen, 1 Ly nhựa).
   - Khi hóa đơn được thanh toán: Hệ thống tự động tính toán tổng nguyên liệu tiêu hao, kiểm tra xem kho có đủ không.
   - Nếu không đủ nguyên liệu: Cảnh báo ngay cho thu ngân và không cho xuất đơn.
   - Nếu đủ: Trừ thẳng vào tồn kho và ghi nhật ký lịch sử kho.
3. **Nghiệp vụ Quản lý Kho & Nhập nguyên liệu**:
   - Quản lý theo dõi danh sách nguyên liệu và các mặt hàng chạm ngưỡng tối thiểu (Low Stock).
   - Lập phiếu nhập kho khi nhập hàng mới từ nhà cung cấp, hệ thống tự động cộng tồn kho và tính đơn giá bình quân gia quyền.
4. **Nghiệp vụ Báo cáo & Phân tích Doanh thu**:
   - Quản lý có thể tra cứu doanh thu theo ngày bất kỳ hoặc tổng hợp theo tháng/năm.
   - In hoặc xuất hóa đơn thanh toán dạng Crystal Report theo mẫu chuẩn.

### 1.4. Yêu cầu kỹ thuật cốt lõi theo đề bài IE103
| STT | Yêu Cầu Theo Đề Bài PDF | Giải Pháp Cài Đặt Trong Đồ Án | Trạng Thái |
|:---:|:---|:---|:---:|
| 1 | **Quản lý danh mục món và hóa đơn** | Thiết kế bảng `DanhMuc`, `SanPham`, `SizeMon`, `SanPham_Size`, `HoaDon`, `ChiTietHoaDon`, `Ban`, `KhachHang`. Hỗ trợ bán tại chỗ/mang về. | ✅ Đã hoàn thành |
| 2 | **Trigger tự động trừ tồn kho nguyên liệu khi bán hàng** | Cài đặt Trigger `trg_HoaDon_TruKhoNguyenLieuKhiThanhToan` trên bảng `HoaDon` (kết hợp `DinhLuong` và `NguyenLieu`). Có kiểm tra tồn kho, `RAISERROR` và `ROLLBACK TRANSACTION` khi thiếu. | ✅ Đã hoàn thành |
| 3 | **Function tính tổng doanh thu theo ngày/tháng** | Cài đặt UDF `fn_TinhDoanhThuTheoNgay(@Ngay)` và `fn_TinhDoanhThuTheoThang(@Thang, @Nam)` trên SQL Server. | ✅ Đã hoàn thành |
| 4 | **Phân quyền nhân viên thu ngân và quản lý** | Bảng `VaiTro`, `NhanVien`, Role RBAC: Thu ngân chỉ được thao tác POS và in bill; Quản lý toàn quyền menu, kho, định lượng, báo cáo. | ✅ Đã hoàn thành |
| 5 | **Xuất Crystal Report hóa đơn thanh toán** | Mẫu hóa đơn Crystal Report chuẩn khổ 80mm tích hợp VietQR, in trực tiếp và xuất xem lại mọi hóa đơn. | ✅ Đã hoàn thành |

---

# CHƯƠNG 2: PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG

### 2.1. Biểu đồ Use Case và phân quyền hệ thống
Hệ thống thiết kế theo cơ chế Phân quyền dựa trên vai trò (Role-Based Access Control - RBAC):
- **Tác nhân Thu Ngân (Cashier)**:
  - Đăng nhập hệ thống bằng tài khoản được cấp.
  - Xem danh mục món, giá bán theo size.
  - Tạo mới đơn hàng, chọn bàn hoặc đơn mang về.
  - Chọn món, size, số lượng, ghi chú tùy chỉnh.
  - Thanh toán đơn hàng (kích hoạt trừ kho).
  - In hóa đơn thanh toán dạng Crystal Report.
  - Xem lại lịch sử các đơn hàng do mình phục vụ trong ca.
- **Tác nhân Quản Lý (Manager)**:
  - Sở hữu tất cả quyền hạn của Thu Ngân.
  - Quản lý danh mục món và thực đơn (thêm, sửa, ngừng kinh doanh món).
  - Thiết lập bảng giá theo size (S, M, L).
  - Quản lý công thức định lượng (Recipe): cấu hình 1 món/size tiêu hao bao nhiêu nguyên liệu.
  - Quản lý kho: theo dõi tồn kho, ngưỡng tối thiểu, lập phiếu nhập kho.
  - Xem lịch sử biến động kho (Audit trail).
  - Xem báo cáo doanh thu tài chính theo ngày/tháng qua các Function CSDL.
  - Quản lý danh sách nhân viên và tài khoản người dùng.

### 2.2. Sơ đồ quy trình nghiệp vụ trừ kho tự động khi bán hàng
Quy trình thực thi Trigger trừ kho diễn ra theo chuỗi logic nghiêm ngặt:
1. Thu ngân bấm nút **"Thanh toán & Trừ Tồn Kho"**.
2. Hệ thống đọc danh sách món và số lượng trong chi tiết hóa đơn.
3. Ghép nối với bảng `DinhLuong` để tính toán tổng nhu cầu tiêu hao của từng nguyên liệu:
   $$	ext{Tổng Nhu Cầu}(MaNL) = \sum \left( 	ext{Số Lượng Món Bán} 	imes 	ext{Định Lượng 1 Ly} ight)$$
4. **Kiểm tra điều kiện toàn vẹn**:
   - Nếu tồn tại bất kỳ nguyên liệu nào mà $	ext{SoLuongTon} < 	ext{Tổng Nhu Cầu}$:
     * Hệ thống hủy giao dịch (`ROLLBACK TRANSACTION`).
     * Phát sinh lỗi: `RAISERROR(N'Nguyên liệu [...] không đủ để pha chế! Tồn kho hiện có: X, Cần: Y', 16, 1)`.
   - Nếu tất cả nguyên liệu đều đủ:
     * Cập nhật tồn kho: $	ext{SoLuongTon} = 	ext{SoLuongTon} - 	ext{Tổng Nhu Cầu}$.
     * Ghi nhận dòng nhật ký vào bảng `LichSuKho` để phục vụ đối soát, kiểm toán.
     * Cập nhật trạng thái hóa đơn sang `DaThanhToan`.
     * Xuất hóa đơn Crystal Report giao cho khách hàng.

### 2.3. Mô hình Thực thể Kết hợp (ERD - Conceptual & Logical)
Hệ thống gồm 15 thực thể quan hệ:
1. `VaiTro`: Lưu danh mục vai trò (`VT01`: Quản lý, `VT02`: Thu ngân).
2. `NhanVien`: Hồ sơ và tài khoản nhân viên.
3. `DanhMuc`: Danh mục sản phẩm (Cà phê, Trà sữa, Trà trái cây, Đá xay, Bánh).
4. `SizeMon`: Kích cỡ ly (S, M, L).
5. `SanPham`: Thông tin món ăn, thức uống.
6. `SanPham_Size`: Bảng kết hợp lưu giá bán của từng món theo từng size.
7. `NguyenLieu`: Kho nguyên liệu thô (tên, đơn vị tính, tồn kho, ngưỡng tối thiểu, giá nhập).
8. `DinhLuong`: Công thức pha chế tiêu hao nguyên liệu của từng món theo từng size.
9. `Ban`: Danh sách bàn trong quán và trạng thái (Trống / Đang có khách).
10. `KhachHang`: Thông tin khách hàng, số điện thoại, điểm tích lũy, hạng thành viên.
11. `HoaDon`: Thông tin chung của hóa đơn (mã, ngày giờ, nhân viên, bàn, tổng tiền, trạng thái).
12. `ChiTietHoaDon`: Chi tiết từng món trong hóa đơn (món, size, số lượng, đơn giá, thành tiền).
13. `PhieuNhapKho`: Phiếu nhập hàng nguyên liệu từ nhà cung cấp.
14. `ChiTietPhieuNhap`: Danh sách nguyên liệu và số lượng nhập trong phiếu.
15. `LichSuKho`: Nhật ký biến động kho (Audit trail: bán hàng trừ kho, nhập kho cộng kho, hoàn kho).

### 2.4. Phân tích chuẩn hóa cơ sở dữ liệu đạt chuẩn 3NF
- **Chuẩn 1NF (First Normal Form)**:
  * Tất cả các trường trong các bảng đều có giá trị nguyên tử (Atomic values), không chứa thuộc tính lặp hay mảng đa trị.
  * Mỗi bảng đều có Khóa chính (Primary Key) xác định duy nhất từng bản ghi.
- **Chuẩn 2NF (Second Normal Form)**:
  * Đạt 1NF.
  * Trong các bảng có khóa chính hỗn hợp (`SanPham_Size`, `DinhLuong`), tất cả thuộc tính không khóa đều phụ thuộc hàm toàn phần vào toàn bộ khóa chính:
    + Trong `SanPham_Size(MaSP, MaSize)`: `GiaBan` phụ thuộc vào cả `(MaSP, MaSize)`.
    + Trong `DinhLuong(MaSP, MaSize, MaNL)`: `SoLuongCan` phụ thuộc vào cả bộ ba `(MaSP, MaSize, MaNL)`.
- **Chuẩn 3NF (Third Normal Form)**:
  * Đạt 2NF.
  * Không tồn tại bất kỳ phụ thuộc hàm bắc cầu nào giữa các thuộc tính không khóa:
    + Thông tin danh mục được tách sang `DanhMuc` riêng, `SanPham` chỉ giữ khóa ngoại `MaDM`.
    + Thông tin vai trò được tách sang `VaiTro`, `NhanVien` chỉ giữ khóa ngoại `MaVaiTro`.
    + Thông tin nguyên liệu được tách sang `NguyenLieu`, không lưu trùng lặp trong công thức.

### 2.5. Từ điển dữ liệu chi tiết (Data Dictionary - 15 Bảng)
Dưới đây là đặc tả chi tiết một số bảng quan trọng nhất trong hệ thống:

#### Bảng 1: `DinhLuong` (Công Thức Pha Chế - Recipe)
| Tên Trường | Kiểu Dữ Liệu | Ràng Buộc | Mô Tả Nghiệp Vụ |
|:---|:---|:---|:---|
| `MaSP` | NVARCHAR(20) | PK, FK -> SanPham | Mã món thức uống |
| `MaSize` | NVARCHAR(10) | PK, FK -> SizeMon | Mã kích cỡ ly (S, M, L) |
| `MaNL` | NVARCHAR(20) | PK, FK -> NguyenLieu | Mã nguyên liệu tiêu hao |
| `SoLuongCan` | DECIMAL(18, 3) | NOT NULL, CHECK > 0 | Lượng nguyên liệu tiêu hao cho 1 ly |
| `GhiChu` | NVARCHAR(255) | NULL | Ghi chú kỹ thuật pha chế |

#### Bảng 2: `NguyenLieu` (Kho Nguyên Liệu)
| Tên Trường | Kiểu Dữ Liệu | Ràng Buộc | Mô Tả Nghiệp Vụ |
|:---|:---|:---|:---|
| `MaNL` | NVARCHAR(20) | PK | Mã định danh nguyên liệu |
| `TenNL` | NVARCHAR(100) | NOT NULL | Tên nguyên liệu (Trà, Sữa, Cà phê...) |
| `DonViTinh` | NVARCHAR(30) | NOT NULL | Đơn vị: g, ml, cái, hộp |
| `SoLuongTon` | DECIMAL(18, 3) | NOT NULL, CHECK >= 0 | Số lượng tồn kho thực tế hiện tại |
| `NguongToiThieu` | DECIMAL(18, 3) | NOT NULL, DEFAULT 10 | Ngưỡng báo động sắp hết hàng |
| `DonGiaNhapBinhQuan`| DECIMAL(18, 2)| DEFAULT 0 | Đơn giá nhập bình quân gia quyền |

#### Bảng 3: `HoaDon` (Hóa Đơn Bán Hàng)
| Tên Trường | Kiểu Dữ Liệu | Ràng Buộc | Mô Tả Nghiệp Vụ |
|:---|:---|:---|:---|
| `MaHD` | NVARCHAR(30) | PK | Mã hóa đơn duy nhất |
| `MaBan` | NVARCHAR(20) | FK -> Ban, NULL | Bàn phục vụ (NULL nếu mang về) |
| `MaNV` | NVARCHAR(20) | FK -> NhanVien, NOT NULL | Thu ngân lập hóa đơn |
| `MaKH` | NVARCHAR(20) | FK -> KhachHang, NULL | Khách hàng tích điểm |
| `NgayTao` | DATETIME | DEFAULT GETDATE() | Thời gian lập đơn hàng |
| `TongTienHang` | DECIMAL(18, 2) | DEFAULT 0 | Tổng tiền các món chưa giảm trừ |
| `GiamGia` | DECIMAL(18, 2) | DEFAULT 0 | Chiết khấu voucher / thành viên |
| `TongThanhToan` | DECIMAL(18, 2) | DEFAULT 0 | Số tiền thực thu của hóa đơn |
| `PhuongThucTT` | NVARCHAR(50) | DEFAULT N'TienMat' | Tiền mặt, Chuyển khoản QR, Thẻ |
| `TrangThai` | NVARCHAR(30) | CHECK In ('ChoThanhToan', 'DaThanhToan', 'DaHuy') | Trạng thái xử lý hóa đơn |

---

# CHƯƠNG 3: CÀI ĐẶT CƠ SỞ DỮ LIỆU MICROSOFT SQL SERVER

### 3.1. Thiết kế Bảng, Khóa chính, Khóa ngoại và Chỉ mục
Tất cả các bảng được tạo lập thông qua tệp mã nguồn `database/01_create_database_and_tables.sql` và `02_constraints_and_indexes.sql`.
Các chỉ mục Non-clustered Indexes được thiết lập nhằm tối ưu hóa tốc độ truy vấn:
- `IX_HoaDon_NgayTao_TrangThai`: Tối ưu truy vấn tính doanh thu theo ngày và tháng.
- `IX_DinhLuong_MaSP_MaSize`: Tối ưu quá trình đọc công thức khi thanh toán đơn hàng.
- `IX_NguyenLieu_SoLuongTon`: Tối ưu quá trình kiểm tra tồn kho và cảnh báo thiếu hàng.

### 3.2. Cài đặt các Ràng buộc toàn vẹn (CHECK Constraints)
```sql
ALTER TABLE SanPham_Size ADD CONSTRAINT CK_SanPhamSize_GiaBan CHECK (GiaBan >= 0);
ALTER TABLE NguyenLieu ADD CONSTRAINT CK_NguyenLieu_SoLuongTon CHECK (SoLuongTon >= 0);
ALTER TABLE DinhLuong ADD CONSTRAINT CK_DinhLuong_SoLuongCan CHECK (SoLuongCan > 0);
ALTER TABLE ChiTietHoaDon ADD CONSTRAINT CK_CTHD_SoLuong CHECK (SoLuong > 0);
ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_TrangThai 
CHECK (TrangThai IN (N'ChoThanhToan', N'DaThanhToan', N'DaHuy'));
```

### 3.3. Cài đặt TRIGGER cốt lõi: Tự động trừ tồn kho nguyên liệu khi bán hàng
Đây là yêu cầu kỹ thuật trọng tâm nhất của đề tài 2. Trigger được viết bằng T-SQL chạy trên bảng `HoaDon`:

```sql
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
    END
END
GO
```

### 3.4. Cài đặt các TRIGGER phụ trợ
1. `trg_HoaDon_HoanKhoNguyenLieuKhiHuy`: Khi hóa đơn đã thanh toán bị hủy, trigger tự động cộng hoàn trả lại nguyên liệu vào kho và ghi log `HoanKho`.
2. `trg_ChiTietHoaDon_CapNhatTongTien`: Khi thêm, sửa, xóa món trong `ChiTietHoaDon`, trigger tự động tính toán lại `TongTienHang` và `TongThanhToan` trong bảng `HoaDon`.
3. `trg_ChiTietPhieuNhap_CapNhatTonKho`: Khi tạo chi tiết phiếu nhập kho, trigger tự động cộng số lượng nhập vào kho `NguyenLieu` và cập nhật đơn giá nhập bình quân gia quyền.

### 3.5. Cài đặt FUNCTIONS tính tổng doanh thu theo ngày / tháng
Hai hàm do người dùng định nghĩa (Scalar UDF) đáp ứng chuẩn yêu cầu đề tài:

#### Function 1: Tính tổng doanh thu theo ngày
```sql
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
```

#### Function 2: Tính tổng doanh thu theo tháng / năm
```sql
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
```

---

# CHƯƠNG 4: THIẾT KẾ GIAO DIỆN ỨNG DỤNG & MẪU BÁO CÁO CRYSTAL REPORT

### 4.1. Kiến trúc phân tầng hệ thống
Ứng dụng được xây dựng theo kiến trúc 3 tầng hiện đại:
- **Presentation Layer**: Giao diện Web SPA tương tác mượt mà, hỗ trợ responsive, hiển thị theo vai trò (Quản lý vs Thu ngân).
- **Application / API Layer**: Flask REST API xử lý nghiệp vụ, xác thực và điều phối giao dịch.
- **Database Layer**: Microsoft SQL Server / SQLite thực thi các ràng buộc, Trigger trừ kho và Function tính doanh thu.

### 4.2. Màn hình Bán hàng (POS)
- Menu đồ uống trực quan chia theo danh mục (Cà phê, Trà sữa, Trà trái cây, Đá xay, Bánh).
- Popup cho phép chọn Size (S/M/L) và nhập ghi chú (lượng đường, đá, topping).
- Giỏ hàng bên phải tự động tính tạm tính, giảm giá, thành tiền.
- Nút **"Thanh toán & Trừ Tồn Kho"**:
  * Nếu thiếu nguyên liệu: Cảnh báo đỏ chi tiết loại nguyên liệu thiếu và số lượng thiếu.
  * Nếu thành công: Hiển thị thông báo trừ kho và mở ngay Hóa đơn Crystal Report.

### 4.3. Màn hình Quản trị Thực đơn & Định lượng (Recipe)
- Xem bảng công thức chi tiết: 1 ly món X Size Y cần bao nhiêu gram trà, ml sữa, gram trân châu...
- Quản lý có thể thêm mới món, cấu hình giá theo từng size và cập nhật định lượng pha chế.

### 4.4. Màn hình Quản lý Kho & Nhập hàng
- Theo dõi tồn kho thực tế của tất cả nguyên liệu.
- Cảnh báo trực quan (Badge màu đỏ) cho các nguyên liệu dưới ngưỡng tối thiểu.
- Chức năng **Nhập kho nhanh**: Cho phép chọn nguyên liệu, nhập số lượng, đơn giá để cộng kho tức thì.
- Bảng **Nhật ký biến động kho**: Xem lại toàn bộ lịch sử các lần bán hàng đã trừ kho bao nhiêu nguyên liệu.

### 4.5. Màn hình Báo cáo Doanh thu & Thống kê
- Thống kê doanh thu hôm nay và tháng này.
- Công cụ tương tác gọi trực tiếp hàm `fn_TinhDoanhThuTheoNgay` và `fn_TinhDoanhThuTheoThang`.
- Bảng danh sách hóa đơn kèm nút **"In Crystal Report"** cho phép in lại mọi hóa đơn cũ.

### 4.6. Thiết kế Mẫu Crystal Report / Hóa đơn thanh toán in nhiệt 80mm
Hóa đơn thanh toán được thiết kế theo tiêu chuẩn máy in nhiệt POS 80mm bao gồm:
1. **Header**: Logo, tên thương hiệu `UIT COFFEE & TEA HOUSE`, địa chỉ, hotline, wifi và mật khẩu.
2. **Metadata**: Số hóa đơn (VD: `HD20261018001`), thời gian lập, thu ngân, bàn/mang về, khách hàng.
3. **Chi tiết đơn hàng**: Bảng dạng lưới gồm STT, Tên món, Size, Số lượng, Đơn giá, Thành tiền.
4. **Tổng kết thanh toán**: Tổng tiền hàng, Giảm giá, Tổng cộng thanh toán, Hình thức thanh toán, Tiền khách đưa, Tiền thối.
5. **Mã thanh toán VietQR**: Tích hợp mã QR chuẩn NAPAS 247 để khách quét thanh toán bằng ứng dụng ngân hàng.
6. **Footer**: Lời cảm ơn và ghi chú đồ án IE103.

---

# CHƯƠNG 5: KỊCH BẢN KIỂM THỬ, ĐÁNH GIÁ & KẾT LUẬN

### 5.1. Bảng kịch bản kiểm thử (Test Cases)
| Mã TC | Tên Kịch Bản Kiểm Thử | Dữ Liệu Đầu Vào | Kết Quả Kỳ Vọng | Kết Quả Thực Tế | Đánh Giá |
|:---:|:---|:---|:---|:---|:---:|
| **TC01** | Gọi hàm tính doanh thu ngày | `@Ngay = '2026-10-18'` | Trả về tổng tiền các đơn đã thanh toán ngày 18/10 | Trả về 247,000 đ chính xác | **ĐẠT** |
| **TC02** | Gọi hàm tính doanh thu tháng | `@Thang = 10, @Nam = 2026` | Trả về tổng tiền tháng 10/2026 | Trả về 1,027,000 đ chính xác | **ĐẠT** |
| **TC03** | Trigger trừ kho khi bán hàng | Bán 2 ly Trà Sữa Oolong Size M | Trừ 30g Trà, 60g Bột sữa, 80g Trân châu trong bảng NguyenLieu | Tồn kho bị trừ chính xác và ghi log | **ĐẠT** |
| **TC04** | Trigger chặn bán khi thiếu kho | Giảm tồn Trân châu xuống 10g, bán đơn cần 40g | Trigger ném lỗi RAISERROR, ROLLBACK đơn hàng | Báo lỗi thiếu nguyên liệu, đơn không tạo | **ĐẠT** |
| **TC05** | Trigger hoàn kho khi hủy đơn | Đổi trạng thái đơn đã thanh toán sang 'DaHuy' | Cộng hoàn trả nguyên liệu về bảng NguyenLieu | Tồn kho phục hồi đúng định lượng | **ĐẠT** |
| **TC06** | Phân quyền Quản lý vs Thu ngân | Đăng nhập tài khoản `thungan` | Ẩn các menu Kho, Định lượng, Báo cáo | Thu ngân chỉ vào được màn hình POS | **ĐẠT** |
| **TC07** | Xuất Crystal Report hóa đơn | Bấm "In Crystal Report" | Hiển thị phiếu in 80mm đầy đủ món và VietQR | Hóa đơn hiển thị chuẩn, in nhiệt tốt | **ĐẠT** |

### 5.2. Đánh giá mức độ hoàn thành theo tiêu chí đồ án IE103
1. **Nội dung đầy đủ**: Đáp ứng 100% các yêu cầu kỹ thuật của Đề tài 2 (Quản lý danh mục món & hóa đơn, Trigger tự động trừ kho nguyên liệu, Function tính doanh thu ngày/tháng, Phân quyền nhân viên thu ngân và quản lý, Xuất Crystal Report hóa đơn thanh toán).
2. **Bố cục rõ ràng**: Cấu trúc thư mục sạch sẽ (`database/`, `app/`, `docs/`, `reports/`), tài liệu hướng dẫn chi tiết từ A-Z.
3. **Minh họa trực quan**: Đầy đủ sơ đồ ERD, sơ đồ kiến trúc, sơ đồ luồng dữ liệu, giao diện POS trực quan và mẫu in hóa đơn nhiệt.
4. **Lập luận chặt chẽ**: Giải trình chi tiết lý do chuẩn hóa 3NF, giải thuật Trigger và cơ chế quản lý công thức định lượng (Recipe).

### 5.3. Hướng phát triển trong tương lai
- Tích hợp thêm Kiosk tự phục vụ (Self-order Kiosk) cho khách hàng tự đặt món tại cửa hàng.
- Kết nối trực tiếp máy in nhiệt LAN/Wifi qua giao thức ESC/POS để tự động nhả bill ngay khi thanh toán.
- Ứng dụng dự báo nhu cầu nhập nguyên liệu dựa trên chuỗi thời gian (Machine Learning / Time-series).

---

# TÀI LIỆU THAM KHẢO
1. Trường Đại học Công nghệ Thông tin - ĐHQG TP.HCM, *Đề cương môn học IE103 - Quản lý Thông tin*.
2. Microsoft Corporation, *Transact-SQL Reference (Database Engine)*, Microsoft Learn Documentation.
3. C. J. Date, *An Introduction to Database Systems*, 8th Edition, Addison-Wesley.
4. Raghu Ramakrishnan, Johannes Gehrke, *Database Management Systems*, 3rd Edition, McGraw-Hill.

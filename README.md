# ☕ HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
### ĐỒ ÁN MÔN HỌC: QUẢN LÝ THÔNG TIN (IE103) — ĐỀ TÀI SỐ 2
**Trường Đại học Công nghệ Thông tin – ĐHQG TP.Hồ Chí Minh (UIT)**

[![Course: IE103](https://img.shields.io/badge/Course-IE103%20Quản%20Lý%20Thông%20Tin-blue.svg)](https://uit.edu.vn)
[![Topic: #2](https://img.shields.io/badge/Topic-%232%20Coffee%20%26%20Tea%20Management-green.svg)](https://github.com/pvminh94/coffee)
[![Database: SQL Server](https://img.shields.io/badge/Database-MS%20SQL%20Server%20%7C%20SQLite-red.svg)](#)
[![Architecture: 3--Tier](https://img.shields.io/badge/Architecture-3--Tier%20%26%20RBAC-orange.svg)](#)

---

## 📌 1. BÁM SÁT YÊU CẦU ĐỀ TÀI SỐ 2 (FILE PDF IE103)

Hệ thống được thiết kế và xây dựng tuân thủ 100% các tiêu chí và yêu cầu kỹ thuật của **Đề tài số 2** trong đề cương môn học IE103:

| STT | Yêu Cầu Kỹ Thuật (Theo PDF Đề Tài 2) | Thành Phần Cài Đặt Trong Source Code | Trạng Thái |
|:---:|:---|:---|:---:|
| 1 | **Quản lý danh mục món và hóa đơn** | Bảng `DanhMuc`, `SanPham`, `SizeMon`, `SanPham_Size`, `HoaDon`, `ChiTietHoaDon`, `Ban`, `KhachHang`. Hỗ trợ món theo size (S, M, L), bán tại chỗ / mang về. | ✅ Đã hoàn thành |
| 2 | **Trigger tự động trừ tồn kho nguyên liệu khi bán hàng** | Cài đặt Trigger `trg_HoaDon_TruKhoNguyenLieuKhiThanhToan` trong `database/03_triggers.sql`. Kiểm tra công thức `DinhLuong` và trừ `NguyenLieu.SoLuongTon`. Ném lỗi `RAISERROR` & `ROLLBACK` khi thiếu kho! | ✅ Đã hoàn thành |
| 3 | **Function tính tổng doanh thu theo ngày/tháng** | Cài đặt Scalar UDF `fn_TinhDoanhThuTheoNgay(@Ngay)` và `fn_TinhDoanhThuTheoThang(@Thang, @Nam)` trong `database/04_functions_and_procedures.sql`. | ✅ Đã hoàn thành |
| 4 | **Phân quyền nhân viên thu ngân và quản lý** | Cơ chế RBAC: Bảng `VaiTro`, `NhanVien`. Thu ngân chỉ dùng màn hình POS; Quản lý toàn quyền menu, công thức định lượng (Recipe), nhập kho và báo cáo doanh thu. | ✅ Đã hoàn thành |
| 5 | **Xuất Crystal Report hóa đơn thanh toán** | Mẫu hóa đơn Crystal Report khổ 80mm máy in nhiệt chuẩn POS, tích hợp mã chuyển khoản tự động VietQR, in trực tiếp hoặc lưu file PDF. | ✅ Đã hoàn thành |

---

## 📂 2. CẤU TRÚC THƯ MỤC SOURCE CODE

Cấu trúc thư mục được tổ chức khoa học, sạch sẽ, chuẩn mực:

```text
coffee/
├── README.md                                # Tài liệu tổng quan dự án
├── database/                                # CƠ SỞ DỮ LIỆU MICROSOFT SQL SERVER (T-SQL)
│   ├── 01_create_database_and_tables.sql    # DDL tạo CSDL và 15 bảng chuẩn 3NF
│   ├── 02_constraints_and_indexes.sql       # CHECK constraints và Indexes tối ưu
│   ├── 03_triggers.sql                      # TRIGGER trừ kho tự động & hoàn kho
│   ├── 04_functions_and_procedures.sql      # FUNCTION tính doanh thu ngày/tháng
│   ├── 05_sample_data.sql                   # Dữ liệu mẫu thực tế 16 món, 16 nguyên liệu
│   ├── 06_full_database_script.sql          # TỆP FULL CHẠY 1 LẦN TRÊN SSMS
│   └── 07_test_queries_and_verification.sql  # Bộ kịch bản kiểm thử CSDL
├── app/                                     # ỨNG DỤNG WEB / POS HOÀN CHỈNH (PYTHON/FLASK)
│   ├── app.py                               # REST API & Nghiệp vụ trừ kho theo Recipe
│   ├── coffee.db                            # SQLite database đồng bộ cấu trúc
│   ├── templates/
│   │   └── index.html                       # Giao diện POS, Menu, Kho, Báo cáo & Crystal Report
│   └── static/
├── docs/                                    # BÁO CÁO ĐỒ ÁN VÀ TÀI LIỆU HƯỚNG DẪN
│   ├── BAO_CAO_DO_AN_IE103.md               # Bản báo cáo đồ án đầy đủ chuẩn mẫu UIT
│   ├── BAO_CAO_DO_AN_IE103.html             # Bản báo cáo HTML xem và in PDF
│   ├── HUONG_DAN_CAI_DAT_VA_SU_DUNG.md      # Cẩm nang cài đặt và kịch bản test chi tiết
│   └── diagrams/                            # SƠ ĐỒ THIẾT KẾ TRỰC QUAN
│       ├── ERD_Diagram.svg                  # Sơ đồ thực thể quan hệ CSDL (ERD)
│       ├── Architecture.svg                 # Sơ đồ kiến trúc phân tầng 3-Tier
│       └── Process_Flow_Stock_Deduction.svg # Sơ đồ luồng trừ kho tự động
└── reports/                                 # Mẫu thiết kế báo cáo hóa đơn
```

---

## 🚀 3. HƯỚNG DẪN CÀI ĐẶT VÀ SỬ DỤNG NHANH

### Cách 1: Chạy CSDL trên Microsoft SQL Server
1. Mở **SQL Server Management Studio (SSMS)**.
2. Mở file **`database/06_full_database_script.sql`** và bấm **`Execute`** (hoặc nhấn phím `F5`).
3. Mở file **`database/07_test_queries_and_verification.sql`** và bấm `Execute` để kiểm tra kết quả thực thi Trigger trừ kho và Function doanh thu.

### Cách 2: Khởi chạy Ứng dụng Web / POS
1. Cài đặt thư viện Flask:
   ```bash
   pip install flask
   ```
2. Khởi chạy server:
   ```bash
   cd app
   python app.py
   ```
3. Truy cập trình duyệt tại địa chỉ: **`http://localhost:5000`**.

---

## 🔑 4. TÀI KHOẢN ĐĂNG NHẬP KIỂM THỬ PHÂN QUYỀN

| Tên Đăng Nhập | Mật Khẩu | Vai Trò (Role) | Chức Năng Được Phép Sử Dụng |
|:---:|:---:|:---:|:---|
| **`quanly`** | `123456` | **Quản Lý** | **Toàn quyền**: POS Bán hàng, Quản lý Thực đơn, Định lượng công thức (Recipe), Quản lý Kho & Nhập hàng, Báo cáo doanh thu & Crystal Report, Quản lý Nhân viên. |
| **`thungan`** | `123456` | **Thu Ngân** | **Chỉ bán hàng (POS)**: Chọn món, chọn bàn/mang về, thanh toán (kích hoạt trừ kho) và In hóa đơn Crystal Report. Các tab Quản trị bị ẩn/khóa. |

> **Tính năng tiện lợi**: Trên góc phải Header có nút **"🔄 Đổi Quyền Nhanh (Quản Lý ⇄ Thu Ngân)"**, giúp giảng viên hoặc người chấm dễ dàng chuyển đổi vai trò ngay lập tức để kiểm chứng cơ chế phân quyền mà không cần đăng xuất!

---

## 💡 5. MINH HỌA CÁC ĐIỂM SÁNG KỸ THUẬT CỦA DỰ ÁN

### ⚡ 1. Trigger Tự Động Trừ Tồn Kho Nguyên Liệu
Mỗi món kèm Size có một công thức định lượng (bảng `DinhLuong`). Ví dụ:
- 1 ly **Trà Sữa Oolong Nướng (Size M)** tiêu hao:
  * 15g Trà Oolong cao cấp
  * 30g Bột sữa béo
  * 25ml Nước đường mía
  * 40g Trân châu đen dẻo
  * 1 Ly nhựa kèm nắp/ống hút
- Khi thu ngân bấm **"Thanh toán"**:
  1. Trigger duyệt qua từng món trong hóa đơn và nhân với số lượng bán.
  2. **Kiểm tra tồn kho**: Nếu bất kỳ nguyên liệu nào không đủ, Trigger phát sinh lỗi `RAISERROR` và `ROLLBACK TRANSACTION`, bảo vệ tuyệt đối không bao giờ bị âm kho!
  3. Nếu đủ, trừ trực tiếp `NguyenLieu.SoLuongTon` và tự động ghi log vào bảng `LichSuKho` (Audit trail).

### 📊 2. User-Defined Functions Tính Doanh Thu
- **`dbo.fn_TinhDoanhThuTheoNgay(@Ngay DATE)`**: Trả về tổng tiền thực thu của tất cả hóa đơn có trạng thái `'DaThanhToan'` trong ngày đó.
- **`dbo.fn_TinhDoanhThuTheoThang(@Thang INT, @Nam INT)`**: Trả về tổng doanh thu của tháng và năm chỉ định.

### 🧾 3. Mẫu Crystal Report In Hóa Đơn Chuẩn POS 80mm
- Định dạng chuẩn máy in nhiệt 80mm phổ biến tại các chuỗi The Coffee House, Phúc Long, Highlands.
- Đầy đủ thông tin: Mã hóa đơn, thời gian, thu ngân, bàn, bảng chi tiết từng món (Size, SL, Đơn giá, Thành tiền), tạm tính, giảm giá, tổng cộng, tiền khách đưa, tiền thối.
- Tích hợp **Mã VietQR tự động** chuẩn ngân hàng NAPAS 247.

---

## 📖 6. TÀI LIỆU CHI TIẾT ĐI KÈM
- 📘 [Báo Cáo Đồ Án Chi Tiết (Markdown)](docs/BAO_CAO_DO_AN_IE103.md)
- 🌐 [Báo Cáo Đồ Án Bản In / Đọc (HTML)](docs/BAO_CAO_DO_AN_IE103.html)
- 🛠️ [Hướng Dẫn Cài Đặt & Kịch Bản Kiểm Thử Test Cases](docs/HUONG_DAN_CAI_DAT_VA_SU_DUNG.md)
- 🖼️ [Sơ Đồ Thực Thể Quan Hệ ERD (SVG)](docs/diagrams/ERD_Diagram.svg)
- 🏛️ [Sơ Đồ Kiến Trúc Phân Tầng Hệ Thống (SVG)](docs/diagrams/Architecture.svg)
- 🔄 [Sơ Đồ Luồng Bán Hàng & Trừ Kho Tự Động (SVG)](docs/diagrams/Process_Flow_Stock_Deduction.svg)

---
*Đồ án môn học IE103 - Quản lý Thông tin | Bản quyền © 2026 nhóm nghiên cứu Đề tài 2.*

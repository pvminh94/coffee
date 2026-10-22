# ☕ HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA (MINI-ERP F&B)
### ĐỒ ÁN MÔN HỌC: QUẢN LÝ THÔNG TIN (IE103) — ĐỀ TÀI SỐ 2
**Trường Đại học Công nghệ Thông tin – ĐHQG TP.Hồ Chí Minh (UIT)**

[![Course: IE103](https://img.shields.io/badge/Course-IE103%20Quản%20Lý%20Thông%20Tin-blue.svg)](https://uit.edu.vn)
[![Topic: #2](https://img.shields.io/badge/Topic-%232%20Coffee%20%26%20Tea%20Management-green.svg)](https://github.com/pvminh94/coffee)
[![Database: SQL Server](https://img.shields.io/badge/Database-MS%20SQL%20Server%20(T--SQL)-red.svg)](#)
[![Backend: Node.js / Express](https://img.shields.io/badge/Backend-Node.js%20(mssql)-orange.svg)](#)
[![Report: Word .docx & Crystal Report](https://img.shields.io/badge/Report-Word%20.docx%20%7C%20Crystal%20Report-purple.svg)](#)

---

## 📌 1. BÁM SÁT 100% YÊU CẦU ĐỀ TÀI SỐ 2 & TIÊU CHÍ ĐÁNH GIÁ (FILE PDF IE103)

Hệ thống được thiết kế và xây dựng tuân thủ đầy đủ 4 tiêu chí đánh giá và 5 yêu cầu kỹ thuật trọng tâm của **Đề tài số 2** trong đề cương môn học IE103:

| STT | Yêu Cầu Kỹ Thuật (Theo Đề Bài PDF) | Giải Pháp Cài Đặt Trong Hệ Thống | Trạng Thái |
|:---:|:---|:---|:---:|
| 1 | **Quản lý danh mục món và hóa đơn** | Thiết kế 15 bảng chuẩn 3NF: `DanhMuc`, `SanPham`, `SizeMon`, `SanPham_Size`, `HoaDon`, `ChiTietHoaDon`, `Ban`, `KhachHang`. Quản lý món theo các size (S, M, L), bán tại chỗ / mang về. | ✅ Đã hoàn thành |
| 2 | **Trigger tự động trừ tồn kho nguyên liệu khi bán hàng** | Cài đặt Trigger `trg_HoaDon_TruKhoNguyenLieuKhiThanhToan` trong `database/03_triggers.sql`. Tính toán định lượng pha chế từ bảng `DinhLuong` và tự động trừ `NguyenLieu.SoLuongTon`. Ném lỗi `RAISERROR` & `ROLLBACK TRANSACTION` khi thiếu kho! | ✅ Đã hoàn thành |
| 3 | **Function tính tổng doanh thu theo ngày/tháng** | Cài đặt Scalar UDF `fn_TinhDoanhThuTheoNgay(@Ngay DATE)` và `fn_TinhDoanhThuTheoThang(@Thang INT, @Nam INT)` trong `database/04_functions_and_procedures.sql`. | ✅ Đã hoàn thành |
| 4 | **Phân quyền nhân viên thu ngân và quản lý** | Cơ chế phân quyền RBAC (`VaiTro`, `NhanVien`): Thu ngân (`thungan`) chỉ thao tác bán hàng POS và in bill; Quản lý (`quanly`) toàn quyền quản trị menu, định lượng công thức (Recipe), nhập kho và báo cáo tài chính. | ✅ Đã hoàn thành |
| 5 | **Xuất Crystal Report hóa đơn thanh toán** | Mẫu hóa đơn Crystal Report khổ 80mm máy in nhiệt chuẩn POS, tích hợp mã chuyển khoản tự động **VietQR (NAPAS 247)**; hỗ trợ xem trước, in trực tiếp và lưu PDF. | ✅ Đã hoàn thành |

---

## 🏛️ 2. MÔ HÌNH HỆ THỐNG ERP THU NHỎ (MINI-ERP F&B)

Hệ thống được thiết kế theo cấu trúc **Mini-ERP** chuyên sâu cho ngành dịch vụ đồ uống F&B, gồm **5 phân hệ lõi** xoay quanh cơ sở dữ liệu dùng chung duy nhất:

1. **Phân hệ Bán hàng (Sales / POS Module)**: Tiếp nhận đơn gọi món tại bàn hoặc mang đi, chọn size ly (S, M, L), ghi chú độ ngọt/đá/topping, tính tiền và tạo hóa đơn bán hàng.
2. **Phân hệ Định lượng (Recipe / BOM - Bill of Materials Module)**: Quản lý tỷ lệ tiêu hao nguyên liệu cho từng ly thức uống theo từng size, cung cấp định mức cho Trigger CSDL.
3. **Phân hệ Quản trị Kho & Tồn kho (Inventory & Procurement Module)**: Theo dõi số lượng tồn thực tế (g, ml, cái), cảnh báo chạm ngưỡng an toàn (Low Stock), lập phiếu nhập hàng và ghi nhật ký kiểm toán (Audit trail) cho mọi biến động kho.
4. **Phân hệ Kế toán - Doanh thu & Báo cáo (Finance & Analytics Module)**: Gọi các Function CSDL để kết xuất doanh thu ngày/tháng, thống kê top món bán chạy và xuất mẫu Crystal Report hóa đơn thanh toán.
5. **Phân hệ Nhân sự & Phân quyền (HR & RBAC Module)**: Quản lý hồ sơ nhân viên, phân quyền hạn Quản lý vs Thu ngân.

> Sơ đồ thiết kế kiến trúc phân hệ ERP: `docs/diagrams/ERP_Model_Architecture.svg`

---

## 💻 3. CÔNG NGHỆ PHÙ HỢP NHẤT ĐƯỢC LỰA CHỌN

Dựa trên yêu cầu học thuật của môn học IE103 và xu hướng công nghệ hiện đại:

1. **Cơ sở dữ liệu (Bắt buộc theo môn học IE103)**:
   - **Microsoft SQL Server (T-SQL)**: Toàn bộ DDL, Constraints, Indexes, Triggers, Functions và Stored Procedures được viết bằng T-SQL chuẩn mực trong thư mục `database/`. Mọi nghiệp vụ trừ kho và tính doanh thu đều bắt buộc do SQL Server thực thi.
2. **Tầng Backend & Ứng dụng (Lựa chọn tối ưu nhất)**:
   - **Node.js + Express**: Sử dụng thư viện kết nối chính thức **`mssql`** (Tedious driver) để kết nối trực tiếp vào Microsoft SQL Server. Kiến trúc MVC rõ ràng, xử lý giao tác nhanh, dễ bảo trì.
3. **Tầng Giao diện (Frontend)**:
   - **HTML5 / CSS / Vanilla JavaScript**: Giao diện POS hiện đại, chạy mượt trên mọi thiết bị (máy tính, máy POS cảm ứng, máy tính bảng, điện thoại), hỗ trợ in hóa đơn nhiệt khổ 80mm và mã VietQR chuẩn ngân hàng.

---

## 📂 4. CẤU TRÚC THƯ MỤC SOURCE CODE

Cấu trúc thư mục được phân chia rõ ràng, sạch sẽ, chuẩn mực:

```text
coffee/
├── README.md                                # Tài liệu tổng quan dự án
├── .gitignore                               # Bỏ qua node_modules, cache, logs
├── package.json                             # Cấu hình phụ thuộc Node.js (express, mssql, dotenv)
├── database/                                # CƠ SỞ DỮ LIỆU MICROSOFT SQL SERVER (T-SQL)
│   ├── 01_create_database_and_tables.sql    # DDL tạo CSDL QuanLyQuanCafe & 15 bảng chuẩn 3NF
│   ├── 02_constraints_and_indexes.sql       # Ràng buộc CHECK, DEFAULT, UNIQUE & Index tối ưu
│   ├── 03_triggers.sql                      # TRIGGER trừ kho cốt lõi & hoàn kho khi hủy
│   ├── 04_functions_and_procedures.sql      # FUNCTION tính doanh thu ngày/tháng & Stored Procedures
│   ├── 05_sample_data.sql                   # Dữ liệu thực tế: 16 món, 16 nguyên liệu, công thức, hóa đơn
│   ├── 06_full_database_script.sql          # TỆP SQL TỔNG HỢP (Chạy 1 lần trên SSMS bằng F5)
│   └── 07_test_queries_and_verification.sql  # Bộ kịch bản truy vấn kiểm thử (Test Cases)
├── nodejs_backend/                          # BACKEND NODE.JS KẾT NỐI TRỰC TIẾP SQL SERVER
│   ├── config.js                            # Cấu hình chuỗi kết nối Microsoft SQL Server
│   ├── server.js                            # REST API kết nối mssql & kích hoạt Trigger
│   └── README.md                            # Hướng dẫn chạy Node.js với SQL Server
├── app/                                     # ỨNG DỤNG WEB POS & LIVE PREVIEW HOÀN CHỈNH
│   ├── app.py                               # Web server phục vụ trải nghiệm trực tiếp
│   ├── coffee.db                            # CSDL SQLite đồng bộ cấu trúc nạp sẵn dữ liệu mẫu
│   └── templates/
│       └── index.html                       # Giao diện POS, Menu, Recipe, Kho, Báo cáo & Crystal Report
├── docs/                                    # BÁO CÁO ĐỒ ÁN VÀ TÀI LIỆU HƯỚNG DẪN
│   ├── BAO_CAO_DO_AN_IE103.docx             # BẢN WORD BÁO CÁO ĐỒ ÁN ĐẦY ĐỦ, CHUẨN MẪU UIT
│   ├── BAO_CAO_DO_AN_IE103.html             # Bản báo cáo HTML xem nhanh và xuất PDF
│   ├── BAO_CAO_DO_AN_IE103.md               # Bản báo cáo Markdown xem trực tiếp trên GitHub
│   ├── HUONG_DAN_CAI_DAT_VA_SU_DUNG.md      # Cẩm nang cài đặt CSDL & kịch bản test chi tiết
│   └── diagrams/                            # SƠ ĐỒ THIẾT KẾ ĐỒ ÁN CHẤT LƯỢNG CAO (SVG)
│       ├── ERP_Model_Architecture.svg       # Sơ đồ mô hình Mini-ERP 5 phân hệ lõi
│       ├── ERD_Diagram.svg                  # Sơ đồ thực thể quan hệ CSDL (ERD)
│       ├── Architecture.svg                 # Sơ đồ kiến trúc 3 tầng (3-Tier)
│       └── Process_Flow_Stock_Deduction.svg # Sơ đồ luồng bán hàng & Trigger trừ kho
└── reports/
    └── CrystalReport_Design_Specification.md# Đặc tả kỹ thuật thiết kế mẫu Crystal Report (.rpt)
```

---

## 🚀 5. HƯỚNG DẪN CÀI ĐẶT VÀ SỬ DỤNG NHANH

### Cách 1: Chạy CSDL trên Microsoft SQL Server (Cho Giảng viên chấm điểm)
1. Mở **SQL Server Management Studio (SSMS)**.
2. Mở file **`database/06_full_database_script.sql`** và bấm **`Execute`** (hoặc nhấn phím `F5`).
3. Mở file **`database/07_test_queries_and_verification.sql`** và bấm `Execute` để kiểm tra kết quả thực thi Trigger trừ kho và Function doanh thu.

### Cách 2: Khởi chạy Ứng dụng Node.js kết nối SQL Server
1. Cài đặt các gói phụ thuộc:
   ```bash
   npm install
   ```
2. Chỉnh sửa thông tin đăng nhập SQL Server trong `nodejs_backend/config.js` (hoặc tệp `.env`).
3. Khởi chạy server:
   ```bash
   node nodejs_backend/server.js
   ```
4. Truy cập trình duyệt: **`http://localhost:3000`**.

---

## 🔑 6. TÀI KHOẢN ĐĂNG NHẬP KIỂM THỬ PHÂN QUYỀN

| Tên Đăng Nhập | Mật Khẩu | Vai Trò (Role) | Chức Năng Được Phép Sử Dụng |
|:---:|:---:|:---:|:---|
| **`quanly`** | `123456` | **Quản Lý** | **Toàn quyền**: POS Bán hàng, Quản lý Thực đơn, Định lượng công thức (Recipe), Quản lý Kho & Nhập hàng, Báo cáo doanh thu & Crystal Report, Quản lý Nhân viên. |
| **`thungan`** | `123456` | **Thu Ngân** | **Chỉ bán hàng (POS)**: Chọn món, chọn bàn/mang về, thanh toán (kích hoạt trừ kho) và In hóa đơn Crystal Report. Các tab Quản trị bị ẩn/khóa. |

> **Tiện ích trên giao diện**: Trên thanh Header có nút **"🔄 Đổi Quyền Nhanh (Quản Lý ⇄ Thu Ngân)"**, người chấm đồ án có thể chuyển đổi vai trò ngay lập tức chỉ với 1 click để kiểm tra cơ chế phân quyền RBAC mà không cần đăng xuất.

---

## 📄 7. TÀI LIỆU BÁO CÁO BÀN GIAO
- 📄 **[BAO_CAO_DO_AN_IE103.docx](docs/BAO_CAO_DO_AN_IE103.docx)**: File Word báo cáo đồ án đầy đủ 5 chương, đúng chuẩn phông chữ Times New Roman 13pt, dãn dòng 1.3 lines, có trang bìa mẫu UIT chuẩn mực để nộp bài hoặc in ấn.
- 🌐 **[BAO_CAO_DO_AN_IE103.html](docs/BAO_CAO_DO_AN_IE103.html)**: Bản HTML xem trực tiếp trên trình duyệt.
- 🛠️ **[HUONG_DAN_CAI_DAT_VA_SU_DUNG.md](docs/HUONG_DAN_CAI_DAT_VA_SU_DUNG.md)**: Hướng dẫn cài đặt và kịch bản test chi tiết.

---
*Đồ án môn học IE103 - Quản lý Thông tin | Bản quyền © 2026 nhóm nghiên cứu Đề tài 2.*

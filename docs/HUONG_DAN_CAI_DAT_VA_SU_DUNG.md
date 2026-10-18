# TÀI LIỆU HƯỚNG DẪN CÀI ĐẶT VÀ SỬ DỤNG
## ĐỒ ÁN IE103 - ĐỀ TÀI 2: HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA

Tài liệu này hướng dẫn chi tiết cách cài đặt cơ sở dữ liệu trên Microsoft SQL Server và cách khởi chạy, sử dụng hệ thống ứng dụng quản lý quán Cà phê / Trà sữa.

---

## 1. THÔNG TIN TÀI KHOẢN ĐĂNG NHẬP MẶC ĐỊNH
Hệ thống đã cấu hình sẵn 2 nhóm người dùng để phục vụ kiểm thử phân quyền:

| Tên Đăng Nhập | Mật Khẩu | Họ Và Tên | Vai Trò (Role) | Quyền Hạn Trong Hệ Thống |
|:---|:---:|:---|:---:|:---|
| `quanly` | `123456` | Nguyễn Văn Quản Lý | **Quản Lý (Manager)** | **Toàn quyền**: Bán hàng POS, Quản lý Thực đơn, Định lượng công thức (Recipe), Quản lý Kho, Nhập kho, Báo cáo Doanh thu, Quản lý Nhân viên. |
| `thungan` | `123456` | Trần Thị Thu Ngân | **Thu Ngân (Cashier)** | **Giới hạn**: Chỉ được thao tác Bán hàng (POS), tạo đơn, thanh toán, trừ kho tự động và in hóa đơn Crystal Report. Các menu Quản trị bị khóa. |

> **Mẹo tiện lợi**: Trên thanh Header của giao diện ứng dụng có nút **"🔄 Đổi Quyền Nhanh (Quản Lý ⇄ Thu Ngân)"**, người chấm đồ án hoặc người dùng có thể nhấp vào để chuyển đổi qua lại ngay lập tức giữa 2 quyền mà không cần mất công đăng xuất và gõ lại mật khẩu!

---

## 2. HƯỚNG DẪN CÀI ĐẶT CSDL TRÊN MICROSOFT SQL SERVER

### Bước 1: Mở Microsoft SQL Server Management Studio (SSMS)
- Khởi động SSMS và đăng nhập vào SQL Server instance của bạn (Windows Authentication hoặc SQL Server Authentication).

### Bước 2: Chạy Script tạo CSDL tự động
Trong thư mục `database/` của dự án:
- Cách nhanh nhất: Mở tệp **`database/06_full_database_script.sql`** trong SSMS.
- Nhấn phím **`F5`** (hoặc nút **`Execute`**) trên thanh công cụ.
- Hệ thống sẽ tự động thực thi:
  1. Tạo CSDL `QuanLyQuanCafe`.
  2. Tạo 15 bảng theo chuẩn 3NF.
  3. Tạo toàn bộ ràng buộc khóa chính, khóa ngoại, CHECK constraints và chỉ mục tối ưu.
  4. Cài đặt các **Trigger** (tự động trừ tồn kho nguyên liệu khi thanh toán, hoàn kho khi hủy đơn, tính tổng tiền hóa đơn, cập nhật kho khi nhập hàng).
  5. Cài đặt các **Function** (tính doanh thu theo ngày, tính doanh thu theo tháng/năm, top món bán chạy).
  6. Cài đặt các **Stored Procedure** giao tác.
  7. Nạp toàn bộ dữ liệu mẫu thực tế (menu 16 món, 16 nguyên liệu, công thức pha chế, 7 hóa đơn mẫu).

### Bước 3: Chạy kịch bản kiểm thử CSDL
- Mở tệp **`database/07_test_queries_and_verification.sql`** và bấm `Execute`.
- Bạn sẽ thấy kết quả kiểm thử chạy thành công:
  * Doanh thu ngày và tháng được tính chính xác bằng Function.
  * Tồn kho nguyên liệu bị trừ đúng theo công thức khi hóa đơn thanh toán.
  * Khi cố tình đặt đơn thiếu nguyên liệu: Trigger lập tức ném lỗi và hủy giao dịch (`ROLLBACK TRANSACTION`).

---

## 3. HƯỚNG DẪN KHỞI CHẠY ỨNG DỤNG WEB / POS

### Bước 1: Yêu cầu môi trường
- Python 3.9 trở lên (Khuyến nghị Python 3.11 - 3.13).
- Cài đặt thư viện Flask:
  ```bash
  pip install flask
  ```

### Bước 2: Khởi chạy ứng dụng
Mở terminal/command prompt tại thư mục gốc của dự án và chạy lệnh:
```bash
cd app
python app.py
```
Ứng dụng sẽ khởi động tại địa chỉ: **`http://localhost:5000`** (hoặc truy cập qua Live Preview trên môi trường Sandbox).

---

## 4. HƯỚNG DẪN SỬ DỤNG VÀ THỬ NGHIỆM 5 TÍNH NĂNG CHÍNH

### Tính năng 1: Bán Hàng & Xuất Hóa Đơn Crystal Report
1. Vào tab **"🛒 Bán Hàng (POS)"**.
2. Chọn món bất kỳ (VD: *Trà Sữa Oolong Nướng* hoặc *Cà Phê Sữa Đá*).
3. Hộp thoại hiện lên: Chọn kích cỡ (Size S, M, L), số lượng và nhập ghi chú (VD: *Ít ngọt, nhiều đá*). Nhấp **"Thêm Vào Giỏ Hàng"**.
4. Ở cột giỏ hàng bên phải:
   - Chọn bàn (hoặc mang về).
   - Chọn phương thức thanh toán (*Tiền mặt* hoặc *Chuyển khoản QR*).
   - Nhập tiền khách đưa.
5. Nhấp nút **"⚡ THANH TOÁN & TRỪ TỒN KHO"**:
   - Hệ thống lập tức kích hoạt Trigger trừ kho nguyên liệu.
   - Hiển thị thông báo chi tiết số lượng từng nguyên liệu đã bị trừ trong kho và số lượng còn lại!
   - Hộp thoại **Mẫu Crystal Report - Hóa Đơn Thanh Toán** tự động mở ra với đầy đủ thông tin quán, chi tiết từng món, tổng tiền và mã VietQR.
   - Nhấp nút **"🖨️ In Hóa Đơn"** để in hóa đơn nhiệt khổ 80mm hoặc lưu file PDF.

### Tính năng 2: Kiểm Tra Trigger Chặn Bán Khi Thiếu Tồn Kho
1. Chuyển sang quyền Quản lý.
2. Vào tab **"📦 Kho & Nhập Hàng"**, ghi nhớ số lượng tồn của một nguyên liệu (hoặc xem món nào cần nhiều nguyên liệu).
3. Quay lại tab POS, cố tình thêm một đơn hàng với số lượng cực lớn (VD: 500 ly Trà sữa Oolong).
4. Bấm thanh toán -> Hệ thống lập tức kích hoạt cơ chế Trigger phát hiện tồn kho không đủ và hiện cảnh báo:
   `"⛔ TRIGGER CẢNH BÁO TỒN KHO: Không đủ nguyên liệu [Trà Oolong Cao Cấp] để pha chế! Hiện có: ... g, Cần: ... g. Giao dịch bị hủy!"`
5. Giao dịch được rollback an toàn, không có món nào bị trừ âm kho!

### Tính năng 3: Quản Lý Định Lượng Công Thức (Recipe)
1. Vào tab **"⚖️ Định Lượng (Recipe)"**.
2. Xem bảng định lượng: Đối với mỗi món và từng size, hệ thống hiển thị chính xác lượng nguyên liệu tiêu hao cho 1 ly.
3. Người quản lý có thể lọc xem theo từng món cụ thể để kiểm tra tỷ lệ pha chế.

### Tính năng 4: Quản Lý Kho & Nhập Nguyên Liệu Mới
1. Vào tab **"📦 Kho & Nhập Hàng"**.
2. Xem danh sách tồn kho hiện tại, các nguyên liệu chạm ngưỡng tối thiểu sẽ có màu đỏ nổi bật.
3. Nhấp nút **"📥 Nhập Kho Nguyên Liệu"**:
   - Chọn nguyên liệu cần nhập (VD: *Trà Oolong*, *Trân Châu Đen*...).
   - Nhập số lượng và đơn giá nhập.
   - Nhấp lưu -> Tồn kho được cộng ngay lập tức, đơn giá bình quân được tính lại và lịch sử nhập kho được ghi nhận.
4. Kéo xuống dưới để xem **Nhật ký biến động kho (Audit trail)**: Xem từng dòng giao dịch bán hàng đã tự động trừ nguyên liệu nào, vào thời gian nào, cho hóa đơn nào.

### Tính năng 5: Tra Cứu Doanh Thu Bằng Function CSDL
1. Vào tab **"📊 Báo Cáo & Crystal Report"**.
2. Xem các thẻ thống kê tổng quan: Doanh thu hôm nay (từ hàm `fn_TinhDoanhThuTheoNgay`) và Doanh thu tháng này (từ hàm `fn_TinhDoanhThuTheoThang`).
3. Sử dụng công cụ tra cứu tương tác:
   - Chọn ngày cụ thể (VD: `2026-10-18`) -> Bấm **"Truy Vấn"** để gọi hàm tính doanh thu ngày.
   - Chọn tháng và năm (VD: Tháng `10`, Năm `2026`) -> Bấm **"Truy Vấn"** để gọi hàm tính doanh thu tháng.
4. Xem danh sách tất cả các hóa đơn trong ngày, có thể nhấp nút **"🧾 In Crystal Report"** trên từng dòng để xem lại và in lại bất kỳ hóa đơn nào trong quá khứ!

---

## 5. CẤU TRÚC THƯ MỤC NGUỒN CỦA DỰ ÁN
```text
coffee/
├── README.md                           # Giới thiệu tổng quan & hướng dẫn nhanh
├── database/                           # Tệp mã nguồn Cơ sở dữ liệu Microsoft SQL Server
│   ├── 01_create_database_and_tables.sql
│   ├── 02_constraints_and_indexes.sql
│   ├── 03_triggers.sql                 # Chứa Trigger tự động trừ tồn kho cốt lõi
│   ├── 04_functions_and_procedures.sql # Chứa Function tính doanh thu ngày/tháng
│   ├── 05_sample_data.sql              # Dữ liệu mẫu phong phú
│   ├── 06_full_database_script.sql     # Script tổng hợp chạy 1 lần trên SSMS
│   └── 07_test_queries_and_verification.sql # Bộ kịch bản kiểm thử CSDL
├── app/                                # Ứng dụng Quản lý & POS (Python/Flask)
│   ├── app.py                          # Backend API & Xử lý trừ kho theo Recipe
│   ├── coffee.db                       # Database SQLite đồng bộ cấu trúc
│   ├── templates/
│   │   └── index.html                  # Giao diện POS, Menu, Kho, Báo cáo & Crystal Report
│   └── static/
├── docs/                               # Tài liệu học thuật & Báo cáo đồ án
│   ├── BAO_CAO_DO_AN_IE103.md          # Cuốn báo cáo đồ án chuẩn mẫu UIT
│   ├── BAO_CAO_DO_AN_IE103.html        # Bản báo cáo HTML xem và in PDF
│   ├── HUONG_DAN_CAI_DAT_VA_SU_DUNG.md # Hướng dẫn cài đặt & kịch bản kiểm thử
│   └── diagrams/                       # Sơ đồ trực quan
│       ├── ERD_Diagram.svg             # Sơ đồ thực thể quan hệ CSDL
│       ├── Architecture.svg            # Sơ đồ kiến trúc phân tầng
│       └── Process_Flow_Stock_Deduction.svg # Sơ đồ luồng trừ kho tự động
```

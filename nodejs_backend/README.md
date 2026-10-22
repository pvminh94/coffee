# HƯỚNG DẪN CHẠY BACKEND NODE.JS VỚI MICROSOFT SQL SERVER
## ĐỒ ÁN IE103 - ĐỀ TÀI 2

Mã nguồn trong thư mục này được xây dựng bằng **Node.js + Express** và thư viện **`mssql`** chính thức để kết nối trực tiếp vào cơ sở dữ liệu **Microsoft SQL Server**.

### 1. Cài đặt các gói phụ thuộc
```bash
npm install
```

### 2. Cấu hình kết nối SQL Server
Mở tệp `.env` hoặc chỉnh sửa trực tiếp trong `config.js`:
```env
DB_USER=sa
DB_PASSWORD=YourPassword123!
DB_SERVER=localhost
DB_DATABASE=QuanLyQuanCafe
DB_PORT=1433
```

### 3. Khởi động server Node.js
```bash
node nodejs_backend/server.js
```
Truy cập: `http://localhost:3000`

### 4. Cơ chế hoạt động với SQL Server:
- Khi bán hàng, Node.js gửi lệnh `UPDATE HoaDon SET TrangThai = N'DaThanhToan'`.
- Lúc này, **Trigger `trg_HoaDon_TruKhoNguyenLieuKhiThanhToan` trong SQL Server** được kích hoạt tự động.
- Nếu kho thiếu nguyên liệu, Trigger của SQL Server sẽ ném lỗi `RAISERROR` và Node.js bắt lỗi này hiển thị trực tiếp lên giao diện cho thu ngân!
- Các báo cáo doanh thu gọi trực tiếp hàm Scalar UDF `dbo.fn_TinhDoanhThuTheoNgay` và `dbo.fn_TinhDoanhThuTheoThang` của SQL Server.

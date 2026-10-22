/**
 * BACKEND NODE.JS + EXPRESS KẾT NỐI TRỰC TIẾP MICROSOFT SQL SERVER
 * Đề tài 2: Quản lý cửa hàng Cà phê / Trà sữa (IE103)
 */

const express = require('express');
const sql = require('mssql');
const path = require('path');
const sqlConfig = require('./config');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, '../app/static')));

let poolPromise = null;

async function getPool() {
    if (!poolPromise) {
        poolPromise = new sql.ConnectionPool(sqlConfig)
            .connect()
            .then(pool => {
                console.log('✅ Đã kết nối thành công tới Microsoft SQL Server (QuanLyQuanCafe)!');
                return pool;
            })
            .catch(err => {
                console.error('❌ Lỗi kết nối SQL Server:', err.message);
                poolPromise = null;
                throw err;
            });
    }
    return poolPromise;
}

// 1. API GỌI FUNCTION TÍNH DOANH THU THEO NGÀY TRONG SQL SERVER
app.get('/api/reports/revenue/by-day', async (req, res) => {
    try {
        const pool = await getPool();
        const dateStr = req.query.date || new Date().toISOString().slice(0, 10);
        
        // Thực thi gọi hàm Scalar Function fn_TinhDoanhThuTheoNgay trong SQL Server
        const result = await pool.request()
            .input('Ngay', sql.Date, dateStr)
            .query('SELECT dbo.fn_TinhDoanhThuTheoNgay(@Ngay) AS DoanhThu');

        // Danh sách hóa đơn trong ngày
        const invoices = await pool.request()
            .input('Ngay', sql.Date, dateStr)
            .query(`
                SELECT hd.MaHD, hd.NgayTao, hd.TongThanhToan, hd.PhuongThucTT, nv.HoTen AS ThuNgan, b.TenBan, hd.LoaiDon
                FROM HoaDon hd
                JOIN NhanVien nv ON hd.MaNV = nv.MaNV
                LEFT JOIN Ban b ON hd.MaBan = b.MaBan
                WHERE CAST(hd.NgayTao AS DATE) = @Ngay AND hd.TrangThai = N'DaThanhToan'
                ORDER BY hd.NgayTao DESC
            `);

        res.json({
            success: true,
            date: dateStr,
            revenue: result.recordset[0].DoanhThu || 0,
            orderCount: invoices.recordset.length,
            invoices: invoices.recordset
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// 2. API GỌI FUNCTION TÍNH DOANH THU THEO THÁNG TRONG SQL SERVER
app.get('/api/reports/revenue/by-month', async (req, res) => {
    try {
        const pool = await getPool();
        const month = parseInt(req.query.month) || (new Date().getMonth() + 1);
        const year = parseInt(req.query.year) || new Date().getFullYear();

        // Thực thi gọi hàm Scalar Function fn_TinhDoanhThuTheoThang trong SQL Server
        const result = await pool.request()
            .input('Thang', sql.Int, month)
            .input('Nam', sql.Int, year)
            .query('SELECT dbo.fn_TinhDoanhThuTheoThang(@Thang, @Nam) AS DoanhThu');

        res.json({
            success: true,
            month,
            year,
            revenue: result.recordset[0].DoanhThu || 0
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// 3. API THANH TOÁN - KÍCH HOẠT TRIGGER TRỪ KHO CỦA SQL SERVER
app.post('/api/orders/checkout', async (req, res) => {
    const { items, MaBan, PhuongThucTT, GiamGia, TienKhachDua } = req.body;
    if (!items || !items.length) {
        return res.status(400).json({ success: false, message: 'Giỏ hàng đang trống!' });
    }

    const transaction = new sql.Transaction(await getPool());

    try {
        await transaction.begin();

        const maHD = 'HD' + Date.now();
        const request = new sql.Request(transaction);

        // Tạo hóa đơn
        await request
            .input('MaHD', sql.NVarChar, maHD)
            .input('MaBan', sql.NVarChar, MaBan || null)
            .input('MaNV', sql.NVarChar, 'NV02')
            .input('TongTienHang', sql.Decimal(18, 2), items.reduce((s, i) => s + (i.DonGia * i.SoLuong), 0))
            .input('GiamGia', sql.Decimal(18, 2), GiamGia || 0)
            .input('TongThanhToan', sql.Decimal(18, 2), Math.max(0, items.reduce((s, i) => s + (i.DonGia * i.SoLuong), 0) - (GiamGia || 0)))
            .input('PhuongThucTT', sql.NVarChar, PhuongThucTT || 'TienMat')
            .input('TienKhachDua', sql.Decimal(18, 2), TienKhachDua || 0)
            .input('LoaiDon', sql.NVarChar, MaBan ? 'TaiCho' : 'MangVe')
            .query(`
                INSERT INTO HoaDon (MaHD, MaBan, MaNV, TongTienHang, GiamGia, TongThanhToan, PhuongThucTT, TienKhachDua, TrangThai, LoaiDon)
                VALUES (@MaHD, @MaBan, @MaNV, @TongTienHang, @GiamGia, @TongThanhToan, @PhuongThucTT, @TienKhachDua, N'ChoThanhToan', @LoaiDon)
            `);

        // Thêm chi tiết hóa đơn
        for (const it of items) {
            const reqItem = new sql.Request(transaction);
            await reqItem
                .input('MaHD', sql.NVarChar, maHD)
                .input('MaSP', sql.NVarChar, it.MaSP)
                .input('MaSize', sql.NVarChar, it.MaSize)
                .input('SoLuong', sql.Int, it.SoLuong)
                .input('DonGia', sql.Decimal(18, 2), it.DonGia)
                .query(`
                    INSERT INTO ChiTietHoaDon (MaHD, MaSP, MaSize, SoLuong, DonGia)
                    VALUES (@MaHD, @MaSP, @MaSize, @SoLuong, @DonGia)
                `);
        }

        // Cập nhật trạng thái sang 'DaThanhToan' -> DÒNG NÀY SẼ KÍCH HOẠT TRIGGER trg_HoaDon_TruKhoNguyenLieuKhiThanhToan CỦA SQL SERVER!
        // Nếu kho không đủ, Trigger của SQL Server sẽ RAISERROR và hủy transaction tự động!
        const reqUpdate = new sql.Request(transaction);
        await reqUpdate
            .input('MaHD', sql.NVarChar, maHD)
            .query(`UPDATE HoaDon SET TrangThai = N'DaThanhToan' WHERE MaHD = @MaHD`);

        await transaction.commit();

        res.json({
            success: true,
            invoiceId: maHD,
            message: 'Thanh toán thành công! Trigger SQL Server đã tự động trừ tồn kho nguyên liệu.'
        });
    } catch (err) {
        await transaction.rollback();
        // Thông báo lỗi từ Trigger của SQL Server trả về cho người dùng
        res.status(400).json({
            success: false,
            message: err.message
        });
    }
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../app/templates/index.html'));
});

app.listen(PORT, () => {
    console.log(`Server Node.js đang chạy tại: http://localhost:${PORT}`);
});

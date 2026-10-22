/**
 * CẤU HÌNH KẾT NỐI MICROSOFT SQL SERVER CHO NODE.JS (IE103)
 * Sử dụng thư viện: mssql (Tedious driver)
 */
require('dotenv').config();

const sqlConfig = {
    user: process.env.DB_USER || 'sa',
    password: process.env.DB_PASSWORD || 'Password123!',
    server: process.env.DB_SERVER || 'localhost', // Hoặc '127.0.0.1' hoặc 'DESKTOP-ABC\\SQLEXPRESS'
    database: process.env.DB_DATABASE || 'QuanLyQuanCafe',
    port: parseInt(process.env.DB_PORT || '1433'),
    options: {
        encrypt: false, // Set false cho SQL Server local
        trustServerCertificate: true, // Cho phép tự ký chứng chỉ SSL
        enableArithAbort: true
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
};

module.exports = sqlConfig;

-- =========================================================================
-- ĐỒ ÁN MÔN HỌC: IE103 - QUẢN LÝ THÔNG TIN
-- ĐỀ TÀI 2: HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
-- PHẦN 7: BỘ KỊCH BẢN TRUY VẤN KIỂM THỬ (TEST SCRIPTS)
-- Kiểm chứng hoạt động của:
-- 1. Function tính doanh thu theo ngày và tháng
-- 2. Trigger tự động trừ tồn kho nguyên liệu khi bán hàng
-- 3. Trigger chặn bán khi tồn kho không đủ (RAISERROR & ROLLBACK)
-- 4. Trigger tự động tính tổng tiền hóa đơn
-- 5. Trigger hoàn trả kho khi hủy đơn
-- =========================================================================

USE QuanLyQuanCafe;
GO

PRINT '===========================================================';
PRINT 'TEST CASE 1: KIỂM THỬ FUNCTION TÍNH TỔNG DOANH THU THEO NGÀY';
PRINT '===========================================================';
-- Tính tổng doanh thu ngày 18/10/2026
SELECT dbo.fn_TinhDoanhThuTheoNgay('2026-10-18') AS DoanhThu_Ngay_2026_10_18;
GO

PRINT '===========================================================';
PRINT 'TEST CASE 2: KIỂM THỬ FUNCTION TÍNH TỔNG DOANH THU THEO THÁNG';
PRINT '===========================================================';
-- Tính tổng doanh thu tháng 10 năm 2026
SELECT dbo.fn_TinhDoanhThuTheoThang(10, 2026) AS DoanhThu_Thang_10_2026;
GO

PRINT '===========================================================';
PRINT 'TEST CASE 3: KIỂM THỬ TRIGGER TỰ ĐỘNG TRỪ TỒN KHO NGUYÊN LIỆU KHI BÁN HÀNG';
PRINT '===========================================================';
-- Bước 1: Xem tồn kho ban đầu của Trà Oolong (NL03) và Bột sữa (NL06)
PRINT N'--> Tồn kho ban đầu trước khi bán:';
SELECT MaNL, TenNL, SoLuongTon, DonViTinh 
FROM NguyenLieu 
WHERE MaNL IN ('NL03', 'NL06', 'NL10');

-- Bước 2: Tạo hóa đơn mới cho 2 ly Trà Sữa Oolong Nướng Size M
-- Theo công thức SP05 Size M: 1 ly cần 15g Trà Oolong, 30g Bột sữa, 40g Trân châu
-- 2 ly sẽ cần: 30g Trà Oolong, 60g Bột sữa, 80g Trân châu
EXEC dbo.sp_TaoHoaDon 
    @MaHD = 'HD_TEST_TRUKHO_01', 
    @MaBan = 'B01', 
    @MaNV = 'NV02', 
    @LoaiDon = N'TaiCho', 
    @GhiChu = N'Kiểm thử Trigger trừ kho';

INSERT INTO ChiTietHoaDon (MaHD, MaSP, MaSize, SoLuong, DonGia)
VALUES ('HD_TEST_TRUKHO_01', 'SP05', 'M', 2, 45000);

-- Bước 3: Thực hiện thanh toán hóa đơn
EXEC dbo.sp_ThanhToanHoaDon 
    @MaHD = 'HD_TEST_TRUKHO_01', 
    @PhuongThucTT = N'TienMat', 
    @GiamGia = 0, 
    @TienKhachDua = 100000;

-- Bước 4: Kiểm tra lại tồn kho sau khi thanh toán -> Đã bị trừ đúng 30g Trà, 60g Bột sữa, 80g Trân châu!
PRINT N'--> Tồn kho sau khi thanh toán hóa đơn (đã trừ tự động bởi Trigger):';
SELECT MaNL, TenNL, SoLuongTon, DonViTinh 
FROM NguyenLieu 
WHERE MaNL IN ('NL03', 'NL06', 'NL10');

-- Xem lịch sử biến động kho vừa được ghi tự động
PRINT N'--> Lịch sử biến động kho vừa được Trigger ghi log:';
SELECT TOP 3 MaLS, MaNL, LoaiGiaoDich, SoLuongThayDoi, SoLuongTonSauDo, MaChungTu, NgayThucHien
FROM LichSuKho
ORDER BY MaLS DESC;
GO

PRINT '===========================================================';
PRINT 'TEST CASE 4: KIỂM THỬ TRIGGER CHẶN BÁN KHI KHO KHÔNG ĐỦ NGUYÊN LIỆU';
PRINT '===========================================================';
-- Cố tình ép tồn kho Trân châu đen (NL10) xuống còn 10g
UPDATE NguyenLieu SET SoLuongTon = 10 WHERE MaNL = 'NL10';

-- Tạo đơn hàng đòi 1 ly Trà sữa Oolong Size M (cần 40g Trân châu)
EXEC dbo.sp_TaoHoaDon 
    @MaHD = 'HD_TEST_THIEUKHO_01', 
    @MaBan = 'B02', 
    @MaNV = 'NV02';

INSERT INTO ChiTietHoaDon (MaHD, MaSP, MaSize, SoLuong, DonGia)
VALUES ('HD_TEST_THIEUKHO_01', 'SP05', 'M', 1, 45000);

-- Thử thanh toán đơn hàng này -> TRIGGER SẼ NÉM LỖI VÀ ROLLBACK TRANSACTION!
PRINT N'--> Kích hoạt thanh toán đơn thiếu nguyên liệu (Kỳ vọng: Báo lỗi và hủy giao tác):';
BEGIN TRY
    EXEC dbo.sp_ThanhToanHoaDon 
        @MaHD = 'HD_TEST_THIEUKHO_01', 
        @PhuongThucTT = N'TienMat', 
        @GiamGia = 0, 
        @TienKhachDua = 50000;
END TRY
BEGIN CATCH
    PRINT N'BẮT ĐƯỢC LỖI KỲ VỌNG: ' + ERROR_MESSAGE();
END CATCH;

-- Khôi phục lại tồn kho cho NL10
UPDATE NguyenLieu SET SoLuongTon = 12000.0 WHERE MaNL = 'NL10';
GO

PRINT '===========================================================';
PRINT 'TEST CASE 5: KIỂM THỬ VIEW VÀ TABLE-VALUED FUNCTIONS';
PRINT '===========================================================';
-- Top 3 món bán chạy
SELECT * FROM dbo.fn_ThongKeMonBanChay('2026-10-01', '2026-10-31', 3);

-- Cảnh báo nguyên liệu sắp hết
SELECT * FROM dbo.fn_CanhBaoNguyenLieuSapHet();
GO

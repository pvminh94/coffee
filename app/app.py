# -*- coding: utf-8 -*-
"""
HỆ THỐNG QUẢN LÝ CỬA HÀNG CÀ PHÊ / TRÀ SỮA
Môn học: IE103 - Quản lý thông tin
Đề tài 2: Quản lý danh mục món, hóa đơn, trigger trừ kho, function doanh thu, phân quyền, Crystal Report
"""

import os
import sqlite3
from datetime import datetime, date
from flask import Flask, request, jsonify, render_template, session, redirect, url_for

app = Flask(__name__, static_folder='static', template_folder='templates')
app.secret_key = 'ie103_coffee_management_secret_key_2026'

DB_PATH = os.path.join(os.path.dirname(__file__), 'coffee.db')

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn

# =========================================================================
# AUTHENTICATION & ROLE-BASED ACCESS CONTROL
# =========================================================================
@app.route('/api/auth/me', methods=['GET'])
def get_current_user():
    user = session.get('user')
    if not user:
        # Mặc định khởi tạo tài khoản Quản lý cho lần đầu truy cập tiện kiểm thử
        session['user'] = {
            'username': 'quanly',
            'fullName': 'Nguyễn Văn Quản Lý',
            'role': 'VT01',
            'roleName': 'Quản Lý'
        }
        user = session['user']
    return jsonify({'success': True, 'user': user})

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.json or {}
    username = data.get('username')
    password = data.get('password')

    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT nv.MaNV, nv.HoTen, nv.TenDangNhap, nv.MatKhau, nv.MaVaiTro, vt.TenVaiTro
        FROM NhanVien nv
        JOIN VaiTro vt ON nv.MaVaiTro = vt.MaVaiTro
        WHERE nv.TenDangNhap = ? AND nv.TrangThai = 'DangLamViec'
    """, (username,))
    row = cur.fetchone()
    conn.close()

    if not row or row['MatKhau'] != password:
        return jsonify({'success': False, 'message': 'Sai tên đăng nhập hoặc mật khẩu!'}), 401

    session['user'] = {
        'username': row['TenDangNhap'],
        'fullName': row['HoTen'],
        'role': row['MaVaiTro'],
        'roleName': row['TenVaiTro']
    }
    return jsonify({'success': True, 'user': session['user']})

@app.route('/api/auth/switch-role', methods=['POST'])
def switch_role():
    """Chức năng chuyển nhanh vai trò Quản Lý <-> Thu Ngân để kiểm thử phân quyền"""
    target = request.json.get('role', 'VT02')
    conn = get_db()
    cur = conn.cursor()
    if target == 'VT01':
        cur.execute("SELECT nv.*, vt.TenVaiTro FROM NhanVien nv JOIN VaiTro vt ON nv.MaVaiTro = vt.MaVaiTro WHERE nv.TenDangNhap = 'quanly'")
    else:
        cur.execute("SELECT nv.*, vt.TenVaiTro FROM NhanVien nv JOIN VaiTro vt ON nv.MaVaiTro = vt.MaVaiTro WHERE nv.TenDangNhap = 'thungan'")
    row = cur.fetchone()
    conn.close()

    if row:
        session['user'] = {
            'username': row['TenDangNhap'],
            'fullName': row['HoTen'],
            'role': row['MaVaiTro'],
            'roleName': row['TenVaiTro']
        }
        return jsonify({'success': True, 'user': session['user']})
    return jsonify({'success': False, 'message': 'Không tìm thấy người dùng'}), 404

@app.route('/api/auth/logout', methods=['POST'])
def logout():
    session.pop('user', None)
    return jsonify({'success': True})

# =========================================================================
# 1. QUẢN LÝ DANH MỤC & SẢN PHẨM / MÓN
# =========================================================================
@app.route('/api/categories', methods=['GET'])
def get_categories():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM DanhMuc WHERE TrangThai = 1 ORDER BY ThuTuHienThi ASC")
    categories = [dict(row) for row in cur.fetchall()]
    conn.close()
    return jsonify({'success': True, 'data': categories})

@app.route('/api/products', methods=['GET'])
def get_products():
    category_id = request.args.get('categoryId')
    conn = get_db()
    cur = conn.cursor()

    query = """
        SELECT sp.MaSP, sp.TenSP, sp.MaDM, dm.TenDM, sp.MoTa, sp.HinhAnh, sp.TrangThai
        FROM SanPham sp
        JOIN DanhMuc dm ON sp.MaDM = dm.MaDM
        WHERE sp.TrangThai = 1
    """
    params = []
    if category_id:
        query += " AND sp.MaDM = ?"
        params.append(category_id)

    query += " ORDER BY sp.MaDM, sp.MaSP"
    cur.execute(query, params)
    products = [dict(row) for row in cur.fetchall()]

    # Lấy giá theo từng size cho mỗi món
    for p in products:
        cur.execute("""
            SELECT ss.MaSize, sm.TenSize, ss.GiaBan
            FROM SanPham_Size ss
            JOIN SizeMon sm ON ss.MaSize = sm.MaSize
            WHERE ss.MaSP = ? AND ss.TrangThai = 1
            ORDER BY ss.GiaBan ASC
        """, (p['MaSP'],))
        p['sizes'] = [dict(r) for r in cur.fetchall()]
        p['minPrice'] = p['sizes'][0]['GiaBan'] if p['sizes'] else 0

    conn.close()
    return jsonify({'success': True, 'data': products})

@app.route('/api/products', methods=['POST'])
def create_product():
    user = session.get('user', {})
    if user.get('role') != 'VT01':
        return jsonify({'success': False, 'message': 'Chỉ Quản lý mới có quyền thêm/sửa món!'}), 403

    data = request.json or {}
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""
            INSERT INTO SanPham (MaSP, TenSP, MaDM, MoTa, HinhAnh, TrangThai)
            VALUES (?, ?, ?, ?, ?, 1)
        """, (data['MaSP'], data['TenSP'], data['MaDM'], data.get('MoTa', ''), data.get('HinhAnh', '☕')))

        for s in data.get('sizes', []):
            cur.execute("""
                INSERT INTO SanPham_Size (MaSP, MaSize, GiaBan)
                VALUES (?, ?, ?)
            """, (data['MaSP'], s['MaSize'], s['GiaBan']))

        conn.commit()
        return jsonify({'success': True, 'message': 'Thêm món thành công!'})
    except Exception as e:
        conn.rollback()
        return jsonify({'success': False, 'message': str(e)}), 400
    finally:
        conn.close()

# =========================================================================
# 2. QUẢN LÝ BÀN & KHÁCH HÀNG
# =========================================================================
@app.route('/api/tables', methods=['GET'])
def get_tables():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM Ban ORDER BY MaBan")
    tables = [dict(row) for row in cur.fetchall()]
    conn.close()
    return jsonify({'success': True, 'data': tables})

@app.route('/api/customers', methods=['GET'])
def get_customers():
    phone = request.args.get('phone')
    conn = get_db()
    cur = conn.cursor()
    if phone:
        cur.execute("SELECT * FROM KhachHang WHERE SoDienThoai LIKE ?", (f"%{phone}%",))
    else:
        cur.execute("SELECT * FROM KhachHang ORDER BY DiemTichLuy DESC")
    customers = [dict(row) for row in cur.fetchall()]
    conn.close()
    return jsonify({'success': True, 'data': customers})

# =========================================================================
# 3. QUẢN LÝ KHO & ĐỊNH LƯỢNG NGUYÊN LIỆU (RECIPE)
# =========================================================================
@app.route('/api/ingredients', methods=['GET'])
def get_ingredients():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT *, 
            CASE 
                WHEN SoLuongTon = 0 THEN 'Hết hàng'
                WHEN SoLuongTon <= NguongToiThieu THEN 'Cảnh báo sắp hết'
                ELSE 'Đủ hàng'
            END AS TrangThaiKho
        FROM NguyenLieu 
        ORDER BY (SoLuongTon <= NguongToiThieu) DESC, MaNL ASC
    """)
    ingredients = [dict(row) for row in cur.fetchall()]
    conn.close()
    return jsonify({'success': True, 'data': ingredients})

@app.route('/api/recipes', methods=['GET'])
def get_recipes():
    product_id = request.args.get('productId')
    conn = get_db()
    cur = conn.cursor()
    query = """
        SELECT dl.MaSP, sp.TenSP, dl.MaSize, sm.TenSize, dl.MaNL, nl.TenNL, nl.DonViTinh, dl.SoLuongCan, dl.GhiChu
        FROM DinhLuong dl
        JOIN SanPham sp ON dl.MaSP = sp.MaSP
        JOIN SizeMon sm ON dl.MaSize = sm.MaSize
        JOIN NguyenLieu nl ON dl.MaNL = nl.MaNL
    """
    params = []
    if product_id:
        query += " WHERE dl.MaSP = ?"
        params.append(product_id)
    query += " ORDER BY dl.MaSP, dl.MaSize, dl.MaNL"
    cur.execute(query, params)
    recipes = [dict(row) for row in cur.fetchall()]
    conn.close()
    return jsonify({'success': True, 'data': recipes})

@app.route('/api/recipes', methods=['POST'])
def save_recipe():
    user = session.get('user', {})
    if user.get('role') != 'VT01':
        return jsonify({'success': False, 'message': 'Chỉ Quản lý mới có quyền cấu hình công thức định lượng!'}), 403

    data = request.json or {}
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""
            INSERT INTO DinhLuong (MaSP, MaSize, MaNL, SoLuongCan, GhiChu)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(MaSP, MaSize, MaNL) DO UPDATE SET
                SoLuongCan = excluded.SoLuongCan,
                GhiChu = excluded.GhiChu
        """, (data['MaSP'], data['MaSize'], data['MaNL'], float(data['SoLuongCan']), data.get('GhiChu', '')))
        conn.commit()
        return jsonify({'success': True, 'message': 'Cập nhật định lượng thành công!'})
    except Exception as e:
        conn.rollback()
        return jsonify({'success': False, 'message': str(e)}), 400
    finally:
        conn.close()

@app.route('/api/inventory/import', methods=['POST'])
def import_inventory():
    """Tạo phiếu nhập kho nguyên liệu (Cộng tồn kho)"""
    user = session.get('user', {})
    if user.get('role') != 'VT01':
        return jsonify({'success': False, 'message': 'Chỉ Quản lý mới có quyền nhập kho!'}), 403

    data = request.json or {}
    items = data.get('items', [])
    if not items:
        return jsonify({'success': False, 'message': 'Phiếu nhập phải có ít nhất 1 nguyên liệu!'}), 400

    conn = get_db()
    cur = conn.cursor()
    try:
        ma_pn = f"PN{datetime.now().strftime('%Y%m%d%H%M%S')}"
        tong_tien = sum(float(it['SoLuong']) * float(it['DonGia']) for it in items)

        cur.execute("""
            INSERT INTO PhieuNhapKho (MaPN, MaNV, NhaCungCap, TongTienNhap, GhiChu)
            VALUES (?, 'NV01', ?, ?, ?)
        """, (ma_pn, data.get('NhaCungCap', 'Nhà cung cấp uy tín'), tong_tien, data.get('GhiChu', 'Nhập kho định kỳ')))

        for it in items:
            sl = float(it['SoLuong'])
            dg = float(it['DonGia'])
            tt = sl * dg
            cur.execute("""
                INSERT INTO ChiTietPhieuNhap (MaPN, MaNL, SoLuongNhap, DonGiaNhap, ThanhTien)
                VALUES (?, ?, ?, ?, ?)
            """, (ma_pn, it['MaNL'], sl, dg, tt))

            # Cộng tồn kho
            cur.execute("""
                UPDATE NguyenLieu
                SET SoLuongTon = SoLuongTon + ?,
                    DonGiaNhapBinhQuan = CASE 
                        WHEN (SoLuongTon + ?) > 0 THEN ((SoLuongTon * DonGiaNhapBinhQuan) + (? * ?)) / (SoLuongTon + ?)
                        ELSE ?
                    END
                WHERE MaNL = ?
            """, (sl, sl, sl, dg, sl, dg, it['MaNL']))

            # Lấy tồn kho sau đó
            cur.execute("SELECT SoLuongTon FROM NguyenLieu WHERE MaNL = ?", (it['MaNL'],))
            ton_sau = cur.fetchone()['SoLuongTon']

            # Ghi log lịch sử kho
            cur.execute("""
                INSERT INTO LichSuKho (MaNL, LoaiGiaoDich, SoLuongThayDoi, SoLuongTonSauDo, MaChungTu, GhiChu)
                VALUES (?, 'NhapKho', ?, ?, ?, ?)
            """, (it['MaNL'], sl, ton_sau, ma_pn, f"Nhập kho từ phiếu {ma_pn}"))

        conn.commit()
        return jsonify({'success': True, 'message': f'Nhập kho thành công! Mã phiếu: {ma_pn}'})
    except Exception as e:
        conn.rollback()
        return jsonify({'success': False, 'message': str(e)}), 400
    finally:
        conn.close()

# =========================================================================
# 4. BÁN HÀNG & TRIGGER TỰ ĐỘNG TRỪ TỒN KHO NGUYÊN LIỆU (CỐT LÕI)
# =========================================================================
@app.route('/api/orders/checkout', methods=['POST'])
def checkout_order():
    """
    XỬ LÝ THANH TOÁN VÀ THỰC THI TRIGGER TRỪ KHO:
    1. Tiếp nhận giỏ hàng (Danh sách món, size, số lượng).
    2. Truy vấn bảng DinhLuong để tính toán tổng nguyên liệu tiêu hao.
    3. KIỂM TRA TỒN KHO: Nếu bất kỳ nguyên liệu nào không đủ -> Báo lỗi & HỦY giao dịch!
    4. Nếu đủ: Tạo Hóa đơn, Chi tiết hóa đơn, TRỪ kho nguyên liệu, ghi Lịch sử kho!
    """
    data = request.json or {}
    items = data.get('items', [])
    if not items:
        return jsonify({'success': False, 'message': 'Giỏ hàng đang trống!'}), 400

    conn = get_db()
    cur = conn.cursor()

    try:
        # Bước 1: Tính toán tổng nguyên liệu cần tiêu hao cho toàn bộ đơn hàng
        needed_ingredients = {}
        for it in items:
            ma_sp = it['MaSP']
            ma_size = it['MaSize']
            so_luong = int(it['SoLuong'])

            cur.execute("""
                SELECT dl.MaNL, nl.TenNL, nl.DonViTinh, nl.SoLuongTon, dl.SoLuongCan
                FROM DinhLuong dl
                JOIN NguyenLieu nl ON dl.MaNL = nl.MaNL
                WHERE dl.MaSP = ? AND dl.MaSize = ?
            """, (ma_sp, ma_size))
            recipes = cur.fetchall()

            for r in recipes:
                ma_nl = r['MaNL']
                can_cho_dong_nay = r['SoLuongCan'] * so_luong
                if ma_nl not in needed_ingredients:
                    needed_ingredients[ma_nl] = {
                        'TenNL': r['TenNL'],
                        'DonViTinh': r['DonViTinh'],
                        'SoLuongTon': r['SoLuongTon'],
                        'TongCan': 0
                    }
                needed_ingredients[ma_nl]['TongCan'] += can_cho_dong_nay

        # Bước 2: KIỂM TRA TỒN KHO (Tương đương Trigger Validation trong SQL Server)
        for ma_nl, info in needed_ingredients.items():
            if info['SoLuongTon'] < info['TongCan']:
                thieu = info['TongCan'] - info['SoLuongTon']
                err_msg = (
                    f"⛔ TRIGGER CẢNH BÁO TỒN KHO: Không đủ nguyên liệu [{info['TenNL']}] để pha chế! "
                    f"Hiện có: {info['SoLuongTon']} {info['DonViTinh']}, Cần: {info['TongCan']} {info['DonViTinh']} "
                    f"(Thiếu: {thieu} {info['DonViTinh']}). Giao dịch bị hủy!"
                )
                return jsonify({'success': False, 'message': err_msg, 'isStockError': True}), 400

        # Bước 3: Tạo mã Hóa Đơn & Lưu thông tin
        now_str = datetime.now().strftime('%Y%m%d%H%M%S')
        ma_hd = f"HD{now_str}"
        ma_ban = data.get('MaBan') or None
        loai_don = 'MangVe' if not ma_ban else 'TaiCho'
        ma_nv = session.get('user', {}).get('username', 'thungan')
        # Chuyển username sang MaNV nếu cần
        cur.execute("SELECT MaNV FROM NhanVien WHERE TenDangNhap = ?", (ma_nv,))
        r_nv = cur.fetchone()
        ma_nv = r_nv['MaNV'] if r_nv else 'NV02'

        tong_tien_hang = sum(float(it['DonGia']) * int(it['SoLuong']) for it in items)
        giam_gia = float(data.get('GiamGia', 0))
        tong_thanh_toan = max(0.0, tong_tien_hang - giam_gia)
        pt_tt = data.get('PhuongThucTT', 'TienMat')
        tien_khach = float(data.get('TienKhachDua', tong_thanh_toan))
        tien_thoi = max(0.0, tien_khach - tong_thanh_toan)

        cur.execute("""
            INSERT INTO HoaDon (MaHD, MaBan, MaNV, MaKH, TongTienHang, GiamGia, TongThanhToan, PhuongThucTT, TienKhachDua, TienThoiLai, TrangThai, LoaiDon, GhiChu)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'DaThanhToan', ?, ?)
        """, (ma_hd, ma_ban, ma_nv, data.get('MaKH') or None, tong_tien_hang, giam_gia, tong_thanh_toan, pt_tt, tien_khach, tien_thoi, loai_don, data.get('GhiChu', '')))

        for it in items:
            tt = float(it['DonGia']) * int(it['SoLuong'])
            cur.execute("""
                INSERT INTO ChiTietHoaDon (MaHD, MaSP, MaSize, SoLuong, DonGia, ThanhTien, GhiChu)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (ma_hd, it['MaSP'], it['MaSize'], int(it['SoLuong']), float(it['DonGia']), tt, it.get('GhiChu', '')))

        # Bước 4: THỰC THI TRIGGER TRỪ KHO NGUYÊN LIỆU (Tương đương AFTER INSERT Trigger)
        for ma_nl, info in needed_ingredients.items():
            luong_tru = info['TongCan']
            cur.execute("""
                UPDATE NguyenLieu
                SET SoLuongTon = SoLuongTon - ?
                WHERE MaNL = ?
            """, (luong_tru, ma_nl))

            # Lấy tồn kho mới nhất
            cur.execute("SELECT SoLuongTon FROM NguyenLieu WHERE MaNL = ?", (ma_nl,))
            ton_moi = cur.fetchone()['SoLuongTon']

            # Ghi log lịch sử biến động kho
            cur.execute("""
                INSERT INTO LichSuKho (MaNL, LoaiGiaoDich, SoLuongThayDoi, SoLuongTonSauDo, MaChungTu, GhiChu)
                VALUES (?, 'BanHang', ?, ?, ?, ?)
            """, (ma_nl, -luong_tru, ton_moi, ma_hd, f"Trừ kho tự động khi bán đơn hàng {ma_hd}"))

        # Cập nhật trạng thái bàn
        if ma_ban:
            cur.execute("UPDATE Ban SET TrangThai = 'CoKhach' WHERE MaBan = ?", (ma_ban,))

        conn.commit()

        return jsonify({
            'success': True,
            'message': 'Thanh toán thành công và đã tự động trừ tồn kho nguyên liệu!',
            'invoiceId': ma_hd,
            'deductedIngredients': [
                {'name': v['TenNL'], 'amount': f"{v['TongCan']} {v['DonViTinh']}", 'remain': f"{v['SoLuongTon'] - v['TongCan']} {v['DonViTinh']}"}
                for v in needed_ingredients.values()
            ]
        })

    except Exception as e:
        conn.rollback()
        return jsonify({'success': False, 'message': f"Lỗi hệ thống: {str(e)}"}), 500
    finally:
        conn.close()

# =========================================================================
# 5. XUẤT CRYSTAL REPORT / HÓA ĐƠN THANH TOÁN
# =========================================================================
@app.route('/api/orders/<invoice_id>/receipt', methods=['GET'])
def get_invoice_receipt(invoice_id):
    """Lấy dữ liệu chi tiết hóa đơn theo mẫu chuẩn Crystal Report"""
    conn = get_db()
    cur = conn.cursor()

    cur.execute("""
        SELECT hd.*, nv.HoTen AS TenThuNgan, b.TenBan, kh.HoTen AS TenKhachHang, kh.SoDienThoai AS SDTKhachHang
        FROM HoaDon hd
        JOIN NhanVien nv ON hd.MaNV = nv.MaNV
        LEFT JOIN Ban b ON hd.MaBan = b.MaBan
        LEFT JOIN KhachHang kh ON hd.MaKH = kh.MaKH
        WHERE hd.MaHD = ?
    """, (invoice_id,))
    invoice = cur.fetchone()

    if not invoice:
        conn.close()
        return jsonify({'success': False, 'message': 'Không tìm thấy hóa đơn!'}), 404

    cur.execute("""
        SELECT ct.*, sp.TenSP, sm.TenSize
        FROM ChiTietHoaDon ct
        JOIN SanPham sp ON ct.MaSP = sp.MaSP
        JOIN SizeMon sm ON ct.MaSize = sm.MaSize
        WHERE ct.MaHD = ?
    """, (invoice_id,))
    details = [dict(r) for r in cur.fetchall()]
    conn.close()

    receipt_data = dict(invoice)
    receipt_data['items'] = details
    receipt_data['store'] = {
        'name': 'UIT COFFEE & TEA HOUSE',
        'address': 'Khu phố 6, P. Linh Trung, TP. Thủ Đức, TP. Hồ Chí Minh',
        'phone': '0901.234.567',
        'wifi': 'UIT_Coffee_HighSpeed (Pass: uit123456)',
        'slogan': 'Cà phê nguyên bản - Trà sữa chuẩn gu'
    }
    return jsonify({'success': True, 'data': receipt_data})

# =========================================================================
# 6. FUNCTIONS TÍNH DOANH THU & BÁO CÁO THỐNG KÊ (YÊU CẦU CỐT LÕI)
# =========================================================================
@app.route('/api/reports/revenue/by-day', methods=['GET'])
def revenue_by_day():
    """Tương đương hàm fn_TinhDoanhThuTheoNgay(@Ngay DATE)"""
    day_str = request.args.get('date', datetime.now().strftime('%Y-%m-%d'))
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT COALESCE(SUM(TongThanhToan), 0) AS DoanhThu, COUNT(MaHD) AS SoHoaDon
        FROM HoaDon
        WHERE DATE(NgayTao) = ? AND TrangThai = 'DaThanhToan'
    """, (day_str,))
    row = cur.fetchone()

    # Danh sách hóa đơn trong ngày
    cur.execute("""
        SELECT hd.MaHD, hd.NgayTao, hd.TongThanhToan, hd.PhuongThucTT, nv.HoTen AS ThuNgan, b.TenBan, hd.LoaiDon
        FROM HoaDon hd
        JOIN NhanVien nv ON hd.MaNV = nv.MaNV
        LEFT JOIN Ban b ON hd.MaBan = b.MaBan
        WHERE DATE(hd.NgayTao) = ? AND hd.TrangThai = 'DaThanhToan'
        ORDER BY hd.NgayTao DESC
    """, (day_str,))
    invoices = [dict(r) for r in cur.fetchall()]
    conn.close()

    return jsonify({
        'success': True,
        'date': day_str,
        'revenue': row['DoanhThu'],
        'orderCount': row['SoHoaDon'],
        'invoices': invoices
    })

@app.route('/api/reports/revenue/by-month', methods=['GET'])
def revenue_by_month():
    """Tương đương hàm fn_TinhDoanhThuTheoThang(@Thang INT, @Nam INT)"""
    month = request.args.get('month', datetime.now().month, type=int)
    year = request.args.get('year', datetime.now().year, type=int)
    month_str = f"{year:04d}-{month:02d}"

    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT COALESCE(SUM(TongThanhToan), 0) AS DoanhThu, COUNT(MaHD) AS SoHoaDon
        FROM HoaDon
        WHERE strftime('%Y-%m', NgayTao) = ? AND TrangThai = 'DaThanhToan'
    """, (month_str,))
    row = cur.fetchone()

    # Gom nhóm theo từng ngày trong tháng
    cur.execute("""
        SELECT DATE(NgayTao) AS Ngay, SUM(TongThanhToan) AS DoanhThu, COUNT(MaHD) AS SoHoaDon
        FROM HoaDon
        WHERE strftime('%Y-%m', NgayTao) = ? AND TrangThai = 'DaThanhToan'
        GROUP BY DATE(NgayTao)
        ORDER BY Ngay ASC
    """, (month_str,))
    daily_breakdown = [dict(r) for r in cur.fetchall()]
    conn.close()

    return jsonify({
        'success': True,
        'month': month,
        'year': year,
        'revenue': row['DoanhThu'],
        'orderCount': row['SoHoaDon'],
        'daily': daily_breakdown
    })

@app.route('/api/reports/top-selling', methods=['GET'])
def top_selling():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT sp.MaSP, sp.TenSP, dm.TenDM, ct.MaSize, SUM(ct.SoLuong) AS TongBan, SUM(ct.ThanhTien) AS DoanhThu
        FROM ChiTietHoaDon ct
        JOIN HoaDon hd ON ct.MaHD = hd.MaHD
        JOIN SanPham sp ON ct.MaSP = sp.MaSP
        JOIN DanhMuc dm ON sp.MaDM = dm.MaDM
        WHERE hd.TrangThai = 'DaThanhToan'
        GROUP BY sp.MaSP, ct.MaSize
        ORDER BY TongBan DESC
        LIMIT 10
    """)
    top = [dict(r) for r in cur.fetchall()]
    conn.close()
    return jsonify({'success': True, 'data': top})

@app.route('/api/reports/stock-history', methods=['GET'])
def stock_history():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT ls.*, nl.TenNL, nl.DonViTinh
        FROM LichSuKho ls
        JOIN NguyenLieu nl ON ls.MaNL = nl.MaNL
        ORDER BY ls.MaLS DESC
        LIMIT 50
    """)
    logs = [dict(r) for r in cur.fetchall()]
    conn.close()
    return jsonify({'success': True, 'data': logs})

@app.route('/api/employees', methods=['GET'])
def get_employees():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT nv.MaNV, nv.HoTen, nv.SoDienThoai, nv.Email, nv.TenDangNhap, nv.MaVaiTro, vt.TenVaiTro, nv.NgayVaoLam, nv.TrangThai
        FROM NhanVien nv
        JOIN VaiTro vt ON nv.MaVaiTro = vt.MaVaiTro
        ORDER BY nv.MaNV
    """)
    employees = [dict(r) for r in cur.fetchall()]
    conn.close()
    return jsonify({'success': True, 'data': employees})

# =========================================================================
# WEB PAGES
# =========================================================================
@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    # Chạy trên port 5000 và host 0.0.0.0 theo đúng quy định sandbox Live Preview
    app.run(host='0.0.0.0', port=5000, debug=True)

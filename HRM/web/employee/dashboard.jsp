<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Bảng điều khiển - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f0f4f8; }

    .dashboard-container {
        margin-top: 80px;
        padding-bottom: 60px;
    }

    /* Welcome Banner */
    .welcome-banner {
        background: linear-gradient(135deg, #0a2540 0%, #1a3a6b 100%);
        color: white;
        border-radius: 14px;
        padding: 24px 32px;
        margin-bottom: 24px;
        position: relative;
        overflow: hidden;
    }
    .welcome-banner::after {
        content: '';
        position: absolute;
        top: -60px; right: -60px;
        width: 220px; height: 220px;
        background: rgba(255,255,255,0.04);
        border-radius: 50%;
        pointer-events: none;
    }
    .welcome-banner h2 { font-size: 1.4rem; font-weight: 700; margin: 0 0 6px; }
    .welcome-banner p  { margin: 0; opacity: 0.72; font-size: 0.9rem; }

    /* Row uses stretch so all col cards align bottom */
    .dashboard-row {
        display: flex;
        gap: 20px;
        align-items: stretch;
    }
    .dashboard-col {
        flex: 1 1 0;
        min-width: 0;
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    /* Card */
    .card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        padding: 22px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        transition: box-shadow 0.2s;
    }
    .card:hover { box-shadow: 0 6px 18px rgba(0,0,0,0.07); }

    /* Card that fills remaining height */
    .card-fill { flex: 1; }

    .card-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        margin-bottom: 18px;
        padding-bottom: 12px;
        border-bottom: 1px solid #edf2f7;
    }
    .card-header-title {
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 700;
        font-size: 0.95rem;
        color: #2d3748;
        margin: 0;
    }

    /* ── Clock Widget ── */
    .clock-wrap { text-align: center; padding: 8px 0 4px; }
    .clock-time {
        font-size: 2.6rem;
        font-weight: 800;
        color: #0a2540;
        font-family: 'Courier New', monospace;
        letter-spacing: -1px;
        line-height: 1;
    }
    .clock-date {
        font-size: 0.82rem;
        color: #718096;
        font-weight: 500;
        margin: 6px 0 20px;
    }
    .btn-checkin {
        display: block;
        width: 100%;
        padding: 13px;
        background: #2b6cb0;
        color: #fff;
        border: none;
        border-radius: 10px;
        font-weight: 700;
        font-size: 1rem;
        cursor: pointer;
        transition: background 0.2s, transform 0.15s;
    }
    .btn-checkin:hover { background: #2c5282; transform: translateY(-1px); }
    .clock-location {
        margin-top: 12px;
        font-size: 0.8rem;
        color: #718096;
        text-align: center;
    }

    /* ── Stat rows ── */
    .stat-row {
        display: flex;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px dashed #edf2f7;
    }
    .stat-row:last-child { border-bottom: none; padding-bottom: 0; }
    .stat-icon {
        width: 40px; height: 40px;
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
        margin-right: 14px;
    }
    .stat-icon.blue   { background:#ebf8ff; color:#3182ce; }
    .stat-icon.orange { background:#fffaf0; color:#dd6b20; }
    .stat-icon.green  { background:#f0fff4; color:#38a169; }
    .stat-content h5 {
        margin: 0;
        font-size: 1.3rem;
        font-weight: 800;
        color: #1a202c;
        line-height: 1;
    }
    .stat-content span {
        font-size: 0.78rem;
        color: #718096;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.02em;
    }

    /* ── News list ── */
    .news-item {
        display: flex;
        align-items: flex-start;
        gap: 14px;
        padding: 14px 0;
        border-bottom: 1px dashed #edf2f7;
    }
    .news-item:last-child { border-bottom: none; padding-bottom: 0; }
    .news-icon {
        width: 36px; height: 36px;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        color: #fff;
        font-size: 0.85rem;
        flex-shrink: 0;
    }
    .news-content h6 {
        margin: 0 0 4px;
        font-size: 0.88rem;
        font-weight: 700;
        color: #2d3748;
        line-height: 1.3;
    }
    .news-content p {
        margin: 0 0 4px;
        font-size: 0.82rem;
        color: #4a5568;
        line-height: 1.45;
    }
    .news-date {
        font-size: 0.74rem;
        color: #a0aec0;
        font-weight: 500;
    }
    .btn-all {
        font-size: 0.78rem;
        padding: 4px 12px;
        border: 1px solid #cbd5e0;
        border-radius: 6px;
        color: #4a5568;
        text-decoration: none;
        white-space: nowrap;
        transition: background 0.15s;
    }
    .btn-all:hover { background: #f7fafc; color: #2d3748; }

    /* ── Shift schedule ── */
    .shift-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 10px 14px;
        border-radius: 8px;
        margin-bottom: 8px;
        background: #f8fafc;
        border-left: 4px solid #a0aec0;
    }
    .shift-item:last-child { margin-bottom: 0; }
    .shift-item.today  { border-left-color: #3182ce; background: #ebf8ff; }
    .shift-item.future { border-left-color: #38a169; }
    .shift-item.off    { border-left-color: #dd6b20; background: #fffaf0; }
    .shift-item.past   { opacity: 0.6; }
    .shift-day  { font-weight: 700; font-size: 0.85rem; color: #2d3748; }
    .shift-time { font-size: 0.82rem; color: #4a5568; display: flex; align-items: center; gap: 6px; }

    /* ── Responsive ── */
    @media (max-width: 991px) {
        .dashboard-row { flex-direction: column; }
    }
</style>

<div class="container dashboard-container">

    <!-- Welcome Banner -->
    <div class="welcome-banner">
        <h2>Chào buổi sáng, ${sessionScope.currentUser != null ? sessionScope.currentUser.fullName : 'Nhân viên'}!</h2>
        <p>Chúc bạn một ca làm việc năng suất và an toàn. Kiểm tra các thông báo mới nhất bên dưới.</p>
    </div>

    <!-- Main 3-column grid -->
    <div class="dashboard-row">

        <!-- ══ CỘT 1: Chấm công + Thống kê ══ -->
        <div class="dashboard-col">

            <!-- Chấm công -->
            <div class="card">
                <div class="card-header">
                    <span class="card-header-title">
                        <i class="fas fa-fingerprint text-primary"></i>
                        Chấm công Self-Service
                    </span>
                </div>
                <div class="clock-wrap">
                    <div class="clock-time" id="clockDisplay">00:00:00</div>
                    <div class="clock-date"  id="dateDisplay">—</div>
                    <button class="btn-checkin">
                        <i class="fas fa-sign-in-alt me-2"></i>CHẤM CÔNG VÀO
                    </button>
                    <div class="clock-location">
                        <i class="fas fa-map-marker-alt text-success me-1"></i>
                        Đã kết nối định vị (Nhà máy Khu B)
                    </div>
                </div>
            </div>

            <!-- Thống kê cá nhân -->
            <div class="card card-fill">
                <div class="card-header">
                    <span class="card-header-title">
                        <i class="fas fa-chart-pie text-success"></i>
                        Thống kê cá nhân (Tháng này)
                    </span>
                </div>

                <div class="stat-row">
                    <div class="stat-icon blue"><i class="fas fa-calendar-check"></i></div>
                    <div class="stat-content">
                        <h5>22 / 24</h5>
                        <span>Ngày công tiêu chuẩn</span>
                    </div>
                </div>

                <div class="stat-row">
                    <div class="stat-icon orange"><i class="fas fa-business-time"></i></div>
                    <div class="stat-content">
                        <h5>12.5h</h5>
                        <span>Giờ tăng ca (OT)</span>
                    </div>
                </div>

                <div class="stat-row">
                    <div class="stat-icon green"><i class="fas fa-umbrella-beach"></i></div>
                    <div class="stat-content">
                        <h5>10 ngày</h5>
                        <span>Phép năm còn lại</span>
                    </div>
                </div>
            </div>

        </div>
        <!-- ══ END CỘT 1 ══ -->


        <!-- ══ CỘT 2: Bảng tin ══ -->
        <div class="dashboard-col">
            <div class="card card-fill">
                <div class="card-header">
                    <span class="card-header-title">
                        <i class="fas fa-bullhorn text-warning"></i>
                        Bảng tin & Thông báo nội bộ
                    </span>
                    <a href="#" class="btn-all">Xem tất cả</a>
                </div>

                <div class="news-item">
                    <div class="news-icon" style="background:#e53e3e;">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <div class="news-content">
                        <h6>Nhắc nhở: Tuân thủ An toàn Lao động & Bảo hộ</h6>
                        <p>HSE yêu cầu toàn bộ CNVC khối Sản xuất mặc đầy đủ thiết bị bảo hộ khi vào xưởng lắp ráp.</p>
                        <span class="news-date"><i class="far fa-clock me-1"></i>Hôm qua, 15:30 · HSE Dept</span>
                    </div>
                </div>

                <div class="news-item">
                    <div class="news-icon" style="background:#3182ce;">
                        <i class="fas fa-gift"></i>
                    </div>
                    <div class="news-content">
                        <h6>Thông báo Chuyển lương & Thưởng KPI tháng trước</h6>
                        <p>Phòng Kế toán đã hoàn tất chuyển lương. Vui lòng kiểm tra "Phiếu lương" trong hệ thống.</p>
                        <span class="news-date"><i class="far fa-clock me-1"></i>12/05/2026 · Finance Dept</span>
                    </div>
                </div>

                <div class="news-item">
                    <div class="news-icon" style="background:#38a169;">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="news-content">
                        <h6>Khảo sát Môi trường làm việc Quý 2</h6>
                        <p>Đề nghị toàn bộ CBCNV dành 5 phút hoàn thành form khảo sát chất lượng bữa ăn ca.</p>
                        <span class="news-date"><i class="far fa-clock me-1"></i>10/05/2026 · HR Dept</span>
                    </div>
                </div>

            </div>
        </div>
        <!-- ══ END CỘT 2 ══ -->


        <!-- ══ CỘT 3: Lịch phân ca ══ -->
        <div class="dashboard-col">
            <div class="card card-fill">
                <div class="card-header">
                    <span class="card-header-title">
                        <i class="fas fa-calendar-alt text-info"></i>
                        Lịch Phân Ca (Tuần này)
                    </span>
                </div>

                <div class="shift-item past">
                    <span class="shift-day">Thứ 2 (Hôm qua)</span>
                    <span class="shift-time">
                        <span class="badge bg-secondary">Hành chính</span>08:00 – 17:00
                    </span>
                </div>

                <div class="shift-item today">
                    <span class="shift-day">Thứ 3 (Hôm nay)</span>
                    <span class="shift-time">
                        <span class="badge bg-primary">Hành chính</span>08:00 – 17:00
                    </span>
                </div>

                <div class="shift-item future">
                    <span class="shift-day">Thứ 4 (Ngày mai)</span>
                    <span class="shift-time">
                        <span class="badge bg-success">Ca Đêm</span>22:00 – 06:00
                    </span>
                </div>

                <div class="shift-item future">
                    <span class="shift-day">Thứ 5</span>
                    <span class="shift-time">
                        <span class="badge bg-success">Ca Đêm</span>22:00 – 06:00
                    </span>
                </div>

                <div class="shift-item future">
                    <span class="shift-day">Thứ 6</span>
                    <span class="shift-time">
                        <span class="badge bg-success">Ca Đêm</span>22:00 – 06:00
                    </span>
                </div>

                <div class="shift-item off">
                    <span class="shift-day">Thứ 7 & Chủ Nhật</span>
                    <span class="shift-time text-muted">
                        <i class="fas fa-bed me-1"></i>Nghỉ tuần
                    </span>
                </div>

            </div>
        </div>
        <!-- ══ END CỘT 3 ══ -->

    </div><!-- end .dashboard-row -->

</div><!-- end .dashboard-container -->

<script>
    function updateClock() {
        const now = new Date();
        document.getElementById('clockDisplay').textContent =
            now.toLocaleTimeString('vi-VN', { hour12: false });
        document.getElementById('dateDisplay').textContent =
            now.toLocaleDateString('vi-VN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
    }
    setInterval(updateClock, 1000);
    updateClock();
</script>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Bảng điều hành - Giám đốc" scope="request" />
<jsp:include page="../header.jsp" />

<style>
footer, #chatWidget { display: none !important; }
body { background: #f1f5f9; font-family: 'Inter', sans-serif; padding-top: 0 !important; min-height: 100vh; }
.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.dash-main { flex: 1; min-width: 0; background: #f1f5f9; }
.dash-content { padding: 28px 32px; display: flex; flex-direction: column; gap: 24px; }

/* ── Hero Welcome ── */
.director-hero {
    background: linear-gradient(135deg, #7c3aed 0%, #4f46e5 50%, #2563eb 100%);
    border-radius: 20px;
    padding: 32px 36px;
    color: #fff;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    box-shadow: 0 8px 32px rgba(124,58,237,0.25);
    position: relative;
    overflow: hidden;
}
.director-hero::before {
    content: '';
    position: absolute;
    top: -60px; right: -60px;
    width: 200px; height: 200px;
    border-radius: 50%;
    background: rgba(255,255,255,0.06);
}
.director-hero::after {
    content: '';
    position: absolute;
    bottom: -40px; left: 30%;
    width: 140px; height: 140px;
    border-radius: 50%;
    background: rgba(255,255,255,0.04);
}
.hero-left { position: relative; z-index: 1; }
.hero-greeting { font-size: 0.9rem; font-weight: 500; opacity: 0.75; margin-bottom: 8px; }
.hero-name { font-size: 1.7rem; font-weight: 800; letter-spacing: -0.5px; }
.hero-sub { font-size: 0.88rem; opacity: 0.7; margin-top: 6px; }
.hero-right { position: relative; z-index: 1; text-align: right; }
.hero-badge {
    display: inline-flex; align-items: center; gap: 8px;
    background: rgba(255,255,255,0.15);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255,255,255,0.2);
    border-radius: 12px;
    padding: 10px 18px;
    font-size: 0.88rem; font-weight: 700;
}
.hero-date { font-size: 0.8rem; opacity: 0.65; margin-top: 8px; }

/* ── Stat Cards ── */
.stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; }
.stat-card {
    background: #fff;
    border-radius: 16px;
    padding: 22px 24px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    display: flex; align-items: center; gap: 16px;
    transition: transform 0.2s, box-shadow 0.2s;
    position: relative; overflow: hidden;
}
.stat-card::after {
    content: '';
    position: absolute; bottom: 0; left: 0; right: 0;
    height: 3px; border-radius: 0 0 16px 16px;
}
.stat-card.purple::after { background: linear-gradient(90deg, #7c3aed, #4f46e5); }
.stat-card.blue::after   { background: linear-gradient(90deg, #2563eb, #0284c7); }
.stat-card.green::after  { background: linear-gradient(90deg, #059669, #0d9488); }
.stat-card.amber::after  { background: linear-gradient(90deg, #d97706, #dc2626); }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
.stat-icon {
    width: 52px; height: 52px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.3rem; flex-shrink: 0;
}
.stat-icon.purple { background: #f3f0ff; color: #7c3aed; }
.stat-icon.blue   { background: #eff6ff; color: #2563eb; }
.stat-icon.green  { background: #f0fdf4; color: #059669; }
.stat-icon.amber  { background: #fffbeb; color: #d97706; }
.stat-val { font-size: 2rem; font-weight: 800; color: #0f172a; line-height: 1; }
.stat-label { font-size: 0.78rem; color: #64748b; font-weight: 600;
              text-transform: uppercase; letter-spacing: 0.5px; margin-top: 4px; }
.stat-sub { font-size: 0.75rem; color: #94a3b8; margin-top: 2px; }

/* ── Coming Soon Card ── */
.coming-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 18px; }
.coming-card {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    border: 1px solid #e2e8f0;
    border-style: dashed;
    box-shadow: 0 1px 3px rgba(0,0,0,0.03);
    display: flex; flex-direction: column; gap: 12px;
}
.coming-header { display: flex; align-items: center; gap: 12px; }
.coming-icon {
    width: 42px; height: 42px; border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1rem; opacity: 0.6;
}
.coming-title { font-size: 0.95rem; font-weight: 700; color: #374151; }
.coming-desc { font-size: 0.83rem; color: #94a3b8; line-height: 1.5; }
.coming-badge {
    display: inline-flex; align-items: center; gap: 5px;
    background: #fef3c7; color: #92400e;
    border-radius: 6px; padding: 4px 10px;
    font-size: 0.75rem; font-weight: 700; width: fit-content;
}

/* ── Section Title ── */
.section-title {
    font-size: 1rem; font-weight: 700; color: #374151;
    display: flex; align-items: center; gap: 8px;
    margin-bottom: -8px;
}
.section-title::before {
    content: ''; display: block;
    width: 4px; height: 18px; border-radius: 2px;
    background: linear-gradient(180deg, #7c3aed, #4f46e5);
}

@media (max-width: 768px) {
    .dash-content { padding: 20px 16px; }
    .director-hero { flex-direction: column; align-items: flex-start; }
    .hero-right { text-align: left; }
}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="director-dashboard"/>
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">

            <%-- Hero Banner --%>
            <div class="director-hero">
                <div class="hero-left">
                    <div class="hero-greeting">Xin chào,</div>
                    <div class="hero-name">${sessionScope.currentUser.fullName}</div>
                    <div class="hero-sub">Bảng điều hành — Tổng quan toàn công ty</div>
                </div>
                <div class="hero-right">
                    <div class="hero-badge">
                        <i class="fas fa-user-tie"></i> Giám đốc
                    </div>
                    <div class="hero-date" id="directorDate"></div>
                </div>
            </div>

            <%-- Stats hiện có --%>
            <div class="section-title">Tổng quan nhân sự</div>
            <div class="stat-grid">
                <div class="stat-card purple">
                    <div class="stat-icon purple"><i class="fas fa-users"></i></div>
                    <div>
                        <div class="stat-val">${totalEmployees}</div>
                        <div class="stat-label">Tổng nhân sự</div>
                        <div class="stat-sub">Toàn công ty</div>
                    </div>
                </div>
                <div class="stat-card green">
                    <div class="stat-icon green"><i class="fas fa-user-check"></i></div>
                    <div>
                        <div class="stat-val">${activeEmployees}</div>
                        <div class="stat-label">Nhân viên đang làm việc</div>
                        <div class="stat-sub">Trạng thái active</div>
                    </div>
                </div>
                <div class="stat-card blue">
                    <div class="stat-icon blue"><i class="fas fa-user-times"></i></div>
                    <div>
                        <div class="stat-val">${totalEmployees - activeEmployees}</div>
                        <div class="stat-label">Đã nghỉ việc</div>
                        <div class="stat-sub">Tài khoản inactive</div>
                    </div>
                </div>
            </div>

            <%-- Modules sắp có (Iteration 2) --%>
            <div class="section-title">Tính năng sắp có — Iteration 2</div>
            <div class="coming-grid">
                <div class="coming-card">
                    <div class="coming-header">
                        <div class="coming-icon" style="background:#f3f0ff;color:#7c3aed;">
                            <i class="fas fa-file-invoice-dollar"></i>
                        </div>
                        <div class="coming-title">Duyệt chốt bảng lương</div>
                    </div>
                    <div class="coming-desc">
                        Xem và phê duyệt chốt bảng lương tháng sau khi HR Manager đã kiểm tra lần đầu.
                        Sau khi Giám đốc duyệt, HR Staff xuất file payroll gửi ngân hàng.
                    </div>
                    <div class="coming-badge"><i class="fas fa-clock"></i> Iteration 2</div>
                </div>

                <div class="coming-card">
                    <div class="coming-header">
                        <div class="coming-icon" style="background:#fffbeb;color:#d97706;">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <div class="coming-title">Báo cáo tổng hợp</div>
                    </div>
                    <div class="coming-desc">
                        Báo cáo biến động nhân sự, tổng quỹ lương theo tháng/quý,
                        thống kê nghỉ phép và tăng ca toàn công ty.
                    </div>
                    <div class="coming-badge"><i class="fas fa-clock"></i> Iteration 2</div>
                </div>

                <div class="coming-card">
                    <div class="coming-header">
                        <div class="coming-icon" style="background:#fef2f2;color:#dc2626;">
                            <i class="fas fa-file-contract"></i>
                        </div>
                        <div class="coming-title">Hợp đồng sắp hết hạn</div>
                    </div>
                    <div class="coming-desc">
                        Danh sách nhân viên có hợp đồng hết hạn trong 30–60 ngày tới,
                        để Giám đốc nắm trước và chỉ đạo HR xử lý gia hạn.
                    </div>
                    <div class="coming-badge"><i class="fas fa-clock"></i> Iteration 2</div>
                </div>
            </div>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div>

<script>
// Hiển thị ngày giờ hiện tại
(function() {
    const el = document.getElementById('directorDate');
    if (!el) return;
    const now = new Date();
    const days = ['Chủ nhật','Thứ hai','Thứ ba','Thứ tư','Thứ năm','Thứ sáu','Thứ bảy'];
    el.textContent = days[now.getDay()] + ', ' +
        now.toLocaleDateString('vi-VN', { day:'2-digit', month:'2-digit', year:'numeric' });
})();
</script>

<jsp:include page="../footer.jsp" />

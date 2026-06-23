<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Bảng Điều Khiển Quản Lý" scope="request"/>
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
footer, #chatWidget { display: none !important; }

body {
    background-color: #f1f5f9 !important;
    font-family: 'Inter', sans-serif !important;
    padding-top: 0 !important;
    min-height: 100vh;
    overflow-x: hidden;
}

/* ── Layout ── */
.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.dash-main { flex: 1; min-width: 0; background: #f1f5f9; }
.dash-content { padding: 28px 32px; display: flex; flex-direction: column; gap: 28px; }

/* ── Page Header ── */
.dash-page-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; }
.dash-page-header-left { display: flex; flex-direction: column; gap: 4px; }
.dash-breadcrumb { font-size: 0.78rem; color: #94a3b8; display: flex; align-items: center; gap: 6px; }
.dash-breadcrumb a { color: #0d9488; text-decoration: none; }
.dash-breadcrumb a:hover { text-decoration: underline; }
.dash-page-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; letter-spacing: -0.5px; }
.dash-role-badge {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 14px; border-radius: 20px;
    font-size: 0.8rem; font-weight: 700;
    background: linear-gradient(135deg, #0d9488, #0369a1);
    color: #fff; box-shadow: 0 2px 8px rgba(13,148,136,0.3);
}

/* ── Stat Cards ── */
.dash-stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; }
.dash-stat-card {
    background: #fff; border-radius: 16px; padding: 22px 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e2e8f0;
    display: flex; flex-direction: column; gap: 10px;
    transition: transform 0.2s, box-shadow 0.2s;
}
.dash-stat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
.dash-stat-header { display: flex; justify-content: space-between; align-items: flex-start; }
.dash-stat-title { font-size: 0.75rem; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.6px; }
.dash-stat-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1rem; }
.dash-stat-val { font-size: 2rem; font-weight: 800; color: #0f172a; line-height: 1.1; }
.dash-stat-change { font-size: 0.75rem; font-weight: 600; display: flex; align-items: center; gap: 4px; }
.dash-stat-change.up { color: #10b981; }
.dash-stat-change.down { color: #ef4444; }
.dash-stat-change.neutral { color: #94a3b8; }

.dash-stat-card.stat-warning { border-left: 4px solid #f59e0b; }
.dash-stat-card.stat-warning .dash-stat-icon { background: #fef3c7; color: #d97706; }
.dash-stat-card.stat-danger { border-left: 4px solid #ef4444; }
.dash-stat-card.stat-danger .dash-stat-icon { background: #fee2e2; color: #dc2626; }
.dash-stat-card.stat-success { border-left: 4px solid #10b981; }
.dash-stat-card.stat-success .dash-stat-icon { background: #d1fae5; color: #059669; }
.dash-stat-card.stat-teal { border-left: 4px solid #0d9488; }
.dash-stat-card.stat-teal .dash-stat-icon { background: #ccfbf1; color: #0d9488; }

/* ── Charts ── */
.dash-charts-grid { display: grid; grid-template-columns: 1.6fr 1fr; gap: 20px; }
@media (max-width: 1100px) { .dash-charts-grid { grid-template-columns: 1fr; } }

.dash-card {
    background: #fff; border-radius: 16px; padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e2e8f0;
}
.dash-card-header { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
.dash-card-title { font-size: 0.95rem; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 8px; }

@media (max-width: 768px) { .dash-content { padding: 20px 16px; } }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">

            <%-- ── Page Header ── --%>
            <div class="dash-page-header">
                <div class="dash-page-header-left">
                    <div class="dash-breadcrumb">
                        <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                        <span>/</span>
                        <span>Dashboard</span>
                    </div>
                    <div class="dash-page-title">
                        Tổng Quan Hoạt Động
                    </div>
                </div>
                <div class="dash-role-badge">
                    <i class="fas fa-briefcase"></i> Quản lý
                </div>
            </div>

            <%-- ── FACTORY / DEPT MANAGER STATS ── --%>
            <div class="dash-stat-grid">
                <div class="dash-stat-card stat-teal">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Nhân Sự Quản Lý</span>
                        <div class="dash-stat-icon"><i class="fas fa-users-cog"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty totalEmployees ? totalEmployees : '—'}</div>
                    <div class="dash-stat-change up">Nhân viên / Công nhân</div>
                </div>
                <div class="dash-stat-card stat-success">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Chấm Công Hôm Nay</span>
                        <div class="dash-stat-icon"><i class="fas fa-user-clock"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty todayAttendance ? todayAttendance : '0'}</div>
                    <div class="dash-stat-change neutral">Đã điểm danh</div>
                </div>
                <div class="dash-stat-card stat-warning">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Yêu Cầu Làm Thêm (OT)</span>
                        <div class="dash-stat-icon"><i class="fas fa-business-time"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty pendingOT ? pendingOT : '0'}</div>
                    <div class="dash-stat-change down">Chờ phê duyệt</div>
                </div>
                <div class="dash-stat-card stat-danger">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Đơn Xin Nghỉ Phép</span>
                        <div class="dash-stat-icon"><i class="fas fa-calendar-times"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty pendingLeaves ? pendingLeaves : '0'}</div>
                    <div class="dash-stat-change neutral">Chờ duyệt</div>
                </div>
            </div>

            <%-- Manager Charts --%>
            <div class="dash-charts-grid">
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">Hiệu Suất Sản Xuất / Công Việc</h3>
                    </div>
                    <div style="height:300px;"><canvas id="performanceChart"></canvas></div>
                </div>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">Phân Bổ Ca Làm Việc</h3>
                    </div>
                    <div style="height:300px;"><canvas id="shiftChart"></canvas></div>
                </div>
            </div>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div><%-- end dashboard-wrapper --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    new Chart(document.getElementById('performanceChart').getContext('2d'), {
        type: 'bar',
        data: {
            labels: ['Tuần 1','Tuần 2','Tuần 3','Tuần 4'],
            datasets: [
                { label:'Mục tiêu', data:[100,100,100,100], backgroundColor:'rgba(148,163,184,0.3)', borderRadius:4 },
                { label:'Thực tế', data:[95,102,98,105], backgroundColor:'#0d9488', borderRadius:4 }
            ]
        },
        options: { responsive:true, maintainAspectRatio:false }
    });
    new Chart(document.getElementById('shiftChart').getContext('2d'), {
        type: 'pie',
        data: {
            labels: ['Ca Hành Chính','Ca Đêm 1','Ca Đêm 2','Nghỉ'],
            datasets: [{ data:[40,25,20,15], backgroundColor:['#10b981','#f59e0b','#6366f1','#dd6b20'], borderWidth:2 }]
        },
        options: { responsive:true, maintainAspectRatio:false, plugins:{ legend:{ position:'right' } } }
    });
});
</script>

<jsp:include page="../footer.jsp" />

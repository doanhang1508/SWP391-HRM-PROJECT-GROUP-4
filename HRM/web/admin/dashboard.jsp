<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Bảng Điều Khiển Admin" scope="request"/>
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
.dash-stat-card.stat-blue { border-left: 4px solid #3b82f6; }
.dash-stat-card.stat-blue .dash-stat-icon { background: #dbeafe; color: #2563eb; }
.dash-stat-card.stat-purple { border-left: 4px solid #8b5cf6; }
.dash-stat-card.stat-purple .dash-stat-icon { background: #ede9fe; color: #7c3aed; }

/* ── Charts ── */
.dash-charts-grid { display: grid; grid-template-columns: 1.6fr 1fr; gap: 20px; }
@media (max-width: 1100px) { .dash-charts-grid { grid-template-columns: 1fr; } }

.dash-card {
    background: #fff; border-radius: 16px; padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e2e8f0;
}
.dash-card-header { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
.dash-card-title { font-size: 0.95rem; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 8px; }
.dash-card-title-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.dot-teal { background: #0d9488; } .dot-blue { background: #3b82f6; } .dot-orange { background: #f59e0b; }

/* ── Table ── */
.dash-table-container { width: 100%; overflow-x: auto; }
.dash-table { width: 100%; border-collapse: collapse; text-align: left; }
.dash-table th {
    padding: 12px 16px; border-bottom: 1px solid #e2e8f0;
    color: #64748b; font-size: 0.73rem; font-weight: 700;
    text-transform: uppercase; letter-spacing: 0.6px; background: #fafbfc;
}
.dash-table td { padding: 15px 16px; border-bottom: 1px solid #f1f5f9; color: #0f172a; font-size: 0.88rem; vertical-align: middle; }
.dash-table tbody tr:last-child td { border-bottom: none; }
.dash-table tbody tr:hover td { background: #f8fafc; }
.dash-emp-cell { display: flex; align-items: center; gap: 10px; }
.dash-emp-avatar {
    width: 34px; height: 34px; border-radius: 8px;
    background: #eff6ff; color: #3b82f6;
    display: flex; align-items: center; justify-content: center;
    font-weight: 700; font-size: 0.85rem; flex-shrink: 0;
}
.dash-btn {
    padding: 6px 14px; font-size: 0.8rem; font-weight: 700;
    border-radius: 8px; border: none; cursor: pointer;
    transition: all 0.2s; text-decoration: none; display: inline-block;
}
.dash-btn-primary { background: #0d9488; color: #fff; }
.dash-btn-primary:hover { background: #0f766e; }
.dash-btn-secondary { background: #f1f5f9; color: #475569; }
.dash-btn-secondary:hover { background: #e2e8f0; }
.dash-badge { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 20px; font-size: 0.73rem; font-weight: 700; }
.badge-pending   { background: #fef3c7; color: #d97706; }
.badge-completed { background: #d1fae5; color: #059669; }
.badge-rejected  { background: #fee2e2; color: #dc2626; }

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
                        Tổng Quan Hệ Thống
                    </div>
                </div>
                <div class="dash-role-badge">
                    <i class="fas fa-server"></i> Admin
                </div>
            </div>

            <%-- ── ADMIN STATS ── --%>
            <div class="dash-stat-grid">
                <div class="dash-stat-card stat-teal">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Người Dùng Hoạt Động</span>
                        <div class="dash-stat-icon"><i class="fas fa-user-check"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty activeUsers ? activeUsers : '—'}</div>
                    <div class="dash-stat-change up"><i class="fas fa-arrow-up"></i> Đang hoạt động</div>
                </div>
                <div class="dash-stat-card stat-blue">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Tổng Người Dùng</span>
                        <div class="dash-stat-icon"><i class="fas fa-users"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty totalUsers ? totalUsers : '—'}</div>
                    <div class="dash-stat-change neutral">Toàn hệ thống</div>
                </div>
                <div class="dash-stat-card stat-danger">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Tài Khoản Bị Khóa</span>
                        <div class="dash-stat-icon"><i class="fas fa-user-slash"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty lockedUsers ? lockedUsers : '0'}</div>
                    <div class="dash-stat-change down"><i class="fas fa-lock"></i> Đang bị tạm khóa</div>
                </div>
                <div class="dash-stat-card stat-success">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Vai Trò Hệ Thống</span>
                        <div class="dash-stat-icon"><i class="fas fa-user-shield"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty totalRoles ? totalRoles : '—'}</div>
                    <div class="dash-stat-change neutral">Đang hoạt động</div>
                </div>
            </div>

            <%-- Admin Charts --%>
            <div class="dash-charts-grid">
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-teal"></div>
                            Lượt Đăng Nhập (7 Ngày Qua)
                        </h3>
                    </div>
                    <div style="position:relative;height:280px;width:100%;">
                        <canvas id="trafficChart"></canvas>
                    </div>
                </div>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-blue"></div>
                            Phân Bổ Theo Vai Trò
                        </h3>
                    </div>
                    <div style="position:relative;height:280px;width:100%;display:flex;justify-content:center;align-items:center;">
                        <canvas id="rolesChart"></canvas>
                    </div>
                </div>
            </div>

            <%-- Admin: danh sách user gần đây --%>
            <div class="dash-card">
                <div class="dash-card-header">
                    <h3 class="dash-card-title">
                        <div class="dash-card-title-dot dot-orange"></div>
                        Người Dùng Gần Đây
                    </h3>
                    <a href="${pageContext.request.contextPath}/admin/users" class="dash-btn dash-btn-secondary">Xem tất cả</a>
                </div>
                <div class="dash-table-container">
                    <table class="dash-table">
                        <thead><tr><th>Họ Tên</th><th>Email</th><th>Trạng Thái</th><th>Chi Tiết</th></tr></thead>
                        <tbody>
                            <c:forEach items="${recentUsers}" var="u">
                                <tr>
                                    <td>
                                        <div class="dash-emp-cell">
                                            <div class="dash-emp-avatar">${fn:substring(u.fullName,0,1)}</div>
                                            <span style="font-weight:600;">${u.fullName}</span>
                                        </div>
                                    </td>
                                    <td style="color:#64748b;">${u.email}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.status == 1}">
                                                <span class="dash-badge badge-completed"><i class="fas fa-circle" style="font-size:.55rem;"></i> Hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="dash-badge badge-rejected"><i class="fas fa-circle" style="font-size:.55rem;"></i> Bị khóa</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/users?id=${u.userId}" class="dash-btn dash-btn-primary">Xem</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div><%-- end dashboard-wrapper --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    new Chart(document.getElementById('trafficChart').getContext('2d'), {
        type: 'line',
        data: {
            labels: ['21/05','22/05','23/05','24/05','25/05','26/05','27/05'],
            datasets: [
                { label: 'Đăng nhập thành công', data: [1120,1280,850,420,1340,1420,1245],
                  borderColor:'#0d9488', backgroundColor:'rgba(13,148,136,0.06)', fill:true, tension:0.35, borderWidth:2.5, pointBackgroundColor:'#0d9488', pointRadius:4 },
                { label: 'Đăng nhập thất bại', data: [15,24,18,5,29,32,21],
                  borderColor:'#ef4444', fill:false, tension:0.35, borderWidth:2, borderDash:[6,4], pointBackgroundColor:'#ef4444', pointRadius:3 }
            ]
        },
        options: { responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{ position:'top', labels:{ boxWidth:12, font:{family:'Inter',size:12}, padding:16 }}},
            scales:{ y:{ grid:{color:'rgba(0,0,0,0.04)'}, ticks:{font:{family:'Inter',size:11},color:'#94a3b8'}},
                     x:{ grid:{display:false}, ticks:{font:{family:'Inter',size:11},color:'#94a3b8'}}}}
    });
    new Chart(document.getElementById('rolesChart').getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: ['Admin','HR Manager','Quản đốc','Giám đốc'],
            datasets: [{ data:[10,30,20,5], backgroundColor:['#0d9488','#3b82f6','#f59e0b','#8b5cf6'], borderWidth:3, borderColor:'#fff' }]
        },
        options: { responsive:true, maintainAspectRatio:false, cutout:'68%',
            plugins:{ legend:{ position:'bottom', labels:{ boxWidth:12, padding:18, font:{family:'Inter',size:12}}}}}
    });
});
</script>

<jsp:include page="../footer.jsp" />

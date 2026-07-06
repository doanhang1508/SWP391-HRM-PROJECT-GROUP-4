<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Bảng Điều Khiển Admin" scope="request"/>
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
footer, #chatWidget { display: none !important; }

*, *::before, *::after { box-sizing: border-box; }

body {
    background: #f0f2f5 !important;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif !important;
    padding-top: 0 !important;
    min-height: 100vh;
    color: #1a1d23;
}

/* Layout */
.db-wrap { display: flex; min-height: calc(100vh - 64px); }
.db-main { flex: 1; min-width: 0; padding: 28px 32px; display: flex; flex-direction: column; gap: 24px; }

/* Header */
.db-header { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; }
.db-header-left { display: flex; flex-direction: column; gap: 4px; }
.db-breadcrumb { font-size: 0.8rem; color: #8892a4; display: flex; align-items: center; gap: 6px; }
.db-breadcrumb a { color: #4f7ef8; text-decoration: none; }
.db-title { font-size: 1.6rem; font-weight: 700; color: #111827; letter-spacing: -0.3px; margin: 0; }
.db-subtitle { font-size: 0.85rem; color: #6b7280; margin-top: 2px; }
.db-date-badge {
    display: flex; align-items: center; gap: 8px;
    padding: 8px 16px; border-radius: 10px;
    background: #fff; border: 1px solid #e5e7eb;
    font-size: 0.82rem; font-weight: 600; color: #374151;
    box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}

/* Stat Cards Row */
.stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
@media (max-width: 1200px) { .stat-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 640px) { .stat-grid { grid-template-columns: 1fr; } }

.stat-card {
    background: #fff;
    border-radius: 16px;
    padding: 22px 24px;
    border: 1px solid #f0f0f0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    display: flex; align-items: center; gap: 18px;
    transition: box-shadow 0.25s, transform 0.25s;
    position: relative; overflow: hidden;
}
.stat-card::before {
    content: ''; position: absolute; top: 0; left: 0;
    width: 4px; height: 100%; border-radius: 16px 0 0 16px;
}
.stat-card:hover { box-shadow: 0 8px 24px rgba(0,0,0,0.09); transform: translateY(-2px); }

.stat-card.blue::before { background: linear-gradient(180deg, #4f7ef8, #3b5fce); }
.stat-card.green::before { background: linear-gradient(180deg, #22c55e, #16a34a); }
.stat-card.red::before { background: linear-gradient(180deg, #f43f5e, #e11d48); }
.stat-card.purple::before { background: linear-gradient(180deg, #a855f7, #9333ea); }

.stat-icon {
    width: 52px; height: 52px; border-radius: 14px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.25rem; color: #fff; flex-shrink: 0;
}
.stat-card.blue .stat-icon { background: linear-gradient(135deg, #4f7ef8, #3b5fce); }
.stat-card.green .stat-icon { background: linear-gradient(135deg, #22c55e, #16a34a); }
.stat-card.red .stat-icon { background: linear-gradient(135deg, #f43f5e, #e11d48); }
.stat-card.purple .stat-icon { background: linear-gradient(135deg, #a855f7, #9333ea); }

.stat-body { flex: 1; min-width: 0; }
.stat-val { font-size: 2rem; font-weight: 800; color: #111827; line-height: 1; }
.stat-lbl { font-size: 0.8rem; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.4px; margin-top: 4px; }
.stat-sub { font-size: 0.78rem; color: #9ca3af; margin-top: 6px; }
.stat-pct {
    font-size: 0.75rem; font-weight: 700;
    padding: 3px 8px; border-radius: 20px; margin-top: 6px; display: inline-block;
}
.pct-green { background: #dcfce7; color: #15803d; }
.pct-red { background: #fee2e2; color: #b91c1c; }
.pct-blue { background: #dbeafe; color: #1d4ed8; }
.pct-purple { background: #f3e8ff; color: #7e22ce; }

/* Card base */
.card {
    background: #fff; border-radius: 16px;
    border: 1px solid #f0f0f0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    padding: 24px;
}
.card-head {
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 20px;
}
.card-title {
    font-size: 0.95rem; font-weight: 700; color: #111827;
    display: flex; align-items: center; gap: 10px; margin: 0;
}
.card-icon {
    width: 30px; height: 30px; border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.8rem; color: #fff;
}
.ci-blue { background: linear-gradient(135deg, #4f7ef8, #3b5fce); }
.ci-green { background: linear-gradient(135deg, #22c55e, #16a34a); }
.ci-orange { background: linear-gradient(135deg, #f59e0b, #d97706); }
.ci-teal { background: linear-gradient(135deg, #14b8a6, #0d9488); }
.ci-purple { background: linear-gradient(135deg, #a855f7, #9333ea); }

.card-link {
    font-size: 0.8rem; font-weight: 600; color: #4f7ef8;
    text-decoration: none; padding: 6px 12px; border-radius: 8px;
    background: #eff4ff; transition: background 0.2s;
}
.card-link:hover { background: #dbeafe; color: #1d4ed8; }

/* Charts row */
.charts-row { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }
@media (max-width: 1100px) { .charts-row { grid-template-columns: 1fr; } }

/* Onboarding + Quick Actions row */
.bottom-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
@media (max-width: 900px) { .bottom-row { grid-template-columns: 1fr; } }

/* Onboarding progress */
.onb-items { display: flex; flex-direction: column; gap: 14px; }
.onb-item { display: flex; flex-direction: column; gap: 6px; }
.onb-item-head { display: flex; justify-content: space-between; align-items: center; }
.onb-label { font-size: 0.85rem; font-weight: 600; color: #374151; display: flex; align-items: center; gap: 8px; }
.onb-dot { width: 8px; height: 8px; border-radius: 50%; }
.onb-val { font-size: 0.85rem; font-weight: 700; color: #111827; }
.prog-bar { height: 8px; background: #f3f4f6; border-radius: 99px; overflow: hidden; }
.prog-fill { height: 100%; border-radius: 99px; transition: width 1s ease; }

/* Quick Actions */
.qa-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.qa-btn {
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    gap: 10px; padding: 20px 12px; border-radius: 14px;
    background: #f9fafb; border: 1.5px solid #f0f0f0;
    text-decoration: none; transition: all 0.2s; cursor: pointer;
    text-align: center;
}
.qa-btn:hover { background: #f0f4ff; border-color: #c7d7fd; transform: translateY(-2px); box-shadow: 0 6px 16px rgba(79,126,248,0.1); }
.qa-icon {
    width: 44px; height: 44px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem; color: #fff;
}
.qa-text { font-size: 0.8rem; font-weight: 600; color: #374151; }

/* User Table */
.user-table-wrap { overflow-x: auto; }
.user-table { width: 100%; border-collapse: collapse; }
.user-table th {
    padding: 10px 14px; font-size: 0.75rem; font-weight: 700;
    color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px;
    background: #f9fafb; border-bottom: 1px solid #f0f0f0;
}
.user-table th:first-child { border-radius: 10px 0 0 10px; }
.user-table th:last-child { border-radius: 0 10px 10px 0; }
.user-table td {
    padding: 14px; font-size: 0.875rem; color: #374151;
    border-bottom: 1px solid #f9fafb; vertical-align: middle;
}
.user-table tbody tr:hover td { background: #f9fbff; }
.user-table tbody tr:last-child td { border-bottom: none; }

.ua { display: flex; align-items: center; gap: 12px; }
.av {
    width: 38px; height: 38px; border-radius: 10px; flex-shrink: 0;
    background: linear-gradient(135deg, #dbeafe, #c7d2fe);
    color: #3730a3; font-weight: 800; font-size: 0.95rem;
    display: flex; align-items: center; justify-content: center;
}
.un { font-weight: 600; color: #111827; font-size: 0.875rem; }
.ue { font-size: 0.78rem; color: #9ca3af; }

.badge { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
.badge::before { content:''; width:6px; height:6px; border-radius:50%; }
.badge-on { background: #dcfce7; color: #15803d; }
.badge-on::before { background: #22c55e; }
.badge-off { background: #fee2e2; color: #b91c1c; }
.badge-off::before { background: #ef4444; }

.btn-act {
    font-size: 0.78rem; font-weight: 600; padding: 6px 14px;
    border-radius: 8px; background: #eff4ff; color: #4f7ef8;
    text-decoration: none; border: 1px solid #dbeafe;
    transition: all 0.2s; display: inline-block;
}
.btn-act:hover { background: #4f7ef8; color: #fff; }
</style>

<div class="db-wrap">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <div class="db-main">

        <%-- Header --%>
        <div class="db-header">
            <div class="db-header-left">
                <div class="db-breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <i class="fas fa-chevron-right" style="font-size:0.65rem;color:#d1d5db;"></i>
                    <span>Dashboard</span>
                </div>
                <h1 class="db-title">Tổng Quan Hệ Thống</h1>
                <div class="db-subtitle">Giám sát tài khoản, phân quyền và trạng thái hệ thống</div>
            </div>
            <div class="db-date-badge">
                <i class="fas fa-crown" style="color:#f59e0b;"></i>
                <span>Quản Trị Viên</span>
            </div>
        </div>

        <%-- Stat Cards --%>
        <div class="stat-grid">
            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-users"></i></div>
                <div class="stat-body">
                    <div class="stat-val">${totalUsers}</div>
                    <div class="stat-lbl">Tổng Người Dùng</div>
                    <span class="stat-pct pct-blue">Toàn hệ thống</span>
                </div>
            </div>
            <div class="stat-card green">
                <div class="stat-icon"><i class="fas fa-user-check"></i></div>
                <div class="stat-body">
                    <div class="stat-val">${activeUsers}</div>
                    <div class="stat-lbl">Đang Hoạt Động</div>
                    <c:if test="${totalUsers > 0}">
                        <span class="stat-pct pct-green">
                            <fmt:formatNumber value="${activeUsers * 100 / totalUsers}" maxFractionDigits="1"/>% tài khoản
                        </span>
                    </c:if>
                </div>
            </div>
            <div class="stat-card red">
                <div class="stat-icon"><i class="fas fa-user-lock"></i></div>
                <div class="stat-body">
                    <div class="stat-val">${lockedUsers}</div>
                    <div class="stat-lbl">Bị Vô Hiệu Hóa</div>
                    <c:if test="${totalUsers > 0}">
                        <span class="stat-pct pct-red">
                            <fmt:formatNumber value="${lockedUsers * 100 / totalUsers}" maxFractionDigits="1"/>% tài khoản
                        </span>
                    </c:if>
                </div>
            </div>
            <div class="stat-card purple">
                <div class="stat-icon"><i class="fas fa-shield-alt"></i></div>
                <div class="stat-body">
                    <div class="stat-val">${totalRoles}</div>
                    <div class="stat-lbl">Vai Trò</div>
                    <span class="stat-pct pct-purple">Nhóm phân quyền</span>
                </div>
            </div>
        </div>

        <%-- Charts Row --%>
        <div class="charts-row">
            <div class="card">
                <div class="card-head">
                    <h3 class="card-title">
                        <div class="card-icon ci-blue"><i class="fas fa-chart-line"></i></div>
                        Tăng Trưởng Người Dùng (6 Tháng Gần Nhất)
                    </h3>
                </div>
                <div style="position:relative;height:260px;">
                    <canvas id="growthChart"></canvas>
                </div>
            </div>
            <div class="card">
                <div class="card-head">
                    <h3 class="card-title">
                        <div class="card-icon ci-teal"><i class="fas fa-chart-pie"></i></div>
                        Phân Bổ Vai Trò
                    </h3>
                </div>
                <div style="position:relative;height:260px;display:flex;align-items:center;justify-content:center;">
                    <canvas id="rolesChart"></canvas>
                </div>
            </div>
        </div>

        <%-- Onboarding + Quick Actions --%>
        <div class="bottom-row">
            <div class="card">
                <div class="card-head">
                    <h3 class="card-title">
                        <div class="card-icon ci-orange"><i class="fas fa-user-plus"></i></div>
                        Trạng Thái Yêu Cầu Onboarding
                    </h3>
                    <a href="${pageContext.request.contextPath}/admin/onboarding/list" class="card-link">Xem tất cả</a>
                </div>
                <div class="onb-items">
                    <div class="onb-item">
                        <div class="onb-item-head">
                            <span class="onb-label"><span class="onb-dot" style="background:#6b7280;"></span>Tổng yêu cầu</span>
                            <span class="onb-val">${onboardingTotal}</span>
                        </div>
                        <div class="prog-bar"><div class="prog-fill" style="width:100%;background:#6b7280;"></div></div>
                    </div>
                    <div class="onb-item">
                        <div class="onb-item-head">
                            <span class="onb-label"><span class="onb-dot" style="background:#f59e0b;"></span>Đang chờ duyệt</span>
                            <span class="onb-val" style="color:#d97706;">${onboardingPending}</span>
                        </div>
                        <div class="prog-bar">
                            <div class="prog-fill" style="background:linear-gradient(90deg,#fbbf24,#f59e0b);
                                width:<c:choose><c:when test="${onboardingTotal > 0}">${onboardingPending * 100 / onboardingTotal}%</c:when><c:otherwise>0%</c:otherwise></c:choose>;"></div>
                        </div>
                    </div>
                    <div class="onb-item">
                        <div class="onb-item-head">
                            <span class="onb-label"><span class="onb-dot" style="background:#22c55e;"></span>Đã phê duyệt</span>
                            <span class="onb-val" style="color:#15803d;">${onboardingApproved}</span>
                        </div>
                        <div class="prog-bar">
                            <div class="prog-fill" style="background:linear-gradient(90deg,#4ade80,#22c55e);
                                width:<c:choose><c:when test="${onboardingTotal > 0}">${onboardingApproved * 100 / onboardingTotal}%</c:when><c:otherwise>0%</c:otherwise></c:choose>;"></div>
                        </div>
                    </div>
                    <div class="onb-item">
                        <div class="onb-item-head">
                            <span class="onb-label"><span class="onb-dot" style="background:#ef4444;"></span>Đã từ chối</span>
                            <span class="onb-val" style="color:#b91c1c;">${onboardingRejected}</span>
                        </div>
                        <div class="prog-bar">
                            <div class="prog-fill" style="background:linear-gradient(90deg,#f87171,#ef4444);
                                width:<c:choose><c:when test="${onboardingTotal > 0}">${onboardingRejected * 100 / onboardingTotal}%</c:when><c:otherwise>0%</c:otherwise></c:choose>;"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-head">
                    <h3 class="card-title">
                        <div class="card-icon ci-purple"><i class="fas fa-bolt"></i></div>
                        Thao Tác Nhanh
                    </h3>
                </div>
                <div class="qa-grid">
                    <a href="${pageContext.request.contextPath}/admin/users" class="qa-btn">
                        <div class="qa-icon" style="background:linear-gradient(135deg,#4f7ef8,#3b5fce);"><i class="fas fa-users"></i></div>
                        <span class="qa-text">Quản lý<br>Người Dùng</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/role" class="qa-btn">
                        <div class="qa-icon" style="background:linear-gradient(135deg,#a855f7,#9333ea);"><i class="fas fa-shield-alt"></i></div>
                        <span class="qa-text">Phân Quyền<br>Vai Trò</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/onboarding/list" class="qa-btn">
                        <div class="qa-icon" style="background:linear-gradient(135deg,#f59e0b,#d97706);"><i class="fas fa-user-plus"></i></div>
                        <span class="qa-text">Yêu Cầu<br>Onboarding</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/editRolePermission" class="qa-btn">
                        <div class="qa-icon" style="background:linear-gradient(135deg,#14b8a6,#0d9488);"><i class="fas fa-key"></i></div>
                        <span class="qa-text">Cấu Hình<br>Quyền Hạn</span>
                    </a>
                </div>
            </div>
        </div>

    </div><%-- end db-main --%>
</div><%-- end db-wrap --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    Chart.defaults.font.family = "'Inter', sans-serif";
    Chart.defaults.color = '#6b7280';

    const growthLabels = ${growthLabels};
    const growthValues = ${growthValues};
    const roleLabels   = ${roleLabels};
    const roleValues   = ${roleValues};

    // Line Chart
    const ctxG = document.getElementById('growthChart').getContext('2d');
    const grad = ctxG.createLinearGradient(0, 0, 0, 260);
    grad.addColorStop(0, 'rgba(79,126,248,0.25)');
    grad.addColorStop(1, 'rgba(79,126,248,0.0)');

    new Chart(ctxG, {
        type: 'line',
        data: {
            labels: growthLabels,
            datasets: [{
                label: 'Tài khoản mới',
                data: growthValues,
                borderColor: '#4f7ef8',
                backgroundColor: grad,
                fill: true,
                tension: 0.45,
                borderWidth: 2.5,
                pointBackgroundColor: '#fff',
                pointBorderColor: '#4f7ef8',
                pointBorderWidth: 2,
                pointRadius: 5,
                pointHoverRadius: 7
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#111827',
                    titleFont: { size: 13, weight: '700' },
                    bodyFont: { size: 13 },
                    padding: 12,
                    displayColors: false,
                    callbacks: { label: ctx => ctx.parsed.y + ' tài khoản mới' }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: 'rgba(0,0,0,0.05)', drawBorder: false },
                    ticks: { font: { size: 12 }, stepSize: 1 }
                },
                x: {
                    grid: { display: false, drawBorder: false },
                    ticks: { font: { size: 12 } }
                }
            }
        }
    });

    // Doughnut Chart
    new Chart(document.getElementById('rolesChart').getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: roleLabels,
            datasets: [{
                data: roleValues,
                backgroundColor: ['#4f7ef8','#22c55e','#f59e0b','#a855f7','#14b8a6','#f43f5e','#6b7280'],
                borderWidth: 3,
                borderColor: '#fff',
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false, cutout: '68%',
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { boxWidth: 10, padding: 14, font: { size: 11, weight: '600' }, usePointStyle: true }
                },
                tooltip: {
                    backgroundColor: '#111827',
                    titleFont: { size: 12 },
                    bodyFont: { size: 13, weight: '600' },
                    padding: 10
                }
            }
        }
    });
});
</script>

<jsp:include page="../footer.jsp" />

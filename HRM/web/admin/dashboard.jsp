<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Bảng Điều Khiển Admin" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
/* ── Reset portal footer cho trang admin ── */
footer, #chatWidget {
    display: none !important;
}

body {
    background-color: #f1f5f9 !important;
    font-family: 'Inter', sans-serif !important;
    padding-top: 0 !important;
    min-height: 100vh;
    overflow-x: hidden;
}

/* ── Layout ── */
.dashboard-wrapper {
    display: flex;
    min-height: calc(100vh - 64px);
}

/* ── Main Area ── */
.dash-main {
    flex: 1;
    min-width: 0;
    background: #f1f5f9;
}



/* ── Content Area ── */
.dash-content {
    padding: 28px 32px;
    display: flex;
    flex-direction: column;
    gap: 28px;
}

/* ── Breadcrumb / Page Title ── */
.dash-page-header {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.dash-breadcrumb {
    font-size: 0.78rem;
    color: #94a3b8;
    display: flex;
    align-items: center;
    gap: 6px;
}

.dash-breadcrumb a {
    color: #0d9488;
    text-decoration: none;
}

.dash-breadcrumb a:hover { text-decoration: underline; }

.dash-page-title {
    font-size: 1.5rem;
    font-weight: 800;
    color: #0f172a;
    letter-spacing: -0.5px;
}

/* ── Stat Cards ── */
.dash-stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 20px;
}

.dash-stat-card {
    background: #fff;
    border-radius: 16px;
    padding: 22px 24px;
    box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
    display: flex;
    flex-direction: column;
    gap: 10px;
    position: relative;
    overflow: hidden;
    transition: transform 0.2s, box-shadow 0.2s;
}

.dash-stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
}

.dash-stat-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}

.dash-stat-title {
    font-size: 0.75rem;
    font-weight: 700;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.6px;
}

.dash-stat-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
}

.dash-stat-val {
    font-size: 2rem;
    font-weight: 800;
    color: #0f172a;
    line-height: 1.1;
}

.dash-stat-change {
    font-size: 0.75rem;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 4px;
}

.dash-stat-change.up { color: #10b981; }
.dash-stat-change.down { color: #ef4444; }
.dash-stat-change.neutral { color: #94a3b8; }

/* Theme variations */
.dash-stat-card.stat-warning { border-left: 4px solid #f59e0b; }
.dash-stat-card.stat-warning .dash-stat-icon { background: #fef3c7; color: #d97706; }

.dash-stat-card.stat-danger { border-left: 4px solid #ef4444; }
.dash-stat-card.stat-danger .dash-stat-icon { background: #fee2e2; color: #dc2626; }

.dash-stat-card.stat-success { border-left: 4px solid #10b981; }
.dash-stat-card.stat-success .dash-stat-icon { background: #d1fae5; color: #059669; }

.dash-stat-card.stat-teal { border-left: 4px solid #0d9488; }
.dash-stat-card.stat-teal .dash-stat-icon { background: #ccfbf1; color: #0d9488; }

/* ── Chart Cards ── */
.dash-charts-grid {
    display: grid;
    grid-template-columns: 1.6fr 1fr;
    gap: 20px;
}

@media (max-width: 1100px) {
    .dash-charts-grid { grid-template-columns: 1fr; }
}

.dash-card {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
}

.dash-card-header {
    margin-bottom: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.dash-card-title {
    font-size: 0.95rem;
    font-weight: 700;
    color: #0f172a;
    display: flex;
    align-items: center;
    gap: 8px;
}

.dash-card-title-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    flex-shrink: 0;
}

.dot-teal   { background: #0d9488; }
.dot-blue   { background: #3b82f6; }
.dot-orange { background: #f59e0b; }

.dash-card-badge {
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.72rem;
    font-weight: 700;
    background: #f0fdf4;
    color: #059669;
}

/* ── Table ── */
.dash-table-container {
    width: 100%;
    overflow-x: auto;
}

.dash-table {
    width: 100%;
    border-collapse: collapse;
    text-align: left;
}

.dash-table th {
    padding: 12px 16px;
    border-bottom: 1px solid #e2e8f0;
    color: #64748b;
    font-size: 0.73rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    background: #fafbfc;
}

.dash-table td {
    padding: 15px 16px;
    border-bottom: 1px solid #f1f5f9;
    color: #0f172a;
    font-size: 0.88rem;
    vertical-align: middle;
}

.dash-table tbody tr:last-child td { border-bottom: none; }
.dash-table tbody tr:hover td { background: #f8fafc; }

.dash-badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.73rem;
    font-weight: 700;
}

.badge-pending   { background: #fef3c7; color: #d97706; }
.badge-completed { background: #d1fae5; color: #059669; }
.badge-rejected  { background: #fee2e2; color: #dc2626; }

.dash-emp-cell {
    display: flex;
    align-items: center;
    gap: 10px;
}

.dash-emp-avatar {
    width: 34px;
    height: 34px;
    border-radius: 8px;
    background: #eff6ff;
    color: #3b82f6;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 0.85rem;
    flex-shrink: 0;
}

.dash-btn {
    padding: 6px 14px;
    font-size: 0.8rem;
    font-weight: 700;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
    text-decoration: none;
}

.dash-btn-primary { background: #0d9488; color: #fff; }
.dash-btn-primary:hover { background: #0f766e; }

.dash-btn-secondary { background: #f1f5f9; color: #475569; }
.dash-btn-secondary:hover { background: #e2e8f0; }

.dash-actions-cell { display: flex; gap: 6px; }

/* ── Quick Stats Row ── */
.dash-quick-stats {
    display: flex;
    gap: 16px;
    flex-wrap: wrap;
}

.dash-quick-stat {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.82rem;
    color: #64748b;
}

.dash-quick-stat strong { color: #0f172a; }

@media (max-width: 768px) {
    .dash-content { padding: 20px 16px; }
}
</style>

<div class="dashboard-wrapper">
    <%-- Sidebar chung --%>
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <%-- Main Content Area --%>
    <div class="dash-main">

        <%-- ── Content ── --%>
        <div class="dash-content">

            <%-- Page Header --%>
            <div class="dash-page-header">
                <div class="dash-breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <span>Bảng điều khiển</span>
                </div>
                <div class="dash-page-title">Tổng Quan Hệ Thống</div>
            </div>

            <%-- ── Stat Cards ── --%>
            <div class="dash-stat-grid">

                <div class="dash-stat-card stat-teal">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Người Dùng Hoạt Động</span>
                        <div class="dash-stat-icon">
                            <i class="fa-solid fa-user-check"></i>
                        </div>
                    </div>
                    <div class="dash-stat-val">${not empty activeUsers ? activeUsers : '7'}</div>
                    <div class="dash-stat-change up">
                        <i class="fas fa-arrow-up"></i> Đang hoạt động trong hệ thống
                    </div>
                </div>

                <div class="dash-stat-card stat-warning">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Đơn Chờ Xử Lý</span>
                        <div class="dash-stat-icon">
                            <i class="fa-solid fa-user-plus"></i>
                        </div>
                    </div>
                    <div class="dash-stat-val">12</div>
                    <div class="dash-stat-change neutral">
                        <i class="fas fa-clock"></i> Cần xem xét và duyệt
                    </div>
                </div>

                <div class="dash-stat-card stat-danger">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Tài Khoản Bị Khóa</span>
                        <div class="dash-stat-icon">
                            <i class="fa-solid fa-user-slash"></i>
                        </div>
                    </div>
                    <div class="dash-stat-val">5</div>
                    <div class="dash-stat-change down">
                        <i class="fas fa-lock"></i> Đang bị tạm khóa
                    </div>
                </div>

                <div class="dash-stat-card stat-success">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Thời Gian Hoạt Động</span>
                        <div class="dash-stat-icon">
                            <i class="fa-solid fa-square-poll-vertical"></i>
                        </div>
                    </div>
                    <div class="dash-stat-val">99,98%</div>
                    <div class="dash-stat-change up">
                        <i class="fas fa-server"></i> Hệ thống ổn định
                    </div>
                </div>

            </div>

            <%-- ── Charts Row ── --%>
            <div class="dash-charts-grid">
                <%-- Line Chart --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-teal"></div>
                            Lượt Truy Cập & Đăng Nhập (7 Ngày Qua)
                        </h3>
                        <span class="dash-card-badge"><i class="fas fa-circle" style="font-size:0.5rem;"></i> Trực tiếp</span>
                    </div>
                    <div style="position: relative; height: 280px; width: 100%;">
                        <canvas id="trafficChart"></canvas>
                    </div>
                </div>

                <%-- Donut Chart --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-blue"></div>
                            Phân Bổ Người Dùng Theo Vai Trò
                        </h3>
                    </div>
                    <div style="position: relative; height: 280px; width: 100%; display: flex; justify-content: center; align-items: center;">
                        <canvas id="rolesChart"></canvas>
                    </div>
                </div>
            </div>

            <%-- ── Recent Requests Table ── --%>
            <div class="dash-card">
                <div class="dash-card-header">
                    <h3 class="dash-card-title">
                        <div class="dash-card-title-dot dot-orange"></div>
                        Yêu Cầu Tạo Tài Khoản Gần Đây (Từ HR)
                    </h3>
                    <a href="${pageContext.request.contextPath}/admin/pending-requests"
                       class="dash-btn dash-btn-secondary" style="font-size:0.78rem;">
                        Xem tất cả <i class="fas fa-arrow-right ms-1"></i>
                    </a>
                </div>
                <div class="dash-table-container">
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>Nhân Viên</th>
                                <th>Phòng Ban</th>
                                <th>Ngày Gửi</th>
                                <th>Trạng Thái</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>
                                    <div class="dash-emp-cell">
                                        <div class="dash-emp-avatar">A</div>
                                        <span style="font-weight:600;">Alex Rivera</span>
                                    </div>
                                </td>
                                <td style="color:#64748b;">Kỹ thuật Sản phẩm</td>
                                <td style="color:#64748b;">27/05/2026</td>
                                <td><span class="dash-badge badge-pending"><i class="fas fa-clock" style="font-size:0.65rem;"></i> Chờ duyệt</span></td>
                                <td class="dash-actions-cell">
                                    <button class="dash-btn dash-btn-primary">Tạo tài khoản</button>
                                    <button class="dash-btn dash-btn-secondary">Từ chối</button>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div class="dash-emp-cell">
                                        <div class="dash-emp-avatar" style="background:#faf5ff;color:#7c3aed;">S</div>
                                        <span style="font-weight:600;">Sophia Martinez</span>
                                    </div>
                                </td>
                                <td style="color:#64748b;">Tuyển dụng Nhân sự</td>
                                <td style="color:#64748b;">26/05/2026</td>
                                <td><span class="dash-badge badge-pending"><i class="fas fa-clock" style="font-size:0.65rem;"></i> Chờ duyệt</span></td>
                                <td class="dash-actions-cell">
                                    <button class="dash-btn dash-btn-primary">Tạo tài khoản</button>
                                    <button class="dash-btn dash-btn-secondary">Từ chối</button>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div class="dash-emp-cell">
                                        <div class="dash-emp-avatar" style="background:#f0fdf4;color:#059669;">D</div>
                                        <span style="font-weight:600;">David Chen</span>
                                    </div>
                                </td>
                                <td style="color:#64748b;">Tài chính Kế toán</td>
                                <td style="color:#64748b;">25/05/2026</td>
                                <td><span class="dash-badge badge-completed"><i class="fas fa-check-circle" style="font-size:0.65rem;"></i> Hoàn thành</span></td>
                                <td class="dash-actions-cell">
                                    <button class="dash-btn dash-btn-secondary" style="opacity:0.6;cursor:not-allowed;" disabled>Đã tạo</button>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div class="dash-emp-cell">
                                        <div class="dash-emp-avatar" style="background:#fef3c7;color:#d97706;">E</div>
                                        <span style="font-weight:600;">Emma Watson</span>
                                    </div>
                                </td>
                                <td style="color:#64748b;">Marketing Chiến lược</td>
                                <td style="color:#64748b;">24/05/2026</td>
                                <td><span class="dash-badge badge-completed"><i class="fas fa-check-circle" style="font-size:0.65rem;"></i> Hoàn thành</span></td>
                                <td class="dash-actions-cell">
                                    <button class="dash-btn dash-btn-secondary" style="opacity:0.6;cursor:not-allowed;" disabled>Đã tạo</button>
                                </td>
                            </tr>
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

    // 1. Biểu đồ Lượt Truy Cập & Đăng Nhập
    const trafficCtx = document.getElementById('trafficChart').getContext('2d');
    new Chart(trafficCtx, {
        type: 'line',
        data: {
            labels: ['21/05', '22/05', '23/05', '24/05', '25/05', '26/05', '27/05'],
            datasets: [
                {
                    label: 'Đăng nhập thành công',
                    data: [1120, 1280, 850, 420, 1340, 1420, 1245],
                    borderColor: '#0d9488',
                    backgroundColor: 'rgba(13,148,136,0.06)',
                    fill: true,
                    tension: 0.35,
                    borderWidth: 2.5,
                    pointBackgroundColor: '#0d9488',
                    pointRadius: 4,
                    pointHoverRadius: 6
                },
                {
                    label: 'Đăng nhập thất bại',
                    data: [15, 24, 18, 5, 29, 32, 21],
                    borderColor: '#ef4444',
                    backgroundColor: 'transparent',
                    fill: false,
                    tension: 0.35,
                    borderWidth: 2,
                    borderDash: [6, 4],
                    pointBackgroundColor: '#ef4444',
                    pointRadius: 3,
                    pointHoverRadius: 5
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                    labels: { boxWidth: 12, font: { family: 'Inter', size: 12 }, padding: 16 }
                }
            },
            scales: {
                y: {
                    grid: { color: 'rgba(0,0,0,0.04)' },
                    ticks: { font: { family: 'Inter', size: 11 }, color: '#94a3b8' }
                },
                x: {
                    grid: { display: false },
                    ticks: { font: { family: 'Inter', size: 11 }, color: '#94a3b8' }
                }
            }
        }
    });

    // 2. Biểu đồ Phân Bổ Vai Trò
    const rolesCtx = document.getElementById('rolesChart').getContext('2d');
    new Chart(rolesCtx, {
        type: 'doughnut',
        data: {
            labels: ['HR', 'Quản lý dự án', 'Giám sát', 'Nhân viên'],
            datasets: [{
                data: [45, 120, 80, 1000],
                backgroundColor: ['#0d9488','#0f172a','#3b82f6','#94a3b8'],
                borderWidth: 3,
                borderColor: '#ffffff',
                hoverBorderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '68%',
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { boxWidth: 12, padding: 18, font: { family: 'Inter', size: 12 } }
                }
            }
        }
    });

});
</script>

<jsp:include page="../footer.jsp" />

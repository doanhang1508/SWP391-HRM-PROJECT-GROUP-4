<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Thống Kê Phòng Ban" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
:root {
    --navy:    #0a2540;
    --blue:    #2b6cb0;
    --blue-lt: #63b3ed;
    --accent:  #3ecf8e;
    --bg:      #f0ede8;
    --surface: #ffffff;
    --border:  #e2e8f0;
    --text:    #0f172a;
    --muted:   #64748b;
}
* { box-sizing: border-box; }
body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }

.dept-wrapper { display: flex; min-height: calc(100vh - 64px); }
.dept-main { flex: 1; padding: 32px 36px; overflow-x: hidden; }

/* TOP BAR */
.page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 32px; flex-wrap: wrap; gap: 16px; }
.page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.6rem; font-weight: 800; color: var(--navy); letter-spacing: -.5px; margin: 0 0 4px; }
.breadcrumb-txt { font-size: .8rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
.breadcrumb-txt a { color: var(--blue); text-decoration: none; }

/* SUMMARY CARDS */
.summary-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px; margin-bottom: 24px; }
.summary-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 22px 24px; display: flex; align-items: center; gap: 18px; transition: transform .25s, box-shadow .25s; }
.summary-card:hover { transform: translateY(-3px); box-shadow: 0 16px 32px rgba(10,37,64,.08); }
.summary-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; flex-shrink: 0; }
.si-blue   { background: #eff6ff; color: #2b6cb0; }
.si-green  { background: #f0fdf4; color: #16a34a; }
.si-purple { background: #faf5ff; color: #7c3aed; }
.summary-info {}
.summary-label { font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); margin-bottom: 4px; }
.summary-value { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.9rem; font-weight: 800; color: var(--navy); letter-spacing: -1px; line-height: 1; }
.summary-sub { font-size: .78rem; color: var(--muted); font-weight: 500; margin-top: 4px; }

/* PANELS */
.panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 26px 28px; margin-bottom: 24px; }
.panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 22px; }
.panel-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); letter-spacing: -.3px; margin: 0; display: flex; align-items: center; gap: 10px; }
.panel-title-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.dot-blue   { background: var(--blue); }
.dot-green  { background: var(--accent); }
.dot-orange { background: #f97316; }
.dot-purple { background: #7c3aed; }

/* TABLE */
.dept-table { width: 100%; border-collapse: collapse; }
.dept-table thead th {
    font-size: .72rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: var(--muted);
    padding: 12px 16px;
    border-bottom: 2px solid var(--border);
    text-align: left;
    white-space: nowrap;
}
.dept-table tbody td {
    padding: 14px 16px;
    font-size: .88rem;
    color: var(--text);
    border-bottom: 1px solid #f8fafc;
    vertical-align: middle;
}
.dept-table tbody tr:last-child td { border-bottom: none; }
.dept-table tbody tr { transition: background .15s; }
.dept-table tbody tr:hover td { background: #f8fafc; }

.dept-name { font-weight: 700; color: var(--navy); }
.dept-manager { color: var(--muted); font-size: .84rem; }

.progress-wrap { display: flex; align-items: center; gap: 10px; }
.progress-bar-bg { flex: 1; height: 7px; background: #f1f5f9; border-radius: 4px; overflow: hidden; min-width: 80px; }
.progress-bar-fill { height: 100%; border-radius: 4px; transition: width .6s ease; }
.fill-green  { background: linear-gradient(90deg, #48bb78, #3ecf8e); }
.fill-orange { background: linear-gradient(90deg, #f97316, #fbbf24); }
.progress-pct { font-size: .8rem; font-weight: 700; color: var(--navy); min-width: 36px; text-align: right; }

/* BADGE */
.badge-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 12px; border-radius: 20px; font-size: .73rem; font-weight: 700; }
.bp-green  { background: #dcfce7; color: #16a34a; }
.bp-orange { background: #fef3c7; color: #d97706; }

/* ATTENDANCE NUMBER */
.attend-num { font-weight: 700; color: var(--navy); }
.attend-total { color: var(--muted); font-size: .82rem; }

@media (max-width: 1100px) {
    .summary-grid { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 768px) {
    .dept-main { padding: 20px 16px; }
    .summary-grid { grid-template-columns: 1fr; }
    .dept-table { font-size: .82rem; }
    .dept-table thead th, .dept-table tbody td { padding: 10px 10px; }
}
</style>

<div class="dept-wrapper">
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="departments" />
    </jsp:include>

    <div class="dept-main">

        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb-txt">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span style="color:#cbd5e0">/</span>
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
                    <span style="color:#cbd5e0">/</span>
                    <span>Phòng ban</span>
                </div>
                <h1>Thống Kê Phòng Ban</h1>
            </div>
        </div>

        <!-- SUMMARY CARDS -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="summary-icon si-blue"><i class="fas fa-sitemap"></i></div>
                <div class="summary-info">
                    <div class="summary-label">Tổng phòng ban</div>
                    <div class="summary-value">8</div>
                    <div class="summary-sub">Đang hoạt động</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="summary-icon si-green"><i class="fas fa-user-check"></i></div>
                <div class="summary-info">
                    <div class="summary-label">Có mặt trung bình</div>
                    <div class="summary-value">93%</div>
                    <div class="summary-sub">Hôm nay · Tốt</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="summary-icon si-purple"><i class="fas fa-crown"></i></div>
                <div class="summary-info">
                    <div class="summary-label">Phòng đông nhất</div>
                    <div class="summary-value" style="font-size:1.3rem;">Sản xuất</div>
                    <div class="summary-sub">85 nhân viên</div>
                </div>
            </div>
        </div>

        <!-- BAR CHART -->
        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-title-dot dot-blue"></div> Nhân Sự Theo Phòng Ban</h3>
                <span style="font-size:.78rem;font-weight:600;color:var(--muted);">Tổng: 288 nhân viên</span>
            </div>
            <div style="height:280px; position:relative;">
                <canvas id="deptBarChart"></canvas>
            </div>
        </div>

        <!-- DETAIL TABLE -->
        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-title-dot dot-green"></div> Chi Tiết Từng Phòng Ban</h3>
                <span style="font-size:.78rem;font-weight:600;color:var(--muted);">Cập nhật: 27/05/2026</span>
            </div>
            <div style="overflow-x:auto;">
                <table class="dept-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Phòng ban</th>
                            <th>Trưởng phòng</th>
                            <th style="text-align:center;">Số NV</th>
                            <th style="text-align:center;">Có mặt hôm nay</th>
                            <th>Tỉ lệ có mặt</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="color:var(--muted);font-weight:600;">01</td>
                            <td><div class="dept-name"><i class="fas fa-microchip" style="color:#2b6cb0;margin-right:8px;"></i>Kỹ thuật</div></td>
                            <td><div class="dept-manager">Nguyễn Văn Khoa</div></td>
                            <td style="text-align:center;"><span class="attend-num">68</span></td>
                            <td style="text-align:center;"><span class="attend-num">65</span> <span class="attend-total">/ 68</span></td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar-bg"><div class="progress-bar-fill fill-green" style="width:96%"></div></div>
                                    <span class="progress-pct">96%</span>
                                </div>
                            </td>
                            <td><span class="badge-pill bp-green"><i class="fas fa-circle" style="font-size:.45rem;"></i> Tốt</span></td>
                        </tr>
                        <tr>
                            <td style="color:var(--muted);font-weight:600;">02</td>
                            <td><div class="dept-name"><i class="fas fa-industry" style="color:#7c3aed;margin-right:8px;"></i>Sản xuất</div></td>
                            <td><div class="dept-manager">Trần Thị Mai</div></td>
                            <td style="text-align:center;"><span class="attend-num">85</span></td>
                            <td style="text-align:center;"><span class="attend-num">77</span> <span class="attend-total">/ 85</span></td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar-bg"><div class="progress-bar-fill fill-green" style="width:91%"></div></div>
                                    <span class="progress-pct">91%</span>
                                </div>
                            </td>
                            <td><span class="badge-pill bp-green"><i class="fas fa-circle" style="font-size:.45rem;"></i> Tốt</span></td>
                        </tr>
                        <tr>
                            <td style="color:var(--muted);font-weight:600;">03</td>
                            <td><div class="dept-name"><i class="fas fa-users-cog" style="color:#16a34a;margin-right:8px;"></i>HCNS</div></td>
                            <td><div class="dept-manager">Lê Minh Tuấn</div></td>
                            <td style="text-align:center;"><span class="attend-num">22</span></td>
                            <td style="text-align:center;"><span class="attend-num">22</span> <span class="attend-total">/ 22</span></td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar-bg"><div class="progress-bar-fill fill-green" style="width:100%"></div></div>
                                    <span class="progress-pct">100%</span>
                                </div>
                            </td>
                            <td><span class="badge-pill bp-green"><i class="fas fa-circle" style="font-size:.45rem;"></i> Tốt</span></td>
                        </tr>
                        <tr>
                            <td style="color:var(--muted);font-weight:600;">04</td>
                            <td><div class="dept-name"><i class="fas fa-calculator" style="color:#ea580c;margin-right:8px;"></i>Kế toán</div></td>
                            <td><div class="dept-manager">Phạm Thu Hà</div></td>
                            <td style="text-align:center;"><span class="attend-num">18</span></td>
                            <td style="text-align:center;"><span class="attend-num">15</span> <span class="attend-total">/ 18</span></td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar-bg"><div class="progress-bar-fill fill-orange" style="width:83%"></div></div>
                                    <span class="progress-pct">83%</span>
                                </div>
                            </td>
                            <td><span class="badge-pill bp-orange"><i class="fas fa-circle" style="font-size:.45rem;"></i> Chú ý</span></td>
                        </tr>
                        <tr>
                            <td style="color:var(--muted);font-weight:600;">05</td>
                            <td><div class="dept-name"><i class="fas fa-handshake" style="color:#2b6cb0;margin-right:8px;"></i>Kinh doanh</div></td>
                            <td><div class="dept-manager">Hoàng Đức Nam</div></td>
                            <td style="text-align:center;"><span class="attend-num">35</span></td>
                            <td style="text-align:center;"><span class="attend-num">31</span> <span class="attend-total">/ 35</span></td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar-bg"><div class="progress-bar-fill fill-green" style="width:89%"></div></div>
                                    <span class="progress-pct">89%</span>
                                </div>
                            </td>
                            <td><span class="badge-pill bp-green"><i class="fas fa-circle" style="font-size:.45rem;"></i> Tốt</span></td>
                        </tr>
                        <tr>
                            <td style="color:var(--muted);font-weight:600;">06</td>
                            <td><div class="dept-name"><i class="fas fa-laptop-code" style="color:#7c3aed;margin-right:8px;"></i>CNTT</div></td>
                            <td><div class="dept-manager">Vũ Quang Huy</div></td>
                            <td style="text-align:center;"><span class="attend-num">20</span></td>
                            <td style="text-align:center;"><span class="attend-num">19</span> <span class="attend-total">/ 20</span></td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar-bg"><div class="progress-bar-fill fill-green" style="width:95%"></div></div>
                                    <span class="progress-pct">95%</span>
                                </div>
                            </td>
                            <td><span class="badge-pill bp-green"><i class="fas fa-circle" style="font-size:.45rem;"></i> Tốt</span></td>
                        </tr>
                        <tr>
                            <td style="color:var(--muted);font-weight:600;">07</td>
                            <td><div class="dept-name"><i class="fas fa-truck" style="color:#16a34a;margin-right:8px;"></i>Logistic</div></td>
                            <td><div class="dept-manager">Đỗ Thị Lan</div></td>
                            <td style="text-align:center;"><span class="attend-num">15</span></td>
                            <td style="text-align:center;"><span class="attend-num">13</span> <span class="attend-total">/ 15</span></td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar-bg"><div class="progress-bar-fill fill-green" style="width:87%"></div></div>
                                    <span class="progress-pct">87%</span>
                                </div>
                            </td>
                            <td><span class="badge-pill bp-green"><i class="fas fa-circle" style="font-size:.45rem;"></i> Tốt</span></td>
                        </tr>
                        <tr>
                            <td style="color:var(--muted);font-weight:600;">08</td>
                            <td><div class="dept-name"><i class="fas fa-clipboard-check" style="color:#ea580c;margin-right:8px;"></i>QA/QC</div></td>
                            <td><div class="dept-manager">Bùi Văn Thắng</div></td>
                            <td style="text-align:center;"><span class="attend-num">25</span></td>
                            <td style="text-align:center;"><span class="attend-num">22</span> <span class="attend-total">/ 25</span></td>
                            <td>
                                <div class="progress-wrap">
                                    <div class="progress-bar-bg"><div class="progress-bar-fill fill-green" style="width:88%"></div></div>
                                    <span class="progress-pct">88%</span>
                                </div>
                            </td>
                            <td><span class="badge-pill bp-green"><i class="fas fa-circle" style="font-size:.45rem;"></i> Tốt</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const ctx = document.getElementById('deptBarChart');
    if (!ctx) return;
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Kỹ thuật', 'Sản xuất', 'HCNS', 'Kế toán', 'Kinh doanh', 'CNTT', 'Logistic', 'QA/QC'],
            datasets: [
                {
                    label: 'Có mặt',
                    data: [65, 77, 22, 15, 31, 19, 13, 22],
                    backgroundColor: '#2b6cb0',
                    borderRadius: 6,
                    barPercentage: 0.6,
                    categoryPercentage: 0.75
                },
                {
                    label: 'Vắng mặt',
                    data: [3, 8, 0, 3, 4, 1, 2, 3],
                    backgroundColor: '#e2e8f0',
                    borderRadius: 6,
                    barPercentage: 0.6,
                    categoryPercentage: 0.75
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    stacked: true,
                    grid: { display: false },
                    border: { display: false },
                    ticks: { font: { family: 'Inter', size: 12 }, color: '#64748b' }
                },
                y: {
                    stacked: true,
                    beginAtZero: true,
                    grid: { color: '#f1f5f9' },
                    border: { display: false },
                    ticks: { font: { family: 'Inter', size: 12 }, color: '#94a3b8' }
                }
            },
            plugins: {
                legend: {
                    position: 'top',
                    align: 'end',
                    labels: {
                        font: { family: 'Inter', size: 12, weight: '600' },
                        color: '#0a2540',
                        usePointStyle: true,
                        pointStyle: 'rectRounded',
                        boxWidth: 12,
                        padding: 16
                    }
                },
                tooltip: {
                    backgroundColor: '#0a2540',
                    padding: 12,
                    titleFont: { family: 'Inter', size: 12, weight: '600' },
                    bodyFont: { family: 'Inter', size: 12 },
                    cornerRadius: 8,
                    boxPadding: 4
                }
            }
        }
    });
});
</script>

<jsp:include page="../footer.jsp" />

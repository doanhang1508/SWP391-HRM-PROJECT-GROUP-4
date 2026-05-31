<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"
uri="http://java.sun.com/jsp/jstl/functions" %>

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
        <a href="${pageContext.request.contextPath}/home">
            <i class="fas fa-home"></i> Trang chủ
        </a>
        <span>/</span>
        <span>HR Dashboard</span>
    </div>

    <div class="dash-page-title">
        Tổng Quan Nhân Sự
    </div>
</div>

            <%-- ── Stat Cards ── --%>
           <div class="dash-stat-grid">

    <div class="dash-stat-card stat-teal">
        <div class="dash-stat-header">
            <span class="dash-stat-title">Tổng Nhân Viên</span>
            <div class="dash-stat-icon">
                <i class="fa-solid fa-users"></i>
            </div>
        </div>

        <div class="dash-stat-val">
            ${totalEmployees}
        </div>

        <div class="dash-stat-change up">
            <i class="fas fa-user-check"></i>
            Đang làm việc
        </div>
    </div>

    <div class="dash-stat-card stat-success">
        <div class="dash-stat-header">
            <span class="dash-stat-title">Phòng Ban</span>
            <div class="dash-stat-icon">
                <i class="fa-solid fa-building"></i>
            </div>
        </div>

        <div class="dash-stat-val">
            ${totalDepartments}
        </div>

        <div class="dash-stat-change neutral">
            Đang hoạt động
        </div>
    </div>

    <div class="dash-stat-card stat-warning">
        <div class="dash-stat-header">
            <span class="dash-stat-title">Hợp Đồng Sắp Hết Hạn</span>
            <div class="dash-stat-icon">
                <i class="fa-solid fa-file-contract"></i>
            </div>
        </div>

        <div class="dash-stat-val">
            ${expiringContracts}
        </div>

        <div class="dash-stat-change down">
            Trong 30 ngày tới
        </div>
    </div>

    <div class="dash-stat-card stat-danger">
        <div class="dash-stat-header">
            <span class="dash-stat-title">Đơn Nghỉ Phép</span>
            <div class="dash-stat-icon">
                <i class="fa-solid fa-calendar-days"></i>
            </div>
        </div>

        <div class="dash-stat-val">
            ${pendingLeaves}
        </div>

        <div class="dash-stat-change neutral">
            Chờ duyệt
        </div>
    </div>

</div>

          <div class="dash-charts-grid">

    <div class="dash-card">
        <div class="dash-card-header">
            <h3 class="dash-card-title">
                Nhân Viên Theo Phòng Ban
            </h3>
        </div>

        <div style="height:300px;">
            <canvas id="departmentChart"></canvas>
        </div>
    </div>

    <div class="dash-card">
        <div class="dash-card-header">
            <h3 class="dash-card-title">
                Cơ Cấu Giới Tính
            </h3>
        </div>

        <div style="height:300px;">
            <canvas id="genderChart"></canvas>
        </div>
    </div>

</div>

            <%-- ── Recent Requests Table ── --%>
          <div class="dash-card">
    <div class="dash-card-header">
        <h3 class="dash-card-title">
            <div class="dash-card-title-dot dot-orange"></div>
            Nhân Viên Mới Nhất
        </h3>

        <a href="${pageContext.request.contextPath}/hr/employees"
           class="dash-btn dash-btn-secondary">
            Xem tất cả
        </a>
    </div>

    <div class="dash-table-container">
        <table class="dash-table">
            <thead>
                <tr>
                    <th>Họ Tên</th>
                    <th>Phòng Ban</th>
                    <th>Chức Vụ</th>
                    <th>Ngày Vào Làm</th>
                    <th>Chi Tiết</th>
                </tr>
            </thead>

            <tbody>

                <c:forEach items="${recentEmployees}" var="emp">

                    <tr>

                        <td>
                            <div class="dash-emp-cell">
                                <div class="dash-emp-avatar">
                            ${fn:substring(emp.fullName,0,1)}                                </div>

                                <span style="font-weight:600;">
                                    ${emp.fullName}
                                </span>
                            </div>
                        </td>

                        <td>${emp.departmentName}</td>

                        <td>${emp.positionName}</td>

                        <td>
                            <fmt:formatDate value="${emp.hireDate}"
                                            pattern="dd/MM/yyyy"/>
                        </td>

                        <td>
                            <a href="${pageContext.request.contextPath}/hr/employee-detail?id=${emp.employeeId}"
                               class="dash-btn dash-btn-primary">
                                Xem
                            </a>
                        </td>

                    </tr>

                </c:forEach>

            </tbody>
        </table>
    </div>
</div>   <!-- dash-card -->
</div>   <%-- dash-content --%>
</div>   <%-- dash-main --%>
</div>   <%-- dashboard-wrapper --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {

    const departmentCtx =
        document.getElementById('departmentChart').getContext('2d');

    new Chart(departmentCtx, {
        type: 'bar',
        data: {
            labels: [
                'IT',
                'HR',
                'Finance',
                'Marketing',
                'Sales'
            ],
            datasets: [{
                label: 'Số nhân viên',
                data: [35, 12, 15, 18, 25]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });

    const genderCtx =
        document.getElementById('genderChart').getContext('2d');

    new Chart(genderCtx, {
        type: 'doughnut',
        data: {
            labels: [
                'Nam',
                'Nữ',
                'Khác'
            ],
            datasets: [{
                data: [60, 38, 2]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });

});
</script>

<jsp:include page="../footer.jsp" />

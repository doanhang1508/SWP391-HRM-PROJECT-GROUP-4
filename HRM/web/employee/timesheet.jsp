<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Bảng Công Cá Nhân - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<!-- Google Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    :root {
        --pri: #6366f1;
        --pri-l: rgba(99,102,241,.1);
        --ok: #10b981;
        --ok-l: rgba(16,185,129,.1);
        --ng: #ef4444;
        --ng-l: rgba(239,68,68,.1);
        --warn: #f59e0b;
        --bg: #f4f7fe;
        --card: #fff;
        --txt: #1e293b;
        --muted: #64748b;
    }
    body {
        background: var(--bg);
        font-family: 'Inter', sans-serif;
    }
    .dashboard-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .main-content {
        flex: 1;
        padding: 30px;
        width: calc(100% - 260px);
    }
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 28px;
        flex-wrap: wrap;
        gap: 12px;
    }
    .page-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--txt);
        margin: 0;
    }
    .breadcrumb-c {
        font-size: .85rem;
        color: var(--muted);
        margin: 4px 0 0;
    }
    .breadcrumb-c a {
        color: var(--pri);
        text-decoration: none;
    }
    .admin-panel {
        background: var(--card);
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 4px 20px rgba(0,0,0,.03);
        border: 1px solid rgba(0,0,0,.04);
        margin-bottom: 24px;
    }
    .panel-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 1px solid #f1f5f9;
        flex-wrap: wrap;
        gap: 10px;
    }
    .panel-title {
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--txt);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .panel-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        background: var(--pri-l);
        color: var(--pri);
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .tbl {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 6px;
    }
    .tbl th {
        background: transparent;
        color: var(--muted);
        font-weight: 600;
        font-size: .78rem;
        text-transform: uppercase;
        letter-spacing: .5px;
        padding: 10px 14px;
        border: none;
        white-space: nowrap;
    }
    .tbl td {
        background: #fff;
        padding: 13px 14px;
        vertical-align: middle;
        color: #475569;
        font-size: .87rem;
        border-top: 1px solid #f1f5f9;
        border-bottom: 1px solid #f1f5f9;
    }
    .tbl tr td:first-child {
        border-left: 1px solid #f1f5f9;
        border-radius: 10px 0 0 10px;
    }
    .tbl tr td:last-child {
        border-right: 1px solid #f1f5f9;
        border-radius: 0 10px 10px 0;
    }
    .tbl tbody tr:hover td {
        background: #f8fafc;
    }
    .badge-s {
        padding: 5px 12px;
        border-radius: 6px;
        font-weight: 600;
        font-size: .74rem;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .b-draft {
        background: rgba(100, 116, 139, 0.1);
        color: #475569;
    }
    .b-pending {
        background: rgba(245, 158, 11, 0.1);
        color: #d97706;
    }
    .b-approved {
        background: var(--ok-l);
        color: var(--ok);
    }
    .b-rejected {
        background: var(--ng-l);
        color: var(--ng);
    }
    .b-info {
        background: rgba(59, 130, 246, 0.1);
        color: #2563eb;
    }
    .stat-card {
        background: #fff;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 4px 15px rgba(0,0,0,.02);
        border: 1px solid rgba(0,0,0,.04);
        text-align: center;
    }
    .stat-num {
        font-size: 1.8rem;
        font-weight: 800;
        color: var(--txt);
        margin: 6px 0 0;
    }
    @media(max-width:768px) {
        .main-content {
            width: 100% !important;
            padding: 20px 16px !important;
        }
        .page-header {
            flex-direction: column;
            align-items: flex-start;
        }
    }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="personal-timesheet" />
    </jsp:include>

    <div class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <div>
                <h1 class="page-title">Bảng Công Cá Nhân</h1>
                <p class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Bảng công của tôi
                </p>
            </div>
        </div>

        <!-- Summary Metrics -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="small fw-bold text-muted uppercase">Số Ngày Đi Làm</div>
                    <div class="stat-num text-success">${summaryPresent != null ? summaryPresent : 0}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="small fw-bold text-muted uppercase">Số Ngày Đi Trễ</div>
                    <div class="stat-num text-warning">${summaryLate != null ? summaryLate : 0}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="small fw-bold text-muted uppercase">Số Ngày Vắng</div>
                    <div class="stat-num text-danger">${summaryAbsent != null ? summaryAbsent : 0}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="small fw-bold text-muted uppercase">Tăng Ca (Ngày)</div>
                    <div class="stat-num text-primary">${summaryOT != null ? summaryOT : 0}</div>
                </div>
            </div>
        </div>

        <div class="admin-panel">
            <div class="panel-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                <h3 class="panel-title">
                    <div class="panel-icon"><i class="fas fa-calendar-alt"></i></div>
                    Chi tiết công trong tháng
                </h3>
                
                <c:if test="${not empty deptConfirmation}">
                    <div class="d-flex align-items-center gap-2">
                        <span class="small fw-semibold text-muted">Trạng thái bảng công phòng ban:</span>
                        <c:choose>
                            <c:when test="${deptConfirmation.status == 'DRAFT'}"><span class="badge-s b-draft">Draft</span></c:when>
                            <c:when test="${deptConfirmation.status == 'SENT_TO_DEPARTMENT'}"><span class="badge-s b-pending">Chờ xác nhận</span></c:when>
                            <c:when test="${deptConfirmation.status == 'DEPARTMENT_CONFIRMED' || deptConfirmation.status == 'SENT_TO_HR_MANAGER'}"><span class="badge-s b-approved">Đã xác nhận</span></c:when>
                            <c:when test="${deptConfirmation.status == 'HR_MANAGER_APPROVED'}"><span class="badge-s b-approved" style="background:#ecfdf5;color:#047857;"><i class="fas fa-check-double"></i> Đã Duyệt Cuối</span></c:when>
                            <c:when test="${deptConfirmation.status == 'HR_MANAGER_REJECTED'}"><span class="badge-s b-rejected">Bị từ chối</span></c:when>
                        </c:choose>
                    </div>
                </c:if>
            </div>

            <!-- Filter Month/Year -->
            <div class="row g-3 align-items-center mb-4">
                <div class="col-md-2">
                    <label class="form-label small fw-bold text-muted">Tháng</label>
                    <select id="filterMonth" onchange="reloadPersonalTimesheet()" class="form-select" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small fw-bold text-muted">Năm</label>
                    <select id="filterYear" onchange="reloadPersonalTimesheet()" class="form-select" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                        <c:forEach var="y" begin="2024" end="2030">
                            <option value="${y}" ${selectedYear == y ? 'selected' : ''}>${y}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <script>
                function reloadPersonalTimesheet() {
                    var month = document.getElementById('filterMonth').value;
                    var year = document.getElementById('filterYear').value;
                    window.location.href = '${pageContext.request.contextPath}/employee/timesheet?month=' + month + '&year=' + year;
                }
            </script>

            <!-- Table of Attendance Details -->
            <div class="table-responsive">
                <table class="tbl table-hover">
                    <thead>
                        <tr>
                            <th>Ngày</th>
                            <th>Ca Làm Việc</th>
                            <th>Giờ Vào</th>
                            <th>Giờ Ra</th>
                            <th>Trạng Thái Chấm Công</th>
                            <th>Giờ Tăng Ca</th>
                            <th>Lý Do / Ghi Chú</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty attendanceList}">
                                <tr>
                                    <td colspan="7" class="text-center py-4" style="color:var(--muted)">Không tìm thấy dữ liệu chấm công cho tháng này.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="a" items="${attendanceList}">
                                    <tr>
                                        <td><strong><fmt:formatDate value="${a.workDate}" pattern="dd/MM/yyyy"/></strong></td>
                                        <td>${a.shiftName != null ? a.shiftName : '-'}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.checkIn != null}"><fmt:formatDate value="${a.checkIn}" pattern="HH:mm"/></c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.checkOut != null}"><fmt:formatDate value="${a.checkOut}" pattern="HH:mm"/></c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.status == 'PRESENT'}"><span class="badge-s b-approved">Present</span></c:when>
                                                <c:when test="${a.status == 'ABSENT'}"><span class="badge-s b-rejected">Absent</span></c:when>
                                                <c:when test="${a.status == 'LATE'}"><span class="badge-s b-pending">Late</span></c:when>
                                                <c:when test="${a.status == 'HALFDAY'}"><span class="badge-s b-info">Halfday</span></c:when>
                                                <c:otherwise><span class="badge-s b-draft">${a.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${a.overtimeHrs > 0 ? a.overtimeHrs : '-'}</td>
                                        <td class="text-muted small">${a.otReason != null ? a.otReason : '-'}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

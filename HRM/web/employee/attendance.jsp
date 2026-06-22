<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chấm Công Cá Nhân - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root {
        --pri: #6366f1; --ok: #10b981; --ng: #ef4444;
        --warn: #f59e0b; --info: #3b82f6;
        --bg: #f4f7fe; --card: #fff; --txt: #1e293b; --muted: #64748b;
    }
    body { background: var(--bg); font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 30px; }
    .page-title { font-size: 1.5rem; font-weight: 700; color: var(--txt); margin: 0 0 4px; }
    .breadcrumb-c { font-size: .85rem; color: var(--muted); }
    .breadcrumb-c a { color: var(--pri); text-decoration: none; }

    /* Stats */
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit,minmax(160px,1fr)); gap: 16px; margin: 24px 0; }
    .stat-card {
        background: var(--card); border-radius: 14px; padding: 20px;
        display: flex; align-items: center; gap: 14px;
        box-shadow: 0 2px 10px rgba(0,0,0,.04); border: 1px solid #f1f5f9;
    }
    .stat-icon {
        width: 46px; height: 46px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center; font-size: 1.1rem; flex-shrink: 0;
    }
    .stat-card h4 { margin: 0; font-size: 1.5rem; font-weight: 800; color: var(--txt); }
    .stat-card span { font-size: .72rem; color: var(--muted); font-weight: 600; text-transform: uppercase; }

    /* Filter */
    .filter-row {
        display: flex; gap: 12px; align-items: center; flex-wrap: wrap;
        background: var(--card); border-radius: 12px; padding: 16px 20px;
        margin-bottom: 20px; border: 1px solid #f1f5f9;
        box-shadow: 0 2px 8px rgba(0,0,0,.03);
    }
    .filter-row label { font-size: .82rem; font-weight: 600; color: var(--muted); }
    .filter-row select {
        border: 1.5px solid #e2e8f0; border-radius: 8px; padding: 7px 12px;
        font-size: .85rem; font-family: 'Inter', sans-serif; color: var(--txt);
        outline: none;
    }
    .filter-row select:focus { border-color: var(--pri); }
    .btn-filter {
        background: var(--pri); color: #fff; border: none; border-radius: 8px;
        padding: 8px 18px; font-weight: 600; font-size: .85rem; cursor: pointer; transition: all .2s;
    }
    .btn-filter:hover { background: #4f46e5; }

    /* Table */
    .table-panel {
        background: var(--card); border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0,0,0,.04); border: 1px solid rgba(0,0,0,.05); overflow: hidden;
    }
    .table-header {
        padding: 18px 24px; display: flex; justify-content: space-between; align-items: center;
        border-bottom: 1px solid #f1f5f9;
    }
    .table-title { font-size: 1rem; font-weight: 700; color: var(--txt); }
    table { width: 100%; border-collapse: collapse; }
    thead th {
        background: #f8fafc; padding: 12px 16px; text-align: left;
        font-size: .78rem; font-weight: 700; color: var(--muted);
        text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid #e2e8f0;
    }
    tbody td {
        padding: 13px 16px; font-size: .87rem; color: var(--txt);
        border-bottom: 1px solid #f8fafc; vertical-align: middle;
    }
    tbody tr:hover td { background: #fafbff; }
    tbody tr:last-child td { border-bottom: none; }

    /* Status badges */
    .badge {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 4px 10px; border-radius: 20px; font-size: .75rem; font-weight: 700;
    }
    .badge-present { background: rgba(16,185,129,.1); color: #065f46; }
    .badge-late { background: rgba(245,158,11,.1); color: #92400e; }
    .badge-absent { background: rgba(239,68,68,.1); color: #991b1b; }
    .badge-halfday { background: rgba(59,130,246,.1); color: #1e40af; }

    /* Claim link */
    .btn-claim {
        color: var(--pri); font-size: .8rem; font-weight: 600; text-decoration: none;
        display: inline-flex; align-items: center; gap: 4px; padding: 4px 8px;
        border-radius: 6px; transition: background .2s;
    }
    .btn-claim:hover { background: rgba(99,102,241,.08); }
    .claimed { color: var(--muted); font-size: .8rem; font-style: italic; }

    .empty-state { text-align: center; padding: 50px 20px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 14px; color: #cbd5e1; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="attendance"/>
    </jsp:include>

    <div class="main-content">
        <div style="margin-bottom:24px">
            <h1 class="page-title"><i class="fas fa-calendar-check" style="color:var(--pri);margin-right:10px"></i>Chấm Công Cá Nhân</h1>
            <div class="breadcrumb-c"><a href="${pageContext.request.contextPath}/employee/dashboard">Dashboard</a> / Chấm Công</div>
        </div>

        <!-- Summary stats -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(16,185,129,.1);color:var(--ok)"><i class="fas fa-user-check"></i></div>
                <div><h4>${summaryPresent}</h4><span>Có mặt</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(245,158,11,.1);color:var(--warn)"><i class="fas fa-clock"></i></div>
                <div><h4>${summaryLate}</h4><span>Đi trễ</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(239,68,68,.1);color:var(--ng)"><i class="fas fa-user-times"></i></div>
                <div><h4>${summaryAbsent}</h4><span>Vắng mặt</span></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(99,102,241,.1);color:var(--pri)"><i class="fas fa-moon"></i></div>
                <div><h4>${summaryOT}</h4><span>Ngày OT</span></div>
            </div>
        </div>

        <!-- Filter -->
        <form method="get" action="${pageContext.request.contextPath}/employee/attendance">
            <div class="filter-row">
                <label>Tháng:</label>
                <select name="month">
                    <c:forEach begin="1" end="12" var="m">
                        <option value="${m}" ${m == selectedMonth ? 'selected' : ''}>Tháng ${m}</option>
                    </c:forEach>
                </select>
                <label>Năm:</label>
                <select name="year">
                    <c:forEach items="${yearOptions}" var="y">
                        <option value="${y}" ${y == selectedYear ? 'selected' : ''}>${y}</option>
                    </c:forEach>
                </select>
                <label>Tuần:</label>
                <select name="week" style="margin-right: 10px;">
                    <option value="0" ${selectedWeek == 0 ? 'selected' : ''}>Cả tháng</option>
                    <option value="1" ${selectedWeek == 1 ? 'selected' : ''}>Tuần 1 (Ngày 1-7)</option>
                    <option value="2" ${selectedWeek == 2 ? 'selected' : ''}>Tuần 2 (Ngày 8-14)</option>
                    <option value="3" ${selectedWeek == 3 ? 'selected' : ''}>Tuần 3 (Ngày 15-21)</option>
                    <option value="4" ${selectedWeek == 4 ? 'selected' : ''}>Tuần 4 (Ngày 22-28)</option>
                    <option value="5" ${selectedWeek == 5 ? 'selected' : ''}>Tuần 5 (Ngày 29-cuối tháng)</option>
                </select>
                <button type="submit" class="btn-filter"><i class="fas fa-search"></i> Xem</button>
            </div>
        </form>

        <!-- Table -->
        <div class="table-panel">
            <div class="table-header">
                <span class="table-title">
                    <i class="fas fa-list-alt" style="color:var(--pri);margin-right:8px"></i>
                    Bảng Chấm Công — Tháng ${selectedMonth}/${selectedYear}
                </span>
                <span style="font-size:.82rem;color:var(--muted)">${attendanceList.size()} bản ghi</span>
            </div>

            <c:choose>
                <c:when test="${empty attendanceList}">
                    <div class="empty-state">
                        <i class="fas fa-calendar-times"></i>
                        <p style="margin:0;font-weight:600">Không có dữ liệu chấm công</p>
                        <p style="font-size:.83rem;margin:4px 0 0">cho tháng ${selectedMonth}/${selectedYear}</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Ngày</th><th>Ca</th><th>Vào</th><th>Ra</th>
                                <th>Trạng thái</th><th>OT (giờ)</th><th>Ghi chú OT</th><th>Khiếu nại</th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${attendanceList}" var="a">
                            <tr>
                                <td style="font-weight:600">
                                    <fmt:formatDate value="${a.workDate}" pattern="dd/MM/yyyy"/>
                                    <br><span style="font-size:.72rem;color:var(--muted)">
                                        <fmt:formatDate value="${a.workDate}" pattern="EEEE" /></span>
                                </td>
                                <td>${a.shiftName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty a.checkIn}">
                                            <fmt:formatDate value="${a.checkIn}" pattern="HH:mm" type="time"/>
                                        </c:when>
                                        <c:otherwise><span style="color:var(--muted)">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty a.checkOut}">
                                            <fmt:formatDate value="${a.checkOut}" pattern="HH:mm" type="time"/>
                                        </c:when>
                                        <c:otherwise><span style="color:var(--muted)">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.status == 'PRESENT'}"><span class="badge badge-present"><i class="fas fa-check-circle"></i> Có mặt</span></c:when>
                                        <c:when test="${a.status == 'LATE'}"><span class="badge badge-late"><i class="fas fa-clock"></i> Đi trễ</span></c:when>
                                        <c:when test="${a.status == 'ABSENT'}"><span class="badge badge-absent"><i class="fas fa-times-circle"></i> Vắng</span></c:when>
                                        <c:when test="${a.status == 'HALFDAY'}"><span class="badge badge-halfday"><i class="fas fa-adjust"></i> Nửa ngày</span></c:when>
                                        <c:otherwise>${a.status}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.overtimeHrs > 0}">
                                            <strong style="color:var(--pri)">${a.overtimeHrs}h</strong>
                                        </c:when>
                                        <c:otherwise><span style="color:var(--muted)">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="font-size:.82rem;color:var(--muted);max-width:180px">
                                    ${a.otReason}
                                </td>
                                <td>
                                    <c:if test="${a.status == 'ABSENT' or a.status == 'LATE'}">
                                        <a href="${pageContext.request.contextPath}/employee/attendance-claim?attendanceId=${a.attendanceId}&workDate=${a.workDate}"
                                           class="btn-claim">
                                            <i class="fas fa-flag"></i> Khiếu nại
                                        </a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Tăng Ca Của Tôi - HRM" scope="request" />
<jsp:include page="../header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root{--pri:#6366f1;--pri-l:rgba(99,102,241,.1);--ok:#10b981;--ok-l:rgba(16,185,129,.1);--ng:#ef4444;--ng-l:rgba(239,68,68,.1);--warn:#f59e0b;--warn-l:rgba(245,158,11,.1);--bg:#f4f7fe;--card:#fff;--txt:#1e293b;--muted:#64748b}
    body{background:var(--bg);font-family:'Inter',sans-serif}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px)}
    .main-content{flex:1;padding:30px;width:calc(100% - 260px)}
    .page-title{font-size:1.5rem;font-weight:700;color:var(--txt);margin:0}
    .breadcrumb-c{font-size:.85rem;color:var(--muted);margin:4px 0 0}
    .breadcrumb-c a{color:var(--pri);text-decoration:none}
    .admin-panel{background:var(--card);border-radius:16px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);border:1px solid rgba(0,0,0,.04);margin-bottom:24px}
    .panel-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:1px solid #f1f5f9;flex-wrap:wrap;gap:10px}
    .panel-title{font-size:1.1rem;font-weight:700;color:var(--txt);margin:0;display:flex;align-items:center;gap:10px}
    .panel-icon{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center}
    .tbl{width:100%;border-collapse:separate;border-spacing:0 6px}
    .tbl th{background:transparent;color:var(--muted);font-weight:600;font-size:.78rem;text-transform:uppercase;letter-spacing:.5px;padding:10px 14px;border:none;white-space:nowrap}
    .tbl td{background:#fff;padding:13px 14px;vertical-align:middle;color:#475569;font-size:.87rem;border-top:1px solid #f1f5f9;border-bottom:1px solid #f1f5f9}
    .tbl tr td:first-child{border-left:1px solid #f1f5f9;border-radius:10px 0 0 10px}
    .tbl tr td:last-child{border-right:1px solid #f1f5f9;border-radius:0 10px 10px 0}
    .tbl tbody tr:hover td{background:#f8fafc}
    .badge-s{padding:5px 12px;border-radius:6px;font-weight:600;font-size:.74rem;display:inline-flex;align-items:center;gap:5px}
    .b-approved{background:var(--ok-l);color:var(--ok)}
    .b-pending{background:var(--warn-l);color:#b45309}
    .b-cancelled{background:var(--ng-l);color:var(--ng)}
    .hours-p{background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;padding:4px 12px;border-radius:20px;font-weight:700;font-size:.82rem;display:inline-block}
    .nav-tabs-custom{border-bottom:2px solid #e2e8f0;margin-bottom:24px}
    .nav-tabs-custom .nav-link{border:none;color:var(--muted);font-weight:600;padding:12px 20px;border-bottom:3px solid transparent;margin-bottom:-2px;transition:all .2s}
    .nav-tabs-custom .nav-link.active{color:var(--pri);border-bottom-color:var(--pri)}
    .nav-tabs-custom .nav-link:hover{color:var(--pri)}
    .empty-state{text-align:center;padding:50px 20px;color:var(--muted)}
    .empty-state i{font-size:3rem;margin-bottom:16px;opacity:.3;display:block}
    @media(max-width:768px){.main-content{width:100%!important;padding:20px 16px!important}}
</style>
<div class="dashboard-wrapper">
    <jsp:include page="sidebar.jsp"><jsp:param name="activeMenu" value="overtime"/></jsp:include>
    <div class="main-content">
        <div style="margin-bottom:28px">
            <h1 class="page-title"><i class="fas fa-clock me-2" style="color:var(--pri)"></i>Tăng Ca Của Tôi</h1>
            <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/employee/dashboard">Trang chủ</a> &gt; Tăng ca</p>
        </div>

        <!-- Tabs -->
        <ul class="nav nav-tabs-custom">
            <li class="nav-item"><a class="nav-link ${activeTab == 'assigned' ? 'active' : ''}" href="${pageContext.request.contextPath}/employee/overtime?action=assigned"><i class="fas fa-calendar-check me-2"></i>Lịch Tăng Ca</a></li>
            <li class="nav-item"><a class="nav-link ${activeTab == 'history' ? 'active' : ''}" href="${pageContext.request.contextPath}/employee/overtime?action=history"><i class="fas fa-history me-2"></i>Lịch Sử OT</a></li>
        </ul>

        <!-- Upcoming OT (View Assigned OT) -->
        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-icon" style="background:var(--pri-l);color:var(--pri)"><i class="fas fa-calendar-alt"></i></div> Lịch Tăng Ca Sắp Tới</h3>
                <span style="font-size:.85rem;color:var(--muted)"><strong>${upcomingOT.size()}</strong> phân công</span>
            </div>
            <c:choose>
                <c:when test="${empty upcomingOT}">
                    <div class="empty-state"><i class="fas fa-calendar-times"></i><p>Bạn chưa được phân công tăng ca nào sắp tới.</p></div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="tbl">
                            <thead><tr><th>Ngày</th><th>Phòng ban</th><th>Mô tả</th><th>Số giờ</th><th>Trạng thái</th></tr></thead>
                            <tbody>
                                <c:forEach var="a" items="${upcomingOT}">
                                    <tr>
                                        <td><span class="fw-bold" style="color:var(--pri)">${a.targetDate}</span></td>
                                        <td>${a.departmentName}</td>
                                        <td>${a.planDescription}</td>
                                        <td><span class="hours-p">${a.assignedHours}h</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-circle" style="font-size:6px"></i> Đã duyệt</span></c:when>
                                                <c:when test="${a.status == 'Pending'}"><span class="badge-s b-pending"><i class="fas fa-circle" style="font-size:6px"></i> Chờ duyệt</span></c:when>
                                                <c:otherwise><span class="badge-s b-cancelled"><i class="fas fa-circle" style="font-size:6px"></i> ${a.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- OT History (View OT History) -->
        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-icon" style="background:var(--ok-l);color:var(--ok)"><i class="fas fa-history"></i></div> Lịch Sử Tăng Ca</h3>
                <span style="font-size:.85rem;color:var(--muted)"><strong>${pastOT.size()}</strong> bản ghi</span>
            </div>
            <c:choose>
                <c:when test="${empty pastOT}">
                    <div class="empty-state"><i class="fas fa-inbox"></i><p>Chưa có lịch sử tăng ca.</p></div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="tbl">
                            <thead><tr><th>Ngày</th><th>Mô tả</th><th>Số giờ</th><th>Trạng thái</th></tr></thead>
                            <tbody>
                                <c:forEach var="a" items="${pastOT}">
                                    <tr>
                                        <td><span class="fw-bold">${a.targetDate}</span></td>
                                        <td>${a.planDescription}</td>
                                        <td><span class="hours-p">${a.assignedHours}h</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-check-circle"></i> Đã duyệt</span></c:when>
                                                <c:when test="${a.status == 'Pending'}"><span class="badge-s b-pending"><i class="fas fa-hourglass-half"></i> Chờ duyệt</span></c:when>
                                                <c:when test="${a.status == 'Cancelled'}"><span class="badge-s b-cancelled"><i class="fas fa-times-circle"></i> Đã hủy</span></c:when>
                                                <c:otherwise><span class="badge-s b-pending">${a.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
<jsp:include page="../footer.jsp"/>

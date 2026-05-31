<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="java.time.LocalDate, java.time.format.DateTimeFormatter, java.util.Map, model.ShiftAssignment"%>

<c:set var="pageTitle" value="Xếp Lịch Ca - HRM" scope="request" />
<jsp:include page="../header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root{--pri:#6366f1;--pri-l:rgba(99,102,241,.1);--ok:#10b981;--teal:#0d9488;--ng:#ef4444;--bg:#f4f7fe;--card:#fff;--txt:#1e293b;--muted:#64748b}
    body{background:var(--bg);font-family:'Inter',sans-serif}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px)}
    .main-content{flex:1;padding:30px;width:calc(100% - 260px)}
    .page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:28px;flex-wrap:wrap;gap:12px}
    .page-title{font-size:1.5rem;font-weight:700;color:var(--txt);margin:0}
    .breadcrumb-c{font-size:.85rem;color:var(--muted);margin:4px 0 0}
    .breadcrumb-c a{color:var(--pri);text-decoration:none}
    .admin-panel{background:var(--card);border-radius:16px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);border:1px solid rgba(0,0,0,.04);margin-bottom:24px}
    .panel-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:1px solid #f1f5f9;flex-wrap:wrap;gap:10px}
    .panel-title{font-size:1.1rem;font-weight:700;color:var(--txt);margin:0;display:flex;align-items:center;gap:10px}
    .panel-icon{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:1rem}
    .alert-c{border:none;border-radius:10px;font-size:.88rem;padding:12px 20px}
    .a-ok{background:#d1fae5;color:#065f46}.a-err{background:#fee2e2;color:#991b1b}

    /* Week nav */
    .week-nav{display:flex;align-items:center;gap:12px;margin-bottom:24px}
    .week-nav a{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:8px;background:var(--card);border:1px solid #e2e8f0;color:var(--txt);text-decoration:none;font-weight:600;font-size:.85rem;transition:all .2s}
    .week-nav a:hover{background:var(--pri);color:#fff;border-color:var(--pri)}
    .week-label{font-weight:700;font-size:1rem;color:var(--txt)}

    /* Schedule grid */
    .sched-tbl{width:100%;border-collapse:collapse;table-layout:fixed}
    .sched-tbl th{background:#f8fafc;color:var(--muted);font-weight:700;font-size:.78rem;text-transform:uppercase;letter-spacing:.4px;padding:12px 8px;border:1px solid #f1f5f9;text-align:center;white-space:nowrap}
    .sched-tbl th.day-header{min-width:100px}
    .sched-tbl th.emp-header{width:180px;text-align:left;padding-left:16px}
    .sched-tbl td{padding:8px;border:1px solid #f1f5f9;text-align:center;vertical-align:middle;height:52px}
    .sched-tbl td.emp-name{text-align:left;padding-left:16px;font-weight:600;color:var(--txt);font-size:.88rem;background:#fafbfc;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .sched-tbl tbody tr:hover td{background:#f0f4ff}
    .sched-tbl .today-col{background:rgba(99,102,241,.04)}
    .sched-tbl th.today-col{background:rgba(99,102,241,.1);color:var(--pri)}

    /* Shift badge in cell */
    .shift-badge{display:inline-block;padding:4px 10px;border-radius:6px;font-size:.72rem;font-weight:700;letter-spacing:.3px;white-space:nowrap}
    .shift-badge.morning{background:rgba(245,158,11,.12);color:#b45309}
    .shift-badge.afternoon{background:rgba(59,130,246,.12);color:#1d4ed8}
    .shift-badge.night{background:rgba(139,92,246,.12);color:#6d28d9}
    .shift-badge.office{background:rgba(16,185,129,.12);color:#047857}
    .shift-badge.default{background:rgba(100,116,139,.1);color:#475569}
    .empty-cell{color:#cbd5e1;font-size:.8rem}

    /* Assign form */
    .assign-form{background:#f8fafc;border-radius:12px;padding:20px;border:1px solid #e2e8f0}
    .assign-form .form-label{font-weight:600;font-size:.82rem;color:var(--txt)}
    .assign-form .form-control,.assign-form .form-select{border-radius:8px;font-size:.85rem;padding:8px 12px;border:1px solid #e2e8f0}
    .assign-form .form-control:focus,.assign-form .form-select:focus{border-color:var(--pri);box-shadow:0 0 0 3px var(--pri-l)}
    .btn-assign{background:var(--teal);color:#fff;border:none;border-radius:8px;padding:10px 24px;font-weight:600;font-size:.88rem;cursor:pointer;transition:all .2s}
    .btn-assign:hover{background:#0f766e;transform:translateY(-1px);box-shadow:0 4px 12px rgba(13,148,136,.3)}

    @media(max-width:768px){.main-content{width:100%!important;padding:20px 16px!important}.page-header{flex-direction:column;align-items:flex-start}}
</style>

<%
    // Pre-compute values for the week navigation
    LocalDate weekStart = (LocalDate) request.getAttribute("weekStart");
    LocalDate prevWeek = weekStart.minusWeeks(1);
    LocalDate nextWeek = weekStart.plusWeeks(1);
    LocalDate today = LocalDate.now();
    DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("dd/MM");
    DateTimeFormatter fullFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    LocalDate[] weekDates = (LocalDate[]) request.getAttribute("weekDates");
    String[] dayNames = {"T2", "T3", "T4", "T5", "T6", "T7", "CN"};

    // Matrix: Map<Integer userId, Map<Integer dayIdx, ShiftAssignment>>
    @SuppressWarnings("unchecked")
    Map<Integer, Map<Integer, ShiftAssignment>> matrix =
            (Map<Integer, Map<Integer, ShiftAssignment>>) request.getAttribute("matrix");
%>

<div class="dashboard-wrapper">
    <jsp:include page="sidebar.jsp"><jsp:param name="activeMenu" value="shifts"/></jsp:include>
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title"><i class="fas fa-calendar-alt me-2" style="color:var(--teal)"></i>Bảng Xếp Lịch Ca</h1>
                <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/admin/shifts">Ca làm việc</a> &gt; Xếp lịch</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/shifts" class="btn-assign" style="background:var(--pri)"><i class="fas fa-arrow-left me-1"></i>Quản Lý Ca</a>
        </div>

        <c:if test="${not empty param.message}"><div class="alert alert-c a-ok alert-dismissible fade show" role="alert"><i class="fas fa-check-circle me-2"></i>${param.message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
        <c:if test="${not empty param.error}"><div class="alert alert-c a-err alert-dismissible fade show" role="alert"><i class="fas fa-exclamation-circle me-2"></i>${param.error}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

        <!-- Assign Form -->
        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-icon" style="background:rgba(13,148,136,.1);color:var(--teal)"><i class="fas fa-user-clock"></i></div> Xếp Ca Cho Nhân Viên</h3>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/admin/shifts?action=assign" class="assign-form">
                <div class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label">Nhân viên</label>
                        <select name="userId" class="form-select" required>
                            <option value="">-- Chọn --</option>
                            <c:forEach var="u" items="${allUsers}">
                                <option value="${u.userId}">${u.fullName} (${u.username})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Ca làm việc</label>
                        <select name="shiftId" class="form-select" required>
                            <option value="">-- Chọn ca --</option>
                            <c:forEach var="sh" items="${activeShifts}">
                                <option value="${sh.shiftId}">${sh.shiftName} (${sh.startTime}-${sh.endTime})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2"><label class="form-label">Từ ngày</label><input type="date" name="fromDate" class="form-control" required></div>
                    <div class="col-md-2"><label class="form-label">Đến ngày</label><input type="date" name="toDate" class="form-control" required></div>
                    <div class="col-md-2"><button type="submit" class="btn-assign w-100"><i class="fas fa-calendar-check me-1"></i>Xếp Lịch</button></div>
                </div>
            </form>
        </div>

        <!-- Week Navigation -->
        <div class="week-nav">
            <a href="${pageContext.request.contextPath}/admin/shifts?action=schedule&week=<%= prevWeek %>"><i class="fas fa-chevron-left"></i> Tuần trước</a>
            <span class="week-label"><i class="fas fa-calendar-week me-1" style="color:var(--pri)"></i> <%= weekDates[0].format(fullFmt) %> — <%= weekDates[6].format(fullFmt) %></span>
            <a href="${pageContext.request.contextPath}/admin/shifts?action=schedule&week=<%= nextWeek %>">Tuần sau <i class="fas fa-chevron-right"></i></a>
            <a href="${pageContext.request.contextPath}/admin/shifts?action=schedule" style="background:var(--teal);color:#fff;border-color:var(--teal)"><i class="fas fa-crosshairs"></i> Hôm nay</a>
        </div>

        <!-- Schedule Grid -->
        <div class="admin-panel" style="padding:16px;overflow-x:auto">
            <table class="sched-tbl">
                <thead>
                    <tr>
                        <th class="emp-header">Nhân viên</th>
                        <% for (int d = 0; d < 7; d++) {
                            boolean isToday = weekDates[d].equals(today);
                        %>
                        <th class="day-header <%= isToday ? "today-col" : "" %>">
                            <%= dayNames[d] %><br><span style="font-weight:400;font-size:.72rem"><%= weekDates[d].format(dayFmt) %></span>
                        </th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (matrix == null || matrix.isEmpty()) {
                    %>
                    <tr><td colspan="8" style="text-align:center;padding:40px;color:var(--muted)"><i class="fas fa-calendar-times" style="font-size:2rem;opacity:.3;display:block;margin-bottom:12px"></i>Chưa có lịch xếp ca cho tuần này.</td></tr>
                    <%
                        } else {
                            // We need user names. Loop through allUsers and check if they have entries in the matrix.
                            java.util.List<model.User> allUsers = (java.util.List<model.User>) request.getAttribute("allUsers");
                            for (model.User u : allUsers) {
                                Map<Integer, ShiftAssignment> row = matrix.get(u.getUserId());
                                if (row == null) continue; // Skip users with no assignments this week
                    %>
                    <tr>
                        <td class="emp-name"><i class="fas fa-user-circle me-2" style="color:var(--muted)"></i><%= u.getFullName() %></td>
                        <% for (int d = 0; d < 7; d++) {
                            boolean isToday = weekDates[d].equals(today);
                            ShiftAssignment sa = (row != null) ? row.get(d) : null;
                        %>
                        <td class="<%= isToday ? "today-col" : "" %>">
                            <% if (sa != null) {
                                String sName = sa.getShiftName() != null ? sa.getShiftName() : "";
                                String cssClass = "default";
                                if (sName.contains("Sáng") || sName.contains("Ca 1")) cssClass = "morning";
                                else if (sName.contains("Chiều") || sName.contains("Ca 2")) cssClass = "afternoon";
                                else if (sName.contains("Đêm") || sName.contains("Ca 3")) cssClass = "night";
                                else if (sName.contains("Hành chính")) cssClass = "office";
                            %>
                            <span class="shift-badge <%= cssClass %>" title="<%= sName %>"><%= sName %></span>
                            <% } else { %>
                            <span class="empty-cell">—</span>
                            <% } %>
                        </td>
                        <% } %>
                    </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<jsp:include page="../footer.jsp"/>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.time.LocalDate, java.time.format.DateTimeFormatter, java.util.Map, model.ShiftAssignment"%>

<c:set var="pageTitle" value="Xếp Lịch Ca - Quản đốc" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<style>
footer, #chatWidget { display: none !important; }
body { background: #f1f5f9; font-family: 'Inter', sans-serif; padding-top: 0 !important; }
.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.main-content { flex: 1; padding: 28px 32px; }

/* ── Page Header ── */
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
.page-title-block h1 { font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0; letter-spacing: -0.5px; }
.page-breadcrumb { font-size: 0.78rem; color: #94a3b8; margin-top: 4px; }
.page-breadcrumb a { color: #0d9488; text-decoration: none; }
.role-badge {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 7px 16px; border-radius: 20px; font-size: 0.82rem; font-weight: 700;
    background: linear-gradient(135deg, #d97706, #b45309); color: #fff;
    box-shadow: 0 2px 8px rgba(217,119,6,0.3);
}

/* ── Alert ── */
.alert-c { border-radius: 10px; padding: 12px 20px; font-size: 0.87rem; font-weight: 500;
           display: flex; align-items: center; gap: 10px; margin-bottom: 20px; }
.a-ok  { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
.a-err { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

/* ── Card ── */
.card-panel {
    background: #fff; border-radius: 16px; border: 1px solid #e2e8f0;
    box-shadow: 0 1px 4px rgba(0,0,0,0.05); padding: 24px; margin-bottom: 24px;
}
.card-panel-header { display: flex; justify-content: space-between; align-items: center;
                     margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #f1f5f9; }
.card-panel-title { font-size: 1rem; font-weight: 700; color: #0f172a;
                    display: flex; align-items: center; gap: 10px; }
.card-panel-icon { width: 38px; height: 38px; border-radius: 9px;
                   display: flex; align-items: center; justify-content: center; font-size: 0.95rem; }

/* ── Assign Form ── */
.assign-form .form-label { font-weight: 600; font-size: 0.82rem; color: #374151; }
.assign-form .form-control,
.assign-form .form-select {
    border-radius: 8px; font-size: 0.85rem; padding: 8px 12px;
    border: 1px solid #e2e8f0;
    transition: border-color 0.2s, box-shadow 0.2s;
}
.assign-form .form-control:focus,
.assign-form .form-select:focus {
    border-color: #d97706; box-shadow: 0 0 0 3px rgba(217,119,6,0.12); outline: none;
}
.btn-assign {
    background: #d97706; color: #fff; border: none; border-radius: 8px;
    padding: 10px 22px; font-weight: 700; font-size: 0.88rem;
    cursor: pointer; transition: all 0.2s; width: 100%;
    display: flex; align-items: center; justify-content: center; gap: 6px;
}
.btn-assign:hover { background: #b45309; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(217,119,6,0.35); }

/* ── OT badge hint ── */
.ot-hint {
    background: #fef3c7; border: 1px solid #fde68a; border-radius: 8px;
    padding: 8px 14px; font-size: 0.8rem; color: #92400e; font-weight: 500;
    display: flex; align-items: center; gap: 8px; margin-bottom: 16px;
}

/* ── Week Nav ── */
.week-nav { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.week-nav a {
    display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px;
    border-radius: 8px; background: #fff; border: 1px solid #e2e8f0;
    color: #374151; text-decoration: none; font-weight: 600; font-size: 0.84rem; transition: all 0.2s;
}
.week-nav a:hover { background: #d97706; color: #fff; border-color: #d97706; }
.week-nav a.today-btn { background: #0d9488; color: #fff; border-color: #0d9488; }
.week-nav a.today-btn:hover { background: #0f766e; }
.week-label { font-weight: 700; font-size: 1rem; color: #0f172a; }

/* ── Schedule Table ── */
.sched-wrap { overflow-x: auto; }
.sched-tbl { width: 100%; border-collapse: collapse; table-layout: fixed; min-width: 700px; }
.sched-tbl th {
    background: #f8fafc; color: #64748b; font-weight: 700; font-size: 0.75rem;
    text-transform: uppercase; letter-spacing: 0.4px; padding: 12px 8px;
    border: 1px solid #f1f5f9; text-align: center; white-space: nowrap;
}
.sched-tbl th.emp-header { width: 180px; text-align: left; padding-left: 16px; }
.sched-tbl th.day-header { min-width: 100px; }
.sched-tbl th.today-col { background: rgba(217,119,6,0.08); color: #d97706; }
.sched-tbl td {
    padding: 8px; border: 1px solid #f1f5f9; text-align: center;
    vertical-align: middle; height: 52px;
}
.sched-tbl td.emp-name {
    text-align: left; padding-left: 14px; font-weight: 600; color: #0f172a;
    font-size: 0.87rem; background: #fafbfc; white-space: nowrap;
    overflow: hidden; text-overflow: ellipsis;
}
.sched-tbl td.today-col { background: rgba(217,119,6,0.03); }
.sched-tbl tbody tr:hover td { background: #fffbeb; }

/* ── Shift Badges ── */
.shift-badge {
    display: inline-block; padding: 4px 10px; border-radius: 6px;
    font-size: 0.72rem; font-weight: 700; letter-spacing: 0.3px; white-space: nowrap;
}
.shift-badge.office  { background: rgba(16,185,129,0.12);  color: #047857; }
.shift-badge.ot-short{ background: rgba(245,158,11,0.15);  color: #b45309; }
.shift-badge.ot-long { background: rgba(239,68,68,0.12);   color: #b91c1c; }
.shift-badge.default { background: rgba(100,116,139,0.10); color: #475569; }
.empty-cell { color: #cbd5e1; font-size: 0.8rem; }

@media (max-width: 768px) { .main-content { padding: 20px 16px !important; } }

/* ── Custom Select2 Styling ── */
.select2-container--default .select2-selection--multiple {
    border: 1px solid #e2e8f0 !important;
    border-radius: 8px !important;
    padding: 3px 8px !important;
    min-height: 38px !important;
    transition: all 0.2s !important;
    background-color: #fff !important;
}
.select2-container--default.select2-container--focus .select2-selection--multiple {
    border-color: #d97706 !important;
    box-shadow: 0 0 0 3px rgba(217,119,6,0.12) !important;
}
.select2-container--default .select2-selection--multiple .select2-selection__choice {
    background-color: #fef3c7 !important;
    border: 1px solid #fde68a !important;
    color: #92400e !important;
    border-radius: 6px !important;
    padding: 2px 8px !important;
    font-size: 0.8rem !important;
    font-weight: 600 !important;
    margin-top: 4px !important;
}
.select2-container--default .select2-selection--multiple .select2-selection__choice__remove {
    color: #b45309 !important;
    margin-right: 5px !important;
    border-right: 1px solid #fde68a !important;
    padding-right: 4px !important;
    background: none !important;
    border-top-left-radius: 4px !important;
    border-bottom-left-radius: 4px !important;
}
.select2-container--default .select2-selection--multiple .select2-selection__choice__remove:hover {
    background-color: #fde68a !important;
    color: #78350f !important;
}
.select2-container--default .select2-results__option--highlighted[aria-selected] {
    background-color: #d97706 !important;
    color: #fff !important;
}
.select2-dropdown {
    border-color: #e2e8f0 !important;
    border-radius: 8px !important;
    box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06) !important;
}
</style>

<%
    LocalDate weekStart = (LocalDate) request.getAttribute("weekStart");
    LocalDate prevWeek  = weekStart.minusWeeks(1);
    LocalDate nextWeek  = weekStart.plusWeeks(1);
    LocalDate today     = LocalDate.now();
    DateTimeFormatter dayFmt  = DateTimeFormatter.ofPattern("dd/MM");
    DateTimeFormatter fullFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    LocalDate[] weekDates = (LocalDate[]) request.getAttribute("weekDates");
    String[] dayNames = {"T2", "T3", "T4", "T5", "T6", "T7", "CN"};

    @SuppressWarnings("unchecked")
    Map<Integer, Map<Integer, java.util.List<ShiftAssignment>>> matrix =
        (Map<Integer, Map<Integer, java.util.List<ShiftAssignment>>>) request.getAttribute("matrix");
%>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="shift-schedule"/>
    </jsp:include>

    <div class="main-content">

        <%-- Page Header --%>
        <div class="page-header">
            <div class="page-title-block">
                <h1><i class="fas fa-calendar-alt" style="color:#d97706;margin-right:10px;"></i>Xếp Lịch Ca</h1>
                <div class="page-breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    &gt; Xếp lịch ca công nhân
                </div>
            </div>
            <div class="role-badge"><i class="fas fa-hard-hat"></i> Quản đốc xưởng</div>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty param.message}">
            <div class="alert-c a-ok"><i class="fas fa-check-circle"></i> ${param.message}</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert-c a-err"><i class="fas fa-exclamation-circle"></i> ${param.error}</div>
        </c:if>

        <%-- Assign Form --%>
        <div class="card-panel">
            <div class="card-panel-header">
                <div class="card-panel-title">
                    <div class="card-panel-icon" style="background:rgba(217,119,6,0.1);color:#d97706;">
                        <i class="fas fa-user-clock"></i>
                    </div>
                    Gán Ca Cho Công Nhân
                </div>
            </div>

            <%-- Ghi chú OT --%>
            <div class="ot-hint">
                <i class="fas fa-info-circle"></i>
                <span>Tăng ca (OT) do quản đốc phân sẽ được tự động hiển thị dưới dạng <strong>Ca hành chính</strong> (ban ngày) hoặc <strong>Ca 3 (Đêm)</strong> (ban đêm) dựa trên khung giờ.</span>
            </div>

            <form method="POST" action="${pageContext.request.contextPath}/manager/shift-schedule?action=assign"
                  class="assign-form">
                <div class="row g-3 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label"><i class="fas fa-search" style="color:#d97706; margin-right:6px;"></i>Tìm & Chọn công nhân (gõ tên để tìm kiếm)</label>
                        <select id="workerSelect" name="userId" class="form-select" multiple="multiple" required>
                            <c:forEach var="w" items="${workers}">
                                <option value="${w.userId}">${w.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <!-- Time selection for custom OT -->
                    <div class="col-md-3">
                        <label class="form-label">Loại Tăng Ca (OT)</label>
                        <select name="otType" class="form-select" required>
                            <option value="">-- Chọn Loại OT --</option>
                            <option value="2">Ca Đêm 1 (18:00 - 20:00) - Không nghỉ</option>
                            <option value="4">Ca Đêm 2 (18:00 - 22:00) - Nghỉ 20h-20h30</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Từ ngày</label>
                        <input type="date" name="fromDate" class="form-control" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Đến ngày</label>
                        <input type="date" name="toDate" class="form-control" required>
                    </div>
                    <div class="col-12 text-end mt-3">
                        <button type="submit" class="btn-assign" style="width: auto; min-width: 160px; display: inline-flex;">
                            <i class="fas fa-calendar-check"></i> Xếp lịch
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <%-- Week Navigation --%>
        <div class="week-nav">
            <a href="${pageContext.request.contextPath}/manager/shift-schedule?week=<%= prevWeek %>">
                <i class="fas fa-chevron-left"></i> Tuần trước
            </a>
            <span class="week-label">
                <i class="fas fa-calendar-week" style="color:#d97706;margin-right:4px;"></i>
                <%= weekDates[0].format(fullFmt) %> — <%= weekDates[6].format(fullFmt) %>
            </span>
            <a href="${pageContext.request.contextPath}/manager/shift-schedule?week=<%= nextWeek %>">
                Tuần sau <i class="fas fa-chevron-right"></i>
            </a>
            <a href="${pageContext.request.contextPath}/manager/shift-schedule" class="today-btn">
                <i class="fas fa-crosshairs"></i> Tuần này
            </a>
        </div>

        <%-- Schedule Grid --%>
        <div class="card-panel" style="padding: 16px;">
            <div class="sched-wrap">
                <table class="sched-tbl">
                    <thead>
                        <tr>
                            <th class="emp-header">Công nhân</th>
                            <% for (int d = 0; d < 7; d++) {
                                boolean isToday = weekDates[d].equals(today); %>
                            <th class="day-header <%= isToday ? "today-col" : "" %>">
                                <%= dayNames[d] %><br>
                                <span style="font-weight:400;font-size:0.72rem;"><%= weekDates[d].format(dayFmt) %></span>
                            </th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (matrix == null || matrix.isEmpty()) { %>
                        <tr>
                            <td colspan="8" style="text-align:center;padding:48px;color:#94a3b8;">
                                <i class="fas fa-calendar-times" style="font-size:2rem;opacity:0.3;display:block;margin-bottom:12px;"></i>
                                Chưa có lịch xếp ca cho tuần này.
                            </td>
                        </tr>
                        <% } else {
                            java.util.List<model.User> workers =
                                (java.util.List<model.User>) request.getAttribute("workers");
                            for (model.User w : workers) {
                                Map<Integer, java.util.List<ShiftAssignment>> row = matrix.get(w.getUserId());
                                if (row == null) continue; %>
                        <tr>
                            <td class="emp-name">
                                <i class="fas fa-user-hard-hat" style="color:#d97706;margin-right:6px;"></i>
                                <%= w.getFullName() %>
                            </td>
                            <% for (int d = 0; d < 7; d++) {
                                boolean isToday = weekDates[d].equals(today);
                                java.util.List<ShiftAssignment> saList = (row != null) ? row.get(d) : null; %>
                            <td class="<%= isToday ? "today-col" : "" %>">
                                <% if (saList != null && !saList.isEmpty()) {
                                    for (ShiftAssignment sa : saList) {
                                        String sName = sa.getShiftName() != null ? sa.getShiftName() : "";
                                        String css = "default";
                                        if (sName.toLowerCase().contains("hành chính")) css = "office";
                                        else if (sName.toLowerCase().contains("đêm"))   css = "ot-long";
                                        else css = "default";
                                        
                                        // Set display name explicitly if needed or rely on sName
                                %>
                                        <div style="margin-bottom: 4px; display: inline-block;">
                                            <span class="shift-badge <%= css %>" title="<%= sName %>">
                                                <%= sName %>
                                                <form action="${pageContext.request.contextPath}/manager/shift-schedule" method="POST" style="display:inline; margin-left: 6px;">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="assignmentId" value="<%= sa.getAssignmentId() %>">
                                                    <button type="submit" onclick="return confirm('Bạn có chắc muốn xóa ca <%= sName %> này không?');"
                                                            style="background: none; border: none; padding: 0; color: inherit; opacity: 0.8; cursor: pointer; text-decoration: none;">
                                                        <i class="fas fa-times-circle"></i>
                                                    </button>
                                                </form>
                                            </span>
                                        </div><br/>
                                <%  } 
                                   } else { %>
                                    <span class="empty-cell">—</span>
                                <% } %>
                            </td>
                            <% } %>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div><%-- end main-content --%>
</div><%-- end dashboard-wrapper --%>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<script>
    $(document).ready(function() {
        $('#workerSelect').select2({
            placeholder: "Gõ tên nhân viên để tìm kiếm...",
            allowClear: true,
            width: '100%',
            language: {
                noResults: function() {
                    return "Không tìm thấy công nhân nào";
                }
            }
        });
    });
</script>

<jsp:include page="../footer.jsp"/>

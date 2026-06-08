<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page import="java.time.LocalDate, java.time.LocalTime, java.time.format.DateTimeFormatter, model.ShiftAssignment, java.util.*"%>

<c:set var="pageTitle" value="Lịch Phân Ca - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<%
    LocalDate weekStart = (LocalDate) request.getAttribute("weekStart");
    LocalDate weekEnd   = (LocalDate) request.getAttribute("weekEnd");
    LocalDate prevWeek  = weekStart.minusWeeks(1);
    LocalDate nextWeek  = weekStart.plusWeeks(1);
    LocalDate today     = LocalDate.now();
    LocalDate[] weekDates = (LocalDate[]) request.getAttribute("weekDates");
    DateTimeFormatter dayFmt  = DateTimeFormatter.ofPattern("dd/MM");
    DateTimeFormatter fullFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @SuppressWarnings("unchecked")
    List<ShiftAssignment> weekAssignments = (List<ShiftAssignment>) request.getAttribute("weekAssignments");
    double[] workingHours = (double[]) request.getAttribute("workingHours");

    // Build a map: dayOfWeek-index -> List<ShiftAssignment> for quick lookup
    Map<Integer, List<ShiftAssignment>> dayMap = new LinkedHashMap<>();
    Map<Integer, List<Double>> hoursMap = new LinkedHashMap<>();
    if (weekAssignments != null) {
        for (int i = 0; i < weekAssignments.size(); i++) {
            ShiftAssignment sa = weekAssignments.get(i);
            int dayIdx = (int) (sa.getAssignedDate().toEpochDay() - weekStart.toEpochDay());
            if (dayIdx >= 0 && dayIdx < 7) {
                dayMap.computeIfAbsent(dayIdx, k -> new ArrayList<>()).add(sa);
                if (workingHours != null && i < workingHours.length) {
                    hoursMap.computeIfAbsent(dayIdx, k -> new ArrayList<>()).add(workingHours[i]);
                }
            }
        }
    }

    String[] dayNames = {"Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ Nhật"};
%>

<style>
    :root {
        --pri: #6366f1; --pri-l: rgba(99,102,241,.1);
        --teal: #0d9488; --ok: #10b981; --ng: #ef4444;
        --bg: #f0f4f8; --card: #fff; --txt: #1e293b; --muted: #64748b;
    }
    body { background: var(--bg); font-family: 'Inter', sans-serif; }

    .emp-layout { display: flex; min-height: calc(100vh - 64px); }
    .emp-content { flex: 1; padding: 30px; overflow-y: auto; }

    /* Page header */
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; flex-wrap: wrap; gap: 12px; }
    .page-title { font-size: 1.5rem; font-weight: 700; color: var(--txt); margin: 0; }
    .breadcrumb-c { font-size: .85rem; color: var(--muted); margin: 4px 0 0; }
    .breadcrumb-c a { color: var(--pri); text-decoration: none; }

    /* Summary banner */
    .summary-banner {
        background: linear-gradient(135deg, #0a2540 0%, #1a3a6b 100%);
        color: white; border-radius: 16px; padding: 24px 32px;
        margin-bottom: 24px; position: relative; overflow: hidden;
        display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;
    }
    .summary-banner::after {
        content: ''; position: absolute; top: -60px; right: -60px;
        width: 220px; height: 220px; background: rgba(255,255,255,.04);
        border-radius: 50%; pointer-events: none;
    }
    .summary-left h2 { font-size: 1.3rem; font-weight: 700; margin: 0 0 6px; }
    .summary-left p { margin: 0; opacity: .72; font-size: .88rem; }
    .summary-stats { display: flex; gap: 24px; z-index: 1; }
    .stat-box { text-align: center; }
    .stat-box .stat-num { font-size: 1.8rem; font-weight: 800; line-height: 1; }
    .stat-box .stat-label { font-size: .72rem; opacity: .7; text-transform: uppercase; letter-spacing: .5px; font-weight: 600; }

    /* Week nav */
    .week-nav { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; }
    .week-nav a {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 16px; border-radius: 8px; background: var(--card);
        border: 1px solid #e2e8f0; color: var(--txt); text-decoration: none;
        font-weight: 600; font-size: .85rem; transition: all .2s;
    }
    .week-nav a:hover { background: var(--pri); color: #fff; border-color: var(--pri); }
    .week-label { font-weight: 700; font-size: 1rem; color: var(--txt); }

    /* Schedule cards */
    .sched-panel { background: var(--card); border-radius: 16px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,.03); border: 1px solid rgba(0,0,0,.04); }
    .sched-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px; }

    .day-card {
        background: #f8fafc; border-radius: 14px; padding: 18px; position: relative;
        border: 1px solid #e2e8f0; transition: all .25s; overflow: hidden;
    }
    .day-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.07); }
    .day-card.is-today {
        border: 2px solid var(--pri); background: linear-gradient(135deg, rgba(99,102,241,.04), rgba(99,102,241,.08));
    }
    .day-card.is-today::before {
        content: 'HÔM NAY'; position: absolute; top: 8px; right: 8px;
        background: var(--pri); color: #fff; font-size: .62rem; font-weight: 800;
        padding: 3px 8px; border-radius: 20px; letter-spacing: .5px;
    }
    .day-card.is-past { opacity: .55; }
    .day-card.is-off { border-left: 4px solid #dd6b20; }

    .day-header { display: flex; align-items: center; gap: 10px; margin-bottom: 14px; }
    .day-num {
        width: 42px; height: 42px; border-radius: 10px; display: flex;
        align-items: center; justify-content: center; font-weight: 800;
        font-size: 1.1rem; flex-shrink: 0;
    }
    .day-num.default { background: #f1f5f9; color: var(--txt); }
    .day-num.today { background: var(--pri); color: #fff; }
    .day-name { font-weight: 700; font-size: .92rem; color: var(--txt); }
    .day-date { font-size: .76rem; color: var(--muted); font-weight: 500; }

    .shift-info { display: flex; flex-direction: column; gap: 8px; }
    .shift-badge-lg {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 6px 14px; border-radius: 8px; font-size: .82rem; font-weight: 700;
    }
    .shift-badge-lg.morning { background: rgba(245,158,11,.12); color: #b45309; }
    .shift-badge-lg.afternoon { background: rgba(59,130,246,.12); color: #1d4ed8; }
    .shift-badge-lg.night { background: rgba(139,92,246,.15); color: #6d28d9; }
    .shift-badge-lg.office { background: rgba(16,185,129,.12); color: #047857; }
    .shift-badge-lg.default-badge { background: rgba(100,116,139,.1); color: #475569; }

    .shift-time-row { display: flex; align-items: center; gap: 8px; font-size: .84rem; color: var(--txt); font-weight: 500; }
    .shift-time-row i { color: var(--muted); font-size: .8rem; }
    .shift-hours { font-size: .78rem; color: var(--muted); font-weight: 600; }
    .shift-coeff { font-size: .72rem; padding: 2px 8px; border-radius: 12px; background: rgba(245,158,11,.1); color: #b45309; font-weight: 700; }

    .off-label { display: flex; align-items: center; gap: 8px; font-size: .88rem; color: #dd6b20; font-weight: 600; }
    .off-label i { font-size: 1rem; }

    /* Legend */
    .legend { display: flex; gap: 16px; flex-wrap: wrap; margin-top: 20px; padding-top: 16px; border-top: 1px solid #f1f5f9; }
    .legend-item { display: flex; align-items: center; gap: 6px; font-size: .76rem; color: var(--muted); font-weight: 600; }
    .legend-dot { width: 10px; height: 10px; border-radius: 3px; }

    @media(max-width: 768px) {
        .emp-content { padding: 20px 16px !important; }
        .sched-grid { grid-template-columns: 1fr; }
        .summary-banner { flex-direction: column; align-items: flex-start; }
    }
</style>

<div class="emp-layout">
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="schedule" />
    </jsp:include>

    <div class="emp-content">
        <div class="page-header">
            <div>
                <h1 class="page-title"><i class="fas fa-calendar-alt me-2" style="color:var(--teal)"></i>Lịch Phân Ca Cá Nhân</h1>
                <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/employee/dashboard">Trang chủ</a> &gt; Lịch phân ca</p>
            </div>
        </div>

        <!-- Summary Banner -->
        <%
            int totalShifts = 0;
            int nightCount = 0;
            double totalHours = 0;
            for (Map.Entry<Integer, List<ShiftAssignment>> entry : dayMap.entrySet()) {
                List<ShiftAssignment> listSa = entry.getValue();
                totalShifts += listSa.size();
                for (ShiftAssignment sa : listSa) {
                    if (sa.isNightShift()) nightCount++;
                }
                List<Double> listH = hoursMap.get(entry.getKey());
                if (listH != null) {
                    for (Double h : listH) totalHours += h;
                }
            }
        %>
        <div class="summary-banner">
            <div class="summary-left">
                <h2><i class="fas fa-calendar-week me-2"></i>Tổng quan tuần</h2>
                <p><%= weekDates[0].format(fullFmt) %> — <%= weekDates[6].format(fullFmt) %></p>
            </div>
            <div class="summary-stats">
                <div class="stat-box">
                    <div class="stat-num"><%= totalShifts %></div>
                    <div class="stat-label">Ca làm việc</div>
                </div>
                <div class="stat-box">
                    <div class="stat-num"><%= String.format("%.1f", totalHours) %></div>
                    <div class="stat-label">Tổng giờ</div>
                </div>
                <div class="stat-box">
                    <div class="stat-num"><%= nightCount %></div>
                    <div class="stat-label">Ca đêm</div>
                </div>
                <div class="stat-box">
                    <div class="stat-num"><%= 7 - totalShifts %></div>
                    <div class="stat-label">Ngày nghỉ</div>
                </div>
            </div>
        </div>

        <!-- Week Navigation -->
        <div class="week-nav">
            <a href="${pageContext.request.contextPath}/employee/schedule?week=<%= prevWeek %>"><i class="fas fa-chevron-left"></i> Tuần trước</a>
            <span class="week-label"><i class="fas fa-calendar-week me-1" style="color:var(--pri)"></i> <%= weekDates[0].format(fullFmt) %> — <%= weekDates[6].format(fullFmt) %></span>
            <a href="${pageContext.request.contextPath}/employee/schedule?week=<%= nextWeek %>">Tuần sau <i class="fas fa-chevron-right"></i></a>
            <a href="${pageContext.request.contextPath}/employee/schedule" style="background:var(--teal);color:#fff;border-color:var(--teal)"><i class="fas fa-crosshairs"></i> Hôm nay</a>
        </div>

        <!-- Schedule Grid -->
        <div class="sched-panel">
            <div class="sched-grid">
                <% for (int d = 0; d < 7; d++) {
                    boolean isToday = weekDates[d].equals(today);
                    boolean isPast  = weekDates[d].isBefore(today);
                    List<ShiftAssignment> saList = dayMap.get(d);
                    boolean isOff = (saList == null || saList.isEmpty());

                    String cardClass = "day-card";
                    if (isToday) cardClass += " is-today";
                    else if (isPast) cardClass += " is-past";
                    if (isOff) cardClass += " is-off";
                %>
                <div class="<%= cardClass %>">
                    <div class="day-header">
                        <div class="day-num <%= isToday ? "today" : "default" %>">
                            <%= weekDates[d].getDayOfMonth() %>
                        </div>
                        <div>
                            <div class="day-name"><%= dayNames[d] %></div>
                            <div class="day-date"><%= weekDates[d].format(dayFmt) %></div>
                        </div>
                    </div>

                    <% if (!isOff) {
                        for (int sIdx = 0; sIdx < saList.size(); sIdx++) {
                            ShiftAssignment sa = saList.get(sIdx);
                            String sName = sa.getShiftName() != null ? sa.getShiftName() : "";
                            String badgeClass = "default-badge";
                            String badgeIcon = "fa-clock";
                            if (sName.contains("Sáng") || sName.contains("Ca 1")) { badgeClass = "morning"; badgeIcon = "fa-sun"; }
                            else if (sName.contains("Chiều") || sName.contains("Ca 2")) { badgeClass = "afternoon"; badgeIcon = "fa-cloud-sun"; }
                            else if (sName.contains("Đêm") || sName.contains("Ca 3") || sa.isNightShift()) { badgeClass = "night"; badgeIcon = "fa-moon"; }
                            else if (sName.contains("Hành chính")) { badgeClass = "office"; badgeIcon = "fa-building"; }

                            String startStr = sa.getStartTime() != null ? sa.getStartTime().toString() : "--:--";
                            String endStr   = sa.getEndTime()   != null ? sa.getEndTime().toString()   : "--:--";
                            List<Double> listH = hoursMap.get(d);
                            Double hours = (listH != null && sIdx < listH.size()) ? listH.get(sIdx) : null;
                    %>
                    <div class="shift-info" style="margin-bottom: 12px; padding-bottom: 12px; border-bottom: <%= sIdx < saList.size() - 1 ? "1px dashed #e2e8f0" : "none" %>;">
                        <span class="shift-badge-lg <%= badgeClass %>" style="display:inline-flex; width: fit-content;">
                            <i class="fas <%= badgeIcon %>"></i> <%= sName %>
                        </span>
                        <div class="shift-time-row">
                            <i class="fas fa-clock"></i>
                            <span><%= startStr %> — <%= endStr %></span>
                        </div>
                        <div style="display:flex;align-items:center;gap:10px;">
                            <% if (hours != null) { %>
                            <span class="shift-hours"><i class="fas fa-hourglass-half me-1"></i><%= String.format("%.1f", hours) %>h làm việc</span>
                            <% } %>
                            <% if (sa.getCoefficient() > 1.0f) { %>
                            <span class="shift-coeff">x<%= String.format("%.1f", sa.getCoefficient()) %></span>
                            <% } %>
                        </div>
                        <% if (sa.isNightShift()) { %>
                        <div style="font-size:.72rem;color:#6d28d9;font-weight:600;display:flex;align-items:center;gap:4px;">
                            <i class="fas fa-moon" style="font-size:.65rem;"></i> Ca xuyên đêm
                        </div>
                        <% } %>
                    </div>
                    <%  } // end for saList
                       } else { %>
                    <div class="off-label">
                        <i class="fas fa-bed"></i> Nghỉ
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>

            <!-- Legend -->
            <div class="legend">
                <div class="legend-item"><div class="legend-dot" style="background:rgba(245,158,11,.6)"></div>Ca Sáng</div>
                <div class="legend-item"><div class="legend-dot" style="background:rgba(59,130,246,.6)"></div>Ca Chiều</div>
                <div class="legend-item"><div class="legend-dot" style="background:rgba(139,92,246,.6)"></div>Ca Đêm</div>
                <div class="legend-item"><div class="legend-dot" style="background:rgba(16,185,129,.6)"></div>Hành chính</div>
                <div class="legend-item"><div class="legend-dot" style="background:#dd6b20"></div>Nghỉ</div>
            </div>
        </div>

    </div><!-- end .emp-content -->
</div><!-- end .emp-layout -->

<jsp:include page="../footer.jsp" />

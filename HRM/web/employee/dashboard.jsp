    <%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Bảng điều khiển - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f0f4f8; }

    /* ── Layout wrapper ── */
    .emp-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .emp-content {
        flex: 1;
        padding: 30px;
        overflow-y: auto;
    }

    /* ── Welcome Banner ── */
    .welcome-banner {
        background: linear-gradient(135deg, #0a2540 0%, #1a3a6b 100%);
        color: white;
        border-radius: 14px;
        padding: 24px 32px;
        margin-bottom: 24px;
        position: relative;
        overflow: hidden;
    }
    .welcome-banner::after {
        content: '';
        position: absolute;
        top: -60px; right: -60px;
        width: 220px; height: 220px;
        background: rgba(255,255,255,0.04);
        border-radius: 50%;
        pointer-events: none;
    }
    .welcome-banner h2 { font-size: 1.4rem; font-weight: 700; margin: 0 0 6px; }
    .welcome-banner p  { margin: 0; opacity: 0.72; font-size: 0.9rem; }

    /* ── Card ── */
    .emp-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        padding: 22px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        transition: box-shadow 0.2s;
        height: 100%;
    }
    .emp-card:hover { box-shadow: 0 6px 18px rgba(0,0,0,0.07); }

    .emp-card-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        margin-bottom: 18px;
        padding-bottom: 12px;
        border-bottom: 1px solid #edf2f7;
    }
    .emp-card-title {
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 700;
        font-size: 0.95rem;
        color: #2d3748;
        margin: 0;
    }

    /* ── Clock Widget ── */
    .clock-wrap { text-align: center; padding: 8px 0 4px; }
    .clock-time {
        font-size: 2.6rem;
        font-weight: 800;
        color: #0a2540;
        font-family: 'Courier New', monospace;
        letter-spacing: -1px;
        line-height: 1;
    }
    .clock-date {
        font-size: 0.82rem;
        color: #718096;
        font-weight: 500;
        margin: 6px 0 20px;
    }
    .btn-checkin {
        display: block;
        width: 100%;
        padding: 13px;
        background: #2b6cb0;
        color: #fff;
        border: none;
        border-radius: 10px;
        font-weight: 700;
        font-size: 1rem;
        cursor: pointer;
        transition: background 0.2s, transform 0.15s;
    }
    .btn-checkin:hover { background: #2c5282; transform: translateY(-1px); }
    .clock-location {
        margin-top: 12px;
        font-size: 0.8rem;
        color: #718096;
        text-align: center;
    }

    /* ── Stat rows ── */
    .stat-row {
        display: flex;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px dashed #edf2f7;
    }
    .stat-row:last-child { border-bottom: none; padding-bottom: 0; }
    .stat-icon {
        width: 40px; height: 40px;
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
        margin-right: 14px;
    }
    .stat-icon.blue   { background:#ebf8ff; color:#3182ce; }
    .stat-icon.orange { background:#fffaf0; color:#dd6b20; }
    .stat-icon.green  { background:#f0fff4; color:#38a169; }
    .stat-content h5 {
        margin: 0;
        font-size: 1.3rem;
        font-weight: 800;
        color: #1a202c;
        line-height: 1;
    }
    .stat-content span {
        font-size: 0.78rem;
        color: #718096;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.02em;
    }

    /* ── News list ── */
    .news-item {
        display: flex;
        align-items: flex-start;
        gap: 14px;
        padding: 14px 0;
        border-bottom: 1px dashed #edf2f7;
    }
    .news-item:last-child { border-bottom: none; padding-bottom: 0; }
    .news-icon {
        width: 36px; height: 36px;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        color: #fff;
        font-size: 0.85rem;
        flex-shrink: 0;
    }
    .news-content h6 {
        margin: 0 0 4px;
        font-size: 0.88rem;
        font-weight: 700;
        color: #2d3748;
        line-height: 1.3;
    }
    .news-content p {
        margin: 0 0 4px;
        font-size: 0.82rem;
        color: #4a5568;
        line-height: 1.45;
    }
    .news-date {
        font-size: 0.74rem;
        color: #a0aec0;
        font-weight: 500;
    }
    .btn-all {
        font-size: 0.78rem;
        padding: 4px 12px;
        border: 1px solid #cbd5e0;
        border-radius: 6px;
        color: #4a5568;
        text-decoration: none;
        white-space: nowrap;
        transition: background 0.15s;
    }
    .btn-all:hover { background: #f7fafc; color: #2d3748; }

    /* ── Shift schedule ── */
    .shift-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 10px 14px;
        border-radius: 8px;
        margin-bottom: 8px;
        background: #f8fafc;
        border-left: 4px solid #a0aec0;
    }
    .shift-item:last-child { margin-bottom: 0; }
    .shift-item.today  { border-left-color: #3182ce; background: #ebf8ff; }
    .shift-item.future { border-left-color: #38a169; }
    .shift-item.off    { border-left-color: #dd6b20; background: #fffaf0; }
    .shift-item.past   { opacity: 0.6; }
    .shift-day  { font-weight: 700; font-size: 0.85rem; color: #2d3748; }
    .shift-time { font-size: 0.82rem; color: #4a5568; display: flex; align-items: center; gap: 6px; }

    /* ── Responsive ── */
    @media (max-width: 991px) {
        .emp-layout { flex-direction: column; }
        .emp-content { padding: 20px; }
    }
</style>

<div class="emp-layout">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <!-- Main Content -->
    <div class="emp-content">

        <!-- Welcome Banner -->
        <div class="welcome-banner">
            <h2>Chào buổi sáng, ${sessionScope.currentUser != null ? sessionScope.currentUser.fullName : 'Nhân viên'}!</h2>
            <p>Chúc bạn một ca làm việc năng suất và an toàn. Kiểm tra các thông báo mới nhất bên dưới.</p>
        </div>

        <!-- Row 1: Clock + Stats -->
        <div class="row g-4 mb-4">
            <!-- Chấm công -->
            <div class="col-lg-5">
                <div class="emp-card">
                    <div class="emp-card-header">
                        <span class="emp-card-title">
                            <i class="fas fa-fingerprint text-primary"></i>
                            Chấm công Self-Service
                        </span>
                    </div>
                    <div class="clock-wrap">
                        <div class="clock-time" id="clockDisplay">00:00:00</div>
                        <div class="clock-date" id="dateDisplay">—</div>
                        <button class="btn-checkin">
                            <i class="fas fa-sign-in-alt me-2"></i>CHẤM CÔNG VÀO
                        </button>
                        <div class="clock-location">
                            <i class="fas fa-map-marker-alt text-success me-1"></i>
                            Đã kết nối định vị (Nhà máy Khu B)
                        </div>
                    </div>
                </div>
            </div>

            <!-- Thống kê cá nhân -->
            <div class="col-lg-7">
                <div class="emp-card">
                    <div class="emp-card-header">
                        <span class="emp-card-title">
                            <i class="fas fa-chart-pie text-success"></i>
                            Thống kê cá nhân (Tháng này)
                        </span>
                    </div>

                    <div class="stat-row">
                        <div class="stat-icon blue"><i class="fas fa-calendar-check"></i></div>
                        <div class="stat-content">
                            <h5>${not empty attendanceSummary ? attendanceSummary.presentCount : 0} ngày</h5>
                            <span>Ngày công thực tế (Tháng này)</span>
                        </div>
                    </div>

                    <div class="stat-row">
                        <div class="stat-icon orange"><i class="fas fa-business-time"></i></div>
                        <div class="stat-content">
                            <h5>${not empty attendanceSummary ? attendanceSummary.totalOvertimeHrs : 0.0}h</h5>
                            <span>Giờ tăng ca (OT)</span>
                        </div>
                    </div>

                    <div class="stat-row">
                        <div class="stat-icon green"><i class="fas fa-umbrella-beach"></i></div>
                        <div class="stat-content">
                            <h5>${remainingLeave} ngày</h5>
                            <span>Phép năm còn lại</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Row: Personal Requests & KPI -->
        <div class="row g-4 mb-4">
            <!-- Resignation Status -->
            <div class="col-md-4">
                <div class="emp-card h-100">
                    <div class="emp-card-header">
                        <span class="emp-card-title">
                            <i class="fas fa-user-minus text-danger"></i>
                            Đơn xin thôi việc
                        </span>
                    </div>
                    <div class="p-3" style="min-height: 140px;">
                        <c:choose>
                            <c:when test="${not empty latestResignation}">
                                <div class="mb-2">
                                    <span class="text-muted d-block small">Ngày gửi:</span>
                                    <strong><fmt:formatDate value="${latestResignation.createdAt}" pattern="dd/MM/yyyy HH:mm" /></strong>
                                </div>
                                <div class="mb-2">
                                    <span class="text-muted d-block small">Lý do:</span>
                                    <span class="text-truncate d-block" title="${latestResignation.reason}">${latestResignation.reason}</span>
                                </div>
                                <div>
                                    <span class="text-muted d-block small">Trạng thái:</span>
                                    <c:choose>
                                        <c:when test="${latestResignation.status == 'Approved'}">
                                            <span class="badge bg-success"><i class="fas fa-check-circle me-1"></i>Đã duyệt</span>
                                        </c:when>
                                        <c:when test="${latestResignation.status == 'Rejected'}">
                                            <span class="badge bg-danger"><i class="fas fa-times-circle me-1"></i>Từ chối</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning text-dark"><i class="fas fa-hourglass-half me-1"></i>Chờ duyệt</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4 text-muted">
                                    <i class="fas fa-check-circle fa-2x mb-2 text-success"></i>
                                    <p class="mb-0 small">Không có yêu cầu thôi việc nào</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Transfer Status -->
            <div class="col-md-4">
                <div class="emp-card h-100">
                    <div class="emp-card-header">
                        <span class="emp-card-title">
                            <i class="fas fa-exchange-alt text-primary"></i>
                            Yêu cầu điều chuyển
                        </span>
                    </div>
                    <div class="p-3" style="min-height: 140px;">
                        <c:choose>
                            <c:when test="${not empty latestTransfer}">
                                <div class="mb-2">
                                    <span class="text-muted d-block small">Ngày gửi:</span>
                                    <strong><fmt:formatDate value="${latestTransfer.createdAt}" pattern="dd/MM/yyyy HH:mm" /></strong>
                                </div>
                                <div class="mb-2">
                                    <span class="text-muted d-block small">Bộ phận mới:</span>
                                    <span>${latestTransfer.newDepartmentName}</span>
                                </div>
                                <div>
                                    <span class="text-muted d-block small">Trạng thái:</span>
                                    <c:choose>
                                        <c:when test="${latestTransfer.status == 'Approved'}">
                                            <span class="badge bg-success"><i class="fas fa-check-circle me-1"></i>Đã duyệt</span>
                                        </c:when>
                                        <c:when test="${latestTransfer.status == 'Rejected'}">
                                            <span class="badge bg-danger"><i class="fas fa-times-circle me-1"></i>Từ chối</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning text-dark"><i class="fas fa-hourglass-half me-1"></i>Chờ duyệt</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4 text-muted">
                                    <i class="fas fa-route fa-2x mb-2 text-primary"></i>
                                    <p class="mb-0 small">Không có yêu cầu điều chuyển nào</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- KPI score -->
            <div class="col-md-4">
                <div class="emp-card h-100">
                    <div class="emp-card-header">
                        <span class="emp-card-title">
                            <i class="fas fa-award text-warning"></i>
                            KPI & Hiệu suất mới nhất
                        </span>
                    </div>
                    <div class="p-3" style="min-height: 140px;">
                        <c:choose>
                            <c:when test="${not empty latestKpi}">
                                <div class="d-flex align-items-center mb-3">
                                    <div class="me-3 bg-warning-subtle text-warning p-2 rounded-circle text-center d-flex align-items-center justify-content-center" style="width: 48px; height: 48px; background: rgba(246, 173, 85, 0.2);">
                                        <i class="fas fa-star fa-lg"></i>
                                    </div>
                                    <div>
                                        <span class="text-muted d-block small">Điểm đánh giá:</span>
                                        <h4 class="mb-0 text-warning font-weight-bold" style="font-weight: 700;">${latestKpi.score} / 100</h4>
                                    </div>
                                </div>
                                <div class="mb-2">
                                    <span class="text-muted d-block small">Kỳ đánh giá:</span>
                                    <span>${latestKpi.cycleName}</span>
                                </div>
                                <div>
                                    <span class="text-muted d-block small">Nhận xét:</span>
                                    <span class="text-muted d-block text-truncate fst-italic" title="${latestKpi.comment}">${latestKpi.comment}</span>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4 text-muted">
                                    <i class="fas fa-award fa-2x mb-2 text-warning"></i>
                                    <p class="mb-0 small">Chưa có đánh giá KPI nào</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- Row 2: News + Schedule -->
        <div class="row g-4">
            <!-- Bảng tin -->
            <div class="col-lg-7">
                <div class="emp-card">
                    <div class="emp-card-header">
                        <span class="emp-card-title">
                            <i class="fas fa-bullhorn text-warning"></i>
                            Bảng tin & Thông báo nội bộ
                        </span>
                        <a href="#" class="btn-all">Xem tất cả</a>
                    </div>

                    <div class="news-item">
                        <div class="news-icon" style="background:#e53e3e;">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div class="news-content">
                            <h6>Nhắc nhở: Tuân thủ An toàn Lao động & Bảo hộ</h6>
                            <p>HSE yêu cầu toàn bộ CNVC khối Sản xuất mặc đầy đủ thiết bị bảo hộ khi vào xưởng lắp ráp.</p>
                            <span class="news-date"><i class="far fa-clock me-1"></i>Hôm qua, 15:30 · HSE Dept</span>
                        </div>
                    </div>

                    <div class="news-item">
                        <div class="news-icon" style="background:#3182ce;">
                            <i class="fas fa-gift"></i>
                        </div>
                        <div class="news-content">
                            <h6>Thông báo Chuyển lương & Thưởng KPI tháng trước</h6>
                            <p>Phòng Kế toán đã hoàn tất chuyển lương. Vui lòng kiểm tra "Phiếu lương" trong hệ thống.</p>
                            <span class="news-date"><i class="far fa-clock me-1"></i>12/05/2026 · Finance Dept</span>
                        </div>
                    </div>

                    <div class="news-item">
                        <div class="news-icon" style="background:#38a169;">
                            <i class="fas fa-users"></i>
                        </div>
                        <div class="news-content">
                            <h6>Khảo sát Môi trường làm việc Quý 2</h6>
                            <p>Đề nghị toàn bộ CBCNV dành 5 phút hoàn thành form khảo sát chất lượng bữa ăn ca.</p>
                            <span class="news-date"><i class="far fa-clock me-1"></i>10/05/2026 · HR Dept</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Lịch phân ca (Dynamic) -->
            <div class="col-lg-5">
                <div class="emp-card">
                    <div class="emp-card-header">
                        <span class="emp-card-title">
                            <i class="fas fa-calendar-alt text-info"></i>
                            Lịch Phân Ca (Tuần này)
                        </span>
                        <a href="${pageContext.request.contextPath}/employee/schedule" class="btn-all">Xem chi tiết</a>
                    </div>

                    <%@page import="java.time.LocalDate, java.time.LocalTime, java.time.format.DateTimeFormatter, model.ShiftAssignment, java.util.*"%>
                    <%
                        LocalDate[] wkDates = (LocalDate[]) request.getAttribute("weekDates");
                        LocalDate wkStart = (LocalDate) request.getAttribute("weekStart");
                        LocalDate todayDate = LocalDate.now();

                        @SuppressWarnings("unchecked")
                        List<ShiftAssignment> wkAssignments = (List<ShiftAssignment>) request.getAttribute("weekAssignments");

                        // Build a map: dayIndex -> ShiftAssignment
                        Map<Integer, ShiftAssignment> wkMap = new LinkedHashMap<>();
                        if (wkAssignments != null && wkStart != null) {
                            for (ShiftAssignment sa : wkAssignments) {
                                int dayIdx = (int) (sa.getAssignedDate().toEpochDay() - wkStart.toEpochDay());
                                if (dayIdx >= 0 && dayIdx < 7) wkMap.put(dayIdx, sa);
                            }
                        }

                        String[] dNames = {"Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ Nhật"};

                        if (wkDates != null) {
                            for (int d = 0; d < 7; d++) {
                                boolean isTdy = wkDates[d].equals(todayDate);
                                boolean isPst = wkDates[d].isBefore(todayDate);
                                ShiftAssignment sa = wkMap.get(d);

                                String itemClass = "shift-item";
                                if (isTdy) itemClass += " today";
                                else if (isPst) itemClass += " past";
                                else if (sa == null) itemClass += " off";
                                else itemClass += " future";

                                String dayLabel = dNames[d];
                                if (isTdy) dayLabel += " (Hôm nay)";
                    %>
                    <div class="<%= itemClass %>">
                        <span class="shift-day"><%= dayLabel %></span>
                        <% if (sa != null) {
                            String sn = sa.getShiftName() != null ? sa.getShiftName() : "Ca";
                            String badgeCss = "bg-secondary";
                            if (sn.contains("Sáng") || sn.contains("Ca 1")) badgeCss = "bg-warning text-dark";
                            else if (sn.contains("Chiều") || sn.contains("Ca 2")) badgeCss = "bg-primary";
                            else if (sn.contains("Đêm") || sn.contains("Ca 3") || sa.isNightShift()) badgeCss = "bg-success";
                            else if (sn.contains("Hành chính")) badgeCss = "bg-secondary";
                            String st = sa.getStartTime() != null ? sa.getStartTime().toString() : "--:--";
                            String et = sa.getEndTime() != null ? sa.getEndTime().toString() : "--:--";
                        %>
                        <span class="shift-time">
                            <span class="badge <%= badgeCss %>"><%= sn %></span><%= st %> – <%= et %>
                        </span>
                        <% } else { %>
                        <span class="shift-time text-muted">
                            <i class="fas fa-bed me-1"></i>Nghỉ
                        </span>
                        <% } %>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div class="shift-item off">
                        <span class="shift-day">Chưa có dữ liệu lịch ca</span>
                        <span class="shift-time text-muted"><i class="fas fa-info-circle me-1"></i>Liên hệ quản lý</span>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

    </div><!-- end .emp-content -->
</div><!-- end .emp-layout -->

<script>
    function updateClock() {
        const now = new Date();
        document.getElementById('clockDisplay').textContent =
            now.toLocaleTimeString('vi-VN', { hour12: false });
        document.getElementById('dateDisplay').textContent =
            now.toLocaleDateString('vi-VN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
    }
    setInterval(updateClock, 1000);
    updateClock();
</script>

<jsp:include page="../footer.jsp" />

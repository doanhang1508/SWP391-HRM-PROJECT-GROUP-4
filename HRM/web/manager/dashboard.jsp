<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:choose>
    <c:when test="${currentUser.roleId == 6}">
        <c:set var="pageTitle" value="Bảng Điều Khiển Trưởng Phòng" scope="request"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Bảng Điều Khiển Quản Lý" scope="request"/>
    </c:otherwise>
</c:choose>
<jsp:include page="../header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

<style>
footer, #chatWidget { display: none !important; }
body { background: #f0f4f8 !important; font-family: 'Inter', sans-serif !important; padding-top: 0 !important; min-height: 100vh; overflow-x: hidden; }

.dw { display: flex; min-height: calc(100vh - 64px); }
.dm { flex: 1; min-width: 0; background: #f0f4f8; }
.dc { padding: 28px 32px; display: flex; flex-direction: column; gap: 24px; }

/* ── Header ── */
.ph { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; }
.ph-left { display: flex; flex-direction: column; gap: 4px; }
.ph-bread { font-size: 0.78rem; color: #94a3b8; display: flex; align-items: center; gap: 6px; }
.ph-bread a { color: #0d9488; text-decoration: none; }
.ph-bread a:hover { text-decoration: underline; }
.ph-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; letter-spacing: -0.5px; }
.role-badge {
    display: inline-flex; align-items: center; gap: 7px;
    padding: 8px 18px; border-radius: 24px; font-size: 0.82rem; font-weight: 700;
    background: linear-gradient(135deg, #0d9488 0%, #0891b2 100%);
    color: #fff; box-shadow: 0 4px 14px rgba(13,148,136,0.35);
}

/* ── Stat Cards ── */
.stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(215px, 1fr)); gap: 18px; }
.stat-card {
    background: #fff; border-radius: 18px; padding: 22px 24px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06); border: 1px solid #e8edf2;
    display: flex; flex-direction: column; gap: 8px;
    transition: transform 0.22s, box-shadow 0.22s; position: relative; overflow: hidden;
}
.stat-card::before { content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; }
.stat-card.c-teal::before { background: #0d9488; }
.stat-card.c-blue::before { background: #3b82f6; }
.stat-card.c-orange::before { background: #f59e0b; }
.stat-card.c-red::before { background: #ef4444; }
.stat-card.c-purple::before { background: #8b5cf6; }
.stat-card.c-green::before { background: #10b981; }
.stat-card.c-indigo::before { background: #6366f1; }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 10px 28px rgba(0,0,0,0.1); }
.sc-head { display: flex; justify-content: space-between; align-items: flex-start; }
.sc-title { font-size: 0.71rem; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.7px; }
.sc-icon { width: 42px; height: 42px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.05rem; }
.c-teal .sc-icon   { background: #ccfbf1; color: #0d9488; }
.c-blue .sc-icon   { background: #dbeafe; color: #2563eb; }
.c-orange .sc-icon { background: #fef3c7; color: #d97706; }
.c-red .sc-icon    { background: #fee2e2; color: #dc2626; }
.c-purple .sc-icon { background: #ede9fe; color: #7c3aed; }
.c-green .sc-icon  { background: #d1fae5; color: #059669; }
.c-indigo .sc-icon { background: #e0e7ff; color: #4338ca; }
.sc-val { font-size: 2.2rem; font-weight: 900; color: #0f172a; line-height: 1.1; }
.sc-sub { font-size: 0.73rem; font-weight: 600; color: #94a3b8; display: flex; align-items: center; gap: 4px; }
.sc-sub.warn   { color: #d97706; }
.sc-sub.danger { color: #dc2626; }
.sc-sub.good   { color: #059669; }
.sc-link { margin-top: 4px; font-size: 0.75rem; font-weight: 600; color: #0d9488; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
.sc-link:hover { color: #0f766e; text-decoration: underline; }

/* ── Cards ── */
.card { background: #fff; border-radius: 18px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border: 1px solid #e8edf2; }
.card-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.card-title { font-size: 0.95rem; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 8px; }
.ct-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.d-teal { background: #0d9488; } .d-blue { background: #3b82f6; }
.d-orange { background: #f59e0b; } .d-purple { background: #8b5cf6; }
.d-red { background: #ef4444; } .d-green { background: #10b981; }

/* ── Charts ── */
.chart-row { display: grid; grid-template-columns: 1.6fr 1fr; gap: 20px; }
@media (max-width: 1100px) { .chart-row { grid-template-columns: 1fr; } }
.chart-row-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; }
@media (max-width: 1200px) { .chart-row-3 { grid-template-columns: 1fr 1fr; } }
@media (max-width: 768px) { .chart-row-3 { grid-template-columns: 1fr; } }
.chart-canvas-wrap { position: relative; height: 270px; }

/* ── Section divider (roleId=6 only) ── */
.section-sep {
    display: flex; align-items: center; gap: 14px;
}
.sep-title { font-size: 1rem; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px; white-space: nowrap; }
.sep-title i { color: #0d9488; }
.sep-line { flex: 1; height: 2px; background: linear-gradient(90deg, #0d9488 0%, transparent 100%); border-radius: 2px; }

/* ── Progress bar ── */
.kpi-bar-wrap { background: #e2e8f0; border-radius: 12px; height: 22px; overflow: hidden; margin: 14px 0 8px; }
.kpi-bar-fill {
    height: 100%; border-radius: 12px;
    background: linear-gradient(90deg, #0d9488, #06b6d4);
    display: flex; align-items: center; justify-content: center;
    font-size: 0.72rem; font-weight: 700; color: #fff;
    min-width: 36px; transition: width 0.7s ease;
}
.kpi-bar-stats { display: flex; justify-content: space-between; font-size: 0.8rem; color: #64748b; font-weight: 500; }
.kpi-bar-stats strong { color: #0f172a; }

/* ── Deadline badge ── */
.dl-badge { display: inline-flex; align-items: center; gap: 5px; padding: 3px 10px; border-radius: 10px; font-size: 0.72rem; font-weight: 700; }
.dl-safe    { background: #d1fae5; color: #059669; }
.dl-warn    { background: #fef3c7; color: #d97706; }
.dl-danger  { background: #fee2e2; color: #dc2626; }
.dl-overdue { background: #fecaca; color: #991b1b; }

/* ── Table ── */
.dt-wrap { width: 100%; overflow-x: auto; }
.dt { width: 100%; border-collapse: collapse; }
.dt th { padding: 11px 16px; border-bottom: 1px solid #e8edf2; color: #64748b; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.7px; background: #f8fafc; }
.dt td { padding: 14px 16px; border-bottom: 1px solid #f1f5f9; color: #1e293b; font-size: 0.875rem; vertical-align: middle; }
.dt tbody tr:last-child td { border-bottom: none; }
.dt tbody tr:hover td { background: #fafcff; }
.emp-cell { display: flex; align-items: center; gap: 10px; }
.emp-av { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.82rem; flex-shrink: 0; }
.av-teal   { background: #ccfbf1; color: #0d9488; }
.av-blue   { background: #dbeafe; color: #2563eb; }
.av-orange { background: #fef3c7; color: #d97706; }
.av-purple { background: #ede9fe; color: #7c3aed; }
.av-red    { background: #fee2e2; color: #dc2626; }

.badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 20px; font-size: 0.71rem; font-weight: 700; }
.b-pending  { background: #fef3c7; color: #d97706; }
.b-approved { background: #d1fae5; color: #059669; }
.b-rejected { background: #fee2e2; color: #dc2626; }
.b-draft    { background: #f1f5f9; color: #475569; }
.b-submitted { background: #dbeafe; color: #2563eb; }

.btn { padding: 6px 14px; font-size: 0.78rem; font-weight: 700; border-radius: 9px; border: none; cursor: pointer; text-decoration: none; display: inline-block; transition: all 0.18s; }
.btn-primary { background: #0d9488; color: #fff; }
.btn-primary:hover { background: #0f766e; color: #fff; }
.btn-ghost { background: #f1f5f9; color: #475569; }
.btn-ghost:hover { background: #e2e8f0; }

.empty-state { text-align: center; padding: 36px; color: #94a3b8; }
.empty-state i { font-size: 2rem; margin-bottom: 8px; display: block; opacity: 0.4; }

@media (max-width: 768px) { .dc { padding: 18px 14px; } }
</style>

<div class="dw">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <div class="dm">
        <div class="dc">

            <%-- ── PAGE HEADER ── --%>
            <div class="ph">
                <div class="ph-left">
                    <div class="ph-bread">
                        <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                        <span>/</span><span>Dashboard</span>
                    </div>
                    <div class="ph-title">Tổng Quan Hoạt Động</div>
                </div>
                <div class="role-badge">
                    <c:choose>
                        <c:when test="${currentUser.roleId == 6}"><i class="fas fa-user-shield"></i> Trưởng Phòng</c:when>
                        <c:otherwise><i class="fas fa-briefcase"></i> Quản lý</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <%-- ══════════════════════════════════════════════════════════════════ --%>
            <%-- Phần CHUNG: Stat cards + Charts — hiển thị cho CẢ HAI role (3+6) --%>
            <%-- ══════════════════════════════════════════════════════════════════ --%>
            <div class="stat-grid">
                <div class="stat-card c-teal">
                    <div class="sc-head"><span class="sc-title">Nhân Sự Quản Lý</span><div class="sc-icon"><i class="fas fa-users-cog"></i></div></div>
                    <div class="sc-val">${not empty totalEmployees ? totalEmployees : '0'}</div>
                    <div class="sc-sub good"><i class="fas fa-users"></i> Nhân viên trong phòng</div>
                </div>
                <div class="stat-card c-green">
                    <div class="sc-head"><span class="sc-title">Chấm Công Hôm Nay</span><div class="sc-icon"><i class="fas fa-user-clock"></i></div></div>
                    <div class="sc-val">${not empty todayAttendance ? todayAttendance : '0'}</div>
                    <div class="sc-sub <c:choose><c:when test='${todayAttendance < totalEmployees}'>warn</c:when><c:otherwise>good</c:otherwise></c:choose>">
                        <i class="fas fa-clock"></i> Đã điểm danh hôm nay
                    </div>
                </div>
                <div class="stat-card c-orange">
                    <div class="sc-head"><span class="sc-title">Yêu Cầu OT</span><div class="sc-icon"><i class="fas fa-business-time"></i></div></div>
                    <div class="sc-val">${not empty pendingOT ? pendingOT : '0'}</div>
                    <div class="sc-sub <c:if test='${pendingOT > 0}'>warn</c:if>"><i class="fas fa-clock"></i> Chờ phê duyệt OT</div>
                </div>
                <div class="stat-card c-red">
                    <div class="sc-head"><span class="sc-title">Đơn Xin Nghỉ</span><div class="sc-icon"><i class="fas fa-calendar-times"></i></div></div>
                    <div class="sc-val">${not empty pendingLeaves ? pendingLeaves : '0'}</div>
                    <div class="sc-sub <c:if test='${pendingLeaves > 0}'>warn</c:if>"><i class="fas fa-hourglass-half"></i> Chờ phê duyệt</div>
                </div>
            </div>

            <%-- Charts chung --%>
            <div class="chart-row">
                <div class="card">
                    <div class="card-head"><h3 class="card-title"><span class="ct-dot d-teal"></span>Tỷ Lệ Điểm Danh 7 Ngày Qua</h3></div>
                    <div class="chart-canvas-wrap"><canvas id="performanceChart"></canvas></div>
                </div>
                <div class="card">
                    <div class="card-head"><h3 class="card-title"><span class="ct-dot d-blue"></span>Phân Bổ Ca Hôm Nay</h3></div>
                    <div class="chart-canvas-wrap"><canvas id="shiftChart"></canvas></div>
                </div>
            </div>

            <%-- ══════════════════════════════════════════════════════════════════════ --%>
            <%-- TuVV: DEPARTMENT MANAGER (roleId == 6) ONLY — Điều chuyển + KPI --%>
            <%-- KHÔNG được render cho roleId == 3 (Factory Manager / KhoaNV) ════════ --%>
            <%-- ══════════════════════════════════════════════════════════════════════ --%>
            <c:if test="${currentUser.roleId == 6}">

            <%-- Section separator --%>
            <div class="section-sep">
                <div class="sep-title"><i class="fas fa-tasks"></i> Công Việc Cần Xử Lý — Trưởng Phòng</div>
                <div class="sep-line"></div>
            </div>

            <%-- ── Stat cards nghiệp vụ Trưởng Phòng ── --%>
            <div class="stat-grid">
                <div class="stat-card c-purple">
                    <div class="sc-head"><span class="sc-title">Điều Chuyển Chờ Duyệt</span><div class="sc-icon"><i class="fas fa-exchange-alt"></i></div></div>
                    <div class="sc-val">${not empty pendingTransferCount ? pendingTransferCount : '0'}</div>
                    <div class="sc-sub <c:if test='${pendingTransferCount > 0}'>warn</c:if>">
                        <i class="fas fa-user-check"></i> NV đã xác nhận, chờ TP duyệt
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals" class="sc-link"><i class="fas fa-arrow-right"></i> Duyệt ngay</a>
                </div>
                <div class="stat-card c-blue">
                    <div class="sc-head"><span class="sc-title">Điều Chuyển Sắp Hiệu Lực</span><div class="sc-icon"><i class="fas fa-calendar-check"></i></div></div>
                    <div class="sc-val">${not empty upcomingTransferCount ? upcomingTransferCount : '0'}</div>
                    <div class="sc-sub"><i class="fas fa-clock"></i> Trong 7 ngày tới</div>
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals" class="sc-link"><i class="fas fa-arrow-right"></i> Xem chi tiết</a>
                </div>
                <div class="stat-card <c:choose><c:when test='${activeKpiCycle == null}'>c-teal</c:when><c:when test='${kpiDaysLeft < 0 || kpiDaysLeft <= 2}'>c-red</c:when><c:when test='${kpiDaysLeft <= 7}'>c-orange</c:when><c:otherwise>c-green</c:otherwise></c:choose>">
                    <div class="sc-head"><span class="sc-title">Hạn Đánh Giá KPI</span><div class="sc-icon"><i class="fas fa-chart-line"></i></div></div>
                    <c:choose>
                        <c:when test="${activeKpiCycle != null}">
                            <div class="sc-val" style="font-size:1.6rem;"><fmt:formatDate value="${activeKpiCycle.deadline}" pattern="dd/MM/yy"/></div>
                            <div class="sc-sub <c:choose><c:when test='${kpiDaysLeft < 0}'>danger</c:when><c:when test='${kpiDaysLeft <= 7}'>warn</c:when><c:otherwise>good</c:otherwise></c:choose>">
                                <c:choose>
                                    <c:when test="${kpiDaysLeft < 0}"><i class="fas fa-exclamation-circle"></i> Quá hạn ${-kpiDaysLeft} ngày!</c:when>
                                    <c:when test="${kpiDaysLeft == 0}"><i class="fas fa-bell"></i> Hôm nay là hạn cuối!</c:when>
                                    <c:otherwise><i class="fas fa-hourglass-half"></i> Còn ${kpiDaysLeft} ngày</c:otherwise>
                                </c:choose>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="sc-val" style="font-size:1.1rem; margin-top:4px;">—</div>
                            <div class="sc-sub">Chưa có kỳ KPI mở</div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="stat-card c-orange">
                    <div class="sc-head"><span class="sc-title">KPI Chưa Đánh Giá</span><div class="sc-icon"><i class="fas fa-clipboard-list"></i></div></div>
                    <c:choose>
                        <c:when test="${activeKpiCycle != null && kpiTotalCount > 0}">
                            <div class="sc-val">${kpiPendingCount}<span style="font-size:1rem; color:#94a3b8; font-weight:500;">/${kpiTotalCount}</span></div>
                            <div class="sc-sub <c:if test='${kpiPendingCount > 0}'>warn</c:if>">
                                <c:choose>
                                    <c:when test="${kpiPendingCount == 0}"><i class="fas fa-check-double"></i> Đã hoàn thành tất cả</c:when>
                                    <c:otherwise><i class="fas fa-user-clock"></i> Nhân viên chưa được đánh giá</c:otherwise>
                                </c:choose>
                            </div>
                            <a href="${pageContext.request.contextPath}/manager/kpi-approvals" class="sc-link"><i class="fas fa-arrow-right"></i> Đánh giá KPI</a>
                        </c:when>
                        <c:otherwise>
                            <div class="sc-val" style="font-size:1.1rem; margin-top:4px;">—</div>
                            <div class="sc-sub">Chưa có dữ liệu KPI</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <%-- ── Charts nghiệp vụ Trưởng Phòng: KPI Donut + Attendance vs Target ── --%>
            <div class="chart-row-3">
                <%-- Donut: KPI hoàn thành vs chưa --%>
                <div class="card">
                    <div class="card-head">
                        <h3 class="card-title"><span class="ct-dot d-green"></span>Tiến Độ KPI</h3>
                        <c:if test="${activeKpiCycle != null}">
                            <span class="dl-badge <c:choose><c:when test='${kpiDaysLeft < 0}'>dl-overdue</c:when><c:when test='${kpiDaysLeft <= 2}'>dl-danger</c:when><c:when test='${kpiDaysLeft <= 7}'>dl-warn</c:when><c:otherwise>dl-safe</c:otherwise></c:choose>">
                                <i class="fas fa-calendar-alt"></i> ${activeKpiCycle.name}
                            </span>
                        </c:if>
                    </div>
                    <div class="chart-canvas-wrap"><canvas id="kpiDonutChart"></canvas></div>
                    <c:if test="${kpiTotalCount > 0}">
                    <div class="kpi-bar-wrap" style="margin-top:12px;">
                        <div class="kpi-bar-fill" style="width: ${kpiProgressPercent}%;">${kpiProgressPercent}%</div>
                    </div>
                    <div class="kpi-bar-stats">
                        <span><strong>${kpiCompletedCount}</strong>/${kpiTotalCount} đã xong</span>
                        <span>Còn <strong>${kpiPendingCount}</strong> chưa đánh giá</span>
                    </div>
                    </c:if>
                </div>

                <%-- Bar: Điều chuyển - Hiện tại vs Sắp hiệu lực --%>
                <div class="card">
                    <div class="card-head">
                        <h3 class="card-title"><span class="ct-dot d-purple"></span>Điều Chuyển Nhân Sự</h3>
                        <a href="${pageContext.request.contextPath}/manager/transfer-approvals" class="btn btn-ghost">Chi tiết</a>
                    </div>
                    <div class="chart-canvas-wrap"><canvas id="transferBarChart"></canvas></div>
                </div>

                <%-- Mini stat: tỷ lệ có mặt hôm nay --%>
                <div class="card">
                    <div class="card-head">
                        <h3 class="card-title"><span class="ct-dot d-teal"></span>Tỷ Lệ Có Mặt Hôm Nay</h3>
                    </div>
                    <div class="chart-canvas-wrap"><canvas id="attendanceTodayChart"></canvas></div>
                    <div class="kpi-bar-stats" style="margin-top:12px;">
                        <span>Có mặt: <strong>${todayAttendance}</strong></span>
                        <span>Vắng: <strong>${totalEmployees - todayAttendance < 0 ? 0 : totalEmployees - todayAttendance}</strong></span>
                    </div>
                </div>
            </div>

            <%-- ── Bảng 1: Điều chuyển chờ duyệt ── --%>
            <div class="card">
                <div class="card-head">
                    <h3 class="card-title"><span class="ct-dot d-purple"></span>Điều Chuyển Chờ Phê Duyệt</h3>
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals" class="btn btn-ghost">Xem tất cả</a>
                </div>
                <div class="dt-wrap">
                    <table class="dt">
                        <thead>
                            <tr>
                                <th>Nhân Viên</th>
                                <th>Phòng Ban Cũ</th>
                                <th>Phòng Ban Mới</th>
                                <th>Ngày Hiệu Lực</th>
                                <th>Trạng Thái</th>
                                <th>Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty pendingTransferList}">
                                    <c:forEach items="${pendingTransferList}" var="tr">
                                        <tr>
                                            <td>
                                                <div class="emp-cell">
                                                    <div class="emp-av av-purple">${fn:substring(tr.employeeName, 0, 1)}</div>
                                                    <span style="font-weight:600;">${tr.employeeName}</span>
                                                </div>
                                            </td>
                                            <td style="color:#64748b;">${not empty tr.oldDepartmentName ? tr.oldDepartmentName : '—'}</td>
                                            <td style="color:#0d9488; font-weight:600;">${not empty tr.newDepartmentName ? tr.newDepartmentName : '—'}</td>
                                            <td><fmt:formatDate value="${tr.effectiveDate}" pattern="dd/MM/yyyy"/></td>
                                            <td><span class="badge b-pending"><i class="fas fa-clock"></i> Chờ TP duyệt</span></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/manager/transfer-approval-detail?id=${tr.transferRequestId}" class="btn btn-primary">Duyệt</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr><td colspan="6" class="empty-state"><i class="fas fa-check-double"></i>Không có điều chuyển nào đang chờ duyệt</td></tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <%-- ── Bảng 2: KPI nhân viên chưa đánh giá ── --%>
            <div class="card">
                <div class="card-head">
                    <h3 class="card-title"><span class="ct-dot d-orange"></span>Nhân Viên Cần Đánh Giá KPI</h3>
                    <c:if test="${activeKpiCycle != null}">
                        <a href="${pageContext.request.contextPath}/manager/kpi-approvals?cycleId=${activeKpiCycle.cycleId}" class="btn btn-ghost">Xem tất cả</a>
                    </c:if>
                </div>
                <div class="dt-wrap">
                    <table class="dt">
                        <thead>
                            <tr>
                                <th>Nhân Viên</th>
                                <th>Phòng Ban</th>
                                <th>Chu Kỳ KPI</th>
                                <th>Trạng Thái</th>
                                <th>Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty pendingKpiEvaluations}">
                                    <c:forEach items="${pendingKpiEvaluations}" var="ev">
                                        <tr>
                                            <td>
                                                <div class="emp-cell">
                                                    <div class="emp-av av-orange">${fn:substring(ev.employeeName, 0, 1)}</div>
                                                    <span style="font-weight:600;">${ev.employeeName}</span>
                                                </div>
                                            </td>
                                            <td style="color:#64748b;">${not empty ev.departmentName ? ev.departmentName : '—'}</td>
                                            <td style="color:#64748b;">${ev.cycleName}</td>
                                            <td><span class="badge b-draft"><i class="fas fa-edit"></i> Chưa đánh giá</span></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/manager/kpi-approvals?cycleId=${ev.cycleId}&viewId=${ev.evaluationId}" class="btn btn-primary">Đánh giá</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" class="empty-state">
                                            <i class="fas fa-check-double"></i>
                                            <c:choose>
                                                <c:when test="${activeKpiCycle == null}">Chưa có kỳ KPI đang mở</c:when>
                                                <c:otherwise>Đã đánh giá xong tất cả nhân viên!</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            </c:if><%-- end roleId == 6 --%>

        </div><%-- end dc --%>
    </div><%-- end dm --%>
</div><%-- end dw --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    const baseFont = { family: "'Inter', sans-serif", size: 12 };
    Chart.defaults.font = baseFont;

    // ── Biểu đồ CHUNG (render cho cả role 3 và 6) ──
    const perfLabels = [<c:forEach var="l" items="${perfLabels}" varStatus="s">'${l}'${!s.last ? ',' : ''}</c:forEach>];
    const perfTarget = [<c:forEach var="t" items="${perfTarget}" varStatus="s">${t}${!s.last ? ',' : ''}</c:forEach>];
    const perfActual = [<c:forEach var="a" items="${perfActual}" varStatus="s">${a}${!s.last ? ',' : ''}</c:forEach>];
    const shiftLabels = [<c:forEach var="l" items="${shiftLabels}" varStatus="s">'${l}'${!s.last ? ',' : ''}</c:forEach>];
    const shiftData   = [<c:forEach var="v" items="${shiftData}"   varStatus="s">${v}${!s.last ? ',' : ''}</c:forEach>];

    // Performance chart (bar grouped)
    new Chart(document.getElementById('performanceChart'), {
        type: 'bar',
        data: {
            labels: perfLabels,
            datasets: [
                { label: 'Tổng NS', data: perfTarget, backgroundColor: 'rgba(148,163,184,0.25)', borderRadius: 5 },
                { label: 'Có mặt', data: perfActual, backgroundColor: '#0d9488', borderRadius: 5 }
            ]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { position: 'top', labels: { boxWidth: 10, font: baseFont } } },
            scales: {
                y: { beginAtZero: true, ticks: { precision: 0, color: '#94a3b8', font: baseFont }, grid: { color: 'rgba(0,0,0,0.04)' } },
                x: { ticks: { color: '#475569', font: baseFont }, grid: { display: false } }
            }
        }
    });

    // Shift pie chart
    new Chart(document.getElementById('shiftChart'), {
        type: 'pie',
        data: {
            labels: shiftLabels,
            datasets: [{ data: shiftData,
                backgroundColor: ['#10b981','#f59e0b','#6366f1','#dd6b20','#3b82f6','#ec4899','#6b7280'],
                borderWidth: 2, borderColor: '#fff' }]
        },
        options: { responsive: true, maintainAspectRatio: false,
            plugins: { legend: { position: 'right', labels: { boxWidth: 12, font: baseFont } } } }
    });
</script>

<%-- ── Charts chỉ cho Department Manager (roleId == 6) ── --%>
<c:if test="${currentUser.roleId == 6}">
<script>
(function() {
    const baseFont = { family: "'Inter', sans-serif", size: 12 };

    // ── KPI Donut Chart ──
    const kpiCompleted = ${kpiCompletedCount};
    const kpiPending   = ${kpiPendingCount};
    const kpiTotal     = ${kpiTotalCount};
    new Chart(document.getElementById('kpiDonutChart'), {
        type: 'doughnut',
        data: {
            labels: ['Đã đánh giá', 'Chưa đánh giá'],
            datasets: [{
                data: kpiTotal > 0 ? [kpiCompleted, kpiPending] : [0, 1],
                backgroundColor: kpiTotal > 0 ? ['#10b981', '#e2e8f0'] : ['#e2e8f0', '#e2e8f0'],
                borderWidth: 4, borderColor: '#fff', hoverOffset: 6
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false, cutout: '68%',
            plugins: {
                legend: { position: 'bottom', labels: { boxWidth: 10, font: baseFont } },
                tooltip: {
                    callbacks: {
                        label: ctx => ' ' + ctx.label + ': ' + ctx.parsed + ' người'
                    }
                }
            }
        }
    });

    // ── Transfer Bar Chart ──
    new Chart(document.getElementById('transferBarChart'), {
        type: 'bar',
        data: {
            labels: ['Chờ TP duyệt', 'Sắp hiệu lực (7N)'],
            datasets: [{
                label: 'Điều chuyển',
                data: [${pendingTransferCount}, ${upcomingTransferCount}],
                backgroundColor: ['#8b5cf6', '#3b82f6'],
                borderRadius: 10, borderSkipped: false
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false, indexAxis: 'y',
            plugins: { legend: { display: false },
                tooltip: { callbacks: { label: ctx => ' ' + ctx.parsed.x + ' đơn' } } },
            scales: {
                x: { beginAtZero: true, ticks: { precision: 0, color: '#94a3b8', font: baseFont }, grid: { color: 'rgba(0,0,0,0.04)' } },
                y: { ticks: { color: '#475569', font: { ...baseFont, weight: '600' } }, grid: { display: false } }
            }
        }
    });

    // ── Attendance Today Donut ──
    const atPresent = ${not empty todayAttendance ? todayAttendance : 0};
    const atTotal   = ${not empty totalEmployees ? totalEmployees : 0};
    const atAbsent  = Math.max(0, atTotal - atPresent);
    new Chart(document.getElementById('attendanceTodayChart'), {
        type: 'doughnut',
        data: {
            labels: ['Có mặt', 'Vắng'],
            datasets: [{
                data: atTotal > 0 ? [atPresent, atAbsent] : [0, 1],
                backgroundColor: atTotal > 0 ? ['#0d9488', '#fee2e2'] : ['#e2e8f0', '#e2e8f0'],
                borderWidth: 4, borderColor: '#fff', hoverOffset: 6
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false, cutout: '68%',
            plugins: {
                legend: { position: 'bottom', labels: { boxWidth: 10, font: baseFont } },
                tooltip: { callbacks: { label: ctx => ' ' + ctx.label + ': ' + ctx.parsed + ' người' } }
            }
        }
    });
})();
</script>
</c:if>

<jsp:include page="../footer.jsp" />

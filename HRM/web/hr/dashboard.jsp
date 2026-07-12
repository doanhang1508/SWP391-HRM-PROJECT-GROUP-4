<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:choose>
    <c:when test="${currentUser.roleId == 5}">
        <c:set var="pageTitle" value="Bảng Điều Khiển HR Staff" scope="request"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Bảng Điều Khiển HR Manager" scope="request"/>
    </c:otherwise>
</c:choose>
<jsp:include page="../header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

<style>
footer, #chatWidget { display: none !important; }
body { background: #f0f4f8 !important; font-family: 'Inter', sans-serif !important; padding-top: 0 !important; min-height: 100vh; overflow-x: hidden; }

/* ── Layout ── */
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
    letter-spacing: 0.3px;
}

/* ── Stat Cards ── */
.stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(215px, 1fr)); gap: 18px; }
.stat-card {
    background: #fff; border-radius: 18px; padding: 22px 24px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06); border: 1px solid #e8edf2;
    display: flex; flex-direction: column; gap: 8px;
    transition: transform 0.22s, box-shadow 0.22s; position: relative; overflow: hidden;
}
.stat-card::before {
    content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%;
}
.stat-card.c-teal::before { background: #0d9488; }
.stat-card.c-blue::before { background: #3b82f6; }
.stat-card.c-orange::before { background: #f59e0b; }
.stat-card.c-red::before { background: #ef4444; }
.stat-card.c-purple::before { background: #8b5cf6; }
.stat-card.c-green::before { background: #10b981; }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 10px 28px rgba(0,0,0,0.1); }
.sc-head { display: flex; justify-content: space-between; align-items: flex-start; }
.sc-title { font-size: 0.71rem; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.7px; }
.sc-icon { width: 42px; height: 42px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.05rem; }
.c-teal .sc-icon { background: #ccfbf1; color: #0d9488; }
.c-blue .sc-icon  { background: #dbeafe; color: #2563eb; }
.c-orange .sc-icon{ background: #fef3c7; color: #d97706; }
.c-red .sc-icon   { background: #fee2e2; color: #dc2626; }
.c-purple .sc-icon{ background: #ede9fe; color: #7c3aed; }
.c-green .sc-icon { background: #d1fae5; color: #059669; }
.sc-val { font-size: 2.2rem; font-weight: 900; color: #0f172a; line-height: 1.1; }
.sc-sub { font-size: 0.73rem; font-weight: 600; color: #94a3b8; display: flex; align-items: center; gap: 4px; }
.sc-sub.warn { color: #d97706; }
.sc-sub.danger { color: #dc2626; }
.sc-sub.good { color: #059669; }
.sc-link { margin-top: 4px; font-size: 0.75rem; font-weight: 600; color: #0d9488; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
.sc-link:hover { color: #0f766e; text-decoration: underline; }

/* ── Cards ── */
.card {
    background: #fff; border-radius: 18px; padding: 24px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06); border: 1px solid #e8edf2;
}
.card-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.card-title { font-size: 0.95rem; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 8px; }
.ct-dot { width: 8px; height: 8px; border-radius: 50%; }
.d-teal { background: #0d9488; } .d-blue { background: #3b82f6; } .d-orange { background: #f59e0b; } .d-purple { background: #8b5cf6; }

/* ── Two-col chart layout ── */
.chart-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
@media (max-width: 1024px) { .chart-row { grid-template-columns: 1fr; } }
.chart-canvas-wrap { position: relative; height: 280px; }

/* ── Table ── */
.dt-wrap { width: 100%; overflow-x: auto; }
.dt { width: 100%; border-collapse: collapse; }
.dt th { padding: 11px 16px; border-bottom: 1px solid #e8edf2; color: #64748b; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.7px; background: #f8fafc; }
.dt td { padding: 14px 16px; border-bottom: 1px solid #f1f5f9; color: #1e293b; font-size: 0.875rem; vertical-align: middle; }
.dt tbody tr:last-child td { border-bottom: none; }
.dt tbody tr:hover td { background: #fafcff; }
.emp-cell { display: flex; align-items: center; gap: 10px; }
.emp-av { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.82rem; flex-shrink: 0; }
.av-teal { background: #ccfbf1; color: #0d9488; }
.av-blue { background: #dbeafe; color: #2563eb; }
.av-orange { background: #fef3c7; color: #d97706; }
.av-red   { background: #fee2e2; color: #dc2626; }
.av-purple { background: #ede9fe; color: #7c3aed; }

.badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 20px; font-size: 0.71rem; font-weight: 700; }
.b-active   { background: #d1fae5; color: #059669; }
.b-pending  { background: #fef3c7; color: #d97706; }
.b-expiring { background: #fee2e2; color: #dc2626; }
.b-expired  { background: #f1f5f9; color: #64748b; }
.b-draft    { background: #f1f5f9; color: #475569; }
.b-approved { background: #d1fae5; color: #059669; }
.b-rejected { background: #fee2e2; color: #dc2626; }
.b-signed   { background: #dbeafe; color: #2563eb; }

.btn { padding: 6px 14px; font-size: 0.78rem; font-weight: 700; border-radius: 9px; border: none; cursor: pointer; text-decoration: none; display: inline-block; transition: all 0.18s; }
.btn-primary { background: #0d9488; color: #fff; }
.btn-primary:hover { background: #0f766e; color: #fff; }
.btn-ghost { background: #f1f5f9; color: #475569; }
.btn-ghost:hover { background: #e2e8f0; }

/* ── Empty state ── */
.empty-state { text-align: center; padding: 36px; color: #94a3b8; }
.empty-state i { font-size: 2rem; margin-bottom: 8px; display: block; opacity: 0.4; }

/* ── Contract expiry countdown ── */
.days-tag { display: inline-flex; align-items: center; gap: 3px; padding: 3px 9px; border-radius: 8px; font-size: 0.72rem; font-weight: 700; }
.days-crit { background: #fee2e2; color: #dc2626; }
.days-warn { background: #fef3c7; color: #d97706; }
.days-ok   { background: #f1f5f9; color: #64748b; }

/* ── Responsive ── */
@media (max-width: 768px) { .dc { padding: 18px 14px; } .stat-grid { grid-template-columns: 1fr 1fr; } }
@media (max-width: 480px) { .stat-grid { grid-template-columns: 1fr; } }
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
                    <div class="ph-title">
                        <c:choose>
                            <c:when test="${currentUser.roleId == 5}">Bảng Điều Khiển HR Staff</c:when>
                            <c:otherwise>Tổng Quan Nhân Sự</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="role-badge">
                    <c:choose>
                        <c:when test="${currentUser.roleId == 5}"><i class="fas fa-user-edit"></i> HR Staff</c:when>
                        <c:otherwise><i class="fas fa-user-tie"></i> HR Manager</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <%-- ══════════════════════════════════════════════════════ --%>
            <%-- HR MANAGER (roleId == 2):--%>
            <%-- ══════════════════════════════════════════════════════ --%>
            <c:if test="${currentUser.roleId == 2}">
            <div class="stat-grid">
                <div class="stat-card c-teal">
                    <div class="sc-head"><span class="sc-title">Tổng Nhân Viên</span><div class="sc-icon"><i class="fas fa-users"></i></div></div>
                    <div class="sc-val">${not empty totalEmployees ? totalEmployees : '—'}</div>
                    <div class="sc-sub good"><i class="fas fa-user-check"></i> Đang làm việc</div>
                </div>
                <div class="stat-card c-green">
                    <div class="sc-head"><span class="sc-title">Phòng Ban</span><div class="sc-icon"><i class="fas fa-building"></i></div></div>
                    <div class="sc-val">${not empty totalDepartments ? totalDepartments : '—'}</div>
                    <div class="sc-sub">Đang hoạt động</div>
                </div>
                <div class="stat-card c-orange" onclick="window.location.href='${pageContext.request.contextPath}/hr/transfers'" style="cursor:pointer;">
                    <div class="sc-head"><span class="sc-title">Đơn Điều Chuyển</span><div class="sc-icon"><i class="fas fa-exchange-alt"></i></div></div>
                    <div class="sc-val">${pendingTransfers != null ? pendingTransfers : 0}</div>
                    <div class="sc-sub warn">Chờ duyệt</div>
                </div>
                <div class="stat-card c-red" onclick="window.location.href='${pageContext.request.contextPath}/hr/resignations'" style="cursor:pointer;">
                    <div class="sc-head"><span class="sc-title">Đơn Nghỉ Việc</span><div class="sc-icon"><i class="fas fa-sign-out-alt"></i></div></div>
                    <div class="sc-val">${pendingResignations != null ? pendingResignations : 0}</div>
                    <div class="sc-sub danger">Chờ duyệt</div>
                </div>
                <div class="stat-card c-blue" onclick="window.location.href='${pageContext.request.contextPath}/hr/payroll'" style="cursor:pointer;">
                    <div class="sc-head"><span class="sc-title">Quản Lý Bảng Lương</span><div class="sc-icon"><i class="fas fa-file-invoice-dollar"></i></div></div>
                    <div class="sc-val" style="font-size:1.1rem; padding-top:4px;">Bảng Lương</div>
                    <div class="sc-sub">Click để quản lý</div>
                </div>
            </div>
            <div class="chart-row">
                <div class="card">
                    <div class="card-head"><h3 class="card-title"><span class="ct-dot d-teal"></span>Nhân Viên Theo Phòng Ban</h3></div>
                    <div class="chart-canvas-wrap"><canvas id="departmentChart"></canvas></div>
                </div>
                <div class="card">
                    <div class="card-head"><h3 class="card-title"><span class="ct-dot d-blue"></span>Cơ Cấu Giới Tính</h3></div>
                    <div class="chart-canvas-wrap"><canvas id="genderChart"></canvas></div>
                </div>
            </div>
            <div class="card">
                <div class="card-head">
                    <h3 class="card-title"><span class="ct-dot d-orange"></span>Nhân Viên Mới Nhất</h3>
                    <a href="${pageContext.request.contextPath}/hr/employees" class="btn btn-ghost">Xem tất cả</a>
                </div>
                <div class="dt-wrap">
                    <table class="dt">
                        <thead><tr><th>Họ Tên</th><th>Email</th><th>Chi Tiết</th></tr></thead>
                        <tbody>
                            <c:forEach items="${recentEmployees}" var="emp">
                            <tr>
                                <td><div class="emp-cell"><div class="emp-av av-teal">${fn:substring(emp.fullName,0,1)}</div><span style="font-weight:600;">${emp.fullName}</span></div></td>
                                <td style="color:#64748b;">${emp.email}</td>
                                <td><a href="${pageContext.request.contextPath}/hr/employee-detail?userId=${emp.userId}" class="btn btn-primary">Xem</a></td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            </c:if><%-- end roleId == 2 --%>

            <%-- ════════════════════════════════════════════════════════════════ --%>
            <%-- TuVV: HR STAFF (roleId == 5) — Dashboard vận hành với biểu đồ --%>
            <%-- ════════════════════════════════════════════════════════════════ --%>
            <c:if test="${currentUser.roleId == 5}">

            <%-- ── STAT CARDS ROW 1: Hợp đồng + Onboarding ── --%>
            <div class="stat-grid">
                <div class="stat-card c-orange">
                    <div class="sc-head"><span class="sc-title">HĐ Sắp Hết Hạn</span><div class="sc-icon"><i class="fas fa-file-contract"></i></div></div>
                    <div class="sc-val">${expiringContractCount}</div>
                    <div class="sc-sub <c:if test='${expiringContractCount > 0}'>warn</c:if>"><i class="fas fa-clock"></i> Trong 30 ngày tới</div>
                    <a href="${pageContext.request.contextPath}/hr/contracts?status=expiring" class="sc-link"><i class="fas fa-arrow-right"></i> Xem danh sách</a>
                </div>
                <div class="stat-card c-blue">
                    <div class="sc-head"><span class="sc-title">Chờ Nhân Viên Ký</span><div class="sc-icon"><i class="fas fa-pen-nib"></i></div></div>
                    <div class="sc-val">${pendingSignatureCount}</div>
                    <div class="sc-sub <c:if test='${pendingSignatureCount > 0}'>warn</c:if>"><i class="fas fa-hourglass-half"></i> Hợp đồng chờ xác nhận</div>
                    <a href="${pageContext.request.contextPath}/hr/contracts" class="sc-link"><i class="fas fa-arrow-right"></i> Quản lý hợp đồng</a>
                </div>
                <div class="stat-card c-teal">
                    <div class="sc-head"><span class="sc-title">Onboarding Chờ Duyệt</span><div class="sc-icon"><i class="fas fa-user-plus"></i></div></div>
                    <div class="sc-val">${onboardingPendingCount}</div>
                    <div class="sc-sub <c:if test='${onboardingPendingCount > 0}'>warn</c:if>"><i class="fas fa-paper-plane"></i> Hồ sơ bạn tạo đang chờ</div>
                    <a href="${pageContext.request.contextPath}/hr/onboarding/list" class="sc-link"><i class="fas fa-arrow-right"></i> Xem danh sách</a>
                </div>
                <div class="stat-card c-red">
                    <div class="sc-head"><span class="sc-title">Onboarding Từ Chối</span><div class="sc-icon"><i class="fas fa-exclamation-triangle"></i></div></div>
                    <div class="sc-val">${onboardingRejectedCount}</div>
                    <div class="sc-sub <c:if test='${onboardingRejectedCount > 0}'>danger</c:if>"><i class="fas fa-redo"></i> Cần sửa và gửi lại</div>
                    <a href="${pageContext.request.contextPath}/hr/onboarding/list" class="sc-link"><i class="fas fa-arrow-right"></i> Sửa hồ sơ</a>
                </div>
            </div>

            <%-- ── STAT CARDS ROW 2: Bảng lương tháng này ── --%>
            <div style="display:flex; align-items:center; gap:10px;">
                <span style="font-size:0.8rem; font-weight:700; color:#64748b; text-transform:uppercase; letter-spacing:0.5px; white-space:nowrap;">
                    <i class="fas fa-coins" style="color:#f59e0b;"></i> Bảng Lương ${currentMonthLabel}
                </span>
                <div style="flex:1; height:1px; background:linear-gradient(90deg,#e2e8f0,transparent);"></div>
                <a href="${pageContext.request.contextPath}/hr/payroll" style="font-size:0.75rem; font-weight:600; color:#0d9488; text-decoration:none; white-space:nowrap;">Quản lý lương →</a>
            </div>
            <div class="stat-grid" style="grid-template-columns: repeat(4, 1fr); margin-top:0;">
                <div class="stat-card c-purple">
                    <div class="sc-head"><span class="sc-title">Nháp</span><div class="sc-icon"><i class="fas fa-file-alt"></i></div></div>
                    <div class="sc-val">${payrollDraftCount}</div>
                    <div class="sc-sub"><i class="fas fa-pencil-alt"></i> Phiếu lương nháp</div>
                </div>
                <div class="stat-card c-orange">
                    <div class="sc-head"><span class="sc-title">Chờ Duyệt</span><div class="sc-icon"><i class="fas fa-hourglass-half"></i></div></div>
                    <div class="sc-val">${payrollPendingCount}</div>
                    <div class="sc-sub <c:if test='${payrollPendingCount > 0}'>warn</c:if>"><i class="fas fa-clock"></i> Đang chờ phê duyệt</div>
                </div>
                <div class="stat-card c-blue">
                    <div class="sc-head"><span class="sc-title">Đã Duyệt</span><div class="sc-icon"><i class="fas fa-check-circle"></i></div></div>
                    <div class="sc-val">${payrollApprovedCount}</div>
                    <div class="sc-sub good"><i class="fas fa-thumbs-up"></i> Đã được phê duyệt</div>
                </div>
                <div class="stat-card c-green">
                    <div class="sc-head"><span class="sc-title">Đã Thanh Toán</span><div class="sc-icon"><i class="fas fa-money-bill-wave"></i></div></div>
                    <div class="sc-val">${payrollPaidCount}</div>
                    <div class="sc-sub good"><i class="fas fa-check-double"></i> Đã chi trả lương</div>
                </div>
            </div>

            <%-- ── BIỂU ĐỒ ROW 1: Donut HĐ + Bar Onboarding ── --%>
            <div class="chart-row">
                <div class="card">
                    <div class="card-head">
                        <h3 class="card-title"><span class="ct-dot d-teal"></span>Phân Bố Trạng Thái Hợp Đồng</h3>
                        <a href="${pageContext.request.contextPath}/hr/contracts" class="btn btn-ghost">Chi tiết</a>
                    </div>
                    <div style="height:260px;">
                        <canvas id="contractStatusChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <div class="card-head">
                        <h3 class="card-title"><span class="ct-dot d-blue"></span>Pipeline Onboarding Của Bạn</h3>
                        <a href="${pageContext.request.contextPath}/hr/onboarding/list" class="btn btn-ghost">Chi tiết</a>
                    </div>
                    <div style="height:260px;">
                        <canvas id="onboardingPipelineChart"></canvas>
                    </div>
                </div>
            </div>

            <%-- ── BIỂU ĐỒ ROW 2: Donut loại HĐ + Stacked bar bảng lương ── --%>
            <div class="chart-row">
                <div class="card">
                    <div class="card-head">
                        <h3 class="card-title"><span class="ct-dot d-purple"></span>Phân Bố Loại Hợp Đồng</h3>
                        <a href="${pageContext.request.contextPath}/hr/contracts" class="btn btn-ghost">Chi tiết</a>
                    </div>
                    <div style="height:260px;">
                        <canvas id="contractTypeChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <div class="card-head">
                        <h3 class="card-title"><span class="ct-dot d-orange"></span>Tổng Quỹ Lương Chi Trả 6 Tháng</h3>
                        <a href="${pageContext.request.contextPath}/hr/payroll" class="btn btn-ghost">Quản lý</a>
                    </div>
                    <div style="height:260px;">
                        <canvas id="payrollTrendChart"></canvas>
                    </div>
                </div>
            </div>

            <%-- ── BẢNG 1: Hợp đồng sắp hết hạn (top 5) ── --%>
            <div class="card">
                <div class="card-head">
                    <h3 class="card-title"><span class="ct-dot d-orange"></span>Hợp Đồng Sắp Hết Hạn Gần Nhất</h3>
                    <a href="${pageContext.request.contextPath}/hr/contracts?status=expiring" class="btn btn-ghost">Xem tất cả</a>
                </div>
                <div class="dt-wrap">
                    <table class="dt">
                        <thead>
                            <tr><th>Nhân Viên</th><th>Loại Hợp Đồng</th><th>Ngày Kết Thúc</th><th>Còn Lại</th><th>Trạng Thái Ký</th><th>Hành Động</th></tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty top5ExpiringContracts}">
                                    <c:forEach items="${top5ExpiringContracts}" var="ct">
                                        <tr>
                                            <td>
                                                <div class="emp-cell">
                                                    <div class="emp-av av-orange">${fn:substring(ct.fullName, 0, 1)}</div>
                                                    <span style="font-weight:600;">${ct.fullName}</span>
                                                </div>
                                            </td>
                                            <td style="color:#64748b;">${not empty ct.contractTypeName ? ct.contractTypeName : '—'}</td>
                                            <td><fmt:formatDate value="${ct.endDate}" pattern="dd/MM/yyyy"/></td>
                                            <td>
                                                <% model.EmployeeContract ctBean = (model.EmployeeContract) pageContext.findAttribute("ct");
                                                   long daysLeft = 0;
                                                   if (ctBean != null && ctBean.getEndDate() != null)
                                                       daysLeft = (ctBean.getEndDate().getTime() - System.currentTimeMillis()) / 86400000L;
                                                   pageContext.setAttribute("daysLeft", daysLeft); %>
                                                <c:choose>
                                                    <c:when test="${daysLeft <= 7}"><span class="days-tag days-crit"><i class="fas fa-fire"></i> <c:choose><c:when test="${daysLeft < 0}">0</c:when><c:otherwise>${daysLeft}</c:otherwise></c:choose> ngày</span></c:when>
                                                    <c:when test="${daysLeft <= 20}"><span class="days-tag days-warn"><i class="fas fa-exclamation"></i> ${daysLeft} ngày</span></c:when>
                                                    <c:otherwise><span class="days-tag days-ok">${daysLeft} ngày</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${ct.signStatus == 'SIGNED'}"><span class="badge b-signed"><i class="fas fa-check"></i> Đã ký</span></c:when>
                                                    <c:when test="${ct.signStatus == 'PENDING'}"><span class="badge b-pending"><i class="fas fa-clock"></i> Chờ ký</span></c:when>
                                                    <c:when test="${ct.signStatus == 'REJECTED'}"><span class="badge b-rejected"><i class="fas fa-times"></i> Từ chối</span></c:when>
                                                    <c:otherwise><span class="badge b-expired">N/A</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><a href="${pageContext.request.contextPath}/hr/contracts?userId=${ct.userId}" class="btn btn-primary">Gia hạn</a></td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr><td colspan="6" class="empty-state"><i class="fas fa-check-double"></i>Không có hợp đồng nào sắp hết hạn</td></tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <%-- ── BẢNG 2: Hồ sơ Onboarding gần nhất của HR Staff này ── --%>
            <div class="card">
                <div class="card-head">
                    <h3 class="card-title"><span class="ct-dot d-purple"></span>Hồ Sơ Onboarding Gần Nhất</h3>
                    <a href="${pageContext.request.contextPath}/hr/onboarding/new" class="btn btn-primary"><i class="fas fa-plus"></i> Tạo mới</a>
                </div>
                <div class="dt-wrap">
                    <table class="dt">
                        <thead>
                            <tr><th>Ứng Viên</th><th>Phòng Ban</th><th>Chức Vụ</th><th>Ngày Tạo</th><th>Trạng Thái</th><th>Hành Động</th></tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty recentOnboarding}">
                                    <c:forEach items="${recentOnboarding}" var="ob">
                                        <tr>
                                            <td>
                                                <div class="emp-cell">
                                                    <div class="emp-av av-purple">${ob.initial}</div>
                                                    <div>
                                                        <div style="font-weight:600;">${ob.fullName}</div>
                                                        <div style="font-size:0.73rem;color:#94a3b8;">${ob.email}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td style="color:#64748b;">${not empty ob.departmentName ? ob.departmentName : '—'}</td>
                                            <td style="color:#64748b;">${not empty ob.positionName ? ob.positionName : '—'}</td>
                                            <td style="color:#64748b;font-size:0.82rem;"><fmt:formatDate value="${ob.createdAt}" pattern="dd/MM/yyyy"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${ob.status == 'APPROVED'}"><span class="badge b-approved"><i class="fas fa-check-circle"></i> Đã duyệt</span></c:when>
                                                    <c:when test="${ob.status == 'PENDING'}"><span class="badge b-pending"><i class="fas fa-clock"></i> Chờ duyệt</span></c:when>
                                                    <c:when test="${ob.status == 'REJECTED'}"><span class="badge b-rejected"><i class="fas fa-times-circle"></i> Từ chối</span></c:when>
                                                    <c:otherwise><span class="badge b-draft"><i class="fas fa-edit"></i> Nháp</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${ob.status == 'DRAFT' || ob.status == 'REJECTED'}">
                                                        <a href="${pageContext.request.contextPath}/hr/onboarding/edit?id=${ob.id}" class="btn btn-primary">Sửa</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/hr/onboarding/edit?id=${ob.id}" class="btn btn-ghost">Xem</a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr><td colspan="6" class="empty-state"><i class="fas fa-user-plus"></i>Chưa có hồ sơ nào. <a href="${pageContext.request.contextPath}/hr/onboarding/new" style="color:#0d9488;">Tạo hồ sơ đầu tiên</a></td></tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            </c:if><%-- end roleId == 5 --%>

        </div><%-- end dc --%>
    </div><%-- end dm --%>
</div><%-- end dw --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<c:if test="${currentUser.roleId == 2}">
<script>
document.addEventListener('DOMContentLoaded', function () {
    const bf = { family: "'Inter', sans-serif" };
    new Chart(document.getElementById('departmentChart'), {
        type: 'bar',
        data: { labels: ['Hành chính','Nhân sự','Kế toán','Kinh doanh','Xưởng SX'],
            datasets: [{ data:[8,12,10,25,35], backgroundColor:['#0d9488','#0891b2','#6366f1','#f59e0b','#10b981'], borderRadius:8 }] },
        options: { responsive:true, maintainAspectRatio:false, plugins:{legend:{display:false}},
            scales:{y:{ticks:{font:bf,color:'#94a3b8'},grid:{color:'rgba(0,0,0,0.04)'}},x:{ticks:{font:bf,color:'#94a3b8'},grid:{display:false}}}}
    });
    new Chart(document.getElementById('genderChart'), {
        type: 'doughnut',
        data: { labels:['Nam','Nữ','Khác'], datasets:[{data:[60,38,2],backgroundColor:['#3b82f6','#ec4899','#94a3b8'],borderWidth:3,borderColor:'#fff'}] },
        options: { responsive:true, maintainAspectRatio:false, cutout:'65%',
            plugins:{legend:{position:'bottom',labels:{boxWidth:12,padding:16,font:bf}}} }
    });
});
</script>
</c:if>

<c:if test="${currentUser.roleId == 5}">
<script>
// ── Dữ liệu từ server ──
const cActive=${contractCountActive}, cPending=${contractCountPending},
      cExpiring=${contractCountExpiring}, cExpired=${contractCountExpired}, cTerminated=${contractCountTerminated};
const contractHasData = ${contractChartHasData};

const oDraft=${onboardingDraftCount}, oPend=${onboardingPendingCountAll},
      oApprv=${onboardingApprovedCount}, oReject=${onboardingRejectedCountAll};
const onbHasData = ${onboardingChartHasData};

const ctLabels=[<c:forEach var="l" items="${contractTypeLabels}" varStatus="s">'${l}'${!s.last?',':''}</c:forEach>];
const ctData=[<c:forEach var="v" items="${contractTypeData}" varStatus="s">${v}${!s.last?',':''}</c:forEach>];
const ctHasData=${contractTypeHasData};

const payLbl=[<c:forEach var="l" items="${payrollLabels}" varStatus="s">'${l}'${!s.last?',':''}</c:forEach>];
const payAmounts=[<c:forEach var="v" items="${payrollAmounts}" varStatus="s">${v}${!s.last?',':''}</c:forEach>];
const payHasData=${payrollHasData};

document.addEventListener('DOMContentLoaded', function () {
    const bf = { family: "'Inter', sans-serif", size: 12 };
    const rLegend = { position:'right', labels:{boxWidth:11,padding:12,font:bf,color:'#475569'} };

    // ── Chart 1: Donut — Trạng thái hợp đồng ──
    (function(){
        const total = cActive+cPending+cExpiring+cExpired+cTerminated;
        const labels = total > 0
            ? ['Đang hiệu lực','Chờ duyệt','Sắp hết hạn','Đã hết hạn','Đã chấm dứt']
            : ['Chưa có dữ liệu'];
        const data   = total > 0 ? [cActive,cPending,cExpiring,cExpired,cTerminated] : [1];
        const colors = total > 0 ? ['#10b981','#f59e0b','#ef4444','#94a3b8','#6366f1'] : ['#e2e8f0'];
        new Chart(document.getElementById('contractStatusChart'), {
            type: 'doughnut',
            data: { labels, datasets: [{ data, backgroundColor:colors, borderWidth:3, borderColor:'#fff', hoverOffset:8 }] },
            options: {
                responsive:true, maintainAspectRatio:false, cutout:'62%',
                plugins:{
                    legend: rLegend,
                    tooltip:{ callbacks:{ label: c => total > 0 ? '  '+c.label+': '+c.parsed+' HĐ' : '  Chưa có dữ liệu' } }
                }
            }
        });
    })();

    // ── Chart 2: Bar — Onboarding pipeline ──
    new Chart(document.getElementById('onboardingPipelineChart'), {
        type: 'bar',
        data: {
            labels: ['Bản Nháp','Chờ Duyệt','Đã Duyệt','Bị Từ Chối'],
            datasets: [{ data:[oDraft,oPend,oApprv,oReject],
                backgroundColor:['#94a3b8','#f59e0b','#10b981','#ef4444'],
                borderRadius:10, borderSkipped:false }]
        },
        options: { responsive:true, maintainAspectRatio:false,
            plugins:{ legend:{display:false}, tooltip:{callbacks:{label:c=>'  '+c.parsed.y+' hồ sơ'}} },
            scales:{ y:{beginAtZero:true,ticks:{precision:0,color:'#94a3b8',font:bf},grid:{color:'rgba(0,0,0,0.04)'}},
                     x:{ticks:{color:'#475569',font:{...bf,weight:'600'}},grid:{display:false}} } }
    });

    // ── Chart 3: Donut — Loại hợp đồng ──
    (function(){
        const pal=['#0d9488','#3b82f6','#8b5cf6','#f59e0b','#10b981','#ef4444','#6366f1','#ec4899'];
        const hasData = ctLabels.length > 0;
        const labels  = hasData ? ctLabels : ['Chưa có dữ liệu'];
        const data    = hasData ? ctData   : [1];
        const colors  = hasData ? pal.slice(0,ctLabels.length) : ['#e2e8f0'];
        new Chart(document.getElementById('contractTypeChart'), {
            type: 'doughnut',
            data: { labels, datasets:[{ data, backgroundColor:colors, borderWidth:3, borderColor:'#fff', hoverOffset:8 }] },
            options: { responsive:true, maintainAspectRatio:false, cutout:'55%',
                plugins:{ legend:rLegend, tooltip:{callbacks:{label:c=>hasData?'  '+c.label+': '+c.parsed+' HĐ':'  Chưa có dữ liệu'}} } }
        });
    })();

    // ── Chart 4: Line/Area — Tổng quỹ lương chi trả 6 tháng ──
    const ctx = document.getElementById('payrollTrendChart').getContext('2d');
    const gradient = ctx.createLinearGradient(0, 0, 0, 240);
    gradient.addColorStop(0, 'rgba(13, 148, 136, 0.25)'); // Teal semi-transparent
    gradient.addColorStop(1, 'rgba(13, 148, 136, 0.0)');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: payLbl,
            datasets: [{
                label: 'Tổng chi trả',
                data: payAmounts,
                borderColor: '#0d9488', // Teal
                borderWidth: 3,
                backgroundColor: gradient,
                fill: true,
                tension: 0.35,
                pointBackgroundColor: '#0d9488',
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive:true, maintainAspectRatio:false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: c => {
                            const val = c.parsed.y;
                            return '  Chi trả: ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
                        }
                    }
                }
            },
            scales: {
                x: { ticks: { color: '#475569', font: bf }, grid: { display: false } },
                y: {
                    beginAtZero: true,
                    ticks: {
                        color: '#94a3b8',
                        font: bf,
                        callback: val => {
                            if (val >= 1e9) return (val / 1e9).toFixed(1) + 'B'; // Billions (Tỷ)
                            if (val >= 1e6) return (val / 1e6).toFixed(0) + 'M'; // Millions (Triệu)
                            return val;
                        }
                    },
                    grid: { color: 'rgba(0,0,0,0.04)' }
                }
            }
        }
    });
});
</script>
</c:if>


<jsp:include page="../footer.jsp" />

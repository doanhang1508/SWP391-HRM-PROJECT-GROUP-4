<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Duyệt Nghỉ phép / OT" scope="request" />
<jsp:include page="../header.jsp" />

<style>
footer, #chatWidget { display: none !important; }

body {
    background-color: #f1f5f9 !important;
    font-family: 'Inter', -apple-system, sans-serif !important;
    padding-top: 0 !important;
    min-height: 100vh;
}

/* ── Layout ── */
.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.dash-main { flex: 1; min-width: 0; background: #f1f5f9; }
.dash-content { padding: 28px 32px; display: flex; flex-direction: column; gap: 24px; }

/* ── Page Header ── */
.page-header-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
}
.page-header-left { display: flex; flex-direction: column; gap: 4px; }
.page-breadcrumb { font-size: 0.78rem; color: #94a3b8; display: flex; align-items: center; gap: 6px; }
.page-breadcrumb a { color: #0d9488; text-decoration: none; }
.page-breadcrumb a:hover { text-decoration: underline; }
.page-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; letter-spacing: -0.5px; }
.page-role-badge {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 14px; border-radius: 20px;
    font-size: 0.8rem; font-weight: 700;
    background: linear-gradient(135deg, #0d9488, #0369a1);
    color: #fff; box-shadow: 0 2px 8px rgba(13,148,136,0.3);
}

/* ── Scope Info Banner ── */
.scope-banner {
    background: linear-gradient(135deg, #eff6ff, #f0fdf4);
    border: 1px solid #bfdbfe;
    border-radius: 12px;
    padding: 12px 20px;
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 0.85rem;
    color: #1e40af;
    font-weight: 500;
}
.scope-banner i { font-size: 1rem; color: #3b82f6; flex-shrink: 0; }

/* ── Stat Cards ── */
.stat-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; }
.stat-mini {
    background: #fff;
    border-radius: 14px;
    padding: 18px 20px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 1px 3px rgba(0,0,0,0.04);
    display: flex;
    align-items: center;
    gap: 14px;
    transition: transform 0.2s, box-shadow 0.2s;
}
.stat-mini:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(0,0,0,0.07); }
.stat-mini-icon {
    width: 44px; height: 44px;
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem;
    flex-shrink: 0;
}
.stat-mini-icon.warn { background: #fef3c7; color: #d97706; }
.stat-mini-icon.info { background: #dbeafe; color: #2563eb; }
.stat-mini-icon.success { background: #d1fae5; color: #059669; }
.stat-mini-val { font-size: 1.5rem; font-weight: 800; color: #0f172a; line-height: 1; }
.stat-mini-label { font-size: 0.75rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 2px; }

/* ── Card ── */
.mgr-card {
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
    overflow: hidden;
}

/* ── Tabs ── */
.mgr-tabs {
    display: flex;
    border-bottom: 2px solid #e2e8f0;
    background: #fafbfc;
    padding: 0 24px;
}
.mgr-tab {
    padding: 14px 20px;
    font-size: 0.88rem;
    font-weight: 600;
    color: #64748b;
    cursor: pointer;
    border: none;
    background: none;
    border-bottom: 2px solid transparent;
    margin-bottom: -2px;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s;
}
.mgr-tab:hover { color: #0f172a; }
.mgr-tab.active { color: #0d9488; border-bottom-color: #0d9488; }
.mgr-tab .badge-count {
    background: #fee2e2;
    color: #dc2626;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 0.72rem;
    font-weight: 700;
    min-width: 20px;
    text-align: center;
}
.mgr-tab.active .badge-count {
    background: rgba(13, 148, 136, 0.12);
    color: #0d9488;
}

/* ── Tab content ── */
.mgr-tab-pane { display: none; }
.mgr-tab-pane.active { display: block; }

/* ── Table ── */
.mgr-table { width: 100%; border-collapse: collapse; text-align: left; }
.mgr-table th {
    padding: 12px 20px;
    border-bottom: 1px solid #e2e8f0;
    color: #64748b;
    font-size: 0.73rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    background: #fafbfc;
    white-space: nowrap;
}
.mgr-table td {
    padding: 14px 20px;
    border-bottom: 1px solid #f1f5f9;
    color: #0f172a;
    font-size: 0.88rem;
    vertical-align: middle;
}
.mgr-table tbody tr:last-child td { border-bottom: none; }
.mgr-table tbody tr:hover td { background: #f8fafc; }

.emp-cell { display: flex; align-items: center; gap: 10px; }
.emp-avatar {
    width: 34px; height: 34px;
    border-radius: 8px;
    background: linear-gradient(135deg, #0d9488, #1e40af);
    color: #fff;
    display: flex; align-items: center; justify-content: center;
    font-weight: 700; font-size: 0.82rem;
    flex-shrink: 0;
}
.emp-name { font-weight: 600; }

.leave-type-badge {
    display: inline-flex; align-items: center; gap: 4px;
    padding: 4px 10px; border-radius: 6px;
    font-size: 0.78rem; font-weight: 600;
    background: #eff6ff; color: #2563eb;
}

.date-range { white-space: nowrap; font-size: 0.85rem; color: #475569; }

.reason-cell {
    max-width: 200px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.reason-cell:hover {
    white-space: normal;
    overflow: visible;
}

/* ── Action Buttons ── */
.action-btns { display: flex; gap: 6px; }
.btn-approve, .btn-reject {
    padding: 6px 14px;
    border-radius: 8px;
    font-size: 0.8rem;
    font-weight: 700;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}
.btn-approve { background: #d1fae5; color: #059669; }
.btn-approve:hover { background: #059669; color: #fff; }
.btn-reject { background: #fee2e2; color: #dc2626; }
.btn-reject:hover { background: #dc2626; color: #fff; }

/* ── Empty State ── */
.empty-state {
    padding: 60px 24px;
    text-align: center;
    color: #94a3b8;
}
.empty-state i { font-size: 2.5rem; margin-bottom: 16px; display: block; }
.empty-state p { font-size: 0.95rem; font-weight: 500; }

/* ── Alert ── */
.alert-custom {
    border-radius: 10px;
    padding: 14px 20px;
    font-size: 0.88rem;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 10px;
}
.alert-custom.success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
.alert-custom.error   { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

/* ── OT Hours ── */
.ot-hours {
    font-weight: 700;
    font-size: 0.95rem;
    color: #d97706;
}

@media (max-width: 768px) {
    .dash-content { padding: 20px 16px; }
    .mgr-table th, .mgr-table td { padding: 10px 12px; }
    .reason-cell { max-width: 120px; }
}
</style>

<div class="dashboard-wrapper">
    <%-- Shared Sidebar --%>
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="leave-ot" />
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">

            <%-- Page Header --%>
            <div class="page-header-bar">
                <div class="page-header-left">
                    <div class="page-breadcrumb">
                        <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Dashboard</a>
                        <span>/</span>
                        <span>Duyệt nghỉ phép / OT</span>
                    </div>
                    <div class="page-title">Duyệt Nghỉ phép &amp; Tăng ca</div>
                </div>
                <div class="page-role-badge">
                    <c:choose>
                        <c:when test="${sessionScope.currentUser.roleId == 3}">
                            <i class="fas fa-industry"></i> Quản đốc xưởng
                        </c:when>
                        <c:when test="${sessionScope.currentUser.roleId == 6}">
                            <i class="fas fa-briefcase"></i> Trưởng phòng
                        </c:when>
                        <c:when test="${sessionScope.currentUser.roleId == 2}">
                            <i class="fas fa-user-tie"></i> HR Manager
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-user-shield"></i> Quản lý
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <%-- Scope info banner — cho biết đang xem phạm vi nào --%>
            <c:choose>
                <c:when test="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6}">
                    <div class="scope-banner">
                        <i class="fas fa-filter"></i>
                        Bạn đang xem đơn của nhân viên thuộc phòng ban / khu vực của mình.
                    </div>
                </c:when>
                <c:when test="${sessionScope.currentUser.roleId == 2}">
                    <div class="scope-banner">
                        <i class="fas fa-globe"></i>
                        Bạn đang xem tất cả đơn chờ duyệt toàn công ty.
                    </div>
                </c:when>
            </c:choose>

            <%-- Alerts --%>
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert-custom success">
                    <i class="fas fa-check-circle"></i> ${sessionScope.successMessage}
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert-custom error">
                    <i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMessage}
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <%-- Stats --%>
            <div class="stat-row">
                <div class="stat-mini">
                    <div class="stat-mini-icon warn"><i class="fas fa-calendar-times"></i></div>
                    <div>
                        <div class="stat-mini-val">${fn:length(pendingLeaves)}</div>
                        <div class="stat-mini-label">Đơn nghỉ phép chờ</div>
                    </div>
                </div>
                <c:if test="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 2}">
                    <%-- OT chỉ có ở xưởng (Supervisor) hoặc HR Manager xem tổng --%>
                    <div class="stat-mini">
                        <div class="stat-mini-icon info"><i class="fas fa-business-time"></i></div>
                        <div>
                            <div class="stat-mini-val">${fn:length(pendingOTs)}</div>
                            <div class="stat-mini-label">Phân ca OT chờ duyệt</div>
                        </div>
                    </div>
                </c:if>
                <div class="stat-mini">
                    <div class="stat-mini-icon success"><i class="fas fa-check-double"></i></div>
                    <div>
                        <div class="stat-mini-val">${fn:length(pendingLeaves) + fn:length(pendingOTs)}</div>
                        <div class="stat-mini-label">Tổng chờ xử lý</div>
                    </div>
                </div>
            </div>

            <%-- Main Card with Tabs --%>
            <div class="mgr-card">
                <div class="mgr-tabs">
                    <button class="mgr-tab active" onclick="switchTab(event, 'leavePane')">
                        <i class="fas fa-umbrella-beach"></i> Đơn nghỉ phép
                        <c:if test="${fn:length(pendingLeaves) > 0}">
                            <span class="badge-count">${fn:length(pendingLeaves)}</span>
                        </c:if>
                    </button>
                    <%-- Tab OT chỉ hiện với Supervisor (xưởng) hoặc HR Manager xem tổng --%>
                    <c:if test="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 2}">
                        <button class="mgr-tab" onclick="switchTab(event, 'otPane')">
                            <i class="fas fa-business-time"></i> Phân ca Tăng ca (OT)
                            <c:if test="${fn:length(pendingOTs) > 0}">
                                <span class="badge-count">${fn:length(pendingOTs)}</span>
                            </c:if>
                        </button>
                    </c:if>
                </div>

                <%-- LEAVE TAB --%>
                <div class="mgr-tab-pane active" id="leavePane">
                    <c:choose>
                        <c:when test="${not empty pendingLeaves}">
                            <div class="table-responsive">
                                <table class="mgr-table">
                                    <thead>
                                        <tr>
                                            <th>Nhân viên</th>
                                            <th>Loại nghỉ</th>
                                            <th>Thời gian</th>
                                            <th>Số ngày</th>
                                            <th>Lý do</th>
                                            <th>Ngày gửi</th>
                                            <th style="text-align:center;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="lr" items="${pendingLeaves}">
                                            <tr>
                                                <td>
                                                    <div class="emp-cell">
                                                        <div class="emp-avatar">${fn:substring(lr.userName, 0, 1)}</div>
                                                        <span class="emp-name">${lr.userName}</span>
                                                    </div>
                                                </td>
                                                <td><span class="leave-type-badge"><i class="fas fa-tag"></i> ${lr.leaveTypeName}</span></td>
                                                <td class="date-range">
                                                    <fmt:formatDate value="${lr.startDate}" pattern="dd/MM/yyyy"/>
                                                    <i class="fas fa-arrow-right" style="font-size:0.65rem;color:#cbd5e1;margin:0 4px;"></i>
                                                    <fmt:formatDate value="${lr.endDate}" pattern="dd/MM/yyyy"/>
                                                </td>
                                                <td><strong>${lr.totalDays}</strong></td>
                                                <td class="reason-cell" title="${lr.reason}">${lr.reason}</td>
                                                <td style="color:#94a3b8;font-size:0.82rem;">
                                                    <fmt:formatDate value="${lr.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </td>
                                                <td>
                                                    <div class="action-btns" style="justify-content:center;">
                                                        <form action="${pageContext.request.contextPath}/manager/leave-ot" method="POST" style="display:inline;">
                                                            <input type="hidden" name="type" value="leave">
                                                            <input type="hidden" name="id" value="${lr.requestId}">
                                                            <input type="hidden" name="action" value="approve">
                                                            <button type="submit" class="btn-approve"
                                                                    onclick="return confirm('Duyệt đơn nghỉ phép của ${lr.userName}?');">
                                                                <i class="fas fa-check"></i> Duyệt
                                                            </button>
                                                        </form>
                                                        <form action="${pageContext.request.contextPath}/manager/leave-ot" method="POST" style="display:inline;">
                                                            <input type="hidden" name="type" value="leave">
                                                            <input type="hidden" name="id" value="${lr.requestId}">
                                                            <input type="hidden" name="action" value="reject">
                                                            <button type="submit" class="btn-reject"
                                                                    onclick="return confirm('Từ chối đơn nghỉ phép của ${lr.userName}?');">
                                                                <i class="fas fa-times"></i> Từ chối
                                                            </button>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-inbox"></i>
                                <p>Không có đơn nghỉ phép nào đang chờ duyệt</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- OT TAB — chỉ Supervisor (3) xưởng và HR Manager (2) xem tổng --%>
                <c:if test="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 2}">
                    <div class="mgr-tab-pane" id="otPane">
                        <c:choose>
                            <c:when test="${not empty pendingOTs}">
                                <div class="table-responsive">
                                    <table class="mgr-table">
                                        <thead>
                                            <tr>
                                                <th>Nhân viên</th>
                                                <th>Ngày làm việc</th>
                                                <th>Ca tăng ca</th>
                                                <th>Số giờ OT</th>
                                                <th>Lý do phân ca</th>
                                                <th>Ngày tạo</th>
                                                <th style="text-align:center;">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="ot" items="${pendingOTs}">
                                                <tr>
                                                    <td>
                                                        <div class="emp-cell">
                                                            <div class="emp-avatar">${fn:substring(ot.userName, 0, 1)}</div>
                                                            <span class="emp-name">${ot.userName}</span>
                                                        </div>
                                                    </td>
                                                    <td><fmt:formatDate value="${ot.workDate}" pattern="dd/MM/yyyy"/></td>
                                                    <td><span class="leave-type-badge" style="background:#fef3c7;color:#92400e;">
                                                        <i class="fas fa-clock"></i> ${ot.shiftName}
                                                    </span></td>
                                                    <td><span class="ot-hours">${ot.overtimeHrs}h</span></td>
                                                    <td class="reason-cell" title="${ot.otReason}">${ot.otReason}</td>
                                                    <td style="color:#94a3b8;font-size:0.82rem;">
                                                        <fmt:formatDate value="${ot.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </td>
                                                    <td>
                                                        <div class="action-btns" style="justify-content:center;">
                                                            <form action="${pageContext.request.contextPath}/manager/leave-ot" method="POST" style="display:inline;">
                                                                <input type="hidden" name="type" value="ot">
                                                                <input type="hidden" name="id" value="${ot.attendanceId}">
                                                                <input type="hidden" name="action" value="approve">
                                                                <button type="submit" class="btn-approve"
                                                                        onclick="return confirm('Xác nhận phân ca OT cho ${ot.userName}?');">
                                                                    <i class="fas fa-check"></i> Xác nhận
                                                                </button>
                                                            </form>
                                                            <form action="${pageContext.request.contextPath}/manager/leave-ot" method="POST" style="display:inline;">
                                                                <input type="hidden" name="type" value="ot">
                                                                <input type="hidden" name="id" value="${ot.attendanceId}">
                                                                <input type="hidden" name="action" value="reject">
                                                                <button type="submit" class="btn-reject"
                                                                        onclick="return confirm('Huỷ phân ca OT cho ${ot.userName}?');">
                                                                    <i class="fas fa-times"></i> Huỷ
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    <p>Không có ca tăng ca nào đang chờ xác nhận</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
            </div>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div><%-- end dashboard-wrapper --%>

<script>
function switchTab(event, paneId) {
    document.querySelectorAll('.mgr-tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.mgr-tab-pane').forEach(p => p.classList.remove('active'));
    event.currentTarget.classList.add('active');
    document.getElementById(paneId).classList.add('active');
}
</script>

<jsp:include page="../footer.jsp" />

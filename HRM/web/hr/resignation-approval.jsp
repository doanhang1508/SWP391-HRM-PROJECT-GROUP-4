<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Duyệt Đơn Xin Nghỉ Việc - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    :root {
        --navy:          #0a2540;
        --blue:          #2b6cb0;
        --accent:        #3ecf8e;
        --bg:            #f0ede8;
        --surface:       #ffffff;
        --border:        #e2e8f0;
        --text:          #0f172a;
        --muted:         #64748b;
        --danger:        #e11d48;
        --danger-light:  #fff1f2;
        --success:       #10b981;
        --success-light: #d1fae5;
        --warning:       #f59e0b;
        --warning-light: #fffbeb;
    }

    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }

    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    /* ── TOP BAR ── */
    .page-topbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 28px;
        flex-wrap: wrap;
        gap: 16px;
    }

    .page-topbar-left h1 {
        font-family: 'Be Vietnam Pro', sans-serif;
        font-size: 1.55rem;
        font-weight: 800;
        color: var(--navy);
        margin: 0 0 4px;
        letter-spacing: -0.4px;
    }

    .breadcrumb {
        font-size: 0.78rem;
        color: var(--muted);
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .breadcrumb a {
        color: var(--blue);
        text-decoration: none;
    }

    /* ── ALERTS ── */
    .alert {
        padding: 14px 20px;
        border-radius: 12px;
        font-size: 0.9rem;
        font-weight: 500;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        gap: 12px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.02);
    }

    .alert-success {
        background: var(--success-light);
        border: 1px solid #a7f3d0;
        color: #065f46;
    }

    .alert-danger {
        background: var(--danger-light);
        border: 1px solid #fecdd3;
        color: #9f1239;
    }

    /* ── STATS CARDS ── */
    .stats-row {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }

    .stat-card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 14px;
        padding: 20px 22px;
        display: flex;
        align-items: center;
        gap: 16px;
        box-shadow: 0 2px 8px rgba(10,37,64,0.04);
    }

    .stat-icon {
        width: 46px;
        height: 46px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        flex-shrink: 0;
    }

    .stat-icon.pending  { background: var(--warning-light); color: var(--warning); }
    .stat-icon.approved { background: var(--success-light);  color: var(--success); }
    .stat-icon.rejected { background: var(--danger-light);   color: var(--danger);  }

    .stat-value {
        font-size: 1.7rem;
        font-weight: 800;
        color: var(--navy);
        line-height: 1;
        margin-bottom: 3px;
    }

    .stat-label {
        font-size: 0.8rem;
        color: var(--muted);
        font-weight: 500;
    }

    /* ── FILTER TABS ── */
    .filter-tabs {
        display: flex;
        gap: 8px;
        margin-bottom: 20px;
        flex-wrap: wrap;
    }

    .filter-tab {
        padding: 8px 18px;
        border-radius: 20px;
        border: 1px solid var(--border);
        background: var(--surface);
        font-size: 0.85rem;
        font-weight: 500;
        color: var(--muted);
        text-decoration: none;
        transition: all 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .filter-tab:hover {
        border-color: var(--navy);
        color: var(--navy);
    }

    .filter-tab.active {
        background: var(--navy);
        color: #fff;
        border-color: var(--navy);
    }

    /* ── TABLE CARD ── */
    .table-card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 16px;
        box-shadow: 0 4px 16px rgba(10,37,64,0.05);
        overflow: hidden;
    }

    .table-card-header {
        padding: 20px 24px;
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .table-card-header h3 {
        font-size: 1rem;
        font-weight: 700;
        color: var(--navy);
        margin: 0;
    }

    .table-card-header span {
        font-size: 0.82rem;
        color: var(--muted);
    }

    .table-wrapper {
        overflow-x: auto;
    }

    table.resign-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.875rem;
    }

    .resign-table thead th {
        background: #f8fafc;
        padding: 12px 18px;
        text-align: left;
        font-weight: 600;
        font-size: 0.75rem;
        color: var(--muted);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid var(--border);
        white-space: nowrap;
    }

    .resign-table tbody tr {
        border-bottom: 1px solid #f1f5f9;
        transition: background 0.15s;
    }

    .resign-table tbody tr:last-child { border-bottom: none; }
    .resign-table tbody tr:hover { background: #f8fafc; }

    .resign-table tbody td {
        padding: 14px 18px;
        color: var(--text);
        vertical-align: middle;
    }

    .employee-info strong {
        display: block;
        font-weight: 600;
        margin-bottom: 2px;
    }

    .employee-info span {
        font-size: 0.78rem;
        color: var(--muted);
    }

    .reason-text {
        max-width: 220px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        display: block;
        cursor: pointer;
    }

    /* ── STATUS BADGES ── */
    .badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 600;
        white-space: nowrap;
    }

    .badge-pending  { background: var(--warning-light); color: #92400e; border: 1px solid #fde68a; }
    .badge-approved { background: var(--success-light);  color: #065f46; border: 1px solid #a7f3d0; }
    .badge-rejected { background: var(--danger-light);   color: #9f1239; border: 1px solid #fecdd3; }

    /* ── ACTION BUTTONS ── */
    .btn-approve {
        background: var(--success);
        color: #fff;
        border: none;
        padding: 7px 14px;
        border-radius: 8px;
        font-size: 0.82rem;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.2s;
        font-family: 'Inter', sans-serif;
    }

    .btn-approve:hover {
        background: #059669;
        transform: translateY(-1px);
    }

    .btn-reject {
        background: var(--danger-light);
        color: var(--danger);
        border: 1px solid #fecdd3;
        padding: 7px 14px;
        border-radius: 8px;
        font-size: 0.82rem;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.2s;
        font-family: 'Inter', sans-serif;
    }

    .btn-reject:hover {
        background: var(--danger);
        color: #fff;
    }

    .action-btns {
        display: flex;
        gap: 8px;
        align-items: center;
    }

    /* ── EMPTY STATE ── */
    .empty-state {
        text-align: center;
        padding: 60px 24px;
        color: var(--muted);
    }

    .empty-state i {
        font-size: 2.8rem;
        margin-bottom: 16px;
        display: block;
        opacity: 0.5;
    }

    .empty-state p { font-size: 0.9rem; margin: 0; }

    /* ── MODAL ── */
    .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.55);
        z-index: 9000;
        align-items: center;
        justify-content: center;
    }

    .modal-overlay.active { display: flex; }

    .modal-box {
        background: #fff;
        border-radius: 16px;
        padding: 32px 36px;
        max-width: 480px;
        width: 90%;
        box-shadow: 0 24px 64px rgba(0,0,0,0.2);
        animation: modalIn 0.22s ease;
    }

    @keyframes modalIn {
        from { transform: scale(0.9); opacity: 0; }
        to   { transform: scale(1);   opacity: 1; }
    }

    .modal-icon {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        margin: 0 auto 18px;
    }

    .modal-icon.approve { background: var(--success-light); color: var(--success); }
    .modal-icon.reject  { background: var(--danger-light);  color: var(--danger);  }

    .modal-box h4 {
        font-size: 1.1rem;
        font-weight: 800;
        color: var(--navy);
        text-align: center;
        margin: 0 0 10px;
    }

    .modal-box p {
        font-size: 0.85rem;
        color: var(--muted);
        text-align: center;
        margin: 0 0 20px;
        line-height: 1.65;
    }

    .modal-info-box {
        background: #f8fafc;
        border: 1px solid var(--border);
        border-radius: 10px;
        padding: 14px 16px;
        margin-bottom: 20px;
    }

    .modal-info-box .info-row {
        display: flex;
        justify-content: space-between;
        font-size: 0.83rem;
        padding: 5px 0;
        border-bottom: 1px solid var(--border);
    }

    .modal-info-box .info-row:last-child { border-bottom: none; }
    .modal-info-box .info-row span:first-child { color: var(--muted); font-weight: 500; }
    .modal-info-box .info-row span:last-child  { color: var(--text);  font-weight: 600; }

    .form-group-modal { margin-bottom: 16px; }

    .form-label-modal {
        display: block;
        font-size: 0.84rem;
        font-weight: 600;
        color: var(--navy);
        margin-bottom: 7px;
    }

    .form-control-modal {
        width: 100%;
        padding: 11px 14px;
        border: 1px solid var(--border);
        border-radius: 9px;
        font-size: 0.88rem;
        font-family: 'Inter', sans-serif;
        outline: none;
        transition: border-color 0.2s;
        resize: vertical;
        min-height: 90px;
        background: #f8fafc;
    }

    .form-control-modal:focus {
        border-color: var(--danger);
        box-shadow: 0 0 0 3px rgba(225,29,72,0.1);
        background: #fff;
    }

    .modal-actions {
        display: flex;
        gap: 10px;
    }

    .btn-modal-cancel {
        flex: 1;
        padding: 11px;
        border-radius: 9px;
        border: 1px solid var(--border);
        background: #f8fafc;
        font-weight: 600;
        font-size: 0.88rem;
        cursor: pointer;
        color: var(--muted);
        transition: background 0.15s;
        font-family: 'Inter', sans-serif;
    }

    .btn-modal-cancel:hover { background: var(--border); }

    .btn-modal-confirm-approve {
        flex: 1.5;
        padding: 11px;
        border-radius: 9px;
        border: none;
        background: var(--success);
        color: #fff;
        font-weight: 700;
        font-size: 0.88rem;
        cursor: pointer;
        transition: background 0.15s;
        font-family: 'Inter', sans-serif;
    }

    .btn-modal-confirm-approve:hover { background: #059669; }

    .btn-modal-confirm-reject {
        flex: 1.5;
        padding: 11px;
        border-radius: 9px;
        border: none;
        background: var(--danger);
        color: #fff;
        font-weight: 700;
        font-size: 0.88rem;
        cursor: pointer;
        transition: background 0.15s;
        font-family: 'Inter', sans-serif;
    }

    .btn-modal-confirm-reject:hover { background: #be123c; }

    @media (max-width: 1024px) {
        .stats-row { grid-template-columns: 1fr 1fr; }
    }

    @media (max-width: 768px) {
        .page-main { padding: 20px 16px; }
        .stats-row { grid-template-columns: 1fr; }
        .filter-tabs { gap: 6px; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="resignation-approval" />
    </jsp:include>

    <div class="page-main">

        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <span>Duyệt Đơn Nghỉ Việc</span>
                </div>
                <h1><i class="fas fa-file-signature" style="color:#e11d48;margin-right:10px;font-size:1.3rem;"></i>Duyệt Đơn Xin Nghỉ Việc</h1>
            </div>
        </div>

        <!-- Flash Messages -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle" style="font-size:1.2rem;"></i>
                ${sessionScope.successMessage}
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle" style="font-size:1.2rem;"></i>
                ${sessionScope.errorMessage}
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <%-- Thông báo nếu là HR Staff (chỉ xem, không được duyệt) --%>
        <c:if test="${sessionScope.currentUser.roleId == 5}">
            <div class="alert" style="background:#eff6ff;border:1px solid #bfdbfe;color:#1e40af;margin-bottom:24px;">
                <i class="fas fa-info-circle" style="font-size:1.2rem;"></i>
                <span><strong>Chế độ xem:</strong> Chỉ <strong>HR Manager</strong> mới có quyền duyệt hoặc từ chối đơn xin nghỉ việc.</span>
            </div>
        </c:if>

        <!-- Stats Row -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-icon pending"><i class="fas fa-clock"></i></div>
                <div>
                    <div class="stat-value">
                        <c:set var="pendingCount" value="0"/>
                        <c:forEach var="rr" items="${resignationList}">
                            <c:if test="${rr.status == 'PENDING'}">
                                <c:set var="pendingCount" value="${pendingCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${statusFilter == 'all' ? pendingCount : (statusFilter == 'PENDING' ? resignationList.size() : '—')}
                    </div>
                    <div class="stat-label">Chờ duyệt</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon approved"><i class="fas fa-check-circle"></i></div>
                <div>
                    <div class="stat-value">
                        <c:set var="approvedCount" value="0"/>
                        <c:forEach var="rr" items="${resignationList}">
                            <c:if test="${rr.status == 'APPROVED'}">
                                <c:set var="approvedCount" value="${approvedCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${statusFilter == 'all' ? approvedCount : (statusFilter == 'APPROVED' ? resignationList.size() : '—')}
                    </div>
                    <div class="stat-label">Đã duyệt</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon rejected"><i class="fas fa-times-circle"></i></div>
                <div>
                    <div class="stat-value">
                        <c:set var="rejectedCount" value="0"/>
                        <c:forEach var="rr" items="${resignationList}">
                            <c:if test="${rr.status == 'REJECTED'}">
                                <c:set var="rejectedCount" value="${rejectedCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${statusFilter == 'all' ? rejectedCount : (statusFilter == 'REJECTED' ? resignationList.size() : '—')}
                    </div>
                    <div class="stat-label">Từ chối</div>
                </div>
            </div>
        </div>

        <!-- Filter Tabs -->
        <div class="filter-tabs">
            <a href="${pageContext.request.contextPath}/hr/resignation-approval?status=all"
               class="filter-tab ${statusFilter == 'all' ? 'active' : ''}">
                <i class="fas fa-list"></i> Tất cả
            </a>
            <a href="${pageContext.request.contextPath}/hr/resignation-approval?status=PENDING"
               class="filter-tab ${statusFilter == 'PENDING' ? 'active' : ''}">
                <i class="fas fa-clock"></i> Chờ duyệt
            </a>
            <a href="${pageContext.request.contextPath}/hr/resignation-approval?status=APPROVED"
               class="filter-tab ${statusFilter == 'APPROVED' ? 'active' : ''}">
                <i class="fas fa-check-circle"></i> Đã duyệt
            </a>
            <a href="${pageContext.request.contextPath}/hr/resignation-approval?status=REJECTED"
               class="filter-tab ${statusFilter == 'REJECTED' ? 'active' : ''}">
                <i class="fas fa-times-circle"></i> Từ chối
            </a>
        </div>

        <!-- Table Card -->
        <div class="table-card">
            <div class="table-card-header">
                <h3><i class="fas fa-inbox" style="margin-right:8px;color:#e11d48;"></i>Danh Sách Đơn Xin Nghỉ</h3>
                <span>${resignationList.size()} đơn</span>
            </div>

            <c:choose>
                <c:when test="${empty resignationList}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <p>Không có đơn nào trong danh sách này.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-wrapper">
                        <table class="resign-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Nhân viên</th>
                                    <th>Ngày nộp</th>
                                    <th>Ngày muốn nghỉ</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                    <th>Người duyệt</th>
                                    <th>Ghi chú HR</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rr" items="${resignationList}" varStatus="st">
                                    <tr>
                                        <td style="color:#94a3b8;font-weight:500;">${st.index + 1}</td>
                                        <td>
                                            <div class="employee-info">
                                                <strong>${rr.employeeName}</strong>
                                                <span>Mã NV: ${rr.employeeUsername}</span>
                                            </div>
                                        </td>
                                        <td style="white-space:nowrap;">
                                            <fmt:formatDate value="${rr.submittedAt}" pattern="dd/MM/yyyy"/>
                                            <br>
                                            <span style="font-size:0.75rem;color:#94a3b8;">
                                                <fmt:formatDate value="${rr.submittedAt}" pattern="HH:mm"/>
                                            </span>
                                        </td>
                                        <td>
                                            <strong style="color:#0a2540;">
                                                <fmt:formatDate value="${rr.desiredLastDate}" pattern="dd/MM/yyyy"/>
                                            </strong>
                                        </td>
                                        <td>
                                            <span class="reason-text" title="${rr.reason}">${rr.reason}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rr.status == 'PENDING'}">
                                                    <span class="badge badge-pending">
                                                        <i class="fas fa-clock"></i> Chờ duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${rr.status == 'APPROVED'}">
                                                    <span class="badge badge-approved">
                                                        <i class="fas fa-check-circle"></i> Đã duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${rr.status == 'REJECTED'}">
                                                    <span class="badge badge-rejected">
                                                        <i class="fas fa-times-circle"></i> Từ chối
                                                    </span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty rr.reviewerName}">
                                                    <span style="font-size:0.85rem;">${rr.reviewerName}</span>
                                                    <br>
                                                    <span style="font-size:0.75rem;color:#94a3b8;">
                                                        <fmt:formatDate value="${rr.reviewedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#94a3b8;">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty rr.hrNote}">
                                                    <span style="font-size:0.83rem;color:#475569;max-width:160px;display:block;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"
                                                          title="${rr.hrNote}">${rr.hrNote}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#94a3b8;">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rr.status == 'PENDING' && sessionScope.currentUser.roleId == 2}">
                                                    <div class="action-btns">
                                                        <button class="btn-approve"
                                                                onclick="openApproveModal(${rr.resignationId}, '${rr.employeeName}', '${rr.desiredLastDate}')">
                                                            <i class="fas fa-check"></i> Duyệt
                                                        </button>
                                                        <button class="btn-reject"
                                                                onclick="openRejectModal(${rr.resignationId}, '${rr.employeeName}')">
                                                            <i class="fas fa-times"></i> Từ chối
                                                        </button>
                                                    </div>
                                                </c:when>
                                                <c:when test="${rr.status == 'PENDING' && sessionScope.currentUser.roleId != 2}">
                                                    <span style="font-size:0.8rem;color:#94a3b8;">— Không có quyền —</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="font-size:0.8rem;color:#94a3b8;">Đã xử lý</span>
                                                </c:otherwise>
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

<!-- ══ APPROVE MODAL ══════════════════════════════════════════════════ -->
<div class="modal-overlay" id="approveModal">
    <div class="modal-box">
        <div class="modal-icon approve">
            <i class="fas fa-check-circle"></i>
        </div>
        <h4>Xác Nhận Duyệt Đơn</h4>
        <p>Sau khi duyệt, tài khoản nhân viên sẽ bị vô hiệu hóa và không thể đăng nhập hệ thống.<br>Hành động này <strong>không thể hoàn tác</strong>.</p>

        <div class="modal-info-box" id="approveInfoBox">
            <div class="info-row">
                <span>Nhân viên</span>
                <span id="approveEmployeeName">—</span>
            </div>
            <div class="info-row">
                <span>Ngày nghỉ dự kiến</span>
                <span id="approveDesiredDate">—</span>
            </div>
        </div>

        <form id="approveForm" action="${pageContext.request.contextPath}/hr/resignation-approval" method="post">
            <input type="hidden" name="action" value="approve">
            <input type="hidden" name="resignationId" id="approveResignationId">
        </form>

        <div class="modal-actions">
            <button class="btn-modal-cancel" onclick="closeApproveModal()">
                <i class="fas fa-arrow-left"></i> Hủy
            </button>
            <button class="btn-modal-confirm-approve"
                    onclick="document.getElementById('approveForm').submit()">
                <i class="fas fa-check"></i> Xác nhận duyệt
            </button>
        </div>
    </div>
</div>

<!-- ══ REJECT MODAL ═══════════════════════════════════════════════════ -->
<div class="modal-overlay" id="rejectModal">
    <div class="modal-box">
        <div class="modal-icon reject">
            <i class="fas fa-times-circle"></i>
        </div>
        <h4>Từ Chối Đơn Nghỉ Việc</h4>
        <p>Nhập lý do từ chối để nhân viên <strong id="rejectEmployeeName">—</strong> biết và cải thiện.</p>

        <form id="rejectForm" action="${pageContext.request.contextPath}/hr/resignation-approval" method="post">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="resignationId" id="rejectResignationId">

            <div class="form-group-modal">
                <label class="form-label-modal">
                    Lý do từ chối <span style="color:#e11d48;">*</span>
                </label>
                <textarea id="hrNoteInput" name="hrNote" class="form-control-modal"
                          placeholder="Ví dụ: Chưa có nhân viên thay thế, cần bàn giao công việc trước..."
                          required></textarea>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-modal-cancel" onclick="closeRejectModal()">
                    <i class="fas fa-arrow-left"></i> Hủy
                </button>
                <button type="submit" class="btn-modal-confirm-reject">
                    <i class="fas fa-times"></i> Xác nhận từ chối
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    // ── Approve Modal ──
    function openApproveModal(id, name, date) {
        document.getElementById('approveResignationId').value = id;
        document.getElementById('approveEmployeeName').textContent = name;
        document.getElementById('approveDesiredDate').textContent = date;
        document.getElementById('approveModal').classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function closeApproveModal() {
        document.getElementById('approveModal').classList.remove('active');
        document.body.style.overflow = '';
    }

    // ── Reject Modal ──
    function openRejectModal(id, name) {
        document.getElementById('rejectResignationId').value = id;
        document.getElementById('rejectEmployeeName').textContent = name;
        document.getElementById('hrNoteInput').value = '';
        document.getElementById('rejectModal').classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function closeRejectModal() {
        document.getElementById('rejectModal').classList.remove('active');
        document.body.style.overflow = '';
    }

    // ── Close when clicking overlay background ──
    document.getElementById('approveModal').addEventListener('click', function(e) {
        if (e.target === this) closeApproveModal();
    });

    document.getElementById('rejectModal').addEventListener('click', function(e) {
        if (e.target === this) closeRejectModal();
    });

    // ── ESC key ──
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeApproveModal();
            closeRejectModal();
        }
    });
</script>

<jsp:include page="../footer.jsp" />

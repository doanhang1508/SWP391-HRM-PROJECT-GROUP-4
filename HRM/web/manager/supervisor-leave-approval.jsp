<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Duyệt Nghỉ phép" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    footer,
    #chatWidget {
        display: none !important;
    }

    body {
        background-color: #f1f5f9 !important;
        font-family: 'Inter', -apple-system, sans-serif !important;
        padding-top: 0 !important;
        min-height: 100vh;
    }

    /* ── Offcanvas Detail Pane (Premium UI) ── */
    .offcanvas-pane {
        position: fixed;
        top: 0;
        right: -550px;
        width: 500px;
        height: 100vh;
        background: #f8fafc;
        box-shadow: -10px 0 40px rgba(0, 0, 0, 0.15);
        transition: right 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        z-index: 9999;
        display: flex;
        flex-direction: column;
    }

    .offcanvas-pane.open {
        right: 0;
    }

    .offcanvas-backdrop {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background: rgba(15, 23, 42, 0.5);
        backdrop-filter: blur(4px);
        z-index: 9998;
        opacity: 0;
        visibility: hidden;
        transition: all 0.4s;
    }

    .offcanvas-backdrop.open {
        opacity: 1;
        visibility: visible;
    }

    /* Header with gradient */
    .offcanvas-header {
        background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
        padding: 30px 24px 60px 24px;
        position: relative;
        color: white;
        border-bottom-left-radius: 20px;
        border-bottom-right-radius: 20px;
    }

    .offcanvas-title {
        font-size: 1.25rem;
        font-weight: 700;
        margin: 0;
        color: white;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .offcanvas-close {
        position: absolute;
        top: 24px;
        right: 24px;
        background: rgba(255, 255, 255, 0.2);
        border: none;
        font-size: 1.2rem;
        color: white;
        cursor: pointer;
        width: 36px;
        height: 36px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.2s, transform 0.2s;
    }

    .offcanvas-close:hover {
        background: rgba(255, 255, 255, 0.4);
        transform: scale(1.05);
    }

    /* Body Content */
    .offcanvas-body {
        padding: 0 24px 24px 24px;
        overflow-y: auto;
        flex: 1;
        margin-top: -40px;
        /* Pull up to overlap header */
        position: relative;
        z-index: 2;
    }

    /* Profile Card */
    .detail-profile-card {
        background: white;
        border-radius: 16px;
        padding: 20px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 24px;
        border: 1px solid rgba(255, 255, 255, 0.8);
    }

    .emp-avatar-large {
        width: 60px;
        height: 60px;
        border-radius: 16px;
        background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
        color: #334155;
        font-size: 1.5rem;
        font-weight: 800;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
    }

    /* Info Cards */
    .detail-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-bottom: 24px;
    }

    .detail-card {
        background: white;
        border-radius: 14px;
        padding: 16px;
        border: 1px solid #f1f5f9;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
    }

    .detail-icon-wrap {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 12px;
        font-size: 0.9rem;
    }

    .detail-label-premium {
        font-size: 0.75rem;
        font-weight: 600;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 4px;
    }

    .detail-value-premium {
        font-size: 1.05rem;
        font-weight: 700;
        color: #0f172a;
    }

    /* Block Info */
    .detail-block {
        background: white;
        border-radius: 14px;
        padding: 20px;
        border: 1px solid #f1f5f9;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
        margin-bottom: 24px;
    }

    .detail-block-title {
        font-size: 0.85rem;
        font-weight: 700;
        color: #475569;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .detail-reason-text {
        font-size: 0.95rem;
        color: #334155;
        line-height: 1.6;
        background: #f8fafc;
        padding: 16px;
        border-radius: 10px;
        border: 1px dashed #cbd5e1;
    }

    .detail-reject-reason {
        font-size: 0.95rem;
        color: #991b1b;
        line-height: 1.6;
        background: #fef2f2;
        padding: 16px;
        border-radius: 10px;
        border: 1px dashed #fecaca;
    }

    /* Footer */
    .offcanvas-footer {
        padding: 20px 24px;
        background: white;
        border-top: 1px solid #f1f5f9;
        display: flex;
        gap: 12px;
        justify-content: flex-end;
        box-shadow: 0 -4px 15px rgba(0, 0, 0, 0.02);
    }

    .btn-premium {
        padding: 10px 20px;
        border-radius: 10px;
        font-size: 0.9rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 8px;
        border: none;
    }

    .btn-premium-reject {
        background: #fee2e2;
        color: #dc2626;
        border: 1px solid #fecaca;
    }

    .btn-premium-reject:hover {
        background: #fecaca;
        transform: translateY(-1px);
    }

    .btn-premium-approve {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: white;
        box-shadow: 0 4px 10px rgba(16, 185, 129, 0.2);
    }

    .btn-premium-approve:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 15px rgba(16, 185, 129, 0.3);
    }

    /* ── Layout ── */
    .dashboard-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }

    .dash-main {
        flex: 1;
        min-width: 0;
        background: #f1f5f9;
    }

    .dash-content {
        padding: 28px 32px;
        display: flex;
        flex-direction: column;
        gap: 24px;
    }

    /* ── Page Header ── */
    .page-header-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
    }

    .page-header-left {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .page-breadcrumb {
        font-size: 0.78rem;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .page-breadcrumb a {
        color: #0d9488;
        text-decoration: none;
    }

    .page-breadcrumb a:hover {
        text-decoration: underline;
    }

    .page-title {
        font-size: 1.5rem;
        font-weight: 800;
        color: #0f172a;
        letter-spacing: -0.5px;
    }

    .page-role-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 14px;
        border-radius: 20px;
        font-size: 0.8rem;
        font-weight: 700;
        background: linear-gradient(135deg, #0d9488, #0369a1);
        color: #fff;
        box-shadow: 0 2px 8px rgba(13, 148, 136, 0.3);
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

    .scope-banner i {
        font-size: 1rem;
        color: #3b82f6;
        flex-shrink: 0;
    }

    /* ── Stat Cards ── */
    .stat-row {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
        gap: 16px;
    }

    .stat-mini {
        background: #fff;
        border-radius: 14px;
        padding: 18px 20px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        display: flex;
        align-items: center;
        gap: 14px;
        transition: transform 0.2s, box-shadow 0.2s;
    }

    .stat-mini:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 18px rgba(0, 0, 0, 0.07);
    }

    .stat-mini-icon {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.1rem;
        flex-shrink: 0;
    }

    .stat-mini-icon.warn {
        background: #fef3c7;
        color: #d97706;
    }

    .stat-mini-icon.info {
        background: #dbeafe;
        color: #2563eb;
    }

    .stat-mini-icon.success {
        background: #d1fae5;
        color: #059669;
    }

    .stat-mini-val {
        font-size: 1.5rem;
        font-weight: 800;
        color: #0f172a;
        line-height: 1;
    }

    .stat-mini-label {
        font-size: 0.75rem;
        color: #64748b;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-top: 2px;
    }

    /* ── Card ── */
    .mgr-card {
        background: #fff;
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
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

    .mgr-tab:hover {
        color: #0f172a;
    }

    .mgr-tab.active {
        color: #0d9488;
        border-bottom-color: #0d9488;
    }

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
    .mgr-tab-pane {
        display: none;
    }

    .mgr-tab-pane.active {
        display: block;
    }

    /* ── Table ── */
    .mgr-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }

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

    .mgr-table tbody tr:last-child td {
        border-bottom: none;
    }

    .mgr-table tbody tr:hover td {
        background: #f8fafc;
    }

    .emp-cell {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .emp-avatar {
        width: 34px;
        height: 34px;
        border-radius: 8px;
        background: linear-gradient(135deg, #0d9488, #1e40af);
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 0.82rem;
        flex-shrink: 0;
    }

    .emp-name {
        font-weight: 600;
    }

    .leave-type-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 0.78rem;
        font-weight: 600;
        background: #eff6ff;
        color: #2563eb;
    }

    .date-range {
        white-space: nowrap;
        font-size: 0.85rem;
        color: #475569;
    }

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
    .action-btns {
        display: flex;
        gap: 6px;
    }

    .btn-approve,
    .btn-reject {
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

    .btn-approve {
        background: #d1fae5;
        color: #059669;
    }

    .btn-approve:hover {
        background: #059669;
        color: #fff;
    }

    .btn-reject {
        background: #fee2e2;
        color: #dc2626;
    }

    .btn-reject:hover {
        background: #dc2626;
        color: #fff;
    }

    /* ── Empty State ── */
    .empty-state {
        padding: 60px 24px;
        text-align: center;
        color: #94a3b8;
    }

    .empty-state i {
        font-size: 2.5rem;
        margin-bottom: 16px;
        display: block;
    }

    .empty-state p {
        font-size: 0.95rem;
        font-weight: 500;
    }

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

    .alert-custom.success {
        background: #d1fae5;
        color: #065f46;
        border: 1px solid #a7f3d0;
    }

    .alert-custom.error {
        background: #fee2e2;
        color: #991b1b;
        border: 1px solid #fecaca;
    }

    /* ── OT Hours ── */
    .ot-hours {
        font-weight: 700;
        font-size: 0.95rem;
        color: #d97706;
    }

    .btn-detail {
        padding: 6px 14px;
        border-radius: 8px;
        font-size: 0.8rem;
        font-weight: 600;
        border: 1px solid #e2e8f0;
        background: #f8fafc;
        color: #475569;
        cursor: pointer;
        transition: all 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    .btn-detail:hover {
        background: #0d9488;
        color: #fff;
        border-color: #0d9488;
    }

    @media (max-width: 768px) {
        .dash-content {
            padding: 20px 16px;
        }

        .mgr-table th,
        .mgr-table td {
            padding: 10px 12px;
        }

        .reason-cell {
            max-width: 120px;
        }
    }
</style>

<div class="dashboard-wrapper">
    <%-- Shared Sidebar --%>
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="leave" />
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">

            <%-- Page Header --%>
            <div class="page-header-bar">
                <div class="page-header-left">
                    <div class="page-breadcrumb">
                        <a href="${pageContext.request.contextPath}/dashboard"><i
                                class="fas fa-home"></i> Dashboard</a>
                        <span>/</span>
                        <span>Duyệt nghỉ phép</span>
                    </div>
                    <div class="page-title">Duyệt Nghỉ phép</div>
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
                <c:when
                    test="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6 || sessionScope.currentUser.roleId == 2}">
                    <div class="scope-banner">
                        <i class="fas fa-filter"></i>
                        Bạn đang xem đơn của nhân viên thuộc phòng ban của mình.
                    </div>
                </c:when>
            </c:choose>

            <%-- Alerts --%>
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert-custom success">
                    <i class="fas fa-check-circle"></i> ${sessionScope.successMessage}
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert-custom error">
                    <i class="fas fa-exclamation-circle"></i>
                    ${sessionScope.errorMessage}
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <%-- Stats --%>
                <!-- DEBUG: pendingLeaves.size = ${fn:length(pendingLeaves)}, allLeaves.size = ${fn:length(allLeaves)}, userDeptId = ${sessionScope.currentUser.departmentId}, roleId = ${sessionScope.currentUser.roleId} -->
            <div class="stat-row">
                <div class="stat-mini">
                    <div class="stat-mini-icon warn"><i
                            class="fas fa-calendar-times"></i></div>
                    <div>
                        <div class="stat-mini-val">${fn:length(pendingLeaves)}</div>
                        <div class="stat-mini-label">Đơn nghỉ phép chờ</div>
                    </div>
                </div>
                <div class="stat-mini">
                    <div class="stat-mini-icon success"><i
                            class="fas fa-check-double"></i></div>
                    <div>
                        <div class="stat-mini-val">${fn:length(allLeaves)}</div>
                        <div class="stat-mini-label">Tổng lịch sử đơn</div>
                    </div>
                </div>
            </div>

            <%-- Main Card with Tabs --%>
            <div class="mgr-card">
                <div class="mgr-tabs">
                    <button type="button" class="mgr-tab active"
                            onclick="switchTab(event, 'leavePane')">
                        <i class="fas fa-umbrella-beach"></i> Đơn Nghỉ phép
                        <c:if test="${fn:length(pendingLeaves) > 0}">
                            <span
                                class="badge-count">${fn:length(pendingLeaves)}</span>
                        </c:if>
                    </button>
                    <button type="button" class="mgr-tab"
                            onclick="switchTab(event, 'historyPane')">
                        <i class="fas fa-history"></i> Lịch sử đơn
                        <c:if test="${fn:length(allLeaves) > 0}">
                            <span class="badge-count"
                                  style="background:#94a3b8;">${fn:length(allLeaves)}</span>
                        </c:if>
                    </button>
                </div>

                <!-- BỘ LỌC VÀ TÌM KIẾM -->
                <div class="filter-container" style="display: flex; flex-wrap: wrap; gap: 15px; margin-bottom: 20px; align-items: center; background: #f8fafc; padding: 15px; border-radius: 12px; border: 1px solid #e2e8f0;">
                    <div style="position: relative; flex: 1; min-width: 250px;">
                        <i class="fas fa-search" style="position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #94a3b8;"></i>
                        <input type="text" id="searchInput" placeholder="Tìm kiếm theo tên nhân viên, lý do..." class="form-control" style="padding-left: 40px; border-radius: 8px; border: 1px solid #cbd5e1; box-shadow: none;" onkeyup="applyFiltersAndPagination()">
                    </div>
                    <div style="min-width: 180px;">
                        <select id="typeFilter" class="form-select" style="border-radius: 8px; border: 1px solid #cbd5e1; box-shadow: none;" onchange="applyFiltersAndPagination()">
                            <option value="">Tất cả loại nghỉ</option>
                            <option value="Nghỉ ốm">Nghỉ ốm</option>
                            <option value="Nghỉ phép năm">Nghỉ phép năm</option>
                            <option value="Nghỉ không lương">Nghỉ không lương</option>

                            <option value="Khác">Khác</option>
                        </select>
                    </div>
                    <div id="statusFilterContainer" style="display: none; min-width: 180px;">
                        <select id="statusFilter" class="form-select" style="border-radius: 8px; border: 1px solid #cbd5e1; box-shadow: none;" onchange="applyFiltersAndPagination()">
                            <option value="">Tất cả trạng thái</option>
                            <option value="đã duyệt">Đã duyệt</option>
                            <option value="từ chối">Từ chối</option>
                            <option value="chờ duyệt">Chờ duyệt</option>
                        </select>
                    </div>
                    <div style="min-width: 120px;">
                        <select id="pageSizeFilter" class="form-select" style="border-radius: 8px; border: 1px solid #cbd5e1; box-shadow: none;" onchange="changePageSize()">
                            <option value="5">5 dòng/trang</option>
                            <option value="10" selected>10 dòng/trang</option>
                            <option value="20">20 dòng/trang</option>
                            <option value="50">50 dòng/trang</option>
                        </select>
                    </div>
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
                                            <th>Đính kèm</th>
                                            <th>Ngày gửi</th>
                                            <th style="text-align:center;">
                                                Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="lr"
                                                   items="${pendingLeaves}">
                                            <tr>
                                                <td>
                                                    <div class="emp-cell">
                                                        <div
                                                            class="emp-avatar">
                                                            ${fn:substring(lr.userName,
                                                              0, 1)}</div>
                                                        <span
                                                            class="emp-name">${lr.userName}</span>
                                                    </div>
                                                </td>
                                                <td><span
                                                        class="leave-type-badge"><i
                                                            class="fas fa-tag"></i>
                                                        ${lr.leaveTypeName}</span>
                                                </td>
                                                <td class="date-range">
                                                    <div>
                                                        <fmt:formatDate
                                                            value="${lr.startDate}"
                                                            pattern="dd/MM/yyyy" />
                                                        <i class="fas fa-arrow-right"
                                                           style="font-size:0.65rem;color:#cbd5e1;margin:0 4px;"></i>
                                                        <fmt:formatDate
                                                            value="${lr.endDate}"
                                                            pattern="dd/MM/yyyy" />
                                                    </div>

                                                    <%-- Conflict Check --%>
                                                    <c:set
                                                        var="conflictFound"
                                                        value="false" />
                                                    <c:set
                                                        var="conflictNames"
                                                        value="" />
                                                    <c:forEach var="al"
                                                               items="${approvedLeaves}">
                                                        <c:if
                                                            test="${al.userId != lr.userId}">
                                                            <c:if
                                                                test="${lr.endDate.time >= al.startDate.time && lr.startDate.time <= al.endDate.time}">
                                                                <c:set
                                                                    var="conflictFound"
                                                                    value="true" />
                                                                <c:set
                                                                    var="conflictNames"
                                                                    value="${conflictNames} - ${al.userName} (${al.startDate} đến ${al.endDate})&#10;" />
                                                            </c:if>
                                                        </c:if>
                                                    </c:forEach>

                                                    <c:if
                                                        test="${conflictFound}">
                                                        <div
                                                            style="margin-top: 6px;">
                                                            <span
                                                                class="badge"
                                                                style="background:#fef3c7; color:#d97706; border:1px solid #fde68a; cursor:help;"
                                                                title="Nhân sự khác đang nghỉ cùng thời điểm:&#10;${conflictNames}">
                                                                <i
                                                                    class="fas fa-exclamation-triangle"></i>
                                                                Trùng
                                                                lịch
                                                            </span>
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td><strong>${lr.totalDays}</strong>
                                                </td>
                                                <td class="reason-cell"
                                                    title="${lr.reason}">
                                                    ${lr.reason}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when
                                                            test="${not empty lr.attachment}">
                                                            <a href="${pageContext.request.contextPath}/${lr.attachment}"
                                                               target="_blank"
                                                               class="badge bg-info text-decoration-none"
                                                               style="padding: 6px 10px;">
                                                                <i
                                                                    class="fas fa-file-download"></i>
                                                                Xem
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span
                                                                style="color:#94a3b8; font-size:0.8rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td
                                                    style="color:#94a3b8;font-size:0.82rem;">
                                                    <fmt:formatDate
                                                        value="${lr.createdAt}"
                                                        pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                                <td>
                                                    <div class="action-btns"
                                                         style="justify-content:center;">
                                                        <button class="btn-detail" onclick="openLeaveDetail('${lr.requestId}', '${fn:escapeXml(lr.userName)}', '${fn:escapeXml(lr.leaveTypeName)}', '<fmt:formatDate value="${lr.startDate}" pattern="dd/MM/yyyy" />', '<fmt:formatDate value="${lr.endDate}" pattern="dd/MM/yyyy" />', '${lr.totalDays}', '${fn:escapeXml(lr.reason)}', '${lr.status}', '${lr.attachment}', '${fn:escapeXml(lr.rejectReason)}')">
                                                            <i class="fas fa-search"></i> Chi tiết
                                                        </button>
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
                                <p>Không có đơn nghỉ phép nào đang chờ duyệt
                                </p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- HISTORY TAB --%>
                <div class="mgr-tab-pane" id="historyPane">
                    <c:choose>
                        <c:when test="${not empty allLeaves}">
                            <div class="table-responsive">
                                <table class="mgr-table">
                                    <thead>
                                        <tr>
                                            <th>Nhân viên</th>
                                            <th>Loại nghỉ</th>
                                            <th>Thời gian</th>
                                            <th>Số ngày</th>
                                            <th>Lý do</th>
                                            <th>Đính kèm</th>
                                            <th>Ngày gửi</th>
                                            <th>Trạng thái</th>
                                            <th
                                                style="text-align:center;">
                                                Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="lr"
                                                   items="${allLeaves}">
                                            <tr>
                                                <td>
                                                    <div
                                                        class="emp-cell">
                                                        <div class="emp-avatar"
                                                             style="background:#e2e8f0;color:#64748b;">
                                                            ${fn:substring(lr.userName,
                                                              0, 1)}</div>
                                                        <span
                                                            class="emp-name">${lr.userName}</span>
                                                    </div>
                                                </td>
                                                <td><span
                                                        class="leave-type-badge"><i
                                                            class="fas fa-tag"></i>
                                                        ${lr.leaveTypeName}</span>
                                                </td>
                                                <td class="date-range">
                                                    <fmt:formatDate
                                                        value="${lr.startDate}"
                                                        pattern="dd/MM/yyyy" />
                                                    <i class="fas fa-arrow-right"
                                                       style="font-size:0.65rem;color:#cbd5e1;margin:0 4px;"></i>
                                                    <fmt:formatDate
                                                        value="${lr.endDate}"
                                                        pattern="dd/MM/yyyy" />
                                                </td>
                                                <td><strong>${lr.totalDays}</strong>
                                                </td>
                                                <td class="reason-cell"
                                                    title="${lr.reason}">
                                                    ${lr.reason}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when
                                                            test="${not empty lr.attachment}">
                                                            <a href="${pageContext.request.contextPath}/${lr.attachment}"
                                                               target="_blank"
                                                               class="badge bg-info text-decoration-none"
                                                               style="padding: 6px 10px;">
                                                                <i
                                                                    class="fas fa-file-download"></i>
                                                                Xem
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span
                                                                style="color:#94a3b8; font-size:0.8rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td
                                                    style="color:#94a3b8;font-size:0.82rem;">
                                                    <fmt:formatDate
                                                        value="${lr.createdAt}"
                                                        pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when
                                                            test="${lr.status == 'Approved'}">
                                                            <span
                                                                class="badge"
                                                                style="background:#dcfce7;color:#166534;"><i
                                                                    class="fas fa-check"></i>
                                                                Đã
                                                                duyệt</span>
                                                            </c:when>
                                                            <c:when
                                                                test="${lr.status == 'Rejected'}">
                                                            <span
                                                                class="badge"
                                                                style="background:#fee2e2;color:#991b1b;"><i
                                                                    class="fas fa-times"></i>
                                                                Từ
                                                                chối</span>
                                                                <c:if
                                                                    test="${not empty lr.rejectReason}">
                                                                <div style="font-size:0.75rem; color:#dc3545; margin-top:4px; font-style:italic;"
                                                                     title="${lr.rejectReason}">
                                                                    <i
                                                                        class="fas fa-info-circle"></i>
                                                                    ${lr.rejectReason}
                                                                </div>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span
                                                                class="badge"
                                                                style="background:#fef9c3;color:#854d0e;"><i
                                                                    class="fas fa-clock"></i>
                                                                Chờ
                                                                duyệt</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                </td>
                                                <td>
                                                    <button class="btn-detail" onclick="openLeaveDetail('${lr.requestId}', '${fn:escapeXml(lr.userName)}', '${fn:escapeXml(lr.leaveTypeName)}', '<fmt:formatDate value="${lr.startDate}" pattern="dd/MM/yyyy" />', '<fmt:formatDate value="${lr.endDate}" pattern="dd/MM/yyyy" />', '${lr.totalDays}', '${fn:escapeXml(lr.reason)}', '${lr.status}', '${lr.attachment}', '${fn:escapeXml(lr.rejectReason)}')">
                                                        <i class="fas fa-search"></i> Chi tiết
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-folder-open"></i>
                                <p>Chưa có lịch sử đơn xin nghỉ phép nào
                                </p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>


            </div>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div><%-- end dashboard-wrapper --%>

<!-- Offcanvas Backdrop & Panel -->
<div class="offcanvas-backdrop" id="leaveDetailBackdrop" onclick="closeLeaveDetail()"></div>
<div class="offcanvas-pane" id="leaveDetailPane">
    <div class="offcanvas-header">
        <h4 class="offcanvas-title"><i class="fas fa-file-invoice"></i> Chi tiết đơn nghỉ phép</h4>
        <button class="offcanvas-close" onclick="closeLeaveDetail()"><i
                class="fas fa-times"></i></button>
    </div>

    <div class="offcanvas-body">
        <!-- Profile Card -->
        <div class="detail-profile-card">
            <div class="emp-avatar-large" id="detailAvatar">A</div>
            <div>
                <div class="detail-value-premium" style="font-size:1.2rem;" id="detailName">Nguyễn
                    Văn A</div>
                <div style="margin-top:6px;" id="detailStatus"><span class="badge bg-warning">Chờ
                        duyệt</span></div>
            </div>
        </div>

        <!-- Info Grid -->
        <div class="detail-grid">
            <div class="detail-card">
                <div class="detail-icon-wrap" style="background:#e0e7ff; color:#4f46e5;">
                    <i class="fas fa-tag"></i>
                </div>
                <div class="detail-label-premium">Loại nghỉ phép</div>
                <div class="detail-value-premium" id="detailType" style="font-size:0.95rem;">Nghỉ ốm
                </div>
            </div>
            <div class="detail-card">
                <div class="detail-icon-wrap" style="background:#fef3c7; color:#d97706;">
                    <i class="fas fa-calendar-day"></i>
                </div>
                <div class="detail-label-premium">Số ngày nghỉ</div>
                <div class="detail-value-premium"><span id="detailTotalDays">3</span> ngày</div>
            </div>
            <div class="detail-card">
                <div class="detail-icon-wrap" style="background:#f1f5f9; color:#64748b;">
                    <i class="fas fa-hourglass-start"></i>
                </div>
                <div class="detail-label-premium">Bắt đầu</div>
                <div class="detail-value-premium" id="detailStartDate" style="font-size:0.9rem;">
                    01/01/2026</div>
            </div>
            <div class="detail-card">
                <div class="detail-icon-wrap" style="background:#f1f5f9; color:#64748b;">
                    <i class="fas fa-hourglass-end"></i>
                </div>
                <div class="detail-label-premium">Kết thúc</div>
                <div class="detail-value-premium" id="detailEndDate" style="font-size:0.9rem;">
                    03/01/2026</div>
            </div>
        </div>

        <!-- Reason Block -->
        <div class="detail-block">
            <div class="detail-block-title"><i class="fas fa-comment-dots text-secondary"></i> Lý do
                xin nghỉ</div>
            <div class="detail-reason-text" id="detailReason">Lý do...</div>
        </div>

        <!-- Reject Reason Block -->
        <div class="detail-block" id="detailRejectReasonContainer"
             style="display:none; border-color:#fecaca;">
            <div class="detail-block-title" style="color:#dc2626;"><i
                    class="fas fa-exclamation-circle text-danger"></i> Lý do từ chối</div>
            <div class="detail-reject-reason" id="detailRejectReason">...</div>
        </div>

        <!-- Attachment Block -->
        <div class="detail-block" id="detailAttachmentContainer" style="display:none;">
            <div class="detail-block-title"><i class="fas fa-paperclip text-secondary"></i> Tài liệu
                đính kèm</div>
            <div style="margin-top:12px;">
                <a href="#" id="detailAttachment" target="_blank"
                   class="badge bg-info text-decoration-none"
                   style="padding: 10px 16px; font-size:0.9rem; border-radius:8px;">
                    <i class="fas fa-file-download me-1"></i> Nhấn để tải / xem tài liệu
                </a>
            </div>
        </div>

        <!-- Inline Reject Input -->
        <div class="detail-block" id="detailRejectInputContainer"
             style="display:none; border-color:#fecaca; background:#fef2f2;">
            <div class="detail-block-title" style="color:#dc2626;"><i class="fas fa-ban"></i> Nhập
                lý do từ chối</div>
            <textarea id="inlineRejectReason" rows="3" class="form-control"
                      style="border: 1px solid #fca5a5; border-radius: 8px; width: 100%; padding: 10px; font-size: 0.95rem; margin-bottom:12px;"
                      placeholder="Ví dụ: Không đủ nhân sự ca này..."></textarea>
            <div style="display:flex; justify-content:flex-end; gap:8px;">
                <button type="button" class="btn btn-sm btn-outline-secondary"
                        onclick="cancelInlineReject()">Hủy</button>
                <button type="button" class="btn btn-sm btn-danger"
                        onclick="confirmInlineReject()">Xác nhận từ chối</button>
            </div>
        </div>
    </div>

    <div class="offcanvas-footer" id="detailFooter">
        <form action="${pageContext.request.contextPath}/manager/leave" method="POST"
              id="rejectForm" style="display:inline;">
            <input type="hidden" name="type" value="leave">
            <input type="hidden" name="id" id="rejectRequestId">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="rejectReason" id="rejectReasonInput"
                   class="rejectReasonInput">
            <button type="button" class="btn-premium btn-premium-reject"
                    onclick="showInlineReject()">
                <i class="fas fa-times"></i> Từ chối
            </button>
        </form>
        <form action="${pageContext.request.contextPath}/manager/leave" method="POST"
              id="approveForm" style="display:inline;">
            <input type="hidden" name="type" value="leave">
            <input type="hidden" name="id" id="approveRequestId">
            <input type="hidden" name="action" value="approve">
            <button type="submit" class="btn-premium btn-premium-approve"
                    onclick="return confirm('Duyệt đơn nghỉ phép này?');">
                <i class="fas fa-check"></i> Duyệt
            </button>
        </form>
    </div>
</div>

<script>
    let currentPage = 1;
    let rowsPerPage = 10;

    function changePageSize() {
        rowsPerPage = parseInt(document.getElementById('pageSizeFilter').value);
        currentPage = 1;
        applyFiltersAndPagination();
    }

    function applyFiltersAndPagination() {
        const activePane = document.querySelector('.mgr-tab-pane.active');
        if (!activePane)
            return;

        const table = activePane.querySelector('table tbody');
        if (!table)
            return;

        const rows = Array.from(table.querySelectorAll('tr'));
        if (rows.length === 0)
            return;

        const searchValue = document.getElementById('searchInput').value.toLowerCase();
        const typeValue = document.getElementById('typeFilter').value.toLowerCase();
        const statusValue = document.getElementById('statusFilter').value.toLowerCase();

        let filteredRows = [];

        rows.forEach(row => {
            const empName = row.querySelector('.emp-name') ? row.querySelector('.emp-name').textContent.toLowerCase() : '';
            const reason = row.querySelector('.reason-cell') ? row.querySelector('.reason-cell').textContent.toLowerCase() : '';
            const leaveType = row.querySelector('.leave-type-badge') ? row.querySelector('.leave-type-badge').textContent.toLowerCase() : '';

            let status = '';
            if (activePane.id === 'historyPane') {
                const statusBadge = row.querySelector('td:nth-child(8) .badge');
                if (statusBadge)
                    status = statusBadge.textContent.toLowerCase();
            }

            const matchSearch = empName.includes(searchValue) || reason.includes(searchValue);
            const matchType = typeValue === '' || leaveType.includes(typeValue);
            const matchStatus = statusValue === '' || status.includes(statusValue);

            if (matchSearch && matchType && matchStatus) {
                filteredRows.push(row);
            } else {
                row.style.display = 'none';
            }
        });

        const totalPages = Math.ceil(filteredRows.length / rowsPerPage);
        if (currentPage > totalPages && totalPages > 0)
            currentPage = totalPages;
        if (currentPage === 0 && totalPages > 0)
            currentPage = 1;

        const startIndex = (currentPage - 1) * rowsPerPage;
        const endIndex = startIndex + rowsPerPage;

        filteredRows.forEach((row, index) => {
            if (index >= startIndex && index < endIndex) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });

        renderPagination(totalPages, activePane);
    }

    function renderPagination(totalPages, activePane) {
        let paginationContainer = activePane.querySelector('.pagination-container');
        if (!paginationContainer) {
            paginationContainer = document.createElement('div');
            paginationContainer.className = 'pagination-container';
            paginationContainer.style.display = 'flex';
            paginationContainer.style.justifyContent = 'space-between';
            paginationContainer.style.alignItems = 'center';
            paginationContainer.style.marginTop = '20px';
            paginationContainer.style.padding = '10px 0';
            activePane.appendChild(paginationContainer);
        }

        if (totalPages <= 1) {
            paginationContainer.innerHTML = '';
            return;
        }

        let html = '<div style="color: #64748b; font-size: 0.9rem;">Trang ' + currentPage + ' / ' + totalPages + '</div>';
        html += '<div style="display: flex; gap: 5px;">';
        html += '<button class="btn btn-sm btn-outline-secondary" onclick="changePage(' + (currentPage - 1) + ')" ' + (currentPage === 1 ? 'disabled' : '') + '>Trước</button>';

        for (let i = 1; i <= totalPages; i++) {
            if (i === 1 || i === totalPages || (i >= currentPage - 1 && i <= currentPage + 1)) {
                let btnClass = (i === currentPage) ? 'btn-primary' : 'btn-outline-secondary';
                html += '<button class="btn btn-sm ' + btnClass + '" onclick="changePage(' + i + ')">' + i + '</button>';
            } else if (i === currentPage - 2 || i === currentPage + 2) {
                html += '<span style="padding: 4px 8px; color: #94a3b8;">...</span>';
            }
        }

        html += '<button class="btn btn-sm btn-outline-secondary" onclick="changePage(' + (currentPage + 1) + ')" ' + (currentPage === totalPages ? 'disabled' : '') + '>Sau</button>';
        html += '</div>';

        paginationContainer.innerHTML = html;
    }

    function changePage(page) {
        currentPage = page;
        applyFiltersAndPagination();
    }

    document.addEventListener('DOMContentLoaded', () => {
        applyFiltersAndPagination();
    });

    function switchTab(evt, tabId) {
        document.querySelectorAll('.mgr-tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.mgr-tab-pane').forEach(p => p.classList.remove('active'));
        evt.currentTarget.classList.add('active');
        document.getElementById(tabId).classList.add('active');

        if (tabId === 'historyPane') {
            document.getElementById('statusFilterContainer').style.display = 'block';
        } else {
            document.getElementById('statusFilterContainer').style.display = 'none';
            document.getElementById('statusFilter').value = '';
        }

        currentPage = 1;
        applyFiltersAndPagination();
    }

    function handleReject(form, userName) {
        let reason = prompt('Vui lòng nhập lý do từ chối đơn xin nghỉ phép của ' + userName + ':');
        if (reason === null) {
            return false; // User cancelled
        }
        if (reason.trim() === '') {
            alert('Bạn phải nhập lý do từ chối để nhân viên hiểu rõ nguyên nhân!');
            return false;
        }
        form.querySelector('.rejectReasonInput').value = reason.trim();
        return true;
    }

    function openLeaveDetail(id, name, type, startDate, endDate, totalDays, reason, status, attachment, rejectReason) {
        document.getElementById('detailAvatar').innerText = name.substring(0, 1);
        document.getElementById('detailName').innerText = name;
        document.getElementById('detailType').innerHTML = '<i class="fas fa-tag" style="color:#64748b; margin-right:6px;"></i>' + type;
        document.getElementById('detailStartDate').innerText = startDate;
        document.getElementById('detailEndDate').innerText = endDate;
        document.getElementById('detailTotalDays').innerText = totalDays;
        document.getElementById('detailReason').innerText = reason;

        // Status Badge
        let statusHtml = '';
        if (status === 'Approved')
            statusHtml = '<span class="badge" style="background:#dcfce7;color:#166534;">Đã duyệt</span>';
        else if (status === 'Rejected')
            statusHtml = '<span class="badge" style="background:#fee2e2;color:#991b1b;">Từ chối</span>';
        else
            statusHtml = '<span class="badge" style="background:#fef9c3;color:#854d0e;">Chờ duyệt</span>';
        document.getElementById('detailStatus').innerHTML = statusHtml;

        // Attachment
        let attachContainer = document.getElementById('detailAttachmentContainer');
        if (attachment && attachment.trim() !== '') {
            attachContainer.style.display = 'block';
            document.getElementById('detailAttachment').href = '${pageContext.request.contextPath}/' + attachment;
        } else {
            attachContainer.style.display = 'none';
        }

        // Reject Reason (if Rejected)
        let rejectContainer = document.getElementById('detailRejectReasonContainer');
        if (status === 'Rejected' && rejectReason && rejectReason.trim() !== '') {
            rejectContainer.style.display = 'block';
            document.getElementById('detailRejectReason').innerText = rejectReason;
        } else {
            rejectContainer.style.display = 'none';
        }

        // Footer actions
        let footer = document.getElementById('detailFooter');
        if (status === 'Pending') {
            footer.style.display = 'flex';
            document.getElementById('approveRequestId').value = id;
            document.getElementById('rejectRequestId').value = id;

            // Reset inline reject area
            document.getElementById('detailRejectInputContainer').style.display = 'none';
            document.getElementById('inlineRejectReason').value = '';
            footer.style.display = 'flex';
        } else {
            footer.style.display = 'none';
            document.getElementById('detailRejectInputContainer').style.display = 'none';
        }

        // Open Offcanvas
        document.getElementById('leaveDetailPane').classList.add('open');
        document.getElementById('leaveDetailBackdrop').classList.add('open');
    }

    function closeLeaveDetail() {
        document.getElementById('leaveDetailPane').classList.remove('open');
        document.getElementById('leaveDetailBackdrop').classList.remove('open');
    }

    function showInlineReject() {
        document.getElementById('detailRejectInputContainer').style.display = 'block';
        document.getElementById('detailFooter').style.display = 'none'; // Hide the normal footer buttons
        document.getElementById('inlineRejectReason').focus();
    }

    function cancelInlineReject() {
        document.getElementById('detailRejectInputContainer').style.display = 'none';
        document.getElementById('inlineRejectReason').value = '';
        document.getElementById('detailFooter').style.display = 'flex'; // Restore normal footer buttons
    }

    function confirmInlineReject() {
        let reason = document.getElementById('inlineRejectReason').value.trim();
        if (reason === '') {
            alert('Bạn phải nhập lý do từ chối!');
            document.getElementById('inlineRejectReason').focus();
            return;
        }
        // Set value and submit
        document.getElementById('rejectReasonInput').value = reason;
        document.getElementById('rejectForm').submit();
    }
</script>

<jsp:include page="../footer.jsp" />
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    int pendingContractsCount = 0;
    if (session.getAttribute("currentUser") != null) {
        model.User cu = (model.User) session.getAttribute("currentUser");
        pendingContractsCount = new dao.EmployeeContractDAO().getPendingSignContracts(cu.getUserId()).size();
    }
    request.setAttribute("pendingContractsCount", pendingContractsCount);
%>
<style>
    /* ─── SIDEBAR BASE ─────────────────────────────────── */
    .admin-sidebar {
        width: 260px;
        background: #0f172a;
        border-right: 1px solid #1e293b;
        padding: 0;
        position: sticky;
        top: 64px;
        height: calc(100vh - 64px);
        overflow-y: auto;
        flex-shrink: 0;
        transition: transform 0.3s cubic-bezier(.22, 1, .36, 1);
        z-index: 990;
        display: flex;
        flex-direction: column;
    }

    .admin-sidebar::-webkit-scrollbar {
        width: 4px;
    }

    .admin-sidebar::-webkit-scrollbar-track {
        background: #0f172a;
    }

    .admin-sidebar::-webkit-scrollbar-thumb {
        background: #334155;
        border-radius: 2px;
    }

    /* ─── SIDEBAR HEADER / LOGO ─────────────────────────── */
    .sidebar-brand {
        padding: 20px 24px;
        border-bottom: 1px solid #1e293b;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .sidebar-brand-icon {
        width: 36px;
        height: 36px;
        background: #0d9488;
        border-radius: 9px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        color: #fff;
        flex-shrink: 0;
    }

    .sidebar-brand-text {
        font-size: 1.05rem;
        font-weight: 800;
        color: #fff;
        letter-spacing: -0.3px;
    }

    .sidebar-brand-sub {
        font-size: 0.7rem;
        color: #64748b;
        font-weight: 500;
        margin-top: 1px;
    }

    /* ─── USER INFO ─────────────────────────────────────── */
    .sidebar-user {
        padding: 16px 24px;
        border-bottom: 1px solid #1e293b;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .sidebar-user-avatar {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        background: linear-gradient(135deg, #0d9488 0%, #1e40af 100%);
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 800;
        font-size: 1rem;
        flex-shrink: 0;
    }

    .sidebar-user-name {
        font-size: 0.88rem;
        font-weight: 700;
        color: #f1f5f9;
        line-height: 1.2;
    }

    .sidebar-user-role {
        font-size: 0.72rem;
        color: #64748b;
        font-weight: 500;
        margin-top: 2px;
    }

    /* ─── SIDEBAR MENU ──────────────────────────────────── */
    .sidebar-nav {
        flex: 1;
        padding: 16px 12px;
    }

    .sidebar-menu {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .sidebar-menu-category {
        padding: 12px 12px 6px;
        font-size: 0.68rem;
        font-weight: 700;
        color: #475569;
        text-transform: uppercase;
        letter-spacing: 1.2px;
        margin-top: 4px;
    }

    .sidebar-item {
        margin-bottom: 2px;
    }

    .sidebar-link {
        display: flex;
        align-items: center;
        padding: 10px 12px;
        color: #94a3b8;
        text-decoration: none;
        font-weight: 500;
        font-size: 0.88rem;
        transition: all 0.2s ease;
        border-radius: 8px;
        gap: 10px;
    }

    .sidebar-link i {
        width: 20px;
        font-size: 0.95rem;
        color: #475569;
        transition: color 0.2s ease;
        text-align: center;
        flex-shrink: 0;
    }

    .sidebar-link:hover {
        background: rgba(255, 255, 255, 0.06);
        color: #e2e8f0;
    }

    .sidebar-link:hover i {
        color: #94a3b8;
    }

    .sidebar-link.active {
        background: #0d9488;
        color: #fff;
        box-shadow: 0 2px 8px rgba(13, 148, 136, 0.35);
    }

    .sidebar-link.active i {
        color: #fff;
    }

    /* ─── SIDEBAR FOOTER ────────────────────────────────── */
    .sidebar-footer {
        padding: 12px;
        border-top: 1px solid #1e293b;
    }

    .sidebar-logout {
        display: flex;
        align-items: center;
        padding: 10px 12px;
        color: #f87171;
        text-decoration: none;
        font-weight: 600;
        font-size: 0.88rem;
        border-radius: 8px;
        gap: 10px;
        transition: all 0.2s ease;
    }

    .sidebar-logout i {
        width: 20px;
        text-align: center;
        color: #f87171;
        flex-shrink: 0;
    }

    .sidebar-logout:hover {
        background: rgba(248, 113, 113, 0.12);
        color: #fca5a5;
    }

    .sidebar-logout:hover i {
        color: #fca5a5;
    }

    /* ─── MOBILE ──────────────────────────────────────────── */
    .sidebar-toggle-btn {
        display: none;
        position: fixed;
        top: 72px;
        left: 16px;
        z-index: 1050;
        width: 42px;
        height: 42px;
        border-radius: 10px;
        background: #0d9488;
        color: #fff;
        border: none;
        cursor: pointer;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        box-shadow: 0 4px 14px rgba(13, 148, 136, 0.4);
        transition: background 0.2s, transform 0.2s;
    }

    .sidebar-toggle-btn:hover {
        background: #0f766e;
        transform: scale(1.05);
    }

    .sidebar-close-btn {
        display: none;
        position: absolute;
        top: 12px;
        right: 12px;
        background: rgba(255, 255, 255, 0.1);
        border: none;
        font-size: 16px;
        color: #94a3b8;
        cursor: pointer;
        padding: 6px 8px;
        border-radius: 6px;
    }

    .sidebar-close-btn:hover {
        background: rgba(255, 255, 255, 0.15);
        color: #fff;
    }

    .sidebar-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.6);
        z-index: 1039;
        backdrop-filter: blur(2px);
        opacity: 0;
        transition: opacity 0.3s ease;
    }

    .sidebar-overlay.active {
        opacity: 1;
    }

    @media (max-width: 768px) {
        .admin-sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            transform: translateX(-100%);
            padding-top: 56px;
            box-shadow: 6px 0 30px rgba(0, 0, 0, 0.4);
            z-index: 1040;
        }

        .admin-sidebar.sidebar-open {
            transform: translateX(0);
        }

        .sidebar-toggle-btn {
            display: flex;
        }

        .sidebar-close-btn {
            display: block;
        }

        .sidebar-overlay {
            display: block;
        }

        .main-content {
            width: 100% !important;
            padding: 20px 16px !important;
        }
    }
</style>

<%-- ── Overlay & Toggle ─────────────────────────────── --%>
<div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
<button class="sidebar-toggle-btn" id="sidebarToggleBtn" onclick="toggleSidebar()" aria-label="Mở menu">
    <i class="fas fa-bars"></i>
</button>

<%-- ── Sidebar ────────────────────────────────────────── --%>
<aside class="admin-sidebar" id="adminSidebar">
    <button class="sidebar-close-btn" onclick="closeSidebar()" aria-label="Đóng menu">
        <i class="fas fa-times"></i>
    </button>


    <%-- User Info --%>
    <div class="sidebar-user">
        <div class="sidebar-user-avatar">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser.fullName}">
                    ${sessionScope.currentUser.fullName.substring(0,1)}
                </c:when>
                <c:otherwise>?</c:otherwise>
            </c:choose>
        </div>
        <div>
            <div class="sidebar-user-name">
                <c:out value="${not empty sessionScope.currentUser.fullName
                                ? sessionScope.currentUser.fullName : sessionScope.currentUser.email}" />
            </div>
            <div class="sidebar-user-role">
                <c:choose>
                    <c:when test="${sessionScope.currentUser.roleId == 1}">Quản trị viên</c:when>
                    <c:when test="${sessionScope.currentUser.roleId == 2}">HR Manager</c:when>
                    <c:when test="${sessionScope.currentUser.roleId == 3}">Quản đốc xưởng</c:when>
                    <c:when test="${sessionScope.currentUser.roleId == 4}">Giám đốc</c:when>
                    <c:when test="${sessionScope.currentUser.roleId == 5}">Nhân viên HR</c:when>
                    <c:when test="${sessionScope.currentUser.roleId == 6}">Quản lý phòng ban
                    </c:when>
                    <c:when test="${sessionScope.currentUser.roleId == 7}">Nhân viên</c:when>
                    <c:when test="${sessionScope.currentUser.roleId == 8}">Kế Toán</c:when>
                    <c:otherwise>Nhân viên</c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <%-- Navigation — phân quyền theo role --%>
    <nav class="sidebar-nav">
        <ul class="sidebar-menu">

            <%-- ══════ MENU CHUNG cho mọi role ══════ --%>
            <c:if test="${sessionScope.currentUser.roleId != 4}">
                <li class="sidebar-menu-category">Tổng quan</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/dashboard"
                       class="sidebar-link ${param.activeMenu eq 'dashboard' ? 'active' : ''}">
                        <i class="fas fa-chart-line"></i> Bảng điều khiển
                    </a>
                </li>
            </c:if>

            <%-- ══════ Lịch nghỉ lễ: hiển thị cho TOÀN BỘ nhân viên công ty ══════ --%>
            <li class="sidebar-item">
                <a href="${pageContext.request.contextPath}/hr/holiday"
                   class="sidebar-link ${param.activeMenu eq 'holiday' ? 'active' : ''}">
                    <i class="fas fa-calendar-day"></i> Lịch nghỉ lễ công ty
                </a>
            </li>

            <%-- ══════ ADMIN (roleId=1): CHỈ quản trị hệ thống ══════ --%>
            <c:if test="${sessionScope.currentUser.roleId == 1}">
                <li class="sidebar-menu-category">Quản trị Hệ thống</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/admin/users"
                       class="sidebar-link ${param.activeMenu eq 'users' ? 'active' : ''}">
                        <i class="fas fa-users-cog"></i> Quản lý Người dùng
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/admin/onboarding/list"
                       class="sidebar-link ${param.activeMenu eq 'onboarding-admin' ? 'active' : ''}">
                        <i class="fas fa-user-clock"></i> Tiếp nhận nhân viên
                    </a>
                </li>

                <li class="sidebar-menu-category">Phân quyền</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/role?action=list"
                       class="sidebar-link ${param.activeMenu eq 'roles' ? 'active' : ''}">
                        <i class="fas fa-user-shield"></i> Quản lý Vai trò
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/editRolePermission"
                       class="sidebar-link ${param.activeMenu eq 'permissions' ? 'active' : ''}">
                        <i class="fas fa-key"></i> Phân quyền hệ thống
                    </a>
                </li>


            </c:if>

            <%-- ══════ HR MANAGER (roleId=2): Quản lý nhân sự ══════ --%>
            <c:if test="${sessionScope.currentUser.roleId == 2}">

                <%-- ── Nhân viên & Hợp đồng ── --%>
                <li class="sidebar-menu-category">Nhân viên &amp; Hợp đồng</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/employees"
                       class="sidebar-link ${param.activeMenu eq 'employees' ? 'active' : ''}">
                        <i class="fas fa-users"></i> Danh sách nhân viên
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/contract-approval"
                       class="sidebar-link ${param.activeMenu eq 'contract-approval' ? 'active' : ''}">
                        <i class="fas fa-clipboard-check"></i> Duyệt Hợp đồng
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/contracts"
                       class="sidebar-link ${param.activeMenu eq 'contract-management' ? 'active' : ''}">
                        <i class="fas fa-file-signature"></i> Quản lý Hợp đồng
                    </a>
                </li>



                <%-- ── KPI ── --%>
                <li class="sidebar-menu-category">KPI</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/employee-kpi"
                       class="sidebar-link ${param.activeMenu eq 'employee-kpi' ? 'active' : ''}">
                        <i class="fas fa-star"></i> Đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/kpi-history"
                       class="sidebar-link ${param.activeMenu eq 'kpi-history' ? 'active' : ''}">
                        <i class="fas fa-history"></i> Lịch sử đánh giá KPI
                    </a>
                </li>

                <%-- ── Chấm công ── --%>
                <li class="sidebar-menu-category">Chấm công</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/timesheet-confirm"
                       class="sidebar-link ${param.activeMenu eq 'timesheet-confirm' ? 'active' : ''}">
                        <i class="fas fa-check-double"></i> Xác nhận bảng công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/timesheet-approval"
                       class="sidebar-link ${param.activeMenu eq 'timesheet-approval' ? 'active' : ''}">
                        <i class="fas fa-user-check"></i> Duyệt bảng công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/attendance-management?action=detail"
                       class="sidebar-link ${param.activeMenu eq 'attendance-summary' || param.activeMenu eq 'attendance-detail' ? 'active' : ''}">
                        <i class="fas fa-clipboard-check"></i> Quản lý bảng công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/resolve-claim"
                       class="sidebar-link ${param.activeMenu eq 'hr-attendance-claims' ? 'active' : ''}">
                        <i class="fas fa-balance-scale"></i> Giải quyết khiếu nại công
                    </a>
                </li>


                <%-- ── Nhân sự & Điều chuyển ── --%>
                <li class="sidebar-menu-category">Nhân sự &amp; Điều chuyển</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/shift-schedule"
                       class="sidebar-link ${param.activeMenu eq 'hr-shift-schedule' ? 'active' : ''}">
                        <i class="fas fa-calendar-alt"></i> Xếp lịch ca
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/leave"
                       class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                        <i class="fas fa-calendar-check"></i> Duyệt nghỉ phép
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/leave"
                       class="sidebar-link ${param.activeMenu eq 'leaveManagement' ? 'active' : ''}">
                        <i class="fas fa-calendar-times"></i> Quản lý Nghỉ phép
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/terminate-employee"
                       class="sidebar-link ${param.activeMenu eq 'termination' ? 'active' : ''}">
                        <i class="fas fa-user-minus"></i> Quản lý nghỉ việc
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/resignation-approval"
                       class="sidebar-link ${param.activeMenu eq 'resignation-approval' ? 'active' : ''}">
                        <i class="fas fa-door-open"></i> Duyệt đơn nghỉ việc
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/transfer-requests"
                       class="sidebar-link ${param.activeMenu eq 'transfer-list' || param.activeMenu eq 'transfer-create' ? 'active' : ''}">
                        <i class="fas fa-exchange-alt"></i> Điều chuyển nhân sự
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals"
                       class="sidebar-link ${param.activeMenu eq 'transfer-approvals' ? 'active' : ''}">
                        <i class="fas fa-tasks"></i> Phê duyệt điều chuyển
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/hr-transfer-confirm"
                       class="sidebar-link ${param.activeMenu eq 'hr-transfer-confirm' ? 'active' : ''}">
                        <i class="fas fa-check-double"></i> Xác nhận điều chuyển
                    </a>
                </li>

                <%-- ── Lương & Phúc lợi ── --%>
                <li class="sidebar-menu-category">Lương &amp; Phúc lợi</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/payroll-configs"
                       class="sidebar-link ${param.activeMenu eq 'payroll-configs' ? 'active' : ''}">
                        <i class="fas fa-cogs"></i> Cấu hình lương
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/salary-grade"
                       class="sidebar-link ${param.activeMenu eq 'salary-grade' ? 'active' : ''}">
                        <i class="fas fa-money-bill-wave"></i> Bậc lương
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/reward-disciplines"
                       class="sidebar-link ${param.activeMenu eq 'reward-disciplines' ? 'active' : ''}">
                        <i class="fas fa-award"></i> Danh mục Thưởng/Phạt
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/manual-reward-discipline"
                       class="sidebar-link ${param.activeMenu eq 'manual-reward' ? 'active' : ''}">
                        <i class="fas fa-medal"></i> Khen thưởng/Kỷ luật
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/insurance-rate"
                       class="sidebar-link ${param.activeMenu eq 'insurance-rate' ? 'active' : ''}">
                        <i class="fas fa-shield-alt"></i> Bảo hiểm
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/tax-config"
                       class="sidebar-link ${param.activeMenu eq 'tax-config' ? 'active' : ''}">
                        <i class="fas fa-money-check-alt"></i> Thuế
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/holiday"
                       class="sidebar-link ${param.activeMenu eq 'holiday' ? 'active' : ''}">
                        <i class="fas fa-calendar-day"></i> Ngày nghỉ lễ
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/payroll"
                       class="sidebar-link ${param.activeMenu eq 'payroll' ? 'active' : ''}">
                        <i class="fas fa-file-invoice-dollar"></i> Bảng lương
                    </a>
                </li>
                <li class="sidebar-menu-category">Báo cáo</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/report"
                       class="sidebar-link ${param.activeMenu eq 'hr-report' ? 'active' : ''}">
                        <i class="fas fa-chart-bar"></i> Báo cáo Hợp đồng
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/time-leave-report"
                       class="sidebar-link ${param.activeMenu eq 'time-leave-report' ? 'active' : ''}">
                        <i class="fas fa-file-excel"></i> Báo cáo Công &amp; Phép
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/master-payroll-report"
                       class="sidebar-link ${param.activeMenu eq 'master-payroll-report' ? 'active' : ''}">
                        <i class="fas fa-chart-bar"></i> Báo cáo bảng lương
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/kpi-performance-report"
                       class="sidebar-link ${param.activeMenu eq 'kpi-performance-report' ? 'active' : ''}">
                        <i class="fas fa-chart-line"></i> Báo cáo đánh giá KPI
                    </a>
                </li>

            </c:if>



            <%-- ══════ FACTORY MANAGER / SUPERVISOR (roleId=3) ══════ Quyền: xếp ca
                + phân tăng ca cho công nhân xưởng, duyệt nghỉ phép xưởng, xem/duyệt
                yêu cầu điều chỉnh CC. --%>
            <c:if test="${sessionScope.currentUser.roleId == 3}">
                <li class="sidebar-menu-category">Quản lý xưởng</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/employees"
                       class="sidebar-link ${param.activeMenu eq 'my-employees' ? 'active' : ''}">
                        <i class="fas fa-users"></i> Nhân viên của tôi
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/employee-kpi"
                       class="sidebar-link ${param.activeMenu eq 'employee-kpi' ? 'active' : ''}">
                        <i class="fas fa-star"></i> Đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/kpi-history"
                       class="sidebar-link ${param.activeMenu eq 'kpi-history' ? 'active' : ''}">
                        <i class="fas fa-history"></i> Lịch sử đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/kpi-performance-report"
                       class="sidebar-link ${param.activeMenu eq 'kpi-performance-report' ? 'active' : ''}">
                        <i class="fas fa-chart-bar"></i> Báo cáo đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/shift-schedule"
                       class="sidebar-link ${param.activeMenu eq 'shift-schedule' ? 'active' : ''}">
                        <i class="fas fa-calendar-alt"></i> Xếp lịch ca
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/leave"
                       class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                        <i class="fas fa-calendar-check"></i> Duyệt nghỉ phép
                    </a>
                </li>
                <li class="sidebar-menu-category">Chấm công</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/attendance-claims"
                       class="sidebar-link ${param.activeMenu eq 'attendance-claims' ? 'active' : ''}">
                        <i class="fas fa-balance-scale"></i> Giải quyết khiếu
                        nại công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/timesheet-confirm"
                       class="sidebar-link ${param.activeMenu eq 'timesheet-confirm' ? 'active' : ''}">
                        <i class="fas fa-check-double"></i> Xác nhận bảng công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals"
                       class="sidebar-link ${param.activeMenu eq 'transfer-approvals' ? 'active' : ''}">
                        <i class="fas fa-tasks"></i> Phê duyệt điều chuyển
                    </a>
                </li>

            </c:if>

            <%-- ══════ DIRECTOR (roleId=4) ══════ Quyền: xem tổng quan nhân sự,
                duyệt chốt bảng lương, xem báo cáo tổng hợp. KHÔNG có quyền vận
                hành (phòng ban CRUD, etc.) --%>
            <c:if test="${sessionScope.currentUser.roleId == 4}">
                <li class="sidebar-menu-category">Bảng điều hành</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/director/dashboard"
                       class="sidebar-link ${param.activeMenu eq 'director-dashboard' ? 'active' : ''}">
                        <i class="fas fa-tachometer-alt"></i> Tổng quan
                    </a>
                </li>
                <li class="sidebar-menu-category">Lương & Phê duyệt</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/director/payroll"
                       class="sidebar-link ${param.activeMenu eq 'director-payroll' ? 'active' : ''}">
                        <i class="fas fa-file-invoice-dollar"></i> Duyệt
                        bảng lương
                    </a>
                </li>
                <li class="sidebar-menu-category">Báo cáo</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/director/reports"
                       class="sidebar-link ${param.activeMenu eq 'director-reports' ? 'active' : ''}">
                        <i class="fas fa-chart-line"></i> Báo cáo tổng hợp
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/master-payroll-report"
                       class="sidebar-link ${param.activeMenu eq 'master-payroll-report' ? 'active' : ''}">
                        <i class="fas fa-chart-bar"></i> Báo cáo bảng lương
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/kpi-performance-report"
                       class="sidebar-link ${param.activeMenu eq 'kpi-performance-report' ? 'active' : ''}">
                        <i class="fas fa-chart-line"></i> Báo cáo đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/employee-kpi"
                       class="sidebar-link ${param.activeMenu eq 'employee-kpi' ? 'active' : ''}">
                        <i class="fas fa-star"></i> Đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/kpi-history"
                       class="sidebar-link ${param.activeMenu eq 'kpi-history' ? 'active' : ''}">
                        <i class="fas fa-history"></i> Lịch sử đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-menu-category">Nhân sự</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/shift-schedule"
                       class="sidebar-link ${param.activeMenu eq 'hr-shift-schedule' ? 'active' : ''}">
                        <i class="fas fa-calendar-alt"></i> Xếp lịch ca trưởng phòng
                    </a>
                </li>
            </c:if>

            <%-- ══════ HR STAFF (roleId=5) ══════ Quyền: xem danh sách NV,
                upload/xem chấm công, quản lý hợp đồng, xuất payroll. KHÔNG
                duyệt nghỉ phép (Supervisor/DeptMgr duyệt). --%>
            <c:if test="${sessionScope.currentUser.roleId == 5}">
                <li class="sidebar-menu-category">Quản lý nhân sự</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/employees"
                       class="sidebar-link ${param.activeMenu eq 'employees' ? 'active' : ''}">
                        <i class="fas fa-users"></i> Danh sách nhân viên
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/contracts"
                       class="sidebar-link ${param.activeMenu eq 'contract-management' ? 'active' : ''}">
                        <i class="fas fa-file-signature"></i> Quản lý Hợp đồng
                    </a>
                </li>


                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/department"
                       class="sidebar-link ${param.activeMenu eq 'department' ? 'active' : ''}">
                        <i class="fas fa-building"></i> Phòng ban
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/position"
                       class="sidebar-link ${param.activeMenu eq 'position' ? 'active' : ''}">
                        <i class="fas fa-id-card-alt"></i> Chức vụ
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/contract-type"
                       class="sidebar-link ${param.activeMenu eq 'contract-type' ? 'active' : ''}">
                        <i class="fas fa-file-contract"></i> Loại hợp đồng
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/onboarding/list"
                       class="sidebar-link ${param.activeMenu eq 'onboarding' ? 'active' : ''}">
                        <i class="fas fa-user-clock"></i> Tiếp nhận nhân viên
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/terminate-employee"
                       class="sidebar-link ${param.activeMenu eq 'termination' ? 'active' : ''}">
                        <i class="fas fa-user-minus"></i> Quản lý nghỉ việc
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/resignation-approval"
                       class="sidebar-link ${param.activeMenu eq 'resignation-approval' ? 'active' : ''}">
                        <i class="fas fa-door-open"></i> Duyệt đơn nghỉ việc
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/transfer-requests"
                       class="sidebar-link ${param.activeMenu eq 'transfer-list' || param.activeMenu eq 'transfer-create' ? 'active' : ''}">
                        <i class="fas fa-exchange-alt"></i> Điều chuyển nhân sự
                    </a>
                </li>

                <li class="sidebar-menu-category">KPI</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/kpi-templates"
                       class="sidebar-link ${param.activeMenu eq 'kpi-templates' || param.activeMenu eq 'kpi-template-edit' ? 'active' : ''}">
                        <i class="fas fa-cubes"></i> Mẫu KPI Tiêu chuẩn
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/kpi-cycles"
                       class="sidebar-link ${param.activeMenu eq 'kpi-cycles' ? 'active' : ''}">
                        <i class="fas fa-sync-alt"></i> Chu kỳ Đánh giá
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/kpi-history"
                       class="sidebar-link ${param.activeMenu eq 'kpi-history' ? 'active' : ''}">
                        <i class="fas fa-history"></i> Lịch sử đánh giá KPI
                    </a>
                </li>

                <li class="sidebar-menu-category">Cấu hình Chính sách</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/shifts"
                       class="sidebar-link ${param.activeMenu eq 'shifts' ? 'active' : ''}">
                        <i class="fas fa-clock"></i> Quản lý Ca làm việc
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/reward-disciplines"
                       class="sidebar-link ${param.activeMenu eq 'reward-disciplines' ? 'active' : ''}">
                        <i class="fas fa-award"></i> Danh mục Thưởng/Phạt
                    </a>
                </li>

                <li class="sidebar-menu-category">Chấm công</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/import-attendance"
                       class="sidebar-link ${param.activeMenu eq 'import-attendance' ? 'active' : ''}">
                        <i class="fas fa-file-import"></i> Import chấm công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/timesheet-confirm"
                       class="sidebar-link ${param.activeMenu eq 'timesheet-confirm' ? 'active' : ''}">
                        <i class="fas fa-check-double"></i> Xác nhận bảng công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/shift-schedule"
                       class="sidebar-link ${param.activeMenu eq 'hr-shift-schedule' ? 'active' : ''}">
                        <i class="fas fa-calendar-alt"></i> Xếp lịch ca quản lý
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/resolve-claim"
                       class="sidebar-link ${param.activeMenu eq 'hr-attendance-claims' ? 'active' : ''}">
                        <i class="fas fa-balance-scale"></i> Giải quyết khiếu nại công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/attendance-management?action=detail"
                       class="sidebar-link ${param.activeMenu eq 'attendance-summary' || param.activeMenu eq 'attendance-detail' ? 'active' : ''}">
                        <i class="fas fa-clipboard-check"></i> Quản lý bảng công
                    </a>
                </li>


                <li class="sidebar-menu-category">Lương &amp; Phúc lợi</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/allowance"
                       class="sidebar-link ${param.activeMenu eq 'allowance' ? 'active' : ''}">
                        <i class="fas fa-hand-holding-usd"></i> Phụ cấp
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/position-allowance"
                       class="sidebar-link ${param.activeMenu eq 'position-allowance' ? 'active' : ''}">
                        <i class="fas fa-table"></i> Cấu hình Phụ cấp
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/payroll"
                       class="sidebar-link ${param.activeMenu eq 'payroll' ? 'active' : ''}">
                        <i class="fas fa-file-invoice-dollar"></i> Bảng lương
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/insurance-rate"
                       class="sidebar-link ${param.activeMenu eq 'insurance-rate' ? 'active' : ''}">
                        <i class="fas fa-shield-alt"></i> Bảo hiểm
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/tax-config"
                       class="sidebar-link ${param.activeMenu eq 'tax-config' ? 'active' : ''}">
                        <i class="fas fa-money-check-alt"></i> Thuế
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/manual-reward-discipline"
                       class="sidebar-link ${param.activeMenu eq 'manual-reward' ? 'active' : ''}">
                        <i class="fas fa-award"></i> Khen thưởng/Kỷ luật
                    </a>
                </li>
                <li class="sidebar-menu-category">Báo cáo</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/report"
                       class="sidebar-link ${param.activeMenu eq 'hr-report' ? 'active' : ''}">
                        <i class="fas fa-chart-bar"></i> Báo cáo Hợp đồng
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/time-leave-report"
                       class="sidebar-link ${param.activeMenu eq 'time-leave-report' ? 'active' : ''}">
                        <i class="fas fa-file-excel"></i> Báo cáo Công &amp; Phép
                    </a>
                </li>

                <li class="sidebar-menu-category">Cá nhân</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/work-history"
                       class="sidebar-link ${param.activeMenu eq 'work-history' ? 'active' : ''}">
                        <i class="fas fa-history"></i> Lịch sử làm việc
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/leave"
                       class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                        <i class="fas fa-calendar-times"></i> Nghỉ phép
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/resignation"
                       class="sidebar-link ${param.activeMenu eq 'resignation' ? 'active' : ''}">
                        <i class="fas fa-door-open"></i> Xin nghỉ việc
                    </a>
                </li>
            </c:if>

            <%-- ══════ DEPARTMENT MANAGER (roleId=6) ══════ Quyền:
                duyệt nghỉ phép nhân viên văn phòng, duyệt yêu cầu điều
                chỉnh chấm công phòng ban. KHÔNG xếp ca (văn phòng chỉ
                giờ hành chính). KHÔNG có OT (văn phòng không tăng ca).
            --%>
            <c:if test="${sessionScope.currentUser.roleId == 6}">
                <li class="sidebar-menu-category">Quản lý phòng ban
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/employees"
                       class="sidebar-link ${param.activeMenu eq 'my-employees' ? 'active' : ''}">
                        <i class="fas fa-users"></i> Nhân viên của
                        tôi
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/employee-kpi"
                       class="sidebar-link ${param.activeMenu eq 'employee-kpi' ? 'active' : ''}">
                        <i class="fas fa-star"></i> Đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/kpi-history"
                       class="sidebar-link ${param.activeMenu eq 'kpi-history' ? 'active' : ''}">
                        <i class="fas fa-history"></i> Lịch sử đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/hr/kpi-performance-report"
                       class="sidebar-link ${param.activeMenu eq 'kpi-performance-report' ? 'active' : ''}">
                        <i class="fas fa-chart-bar"></i> Báo cáo đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/leave"
                       class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                        <i class="fas fa-calendar-check"></i> Duyệt
                        nghỉ phép
                    </a>
                </li>
                <li class="sidebar-menu-category">Chấm công</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/attendance-claims"
                       class="sidebar-link ${param.activeMenu eq 'attendance-claims' ? 'active' : ''}">
                        <i class="fas fa-balance-scale"></i> Giải
                        quyết khiếu nại công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/timesheet-confirm"
                       class="sidebar-link ${param.activeMenu eq 'timesheet-confirm' ? 'active' : ''}">
                        <i class="fas fa-check-double"></i> Xác nhận
                        bảng công
                    </a>
                </li>
                <li class="sidebar-menu-category">Điều chuyển</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals"
                       class="sidebar-link ${param.activeMenu eq 'transfer-approvals' ? 'active' : ''}">
                        <i class="fas fa-exchange-alt"></i> Phê duyệt điều chuyển
                    </a>
                </li>
            </c:if>

            <%-- ══════ EMPLOYEE (roleId=7) ══════ --%>
            <c:if
                test="${sessionScope.currentUser.roleId == 7}">
                <li class="sidebar-menu-category">Ca làm & Chấm
                    công</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/schedule"
                       class="sidebar-link ${param.activeMenu eq 'schedule' ? 'active' : ''}">
                        <i class="fas fa-calendar-alt"></i> Lịch
                        phân ca
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/overtime"
                       class="sidebar-link ${param.activeMenu eq 'personal-overtime' ? 'active' : ''}">
                        <i class="fas fa-business-time"></i> Tăng ca của tôi
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/timesheet"
                       class="sidebar-link ${param.activeMenu eq 'personal-timesheet' ? 'active' : ''}">
                        <i class="fas fa-fingerprint"></i> Bảng
                        công cá nhân
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/attendance-claim"
                       class="sidebar-link ${param.activeMenu eq 'attendance-claim' ? 'active' : ''}">
                        <i class="fas fa-paper-plane"></i> Yêu
                        cầu chấm lại công
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/work-history"
                       class="sidebar-link ${param.activeMenu eq 'work-history' ? 'active' : ''}">
                        <i class="fas fa-history"></i> Lịch sử
                        làm việc
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/transfer-confirm"
                       class="sidebar-link ${param.activeMenu eq 'transfer-confirm' ? 'active' : ''}">
                        <i class="fas fa-exchange-alt"></i> Xác nhận điều chuyển
                    </a>
                </li>

                <li class="sidebar-menu-category">Phúc lợi &
                    Nghỉ phép</li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/leave"
                       class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                        <i class="fas fa-calendar-times"></i>
                        Nghỉ phép
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/kpi-view"
                       class="sidebar-link ${param.activeMenu eq 'employee-kpi-view' ? 'active' : ''}">
                        <i class="fas fa-star"></i> Đánh giá KPI
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/payslip"
                       class="sidebar-link ${param.activeMenu eq 'personal-payslip' ? 'active' : ''}">
                        <i
                            class="fas fa-file-invoice-dollar"></i>
                        Phiếu lương
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/contract-signing"
                       class="sidebar-link ${param.activeMenu eq 'contract-signing' ? 'active' : ''}">
                        <i class="fas fa-pen-nib"></i>
                        Xác nhận Hợp đồng
                        <c:if test="${pendingContractsCount > 0}">
                            <span style="background: #dc2626; color: white; padding: 2px 6px; border-radius: 10px; font-size: 0.65rem; margin-left: auto;">${pendingContractsCount}</span>
                        </c:if>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/my-contract"
                       class="sidebar-link ${param.activeMenu eq 'my-contract' ? 'active' : ''}">
                        <i class="fas fa-file-signature"></i>
                        Hợp đồng của tôi
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/resignation"
                       class="sidebar-link ${param.activeMenu eq 'resignation' ? 'active' : ''}">
                        <i class="fas fa-door-open"></i> Xin
                        nghỉ việc
                    </a>
                </li>

            </c:if>

            <%-- ══════ ACCOUNTANT (roleId=8) ══════ Quyền: xem
                bảng lương, xác nhận chuyển khoản --%>
            <c:if
                test="${sessionScope.currentUser.roleId == 8}">
                <li class="sidebar-menu-category">Kế Toán
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/accountant/payroll"
                       class="sidebar-link ${param.activeMenu eq 'accountant-payroll' ? 'active' : ''}">
                        <i
                            class="fas fa-file-invoice-dollar"></i>
                        Bảng Lương
                    </a>
                </li>

            </c:if>

            <%-- ══════ TÀI KHOẢN (chung) ══════ --%>
            <li class="sidebar-menu-category">Tài khoản
            </li>
            <c:if
                test="${sessionScope.currentUser.roleId != 7 && sessionScope.currentUser.roleId != 1 && sessionScope.currentUser.roleId != 4}">
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/schedule"
                       class="sidebar-link ${param.activeMenu eq 'schedule' ? 'active' : ''}">
                        <i class="fas fa-calendar-alt"></i>
                        Lịch phân ca cá nhân
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/timesheet"
                       class="sidebar-link ${param.activeMenu eq 'personal-timesheet' ? 'active' : ''}">
                        <i
                            class="fas fa-fingerprint"></i>
                        Bảng công cá nhân
                    </a>
                </li>
            </c:if>
            <%-- Phiếu lương cá nhân: hiển thị cho mọi
                role có lương (trừ Admin và Employee -
                Employee đã có ở section riêng) --%>
            <c:if
                test="${sessionScope.currentUser.roleId != 1 && sessionScope.currentUser.roleId != 7 && sessionScope.currentUser.roleId != 4}">
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/kpi-view"
                       class="sidebar-link ${param.activeMenu eq 'employee-kpi-view' ? 'active' : ''}">
                        <i class="fas fa-star"></i> Đánh giá KPI cá nhân
                    </a>
                </li>
            </c:if>
            <c:if
                test="${sessionScope.currentUser.roleId != 1 && sessionScope.currentUser.roleId != 7}">
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/payslip"
                       class="sidebar-link ${param.activeMenu eq 'personal-payslip' ? 'active' : ''}">
                        <i
                            class="fas fa-file-invoice-dollar"></i>
                        Phiếu lương
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/contract-signing"
                       class="sidebar-link ${param.activeMenu eq 'contract-signing' ? 'active' : ''}">
                        <i class="fas fa-pen-nib"></i>
                        Xác nhận Hợp đồng
                        <c:if test="${pendingContractsCount > 0}">
                            <span style="background: #dc2626; color: white; padding: 2px 6px; border-radius: 10px; font-size: 0.65rem; margin-left: auto;">${pendingContractsCount}</span>
                        </c:if>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a href="${pageContext.request.contextPath}/employee/my-contract"
                       class="sidebar-link ${param.activeMenu eq 'my-contract' ? 'active' : ''}">
                        <i
                            class="fas fa-file-signature"></i>
                        Hợp đồng của tôi
                    </a>
                </li>
            </c:if>
            <li class="sidebar-item">
                <a href="${pageContext.request.contextPath}/profile"
                   class="sidebar-link ${param.activeMenu eq 'profile' ? 'active' : ''}">
                    <i class="fas fa-id-badge"></i>
                    Thông tin cá nhân
                </a>
            </li>
            <li class="sidebar-item">
                <a href="${pageContext.request.contextPath}/settings"
                   class="sidebar-link ${param.activeMenu eq 'settings' ? 'active' : ''}">
                    <i class="fas fa-cog"></i> Cài
                    đặt
                </a>
            </li>

        </ul>
    </nav>

    <%-- Footer --%>
    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-logout"
           onclick="return confirm('Bạn có chắc chắn muốn đăng xuất không?');">
            <i class="fas fa-sign-out-alt"></i> Đăng xuất
        </a>
    </div>

</aside>

<script>
    function toggleSidebar() {
        const s = document.getElementById('adminSidebar');
        s.classList.contains('sidebar-open') ? closeSidebar() : openSidebar();
    }
    function openSidebar() {
        document.getElementById('adminSidebar').classList.add('sidebar-open');
        const ov = document.getElementById('sidebarOverlay');
        ov.style.display = 'block';
        requestAnimationFrame(() => ov.classList.add('active'));
        document.body.style.overflow = 'hidden';
    }
    function closeSidebar() {
        document.getElementById('adminSidebar').classList.remove('sidebar-open');
        const ov = document.getElementById('sidebarOverlay');
        ov.classList.remove('active');
        setTimeout(() => {
            ov.style.display = 'none';
        }, 310);
        document.body.style.overflow = '';
    }
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape')
            closeSidebar();
    });
</script>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* Sidebar Navigation - Reuse Admin Sidebar CSS */
    .admin-sidebar {
        width: 260px;
        background: #ffffff;
        border-right: 1px solid #e2e8f0;
        padding: 20px 0;
        position: sticky;
        top: 64px;
        height: calc(100vh - 64px);
        overflow-y: auto;
        box-shadow: 4px 0 20px rgba(0, 0, 0, 0.02);
        flex-shrink: 0;
    }

    .sidebar-menu {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .sidebar-menu-category {
        padding: 10px 25px;
        font-size: 0.75rem;
        font-weight: 700;
        color: #8f9fbc;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-top: 15px;
    }

    .sidebar-item {
        margin-bottom: 5px;
    }

    .sidebar-link {
        display: flex;
        align-items: center;
        padding: 12px 25px;
        color: #4a5568;
        text-decoration: none;
        font-weight: 500;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        border-left: 3px solid transparent;
    }

    .sidebar-link i {
        width: 24px;
        font-size: 1.1rem;
        margin-right: 10px;
        color: #8f9fbc;
        transition: all 0.3s ease;
    }

    .sidebar-link:hover, .sidebar-link.active {
        background: rgba(67, 97, 238, 0.05);
        color: #4361ee;
        border-left-color: #4361ee;
    }

    .sidebar-link:hover i, .sidebar-link.active i {
        color: #4361ee;
    }
</style>

<aside class="admin-sidebar">
    <div class="text-center mb-4 mt-2">
        <div class="avatar-sm mx-auto mb-2" style="width: 60px; height: 60px; font-size: 1.5rem; border-radius: 10px; background: linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: bold;">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    ${sessionScope.currentUser.fullName.substring(0,1)}
                </c:when>
                <c:otherwise>
                    E
                </c:otherwise>
            </c:choose>
        </div>
        <h6 class="mb-0 fw-bold" style="color: #2b2b2b;">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    ${sessionScope.currentUser.fullName}
                </c:when>
                <c:otherwise>
                    Employee
                </c:otherwise>
            </c:choose>
        </h6>
        <span class="small text-muted">
            <c:choose>
                <c:when test="${sessionScope.currentUser.roleId == 2}">Manager</c:when>
                <c:when test="${sessionScope.currentUser.roleId == 4}">HR Staff</c:when>
                <c:when test="${sessionScope.currentUser.roleId == 5}">Accountant</c:when>
                <c:when test="${sessionScope.currentUser.roleId == 6}">Department Head</c:when>
                <c:otherwise>Employee</c:otherwise>
            </c:choose>
        </span>
    </div>

    <ul class="sidebar-menu">
        <li class="sidebar-menu-category">MAIN</li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/employee/dashboard" class="sidebar-link ${param.activeMenu eq 'dashboard' ? 'active' : ''}">
                <i class="fas fa-home"></i> Bảng điều khiển
            </a>
        </li>

        <li class="sidebar-menu-category">CÔNG VIỆC</li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/attendance" class="sidebar-link ${param.activeMenu eq 'attendance' ? 'active' : ''}">
                <i class="fas fa-fingerprint"></i> Chấm công
            </a>
        </li>
        <li class="sidebar-item">
            <a href="#" class="sidebar-link ${param.activeMenu eq 'schedule' ? 'active' : ''}">
                <i class="fas fa-calendar-alt"></i> Lịch phân ca
            </a>
        </li>
        <li class="sidebar-item">
            <a href="#" class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                <i class="fas fa-paper-plane"></i> Đơn nghỉ phép
            </a>
        </li>

        <li class="sidebar-menu-category">TÀI CHÍNH</li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/payroll" class="sidebar-link ${param.activeMenu eq 'payroll' ? 'active' : ''}">
                <i class="fas fa-file-invoice-dollar"></i> Phiếu lương
            </a>
        </li>

        <li class="sidebar-menu-category">TÀI KHOẢN</li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/profile" class="sidebar-link ${param.activeMenu eq 'profile' ? 'active' : ''}">
                <i class="fas fa-id-badge"></i> Hồ sơ cá nhân
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/work-history" class="sidebar-link ${param.activeMenu eq 'work-history' ? 'active' : ''}">
                <i class="fas fa-briefcase"></i> Lịch sử công tác
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/settings" class="sidebar-link ${param.activeMenu eq 'settings' ? 'active' : ''}">
                <i class="fas fa-cog"></i> Cài đặt 
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/logout" class="sidebar-link" style="color: #e53e3e;" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất không?');">
                <i class="fas fa-sign-out-alt" style="color: #e53e3e;"></i> Đăng xuất
            </a>
        </li>
    </ul>
</aside>

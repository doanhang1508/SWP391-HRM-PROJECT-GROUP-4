<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* ─── SIDEBAR BASE ─────────────────────────────────── */
    .admin-sidebar {
        width: 260px;
        background: #ffffff;
        border-right: 1px solid #e2e8f0;
        padding: 20px 0;
        position: sticky;
        top: 64px;
        height: calc(100vh - 64px);
        overflow-y: auto;
        box-shadow: 4px 0 20px rgba(0,0,0,0.02);
        flex-shrink: 0;
        transition: transform 0.3s cubic-bezier(.22,1,.36,1);
        z-index: 1040;
    }

    /* ─── SIDEBAR MENU ──────────────────────────────────── */
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

    .sidebar-item { margin-bottom: 5px; }

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

    .sidebar-link:hover,
    .sidebar-link.active {
        background: rgba(67,97,238,0.05);
        color: #4361ee;
        border-left-color: #4361ee;
    }

    .sidebar-link:hover i,
    .sidebar-link.active i {
        color: #4361ee;
    }

    /* ─── HAMBURGER BUTTON (mobile only) ─────────────────── */
    .sidebar-toggle-btn {
        display: none;               /* ẩn trên desktop */
        position: fixed;
        top: 72px;
        left: 16px;
        z-index: 1050;
        width: 42px;
        height: 42px;
        border-radius: 10px;
        background: #4361ee;
        color: #fff;
        border: none;
        cursor: pointer;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        box-shadow: 0 4px 14px rgba(67,97,238,0.4);
        transition: background 0.2s, transform 0.2s;
    }
    .sidebar-toggle-btn:hover {
        background: #3451d1;
        transform: scale(1.05);
    }

    /* ─── SIDEBAR CLOSE BUTTON (inside sidebar, mobile) ──── */
    .sidebar-close-btn {
        display: none;
        position: absolute;
        top: 12px;
        right: 12px;
        background: none;
        border: none;
        font-size: 20px;
        color: #8f9fbc;
        cursor: pointer;
        padding: 4px 8px;
        border-radius: 6px;
    }
    .sidebar-close-btn:hover { background: #f1f5f9; color: #4a5568; }

    /* ─── OVERLAY BACKDROP (mobile only) ─────────────────── */
    .sidebar-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.45);
        z-index: 1039;
        backdrop-filter: blur(2px);
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    .sidebar-overlay.active { opacity: 1; }

    /* ─── RESPONSIVE ──────────────────────────────────────── */
    @media (max-width: 768px) {
        /* Sidebar trở thành drawer cố định, ẩn sang trái */
        .admin-sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            transform: translateX(-100%);
            padding-top: 56px;   /* chừa chỗ cho nút đóng */
            box-shadow: 6px 0 30px rgba(0,0,0,0.15);
        }

        /* Khi sidebar mở */
        .admin-sidebar.sidebar-open {
            transform: translateX(0);
        }

        /* Hiện nút hamburger */
        .sidebar-toggle-btn  { display: flex; }
        /* Hiện nút đóng trong sidebar */
        .sidebar-close-btn   { display: block; }
        /* Hiện overlay */
        .sidebar-overlay     { display: block; }

        /* Main content chiếm toàn bộ chiều rộng */
        .main-content {
            width: 100% !important;
            padding: 20px 16px !important;
        }
    }
</style>

<%-- ── Overlay Backdrop ─────────────────────────────── --%>
<div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>

<%-- ── Hamburger Button ─────────────────────────────── --%>
<button class="sidebar-toggle-btn" id="sidebarToggleBtn"
        onclick="toggleSidebar()" aria-label="Mở menu">
    <i class="fas fa-bars"></i>
</button>

<%-- ── Sidebar ────────────────────────────────────────── --%>
<aside class="admin-sidebar" id="adminSidebar">

    <%-- Nút đóng (chỉ hiện trên mobile) --%>
    <button class="sidebar-close-btn" onclick="closeSidebar()" aria-label="Đóng menu">
        <i class="fas fa-times"></i>
    </button>

    <div class="text-center mb-4 mt-2">
        <div class="avatar-sm mx-auto mb-2" style="
            width:60px; height:60px; font-size:1.5rem; border-radius:10px;
            background: linear-gradient(135deg,#e0c3fc 0%,#8ec5fc 100%);
            color:#fff; display:flex; align-items:center; justify-content:center; font-weight:bold;">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    ${sessionScope.currentUser.fullName.substring(0,1)}
                </c:when>
                <c:otherwise>A</c:otherwise>
            </c:choose>
        </div>
        <h6 class="mb-0 fw-bold" style="color:#2b2b2b;">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    ${sessionScope.currentUser.fullName}
                </c:when>
                <c:otherwise>Administrator</c:otherwise>
            </c:choose>
        </h6>
        <span class="small text-muted">Administrator</span>
    </div>

    <ul class="sidebar-menu">
        <li class="sidebar-menu-category">MAIN</li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="sidebar-link ${param.activeMenu eq 'dashboard' ? 'active' : ''}">
                <i class="fas fa-home"></i> Bảng điều khiển
            </a>
        </li>

        <li class="sidebar-menu-category">ADMINISTRATION</li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/admin/dashboard#users" class="sidebar-link">
                <i class="fas fa-users"></i> Quản lý Người dùng
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/role?action=list"
               class="sidebar-link ${param.activeMenu eq 'roles' ? 'active' : ''}">
                <i class="fas fa-user-shield"></i> Quản lý Vai trò
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/editRolePermission"
               class="sidebar-link ${param.activeMenu eq 'permissions' ? 'active' : ''}">
                <i class="fas fa-key"></i> Phân quyền Hệ thống
            </a>
        </li>

        <li class="sidebar-menu-category">REPORTS</li>
        <li class="sidebar-item">
            <a href="#" class="sidebar-link">
                <i class="fas fa-chart-pie"></i> Thống kê
            </a>
        </li>
        <li class="sidebar-item">
            <a href="#" class="sidebar-link">
                <i class="fas fa-file-alt"></i> Nhật ký hoạt động
            </a>
        </li>

        <li class="sidebar-menu-category">TÀI KHOẢN</li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/profile"
               class="sidebar-link ${param.activeMenu eq 'profile' ? 'active' : ''}">
                <i class="fas fa-id-badge"></i> Hồ sơ cá nhân
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/work-history"
               class="sidebar-link ${param.activeMenu eq 'work-history' ? 'active' : ''}">
                <i class="fas fa-briefcase"></i> Lịch sử công tác
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/settings"
               class="sidebar-link ${param.activeMenu eq 'settings' ? 'active' : ''}">
                <i class="fas fa-cog"></i> Cài đặt
            </a>
        </li>
        <li class="sidebar-item">
            <a href="${pageContext.request.contextPath}/logout"
               class="sidebar-link" style="color:#e53e3e;"
               onclick="return confirm('Bạn có chắc chắn muốn đăng xuất không?');">
                <i class="fas fa-sign-out-alt" style="color:#e53e3e;"></i> Đăng xuất
            </a>
        </li>
    </ul>
</aside>

<script>
    function toggleSidebar() {
        const sidebar  = document.getElementById('adminSidebar');
        const overlay  = document.getElementById('sidebarOverlay');
        const isOpen   = sidebar.classList.contains('sidebar-open');
        isOpen ? closeSidebar() : openSidebar();
    }

    function openSidebar() {
        document.getElementById('adminSidebar').classList.add('sidebar-open');
        const ov = document.getElementById('sidebarOverlay');
        ov.style.display = 'block';
        // Chờ 1 frame để transition hoạt động
        requestAnimationFrame(() => ov.classList.add('active'));
        document.body.style.overflow = 'hidden'; // Chặn scroll nền
    }

    function closeSidebar() {
        document.getElementById('adminSidebar').classList.remove('sidebar-open');
        const ov = document.getElementById('sidebarOverlay');
        ov.classList.remove('active');
        // Ẩn overlay sau animation
        setTimeout(() => { ov.style.display = 'none'; }, 310);
        document.body.style.overflow = '';
    }

    // Đóng sidebar khi ấn phím Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeSidebar();
    });
</script>

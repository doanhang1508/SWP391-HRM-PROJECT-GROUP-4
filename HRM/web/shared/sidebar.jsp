<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
                                        <c:otherwise>Nhân viên</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <%-- Navigation — phân quyền theo role --%>
                            <nav class="sidebar-nav">
                                <ul class="sidebar-menu">

                                    <%-- ══════ MENU CHUNG cho mọi role ══════ --%>
                                        <li class="sidebar-menu-category">Tổng quan</li>
                                        <li class="sidebar-item">
                                            <a href="${pageContext.request.contextPath}/dashboard"
                                                class="sidebar-link ${param.activeMenu eq 'dashboard' ? 'active' : ''}">
                                                <i class="fas fa-chart-line"></i> Bảng điều khiển
                                            </a>
                                        </li>

                                        <%-- ══════ ADMIN (roleId=1) ══════ --%>
                                            <c:if test="${sessionScope.currentUser.roleId == 1}">
                                                <li class="sidebar-menu-category">Quản trị hệ thống</li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/users"
                                                        class="sidebar-link ${param.activeMenu eq 'users' ? 'active' : ''}">
                                                        <i class="fas fa-users"></i> Quản lý Người dùng
                                                    </a>
                                                </li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/department"
                                                        class="sidebar-link ${param.activeMenu eq 'department' ? 'active' : ''}">
                                                        <i class="fas fa-building"></i> Phòng ban
                                                    </a>
                                                </li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/position"
                                                        class="sidebar-link ${param.activeMenu eq 'position' ? 'active' : ''}">
                                                        <i class="fas fa-id-card-alt"></i> Chức vụ
                                                    </a>
                                                </li>

                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/contract-type"
                                                        class="sidebar-link ${param.activeMenu eq 'contract-type' ? 'active' : ''}">
                                                        <i class="fas fa-file-contract"></i> Loại hợp đồng
                                                    </a>
                                                </li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/shifts"
                                                        class="sidebar-link ${param.activeMenu eq 'shifts' ? 'active' : ''}">
                                                        <i class="fas fa-clock"></i> Quản lý Ca làm việc
                                                    </a>
                                                </li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/leave-types"
                                                        class="sidebar-link ${param.activeMenu eq 'leave-types' ? 'active' : ''}">
                                                        <i class="fas fa-calendar-times"></i> Loại nghỉ phép
                                                    </a>
                                                </li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/shifts?action=schedule"
                                                        class="sidebar-link ${param.activeMenu eq 'schedule' ? 'active' : ''}">
                                                        <i class="fas fa-calendar-alt"></i> Xếp lịch ca
                                                    </a>
                                                </li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/pending-requests"
                                                        class="sidebar-link ${param.activeMenu eq 'pending-requests' ? 'active' : ''}">
                                                        <i class="fas fa-hourglass-half"></i> Đơn chờ xử lý
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

                                            <%-- ══════ HR MANAGER (roleId=2) ══════ --%>
                                                <c:if test="${sessionScope.currentUser.roleId == 2}">
                                                    <li class="sidebar-menu-category">Quản lý nhân viên</li>
                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/employees"
                                                            class="sidebar-link ${param.activeMenu eq 'employees' ? 'active' : ''}">
                                                            <i class="fas fa-users"></i> Danh sách nhân viên
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
                                                        <a href="${pageContext.request.contextPath}/hr/salary-grade"
                                                            class="sidebar-link ${param.activeMenu eq 'salary-grade' ? 'active' : ''}">
                                                            <i class="fas fa-money-bill-wave"></i> Bậc lương
                                                        </a>
                                                    </li>
                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/insurance-rate"
                                                            class="sidebar-link ${param.activeMenu eq 'insurance-rate' ? 'active' : ''}">
                                                            <i class="fas fa-shield-alt"></i> Bảo hiểm
                                                        </a>
                                                    </li>
                                                    <li class="sidebar-menu-category">Nghỉ phép &amp; OT</li>
                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/manager/leave-ot"
                                                            class="sidebar-link ${param.activeMenu eq 'leave-ot' ? 'active' : ''}">
                                                            <i class="fas fa-calendar-check"></i> Duyệt nghỉ phép / OT
                                                        </a>
                                                    </li>
                                                </c:if>

                                                <%-- ══════ FACTORY MANAGER (roleId=3) ══════ --%>
                                                    <c:if test="${sessionScope.currentUser.roleId == 3}">
                                                        <li class="sidebar-menu-category">Quản lý xưởng</li>
                                                        <li class="sidebar-item">
                                                            <a href="${pageContext.request.contextPath}/admin/shifts?action=schedule"
                                                                class="sidebar-link ${param.activeMenu eq 'schedule' ? 'active' : ''}">
                                                                <i class="fas fa-calendar-alt"></i> Lịch ca làm việc
                                                            </a>
                                                        </li>
                                                        <li class="sidebar-item">
                                                            <a href="${pageContext.request.contextPath}/manager/leave-ot"
                                                                class="sidebar-link ${param.activeMenu eq 'leave-ot' ? 'active' : ''}">
                                                                <i class="fas fa-calendar-check"></i> Duyệt nghỉ phép /
                                                                OT
                                                            </a>
                                                        </li>
                                                    </c:if>

                                                    <%-- ══════ DIRECTOR (roleId=4) ══════ --%>
                                                        <c:if test="${sessionScope.currentUser.roleId == 4}">
                                                            <li class="sidebar-menu-category">Báo cáo &amp; Tổng quan
                                                            </li>
                                                            <li class="sidebar-item">
                                                                <a href="${pageContext.request.contextPath}/admin/department"
                                                                    class="sidebar-link ${param.activeMenu eq 'department' ? 'active' : ''}">
                                                                    <i class="fas fa-building"></i> Phòng ban
                                                                </a>
                                                            </li>
                                                            <li class="sidebar-item">
                                                                <a href="#"
                                                                    class="sidebar-link ${param.activeMenu eq 'reports' ? 'active' : ''}">
                                                                    <i class="fas fa-chart-pie"></i> Báo cáo nhân sự
                                                                </a>
                                                            </li>
                                                            <li class="sidebar-item">
                                                                <a href="${pageContext.request.contextPath}/admin/pending-requests"
                                                                    class="sidebar-link ${param.activeMenu eq 'pending-requests' ? 'active' : ''}">
                                                                    <i class="fas fa-hourglass-half"></i> Đơn chờ phê
                                                                    duyệt
                                                                </a>
                                                            </li>
                                                        </c:if>

                                                        <%-- ══════ HR STAFF (roleId=5) ══════ --%>
                                                            <c:if test="${sessionScope.currentUser.roleId == 5}">
                                                                <li class="sidebar-menu-category">Quản lý nhân sự</li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/employees"
                                                                        class="sidebar-link ${param.activeMenu eq 'employees' ? 'active' : ''}">
                                                                        <i class="fas fa-users"></i> Danh sách nhân viên
                                                                    </a>
                                                                </li>
                                                                <li class="sidebar-menu-category">Nghỉ phép &amp; OT
                                                                </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/manager/leave-ot"
                                                                        class="sidebar-link ${param.activeMenu eq 'leave-ot' ? 'active' : ''}">
                                                                        <i class="fas fa-calendar-check"></i> Duyệt nghỉ
                                                                        phép / OT
                                                                    </a>
                                                                </li>
                                                            </c:if>

                                                            <%-- ══════ DEPARTMENT MANAGER (roleId=6) ══════ --%>
                                                                <c:if test="${sessionScope.currentUser.roleId == 6}">
                                                                    <li class="sidebar-menu-category">Quản lý phòng ban
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/manager/leave-ot"
                                                                            class="sidebar-link ${param.activeMenu eq 'leave-ot' ? 'active' : ''}">
                                                                            <i class="fas fa-calendar-check"></i> Duyệt
                                                                            nghỉ phép / OT
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/admin/shifts?action=schedule"
                                                                            class="sidebar-link ${param.activeMenu eq 'schedule' ? 'active' : ''}">
                                                                            <i class="fas fa-calendar-alt"></i> Lịch ca
                                                                            làm việc
                                                                        </a>
                                                                    </li>
                                                                </c:if>

                                                                <%-- ══════ TÀI KHOẢN (chung) ══════ --%>
                                                                    <li class="sidebar-menu-category">Tài khoản</li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/profile"
                                                                            class="sidebar-link ${param.activeMenu eq 'profile' ? 'active' : ''}">
                                                                            <i class="fas fa-id-badge"></i> Hồ sơ cá
                                                                            nhân
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/settings"
                                                                            class="sidebar-link ${param.activeMenu eq 'settings' ? 'active' : ''}">
                                                                            <i class="fas fa-cog"></i> Cài đặt
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
                        setTimeout(() => { ov.style.display = 'none'; }, 310);
                        document.body.style.overflow = '';
                    }
                    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeSidebar(); });
                </script>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <style>
            /* â”€â”€â”€ SIDEBAR BASE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
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

            /* â”€â”€â”€ SIDEBAR HEADER / LOGO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
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

            /* â”€â”€â”€ USER INFO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
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

            /* â”€â”€â”€ SIDEBAR MENU â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
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

            /* â”€â”€â”€ SIDEBAR FOOTER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
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

            /* â”€â”€â”€ MOBILE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
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

        <%-- â”€â”€ Overlay & Toggle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ --%>
            <div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
            <button class="sidebar-toggle-btn" id="sidebarToggleBtn" onclick="toggleSidebar()" aria-label="Má»Ÿ menu">
                <i class="fas fa-bars"></i>
            </button>

            <%-- â”€â”€ Sidebar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ --%>
                <aside class="admin-sidebar" id="adminSidebar">
                    <button class="sidebar-close-btn" onclick="closeSidebar()" aria-label="ÄÃ³ng menu">
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
                                        <c:when test="${sessionScope.currentUser.roleId == 1}">Quáº£n trá»‹ viÃªn</c:when>
                                        <c:when test="${sessionScope.currentUser.roleId == 2}">HR Manager</c:when>
                                        <c:when test="${sessionScope.currentUser.roleId == 3}">Quáº£n Ä‘á»‘c xÆ°á»Ÿng</c:when>
                                        <c:when test="${sessionScope.currentUser.roleId == 4}">GiÃ¡m Ä‘á»‘c</c:when>
                                        <c:when test="${sessionScope.currentUser.roleId == 5}">NhÃ¢n viÃªn HR</c:when>
                                        <c:when test="${sessionScope.currentUser.roleId == 6}">Quáº£n lÃ½ phÃ²ng ban</c:when>
                                        <c:when test="${sessionScope.currentUser.roleId == 7}">NhÃ¢n viÃªn</c:when>
                                        <c:when test="${sessionScope.currentUser.roleId == 8}">Káº¿ ToÃ¡n</c:when>
                                        <c:otherwise>NhÃ¢n viÃªn</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <%-- Navigation â€” phÃ¢n quyá»n theo role --%>
                            <nav class="sidebar-nav">
                                <ul class="sidebar-menu">

                                    <%-- â•â•â•â•â•â• MENU CHUNG cho má»i role â•â•â•â•â•â• --%>
                                    <c:if test="${sessionScope.currentUser.roleId != 4}">
                                        <li class="sidebar-menu-category">Tá»•ng quan</li>
                                        <li class="sidebar-item">
                                            <a href="${pageContext.request.contextPath}/dashboard"
                                                class="sidebar-link ${param.activeMenu eq 'dashboard' ? 'active' : ''}">
                                                <i class="fas fa-chart-line"></i> Báº£ng Ä‘iá»u khiá»ƒn
                                            </a>
                                        </li>
                                    </c:if>

                                        <%-- â•â•â•â•â•â• ADMIN (roleId=1): CHá»ˆ quáº£n trá»‹ há»‡ thá»‘ng â•â•â•â•â•â• --%>
                                            <c:if test="${sessionScope.currentUser.roleId == 1}">
                                                <li class="sidebar-menu-category">Quáº£n trá»‹ Há»‡ thá»‘ng</li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/users"
                                                        class="sidebar-link ${param.activeMenu eq 'users' ? 'active' : ''}">
                                                        <i class="fas fa-users-cog"></i> Quáº£n lÃ½ NgÆ°á»i dÃ¹ng
                                                    </a>
                                                </li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/admin/onboarding/list"
                                                        class="sidebar-link ${param.activeMenu eq 'onboarding-admin' ? 'active' : ''}">
                                                        <i class="fas fa-user-clock"></i> Tiáº¿p nháº­n nhÃ¢n viÃªn
                                                    </a>
                                                </li>

                                                <li class="sidebar-menu-category">PhÃ¢n quyá»n</li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/role?action=list"
                                                        class="sidebar-link ${param.activeMenu eq 'roles' ? 'active' : ''}">
                                                        <i class="fas fa-user-shield"></i> Quáº£n lÃ½ Vai trÃ²
                                                    </a>
                                                </li>
                                                <li class="sidebar-item">
                                                    <a href="${pageContext.request.contextPath}/editRolePermission"
                                                        class="sidebar-link ${param.activeMenu eq 'permissions' ? 'active' : ''}">
                                                        <i class="fas fa-key"></i> PhÃ¢n quyá»n há»‡ thá»‘ng
                                                    </a>
                                                </li>

                                                <li class="sidebar-menu-category">Quáº£n lÃ½ Cháº¥m cÃ´ng</li>


                                            </c:if>

                                            <%-- â•â•â•â•â•â• HR MANAGER (roleId=2): Quáº£n lÃ½ nhÃ¢n sá»± â•â•â•â•â•â• --%>
                                                <c:if test="${sessionScope.currentUser.roleId == 2}">
                                                    <li class="sidebar-menu-category">Quáº£n lÃ½ nhÃ¢n viÃªn</li>
                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/employees"
                                                            class="sidebar-link ${param.activeMenu eq 'employees' ? 'active' : ''}">
                                                            <i class="fas fa-users"></i> Danh sÃ¡ch nhÃ¢n viÃªn
                                                        </a>
                                                    </li>

                                                    <li class="sidebar-menu-category">Cáº¥u hÃ¬nh ChÃ­nh sÃ¡ch</li>



                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/leave"
                                                            class="sidebar-link ${param.activeMenu eq 'leaveManagement' ? 'active' : ''}">
                                                            <i class="fas fa-calendar-times"></i> Quáº£n lÃ½ Nghá»‰ phÃ©p
                                                        </a>
                                                    </li>
                                                    <li class="sidebar-item">

                                                        <a href="${pageContext.request.contextPath}/hr/reward-disciplines"
                                                            class="sidebar-link ${param.activeMenu eq 'reward-disciplines' ? 'active' : ''}">
                                                            <i class="fas fa-award"></i> Danh má»¥c ThÆ°á»Ÿng/Pháº¡t
                                                        </a>
                                                    </li>

                                                    <li class="sidebar-menu-category">LÆ°Æ¡ng &amp; PhÃºc lá»£i</li>
                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/payroll-configs"
                                                            class="sidebar-link ${param.activeMenu eq 'payroll-configs' ? 'active' : ''}">
                                                            <i class="fas fa-cogs"></i> Cáº¥u hÃ¬nh lÆ°Æ¡ng
                                                        </a>
                                                    </li>

                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/salary-grade"
                                                            class="sidebar-link ${param.activeMenu eq 'salary-grade' ? 'active' : ''}">
                                                            <i class="fas fa-money-bill-wave"></i> Báº­c lÆ°Æ¡ng
                                                        </a>
                                                    </li>

                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/payroll"
                                                            class="sidebar-link ${param.activeMenu eq 'payroll' ? 'active' : ''}">
                                                            <i class="fas fa-file-invoice-dollar"></i> Báº£ng lÆ°Æ¡ng
                                                        </a>
                                                    </li>



                                                    <li class="sidebar-menu-category">Cháº¥m cÃ´ng</li>
                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/timesheet-approval"
                                                            class="sidebar-link ${param.activeMenu eq 'timesheet-approval' ? 'active' : ''}">
                                                            <i class="fas fa-user-check"></i> Duyá»‡t báº£ng cÃ´ng
                                                        </a>
                                                    </li>
                                                    <li class="sidebar-item">
                                                        <a href="${pageContext.request.contextPath}/hr/attendance-management?action=summary"
                                                            class="sidebar-link ${param.activeMenu eq 'attendance-summary' || param.activeMenu eq 'attendance-detail' ? 'active' : ''}">
                                                            <i class="fas fa-clipboard-check"></i> Quáº£n lÃ½ báº£ng cÃ´ng
                                                        </a>
                                                    </li>


                                                </c:if>

                                                <%-- â•â•â•â•â•â• FACTORY MANAGER / SUPERVISOR (roleId=3) â•â•â•â•â•â•
                                                     Quyá»n: xáº¿p ca + phÃ¢n tÄƒng ca cho cÃ´ng nhÃ¢n xÆ°á»Ÿng,
                                                     duyá»‡t nghá»‰ phÃ©p xÆ°á»Ÿng, xem/duyá»‡t yÃªu cáº§u Ä‘iá»u chá»‰nh CC.
                                                --%>
                                                    <c:if test="${sessionScope.currentUser.roleId == 3}">
                                                        <li class="sidebar-menu-category">Quáº£n lÃ½ xÆ°á»Ÿng</li>
                                                        <li class="sidebar-item">
                                                            <a href="${pageContext.request.contextPath}/manager/employees"
                                                                class="sidebar-link ${param.activeMenu eq 'my-employees' ? 'active' : ''}">
                                                                <i class="fas fa-users"></i> NhÃ¢n viÃªn cá»§a tÃ´i
                                                            </a>
                                                        </li>
                                                        <li class="sidebar-item">
                                                            <a href="${pageContext.request.contextPath}/manager/shift-schedule"
                                                                class="sidebar-link ${param.activeMenu eq 'shift-schedule' ? 'active' : ''}">
                                                                <i class="fas fa-calendar-alt"></i> Xáº¿p lá»‹ch ca
                                                            </a>
                                                        </li>
                                                        <li class="sidebar-item">
                                                            <a href="${pageContext.request.contextPath}/manager/leave"
                                                                class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                                                                <i class="fas fa-calendar-check"></i> Duyá»‡t nghá»‰ phÃ©p
                                                            </a>
                                                        </li>
                                                        <li class="sidebar-menu-category">Cháº¥m cÃ´ng</li>
                                                        <li class="sidebar-item">
                                                            <a href="${pageContext.request.contextPath}/manager/attendance-claims"
                                                                class="sidebar-link ${param.activeMenu eq 'attendance-claims' ? 'active' : ''}">
                                                                <i class="fas fa-balance-scale"></i> Giáº£i quyáº¿t khiáº¿u náº¡i cÃ´ng
                                                            </a>
                                                        </li>

                                                    </c:if>

                                                    <%-- â•â•â•â•â•â• DIRECTOR (roleId=4) â•â•â•â•â•â•
                                                         Quyá»n: xem tá»•ng quan nhÃ¢n sá»±,
                                                         duyá»‡t chá»‘t báº£ng lÆ°Æ¡ng,
                                                         xem bÃ¡o cÃ¡o tá»•ng há»£p.
                                                         KHÃ”NG cÃ³ quyá»n váº­n hÃ nh (phÃ²ng ban CRUD, etc.)
                                                    --%>
                                                        <c:if test="${sessionScope.currentUser.roleId == 4}">
                                                            <li class="sidebar-menu-category">Báº£ng Ä‘iá»u hÃ nh</li>
                                                            <li class="sidebar-item">
                                                                <a href="${pageContext.request.contextPath}/director/dashboard"
                                                                    class="sidebar-link ${param.activeMenu eq 'director-dashboard' ? 'active' : ''}">
                                                                    <i class="fas fa-tachometer-alt"></i> Tá»•ng quan
                                                                </a>
                                                            </li>
                                                            <li class="sidebar-menu-category">LÆ°Æ¡ng & PhÃª duyá»‡t</li>
                                                            <li class="sidebar-item">
                                                                <a href="${pageContext.request.contextPath}/director/payroll"
                                                                    class="sidebar-link ${param.activeMenu eq 'director-payroll' ? 'active' : ''}">
                                                                    <i class="fas fa-file-invoice-dollar"></i> Duyá»‡t báº£ng lÆ°Æ¡ng
                                                                </a>
                                                            </li>
                                                            <li class="sidebar-menu-category">BÃ¡o cÃ¡o</li>
                                                            <li class="sidebar-item">
                                                                <a href="${pageContext.request.contextPath}/director/reports" class="sidebar-link ${param.activeMenu eq 'director-reports' ? 'active' : ''}">
                                                                    <i class="fas fa-chart-line"></i> BÃ¡o cÃ¡o tá»•ng há»£p
                                                                </a>
                                                            </li>
                                                        </c:if>

                                                        <%-- â•â•â•â•â•â• HR STAFF (roleId=5) â•â•â•â•â•â•
                                                             Quyá»n: xem danh sÃ¡ch NV, upload/xem cháº¥m cÃ´ng,
                                                             quáº£n lÃ½ há»£p Ä‘á»“ng, xuáº¥t payroll.
                                                             KHÃ”NG duyá»‡t nghá»‰ phÃ©p (Supervisor/DeptMgr duyá»‡t).
                                                        --%>
                                                            <c:if test="${sessionScope.currentUser.roleId == 5}">
                                                                <li class="sidebar-menu-category">Quáº£n lÃ½ nhÃ¢n sá»±</li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/employees"
                                                                        class="sidebar-link ${param.activeMenu eq 'employees' ? 'active' : ''}">
                                                                        <i class="fas fa-users"></i> Danh sÃ¡ch nhÃ¢n viÃªn
                                                                    </a>
                                                                </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/department"
                                                                        class="sidebar-link ${param.activeMenu eq 'department' ? 'active' : ''}">
                                                                        <i class="fas fa-building"></i> PhÃ²ng ban
                                                                    </a>
                                                                </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/position"
                                                                        class="sidebar-link ${param.activeMenu eq 'position' ? 'active' : ''}">
                                                                        <i class="fas fa-id-card-alt"></i> Chá»©c vá»¥
                                                                    </a>
                                                                </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/contract-type"
                                                                        class="sidebar-link ${param.activeMenu eq 'contract-type' ? 'active' : ''}">
                                                                        <i class="fas fa-file-contract"></i> Loáº¡i há»£p Ä‘á»“ng
                                                                    </a>
                                                                </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/onboarding/list"
                                                                        class="sidebar-link ${param.activeMenu eq 'onboarding' ? 'active' : ''}">
                                                                        <i class="fas fa-user-clock"></i> Tiáº¿p nháº­n nhÃ¢n viÃªn
                                                                    </a>
                                                                </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/terminate-employee"
                                                                        class="sidebar-link ${param.activeMenu eq 'termination' ? 'active' : ''}">
                                                                        <i class="fas fa-user-minus"></i> Quáº£n lÃ½ nghá»‰ viá»‡c
                                                                    </a>
                                                                </li>

                                                                <li class="sidebar-menu-category">Cáº¥u hÃ¬nh ChÃ­nh sÃ¡ch</li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/shifts"
                                                                        class="sidebar-link ${param.activeMenu eq 'shifts' ? 'active' : ''}">
                                                                        <i class="fas fa-clock"></i> Quáº£n lÃ½ Ca lÃ m viá»‡c
                                                                    </a>
                                                                </li>

                                                                <li class="sidebar-menu-category">Cháº¥m cÃ´ng</li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/import-attendance"
                                                                        class="sidebar-link ${param.activeMenu eq 'import-attendance' ? 'active' : ''}">
                                                                        <i class="fas fa-file-import"></i> Import cháº¥m cÃ´ng
                                                                    </a>
                                                                </li>
                                                                 <li class="sidebar-item">
                                                                     <a href="${pageContext.request.contextPath}/manager/timesheet-confirm"
                                                                         class="sidebar-link ${param.activeMenu eq 'timesheet-confirm' ? 'active' : ''}">
                                                                         <i class="fas fa-check-double"></i> XÃ¡c nháº­n báº£ng cÃ´ng
                                                                     </a>
                                                                 </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/attendance-management?action=summary"
                                                                        class="sidebar-link ${param.activeMenu eq 'attendance-summary' || param.activeMenu eq 'attendance-detail' ? 'active' : ''}">
                                                                        <i class="fas fa-clipboard-check"></i> Quáº£n lÃ½ báº£ng cÃ´ng
                                                                    </a>
                                                                </li>

                                                                <li class="sidebar-menu-category">LÆ°Æ¡ng &amp; PhÃºc lá»£i</li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/allowance"
                                                                        class="sidebar-link ${param.activeMenu eq 'allowance' ? 'active' : ''}">
                                                                        <i class="fas fa-hand-holding-usd"></i> Phá»¥ cáº¥p
                                                                    </a>
                                                                </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/payroll"
                                                                        class="sidebar-link ${param.activeMenu eq 'payroll' ? 'active' : ''}">
                                                                        <i class="fas fa-file-invoice-dollar"></i> Báº£ng lÆ°Æ¡ng
                                                                    </a>
                                                                </li>


                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/insurance-rate"
                                                                        class="sidebar-link ${param.activeMenu eq 'insurance-rate' ? 'active' : ''}">
                                                                        <i class="fas fa-shield-alt"></i> Báº£o hiá»ƒm
                                                                    </a>
                                                                </li>
                                                                <li class="sidebar-item">
                                                                    <a href="${pageContext.request.contextPath}/hr/manual-reward-discipline"
                                                                        class="sidebar-link ${param.activeMenu eq 'manual-reward' ? 'active' : ''}">
                                                                        <i class="fas fa-award"></i> Khen thÆ°á»Ÿng/Ká»· luáº­t
                                                                    </a>
                                                                </li>
                                                            </c:if>

                                                            <%-- â•â•â•â•â•â• DEPARTMENT MANAGER (roleId=6) â•â•â•â•â•â•
                                                             Quyá»n: duyá»‡t nghá»‰ phÃ©p nhÃ¢n viÃªn vÄƒn phÃ²ng,
                                                             duyá»‡t yÃªu cáº§u Ä‘iá»u chá»‰nh cháº¥m cÃ´ng phÃ²ng ban.
                                                             KHÃ”NG xáº¿p ca (vÄƒn phÃ²ng chá»‰ giá» hÃ nh chÃ­nh).
                                                             KHÃ”NG cÃ³ OT (vÄƒn phÃ²ng khÃ´ng tÄƒng ca).
                                                        --%>
                                                                <c:if test="${sessionScope.currentUser.roleId == 6}">
                                                                    <li class="sidebar-menu-category">Quáº£n lÃ½ phÃ²ng ban</li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/manager/employees"
                                                                            class="sidebar-link ${param.activeMenu eq 'my-employees' ? 'active' : ''}">
                                                                            <i class="fas fa-users"></i> NhÃ¢n viÃªn cá»§a tÃ´i
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/manager/leave"
                                                                            class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                                                                            <i class="fas fa-calendar-check"></i> Duyá»‡t nghá»‰ phÃ©p
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-menu-category">Cháº¥m cÃ´ng</li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/manager/attendance-claims"
                                                                            class="sidebar-link ${param.activeMenu eq 'attendance-claims' ? 'active' : ''}">
                                                                            <i class="fas fa-balance-scale"></i> Giáº£i quyáº¿t khiáº¿u náº¡i cÃ´ng
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/manager/timesheet-confirm"
                                                                            class="sidebar-link ${param.activeMenu eq 'timesheet-confirm' ? 'active' : ''}">
                                                                            <i class="fas fa-check-double"></i> XÃ¡c nháº­n báº£ng cÃ´ng
                                                                        </a>
                                                                    </li>

                                                                </c:if>

                                                                <%-- â•â•â•â•â•â• EMPLOYEE (roleId=7) â•â•â•â•â•â• --%>
                                                                <c:if test="${sessionScope.currentUser.roleId == 7}">
                                                                    <li class="sidebar-menu-category">Ca lÃ m & Cháº¥m cÃ´ng</li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/employee/schedule"
                                                                            class="sidebar-link ${param.activeMenu eq 'schedule' ? 'active' : ''}">
                                                                            <i class="fas fa-calendar-alt"></i> Lá»‹ch phÃ¢n ca
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/employee/timesheet"
                                                                            class="sidebar-link ${param.activeMenu eq 'personal-timesheet' ? 'active' : ''}">
                                                                            <i class="fas fa-fingerprint"></i> Báº£ng cÃ´ng cÃ¡ nhÃ¢n
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/employee/attendance-claim"
                                                                            class="sidebar-link ${param.activeMenu eq 'attendance-claim' ? 'active' : ''}">
                                                                            <i class="fas fa-paper-plane"></i> YÃªu cáº§u cháº¥m láº¡i cÃ´ng
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/employee/work-history"
                                                                            class="sidebar-link ${param.activeMenu eq 'work-history' ? 'active' : ''}">
                                                                            <i class="fas fa-history"></i> Lá»‹ch sá»­ lÃ m viá»‡c
                                                                        </a>
                                                                    </li>

                                                                    <li class="sidebar-menu-category">PhÃºc lá»£i & Nghá»‰ phÃ©p</li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/employee/leave"
                                                                            class="sidebar-link ${param.activeMenu eq 'leave' ? 'active' : ''}">
                                                                            <i class="fas fa-calendar-times"></i> Nghá»‰ phÃ©p
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/employee/payroll"
                                                                            class="sidebar-link ${param.activeMenu eq 'payroll' ? 'active' : ''}">
                                                                            <i class="fas fa-file-invoice-dollar"></i> Phiáº¿u lÆ°Æ¡ng
                                                                        </a>
                                                                    </li>

                                                                </c:if>

                                                                <%-- â•â•â•â•â•â• ACCOUNTANT (roleId=8) â•â•â•â•â•â•
                                                                     Quyá»n: xem báº£ng lÆ°Æ¡ng, xÃ¡c nháº­n chuyá»ƒn khoáº£n
                                                                --%>
                                                                <c:if test="${sessionScope.currentUser.roleId == 8}">
                                                                    <li class="sidebar-menu-category">Káº¿ ToÃ¡n</li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/accountant/payroll"
                                                                            class="sidebar-link ${param.activeMenu eq 'accountant-payroll' ? 'active' : ''}">
                                                                            <i class="fas fa-file-invoice-dollar"></i> Báº£ng LÆ°Æ¡ng
                                                                        </a>
                                                                    </li>

                                                                </c:if>

                                                                <%-- â•â•â•â•â•â• TÃ€I KHOáº¢N (chung) â•â•â•â•â•â• --%>
                                                                    <li class="sidebar-menu-category">TÃ i khoáº£n</li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/profile"
                                                                            class="sidebar-link ${param.activeMenu eq 'profile' ? 'active' : ''}">
                                                                            <i class="fas fa-id-badge"></i> ThÃ´ng tin cÃ¡ nhÃ¢n
                                                                        </a>
                                                                    </li>
                                                                    <li class="sidebar-item">
                                                                        <a href="${pageContext.request.contextPath}/settings"
                                                                            class="sidebar-link ${param.activeMenu eq 'settings' ? 'active' : ''}">
                                                                            <i class="fas fa-cog"></i> CÃ i Ä‘áº·t
                                                                        </a>
                                                                    </li>

                                </ul>
                            </nav>

                            <%-- Footer --%>
                                <div class="sidebar-footer">
                                    <a href="${pageContext.request.contextPath}/logout" class="sidebar-logout"
                                        onclick="return confirm('Báº¡n cÃ³ cháº¯c cháº¯n muá»‘n Ä‘Äƒng xuáº¥t khÃ´ng?');">
                                        <i class="fas fa-sign-out-alt"></i> ÄÄƒng xuáº¥t
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


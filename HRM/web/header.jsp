<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="jakarta.tags.core" %>
        <%@taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <!-- ===== THEME: apply before first paint ===== -->
                <script>
                    (function(){
                        var t = localStorage.getItem('hrm-theme') || 'light';
                        document.documentElement.setAttribute('data-theme', t);
                    })();
                </script>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:choose>
                        <c:when test="${not empty pageTitle}">
                            <c:out value="${pageTitle} | Group4 HRM" />
                        </c:when>
                        <c:otherwise>
                            Group4 HRM - Hệ thống Quản trị Nhân sự toàn diện
                        </c:otherwise>
                    </c:choose>
                </title>

                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
                <link
                    href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap"
                    rel="stylesheet">
                
                <style>
                    /* ===== GLOBAL THEME TOKENS ===== */
                    :root {
                        --th-bg:        #f0f4f8;
                        --th-surface:   #ffffff;
                        --th-surface2:  #f8fafc;
                        --th-border:    #e2e8f0;
                        --th-text:      #0f172a;
                        --th-text2:     #2d3748;
                        --th-muted:     #64748b;
                        --th-input-bg:  #f8fafc;
                        --th-input-border: #e2e8f0;
                        --th-card-shadow: 0 2px 8px rgba(0,0,0,0.06);
                        --th-hover-bg:  #f1f5f9;
                        --th-navbar:    #0a2540;
                    }
                    [data-theme="dark"] {
                        --th-bg:        #07080f;
                        --th-surface:   rgba(255,255,255,0.05);
                        --th-surface2:  rgba(255,255,255,0.03);
                        --th-border:    rgba(255,255,255,0.09);
                        --th-text:      #f0f4ff;
                        --th-text2:     #cbd5e0;
                        --th-muted:     #8892a4;
                        --th-input-bg:  rgba(255,255,255,0.05);
                        --th-input-border: rgba(255,255,255,0.12);
                        --th-card-shadow: 0 2px 20px rgba(0,0,0,0.4);
                        --th-hover-bg:  rgba(255,255,255,0.06);
                        --th-navbar:    #050810;
                    }
                    /* Apply to body */
                    body {
                        background-color: var(--th-bg) !important;
                        color: var(--th-text) !important;
                        transition: background-color 0.3s ease, color 0.3s ease;
                    }
                    /* ===== NAVBAR EDITORIAL ===== */
                    body {
                        font-family: 'Be Vietnam Pro', sans-serif;
                    }

                    .navbar-editorial {
                        background: #0a2540;
                        padding: 0 0;
                        position: fixed;
                        top: 0;
                        left: 0;
                        right: 0;
                        z-index: 1000;
                        border-bottom: 1px solid rgba(255, 255, 255, .08);
                    }

                    .navbar-editorial .container {
                        display: flex;
                        align-items: stretch;
                        height: 64px;
                    }

                    .nav-brand {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        text-decoration: none;
                        color: #fff;
                        font-family: 'Be Vietnam Pro', sans-serif;
                        font-weight: 800;
                        font-size: 1.1rem;
                        letter-spacing: -.5px;
                        padding: 0 30px 0 0;
                        border-right: 1px solid rgba(255, 255, 255, .1);
                        margin-right: 20px;
                    }

                    .nav-brand i {
                        color: #63b3ed;
                        font-size: 1.2rem;
                    }

                    .nav-links {
                        display: flex;
                        align-items: stretch;
                        gap: 0;
                        list-style: none;
                        margin: 0;
                        padding: 0;
                    }

                    .nav-links li a {
                        display: flex;
                        align-items: center;
                        padding: 0 20px;
                        color: rgba(255, 255, 255, .6);
                        font-size: .88rem;
                        font-weight: 500;
                        text-decoration: none;
                        height: 100%;
                        border-bottom: 2px solid transparent;
                        transition: all .2s;
                    }

                    .nav-links li a:hover,
                    .nav-links li a.active {
                        color: #fff;
                        border-bottom-color: #63b3ed;
                    }

                    .nav-right {
                        margin-left: auto;
                        display: flex;
                        align-items: center;
                        gap: 12px;
                    }

                    /* ── Theme Toggle Button ── */
                    .theme-toggle-btn {
                        width: 38px;
                        height: 38px;
                        border-radius: 10px;
                        border: 1.5px solid rgba(255,255,255,0.18);
                        background: rgba(255,255,255,0.07);
                        color: rgba(255,255,255,0.75);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        cursor: pointer;
                        font-size: 1rem;
                        transition: all 0.25s;
                        flex-shrink: 0;
                    }
                    .theme-toggle-btn:hover {
                        background: rgba(255,255,255,0.15);
                        color: #fff;
                        border-color: rgba(255,255,255,0.35);
                        transform: rotate(20deg);
                    }
                    .theme-toggle-btn .icon-dark { display: none; }
                    .theme-toggle-btn .icon-light { display: inline; }
                    [data-theme="dark"] .theme-toggle-btn .icon-dark  { display: inline; }
                    [data-theme="dark"] .theme-toggle-btn .icon-light { display: none; }

                    .btn-nav-login {
                        color: rgba(255, 255, 255, .8);
                        font-size: .85rem;
                        font-weight: 600;
                        text-decoration: none;
                        padding: 8px 20px;
                        border: 1px solid rgba(255, 255, 255, .2);
                        transition: all .3s;
                    }

                    .btn-nav-login:hover {
                        background: rgba(255, 255, 255, .08);
                        color: #fff;
                        border-color: rgba(255, 255, 255, .4);
                    }



                    .user-avatar {
                        width: 34px;
                        height: 34px;
                        border-radius: 0;
                        background: linear-gradient(135deg, #2b6cb0, #63b3ed);
                        color: #fff;
                        font-weight: 800;
                        font-size: .85rem;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }

                    .navbar-editorial .dropdown-menu {
                        border-radius: 0;
                        border: 1px solid #e2e8f0;
                        box-shadow: 0 8px 30px rgba(0, 0, 0, .1);
                        margin-top: 0;
                    }

                    .hrm-notif-wrap {
                        position: relative;
                    }

                    .hrm-notif-btn {
                        width: 38px;
                        height: 38px;
                        border: 1.5px solid #e2e8f0;
                        border-radius: 10px;
                        background: #fff;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        cursor: pointer;
                        transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
                        position: relative;
                        color: #4a5568;
                        text-decoration: none;
                    }

                    .hrm-notif-btn:hover {
                        border-color: #3182ce;
                        background: #ebf8ff;
                        color: #2b6cb0;
                        box-shadow: 0 0 0 3px rgba(49, 130, 206, 0.10);
                    }

                    .hrm-notif-btn i {
                        font-size: 1rem;
                    }

                    /* Badge đỏ */
                    .hrm-notif-badge {
                        position: absolute;
                        top: -5px;
                        right: -5px;
                        min-width: 18px;
                        height: 18px;
                        padding: 0 4px;
                        background: #e53e3e;
                        color: #fff;
                        font-size: 0.65rem;
                        font-weight: 700;
                        border-radius: 9px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        border: 2px solid #fff;
                        line-height: 1;
                        opacity: 0;
                        transform: scale(0.7);
                        transition: opacity 0.2s, transform 0.2s;
                        pointer-events: none;
                    }

                    .hrm-notif-badge.visible {
                        opacity: 1;
                        transform: scale(1);
                    }

                    /* ── Dropdown panel ── */
                    .hrm-notif-dropdown {
                        display: none;
                        position: absolute;
                        top: calc(100% + 10px);
                        right: 0;
                        width: 360px;
                        background: #fff;
                        border: 1px solid #e2e8f0;
                        border-radius: 14px;
                        box-shadow: 0 12px 32px rgba(0, 0, 0, 0.12);
                        z-index: 9999;
                        overflow: hidden;
                        animation: notifSlideIn 0.18s ease;
                    }

                    .hrm-notif-dropdown.open {
                        display: block;
                    }

                    @keyframes notifSlideIn {
                        from {
                            opacity: 0;
                            transform: translateY(-8px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    /* Header của dropdown */
                    .hrm-notif-head {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 14px 18px 12px;
                        border-bottom: 1px solid #edf2f7;
                    }

                    .hrm-notif-head h6 {
                        margin: 0;
                        font-weight: 700;
                        font-size: 0.92rem;
                        color: #1a202c;
                        display: flex;
                        align-items: center;
                        gap: 7px;
                    }

                    .hrm-notif-head a {
                        font-size: 0.78rem;
                        color: #3182ce;
                        text-decoration: none;
                        font-weight: 600;
                    }

                    .hrm-notif-head a:hover {
                        text-decoration: underline;
                    }

                    /* Tab bar */
                    .hrm-notif-tabs {
                        display: flex;
                        border-bottom: 1px solid #edf2f7;
                    }

                    .hrm-notif-tab {
                        flex: 1;
                        padding: 9px 0;
                        text-align: center;
                        font-size: 0.8rem;
                        font-weight: 600;
                        color: #718096;
                        cursor: pointer;
                        border-bottom: 2px solid transparent;
                        transition: color 0.15s, border-color 0.15s;
                        background: none;
                        border-top: none;
                        border-left: none;
                        border-right: none;
                    }

                    .hrm-notif-tab.active {
                        color: #3182ce;
                        border-bottom-color: #3182ce;
                    }

                    .hrm-notif-tab:hover:not(.active) {
                        color: #4a5568;
                    }

                    /* List */
                    .hrm-notif-list {
                        max-height: 340px;
                        overflow-y: auto;
                        padding: 6px 0;
                    }

                    .hrm-notif-list::-webkit-scrollbar {
                        width: 4px;
                    }

                    .hrm-notif-list::-webkit-scrollbar-thumb {
                        background: #e2e8f0;
                        border-radius: 4px;
                    }

                    /* Từng item */
                    .hrm-notif-item {
                        display: flex;
                        align-items: flex-start;
                        gap: 12px;
                        padding: 12px 18px;
                        cursor: pointer;
                        transition: background 0.15s;
                        text-decoration: none;
                        color: inherit;
                        border-bottom: 1px solid #f7fafc;
                        position: relative;
                    }

                    .hrm-notif-item:last-child {
                        border-bottom: none;
                    }

                    .hrm-notif-item:hover {
                        background: #f8fafc;
                    }

                    .hrm-notif-item.unread {
                        background: #f0f7ff;
                    }

                    .hrm-notif-item.unread:hover {
                        background: #e8f3ff;
                    }

                    /* Dot chưa đọc */
                    .hrm-notif-item.unread::after {
                        content: '';
                        position: absolute;
                        top: 16px;
                        right: 14px;
                        width: 7px;
                        height: 7px;
                        background: #3182ce;
                        border-radius: 50%;
                    }

                    /* Icon loại thông báo */
                    .hrm-notif-icon {
                        width: 36px;
                        height: 36px;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 0.85rem;
                        flex-shrink: 0;
                        color: #fff;
                    }

                    .ni-red {
                        background: #e53e3e;
                    }

                    .ni-blue {
                        background: #3182ce;
                    }

                    .ni-green {
                        background: #38a169;
                    }

                    .ni-orange {
                        background: #dd6b20;
                    }

                    .ni-purple {
                        background: #805ad5;
                    }

                    .hrm-notif-text h6 {
                        margin: 0 0 3px;
                        font-size: 0.84rem;
                        font-weight: 700;
                        color: #2d3748;
                        line-height: 1.3;
                        padding-right: 16px;
                    }

                    .hrm-notif-text p {
                        margin: 0 0 4px;
                        font-size: 0.79rem;
                        color: #4a5568;
                        line-height: 1.4;
                    }

                    .hrm-notif-time {
                        font-size: 0.72rem;
                        color: #a0aec0;
                        font-weight: 500;
                    }

                    /* Empty state */
                    .hrm-notif-empty {
                        text-align: center;
                        padding: 40px 20px;
                        color: #a0aec0;
                    }

                    .hrm-notif-empty i {
                        font-size: 2rem;
                        margin-bottom: 10px;
                        display: block;
                    }

                    .hrm-notif-empty p {
                        margin: 0;
                        font-size: 0.85rem;
                    }

                    /* Footer */
                    .hrm-notif-footer {
                        padding: 10px 18px;
                        border-top: 1px solid #edf2f7;
                        text-align: center;
                    }

                    .hrm-notif-footer a {
                        font-size: 0.82rem;
                        color: #3182ce;
                        text-decoration: none;
                        font-weight: 600;
                    }

                    .hrm-notif-footer a:hover {
                        text-decoration: underline;
                    }
                </style>
            </head>

            <body class="d-flex flex-column min-vh-100" data-context-path="${pageContext.request.contextPath}">

                <nav class="navbar-editorial">
                    <div class="container">
                        <a class="nav-brand" href="${pageContext.request.contextPath}/home">
                            <i class="fas fa-industry"></i> TẬP ĐOÀN HRM
                        </a>

                        <ul class="nav-links">
                            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
                            <c:if test="${sessionScope.currentUser != null}">
                                <c:choose>
                                    <c:when test="${sessionScope.currentUser.roleId == 1}">
                                        <li><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                                    </c:when>
                                    <c:otherwise>
                                        <li><a href="${pageContext.request.contextPath}/employee/dashboard">Bảng điều khiển</a></li>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </ul>


                        <div class="nav-right">
                            <!-- Theme Toggle -->
                            <button class="theme-toggle-btn" id="themeToggleBtn" title="Chuyển giao diện" aria-label="Toggle theme">
                                <i class="fas fa-sun icon-light"></i>
                                <i class="fas fa-moon icon-dark"></i>
                            </button>
                            <c:if test="${sessionScope.currentUser != null}">
                                <div class="hrm-notif-wrap me-2" id="hrmNotifWrap">

                                    <%-- Nút chuông --%>
                                        <button class="hrm-notif-btn" id="hrmNotifBtn" title="Thông báo"
                                            aria-label="Thông báo">
                                            <i class="fas fa-bell"></i>
                                            <span class="hrm-notif-badge" id="hrmNotifBadge">0</span>
                                        </button>

                                        <%-- Dropdown panel --%>
                                            <div class="hrm-notif-dropdown" id="hrmNotifPanel">

                                                <%-- Header --%>
                                                    <div class="hrm-notif-head">
                                                        <h6>
                                                            <i class="fas fa-bell text-primary"></i>
                                                            Thông báo
                                                            <span id="hrmNotifUnreadLabel" class="badge"
                                                                style="background:#ebf8ff;color:#2b6cb0;font-size:0.7rem;padding:2px 8px;border-radius:10px;display:none;">
                                                                0 chưa đọc
                                                            </span>
                                                        </h6>
                                                        <a href="#" id="hrmMarkAllRead">Đánh dấu tất cả đã đọc</a>
                                                    </div>

                                                    <%-- Tabs --%>
                                                        <div class="hrm-notif-tabs">
                                                            <button class="hrm-notif-tab active" data-tab="all">Tất
                                                                cả</button>
                                                            <button class="hrm-notif-tab" data-tab="unread">Chưa
                                                                đọc</button>
                                                            <button class="hrm-notif-tab" data-tab="system">Hệ
                                                                thống</button>
                                                        </div>

                                                        <%-- Danh sách (render bằng JS từ API) --%>
                                                            <div class="hrm-notif-list" id="hrmNotifList">
                                                                <div class="hrm-notif-empty">
                                                                    <i class="fas fa-bell-slash"></i>
                                                                    <p>Đang tải thông báo...</p>
                                                                </div>
                                                            </div>

                                                            <%-- Footer --%>
                                                                <div class="hrm-notif-footer">
                                                                    <a
                                                                        href="${pageContext.request.contextPath}/notifications">Xem
                                                                        tất cả thông báo</a>
                                                                </div>

                                            </div>
                                </div>

                                <%-- ── JAVASCRIPT ── --%>
                                    <script>
                                        (function () {
                                            'use strict';

                                            var CTX = '${pageContext.request.contextPath}';
                                            var btn = document.getElementById('hrmNotifBtn');
                                            var panel = document.getElementById('hrmNotifPanel');
                                            var badge = document.getElementById('hrmNotifBadge');
                                            var list = document.getElementById('hrmNotifList');
                                            var unreadLbl = document.getElementById('hrmNotifUnreadLabel');
                                            var markAllBtn = document.getElementById('hrmMarkAllRead');
                                            var tabs = document.querySelectorAll('.hrm-notif-tab');

                                            var allData = [];
                                            var activeTab = 'all';
                                            var isOpen = false;
                                            var loaded = false;

                                            /* ── Icon map theo loại thông báo HRM ── */
                                            var iconMap = {
                                                'attendance': { cls: 'ni-blue', icon: 'fas fa-fingerprint' },
                                                'leave': { cls: 'ni-green', icon: 'fas fa-umbrella-beach' },
                                                'overtime': { cls: 'ni-orange', icon: 'fas fa-business-time' },
                                                'payroll': { cls: 'ni-blue', icon: 'fas fa-file-invoice-dollar' },
                                                'kpi': { cls: 'ni-purple', icon: 'fas fa-bullseye' },
                                                'training': { cls: 'ni-purple', icon: 'fas fa-graduation-cap' },
                                                'system': { cls: 'ni-red', icon: 'fas fa-exclamation-triangle' },
                                                'announcement': { cls: 'ni-red', icon: 'fas fa-bullhorn' },
                                                'shift': { cls: 'ni-orange', icon: 'fas fa-calendar-alt' },
                                                'default': { cls: 'ni-blue', icon: 'fas fa-bell' }
                                            };

                                            /* ── Fetch danh sách (endpoint phía dưới) ── */
                                            function loadNotifications() {
                                                fetch(CTX + '/notifications/list?limit=20')
                                                    .then(function (r) {
                                                        return r.json();
                                                    })
                                                    .then(function (data) {
                                                        allData = data.notifications || [];
                                                        loaded = true;
                                                        updateBadge(data.unreadCount || 0);
                                                        renderList(activeTab);
                                                    })
                                                    .catch(function () {
                                                        list.innerHTML = '<div class="hrm-notif-empty">' +
                                                            '<i class="fas fa-wifi" style="color:#e53e3e;"></i>' +
                                                            '<p>Không thể tải thông báo</p></div>';
                                                    });
                                            }

                                            /* ── Cập nhật badge số ── */
                                            function updateBadge(n) {
                                                if (n > 0) {
                                                    badge.textContent = n > 99 ? '99+' : n;
                                                    badge.classList.add('visible');
                                                    unreadLbl.textContent = n + ' chưa đọc';
                                                    unreadLbl.style.display = 'inline-block';
                                                } else {
                                                    badge.classList.remove('visible');
                                                    unreadLbl.style.display = 'none';
                                                }
                                            }

                                            /* ── Render danh sách theo tab ── */
                                            function renderList(tab) {
                                                var filtered = allData;
                                                if (tab === 'unread')
                                                    filtered = allData.filter(function (n) {
                                                        return !n.isRead;
                                                    });
                                                if (tab === 'system')
                                                    filtered = allData.filter(function (n) {
                                                        return n.type === 'system' || n.type === 'announcement';
                                                    });

                                                if (filtered.length === 0) {
                                                    list.innerHTML = '<div class="hrm-notif-empty">' +
                                                        '<i class="fas fa-bell-slash"></i>' +
                                                        '<p>Không có thông báo nào</p></div>';
                                                    return;
                                                }

                                                var html = filtered.map(function (n) {
                                                    var ic = iconMap[n.type] || iconMap['default'];
                                                    return '<a href="' + (n.link ? CTX + n.link : '#') + '" ' +
                                                        'class="hrm-notif-item' + (n.isRead ? '' : ' unread') + '" ' +
                                                        'data-id="' + n.id + '">' +
                                                        '<div class="hrm-notif-icon ' + ic.cls + '"><i class="' + ic.icon + '"></i></div>' +
                                                        '<div class="hrm-notif-text">' +
                                                        '<h6>' + escHtml(n.title) + '</h6>' +
                                                        '<p>' + escHtml(n.body) + '</p>' +
                                                        '<span class="hrm-notif-time"><i class="far fa-clock me-1"></i>' + escHtml(n.timeAgo) + '</span>' +
                                                        '</div>' +
                                                        '</a>';
                                                }).join('');

                                                list.innerHTML = html;

                                                /* Đánh dấu đã đọc khi click từng item */
                                                list.querySelectorAll('.hrm-notif-item[data-id]').forEach(function (el) {
                                                    el.addEventListener('click', function (e) {
                                                        var id = el.dataset.id;
                                                        if (!el.classList.contains('unread'))
                                                            return;
                                                        fetch(CTX + '/notifications/read?id=' + id, { method: 'POST' }).catch(function () { });
                                                        el.classList.remove('unread');
                                                        var n = allData.find(function (x) {
                                                            return String(x.id) === id;
                                                        });
                                                        if (n)
                                                            n.isRead = true;
                                                        var unread = allData.filter(function (x) {
                                                            return !x.isRead;
                                                        }).length;
                                                        updateBadge(unread);
                                                    });
                                                });
                                            }

                                            /* ── Escape HTML ── */
                                            function escHtml(str) {
                                                if (!str)
                                                    return '';
                                                return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
                                            }

                                            /* ── Toggle dropdown ── */
                                            btn.addEventListener('click', function (e) {
                                                e.stopPropagation();
                                                isOpen = !isOpen;
                                                if (isOpen) {
                                                    panel.classList.add('open');
                                                    if (!loaded)
                                                        loadNotifications();
                                                } else {
                                                    panel.classList.remove('open');
                                                }
                                            });

                                            /* ── Đóng khi click ngoài ── */
                                            document.addEventListener('click', function (e) {
                                                if (isOpen && !document.getElementById('hrmNotifWrap').contains(e.target)) {
                                                    panel.classList.remove('open');
                                                    isOpen = false;
                                                }
                                            });

                                            /* ── Chuyển tab ── */
                                            tabs.forEach(function (tab) {
                                                tab.addEventListener('click', function () {
                                                    tabs.forEach(function (t) {
                                                        t.classList.remove('active');
                                                    });
                                                    tab.classList.add('active');
                                                    activeTab = tab.dataset.tab;
                                                    renderList(activeTab);
                                                });
                                            });

                                            /* ── Đánh dấu tất cả đã đọc ── */
                                            markAllBtn.addEventListener('click', function (e) {
                                                e.preventDefault();
                                                fetch(CTX + '/notifications/read-all', { method: 'POST' })
                                                    .then(function () {
                                                        allData.forEach(function (n) {
                                                            n.isRead = true;
                                                        });
                                                        updateBadge(0);
                                                        renderList(activeTab);
                                                    })
                                                    .catch(function () { });
                                            });

                                            /* ── Polling tự động mỗi 60 giây ── */
                                            setInterval(function () {
                                                fetch(CTX + '/notifications/count')
                                                    .then(function (r) {
                                                        return r.json();
                                                    })
                                                    .then(function (d) {
                                                        updateBadge(d.unread || 0);
                                                        if (d.unread > 0 && loaded)
                                                            loadNotifications();
                                                    })
                                                    .catch(function () { });
                                            }, 60000);

                                            /* ── Load count ngay khi trang mở ── */
                                            fetch(CTX + '/notifications/count')
                                                .then(function (r) {
                                                    return r.json();
                                                })
                                                .then(function (d) {
                                                    updateBadge(d.unread || 0);
                                                })
                                                .catch(function () { });

                                        })();
                                    </script>

                                    <!-- Theme Toggle Script -->
                                    <script>
                                    (function(){
                                        var btn = document.getElementById('themeToggleBtn');
                                        if (!btn) return;
                                        btn.addEventListener('click', function(){
                                            var current = document.documentElement.getAttribute('data-theme') || 'light';
                                            var next = current === 'dark' ? 'light' : 'dark';
                                            document.documentElement.setAttribute('data-theme', next);
                                            localStorage.setItem('hrm-theme', next);
                                        });
                                    })();
                                    </script>
                            </c:if>

                            <c:choose>
                                <c:when test="${sessionScope.currentUser != null}">
                                    <span style="color:rgba(255,255,255,.7);font-size:.85rem;font-weight:500" class="me-3">
                                        <i class="fas fa-user-circle me-1"></i>${sessionScope.currentUser.fullName}
                                    </span>
                                    <a href="${pageContext.request.contextPath}/logout" class="btn-nav-login" style="border-radius:6px;padding:6px 16px;font-size:.8rem;">
                                        <i class="fas fa-sign-out-alt me-1"></i>Đăng xuất
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/login" class="btn-nav-login">Đăng
                                        nhập</a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </nav>

                <div style="height:64px"></div>

                <%-- ═══════════════════════════════════════════════════
                     TOAST NOTIFICATION COMPONENT
                     Đọc toastSuccess (login) hoặc toastMessage (chung)
                     từ session rồi xóa đi ngay (flash message pattern)
                ═══════════════════════════════════════════════════ --%>
                <c:set var="toastText"  value="${sessionScope.toastSuccess}" />
                <c:set var="toastType"  value="success" />
                <c:if test="${empty toastText}">
                    <c:set var="toastText" value="${sessionScope.toastMessage}" />
                    <c:set var="toastType" value="${not empty sessionScope.toastType ? sessionScope.toastType : 'info'}" />
                </c:if>

                <c:if test="${not empty toastText}">
                    <%
                        // Xóa flash message ngay sau khi đọc
                        session.removeAttribute("toastSuccess");
                        session.removeAttribute("toastMessage");
                        session.removeAttribute("toastType");
                    %>

                    <!-- Toast Container -->
                    <div id="hrm-toast-container" style="
                        position: fixed;
                        bottom: 28px;
                        right: 28px;
                        z-index: 99999;
                        display: flex;
                        flex-direction: column;
                        gap: 12px;
                        pointer-events: none;
                    ">
                        <div id="hrm-toast" style="
                            display: flex;
                            align-items: flex-start;
                            gap: 14px;
                            min-width: 320px;
                            max-width: 420px;
                            background: #ffffff;
                            border-radius: 16px;
                            box-shadow: 0 8px 32px rgba(0,0,0,0.14), 0 2px 8px rgba(0,0,0,0.08);
                            padding: 18px 20px 18px 18px;
                            pointer-events: auto;
                            border-left: 5px solid
                                <c:choose>
                                    <c:when test="${toastType == 'success'}">#22c55e</c:when>
                                    <c:when test="${toastType == 'error'}">#ef4444</c:when>
                                    <c:when test="${toastType == 'warning'}">#f59e0b</c:when>
                                    <c:otherwise>#3b82f6</c:otherwise>
                                </c:choose>;
                            opacity: 0;
                            transform: translateX(60px);
                            transition: opacity 0.4s cubic-bezier(.22,1,.36,1), transform 0.4s cubic-bezier(.22,1,.36,1);
                        ">
                            <!-- Icon -->
                            <div style="
                                flex-shrink: 0;
                                width: 40px; height: 40px;
                                border-radius: 50%;
                                display: flex; align-items: center; justify-content: center;
                                background:
                                    <c:choose>
                                        <c:when test="${toastType == 'success'}">#dcfce7</c:when>
                                        <c:when test="${toastType == 'error'}">#fee2e2</c:when>
                                        <c:when test="${toastType == 'warning'}">#fef9c3</c:when>
                                        <c:otherwise>#dbeafe</c:otherwise>
                                    </c:choose>;
                                font-size: 18px;
                                color:
                                    <c:choose>
                                        <c:when test="${toastType == 'success'}">#16a34a</c:when>
                                        <c:when test="${toastType == 'error'}">#dc2626</c:when>
                                        <c:when test="${toastType == 'warning'}">#d97706</c:when>
                                        <c:otherwise>#2563eb</c:otherwise>
                                    </c:choose>;
                            ">
                                <c:choose>
                                    <c:when test="${toastType == 'success'}">✓</c:when>
                                    <c:when test="${toastType == 'error'}">✕</c:when>
                                    <c:when test="${toastType == 'warning'}">⚠</c:when>
                                    <c:otherwise>ℹ</c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Content -->
                            <div style="flex: 1; min-width: 0;">
                                <div style="font-weight: 700; font-size: 13px; letter-spacing: 0.5px; color: #111827; margin-bottom: 3px; text-transform: uppercase;">
                                    <c:choose>
                                        <c:when test="${toastType == 'success'}">Thành công</c:when>
                                        <c:when test="${toastType == 'error'}">Lỗi</c:when>
                                        <c:when test="${toastType == 'warning'}">Cảnh báo</c:when>
                                        <c:otherwise>Thông báo</c:otherwise>
                                    </c:choose>
                                </div>
                                <div style="font-size: 13.5px; color: #4b5563; line-height: 1.5; word-break: break-word;">
                                    <c:out value="${toastText}" />
                                </div>
                            </div>

                            <!-- Close button -->
                            <button onclick="hrmDismissToast()" style="
                                flex-shrink: 0;
                                background: none; border: none; cursor: pointer;
                                color: #9ca3af; font-size: 16px; line-height: 1;
                                padding: 0; margin-top: -2px;
                            " title="Đóng">×</button>
                        </div>
                    </div>

                    <script>
                        (function () {
                            const toast = document.getElementById('hrm-toast');
                            let timer;

                            function showToast() {
                                // Slide in
                                requestAnimationFrame(() => {
                                    toast.style.opacity = '1';
                                    toast.style.transform = 'translateX(0)';
                                });
                                // Auto dismiss sau 5 giây
                                timer = setTimeout(hrmDismissToast, 5000);
                            }

                            window.hrmDismissToast = function () {
                                clearTimeout(timer);
                                toast.style.opacity = '0';
                                toast.style.transform = 'translateX(60px)';
                                setTimeout(() => {
                                    const container = document.getElementById('hrm-toast-container');
                                    if (container) container.remove();
                                }, 450);
                            };

                            // Khởi động sau khi DOM sẵn sàng
                            if (document.readyState === 'loading') {
                                document.addEventListener('DOMContentLoaded', showToast);
                            } else {
                                showToast();
                            }
                        })();
                    </script>
                </c:if>


                <main class="flex-grow-1">
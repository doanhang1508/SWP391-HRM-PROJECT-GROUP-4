<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Tất cả thông báo"/>
<jsp:include page="header.jsp"/>

<style>
    /* ─── NOTIFICATIONS PAGE STYLES ───────────────────────────────────────── */
    .notif-page-header {
        background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        padding: 40px 0;
        color: #fff;
        margin-bottom: 40px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    }

    .notif-page-title {
        font-size: 2rem;
        font-weight: 800;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 15px;
    }

    .notif-page-subtitle {
        color: rgba(255, 255, 255, 0.8);
        font-size: 1.05rem;
        margin-top: 10px;
    }

    .notif-container {
        background: #fff;
        border-radius: 16px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.05);
        overflow: hidden;
        border: 1px solid #e2e8f0;
        margin-bottom: 60px;
    }

    .notif-toolbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px 30px;
        border-bottom: 1px solid #e2e8f0;
        background: #f8fafc;
    }

    .notif-filters {
        display: flex;
        gap: 10px;
    }

    .notif-filter-btn {
        background: #fff;
        border: 1px solid #cbd5e1;
        padding: 8px 18px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 0.9rem;
        color: #64748b;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .notif-filter-btn:hover {
        border-color: #3b82f6;
        color: #3b82f6;
    }

    .notif-filter-btn.active {
        background: #ebf5ff;
        color: #2563eb;
        border-color: #93c5fd;
    }

    .mark-all-btn {
        background: none;
        border: none;
        color: #2563eb;
        font-weight: 600;
        font-size: 0.9rem;
        cursor: pointer;
        transition: color 0.2s;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .mark-all-btn:hover {
        color: #1d4ed8;
        text-decoration: underline;
    }

    /* List and Items */
    .notif-list-container {
        min-height: 400px;
    }

    .notif-item {
        display: flex;
        align-items: flex-start;
        padding: 24px 30px;
        border-bottom: 1px solid #f1f5f9;
        text-decoration: none;
        color: inherit;
        transition: background 0.2s;
        position: relative;
    }

    .notif-item:last-child {
        border-bottom: none;
    }

    .notif-item:hover {
        background: #f8fafc;
    }

    .notif-item.unread {
        background: #f0f7ff;
    }

    .notif-item.unread:hover {
        background: #e8f3ff;
    }

    .notif-icon-lg {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.3rem;
        color: #fff;
        flex-shrink: 0;
        margin-right: 20px;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

    .notif-content {
        flex-grow: 1;
    }

    .notif-content h5 {
        margin: 0 0 6px 0;
        font-size: 1.1rem;
        font-weight: 700;
        color: #1e293b;
    }

    .notif-content p {
        margin: 0 0 10px 0;
        font-size: 0.95rem;
        color: #475569;
        line-height: 1.5;
    }

    .notif-meta {
        font-size: 0.85rem;
        color: #94a3b8;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 15px;
    }

    .notif-unread-dot {
        width: 10px;
        height: 10px;
        background: #3b82f6;
        border-radius: 50%;
        position: absolute;
        top: 30px;
        right: 30px;
        display: none;
    }

    .notif-item.unread .notif-unread-dot {
        display: block;
    }

    /* Icon Colors */
    .bg-blue {
        background: #3b82f6;
    }

    .bg-green {
        background: #10b981;
    }

    .bg-orange {
        background: #f59e0b;
    }

    .bg-red {
        background: #ef4444;
    }

    .bg-purple {
        background: #8b5cf6;
    }

    /* Empty State */
    .notif-empty-state {
        text-align: center;
        padding: 80px 20px;
        color: #94a3b8;
    }

    .notif-empty-state i {
        font-size: 4rem;
        margin-bottom: 20px;
        color: #cbd5e1;
    }

    .notif-empty-state h4 {
        font-weight: 700;
        color: #475569;
        margin-bottom: 10px;
    }

    /* Loader */
    .notif-loader {
        text-align: center;
        padding: 80px;
    }

    .spinner-border {
        color: #3b82f6;
    }
</style>

<div class="notif-page-header">
    <div class="container">
        <h1 class="notif-page-title"><i class="fas fa-bell"></i> Trung tâm thông báo</h1>
        <p class="notif-page-subtitle">Xem tất cả các cập nhật, thông báo từ hệ thống và nhắc nhở công việc</p>
    </div>
</div>

<div class="container">
    <div class="notif-container">
        <div class="notif-toolbar">
            <div class="notif-filters">
                <button class="notif-filter-btn active" data-filter="all">Tất cả</button>
                <button class="notif-filter-btn" data-filter="unread">Chưa đọc</button>
                <button class="notif-filter-btn" data-filter="system">Hệ thống</button>
            </div>
            <button class="mark-all-btn" id="pageMarkAllBtn">
                <i class="fas fa-check-double"></i> Đánh dấu tất cả đã đọc
            </button>
        </div>

        <div class="notif-list-container" id="pageNotifList">
            <div class="notif-loader">
                <div class="spinner-border" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const CTX = '${pageContext.request.contextPath}';
        const listContainer = document.getElementById('pageNotifList');
        const filterBtns = document.querySelectorAll('.notif-filter-btn');
        const markAllBtn = document.getElementById('pageMarkAllBtn');

        let allNotifications = [];
        let currentFilter = 'all';

        const iconMapping = {
            'attendance': {cls: 'bg-blue', icon: 'fas fa-fingerprint'},
            'leave': {cls: 'bg-green', icon: 'fas fa-umbrella-beach'},
            'overtime': {cls: 'bg-orange', icon: 'fas fa-business-time'},
            'payroll': {cls: 'bg-blue', icon: 'fas fa-file-invoice-dollar'},
            'kpi': {cls: 'bg-purple', icon: 'fas fa-bullseye'},
            'training': {cls: 'bg-purple', icon: 'fas fa-graduation-cap'},
            'system': {cls: 'bg-red', icon: 'fas fa-exclamation-triangle'},
            'announcement': {cls: 'bg-red', icon: 'fas fa-bullhorn'},
            'shift': {cls: 'bg-orange', icon: 'fas fa-calendar-alt'},
            'default': {cls: 'bg-blue', icon: 'fas fa-bell'}
        };

        function escapeHtml(str) {
            if (!str) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        function fetchNotifications() {
            fetch(CTX + '/notifications/list?limit=100')
                .then(res => res.json())
                .then(data => {
                    allNotifications = data.notifications || [];
                    renderNotifications();
                })
                .catch(err => {
                    listContainer.innerHTML = `
                    <div class="notif-empty-state">
                        <i class="fas fa-exclamation-circle" style="color: #ef4444;"></i>
                        <h4>Lỗi tải dữ liệu</h4>
                        <p>Không thể tải thông báo. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.</p>
                    </div>`;
                });
        }

        function renderNotifications() {
            let filtered = allNotifications;

            if (currentFilter === 'unread') {
                filtered = allNotifications.filter(n => !n.isRead);
            } else if (currentFilter === 'system') {
                filtered = allNotifications.filter(n => n.type === 'system' || n.type === 'announcement');
            }

            if (filtered.length === 0) {
                listContainer.innerHTML = `
                <div class="notif-empty-state">
                    <i class="fas fa-bell-slash"></i>
                    <h4>Không có thông báo</h4>
                    <p>Bạn đã xem hết tất cả thông báo trong mục này.</p>
                </div>`;
                return;
            }

            const html = filtered.map(n => {
                const ic = iconMapping[n.type] || iconMapping['default'];
                const link = n.link ? (CTX + n.link) : '#';
                const unreadClass = n.isRead ? '' : 'unread';

                return `
                <a href="` + escapeHtml(link) + `" class="notif-item ` + unreadClass + `" data-id="` + n.id + `">
                    <div class="notif-icon-lg ` + ic.cls + `">
                        <i class="` + ic.icon + `"></i>
                    </div>
                    <div class="notif-content">
                        <h5>` + escapeHtml(n.title) + `</h5>
                        <p>` + escapeHtml(n.body) + `</p>
                        <div class="notif-meta">
                            <span><i class="far fa-clock"></i> ` + escapeHtml(n.timeAgo) + `</span>
                            <span class="type-badge">` + escapeHtml(n.type).toUpperCase() + `</span>
                        </div>
                    </div>
                    <div class="notif-unread-dot"></div>
                </a>
            `;
            }).join('');

            listContainer.innerHTML = html;
            attachClickEvents();
        }

        function attachClickEvents() {
            const items = listContainer.querySelectorAll('.notif-item.unread');
            items.forEach(item => {
                item.addEventListener('click', function (e) {
                    const id = this.dataset.id;
                    fetch(CTX + '/notifications/read?id=' + id, {method: 'POST'});

                    // Update local state so it doesn't reappear as unread immediately
                    const notif = allNotifications.find(n => String(n.id) === id);
                    if (notif) notif.isRead = true;

                    this.classList.remove('unread');
                });
            });
        }

        // Filter Buttons
        filterBtns.forEach(btn => {
            btn.addEventListener('click', function () {
                filterBtns.forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                currentFilter = this.dataset.filter;
                renderNotifications();
            });
        });

        // Mark All As Read
        markAllBtn.addEventListener('click', function () {
            if (!confirm('Đánh dấu tất cả thông báo là đã đọc?')) return;

            fetch(CTX + '/notifications/read-all', {method: 'POST'})
                .then(() => {
                    allNotifications.forEach(n => n.isRead = true);
                    renderNotifications();
                    // If header script is active, this will also update its badge eventually
                    // on the next polling, but we can't easily sync them without custom events.
                    // The page will look correct locally.
                });
        });

        // Initial load
        fetchNotifications();
    });
</script>

<jsp:include page="footer.jsp"/>

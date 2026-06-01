<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:choose>
    <c:when test="${sessionScope.currentUser.roleId == 1}">
        <c:set var="pageTitle" value="Bảng Điều Khiển Admin" scope="request"/>
    </c:when>
    <c:when test="${sessionScope.currentUser.roleId == 2}">
        <c:set var="pageTitle" value="Bảng Điều Khiển HR" scope="request"/>
    </c:when>
    <c:when test="${sessionScope.currentUser.roleId == 3}">
        <c:set var="pageTitle" value="Bảng Điều Khiển Quản Đốc" scope="request"/>
    </c:when>
    <c:when test="${sessionScope.currentUser.roleId == 4}">
        <c:set var="pageTitle" value="Bảng Điều Khiển Giám Đốc" scope="request"/>
    </c:when>
</c:choose>
<jsp:include page="header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
footer, #chatWidget { display: none !important; }

body {
    background-color: #f1f5f9 !important;
    font-family: 'Inter', sans-serif !important;
    padding-top: 0 !important;
    min-height: 100vh;
    overflow-x: hidden;
}

/* ── Layout ── */
.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.dash-main { flex: 1; min-width: 0; background: #f1f5f9; }
.dash-content { padding: 28px 32px; display: flex; flex-direction: column; gap: 28px; }

/* ── Page Header ── */
.dash-page-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; }
.dash-page-header-left { display: flex; flex-direction: column; gap: 4px; }
.dash-breadcrumb { font-size: 0.78rem; color: #94a3b8; display: flex; align-items: center; gap: 6px; }
.dash-breadcrumb a { color: #0d9488; text-decoration: none; }
.dash-breadcrumb a:hover { text-decoration: underline; }
.dash-page-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; letter-spacing: -0.5px; }
.dash-role-badge {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 14px; border-radius: 20px;
    font-size: 0.8rem; font-weight: 700;
    background: linear-gradient(135deg, #0d9488, #0369a1);
    color: #fff; box-shadow: 0 2px 8px rgba(13,148,136,0.3);
}

/* ── Stat Cards ── */
.dash-stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; }
.dash-stat-card {
    background: #fff; border-radius: 16px; padding: 22px 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e2e8f0;
    display: flex; flex-direction: column; gap: 10px;
    transition: transform 0.2s, box-shadow 0.2s;
}
.dash-stat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
.dash-stat-header { display: flex; justify-content: space-between; align-items: flex-start; }
.dash-stat-title { font-size: 0.75rem; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.6px; }
.dash-stat-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1rem; }
.dash-stat-val { font-size: 2rem; font-weight: 800; color: #0f172a; line-height: 1.1; }
.dash-stat-change { font-size: 0.75rem; font-weight: 600; display: flex; align-items: center; gap: 4px; }
.dash-stat-change.up { color: #10b981; }
.dash-stat-change.down { color: #ef4444; }
.dash-stat-change.neutral { color: #94a3b8; }

.dash-stat-card.stat-warning { border-left: 4px solid #f59e0b; }
.dash-stat-card.stat-warning .dash-stat-icon { background: #fef3c7; color: #d97706; }
.dash-stat-card.stat-danger { border-left: 4px solid #ef4444; }
.dash-stat-card.stat-danger .dash-stat-icon { background: #fee2e2; color: #dc2626; }
.dash-stat-card.stat-success { border-left: 4px solid #10b981; }
.dash-stat-card.stat-success .dash-stat-icon { background: #d1fae5; color: #059669; }
.dash-stat-card.stat-teal { border-left: 4px solid #0d9488; }
.dash-stat-card.stat-teal .dash-stat-icon { background: #ccfbf1; color: #0d9488; }
.dash-stat-card.stat-blue { border-left: 4px solid #3b82f6; }
.dash-stat-card.stat-blue .dash-stat-icon { background: #dbeafe; color: #2563eb; }
.dash-stat-card.stat-purple { border-left: 4px solid #8b5cf6; }
.dash-stat-card.stat-purple .dash-stat-icon { background: #ede9fe; color: #7c3aed; }

/* ── Charts ── */
.dash-charts-grid { display: grid; grid-template-columns: 1.6fr 1fr; gap: 20px; }
@media (max-width: 1100px) { .dash-charts-grid { grid-template-columns: 1fr; } }

.dash-card {
    background: #fff; border-radius: 16px; padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e2e8f0;
}
.dash-card-header { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
.dash-card-title { font-size: 0.95rem; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 8px; }
.dash-card-title-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.dot-teal { background: #0d9488; } .dot-blue { background: #3b82f6; } .dot-orange { background: #f59e0b; }

/* ── Table ── */
.dash-table-container { width: 100%; overflow-x: auto; }
.dash-table { width: 100%; border-collapse: collapse; text-align: left; }
.dash-table th {
    padding: 12px 16px; border-bottom: 1px solid #e2e8f0;
    color: #64748b; font-size: 0.73rem; font-weight: 700;
    text-transform: uppercase; letter-spacing: 0.6px; background: #fafbfc;
}
.dash-table td { padding: 15px 16px; border-bottom: 1px solid #f1f5f9; color: #0f172a; font-size: 0.88rem; vertical-align: middle; }
.dash-table tbody tr:last-child td { border-bottom: none; }
.dash-table tbody tr:hover td { background: #f8fafc; }
.dash-emp-cell { display: flex; align-items: center; gap: 10px; }
.dash-emp-avatar {
    width: 34px; height: 34px; border-radius: 8px;
    background: #eff6ff; color: #3b82f6;
    display: flex; align-items: center; justify-content: center;
    font-weight: 700; font-size: 0.85rem; flex-shrink: 0;
}
.dash-btn {
    padding: 6px 14px; font-size: 0.8rem; font-weight: 700;
    border-radius: 8px; border: none; cursor: pointer;
    transition: all 0.2s; text-decoration: none; display: inline-block;
}
.dash-btn-primary { background: #0d9488; color: #fff; }
.dash-btn-primary:hover { background: #0f766e; }
.dash-btn-secondary { background: #f1f5f9; color: #475569; }
.dash-btn-secondary:hover { background: #e2e8f0; }
.dash-badge { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 20px; font-size: 0.73rem; font-weight: 700; }
.badge-pending   { background: #fef3c7; color: #d97706; }
.badge-completed { background: #d1fae5; color: #059669; }
.badge-rejected  { background: #fee2e2; color: #dc2626; }

@media (max-width: 768px) { .dash-content { padding: 20px 16px; } }
</style>

<div class="dashboard-wrapper">
    <%-- Sidebar phân quyền chung --%>
    <jsp:include page="shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">

            <%-- ── Page Header ── --%>
            <div class="dash-page-header">
                <div class="dash-page-header-left">
                    <div class="dash-breadcrumb">
                        <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                        <span>/</span>
                        <span>Dashboard</span>
                    </div>
                    <div class="dash-page-title">
                        <c:choose>
                            <c:when test="${sessionScope.currentUser.roleId == 1}">Tổng Quan Hệ Thống</c:when>
                            <c:when test="${sessionScope.currentUser.roleId == 2}">Tổng Quan Nhân Sự</c:when>
                            <c:when test="${sessionScope.currentUser.roleId == 3}">Tổng Quan Xưởng Sản Xuất</c:when>
                            <c:when test="${sessionScope.currentUser.roleId == 4}">Tổng Quan Điều Hành</c:when>
                        </c:choose>
                    </div>
                </div>
                <div class="dash-role-badge">
                    <c:choose>
                        <c:when test="${sessionScope.currentUser.roleId == 1}"><i class="fas fa-server"></i> Admin</c:when>
                        <c:when test="${sessionScope.currentUser.roleId == 2}"><i class="fas fa-user-tie"></i> HR Manager</c:when>
                        <c:when test="${sessionScope.currentUser.roleId == 3}"><i class="fas fa-industry"></i> Quản Đốc</c:when>
                        <c:when test="${sessionScope.currentUser.roleId == 4}"><i class="fas fa-chess-king"></i> Giám Đốc</c:when>
                    </c:choose>
                </div>
            </div>

            <%-- ════════════════════════════════════════
                 STAT CARDS — phân theo role
            ════════════════════════════════════════ --%>

            <%-- ── ADMIN STATS ── --%>
            <c:if test="${sessionScope.currentUser.roleId == 1}">
                <div class="dash-stat-grid">
                    <div class="dash-stat-card stat-teal">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Người Dùng Hoạt Động</span>
                            <div class="dash-stat-icon"><i class="fas fa-user-check"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty activeUsers ? activeUsers : '—'}</div>
                        <div class="dash-stat-change up"><i class="fas fa-arrow-up"></i> Đang hoạt động</div>
                    </div>
                    <div class="dash-stat-card stat-blue">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Tổng Người Dùng</span>
                            <div class="dash-stat-icon"><i class="fas fa-users"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalUsers ? totalUsers : '—'}</div>
                        <div class="dash-stat-change neutral">Toàn hệ thống</div>
                    </div>
                    <div class="dash-stat-card stat-danger">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Tài Khoản Bị Khóa</span>
                            <div class="dash-stat-icon"><i class="fas fa-user-slash"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty lockedUsers ? lockedUsers : '0'}</div>
                        <div class="dash-stat-change down"><i class="fas fa-lock"></i> Đang bị tạm khóa</div>
                    </div>
                    <div class="dash-stat-card stat-success">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Vai Trò Hệ Thống</span>
                            <div class="dash-stat-icon"><i class="fas fa-user-shield"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalRoles ? totalRoles : '—'}</div>
                        <div class="dash-stat-change neutral">Đang hoạt động</div>
                    </div>
                </div>

                <%-- Admin Charts --%>
                <div class="dash-charts-grid">
                    <div class="dash-card">
                        <div class="dash-card-header">
                            <h3 class="dash-card-title">
                                <div class="dash-card-title-dot dot-teal"></div>
                                Lượt Đăng Nhập (7 Ngày Qua)
                            </h3>
                        </div>
                        <div style="position:relative;height:280px;width:100%;">
                            <canvas id="trafficChart"></canvas>
                        </div>
                    </div>
                    <div class="dash-card">
                        <div class="dash-card-header">
                            <h3 class="dash-card-title">
                                <div class="dash-card-title-dot dot-blue"></div>
                                Phân Bổ Theo Vai Trò
                            </h3>
                        </div>
                        <div style="position:relative;height:280px;width:100%;display:flex;justify-content:center;align-items:center;">
                            <canvas id="rolesChart"></canvas>
                        </div>
                    </div>
                </div>

                <%-- Admin: danh sách user gần đây --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-orange"></div>
                            Người Dùng Gần Đây
                        </h3>
                        <a href="${pageContext.request.contextPath}/admin/users" class="dash-btn dash-btn-secondary">Xem tất cả</a>
                    </div>
                    <div class="dash-table-container">
                        <table class="dash-table">
                            <thead><tr><th>Họ Tên</th><th>Email</th><th>Trạng Thái</th><th>Chi Tiết</th></tr></thead>
                            <tbody>
                                <c:forEach items="${recentUsers}" var="u">
                                    <tr>
                                        <td>
                                            <div class="dash-emp-cell">
                                                <div class="dash-emp-avatar">${fn:substring(u.fullName,0,1)}</div>
                                                <span style="font-weight:600;">${u.fullName}</span>
                                            </div>
                                        </td>
                                        <td style="color:#64748b;">${u.email}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${u.status == 1}">
                                                    <span class="dash-badge badge-completed"><i class="fas fa-circle" style="font-size:.55rem;"></i> Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="dash-badge badge-rejected"><i class="fas fa-circle" style="font-size:.55rem;"></i> Bị khóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/users?id=${u.userId}" class="dash-btn dash-btn-primary">Xem</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <%-- ── HR MANAGER STATS ── --%>
            <c:if test="${sessionScope.currentUser.roleId == 2}">
                <div class="dash-stat-grid">
                    <div class="dash-stat-card stat-teal">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Tổng Nhân Viên</span>
                            <div class="dash-stat-icon"><i class="fas fa-users"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalEmployees ? totalEmployees : '—'}</div>
                        <div class="dash-stat-change up"><i class="fas fa-user-check"></i> Đang làm việc</div>
                    </div>
                    <div class="dash-stat-card stat-success">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Phòng Ban</span>
                            <div class="dash-stat-icon"><i class="fas fa-building"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalDepartments ? totalDepartments : '—'}</div>
                        <div class="dash-stat-change neutral">Đang hoạt động</div>
                    </div>
                    <div class="dash-stat-card stat-warning">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Hợp Đồng Sắp Hết Hạn</span>
                            <div class="dash-stat-icon"><i class="fas fa-file-contract"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty expiringContracts ? expiringContracts : '0'}</div>
                        <div class="dash-stat-change down">Trong 30 ngày tới</div>
                    </div>
                    <div class="dash-stat-card stat-danger">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Đơn Nghỉ Phép</span>
                            <div class="dash-stat-icon"><i class="fas fa-calendar-days"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty pendingLeaves ? pendingLeaves : '0'}</div>
                        <div class="dash-stat-change neutral">Chờ duyệt</div>
                    </div>
                </div>

                <%-- HR Charts --%>
                <div class="dash-charts-grid">
                    <div class="dash-card">
                        <div class="dash-card-header">
                            <h3 class="dash-card-title">Nhân Viên Theo Phòng Ban</h3>
                        </div>
                        <div style="height:300px;"><canvas id="departmentChart"></canvas></div>
                    </div>
                    <div class="dash-card">
                        <div class="dash-card-header">
                            <h3 class="dash-card-title">Cơ Cấu Giới Tính</h3>
                        </div>
                        <div style="height:300px;"><canvas id="genderChart"></canvas></div>
                    </div>
                </div>

                <%-- HR: nhân viên mới nhất --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-orange"></div>
                            Nhân Viên Mới Nhất
                        </h3>
                        <a href="${pageContext.request.contextPath}/hr/employees" class="dash-btn dash-btn-secondary">Xem tất cả</a>
                    </div>
                    <div class="dash-table-container">
                        <table class="dash-table">
                            <thead><tr><th>Họ Tên</th><th>Email</th><th>Chi Tiết</th></tr></thead>
                            <tbody>
                                <c:forEach items="${recentEmployees}" var="emp">
                                    <tr>
                                        <td>
                                            <div class="dash-emp-cell">
                                                <div class="dash-emp-avatar">${fn:substring(emp.fullName,0,1)}</div>
                                                <span style="font-weight:600;">${emp.fullName}</span>
                                            </div>
                                        </td>
                                        <td style="color:#64748b;">${emp.email}</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/hr/employee-detail?id=${emp.userId}" class="dash-btn dash-btn-primary">Xem</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <%-- ── FACTORY MANAGER STATS ── --%>
            <c:if test="${sessionScope.currentUser.roleId == 3}">
                <div class="dash-stat-grid">
                    <div class="dash-stat-card stat-teal">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Tổng Nhân Viên</span>
                            <div class="dash-stat-icon"><i class="fas fa-users"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalEmployees ? totalEmployees : '—'}</div>
                        <div class="dash-stat-change up"><i class="fas fa-user-check"></i> Trong hệ thống</div>
                    </div>
                    <div class="dash-stat-card stat-warning">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">OT Chờ Duyệt</span>
                            <div class="dash-stat-icon"><i class="fas fa-clock"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty pendingOT ? pendingOT : '0'}</div>
                        <div class="dash-stat-change neutral">Chờ xử lý</div>
                    </div>
                    <div class="dash-stat-card stat-blue">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Chấm Công Hôm Nay</span>
                            <div class="dash-stat-icon"><i class="fas fa-calendar-check"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty todayAttendance ? todayAttendance : '0'}</div>
                        <div class="dash-stat-change neutral">Người đã chấm công</div>
                    </div>
                    <div class="dash-stat-card stat-success">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Phòng Ban</span>
                            <div class="dash-stat-icon"><i class="fas fa-building"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalDepartments ? totalDepartments : '—'}</div>
                        <div class="dash-stat-change neutral">Đang hoạt động</div>
                    </div>
                </div>
                <div class="dash-card" style="text-align:center;padding:48px 24px;">
                    <i class="fas fa-calendar-alt" style="font-size:3rem;color:#0d9488;margin-bottom:16px;"></i>
                    <div style="font-size:1.1rem;font-weight:700;color:#0f172a;margin-bottom:8px;">Quản lý lịch ca làm việc</div>
                    <p style="color:#64748b;margin-bottom:20px;">Xem và phân công ca cho nhân viên xưởng</p>
                    <a href="${pageContext.request.contextPath}/admin/shifts?action=schedule" class="dash-btn dash-btn-primary">
                        <i class="fas fa-arrow-right"></i> Đến lịch ca
                    </a>
                </div>
            </c:if>

            <%-- ── DIRECTOR STATS ── --%>
            <c:if test="${sessionScope.currentUser.roleId == 4}">
                <div class="dash-stat-grid">
                    <div class="dash-stat-card stat-teal">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Tổng Nhân Viên</span>
                            <div class="dash-stat-icon"><i class="fas fa-users"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalEmployees ? totalEmployees : '—'}</div>
                        <div class="dash-stat-change up"><i class="fas fa-user-check"></i> Toàn công ty</div>
                    </div>
                    <div class="dash-stat-card stat-success">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Phòng Ban</span>
                            <div class="dash-stat-icon"><i class="fas fa-building"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalDepartments ? totalDepartments : '—'}</div>
                        <div class="dash-stat-change neutral">Đang hoạt động</div>
                    </div>
                    <div class="dash-stat-card stat-blue">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Nhân Viên Hoạt Động</span>
                            <div class="dash-stat-icon"><i class="fas fa-user-check"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty activeEmployees ? activeEmployees : '—'}</div>
                        <div class="dash-stat-change up">Đang làm việc</div>
                    </div>
                    <div class="dash-stat-card stat-purple">
                        <div class="dash-stat-header">
                            <span class="dash-stat-title">Vai Trò Hệ Thống</span>
                            <div class="dash-stat-icon"><i class="fas fa-layer-group"></i></div>
                        </div>
                        <div class="dash-stat-val">${not empty totalRoles ? totalRoles : '—'}</div>
                        <div class="dash-stat-change neutral">Phân cấp quản lý</div>
                    </div>
                </div>

                <%-- Director Charts --%>
                <div class="dash-charts-grid">
                    <div class="dash-card">
                        <div class="dash-card-header">
                            <h3 class="dash-card-title">
                                <div class="dash-card-title-dot dot-teal"></div>
                                Tăng Trưởng Nhân Sự (6 Tháng)
                            </h3>
                        </div>
                        <div style="position:relative;height:280px;width:100%;">
                            <canvas id="growthChart"></canvas>
                        </div>
                    </div>
                    <div class="dash-card">
                        <div class="dash-card-header">
                            <h3 class="dash-card-title">
                                <div class="dash-card-title-dot dot-blue"></div>
                                Cơ Cấu Nhân Sự
                            </h3>
                        </div>
                        <div style="position:relative;height:280px;width:100%;display:flex;justify-content:center;align-items:center;">
                            <canvas id="structureChart"></canvas>
                        </div>
                    </div>
                </div>

                <%-- Director: quick actions --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-orange"></div>
                            Truy Cập Nhanh
                        </h3>
                    </div>
                    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;">
                        <a href="${pageContext.request.contextPath}/admin/pending-requests" class="dash-btn dash-btn-primary" style="text-align:center;padding:14px;">
                            <i class="fas fa-hourglass-half" style="display:block;font-size:1.5rem;margin-bottom:8px;"></i>
                            Đơn chờ phê duyệt
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/department" class="dash-btn dash-btn-secondary" style="text-align:center;padding:14px;">
                            <i class="fas fa-building" style="display:block;font-size:1.5rem;margin-bottom:8px;"></i>
                            Xem phòng ban
                        </a>
                        <a href="#" class="dash-btn dash-btn-secondary" style="text-align:center;padding:14px;">
                            <i class="fas fa-chart-pie" style="display:block;font-size:1.5rem;margin-bottom:8px;"></i>
                            Báo cáo nhân sự
                        </a>
                    </div>
                </div>
            </c:if>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div><%-- end dashboard-wrapper --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
const CHART_DEFAULTS = {
    font: { family: 'Inter' },
    color: '#94a3b8'
};

document.addEventListener('DOMContentLoaded', function () {
    const roleId = ${sessionScope.currentUser.roleId};

    // ── ADMIN charts ──
    if (roleId === 1) {
        new Chart(document.getElementById('trafficChart').getContext('2d'), {
            type: 'line',
            data: {
                labels: ['21/05','22/05','23/05','24/05','25/05','26/05','27/05'],
                datasets: [
                    { label: 'Đăng nhập thành công', data: [1120,1280,850,420,1340,1420,1245],
                      borderColor:'#0d9488', backgroundColor:'rgba(13,148,136,0.06)', fill:true, tension:0.35, borderWidth:2.5, pointBackgroundColor:'#0d9488', pointRadius:4 },
                    { label: 'Đăng nhập thất bại', data: [15,24,18,5,29,32,21],
                      borderColor:'#ef4444', fill:false, tension:0.35, borderWidth:2, borderDash:[6,4], pointBackgroundColor:'#ef4444', pointRadius:3 }
                ]
            },
            options: { responsive:true, maintainAspectRatio:false,
                plugins:{ legend:{ position:'top', labels:{ boxWidth:12, font:{family:'Inter',size:12}, padding:16 }}},
                scales:{ y:{ grid:{color:'rgba(0,0,0,0.04)'}, ticks:{font:{family:'Inter',size:11},color:'#94a3b8'}},
                         x:{ grid:{display:false}, ticks:{font:{family:'Inter',size:11},color:'#94a3b8'}}}}
        });
        new Chart(document.getElementById('rolesChart').getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['Admin','HR Manager','Quản đốc','Giám đốc'],
                datasets: [{ data:[10,30,20,5], backgroundColor:['#0d9488','#3b82f6','#f59e0b','#8b5cf6'], borderWidth:3, borderColor:'#fff' }]
            },
            options: { responsive:true, maintainAspectRatio:false, cutout:'68%',
                plugins:{ legend:{ position:'bottom', labels:{ boxWidth:12, padding:18, font:{family:'Inter',size:12}}}}}
        });
    }

    // ── HR charts ──
    if (roleId === 2) {
        new Chart(document.getElementById('departmentChart').getContext('2d'), {
            type: 'bar',
            data: {
                labels: ['Hành chính','Nhân sự','Kế toán','Kinh doanh','Xưởng SX'],
                datasets: [{ label:'Số nhân viên', data:[8,12,10,25,35],
                    backgroundColor:'rgba(13,148,136,0.8)', borderRadius:6 }]
            },
            options: { responsive:true, maintainAspectRatio:false,
                plugins:{ legend:{ display:false }},
                scales:{ y:{ grid:{color:'rgba(0,0,0,0.04)'}, ticks:{font:{family:'Inter',size:11},color:'#94a3b8'}},
                         x:{ grid:{display:false}, ticks:{font:{family:'Inter',size:11},color:'#94a3b8'}}}}
        });
        new Chart(document.getElementById('genderChart').getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['Nam','Nữ','Khác'],
                datasets: [{ data:[60,38,2], backgroundColor:['#3b82f6','#ec4899','#94a3b8'], borderWidth:3, borderColor:'#fff' }]
            },
            options: { responsive:true, maintainAspectRatio:false, cutout:'65%',
                plugins:{ legend:{ position:'bottom', labels:{ boxWidth:12, padding:16, font:{family:'Inter',size:12}}}}}
        });
    }

    // ── Director charts ──
    if (roleId === 4) {
        new Chart(document.getElementById('growthChart').getContext('2d'), {
            type: 'line',
            data: {
                labels: ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6'],
                datasets: [{
                    label: 'Tổng nhân viên', data: [80,85,88,90,93,95],
                    borderColor:'#0d9488', backgroundColor:'rgba(13,148,136,0.08)',
                    fill:true, tension:0.4, borderWidth:2.5, pointBackgroundColor:'#0d9488', pointRadius:5
                }]
            },
            options: { responsive:true, maintainAspectRatio:false,
                plugins:{ legend:{ position:'top', labels:{ font:{family:'Inter',size:12}}}},
                scales:{ y:{ beginAtZero:false, grid:{color:'rgba(0,0,0,0.04)'}, ticks:{font:{family:'Inter',size:11},color:'#94a3b8'}},
                         x:{ grid:{display:false}, ticks:{font:{family:'Inter',size:11},color:'#94a3b8'}}}}
        });
        new Chart(document.getElementById('structureChart').getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['Văn phòng','Xưởng SX','Kinh doanh'],
                datasets: [{ data:[40,35,25], backgroundColor:['#0d9488','#3b82f6','#f59e0b'], borderWidth:3, borderColor:'#fff' }]
            },
            options: { responsive:true, maintainAspectRatio:false, cutout:'65%',
                plugins:{ legend:{ position:'bottom', labels:{ boxWidth:12, padding:16, font:{family:'Inter',size:12}}}}}
        });
    }
});
</script>

<jsp:include page="footer.jsp" />

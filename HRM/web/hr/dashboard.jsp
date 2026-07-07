<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:choose>
    <c:when test="${currentUser.roleId == 5}">
        <c:set var="pageTitle" value="Bảng Điều Khiển HR Staff" scope="request"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Bảng Điều Khiển HR" scope="request"/>
    </c:otherwise>
</c:choose>
<jsp:include page="../header.jsp" />

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

/* ── TuVV: HR Staff — Styles bổ sung ── */
.staff-section-title {
    font-size: 1.1rem; font-weight: 800; color: #0f172a;
    display: flex; align-items: center; gap: 10px;
    padding-bottom: 8px; border-bottom: 2px solid #e2e8f0;
}
.staff-section-title i { color: #0d9488; }

.progress-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 14px; }
.progress-item {
    background: #f8fafc; border-radius: 12px; padding: 16px;
    text-align: center; border: 1px solid #e2e8f0;
    transition: transform 0.2s;
}
.progress-item:hover { transform: translateY(-1px); }
.progress-item .p-count { font-size: 1.8rem; font-weight: 800; color: #0f172a; line-height: 1.2; }
.progress-item .p-label { font-size: 0.75rem; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 4px; }
.progress-item.p-draft { border-left: 3px solid #94a3b8; }
.progress-item.p-pending { border-left: 3px solid #f59e0b; }
.progress-item.p-approved { border-left: 3px solid #10b981; }
.progress-item.p-rejected { border-left: 3px solid #ef4444; }

.alert-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
.alert-card {
    background: #fff; border-radius: 12px; padding: 18px 20px;
    border: 1px solid #e2e8f0; display: flex; align-items: center; gap: 14px;
    transition: transform 0.2s, box-shadow 0.2s;
}
.alert-card:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.06); }
.alert-icon {
    width: 44px; height: 44px; border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem; flex-shrink: 0;
}
.alert-icon.a-warning { background: #fef3c7; color: #d97706; }
.alert-icon.a-danger { background: #fee2e2; color: #dc2626; }
.alert-icon.a-info { background: #dbeafe; color: #2563eb; }
.alert-info { flex: 1; }
.alert-info .a-count { font-size: 1.3rem; font-weight: 800; color: #0f172a; }
.alert-info .a-label { font-size: 0.78rem; color: #64748b; font-weight: 500; }

.task-level { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 12px; font-size: 0.72rem; font-weight: 700; }
.level-danger { background: #fee2e2; color: #dc2626; }
.level-warning { background: #fef3c7; color: #d97706; }
.level-success { background: #d1fae5; color: #059669; }

@media (max-width: 768px) { .dash-content { padding: 20px 16px; } }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">

            <%-- ── Page Header — Badge/Title hiển thị động theo role ── --%>
            <div class="dash-page-header">
                <div class="dash-page-header-left">
                    <div class="dash-breadcrumb">
                        <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                        <span>/</span>
                        <span>Dashboard</span>
                    </div>
                    <div class="dash-page-title">
                        <c:choose>
                            <c:when test="${currentUser.roleId == 5}">Bảng Điều Khiển Công Việc HR Staff</c:when>
                            <c:otherwise>Tổng Quan Nhân Sự</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="dash-role-badge">
                    <c:choose>
                        <c:when test="${currentUser.roleId == 5}">
                            <i class="fas fa-user-edit"></i> HR Staff
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-user-tie"></i> HR Manager
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <%-- ══════════════════════════════════════════════════════════════ --%>
            <%-- ── HR MANAGER (roleId == 2): Giữ nguyên 100% nội dung cũ ── --%>
            <%-- ══════════════════════════════════════════════════════════════ --%>
            <c:if test="${currentUser.roleId == 2}">

            <%-- ── HR MANAGER STATS ── --%>
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
                <div class="dash-stat-card stat-blue" onclick="window.location.href='${pageContext.request.contextPath}/hr/payroll'" style="cursor: pointer;">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Quản Lý Bảng Lương</span>
                        <div class="dash-stat-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                    </div>
                    <div class="dash-stat-val">Lương</div>
                    <div class="dash-stat-change neutral">Click để quản lý nháp</div>
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
                                        <a href="${pageContext.request.contextPath}/hr/employee-detail?userId=${emp.userId}" class="dash-btn dash-btn-primary">Xem</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            </c:if><%-- end roleId == 2 --%>

            <%-- ══════════════════════════════════════════════════════════════════ --%>
            <%-- ── TuVV: HR STAFF (roleId == 5): Dashboard công việc vận hành ── --%>
            <%-- ══════════════════════════════════════════════════════════════════ --%>
            <c:if test="${currentUser.roleId == 5}">

            <%-- ── HR Staff: Stat Cards ── --%>
            <div class="dash-stat-grid">
                <div class="dash-stat-card stat-warning">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Hợp Đồng Sắp Hết Hạn</span>
                        <div class="dash-stat-icon"><i class="fas fa-file-contract"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty expiringContractCount ? expiringContractCount : '0'}</div>
                    <div class="dash-stat-change down"><i class="fas fa-clock"></i> Trong 30 ngày tới</div>
                    <a href="${pageContext.request.contextPath}/hr/contracts?status=expiring" class="dash-btn dash-btn-secondary" style="margin-top:4px; text-align:center;">Xem danh sách</a>
                </div>
                <div class="dash-stat-card stat-blue">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Chờ Nhân Viên Ký</span>
                        <div class="dash-stat-icon"><i class="fas fa-pen-nib"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty pendingSignatureCount ? pendingSignatureCount : '0'}</div>
                    <div class="dash-stat-change neutral"><i class="fas fa-hourglass-half"></i> Hợp đồng/phụ lục chưa xác nhận</div>
                    <a href="${pageContext.request.contextPath}/hr/contracts" class="dash-btn dash-btn-secondary" style="margin-top:4px; text-align:center;">Quản lý hợp đồng</a>
                </div>
                <div class="dash-stat-card stat-teal">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Onboarding Chờ Duyệt</span>
                        <div class="dash-stat-icon"><i class="fas fa-user-plus"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty onboardingPendingCount ? onboardingPendingCount : '0'}</div>
                    <div class="dash-stat-change neutral"><i class="fas fa-paper-plane"></i> Do bạn tạo, chờ phê duyệt</div>
                    <a href="${pageContext.request.contextPath}/hr/onboarding/list" class="dash-btn dash-btn-secondary" style="margin-top:4px; text-align:center;">Xem danh sách</a>
                </div>
                <div class="dash-stat-card stat-danger">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Onboarding Bị Từ Chối</span>
                        <div class="dash-stat-icon"><i class="fas fa-exclamation-triangle"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty onboardingRejectedCount ? onboardingRejectedCount : '0'}</div>
                    <div class="dash-stat-change down"><i class="fas fa-redo"></i> Cần sửa và gửi lại</div>
                    <a href="${pageContext.request.contextPath}/hr/onboarding/list" class="dash-btn dash-btn-secondary" style="margin-top:4px; text-align:center;">Sửa hồ sơ</a>
                </div>
            </div>

            <%-- ── HR Staff: Tiến độ nhập hồ sơ + Cảnh báo dữ liệu ── --%>
            <div class="dash-charts-grid">
                <%-- Tiến độ nhập hồ sơ onboarding --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-teal"></div>
                            Tiến Độ Nhập Hồ Sơ
                        </h3>
                        <a href="${pageContext.request.contextPath}/hr/onboarding/list" class="dash-btn dash-btn-secondary">Xem tất cả</a>
                    </div>
                    <div class="progress-grid">
                        <div class="progress-item p-draft">
                            <div class="p-count">${not empty onboardingDraftCount ? onboardingDraftCount : '0'}</div>
                            <div class="p-label"><i class="fas fa-edit"></i> Nháp</div>
                        </div>
                        <div class="progress-item p-pending">
                            <div class="p-count">${not empty onboardingPendingCountAll ? onboardingPendingCountAll : '0'}</div>
                            <div class="p-label"><i class="fas fa-clock"></i> Chờ duyệt</div>
                        </div>
                        <div class="progress-item p-approved">
                            <div class="p-count">${not empty onboardingApprovedCount ? onboardingApprovedCount : '0'}</div>
                            <div class="p-label"><i class="fas fa-check-circle"></i> Đã duyệt</div>
                        </div>
                        <div class="progress-item p-rejected">
                            <div class="p-count">${not empty onboardingRejectedCountAll ? onboardingRejectedCountAll : '0'}</div>
                            <div class="p-label"><i class="fas fa-times-circle"></i> Từ chối</div>
                        </div>
                    </div>
                </div>

                <%-- Cảnh báo dữ liệu còn thiếu --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-orange"></div>
                            Cảnh Báo Dữ Liệu Còn Thiếu
                        </h3>
                    </div>
                    <div class="alert-grid">
                        <div class="alert-card">
                            <div class="alert-icon a-warning"><i class="fas fa-university"></i></div>
                            <div class="alert-info">
                                <div class="a-count">${not empty missingBankCount ? missingBankCount : '0'}</div>
                                <div class="a-label">Thiếu thông tin ngân hàng</div>
                            </div>
                        </div>
                        <div class="alert-card">
                            <div class="alert-icon a-danger"><i class="fas fa-receipt"></i></div>
                            <div class="alert-info">
                                <div class="a-count">${not empty missingTaxCount ? missingTaxCount : '0'}</div>
                                <div class="a-label">Thiếu mã số thuế</div>
                            </div>
                        </div>
                        <div class="alert-card">
                            <div class="alert-icon a-info"><i class="fas fa-shield-alt"></i></div>
                            <div class="alert-info">
                                <div class="a-count">${not empty missingSocialInsCount ? missingSocialInsCount : '0'}</div>
                                <div class="a-label">Thiếu số BHXH</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- ── HR Staff: Bảng "Việc cần xử lý gần nhất" ── --%>
            <div class="dash-card">
                <div class="dash-card-header">
                    <h3 class="dash-card-title">
                        <div class="dash-card-title-dot dot-teal"></div>
                        Việc Cần Xử Lý Gần Nhất
                    </h3>
                </div>
                <div class="dash-table-container">
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>Việc cần xử lý</th>
                                <th>Số lượng</th>
                                <th>Mức độ</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty taskList}">
                                    <c:forEach items="${taskList}" var="task">
                                        <tr>
                                            <td style="font-weight:600;">${task.name}</td>
                                            <td>
                                                <span style="font-weight:800; font-size:1.1rem;">${task.count}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${task.level == 'danger'}">
                                                        <span class="task-level level-danger"><i class="fas fa-exclamation-circle"></i> Khẩn cấp</span>
                                                    </c:when>
                                                    <c:when test="${task.level == 'warning'}">
                                                        <span class="task-level level-warning"><i class="fas fa-exclamation-triangle"></i> Cần xử lý</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="task-level level-success"><i class="fas fa-check-circle"></i> Hoàn thành</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="${task.link}" class="dash-btn dash-btn-primary">Xem</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" style="text-align:center; color:#94a3b8; padding:30px;">
                                            <i class="fas fa-check-double" style="font-size:1.5rem; margin-bottom:8px; display:block;"></i>
                                            Không có việc cần xử lý
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            </c:if><%-- end roleId == 5 --%>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div><%-- end dashboard-wrapper --%>

<%-- ── Charts JS: chỉ render cho HR Manager (roleId == 2) ── --%>
<c:if test="${currentUser.roleId == 2}">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
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
});
</script>
</c:if>

<jsp:include page="../footer.jsp" />

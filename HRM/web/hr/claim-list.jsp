<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý khiếu nại lương - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --pri: #6366f1;
        --pri-l: rgba(99, 102, 241, 0.1);
        --ok: #10b981;
        --ok-l: rgba(16, 185, 129, 0.1);
        --ng: #ef4444;
        --ng-l: rgba(239, 68, 68, 0.1);
        --warn: #f59e0b;
        --bg: #f4f7fe;
        --card: #ffffff;
        --txt: #1e293b;
        --muted: #64748b;
    }
    body {
        background: var(--bg);
        font-family: 'Inter', sans-serif;
    }
    .dashboard-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .main-content {
        flex: 1;
        padding: 30px;
        width: calc(100% - 260px);
    }
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 28px;
    }
    .page-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--txt);
        margin: 0;
    }
    .breadcrumb-c {
        font-size: 0.85rem;
        color: var(--muted);
        margin: 4px 0 0;
    }
    .breadcrumb-c a {
        color: var(--pri);
        text-decoration: none;
    }
    .admin-panel {
        background: var(--card);
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
        border: 1px solid rgba(0, 0, 0, 0.04);
    }
    .panel-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 1px solid #f1f5f9;
    }
    .panel-title {
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--txt);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .panel-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        background: var(--pri-l);
        color: var(--pri);
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .tbl {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 6px;
    }
    .tbl th {
        color: var(--muted);
        font-weight: 600;
        font-size: 0.78rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 10px 14px;
        border: none;
    }
    .tbl td {
        background: #fff;
        padding: 14px;
        vertical-align: middle;
        color: #475569;
        font-size: 0.87rem;
        border-top: 1px solid #f1f5f9;
        border-bottom: 1px solid #f1f5f9;
    }
    .tbl tr td:first-child {
        border-left: 1px solid #f1f5f9;
        border-radius: 10px 0 0 10px;
    }
    .tbl tr td:last-child {
        border-right: 1px solid #f1f5f9;
        border-radius: 0 10px 10px 0;
    }
    .tbl tbody tr:hover td {
        background: #f8fafc;
    }
    .badge-s {
        padding: 5px 12px;
        border-radius: 6px;
        font-weight: 600;
        font-size: 0.74rem;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .b-pending {
        background: rgba(245, 158, 11, 0.1);
        color: #d97706;
    }
    .b-resolved {
        background: var(--ok-l);
        color: var(--ok);
    }
    .btn-resolve {
        background: var(--ok);
        color: #fff;
        border: none;
        border-radius: 8px;
        padding: 8px 16px;
        font-weight: 600;
        font-size: 0.82rem;
        cursor: pointer;
        transition: all 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .btn-resolve:hover {
        background: #059669;
        transform: translateY(-1px);
    }
    
    /* DETAIL GRID (Insurance Style) */
    .detail-grid {
        display: grid;
        grid-template-columns: 180px 1fr;
        gap: 12px 16px;
        font-size: .9rem;
    }
    .detail-label {
        font-weight: 600;
        color: var(--muted);
        display: flex;
        align-items: center;
    }
    .detail-value {
        font-weight: 500;
        color: var(--txt);
    }
    .detail-separator {
        grid-column: 1/-1;
        border: none;
        border-top: 1px solid rgba(0, 0, 0, 0.08);
        margin: 4px 0;
    }
</style>

<div class="dashboard-wrapper">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="payroll" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Yêu Cầu Khiếu Nại Lương</h1>
                <p class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <i class="fas fa-chevron-right mx-2" style="font-size: 0.7rem; color: var(--muted);"></i>
                    <span>Khiếu nại lương</span>
                </p>
            </div>
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.toastSuccess}">
            <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.toastSuccess}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="toastSuccess" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div class="panel-icon"><i class="fas fa-exclamation-circle"></i></div>
                    Danh sách khiếu nại phiếu lương
                </h3>
            </div>

            <div class="table-responsive">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Kỳ lương khiếu nại</th>
                            <th>Loại khiếu nại</th>
                            <th>Ngày gửi</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty claims}">
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-4">Chưa có yêu cầu khiếu nại lương nào.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="c" items="${claims}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark">${c.fullName}</div>
                                            <div class="small text-muted">${c.email}</div>
                                        </td>
                                        <td><span class="fw-semibold">Tháng ${c.month} / ${c.year}</span></td>
                                        <td>
                                            <span class="badge bg-light text-dark border">${c.complaintType}</span>
                                        </td>
                                        <td><fmt:formatDate value="${c.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${c.status eq 'Pending'}">
                                                    <span class="badge-s b-pending"><i class="fas fa-clock me-1"></i>Chờ tiếp nhận</span>
                                                </c:when>
                                                <c:when test="${c.status eq 'Accountant Checking'}">
                                                    <span class="badge-s bg-info text-dark"><i class="fas fa-university me-1"></i>Kế toán kiểm tra CK</span>
                                                </c:when>
                                                <c:when test="${c.status eq 'HR Manager Reviewing'}">
                                                    <span class="badge-s bg-primary text-white"><i class="fas fa-user-tie me-1"></i>HR Manager duyệt</span>
                                                </c:when>
                                                <c:when test="${c.status eq 'Director Reviewing'}">
                                                    <span class="badge-s bg-warning text-dark"><i class="fas fa-user-shield me-1"></i>Giám đốc duyệt</span>
                                                </c:when>
                                                <c:when test="${c.status eq 'Accountant Adjusting'}">
                                                    <span class="badge-s bg-info text-dark"><i class="fas fa-coins me-1"></i>Kế toán điều chỉnh</span>
                                                </c:when>
                                                <c:when test="${c.status eq 'Pending Close'}">
                                                    <span class="badge-s bg-dark text-white"><i class="fas fa-flag-checkered me-1"></i>Chờ đóng KN</span>
                                                </c:when>
                                                <c:when test="${c.status eq 'Resolved'}">
                                                    <span class="badge-s b-resolved"><i class="fas fa-check-circle me-1"></i>Đã giải quyết</span>
                                                </c:when>
                                                <c:when test="${c.status eq 'Rejected'}">
                                                    <span class="badge-s bg-danger text-white"><i class="fas fa-times-circle me-1"></i>Đã từ chối</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">${c.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#claimModal-${c.claimId}">
                                                <i class="fas fa-eye me-1"></i> Xem chi tiết
                                            </button>
                                        </td>
                                    </tr>

                                    <!-- Details Modal -->
                                    <div class="modal fade" id="claimModal-${c.claimId}" tabindex="-1" aria-labelledby="claimModalLabel-${c.claimId}" aria-hidden="true">
                                        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                                            <div class="modal-content" style="border:none;border-radius:18px;overflow:hidden;box-shadow:0 25px 60px rgba(0,0,0,.18);">
                                                <!-- Gradient Header -->
                                                <div class="modal-header" style="background:linear-gradient(135deg,#6366f1 0%,#8b5cf6 50%,#a78bfa 100%);padding:18px 24px;position:relative;border:none;">
                                                    <div style="position:absolute;top:0;right:0;width:120px;height:120px;background:rgba(255,255,255,.08);border-radius:0 0 0 100%;"></div>
                                                    <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                                                        <div>
                                                            <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px;">
                                                                <div style="width:38px;height:38px;background:rgba(255,255,255,.2);border-radius:10px;display:flex;align-items:center;justify-content:center;">
                                                                    <i class="fas fa-file-invoice-dollar" style="color:#fff;font-size:1rem;"></i>
                                                                </div>
                                                                <h5 style="margin:0;color:#fff;font-weight:700;font-size:1.1rem;">Khiếu Nại #${c.claimId}</h5>
                                                            </div>
                                                            <p style="margin:0;color:rgba(255,255,255,.8);font-size:.8rem;">Gửi lúc <fmt:formatDate value="${c.createdAt}" pattern="HH:mm - dd/MM/yyyy"/></p>
                                                        </div>
                                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close" style="margin:0;"></button>
                                                    </div>
                                                </div>

                                                <div class="modal-body" style="padding:18px 22px;background:#fafbff;">
                                                    <!-- Info Cards Row -->
                                                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px;">
                                                        <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:12px;">
                                                            <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;">
                                                                <div style="width:32px;height:32px;background:#eff6ff;border-radius:8px;display:flex;align-items:center;justify-content:center;">
                                                                    <i class="fas fa-user" style="color:#3b82f6;font-size:.8rem;"></i>
                                                                </div>
                                                                <span style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Nhân viên</span>
                                                            </div>
                                                            <div style="font-weight:700;color:#1e293b;font-size:.9rem;">${c.fullName}</div>
                                                            <div style="font-size:.78rem;color:#64748b;margin-top:2px;">${c.email}</div>
                                                        </div>
                                                        <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:12px;">
                                                            <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;">
                                                                <div style="width:32px;height:32px;background:#faf5ff;border-radius:8px;display:flex;align-items:center;justify-content:center;">
                                                                    <i class="fas fa-calendar-alt" style="color:#8b5cf6;font-size:.8rem;"></i>
                                                                </div>
                                                                <span style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Kỳ lương</span>
                                                            </div>
                                                            <div style="font-weight:700;color:#1e293b;font-size:.9rem;">Tháng ${c.month} / ${c.year}</div>
                                                            <div style="font-size:.78rem;color:#64748b;margin-top:2px;"><fmt:formatDate value="${c.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                                        </div>
                                                    </div>

                                                    <!-- Complaint Type & Status -->
                                                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px;">
                                                        <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:12px;">
                                                            <div style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;margin-bottom:8px;">
                                                                <i class="fas fa-tag me-1"></i>Loại khiếu nại
                                                            </div>
                                                            <span style="display:inline-block;background:#fef3c7;color:#92400e;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;">${c.complaintType}</span>
                                                        </div>
                                                        <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:12px;">
                                                            <div style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;margin-bottom:8px;">
                                                                <i class="fas fa-info-circle me-1"></i>Trạng thái
                                                            </div>
                                                            <c:choose>
                                                                <c:when test="${c.status eq 'Pending'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(245,158,11,.1);color:#d97706;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-clock"></i>Chờ tiếp nhận</span></c:when>
                                                                <c:when test="${c.status eq 'Accountant Checking'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(59,130,246,.1);color:#2563eb;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-university"></i>KT kiểm tra CK</span></c:when>
                                                                <c:when test="${c.status eq 'HR Manager Reviewing'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(99,102,241,.1);color:#6366f1;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-user-tie"></i>HR Manager duyệt</span></c:when>
                                                                <c:when test="${c.status eq 'Director Reviewing'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(245,158,11,.1);color:#d97706;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-user-shield"></i>Giám đốc duyệt</span></c:when>
                                                                <c:when test="${c.status eq 'Accountant Adjusting'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(59,130,246,.1);color:#2563eb;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-coins"></i>KT điều chỉnh</span></c:when>
                                                                <c:when test="${c.status eq 'Pending Close'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(30,41,59,.1);color:#1e293b;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-flag-checkered"></i>Chờ đóng</span></c:when>
                                                                <c:when test="${c.status eq 'Resolved'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(16,185,129,.1);color:#059669;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-check-circle"></i>Đã giải quyết</span></c:when>
                                                                <c:when test="${c.status eq 'Rejected'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(239,68,68,.1);color:#dc2626;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-times-circle"></i>Đã từ chối</span></c:when>
                                                                <c:otherwise><span style="display:inline-block;background:#f1f5f9;color:#475569;padding:5px 14px;border-radius:8px;font-weight:600;font-size:.82rem;">${c.status}</span></c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>

                                                    <!-- Description Card -->
                                                    <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:14px;margin-bottom:12px;">
                                                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
                                                            <div style="width:28px;height:28px;background:#fef3c7;border-radius:7px;display:flex;align-items:center;justify-content:center;">
                                                                <i class="fas fa-align-left" style="color:#d97706;font-size:.75rem;"></i>
                                                            </div>
                                                            <span style="font-size:.78rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Mô tả chi tiết</span>
                                                        </div>
                                                        <div style="background:#f8fafc;padding:10px 12px;border-radius:8px;border:1px solid #e2e8f0;white-space:pre-wrap;font-size:.85rem;color:#334155;line-height:1.5;">${c.description}</div>
                                                    </div>

                                                    <!-- Processing Timeline (Notes History) -->
                                                    <c:if test="${not empty c.hrStaffNote || not empty c.accountantNote || not empty c.hrManagerNote || not empty c.directorNote}">
                                                        <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:14px;margin-bottom:12px;">
                                                            <div style="display:flex;align-items:center;gap:8px;margin-bottom:16px;">
                                                                <div style="width:28px;height:28px;background:#eff6ff;border-radius:7px;display:flex;align-items:center;justify-content:center;">
                                                                    <i class="fas fa-history" style="color:#3b82f6;font-size:.75rem;"></i>
                                                                </div>
                                                                <span style="font-size:.78rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Lịch sử xử lý</span>
                                                            </div>
                                                            <div style="display:flex;flex-direction:column;gap:0;position:relative;padding-left:20px;">
                                                                <c:if test="${not empty c.hrStaffNote}">
                                                                    <div style="position:relative;padding-bottom:16px;">
                                                                        <div style="position:absolute;left:-20px;top:4px;width:12px;height:12px;background:#6366f1;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 2px #6366f1;z-index:1;"></div>
                                                                        <c:if test="${not empty c.accountantNote || not empty c.hrManagerNote || not empty c.directorNote}">
                                                                            <div style="position:absolute;left:-15px;top:16px;bottom:0;width:2px;background:#e2e8f0;"></div>
                                                                        </c:if>
                                                                        <div style="font-weight:700;color:#1e293b;font-size:.84rem;margin-bottom:4px;">${not empty c.hrStaffName ? c.hrStaffName : 'HR Staff'}</div>
                                                                        <div style="background:#f8fafc;padding:10px 14px;border-radius:8px;border-left:3px solid #6366f1;font-size:.83rem;color:#475569;line-height:1.5;">${c.hrStaffNote}</div>
                                                                    </div>
                                                                </c:if>
                                                                <c:if test="${not empty c.accountantNote}">
                                                                    <div style="position:relative;padding-bottom:16px;">
                                                                        <div style="position:absolute;left:-20px;top:4px;width:12px;height:12px;background:#0ea5e9;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 2px #0ea5e9;z-index:1;"></div>
                                                                        <c:if test="${not empty c.hrManagerNote || not empty c.directorNote}">
                                                                            <div style="position:absolute;left:-15px;top:16px;bottom:0;width:2px;background:#e2e8f0;"></div>
                                                                        </c:if>
                                                                        <div style="font-weight:700;color:#1e293b;font-size:.84rem;margin-bottom:4px;">${not empty c.accountantName ? c.accountantName : 'Kế toán'}</div>
                                                                        <div style="background:#f8fafc;padding:10px 14px;border-radius:8px;border-left:3px solid #0ea5e9;font-size:.83rem;color:#475569;line-height:1.5;">${c.accountantNote}</div>
                                                                    </div>
                                                                </c:if>
                                                                <c:if test="${not empty c.hrManagerNote}">
                                                                    <div style="position:relative;padding-bottom:16px;">
                                                                        <div style="position:absolute;left:-20px;top:4px;width:12px;height:12px;background:#f59e0b;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 2px #f59e0b;z-index:1;"></div>
                                                                        <c:if test="${not empty c.directorNote}">
                                                                            <div style="position:absolute;left:-15px;top:16px;bottom:0;width:2px;background:#e2e8f0;"></div>
                                                                        </c:if>
                                                                        <div style="font-weight:700;color:#1e293b;font-size:.84rem;margin-bottom:4px;">${not empty c.hrManagerName ? c.hrManagerName : 'HR Manager'}</div>
                                                                        <div style="background:#f8fafc;padding:10px 14px;border-radius:8px;border-left:3px solid #f59e0b;font-size:.83rem;color:#475569;line-height:1.5;">${c.hrManagerNote}</div>
                                                                    </div>
                                                                </c:if>
                                                                <c:if test="${not empty c.directorNote}">
                                                                    <div style="position:relative;padding-bottom:0;">
                                                                        <div style="position:absolute;left:-20px;top:4px;width:12px;height:12px;background:#ef4444;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 2px #ef4444;z-index:1;"></div>
                                                                        <div style="font-weight:700;color:#1e293b;font-size:.84rem;margin-bottom:4px;">${not empty c.directorName ? c.directorName : 'Giám đốc'}</div>
                                                                        <div style="background:#f8fafc;padding:10px 14px;border-radius:8px;border-left:3px solid #ef4444;font-size:.83rem;color:#475569;line-height:1.5;">${c.directorNote}</div>
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </c:if>

                                                    <!-- Action Form -->
                                                    <c:set var="canProcess" value="false" />
                                                    <c:choose>
                                                        <c:when test="${sessionScope.currentUser.roleId == 5 && (c.status eq 'Pending' || c.status eq 'Pending Close')}">
                                                            <c:set var="canProcess" value="true" />
                                                        </c:when>
                                                        <c:when test="${sessionScope.currentUser.roleId == 8 && (c.status eq 'Accountant Checking' || c.status eq 'Accountant Adjusting')}">
                                                            <c:set var="canProcess" value="true" />
                                                        </c:when>
                                                        <c:when test="${sessionScope.currentUser.roleId == 2 && (c.status eq 'HR Manager Reviewing' || c.status eq 'Pending Close')}">
                                                            <c:set var="canProcess" value="true" />
                                                        </c:when>
                                                        <c:when test="${sessionScope.currentUser.roleId == 4 && c.status eq 'Director Reviewing'}">
                                                            <c:set var="canProcess" value="true" />
                                                        </c:when>
                                                    </c:choose>

                                                    <c:if test="${canProcess}">
                                                        <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:16px;border-top:3px solid #f59e0b;">
                                                            <div style="display:flex;align-items:center;gap:8px;margin-bottom:16px;">
                                                                <div style="width:28px;height:28px;background:#fef3c7;border-radius:7px;display:flex;align-items:center;justify-content:center;">
                                                                    <i class="fas fa-edit" style="color:#d97706;font-size:.75rem;"></i>
                                                                </div>
                                                                <span style="font-weight:700;color:#1e293b;font-size:.88rem;">Xử lý khiếu nại</span>
                                                            </div>
                                                            <form action="${pageContext.request.contextPath}/hr/resolve-claim" method="POST">
                                                                <input type="hidden" name="claimId" value="${c.claimId}" />

                                                                <!-- HR Staff -->
                                                                <c:if test="${sessionScope.currentUser.roleId == 5}">
                                                                    <div style="margin-bottom:14px;">
                                                                        <label style="display:block;font-size:.78rem;font-weight:600;color:#64748b;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Ghi chú xử lý <span style="color:#ef4444;">*</span></label>
                                                                        <textarea name="hrStaffNote" rows="3" required style="width:100%;padding:10px 14px;border:1px solid #e2e8f0;border-radius:10px;font-size:.87rem;font-family:'Inter',sans-serif;outline:none;resize:vertical;transition:border .2s;" onfocus="this.style.borderColor='#6366f1';this.style.boxShadow='0 0 0 3px rgba(99,102,241,.1)'" onblur="this.style.borderColor='#e2e8f0';this.style.boxShadow='none'" placeholder="Nhập nhận xét hoặc lý do xử lý...">${c.hrStaffNote}</textarea>
                                                                    </div>
                                                                    <div style="display:flex;gap:10px;">
                                                                        <c:choose>
                                                                            <c:when test="${c.status eq 'Pending'}">
                                                                                <c:choose>
                                                                                    <c:when test="${c.complaintType eq 'Chưa nhận được tiền'}">
                                                                                        <button type="submit" name="action" value="hrStaffForwardAccountant" onclick="return confirmPayrollClaimAction('approve', this)" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:transform .2s,box-shadow .2s;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 12px rgba(99,102,241,.35)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                                                                                            <i class="fas fa-check"></i> Gửi duyệt
                                                                                        </button>
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        <button type="submit" name="action" value="hrStaffForwardManager" onclick="return confirmPayrollClaimAction('approve', this)" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:transform .2s,box-shadow .2s;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 12px rgba(99,102,241,.35)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                                                                                            <i class="fas fa-check"></i> Gửi duyệt
                                                                                        </button>
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                                <button type="submit" name="action" value="hrStaffReject" onclick="return confirmPayrollClaimAction('reject', this)" style="padding:10px 20px;background:#fff;color:#ef4444;border:1.5px solid #fca5a5;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:all .2s;" onmouseover="this.style.background='#fef2f2';this.style.borderColor='#ef4444'" onmouseout="this.style.background='#fff';this.style.borderColor='#fca5a5'">
                                                                                    <i class="fas fa-times"></i> Từ chối
                                                                                </button>
                                                                            </c:when>
                                                                            <c:when test="${c.status eq 'Pending Close'}">
                                                                                <button type="submit" name="action" value="hrStaffClose" onclick="return confirmPayrollClaimAction('approve', this)" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#10b981,#059669);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:transform .2s,box-shadow .2s;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 12px rgba(16,185,129,.35)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                                                                                    <i class="fas fa-check"></i> Gửi duyệt
                                                                                </button>
                                                                            </c:when>
                                                                        </c:choose>
                                                                    </div>
                                                                </c:if>

                                                                <!-- Accountant -->
                                                                <c:if test="${sessionScope.currentUser.roleId == 8}">
                                                                    <c:choose>
                                                                        <c:when test="${c.status eq 'Accountant Checking'}">
                                                                            <div style="margin-bottom:14px;">
                                                                                <label style="display:block;font-size:.78rem;font-weight:600;color:#64748b;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Ghi chú kiểm tra chuyển khoản <span style="color:#ef4444;">*</span></label>
                                                                                <textarea name="accountantNote" rows="3" required style="width:100%;padding:10px 14px;border:1px solid #e2e8f0;border-radius:10px;font-size:.87rem;font-family:'Inter',sans-serif;outline:none;resize:vertical;transition:border .2s;" onfocus="this.style.borderColor='#6366f1';this.style.boxShadow='0 0 0 3px rgba(99,102,241,.1)'" onblur="this.style.borderColor='#e2e8f0';this.style.boxShadow='none'" placeholder="Ghi chú về trạng thái giao dịch ngân hàng...">${c.accountantNote}</textarea>
                                                                            </div>
                                                                            <div style="display:flex;gap:10px;">
                                                                                <button type="submit" name="action" value="accountantCheckDone" onclick="return confirmPayrollClaimAction('approve', this)" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:transform .2s,box-shadow .2s;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 12px rgba(99,102,241,.35)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                                                                                    <i class="fas fa-check"></i> Gửi duyệt
                                                                                </button>
                                                                                <button type="submit" name="action" value="accountantReject" onclick="return confirmPayrollClaimAction('reject', this)" style="padding:10px 20px;background:#fff;color:#ef4444;border:1.5px solid #fca5a5;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:all .2s;" onmouseover="this.style.background='#fef2f2';this.style.borderColor='#ef4444'" onmouseout="this.style.background='#fff';this.style.borderColor='#fca5a5'">
                                                                                    <i class="fas fa-times"></i> Từ chối
                                                                                </button>
                                                                            </div>
                                                                        </c:when>
                                                                        <c:when test="${c.status eq 'Accountant Adjusting'}">
                                                                            <div style="margin-bottom:14px;">
                                                                                <label style="display:block;font-size:.78rem;font-weight:600;color:#64748b;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Ghi chú hoàn tất điều chỉnh <span style="color:#ef4444;">*</span></label>
                                                                                <textarea name="accountantNote" rows="3" required style="width:100%;padding:10px 14px;border:1px solid #e2e8f0;border-radius:10px;font-size:.87rem;font-family:'Inter',sans-serif;outline:none;resize:vertical;transition:border .2s;" onfocus="this.style.borderColor='#6366f1';this.style.boxShadow='0 0 0 3px rgba(99,102,241,.1)'" onblur="this.style.borderColor='#e2e8f0';this.style.boxShadow='none'" placeholder="Xác nhận đã chi trả hoặc khấu trừ thêm...">${c.accountantNote}</textarea>
                                                                            </div>
                                                                            <div style="display:flex;gap:10px;">
                                                                                <button type="submit" name="action" value="accountantResolvePayment" onclick="return confirmPayrollClaimAction('approve', this)" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#10b981,#059669);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:transform .2s,box-shadow .2s;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 12px rgba(16,185,129,.35)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                                                                                    <i class="fas fa-check"></i> Gửi duyệt
                                                                                </button>
                                                                            </div>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </c:if>

                                                                <!-- HR Manager -->
                                                                <c:if test="${sessionScope.currentUser.roleId == 2}">
                                                                    <div style="margin-bottom:14px;">
                                                                        <label style="display:block;font-size:.78rem;font-weight:600;color:#64748b;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Ghi chú HR Manager <span style="color:#ef4444;">*</span></label>
                                                                        <textarea name="hrManagerNote" rows="3" required style="width:100%;padding:10px 14px;border:1px solid #e2e8f0;border-radius:10px;font-size:.87rem;font-family:'Inter',sans-serif;outline:none;resize:vertical;transition:border .2s;" onfocus="this.style.borderColor='#6366f1';this.style.boxShadow='0 0 0 3px rgba(99,102,241,.1)'" onblur="this.style.borderColor='#e2e8f0';this.style.boxShadow='none'" placeholder="Nhập ý kiến của HR Manager...">${c.hrManagerNote}</textarea>
                                                                    </div>
                                                                    <c:choose>
                                                                        <c:when test="${c.status eq 'HR Manager Reviewing'}">
                                                                            <div style="margin-bottom:14px;">
                                                                                <label style="display:block;font-size:.78rem;font-weight:600;color:#64748b;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Hướng xử lý</label>
                                                                                <select name="action" style="width:100%;padding:10px 14px;border:1px solid #e2e8f0;border-radius:10px;font-size:.87rem;font-family:'Inter',sans-serif;outline:none;background:#fff;cursor:pointer;transition:border .2s;" onfocus="this.style.borderColor='#6366f1'" onblur="this.style.borderColor='#e2e8f0'">
                                                                                    <option value="hrManagerResolve">Duyệt & Đóng khiếu nại (Không cần điều chỉnh)</option>
                                                                                    <option value="hrManagerForwardDirector">Trình Giám đốc phê duyệt điều chỉnh lương</option>
                                                                                    <option value="hrManagerRequestRecheck">Yêu cầu Kế toán kiểm tra lại</option>
                                                                                </select>
                                                                            </div>
                                                                            <div style="display:flex;gap:10px;">
                                                                                <button type="submit" onclick="return confirmPayrollClaimAction('approve', this)" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#10b981,#059669);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:transform .2s,box-shadow .2s;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 12px rgba(16,185,129,.35)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                                                                                    <i class="fas fa-check"></i> Gửi duyệt
                                                                                </button>
                                                                                <button type="submit" onclick="event.preventDefault(); var form = this.closest('form'); var noteField = form.querySelector('textarea'); if (!noteField.value.trim()) { alert('Vui lòng nhập ghi chú trước khi từ chối.'); noteField.focus(); return false; } if (confirm('Bạn chắc chắn muốn từ chối khiếu nại này?')) { form.querySelector('select[name=action]').insertAdjacentHTML('beforeend', '<option value=hrManagerReject selected>Reject</option>'); form.submit(); }" style="padding:10px 20px;background:#fff;color:#ef4444;border:1.5px solid #fca5a5;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:all .2s;" onmouseover="this.style.background='#fef2f2';this.style.borderColor='#ef4444'" onmouseout="this.style.background='#fff';this.style.borderColor='#fca5a5'">
                                                                                    <i class="fas fa-times"></i> Từ chối
                                                                                </button>
                                                                            </div>
                                                                        </c:when>
                                                                        <c:when test="${c.status eq 'Pending Close'}">
                                                                            <input type="hidden" name="action" value="hrManagerClose" />
                                                                            <div style="display:flex;gap:10px;">
                                                                                <button type="submit" onclick="return confirmPayrollClaimAction('approve', this)" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#10b981,#059669);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:transform .2s,box-shadow .2s;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 12px rgba(16,185,129,.35)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                                                                                    <i class="fas fa-check"></i> Gửi duyệt
                                                                                </button>
                                                                                <button type="submit" onclick="event.preventDefault(); var form = this.closest('form'); var noteField = form.querySelector('textarea'); if (!noteField.value.trim()) { alert('Vui lòng nhập ghi chú trước khi từ chối.'); noteField.focus(); return false; } if (confirm('Bạn chắc chắn muốn từ chối khiếu nại này?')) { form.querySelector('input[name=action]').value = 'hrManagerReject'; form.submit(); }" style="padding:10px 20px;background:#fff;color:#ef4444;border:1.5px solid #fca5a5;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:all .2s;" onmouseover="this.style.background='#fef2f2';this.style.borderColor='#ef4444'" onmouseout="this.style.background='#fff';this.style.borderColor='#fca5a5'">
                                                                                    <i class="fas fa-times"></i> Từ chối
                                                                                </button>
                                                                            </div>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </c:if>

                                                                <!-- Director -->
                                                                <c:if test="${sessionScope.currentUser.roleId == 4}">
                                                                    <div style="margin-bottom:14px;">
                                                                        <label style="display:block;font-size:.78rem;font-weight:600;color:#64748b;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Ý kiến phê duyệt <span style="color:#ef4444;">*</span></label>
                                                                        <textarea name="directorNote" rows="3" required style="width:100%;padding:10px 14px;border:1px solid #e2e8f0;border-radius:10px;font-size:.87rem;font-family:'Inter',sans-serif;outline:none;resize:vertical;transition:border .2s;" onfocus="this.style.borderColor='#6366f1';this.style.boxShadow='0 0 0 3px rgba(99,102,241,.1)'" onblur="this.style.borderColor='#e2e8f0';this.style.boxShadow='none'" placeholder="Ý kiến phê duyệt...">${c.directorNote}</textarea>
                                                                    </div>
                                                                    <div style="display:flex;gap:10px;">
                                                                        <button type="submit" name="action" value="directorApprove" onclick="return confirmPayrollClaimAction('approve', this)" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#10b981,#059669);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:transform .2s,box-shadow .2s;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 12px rgba(16,185,129,.35)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                                                                            <i class="fas fa-check"></i> Gửi duyệt
                                                                        </button>
                                                                        <button type="submit" name="action" value="directorReject" onclick="return confirmPayrollClaimAction('reject', this)" style="padding:10px 20px;background:#fff;color:#ef4444;border:1.5px solid #fca5a5;border-radius:10px;font-weight:600;font-size:.85rem;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;transition:all .2s;" onmouseover="this.style.background='#fef2f2';this.style.borderColor='#ef4444'" onmouseout="this.style.background='#fff';this.style.borderColor='#fca5a5'">
                                                                            <i class="fas fa-times"></i> Từ chối
                                                                        </button>
                                                                    </div>
                                                                </c:if>
                                                            </form>
                                                        </div>
                                                    </c:if>
                                                </div>

                                                <!-- Footer -->
                                                <div class="modal-footer" style="padding:12px 22px;background:#fff;border-top:1px solid #f1f5f9;display:flex;justify-content:flex-end;">
                                                    <button type="button" data-bs-dismiss="modal" style="padding:8px 20px;background:#f1f5f9;color:#64748b;border:none;border-radius:8px;font-weight:600;font-size:.85rem;cursor:pointer;transition:background .2s;" onmouseover="this.style.background='#e2e8f0'" onmouseout="this.style.background='#f1f5f9'">Đóng</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    function confirmPayrollClaimAction(actionType, btn) {
        var form = btn.closest('form');
        var noteField = form.querySelector('textarea');
        if (noteField && !noteField.value.trim()) {
            alert('Vui lòng nhập ghi chú / ý kiến xử lý trước khi thực hiện.');
            noteField.focus();
            return false;
        }
        var msg = actionType === 'approve' ? 'Bạn chắc chắn muốn gửi duyệt khiếu nại này?' : 'Bạn chắc chắn muốn từ chối khiếu nại này?';
        return confirm(msg);
    }
</script>

<jsp:include page="../footer.jsp" />

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
                            <th>Số tiền mong muốn</th>
                            <th>Ngày gửi</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty claims}">
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">Chưa có yêu cầu khiếu nại lương nào.</td>
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
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty c.expectedAmount && c.expectedAmount > 0}">
                                                    <span class="text-primary fw-semibold"><fmt:formatNumber value="${c.expectedAmount}" type="number" groupingUsed="true"/> ₫</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">--</span>
                                                </c:otherwise>
                                            </c:choose>
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
                                        <div class="modal-dialog modal-lg">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title fw-bold" id="claimModalLabel-${c.claimId}">
                                                        Chi tiết Khiếu nại Lương #${c.claimId}
                                                    </h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                </div>
                                                <div class="modal-body text-start">
                                                    <!-- Info Section -->
                                                    <div class="row mb-3">
                                                        <div class="col-md-6 mb-2">
                                                            <strong>Nhân viên khiếu nại:</strong>
                                                            <div>${c.fullName} (${c.email})</div>
                                                        </div>
                                                        <div class="col-md-6 mb-2">
                                                            <strong>Kỳ lương & Ngày gửi:</strong>
                                                            <div>Tháng ${c.month}/${c.year} - <fmt:formatDate value="${c.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                                        </div>
                                                        <div class="col-md-6 mb-2">
                                                            <strong>Loại khiếu nại:</strong>
                                                            <div><span class="badge bg-secondary">${c.complaintType}</span></div>
                                                        </div>
                                                        <div class="col-md-6 mb-2">
                                                            <strong>Số tiền đề xuất từ Employee:</strong>
                                                            <div>
                                                                <c:choose>
                                                                    <c:when test="${not empty c.expectedAmount && c.expectedAmount > 0}">
                                                                        <span class="text-primary fw-bold"><fmt:formatNumber value="${c.expectedAmount}" type="number" groupingUsed="true"/> ₫</span>
                                                                    </c:when>
                                                                    <c:otherwise>Không đề xuất số tiền cụ thể</c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="mb-3">
                                                        <strong>Mô tả chi tiết từ nhân viên:</strong>
                                                        <div class="p-3 bg-light rounded border mt-1" style="white-space: pre-wrap;">${c.description}</div>
                                                    </div>

                                                    <c:if test="${not empty c.evidence}">
                                                        <div class="mb-3">
                                                            <strong>Minh chứng đính kèm:</strong>
                                                            <div class="mt-1">
                                                                <c:choose>
                                                                    <c:when test="${c.evidence.startsWith('http')}">
                                                                        <a href="${c.evidence}" target="_blank" class="btn btn-sm btn-link p-0"><i class="fas fa-external-link-alt me-1"></i> Xem link minh chứng</a>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted"><i class="fas fa-file-alt me-1"></i> ${c.evidence}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </c:if>

                                                    <hr />

                                                    <!-- Workflow Notes History -->
                                                    <h6 class="fw-bold mb-3"><i class="fas fa-history me-1 text-primary"></i>Lịch sử xử lý & Ghi chú</h6>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-2">
                                                            <strong>HR Staff Note:</strong>
                                                            <div class="small text-muted">${not empty c.hrStaffNote ? c.hrStaffNote : '(Không có ghi chú)'}</div>
                                                        </div>
                                                        <div class="col-md-6 mb-2">
                                                            <strong>Kế toán Note & Đề xuất điều chỉnh:</strong>
                                                            <div class="small text-muted">
                                                                Ghi chú: ${not empty c.accountantNote ? c.accountantNote : '(Không có ghi chú)'}<br/>
                                                                Đề xuất điều chỉnh lương: 
                                                                <span class="text-success fw-bold">
                                                                    <fmt:formatNumber value="${not empty c.proposedAdjustment ? c.proposedAdjustment : 0}" type="number" groupingUsed="true"/> ₫
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6 mb-2">
                                                            <strong>HR Manager Note:</strong>
                                                            <div class="small text-muted">${not empty c.hrManagerNote ? c.hrManagerNote : '(Không có ghi chú)'}</div>
                                                        </div>
                                                        <div class="col-md-6 mb-2">
                                                            <strong>Giám đốc Note:</strong>
                                                            <div class="small text-muted">${not empty c.directorNote ? c.directorNote : '(Không có ghi chú)'}</div>
                                                        </div>
                                                    </div>

                                                    <!-- Action Form (Conditional based on Role and Status) -->
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
                                                        <hr />
                                                        <h6 class="fw-bold text-warning mb-3"><i class="fas fa-edit me-1"></i>Form xử lý dành cho bạn</h6>
                                                        <form action="${pageContext.request.contextPath}/hr/resolve-claim" method="POST">
                                                            <input type="hidden" name="claimId" value="${c.claimId}" />

                                                            <!-- HR Staff processing -->
                                                            <c:if test="${sessionScope.currentUser.roleId == 5}">
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">Ghi chú của HR Staff <span class="text-danger">*</span></label>
                                                                    <textarea name="hrStaffNote" class="form-control" rows="3" placeholder="Nhập nhận xét hoặc lý do xử lý..." required>${c.hrStaffNote}</textarea>
                                                                </div>
                                                                <div class="d-flex gap-2">
                                                                    <c:choose>
                                                                        <c:when test="${c.status eq 'Pending'}">
                                                                            <c:choose>
                                                                                <c:when test="${c.complaintType eq 'Chưa nhận được tiền'}">
                                                                                    <button type="submit" name="action" value="hrStaffForwardAccountant" class="btn btn-primary">
                                                                                        <i class="fas fa-share me-1"></i> Chuyển Kế toán kiểm tra chuyển khoản
                                                                                    </button>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <button type="submit" name="action" value="hrStaffForwardManager" class="btn btn-primary">
                                                                                        <i class="fas fa-share me-1"></i> Trình HR Manager duyệt
                                                                                    </button>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                            <button type="submit" name="action" value="hrStaffReject" class="btn btn-danger" onclick="return confirm('Bạn chắc chắn muốn từ chối khiếu nại này?')">
                                                                                <i class="fas fa-times me-1"></i> Từ chối
                                                                            </button>
                                                                        </c:when>
                                                                        <c:when test="${c.status eq 'Pending Close'}">
                                                                            <button type="submit" name="action" value="hrStaffClose" class="btn btn-success">
                                                                                <i class="fas fa-check-double me-1"></i> Đóng khiếu nại (Đã xử lý xong)
                                                                            </button>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </div>
                                                            </c:if>

                                                            <!-- Accountant processing -->
                                                            <c:if test="${sessionScope.currentUser.roleId == 8}">
                                                                <c:choose>
                                                                    <c:when test="${c.status eq 'Accountant Checking'}">
                                                                        <div class="mb-3">
                                                                            <label class="form-label fw-semibold">Ghi chú kiểm tra chuyển khoản <span class="text-danger">*</span></label>
                                                                            <textarea name="accountantNote" class="form-control" rows="3" placeholder="Ghi chú về trạng thái giao dịch ngân hàng..." required>${c.accountantNote}</textarea>
                                                                        </div>
                                                                        <div class="d-flex gap-2">
                                                                            <button type="submit" name="action" value="accountantCheckDone" class="btn btn-primary">
                                                                                <i class="fas fa-check me-1"></i> Xác nhận & chuyển lại đóng khiếu nại
                                                                            </button>
                                                                            <button type="submit" name="action" value="accountantReject" class="btn btn-danger" onclick="return confirm('Bạn chắc chắn muốn từ chối khiếu nại này?')">
                                                                                <i class="fas fa-times me-1"></i> Từ chối
                                                                            </button>
                                                                        </div>
                                                                    </c:when>
                                                                    <c:when test="${c.status eq 'Accountant Adjusting'}">
                                                                        <div class="mb-3">
                                                                            <label class="form-label fw-semibold">Ghi chú hoàn tất điều chỉnh thanh toán <span class="text-danger">*</span></label>
                                                                            <textarea name="accountantNote" class="form-control" rows="3" placeholder="Xác nhận đã chi trả hoặc khấu trừ thêm..." required>${c.accountantNote}</textarea>
                                                                        </div>
                                                                        <div class="d-flex gap-2">
                                                                            <button type="submit" name="action" value="accountantResolvePayment" class="btn btn-success">
                                                                                <i class="fas fa-check-double me-1"></i> Hoàn tất thanh toán & Đóng khiếu nại
                                                                            </button>
                                                                        </div>
                                                                    </c:when>
                                                                </c:choose>
                                                            </c:if>

                                                            <!-- HR Manager processing -->
                                                            <c:if test="${sessionScope.currentUser.roleId == 2}">
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">Ghi chú của HR Manager <span class="text-danger">*</span></label>
                                                                    <textarea name="hrManagerNote" class="form-control" rows="3" placeholder="Nhập ý kiến của HR Manager..." required>${c.hrManagerNote}</textarea>
                                                                </div>
                                                                <div class="d-flex flex-wrap gap-2">
                                                                    <c:choose>
                                                                        <c:when test="${c.status eq 'HR Manager Reviewing'}">
                                                                            <button type="submit" name="action" value="hrManagerResolve" class="btn btn-success">
                                                                                <i class="fas fa-check me-1"></i> Duyệt & Đóng khiếu nại (Không cần điều chỉnh)
                                                                            </button>
                                                                            <button type="submit" name="action" value="hrManagerForwardDirector" class="btn btn-primary">
                                                                                <i class="fas fa-share me-1"></i> Trình Giám đốc phê duyệt điều chỉnh lương
                                                                            </button>
                                                                            <button type="submit" name="action" value="hrManagerRequestRecheck" class="btn btn-warning">
                                                                                <i class="fas fa-undo me-1"></i> Yêu cầu Kế toán kiểm tra lại
                                                                            </button>
                                                                            <button type="submit" name="action" value="hrManagerReject" class="btn btn-danger" onclick="return confirm('Bạn chắc chắn muốn từ chối khiếu nại này?')">
                                                                                <i class="fas fa-times me-1"></i> Từ chối
                                                                            </button>
                                                                        </c:when>
                                                                        <c:when test="${c.status eq 'Pending Close'}">
                                                                            <button type="submit" name="action" value="hrManagerClose" class="btn btn-success">
                                                                                <i class="fas fa-check-double me-1"></i> Đóng khiếu nại (Đã xử lý xong)
                                                                            </button>
                                                                            <button type="submit" name="action" value="hrManagerReject" class="btn btn-danger" onclick="return confirm('Bạn chắc chắn muốn từ chối khiếu nại này?')">
                                                                                <i class="fas fa-times me-1"></i> Từ chối
                                                                            </button>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </div>
                                                            </c:if>

                                                            <!-- Director processing -->
                                                            <c:if test="${sessionScope.currentUser.roleId == 4}">
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-semibold">Ý kiến phê duyệt của Giám đốc <span class="text-danger">*</span></label>
                                                                    <textarea name="directorNote" class="form-control" rows="3" placeholder="Ý kiến phê duyệt..." required>${c.directorNote}</textarea>
                                                                </div>
                                                                <div class="d-flex gap-2">
                                                                    <button type="submit" name="action" value="directorApprove" class="btn btn-success">
                                                                        <i class="fas fa-check-double me-1"></i> Phê duyệt điều chỉnh (Chuyển Kế toán thanh toán)
                                                                    </button>
                                                                    <button type="submit" name="action" value="directorReject" class="btn btn-danger" onclick="return confirm('Bạn chắc chắn muốn từ chối khiếu nại này?')">
                                                                        <i class="fas fa-times me-1"></i> Từ chối
                                                                    </button>
                                                                </div>
                                                            </c:if>
                                                        </form>
                                                    </c:if>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
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

<jsp:include page="../footer.jsp" />

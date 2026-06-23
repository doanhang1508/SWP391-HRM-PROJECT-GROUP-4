<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Duyệt Bảng Công - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<!-- Google Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    :root {
        --pri: #6366f1;
        --pri-l: rgba(99,102,241,.1);
        --ok: #10b981;
        --ok-l: rgba(16,185,129,.1);
        --ng: #ef4444;
        --ng-l: rgba(239,68,68,.1);
        --warn: #f59e0b;
        --bg: #f4f7fe;
        --card: #fff;
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
        flex-wrap: wrap;
        gap: 12px;
    }
    .page-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--txt);
        margin: 0;
    }
    .breadcrumb-c {
        font-size: .85rem;
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
        box-shadow: 0 4px 20px rgba(0,0,0,.03);
        border: 1px solid rgba(0,0,0,.04);
        margin-bottom: 24px;
    }
    .panel-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 1px solid #f1f5f9;
        flex-wrap: wrap;
        gap: 10px;
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
        background: transparent;
        color: var(--muted);
        font-weight: 600;
        font-size: .78rem;
        text-transform: uppercase;
        letter-spacing: .5px;
        padding: 10px 14px;
        border: none;
        white-space: nowrap;
    }
    .tbl td {
        background: #fff;
        padding: 13px 14px;
        vertical-align: middle;
        color: #475569;
        font-size: .87rem;
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
        font-size: .74rem;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .b-draft {
        background: rgba(100, 116, 139, 0.1);
        color: #475569;
    }
    .b-pending {
        background: rgba(245, 158, 11, 0.1);
        color: #d97706;
    }
    .b-approved {
        background: var(--ok-l);
        color: var(--ok);
    }
    .b-rejected {
        background: var(--ng-l);
        color: var(--ng);
    }
    .b-info {
        background: rgba(59, 130, 246, 0.1);
        color: #2563eb;
    }
    .alert-c {
        border: none;
        border-radius: 10px;
        font-size: .88rem;
        padding: 12px 20px;
    }
    .a-ok {
        background: #d1fae5;
        color: #065f46;
    }
    .a-err {
        background: #fee2e2;
        color: #991b1b;
    }
    .btn-a {
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 8px;
        border: none;
        color: #fff;
        padding: 0 12px;
        font-size: .82rem;
        font-weight: 500;
        text-decoration: none;
        gap: 5px;
        cursor: pointer;
        transition: all .2s;
    }
    .btn-a:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 10px rgba(0,0,0,.12);
        color: #fff;
    }
    .btn-edit {
        background: #3b82f6;
    }
    .btn-submit {
        background: var(--ok);
    }
    .btn-view {
        background: #0d9488;
    }
    @media(max-width:768px) {
        .main-content {
            width: 100% !important;
            padding: 20px 16px !important;
        }
        .page-header {
            flex-direction: column;
            align-items: flex-start;
        }
    }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="timesheet-approval" />
    </jsp:include>

    <div class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <div>
                <h1 class="page-title">Duyệt Bảng Chấm Công (HR Manager)</h1>
                <p class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Phê duyệt bảng công
                </p>
            </div>
        </div>

        <!-- Message Alerts -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-c a-ok alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-check-circle me-2"></i> ${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-c a-err alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i> ${sessionScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div class="panel-icon bg-success text-white"><i class="fas fa-user-check"></i></div>
                    Danh sách bảng công chờ duyệt cuối
                </h3>
            </div>

            <!-- Filter Month/Year -->
            <div class="row g-3 align-items-center mb-4">
                <div class="col-md-2">
                    <label class="form-label small fw-bold text-muted">Tháng</label>
                    <select id="filterMonth" onchange="reloadApprovalPeriod()" class="form-select" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small fw-bold text-muted">Năm</label>
                    <select id="filterYear" onchange="reloadApprovalPeriod()" class="form-select" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                        <c:forEach var="y" begin="2024" end="2030">
                            <option value="${y}" ${selectedYear == y ? 'selected' : ''}>${y}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <script>
                function reloadApprovalPeriod() {
                    var month = document.getElementById('filterMonth').value;
                    var year = document.getElementById('filterYear').value;
                    window.location.href = '${pageContext.request.contextPath}/hr/timesheet-approval?month=' + month + '&year=' + year;
                }
            </script>

            <!-- Table list of pending confirmations -->
            <c:choose>
                <c:when test="${empty confirmations}">
                    <div class="text-center py-5 border rounded bg-white" style="color:var(--muted)">
                        <i class="fas fa-check-circle fa-3x text-success mb-3" style="opacity:.6"></i>
                        <p class="mb-0 fw-bold">Không có bảng công nào cần duyệt hoặc đã xử lý trong kỳ này.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Phòng Ban</th>
                                    <th>Kỳ Công</th>
                                    <th>Trạng Thái</th>
                                    <th>Xác Nhận Bởi</th>
                                    <th>Lý Do Phản Hồi</th>
                                    <th class="text-end">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="c" items="${confirmations}">
                                    <tr>
                                        <td><strong>${c.departmentName}</strong></td>
                                        <td>Tháng ${c.month}/${c.year}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${c.status == 'DEPARTMENT_CONFIRMED'}"><span class="badge-s b-pending"><i class="fas fa-check"></i> Trưởng phòng xác nhận</span></c:when>
                                                <c:when test="${c.status == 'SENT_TO_HR_MANAGER'}"><span class="badge-s b-info"><i class="fas fa-user-tie"></i> Chờ duyệt cuối</span></c:when>
                                                <c:when test="${c.status == 'HR_MANAGER_APPROVED'}"><span class="badge-s b-approved" style="background:#ecfdf5;color:#047857;"><i class="fas fa-check-double"></i> Đã duyệt cuối (Khóa)</span></c:when>
                                                <c:when test="${c.status == 'HR_MANAGER_REJECTED'}"><span class="badge-s b-rejected"><i class="fas fa-times"></i> Đã từ chối duyệt</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div style="font-size:0.85rem">${c.updatedByName != null ? c.updatedByName : '-'}</div>
                                            <div style="font-size:0.75rem" class="text-muted">
                                                <c:if test="${c.updatedAt != null}">
                                                    <fmt:formatDate value="${c.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:if>
                                            </div>
                                        </td>
                                        <td class="text-danger small" style="max-width:200px">${c.rejectReason != null ? c.rejectReason : '-'}</td>
                                        <td class="text-end">
                                            <c:if test="${c.status == 'SENT_TO_HR_MANAGER' || c.status == 'DEPARTMENT_CONFIRMED'}">
                                                <form action="${pageContext.request.contextPath}/hr/timesheet-approval" method="post" style="display:inline-block">
                                                    <input type="hidden" name="action" value="hrManagerApprove">
                                                    <input type="hidden" name="id" value="${c.id}">
                                                    <input type="hidden" name="month" value="${selectedMonth}">
                                                    <input type="hidden" name="year" value="${selectedYear}">
                                                    <button type="submit" class="btn-a btn-submit" onclick="return confirm('Bạn chắc chắn muốn DUYỆT CUỐI bảng công phòng ban này?')">
                                                        <i class="fas fa-check"></i> Duyệt
                                                    </button>
                                                </form>
                                                <button class="btn-a btn-edit" style="background:var(--ng);" data-bs-toggle="modal" data-bs-target="#rejectModal${c.id}">
                                                    <i class="fas fa-times"></i> Từ chối
                                                </button>

                                                <!-- Reject Modal -->
                                                <div class="modal fade" id="rejectModal${c.id}" tabindex="-1" aria-hidden="true">
                                                    <div class="modal-dialog modal-dialog-centered">
                                                        <div class="modal-content">
                                                            <div class="modal-header bg-danger text-white">
                                                                <h5 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Từ Chối Bảng Công</h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                            </div>
                                                            <form action="${pageContext.request.contextPath}/hr/timesheet-approval" method="post">
                                                                <input type="hidden" name="action" value="hrManagerReject">
                                                                <input type="hidden" name="id" value="${c.id}">
                                                                <input type="hidden" name="month" value="${selectedMonth}">
                                                                <input type="hidden" name="year" value="${selectedYear}">
                                                                <div class="modal-body text-start">
                                                                    <p>Nhập lý do từ chối bảng công của phòng ban <strong>${c.departmentName}</strong>:</p>
                                                                    <textarea name="reason" class="form-control" rows="3" required placeholder="Nhập lý do..."></textarea>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                                                    <button type="submit" class="btn btn-danger">Xác nhận Từ Chối</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

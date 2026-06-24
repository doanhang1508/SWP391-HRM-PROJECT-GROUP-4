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

            <c:if test="${not empty confirmations && !allDeptsConfirmed}">
                <div class="alert alert-c a-err mb-4" style="background:#fffbeb; color:#b45309; border-left: 4px solid var(--warn);">
                    <i class="fas fa-exclamation-triangle me-2"></i> <strong>Lưu ý:</strong> Một số phòng ban chưa hoàn thành xác nhận bảng công (còn ở trạng thái DRAFT hoặc SENT_TO_DEPARTMENT). HR Manager chỉ có thể duyệt cuối khi tất cả phòng ban có dữ liệu chấm công đã hoàn thành xác nhận.
                </div>
            </c:if>

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
                    <c:set var="totalCount" value="0" />
                    <c:set var="approvedCount" value="0" />
                    <c:forEach var="c" items="${confirmations}">
                        <c:set var="totalCount" value="${totalCount + 1}" />
                        <c:if test="${c.status == 'HR_MANAGER_APPROVED'}">
                            <c:set var="approvedCount" value="${approvedCount + 1}" />
                        </c:if>
                    </c:forEach>

                    <!-- Summary Table (1 Row for the month) -->
                    <div id="summaryTableContainer" class="table-responsive mb-4">
                        <table class="tbl" style="border: 1px solid #e2e8f0;">
                            <thead>
                                <tr>
                                    <th>Kỳ Công</th>
                                    <th>Tổng Số Phòng Ban</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><strong>Bảng công Tháng ${selectedMonth} / ${selectedYear}</strong></td>
                                    <td>${totalCount} phòng ban</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${isLocked}">
                                                <span class="badge-s b-approved" style="background:#fee2e2;color:#991b1b;">
                                                    <i class="fas fa-lock"></i> Đã khóa công
                                                </span>
                                            </c:when>
                                            <c:when test="${approvedCount == totalCount}">
                                                <span class="badge-s b-approved" style="background:#ecfdf5;color:#047857;">
                                                    <i class="fas fa-check-double"></i> Đã duyệt cuối tất cả (${approvedCount}/${totalCount})
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-s b-pending">
                                                    <i class="fas fa-clock"></i> Đang thực hiện (${approvedCount}/${totalCount} đã duyệt)
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <!-- Toggle details button -->
                                        <button type="button" id="btnToggleDeptDetails" class="btn-a" style="background:#0d9488;color:#fff;height:36px;font-size:.85rem;padding:6px 16px;margin-right: 8px;" onclick="toggleDeptDetails()">
                                            <i class="fas fa-eye"></i> Xem chi tiết
                                        </button>
                                        <!-- Global lock/unlock action -->
                                        <c:choose>
                                            <c:when test="${isLocked}">
                                                <c:choose>
                                                    <c:when test="${hasPayrollDraft}">
                                                        <%-- Đã gen payroll draft → không cho mở khóa --%>
                                                        <span class="badge-s" style="background:#fef3c7;color:#92400e;padding:6px 14px;font-size:.82rem;border-radius:8px;display:inline-flex;align-items:center;gap:6px;">
                                                            <i class="fas fa-file-invoice-dollar"></i> Đã tạo bảng lương nháp
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="${pageContext.request.contextPath}/hr/timesheet-approval" method="post" style="display:inline-block; margin-right: 8px;">
                                                            <input type="hidden" name="action" value="unlockMonth">
                                                            <input type="hidden" name="month" value="${selectedMonth}">
                                                            <input type="hidden" name="year" value="${selectedYear}">
                                                            <button type="submit" class="btn-a" style="background:#059669;color:#fff;height:36px;font-size:.85rem;padding:6px 16px;" onclick="return confirm('Bạn chắc chắn muốn MỞ KHÓA bảng công tháng này?')">
                                                                <i class="fas fa-lock-open"></i> Mở khóa công
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <c:choose>
                                                    <c:when test="${approvedCount == totalCount}">
                                                        <form action="${pageContext.request.contextPath}/hr/timesheet-approval" method="post" style="display:inline-block; margin-right: 8px;">
                                                            <input type="hidden" name="action" value="lockMonth">
                                                            <input type="hidden" name="month" value="${selectedMonth}">
                                                            <input type="hidden" name="year" value="${selectedYear}">
                                                            <button type="submit" class="btn-a" style="background:#b91c1c;color:#fff;height:36px;font-size:.85rem;padding:6px 16px;" onclick="return confirm('Bạn chắc chắn muốn KHÓA bảng công tháng này? Mọi người sẽ không thể chỉnh sửa nữa.')">
                                                                <i class="fas fa-lock"></i> Khóa công
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="button" class="btn-a" style="background:#b91c1c;color:#fff;height:36px;font-size:.85rem;padding:6px 16px;opacity:0.5;cursor:not-allowed;margin-right: 8px;" disabled title="Chưa thể khóa do còn phòng ban chưa được duyệt cuối.">
                                                            <i class="fas fa-lock"></i> Khóa công
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Collapsible Department details list -->
                    <div class="table-responsive" id="deptTableContainer" style="display: none; border-top: 1px dashed #cbd5e1; padding-top: 20px; margin-top: 15px;">
                        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                            <h5 class="fw-bold mb-0 text-muted" style="font-size: 0.95rem;"><i class="fas fa-list me-1"></i> Chi tiết trạng thái các phòng ban</h5>
                            <div style="width: 250px;">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted" style="border-color:#e2e8f0; border-top-left-radius:8px; border-bottom-left-radius:8px;"><i class="fas fa-search"></i></span>
                                    <input type="text" id="searchDept" onkeyup="filterDepts()" class="form-control border-start-0" placeholder="Tìm phòng ban..." style="border-color:#e2e8f0; border-top-right-radius:8px; border-bottom-right-radius:8px; font-size:0.875rem; padding: 8px 12px; outline:none; box-shadow:none;">
                                </div>
                            </div>
                        </div>
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Phòng Ban</th>
                                    <th>Kỳ Công</th>
                                    <th>Trạng Thái</th>
                                    <th>Xác Nhận Bởi</th>
                                </tr>
                            </thead>
                            <tbody id="deptTableBody">
                                <c:forEach var="c" items="${confirmations}">
                                    <tr data-name="${c.departmentName}">
                                        <td><strong>${c.departmentName}</strong></td>
                                        <td>Tháng ${c.month}/${c.year}</td>
                                        <td>
                                            <div class="d-flex align-items-center flex-wrap gap-3">
                                                <c:choose>
                                                    <c:when test="${c.status == 'DEPARTMENT_CONFIRMED'}"><span class="badge-s b-pending"><i class="fas fa-check"></i> Trưởng phòng xác nhận</span></c:when>
                                                    <c:when test="${c.status == 'SENT_TO_HR_MANAGER'}"><span class="badge-s b-info"><i class="fas fa-user-tie"></i> Chờ duyệt cuối</span></c:when>
                                                    <c:when test="${c.status == 'HR_MANAGER_APPROVED'}"><span class="badge-s b-approved" style="background:#ecfdf5;color:#047857;"><i class="fas fa-check-double"></i> Đã duyệt cuối</span></c:when>
                                                    <c:when test="${c.status == 'HR_MANAGER_REJECTED'}"><span class="badge-s b-rejected"><i class="fas fa-times"></i> Đã từ chối duyệt</span></c:when>
                                                </c:choose>

                                                <c:if test="${c.status == 'SENT_TO_HR_MANAGER' || c.status == 'DEPARTMENT_CONFIRMED'}">
                                                    <div class="d-flex gap-2">
                                                        <c:choose>
                                                            <c:when test="${allDeptsConfirmed}">
                                                                <form action="${pageContext.request.contextPath}/hr/timesheet-approval" method="post" style="display:inline-block; margin:0;">
                                                                    <input type="hidden" name="action" value="hrManagerApprove">
                                                                    <input type="hidden" name="id" value="${c.id}">
                                                                    <input type="hidden" name="month" value="${selectedMonth}">
                                                                    <input type="hidden" name="year" value="${selectedYear}">
                                                                    <button type="submit" class="btn-a btn-submit" style="height:26px; font-size:.78rem; padding: 2px 10px;" onclick="return confirm('Bạn chắc chắn muốn DUYỆT CUỐI bảng công phòng ban này?')">
                                                                        <i class="fas fa-check"></i> Duyệt
                                                                    </button>
                                                                </form>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button type="button" class="btn-a btn-submit" style="height:26px; font-size:.78rem; padding: 2px 10px; opacity: 0.5; cursor: not-allowed;" disabled title="Còn phòng ban chưa hoàn thành xác nhận bảng công.">
                                                                    <i class="fas fa-ban"></i> Duyệt
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:if>
                                            </div>

                                            <c:if test="${not empty c.rejectReason}">
                                                <div class="text-danger small mt-1" style="max-width:350px">
                                                    <strong>Lý do phản hồi:</strong> ${c.rejectReason}
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <div style="font-size:0.85rem; font-weight:600;">${c.updatedByName != null ? c.updatedByName : '-'}</div>
                                            <div style="font-size:0.75rem" class="text-muted">
                                                <c:if test="${c.updatedAt != null}">
                                                    <fmt:formatDate value="${c.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        <!-- Front-end Pagination Controls -->
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;flex-wrap:wrap;gap:8px;">
                            <div class="text-muted small fw-semibold" id="paginationInfo">
                                Hiển thị 0 - 0 trong số 0 phòng ban.
                            </div>
                            <div id="paginationControls" style="display:flex;gap:8px;">
                                <!-- Dynamically rendered buttons -->
                            </div>
                        </div>
                    </div>

                    <script>
                        const rowsPerPage = 10;
                        let currentPage = 1;

                        function initPagination() {
                            currentPage = 1;
                            updatePagination();
                        }

                        function updatePagination() {
                            const searchInput = document.getElementById('searchDept');
                            const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
                            const rows = Array.from(document.querySelectorAll('#deptTableBody tr'));
                            
                            if (rows.length === 0) {
                                const paginationInfo = document.getElementById('paginationInfo');
                                if (paginationInfo) paginationInfo.innerText = "Không có dữ liệu phòng ban.";
                                const paginationControls = document.getElementById('paginationControls');
                                if (paginationControls) paginationControls.innerHTML = "";
                                return;
                            }

                            // Filter rows based on query
                            const filteredRows = rows.filter(row => {
                                const deptName = (row.getAttribute('data-name') || '').toLowerCase();
                                return deptName.includes(query);
                            });

                            const totalRecords = filteredRows.length;
                            const totalPages = Math.ceil(totalRecords / rowsPerPage);

                            if (currentPage > totalPages) {
                                currentPage = totalPages;
                            }
                            if (currentPage < 1) {
                                currentPage = 1;
                            }

                            const startIdx = totalRecords === 0 ? 0 : (currentPage - 1) * rowsPerPage;
                            const endIdx = Math.min(currentPage * rowsPerPage, totalRecords);

                            // Toggle visibility of rows
                            rows.forEach(row => {
                                row.style.display = 'none';
                            });

                            if (totalRecords === 0) {
                                const paginationInfo = document.getElementById('paginationInfo');
                                if (paginationInfo) paginationInfo.innerText = "Không tìm thấy kết quả.";
                                const paginationControls = document.getElementById('paginationControls');
                                if (paginationControls) paginationControls.innerHTML = "";
                                return;
                            }

                            filteredRows.slice(startIdx, endIdx).forEach(row => {
                                row.style.display = '';
                            });

                            // Update pagination information label
                            const paginationInfo = document.getElementById('paginationInfo');
                            if (paginationInfo) {
                                paginationInfo.innerText = "Hiển thị " + (startIdx + 1) + " - " + endIdx + " trong số " + totalRecords + " phòng ban.";
                            }

                            // Render pagination controls
                            const paginationControls = document.getElementById('paginationControls');
                            if (!paginationControls) return;
                            
                            let html = '';

                            // Previous button
                            if (currentPage === 1) {
                                html += '<button disabled style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:#cbd5e1;cursor:not-allowed;opacity:0.6;"><i class="fas fa-chevron-left"></i></button>';
                            } else {
                                html += '<button type="button" onclick="changePage(' + (currentPage - 1) + ')" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;transition:all 0.2s;" onmouseover="this.style.borderColor=\'var(--pri)\';this.style.color=\'var(--pri)\';" onmouseout="this.style.borderColor=\'#e2e8f0\';this.style.color=\'var(--muted)\';"><i class="fas fa-chevron-left"></i></button>';
                            }

                            // Next button
                            if (currentPage === totalPages || totalRecords === 0) {
                                html += '<button disabled style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:#cbd5e1;cursor:not-allowed;opacity:0.6;"><i class="fas fa-chevron-right"></i></button>';
                            } else {
                                html += '<button type="button" onclick="changePage(' + (currentPage + 1) + ')" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;transition:all 0.2s;" onmouseover="this.style.borderColor=\'var(--pri)\';this.style.color=\'var(--pri)\';" onmouseout="this.style.borderColor=\'#e2e8f0\';this.style.color=\'var(--muted)\';"><i class="fas fa-chevron-right"></i></button>';
                            }

                            paginationControls.innerHTML = html;
                        }

                        function changePage(page) {
                            currentPage = page;
                            updatePagination();
                        }

                        function filterDepts() {
                            currentPage = 1;
                            updatePagination();
                        }

                        function toggleDeptDetails() {
                            const container = document.getElementById('deptTableContainer');
                            const btn = document.getElementById('btnToggleDeptDetails');
                            if (container.style.display === 'none') {
                                container.style.display = 'block';
                                btn.innerHTML = '<i class="fas fa-eye-slash"></i> Ẩn chi tiết';
                            } else {
                                container.style.display = 'none';
                                btn.innerHTML = '<i class="fas fa-eye"></i> Xem chi tiết';
                            }
                        }

                        document.addEventListener("DOMContentLoaded", function() {
                            initPagination();
                        });
                    </script>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

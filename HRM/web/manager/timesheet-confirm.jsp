<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <c:set var="pageTitle" value="Xác Nhận Bảng Chấm Công - Enterprise HRM" scope="request" />
            <jsp:include page="../header.jsp" />

            <!-- Google Fonts & Icons -->
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                rel="stylesheet">
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

            <style>
                :root {
                    --pri: #6366f1;
                    --pri-l: rgba(99, 102, 241, .1);
                    --ok: #10b981;
                    --ok-l: rgba(16, 185, 129, .1);
                    --ng: #ef4444;
                    --ng-l: rgba(239, 68, 68, .1);
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
                    box-shadow: 0 4px 20px rgba(0, 0, 0, .03);
                    border: 1px solid rgba(0, 0, 0, .04);
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

                .b-purple {
                    background: rgba(168, 85, 247, 0.1);
                    color: #9333ea;
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
                    box-shadow: 0 4px 10px rgba(0, 0, 0, .12);
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

                /* Hide horizontal scrollbar for table-responsive container */
                .table-responsive::-webkit-scrollbar {
                    display: none;
                }
                .table-responsive {
                    -ms-overflow-style: none;
                    scrollbar-width: none;
                }
            </style>
            <div class="dashboard-wrapper">
                <jsp:include page="../shared/sidebar.jsp">
                    <jsp:param name="activeMenu" value="timesheet-confirm" />
                </jsp:include>

                <div class="main-content">
                    <!-- Page Header -->
                    <div class="page-header">
                        <div>
                            <h1 class="page-title">Xác Nhận Bảng Chấm Công</h1>
                            <p class="breadcrumb-c">
                                <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Xác nhận
                                bảng công
                            </p>
                        </div>
                        <div>
                            <a href="${pageContext.request.contextPath}/hr/attendance-management?action=summary&month=${selectedMonth}&year=${selectedYear}"
                                class="btn-a btn-view text-white">
                                <i class="fas fa-table"></i> Bảng tổng hợp công
                            </a>
                        </div>
                    </div>

                    <!-- Message Alerts -->
                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="alert alert-c a-ok alert-dismissible fade show mb-4" role="alert">
                            <i class="fas fa-check-circle me-2"></i> ${sessionScope.successMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                        <c:remove var="successMessage" scope="session" />
                    </c:if>
                    <c:if test="${not empty sessionScope.errorMessage}">
                        <div class="alert alert-c a-err alert-dismissible fade show mb-4" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i> ${sessionScope.errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                        <c:remove var="errorMessage" scope="session" />
                    </c:if>

                    <div class="admin-panel">
                        <div class="panel-header">
                            <h3 class="panel-title">
                                <div class="panel-icon"><i class="fas fa-check-double"></i></div>
                                Quy trình xác nhận bảng công phòng ban
                            </h3>
                        </div>

                        <!-- Filter Month/Year -->
                        <div class="row g-3 align-items-center mb-4">
                            <div class="col-md-2">
                                <label class="form-label small fw-bold text-muted">Tháng</label>
                                <select id="filterMonth" onchange="reloadTimesheetPeriod()" class="form-select"
                                    style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                    <c:forEach var="m" begin="1" end="12">
                                        <option value="${m}" ${selectedMonth==m ? 'selected' : '' }>Tháng ${m}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small fw-bold text-muted">Năm</label>
                                <select id="filterYear" onchange="reloadTimesheetPeriod()" class="form-select"
                                    style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                    <c:forEach var="y" begin="2024" end="2030">
                                        <option value="${y}" ${selectedYear==y ? 'selected' : '' }>${y}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>

                        <script>
                            function reloadTimesheetPeriod() {
                                var month = document.getElementById('filterMonth').value;
                                var year = document.getElementById('filterYear').value;
                                window.location.href = '${pageContext.request.contextPath}/manager/timesheet-confirm?month=' + month + '&year=' + year;
                            }
                        </script>

                        <!-- ================= VIEW FOR HR STAFF / MANAGER / ADMIN ================= -->
                        <c:if test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 5}">



                            <c:if test="${not empty confirmations}">
                                <!-- Summary Table (1 Row for the month) -->
                                <div id="summaryTableContainer" class="table-responsive mb-3">
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
                                                <td><strong>Bảng công Tháng ${selectedMonth} / ${selectedYear}</strong>
                                                </td>
                                                <td>${confirmations.size()} phòng ban</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${isLocked}">
                                                            <span class="badge-s b-approved" style="background:#fee2e2;color:#991b1b;">
                                                                <i class="fas fa-lock"></i> Đã khóa công
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${approvedCount == confirmations.size()}">
                                                            <span class="badge-s b-approved"
                                                                style="background:#ecfdf5;color:#047857;">
                                                                <i class="fas fa-check-double"></i> Đã duyệt tất cả
                                                                (${approvedCount}/${confirmations.size()})
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-s b-pending">
                                                                <i class="fas fa-clock"></i> Đang thực hiện
                                                                (${approvedCount}/${confirmations.size()} đã duyệt)
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end">
                                                    <!-- Toggle details button -->
                                                    <button type="button" id="btnToggleDeptDetails" class="btn-a" style="background:#0d9488;color:#fff;height:36px;font-size:.85rem;padding:6px 16px;margin-right: 8px;" onclick="toggleDeptDetails()">
                                                        <i class="fas fa-eye"></i> Xem chi tiết
                                                    </button>
                                                    <c:if test="${!isLocked}">
                                                        <c:if
                                                            test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 5}">
                                                            <c:set var="hasDrafts" value="false" />
                                                            <c:forEach var="c" items="${confirmations}">
                                                                <c:if
                                                                    test="${c.status == 'DRAFT' || c.status == 'DEPARTMENT_REJECTED' || c.status == 'HR_MANAGER_REJECTED'}">
                                                                    <c:set var="hasDrafts" value="true" />
                                                                </c:if>
                                                            </c:forEach>
                                                            <c:if test="${hasDrafts}">
                                                                <form
                                                                    action="${pageContext.request.contextPath}/manager/timesheet-confirm"
                                                                    method="post"
                                                                    style="display:inline-block; margin-right: 8px;">
                                                                    <input type="hidden" name="action"
                                                                        value="sendAllToDepartments">
                                                                    <input type="hidden" name="month"
                                                                        value="${selectedMonth}">
                                                                    <input type="hidden" name="year"
                                                                        value="${selectedYear}">
                                                                    <button type="submit" class="btn-a btn-submit"
                                                                        style="height:36px; font-size:.85rem; padding: 6px 16px; background-color: var(--pri);">
                                                                        <i class="fas fa-paper-plane"></i> Gửi tất cả phòng
                                                                        ban
                                                                    </button>
                                                                </form>
                                                            </c:if>
                                                        </c:if>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </c:if>

                            <!-- Empty State Placeholder -->
                            <c:if test="${empty confirmations && empty activeDepts}">
                                <div id="emptyPlaceholder" class="text-center py-5 border rounded bg-white"
                                    style="color:var(--muted); margin-bottom: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.01);">
                                    <i class="fas fa-info-circle fa-2x mb-2 text-muted" style="opacity:.6"></i>
                                    <p class="mb-0">Kỳ công này chưa có dữ liệu chấm công được import.</p>
                                </div>
                            </c:if>

                            <!-- Collapsible Department list -->
                            <c:if test="${not empty confirmations}">
                                <div class="table-responsive" id="deptTableContainer"
                                    style="display: none; border-top: 1px dashed #cbd5e1; padding-top: 20px; margin-top: 15px;">
                                    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                                        <h5 class="fw-bold mb-0 text-muted" style="font-size: 0.95rem;"><i
                                                class="fas fa-list me-1"></i> Chi tiết trạng thái các phòng ban</h5>
                                        <div style="width: 250px;">
                                            <div class="input-group">
                                                <span class="input-group-text bg-white border-end-0 text-muted"
                                                    style="border-color:#e2e8f0; border-top-left-radius:8px; border-bottom-left-radius:8px;"><i
                                                        class="fas fa-search"></i></span>
                                                <input type="text" id="searchDept" onkeyup="filterDepts()"
                                                    class="form-control border-start-0" placeholder="Tìm phòng ban..."
                                                    style="border-color:#e2e8f0; border-top-right-radius:8px; border-bottom-right-radius:8px; font-size:0.875rem; padding: 8px 12px; outline:none; box-shadow:none;">
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
                                        <tbody id="tbodyDepts">
                                            <c:forEach var="c" items="${confirmations}">
                                                <tr data-dept-name="${c.departmentName}">
                                                    <td><strong>${c.departmentName}</strong></td>
                                                    <td>Tháng ${c.month}/${c.year}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${c.status == 'DRAFT'}"><span
                                                                    class="badge-s b-draft"><i
                                                                        class="fas fa-file-signature"></i> Draft</span>
                                                            </c:when>
                                                            <c:when test="${c.status == 'SENT_TO_DEPARTMENT'}"><span
                                                                    class="badge-s b-pending"><i
                                                                        class="fas fa-paper-plane"></i> Chờ TP xác
                                                                    nhận</span></c:when>
                                                            <c:when test="${c.status == 'DEPARTMENT_CONFIRMED'}"><span
                                                                    class="badge-s b-approved"><i
                                                                        class="fas fa-check"></i> TP đã xác nhận</span>
                                                            </c:when>
                                                            <c:when test="${c.status == 'DEPARTMENT_REJECTED'}"><span
                                                                    class="badge-s b-rejected"><i
                                                                        class="fas fa-times"></i> TP từ chối</span>
                                                            </c:when>
                                                            <c:when test="${c.status == 'SENT_TO_HR_MANAGER'}"><span
                                                                    class="badge-s b-info"><i
                                                                        class="fas fa-user-tie"></i> Chờ Trưởng phòng NS
                                                                    duyệt</span></c:when>
                                                            <c:when test="${c.status == 'HR_MANAGER_APPROVED'}"><span
                                                                    class="badge-s b-approved"
                                                                    style="background:#ecfdf5;color:#047857;"><i
                                                                        class="fas fa-check-double"></i> Đã duyệt
                                                                    cuối</span></c:when>
                                                            <c:when test="${c.status == 'HR_MANAGER_REJECTED'}"><span
                                                                    class="badge-s b-rejected"><i
                                                                        class="fas fa-undo"></i> Trưởng phòng NS từ
                                                                    chối</span></c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div style="font-size:0.85rem; font-weight:600;">${c.updatedByName != null ?
                                                            c.updatedByName : '-'}</div>
                                                        <div style="font-size:0.75rem" class="text-muted">
                                                            <c:if test="${c.updatedAt != null}">
                                                                <fmt:formatDate value="${c.updatedAt}"
                                                                    pattern="dd/MM/yyyy HH:mm" />
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                    <!-- Front-end Pagination Controls for Departments -->
                                    <div
                                        style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;flex-wrap:wrap;gap:8px;">
                                        <div class="text-muted small fw-semibold" id="deptPaginationInfo">
                                            Hiển thị 0 - 0 trong số 0 phòng ban.
                                        </div>
                                        <div id="deptPaginationControls" style="display:flex;gap:8px;">
                                            <!-- Dynamically rendered buttons -->
                                        </div>
                                    </div>
                                </div>
                            </c:if>

                            <script>
                                const deptRowsPerPage = 10;
                                let currentDeptPage = 1;

                                function initDeptPagination() {
                                    currentDeptPage = 1;
                                    updateDeptPagination();
                                }

                                function updateDeptPagination() {
                                    const searchInput = document.getElementById('searchDept');
                                    const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
                                    const rows = Array.from(document.querySelectorAll('#tbodyDepts tr'));

                                    if (rows.length === 0) {
                                        const infoEl = document.getElementById('deptPaginationInfo');
                                        if (infoEl) infoEl.innerText = "Không có dữ liệu phòng ban.";
                                        const controlsEl = document.getElementById('deptPaginationControls');
                                        if (controlsEl) controlsEl.innerHTML = "";
                                        return;
                                    }

                                    // Filter rows based on query
                                    const filteredRows = rows.filter(row => {
                                        const deptName = (row.getAttribute('data-dept-name') || '').toLowerCase();
                                        return deptName.includes(query);
                                    });

                                    const totalRecords = filteredRows.length;
                                    const totalPages = Math.ceil(totalRecords / deptRowsPerPage);

                                    if (currentDeptPage > totalPages) {
                                        currentDeptPage = totalPages;
                                    }
                                    if (currentDeptPage < 1) {
                                        currentDeptPage = 1;
                                    }

                                    const startIdx = totalRecords === 0 ? 0 : (currentDeptPage - 1) * deptRowsPerPage;
                                    const endIdx = Math.min(currentDeptPage * deptRowsPerPage, totalRecords);

                                    // Toggle visibility of rows
                                    rows.forEach(row => {
                                        row.style.display = 'none';
                                    });

                                    if (totalRecords === 0) {
                                        const infoEl = document.getElementById('deptPaginationInfo');
                                        if (infoEl) infoEl.innerText = "Không tìm thấy kết quả.";
                                        const controlsEl = document.getElementById('deptPaginationControls');
                                        if (controlsEl) controlsEl.innerHTML = "";
                                        return;
                                    }

                                    filteredRows.slice(startIdx, endIdx).forEach(row => {
                                        row.style.display = '';
                                    });

                                    // Update pagination information label
                                    const infoEl = document.getElementById('deptPaginationInfo');
                                    if (infoEl) {
                                        infoEl.innerText = "Hiển thị " + (startIdx + 1) + " - " + endIdx + " trong số " + totalRecords + " phòng ban.";
                                    }

                                    // Render pagination controls
                                    const controlsEl = document.getElementById('deptPaginationControls');
                                    if (!controlsEl) return;

                                    let html = '';

                                    // Previous button
                                    if (currentDeptPage === 1) {
                                        html += '<button disabled style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:#cbd5e1;cursor:not-allowed;opacity:0.6;"><i class="fas fa-chevron-left"></i></button>';
                                    } else {
                                        html += '<button type="button" onclick="changeDeptPage(' + (currentDeptPage - 1) + ')" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;transition:all 0.2s;" onmouseover="this.style.borderColor=\'var(--pri)\';this.style.color=\'var(--pri)\';" onmouseout="this.style.borderColor=\'#e2e8f0\';this.style.color=\'var(--muted)\';"><i class="fas fa-chevron-left"></i></button>';
                                    }

                                    // Next button
                                    if (currentDeptPage === totalPages || totalRecords === 0) {
                                        html += '<button disabled style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:#cbd5e1;cursor:not-allowed;opacity:0.6;"><i class="fas fa-chevron-right"></i></button>';
                                    } else {
                                        html += '<button type="button" onclick="changeDeptPage(' + (currentDeptPage + 1) + ')" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;transition:all 0.2s;" onmouseover="this.style.borderColor=\'var(--pri)\';this.style.color=\'var(--pri)\';" onmouseout="this.style.borderColor=\'#e2e8f0\';this.style.color=\'var(--muted)\';"><i class="fas fa-chevron-right"></i></button>';
                                    }

                                    controlsEl.innerHTML = html;
                                }

                                function changeDeptPage(page) {
                                    currentDeptPage = page;
                                    updateDeptPagination();
                                }

                                function filterDepts() {
                                    currentDeptPage = 1;
                                    updateDeptPagination();
                                }

                                function toggleDeptDetails() {
                                    const container = document.getElementById('deptTableContainer');
                                    const btn = document.getElementById('btnToggleDeptDetails');
                                    if (container.style.display === 'none') {
                                        container.style.display = 'block';
                                        btn.innerHTML = '<i class="fas fa-eye-slash"></i> Ẩn chi tiết';
                                    } else {
                                        container.style.display = 'none';
                                        btn.innerHTML = '<i class="fas fa-eye"></i> Xem';
                                    }
                                }

                                document.addEventListener("DOMContentLoaded", function () {
                                    initDeptPagination();
                                });
                            </script>
                        </c:if>


                        <!-- ================= VIEW FOR DEPARTMENT MANAGER ================= -->
                        <c:if
                            test="${sessionScope.currentUser.roleId == 6 || sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 2}">
                            <div class="mb-4">
                                <h4 class="h6 fw-bold text-muted mb-2">Trạng thái Bảng Công Phòng Ban:</h4>
                                <c:choose>
                                    <c:when test="${empty confirmation || confirmation.status == 'DRAFT'}">
                                        <div class="alert alert-c a-err py-3" style="border-left: 4px solid var(--ng);">
                                            <i class="fas fa-exclamation-circle"></i> Bảng công chưa được gửi để xác
                                            nhận.
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="p-3 bg-white rounded border d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4"
                                            style="box-shadow:0 4px 12px rgba(0,0,0,0.01);">
                                            <div>
                                                <span class="fw-semibold text-muted me-2" style="font-size:0.9rem">Trạng
                                                    thái hiện tại:</span>
                                                <c:choose>
                                                    <c:when test="${confirmation.status == 'SENT_TO_DEPARTMENT'}"><span
                                                            class="badge-s b-pending"><i class="fas fa-paper-plane"></i>
                                                            Chờ Bạn Xác Nhận</span></c:when>
                                                    <c:when test="${confirmation.status == 'DEPARTMENT_CONFIRMED'}">
                                                        <span class="badge-s b-approved"
                                                            style="background:#ecfdf5;color:#047857;"><i
                                                                class="fas fa-check"></i> Đã xác nhận (Chờ duyệt
                                                            cuối)</span></c:when>
                                                    <c:when test="${confirmation.status == 'SENT_TO_HR_MANAGER'}"><span
                                                            class="badge-s b-info"><i class="fas fa-user-tie"></i> Đang
                                                            Chờ Trưởng Phòng NS Duyệt</span></c:when>
                                                    <c:when test="${confirmation.status == 'HR_MANAGER_APPROVED'}"><span
                                                            class="badge-s b-approved"
                                                            style="background:#ecfdf5;color:#047857;"><i
                                                                class="fas fa-check-double"></i> Đã Được Duyệt
                                                            Cuối</span></c:when>
                                                    <c:when test="${confirmation.status == 'HR_MANAGER_REJECTED'}"><span
                                                            class="badge-s b-rejected"><i class="fas fa-undo"></i> Bị
                                                            Trưởng Phòng NS Từ Chối</span></c:when>
                                                </c:choose>
                                                <c:if test="${not empty confirmation.rejectReason}">
                                                    <div class="text-danger small mt-2"><strong>Lý do phản hồi:</strong>
                                                        ${confirmation.rejectReason}</div>
                                                </c:if>
                                            </div>

                                            <div>
                                                <c:choose>
                                                    <c:when test="${confirmation.status == 'SENT_TO_DEPARTMENT'}">
                                                        <c:choose>
                                                            <c:when test="${allEmployeesConfirmed}">
                                                                <form
                                                                    action="${pageContext.request.contextPath}/manager/timesheet-confirm"
                                                                    method="post" style="display:inline-block">
                                                                    <input type="hidden" name="action"
                                                                        value="departmentConfirm">
                                                                    <input type="hidden" name="id"
                                                                        value="${confirmation.id}">
                                                                    <input type="hidden" name="month"
                                                                        value="${selectedMonth}">
                                                                    <input type="hidden" name="year"
                                                                        value="${selectedYear}">
                                                                    <button type="submit" class="btn-a btn-submit"
                                                                        style="height:38px;"
                                                                        onclick="return confirm('Bạn xác nhận dữ liệu chấm công của phòng ban là chính xác?')">
                                                                        <i class="fas fa-check"></i> Xác Nhận Bảng Công
                                                                        Phòng Ban
                                                                    </button>
                                                                </form>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="d-flex align-items-center gap-3">
                                                                    <button type="button" class="btn-a btn-submit"
                                                                        style="height:38px; opacity:0.5; cursor:not-allowed;"
                                                                        disabled
                                                                        title="Còn nhân viên chưa xác nhận phiếu công.">
                                                                        <i class="fas fa-ban"></i> Xác Nhận Bảng Công
                                                                        Phòng Ban
                                                                    </button>
                                                                    <span class="text-danger small fw-bold"><i
                                                                            class="fas fa-exclamation-triangle"></i> Còn
                                                                        nhân viên chưa xác nhận phiếu công.</span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:when>
                                                    <c:when
                                                        test="${confirmation.status == 'DEPARTMENT_CONFIRMED' || confirmation.status == 'SENT_TO_HR_MANAGER'}">
                                                        <span class="badge-s b-approved text-success"
                                                            style="background:#ecfdf5; padding:8px 16px; font-weight:700;"><i
                                                                class="fas fa-check-circle"></i> Phòng ban đã xác
                                                            nhận</span>
                                                    </c:when>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <div class="panel-header mt-4">
                                            <h3 class="panel-title">
                                                <div class="panel-icon"><i class="fas fa-users"></i></div> Danh sách
                                                nhân viên phòng ban
                                            </h3>
                                            <div class="ms-auto" style="max-width: 300px;">
                                                <div class="input-group">
                                                    <span class="input-group-text bg-white border-end-0 text-muted"
                                                        style="border-color:#e2e8f0; border-top-left-radius:8px; border-bottom-left-radius:8px;"><i
                                                            class="fas fa-search"></i></span>
                                                    <input type="text" id="searchEmployee" onkeyup="filterEmployees()"
                                                        class="form-control border-start-0"
                                                        placeholder="Tìm theo ID hoặc họ tên..."
                                                        style="border-color:#e2e8f0; border-top-right-radius:8px; border-bottom-right-radius:8px; font-size:0.875rem; padding: 8px 12px; outline:none; box-shadow:none;">
                                                </div>
                                            </div>
                                        </div>

                                        <div class="table-responsive">
                                            <table class="tbl">
                                                <thead>
                                                    <tr>
                                                        <th>Mã NV</th>
                                                        <th>Họ tên nhân viên</th>
                                                        <th>Tổng ngày làm việc</th>
                                                        <th>Đi trễ (Lần)</th>
                                                        <th>Vắng (Lần)</th>
                                                        <th>Xác nhận cá nhân</th>
                                                        <th class="text-end">Hành động</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="empTableBody">
                                                    <c:choose>
                                                        <c:when test="${empty empSummaryList}">
                                                            <tr>
                                                                <td colspan="7" class="text-center py-4"
                                                                    style="color:var(--muted)">Không tìm thấy nhân viên
                                                                    nào.</td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach var="emp" items="${empSummaryList}">
                                                                <tr data-id="${emp.userId}" data-name="${emp.fullName}"
                                                                    data-dept="${emp.departmentName}" data-pos="${emp.positionName}"
                                                                    data-leave="${emp.totalLeaveDays}" data-ot="${emp.totalOTHours}">
                                                                    <td><strong>#${emp.userId}</strong></td>
                                                                    <td><strong>${emp.fullName}</strong></td>
                                                                    <td>${emp.totalWorkDays}</td>
                                                                    <td><span class="badge bg-warning text-dark rounded-pill">${emp.lateCount}</span></td>
                                                                    <td><span class="badge bg-danger rounded-pill">${emp.absentCount}</span></td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${emp.confirmed}">
                                                                                <span class="badge-s b-approved"><i
                                                                                        class="fas fa-check-circle"></i>
                                                                                    Đã xác nhận</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge-s b-pending"><i
                                                                                        class="fas fa-clock"></i> Chưa
                                                                                    xác nhận</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td class="text-end">
                                                                        <button type="button" class="btn-a btn-view"
                                                                            onclick="showDetails(${emp.userId}, '${emp.fullName}')">
                                                                            <i class="fas fa-eye"></i> Chi tiết
                                                                        </button>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                        </div>

                                        <!-- Front-end Pagination Controls -->
                                        <div
                                            style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;flex-wrap:wrap;gap:8px;">
                                            <div class="text-muted small fw-semibold" id="paginationInfo">
                                                Hiển thị 0 - 0 trong số 0 nhân viên.
                                            </div>
                                            <div id="paginationControls" style="display:flex;gap:8px;">
                                                <!-- Dynamically rendered buttons -->
                                            </div>
                                        </div>

                                        <!-- Detail Modal -->
                                        <div class="modal fade" id="detailModal" tabindex="-1" aria-hidden="true">
                                            <div class="modal-dialog modal-xl modal-dialog-centered">
                                                <div class="modal-content"
                                                    style="border-radius: 16px; border:none; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">
                                                    <div class="modal-header bg-dark text-white"
                                                        style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                                                        <h5 class="modal-title fw-bold"><i
                                                                class="fas fa-calendar-alt me-2"></i> Chi Tiết Chấm
                                                            Công: <span id="modalEmpName"></span></h5>
                                                        <button type="button" class="btn-close btn-close-white"
                                                            data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body" style="max-height: 70vh; overflow-y: auto;">
                                                        <!-- Summary stats row -->
                                                        <div id="modalSummaryStats" class="row g-2 mb-3">
                                                            <div class="col-6 col-md-3">
                                                                <div class="p-2 rounded text-center" style="background:#f0fdf4;border:1px solid #bbf7d0;">
                                                                    <div class="fw-bold text-success" style="font-size:1.2rem;" id="msDept">-</div>
                                                                    <div class="text-muted" style="font-size:.75rem;">Phòng ban</div>
                                                                </div>
                                                            </div>
                                                            <div class="col-6 col-md-3">
                                                                <div class="p-2 rounded text-center" style="background:#eff6ff;border:1px solid #bfdbfe;">
                                                                    <div class="fw-bold text-primary" style="font-size:1.2rem;" id="msPos">-</div>
                                                                    <div class="text-muted" style="font-size:.75rem;">Chức vụ</div>
                                                                </div>
                                                            </div>
                                                            <div class="col-6 col-md-3">
                                                                <div class="p-2 rounded text-center" style="background:var(--ng-l);border:1px solid rgba(239, 68, 68, 0.2);">
                                                                    <div class="fw-bold" style="font-size:1.2rem;color:var(--ng);" id="msLeave">-</div>
                                                                    <div class="text-muted" style="font-size:.75rem;">Tổng ngày nghỉ</div>
                                                                </div>
                                                            </div>
                                                            <div class="col-6 col-md-3">
                                                                <div class="p-2 rounded text-center" style="background:#fdf4ff;border:1px solid #e9d5ff;">
                                                                    <div class="fw-bold text-purple" style="font-size:1.2rem;color:#7c3aed;" id="msOT">-</div>
                                                                    <div class="text-muted" style="font-size:.75rem;">Tổng giờ OT</div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <!-- Attendance detail table -->
                                                        <div class="table-responsive">
                                                            <table class="tbl table table-hover">
                                                                <thead>
                                                                    <tr>
                                                                        <th>Ngày làm việc</th>
                                                                        <th>Ca làm</th>
                                                                        <th>Giờ vào</th>
                                                                        <th>Giờ ra</th>
                                                                        <th>Trạng thái</th>
                                                                        <th>Tăng ca (Giờ)</th>
                                                                        <th>Ghi chú</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="modalDetailBody">
                                                                    <!-- Loaded dynamically by JS -->
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer" style="border-top: 1px solid #f1f5f9;">
                                                        <button type="button" class="btn btn-secondary"
                                                            style="border-radius: 8px;"
                                                            data-bs-dismiss="modal">Đóng</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <script>
                                            const attendanceData = [
                                                <c:forEach var="a" items="${attendanceList}" varStatus="loop">
                                                    {
                                                        userId: ${a.userId},
                                                    workDate: '<fmt:formatDate value="${a.workDate}" pattern="dd/MM/yyyy" />',
                                                    shiftName: '${a.shiftName != null ? a.shiftName : "-"}',
                                                    checkIn: '${a.checkIn != null ? a.checkIn : "-"}',
                                                    checkOut: '${a.checkOut != null ? a.checkOut : "-"}',
                                                    status: '${a.status}',
                                                    overtimeHrs: ${a.overtimeHrs},
                                                    otReason: '${a.otReason != null ? a.otReason : ""}'
                                        }${!loop.last ? ',' : ''}
                                                </c:forEach>
                                            ];

                                            function showDetails(userId, fullName) {
                                                const row = document.querySelector('#empTableBody tr[data-id="' + userId + '"]');
                                                const dept  = row ? (row.dataset.dept || '-') : '-';
                                                const pos   = row ? (row.dataset.pos  || '-') : '-';
                                                const leave = row ? (row.dataset.leave || '0') : '0';
                                                const ot    = row ? (row.dataset.ot   || '0') : '0';

                                                document.getElementById('modalEmpName').innerText = fullName + ' (ID: #' + userId + ')';
                                                document.getElementById('msDept').innerText  = dept;
                                                document.getElementById('msPos').innerText   = pos;
                                                document.getElementById('msLeave').innerText = leave + ' ngày';
                                                document.getElementById('msOT').innerText    = ot + ' giờ';

                                                const tbody = document.getElementById('modalDetailBody');
                                                tbody.innerHTML = '';

                                                const userRecords = attendanceData.filter(r => r.userId === userId);
                                                if (userRecords.length === 0) {
                                                    tbody.innerHTML = '<tr><td colspan="7" class="text-center py-3 text-muted">Không có dữ liệu chi tiết.</td></tr>';
                                                } else {
                                                    userRecords.forEach(r => {
                                                        let statusBadge = '';
                                                        if (r.status === 'PRESENT') statusBadge = '<span class="badge-s b-approved">Present</span>';
                                                        else if (r.status === 'ABSENT') statusBadge = '<span class="badge-s b-rejected">Absent</span>';
                                                        else if (r.status === 'LATE') statusBadge = '<span class="badge-s b-pending">Late</span>';
                                                        else if (r.status === 'HALFDAY') statusBadge = '<span class="badge-s b-info">Halfday</span>';
                                                        else statusBadge = '<span class="badge-s b-draft">' + r.status + '</span>';

                                                        tbody.innerHTML += '<tr>' +
                                                            '<td><strong>' + r.workDate + '</strong></td>' +
                                                            '<td>' + r.shiftName + '</td>' +
                                                            '<td>' + r.checkIn + '</td>' +
                                                            '<td>' + r.checkOut + '</td>' +
                                                            '<td>' + statusBadge + '</td>' +
                                                            '<td>' + (r.overtimeHrs > 0 ? r.overtimeHrs + ' hrs' : '-') + '</td>' +
                                                            '<td class="text-muted small">' + (r.otReason ? r.otReason : '-') + '</td>' +
                                                            '</tr>';
                                                    });
                                                }
                                                var myModal = new bootstrap.Modal(document.getElementById('detailModal'));
                                                myModal.show();
                                            }

                                            const rowsPerPage = 10;
                                            let currentPage = 1;

                                            function initPagination() {
                                                currentPage = 1;
                                                updatePagination();
                                            }

                                            function updatePagination() {
                                                const query = document.getElementById('searchEmployee').value.toLowerCase().trim();
                                                const rows = Array.from(document.querySelectorAll('#empTableBody tr'));

                                                // Filter rows that are not placeholders
                                                const validRows = rows.filter(row => row.getAttribute('data-id') !== null);

                                                if (validRows.length === 0) {
                                                    const paginationInfo = document.getElementById('paginationInfo');
                                                    if (paginationInfo) paginationInfo.innerText = "Không tìm thấy kết quả.";
                                                    const paginationControls = document.getElementById('paginationControls');
                                                    if (paginationControls) paginationControls.innerHTML = "";
                                                    return;
                                                }

                                                // Filter rows based on query
                                                const filteredRows = validRows.filter(row => {
                                                    const empId = row.getAttribute('data-id').toLowerCase();
                                                    const empName = row.getAttribute('data-name').toLowerCase();
                                                    return empId.includes(query) || empName.includes(query);
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
                                                validRows.forEach(row => {
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
                                                    paginationInfo.innerText = "Hiển thị " + (startIdx + 1) + " - " + endIdx + " trong số " + totalRecords + " nhân viên.";
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
                                                if (currentPage === totalPages || totalPages === 0) {
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

                                            function filterEmployees() {
                                                currentPage = 1;
                                                updatePagination();
                                            }

                                            document.addEventListener("DOMContentLoaded", function () {
                                                initPagination();
                                            });
                                        </script>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="pageTitle" value="Duyệt Hợp đồng" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f8f9fa; font-family: 'Be Vietnam Pro', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 24px; width: calc(100% - 260px); }

    .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
    .header-title { font-size: 1.25rem; font-weight: 700; color: #1a1a1a; margin: 0 0 4px 0; }
    .header-breadcrumb { font-size: 0.85rem; color: #6b7280; }
    .header-actions { display: flex; gap: 12px; align-items: center; }

    .search-input {
        padding: 8px 16px 8px 36px;
        border: 1px solid #e5e7eb; border-radius: 6px;
        font-size: 0.875rem; width: 240px;
        background: #fff url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="%239ca3af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>') no-repeat 10px center;
        outline: none;
    }
    .search-input:focus { border-color: #3b82f6; }

    /* Stat Cards */
    .stat-cards-container { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
    .stat-card { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 16px; }
    .stat-card-header { display: flex; align-items: center; gap: 8px; font-size: 0.85rem; color: #6b7280; margin-bottom: 12px; font-weight: 500; }
    .stat-card-value { font-size: 1.5rem; font-weight: 700; color: #1a1a1a; margin-bottom: 8px; }
    .stat-card-sub { font-size: 0.75rem; padding: 4px 8px; border-radius: 12px; display: inline-block; font-weight: 500; }
    .sc-blue .stat-card-header i { color: #3b82f6; } .sc-blue .stat-card-sub { background: #eff6ff; color: #2563eb; }
    .sc-yellow .stat-card-header i { color: #f59e0b; } .sc-yellow .stat-card-sub { background: #fffbeb; color: #d97706; }
    .sc-green .stat-card-header i { color: #10b981; } .sc-green .stat-card-sub { background: #ecfdf5; color: #059669; }
    .sc-red .stat-card-header i { color: #ef4444; } .sc-red .stat-card-sub { background: #fef2f2; color: #dc2626; }

    /* Card panel */
    .card-panel { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; }
    .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; padding-bottom: 16px; border-bottom: 1px solid #f3f4f6; }
    .panel-title { font-size: 1rem; font-weight: 600; color: #1a1a1a; display: flex; align-items: center; gap: 8px; }
    .panel-title i { color: #3b82f6; }

    .filter-tabs { display: flex; gap: 8px; }
    .filter-tab { padding: 6px 12px; border: 1px solid #e5e7eb; border-radius: 6px; font-size: 0.85rem;
        color: #4b5563; text-decoration: none; background: #fff; font-weight: 500; cursor: pointer; }
    .filter-tab.active { background: #f9fafb; font-weight: 600; color: #1a1a1a; border-color: #d1d5db; }
    .filter-tab span { color: #9ca3af; margin-left: 4px; font-size: 0.8rem; }

    /* Table */
    .saas-table { width: 100%; border-collapse: collapse; min-width: 900px; }
    .saas-table th { padding: 14px 16px; text-align: left; font-size: 0.82rem; font-weight: 600;
        color: #6b7280; border-bottom: 2px solid #f3f4f6; white-space: nowrap; }
    .saas-table td { padding: 14px 16px; font-size: 0.875rem; color: #1a1a1a;
        border-bottom: 1px solid #f3f4f6; vertical-align: middle; }
    .saas-table tr:hover td { background: #f9fafb; }

    .emp-cell { display: flex; align-items: center; gap: 10px; }
    .emp-avatar { width: 36px; height: 36px; border-radius: 50%; background: #e0e7ff; color: #4338ca;
        display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.85rem; flex-shrink: 0; }
    .emp-name { font-weight: 600; color: #1a1a1a; margin-bottom: 2px; }
    .emp-code { font-size: 0.75rem; color: #6b7280; }

    .badge-status { padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 600; white-space: nowrap; }
    .b-pending  { background: #eff6ff; color: #2563eb; }
    .b-active   { background: #ecfdf5; color: #059669; }
    .b-rejected { background: #fef2f2; color: #dc2626; }

    .action-btns { display: flex; gap: 6px; justify-content: flex-end; }
    .action-btn { width: 32px; height: 32px; border-radius: 50%; border: 1px solid #e5e7eb;
        background: #fff; color: #6b7280; display: flex; align-items: center; justify-content: center;
        cursor: pointer; text-decoration: none; font-size: 0.8rem; }
    .action-btn:hover { background: #f3f4f6; color: #1a1a1a; }
    .btn-approve { background: #ecfdf5 !important; color: #059669 !important; border-color: #059669 !important; }
    .btn-reject-icon { background: #fef2f2 !important; color: #dc2626 !important; border-color: #dc2626 !important; }

    /* Reject Modal */
    .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.5);
        z-index: 9999; align-items: center; justify-content: center; backdrop-filter: blur(3px); }
    .modal-box { background: #fff; width: 480px; border-radius: 14px; box-shadow: 0 20px 40px rgba(0,0,0,0.15); overflow: hidden; }
    .modal-head { padding: 20px 24px; border-bottom: 1px solid #f3f4f6; display: flex; justify-content: space-between; align-items: center; }
    .modal-head h4 { margin: 0; font-size: 1rem; font-weight: 700; color: #1a1a1a; }
    .modal-body { padding: 24px; }
    .modal-foot { padding: 14px 24px; border-top: 1px solid #f3f4f6; display: flex; justify-content: flex-end; gap: 10px; background: #f9fafb; }
    textarea.form-ctrl { width: 100%; padding: 10px 12px; border: 1px solid #e5e7eb; border-radius: 8px;
        font-size: 0.875rem; font-family: inherit; resize: vertical; min-height: 100px; outline: none; box-sizing: border-box; }
    textarea.form-ctrl:focus { border-color: #3b82f6; }
    .btn-cancel-m { background: #fff; border: 1px solid #e5e7eb; color: #6b7280; padding: 8px 18px; border-radius: 6px; font-weight: 600; font-size: 0.875rem; cursor: pointer; }
    .btn-confirm-r { background: #dc2626; border: none; color: #fff; padding: 8px 18px; border-radius: 6px; font-weight: 600; font-size: 0.875rem; cursor: pointer; }

    /* Pagination */
    .pagination-bar { display: flex; justify-content: space-between; align-items: center; padding-top: 16px; margin-top: 16px; border-top: 1px solid #e5e7eb; }
    .page-info { font-size: 0.85rem; color: #6b7280; }
    .page-controls { display: flex; gap: 4px; }
    .page-btn { min-width: 32px; height: 32px; border-radius: 4px; border: 1px solid #e5e7eb;
        background: #fff; color: #374151; display: flex; align-items: center; justify-content: center;
        font-size: 0.85rem; cursor: pointer; text-decoration: none; }
    .page-btn.active { border-color: #3b82f6; background: #eff6ff; color: #2563eb; font-weight: 600; }
    .page-btn:hover:not(.active) { background: #f9fafb; }

    .empty-state { text-align: center; padding: 48px; color: #9ca3af; }
    .empty-state i { font-size: 2rem; margin-bottom: 10px; display: block; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="contract-approval" />
    </jsp:include>

    <div class="main-content">
        <%-- Alert messages --%>
        <c:if test="${not empty sessionScope.successMsg}">
            <div style="background:#ecfdf5;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:20px;display:flex;align-items:center;gap:10px;">
                <i class="fas fa-check-circle"></i>${sessionScope.successMsg}
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div style="background:#fef2f2;color:#991b1b;padding:12px 16px;border-radius:8px;margin-bottom:20px;display:flex;align-items:center;gap:10px;">
                <i class="fas fa-exclamation-circle"></i>${sessionScope.errorMsg}
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <form action="${pageContext.request.contextPath}/hr/contract-approval" method="GET" id="filterForm">
            <input type="hidden" name="status" value="${currentFilter}" id="statusInput">

            <div class="page-header">
                <div>
                    <h1 class="header-title"><i class="fas fa-clipboard-check" style="color:#f59e0b;margin-right:8px;"></i>Duyệt Hợp đồng Lao động</h1>
                    <div class="header-breadcrumb">HRM / Duyệt hợp đồng</div>
                </div>
                <div class="header-actions">
                    <input type="text" name="search" class="search-input"
                           placeholder="Tìm tên, mã NV..."
                           value="${not empty currentSearch ? currentSearch : ''}"
                           onchange="document.getElementById('filterForm').submit()">
                </div>
            </div>

            <%-- Stat Cards --%>
            <div class="stat-cards-container">
                <div class="stat-card sc-blue">
                    <div class="stat-card-header"><i class="fas fa-file-contract"></i> Tổng hợp đồng</div>
                    <div class="stat-card-value">${counts.all}</div>
                    <span class="stat-card-sub">Tất cả trạng thái</span>
                </div>
                <div class="stat-card sc-yellow">
                    <div class="stat-card-header"><i class="fas fa-hourglass-half"></i> Chờ duyệt</div>
                    <div class="stat-card-value">${counts.pending}</div>
                    <span class="stat-card-sub">Cần xử lý</span>
                </div>
                <div class="stat-card sc-green">
                    <div class="stat-card-header"><i class="fas fa-check-circle"></i> Đã phê duyệt</div>
                    <div class="stat-card-value">${counts.approved}</div>
                    <span class="stat-card-sub">Hiệu lực</span>
                </div>
                <div class="stat-card sc-red">
                    <div class="stat-card-header"><i class="fas fa-times-circle"></i> Đã từ chối</div>
                    <div class="stat-card-value">${counts.rejected}</div>
                    <span class="stat-card-sub">Bị từ chối</span>
                </div>
            </div>

            <%-- Table Panel --%>
            <div class="card-panel">
                <div class="panel-header">
                    <div class="panel-title"><i class="fas fa-list"></i> Danh sách hợp đồng</div>
                    <div class="filter-tabs">
                        <a class="filter-tab ${currentFilter == 'all' ? 'active' : ''}" onclick="setFilter('all')">
                            Tất cả <span>${counts.all}</span>
                        </a>
                        <a class="filter-tab ${currentFilter == 'pending' ? 'active' : ''}" onclick="setFilter('pending')">
                            Chờ duyệt <span>${counts.pending}</span>
                        </a>
                        <a class="filter-tab ${currentFilter == 'approved' ? 'active' : ''}" onclick="setFilter('approved')">
                            Đã duyệt <span>${counts.approved}</span>
                        </a>
                        <a class="filter-tab ${currentFilter == 'rejected' ? 'active' : ''}" onclick="setFilter('rejected')">
                            Từ chối <span>${counts.rejected}</span>
                        </a>
                    </div>
                </div>

                <div style="overflow-x:auto;">
                    <table class="saas-table">
                        <thead>
                            <tr>
                                <th>Nhân viên</th>
                                <th>Loại hợp đồng</th>
                                <th>Phòng ban</th>
                                <th>Lương Gross</th>
                                <th>Ngày bắt đầu</th>
                                <th>Ngày kết thúc</th>
                                <th>Trạng thái</th>
                                <th style="text-align:right;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty contracts}">
                                    <tr>
                                        <td colspan="8">
                                            <div class="empty-state">
                                                <i class="fas fa-inbox"></i>
                                                <p style="font-weight:600;margin:0;">Không có hợp đồng nào phù hợp</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="c" items="${contracts}">
                                        <tr>
                                            <td>
                                                <div class="emp-cell">
                                                    <div class="emp-avatar">
                                                        <c:if test="${not empty c.fullName}">${fn:substring(c.fullName,fn:length(c.fullName)-1,fn:length(c.fullName))}</c:if>
                                                    </div>
                                                    <div>
                                                        <div class="emp-name">${c.fullName}</div>
                                                        <div class="emp-code">NV${c.userId}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${c.docType == 'ADDENDUM'}">
                                                        <span style="color: #d97706; font-weight: 600;"><i class="fas fa-file-signature me-1"></i> Phụ lục HĐ</span>
                                                        <div style="font-size: 0.8rem; font-weight: 400; color: #64748b; margin-top: 2px;">${c.addendumReason != null ? c.addendumReason : ''}</div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${c.contractTypeName}
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${not empty c.departmentName ? c.departmentName : '—'}</td>
                                            <td style="font-weight:700;color:#059669;">
                                                <fmt:formatNumber value="${c.baseSalary}" type="number" groupingUsed="true"/> đ
                                            </td>
                                            <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${c.endDate != null}"><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></c:when>
                                                    <c:otherwise><span style="color:#9ca3af;">Vô thời hạn</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${c.status == 'Pending'}">
                                                        <span class="badge-status b-pending"><i class="fas fa-hourglass-half me-1"></i>Chờ duyệt</span>
                                                    </c:when>
                                                    <c:when test="${c.status == 'Active'}">
                                                        <span class="badge-status b-active"><i class="fas fa-check-circle me-1"></i>Đã duyệt</span>
                                                    </c:when>
                                                    <c:when test="${c.status == 'Rejected'}">
                                                        <span class="badge-status b-rejected" title="${c.rejectReason}"><i class="fas fa-times-circle me-1"></i>Từ chối</span>
                                                    </c:when>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="action-btns">
                                                    <%-- Xem hồ sơ --%>
                                                    <a href="${pageContext.request.contextPath}/hr/employee-contracts?userId=${c.userId}"
                                                       class="action-btn" title="Xem hồ sơ nhân viên">
                                                        <i class="far fa-file-alt"></i>
                                                    </a>
                                                    <%-- Duyệt (chỉ Pending) --%>
                                                    <c:if test="${c.status == 'Pending'}">
                                                        <form action="${pageContext.request.contextPath}/hr/contract-approval" method="POST" style="display:inline;">
                                                            <input type="hidden" name="action" value="approve">
                                                            <input type="hidden" name="contractId" value="${c.contractId}">
                                                            <input type="hidden" name="userId" value="${c.userId}">
                                                            <button type="submit" class="action-btn btn-approve" title="Phê duyệt">
                                                                <i class="fas fa-check"></i>
                                                            </button>
                                                        </form>
                                                        <button type="button" class="action-btn btn-reject-icon"
                                                                onclick="openRejectModal(${c.contractId}, ${c.userId}, '${fn:escapeXml(c.fullName)}')"
                                                                title="Từ chối">
                                                            <i class="fas fa-times"></i>
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="pagination-bar" id="paginationBar" style="display:none;">
                    <div class="page-info">Hiển thị <span id="pageStart">0</span> - <span id="pageEnd">0</span> trong tổng số <span id="totalItems">0</span> hợp đồng</div>
                    <div class="page-controls">
                        <button type="button" class="page-btn" id="btnPrevPage" onclick="prevPage()"><i class="fas fa-chevron-left"></i></button>
                        <div id="pageNumbers" style="display:flex;gap:4px;"></div>
                        <button type="button" class="page-btn" id="btnNextPage" onclick="nextPage()"><i class="fas fa-chevron-right"></i></button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- Modal Từ chối --%>
<div id="rejectModal" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-head">
            <h4><i class="fas fa-times-circle" style="color:#dc2626;margin-right:8px;"></i>Từ chối Hợp đồng</h4>
            <button type="button" onclick="closeRejectModal()" style="background:none;border:none;font-size:1.3rem;color:#9ca3af;cursor:pointer;">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/hr/contract-approval" method="POST">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="contractId" id="rejectContractId">
            <input type="hidden" name="userId" id="rejectUserId">
            <div class="modal-body">
                <p style="margin:0 0 14px;color:#475569;font-size:0.9rem;">
                    Từ chối hợp đồng của nhân viên <strong id="rejectEmpName"></strong>.
                    Nhân viên sẽ nhận thông báo kèm lý do bên dưới.
                </p>
                <label style="font-size:0.85rem;font-weight:600;color:#374151;display:block;margin-bottom:8px;">Lý do từ chối <span style="color:red;">*</span></label>
                <textarea name="rejectReason" class="form-ctrl" required
                          placeholder="VD: Mức lương không phù hợp, cần HR Staff điều chỉnh lại..."></textarea>
            </div>
            <div class="modal-foot">
                <button type="button" class="btn-cancel-m" onclick="closeRejectModal()">Hủy bỏ</button>
                <button type="submit" class="btn-confirm-r"><i class="fas fa-times-circle me-1"></i>Xác nhận Từ chối</button>
            </div>
        </form>
    </div>
</div>

<script>
    function setFilter(status) {
        document.getElementById('statusInput').value = status;
        document.getElementById('filterForm').submit();
    }

    function openRejectModal(contractId, userId, empName) {
        document.getElementById('rejectContractId').value = contractId;
        document.getElementById('rejectUserId').value = userId;
        document.getElementById('rejectEmpName').textContent = empName;
        document.getElementById('rejectModal').style.display = 'flex';
    }
    function closeRejectModal() {
        document.getElementById('rejectModal').style.display = 'none';
    }
    document.getElementById('rejectModal').addEventListener('click', function(e) {
        if (e.target === this) closeRejectModal();
    });

    // Pagination
    let currentPage = 1;
    const itemsPerPage = 8;
    let filteredRows = [];

    function initPagination() {
        const rows = document.querySelectorAll('.saas-table tbody tr');
        filteredRows = Array.from(rows).filter(row => !row.querySelector('td[colspan]'));
        if (filteredRows.length > 0) {
            document.getElementById('paginationBar').style.display = 'flex';
            updatePagination();
        }
    }

    function updatePagination() {
        if (filteredRows.length === 0) return;
        const totalPages = Math.ceil(filteredRows.length / itemsPerPage);
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = Math.min(startIndex + itemsPerPage, filteredRows.length);
        filteredRows.forEach(row => row.style.display = 'none');
        for (let i = startIndex; i < endIndex; i++) filteredRows[i].style.display = '';
        document.getElementById('pageStart').textContent = startIndex + 1;
        document.getElementById('pageEnd').textContent = endIndex;
        document.getElementById('totalItems').textContent = filteredRows.length;
        let pageHtml = '';
        for (let i = 1; i <= totalPages; i++) {
            if (i === currentPage) pageHtml += '<button type="button" class="page-btn active">' + i + '</button>';
            else pageHtml += '<button type="button" class="page-btn" onclick="goToPage(' + i + ')">' + i + '</button>';
        }
        document.getElementById('pageNumbers').innerHTML = pageHtml;
        const prevBtn = document.getElementById('btnPrevPage');
        const nextBtn = document.getElementById('btnNextPage');
        prevBtn.disabled = currentPage === 1;
        prevBtn.style.opacity = currentPage === 1 ? '0.4' : '1';
        prevBtn.style.pointerEvents = currentPage === 1 ? 'none' : 'auto';
        nextBtn.disabled = currentPage === totalPages;
        nextBtn.style.opacity = currentPage === totalPages ? '0.4' : '1';
        nextBtn.style.pointerEvents = currentPage === totalPages ? 'none' : 'auto';
    }

    function goToPage(page) { currentPage = page; updatePagination(); }
    function prevPage() { if (currentPage > 1) { currentPage--; updatePagination(); } }
    function nextPage() { const t = Math.ceil(filteredRows.length / itemsPerPage); if (currentPage < t) { currentPage++; updatePagination(); } }

    document.addEventListener('DOMContentLoaded', initPagination);
</script>

<jsp:include page="../footer.jsp" />

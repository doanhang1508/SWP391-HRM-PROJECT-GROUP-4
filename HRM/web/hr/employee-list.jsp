<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Hồ sơ Nhân sự" scope="request" />
<jsp:include page="../header.jsp" />

<!-- Google Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    body { background-color: #f8fafc; font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 40px; width: calc(100% - 260px); }
    
    .admin-panel {
        background: #fff; border-radius: 20px; padding: 30px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03); border: 1px solid #e2e8f0;
    }
    .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .panel-title { font-size: 1.25rem; font-weight: 700; color: #0f172a; margin: 0; display: flex; align-items: center; gap: 12px; }
    .panel-title-icon { width: 32px; height: 32px; background: #eff6ff; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #3b82f6; font-size: 0.9rem; }
    
    .table-custom { width: 100%; border-collapse: collapse; }
    .table-custom th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 0.8rem; text-transform: uppercase; padding: 16px 20px; border-bottom: 1px solid #e2e8f0; }
    .table-custom td { padding: 16px 20px; vertical-align: middle; color: #0f172a; font-size: 0.95rem; border-bottom: 1px solid #e2e8f0; }
    
    .user-info { display: flex; align-items: center; gap: 16px; }
    .avatar-sm { width: 44px; height: 44px; border-radius: 12px; background: #eff6ff; color: #3b82f6; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.1rem; }
    .badge-soft { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
    .badge-soft.bg-success { background: #d1fae5 !important; color: #059669; }
    .badge-soft.bg-danger { background: #fee2e2 !important; color: #dc2626; }
    .badge-soft.bg-warning { background: #fef3c7 !important; color: #d97706; }
    
    .btn-action-outline { border: 1px solid #e2e8f0; background: #fff; color: #475569; padding: 6px 12px; border-radius: 8px; font-size: 0.8rem; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s; }
    .btn-action-outline:hover { background: #f8fafc; color: #0f172a; border-color: #cbd5e1; }
    
    .btn-primary-soft { background: #eff6ff; color: #2563eb; padding: 6px 12px; border-radius: 8px; font-size: 0.8rem; font-weight: 600; text-decoration: none; border: none; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s; cursor: pointer; }
    .btn-primary-soft:hover { background: #dbeafe; color: #1d4ed8; }

    /* PAGINATION */
    .btn-page { background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; color: #64748b; cursor: pointer; transition: all 0.2s; font-family: 'Inter', sans-serif; }
    .btn-page:hover:not(:disabled) { border-color: #3b82f6; color: #3b82f6; }
    .btn-page.active { background: #3b82f6; border-color: #3b82f6; color: white; }
    .btn-page:disabled { opacity: 0.5; cursor: not-allowed; }

    @media(max-width:768px){.main-content{width:100%!important;padding:20px 16px!important;}}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="employees" />
    </jsp:include>

    <div class="main-content">

        <%-- Banner lọc theo phòng ban / chức vụ --%>
        <c:if test="${not empty filterName}">
            <div style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:12px;padding:12px 20px;margin-bottom:20px;display:flex;align-items:center;justify-content:space-between;gap:12px;">
                <div style="display:flex;align-items:center;gap:10px;">
                    <i class="fas fa-filter" style="color:#2b6cb0;"></i>
                    <span style="font-weight:600;color:#1e40af;">Đang lọc: <strong>${filterName}</strong></span>
                    <span style="color:#64748b;font-size:.85rem;">— ${fn:length(users)} nhân viên</span>
                </div>
                <a href="${pageContext.request.contextPath}/hr/employees"
                   style="font-size:.82rem;color:#2b6cb0;text-decoration:none;border:1px solid #bfdbfe;border-radius:6px;padding:4px 12px;background:#fff;">
                    <i class="fas fa-times" style="font-size:.7rem;"></i> Xem tất cả
                </a>
            </div>
        </c:if>

        <div class="admin-panel" id="users">
            <div class="panel-header">
                <h2 class="panel-title">
                    <div class="panel-title-icon"><i class="fas fa-id-card"></i></div>
                    Danh sách Hồ sơ Nhân viên
                </h2>
            </div>

            <!-- Search + Filter -->
            <form action="${pageContext.request.contextPath}/hr/employees" method="get" class="row g-3 align-items-center mb-4">
                <!-- Search -->
                <div class="col-md-4">
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" name="keyword" class="form-control border-start-0" placeholder="Tìm tên nhân viên..." value="${keyword}">
                    </div>
                </div>

                <!-- Filter Department -->
                <div class="col-md-3">
                    <select name="departmentId" class="form-select">
                        <option value="">Tất cả phòng ban</option>
                        <c:forEach items="${departments}" var="d">
                            <option value="${d.departmentId}" ${selectedDept == d.departmentId.toString() ? 'selected' : ''}>${d.departmentName}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Filter Position -->
                <div class="col-md-3">
                    <select name="positionId" class="form-select">
                        <option value="">Tất cả chức vụ</option>
                        <c:forEach items="${positions}" var="p">
                            <option value="${p.positionId}" ${selectedPos == p.positionId.toString() ? 'selected' : ''}>${p.positionName}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Action Buttons -->
                <div class="col-md-2 d-flex gap-2">
                    <button type="submit" class="btn btn-primary flex-grow-1" style="background:#3b82f6;border:none;">
                        <i class="fas fa-filter"></i> Lọc
                    </button>
                    <a href="${pageContext.request.contextPath}/hr/employees" class="btn btn-light border" title="Reset">
                        <i class="fas fa-rotate-left"></i>
                    </a>
                </div>
            </form>

            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Liên hệ</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hồ sơ HR</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty users}">
                                <tr class="empty-state-row">
                                    <td colspan="4" class="text-center text-muted" style="padding: 40px;">
                                        <i class="fas fa-users" style="font-size: 3rem; opacity: 0.3; margin-bottom: 16px;"></i>
                                        <p style="font-weight: 600; color: #0f172a;">Không tìm thấy nhân viên nào</p>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${users}" var="u">
                                    <tr>
                                        <td>
                                            <div class="user-info">
                                                <div class="avatar-sm">${u.fullName.substring(0,1)}</div>
                                                <div>
                                                    <div class="fw-bold" style="color: #0f172a;">${u.fullName}</div>
                                                    <div style="font-size: 0.8rem; color: #64748b;">@${u.username}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div><i class="fas fa-envelope text-muted me-2" style="font-size: 0.85rem;"></i>${u.email}</div>
                                            <c:if test="${not empty u.phone}">
                                                <div class="mt-1"><i class="fas fa-phone text-muted me-2" style="font-size: 0.85rem;"></i>${u.phone}</div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <span class="badge-soft ${u.status == 1 ? 'bg-success' : 'bg-danger'}">
                                                <i class="fas ${u.status == 1 ? 'fa-check-circle' : 'fa-lock'} me-1"></i>
                                                ${u.status == 1 ? 'Hoạt động' : 'Bị khóa'}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-2 justify-content-end">
                                                <a href="${pageContext.request.contextPath}/hr/employee-detail?userId=${u.userId}" class="btn-action-outline" title="Xem hồ sơ">
                                                    <i class="fas fa-id-card"></i> Hồ sơ NS
                                                </a>
                                                <a href="${pageContext.request.contextPath}/hr/employee-contracts?userId=${u.userId}" class="btn-primary-soft" style="background:#fef3c7; color:#d97706;" title="Quản lý hợp đồng">
                                                    <i class="fas fa-file-signature"></i> Hợp đồng
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- PAGINATION -->
            <div class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 20px; border-top: 1px solid #e2e8f0;">
                <div class="pagination-info" style="font-size: 0.85rem; color: #64748b;">
                    Hiển thị <span id="pageStart" style="font-weight: 600; color: #0f172a;">0</span> - <span id="pageEnd" style="font-weight: 600; color: #0f172a;">0</span> trong tổng số <span id="totalItems" style="font-weight: 600; color: #0f172a;">0</span> nhân viên
                </div>
                <div class="pagination-controls" style="display: flex; gap: 8px;">
                    <button class="btn-page" id="btnPrevPage" onclick="prevPage()"><i class="fas fa-chevron-left"></i></button>
                    <div id="pageNumbers" style="display: flex; gap: 4px;"></div>
                    <button class="btn-page" id="btnNextPage" onclick="nextPage()"><i class="fas fa-chevron-right"></i></button>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Pagination Logic
    let currentPage = 1;
    const itemsPerPage = 8;
    let filteredRows = [];

    document.addEventListener('DOMContentLoaded', function() {
        initPagination();
    });

    function initPagination() {
        const rows = document.querySelectorAll('.table-custom tbody tr:not(.empty-state-row)');
        filteredRows = Array.from(rows);
        updatePagination();
    }

    function updatePagination() {
        if(filteredRows.length === 0) {
            document.getElementById('pageStart').textContent = 0;
            document.getElementById('pageEnd').textContent = 0;
            document.getElementById('totalItems').textContent = 0;
            document.getElementById('pageNumbers').innerHTML = '';
            document.getElementById('btnPrevPage').disabled = true;
            document.getElementById('btnNextPage').disabled = true;
            return;
        }

        const totalPages = Math.ceil(filteredRows.length / itemsPerPage);
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = Math.min(startIndex + itemsPerPage, filteredRows.length);

        // Hide all rows first
        document.querySelectorAll('.table-custom tbody tr:not(.empty-state-row)').forEach(row => row.style.display = 'none');
        
        // Show only rows for current page
        for (let i = startIndex; i < endIndex; i++) {
            filteredRows[i].style.display = '';
        }

        document.getElementById('pageStart').textContent = startIndex + 1;
        document.getElementById('pageEnd').textContent = endIndex;
        document.getElementById('totalItems').textContent = filteredRows.length;

        // Render page numbers
        let pageHtml = '';
        for (let i = 1; i <= totalPages; i++) {
            if (i === currentPage) {
                pageHtml += '<button class="btn-page active">' + i + '</button>';
            } else {
                pageHtml += '<button class="btn-page" onclick="goToPage(' + i + ')">' + i + '</button>';
            }
        }
        document.getElementById('pageNumbers').innerHTML = pageHtml;

        document.getElementById('btnPrevPage').disabled = currentPage === 1;
        document.getElementById('btnNextPage').disabled = currentPage === totalPages;
    }

    function goToPage(page) {
        currentPage = page;
        updatePagination();
    }
    
    function prevPage() {
        if (currentPage > 1) {
            currentPage--;
            updatePagination();
        }
    }
    
    function nextPage() {
        const totalPages = Math.ceil(filteredRows.length / itemsPerPage);
        if (currentPage < totalPages) {
            currentPage++;
            updatePagination();
        }
    }
</script>
<jsp:include page="../footer.jsp" />

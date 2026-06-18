<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Nhân viên của tôi" scope="request" />
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
    .panel-title-icon { width: 32px; height: 32px; background: #f0fdf4; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #16a34a; font-size: 0.9rem; }
    
    .table-custom { width: 100%; border-collapse: collapse; }
    .table-custom th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 0.8rem; text-transform: uppercase; padding: 16px 20px; border-bottom: 1px solid #e2e8f0; }
    .table-custom td { padding: 16px 20px; vertical-align: middle; color: #0f172a; font-size: 0.95rem; border-bottom: 1px solid #e2e8f0; }
    
    .user-info { display: flex; align-items: center; gap: 16px; }
    .avatar-sm { width: 44px; height: 44px; border-radius: 12px; background: #eff6ff; color: #3b82f6; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.1rem; }
    .badge-soft { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
    .badge-soft.bg-success { background: #d1fae5 !important; color: #059669; }
    .badge-soft.bg-danger { background: #fee2e2 !important; color: #dc2626; }
    
    .btn-action-outline { border: 1px solid #e2e8f0; background: #fff; color: #475569; padding: 6px 12px; border-radius: 8px; font-size: 0.8rem; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s; }
    .btn-action-outline:hover { background: #f8fafc; color: #0f172a; border-color: #cbd5e1; }
    
    .btn-primary-soft { background: #eff6ff; color: #2563eb; padding: 6px 12px; border-radius: 8px; font-size: 0.8rem; font-weight: 600; text-decoration: none; border: none; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s; cursor: pointer; }
    .btn-primary-soft:hover { background: #dbeafe; color: #1d4ed8; }

    @media(max-width:768px){.main-content{width:100%!important;padding:20px 16px!important;}}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="my-employees" />
    </jsp:include>

    <div class="main-content">

        <div style="background: linear-gradient(135deg, #eff6ff, #f8fafc); border: 1px solid #e2e8f0; border-radius: 16px; padding: 24px; margin-bottom: 24px;">
            <h1 style="font-size: 1.5rem; font-weight: 800; color: #1e293b; margin-bottom: 8px;">Nhân viên của tôi</h1>
            <p style="color: #64748b; margin: 0; font-size: 0.95rem;">
                <i class="fas fa-info-circle me-1"></i> Quản lý danh sách nhân sự thuộc <c:choose><c:when test="${managerRole == 3}">xưởng</c:when><c:otherwise>phòng ban</c:otherwise></c:choose> của bạn. Bạn có thể xem hồ sơ, đánh giá hiệu suất hoặc đề xuất khen thưởng/kỷ luật.
            </p>
        </div>

        <div class="admin-panel">
            <div class="panel-header">
                <h2 class="panel-title">
                    <div class="panel-title-icon"><i class="fas fa-users"></i></div>
                    Danh sách Nhân viên (${fn:length(employees)})
                </h2>
            </div>

            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Liên hệ</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Nghiệp vụ Quản lý</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty employees}">
                                <tr>
                                    <td colspan="4" class="text-center text-muted" style="padding: 40px;">
                                        <i class="fas fa-user-slash" style="font-size: 3rem; opacity: 0.3; margin-bottom: 16px;"></i>
                                        <p style="font-weight: 600; color: #0f172a;">Chưa có nhân viên nào trong phòng ban/xưởng của bạn</p>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${employees}" var="u">
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
                                                ${u.status == 1 ? 'Đang làm việc' : 'Đã nghỉ/Khoá'}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-2 justify-content-end">
                                                <a href="${pageContext.request.contextPath}/hr/employee-detail?userId=${u.userId}" class="btn-action-outline">
                                                    <i class="fas fa-id-badge"></i> Hồ sơ NS
                                                </a>
                                                <a href="${pageContext.request.contextPath}/manager/employee-kpi?userId=${u.userId}" class="btn-primary-soft">
                                                    <i class="fas fa-star-half-alt"></i> Đánh giá
                                                </a>
                                                <a href="${pageContext.request.contextPath}/manager/employee-discipline-request?userId=${u.userId}" class="btn-primary-soft" style="background:#fef2f2; color:#dc2626;">
                                                    <i class="fas fa-comment-dots"></i> Đề xuất
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

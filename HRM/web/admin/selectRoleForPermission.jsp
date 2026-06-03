<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Phân Quyền Hệ Thống - Hệ Thống HRM" scope="request" />
<jsp:include page="../header.jsp" />

<!-- Google Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --primary-color: #4361ee;
        --secondary-color: #3f37c9;
        --success-color: #4cc9f0;
        --danger-color: #f72585;
        --warning-color: #f8961e;
        --info-color: #4895ef;
        --dark-bg: #f4f7fe;
        --card-bg: #ffffff;
        --text-main: #2b2b2b;
        --text-muted: #8f9fbc;
    }

    body {
        background-color: var(--dark-bg);
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
        margin-bottom: 30px;
    }

    .page-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
    }

    .breadcrumb {
        font-size: 0.85rem;
        color: var(--text-muted);
        margin-bottom: 0;
    }
    .breadcrumb a {
        color: var(--primary-color);
        text-decoration: none;
    }

    .admin-panel {
        background: var(--card-bg);
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 5px 20px rgba(0,0,0,0.02);
        margin-bottom: 25px;
        border: 1px solid rgba(0,0,0,0.04);
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
        font-size: 1.15rem;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .table-custom {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 8px;
    }

    .table-custom th {
        background: transparent;
        color: var(--text-muted);
        font-weight: 600;
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 12px 15px;
        border: none;
    }

    .table-custom td {
        background: #fff;
        padding: 15px;
        vertical-align: middle;
        color: #4a5568;
        font-size: 0.9rem;
        border-top: 1px solid #f1f5f9;
        border-bottom: 1px solid #f1f5f9;
    }

    .table-custom tr td:first-child {
        border-left: 1px solid #f1f5f9;
        border-radius: 8px 0 0 8px;
    }

    .table-custom tr td:last-child {
        border-right: 1px solid #f1f5f9;
        border-radius: 0 8px 8px 0;
    }

    .table-custom tr:hover td {
        background: #f8fafc;
    }

    .badge-soft {
        padding: 6px 12px;
        border-radius: 6px;
        font-weight: 600;
        font-size: 0.75rem;
    }
    .badge-soft-success { background: rgba(76, 201, 240, 0.1); color: #00b4d8; }
    .badge-soft-danger { background: rgba(247, 37, 133, 0.1); color: #f72585; }

    .btn-action {
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 8px;
        transition: all 0.2s;
        border: none;
        color: #fff;
        padding: 0 16px;
        font-size: 0.85rem;
        font-weight: 500;
        text-decoration: none;
        gap: 8px;
        cursor: pointer;
    }
    .btn-manage { background: var(--info-color); }
    .btn-manage:hover { background: #3a0ca3; transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); color: #fff;}
</style>

<div class="dashboard-wrapper">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="permissions" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Phân Quyền Hệ Thống</h1>
                <p class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a> &nbsp;>&nbsp; Phân quyền hệ thống
                </p>
            </div>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #d1fae5; color: #065f46;">
                <i class="fas fa-check-circle me-2"></i> ${param.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #fee2e2; color: #991b1b;">
                <i class="fas fa-exclamation-circle me-2"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div class="admin-panel h-100">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(247, 37, 133, 0.1); color: var(--danger-color); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-key"></i>
                    </div>
                    Chọn Vai Trò Cần Phân Quyền
                </h3>
                <div style="position:relative;">
                    <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:.85rem;"></i>
                    <input type="text" id="searchInput" placeholder="Tìm vai trò..." oninput="filterTable()" style="padding:8px 14px 8px 36px;border:1px solid #e2e8f0;border-radius:8px;font-size:.85rem;width:240px;outline:none;font-family:'Inter',sans-serif;">
                </div>
            </div>

            <div class="table-responsive">
                <table class="table-custom" id="roleTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Vai Trò</th>
                            <th>Trạng Thái</th>
                            <th class="text-end">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty roleList}">
                                <tr class="empty-state-row">
                                    <td colspan="4" class="text-center py-4 text-muted">Không có dữ liệu Roles.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="r" items="${roleList}">
                                    <tr>
                                        <td class="fw-bold text-dark">#${r.roleId}</td>
                                        <td>
                                            <span class="fw-bold" style="color: var(--primary-color);">${r.roleName}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.status == 1}">
                                                    <span class="badge-soft badge-soft-success"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Active</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-soft badge-soft-danger"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Deactive</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <a href="editRolePermission?roleId=${r.roleId}" class="btn-action btn-manage" title="Quản lý Quyền">
                                                <i class="fas fa-sliders-h"></i> Manage Permissions
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- PAGINATION -->
            <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;">
                <div style="font-size:.85rem;color:var(--text-muted);">Hiển thị <span id="pageStart" style="font-weight:600;color:var(--text-main);">0</span> - <span id="pageEnd" style="font-weight:600;color:var(--text-main);">0</span> trong tổng số <span id="totalItems" style="font-weight:600;color:var(--text-main);">0</span> vai trò</div>
                <div style="display:flex;gap:8px;">
                    <button id="btnPrevPage" onclick="prevPage()" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--text-muted);cursor:pointer;"><i class="fas fa-chevron-left"></i></button>
                    <div id="pageNumbers" style="display:flex;gap:4px;"></div>
                    <button id="btnNextPage" onclick="nextPage()" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--text-muted);cursor:pointer;"><i class="fas fa-chevron-right"></i></button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
let currentPage = 1;
const itemsPerPage = 8;
let filteredRows = [];

function filterTable() {
    const query = document.getElementById('searchInput').value.toLowerCase();
    const allRows = Array.from(document.querySelectorAll('#roleTable tbody tr:not(.empty-state-row)'));
    filteredRows = allRows.filter(function(row) {
        return row.textContent.toLowerCase().includes(query);
    });
    currentPage = 1;
    updatePagination();
}

function updatePagination() {
    if(filteredRows.length === 0) {
        document.querySelectorAll('#roleTable tbody tr:not(.empty-state-row)').forEach(row => row.style.display = 'none');
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
    document.querySelectorAll('#roleTable tbody tr:not(.empty-state-row)').forEach(row => row.style.display = 'none');
    for (let i = startIndex; i < endIndex; i++) { filteredRows[i].style.display = ''; }
    document.getElementById('pageStart').textContent = startIndex + 1;
    document.getElementById('pageEnd').textContent = endIndex;
    document.getElementById('totalItems').textContent = filteredRows.length;
    let pageHtml = '';
    for (let i = 1; i <= totalPages; i++) {
        pageHtml += '<button style="background:' + (i===currentPage ? 'var(--primary-color)' : '#fff') + ';border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:' + (i===currentPage ? 'white' : 'var(--text-muted)') + ';cursor:pointer;" onclick="goToPage(' + i + ')">' + i + '</button>';
    }
    document.getElementById('pageNumbers').innerHTML = pageHtml;
    document.getElementById('btnPrevPage').disabled = currentPage === 1;
    document.getElementById('btnNextPage').disabled = currentPage === totalPages;
}

function goToPage(page) { currentPage = page; updatePagination(); }
function prevPage() { if (currentPage > 1) { currentPage--; updatePagination(); } }
function nextPage() { const tp = Math.ceil(filteredRows.length / itemsPerPage); if (currentPage < tp) { currentPage++; updatePagination(); } }

document.addEventListener('DOMContentLoaded', function() {
    filteredRows = Array.from(document.querySelectorAll('#roleTable tbody tr:not(.empty-state-row)'));
    updatePagination();
});
</script>

<jsp:include page="../footer.jsp" />

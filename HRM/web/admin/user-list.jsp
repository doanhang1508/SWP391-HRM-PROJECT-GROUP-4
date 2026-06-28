<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Quản lý Người dùng" scope="request" />
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
    .panel-title-icon { width: 32px; height: 32px; background: #f8fafc; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #64748b; font-size: 0.9rem; }
    
    .table-custom { width: 100%; border-collapse: collapse; }
    .table-custom th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 0.8rem; text-transform: uppercase; padding: 16px 20px; border-bottom: 1px solid #e2e8f0; }
    .table-custom td { padding: 16px 20px; vertical-align: middle; color: #0f172a; font-size: 0.95rem; border-bottom: 1px solid #e2e8f0; }
    
    .user-info { display: flex; align-items: center; gap: 16px; }
    .avatar-sm { width: 44px; height: 44px; border-radius: 12px; background: #eff6ff; color: #3b82f6; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.1rem; }
    .badge-soft { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
    .badge-soft.bg-success { background: #d1fae5 !important; color: #059669; }
    .badge-soft.bg-danger { background: #fee2e2 !important; color: #dc2626; }
    .badge-soft.bg-secondary { background: #f1f5f9 !important; color: #475569; }
    
    .btn-action { width: 32px; height: 32px; border-radius: 8px; border: none; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; transition: all 0.2s; cursor: pointer; text-decoration: none; }
    .btn-view { background: #eff6ff; color: #3b82f6; } .btn-view:hover { background: #3b82f6; color: #fff; }
    .btn-save { background: #f0fdf4; color: #10b981; } .btn-save:hover { background: #10b981; color: #fff; }
    .btn-toggle-on { background: #fee2e2; color: #ef4444; } .btn-toggle-on:hover { background: #ef4444; color: #fff; }
    .btn-toggle-off { background: #d1fae5; color: #10b981; } .btn-toggle-off:hover { background: #10b981; color: #fff; }

    /* PAGINATION */
    .btn-page { background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; color: #64748b; cursor: pointer; transition: all 0.2s; font-family: 'Inter', sans-serif; }
    .btn-page:hover:not(:disabled) { border-color: #3b82f6; color: #3b82f6; }
    .btn-page.active { background: #3b82f6; border-color: #3b82f6; color: white; }
    .btn-page:disabled { opacity: 0.5; cursor: not-allowed; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="users" />
    </jsp:include>

    <div class="main-content">
        <!-- Thông báo lỗi/thành công -->
        <c:if test="${not empty param.message}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i> Thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i> Lỗi thực thi!
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <%-- Banner lọc theo phòng ban / chức vụ --%>
        <c:if test="${not empty filterName}">
            <div style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:12px;padding:12px 20px;margin-bottom:20px;display:flex;align-items:center;justify-content:space-between;gap:12px;">
                <div style="display:flex;align-items:center;gap:10px;">
                    <i class="fas fa-filter" style="color:#2b6cb0;"></i>
                    <span style="font-weight:600;color:#1e40af;">Đang lọc: <strong>${filterName}</strong></span>
                    <span style="color:#64748b;font-size:.85rem;">— ${fn:length(users)} nhân viên</span>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users"
                   style="font-size:.82rem;color:#2b6cb0;text-decoration:none;border:1px solid #bfdbfe;border-radius:6px;padding:4px 12px;background:#fff;">
                    <i class="fas fa-times" style="font-size:.7rem;"></i> Xem tất cả
                </a>
            </div>
        </c:if>

        <!-- Panel Danh sách người dùng -->
        <div class="admin-panel" id="users">
            <div class="panel-header">
                <h2 class="panel-title">
                    <div class="panel-title-icon"><i class="fas fa-users"></i></div>
                    Danh sách Người dùng
                </h2>
                <button type="button" class="btn btn-primary btn-add-user" data-bs-toggle="modal" data-bs-target="#addUserModal" style="background: #3b82f6; border: none; border-radius: 8px; padding: 10px 20px; font-weight: 600;">
                    <i class="fas fa-plus me-2"></i>Thêm tài khoản
                </button>
            </div>

          <!-- Search + Filter -->
<form action="${pageContext.request.contextPath}/admin/users"
      method="get"
      class="row g-3 align-items-center mb-4">

    <!-- Search -->
    <div class="col-md-5">
        <div class="input-group">

            <span class="input-group-text bg-white border-end-0">
                <i class="fas fa-search text-muted"></i>
            </span>

            <input type="text"
                   name="keyword"
                   class="form-control border-start-0"
                   placeholder="Tìm kiếm tên nhân viên..."
                   value="${keyword}">
        </div>
    </div>

    <!-- Filter Role -->
    <div class="col-md-3">

        <select name="roleId" class="form-select">

            <option value="">Tất cả vai trò</option>

            <c:forEach items="${roles}" var="r">

                <option value="${r.roleId}"
                    ${selectedRole == r.roleId.toString() ? 'selected' : ''}>

                    ${r.roleName}

                </option>

            </c:forEach>

        </select>

    </div>

    <!-- Search Button -->
    <div class="col-md-2">

        <button type="submit"
                class="btn btn-primary w-100"
                style="background:#3b82f6;border:none;">

            <i class="fas fa-search me-2"></i>
            Tìm kiếm

        </button>

    </div>

    <!-- Reset Button -->
    <div class="col-md-2">

        <a href="${pageContext.request.contextPath}/admin/users"
           class="btn btn-light border w-100">

            <i class="fas fa-rotate-left me-2"></i>
            Reset

        </a>

    </div>

</form>

<div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Liên hệ</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty users}">
                                <tr class="empty-state-row">
                                    <td colspan="5" class="text-center text-muted" style="padding: 40px;">
                                        <i class="fas fa-users" style="font-size: 3rem; opacity: 0.3; margin-bottom: 16px;"></i>
                                        <p style="font-weight: 600; color: #0f172a;">Không có người dùng nào</p>
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
                                    <div><i class="fas fa-envelope text-muted me-2"></i>${u.email}</div>
                                    <c:if test="${not empty u.phone}">
                                        <div class="mt-1"><i class="fas fa-phone text-muted me-2"></i>${u.phone}</div>
                                    </c:if>
                                </td>
                                <td>
                                    <!-- Form sửa Role -->
                                    <form method="post" action="${pageContext.request.contextPath}/admin/users" class="d-flex align-items-center gap-2 m-0">
                                        <input type="hidden" name="action" value="updateRole" />
                                        <input type="hidden" name="userId" value="${u.userId}" />
                                        <select name="roleId" class="form-select form-select-sm" style="width: 140px; border-radius: 8px;">
                                            <c:forEach items="${roles}" var="r">
                                                <option value="${r.roleId}" ${r.roleId == u.roleId ? 'selected' : ''}>
                                                    ${r.roleName}
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <button type="submit" class="btn-action btn-save" title="Lưu phân quyền">
                                            <i class="fas fa-check"></i>
                                        </button>
                                    </form>
                                </td>
                                <td>
                                    <span class="badge-soft ${u.status == 1 ? 'bg-success' : 'bg-danger'}">
                                        <i class="fas ${u.status == 1 ? 'fa-check-circle' : 'fa-lock'} me-1"></i>
                                        ${u.status == 1 ? 'Hoạt động' : 'Bị khóa'}
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex gap-2 justify-content-end">
                                        <!-- Khóa/Mở khóa -->
                                        <form method="post" action="${pageContext.request.contextPath}/admin/users" class="m-0" onsubmit="return confirm('Bạn có chắc chắn muốn ${u.status == 1 ? 'KHÓA' : 'MỞ KHÓA'} tài khoản của ${u.fullName} không?');">
                                            <input type="hidden" name="action" value="toggleStatus" />
                                            <input type="hidden" name="userId" value="${u.userId}" />
                                            <button type="submit" class="btn-action ${u.status == 1 ? 'btn-toggle-on' : 'btn-toggle-off'}">
                                                <i class="fas ${u.status == 1 ? 'fa-lock' : 'fa-unlock'}"></i>
                                            </button>
                                        </form>
                                        <!-- Đặt lại mật khẩu (Gửi mail) -->
                                        <form method="post" action="${pageContext.request.contextPath}/admin/users" class="m-0" onsubmit="return confirm('Bạn có chắc chắn muốn tạo mật khẩu mới ngẫu nhiên và gửi vào email của ${u.fullName} không?');">
                                            <input type="hidden" name="action" value="resetPassword" />
                                            <input type="hidden" name="userId" value="${u.userId}" />
                                            <button type="submit" class="btn-action" style="background:#fef08a;color:#ca8a04;" title="Cấp lại mật khẩu qua Email">
                                                <i class="fas fa-key"></i>
                                            </button>
                                        </form>
                                        <!-- Xem chi tiết -->
                                        <a href="${pageContext.request.contextPath}/profile?userId=${u.userId}" class="btn-action btn-view" title="Xem chi tiết">
                                            <i class="fas fa-eye"></i>
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
                    Hiển thị <span id="pageStart" style="font-weight: 600; color: #0f172a;">0</span> - <span id="pageEnd" style="font-weight: 600; color: #0f172a;">0</span> trong tổng số <span id="totalItems" style="font-weight: 600; color: #0f172a;">0</span> mục
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

<!-- Modal Thêm Người Dùng -->
<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.1);">
            <div class="modal-header" style="border-bottom: 1px solid #e2e8f0; padding: 20px 24px;">
                <h5 class="modal-title fw-bold" id="addUserModalLabel">Thêm tài khoản mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/users" method="post">
                <input type="hidden" name="action" value="addUser">
                <div class="modal-body" style="padding: 24px;">
                    <div class="mb-3">
                        <label class="form-label text-muted fw-semibold small">Họ và tên <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="fullName" required placeholder="VD: Nguyễn Văn A">
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted fw-semibold small">Email đăng nhập <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" name="email" required placeholder="VD: user@hrm.com">
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted fw-semibold small">Số điện thoại</label>
                        <input type="text" class="form-control" name="phone" placeholder="Không bắt buộc">
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted fw-semibold small">Mật khẩu khởi tạo</label>
                        <input type="text" class="form-control" name="password" value="@123456" placeholder="Mặc định: @123456">
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted fw-semibold small">Vai trò <span class="text-danger">*</span></label>
                        <select class="form-select" name="roleId" required>
                            <c:forEach items="${roles}" var="r">
                                <option value="${r.roleId}">${r.roleName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 16px 24px;">
                    <button type="button" class="btn text-muted" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary" style="background: #3b82f6; border: none; border-radius: 8px; padding: 8px 24px;">Tạo tài khoản</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Pagination Logic
    let currentPage = 1;
    const itemsPerPage = 10;
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

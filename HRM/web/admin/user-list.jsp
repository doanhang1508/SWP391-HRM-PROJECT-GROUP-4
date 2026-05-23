<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Quản lý Người dùng" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    body { background-color: #f8fafc; font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 40px; width: calc(100% - 260px); }
    .admin-panel { background: #fff; border-radius: 20px; padding: 30px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03); border: 1px solid #e2e8f0; }
    .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .panel-title { font-size: 1.25rem; font-weight: 700; color: #0f172a; margin: 0; display: flex; align-items: center; gap: 12px; }
    .panel-title-icon { width: 32px; height: 32px; background: #f8fafc; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #64748b; font-size: 0.9rem; }
    .table-custom { width: 100%; border-collapse: collapse; }
    .table-custom th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 0.8rem; text-transform: uppercase; padding: 16px 20px; border-bottom: 1px solid #e2e8f0; cursor: pointer; user-select: none; white-space: nowrap; }
    .table-custom th:hover { color: #3b82f6; }
    .table-custom th .sort-icon { margin-left: 4px; font-size: 0.7rem; opacity: 0.4; }
    .table-custom th.sorted .sort-icon { opacity: 1; color: #3b82f6; }
    .table-custom td { padding: 16px 20px; vertical-align: middle; color: #0f172a; font-size: 0.95rem; border-bottom: 1px solid #e2e8f0; }
    .user-info { display: flex; align-items: center; gap: 16px; }
    .avatar-sm { width: 44px; height: 44px; border-radius: 12px; background: #eff6ff; color: #3b82f6; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.1rem; }
    .badge-soft { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
    .badge-soft.bg-success { background: #d1fae5 !important; color: #059669; }
    .badge-soft.bg-danger { background: #fee2e2 !important; color: #dc2626; }
    .btn-action { width: 32px; height: 32px; border-radius: 8px; border: none; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; transition: all 0.2s; cursor: pointer; text-decoration: none; }
    .btn-view { background: #eff6ff; color: #3b82f6; } .btn-view:hover { background: #3b82f6; color: #fff; }
    .btn-save { background: #f0fdf4; color: #10b981; } .btn-save:hover { background: #10b981; color: #fff; }
    .btn-toggle-on { background: #fee2e2; color: #ef4444; } .btn-toggle-on:hover { background: #ef4444; color: #fff; }
    .btn-toggle-off { background: #d1fae5; color: #10b981; } .btn-toggle-off:hover { background: #10b981; color: #fff; }
    .btn-reset { background: #fef3c7; color: #d97706; } .btn-reset:hover { background: #d97706; color: #fff; }

    /* Search & Filter Bar */
    .filter-bar { display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; align-items: center; }
    .filter-bar .search-box { flex: 1; min-width: 220px; position: relative; }
    .filter-bar .search-box input { width: 100%; padding: 10px 16px 10px 40px; border: 1px solid #e2e8f0; border-radius: 10px; font-size: 0.9rem; transition: border-color 0.2s; background: #f8fafc; }
    .filter-bar .search-box input:focus { outline: none; border-color: #3b82f6; background: #fff; box-shadow: 0 0 0 3px rgba(59,130,246,0.1); }
    .filter-bar .search-box .search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94a3b8; font-size: 0.85rem; }
    .filter-bar select { padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 10px; font-size: 0.85rem; background: #f8fafc; color: #334155; min-width: 140px; cursor: pointer; }
    .filter-bar select:focus { outline: none; border-color: #3b82f6; }
    .btn-clear-filter { padding: 10px 16px; border: 1px solid #e2e8f0; border-radius: 10px; background: #fff; color: #64748b; font-size: 0.85rem; cursor: pointer; transition: all 0.2s; white-space: nowrap; }
    .btn-clear-filter:hover { background: #fee2e2; color: #dc2626; border-color: #fca5a5; }

    /* Pagination */
    .pagination-bar { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 16px; border-top: 1px solid #f1f5f9; flex-wrap: wrap; gap: 12px; }
    .pagination-info { font-size: 0.85rem; color: #64748b; }
    .pagination-info strong { color: #0f172a; }
    .pagination-controls { display: flex; gap: 4px; align-items: center; }
    .pagination-controls a, .pagination-controls span { display: flex; align-items: center; justify-content: center; min-width: 36px; height: 36px; border-radius: 8px; font-size: 0.85rem; font-weight: 500; text-decoration: none; transition: all 0.2s; padding: 0 8px; }
    .pagination-controls a { background: #f8fafc; color: #334155; border: 1px solid #e2e8f0; }
    .pagination-controls a:hover { background: #3b82f6; color: #fff; border-color: #3b82f6; }
    .pagination-controls span.active { background: #3b82f6; color: #fff; border: 1px solid #3b82f6; }
    .pagination-controls span.disabled { background: #f1f5f9; color: #cbd5e1; border: 1px solid #e2e8f0; cursor: not-allowed; }
    .page-size-select { padding: 6px 10px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 0.8rem; background: #f8fafc; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="users" />
    </jsp:include>

    <div class="main-content">
        <!-- Thông báo -->
        <c:if test="${not empty param.message}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i> ${fn:escapeXml(param.message)}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i> ${fn:escapeXml(param.error)}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="admin-panel" id="users">
            <div class="panel-header">
                <h2 class="panel-title">
                    <div class="panel-title-icon"><i class="fas fa-users"></i></div>
                    Danh sách Người dùng
                    <span style="font-size:0.8rem;font-weight:400;color:#94a3b8;margin-left:4px;">(${totalUsers} người dùng)</span>
                </h2>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal" style="background:#3b82f6;border:none;border-radius:8px;padding:10px 20px;font-weight:600;">
                    <i class="fas fa-plus me-2"></i>Thêm tài khoản
                </button>
            </div>

            <!-- Thanh tìm kiếm & lọc -->
            <form method="get" action="${pageContext.request.contextPath}/admin/users" id="filterForm">
                <div class="filter-bar">
                    <div class="search-box">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" name="search" value="${fn:escapeXml(search)}" placeholder="Tìm theo tên, email hoặc username...">
                    </div>
                    <select name="filterRole" onchange="document.getElementById('filterForm').submit();">
                        <option value="">-- Tất cả vai trò --</option>
                        <c:forEach items="${roles}" var="r">
                            <option value="${r.roleId}" ${filterRole == r.roleId ? 'selected' : ''}>${r.roleName}</option>
                        </c:forEach>
                    </select>
                    <select name="filterStatus" onchange="document.getElementById('filterForm').submit();">
                        <option value="">-- Tất cả trạng thái --</option>
                        <option value="1" ${filterStatus == '1' ? 'selected' : ''}>Hoạt động</option>
                        <option value="0" ${filterStatus == '0' ? 'selected' : ''}>Bị khóa</option>
                    </select>
                    <input type="hidden" name="sortBy" value="${sortBy}">
                    <input type="hidden" name="sortDir" value="${sortDir}">
                    <input type="hidden" name="pageSize" value="${pageSize}">
                    <button type="submit" class="btn-clear-filter" style="background:#3b82f6;color:#fff;border-color:#3b82f6;">
                        <i class="fas fa-search me-1"></i> Tìm
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn-clear-filter">
                        <i class="fas fa-times me-1"></i> Xóa lọc
                    </a>
                </div>
            </form>

            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th onclick="sortTable('name')">
                                Nhân viên <i class="fas ${sortBy == 'name' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} sort-icon"></i>
                            </th>
                            <th onclick="sortTable('email')">
                                Liên hệ <i class="fas ${sortBy == 'email' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} sort-icon"></i>
                            </th>
                            <th>Vai trò</th>
                            <th onclick="sortTable('status')">
                                Trạng thái <i class="fas ${sortBy == 'status' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} sort-icon"></i>
                            </th>
                            <th onclick="sortTable('createdAt')">
                                Ngày tạo <i class="fas ${sortBy == 'createdAt' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} sort-icon"></i>
                            </th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${users}" var="u">
                            <tr>
                                <td>
                                    <div class="user-info">
                                        <div class="avatar-sm">${fn:substring(u.fullName, 0, 1)}</div>
                                        <div>
                                            <div class="fw-bold" style="color:#0f172a;">${u.fullName}</div>
                                            <div style="font-size:0.8rem;color:#64748b;">@${u.username}</div>
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
                                    <form method="post" action="${pageContext.request.contextPath}/admin/users" class="d-flex align-items-center gap-2 m-0">
                                        <input type="hidden" name="action" value="updateRole" />
                                        <input type="hidden" name="userId" value="${u.userId}" />
                                        <select name="roleId" class="form-select form-select-sm" style="width:140px;border-radius:8px;">
                                            <c:forEach items="${roles}" var="r">
                                                <option value="${r.roleId}" ${r.roleId == u.roleId ? 'selected' : ''}>${r.roleName}</option>
                                            </c:forEach>
                                        </select>
                                        <button type="submit" class="btn-action btn-save" title="Lưu phân quyền"><i class="fas fa-check"></i></button>
                                    </form>
                                </td>
                                <td>
                                    <span class="badge-soft ${u.status == 1 ? 'bg-success' : 'bg-danger'}">
                                        <i class="fas ${u.status == 1 ? 'fa-check-circle' : 'fa-lock'} me-1"></i>
                                        ${u.status == 1 ? 'Hoạt động' : 'Bị khóa'}
                                    </span>
                                </td>
                                <td>
                                    <c:if test="${not empty u.createdAt}">
                                        <span style="font-size:0.85rem;color:#64748b;">
                                            <i class="fas fa-calendar-alt me-1"></i>
                                            ${fn:substring(u.createdAt, 0, 10)}
                                        </span>
                                    </c:if>
                                </td>
                                <td>
                                    <div class="d-flex gap-2 justify-content-end">
                                        <!-- Reset mật khẩu -->
                                        <form method="post" action="${pageContext.request.contextPath}/admin/users" class="m-0" onsubmit="return confirm('Bạn có chắc muốn RESET mật khẩu cho ${u.fullName}? Mật khẩu mới sẽ được gửi qua email ${u.email}.');">
                                            <input type="hidden" name="action" value="resetPassword" />
                                            <input type="hidden" name="userId" value="${u.userId}" />
                                            <button type="submit" class="btn-action btn-reset" title="Reset mật khẩu">
                                                <i class="fas fa-key"></i>
                                            </button>
                                        </form>
                                        <!-- Khóa/Mở khóa -->
                                        <form method="post" action="${pageContext.request.contextPath}/admin/users" class="m-0" onsubmit="return confirm('Bạn có chắc chắn muốn ${u.status == 1 ? 'KHÓA' : 'MỞ KHÓA'} tài khoản của ${u.fullName} không?');">
                                            <input type="hidden" name="action" value="toggleStatus" />
                                            <input type="hidden" name="userId" value="${u.userId}" />
                                            <button type="submit" class="btn-action ${u.status == 1 ? 'btn-toggle-on' : 'btn-toggle-off'}">
                                                <i class="fas ${u.status == 1 ? 'fa-lock' : 'fa-unlock'}"></i>
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
                        <c:if test="${empty users}">
                            <tr><td colspan="6" class="text-center py-5" style="color:#94a3b8;">
                                <i class="fas fa-inbox fa-2x mb-2 d-block"></i>Không tìm thấy người dùng nào
                            </td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Phân trang -->
            <div class="pagination-bar">
                <div class="pagination-info">
                    Hiển thị <strong>${fromIndex}</strong> - <strong>${toIndex}</strong> / <strong>${totalUsers}</strong> người dùng
                    &nbsp;|&nbsp;
                    <select class="page-size-select" onchange="changePageSize(this.value)">
                        <option value="5" ${pageSize == 5 ? 'selected' : ''}>5 / trang</option>
                        <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 / trang</option>
                        <option value="25" ${pageSize == 25 ? 'selected' : ''}>25 / trang</option>
                        <option value="50" ${pageSize == 50 ? 'selected' : ''}>50 / trang</option>
                    </select>
                </div>
                <div class="pagination-controls">
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="javascript:void(0)" onclick="goToPage(1)" title="Trang đầu"><i class="fas fa-angle-double-left"></i></a>
                            <a href="javascript:void(0)" onclick="goToPage(${currentPage - 1})" title="Trang trước"><i class="fas fa-angle-left"></i></a>
                        </c:when>
                        <c:otherwise>
                            <span class="disabled"><i class="fas fa-angle-double-left"></i></span>
                            <span class="disabled"><i class="fas fa-angle-left"></i></span>
                        </c:otherwise>
                    </c:choose>

                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                            <c:choose>
                                <c:when test="${i == currentPage}"><span class="active">${i}</span></c:when>
                                <c:otherwise><a href="javascript:void(0)" onclick="goToPage(${i})">${i}</a></c:otherwise>
                            </c:choose>
                        </c:if>
                    </c:forEach>

                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="javascript:void(0)" onclick="goToPage(${currentPage + 1})" title="Trang sau"><i class="fas fa-angle-right"></i></a>
                            <a href="javascript:void(0)" onclick="goToPage(${totalPages})" title="Trang cuối"><i class="fas fa-angle-double-right"></i></a>
                        </c:when>
                        <c:otherwise>
                            <span class="disabled"><i class="fas fa-angle-right"></i></span>
                            <span class="disabled"><i class="fas fa-angle-double-right"></i></span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Thêm Người Dùng -->
<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;border:none;box-shadow:0 10px 40px rgba(0,0,0,0.1);">
            <div class="modal-header" style="border-bottom:1px solid #e2e8f0;padding:20px 24px;">
                <h5 class="modal-title fw-bold" id="addUserModalLabel">Thêm tài khoản mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/users" method="post">
                <input type="hidden" name="action" value="addUser">
                <div class="modal-body" style="padding:24px;">
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
                <div class="modal-footer" style="border-top:1px solid #e2e8f0;padding:16px 24px;">
                    <button type="button" class="btn text-muted" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary" style="background:#3b82f6;border:none;border-radius:8px;padding:8px 24px;">Tạo tài khoản</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function buildBaseUrl() {
        var base = '${pageContext.request.contextPath}/admin/users?';
        var params = [];
        var search = document.querySelector('input[name="search"]');
        var role = document.querySelector('select[name="filterRole"]');
        var status = document.querySelector('select[name="filterStatus"]');
        if (search && search.value) params.push('search=' + encodeURIComponent(search.value));
        if (role && role.value) params.push('filterRole=' + role.value);
        if (status && status.value) params.push('filterStatus=' + status.value);
        return base + params.join('&');
    }
    function sortTable(col) {
        var currentSort = '${sortBy}';
        var currentDir = '${sortDir}';
        var newDir = (col === currentSort && currentDir === 'asc') ? 'desc' : 'asc';
        var url = buildBaseUrl();
        url += '&sortBy=' + col + '&sortDir=' + newDir;
        url += '&pageSize=${pageSize}';
        window.location.href = url;
    }
    function goToPage(page) {
        var url = buildBaseUrl();
        url += '&sortBy=${sortBy}&sortDir=${sortDir}';
        url += '&pageSize=${pageSize}';
        url += '&page=' + page;
        window.location.href = url;
    }
    function changePageSize(size) {
        var url = buildBaseUrl();
        url += '&sortBy=${sortBy}&sortDir=${sortDir}';
        url += '&pageSize=' + size + '&page=1';
        window.location.href = url;
    }
</script>

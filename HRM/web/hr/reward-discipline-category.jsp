<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Danh Mục Thưởng / Kỷ Luật" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
/* ── Reset portal footer cho trang admin ── */
footer, #chatWidget {
    display: none !important;
}

body {
    background-color: #f1f5f9 !important;
    font-family: 'Inter', sans-serif !important;
    padding-top: 0 !important;
    min-height: 100vh;
}

.dashboard-wrapper {
    display: flex;
    min-height: calc(100vh - 64px);
}

.dash-main {
    flex: 1;
    min-width: 0;
    background: #f1f5f9;
}

.dash-content {
    padding: 28px 32px;
    display: flex;
    flex-direction: column;
    gap: 28px;
}

.dash-page-header {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.dash-breadcrumb {
    font-size: 0.78rem;
    color: #94a3b8;
    display: flex;
    align-items: center;
    gap: 6px;
}

.dash-breadcrumb a {
    color: #0d9488;
    text-decoration: none;
}

.dash-page-title {
    font-size: 1.5rem;
    font-weight: 800;
    color: #0f172a;
    letter-spacing: -0.5px;
}

.dash-card {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
}

.dash-card-header {
    margin-bottom: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
}

.dash-card-title {
    font-size: 1.1rem;
    font-weight: 700;
    color: #0f172a;
}

.dash-btn {
    padding: 8px 16px;
    font-size: 0.85rem;
    font-weight: 600;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: #fff;
    background: #0d9488;
    transition: background 0.2s;
}

.dash-btn:hover {
    background: #0f766e;
}

/* ── Search & Filter Bar ── */
.filter-bar {
    display: flex;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

.filter-bar input[type="text"] {
    flex: 1;
    min-width: 200px;
    padding: 9px 14px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.9rem;
    outline: none;
    transition: border-color 0.2s;
}

.filter-bar input[type="text"]:focus {
    border-color: #0d9488;
    box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.12);
}

.filter-bar select {
    padding: 9px 14px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.9rem;
    background: #fff;
    outline: none;
    min-width: 150px;
    cursor: pointer;
}

.filter-bar select:focus {
    border-color: #0d9488;
}

.filter-btn {
    padding: 9px 16px;
    font-size: 0.85rem;
    font-weight: 600;
    border-radius: 8px;
    border: 1px solid #e2e8f0;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #f8fafc;
    color: #475569;
    transition: all 0.2s;
}

.filter-btn:hover {
    background: #e2e8f0;
}

.filter-btn-clear {
    color: #ef4444;
    border-color: #fecaca;
}

.filter-btn-clear:hover {
    background: #fee2e2;
}

/* ── Table ── */
.dash-table {
    width: 100%;
    border-collapse: collapse;
}

.dash-table th {
    padding: 12px 16px;
    border-bottom: 1px solid #e2e8f0;
    color: #64748b;
    font-size: 0.75rem;
    text-transform: uppercase;
    background: #fafbfc;
    text-align: left;
}

.dash-table td {
    padding: 15px 16px;
    border-bottom: 1px solid #f1f5f9;
    font-size: 0.9rem;
    color: #0f172a;
}

.dash-table tbody tr {
    transition: background 0.15s;
}

.dash-table tbody tr:hover {
    background: #f8fafc;
}

.badge {
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 700;
    display: inline-block;
}

.badge-reward { background: #d1fae5; color: #059669; }
.badge-discipline { background: #fee2e2; color: #dc2626; }

.action-btn {
    background: none;
    border: none;
    cursor: pointer;
    padding: 4px 6px;
    border-radius: 4px;
    transition: background 0.15s;
}

.action-btn:hover {
    background: #f1f5f9;
}

.empty-state {
    text-align: center;
    padding: 48px 20px;
    color: #94a3b8;
}

.empty-state i {
    font-size: 2.5rem;
    margin-bottom: 12px;
    display: block;
}

/* ── Modal ── */
.modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    z-index: 1050;
    background: rgba(15, 23, 42, 0.45);
    backdrop-filter: blur(3px);
    animation: fadeIn 0.2s;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-box {
    background: #ffffff;
    margin: 6% auto;
    padding: 24px 28px;
    width: 480px;
    max-width: 95%;
    border-radius: 14px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
    animation: slideDown 0.25s ease-out;
}

@keyframes slideDown {
    from { transform: translateY(-20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 1px solid #e2e8f0;
}

.modal-title {
    font-size: 1rem;
    font-weight: 700;
    color: #0f172a;
    margin: 0;
}

.modal-close {
    background: none;
    border: none;
    font-size: 1.4rem;
    color: #64748b;
    cursor: pointer;
    line-height: 1;
    padding: 0;
}

.form-group {
    margin-bottom: 16px;
}

.form-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 600;
    color: #64748b;
    margin-bottom: 6px;
}

.form-control {
    width: 100%;
    padding: 9px 12px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.9rem;
    outline: none;
    box-sizing: border-box;
}

.form-control:focus {
    border-color: #0d9488;
    box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.15);
}

.modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 18px;
}

.btn-cancel {
    background: none;
    border: 1px solid #e2e8f0;
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 0.85rem;
    color: #64748b;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-cancel:hover {
    background: #f8fafc;
}

/* ── Detail Panel ── */
.detail-panel {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
    animation: slideDown 0.25s ease-out;
}

.detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
}

.detail-item {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.detail-item.full-width {
    grid-column: 1 / -1;
}

.detail-label {
    font-size: 0.75rem;
    font-weight: 600;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.detail-value {
    font-size: 0.95rem;
    font-weight: 500;
    color: #0f172a;
}

/* ── Alert / Toast ── */
.alert-banner {
    padding: 14px 18px;
    border-radius: 8px;
    font-size: 0.9rem;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 10px;
}

.alert-error {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #f87171;
}

.alert-success {
    background: #d1fae5;
    color: #065f46;
    border: 1px solid #6ee7b7;
}

@media (max-width: 768px) {
    .modal-box { width: 95%; margin: 12% auto; }
    .detail-grid { grid-template-columns: 1fr; }
    .filter-bar { flex-direction: column; }
    .filter-bar input[type="text"] { min-width: auto; }
}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="reward-disciplines" />
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">
            <div class="dash-page-header">
                <div class="dash-breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <span>Thưởng & Kỷ luật</span>
                </div>
                <div class="dash-page-title">Quản Lý Danh Mục Thưởng / Kỷ Luật</div>
            </div>

            <!-- Alert Messages -->
            <c:if test="${not empty error or not empty param.error}">
                <div class="alert-banner alert-error">
                    <i class="fas fa-exclamation-triangle"></i> ${not empty error ? error : param.error}
                </div>
            </c:if>
            <c:if test="${not empty param.success}">
                <div class="alert-banner alert-success">
                    <i class="fas fa-check-circle"></i> ${param.success}
                </div>
            </c:if>

            <!-- View Details Panel -->
            <c:if test="${not empty detail}">
                <div class="detail-panel">
                    <div class="dash-card-header" style="margin-bottom: 16px;">
                        <h3 class="dash-card-title"><i class="fas fa-info-circle" style="color:#0d9488;"></i> Chi Tiết Hạng Mục</h3>
                        <a href="${pageContext.request.contextPath}/admin/reward-disciplines" class="filter-btn">
                            <i class="fas fa-times"></i> Đóng
                        </a>
                    </div>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">ID</span>
                            <span class="detail-value">#${detail.id}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Tên Hạng Mục</span>
                            <span class="detail-value">${detail.name}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Phân Loại</span>
                            <span class="detail-value">
                                <c:choose>
                                    <c:when test="${detail.type == 'Reward'}">
                                        <span class="badge badge-reward">Thưởng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-discipline">Kỷ Luật</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Mức Áp Dụng</span>
                            <span class="detail-value">${empty detail.applyLevel ? 'Cá nhân' : detail.applyLevel}</span>
                        </div>
                        <div class="detail-item full-width">
                            <span class="detail-label">Mô Tả</span>
                            <span class="detail-value">${empty detail.description ? '—' : detail.description}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Ngày Tạo</span>
                            <span class="detail-value">
                                <c:choose>
                                    <c:when test="${not empty detail.createdAt}">
                                        <fmt:formatDate value="${detail.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                    </c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Người Tạo</span>
                            <span class="detail-value">${empty detail.createdByName ? '—' : detail.createdByName}</span>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- Main Card: List -->
            <div class="dash-card">
                <div class="dash-card-header">
                    <h3 class="dash-card-title">Danh mục các hạng mục</h3>
                    <button class="dash-btn" onclick="openAddModal()">
                        <i class="fas fa-plus"></i> Thêm Hạng Mục
                    </button>
                </div>

                <!-- Search & Filter Bar -->
                <form class="filter-bar" action="${pageContext.request.contextPath}/admin/reward-disciplines" method="GET" id="filterForm">
                    <input type="text" name="keyword" placeholder="Tìm kiếm theo tên hoặc mô tả..." value="${fn:escapeXml(keyword)}">
                    <select name="typeFilter" onchange="document.getElementById('filterForm').submit();">
                        <option value="all" ${empty typeFilter or typeFilter == 'all' ? 'selected' : ''}>Tất cả</option>
                        <option value="Reward" ${typeFilter == 'Reward' ? 'selected' : ''}>Thưởng</option>
                        <option value="Discipline" ${typeFilter == 'Discipline' ? 'selected' : ''}>Kỷ luật</option>
                    </select>
                    <button type="submit" class="filter-btn">
                        <i class="fas fa-search"></i> Tìm
                    </button>
                    <c:if test="${not empty keyword or (not empty typeFilter and typeFilter != 'all')}">
                        <a href="${pageContext.request.contextPath}/admin/reward-disciplines" class="filter-btn filter-btn-clear">
                            <i class="fas fa-times"></i> Xóa lọc
                        </a>
                    </c:if>
                </form>

                <!-- Table -->
                <table class="dash-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Hạng Mục</th>
                            <th>Phân Loại</th>
                            <th>Mô Tả</th>
                            <th>Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty categories}">
                                <tr>
                                    <td colspan="5">
                                        <div class="empty-state">
                                            <i class="fas fa-inbox"></i>
                                            <div>Không có hạng mục nào.</div>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="item" items="${categories}">
                                    <tr>
                                        <td>#${item.id}</td>
                                        <td style="font-weight: 500;">${item.name}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${item.type == 'Reward'}">
                                                    <span class="badge badge-reward">Thưởng</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-discipline">Kỷ Luật</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="color: #64748b; max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                            ${empty item.description ? '—' : item.description}
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <!-- View Details -->
                                            <a href="${pageContext.request.contextPath}/admin/reward-disciplines?viewId=${item.id}" class="action-btn" style="color: #8b5cf6;" title="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <!-- Edit -->
                                            <button type="button" class="action-btn" style="color: #3b82f6;" title="Chỉnh sửa"
                                                onclick="openEditModal('${item.id}','${fn:escapeXml(item.name)}','${item.type}','${fn:escapeXml(item.description)}','${fn:escapeXml(item.applyLevel)}')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <!-- Delete -->
                                            <form action="${pageContext.request.contextPath}/admin/reward-disciplines" method="POST" style="display: inline;"
                                                  onsubmit="return confirm('Bạn có chắc muốn xóa hạng mục \'${fn:escapeXml(item.name)}\'? Hành động này không thể hoàn tác.');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${item.id}">
                                                <button type="submit" class="action-btn" style="color: #ef4444;" title="Xóa">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- PAGINATION -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 20px; border-top: 1px solid #e2e8f0;">
                    <div style="font-size: 0.85rem; color: #64748b;">
                        Hiển thị <span id="pageStart" style="font-weight: 600; color: #0f172a;">0</span> - <span id="pageEnd" style="font-weight: 600; color: #0f172a;">0</span> trong tổng số <span id="totalItems" style="font-weight: 600; color: #0f172a;">0</span> mục
                    </div>
                    <div style="display: flex; gap: 8px;">
                        <button id="btnPrevPage" onclick="prevPage()" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:0.85rem;color:#64748b;cursor:pointer;"><i class="fas fa-chevron-left"></i></button>
                        <div id="pageNumbers" style="display: flex; gap: 4px;"></div>
                        <button id="btnNextPage" onclick="nextPage()" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:0.85rem;color:#64748b;cursor:pointer;"><i class="fas fa-chevron-right"></i></button>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════ -->
<!-- MODAL: Thêm Hạng Mục Mới                              -->
<!-- ══════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:#0d9488;"></i> Thêm Hạng Mục Mới</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/reward-disciplines" method="POST">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label class="form-label">Tên Hạng Mục <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" class="form-control" maxlength="100" placeholder="Nhập tên hạng mục" required>
            </div>
            <div class="form-group">
                <label class="form-label">Phân Loại <span style="color:#e11d48;">*</span></label>
                <select name="type" class="form-control" required>
                    <option value="Reward">Thưởng</option>
                    <option value="Discipline">Kỷ Luật</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Mô Tả</label>
                <textarea name="description" class="form-control" maxlength="255" rows="3" placeholder="Mô tả ngắn gọn"></textarea>
            </div>
            <div class="form-group">
                <label class="form-label">Mức Áp Dụng</label>
                <select name="applyLevel" class="form-control">
                    <option value="Cá nhân">Cá nhân</option>
                    <option value="Nhóm/Dự án">Nhóm/Dự án</option>
                    <option value="Phòng ban">Phòng ban</option>
                    <option value="Toàn công ty">Toàn công ty</option>
                </select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="dash-btn"><i class="fas fa-save"></i> Lưu</button>
            </div>
        </form>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════ -->
<!-- MODAL: Cập Nhật Hạng Mục                               -->
<!-- ══════════════════════════════════════════════════════ -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-edit" style="color:#3b82f6;"></i> Cập Nhật Hạng Mục</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/reward-disciplines" method="POST">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="edit_id">
            <div class="form-group">
                <label class="form-label">Tên Hạng Mục <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" id="edit_name" class="form-control" maxlength="100" placeholder="Nhập tên hạng mục" required>
            </div>
            <div class="form-group">
                <label class="form-label">Phân Loại <span style="color:#e11d48;">*</span></label>
                <select name="type" id="edit_type" class="form-control" required>
                    <option value="Reward">Thưởng</option>
                    <option value="Discipline">Kỷ Luật</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Mô Tả</label>
                <textarea name="description" id="edit_description" class="form-control" maxlength="255" rows="3" placeholder="Mô tả ngắn gọn"></textarea>
            </div>
            <div class="form-group">
                <label class="form-label">Mức Áp Dụng</label>
                <select name="applyLevel" id="edit_applyLevel" class="form-control">
                    <option value="Cá nhân">Cá nhân</option>
                    <option value="Nhóm/Dự án">Nhóm/Dự án</option>
                    <option value="Phòng ban">Phòng ban</option>
                    <option value="Toàn công ty">Toàn công ty</option>
                </select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Hủy</button>
                <button type="submit" class="dash-btn"><i class="fas fa-save"></i> Cập nhật</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openAddModal() {
        document.getElementById('addModal').style.display = 'block';
    }

    function openEditModal(id, name, type, description, applyLevel) {
        document.getElementById('edit_id').value = id;
        document.getElementById('edit_name').value = name;
        document.getElementById('edit_type').value = type;
        document.getElementById('edit_description').value = description || '';
        document.getElementById('edit_applyLevel').value = applyLevel || 'Cá nhân';
        document.getElementById('editModal').style.display = 'block';
    }

    function closeModal(id) {
        document.getElementById(id).style.display = 'none';
    }

    // Close modal by clicking overlay
    document.querySelectorAll('.modal-overlay').forEach(function (overlay) {
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) {
                overlay.style.display = 'none';
            }
        });
    });

    // Close modal with ESC key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay').forEach(function(m) {
                m.style.display = 'none';
            });
        }
    });

    // ===== PAGINATION =====
    let currentPage = 1;
    const itemsPerPage = 8;
    let filteredRows = [];

    function initPagination() {
        filteredRows = Array.from(document.querySelectorAll('.dash-table tbody tr'));
        filteredRows = filteredRows.filter(r => !r.querySelector('.empty-state'));
        updatePagination();
    }

    function updatePagination() {
        if(filteredRows.length === 0) {
            document.querySelectorAll('.dash-table tbody tr').forEach(row => row.style.display = 'none');
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
        document.querySelectorAll('.dash-table tbody tr').forEach(row => row.style.display = 'none');
        for (let i = startIndex; i < endIndex; i++) { filteredRows[i].style.display = ''; }
        document.getElementById('pageStart').textContent = startIndex + 1;
        document.getElementById('pageEnd').textContent = endIndex;
        document.getElementById('totalItems').textContent = filteredRows.length;
        let pageHtml = '';
        for (let i = 1; i <= totalPages; i++) {
            pageHtml += '<button style="background:' + (i===currentPage ? '#0d9488' : '#fff') + ';border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:0.85rem;color:' + (i===currentPage ? 'white' : '#64748b') + ';cursor:pointer;" onclick="goToPage(' + i + ')">' + i + '</button>';
        }
        document.getElementById('pageNumbers').innerHTML = pageHtml;
        document.getElementById('btnPrevPage').disabled = currentPage === 1;
        document.getElementById('btnNextPage').disabled = currentPage === totalPages;
    }

    function goToPage(page) { currentPage = page; updatePagination(); }
    function prevPage() { if (currentPage > 1) { currentPage--; updatePagination(); } }
    function nextPage() { const tp = Math.ceil(filteredRows.length / itemsPerPage); if (currentPage < tp) { currentPage++; updatePagination(); } }

    document.addEventListener('DOMContentLoaded', function() {
        initPagination();
    });
</script>

<jsp:include page="../footer.jsp" />

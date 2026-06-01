<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Quản lý Chức Vụ" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --navy:    #0a2540;
        --blue:    #2b6cb0;
        --teal:    #0d9488;
        --accent:  #3ecf8e;
        --bg:      #f0ede8;
        --surface: #ffffff;
        --border:  #e2e8f0;
        --text:    #0f172a;
        --muted:   #64748b;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }

    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb  { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }

    /* SUMMARY */
    .summary-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 24px; }
    .summary-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 20px 22px; display: flex; align-items: center; gap: 16px; transition: transform .2s, box-shadow .2s; }
    .summary-card:hover { transform: translateY(-3px); box-shadow: 0 14px 30px rgba(10,37,64,.08); }
    .s-icon   { width: 50px; height: 50px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
    .s-teal   { background: #f0fdfa; color: #0d9488; }
    .s-blue   { background: #eff6ff; color: #2b6cb0; }
    .s-orange { background: #fff7ed; color: #ea580c; }
    .s-label  { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); }
    .s-value  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.85rem; font-weight: 800; color: var(--navy); line-height: 1.1; }
    .s-sub    { font-size: .76rem; color: var(--muted); margin-top: 2px; }

    /* PANEL */
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px 28px; }
    .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--teal); }

    /* SEARCH */
    .search-box { position: relative; }
    .search-box input { padding: 8px 14px 8px 36px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; width: 220px; outline: none; font-family: 'Inter',sans-serif; transition: border .2s; }
    .search-box input:focus { border-color: var(--teal); }
    .search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .85rem; }

    /* TABLE */
    .data-table { width: 100%; border-collapse: collapse; }
    .data-table thead th { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); padding: 11px 16px; border-bottom: 2px solid var(--border); text-align: left; white-space: nowrap; }
    .data-table tbody td { padding: 13px 16px; font-size: .875rem; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
    .data-table tbody tr:last-child td { border-bottom: none; }
    .data-table tbody tr { transition: background .15s; }
    .data-table tbody tr:hover td { background: #f8fafc; }

    .pos-name { font-weight: 700; color: var(--navy); display: flex; align-items: center; gap: 10px; }
    .pos-icon { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: .82rem; flex-shrink: 0; }
    .pos-desc { color: var(--muted); font-size: .82rem; max-width: 280px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    .badge-count  { display: inline-flex; align-items: center; gap: 4px; background: #f0fdfa; color: #0d9488; font-size: .75rem; font-weight: 700; padding: 3px 10px; border-radius: 20px; }
    .badge-active { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }

    /* ACTION */
    .action-btn { background: none; border: none; cursor: pointer; padding: 6px 10px; border-radius: 6px; font-size: .9rem; transition: background .2s; }
    .btn-view   { color: #10b981; }
    .btn-view:hover { background: #d1fae5; }
    .btn-edit   { color: var(--teal); }
    .btn-edit:hover { background: #f0fdfa; }
    .btn-delete { color: #e11d48; }
    .btn-delete:hover { background: #ffe4e6; }

    /* ADD BUTTON */
    .btn-primary { background: var(--teal); color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: background .2s, transform .2s; font-family: 'Inter', sans-serif; }
    .btn-primary:hover { background: #0f766e; transform: translateY(-1px); }

    /* LEVEL BADGE */
    .level-badge { display: inline-block; padding: 3px 10px; border-radius: 6px; font-size: .72rem; font-weight: 700; }
    .lv-1 { background: #faf5ff; color: #7c3aed; } /* Cấp cao */
    .lv-2 { background: #eff6ff; color: #2b6cb0; } /* Quản lý */
    .lv-3 { background: #f0fdfa; color: #0d9488; } /* Chuyên viên */
    .lv-4 { background: #f0fdf4; color: #16a34a; } /* Nhân viên */
    .lv-5 { background: #fff7ed; color: #ea580c; } /* Sản xuất */

    /* EMPTY */
    .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 16px; opacity: .3; }

    /* PAGINATION */
    .btn-page { background: var(--surface); border: 1px solid var(--border); border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; color: var(--muted); cursor: pointer; transition: all 0.2s; font-family: 'Inter', sans-serif; }
    .btn-page:hover:not(:disabled) { border-color: var(--teal); color: var(--teal); }
    .btn-page.active { background: var(--teal); border-color: var(--teal); color: white; }
    .btn-page:disabled { opacity: 0.5; cursor: not-allowed; }

    /* MODAL */
    .modal-overlay { display: none; position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,.5); backdrop-filter: blur(3px); }
    .modal-box { background: var(--surface); margin: 8% auto; padding: 28px 32px; width: 460px; border-radius: 14px; box-shadow: 0 20px 40px rgba(0,0,0,.15); position: relative; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; padding-bottom: 14px; border-bottom: 1px solid var(--border); }
    .modal-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.05rem; font-weight: 800; color: var(--navy); margin: 0; }
    .modal-close  { background: none; border: none; font-size: 1.4rem; color: var(--muted); cursor: pointer; line-height: 1; padding: 0; }
    .modal-close:hover { color: var(--text); }

    .form-group   { margin-bottom: 18px; }
    .form-label   { display: block; font-size: .82rem; font-weight: 600; color: var(--muted); margin-bottom: 6px; }
    .form-control { width: 100%; padding: 10px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .875rem; font-family: 'Inter', sans-serif; outline: none; transition: border .2s; }
    .form-control:focus { border-color: var(--teal); box-shadow: 0 0 0 3px rgba(13,148,136,.12); }
    textarea.form-control { resize: vertical; min-height: 80px; }
    .modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; }
    .btn-cancel   { background: none; border: 1px solid var(--border); padding: 9px 18px; border-radius: 8px; font-size: .875rem; cursor: pointer; color: var(--muted); font-family: 'Inter', sans-serif; }
    .btn-cancel:hover { background: #f8fafc; }

    /* Position level colors */
    .ic-1 { background:#faf5ff;color:#7c3aed; }
    .ic-2 { background:#eff6ff;color:#2b6cb0; }
    .ic-3 { background:#f0fdfa;color:#0d9488; }
    .ic-4 { background:#f0fdf4;color:#16a34a; }
    .ic-5 { background:#fff7ed;color:#ea580c; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .summary-grid { grid-template-columns: 1fr 1fr; }
    }
    @media (max-width:600px) {
        .summary-grid { grid-template-columns: 1fr; }
        .modal-box { width: 95%; margin: 5% auto; padding: 20px; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="position" />
    </jsp:include>

    <div class="page-main">

        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <span>Chức vụ</span>
                </div>
                <h1><i class="fas fa-id-card-alt" style="color:var(--teal);margin-right:10px;font-size:1.3rem;"></i>Quản Lý Chức Vụ</h1>
            </div>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Thêm chức vụ
            </button>
        </div>

        <!-- SUMMARY CARDS -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="s-icon s-teal"><i class="fas fa-id-card-alt"></i></div>
                <div>
                    <div class="s-label">Tổng chức vụ</div>
                    <div class="s-value">${fn:length(positionList)}</div>
                    <div class="s-sub">Đang hoạt động</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-blue"><i class="fas fa-users"></i></div>
                <div>
                    <div class="s-label">Tổng nhân viên</div>
                    <div class="s-value" id="totalEmpCount">—</div>
                    <div class="s-sub">Tất cả chức vụ</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-orange"><i class="fas fa-star"></i></div>
                <div>
                    <div class="s-label">Chức vụ đông nhất</div>
                    <div class="s-value" style="font-size:1.1rem;" id="biggestPos">—</div>
                    <div class="s-sub" id="biggestPosCount"></div>
                </div>
            </div>
        </div>

        <!-- TABLE PANEL -->
        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title"><span class="dot"></span> Danh Sách Chức Vụ</h3>
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Tìm chức vụ..." oninput="filterTable()">
                </div>
            </div>
            <div style="overflow-x:auto;">
                <table class="data-table" id="posTable">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Chức Vụ</th>
                            <th>Mô tả</th>
                            <th style="text-align:center;">Nhân viên</th>
                            <th style="text-align:center;">Trạng thái</th>
                            <th style="text-align:center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty positionList}">
                                <tr class="empty-state-row">
                                    <td colspan="6">
                                        <div class="empty-state">
                                            <i class="fas fa-id-card-alt"></i>
                                            <p style="font-weight:600;color:var(--navy);">Chưa có chức vụ nào</p>
                                            <p style="font-size:.85rem;">Nhấn "Thêm chức vụ" để bắt đầu</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${positionList}" var="pos" varStatus="st">
                                    <tr>
                                        <td style="color:var(--muted);font-weight:600;">${st.count < 10 ? '0' : ''}${st.count}</td>
                                        <td>
                                            <div class="pos-name">
                                                <div class="pos-icon ic-${(st.index % 5) + 1}">
                                                    <i class="fas fa-user-tie"></i>
                                                </div>
                                                ${pos.positionName}
                                            </div>
                                        </td>
                                        <td><span class="pos-desc">${empty pos.description ? '—' : pos.description}</span></td>
                                        <td style="text-align:center;">
                                            <span class="badge-count" data-pos-id="${pos.positionId}" data-pos-name="${pos.positionName}" data-emp-count="${empCountMap[pos.positionId]}" title="Tổng số nhân viên">
                                                <i class="fas fa-user" style="font-size:.6rem;"></i>
                                                <span class="emp-count">...</span>
                                            </span>
                                        </td>
                                        <td style="text-align:center;">
                                            <span class="badge-active"><i class="fas fa-circle" style="font-size:.45rem;"></i> Hoạt động</span>
                                        </td>
                                        <td style="text-align:center;">
                                            <a href="${pageContext.request.contextPath}/admin/users?positionId=${pos.positionId}" class="action-btn btn-view" style="display:inline-flex;" title="Xem danh sách nhân viên">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <button class="action-btn btn-edit" title="Sửa"
                                                    onclick="openEditModal('${pos.positionId}','${pos.positionName}','${pos.description}')">
                                                <i class="fas fa-pen"></i>
                                            </button>
                                            <form action="${pageContext.request.contextPath}/admin/position" method="POST" style="display:inline;" onsubmit="return confirm('Xóa chức vụ \'${pos.positionName}\'?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${pos.positionId}">
                                                <button type="submit" class="action-btn btn-delete" title="Xóa">
                                                    <i class="fas fa-trash-alt"></i>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- PAGINATION -->
            <div class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 20px; border-top: 1px solid var(--border);">
                <div class="pagination-info" style="font-size: 0.85rem; color: var(--muted);">
                    Hiển thị <span id="pageStart" style="font-weight: 600; color: var(--navy);">0</span> - <span id="pageEnd" style="font-weight: 600; color: var(--navy);">0</span> trong tổng số <span id="totalItems" style="font-weight: 600; color: var(--navy);">0</span> mục
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

<!-- ADD MODAL -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:var(--teal);margin-right:8px;"></i>Thêm Chức Vụ Mới</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/position" method="POST">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label class="form-label">Tên chức vụ <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="VD: Trưởng phòng, Chuyên viên..." required>
            </div>
            <div class="form-group">
                <label class="form-label">Mô tả</label>
                <textarea name="description" class="form-control" placeholder="Mô tả vai trò, trách nhiệm của chức vụ..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn-primary"><i class="fas fa-save"></i> Lưu</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT MODAL -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-edit" style="color:var(--teal);margin-right:8px;"></i>Cập Nhật Chức Vụ</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/position" method="POST">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="edit_id">
            <div class="form-group">
                <label class="form-label">Tên chức vụ <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" id="edit_name" class="form-control" required>
            </div>
            <div class="form-group">
                <label class="form-label">Mô tả</label>
                <textarea name="description" id="edit_desc" class="form-control"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Hủy</button>
                <button type="submit" class="btn-primary"><i class="fas fa-save"></i> Cập nhật</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openAddModal()  { document.getElementById('addModal').style.display = 'block'; }
    function closeModal(id)  { document.getElementById(id).style.display = 'none'; }

    function openEditModal(id, name, desc) {
        document.getElementById('edit_id').value   = id;
        document.getElementById('edit_name').value  = name;
        document.getElementById('edit_desc').value  = desc;
        document.getElementById('editModal').style.display = 'block';
    }

    document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) overlay.style.display = 'none';
        });
    });

    // Pagination & Search filter
    let currentPage = 1;
    const itemsPerPage = 8;
    let filteredRows = [];

    function initPagination() {
        const rows = document.querySelectorAll('#posTable tbody tr:not(.empty-state-row)');
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
        document.querySelectorAll('#posTable tbody tr:not(.empty-state-row)').forEach(row => row.style.display = 'none');
        
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

    function filterTable() {
        const query = document.getElementById('searchInput').value.toLowerCase();
        const allRows = Array.from(document.querySelectorAll('#posTable tbody tr:not(.empty-state-row)'));
        
        filteredRows = allRows.filter(row => {
            return row.textContent.toLowerCase().includes(query);
        });
        
        currentPage = 1;
        updatePagination();
    }

    // Load employee counts & init pagination
    document.addEventListener('DOMContentLoaded', function() {
        const badges = document.querySelectorAll('.badge-count');
        let total = 0;
        let biggest = { name: '—', count: 0 };
        badges.forEach(function(badge) {
            const count = parseInt(badge.getAttribute('data-emp-count') || '0');
            badge.querySelector('.emp-count').textContent = count;
            total += count;
            const name = badge.getAttribute('data-pos-name');
            if (count > biggest.count) { biggest = { name: name, count: count }; }
        });
        document.getElementById('totalEmpCount').textContent = total || '—';
        document.getElementById('biggestPos').textContent    = biggest.name;
        document.getElementById('biggestPosCount').textContent = biggest.count > 0 ? biggest.count + ' nhân viên' : '';
        
        initPagination();
    });
</script>

<jsp:include page="../footer.jsp" />

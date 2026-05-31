<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Quản lý Trình độ Học vấn" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --navy:    #0a2540;
        --blue:    #2b6cb0;
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
    .summary-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 24px; }
    .summary-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 20px 22px; display: flex; align-items: center; gap: 16px; transition: transform .2s, box-shadow .2s; }
    .summary-card:hover { transform: translateY(-3px); box-shadow: 0 14px 30px rgba(10,37,64,.08); }
    .s-icon { width: 50px; height: 50px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
    .s-blue   { background: #eff6ff; color: #2b6cb0; }
    .s-green  { background: #f0fdf4; color: #16a34a; }
    .s-purple { background: #faf5ff; color: #7c3aed; }
    .s-label  { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); }
    .s-value  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.85rem; font-weight: 800; color: var(--navy); line-height: 1.1; }
    .s-sub    { font-size: .76rem; color: var(--muted); margin-top: 2px; }
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px 28px; }
    .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }
    .dot          { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); }
    .search-box { position: relative; }
    .search-box input { padding: 8px 14px 8px 36px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; width: 220px; outline: none; font-family: 'Inter',sans-serif; transition: border .2s; }
    .search-box input:focus { border-color: var(--blue); }
    .search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .85rem; }
    .data-table { width: 100%; border-collapse: collapse; }
    .data-table thead th { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); padding: 11px 16px; border-bottom: 2px solid var(--border); text-align: left; white-space: nowrap; }
    .data-table tbody td { padding: 13px 16px; font-size: .875rem; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
    .data-table tbody tr:last-child td { border-bottom: none; }
    .data-table tbody tr { transition: background .15s; }
    .data-table tbody tr:hover td { background: #f8fafc; }
    .item-name { font-weight: 700; color: var(--navy); display: flex; align-items: center; gap: 8px; }
    .item-icon { width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: .8rem; flex-shrink: 0; }
    .item-desc { color: var(--muted); font-size: .82rem; max-width: 320px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .badge-count  { display: inline-flex; align-items: center; gap: 4px; background: #eff6ff; color: #2b6cb0; font-size: .75rem; font-weight: 700; padding: 3px 10px; border-radius: 20px; }
    .badge-active { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    .action-btn { background: none; border: none; cursor: pointer; padding: 6px 10px; border-radius: 6px; font-size: .9rem; transition: background .2s; }
    .btn-edit   { color: var(--blue); }
    .btn-edit:hover { background: #eff6ff; }
    .btn-delete { color: #e11d48; }
    .btn-delete:hover { background: #ffe4e6; }
    .btn-primary { background: var(--blue); color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: background .2s, transform .2s; font-family: 'Inter', sans-serif; }
    .btn-primary:hover { background: #1a4971; transform: translateY(-1px); }
    .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 16px; opacity: .3; display: block; }
    .modal-overlay { display: none; position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,.5); backdrop-filter: blur(3px); }
    .modal-box { background: var(--surface); margin: 8% auto; padding: 28px 32px; width: 460px; border-radius: 14px; box-shadow: 0 20px 40px rgba(0,0,0,.15); position: relative; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; padding-bottom: 14px; border-bottom: 1px solid var(--border); }
    .modal-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.05rem; font-weight: 800; color: var(--navy); margin: 0; }
    .modal-close  { background: none; border: none; font-size: 1.4rem; color: var(--muted); cursor: pointer; line-height: 1; padding: 0; }
    .modal-close:hover { color: var(--text); }
    .form-group { margin-bottom: 18px; }
    .form-label { display: block; font-size: .82rem; font-weight: 600; color: var(--muted); margin-bottom: 6px; }
    .form-control { width: 100%; padding: 10px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .875rem; font-family: 'Inter', sans-serif; outline: none; transition: border .2s; }
    .form-control:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(43,108,176,.12); }
    textarea.form-control { resize: vertical; min-height: 80px; }
    .modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; }
    .btn-cancel { background: none; border: 1px solid var(--border); padding: 9px 18px; border-radius: 8px; font-size: .875rem; cursor: pointer; color: var(--muted); font-family: 'Inter', sans-serif; }
    .btn-cancel:hover { background: #f8fafc; }
    .ic-1 { background:#eff6ff;color:#2b6cb0; }
    .ic-2 { background:#faf5ff;color:#7c3aed; }
    .ic-3 { background:#f0fdf4;color:#16a34a; }
    .ic-4 { background:#fff7ed;color:#ea580c; }
    .ic-5 { background:#fdf2f8;color:#db2777; }
    @media (max-width:900px) { .page-main { padding: 20px 16px; } .summary-grid { grid-template-columns: 1fr 1fr; } }
    @media (max-width:600px) { .summary-grid { grid-template-columns: 1fr; } .modal-box { width: 95%; margin: 5% auto; padding: 20px; } }
</style>

<div class="page-wrapper">
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="education-level" />
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
                    <span>Trình độ học vấn</span>
                </div>
                <h1><i class="fas fa-graduation-cap" style="color:var(--blue);margin-right:10px;font-size:1.3rem;"></i>Quản Lý Trình Độ Học Vấn</h1>
            </div>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Thêm trình độ
            </button>
        </div>

        <!-- SUMMARY CARDS -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="s-icon s-blue"><i class="fas fa-graduation-cap"></i></div>
                <div>
                    <div class="s-label">Tổng trình độ</div>
                    <div class="s-value">${fn:length(educationLevelList)}</div>
                    <div class="s-sub">Đang hoạt động</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-green"><i class="fas fa-users"></i></div>
                <div>
                    <div class="s-label">Nhân viên có hồ sơ</div>
                    <div class="s-value" id="totalEmpCount">—</div>
                    <div class="s-sub">Đã phân loại trình độ</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-purple"><i class="fas fa-chart-bar"></i></div>
                <div>
                    <div class="s-label">Trình độ phổ biến nhất</div>
                    <div class="s-value" style="font-size:1.1rem;" id="topLevel">—</div>
                    <div class="s-sub" id="topLevelCount"></div>
                </div>
            </div>
        </div>

        <!-- TABLE PANEL -->
        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title"><span class="dot"></span> Danh Sách Trình Độ Học Vấn</h3>
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Tìm trình độ..." oninput="filterTable()">
                </div>
            </div>
            <div style="overflow-x:auto;">
                <table class="data-table" id="mainTable">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Tên Trình Độ</th>
                            <th>Mô tả</th>
                            <th style="text-align:center;">Nhân viên</th>
                            <th style="text-align:center;">Trạng thái</th>
                            <th style="text-align:center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty educationLevelList}">
                                <tr>
                                    <td colspan="6">
                                        <div class="empty-state">
                                            <i class="fas fa-graduation-cap"></i>
                                            <p style="font-weight:600;color:var(--navy);">Chưa có trình độ học vấn nào</p>
                                            <p style="font-size:.85rem;">Nhấn "Thêm trình độ" để bắt đầu</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${educationLevelList}" var="el" varStatus="st">
                                    <tr>
                                        <td style="color:var(--muted);font-weight:600;">${st.count < 10 ? '0' : ''}${st.count}</td>
                                        <td>
                                            <div class="item-name">
                                                <div class="item-icon ic-${(st.index % 5) + 1}">
                                                    <i class="fas fa-graduation-cap"></i>
                                                </div>
                                                ${el.levelName}
                                            </div>
                                        </td>
                                        <td><span class="item-desc">${empty el.description ? '—' : el.description}</span></td>
                                        <td style="text-align:center;">
                                            <span class="badge-count" data-id="${el.educationLevelId}" data-name="${el.levelName}">
                                                <i class="fas fa-user" style="font-size:.6rem;"></i>
                                                <span class="emp-count">...</span>
                                            </span>
                                        </td>
                                        <td style="text-align:center;">
                                            <span class="badge-active"><i class="fas fa-circle" style="font-size:.45rem;"></i> Hoạt động</span>
                                        </td>
                                        <td style="text-align:center;">
                                            <button class="action-btn btn-edit" title="Sửa"
                                                    onclick="openEditModal('${el.educationLevelId}','${el.levelName}','${el.description}')">
                                                <i class="fas fa-pen"></i>
                                            </button>
                                            <a href="${pageContext.request.contextPath}/admin/education-level?action=delete&id=${el.educationLevelId}"
                                               class="action-btn btn-delete" title="Xóa"
                                               onclick="return confirm('Xóa trình độ \'${el.levelName}\'?')">
                                                <i class="fas fa-trash-alt"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<!-- ADD MODAL -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:var(--blue);margin-right:8px;"></i>Thêm Trình Độ Mới</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/education-level" method="POST">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label class="form-label">Tên trình độ <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="VD: Đại học" required>
            </div>
            <div class="form-group">
                <label class="form-label">Mô tả</label>
                <textarea name="description" class="form-control" placeholder="Mô tả chi tiết..."></textarea>
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
            <h3 class="modal-title"><i class="fas fa-edit" style="color:var(--blue);margin-right:8px;"></i>Cập Nhật Trình Độ</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/education-level" method="POST">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="edit_id">
            <div class="form-group">
                <label class="form-label">Tên trình độ <span style="color:#e11d48;">*</span></label>
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
        document.getElementById('edit_desc').value  = desc || '';
        document.getElementById('editModal').style.display = 'block';
    }
    document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) { if (e.target === overlay) overlay.style.display = 'none'; });
    });
    function filterTable() {
        const query = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('#mainTable tbody tr').forEach(function(row) {
            row.style.display = row.textContent.toLowerCase().includes(query) ? '' : 'none';
        });
    }
    document.addEventListener('DOMContentLoaded', function() {
        const badges = document.querySelectorAll('.badge-count');
        let total = 0, top = { name: '—', count: 0 };
        badges.forEach(function(b) {
            const c = parseInt(b.getAttribute('data-emp-count') || '0');
            b.querySelector('.emp-count').textContent = c;
            total += c;
            if (c > top.count) top = { name: b.getAttribute('data-name'), count: c };
        });
        document.getElementById('totalEmpCount').textContent = total || '—';
        document.getElementById('topLevel').textContent = top.name;
        document.getElementById('topLevelCount').textContent = top.count > 0 ? top.count + ' nhân viên' : '';
    });
</script>

<jsp:include page="../footer.jsp" />

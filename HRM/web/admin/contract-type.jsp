<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Loại Hợp Đồng" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root { 
        --navy:#0a2540; 
        --blue:#2b6cb0; 
        --bg:#f0ede8; 
        --surface:#fff; 
        --border:#e2e8f0; 
        --text:#0f172a; 
        --muted:#64748b; 
        --inactive: #cbd5e1;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }
    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }
    
    /* TOP BAR */
    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb  { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }
    
    /* SUMMARY */
    .summary-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 24px; }
    .summary-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 20px 22px; display: flex; align-items: center; gap: 16px; transition: transform .2s, box-shadow .2s; }
    .summary-card:hover { transform: translateY(-3px); box-shadow: 0 14px 30px rgba(10,37,64,.08); }
    .s-icon { width: 50px; height: 50px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
    .s-blue{background:#eff6ff;color:#2b6cb0;} 
    .s-green{background:#f0fdf4;color:#16a34a;} 
    .s-amber{background:#fffbeb;color:#d97706;}
    .s-label { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); }
    .s-value { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.85rem; font-weight: 800; color: var(--navy); line-height: 1.1; }
    .s-sub   { font-size: .76rem; color: var(--muted); margin-top: 2px; }
    
    /* PANEL */
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px 28px; }
    .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 16px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); }
    
    /* FILTERS */
    .filter-actions { display: flex; align-items: center; gap: 12px; }
    .search-box { position: relative; }
    .search-box input { padding: 8px 14px 8px 36px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; width: 220px; outline: none; transition: border .2s; font-family: 'Inter', sans-serif; }
    .search-box input:focus { border-color: var(--blue); }
    .search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .85rem; }
    .status-select { padding: 8px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; outline: none; background: var(--surface); font-family: 'Inter', sans-serif; }
    
    /* TABLE */
    .data-table { width: 100%; border-collapse: collapse; }
    .data-table thead th { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); padding: 11px 16px; border-bottom: 2px solid var(--border); text-align: left; white-space: nowrap; }
    .data-table tbody td { padding: 13px 16px; font-size: .875rem; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
    .data-table tbody tr:last-child td { border-bottom: none; }
    .data-table tbody tr:hover td { background: #f8fafc; }
    .item-name { font-weight: 700; color: var(--navy); display: flex; align-items: center; gap: 8px; }
    .item-icon { width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: .8rem; flex-shrink: 0; }
    
    /* BADGES */
    .badge-count  { display: inline-flex; align-items: center; gap: 4px; background: #eff6ff; color: #2b6cb0; font-size: .75rem; font-weight: 700; padding: 3px 10px; border-radius: 20px; text-decoration: none; }
    .badge-count:hover { background: #dbeafe; }
    .badge-active { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    .badge-inactive { display: inline-flex; align-items: center; gap: 5px; background: #f1f5f9; color: #64748b; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    
    /* BUTTONS */
    .action-btn { background: none; border: none; cursor: pointer; padding: 6px 10px; border-radius: 6px; font-size: .9rem; transition: background .2s; display: inline-flex; align-items: center; justify-content: center; }
    .btn-view { color: #10b981; } .btn-view:hover { background: #ecfdf5; }
    .btn-edit { color: var(--blue); } .btn-edit:hover { background: #eff6ff; }
    .btn-deactivate { color: #d97706; } .btn-deactivate:hover { background: #fffbeb; }
    .btn-activate { color: #16a34a; } .btn-activate:hover { background: #f0fdf4; }
    .btn-primary { background: var(--blue); color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: background .2s, transform .2s; font-family: 'Inter', sans-serif; }
    .btn-primary:hover { background: #1a4971; transform: translateY(-1px); }
    
    /* PAGINATION */
    .btn-page { background: var(--surface); border: 1px solid var(--border); border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; color: var(--muted); cursor: pointer; transition: all 0.2s; font-family: 'Inter', sans-serif; }
    .btn-page:hover:not(:disabled) { border-color: var(--blue); color: var(--blue); }
    .btn-page.active { background: var(--blue); border-color: var(--blue); color: white; }
    .btn-page:disabled { opacity: 0.5; cursor: not-allowed; }
    
    /* MODALS */
    .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 16px; opacity: .3; display: block; }
    .modal-overlay { display: none; position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,.5); backdrop-filter: blur(3px); }
    .modal-box { background: var(--surface); margin: 8% auto; padding: 28px 32px; width: 480px; border-radius: 14px; box-shadow: 0 20px 40px rgba(0,0,0,.15); position: relative; }
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
    
    .ic-1{background:#eff6ff;color:#2b6cb0;} .ic-2{background:#faf5ff;color:#7c3aed;} .ic-3{background:#f0fdf4;color:#16a34a;} .ic-4{background:#fff7ed;color:#ea580c;} .ic-5{background:#fdf2f8;color:#db2777;}
    @media (max-width:900px) { .page-main { padding: 20px 16px; } .summary-grid { grid-template-columns: 1fr 1fr; } }
    @media (max-width:600px) { .summary-grid { grid-template-columns: 1fr; } .modal-box { width: 95%; margin: 5% auto; padding: 20px; } }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="contract-type" />
    </jsp:include>

    <div class="page-main">
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <span>Loại hợp đồng</span>
                </div>
                <h1><i class="fas fa-file-contract" style="color:var(--blue);margin-right:10px;font-size:1.3rem;"></i>Quản Lý Hợp Đồng</h1>
            </div>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Thêm loại hợp đồng
            </button>
        </div>

        <div class="summary-grid">
            <div class="summary-card">
                <div class="s-icon s-blue"><i class="fas fa-file-contract"></i></div>
                <div>
                    <div class="s-label">Tổng loại hợp đồng</div>
                    <div class="s-value" id="activeTypesCount">${fn:length(contractTypeList)}</div>
                    <div class="s-sub">Tất cả trạng thái</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-green"><i class="fas fa-users"></i></div>
                <div>
                    <div class="s-label">Nhân viên có hợp đồng</div>
                    <div class="s-value" id="totalEmpCount">—</div>
                    <div class="s-sub">Đã phân loại hợp đồng</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-amber"><i class="fas fa-crown"></i></div>
                <div>
                    <div class="s-label">Loại phổ biến nhất</div>
                    <div class="s-value" style="font-size:1.1rem;" id="topType">—</div>
                    <div class="s-sub" id="topTypeCount"></div>
                </div>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title"><span class="dot"></span> Danh Sách Loại Hợp Đồng</h3>
                <div class="filter-actions">
                    <select id="statusFilter" class="status-select" onchange="filterTable()">
                        <option value="all">Tất cả trạng thái</option>
                        <option value="active" selected>Hoạt động</option>
                        <option value="inactive">Vô hiệu hóa</option>
                    </select>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Tìm loại hợp đồng..." oninput="filterTable()">
                    </div>
                </div>
            </div>
            <div style="overflow-x:auto;">
                <table class="data-table" id="mainTable">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Tên Loại Hợp Đồng</th>
                            <th>Thời hạn</th>
                            <th style="text-align:center;">Nhân viên</th>
                            <th style="text-align:center;">Trạng thái</th>
                            <th style="text-align:center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty contractTypeList}">
                                <tr class="empty-state-row"><td colspan="6">
                                    <div class="empty-state">
                                        <i class="fas fa-file-contract"></i>
                                        <p style="font-weight:600;color:var(--navy);">Chưa có loại hợp đồng nào</p>
                                        <p style="font-size:.85rem;">Nhấn "Thêm loại hợp đồng" để bắt đầu</p>
                                    </div>
                                </td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${contractTypeList}" var="ct" varStatus="st">
                                    <fmt:formatDate value="${ct.createdAt}" pattern="dd/MM/yyyy HH:mm" var="formattedCreatedAt"/>
                                    <fmt:formatDate value="${ct.updatedAt}" pattern="dd/MM/yyyy HH:mm" var="formattedUpdatedAt"/>
                                    <tr data-status="${ct.status ? 'active' : 'inactive'}">
                                        <td style="color:var(--muted);font-weight:600;" class="row-stt">${st.count < 10 ? '0' : ''}${st.count}</td>
                                        <td>
                                            <div class="item-name">
                                                <div class="item-icon ic-${(st.index % 5) + 1}"><i class="fas fa-file-alt"></i></div>
                                                ${ct.typeName}
                                            </div>
                                        </td>
                                        <td style="font-weight: 500;">
                                            <c:choose>
                                                <c:when test="${ct.durationUnit eq 'Vô thời hạn'}">
                                                    Vô thời hạn
                                                </c:when>
                                                <c:when test="${not empty ct.duration}">
                                                    ${ct.duration} ${ct.durationUnit}
                                                </c:when>
                                                <c:otherwise>
                                                    —
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center;">
                                            <span class="badge-count" 
      data-emp-count="${empCountMap[ct.contractTypeId]}" 
      data-id="${ct.contractTypeId}" 
      data-name="${ct.typeName}">
    <i class="fas fa-user" style="font-size:.6rem;"></i>
    <span class="emp-count">...</span>
</span>
                                        </td>
                                        <td style="text-align:center;">
                                            <c:choose>
                                                <c:when test="${ct.status}">
                                                    <span class="badge-active"><i class="fas fa-circle" style="font-size:.45rem;"></i> Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-inactive"><i class="fas fa-circle" style="font-size:.45rem;"></i> Vô hiệu hóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center; white-space: nowrap;">
                                            <button class="action-btn btn-view" title="Xem chi tiết" 
                                                    onclick="openDetailsModal('${ct.contractTypeId}', '${fn:escapeXml(ct.typeName)}', '${fn:escapeXml(ct.description)}', '${ct.duration}', '${ct.durationUnit}', ${ct.status}, '${formattedCreatedAt}', '${formattedUpdatedAt}')">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button class="action-btn btn-edit" title="Chỉnh sửa" 
                                                    onclick="openEditModal('${ct.contractTypeId}','${fn:escapeXml(ct.typeName)}','${fn:escapeXml(ct.description)}','${ct.duration}','${ct.durationUnit}')">
                                                <i class="fas fa-pen"></i>
                                            </button>
                                            <c:choose>
                                                <c:when test="${ct.status}">
                                                    <form action="${pageContext.request.contextPath}/admin/contract-type" method="POST" style="display:inline;" onsubmit="return confirm('Vô hiệu hóa loại hợp đồng \'${fn:escapeXml(ct.typeName)}\'?');">
                                                        <input type="hidden" name="action" value="deactivate">
                                                        <input type="hidden" name="id" value="${ct.contractTypeId}">
                                                        <button type="submit" class="action-btn btn-deactivate" title="Vô hiệu hóa">
                                                            <i class="fas fa-ban"></i>
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="${pageContext.request.contextPath}/admin/contract-type" method="POST" style="display:inline;" onsubmit="return confirm('Kích hoạt lại loại hợp đồng \'${fn:escapeXml(ct.typeName)}\'?');">
                                                        <input type="hidden" name="action" value="activate">
                                                        <input type="hidden" name="id" value="${ct.contractTypeId}">
                                                        <button type="submit" class="action-btn btn-activate" title="Kích hoạt">
                                                            <i class="fas fa-check-circle"></i>
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
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

<!-- VIEW DETAILS MODAL -->
<div class="modal-overlay" id="detailsModal">
    <div class="modal-box" style="width: 500px;">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-eye" style="color:var(--blue);margin-right:8px;"></i>Chi Tiết Loại Hợp Đồng</h3>
            <button class="modal-close" onclick="closeModal('detailsModal')">&times;</button>
        </div>
        <div style="font-size: 0.9rem; line-height: 1.6; color: var(--text);">
            <div style="display: grid; grid-template-columns: 150px 1fr; gap: 12px 16px; margin-bottom: 10px;">
                <div style="font-weight: 600; color: var(--muted);">Mã loại HĐ:</div>
                <div id="detail_id" style="font-weight: 700; color: var(--navy);"></div>

                <div style="font-weight: 600; color: var(--muted);">Tên loại HĐ:</div>
                <div id="detail_name" style="font-weight: 700; color: var(--blue);"></div>

                <div style="font-weight: 600; color: var(--muted);">Thời hạn:</div>
                <div id="detail_duration" style="font-weight: 600;"></div>

                <div style="font-weight: 600; color: var(--muted);">Trạng thái:</div>
                <div id="detail_status"></div>

                <div style="font-weight: 600; color: var(--muted);">Mô tả:</div>
                <div id="detail_desc" style="white-space: pre-wrap; background: #f8fafc; padding: 8px 12px; border-radius: 6px; border: 1px solid var(--border);"></div>

                <div style="font-weight: 600; color: var(--muted);">Ngày tạo:</div>
                <div id="detail_created" style="color: var(--muted);"></div>

                <div style="font-weight: 600; color: var(--muted);">Cập nhật cuối:</div>
                <div id="detail_updated" style="color: var(--muted);"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('detailsModal')">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- ADD MODAL -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:var(--blue);margin-right:8px;"></i>Thêm Loại Hợp Đồng Mới</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/contract-type" method="POST">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label class="form-label">Tên loại hợp đồng <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="VD: Hợp đồng 12 tháng" required>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label class="form-label">Thời hạn (Để trống nếu Vô thời hạn)</label>
                    <input type="number" name="duration" id="add_duration" class="form-control" min="1" placeholder="Số lượng (VD: 1, 3, 12)">
                </div>
                <div class="form-group">
                    <label class="form-label">Đơn vị thời hạn</label>
                    <select name="durationUnit" id="add_duration_unit" class="form-control" onchange="toggleDurationInput('add')">
                        <option value="Tháng">Tháng</option>
                        <option value="Năm">Năm</option>
                        <option value="Ngày">Ngày</option>
                        <option value="Vô thời hạn">Vô thời hạn</option>
                    </select>
                </div>
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
            <h3 class="modal-title"><i class="fas fa-edit" style="color:var(--blue);margin-right:8px;"></i>Cập Nhật Loại Hợp Đồng</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/contract-type" method="POST">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="edit_id">
            <div class="form-group">
                <label class="form-label">Tên loại hợp đồng <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" id="edit_name" class="form-control" required>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label class="form-label">Thời hạn</label>
                    <input type="number" name="duration" id="edit_duration" class="form-control" min="1">
                </div>
                <div class="form-group">
                    <label class="form-label">Đơn vị thời hạn</label>
                    <select name="durationUnit" id="edit_duration_unit" class="form-control" onchange="toggleDurationInput('edit')">
                        <option value="Tháng">Tháng</option>
                        <option value="Năm">Năm</option>
                        <option value="Ngày">Ngày</option>
                        <option value="Vô thời hạn">Vô thời hạn</option>
                    </select>
                </div>
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
    function openAddModal() { 
        document.getElementById('addModal').style.display = 'block'; 
        toggleDurationInput('add');
    }
    
    function closeModal(id) { 
        document.getElementById(id).style.display = 'none'; 
    }
    
    function openEditModal(id, name, desc, duration, durationUnit) {
        document.getElementById('edit_id').value  = id;
        document.getElementById('edit_name').value = name;
        document.getElementById('edit_desc').value = desc || '';
        document.getElementById('edit_duration').value = (duration && duration !== 'null') ? duration : '';
        document.getElementById('edit_duration_unit').value = durationUnit || 'Tháng';
        document.getElementById('editModal').style.display = 'block';
        toggleDurationInput('edit');
    }

    function openDetailsModal(id, name, desc, duration, durationUnit, status, created, updated) {
        document.getElementById('detail_id').textContent = id;
        document.getElementById('detail_name').textContent = name;
        document.getElementById('detail_desc').textContent = desc || '—';
        
        let durationText = '—';
        if (durationUnit === 'Vô thời hạn') {
            durationText = 'Vô thời hạn';
        } else if (duration && duration !== 'null' && duration !== '') {
            durationText = duration + ' ' + durationUnit;
        } else if (durationUnit && durationUnit !== 'null') {
            durationText = durationUnit;
        }
        document.getElementById('detail_duration').textContent = durationText;
        
        document.getElementById('detail_status').innerHTML = status ? 
            '<span class="badge-active"><i class="fas fa-circle" style="font-size:.45rem;"></i> Hoạt động</span>' : 
            '<span class="badge-inactive"><i class="fas fa-circle" style="font-size:.45rem;"></i> Vô hiệu hóa</span>';
            
        document.getElementById('detail_created').textContent = created || '—';
        document.getElementById('detail_updated').textContent = updated || '—';
        
        document.getElementById('detailsModal').style.display = 'block';
    }

    function toggleDurationInput(prefix) {
        const unitSelect = document.getElementById(prefix + '_duration_unit');
        const durationInput = document.getElementById(prefix + '_duration');
        if (unitSelect.value === 'Vô thời hạn') {
            durationInput.value = '';
            durationInput.disabled = true;
            durationInput.placeholder = 'Không yêu cầu';
        } else {
            durationInput.disabled = false;
            durationInput.placeholder = 'Số lượng';
        }
    }

    document.querySelectorAll('.modal-overlay').forEach(function(o) {
        o.addEventListener('click', function(e) { if (e.target === o) o.style.display = 'none'; });
    });

    // Pagination & Search filter logic
    let currentPage = 1;
    const itemsPerPage = 8;
    let filteredRows = [];

    function initPagination() {
        filterTable();
    }

    function updatePagination() {
        const pageStartEl = document.getElementById('pageStart');
        const pageEndEl = document.getElementById('pageEnd');
        const totalItemsEl = document.getElementById('totalItems');
        const pageNumbersEl = document.getElementById('pageNumbers');
        const btnPrevPage = document.getElementById('btnPrevPage');
        const btnNextPage = document.getElementById('btnNextPage');

        // Hide all rows in tbody
        document.querySelectorAll('#mainTable tbody tr:not(.empty-state-row)').forEach(row => row.style.display = 'none');

        if(filteredRows.length === 0) {
            pageStartEl.textContent = 0;
            pageEndEl.textContent = 0;
            totalItemsEl.textContent = 0;
            pageNumbersEl.innerHTML = '';
            btnPrevPage.disabled = true;
            btnNextPage.disabled = true;
            return;
        }

        const totalPages = Math.ceil(filteredRows.length / itemsPerPage);
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = Math.min(startIndex + itemsPerPage, filteredRows.length);
        
        // Show only rows for current page and update index order
        for (let i = startIndex; i < endIndex; i++) {
            filteredRows[i].style.display = '';
            
            // Adjust local row index number
            const sttCell = filteredRows[i].querySelector('.row-stt');
            if (sttCell) {
                const idx = i + 1;
                sttCell.textContent = (idx < 10 ? '0' : '') + idx;
            }
        }

        pageStartEl.textContent = startIndex + 1;
        pageEndEl.textContent = endIndex;
        totalItemsEl.textContent = filteredRows.length;

        // Render page buttons
        let pageHtml = '';
        for (let i = 1; i <= totalPages; i++) {
            if (i === currentPage) {
                pageHtml += '<button class="btn-page active">' + i + '</button>';
            } else {
                pageHtml += '<button class="btn-page" onclick="goToPage(' + i + ')">' + i + '</button>';
            }
        }
        pageNumbersEl.innerHTML = pageHtml;

        btnPrevPage.disabled = currentPage === 1;
        btnNextPage.disabled = currentPage === totalPages;
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
        const statusVal = document.getElementById('statusFilter').value;
        const allRows = Array.from(document.querySelectorAll('#mainTable tbody tr:not(.empty-state-row)'));
        
        filteredRows = allRows.filter(row => {
            const matchesSearch = row.textContent.toLowerCase().includes(query);
            const rowStatus = row.getAttribute('data-status');
            const matchesStatus = (statusVal === 'all' || rowStatus === statusVal);
            return matchesSearch && matchesStatus;
        });

        // Toggle empty state row if zero matching items
        const emptyRow = document.querySelector('#mainTable tbody tr.empty-state-row');
        if (filteredRows.length === 0) {
            if (!emptyRow) {
                const tr = document.createElement('tr');
                tr.className = 'empty-state-row';
                tr.innerHTML = `<td colspan="6">
                    <div class="empty-state">
                        <i class="fas fa-file-contract"></i>
                        <p style="font-weight:600;color:var(--navy);">Không tìm thấy kết quả nào phù hợp</p>
                    </div>
                </td>`;
                document.querySelector('#mainTable tbody').appendChild(tr);
            } else {
                emptyRow.style.display = '';
                emptyRow.querySelector('p').textContent = 'Không tìm thấy kết quả nào phù hợp';
            }
        } else {
            if (emptyRow) emptyRow.style.display = 'none';
        }
        
        currentPage = 1;
        updatePagination();
    }

    document.addEventListener('DOMContentLoaded', function() {
        const badges = document.querySelectorAll('.badge-count');
        let total = 0, top = { name: '—', count: -1 };
        
        badges.forEach(function(b) {
            const c = parseInt(b.getAttribute('data-emp-count') || '0');
            b.querySelector('.emp-count').textContent = c;
            total += c;
            if (c > top.count) top = { name: b.getAttribute('data-name'), count: c };
        });
        document.getElementById('totalEmpCount').textContent = total || '—';
        document.getElementById('topType').textContent = top.name;
        document.getElementById('topTypeCount').textContent = top.count >= 0 ? top.count + ' nhân viên' : '';
        
        // Initial setup for pagination & sorting
        initPagination();
    });
</script>

<jsp:include page="../footer.jsp" />

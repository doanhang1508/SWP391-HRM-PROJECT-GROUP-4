<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Bảo Hiểm" scope="request" />
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
    footer, #chatWidget { display: none !important; }

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
    .s-icon { width: 50px; height: 50px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
    .s-blue   { background: #eff6ff; color: #2b6cb0; }
    .s-green  { background: #f0fdf4; color: #16a34a; }
    .s-purple { background: #faf5ff; color: #7c3aed; }
    .s-label  { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); }
    .s-value  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.85rem; font-weight: 800; color: var(--navy); line-height: 1.1; }
    .s-sub    { font-size: .76rem; color: var(--muted); margin-top: 2px; }

    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px 28px; }
    .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); }

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
    .item-icon { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: .85rem; flex-shrink: 0; background: #faf5ff; color: #7c3aed; }
    .item-desc { color: var(--muted); font-size: .82rem; max-width: 220px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    /* RATE BADGES */
    .rate-badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: .82rem; }
    .rate-company  { background: #eff6ff; color: #2b6cb0; }
    .rate-employee { background: #faf5ff; color: #7c3aed; }
    .rate-total    { background: #f0fdf4; color: #16a34a; }

    .badge-active { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }

    .action-btn { background: none; border: none; cursor: pointer; padding: 6px 10px; border-radius: 6px; font-size: .9rem; transition: background .2s; }
    .btn-view   { color: #0d9488; }
    .btn-view:hover { background: #f0fdf4; }
    .btn-edit   { color: var(--blue); }
    .btn-edit:hover { background: #eff6ff; }
    .btn-delete { color: #e11d48; }
    .btn-delete:hover { background: #ffe4e6; }

    .btn-primary { background: var(--blue); color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: background .2s, transform .2s; font-family: 'Inter', sans-serif; }
    .btn-primary:hover { background: #1a4971; transform: translateY(-1px); }

    .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 16px; opacity: .3; display: block; }

    .alert { padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; font-size: .875rem; font-weight: 500; display: flex; align-items: center; gap: 10px; }
    .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .alert-danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    .modal-overlay { display: none; position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,.5); backdrop-filter: blur(3px); }
    .modal-overlay.show { display: flex; align-items: center; justify-content: center; }
    .modal-box { background: var(--surface); padding: 28px 32px; width: 520px; border-radius: 14px; box-shadow: 0 20px 40px rgba(0,0,0,.15); position: relative; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; padding-bottom: 14px; border-bottom: 1px solid var(--border); }
    .modal-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.05rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 8px; }
    .modal-close  { background: none; border: none; font-size: 1.4rem; color: var(--muted); cursor: pointer; line-height: 1; padding: 0; }
    .modal-close:hover { color: var(--text); }

    .form-group { margin-bottom: 18px; }
    .form-label { display: block; font-size: .82rem; font-weight: 600; color: var(--muted); margin-bottom: 6px; text-transform: uppercase; letter-spacing: .5px; }
    .form-control { width: 100%; padding: 10px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .875rem; font-family: 'Inter', sans-serif; outline: none; transition: border .2s; color: var(--text); }
    .form-control:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(43,108,176,.12); }
    textarea.form-control { resize: vertical; min-height: 80px; }

    /* 2-col row inside modal */
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .input-group { position: relative; }
    .input-suffix { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .82rem; font-weight: 600; pointer-events: none; }

    .modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; padding-top: 18px; border-top: 1px solid var(--border); }
    .btn-cancel { background: none; border: 1px solid var(--border); padding: 9px 18px; border-radius: 8px; font-size: .875rem; cursor: pointer; color: var(--muted); font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-cancel:hover { background: #f8fafc; }
    .btn-submit { background: var(--blue); color: #fff; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-submit:hover { background: #1a4971; }

    .delete-modal-box { width: 400px; text-align: center; }
    .delete-modal-icon { width: 64px; height: 64px; background: #fee2e2; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; color: #e11d48; margin: 0 auto 16px; }
    .delete-modal-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.15rem; font-weight: 800; color: var(--navy); margin-bottom: 8px; }
    .delete-modal-body  { color: var(--muted); font-size: .875rem; margin-bottom: 24px; }
    .btn-danger { background: #e11d48; color: #fff; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-danger:hover { background: #be123c; }

    /* info tooltip hint */
    .hint-text { font-size: .75rem; color: var(--muted); margin-top: 4px; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .summary-grid { grid-template-columns: 1fr 1fr; }
        .form-row { grid-template-columns: 1fr; }
    }
    @media (max-width:600px) {
        .summary-grid { grid-template-columns: 1fr; }
        .modal-box, .delete-modal-box { width: 95%; padding: 20px; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp" />

    <main class="page-main">

        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <h1><i class="fas fa-shield-alt" style="color:var(--blue);margin-right:10px;"></i>Quản Lý Mức Đóng Bảo Hiểm</h1>
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i></a>
                    <i class="fas fa-chevron-right" style="font-size:.65rem;"></i>
                    <span>HR Manager</span>
                    <i class="fas fa-chevron-right" style="font-size:.65rem;"></i>
                    <span>Bảo Hiểm</span>
                </div>
            </div>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Thêm Mức Bảo Hiểm
            </button>
        </div>

        <!-- ALERTS -->
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${sessionScope.successMsg}</div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMsg}</div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <!-- SUMMARY CARDS -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="s-icon s-blue"><i class="fas fa-shield-alt"></i></div>
                <div>
                    <div class="s-label">Tổng Loại BH</div>
                    <div class="s-value">${fn:length(insuranceRateList)}</div>
                    <div class="s-sub">loại bảo hiểm</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-green"><i class="fas fa-building"></i></div>
                <div>
                    <div class="s-label">Doanh Nghiệp Đóng</div>
                    <div class="s-value"><fmt:formatNumber value="${avgCompanyRate}" pattern="0.##"/>%</div>
                    <div class="s-sub">tỷ lệ trung bình</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-purple"><i class="fas fa-user-tie"></i></div>
                <div>
                    <div class="s-label">Nhân Viên Đóng</div>
                    <div class="s-value"><fmt:formatNumber value="${avgEmployeeRate}" pattern="0.##"/>%</div>
                    <div class="s-sub">tỷ lệ trung bình</div>
                </div>
            </div>
        </div>

        <!-- TABLE PANEL -->
        <div class="panel">
            <div class="panel-header">
                <h2 class="panel-title">
                    <span class="dot"></span>
                    Danh Sách Mức Đóng Bảo Hiểm
                </h2>
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Tìm kiếm..." oninput="filterTable()">
                </div>
            </div>

            <c:choose>
                <c:when test="${empty insuranceRateList}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <p style="font-size:1rem;font-weight:600;color:var(--navy);margin-bottom:6px;">Chưa có mức bảo hiểm nào</p>
                        <p style="font-size:.85rem;">Nhấn <strong>Thêm Mức Bảo Hiểm</strong> để bắt đầu.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x:auto;">
                        <table class="data-table" id="insuranceTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Loại Bảo Hiểm</th>
                                    <th>Tỷ Lệ DN (%)</th>
                                    <th>Tỷ Lệ NV (%)</th>
                                    <th>Tổng (%)</th>
                                    <th>Mô Tả</th>
                                    <th>Trạng Thái</th>
                                    <th style="text-align:center;">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="ir" items="${insuranceRateList}" varStatus="s">
                                    <tr>
                                        <td style="color:var(--muted);font-weight:600;">${s.index + 1}</td>
                                        <td>
                                            <div class="item-name">
                                                <div class="item-icon"><i class="fas fa-shield-alt"></i></div>
                                                ${ir.insuranceName}
                                            </div>
                                        </td>
                                        <td><span class="rate-badge rate-company"><fmt:formatNumber value="${ir.companyRate}" pattern="0.##"/>%</span></td>
                                        <td><span class="rate-badge rate-employee"><fmt:formatNumber value="${ir.employeeRate}" pattern="0.##"/>%</span></td>
                                        <td><span class="rate-badge rate-total"><fmt:formatNumber value="${ir.companyRate + ir.employeeRate}" pattern="0.##"/>%</span></td>
                                        <td>
                                            <div class="item-desc" title="${ir.description}">
                                                <c:choose>
                                                    <c:when test="${not empty ir.description}">${ir.description}</c:when>
                                                    <c:otherwise><span style="color:#cbd5e1;font-style:italic;">—</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                        <td><span class="badge-active"><i class="fas fa-circle" style="font-size:.5rem;"></i> Hoạt động</span></td>
                                        <td style="text-align:center; white-space: nowrap;">
                                            <button class="action-btn btn-view"
                                                    onclick="openViewModal('${fn:escapeXml(ir.insuranceName)}', '${ir.companyRate}', '${ir.employeeRate}', '${fn:escapeXml(ir.description)}')"
                                                    title="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button class="action-btn btn-edit"
                                                    onclick="openEditModal(${ir.insuranceRateId}, '${fn:escapeXml(ir.insuranceName)}', '${ir.companyRate}', '${ir.employeeRate}', '${fn:escapeXml(ir.description)}')"
                                                    title="Chỉnh sửa">
                                                <i class="fas fa-pen"></i>
                                            </button>
                                            <button class="action-btn btn-delete"
                                                    onclick="openDeleteModal(${ir.insuranceRateId}, '${fn:escapeXml(ir.insuranceName)}')"
                                                    title="Xóa">
                                                <i class="fas fa-trash-alt"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<!-- ═══════════════════════════ MODAL THÊM ═══════════════════════════ -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:var(--blue);"></i> Thêm Mức Bảo Hiểm Mới</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/insurance-rate">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label class="form-label">Tên Loại Bảo Hiểm <span style="color:#e11d48;">*</span></label>
                <input type="text" name="insuranceName" class="form-control" placeholder="Ví dụ: Bảo hiểm xã hội" required maxlength="100">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Tỷ Lệ Doanh Nghiệp <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="companyRate" class="form-control" placeholder="0.00" step="0.01" min="0" max="100" required style="padding-right:36px;">
                        <span class="input-suffix">%</span>
                    </div>
                    <div class="hint-text">Phần DN đóng góp</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tỷ Lệ Nhân Viên <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="employeeRate" class="form-control" placeholder="0.00" step="0.01" min="0" max="100" required style="padding-right:36px;">
                        <span class="input-suffix">%</span>
                    </div>
                    <div class="hint-text">Phần NV phải đóng</div>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Mô Tả</label>
                <textarea name="description" class="form-control" placeholder="Mô tả chi tiết về loại bảo hiểm này..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn-submit"><i class="fas fa-save" style="margin-right:6px;"></i>Lưu</button>
            </div>
        </form>
    </div>
</div>

<!-- ═══════════════════════════ MODAL SỬA ═══════════════════════════ -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-pen" style="color:var(--blue);"></i> Cập Nhật Mức Bảo Hiểm</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/insurance-rate">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="editId">
            <div class="form-group">
                <label class="form-label">Tên Loại Bảo Hiểm <span style="color:#e11d48;">*</span></label>
                <input type="text" name="insuranceName" id="editName" class="form-control" required maxlength="100">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Tỷ Lệ Doanh Nghiệp <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="companyRate" id="editCompanyRate" class="form-control" step="0.01" min="0" max="100" required style="padding-right:36px;">
                        <span class="input-suffix">%</span>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tỷ Lệ Nhân Viên <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="employeeRate" id="editEmployeeRate" class="form-control" step="0.01" min="0" max="100" required style="padding-right:36px;">
                        <span class="input-suffix">%</span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Mô Tả</label>
                <textarea name="description" id="editDesc" class="form-control"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Hủy</button>
                <button type="submit" class="btn-submit"><i class="fas fa-save" style="margin-right:6px;"></i>Cập Nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- ═══════════════════════════ MODAL XEM CHI TIẾT ═══════════════════════════ -->
<div class="modal-overlay" id="viewModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-info-circle" style="color:var(--blue);"></i> Chi Tiết Mức Đóng Bảo Hiểm</h3>
            <button class="modal-close" onclick="closeModal('viewModal')">&times;</button>
        </div>
        <div class="form-group">
            <label class="form-label">Tên Loại Bảo Hiểm</label>
            <div id="viewName" style="font-weight: 700; color: var(--navy); font-size: 1.1rem; padding: 6px 0;"></div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Tỷ Lệ Doanh Nghiệp</label>
                <div class="rate-badge rate-company" id="viewCompanyRate" style="font-size: 1rem; display: inline-block;"></div>
            </div>
            <div class="form-group">
                <label class="form-label">Tỷ Lệ Nhân Viên</label>
                <div class="rate-badge rate-employee" id="viewEmployeeRate" style="font-size: 1rem; display: inline-block;"></div>
            </div>
        </div>
        <div class="form-group">
            <label class="form-label">Tổng Tỷ Lệ</label>
            <div class="rate-badge rate-total" id="viewTotalRate" style="font-size: 1.1rem; font-weight: 800; display: inline-block; padding: 6px 12px;"></div>
        </div>
        <div class="form-group">
            <label class="form-label">Trạng Thái</label>
            <div>
                <span class="badge-active"><i class="fas fa-circle" style="font-size:.5rem;"></i> Hoạt động</span>
            </div>
        </div>
        <div class="form-group">
            <label class="form-label">Mô Tả</label>
            <div id="viewDesc" style="color: var(--text); background: #f8fafc; padding: 12px; border-radius: 8px; font-size: 0.9rem; min-height: 60px; border: 1px solid var(--border); white-space: pre-wrap;"></div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-cancel" onclick="closeModal('viewModal')">Đóng</button>
        </div>
    </div>
</div>

<!-- ═══════════════════════════ MODAL XÓA ═══════════════════════════ -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal-box delete-modal-box">
        <div class="delete-modal-icon"><i class="fas fa-trash-alt"></i></div>
        <div class="delete-modal-title">Xác nhận xóa</div>
        <div class="delete-modal-body">Bạn có chắc muốn xóa mức bảo hiểm <strong id="deleteInsuranceName"></strong>?<br>Hành động này không thể hoàn tác.</div>
        <form method="get" action="${pageContext.request.contextPath}/hr/insurance-rate">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" id="deleteId">
            <div style="display:flex;justify-content:center;gap:12px;">
                <button type="button" class="btn-cancel" onclick="closeModal('deleteModal')">Hủy</button>
                <button type="submit" class="btn-danger"><i class="fas fa-trash-alt" style="margin-right:6px;"></i>Xóa</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openViewModal(name, companyRate, employeeRate, desc) {
        document.getElementById('viewName').textContent = name;
        document.getElementById('viewCompanyRate').textContent = parseFloat(companyRate).toFixed(2).replace(/\.00$/, '') + '%';
        document.getElementById('viewEmployeeRate').textContent = parseFloat(employeeRate).toFixed(2).replace(/\.00$/, '') + '%';
        var total = parseFloat(companyRate) + parseFloat(employeeRate);
        document.getElementById('viewTotalRate').textContent = total.toFixed(2).replace(/\.00$/, '') + '%';
        document.getElementById('viewDesc').textContent = desc ? desc : '—';
        document.getElementById('viewModal').classList.add('show');
    }
    function openAddModal() {
        document.getElementById('addModal').classList.add('show');
    }
    function openEditModal(id, name, companyRate, employeeRate, desc) {
        document.getElementById('editId').value           = id;
        document.getElementById('editName').value         = name;
        document.getElementById('editCompanyRate').value  = companyRate;
        document.getElementById('editEmployeeRate').value = employeeRate;
        document.getElementById('editDesc').value         = desc;
        document.getElementById('editModal').classList.add('show');
    }
    function openDeleteModal(id, name) {
        document.getElementById('deleteId').value = id;
        document.getElementById('deleteInsuranceName').textContent = name;
        document.getElementById('deleteModal').classList.add('show');
    }
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }
    document.querySelectorAll('.modal-overlay').forEach(function(el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) el.classList.remove('show');
        });
    });
    function filterTable() {
        var q = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('#insuranceTable tbody tr').forEach(function(row) {
            row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
        });
    }
    setTimeout(function() {
        document.querySelectorAll('.alert').forEach(function(el) {
            el.style.transition = 'opacity .5s';
            el.style.opacity = '0';
            setTimeout(function() { el.remove(); }, 500);
        });
    }, 4000);
</script>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Phụ Cấp" scope="request" />
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

    /* TOP BAR */
    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb  { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }

    /* SUMMARY CARDS */
    .summary-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 24px; }
    .summary-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 20px 22px; display: flex; align-items: center; gap: 16px; transition: transform .2s, box-shadow .2s; }
    .summary-card:hover { transform: translateY(-3px); box-shadow: 0 14px 30px rgba(10,37,64,.08); }
    .s-icon { width: 50px; height: 50px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
    .s-blue   { background: #eff6ff; color: #2b6cb0; }
    .s-green  { background: #f0fdf4; color: #16a34a; }
    .s-red    { background: #fff1f2; color: #e11d48; }
    .s-label  { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); }
    .s-value  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.85rem; font-weight: 800; color: var(--navy); line-height: 1.1; }
    .s-sub    { font-size: .76rem; color: var(--muted); margin-top: 2px; }

    /* PANEL */
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px 28px; }
    .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); }

    /* FILTER TABS */
    .filter-tabs { display: flex; gap: 6px; }
    .filter-tab { padding: 6px 14px; border-radius: 20px; font-size: .78rem; font-weight: 600; cursor: pointer; border: 1px solid var(--border); background: transparent; color: var(--muted); transition: all .15s; }
    .filter-tab.active, .filter-tab:hover { background: var(--blue); color: #fff; border-color: var(--blue); }

    /* SEARCH */
    .panel-controls { display: flex; align-items: center; gap: 10px; }
    .search-box { position: relative; }
    .search-box input { padding: 8px 14px 8px 36px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; width: 220px; outline: none; font-family: 'Inter',sans-serif; transition: border .2s; }
    .search-box input:focus { border-color: var(--blue); }
    .search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .85rem; }

    /* TABLE */
    .data-table { width: 100%; border-collapse: collapse; }
    .data-table thead th { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); padding: 11px 16px; border-bottom: 2px solid var(--border); text-align: left; white-space: nowrap; }
    .data-table tbody td { padding: 13px 16px; font-size: .875rem; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
    .data-table tbody tr:last-child td { border-bottom: none; }
    .data-table tbody tr { transition: background .15s; }
    .data-table tbody tr:hover td { background: #f8fafc; }
    .data-table tbody tr.inactive td { opacity: .55; }

    .item-name { font-weight: 700; color: var(--navy); display: flex; align-items: center; gap: 8px; }
    .item-icon { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: .85rem; flex-shrink: 0; background: #eff6ff; color: #2b6cb0; }
    .item-desc { color: var(--muted); font-size: .82rem; max-width: 260px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    .amount-cell { font-family: 'Be Vietnam Pro', sans-serif; font-weight: 700; color: #16a34a; font-size: .92rem; }

    .badge-active   { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    .badge-inactive { display: inline-flex; align-items: center; gap: 5px; background: #f1f5f9; color: var(--muted); font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }

    /* ACTIONS */
    .action-group { display: flex; align-items: center; gap: 2px; justify-content: center; }
    .action-btn { background: none; border: none; cursor: pointer; padding: 6px 9px; border-radius: 6px; font-size: .88rem; transition: background .2s; }
    .btn-view   { color: #0891b2; }
    .btn-view:hover { background: #ecfeff; }
    .btn-edit   { color: var(--blue); }
    .btn-edit:hover { background: #eff6ff; }
    .btn-deact  { color: #e11d48; }
    .btn-deact:hover { background: #ffe4e6; }
    .btn-act    { color: #16a34a; }
    .btn-act:hover { background: #dcfce7; }

    /* ADD BUTTON */
    .btn-primary { background: var(--blue); color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: background .2s, transform .2s; font-family: 'Inter', sans-serif; }
    .btn-primary:hover { background: #1a4971; transform: translateY(-1px); }

    /* EMPTY STATE */
    .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 16px; opacity: .3; display: block; }

    /* ALERTS */
    .alert { padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; font-size: .875rem; font-weight: 500; display: flex; align-items: center; gap: 10px; }
    .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .alert-danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    /* MODAL */
    .modal-overlay { display: none; position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,.5); backdrop-filter: blur(3px); }
    .modal-overlay.show { display: flex; align-items: center; justify-content: center; }
    .modal-box { background: var(--surface); padding: 28px 32px; width: 520px; border-radius: 14px; box-shadow: 0 20px 40px rgba(0,0,0,.15); position: relative; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; padding-bottom: 14px; border-bottom: 1px solid var(--border); }
    .modal-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.05rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 8px; }
    .modal-close  { background: none; border: none; font-size: 1.4rem; color: var(--muted); cursor: pointer; line-height: 1; padding: 0; }
    .modal-close:hover { color: var(--text); }

    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .form-group { margin-bottom: 16px; }
    .form-label { display: block; font-size: .82rem; font-weight: 600; color: var(--muted); margin-bottom: 6px; text-transform: uppercase; letter-spacing: .5px; }
    .form-control { width: 100%; padding: 10px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .875rem; font-family: 'Inter', sans-serif; outline: none; transition: border .2s; color: var(--text); }
    .form-control:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(43,108,176,.12); }
    textarea.form-control { resize: vertical; min-height: 80px; }
    .input-group { position: relative; }
    .input-group .form-control { padding-right: 50px; }
    .input-suffix { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); font-size: .78rem; font-weight: 600; color: var(--muted); pointer-events: none; }

    .modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 22px; padding-top: 16px; border-top: 1px solid var(--border); }
    .btn-cancel { background: none; border: 1px solid var(--border); padding: 9px 18px; border-radius: 8px; font-size: .875rem; cursor: pointer; color: var(--muted); font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-cancel:hover { background: #f8fafc; }
    .btn-submit { background: var(--blue); color: #fff; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-submit:hover { background: #1a4971; }

    /* CONFIRM MODAL */
    .confirm-modal-box { width: 400px; text-align: center; }
    .confirm-icon { width: 64px; height: 64px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin: 0 auto 16px; }
    .confirm-icon.danger { background: #fee2e2; color: #e11d48; }
    .confirm-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.1rem; font-weight: 800; color: var(--navy); margin-bottom: 8px; }
    .confirm-body  { color: var(--muted); font-size: .875rem; margin-bottom: 24px; }
    .btn-danger    { background: #e11d48; color: #fff; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-danger:hover { background: #be123c; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .summary-grid { grid-template-columns: 1fr 1fr; }
        .form-row { grid-template-columns: 1fr; }
    }
    @media (max-width:600px) {
        .summary-grid { grid-template-columns: 1fr; }
        .modal-box, .confirm-modal-box { width: 95%; padding: 20px; }
        .search-box input { width: 150px; }
    }
</style>

<%-- Đếm active / inactive --%>
<c:set var="totalActive" value="0"/>
<c:set var="totalInactive" value="0"/>
<c:forEach var="a" items="${allowanceList}">
    <c:if test="${a.status}"><c:set var="totalActive" value="${totalActive + 1}"/></c:if>
    <c:if test="${!a.status}"><c:set var="totalInactive" value="${totalInactive + 1}"/></c:if>
</c:forEach>

<div class="page-wrapper">
    <jsp:include page="sidebar.jsp" />

    <main class="page-main">

        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <h1><i class="fas fa-hand-holding-usd" style="color:var(--blue);margin-right:10px;"></i>Quản Lý Phụ Cấp</h1>
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i></a>
                    <i class="fas fa-chevron-right" style="font-size:.65rem;"></i>
                    <span>HR Manager</span>
                    <i class="fas fa-chevron-right" style="font-size:.65rem;"></i>
                    <span>Phụ Cấp</span>
                </div>
            </div>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Thêm Phụ Cấp
            </button>
        </div>

        <!-- ALERTS -->
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${sessionScope.successMsg}
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMsg}
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <!-- SUMMARY CARDS -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="s-icon s-blue"><i class="fas fa-layer-group"></i></div>
                <div>
                    <div class="s-label">Tổng Loại</div>
                    <div class="s-value">${fn:length(allowanceList)}</div>
                    <div class="s-sub">loại phụ cấp</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-green"><i class="fas fa-check-circle"></i></div>
                <div>
                    <div class="s-label">Đang Hoạt Động</div>
                    <div class="s-value">${totalActive}</div>
                    <div class="s-sub">đang áp dụng</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-red"><i class="fas fa-ban"></i></div>
                <div>
                    <div class="s-label">Đã Vô Hiệu</div>
                    <div class="s-value">${totalInactive}</div>
                    <div class="s-sub">không áp dụng</div>
                </div>
            </div>
        </div>

        <!-- TABLE PANEL -->
        <div class="panel">
            <div class="panel-header">
                <h2 class="panel-title">
                    <span class="dot"></span>
                    Danh Sách Phụ Cấp
                </h2>
                <div class="panel-controls">
                    <div class="filter-tabs">
                        <button class="filter-tab active" onclick="filterByStatus('all', this)">Tất cả</button>
                        <button class="filter-tab" onclick="filterByStatus('active', this)">Hoạt động</button>
                        <button class="filter-tab" onclick="filterByStatus('inactive', this)">Vô hiệu</button>
                    </div>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Tìm kiếm..." oninput="filterTable()">
                    </div>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty allowanceList}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <p style="font-size:1rem;font-weight:600;color:var(--navy);margin-bottom:6px;">Chưa có phụ cấp nào</p>
                        <p style="font-size:.85rem;">Nhấn <strong>Thêm Phụ Cấp</strong> để bắt đầu.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x:auto;">
                        <table class="data-table" id="allowanceTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Tên Phụ Cấp</th>
                                    <th>Mức Tiền</th>
                                    <th>Điều Kiện</th>
                                    <th>Trạng Thái</th>
                                    <th style="text-align:center;">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="a" items="${allowanceList}" varStatus="s">
                                    <tr class="${a.status ? 'active-row' : 'inactive-row inactive'}"
                                        data-status="${a.status ? 'active' : 'inactive'}">
                                        <td style="color:var(--muted);font-weight:600;">${s.index + 1}</td>
                                        <td>
                                            <div class="item-name">
                                                <div class="item-icon" style="${a.status ? '' : 'background:#f1f5f9;color:var(--muted);'}">
                                                    <i class="fas fa-coins"></i>
                                                </div>
                                                <div>
                                                    <div>${a.allowanceName}</div>
                                                    <div class="item-desc" title="${a.description}">
                                                        <c:choose>
                                                            <c:when test="${not empty a.description}">${a.description}</c:when>
                                                            <c:otherwise><span style="color:#cbd5e1;font-style:italic;">Không có mô tả</span></c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.amount != null && a.amount > 0}">
                                                    <span class="amount-cell">
                                                        <fmt:formatNumber value="${a.amount}" type="number" groupingUsed="true"/> đ
                                                    </span>
                                                </c:when>
                                                <c:otherwise><span style="color:#cbd5e1;font-size:.8rem;">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="item-desc" title="${a.applyCondition}" style="max-width:180px;">
                                                <c:choose>
                                                    <c:when test="${not empty a.applyCondition}">${a.applyCondition}</c:when>
                                                    <c:otherwise><span style="color:#cbd5e1;font-style:italic;">—</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.status}">
                                                    <span class="badge-active"><i class="fas fa-circle" style="font-size:.5rem;"></i> Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-inactive"><i class="fas fa-circle" style="font-size:.5rem;"></i> Vô hiệu</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="action-group">
                                                <%-- View Detail --%>
                                                <a href="${pageContext.request.contextPath}/hr/allowance?action=detail&id=${a.allowanceId}"
                                                   class="action-btn btn-view" title="Xem chi tiết">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <%-- Edit (chỉ khi active) --%>
                                                <c:if test="${a.status}">
                                                    <button class="action-btn btn-edit"
                                                            onclick="openEditModal(${a.allowanceId},'${fn:escapeXml(a.allowanceName)}','${fn:escapeXml(a.description)}','${a.amount}','${fn:escapeXml(a.applyCondition)}')"
                                                            title="Chỉnh sửa">
                                                        <i class="fas fa-pen"></i>
                                                    </button>
                                                    <%-- Deactivate --%>
                                                    <button class="action-btn btn-deact"
                                                            onclick="openDeactModal(${a.allowanceId},'${fn:escapeXml(a.allowanceName)}')"
                                                            title="Vô hiệu hóa">
                                                        <i class="fas fa-ban"></i>
                                                    </button>
                                                </c:if>
                                                <%-- Activate --%>
                                                <c:if test="${!a.status}">
                                                    <a href="${pageContext.request.contextPath}/hr/allowance?action=activate&id=${a.allowanceId}"
                                                       class="action-btn btn-act" title="Kích hoạt lại"
                                                       onclick="return confirm('Kích hoạt lại phụ cấp này?')">
                                                        <i class="fas fa-redo"></i>
                                                    </a>
                                                </c:if>
                                            </div>
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

<!-- ════════════════ MODAL THÊM ════════════════ -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:var(--blue);"></i> Thêm Phụ Cấp Mới</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/allowance">
            <input type="hidden" name="action" value="add">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Tên Phụ Cấp <span style="color:#e11d48;">*</span></label>
                    <input type="text" name="allowanceName" class="form-control" placeholder="Phụ cấp ăn trưa..." required maxlength="100">
                </div>
                <div class="form-group">
                    <label class="form-label">Mức Tiền (VNĐ) <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="amount" class="form-control" placeholder="500000" min="0" step="1000" required>
                        <span class="input-suffix">VNĐ</span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Điều Kiện Hưởng</label>
                <input type="text" name="applyCondition" class="form-control" placeholder="Vd: Áp dụng cho tất cả nhân viên chính thức...">
            </div>
            <div class="form-group">
                <label class="form-label">Mô Tả</label>
                <textarea name="description" class="form-control" placeholder="Nhập mô tả chi tiết..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn-submit"><i class="fas fa-save" style="margin-right:6px;"></i>Lưu</button>
            </div>
        </form>
    </div>
</div>

<!-- ════════════════ MODAL SỬA ════════════════ -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-pen" style="color:var(--blue);"></i> Cập Nhật Phụ Cấp</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/allowance">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="editId">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Tên Phụ Cấp <span style="color:#e11d48;">*</span></label>
                    <input type="text" name="allowanceName" id="editName" class="form-control" required maxlength="100">
                </div>
                <div class="form-group">
                    <label class="form-label">Mức Tiền (VNĐ) <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="amount" id="editAmount" class="form-control" min="0" step="1000" required>
                        <span class="input-suffix">VNĐ</span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Điều Kiện Hưởng</label>
                <input type="text" name="applyCondition" id="editCondition" class="form-control">
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

<!-- ════════════════ MODAL VÔ HIỆU HÓA ════════════════ -->
<div class="modal-overlay" id="deactModal">
    <div class="modal-box confirm-modal-box">
        <div class="confirm-icon danger"><i class="fas fa-ban"></i></div>
        <div class="confirm-title">Vô hiệu hóa phụ cấp</div>
        <div class="confirm-body">Bạn có chắc muốn vô hiệu hóa phụ cấp<br><strong id="deactName"></strong>?<br><small style="color:#94a3b8;">Phụ cấp sẽ không còn được áp dụng. Bạn có thể kích hoạt lại sau.</small></div>
        <a href="#" id="deactLink" class="btn-danger" style="display:inline-block;text-decoration:none;margin-bottom:4px;">
            <i class="fas fa-ban" style="margin-right:6px;"></i>Vô Hiệu Hóa
        </a>
        <br>
        <button class="btn-cancel" onclick="closeModal('deactModal')" style="margin-top:8px;">Hủy</button>
    </div>
</div>

<script>
    const CTX = '${pageContext.request.contextPath}';

    function openAddModal() {
        document.getElementById('addModal').classList.add('show');
    }
    function openEditModal(id, name, desc, amount, condition) {
        document.getElementById('editId').value        = id;
        document.getElementById('editName').value      = name;
        document.getElementById('editDesc').value      = desc;
        document.getElementById('editAmount').value    = amount || '';
        document.getElementById('editCondition').value = condition || '';
        document.getElementById('editModal').classList.add('show');
    }
    function openDeactModal(id, name) {
        document.getElementById('deactName').textContent = name;
        document.getElementById('deactLink').href = CTX + '/hr/allowance?action=deactivate&id=' + id;
        document.getElementById('deactModal').classList.add('show');
    }
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }
    document.querySelectorAll('.modal-overlay').forEach(function(el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) el.classList.remove('show');
        });
    });

    var currentFilter = 'all';
    function filterByStatus(status, btn) {
        currentFilter = status;
        document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
        btn.classList.add('active');
        filterTable();
    }
    function filterTable() {
        var q = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('#allowanceTable tbody tr').forEach(function(row) {
            var matchStatus = currentFilter === 'all' || row.dataset.status === currentFilter;
            var matchText   = row.textContent.toLowerCase().includes(q);
            row.style.display = (matchStatus && matchText) ? '' : 'none';
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

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Bảo Hiểm" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --navy: #0a2540; --blue: #2b6cb0; --bg: #f0ede8;
        --surface: #fff; --border: #e2e8f0; --text: #0f172a; --muted: #64748b;
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
    .summary-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 16px; margin-bottom: 24px; }
    .summary-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 20px 22px; display: flex; align-items: center; gap: 16px; transition: transform .2s, box-shadow .2s; }
    .summary-card:hover { transform: translateY(-3px); box-shadow: 0 14px 30px rgba(10,37,64,.08); }
    .s-icon { width: 50px; height: 50px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
    .s-blue   { background: #eff6ff; color: #2b6cb0; }
    .s-green  { background: #f0fdf4; color: #16a34a; }
    .s-purple { background: #faf5ff; color: #7c3aed; }
    .s-amber  { background: #fffbeb; color: #d97706; }
    .s-label  { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); }
    .s-value  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.85rem; font-weight: 800; color: var(--navy); line-height: 1.1; }
    .s-sub    { font-size: .76rem; color: var(--muted); margin-top: 2px; }

    /* PANEL */
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px 28px; }
    .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); }

    /* FILTERS */
    .filter-area { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .search-box { position: relative; }
    .search-box input { padding: 8px 14px 8px 36px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; width: 230px; outline: none; font-family: 'Inter',sans-serif; transition: border .2s; }
    .search-box input:focus { border-color: var(--blue); }
    .search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .85rem; }
    .status-select { padding: 8px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; outline: none; background: var(--surface); font-family: 'Inter', sans-serif; cursor: pointer; }
    .status-select:focus { border-color: var(--blue); }

    /* TABLE */
    .data-table { width: 100%; border-collapse: collapse; }
    .data-table thead th { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); padding: 11px 16px; border-bottom: 2px solid var(--border); text-align: left; white-space: nowrap; }
    .data-table tbody td { padding: 12px 16px; font-size: .875rem; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
    .data-table tbody tr:last-child td { border-bottom: none; }
    .data-table tbody tr { transition: background .15s; }
    .data-table tbody tr:hover td { background: #f8fafc; }

    .item-name { font-weight: 700; color: var(--navy); display: flex; align-items: center; gap: 8px; }
    .item-icon { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: .85rem; flex-shrink: 0; background: #faf5ff; color: #7c3aed; }
    .code-badge { display: inline-block; background: #f1f5f9; color: #475569; font-size: .72rem; font-weight: 700; padding: 2px 8px; border-radius: 6px; letter-spacing: .5px; }

    /* RATE BADGES */
    .rate-badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: .82rem; }
    .rate-company  { background: #eff6ff; color: #2b6cb0; }
    .rate-employee { background: #faf5ff; color: #7c3aed; }
    .rate-total    { background: #f0fdf4; color: #16a34a; }

    .badge-active   { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    .badge-inactive { display: inline-flex; align-items: center; gap: 5px; background: #f1f5f9; color: #64748b; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }

    /* BUTTONS */
    .action-btn { background: none; border: none; cursor: pointer; padding: 6px 10px; border-radius: 6px; font-size: .9rem; transition: background .2s; display: inline-flex; align-items: center; justify-content: center; }
    .btn-view       { color: #0d9488; } .btn-view:hover       { background: #f0fdf4; }
    .btn-edit       { color: var(--blue); } .btn-edit:hover   { background: #eff6ff; }
    .btn-deactivate { color: #d97706; } .btn-deactivate:hover { background: #fffbeb; }
    .btn-activate   { color: #16a34a; } .btn-activate:hover   { background: #f0fdf4; }

    .btn-primary { background: var(--blue); color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: background .2s, transform .2s; font-family: 'Inter', sans-serif; }
    .btn-primary:hover { background: #1a4971; transform: translateY(-1px); }

    /* PAGINATION */
    .btn-page { background: var(--surface); border: 1px solid var(--border); border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; color: var(--muted); cursor: pointer; transition: all 0.2s; font-family: 'Inter', sans-serif; }
    .btn-page:hover:not(:disabled) { border-color: var(--blue); color: var(--blue); }
    .btn-page.active { background: var(--blue); border-color: var(--blue); color: white; }
    .btn-page:disabled { opacity: 0.5; cursor: not-allowed; }

    /* EMPTY */
    .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 16px; opacity: .3; display: block; }

    /* ALERTS */
    .alert { padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; font-size: .875rem; font-weight: 500; display: flex; align-items: center; gap: 10px; }
    .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .alert-danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    /* MODALS */
    .modal-overlay { display: none; position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,.5); backdrop-filter: blur(3px); }
    .modal-overlay.show { display: flex; align-items: center; justify-content: center; }
    .modal-box { background: var(--surface); padding: 28px 32px; width: 540px; border-radius: 14px; box-shadow: 0 20px 40px rgba(0,0,0,.15); position: relative; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; padding-bottom: 14px; border-bottom: 1px solid var(--border); position: sticky; top: 0; background: var(--surface); z-index: 1; }
    .modal-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.05rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 8px; }
    .modal-close  { background: none; border: none; font-size: 1.4rem; color: var(--muted); cursor: pointer; line-height: 1; padding: 0; }
    .modal-close:hover { color: var(--text); }
    .form-group { margin-bottom: 16px; }
    .form-label { display: block; font-size: .8rem; font-weight: 600; color: var(--muted); margin-bottom: 6px; text-transform: uppercase; letter-spacing: .5px; }
    .form-control { width: 100%; padding: 10px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .875rem; font-family: 'Inter', sans-serif; outline: none; transition: border .2s; color: var(--text); }
    .form-control:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(43,108,176,.12); }
    .form-control[readonly] { background: #f8fafc; cursor: default; }
    textarea.form-control { resize: vertical; min-height: 75px; }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .form-row-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px; }
    .input-group { position: relative; }
    .input-suffix { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .82rem; font-weight: 600; pointer-events: none; }
    .modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--border); }
    .btn-cancel { background: none; border: 1px solid var(--border); padding: 9px 18px; border-radius: 8px; font-size: .875rem; cursor: pointer; color: var(--muted); font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-cancel:hover { background: #f8fafc; }
    .btn-submit { background: var(--blue); color: #fff; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-submit:hover { background: #1a4971; }
    .hint-text { font-size: .75rem; color: var(--muted); margin-top: 4px; }

    /* DETAIL GRID */
    .detail-grid { display: grid; grid-template-columns: 160px 1fr; gap: 12px 16px; font-size: .9rem; }
    .detail-label { font-weight: 600; color: var(--muted); }
    .detail-value { font-weight: 500; color: var(--navy); }
    .detail-separator { grid-column: 1/-1; border: none; border-top: 1px solid var(--border); margin: 4px 0; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .summary-grid { grid-template-columns: 1fr 1fr; }
        .form-row, .form-row-3 { grid-template-columns: 1fr; }
    }
    @media (max-width:600px) {
        .summary-grid { grid-template-columns: 1fr; }
        .modal-box { width: 95%; padding: 20px; }
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
                    <div class="s-sub">tất cả trạng thái</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-green"><i class="fas fa-check-circle"></i></div>
                <div>
                    <div class="s-label">Đang Hoạt Động</div>
                    <div class="s-value">${activeCount}</div>
                    <div class="s-sub">loại bảo hiểm</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-purple"><i class="fas fa-building"></i></div>
                <div>
                    <div class="s-label">DN Đóng TB</div>
                    <div class="s-value"><fmt:formatNumber value="${avgCompanyRate}" pattern="0.##"/>%</div>
                    <div class="s-sub">tỷ lệ trung bình</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-amber"><i class="fas fa-user-tie"></i></div>
                <div>
                    <div class="s-label">NV Đóng TB</div>
                    <div class="s-value"><fmt:formatNumber value="${avgEmployeeRate}" pattern="0.##"/>%</div>
                    <div class="s-sub">tỷ lệ trung bình</div>
                </div>
            </div>
        </div>

        <!-- TABLE PANEL -->
        <div class="panel">
            <div class="panel-header">
                <h2 class="panel-title"><span class="dot"></span> Danh Sách Mức Đóng Bảo Hiểm</h2>
                <div class="filter-area">
                    <select id="statusFilter" class="status-select" onchange="filterTable()">
                        <option value="all">Tất cả trạng thái</option>
                        <option value="active" selected>Hoạt động</option>
                        <option value="inactive">Vô hiệu hóa</option>
                    </select>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Tìm mã, tên bảo hiểm..." oninput="filterTable()">
                    </div>
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
                                    <th>Mã BH</th>
                                    <th>Tên Loại Bảo Hiểm</th>
                                    <th>DN Đóng (%)</th>
                                    <th>NV Đóng (%)</th>
                                    <th>Tổng (%)</th>
                                    <th style="text-align:center;">Trạng Thái</th>
                                    <th style="text-align:center;">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="ir" items="${insuranceRateList}" varStatus="s">
                                    <fmt:formatDate value="${ir.createdAt}" pattern="dd/MM/yyyy HH:mm" var="fmtCreated"/>
                                    <fmt:formatDate value="${ir.updatedAt}" pattern="dd/MM/yyyy HH:mm" var="fmtUpdated"/>
                                    <fmt:formatDate value="${ir.effectiveFrom}" pattern="dd/MM/yyyy" var="fmtFrom"/>
                                    <fmt:formatDate value="${ir.effectiveTo}"   pattern="dd/MM/yyyy" var="fmtTo"/>
                                    <tr data-status="${ir.status ? 'active' : 'inactive'}">
                                        <td style="color:var(--muted);font-weight:600;" class="row-stt">${s.index + 1}</td>
                                        <td><span class="code-badge">${empty ir.insuranceCode ? '—' : ir.insuranceCode}</span></td>
                                        <td>
                                            <div class="item-name">
                                                <div class="item-icon"><i class="fas fa-shield-alt"></i></div>
                                                ${ir.insuranceName}
                                            </div>
                                        </td>
                                        <td><span class="rate-badge rate-company"><fmt:formatNumber value="${ir.companyRate}" pattern="0.##"/>%</span></td>
                                        <td><span class="rate-badge rate-employee"><fmt:formatNumber value="${ir.employeeRate}" pattern="0.##"/>%</span></td>
                                        <td><span class="rate-badge rate-total"><fmt:formatNumber value="${ir.companyRate + ir.employeeRate}" pattern="0.##"/>%</span></td>
                                        <td style="text-align:center;">
                                            <c:choose>
                                                <c:when test="${ir.status}">
                                                    <span class="badge-active"><i class="fas fa-circle" style="font-size:.45rem;"></i> Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-inactive"><i class="fas fa-circle" style="font-size:.45rem;"></i> Vô hiệu hóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center; white-space:nowrap;">
                                            <%-- VIEW --%>
                                            <button class="action-btn btn-view" title="Xem chi tiết"
                                                onclick="openViewModal(
                                                    '${ir.insuranceRateId}',
                                                    '${fn:escapeXml(ir.insuranceCode)}',
                                                    '${fn:escapeXml(ir.insuranceName)}',
                                                    '${ir.companyRate}','${ir.employeeRate}',
                                                    '${fn:escapeXml(ir.description)}',
                                                    '${fmtFrom}','${fmtTo}',
                                                    '${fmtCreated}','${fmtUpdated}',
                                                    ${ir.status})">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <%-- EDIT --%>
                                            <button class="action-btn btn-edit" title="Chỉnh sửa"
                                                onclick="openEditModal(
                                                    ${ir.insuranceRateId},
                                                    '${fn:escapeXml(ir.insuranceCode)}',
                                                    '${fn:escapeXml(ir.insuranceName)}',
                                                    '${ir.companyRate}','${ir.employeeRate}',
                                                    '${fn:escapeXml(ir.description)}',
                                                    '${ir.effectiveFrom}','${ir.effectiveTo}')">
                                                <i class="fas fa-pen"></i>
                                            </button>
                                            <%-- DEACTIVATE / ACTIVATE --%>
                                            <c:choose>
                                                <c:when test="${ir.status}">
                                                    <form method="post" action="${pageContext.request.contextPath}/hr/insurance-rate" style="display:inline;"
                                                          onsubmit="return confirm('Vô hiệu hóa bảo hiểm \'${fn:escapeXml(ir.insuranceName)}\'?');">
                                                        <input type="hidden" name="action" value="deactivate">
                                                        <input type="hidden" name="id" value="${ir.insuranceRateId}">
                                                        <button type="submit" class="action-btn btn-deactivate" title="Vô hiệu hóa">
                                                            <i class="fas fa-ban"></i>
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form method="post" action="${pageContext.request.contextPath}/hr/insurance-rate" style="display:inline;"
                                                          onsubmit="return confirm('Kích hoạt lại bảo hiểm \'${fn:escapeXml(ir.insuranceName)}\'?');">
                                                        <input type="hidden" name="action" value="activate">
                                                        <input type="hidden" name="id" value="${ir.insuranceRateId}">
                                                        <button type="submit" class="action-btn btn-activate" title="Kích hoạt">
                                                            <i class="fas fa-check-circle"></i>
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- PAGINATION -->
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding-top:20px; border-top:1px solid var(--border);">
                        <div style="font-size:.85rem; color:var(--muted);">
                            Hiển thị <span id="pageStart" style="font-weight:600;color:var(--navy);">0</span>
                            – <span id="pageEnd" style="font-weight:600;color:var(--navy);">0</span>
                            trong <span id="totalItems" style="font-weight:600;color:var(--navy);">0</span> mục
                        </div>
                        <div style="display:flex; gap:8px; align-items:center;">
                            <button class="btn-page" id="btnPrev" onclick="prevPage()"><i class="fas fa-chevron-left"></i></button>
                            <div id="pageNumbers" style="display:flex; gap:4px;"></div>
                            <button class="btn-page" id="btnNext" onclick="nextPage()"><i class="fas fa-chevron-right"></i></button>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<!-- ══ MODAL XEM CHI TIẾT ══ -->
<div class="modal-overlay" id="viewModal">
    <div class="modal-box" style="width:560px;">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-eye" style="color:var(--blue);"></i> Chi Tiết Mức Đóng Bảo Hiểm</h3>
            <button class="modal-close" onclick="closeModal('viewModal')">&times;</button>
        </div>
        <div class="detail-grid">
            <div class="detail-label">Mã bảo hiểm</div>
            <div class="detail-value"><span id="vCode" class="code-badge" style="font-size:.85rem;"></span></div>

            <div class="detail-label">Tên loại bảo hiểm</div>
            <div class="detail-value" id="vName" style="font-size:1rem;font-weight:700;color:var(--blue);"></div>

            <hr class="detail-separator">

            <div class="detail-label">DN đóng (%)</div>
            <div class="detail-value"><span id="vCompany" class="rate-badge rate-company"></span></div>

            <div class="detail-label">NV đóng (%)</div>
            <div class="detail-value"><span id="vEmployee" class="rate-badge rate-employee"></span></div>

            <div class="detail-label">Tổng tỷ lệ (%)</div>
            <div class="detail-value"><span id="vTotal" class="rate-badge rate-total" style="font-weight:800;"></span></div>

            <hr class="detail-separator">

            <div class="detail-label">Ngày bắt đầu</div>
            <div class="detail-value" id="vFrom"></div>

            <div class="detail-label">Ngày kết thúc</div>
            <div class="detail-value" id="vTo"></div>

            <div class="detail-label">Trạng thái</div>
            <div class="detail-value" id="vStatus"></div>

            <hr class="detail-separator">

            <div class="detail-label">Mô tả</div>
            <div style="background:#f8fafc;padding:10px 12px;border-radius:8px;border:1px solid var(--border);font-size:.875rem;white-space:pre-wrap;color:var(--text);grid-column:2;" id="vDesc"></div>

            <hr class="detail-separator">

            <div class="detail-label">Ngày tạo</div>
            <div class="detail-value" id="vCreated" style="color:var(--muted);"></div>

            <div class="detail-label">Cập nhật cuối</div>
            <div class="detail-value" id="vUpdated" style="color:var(--muted);"></div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-cancel" onclick="closeModal('viewModal')">Đóng</button>
        </div>
    </div>
</div>

<!-- ══ MODAL THÊM ══ -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:var(--blue);"></i> Thêm Mức Bảo Hiểm Mới</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/insurance-rate" onsubmit="return validateDateRange(this)">
            <input type="hidden" name="action" value="add">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Mã Bảo Hiểm <span style="color:#e11d48;">*</span></label>
                    <input type="text" name="insuranceCode" class="form-control" placeholder="VD: BHXH" required maxlength="20" style="text-transform:uppercase;">
                    <div class="hint-text">Mã viết tắt, không trùng</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tên Loại Bảo Hiểm <span style="color:#e11d48;">*</span></label>
                    <input type="text" name="insuranceName" class="form-control" placeholder="VD: Bảo hiểm xã hội" required maxlength="100">
                </div>
            </div>
            <div class="form-row-3">
                <div class="form-group">
                    <label class="form-label">Tỷ Lệ DN (%) <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="companyRate" id="addCompany" class="form-control" placeholder="0.00" step="0.01" min="0" max="100" required style="padding-right:34px;" oninput="calcAddTotal()">
                        <span class="input-suffix">%</span>
                    </div>
                    <div class="hint-text">Phần DN đóng góp</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tỷ Lệ NV (%) <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="employeeRate" id="addEmployee" class="form-control" placeholder="0.00" step="0.01" min="0" max="100" required style="padding-right:34px;" oninput="calcAddTotal()">
                        <span class="input-suffix">%</span>
                    </div>
                    <div class="hint-text">Phần NV phải đóng</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tổng Tỷ Lệ (%)</label>
                    <div class="input-group">
                        <input type="number" id="addTotal" class="form-control" readonly placeholder="0.00" style="padding-right:34px;background:#f8fafc;">
                        <span class="input-suffix">%</span>
                    </div>
                    <div class="hint-text">Tự động tính</div>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Ngày Bắt Đầu Áp Dụng</label>
                    <input type="date" name="effectiveFrom" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">Ngày Kết Thúc Áp Dụng</label>
                    <input type="date" name="effectiveTo" class="form-control">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Mô Tả</label>
                <textarea name="description" class="form-control" maxlength="255" placeholder="Mô tả chi tiết về loại bảo hiểm..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn-submit"><i class="fas fa-save" style="margin-right:6px;"></i>Lưu</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ MODAL SỬA ══ -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-pen" style="color:var(--blue);"></i> Cập Nhật Mức Bảo Hiểm</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/insurance-rate" onsubmit="return validateDateRange(this)">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="editId">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Mã Bảo Hiểm <span style="color:#e11d48;">*</span></label>
                    <input type="text" name="insuranceCode" id="editCode" class="form-control" required maxlength="20" style="text-transform:uppercase;">
                </div>
                <div class="form-group">
                    <label class="form-label">Tên Loại Bảo Hiểm <span style="color:#e11d48;">*</span></label>
                    <input type="text" name="insuranceName" id="editName" class="form-control" required maxlength="100">
                </div>
            </div>
            <div class="form-row-3">
                <div class="form-group">
                    <label class="form-label">Tỷ Lệ DN (%) <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="companyRate" id="editCompany" class="form-control" step="0.01" min="0" max="100" required style="padding-right:34px;" oninput="calcEditTotal()">
                        <span class="input-suffix">%</span>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tỷ Lệ NV (%) <span style="color:#e11d48;">*</span></label>
                    <div class="input-group">
                        <input type="number" name="employeeRate" id="editEmployee" class="form-control" step="0.01" min="0" max="100" required style="padding-right:34px;" oninput="calcEditTotal()">
                        <span class="input-suffix">%</span>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tổng Tỷ Lệ (%)</label>
                    <div class="input-group">
                        <input type="number" id="editTotal" class="form-control" readonly style="padding-right:34px;background:#f8fafc;">
                        <span class="input-suffix">%</span>
                    </div>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Ngày Bắt Đầu Áp Dụng</label>
                    <input type="date" name="effectiveFrom" id="editFrom" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">Ngày Kết Thúc Áp Dụng</label>
                    <input type="date" name="effectiveTo" id="editTo" class="form-control">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Mô Tả</label>
                <textarea name="description" id="editDesc" class="form-control"  maxlength="255" ></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Hủy</button>
                <button type="submit" class="btn-submit"><i class="fas fa-save" style="margin-right:6px;"></i>Cập Nhật</button>
            </div>
        </form>
    </div>
</div>

<script>
/* ─── Date validation helper ─── */
function validateDateRange(form) {
    var fromVal = form.querySelector('[name="effectiveFrom"]').value;
    var toVal = form.querySelector('[name="effectiveTo"]').value;
    if (fromVal && toVal) {
        var fromDate = new Date(fromVal);
        var toDate = new Date(toVal);
        if (fromDate > toDate) {
            alert('Ngày bắt đầu áp dụng không được lớn hơn ngày kết thúc áp dụng!');
            return false;
        }
    }
    return true;
}

/* ─── Modal helpers ─── */
function closeModal(id) { document.getElementById(id).classList.remove('show'); }
function openAddModal() { document.getElementById('addModal').classList.add('show'); }

function openEditModal(id, code, name, company, employee, desc, from, to) {
    document.getElementById('editId').value       = id;
    document.getElementById('editCode').value     = code;
    document.getElementById('editName').value     = name;
    document.getElementById('editCompany').value  = company;
    document.getElementById('editEmployee').value = employee;
    document.getElementById('editDesc').value     = desc;
    document.getElementById('editFrom').value     = from && from !== 'null' ? from : '';
    document.getElementById('editTo').value       = to   && to   !== 'null' ? to   : '';
    calcEditTotal();
    document.getElementById('editModal').classList.add('show');
}

function openViewModal(id, code, name, company, employee, desc, from, to, created, updated, active) {
    document.getElementById('vCode').textContent  = code || '—';
    document.getElementById('vName').textContent  = name;

    var c = parseFloat(company), e = parseFloat(employee);
    document.getElementById('vCompany').textContent  = c.toFixed(2).replace(/\.00$/, '') + '%';
    document.getElementById('vEmployee').textContent = e.toFixed(2).replace(/\.00$/, '') + '%';
    document.getElementById('vTotal').textContent    = (c + e).toFixed(2).replace(/\.00$/, '') + '%';

    document.getElementById('vFrom').textContent    = from    || '—';
    document.getElementById('vTo').textContent      = to      || '—';
    document.getElementById('vDesc').textContent    = desc    || '—';
    document.getElementById('vCreated').textContent = created || '—';
    document.getElementById('vUpdated').textContent = updated || '—';

    var statusEl = document.getElementById('vStatus');
    if (active == 'true' || active === true || active == 1) {
        statusEl.innerHTML = '<span class="badge-active"><i class="fas fa-circle" style="font-size:.45rem;"></i> Hoạt động</span>';
    } else {
        statusEl.innerHTML = '<span class="badge-inactive"><i class="fas fa-circle" style="font-size:.45rem;"></i> Vô hiệu hóa</span>';
    }
    document.getElementById('viewModal').classList.add('show');
}

document.querySelectorAll('.modal-overlay').forEach(function(el) {
    el.addEventListener('click', function(e) { if (e.target === el) el.classList.remove('show'); });
});

/* ─── Total rate auto-calc ─── */
function calcAddTotal() {
    var c = parseFloat(document.getElementById('addCompany').value) || 0;
    var e = parseFloat(document.getElementById('addEmployee').value) || 0;
    document.getElementById('addTotal').value = (c + e).toFixed(2);
}
function calcEditTotal() {
    var c = parseFloat(document.getElementById('editCompany').value) || 0;
    var e = parseFloat(document.getElementById('editEmployee').value) || 0;
    document.getElementById('editTotal').value = (c + e).toFixed(2);
}

/* ─── Pagination + Filter (all client-side) ─── */
var currentPage  = 1;
var itemsPerPage = 8;
var filteredRows = [];

function filterTable() {
    var query  = document.getElementById('searchInput').value.toLowerCase();
    var status = document.getElementById('statusFilter').value;
    var allRows = Array.from(document.querySelectorAll('#insuranceTable tbody tr:not(.empty-state-row)'));

    filteredRows = allRows.filter(function(row) {
        var matchSearch = row.textContent.toLowerCase().includes(query);
        var rowStatus   = row.getAttribute('data-status');
        var matchStatus = (status === 'all' || rowStatus === status);
        return matchSearch && matchStatus;
    });

    // Show/hide dynamic empty state
    var emptyRow = document.querySelector('#insuranceTable .dynamic-empty');
    if (filteredRows.length === 0) {
        if (!emptyRow) {
            var tr = document.createElement('tr');
            tr.className = 'dynamic-empty';
            tr.innerHTML = '<td colspan="8"><div class="empty-state"><i class="fas fa-search" style="font-size:2rem;margin-bottom:12px;"></i><p style="font-weight:600;color:var(--navy);">Không tìm thấy kết quả</p></div></td>';
            document.querySelector('#insuranceTable tbody').appendChild(tr);
        } else { emptyRow.style.display = ''; }
    } else {
        if (emptyRow) emptyRow.style.display = 'none';
    }

    currentPage = 1;
    updatePagination();
}

function updatePagination() {
    var totalPages = Math.max(1, Math.ceil(filteredRows.length / itemsPerPage));
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;

    var start = (currentPage - 1) * itemsPerPage;
    var end   = Math.min(start + itemsPerPage, filteredRows.length);

    // Hide all data rows then show current page
    document.querySelectorAll('#insuranceTable tbody tr:not(.dynamic-empty)').forEach(function(r) {
        r.style.display = 'none';
    });
    for (var i = start; i < end; i++) {
        filteredRows[i].style.display = '';
        var stt = filteredRows[i].querySelector('.row-stt');
        if (stt) stt.textContent = (i + 1 < 10 ? '0' : '') + (i + 1);
    }

    document.getElementById('pageStart').textContent  = filteredRows.length === 0 ? 0 : start + 1;
    document.getElementById('pageEnd').textContent    = end;
    document.getElementById('totalItems').textContent = filteredRows.length;

    // Page number buttons
    var html = '';
    for (var p = 1; p <= totalPages; p++) {
        html += p === currentPage
            ? '<button class="btn-page active">' + p + '</button>'
            : '<button class="btn-page" onclick="goToPage(' + p + ')">' + p + '</button>';
    }
    document.getElementById('pageNumbers').innerHTML = html;

    document.getElementById('btnPrev').disabled = (currentPage === 1);
    document.getElementById('btnNext').disabled = (currentPage === totalPages);
}

function goToPage(p)  { currentPage = p; updatePagination(); }
function prevPage()   { if (currentPage > 1) { currentPage--; updatePagination(); } }
function nextPage()   {
    var tp = Math.ceil(filteredRows.length / itemsPerPage);
    if (currentPage < tp) { currentPage++; updatePagination(); }
}

/* ─── Init on load ─── */
document.addEventListener('DOMContentLoaded', function() {
    filterTable(); // default: show "active" only
    // Auto-dismiss alerts after 4 s
    setTimeout(function() {
        document.querySelectorAll('.alert').forEach(function(el) {
            el.style.transition = 'opacity .5s';
            el.style.opacity = '0';
            setTimeout(function() { el.remove(); }, 500);
        });
    }, 4000);
});
</script>

<jsp:include page="../footer.jsp" />

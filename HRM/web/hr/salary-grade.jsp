<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Ngạch Lương" scope="request" />
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

    /* SUMMARY */
    .summary-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 24px; }
    .summary-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 20px 22px; display: flex; align-items: center; gap: 16px; transition: transform .2s, box-shadow .2s; }
    .summary-card:hover { transform: translateY(-3px); box-shadow: 0 14px 30px rgba(10,37,64,.08); }
    .s-icon { width: 50px; height: 50px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
    .s-blue   { background: #eff6ff; color: #2b6cb0; }
    .s-green  { background: #f0fdf4; color: #16a34a; }
    .s-orange { background: #fff7ed; color: #ea580c; }
    .s-red    { background: #fff1f2; color: #e11d48; }
    .s-label  { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); }
    .s-value  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.85rem; font-weight: 800; color: var(--navy); line-height: 1.1; }
    .s-sub    { font-size: .76rem; color: var(--muted); margin-top: 2px; }

    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px 28px; }
    .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); }

    /* FILTER BAR */
    .filter-bar { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .search-box { position: relative; }
    .search-box input { padding: 8px 14px 8px 36px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; width: 230px; outline: none; font-family: 'Inter',sans-serif; transition: border .2s; }
    .search-box input:focus { border-color: var(--blue); }
    .search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .85rem; }
    .filter-select { padding: 8px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; font-family: 'Inter',sans-serif; outline: none; color: var(--text); transition: border .2s; cursor: pointer; }
    .filter-select:focus { border-color: var(--blue); }

    /* TABLE */
    .data-table { width: 100%; border-collapse: collapse; }
    .data-table thead th { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); padding: 11px 16px; border-bottom: 2px solid var(--border); text-align: left; white-space: nowrap; }
    .data-table tbody td { padding: 13px 16px; font-size: .875rem; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
    .data-table tbody tr:last-child td { border-bottom: none; }
    .data-table tbody tr { transition: background .15s; }
    .data-table tbody tr:hover td { background: #f8fafc; }
    .data-table tbody tr.inactive-row td { opacity: .6; }

    .item-name { font-weight: 700; color: var(--navy); display: flex; align-items: center; gap: 8px; }
    .item-icon { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: .85rem; flex-shrink: 0; background: #fff7ed; color: #ea580c; }
    .item-desc { color: var(--muted); font-size: .82rem; max-width: 240px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    .badge-active   { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    .badge-inactive { display: inline-flex; align-items: center; gap: 5px; background: #f1f5f9; color: #64748b; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }

    .money-cell  { font-family: 'Be Vietnam Pro', sans-serif; font-weight: 700; color: var(--navy); white-space: nowrap; }
    .coeff-pill  { display: inline-block; background: #eff6ff; color: var(--blue); font-size: .8rem; font-weight: 700; padding: 3px 10px; border-radius: 6px; }

    .action-btn  { background: none; border: none; cursor: pointer; padding: 6px 9px; border-radius: 6px; font-size: .88rem; transition: background .2s; }
    .btn-detail  { color: #7c3aed; }
    .btn-detail:hover  { background: #f5f3ff; }
    .btn-edit    { color: var(--blue); }
    .btn-edit:hover    { background: #eff6ff; }
    .btn-deactivate { color: #e11d48; }
    .btn-deactivate:hover { background: #ffe4e6; }
    .btn-activate   { color: #16a34a; }
    .btn-activate:hover   { background: #dcfce7; }

    .btn-primary { background: var(--blue); color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: background .2s, transform .2s; font-family: 'Inter', sans-serif; }
    .btn-primary:hover { background: #1a4971; transform: translateY(-1px); }

    .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 16px; opacity: .3; display: block; }

    .alert { padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; font-size: .875rem; font-weight: 500; display: flex; align-items: center; gap: 10px; }
    .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .alert-danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    /* MODAL */
    .modal-overlay { display: none; position: fixed; inset: 0; z-index: 1050; background: rgba(0,0,0,.5); backdrop-filter: blur(3px); }
    .modal-overlay.show { display: flex; align-items: center; justify-content: center; }
    .modal-box { background: var(--surface); padding: 28px 32px; width: 520px; border-radius: 14px; box-shadow: 0 20px 40px rgba(0,0,0,.15); position: relative; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; padding-bottom: 14px; border-bottom: 1px solid var(--border); }
    .modal-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.05rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 8px; }
    .modal-close  { background: none; border: none; font-size: 1.4rem; color: var(--muted); cursor: pointer; line-height: 1; padding: 0; }
    .modal-close:hover { color: var(--text); }

    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .form-group { margin-bottom: 18px; }
    .form-label { display: block; font-size: .82rem; font-weight: 600; color: var(--muted); margin-bottom: 6px; text-transform: uppercase; letter-spacing: .5px; }
    .form-label span { color: #e11d48; }
    .form-control { width: 100%; padding: 10px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: .875rem; font-family: 'Inter', sans-serif; outline: none; transition: border .2s; color: var(--text); }
    .form-control:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(43,108,176,.12); }
    textarea.form-control { resize: vertical; min-height: 80px; }
    .input-hint { font-size: .75rem; color: var(--muted); margin-top: 4px; }

    .modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; padding-top: 18px; border-top: 1px solid var(--border); }
    .btn-cancel { background: none; border: 1px solid var(--border); padding: 9px 18px; border-radius: 8px; font-size: .875rem; cursor: pointer; color: var(--muted); font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-cancel:hover { background: #f8fafc; }
    .btn-submit { background: var(--blue); color: #fff; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-submit:hover { background: #1a4971; }

    .confirm-modal-box { width: 420px; text-align: center; }
    .confirm-icon { width: 64px; height: 64px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin: 0 auto 16px; }
    .confirm-icon-deact { background: #fff7ed; color: #ea580c; }
    .confirm-icon-act   { background: #dcfce7; color: #16a34a; }
    .confirm-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.1rem; font-weight: 800; color: var(--navy); margin-bottom: 8px; }
    .confirm-body  { color: var(--muted); font-size: .875rem; margin-bottom: 24px; line-height: 1.6; }
    .btn-warning   { background: #ea580c; color: #fff; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-warning:hover { background: #c2410c; }
    .btn-success-act { background: #16a34a; color: #fff; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; }
    .btn-success-act:hover { background: #15803d; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .summary-grid { grid-template-columns: 1fr 1fr; }
        .form-row { grid-template-columns: 1fr; }
    }
    @media (max-width:600px) {
        .summary-grid { grid-template-columns: 1fr; }
        .modal-box, .confirm-modal-box { width: 95%; padding: 20px; }
    }
</style>

<%-- Pre-compute counts in JSP --%>
<c:set var="totalCount"  value="0" />
<c:set var="activeCount" value="0" />
<c:forEach var="sg" items="${salaryGradeList}">
    <c:set var="totalCount" value="${totalCount + 1}" />
    <c:if test="${sg.status}"><c:set var="activeCount" value="${activeCount + 1}" /></c:if>
</c:forEach>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp" />

    <main class="page-main">

        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <h1><i class="fas fa-layer-group" style="color:var(--blue);margin-right:10px;"></i>Quản Lý Ngạch Lương</h1>
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i></a>
                    <i class="fas fa-chevron-right" style="font-size:.65rem;"></i>
                    <span>HR Manager</span>
                    <i class="fas fa-chevron-right" style="font-size:.65rem;"></i>
                    <span>Ngạch Lương</span>
                </div>
            </div>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Thêm Ngạch Lương
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
                <div class="s-icon s-blue"><i class="fas fa-layer-group"></i></div>
                <div>
                    <div class="s-label">Tổng Ngạch</div>
                    <div class="s-value">${totalCount}</div>
                    <div class="s-sub">ngạch lương</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-green"><i class="fas fa-check-circle"></i></div>
                <div>
                    <div class="s-label">Đang Hoạt Động</div>
                    <div class="s-value">${activeCount}</div>
                    <div class="s-sub">đang áp dụng</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-red"><i class="fas fa-ban"></i></div>
                <div>
                    <div class="s-label">Vô Hiệu Hóa</div>
                    <div class="s-value">${totalCount - activeCount}</div>
                    <div class="s-sub">không áp dụng</div>
                </div>
            </div>
        </div>

        <!-- TABLE PANEL -->
        <div class="panel">
            <div class="panel-header">
                <h2 class="panel-title">
                    <span class="dot"></span>
                    Danh Sách Ngạch Lương
                </h2>
                <form method="get" action="${pageContext.request.contextPath}/hr/salary-grade"
                      style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin:0;" class="filter-bar">
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" name="keyword" id="searchInput"
                               placeholder="Tìm tên ngạch lương..."
                               value="${keyword}" oninput="liveFilter()">
                    </div>
                    <select name="statusFilter" id="statusFilterSelect" class="filter-select"
                            onchange="this.form.submit()">
                        <option value="all"      ${empty statusFilter or statusFilter == 'all'      ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="active"   ${statusFilter == 'active'   ? 'selected' : ''}>Hoạt động</option>
                        <option value="inactive" ${statusFilter == 'inactive' ? 'selected' : ''}>Vô hiệu hóa</option>
                    </select>
                    <button type="submit" style="background:var(--blue);color:#fff;border:none;padding:8px 14px;border-radius:8px;font-size:.85rem;font-weight:600;cursor:pointer;font-family:'Inter',sans-serif;">
                        <i class="fas fa-search"></i>
                    </button>
                    <c:if test="${not empty keyword}">
                        <a href="${pageContext.request.contextPath}/hr/salary-grade?statusFilter=${not empty statusFilter ? statusFilter : 'all'}"
                           style="color:var(--muted);font-size:.85rem;text-decoration:none;padding:4px 6px;" title="Xóa tìm kiếm">
                            <i class="fas fa-times-circle"></i>
                        </a>
                    </c:if>
                </form>
            </div>

            <c:choose>
                <c:when test="${empty salaryGradeList}">
                    <div class="empty-state">
                        <i class="fas fa-${not empty keyword ? 'search' : 'inbox'}"></i>
                        <c:choose>
                            <c:when test="${not empty keyword}">
                                <p style="font-size:1rem;font-weight:600;color:var(--navy);margin-bottom:6px;">Không tìm thấy kết quả cho "<strong>${keyword}</strong>"</p>
                                <p style="font-size:.85rem;"><a href="${pageContext.request.contextPath}/hr/salary-grade" style="color:var(--blue);">Xóa bộ lọc</a> để xem tất cả.</p>
                            </c:when>
                            <c:otherwise>
                                <p style="font-size:1rem;font-weight:600;color:var(--navy);margin-bottom:6px;">Chưa có ngạch lương nào</p>
                                <p style="font-size:.85rem;">Nhấn <strong>Thêm Ngạch Lương</strong> để bắt đầu.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x:auto;">
                        <table class="data-table" id="salaryGradeTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Tên Ngạch Lương</th>
                                    <th>Lương Cơ Bản</th>
                                    <th>Hệ Số</th>
                                    <th>Lương Thực Tế</th>
                                    <th>Mô Tả</th>
                                    <th>Trạng Thái</th>
                                    <th style="text-align:center;">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="sg" items="${salaryGradeList}" varStatus="s">
                                    <tr class="${sg.status ? '' : 'inactive-row'}"
                                        data-status="${sg.status ? 'active' : 'inactive'}">
                                        <td style="color:var(--muted);font-weight:600;">${s.index + 1}</td>
                                        <td>
                                            <div class="item-name">
                                                <div class="item-icon"><i class="fas fa-layer-group"></i></div>
                                                <div>
                                                    <div>${fn:escapeXml(sg.gradeName)}</div>
                                                    <div style="font-size:.73rem;color:var(--muted);font-weight:400;">ID: ${sg.salaryGradeId}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="money-cell">
                                            <fmt:formatNumber value="${sg.baseSalary}" type="number" groupingUsed="true"/> ₫
                                        </td>
                                        <td>
                                            <span class="coeff-pill">× <fmt:formatNumber value="${sg.coefficient}" maxFractionDigits="2"/></span>
                                        </td>
                                        <td class="money-cell" style="color:#16a34a;">
                                            <fmt:formatNumber value="${sg.baseSalary * sg.coefficient}" type="number" groupingUsed="true"/> ₫
                                        </td>
                                        <td>
                                            <div class="item-desc" title="${fn:escapeXml(sg.description)}">
                                                <c:choose>
                                                    <c:when test="${not empty sg.description}">${fn:escapeXml(sg.description)}</c:when>
                                                    <c:otherwise><span style="color:#cbd5e1;font-style:italic;">Không có mô tả</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${sg.status}">
                                                    <span class="badge-active"><i class="fas fa-circle" style="font-size:.5rem;"></i> Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-inactive"><i class="fas fa-circle" style="font-size:.5rem;"></i> Vô hiệu</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center; white-space:nowrap;">
                                            <%-- View Detail --%>
                                            <button class="action-btn btn-detail" title="Xem chi tiết"
                                                    onclick="openDetailModal(
                                                        ${sg.salaryGradeId},
                                                        '${fn:escapeXml(sg.gradeName)}',
                                                        '${sg.baseSalary}',
                                                        '${sg.coefficient}',
                                                        '${fn:escapeXml(sg.description)}',
                                                        '${sg.status}')">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <%-- Edit --%>
                                            <button class="action-btn btn-edit"
                                                    onclick="openEditModal(${sg.salaryGradeId},
                                                                          '${fn:escapeXml(sg.gradeName)}',
                                                                          '${sg.baseSalary}',
                                                                          '${sg.coefficient}',
                                                                          '${fn:escapeXml(sg.description)}')"
                                                    title="Chỉnh sửa" ${sg.status ? '' : 'disabled style="opacity:.4;cursor:not-allowed;"'}>
                                                <i class="fas fa-pen"></i>
                                            </button>
                                            <%-- Deactivate / Activate --%>
                                            <c:choose>
                                                <c:when test="${sg.status}">
                                                    <button class="action-btn btn-deactivate"
                                                            onclick="openDeactivateModal(${sg.salaryGradeId}, '${fn:escapeXml(sg.gradeName)}')"
                                                            title="Vô hiệu hóa">
                                                        <i class="fas fa-ban"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="action-btn btn-activate"
                                                            onclick="openActivateModal(${sg.salaryGradeId}, '${fn:escapeXml(sg.gradeName)}')"
                                                            title="Kích hoạt lại">
                                                        <i class="fas fa-redo"></i>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div id="noResults" style="display:none;" class="empty-state">
                        <i class="fas fa-search"></i>
                        <p style="font-size:.95rem;font-weight:600;color:var(--navy);">Không tìm thấy kết quả</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<!-- ═════════════════════ MODAL XEM CHI TIẾT ═════════════════════ -->
<div class="modal-overlay" id="detailModal">
    <div class="modal-box" style="width:560px;">
        <div class="modal-header" style="background:linear-gradient(135deg,#0a2540,#2b6cb0);border-radius:10px 10px 0 0;margin:-28px -32px 22px;padding:24px 28px;">
            <div style="display:flex;align-items:center;gap:14px;">
                <div style="width:52px;height:52px;background:rgba(255,255,255,.18);border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:#fff;flex-shrink:0;">
                    <i class="fas fa-layer-group"></i>
                </div>
                <div>
                    <h3 class="modal-title" id="detailName" style="color:#fff;margin:0 0 4px;"></h3>
                    <span id="detailIdBadge" style="font-size:.72rem;font-weight:600;background:rgba(255,255,255,.18);color:rgba(255,255,255,.9);padding:2px 10px;border-radius:20px;"></span>
                    <span id="detailStatusBadge" style="margin-left:6px;font-size:.72rem;font-weight:700;padding:2px 10px;border-radius:20px;"></span>
                </div>
            </div>
            <button class="modal-close" onclick="closeModal('detailModal')" style="color:rgba(255,255,255,.8);">&times;</button>
        </div>

        <%-- Lương thực tế highlight --%>
        <div style="background:linear-gradient(135deg,#f0fdf4,#dcfce7);border:1px solid #bbf7d0;border-radius:12px;padding:16px 20px;margin-bottom:22px;display:flex;align-items:center;gap:14px;">
            <div style="width:44px;height:44px;background:#16a34a;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;color:#fff;flex-shrink:0;">
                <i class="fas fa-money-bill-wave"></i>
            </div>
            <div>
                <div style="font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:#16a34a;margin-bottom:2px;">Lương thực tế</div>
                <div id="detailNetSalary" style="font-family:'Be Vietnam Pro',sans-serif;font-size:1.6rem;font-weight:800;color:#15803d;line-height:1;"></div>
            </div>
        </div>

        <%-- Grid thông tin --%>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:20px;">
            <div style="background:#f8fafc;border-radius:10px;padding:14px 16px;">
                <div style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--muted);margin-bottom:5px;"><i class="fas fa-coins" style="margin-right:4px;"></i>Lương cơ bản</div>
                <div id="detailBaseSalary" style="font-family:'Be Vietnam Pro',sans-serif;font-weight:700;color:var(--navy);font-size:.95rem;"></div>
            </div>
            <div style="background:#f8fafc;border-radius:10px;padding:14px 16px;">
                <div style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--muted);margin-bottom:5px;"><i class="fas fa-times" style="margin-right:4px;"></i>Hệ số lương</div>
                <div id="detailCoefficient" style="font-family:'Be Vietnam Pro',sans-serif;font-weight:700;color:var(--blue);font-size:.95rem;"></div>
            </div>
            <div style="background:#f8fafc;border-radius:10px;padding:14px 16px;grid-column:1/-1;">
                <div style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--muted);margin-bottom:5px;"><i class="fas fa-align-left" style="margin-right:4px;"></i>Mô tả</div>
                <div id="detailDesc" style="font-size:.875rem;color:var(--navy);line-height:1.6;"></div>
            </div>
        </div>

        <%-- Công thức tính --%>
        <div style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:10px;padding:12px 16px;margin-bottom:20px;display:flex;align-items:center;justify-content:center;gap:10px;flex-wrap:wrap;">
            <span id="detailFormulaBase" style="font-family:'Be Vietnam Pro',sans-serif;font-weight:700;color:var(--navy);"></span>
            <span style="color:var(--muted);">×</span>
            <span id="detailFormulaCoeff" style="font-family:'Be Vietnam Pro',sans-serif;font-weight:700;color:var(--blue);"></span>
            <span style="color:var(--muted);">=</span>
            <span id="detailFormulaNet" style="font-family:'Be Vietnam Pro',sans-serif;font-weight:800;color:#16a34a;font-size:1.05rem;"></span>
        </div>

        <div class="modal-footer" style="margin-top:0;">
            <button type="button" class="btn-cancel" onclick="closeModal('detailModal')">Đóng</button>
            <button type="button" id="detailEditBtn" class="btn-submit"
                    onclick="closeModal('detailModal'); setTimeout(function(){ openEditFromDetail(); }, 150);">
                <i class="fas fa-pen" style="margin-right:6px;"></i>Chỉnh sửa
            </button>
        </div>
    </div>
</div>

<!-- ═════════════════════ MODAL THÊM MỚI ═════════════════════ -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:var(--blue);"></i> Thêm Ngạch Lương Mới</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/salary-grade" id="addForm">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label class="form-label">Tên Ngạch Lương <span>*</span></label>
                <input type="text" name="gradeName" class="form-control" placeholder="Ví dụ: Ngạch chuyên viên" required maxlength="100">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Lương Cơ Bản (₫) <span>*</span></label>
                    <input type="number" name="baseSalary" class="form-control" placeholder="Ví dụ: 2000000" required min="1" step="1000">
                    <div class="input-hint">Mức lương tối thiểu theo quy định</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Hệ Số Lương <span>*</span></label>
                    <input type="number" name="coefficient" class="form-control" placeholder="Ví dụ: 2.34" required min="0.01" step="0.01">
                    <div class="input-hint">Hệ số nhân với lương cơ bản</div>
                </div>
            </div>
            <div class="form-group" style="background:#f8fafc;border-radius:8px;padding:12px;border:1px solid var(--border);">
                <div style="font-size:.78rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:6px;">Lương Thực Tế (Xem trước)</div>
                <div id="addPreview" style="font-family:'Be Vietnam Pro',sans-serif;font-size:1.3rem;font-weight:800;color:#16a34a;">— ₫</div>
            </div>
            <div class="form-group">
                <label class="form-label">Mô Tả</label>
                <textarea name="description" class="form-control" placeholder="Mô tả về ngạch lương này..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn-submit"><i class="fas fa-save" style="margin-right:6px;"></i>Lưu</button>
            </div>
        </form>
    </div>
</div>

<!-- ═════════════════════ MODAL CẬP NHẬT ═════════════════════ -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-pen" style="color:var(--blue);"></i> Cập Nhật Ngạch Lương</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/salary-grade" id="editForm">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="editId">
            <div class="form-group">
                <label class="form-label">Tên Ngạch Lương <span>*</span></label>
                <input type="text" name="gradeName" id="editGradeName" class="form-control" required maxlength="100">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Lương Cơ Bản (₫) <span>*</span></label>
                    <input type="number" name="baseSalary" id="editBaseSalary" class="form-control" required min="1" step="1000">
                </div>
                <div class="form-group">
                    <label class="form-label">Hệ Số Lương <span>*</span></label>
                    <input type="number" name="coefficient" id="editCoefficient" class="form-control" required min="0.01" step="0.01">
                </div>
            </div>
            <div class="form-group" style="background:#f8fafc;border-radius:8px;padding:12px;border:1px solid var(--border);">
                <div style="font-size:.78rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:6px;">Lương Thực Tế (Xem trước)</div>
                <div id="editPreview" style="font-family:'Be Vietnam Pro',sans-serif;font-size:1.3rem;font-weight:800;color:#16a34a;">— ₫</div>
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

<!-- ═════════════════════ MODAL VÔ HIỆU HÓA ═════════════════════ -->
<div class="modal-overlay" id="deactivateModal">
    <div class="modal-box confirm-modal-box">
        <div class="confirm-icon confirm-icon-deact"><i class="fas fa-ban"></i></div>
        <div class="confirm-title">Vô hiệu hóa ngạch lương</div>
        <div class="confirm-body">
            Bạn có chắc muốn vô hiệu hóa ngạch lương<br>
            <strong id="deactivateName"></strong>?<br><br>
            Ngạch lương sẽ không còn được áp dụng cho nhân viên mới.<br>
            Bạn có thể kích hoạt lại bất cứ lúc nào.
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/salary-grade">
            <input type="hidden" name="action" value="deactivate">
            <input type="hidden" name="id" id="deactivateId">
            <div style="display:flex;justify-content:center;gap:12px;">
                <button type="button" class="btn-cancel" onclick="closeModal('deactivateModal')">Hủy</button>
                <button type="submit" class="btn-warning"><i class="fas fa-ban" style="margin-right:6px;"></i>Vô hiệu hóa</button>
            </div>
        </form>
    </div>
</div>

<!-- ═════════════════════ MODAL KÍCH HOẠT LẠI ═════════════════════ -->
<div class="modal-overlay" id="activateModal">
    <div class="modal-box confirm-modal-box">
        <div class="confirm-icon confirm-icon-act"><i class="fas fa-redo"></i></div>
        <div class="confirm-title">Kích hoạt lại ngạch lương</div>
        <div class="confirm-body">
            Bạn có muốn kích hoạt lại ngạch lương<br>
            <strong id="activateName"></strong>?<br><br>
            Ngạch lương sẽ được áp dụng trở lại cho nhân viên.
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/salary-grade">
            <input type="hidden" name="action" value="activate">
            <input type="hidden" name="id" id="activateId">
            <div style="display:flex;justify-content:center;gap:12px;">
                <button type="button" class="btn-cancel" onclick="closeModal('activateModal')">Hủy</button>
                <button type="submit" class="btn-success-act"><i class="fas fa-redo" style="margin-right:6px;"></i>Kích hoạt</button>
            </div>
        </form>
    </div>
</div>

<script>
    // ── Detail Modal ─────────────────────────────────────────────────────
    var _detailData = {};
    function openDetailModal(id, gradeName, baseSalary, coefficient, desc, status) {
        _detailData = { id: id, gradeName: gradeName, baseSalary: parseFloat(baseSalary), coefficient: parseFloat(coefficient), desc: desc, status: status === 'true' };
        var fmt = function(n){ return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + ' ₫'; };
        var net = _detailData.baseSalary * _detailData.coefficient;

        document.getElementById('detailName').textContent       = gradeName;
        document.getElementById('detailIdBadge').textContent    = '# ID: ' + id;
        document.getElementById('detailBaseSalary').textContent = fmt(_detailData.baseSalary);
        document.getElementById('detailCoefficient').textContent= '× ' + coefficient;
        document.getElementById('detailNetSalary').textContent  = fmt(net);
        document.getElementById('detailDesc').textContent       = desc || 'Chưa có mô tả';
        document.getElementById('detailDesc').style.fontStyle   = desc ? 'normal' : 'italic';
        document.getElementById('detailDesc').style.color       = desc ? 'var(--navy)' : '#94a3b8';
        document.getElementById('detailFormulaBase').textContent  = fmt(_detailData.baseSalary);
        document.getElementById('detailFormulaCoeff').textContent = coefficient;
        document.getElementById('detailFormulaNet').textContent   = fmt(net);

        var badge = document.getElementById('detailStatusBadge');
        if (_detailData.status) {
            badge.textContent = '● Đang hoạt động';
            badge.style.background = 'rgba(22,163,74,.25)';
            badge.style.color = '#bbf7d0';
        } else {
            badge.textContent = '● Đã vô hiệu';
            badge.style.background = 'rgba(255,255,255,.15)';
            badge.style.color = 'rgba(255,255,255,.65)';
        }

        var editBtn = document.getElementById('detailEditBtn');
        editBtn.style.display = _detailData.status ? 'inline-flex' : 'none';

        document.getElementById('detailModal').classList.add('show');
    }
    function openEditFromDetail() {
        openEditModal(_detailData.id, _detailData.gradeName, _detailData.baseSalary, _detailData.coefficient, _detailData.desc);
    }

    // ── Modal helpers ────────────────────────────────────────────────────
    function openAddModal() {
        document.getElementById('addModal').classList.add('show');
    }
    function openEditModal(id, gradeName, baseSalary, coefficient, desc) {
        document.getElementById('editId').value          = id;
        document.getElementById('editGradeName').value   = gradeName;
        document.getElementById('editBaseSalary').value  = baseSalary;
        document.getElementById('editCoefficient').value = coefficient;
        document.getElementById('editDesc').value        = desc;
        updatePreview('edit');
        document.getElementById('editModal').classList.add('show');
    }
    function openDeactivateModal(id, name) {
        document.getElementById('deactivateId').textContent   = id;
        document.getElementById('deactivateId').value         = id;
        document.getElementById('deactivateName').textContent = name;
        document.getElementById('deactivateModal').classList.add('show');
    }
    function openActivateModal(id, name) {
        document.getElementById('activateId').value         = id;
        document.getElementById('activateName').textContent = name;
        document.getElementById('activateModal').classList.add('show');
    }
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }

    // Close on backdrop click
    document.querySelectorAll('.modal-overlay').forEach(function(el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) el.classList.remove('show');
        });
    });

    // ── Salary preview calculator ────────────────────────────────────────
    function updatePreview(prefix) {
        var base  = parseFloat(document.getElementById(prefix + 'BaseSalary').value)  || 0;
        var coeff = parseFloat(document.getElementById(prefix + 'Coefficient').value) || 0;
        var total = base * coeff;
        var el = document.getElementById(prefix + 'Preview');
        el.textContent = total > 0
            ? new Intl.NumberFormat('vi-VN').format(Math.round(total)) + ' ₫'
            : '— ₫';
    }

    document.getElementById('addForm').querySelector('[name="baseSalary"]').addEventListener('input', function(){ updatePreview('add'); });
    document.getElementById('addForm').querySelector('[name="coefficient"]').addEventListener('input', function(){ updatePreview('add'); });
    document.getElementById('editBaseSalary').addEventListener('input',  function(){ updatePreview('edit'); });
    document.getElementById('editCoefficient').addEventListener('input', function(){ updatePreview('edit'); });

    // Live filter nhanh trên client (thêm vào kết quả đã lọc server-side)
    function liveFilter() {
        var q = document.getElementById('searchInput').value.toLowerCase();
        var visible = 0;
        document.querySelectorAll('#salaryGradeTable tbody tr').forEach(function(row) {
            var show = row.textContent.toLowerCase().includes(q);
            row.style.display = show ? '' : 'none';
            if (show) visible++;
        });
        var noResults = document.getElementById('noResults');
        if (noResults) noResults.style.display = (visible === 0) ? 'block' : 'none';
    }

    // ── Auto-dismiss alerts ──────────────────────────────────────────────
    setTimeout(function() {
        document.querySelectorAll('.alert').forEach(function(el) {
            el.style.transition = 'opacity .5s';
            el.style.opacity = '0';
            setTimeout(function() { el.remove(); }, 500);
        });
    }, 4000);
</script>

<jsp:include page="../footer.jsp" />

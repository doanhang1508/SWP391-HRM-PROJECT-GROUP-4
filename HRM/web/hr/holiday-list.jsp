<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Ngày Nghỉ Lễ" scope="request" />
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
    .s-orange{background:#fff7ed;color:#ea580c;} 
    .s-purple{background:#faf5ff;color:#7c3aed;}
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
    .badge-solar { display: inline-flex; align-items: center; gap: 4px; background: #fff7ed; color: #ea580c; font-size: .75rem; font-weight: 700; padding: 3px 10px; border-radius: 20px; }
    .badge-lunar { display: inline-flex; align-items: center; gap: 4px; background: #faf5ff; color: #7c3aed; font-size: .75rem; font-weight: 700; padding: 3px 10px; border-radius: 20px; }
    .badge-ot { display: inline-flex; align-items: center; gap: 4px; background: #fdf2f8; color: #db2777; font-size: .75rem; font-weight: 700; padding: 3px 10px; border-radius: 20px; }
    .badge-active { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    .badge-inactive { display: inline-flex; align-items: center; gap: 5px; background: #f1f5f9; color: #64748b; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    
    /* BUTTONS */
    .action-btn { background: none; border: none; cursor: pointer; padding: 6px 10px; border-radius: 6px; font-size: .9rem; transition: background .2s; display: inline-flex; align-items: center; justify-content: center; }
    .btn-edit { color: var(--blue); } .btn-edit:hover { background: #eff6ff; }
    .btn-deactivate { color: #d97706; } .btn-deactivate:hover { background: #fffbeb; }
    .btn-activate { color: #16a34a; } .btn-activate:hover { background: #f0fdf4; }
    .btn-delete { color: #e11d48; } .btn-delete:hover { background: #ffe4e6; }
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
        <jsp:param name="activeMenu" value="holiday" />
    </jsp:include>

    <div class="page-main">
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <span>Ngày nghỉ lễ</span>
                </div>
                <h1><i class="fas fa-calendar-day" style="color:var(--blue);margin-right:10px;font-size:1.3rem;"></i>Quản Lý Ngày Nghỉ Lễ</h1>
            </div>
            <div style="display: flex; gap: 12px; align-items: center;">
                <form action="${pageContext.request.contextPath}/hr/holiday" method="GET" id="yearForm" style="margin:0;">
                    <select name="year" class="status-select" onchange="document.getElementById('yearForm').submit()" style="font-weight: 600;">
                        <c:forEach items="${availableYears}" var="y">
                            <option value="${y}" ${selectedYear == y ? 'selected' : ''}>Năm ${y}</option>
                        </c:forEach>
                    </select>
                </form>
                <form action="${pageContext.request.contextPath}/hr/holiday" method="POST" style="margin:0;" onsubmit="return confirm('Hệ thống sẽ tự động sinh và bổ sung các ngày lễ còn thiếu cho năm ${selectedYear}. Bạn có chắc chắn không?');">
                    <input type="hidden" name="action" value="generate">
                    <input type="hidden" name="year" value="${selectedYear}">
                    <button type="submit" class="btn-primary" style="background:#16a34a;">
                        <i class="fas fa-magic"></i> Sinh lịch nghỉ năm ${selectedYear}
                    </button>
                </form>
                <button class="btn-primary" onclick="openAddModal()">
                    <i class="fas fa-plus"></i> Thêm ngày lễ
                </button>
            </div>
        </div>

        <!-- JSTL Tính toán Summary Cards -->
        <c:set var="totalSolar" value="0"/>
        <c:set var="totalLunar" value="0"/>
        <c:forEach items="${holidayList}" var="h">
            <c:if test="${h.status}">
                <c:choose>
                    <c:when test="${h.calendarType eq 'SOLAR'}"><c:set var="totalSolar" value="${totalSolar + 1}"/></c:when>
                    <c:when test="${h.calendarType eq 'LUNAR'}"><c:set var="totalLunar" value="${totalLunar + 1}"/></c:when>
                </c:choose>
            </c:if>
        </c:forEach>

        <c:if test="${not empty sessionScope.successMsg}">
            <div style="background-color: #dcfce7; color: #166534; padding: 12px 16px; border-radius: 8px; margin-bottom: 24px; font-size: 0.9rem; font-weight: 500; display: flex; align-items: center; gap: 8px;">
                <i class="fas fa-check-circle"></i>
                ${sessionScope.successMsg}
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>

        <div class="summary-grid">
            <div class="summary-card">
                <div class="s-icon s-blue"><i class="fas fa-calendar-check"></i></div>
                <div>
                    <div class="s-label">Tổng ngày lễ hoạt động</div>
                    <div class="s-value" id="activeTypesCount">${totalSolar + totalLunar}</div>
                    <div class="s-sub">Trong năm nay</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-orange"><i class="fas fa-sun"></i></div>
                <div>
                    <div class="s-label">Dương lịch</div>
                    <div class="s-value">${totalSolar}</div>
                    <div class="s-sub">Cố định hàng năm</div>
                </div>
            </div>
            <div class="summary-card">
                <div class="s-icon s-purple"><i class="fas fa-moon"></i></div>
                <div>
                    <div class="s-label">Âm lịch</div>
                    <div class="s-value">${totalLunar}</div>
                    <div class="s-sub">Cần cập nhật ngày thực tế</div>
                </div>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title"><span class="dot"></span> Danh Sách Ngày Nghỉ Lễ</h3>
                <div class="filter-actions">
                    <select id="statusFilter" class="status-select" onchange="filterTable()">
                        <option value="all">Tất cả trạng thái</option>
                        <option value="active" selected>Hoạt động</option>
                        <option value="inactive">Vô hiệu hóa</option>
                    </select>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Tìm tên ngày lễ..." oninput="filterTable()">
                    </div>
                </div>
            </div>
            <div style="overflow-x:auto;">
                <table class="data-table" id="mainTable">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Tên Ngày Lễ</th>
                            <th>Ngày Dương Lịch</th>
                            <th style="text-align:center;">Loại Lịch</th>
                            <th style="text-align:center;">Hệ số OT</th>
                            <th style="text-align:center;">Nguồn</th>
                            <th style="text-align:center;">Trạng thái</th>
                            <th style="text-align:center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty holidayList}">
                                <tr class="empty-state-row"><td colspan="7">
                                    <div class="empty-state">
                                        <i class="fas fa-calendar-times"></i>
                                        <p style="font-weight:600;color:var(--navy);">Chưa có ngày lễ nào</p>
                                        <p style="font-size:.85rem;">Nhấn "Thêm ngày lễ" để bắt đầu</p>
                                    </div>
                                </td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${holidayList}" var="h" varStatus="st">
                                    <fmt:formatDate value="${h.holidayDate}" pattern="dd/MM/yyyy" var="formattedDate"/>
                                    <tr data-status="${h.status ? 'active' : 'inactive'}">
                                        <td style="color:var(--muted);font-weight:600;" class="row-stt">${st.count < 10 ? '0' : ''}${st.count}</td>
                                        <td>
                                            <div class="item-name">
                                                <div class="item-icon ic-${(st.index % 5) + 1}"><i class="fas fa-gift"></i></div>
                                                ${h.holidayName}
                                            </div>
                                        </td>
                                        <td style="font-weight: 600; color: var(--navy);">
                                            ${formattedDate}
                                        </td>
                                        <td style="text-align:center;">
                                            <c:choose>
                                                <c:when test="${h.calendarType eq 'SOLAR'}">
                                                    <span class="badge-solar"><i class="fas fa-sun"></i> Dương lịch</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-lunar"><i class="fas fa-moon"></i> Âm lịch</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center;">
                                            <span class="badge-ot" title="Hệ số lương làm thêm giờ">
                                                x${h.otMultiplier}
                                            </span>
                                        </td>
                                        <td style="text-align:center;">
                                            <c:choose>
                                                <c:when test="${h.source eq 'AUTO'}">
                                                    <span style="font-size:.75rem; color:#64748b; background:#f1f5f9; padding:3px 8px; border-radius:12px; font-weight:600;"><i class="fas fa-robot"></i> Tự động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="font-size:.75rem; color:#0f766e; background:#ccfbf1; padding:3px 8px; border-radius:12px; font-weight:600;"><i class="fas fa-user-edit"></i> Thủ công</span>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${h.makeupDay}">
                                                <div style="margin-top: 4px;">
                                                    <span style="font-size:.7rem; color:#b45309; background:#fef3c7; padding:2px 6px; border-radius:8px; font-weight:600;">Nghỉ bù</span>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td style="text-align:center;">
                                            <c:choose>
                                                <c:when test="${h.status}">
                                                    <span class="badge-active"><i class="fas fa-circle" style="font-size:.45rem;"></i> Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-inactive"><i class="fas fa-circle" style="font-size:.45rem;"></i> Vô hiệu hóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center; white-space: nowrap;">
                                            <button class="action-btn btn-edit" title="Chỉnh sửa" 
                                                    onclick="openEditModal('${h.holidayId}','${fn:escapeXml(h.holidayName)}','${h.holidayDate}','${h.calendarType}','${h.otMultiplier}','${fn:escapeXml(h.description)}')">
                                                <i class="fas fa-pen"></i>
                                            </button>
                                            <c:choose>
                                                <c:when test="${h.status}">
                                                    <form action="${pageContext.request.contextPath}/hr/holiday" method="POST" style="display:inline;" onsubmit="return confirm('Vô hiệu hóa ngày lễ \'${fn:escapeXml(h.holidayName)}\'?');">
                                                        <input type="hidden" name="action" value="deactivate">
                                                        <input type="hidden" name="id" value="${h.holidayId}">
                                                        <button type="submit" class="action-btn btn-deactivate" title="Vô hiệu hóa">
                                                            <i class="fas fa-ban"></i>
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="${pageContext.request.contextPath}/hr/holiday" method="POST" style="display:inline;" onsubmit="return confirm('Kích hoạt lại ngày lễ \'${fn:escapeXml(h.holidayName)}\'?');">
                                                        <input type="hidden" name="action" value="activate">
                                                        <input type="hidden" name="id" value="${h.holidayId}">
                                                        <button type="submit" class="action-btn btn-activate" title="Kích hoạt">
                                                            <i class="fas fa-check-circle"></i>
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/hr/holiday" method="POST" style="display:inline;" onsubmit="return confirm('Xóa vĩnh viễn ngày lễ \'${fn:escapeXml(h.holidayName)}\'?');">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="id" value="${h.holidayId}">
                                                        <button type="submit" class="action-btn btn-delete" title="Xóa">
                                                            <i class="fas fa-trash-alt"></i>
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

<!-- ADD MODAL -->
<div class="modal-overlay" id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title"><i class="fas fa-plus-circle" style="color:var(--blue);margin-right:8px;"></i>Thêm Ngày Nghỉ Lễ</h3>
            <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/hr/holiday" method="POST">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label class="form-label">Tên ngày lễ <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="VD: Quốc khánh" required>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label class="form-label">Ngày (Dương lịch) <span style="color:#e11d48;">*</span></label>
                    <input type="date" name="holidayDate" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Loại lịch</label>
                    <select name="calendarType" class="form-control">
                        <option value="SOLAR">Dương lịch</option>
                        <option value="LUNAR">Âm lịch</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Hệ số OT <span style="color:#e11d48;">*</span></label>
                <input type="number" name="otMultiplier" class="form-control" step="0.1" min="1" value="3.0" required>
                <div style="font-size:0.75rem; color:var(--muted); margin-top:4px;"><i class="fas fa-info-circle"></i> Theo Điều 98 BLLĐ 2019: đi làm ngày lễ được trả tối thiểu 300% lương</div>
            </div>

            <div class="form-group">
                <label class="form-label">Mô tả</label>
                <textarea name="description" class="form-control" placeholder="Ghi chú thêm..."></textarea>
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
            <h3 class="modal-title"><i class="fas fa-edit" style="color:var(--blue);margin-right:8px;"></i>Cập Nhật Ngày Nghỉ Lễ</h3>
            <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/hr/holiday" method="POST">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="edit_id">
            <div class="form-group">
                <label class="form-label">Tên ngày lễ <span style="color:#e11d48;">*</span></label>
                <input type="text" name="name" id="edit_name" class="form-control" required>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label class="form-label">Ngày (Dương lịch) <span style="color:#e11d48;">*</span></label>
                    <input type="date" name="holidayDate" id="edit_date" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Loại lịch</label>
                    <select name="calendarType" id="edit_calendar" class="form-control">
                        <option value="SOLAR">Dương lịch</option>
                        <option value="LUNAR">Âm lịch</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Hệ số OT <span style="color:#e11d48;">*</span></label>
                <input type="number" name="otMultiplier" id="edit_multiplier" class="form-control" step="0.1" min="1" required>
                <div style="font-size:0.75rem; color:var(--muted); margin-top:4px;"><i class="fas fa-info-circle"></i> Theo Điều 98 BLLĐ 2019: đi làm ngày lễ được trả tối thiểu 300% lương</div>
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
    }

    function openEditModal(id, name, date, type, multiplier, desc) {
        document.getElementById('edit_id').value = id;
        document.getElementById('edit_name').value = name;
        document.getElementById('edit_date').value = date;
        document.getElementById('edit_calendar').value = type;
        document.getElementById('edit_multiplier').value = multiplier;
        document.getElementById('edit_desc').value = desc;
        document.getElementById('editModal').style.display = 'block';
    }

    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    window.onclick = function(event) {
        if (event.target.classList.contains('modal-overlay')) {
            event.target.style.display = 'none';
        }
    }

    /* FILTER & PAGINATION */
    let allRows = [];
    let filteredRows = [];
    let currentPage = 1;
    const itemsPerPage = 10;

    document.addEventListener("DOMContentLoaded", function() {
        const tbody = document.querySelector("#mainTable tbody");
        if (tbody && !tbody.querySelector('.empty-state-row')) {
            allRows = Array.from(tbody.querySelectorAll("tr"));
            filterTable();
        }
    });

    function filterTable() {
        const statusVal = document.getElementById("statusFilter").value;
        const searchVal = document.getElementById("searchInput").value.toLowerCase();

        filteredRows = allRows.filter(row => {
            const status = row.getAttribute("data-status");
            const text = row.innerText.toLowerCase();
            const matchStatus = (statusVal === 'all') || (statusVal === status);
            const matchSearch = text.includes(searchVal);
            return matchStatus && matchSearch;
        });

        currentPage = 1;
        updateTable();
    }

    function updateTable() {
        allRows.forEach(row => row.style.display = 'none');
        
        const totalItems = filteredRows.length;
        const totalPages = Math.ceil(totalItems / itemsPerPage) || 1;
        
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = Math.min(startIndex + itemsPerPage, totalItems);

        for (let i = startIndex; i < endIndex; i++) {
            filteredRows[i].style.display = '';
            filteredRows[i].querySelector('.row-stt').innerText = (i < 9 ? '0' : '') + (i + 1);
        }

        document.getElementById("totalItems").innerText = totalItems;
        document.getElementById("pageStart").innerText = totalItems === 0 ? 0 : startIndex + 1;
        document.getElementById("pageEnd").innerText = endIndex;

        document.getElementById("btnPrevPage").disabled = (currentPage === 1);
        document.getElementById("btnNextPage").disabled = (currentPage === totalPages);

        const pageNumbers = document.getElementById("pageNumbers");
        pageNumbers.innerHTML = '';
        for (let i = 1; i <= totalPages; i++) {
            const btn = document.createElement("button");
            btn.className = "btn-page" + (i === currentPage ? " active" : "");
            btn.innerText = i;
            btn.onclick = function() {
                currentPage = i;
                updateTable();
            };
            pageNumbers.appendChild(btn);
        }
    }

    function prevPage() {
        if (currentPage > 1) {
            currentPage--;
            updateTable();
        }
    }

    function nextPage() {
        const totalPages = Math.ceil(filteredRows.length / itemsPerPage) || 1;
        if (currentPage < totalPages) {
            currentPage++;
            updateTable();
        }
    }
</script>

<jsp:include page="../footer.jsp" />

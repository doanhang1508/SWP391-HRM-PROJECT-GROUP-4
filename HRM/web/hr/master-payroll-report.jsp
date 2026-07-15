<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Báo cáo Bảng lương Tổng hợp" scope="request"/>
<jsp:include page="../header.jsp"/>

<style>
/* ════════════════════════════════════════════════════════
   LAYOUT BASE
════════════════════════════════════════════════════════ */
.dashboard-wrapper { display:flex; min-height:calc(100vh - 64px); }
.main-content      { flex:1; min-width:0; background:#f0f4f8; }
.mpr-body          { padding:26px 28px 48px; }

/* ════════════════════════════════════════════════════════
   HERO HEADER
════════════════════════════════════════════════════════ */
.mpr-hero {
    background: linear-gradient(130deg,#0f172a 0%,#134e48 100%);
    border-radius: 16px;
    padding: 24px 28px;
    margin-bottom: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 14px;
    position: relative;
    overflow: hidden;
}
.mpr-hero::before {
    content:''; position:absolute; top:-50px; right:-50px;
    width:220px; height:220px; border-radius:50%;
    background:rgba(255,255,255,.04); pointer-events:none;
}
.hero-left h1 {
    font-size:1.45rem; font-weight:800; color:#fff;
    margin:0; display:flex; align-items:center; gap:10px;
}
.hero-ico {
    width:40px; height:40px; border-radius:10px;
    background:rgba(255,255,255,.12);
    display:flex; align-items:center; justify-content:center; font-size:1.1rem;
}
.hero-sub { font-size:.82rem; color:rgba(255,255,255,.55); margin:5px 0 0; }
.hero-breadcrumb { font-size:.78rem; color:rgba(255,255,255,.5); display:flex; align-items:center; gap:6px; }
.hero-breadcrumb a { color:rgba(255,255,255,.75); text-decoration:none; }
.hero-breadcrumb a:hover { color:#fff; }
.hero-breadcrumb .sep { color:rgba(255,255,255,.25); }

/* ════════════════════════════════════════════════════════
   FILTER CARD
════════════════════════════════════════════════════════ */
.mpr-filter {
    background:#fff;
    border:1px solid #e8edf3;
    border-radius:14px;
    padding:16px 22px;
    box-shadow:0 1px 6px rgba(0,0,0,.05);
    margin-bottom:18px;
    display:flex; flex-wrap:wrap; gap:12px; align-items:flex-end;
}
.fg { display:flex; flex-direction:column; gap:4px; }
.fg label {
    font-size:.7rem; font-weight:700; color:#64748b;
    text-transform:uppercase; letter-spacing:.5px;
    display:flex; align-items:center; gap:4px;
}
.fg select, .fg input {
    padding:8px 11px;
    border:1.5px solid #e2e8f0;
    border-radius:8px;
    font-size:.86rem; font-family:inherit;
    background:#f8fafc; color:#1e293b;
    min-width:130px;
    transition:border-color .18s, box-shadow .18s;
}
.fg select:focus, .fg input:focus {
    outline:none; border-color:#0d9488;
    box-shadow:0 0 0 3px rgba(13,148,136,.1);
    background:#fff;
}
.btn-go {
    height:38px; padding:0 20px;
    background:linear-gradient(135deg,#0d9488,#0e7490);
    color:#fff; border:none; border-radius:8px;
    font-weight:700; font-size:.85rem; cursor:pointer;
    display:inline-flex; align-items:center; gap:6px;
    transition:opacity .18s,transform .15s;
}
.btn-go:hover { opacity:.88; transform:translateY(-1px); }
.btn-xlsx {
    height:38px; padding:0 18px;
    background:#fff; color:#059669;
    border:1.5px solid #6ee7b7; border-radius:8px;
    font-weight:700; font-size:.85rem; cursor:pointer;
    display:inline-flex; align-items:center; gap:6px;
    transition:all .18s;
}
.btn-xlsx:hover { background:#f0fdf4; border-color:#10b981; box-shadow:0 3px 10px rgba(16,185,129,.15); transform:translateY(-1px); }

/* ════════════════════════════════════════════════════════
   KPI GRID
════════════════════════════════════════════════════════ */
.kpi-grid {
    display:grid;
    grid-template-columns:repeat(5,1fr);
    gap:14px;
    margin-bottom:20px;
}
@media(max-width:1100px){.kpi-grid{grid-template-columns:repeat(3,1fr);}}
@media(max-width:680px){.kpi-grid{grid-template-columns:repeat(2,1fr);}}
.kc {
    background:#fff; border:1px solid #e8edf3; border-radius:13px;
    padding:16px 18px;
    box-shadow:0 1px 5px rgba(0,0,0,.05);
    transition:transform .2s,box-shadow .2s;
    position:relative; overflow:hidden;
}
.kc:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(0,0,0,.09); }
.kc-top { position:absolute; top:0; left:0; right:0; height:3px; border-radius:13px 13px 0 0; }
.kc.c1 .kc-top{background:linear-gradient(90deg,#3b82f6,#6366f1);}
.kc.c2 .kc-top{background:linear-gradient(90deg,#10b981,#059669);}
.kc.c3 .kc-top{background:linear-gradient(90deg,#0d9488,#0284c7);}
.kc.c4 .kc-top{background:linear-gradient(90deg,#f59e0b,#f97316);}
.kc.c5 .kc-top{background:linear-gradient(90deg,#ef4444,#e11d48);}
.kc-row { display:flex; align-items:center; gap:11px; margin-top:2px; }
.kc-ico {
    width:38px; height:38px; border-radius:10px; flex-shrink:0;
    display:flex; align-items:center; justify-content:center; font-size:.95rem;
}
.c1 .kc-ico{background:#eff6ff;color:#3b82f6;}
.c2 .kc-ico{background:#f0fdf4;color:#10b981;}
.c3 .kc-ico{background:#f0fdfa;color:#0d9488;}
.c4 .kc-ico{background:#fffbeb;color:#d97706;}
.c5 .kc-ico{background:#fff1f2;color:#e11d48;}
.kc-lbl { font-size:.68rem; font-weight:700; color:#94a3b8; text-transform:uppercase; letter-spacing:.5px; }
.kc-val { font-size:1rem; font-weight:800; color:#0f172a; margin-top:1px; line-height:1.25; }
.kc-sub { font-size:.7rem; color:#94a3b8; margin-top:8px; }

/* ════════════════════════════════════════════════════════
   TABLE SECTION CARD
════════════════════════════════════════════════════════ */
.tbl-card {
    background:#fff;
    border:1px solid #e8edf3;
    border-radius:14px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
    overflow:hidden;
}

/* ── Card Header ── */
.tbl-card-hdr {
    display:flex; justify-content:space-between; align-items:center;
    padding:16px 22px;
    border-bottom:1px solid #f1f5f9;
    flex-wrap:wrap; gap:12px;
}
.tbl-hdr-left { display:flex; align-items:center; gap:10px; }
.tbl-hdr-icon {
    width:36px; height:36px; border-radius:9px;
    background:#f0fdfa; color:#0d9488;
    display:flex; align-items:center; justify-content:center;
    font-size:.9rem;
}
.tbl-hdr-title { font-size:1.05rem; font-weight:700; color:#0f172a; }
.tbl-hdr-badge {
    background:#f0fdfa; color:#0d9488; border:1px solid #ccfbf1;
    border-radius:20px; padding:2px 11px; font-size:.75rem; font-weight:700;
}
.tbl-hdr-right { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.period-chip {
    background:#f8fafc; border:1px solid #e2e8f0;
    border-radius:8px; padding:5px 12px;
    font-size:.8rem; font-weight:600; color:#475569;
    display:flex; align-items:center; gap:5px;
}
.period-chip i { color:#0d9488; }
.btn-sm-action {
    height:34px; padding:0 14px;
    border:1.5px solid #e2e8f0; border-radius:8px;
    background:#fff; color:#64748b;
    font-size:.8rem; font-weight:600; cursor:pointer;
    display:inline-flex; align-items:center; gap:6px;
    transition:all .15s;
}
.btn-sm-action:hover { border-color:#0d9488; color:#0d9488; background:#f0fdfa; }

/* ── Toolbar (search + pagesize) ── */
.tbl-toolbar {
    display:flex; align-items:center; justify-content:space-between;
    padding:12px 22px;
    background:#fafbfc;
    border-bottom:1px solid #f1f5f9;
    flex-wrap:wrap; gap:10px;
}
.tbl-toolbar-left { display:flex; align-items:center; gap:8px; }
.tbl-toolbar-right { display:flex; align-items:center; gap:10px; }
.tbl-search {
    height:34px; padding:0 10px 0 32px; width:200px;
    border:1.5px solid #e2e8f0; border-radius:8px;
    background:#fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E") 9px center/14px no-repeat;
    font-size:.83rem; color:#1e293b; transition:all .18s;
}
.tbl-search:focus { outline:none; border-color:#0d9488; width:230px; box-shadow:0 0 0 3px rgba(13,148,136,.08); }
.pg-size-wrap { display:flex; align-items:center; gap:6px; font-size:.78rem; color:#64748b; }
.pg-size-wrap select {
    height:32px; padding:0 8px;
    border:1.5px solid #e2e8f0; border-radius:7px;
    background:#fff; font-size:.78rem; cursor:pointer;
}

/* ── Scroll wrap ── */
.tbl-scroll-wrap { overflow-x:auto; -webkit-overflow-scrolling:touch; }
.scroll-hint {
    font-size:.72rem; color:#94a3b8; padding:4px 22px 0;
    display:none; background:#fafbfc;
}
@media(max-width:900px){.scroll-hint{display:block;}}

/* ════════════════════════════════════════════════════════
   PAYROLL TABLE
════════════════════════════════════════════════════════ */
.pl-tbl {
    width:100%; border-collapse:collapse;
    font-size:.84rem; min-width:1120px;
}
/* Sticky header */
.pl-tbl thead tr th {
    background:#1e3a5f;
    color:#e2e8f0;
    padding:0 14px;
    height:48px;
    font-size:.72rem; font-weight:700;
    text-transform:uppercase; letter-spacing:.45px;
    white-space:nowrap;
    position:sticky; top:0; z-index:3;
    border-bottom:2px solid #0d9488;
}
.pl-tbl thead tr th:first-child { border-radius:0; }
.th-c { text-align:center; }
.th-r { text-align:right; }

/* Body rows */
.pl-tbl tbody tr {
    border-bottom:1px solid #f1f5f9;
    transition:background .12s;
}
.pl-tbl tbody tr:hover { background:#f8fffe; }
.pl-tbl tbody tr:last-child { border-bottom:none; }
.pl-tbl tbody tr.row-hidden { display:none; }
.pl-tbl td {
    padding:0 14px;
    height:56px;
    vertical-align:middle;
    color:#1e293b;
    white-space:nowrap;
}
.td-c { text-align:center; }
.td-r { text-align:right; font-variant-numeric:tabular-nums; }

/* Cell types */
.stt-num { font-size:.75rem; font-weight:600; color:#94a3b8; }
.emp-code {
    display:inline-flex; align-items:center;
    padding:3px 9px; border-radius:6px;
    background:#f0fdfa; color:#0d9488;
    font-weight:700; font-size:.78rem; letter-spacing:.3px;
}
.emp-name { font-weight:600; color:#1e293b; font-size:.88rem; }
.dept-badge {
    display:inline-flex; align-items:center; gap:4px;
    padding:3px 10px; border-radius:20px;
    background:#ede9fe; color:#7c3aed;
    font-size:.73rem; font-weight:700;
}
/* Money styling */
.money-base  { color:#1e293b; font-weight:500; }
.money-pos   { color:#059669; font-weight:600; } /* bonus, allowance */
.money-neg   { color:#d97706; font-weight:500; } /* deduction parts */
.money-total-neg { color:#dc2626; font-weight:700; }
.money-net   { color:#059669; font-weight:800; font-size:.93rem; }

/* Status badges */
.st-badge {
    display:inline-flex; align-items:center; gap:4px;
    padding:4px 10px; border-radius:20px;
    font-size:.73rem; font-weight:700; white-space:nowrap;
}
.st-paid    { background:#d1fae5; color:#065f46; }
.st-aprvd   { background:#dbeafe; color:#1d4ed8; }
.st-pending { background:#fef3c7; color:#92400e; }
.st-draft   { background:#f1f5f9; color:#475569; }

/* Tfoot */
.pl-tbl tfoot td {
    background:#1e3a5f; color:#e2e8f0;
    padding:0 14px; height:48px;
    font-weight:700; font-size:.85rem;
    white-space:nowrap;
    border-top:2px solid #0d9488;
}
.pl-tbl tfoot td.td-r { text-align:right; }

/* ════════════════════════════════════════════════════════
   EMPTY STATE
════════════════════════════════════════════════════════ */
.empty-wrap {
    display:flex; flex-direction:column; align-items:center; justify-content:center;
    min-height:290px; padding:40px 24px; text-align:center;
}
.empty-circle {
    width:80px; height:80px; border-radius:50%;
    background:linear-gradient(135deg,#f0fdfa,#e0f2fe);
    display:flex; align-items:center; justify-content:center;
    margin-bottom:20px; font-size:2rem; color:#0d9488;
    box-shadow:0 4px 16px rgba(13,148,136,.15);
}
.empty-title { font-size:1.05rem; font-weight:700; color:#1e293b; margin:0 0 8px; }
.empty-desc  { font-size:.85rem; color:#64748b; margin:0 0 4px; max-width:380px; line-height:1.55; }
.empty-hint  { font-size:.8rem; color:#94a3b8; margin:0 0 22px; }
.empty-actions { display:flex; align-items:center; gap:10px; flex-wrap:wrap; justify-content:center; }
.btn-empty-primary {
    height:38px; padding:0 20px;
    background:linear-gradient(135deg,#0d9488,#0e7490);
    color:#fff; border:none; border-radius:8px;
    font-size:.84rem; font-weight:700; cursor:pointer;
    display:inline-flex; align-items:center; gap:7px;
    transition:opacity .18s,transform .15s;
}
.btn-empty-primary:hover { opacity:.88; transform:translateY(-1px); }
.btn-empty-sec {
    height:38px; padding:0 18px;
    background:#fff; color:#475569;
    border:1.5px solid #e2e8f0; border-radius:8px;
    font-size:.84rem; font-weight:600; cursor:pointer;
    display:inline-flex; align-items:center; gap:7px;
    transition:all .15s;
}
.btn-empty-sec:hover { border-color:#0d9488; color:#0d9488; background:#f0fdfa; }

/* ════════════════════════════════════════════════════════
   PAGINATION
════════════════════════════════════════════════════════ */
.pg-wrap {
    display:flex; justify-content:space-between; align-items:center;
    padding:14px 22px; border-top:1px solid #f1f5f9;
    flex-wrap:wrap; gap:10px; background:#fafbfc;
}
.pg-info { font-size:.8rem; color:#64748b; }
.pg-info strong { color:#0f172a; }
.pg-nav { display:flex; align-items:center; gap:3px; }
.pg-btn {
    min-width:34px; height:34px; padding:0 6px; border-radius:8px;
    border:1.5px solid #e8edf3; background:#fff;
    font-size:.8rem; font-weight:600; color:#475569;
    cursor:pointer; display:flex; align-items:center; justify-content:center;
    transition:all .15s; font-family:inherit;
}
.pg-btn:hover:not(:disabled):not(.pg-active) { background:#f0fdfa; border-color:#0d9488; color:#0d9488; }
.pg-btn.pg-active { background:#0d9488; border-color:#0d9488; color:#fff; cursor:default; }
.pg-btn:disabled { opacity:.35; cursor:not-allowed; }
.pg-dots { min-width:34px; height:34px; display:flex; align-items:center; justify-content:center; color:#94a3b8; font-size:.8rem; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="master-payroll-report"/>
    </jsp:include>

    <div class="main-content">
    <div class="mpr-body">

        <!-- ═══ HERO ═══════════════════════════════════════════════════ -->
        <div class="mpr-hero">
            <div class="hero-left">
                <h1>
                    <span class="hero-ico"><i class="fas fa-chart-bar"></i></span>
                    Báo cáo Bảng lương Tổng hợp
                </h1>
                <p class="hero-sub">Bảng lương trạng thái Approved / Paid — chỉ đọc, hỗ trợ xuất Excel 2 sheet</p>
            </div>
            <div class="hero-breadcrumb">
                <i class="fas fa-home"></i>
                <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                <span class="sep">/</span>
                <span>Báo cáo lương</span>
            </div>
        </div>

        <!-- ═══ FILTER ════════════════════════════════════════════════ -->
        <form action="${pageContext.request.contextPath}/hr/master-payroll-report" method="GET" class="mpr-filter">
            <div class="fg">
                <label><i class="fas fa-calendar-alt"></i> Tháng</label>
                <select name="month">
                    <c:forEach var="m" begin="1" end="12">
                        <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="fg">
                <label><i class="fas fa-calendar"></i> Năm</label>
                <input type="number" name="year" value="${selectedYear}" min="2020" max="2035" style="width:82px;">
            </div>
            <div class="fg">
                <label><i class="fas fa-building"></i> Phòng ban</label>
                <select name="departmentId">
                    <option value="-1" ${selectedDepartmentId == -1 ? 'selected' : ''}>Tất cả phòng ban</option>
                    <c:forEach var="d" items="${departments}">
                        <option value="${d.departmentId}" ${selectedDepartmentId == d.departmentId ? 'selected' : ''}>${d.departmentName}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="fg">
                <label>&nbsp;</label>
                <button type="submit" class="btn-go"><i class="fas fa-filter"></i> Xem báo cáo</button>
            </div>
            <div class="fg" style="margin-left:auto;">
                <label>&nbsp;</label>
                <form action="${pageContext.request.contextPath}/hr/master-payroll-report" method="GET" style="display:contents;">
                    <input type="hidden" name="action"       value="exportExcel">
                    <input type="hidden" name="month"        value="${selectedMonth}">
                    <input type="hidden" name="year"         value="${selectedYear}">
                    <input type="hidden" name="departmentId" value="${selectedDepartmentId}">
                    <button type="submit" class="btn-xlsx"><i class="fas fa-file-excel"></i> Xuất Excel (.xlsx)</button>
                </form>
            </div>
        </form>

        <!-- ═══ KPI CARDS ════════════════════════════════════════════ -->
        <div class="kpi-grid">
            <div class="kc c1">
                <div class="kc-top"></div>
                <div class="kc-row">
                    <div class="kc-ico"><i class="fas fa-users"></i></div>
                    <div>
                        <div class="kc-lbl">Số nhân viên</div>
                        <div class="kc-val">${reportData.size()} NV</div>
                    </div>
                </div>
                <div class="kc-sub">Approved + Paid &mdash; Th${selectedMonth}/${selectedYear}</div>
            </div>
            <div class="kc c2">
                <div class="kc-top"></div>
                <div class="kc-row">
                    <div class="kc-ico"><i class="fas fa-money-bill-wave"></i></div>
                    <div>
                        <div class="kc-lbl">Tổng thực lĩnh</div>
                        <div class="kc-val" style="font-size:.92rem;"><fmt:formatNumber value="${totalNet}" type="number" groupingUsed="true"/> ₫</div>
                    </div>
                </div>
                <div class="kc-sub">Tháng ${selectedMonth}/${selectedYear}</div>
            </div>
            <div class="kc c3">
                <div class="kc-top"></div>
                <div class="kc-row">
                    <div class="kc-ico"><i class="fas fa-wallet"></i></div>
                    <div>
                        <div class="kc-lbl">Lương cơ bản</div>
                        <div class="kc-val" style="font-size:.92rem;"><fmt:formatNumber value="${totalBase}" type="number" groupingUsed="true"/> ₫</div>
                    </div>
                </div>
                <div class="kc-sub">&nbsp;</div>
            </div>
            <div class="kc c4">
                <div class="kc-top"></div>
                <div class="kc-row">
                    <div class="kc-ico"><i class="fas fa-gift"></i></div>
                    <div>
                        <div class="kc-lbl">Thưởng + Phụ cấp</div>
                        <div class="kc-val" style="font-size:.92rem;"><fmt:formatNumber value="${totalBonus + totalAllowance}" type="number" groupingUsed="true"/> ₫</div>
                    </div>
                </div>
                <div class="kc-sub">&nbsp;</div>
            </div>
            <div class="kc c5">
                <div class="kc-top"></div>
                <div class="kc-row">
                    <div class="kc-ico"><i class="fas fa-minus-circle"></i></div>
                    <div>
                        <div class="kc-lbl">Tổng khấu trừ</div>
                        <div class="kc-val" style="font-size:.92rem;"><fmt:formatNumber value="${totalDeduction}" type="number" groupingUsed="true"/> ₫</div>
                    </div>
                </div>
                <div class="kc-sub">Phạt + BHXH + Thuế</div>
            </div>
        </div>

        <!-- ═══ TABLE CARD ════════════════════════════════════════════ -->
        <div class="tbl-card">

            <!-- Card Header -->
            <div class="tbl-card-hdr">
                <div class="tbl-hdr-left">
                    <div class="tbl-hdr-icon"><i class="fas fa-table"></i></div>
                    <span class="tbl-hdr-title">Chi tiết bảng lương</span>
                    <span class="tbl-hdr-badge">${reportData.size()} nhân viên</span>
                </div>
                <div class="tbl-hdr-right">
                    <span class="period-chip">
                        <i class="fas fa-calendar-check"></i>
                        Tháng <fmt:formatNumber value="${selectedMonth}" minIntegerDigits="2" groupingUsed="false"/>/${selectedYear}
                    </span>
                    <button type="button" class="btn-sm-action"
                            onclick="window.location.href='${pageContext.request.contextPath}/hr/master-payroll-report?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDepartmentId}'">
                        <i class="fas fa-sync-alt"></i> Làm mới
                    </button>
                </div>
            </div>

            <!-- ── HAS DATA: Toolbar + Table + Pagination ── -->
            <c:if test="${not empty reportData}">

                <!-- Toolbar -->
                <div class="tbl-toolbar">
                    <div class="tbl-toolbar-left">
                        <input type="search" id="tblSearch" class="tbl-search"
                               placeholder="Tìm tên, mã NV, phòng ban…"
                               oninput="filterTable(this.value)" aria-label="Tìm kiếm nhân viên">
                    </div>
                    <div class="tbl-toolbar-right">
                        <div class="pg-size-wrap">
                            <label for="pgSize">Hiển thị</label>
                            <select id="pgSize" onchange="changePageSize(this.value)">
                                <option value="10">10</option>
                                <option value="20">20</option>
                                <option value="50">50</option>
                                <option value="9999">Tất cả</option>
                            </select>
                            <span>dòng/trang</span>
                        </div>
                    </div>
                </div>

                <p class="scroll-hint"><i class="fas fa-arrows-alt-h me-1"></i> Kéo ngang để xem đầy đủ bảng</p>

                <!-- Table -->
                <div class="tbl-scroll-wrap">
                <table class="pl-tbl" id="mainTbl">
                    <thead>
                        <tr>
                            <th class="th-c"  style="width:42px;">#</th>
                            <th class="th-c"  style="min-width:85px;">Mã NV</th>
                            <th                style="min-width:170px;">Họ và tên</th>
                            <th                style="min-width:130px;">Phòng ban</th>
                            <th class="th-r"   style="min-width:130px;" title="Lương cơ bản">Lương cơ bản</th>
                            <th class="th-r"   style="min-width:100px;">Thưởng</th>
                            <th class="th-r"   style="min-width:100px;">Phụ cấp</th>
                            <th class="th-r"   style="min-width:120px;" title="Khoản khấu trừ kỷ luật">Khấu trừ/Phạt</th>
                            <th class="th-r"   style="min-width:115px;" title="Bảo hiểm nhân viên đóng">Bảo hiểm NV</th>
                            <th class="th-r"   style="min-width:110px;" title="Thuế thu nhập cá nhân">Thuế TNCN</th>
                            <th class="th-r"   style="min-width:130px;" title="Tổng = Phạt + Bảo hiểm + Thuế">
                                <span style="color:#fca5a5;">Tổng khoản trừ</span>
                            </th>
                            <th class="th-r"   style="min-width:130px;">
                                <span style="color:#6ee7b7;">Thực lĩnh</span>
                            </th>
                            <th class="th-c"   style="min-width:110px;">Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody id="tblBody">
                        <c:set var="stt" value="1"/>
                        <c:forEach var="p" items="${reportData}">
                        <tr data-search="${p.fullName} NV${p.userId} ${p.departmentName}">
                            <td class="td-c"><span class="stt-num">${stt}</span></td>
                            <td class="td-c"><span class="emp-code">NV<fmt:formatNumber value="${p.userId}" minIntegerDigits="4" groupingUsed="false"/></span></td>
                            <td><span class="emp-name">${p.fullName}</span></td>
                            <td>
                                <span class="dept-badge">
                                    <c:out value="${not empty p.departmentName ? p.departmentName : '—'}"/>
                                </span>
                            </td>
                            <td class="td-r money-base">
                                <fmt:formatNumber value="${p.baseSalary}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td class="td-r money-pos">
                                <fmt:formatNumber value="${p.bonusAmount}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td class="td-r money-pos">
                                <fmt:formatNumber value="${p.allowanceAmount}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td class="td-r money-neg">
                                <fmt:formatNumber value="${p.deductionAmount}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td class="td-r money-neg">
                                <fmt:formatNumber value="${p.insuranceAmount}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td class="td-r money-neg">
                                <fmt:formatNumber value="${p.taxAmount}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td class="td-r money-total-neg">
                                <fmt:formatNumber value="${p.totalDeductionAll}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td class="td-r money-net">
                                <fmt:formatNumber value="${p.netSalary}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td class="td-c">
                                <c:choose>
                                    <c:when test="${p.status eq 'Paid'}">
                                        <span class="st-badge st-paid"><i class="fas fa-check-double"></i> Đã thanh toán</span>
                                    </c:when>
                                    <c:when test="${p.status eq 'Approved'}">
                                        <span class="st-badge st-aprvd"><i class="fas fa-check-circle"></i> Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${p.status eq 'Pending'}">
                                        <span class="st-badge st-pending"><i class="fas fa-clock"></i> Chờ duyệt</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="st-badge st-draft"><i class="fas fa-pencil-alt"></i> ${p.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <c:set var="stt" value="${stt + 1}"/>
                        </c:forEach>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="4" style="text-align:right; font-size:.73rem; letter-spacing:.5px; color:#94a3b8;">TỔNG CỘNG</td>
                            <td class="td-r"><fmt:formatNumber value="${totalBase}"      type="number" groupingUsed="true"/> ₫</td>
                            <td class="td-r" style="color:#6ee7b7;"><fmt:formatNumber value="${totalBonus}"     type="number" groupingUsed="true"/> ₫</td>
                            <td class="td-r" style="color:#6ee7b7;"><fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/> ₫</td>
                            <td class="td-r" style="color:#fcd34d;" colspan="3">—</td>
                            <td class="td-r" style="color:#fca5a5;"><fmt:formatNumber value="${totalDeduction}" type="number" groupingUsed="true"/> ₫</td>
                            <td class="td-r" style="color:#6ee7b7; font-size:.9rem;"><fmt:formatNumber value="${totalNet}" type="number" groupingUsed="true"/> ₫</td>
                            <td></td>
                        </tr>
                    </tfoot>
                </table>
                </div>

                <!-- Pagination -->
                <div class="pg-wrap" id="pgWrap">
                    <div class="pg-info" id="pgInfo"></div>
                    <div class="pg-nav"  id="pgNav"></div>
                </div>

            </c:if>

            <!-- ── EMPTY STATE ── -->
            <c:if test="${empty reportData}">
                <div class="empty-wrap">
                    <div class="empty-circle">
                        <i class="fas fa-file-invoice-dollar"></i>
                    </div>
                    <h4 class="empty-title">Chưa có bảng lương đã duyệt</h4>
                    <p class="empty-desc">
                        Không tìm thấy bảng lương ở trạng thái <strong>Đã duyệt</strong> hoặc <strong>Đã thanh toán</strong>
                        trong Tháng <fmt:formatNumber value="${selectedMonth}" minIntegerDigits="2" groupingUsed="false"/>/${selectedYear}.
                    </p>
                    <p class="empty-hint">Hãy kiểm tra lại kỳ lương, bộ lọc hoặc quy trình phê duyệt bảng lương.</p>
                    <div class="empty-actions">
                        <button class="btn-empty-primary"
                                onclick="document.querySelector('.mpr-filter').scrollIntoView({behavior:'smooth'})">
                            <i class="fas fa-filter"></i> Kiểm tra bộ lọc
                        </button>
                        <button class="btn-empty-sec"
                                onclick="window.location.href='${pageContext.request.contextPath}/hr/master-payroll-report?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDepartmentId}'">
                            <i class="fas fa-sync-alt"></i> Làm mới dữ liệu
                        </button>
                    </div>
                </div>
            </c:if>

        </div><%-- /tbl-card --%>

    </div><%-- /mpr-body --%>
    </div><%-- /main-content --%>
</div><%-- /dashboard-wrapper --%>

<script>
(function(){
    'use strict';
    var PS = 10, curPage = 1;
    var allRows = [], filteredRows = [];

    function init(){
        var tbody = document.getElementById('tblBody');
        if(!tbody) return;
        tbody.querySelectorAll('tr[data-search]').forEach(function(r){ allRows.push(r); });
        filteredRows = allRows.slice();
        go(1);
    }

    window.filterTable = function(q){
        q = q.toLowerCase().trim();
        filteredRows = q ? allRows.filter(function(r){
            return r.dataset.search.toLowerCase().indexOf(q) >= 0;
        }) : allRows.slice();
        go(1);
    };

    window.changePageSize = function(v){
        PS = parseInt(v)||10; go(1);
    };

    function go(page){
        curPage = page;
        var total = filteredRows.length;
        var start, end;
        if(PS >= 9999){ start=0; end=total; }
        else { start=(page-1)*PS; end=Math.min(start+PS,total); }

        allRows.forEach(function(r){ r.classList.add('row-hidden'); });
        filteredRows.forEach(function(r,i){
            if(i>=start && i<end) r.classList.remove('row-hidden');
        });
        renderInfo(start,end,total);
        renderPg(total);
    }

    function renderInfo(s,e,total){
        var el = document.getElementById('pgInfo');
        if(!el) return;
        if(total===0){ el.innerHTML='Không tìm thấy kết quả'; return; }
        if(PS>=9999){ el.innerHTML='Hiển thị tất cả <strong>'+total+'</strong> nhân viên'; return; }
        el.innerHTML='Hiển thị <strong>'+(s+1)+'&ndash;'+e+'</strong> trong <strong>'+total+'</strong> nhân viên';
    }

    function renderPg(total){
        var nav = document.getElementById('pgNav');
        if(!nav) return;
        nav.innerHTML='';
        if(PS>=9999 || total===0) return;
        var tp = Math.ceil(total/PS);
        if(tp<=1) return;

        function btn(label,page,cls,disabled){
            var b=document.createElement('button');
            b.className='pg-btn'+(cls?' '+cls:'');
            b.innerHTML=label; b.disabled=!!disabled;
            if(!disabled && cls!=='pg-active')
                b.addEventListener('click',function(){ go(page); });
            return b;
        }
        nav.appendChild(btn('<i class="fas fa-chevron-left"></i>', curPage-1, '', curPage===1));
        pages(curPage,tp).forEach(function(p){
            if(p==='...'){
                var s=document.createElement('span'); s.className='pg-dots'; s.textContent='…'; nav.appendChild(s);
            } else {
                nav.appendChild(btn(p, p, p===curPage?'pg-active':'', false));
            }
        });
        nav.appendChild(btn('<i class="fas fa-chevron-right"></i>', curPage+1, '', curPage===tp));
    }

    function pages(cur,tp){
        if(tp<=7){ var r=[]; for(var i=1;i<=tp;i++) r.push(i); return r; }
        if(cur<=4)   return [1,2,3,4,5,'...',tp];
        if(cur>=tp-3) return [1,'...',tp-4,tp-3,tp-2,tp-1,tp];
        return [1,'...',cur-1,cur,cur+1,'...',tp];
    }

    if(document.readyState==='loading')
        document.addEventListener('DOMContentLoaded',init);
    else init();
})();
</script>

</main>
</body>
</html>

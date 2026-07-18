<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="pageTitle" value="Báo cáo Bảng lương Tổng hợp" scope="request"/>
<jsp:include page="../header.jsp"/>

<style>
/* ─────────────────────────────────────────────────────────
   DESIGN TOKENS  (1 accent = #0891b2 cyan-600)
───────────────────────────────────────────────────────── */
:root{
  --bg:       #f8fafc;
  --surface:  #ffffff;
  --border:   #e5e7eb;
  --border-xs:#f3f4f6;
  --txt-1:    #111827;
  --txt-2:    #374151;
  --txt-3:    #6b7280;
  --txt-4:    #9ca3af;
  --accent:   #0891b2;
  --acc-bg:   #f0f9ff;
  --acc-border:#bae6fd;
  --ok:       #059669;
  --ok-bg:    #f0fdf4;
  --ok-border:#a7f3d0;
  --warn:     #d97706;
  --warn-bg:  #fffbeb;
  --err:      #b91c1c;
  --err-bg:   #fef2f2;
  --err-border:#fecaca;
  --neutral-bg:#f9fafb;
  --radius:   12px;
  --radius-sm: 8px;
  --shadow-xs: 0 1px 3px rgba(0,0,0,.06), 0 1px 2px rgba(0,0,0,.04);
  --shadow-sm: 0 2px 6px rgba(0,0,0,.07);
}

/* ─────────────────────────────────────────────────────────
   LAYOUT
───────────────────────────────────────────────────────── */
.dashboard-wrapper{display:flex;min-height:calc(100vh - 64px);}
.main-content{flex:1;min-width:0;background:var(--bg);}
.pr-body{padding:24px 28px 56px;max-width:1600px;}

/* ─────────────────────────────────────────────────────────
   PAGE HEADER  (clean, no gradient)
───────────────────────────────────────────────────────── */
.pr-page-hdr{
  display:flex;justify-content:space-between;align-items:center;
  margin-bottom:24px;flex-wrap:wrap;gap:12px;
}
.pr-page-hdr-left h1{
  font-size:1.35rem;font-weight:500;color:var(--txt-1);
  margin:0;display:flex;align-items:center;gap:8px;
}
.pr-page-hdr-left h1 i{font-size:1.05rem;color:var(--accent);}
.pr-page-hdr-left p{font-size:.82rem;color:var(--txt-3);margin:4px 0 0;}
.breadcrumb-row{
  display:flex;align-items:center;gap:5px;
  font-size:.78rem;color:var(--txt-4);
}
.breadcrumb-row a{color:var(--txt-3);text-decoration:none;}
.breadcrumb-row a:hover{color:var(--accent);}
.breadcrumb-row .sep{color:var(--border);}

/* ─────────────────────────────────────────────────────────
   FILTER ROW
───────────────────────────────────────────────────────── */
.pr-filter{
  background:var(--surface);
  border:1px solid var(--border);
  border-radius:var(--radius);
  padding:14px 20px;
  box-shadow:var(--shadow-xs);
  margin-bottom:20px;
  display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;
}
.fg{display:flex;flex-direction:column;gap:4px;}
.fg label{
  font-size:.7rem;color:var(--txt-3);
  text-transform:uppercase;letter-spacing:.5px;
}
.fg select,.fg input[type=number]{
  height:36px;padding:0 10px;
  border:1px solid var(--border);border-radius:var(--radius-sm);
  background:var(--surface);color:var(--txt-1);
  font-size:.84rem;font-family:inherit;min-width:120px;
  transition:border-color .15s,box-shadow .15s;
}
.fg select:focus,.fg input[type=number]:focus{
  outline:none;border-color:var(--accent);
  box-shadow:0 0 0 3px rgba(8,145,178,.1);
}
.btn-primary{
  height:36px;padding:0 16px;
  background:var(--accent);color:#fff;
  border:none;border-radius:var(--radius-sm);
  font-size:.84rem;font-weight:500;cursor:pointer;
  display:inline-flex;align-items:center;gap:6px;
  transition:background .15s,transform .1s;white-space:nowrap;
}
.btn-primary:hover{background:#0e7490;transform:translateY(-1px);}
.btn-outline{
  height:36px;padding:0 14px;
  background:var(--surface);color:var(--ok);
  border:1px solid var(--ok-border);border-radius:var(--radius-sm);
  font-size:.84rem;font-weight:500;cursor:pointer;
  display:inline-flex;align-items:center;gap:6px;
  transition:all .15s;white-space:nowrap;
}
.btn-outline:hover{background:var(--ok-bg);border-color:var(--ok);}

/* ─────────────────────────────────────────────────────────
   KPI STRIP  (5 cards, minimal)
───────────────────────────────────────────────────────── */
.kpi-row{
  display:grid;
  grid-template-columns:repeat(5,1fr);
  gap:12px;margin-bottom:20px;
}
@media(max-width:1100px){.kpi-row{grid-template-columns:repeat(3,1fr);}}
@media(max-width:680px) {.kpi-row{grid-template-columns:repeat(2,1fr);}}
.kpi{
  background:var(--surface);
  border:1px solid var(--border);
  border-radius:var(--radius);
  padding:16px 18px;
  box-shadow:var(--shadow-xs);
  transition:box-shadow .2s;
}
.kpi:hover{box-shadow:var(--shadow-sm);}
.kpi-lbl{
  font-size:.69rem;color:var(--txt-3);
  text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;
  display:flex;align-items:center;gap:5px;
}
.kpi-lbl i{font-size:.75rem;}
.kpi-val{font-size:1.05rem;color:var(--txt-1);line-height:1.25;}
.kpi-sub{font-size:.69rem;color:var(--txt-4);margin-top:4px;}
.kpi-val.accent{color:var(--accent);}
.kpi-val.ok    {color:var(--ok);}
.kpi-val.err   {color:var(--err);}

/* ─────────────────────────────────────────────────────────
   TABLE CARD
───────────────────────────────────────────────────────── */
.tbl-card{
  background:var(--surface);
  border:1px solid var(--border);
  border-radius:var(--radius);
  box-shadow:var(--shadow-xs);
  overflow:hidden;
}

/* ── Card header ──────────────────────────────────────── */
.tc-hdr{
  display:flex;justify-content:space-between;align-items:center;
  padding:14px 20px;border-bottom:1px solid var(--border-xs);
  flex-wrap:wrap;gap:10px;
}
.tc-hdr-left{display:flex;align-items:center;gap:8px;}
.tc-hdr-icon{
  width:32px;height:32px;border-radius:8px;
  background:var(--acc-bg);color:var(--accent);
  display:flex;align-items:center;justify-content:center;
  font-size:.85rem;
}
.tc-title{font-size:.95rem;font-weight:500;color:var(--txt-1);}
.tc-badge{
  background:var(--neutral-bg);color:var(--txt-3);
  border:1px solid var(--border);
  border-radius:20px;padding:2px 10px;
  font-size:.72rem;
}
.tc-hdr-right{display:flex;align-items:center;gap:8px;}
.period-tag{
  display:inline-flex;align-items:center;gap:5px;
  padding:5px 11px;border:1px solid var(--border);
  border-radius:var(--radius-sm);background:var(--neutral-bg);
  font-size:.78rem;color:var(--txt-2);
}
.period-tag i{color:var(--accent);font-size:.75rem;}
.btn-ghost{
  height:32px;padding:0 12px;
  background:transparent;color:var(--txt-3);
  border:1px solid var(--border);border-radius:var(--radius-sm);
  font-size:.78rem;cursor:pointer;
  display:inline-flex;align-items:center;gap:5px;
  transition:all .15s;
}
.btn-ghost:hover{color:var(--accent);border-color:var(--acc-border);background:var(--acc-bg);}

/* ── Toolbar ──────────────────────────────────────────── */
.tc-toolbar{
  display:flex;justify-content:space-between;align-items:center;
  padding:10px 20px;border-bottom:1px solid var(--border-xs);
  background:var(--neutral-bg);flex-wrap:wrap;gap:8px;
}
.search-wrap{position:relative;display:inline-flex;align-items:center;}
.search-wrap i{
  position:absolute;left:10px;color:var(--txt-4);
  font-size:.75rem;pointer-events:none;
}
.tbl-search{
  height:32px;padding:0 10px 0 30px;
  border:1px solid var(--border);border-radius:var(--radius-sm);
  background:var(--surface);color:var(--txt-1);
  font-size:.82rem;font-family:inherit;width:210px;
  transition:all .18s;
}
.tbl-search:focus{
  outline:none;border-color:var(--accent);width:240px;
  box-shadow:0 0 0 3px rgba(8,145,178,.08);
}
.pg-size-row{display:flex;align-items:center;gap:6px;font-size:.78rem;color:var(--txt-3);}
.pg-size-row select{
  height:30px;padding:0 8px;
  border:1px solid var(--border);border-radius:var(--radius-sm);
  background:var(--surface);font-size:.78rem;cursor:pointer;
  color:var(--txt-2);
}

/* ── Scroll ───────────────────────────────────────────── */
.tbl-scroll{overflow-x:auto;-webkit-overflow-scrolling:touch;}
.scroll-note{
  display:none;font-size:.7rem;color:var(--txt-4);
  padding:4px 20px;background:var(--neutral-bg);
}
@media(max-width:900px){.scroll-note{display:block;}}

/* ─────────────────────────────────────────────────────────
   PAYROLL TABLE — MINIMALIST
───────────────────────────────────────────────────────── */
.ptbl{width:100%;border-collapse:collapse;font-size:.84rem;min-width:1140px;}

/* Header — light, readable */
.ptbl thead th{
  background:var(--neutral-bg);
  color:var(--txt-3);
  padding:0 14px;height:44px;
  font-size:.69rem;
  text-transform:uppercase;letter-spacing:.5px;
  white-space:nowrap;
  border-bottom:1px solid var(--border);
  position:sticky;top:0;z-index:2;
}
.th-c{text-align:center;}
.th-r{text-align:right;}

/* Separator groups */
.ptbl thead th.g-deduct{
  color:#b45309;
  background:#fefce8;
  border-bottom:1px solid #fde68a;
}
.ptbl thead th.g-net{
  color:var(--ok);
  background:var(--ok-bg);
  border-bottom:1px solid var(--ok-border);
}

/* Body rows */
.ptbl tbody tr{border-bottom:1px solid var(--border-xs);transition:background .1s;}
.ptbl tbody tr:hover{background:#fafafa;}
.ptbl tbody tr.row-hidden{display:none;}
.ptbl tbody tr:last-child{border-bottom:none;}
.ptbl td{
  padding:0 14px;height:54px;
  vertical-align:middle;color:var(--txt-1);white-space:nowrap;
}
.td-c{text-align:center;}
.td-r{text-align:right;font-variant-numeric:tabular-nums;}

/* Cells */
.stt{font-size:.75rem;color:var(--txt-4);}
.emp-badge{
  display:inline-flex;align-items:center;
  padding:3px 9px;border-radius:6px;
  background:var(--acc-bg);
  color:var(--accent);
  font-size:.76rem;letter-spacing:.2px;
  border:1px solid var(--acc-border);
}
.dept-badge{
  display:inline-flex;align-items:center;
  padding:3px 9px;border-radius:20px;
  font-size:.74rem;
  background:#f5f3ff;color:#6d28d9;
  border:1px solid #ede9fe;
}
.dept-badge.dept-ns {background:#f0fdf4;color:#065f46;border-color:var(--ok-border);}
.dept-badge.dept-tc {background:#eff6ff;color:#1d4ed8;border-color:#bfdbfe;}
.dept-badge.dept-sx {background:#fff7ed;color:#c2410c;border-color:#fed7aa;}
.dept-badge.dept-it {background:#fdf4ff;color:#7c3aed;border-color:#e9d5ff;}

.emp-name{color:var(--txt-1);font-size:.88rem;}
.money-base{color:var(--txt-2);}
.money-pos {color:#047857;} /* bonus/allowance */
.money-neg {color:#b45309;} /* each deduction part */
.money-total{color:var(--err);}
.money-net {color:var(--ok);font-size:.9rem;}

/* Status badges */
.st{
  display:inline-flex;align-items:center;gap:4px;
  padding:3px 10px;border-radius:20px;
  font-size:.72rem;white-space:nowrap;
}
.st-paid  {background:var(--ok-bg);color:#065f46;border:1px solid var(--ok-border);}
.st-aprvd {background:var(--acc-bg);color:#0e7490;border:1px solid var(--acc-border);}
.st-pend  {background:var(--warn-bg);color:#92400e;border:1px solid #fde68a;}
.st-draft {background:var(--neutral-bg);color:var(--txt-3);border:1px solid var(--border);}

/* ── Summary row ────────────────────────────────────────── */
.ptbl tfoot tr{background:var(--neutral-bg);border-top:2px solid var(--border);}
.ptbl tfoot td{
  padding:0 14px;height:48px;
  font-size:.84rem;
  color:var(--txt-2);white-space:nowrap;
}
.ptbl tfoot td.td-r{text-align:right;font-variant-numeric:tabular-nums;}
.ptbl tfoot td.sum-label{
  text-align:right;font-size:.72rem;letter-spacing:.5px;
  text-transform:uppercase;color:var(--txt-4);
}
.tfoot-total-neg{color:var(--err);}
.tfoot-net     {color:var(--ok);}

/* ─────────────────────────────────────────────────────────
   EMPTY STATE  (compact, minimal)
───────────────────────────────────────────────────────── */
.empty-box{
  display:flex;flex-direction:column;align-items:center;
  justify-content:center;padding:56px 24px;text-align:center;
  min-height:280px;
}
.empty-icon{
  width:68px;height:68px;border-radius:50%;
  background:var(--neutral-bg);border:1.5px solid var(--border);
  display:flex;align-items:center;justify-content:center;
  color:var(--txt-4);font-size:1.6rem;margin-bottom:16px;
}
.empty-title{font-size:.95rem;font-weight:500;color:var(--txt-1);margin:0 0 6px;}
.empty-desc {font-size:.83rem;color:var(--txt-3);max-width:360px;line-height:1.55;margin:0 0 4px;}
.empty-hint {font-size:.76rem;color:var(--txt-4);margin:0 0 20px;}
.empty-btns {display:flex;gap:8px;flex-wrap:wrap;justify-content:center;}
.btn-sm-pri{
  height:34px;padding:0 16px;
  background:var(--accent);color:#fff;
  border:none;border-radius:var(--radius-sm);
  font-size:.8rem;font-weight:500;cursor:pointer;
  display:inline-flex;align-items:center;gap:6px;
  transition:background .15s;
}
.btn-sm-pri:hover{background:#0e7490;}
.btn-sm-ghost{
  height:34px;padding:0 14px;
  background:var(--surface);color:var(--txt-3);
  border:1px solid var(--border);border-radius:var(--radius-sm);
  font-size:.8rem;cursor:pointer;
  display:inline-flex;align-items:center;gap:6px;
  transition:all .15s;
}
.btn-sm-ghost:hover{color:var(--accent);border-color:var(--acc-border);}

/* ─────────────────────────────────────────────────────────
   PAGINATION  — minimal prev/next only
───────────────────────────────────────────────────────── */
.pg-bar{
  display:flex;justify-content:space-between;align-items:center;
  padding:14px 20px;border-top:1px solid var(--border-xs);
  flex-wrap:wrap;gap:8px;
}
.pg-info{font-size:.8rem;color:var(--txt-3);}
.pg-nav{display:flex;align-items:center;gap:4px;}
.pg-arrow{
  width:30px;height:30px;
  border:1px solid var(--border);border-radius:6px;
  background:var(--surface);color:var(--txt-3);cursor:pointer;
  display:flex;align-items:center;justify-content:center;
  font-size:.72rem;
  transition:all .13s;
}
.pg-arrow:hover:not(:disabled){border-color:var(--accent);color:var(--accent);}
.pg-arrow:disabled{opacity:.3;cursor:not-allowed;}

/* ─────────────────────────────────────────────────────────
   CHART CARD
───────────────────────────────────────────────────────── */
.chart-card{
  background:var(--surface);
  border:1px solid var(--border);
  border-radius:var(--radius);
  box-shadow:var(--shadow-xs);
  margin-bottom:20px;
  overflow:hidden;
}
.chart-hdr{
  display:flex;justify-content:space-between;align-items:center;
  padding:14px 20px;border-bottom:1px solid var(--border-xs);
  flex-wrap:wrap;gap:10px;
}
.chart-hdr-left{display:flex;align-items:center;gap:8px;}
.chart-hdr-icon{
  width:32px;height:32px;border-radius:8px;
  background:var(--acc-bg);color:var(--accent);
  display:flex;align-items:center;justify-content:center;
  font-size:.85rem;
}
.chart-title{font-size:.95rem;font-weight:500;color:var(--txt-1);}
.chart-hdr-right{display:flex;align-items:center;gap:6px;flex-wrap:wrap;}
.chart-type-btn{
  height:28px;padding:0 12px;
  background:var(--neutral-bg);color:var(--txt-3);
  border:1px solid var(--border);border-radius:var(--radius-sm);
  font-size:.76rem;cursor:pointer;
  display:inline-flex;align-items:center;gap:4px;
  transition:all .15s;
}
.chart-type-btn.active,
.chart-type-btn:hover{
  background:var(--acc-bg);color:var(--accent);
  border-color:var(--acc-border);
}
.chart-body{padding:20px 24px 24px;}
.chart-canvas-wrap{position:relative;height:340px;}
.chart-legend{
  display:flex;flex-wrap:wrap;gap:12px;justify-content:center;
  margin-top:16px;
}
.chart-legend-item{
  display:flex;align-items:center;gap:6px;
  font-size:.76rem;color:var(--txt-2);
}
.chart-legend-dot{
  width:10px;height:10px;border-radius:2px;flex-shrink:0;
}
.chart-note{
  font-size:.72rem;color:var(--txt-4);text-align:center;
  margin-top:8px;
}
</style>

<!-- ═══ EXPORT FORM (hidden, avoids nested-form bug) ═══ -->
<form id="exportForm"
      action="${pageContext.request.contextPath}/hr/master-payroll-report"
      method="GET" style="display:none;">
    <input type="hidden" name="action"       value="exportExcel">
    <input type="hidden" id="ef_m"  name="month"        value="${selectedMonth}">
    <input type="hidden" id="ef_y"  name="year"         value="${selectedYear}">
    <input type="hidden" id="ef_d"  name="departmentId" value="${selectedDepartmentId}">
</form>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="master-payroll-report"/>
    </jsp:include>

    <div class="main-content">
    <div class="pr-body">

    <!-- ═══ PAGE HEADER ══════════════════════════════════════════════ -->
    <div class="pr-page-hdr">
        <div class="pr-page-hdr-left">
            <h1><i class="fas fa-file-invoice-dollar"></i> Báo cáo Bảng lương Tổng hợp</h1>
        </div>
        <div class="breadcrumb-row">
            <a href="${pageContext.request.contextPath}/dashboard">
                <i class="fas fa-house"></i> Bảng điều khiển
            </a>
            <span class="sep">/</span>
            <span>Báo cáo lương</span>
        </div>
    </div>

    <!-- ═══ FILTER ════════════════════════════════════════════════════ -->
    <form id="filterForm"
          action="${pageContext.request.contextPath}/hr/master-payroll-report"
          method="GET" class="pr-filter">
        <div class="fg">
            <label>Tháng</label>
            <select name="month">
                <c:forEach var="m" begin="1" end="12">
                    <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>
                        Tháng ${m}
                    </option>
                </c:forEach>
            </select>
        </div>
        <div class="fg">
            <label>Năm</label>
            <input type="number" name="year" value="${selectedYear}"
                   min="2020" max="2035" style="width:76px;">
        </div>
        <div class="fg">
            <label>Phòng ban</label>
            <select name="departmentId">
                <option value="-1" ${selectedDepartmentId == -1 ? 'selected' : ''}>
                    Tất cả phòng ban
                </option>
                <c:forEach var="d" items="${departments}">
                    <option value="${d.departmentId}"
                            ${selectedDepartmentId == d.departmentId ? 'selected' : ''}>
                        ${d.departmentName}
                    </option>
                </c:forEach>
            </select>
        </div>
        <div class="fg">
            <label>&nbsp;</label>
            <button type="submit" class="btn-primary">
                <i class="fas fa-magnifying-glass"></i> Xem báo cáo
            </button>
        </div>
        <div class="fg" style="margin-left:auto;">
            <label>&nbsp;</label>
            <button type="button" class="btn-outline" onclick="doExport()">
                <i class="fas fa-file-excel"></i> Xuất Excel
            </button>
        </div>
    </form>

    <!-- ═══ KPI STRIP ════════════════════════════════════════════════ -->
    <div class="kpi-row">
        <div class="kpi">
            <div class="kpi-lbl"><i class="fas fa-users"></i> Số nhân viên</div>
            <div class="kpi-val accent">${reportData.size()} người</div>
            <div class="kpi-sub">Approved + Paid &nbsp;·&nbsp; Th${selectedMonth}/${selectedYear}</div>
        </div>
        <div class="kpi">
            <div class="kpi-lbl"><i class="fas fa-circle-dollar-to-slot"></i> Tổng thực lĩnh</div>
            <div class="kpi-val ok" style="font-size:.98rem;">
                <fmt:formatNumber value="${totalNet}" type="number" groupingUsed="true"/> ₫
            </div>
            <div class="kpi-sub">Tháng ${selectedMonth}/${selectedYear}</div>
        </div>
        <div class="kpi">
            <div class="kpi-lbl"><i class="fas fa-wallet"></i> Lương cơ bản</div>
            <div class="kpi-val" style="font-size:.98rem;">
                <fmt:formatNumber value="${totalBase}" type="number" groupingUsed="true"/> ₫
            </div>
            <div class="kpi-sub">&nbsp;</div>
        </div>
        <div class="kpi">
            <div class="kpi-lbl"><i class="fas fa-gift"></i> Thưởng + Phụ cấp</div>
            <div class="kpi-val" style="font-size:.98rem;">
                <fmt:formatNumber value="${totalBonus + totalAllowance}" type="number" groupingUsed="true"/> ₫
            </div>
            <div class="kpi-sub">&nbsp;</div>
        </div>
        <div class="kpi">
            <div class="kpi-lbl"><i class="fas fa-circle-minus"></i> Tổng khấu trừ</div>
            <div class="kpi-val err" style="font-size:.98rem;">
                <fmt:formatNumber value="${totalDeduction}" type="number" groupingUsed="true"/> ₫
            </div>
            <div class="kpi-sub">Phạt · BHXH · Thuế</div>
        </div>
    </div>

    <!-- ═══ CHART CARD: Cấu hình mức lương theo phòng ban ════════════ -->
    <c:if test="${not empty reportData}">
    <div class="chart-card">
        <div class="chart-hdr">
            <div class="chart-hdr-left">
                <div class="chart-hdr-icon"><i class="fas fa-chart-column"></i></div>
                <span class="chart-title">Cấu hình mức lương theo phòng ban</span>
                <span class="tc-badge">Tháng <fmt:formatNumber value="${selectedMonth}" minIntegerDigits="2" groupingUsed="false"/>/${selectedYear}</span>
            </div>
            <div class="chart-hdr-right">
                <button class="chart-type-btn active" id="btnGrouped" onclick="switchChart('grouped')">
                    <i class="fas fa-chart-bar"></i> Nhóm cột
                </button>
                <button class="chart-type-btn" id="btnStacked" onclick="switchChart('stacked')">
                    <i class="fas fa-layer-group"></i> Cột chồng
                </button>
                <button class="chart-type-btn" id="btnHBar" onclick="switchChart('hbar')">
                    <i class="fas fa-chart-simple"></i> Ngang
                </button>
            </div>
        </div>
        <div class="chart-body">
            <div class="chart-canvas-wrap">
                <canvas id="deptSalaryChart"></canvas>
            </div>
            <div class="chart-legend" id="chartLegend"></div>
            <p class="chart-note">
                <i class="fas fa-circle-info"></i>
                Dữ liệu tổng hợp từ bảng lương Tháng ${selectedMonth}/${selectedYear}.
                Đơn vị: VNĐ (triệu). Chỉ hiển thị phòng ban có bảng lương đã duyệt/thanh toán.
            </p>
        </div>
    </div>
    </c:if>

    <!-- Pre-aggregate salary data by dept server-side (Java) → no client aggregation needed -->
    <%
      /* ── Server-side aggregation by department ── */
      java.util.List<?> _rd = (java.util.List<?>) request.getAttribute("reportData");
      java.util.LinkedHashMap<String, double[]> _deptMap = new java.util.LinkedHashMap<>();
      // keys: dept name. values: [base, bonus, allow, deduct, net]
      if (_rd != null) {
        for (Object _o : _rd) {
          model.Payroll _pr = (model.Payroll) _o;
          String _dn = _pr.getDepartmentName();
          boolean _isDirector = (_dn == null || _dn.trim().isEmpty());
          String _key = _isDirector ? "__GD__" : _dn.trim();
          if (!_deptMap.containsKey(_key)) _deptMap.put(_key, new double[5]);
          double[] _acc = _deptMap.get(_key);
          _acc[0] += _pr.getBaseSalary()       != null ? _pr.getBaseSalary().doubleValue()       : 0;
          _acc[1] += _pr.getBonusAmount()       != null ? _pr.getBonusAmount().doubleValue()      : 0;
          _acc[2] += _pr.getAllowanceAmount()   != null ? _pr.getAllowanceAmount().doubleValue()   : 0;
          _acc[3] += _pr.getTotalDeductionAll() != null ? _pr.getTotalDeductionAll().doubleValue(): 0;
          _acc[4] += _pr.getNetSalary()         != null ? _pr.getNetSalary().doubleValue()        : 0;
        }
      }
      /* sort: normal depts alphabetically, "__GD__" always last */
      java.util.List<String> _sortedKeys = new java.util.ArrayList<>(_deptMap.keySet());
      _sortedKeys.sort((a, b) -> {
          if ("__GD__".equals(a)) return 1;
          if ("__GD__".equals(b)) return -1;
          return a.compareTo(b);
      });
    %>
    <c:if test="${not empty reportData}">
    <script>
    /* window._deptChart — pre-aggregated server-side, ready for Chart.js */
    window._deptChart = {
      labels: [<%
        boolean _first = true;
        for (String _k : _sortedKeys) {
          String _lbl = "__GD__".equals(_k) ? "Giám đốc" : _k;
          // escape for JS string
          _lbl = _lbl.replace("\\", "\\\\").replace("'", "\\'");
          if (!_first) out.print(","); _first = false;
          out.print("'" + _lbl + "'");
        }
      %>],
      base:   [<% _first=true; for(String _k:_sortedKeys){if(!_first)out.print(",");_first=false;out.print(String.format(java.util.Locale.US,"%.2f",_deptMap.get(_k)[0]/1e6));} %>],
      bonus:  [<% _first=true; for(String _k:_sortedKeys){if(!_first)out.print(",");_first=false;out.print(String.format(java.util.Locale.US,"%.2f",_deptMap.get(_k)[1]/1e6));} %>],
      allow:  [<% _first=true; for(String _k:_sortedKeys){if(!_first)out.print(",");_first=false;out.print(String.format(java.util.Locale.US,"%.2f",_deptMap.get(_k)[2]/1e6));} %>],
      deduct: [<% _first=true; for(String _k:_sortedKeys){if(!_first)out.print(",");_first=false;out.print(String.format(java.util.Locale.US,"%.2f",_deptMap.get(_k)[3]/1e6));} %>],
      net:    [<% _first=true; for(String _k:_sortedKeys){if(!_first)out.print(",");_first=false;out.print(String.format(java.util.Locale.US,"%.2f",_deptMap.get(_k)[4]/1e6));} %>]
    };
    </script>
    </c:if>

    <!-- ═══ TABLE CARD ════════════════════════════════════════════════ -->
    <div class="tbl-card">

        <!-- Card header -->
        <div class="tc-hdr">
            <div class="tc-hdr-left">
                <div class="tc-hdr-icon"><i class="fas fa-table-list"></i></div>
                <span class="tc-title">Chi tiết bảng lương</span>
                <span class="tc-badge">${reportData.size()} nhân viên</span>
            </div>
            <div class="tc-hdr-right">
                <span class="period-tag">
                    <i class="fas fa-calendar-check"></i>
                    Tháng <fmt:formatNumber value="${selectedMonth}" minIntegerDigits="2" groupingUsed="false"/>/${selectedYear}
                </span>
                <button class="btn-ghost"
                        onclick="location.href='${pageContext.request.contextPath}/hr/master-payroll-report?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDepartmentId}'">
                    <i class="fas fa-rotate-right"></i> Làm mới
                </button>
            </div>
        </div>

        <!-- ── HAS DATA ── -->
        <c:if test="${not empty reportData}">

        <!-- Toolbar -->
        <div class="tc-toolbar">
            <div class="search-wrap">
                <i class="fas fa-magnifying-glass"></i>
                <input type="search" id="tblSearch" class="tbl-search"
                       placeholder="Tìm tên, mã NV, phòng ban…"
                       oninput="doFilter(this.value)"
                       aria-label="Tìm kiếm nhân viên">
            </div>
            <div class="pg-size-row">
                <span>Hiển thị</span>
                <select id="pgSize" onchange="changeSize(this.value)">
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option value="50">50</option>
                    <option value="9999">Tất cả</option>
                </select>
                <span>dòng / trang</span>
            </div>
        </div>

        <p class="scroll-note"><i class="fas fa-left-right"></i> Kéo ngang để xem đầy đủ</p>

        <!-- Table -->
        <div class="tbl-scroll">
        <table class="ptbl" id="mainTbl">
            <thead>
                <tr>
                    <th class="th-c" style="width:42px;">#</th>
                    <th class="th-c" style="min-width:88px;">Mã NV</th>
                    <th style="min-width:160px;">Họ và tên</th>
                    <th style="min-width:130px;">Phòng ban</th>
                    <th class="th-r" style="min-width:128px;">Lương cơ bản</th>
                    <th class="th-r" style="min-width:100px;">Thưởng</th>
                    <th class="th-r" style="min-width:100px;">Phụ cấp</th>
                    <th class="th-r g-deduct" style="min-width:118px;"
                        title="Khoản khấu trừ kỷ luật">Khấu trừ/Phạt</th>
                    <th class="th-r g-deduct" style="min-width:112px;"
                        title="Phần bảo hiểm nhân viên đóng">Bảo hiểm NV</th>
                    <th class="th-r g-deduct" style="min-width:104px;"
                        title="Thuế thu nhập cá nhân">Thuế TNCN</th>
                    <th class="th-r g-deduct" style="min-width:120px;">Tổng khoản trừ</th>
                    <th class="th-r g-net"    style="min-width:128px;">Thực lĩnh</th>
                    <th class="th-c"          style="min-width:108px;">Trạng thái</th>
                </tr>
            </thead>
            <tbody id="tblBody">
                <c:set var="stt" value="1"/>
                <c:forEach var="p" items="${reportData}">
                <tr data-q="${p.fullName} NV${p.userId} ${p.departmentName}">
                    <td class="td-c"><span class="stt">${stt}</span></td>
                    <td class="td-c">
                        <span class="emp-badge">NV<fmt:formatNumber value="${p.userId}" minIntegerDigits="4" groupingUsed="false"/></span>
                    </td>
                    <td><span class="emp-name">${p.fullName}</span></td>
                    <td>
                        <c:choose>
                            <c:when test="${p.departmentName eq 'Nhân sự'}">
                                <span class="dept-badge dept-ns">${p.departmentName}</span>
                            </c:when>
                            <c:when test="${p.departmentName eq 'Tài chính'}">
                                <span class="dept-badge dept-tc">${p.departmentName}</span>
                            </c:when>
                            <c:when test="${p.departmentName eq 'Xưởng sản xuất'}">
                                <span class="dept-badge dept-sx">${p.departmentName}</span>
                            </c:when>
                            <c:when test="${not empty p.departmentName}">
                                <span class="dept-badge">${p.departmentName}</span>
                            </c:when>
                            <c:otherwise>
                                <span style="color:var(--txt-4);font-size:.8rem;">—</span>
                            </c:otherwise>
                        </c:choose>
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
                    <td class="td-r money-total">
                        <fmt:formatNumber value="${p.totalDeductionAll}" type="number" groupingUsed="true"/> ₫
                    </td>
                    <td class="td-r money-net">
                        <fmt:formatNumber value="${p.netSalary}" type="number" groupingUsed="true"/> ₫
                    </td>
                    <td class="td-c">
                        <c:choose>
                            <c:when test="${p.status eq 'Paid'}">
                                <span class="st st-paid"><i class="fas fa-circle-check"></i> Đã thanh toán</span>
                            </c:when>
                            <c:when test="${p.status eq 'Approved'}">
                                <span class="st st-aprvd"><i class="fas fa-check"></i> Đã duyệt</span>
                            </c:when>
                            <c:when test="${p.status eq 'Pending'}">
                                <span class="st st-pend"><i class="fas fa-clock"></i> Chờ duyệt</span>
                            </c:when>
                            <c:otherwise>
                                <span class="st st-draft">${p.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                <c:set var="stt" value="${stt + 1}"/>
                </c:forEach>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="4" class="sum-label">Tổng cộng</td>
                    <td class="td-r">
                        <fmt:formatNumber value="${totalBase}" type="number" groupingUsed="true"/> ₫
                    </td>
                    <td class="td-r money-pos">
                        <fmt:formatNumber value="${totalBonus}" type="number" groupingUsed="true"/> ₫
                    </td>
                    <td class="td-r money-pos">
                        <fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/> ₫
                    </td>
                    <td class="td-r" colspan="3" style="color:var(--txt-4);">—</td>
                    <td class="td-r tfoot-total-neg">
                        <fmt:formatNumber value="${totalDeduction}" type="number" groupingUsed="true"/> ₫
                    </td>
                    <td class="td-r tfoot-net">
                        <fmt:formatNumber value="${totalNet}" type="number" groupingUsed="true"/> ₫
                    </td>
                    <td></td>
                </tr>
            </tfoot>
        </table>
        </div>

        <!-- Pagination -->
        <div class="pg-bar" id="pgBar">
            <div class="pg-info" id="pgInfo"></div>
            <div class="pg-nav"  id="pgNav"></div>
        </div>

        </c:if>

        <!-- ── EMPTY STATE ── -->
        <c:if test="${empty reportData}">
        <div class="empty-box">
            <div class="empty-icon"><i class="fas fa-file-invoice-dollar"></i></div>
            <p class="empty-title">Chưa có bảng lương đã duyệt</p>
            <p class="empty-desc">
                Không tìm thấy bảng lương ở trạng thái <strong>Đã duyệt</strong> hoặc
                <strong>Đã thanh toán</strong> trong
                Tháng <fmt:formatNumber value="${selectedMonth}" minIntegerDigits="2" groupingUsed="false"/>/${selectedYear}.
            </p>
            <p class="empty-hint">Kiểm tra lại kỳ lương, bộ lọc hoặc quy trình phê duyệt.</p>
            <div class="empty-btns">
                <button class="btn-sm-pri"
                        onclick="document.getElementById('filterForm').scrollIntoView({behavior:'smooth'})">
                    <i class="fas fa-filter"></i> Kiểm tra bộ lọc
                </button>
                <button class="btn-sm-ghost"
                        onclick="location.href='${pageContext.request.contextPath}/hr/master-payroll-report?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDepartmentId}'">
                    <i class="fas fa-rotate-right"></i> Làm mới
                </button>
            </div>
        </div>
        </c:if>

    </div><%-- /tbl-card --%>
    </div><%-- /pr-body --%>
    </div><%-- /main-content --%>
</div><%-- /dashboard-wrapper --%>

<script>
(function(){
  'use strict';
  var PS=10, cur=1, all=[], fil=[];

  function init(){
    var tb=document.getElementById('tblBody');
    if(!tb) return;
    tb.querySelectorAll('tr[data-q]').forEach(function(r){all.push(r);});
    fil=all.slice();
    go(1);
  }

  window.doFilter=function(q){
    q=q.toLowerCase().trim();
    fil=q?all.filter(function(r){return r.dataset.q.toLowerCase().indexOf(q)>=0;}):all.slice();
    go(1);
  };
  window.changeSize=function(v){PS=parseInt(v)||10;go(1);};

  function go(page){
    cur=page;
    var n=fil.length, s, e;
    if(PS>=9999){s=0;e=n;}else{s=(page-1)*PS;e=Math.min(s+PS,n);}
    all.forEach(function(r){r.classList.add('row-hidden');});
    fil.forEach(function(r,i){if(i>=s&&i<e)r.classList.remove('row-hidden');});
    info(s,e,n); pag(n);
  }

  function info(s,e,n){
    var el=document.getElementById('pgInfo'); if(!el)return;
    if(!n){el.textContent='Không tìm thấy kết quả';return;}
    if(PS>=9999){el.textContent='Hiển thị tất cả '+n+' nhân viên.';return;}
    el.textContent='Hiển thị '+(s+1)+' - '+e+' trong số '+n+' nhân viên.';
  }

  function pag(n){
    var nav=document.getElementById('pgNav'); if(!nav)return;
    nav.innerHTML='';
    if(PS>=9999||n===0)return;
    var tp=Math.ceil(n/PS);
    /* Prev */
    var prev=document.createElement('button');
    prev.className='pg-arrow'; prev.disabled=(cur===1);
    prev.innerHTML='<i class="fas fa-chevron-left"></i>';
    prev.onclick=function(){if(cur>1)go(cur-1);};
    nav.appendChild(prev);
    /* Next */
    var next=document.createElement('button');
    next.className='pg-arrow'; next.disabled=(cur===tp||tp<=1);
    next.innerHTML='<i class="fas fa-chevron-right"></i>';
    next.onclick=function(){if(cur<tp)go(cur+1);};
    nav.appendChild(next);
  }

  /* Export — sync filter values then submit hidden form */
  window.doExport=function(){
    var ff=document.getElementById('filterForm');
    if(!ff)return;
    document.getElementById('ef_m').value=ff.querySelector('[name=month]').value;
    document.getElementById('ef_y').value=ff.querySelector('[name=year]').value;
    document.getElementById('ef_d').value=ff.querySelector('[name=departmentId]').value;
    document.getElementById('exportForm').submit();
  };

  if(document.readyState==='loading')
    document.addEventListener('DOMContentLoaded',init);
  else init();
})();
</script>

<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>

<script>
(function(){
  'use strict';

  var COLORS = {
    base:   { bg: 'rgba(8,145,178,0.75)',   border: '#0891b2' },
    bonus:  { bg: 'rgba(5,150,105,0.70)',   border: '#059669' },
    allow:  { bg: 'rgba(16,185,129,0.55)',  border: '#10b981' },
    deduct: { bg: 'rgba(185,28,28,0.65)',   border: '#b91c1c' },
    net:    { bg: 'rgba(6,182,212,0.80)',   border: '#06b6d4' }
  };

  var LABELS_DS = ['Lương cơ bản', 'Thưởng', 'Phụ cấp', 'Tổng khấu trừ', 'Thực lĩnh'];
  var COLOR_KEYS = ['base', 'bonus', 'allow', 'deduct', 'net'];

  var chartInst = null;
  var currentMode = 'grouped';

  /* ── Read pre-aggregated data output by JSP server-side ── */
  function getChartData(){
    if (!window._deptChart) return null;
    var d = window._deptChart;
    if (!d.labels || !d.labels.length) return null;
    return d;
  }

  function buildDatasets(d){
    return COLOR_KEYS.map(function(key, ki){
      var col = COLORS[key];
      return {
        label: LABELS_DS[ki],
        data: d[key],          /* already in triệu ₫, computed server-side */
        backgroundColor: col.bg,
        borderColor: col.border,
        borderWidth: 1.5,
        borderRadius: 3,
        borderSkipped: false
      };
    });
  }

  function buildConfig(mode, depts, datasets){
    var isHBar = (mode === 'hbar');
    var isStacked = (mode === 'stacked');
    var cfg = {
      type: isHBar ? 'bar' : 'bar',
      data: {
        labels: depts,
        datasets: datasets
      },
      options: {
        indexAxis: isHBar ? 'y' : 'x',
        responsive: true,
        maintainAspectRatio: false,
        animation: { duration: 380, easing: 'easeOutQuart' },
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'rgba(17,24,39,0.92)',
            titleColor: '#f9fafb',
            bodyColor: '#d1d5db',
            padding: 12,
            cornerRadius: 8,
            borderColor: 'rgba(255,255,255,0.08)',
            borderWidth: 1,
            callbacks: {
              label: function(ctx){
                return ' ' + ctx.dataset.label + ': ' + ctx.parsed[isHBar?'x':'y'].toLocaleString('vi-VN') + ' triệu ₫';
              }
            }
          }
        },
        scales: {
          x: {
            stacked: isStacked,
            grid: { color: 'rgba(229,231,235,0.6)', lineWidth: 1 },
            ticks: {
              color: '#6b7280', font: { size: 11 },
              callback: isHBar ? function(v){ return v + ' tr'; } : undefined,
              maxRotation: 30
            }
          },
          y: {
            stacked: isStacked,
            grid: { color: 'rgba(229,231,235,0.6)', lineWidth: 1 },
            ticks: {
              color: '#6b7280', font: { size: 11 },
              callback: isHBar ? undefined : function(v){ return v + ' tr'; }
            }
          }
        }
      }
    };
    return cfg;
  }

  function buildLegend(){
    var leg = document.getElementById('chartLegend');
    if(!leg) return;
    leg.innerHTML = '';
    COLOR_KEYS.forEach(function(key, ki){
      var item = document.createElement('div');
      item.className = 'chart-legend-item';
      var dot = document.createElement('div');
      dot.className = 'chart-legend-dot';
      dot.style.background = COLORS[key].border;
      item.appendChild(dot);
      var lbl = document.createElement('span');
      lbl.textContent = LABELS_DS[ki];
      item.appendChild(lbl);
      leg.appendChild(item);
    });
  }

  function render(mode){
    var canvas = document.getElementById('deptSalaryChart');
    if(!canvas) return;

    var d = getChartData();
    if(!d) return;

    var datasets = buildDatasets(d);
    var cfg = buildConfig(mode, d.labels, datasets);

    if(chartInst){ chartInst.destroy(); chartInst = null; }
    chartInst = new Chart(canvas, cfg);
    buildLegend();
  }

  window.switchChart = function(mode){
    currentMode = mode;
    ['grouped','stacked','hbar'].forEach(function(m){
      var btn = document.getElementById('btn' + m.charAt(0).toUpperCase() + m.slice(1));
      if(btn) btn.classList.toggle('active', m === mode);
    });
    render(mode);
  };

  function init(){
    if(!document.getElementById('deptSalaryChart')) return;
    render(currentMode);
  }

  if(document.readyState === 'loading')
    document.addEventListener('DOMContentLoaded', init);
  else init();
})();
</script>

</main>
</body>
</html>

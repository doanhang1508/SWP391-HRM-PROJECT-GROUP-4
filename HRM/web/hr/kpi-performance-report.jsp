<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Báo cáo Đánh giá Năng lực (KPI)" scope="request"/>
<jsp:include page="../header.jsp"/>

<!-- Chart.js for visualizations -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ─────────────────────────────────────────────────────────
   DESIGN TOKENS & STYLE RULES (Matching HR theme)
   ───────────────────────────────────────────────────────── */
:root {
  --bg: #f8fafc;
  --surface: #ffffff;
  --border: #e2e8f0;
  --border-xs: #f1f5f9;
  --txt-1: #0f172a;
  --txt-2: #334155;
  --txt-3: #64748b;
  --txt-4: #94a3b8;
  --accent: #0f766e; /* Teal-700 */
  --accent-light: #0d9488; /* Teal-600 */
  --acc-bg: #f0fdfa;
  --acc-border: #ccfbf1;
  --ok: #15803d;
  --ok-bg: #f0fdf4;
  --ok-border: #dcfce7;
  --warn: #b45309;
  --warn-bg: #fffbeb;
  --warn-border: #fef3c7;
  --err: #b91c1c;
  --err-bg: #fef2f2;
  --err-border: #fee2e2;
  --radius: 12px;
  --radius-sm: 8px;
  --shadow-xs: 0 1px 3px rgba(0,0,0,.05), 0 1px 2px rgba(0,0,0,.03);
  --shadow-sm: 0 4px 6px -1px rgba(0,0,0,.05), 0 2px 4px -2px rgba(0,0,0,.05);
}

.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.main-content { flex: 1; min-width: 0; background: var(--bg); }
.pr-body { padding: 24px 28px 56px; max-width: 1600px; }

/* PAGE HEADER */
.pr-page-hdr {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 24px; flex-wrap: wrap; gap: 12px;
}
.pr-page-hdr-left h1 {
  font-size: 1.45rem; font-weight: 600; color: var(--txt-1);
  margin: 0; display: flex; align-items: center; gap: 10px;
}
.pr-page-hdr-left h1 i { font-size: 1.2rem; color: var(--accent); }
.pr-page-hdr-left p { font-size: .85rem; color: var(--txt-3); margin: 4px 0 0; }
.breadcrumb-row {
  display: flex; align-items: center; gap: 5px;
  font-size: .78rem; color: var(--txt-4);
}
.breadcrumb-row a { color: var(--txt-3); text-decoration: none; }
.breadcrumb-row a:hover { color: var(--accent); }
.breadcrumb-row .sep { color: var(--border); }

/* STATS GRID */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}
.stat-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: var(--shadow-xs);
  transition: transform 0.2s, box-shadow 0.2s;
}
.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-sm);
}
.stat-icon {
  width: 48px; height: 48px;
  border-radius: var(--radius-sm);
  display: flex; align-items: center; justify-content: center;
  font-size: 1.25rem;
}
.stat-info { display: flex; flex-direction: column; }
.stat-val { font-size: 1.35rem; font-weight: 700; color: var(--txt-1); line-height: 1.2; }
.stat-lbl { font-size: .75rem; color: var(--txt-3); text-transform: uppercase; margin-top: 4px; letter-spacing: 0.5px; }

/* CHARTS SECTION */
.charts-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}
.chart-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 20px;
  box-shadow: var(--shadow-xs);
}
.chart-card h3 {
  font-size: 0.95rem; font-weight: 600; color: var(--txt-1);
  margin: 0 0 16px; display: flex; align-items: center; gap: 8px;
}
.chart-card h3 i { color: var(--accent); }
.chart-container {
  position: relative; height: 260px; width: 100%;
}

/* FILTER ROW */
.pr-filter {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px 20px;
  box-shadow: var(--shadow-xs);
  margin-bottom: 20px;
  display: flex; flex-wrap: wrap; gap: 14px; align-items: flex-end;
}
.fg { display: flex; flex-direction: column; gap: 4px; }
.fg label {
  font-size: .7rem; color: var(--txt-3);
  text-transform: uppercase; letter-spacing: .5px; font-weight: 600;
}
.fg select, .fg input[type=text] {
  height: 38px; padding: 0 12px;
  border: 1px solid var(--border); border-radius: var(--radius-sm);
  background: var(--surface); color: var(--txt-1);
  font-size: .85rem; min-width: 160px;
  transition: border-color .15s, box-shadow .15s;
}
.fg select:focus, .fg input[type=text]:focus {
  outline: none; border-color: var(--accent);
  box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.15);
}
.btn-primary {
  height: 38px; padding: 0 18px;
  background: var(--accent); color: #fff;
  border: none; border-radius: var(--radius-sm);
  font-size: .85rem; font-weight: 500; cursor: pointer;
  display: inline-flex; align-items: center; gap: 8px;
  transition: background .2s, transform .1s;
  text-decoration: none;
}
.btn-primary:hover { background: var(--accent-light); }
.btn-primary:active { transform: scale(0.98); }

.btn-secondary {
  height: 38px; padding: 0 18px;
  background: #fff; color: var(--txt-2);
  border: 1px solid var(--border); border-radius: var(--radius-sm);
  font-size: .85rem; font-weight: 500; cursor: pointer;
  display: inline-flex; align-items: center; gap: 8px;
  transition: all .2s;
  text-decoration: none;
}
.btn-secondary:hover { background: var(--bg); border-color: var(--txt-4); }

/* TABLE CARD */
.tbl-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-xs);
  overflow: hidden;
  margin-bottom: 24px;
}
.tbl-card-hdr {
  padding: 16px 20px; border-bottom: 1px solid var(--border);
  display: flex; justify-content: space-between; align-items: center;
  flex-wrap: wrap; gap: 12px;
}
.tbl-card-hdr h2 { font-size: 0.95rem; font-weight: 600; color: var(--txt-1); margin: 0; }

.table-responsive { overflow-x: auto; }
table {
  width: 100%; border-collapse: collapse; text-align: left;
  font-size: .85rem; color: var(--txt-2);
}
th {
  background: var(--bg); color: var(--txt-3);
  font-weight: 600; font-size: .75rem; text-transform: uppercase;
  letter-spacing: .5px; padding: 12px 18px; border-bottom: 1px solid var(--border);
}
td {
  padding: 14px 18px; border-bottom: 1px solid var(--border-xs);
  vertical-align: middle;
}
tr:hover td { background: var(--border-xs); }

/* BADGES */
.badge {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 4px 10px; border-radius: 9999px;
  font-size: .75rem; font-weight: 600;
}
.badge-a { background: #e0f2fe; color: #0369a1; } /* Blue */
.badge-b { background: var(--ok-bg); color: var(--ok); } /* Green */
.badge-c { background: var(--warn-bg); color: var(--warn); } /* Orange */
.badge-d { background: var(--err-bg); color: var(--err); } /* Red */

.badge-pass { background: var(--ok-bg); color: var(--ok); border: 1px solid var(--ok-border); }
.badge-fail { background: var(--err-bg); color: var(--err); border: 1px solid var(--err-border); }

/* PAGINATION FOOTER */
.tbl-ftr {
  padding: 14px 20px; background: var(--bg);
  border-top: 1px solid var(--border);
  display: flex; justify-content: space-between; align-items: center;
  flex-wrap: wrap; gap: 12px;
}
.tbl-ftr-left { font-size: .8rem; color: var(--txt-3); }
.tbl-ftr-right { display: flex; align-items: center; gap: 12px; }
.pg-ctrl { display: flex; align-items: center; gap: 6px; }
.pg-arrow {
  width: 32px; height: 32px; border-radius: var(--radius-sm);
  border: 1px solid var(--border); background: #fff;
  color: var(--txt-2); display: flex; align-items: center; justify-content: center;
  cursor: pointer; transition: all .15s; font-size: 0.75rem;
}
.pg-arrow:hover:not(:disabled) { border-color: var(--accent); color: var(--accent); }
.pg-arrow:disabled { opacity: 0.4; cursor: not-allowed; }

.row-hidden { display: none !important; }
</style>

<!-- Hidden Export Form -->
<form id="exportForm" action="${pageContext.request.contextPath}/hr/kpi-performance-report" method="GET" style="display:none;">
    <input type="hidden" name="action" value="exportExcel">
    <input type="hidden" id="ef_cycle" name="cycleId" value="${selectedCycleId}">
    <input type="hidden" id="ef_dept" name="departmentId" value="${selectedDepartmentId}">
</form>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="kpi-performance-report"/>
    </jsp:include>

    <div class="main-content">
    <div class="pr-body">

        <!-- ═══ PAGE HEADER ══════════════════════════════════════════════ -->
        <div class="pr-page-hdr">
            <div class="pr-page-hdr-left">
                <h1><i class="fas fa-chart-bar"></i> Báo cáo Đánh giá Năng lực (KPI)</h1>
                <p>Báo cáo thành tích cá nhân làm căn cứ xét thưởng, tăng lương và kỷ luật</p>
            </div>
            <div class="breadcrumb-row">
                <a href="${pageContext.request.contextPath}/dashboard">
                    <i class="fas fa-home"></i> Bảng điều khiển
                </a>
                <span class="sep">/</span>
                <span>Báo cáo KPI</span>
            </div>
        </div>

        <!-- ═══ STATS GRID ═══════════════════════════════════════════════ -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon" style="background:#e0f2fe; color:#0284c7;">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-val">${totalEmployees}</span>
                    <span class="stat-lbl">Tổng nhân sự</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:#dcfce7; color:#16a34a;">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-val">${passCount}</span>
                    <span class="stat-lbl">Đạt KPI (>=5.0)</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:#fee2e2; color:#dc2626;">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-val">${failCount}</span>
                    <span class="stat-lbl">Chưa đạt (<5.0)</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:#ccfbf1; color:#0d9488;">
                    <i class="fas fa-percent"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-val">${passRate}%</span>
                    <span class="stat-lbl">Tỷ lệ hoàn thành</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:#fef3c7; color:#d97706;">
                    <i class="fas fa-crown"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-val" title="${topPerformer}"><fmt:formatNumber value="${topPerformerScore}" pattern="#,##0.00"/>đ</span>
                    <span class="stat-lbl" style="white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:150px;">
                        Top: ${topPerformer}
                    </span>
                </div>
            </div>
        </div>

        <!-- ═══ VISUAL CHARTS ════════════════════════════════════════════ -->
        <div class="charts-row">
            <div class="chart-card">
                <h3><i class="fas fa-chart-area"></i> Biểu đồ phân bố điểm số</h3>
                <div class="chart-container">
                    <canvas id="scoreDistChart"></canvas>
                </div>
            </div>
            <div class="chart-card">
                <h3><i class="fas fa-chart-column"></i> Điểm trung bình theo Phòng ban</h3>
                <div class="chart-container">
                    <canvas id="deptAvgChart"></canvas>
                </div>
            </div>
        </div>

        <!-- ═══ FILTER ROW ═══════════════════════════════════════════════ -->
        <form id="filterForm" action="${pageContext.request.contextPath}/hr/kpi-performance-report" method="GET" class="pr-filter">
            <div class="fg">
                <label>Kỳ đánh giá</label>
                <select name="cycleId" onchange="this.form.submit()">
                    <option value="-1" ${selectedCycleId == -1 ? 'selected' : ''}>Tất cả các kỳ</option>
                    <c:forEach var="c" items="${allCycles}">
                        <option value="${c.cycleId}" ${selectedCycleId == c.cycleId ? 'selected' : ''}>
                            ${c.name}
                        </option>
                    </c:forEach>
                </select>
            </div>
            
            <c:if test="${viewAll}">
                <div class="fg">
                    <label>Phòng ban</label>
                    <select name="departmentId" onchange="this.form.submit()">
                        <option value="-1" ${selectedDepartmentId == -1 ? 'selected' : ''}>Tất cả phòng ban</option>
                        <c:forEach var="d" items="${departments}">
                            <option value="${d.departmentId}" ${selectedDepartmentId == d.departmentId ? 'selected' : ''}>
                                ${d.departmentName}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </c:if>

            <div class="fg" style="margin-left: auto;">
                <button type="button" class="btn-secondary" onclick="doExport()" ${empty reportData ? 'disabled' : ''}>
                    <i class="fas fa-file-excel"></i> Xuất Excel thành tích
                </button>
                <button type="submit" class="btn-primary">
                    <i class="fas fa-search"></i> Tra cứu
                </button>
            </div>
        </form>

        <!-- ═══ DATA TABLE CARD ══════════════════════════════════════════ -->
        <div class="tbl-card">
            <div class="tbl-card-hdr">
                <h2>Chi tiết kết quả đánh giá KPI</h2>
                <div style="display:flex; align-items:center; gap:8px;">
                    <div class="fg" style="margin-bottom:0;">
                        <input type="text" id="searchInput" placeholder="Tìm kiếm nhanh..." onkeyup="doFilter(this.value)" style="height:34px; width:200px;">
                    </div>
                </div>
            </div>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th style="width: 50px;">STT</th>
                            <th style="width: 100px;">Mã NV</th>
                            <th>Họ và tên</th>
                            <th>Phòng ban</th>
                            <th style="text-align: right; width: 140px;">Điểm đánh giá</th>
                            <th style="width: 100px; text-align: center;">Xếp loại</th>
                            <th style="width: 120px; text-align: center;">Trạng thái</th>
                            <th>Đề xuất Thưởng/Phạt</th>
                            <th>Người đánh giá</th>
                        </tr>
                    </thead>
                    <tbody id="tblBody">
                        <c:choose>
                            <c:when test="${empty reportData}">
                                <tr>
                                    <td colspan="9" style="text-align:center; padding:32px; color:var(--txt-3);">
                                        Không tìm thấy dữ liệu đánh giá KPI phù hợp với bộ lọc.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="e" items="${reportData}" varStatus="status">
                                    <tr data-q="${e.employeeName} ${e.departmentName}">
                                        <td>${status.index + 1}</td>
                                        <td><strong>NV<fmt:formatNumber value="${e.employeeId}" pattern="0000"/></strong></td>
                                        <td><strong>${e.employeeName}</strong></td>
                                        <td>${not empty e.departmentName ? e.departmentName : '—'}</td>
                                        <td style="text-align: right; font-weight: 700; color: var(--accent);">
                                            <fmt:formatNumber value="${e.weightedScore}" pattern="#,##0.00"/>
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${e.weightedScore >= 9.0}">
                                                    <span class="badge badge-a">Hạng A</span>
                                                </c:when>
                                                <c:when test="${e.weightedScore >= 7.0}">
                                                    <span class="badge badge-b">Hạng B</span>
                                                </c:when>
                                                <c:when test="${e.weightedScore >= 5.0}">
                                                    <span class="badge badge-c">Hạng C</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-d">Hạng D</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${e.weightedScore >= 5.0}">
                                                    <span class="badge badge-pass"><i class="fas fa-check"></i> Đạt</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-fail"><i class="fas fa-exclamation-triangle"></i> Không đạt</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${e.weightedScore >= 9.0}">
                                                    <span style="color:#0369a1; font-weight:600;"><i class="fas fa-gift"></i> Thưởng 10-15% lương</span>
                                                </c:when>
                                                <c:when test="${e.weightedScore >= 7.0}">
                                                    <span style="color:var(--ok); font-weight:600;"><i class="fas fa-gift"></i> Thưởng 5% lương</span>
                                                </c:when>
                                                <c:when test="${e.weightedScore >= 5.0}">
                                                    <span style="color:var(--txt-3);">Không thưởng/phạt</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:var(--err); font-weight:600;"><i class="fas fa-exclamation-circle"></i> Xem xét kỷ luật</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${not empty e.managerName ? e.managerName : '—'}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Pagination footer -->
            <div class="tbl-ftr">
                <div class="tbl-ftr-left" id="pgInfo"></div>
                <div class="tbl-ftr-right">
                    <div class="fg" style="margin-bottom:0; flex-direction:row; align-items:center; gap:8px;">
                        <label style="margin:0;">Số hàng:</label>
                        <select onchange="changeSize(this.value)" style="height:30px; min-width:64px; padding:0 6px;">
                            <option value="10">10</option>
                            <option value="25">25</option>
                            <option value="50">50</option>
                            <option value="9999">Tất cả</option>
                        </select>
                    </div>
                    <div class="pg-ctrl" id="pgNav"></div>
                </div>
            </div>
        </div>

    </div><%-- /pr-body --%>
    </div><%-- /main-content --%>
</div><%-- /dashboard-wrapper --%>

<script>
(function() {
  'use strict';
  
  // Client-side pagination logic
  var PS = 10, cur = 1, all = [], fil = [];

  function initTable() {
    var tb = document.getElementById('tblBody');
    if (!tb) return;
    tb.querySelectorAll('tr[data-q]').forEach(function(r) {
      all.push(r);
    });
    fil = all.slice();
    go(1);
  }

  window.doFilter = function(q) {
    q = q.toLowerCase().trim();
    fil = q ? all.filter(function(r) {
      return r.dataset.q.toLowerCase().indexOf(q) >= 0;
    }) : all.slice();
    go(1);
  };

  window.changeSize = function(v) {
    PS = parseInt(v) || 10;
    go(1);
  };

  function go(page) {
    cur = page;
    var n = fil.length, s, e;
    if (PS >= 9999) {
      s = 0; e = n;
    } else {
      s = (page - 1) * PS;
      e = Math.min(s + PS, n);
    }
    all.forEach(function(r) {
      r.classList.add('row-hidden');
    });
    fil.forEach(function(r, i) {
      if (i >= s && i < e) r.classList.remove('row-hidden');
    });
    info(s, e, n);
    pag(n);
  }

  function info(s, e, n) {
    var el = document.getElementById('pgInfo');
    if (!el) return;
    if (!n) {
      el.textContent = 'Không tìm thấy kết quả';
      return;
    }
    if (PS >= 9999) {
      el.textContent = 'Hiển thị tất cả ' + n + ' dòng.';
      return;
    }
    el.textContent = 'Hiển thị ' + (s + 1) + ' - ' + e + ' trong số ' + n + ' dòng.';
  }

  function pag(n) {
    var nav = document.getElementById('pgNav');
    if (!nav) return;
    nav.innerHTML = '';
    if (PS >= 9999 || n === 0) return;
    var tp = Math.ceil(n / PS);
    
    var prev = document.createElement('button');
    prev.className = 'pg-arrow';
    prev.disabled = (cur === 1);
    prev.innerHTML = '<i class="fas fa-chevron-left"></i>';
    prev.onclick = function() {
      if (cur > 1) go(cur - 1);
    };
    nav.appendChild(prev);
    
    var next = document.createElement('button');
    next.className = 'pg-arrow';
    next.disabled = (cur === tp || tp <= 1);
    next.innerHTML = '<i class="fas fa-chevron-right"></i>';
    next.onclick = function() {
      if (cur < tp) go(cur + 1);
    };
    nav.appendChild(next);
  }

  window.doExport = function() {
    var ff = document.getElementById('filterForm');
    if (!ff) return;
    document.getElementById('ef_cycle').value = ff.querySelector('[name=cycleId]').value;
    var dSelect = ff.querySelector('[name=departmentId]');
    document.getElementById('ef_dept').value = dSelect ? dSelect.value : '-1';
    document.getElementById('exportForm').submit();
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initTable);
  } else {
    initTable();
  }

  // Render Visual Charts using Chart.js
  try {
    // Score Distribution Chart
    var scoreCtx = document.getElementById('scoreDistChart').getContext('2d');
    var scoreData = ${scoreDistribution};
    new Chart(scoreCtx, {
      type: 'line',
      data: {
        labels: ['0-0.9', '1-1.9', '2-2.9', '3-3.9', '4-4.9', '5-5.9', '6-6.9', '7-7.9', '8-8.9', '9-10'],
        datasets: [{
          label: 'Số lượng nhân sự',
          data: scoreData,
          borderColor: '#0d9488',
          backgroundColor: 'rgba(13, 148, 136, 0.1)',
          borderWidth: 2,
          fill: true,
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { stepSize: 1 }
          }
        }
      }
    });

    // Department Averages Chart
    var deptCtx = document.getElementById('deptAvgChart').getContext('2d');
    var deptLabels = ${deptNames};
    var deptAvgs = ${deptAvgs};
    new Chart(deptCtx, {
      type: 'bar',
      data: {
        labels: deptLabels,
        datasets: [{
          label: 'Điểm trung bình KPI',
          data: deptAvgs,
          backgroundColor: '#0f766e',
          borderRadius: 4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 10
          }
        }
      }
    });
  } catch (err) {
    console.error("Lỗi vẽ biểu đồ: ", err);
  }

})();
</script>

</main>
</body>
</html>

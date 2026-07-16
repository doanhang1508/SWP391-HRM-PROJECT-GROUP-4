<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="../header.jsp" />

<style>
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content      { flex: 1; width: calc(100% - 260px); overflow-x: hidden; }

    .rp-header {
        padding: 20px 28px 18px;
        display: flex; justify-content: space-between; align-items: flex-end;
        flex-wrap: wrap; gap: 14px;
        background: #fff; border-bottom: 1px solid #e2e8f0;
    }
    .rp-title { font-size: 1.15rem; font-weight: 700; color: #0f172a; margin: 0 0 3px; }
    .rp-sub   { font-size: 0.8rem; color: #64748b; margin: 0; }

    .rp-filter { display: flex; align-items: flex-end; gap: 10px; flex-wrap: wrap; }
    .rp-filter .fg label { display: block; font-size: 0.72rem; font-weight: 600; color: #475569; margin-bottom: 4px; }
    .rp-filter input[type="date"], .rp-filter select {
        padding: 7px 11px; border: 1.5px solid #e2e8f0; border-radius: 7px;
        font-size: 0.82rem; color: #0f172a; background: #f8fafc; outline: none;
        font-family: 'Be Vietnam Pro', sans-serif; transition: border-color 0.2s;
    }
    .rp-filter input:focus, .rp-filter select:focus { border-color: #0d9488; background: #fff; }
    .btn-filter {
        padding: 8px 18px; background: #0d9488; color: #fff;
        border: none; border-radius: 7px; font-size: 0.82rem; font-weight: 600;
        cursor: pointer; display: inline-flex; align-items: center; gap: 6px;
        font-family: 'Be Vietnam Pro', sans-serif; transition: background 0.2s;
    }
    .btn-filter:hover { background: #0f766e; }

    .rp-body { padding: 22px 28px; background: #f1f5f9; min-height: calc(100vh - 130px); }

    .stat-row { display: grid; grid-template-columns: repeat(4,1fr); gap: 13px; margin-bottom: 20px; }
    .sc { background: #fff; border-radius: 10px; padding: 16px 18px; border: 1px solid #e2e8f0; }
    .sc-label { font-size: 0.76rem; color: #64748b; font-weight: 500; margin-bottom: 6px; }
    .sc-val   { font-size: 1.9rem; font-weight: 800; color: #0f172a; line-height: 1; }
    .sc-val.red   { color: #dc2626; }
    .sc-val.amber { color: #d97706; }
    .sc-val.teal  { color: #0d9488; }

    .charts-row { display: grid; grid-template-columns: 1fr 300px; gap: 14px; margin-bottom: 20px; }
    .chart-card { background: #fff; border-radius: 10px; border: 1px solid #e2e8f0; padding: 18px 22px; }
    .chart-card-title { font-size: 0.8rem; font-weight: 600; color: #475569; margin-bottom: 14px; }

    .detail-card { background: #fff; border-radius: 10px; border: 1px solid #e2e8f0; overflow: hidden; }
    .detail-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 18px; border-bottom: 1px solid #f1f5f9; }
    .detail-title { font-size: 0.84rem; font-weight: 600; color: #1e293b; }
    .btn-excel {
        display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px;
        background: #fff; border: 1.5px solid #0d9488; color: #0d9488;
        border-radius: 7px; font-size: 0.78rem; font-weight: 600;
        cursor: pointer; font-family: 'Be Vietnam Pro', sans-serif; transition: all 0.2s;
    }
    .btn-excel:hover { background: #0d9488; color: #fff; }

    .dt { width: 100%; border-collapse: collapse; }
    .dt th { padding: 10px 16px; text-align: left; font-size: 0.76rem; font-weight: 600; color: #64748b; background: #f8fafc; border-bottom: 1px solid #e2e8f0; white-space: nowrap; }
    .dt td { padding: 11px 16px; font-size: 0.82rem; color: #1e293b; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
    .dt tbody tr:hover td { background: #f8fafc; }
    .dt tbody tr:last-child td { border-bottom: none; }

    .id-chip { font-size: 0.78rem; font-weight: 700; color: #0f172a; }
    .sb { display: inline-block; padding: 2px 10px; border-radius: 100px; font-size: 0.72rem; font-weight: 600; white-space: nowrap; }
    .sb-expired  { background: #fef2f2; color: #b91c1c; }
    .sb-critical { background: #fff7ed; color: #c2410c; }
    .sb-warning  { background: #fefce8; color: #92400e; }
    .sb-safe     { background: #f0fdf4; color: #166534; }
    .sb-noend    { background: #f0f9ff; color: #0369a1; }

    .empty-row td { text-align: center; padding: 48px; color: #94a3b8; font-size: 0.875rem; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="hr-report" />
    </jsp:include>

    <div class="main-content">

        <%-- Page header + filter --%>
        <div class="rp-header">
            <div>
                <h1 class="rp-title">
                    <i class="fas fa-chart-bar" style="color:#0d9488;margin-right:7px;"></i>
                    Báo cáo thống kê hợp đồng
                </h1>
                <p class="rp-sub">Phân tích hợp đồng theo khoảng thời gian và phòng ban</p>
            </div>
            <form action="${pageContext.request.contextPath}/hr/report" method="GET" id="filterForm" class="rp-filter">
                <div class="fg">
                    <label>Từ ngày</label>
                    <input type="date" name="fromDate" value="${fromDate}">
                </div>
                <div class="fg">
                    <label>Đến ngày</label>
                    <input type="date" name="toDate" value="${toDate}">
                </div>
                <div class="fg">
                    <label>Phòng ban</label>
                    <select name="departmentId">
                        <option value="-1">Tất cả phòng ban</option>
                        <c:forEach var="d" items="${departments}">
                            <option value="${d.departmentId}" ${departmentId == d.departmentId ? 'selected' : ''}>${d.departmentName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="fg">
                    <label style="visibility:hidden;">x</label>
                    <button type="submit" class="btn-filter" id="btnFilter">
                        <i class="fas fa-search"></i> Lọc
                    </button>
                </div>
            </form>
        </div>

        <div class="rp-body">

            <%-- Stat cards --%>
            <c:set var="totalCount"    value="${reportData.size()}" />
            <c:set var="expiredCount"  value="0" />
            <c:set var="criticalCount" value="0" />
            <c:set var="safeCount"     value="0" />
            <c:forEach var="row" items="${reportData}">
                <c:if test="${row.daysLeft < 0}">                              <c:set var="expiredCount"  value="${expiredCount + 1}" /></c:if>
                <c:if test="${row.daysLeft >= 0 and row.daysLeft <= 30}">      <c:set var="criticalCount" value="${criticalCount + 1}" /></c:if>
                <c:if test="${row.daysLeft > 30 and row.daysLeft < 99999}">    <c:set var="safeCount"     value="${safeCount + 1}" /></c:if>
                <c:if test="${row.daysLeft >= 99999}">                         <c:set var="safeCount"     value="${safeCount + 1}" /></c:if>
            </c:forEach>

            <div class="stat-row">
                <div class="sc"><div class="sc-label">Tổng hợp đồng hiện lực</div><div class="sc-val">${totalCount}</div></div>
                <div class="sc"><div class="sc-label">Đã quá hạn</div><div class="sc-val red">${expiredCount}</div></div>
                <div class="sc"><div class="sc-label">Sắp hết hạn (≤ 30 ngày)</div><div class="sc-val amber">${criticalCount}</div></div>
                <div class="sc"><div class="sc-label">Còn thời gian (> 30 ngày)</div><div class="sc-val teal">${safeCount}</div></div>
            </div>

            <%-- Charts --%>
            <div class="charts-row">
                <div class="chart-card">
                    <div class="chart-card-title">Số hợp đồng theo trạng thái, chia theo phòng ban</div>
                    <div style="position:relative;height:220px;" id="barWrap">
                        <div id="barEmpty" style="display:flex;align-items:center;justify-content:center;height:100%;color:#94a3b8;font-size:0.82rem;flex-direction:column;gap:6px;">
                            <i class="fas fa-chart-bar" style="font-size:2rem;color:#e2e8f0;"></i>
                            Chưa có dữ liệu
                        </div>
                        <canvas id="barChart" style="display:none;"></canvas>
                    </div>
                </div>
                <div class="chart-card">
                    <div class="chart-card-title">Tỷ lệ theo loại hợp đồng</div>
                    <div style="position:relative;height:220px;" id="donutWrap">
                        <div id="donutEmpty" style="display:flex;align-items:center;justify-content:center;height:100%;color:#94a3b8;font-size:0.82rem;flex-direction:column;gap:6px;">
                            <i class="fas fa-chart-pie" style="font-size:2rem;color:#e2e8f0;"></i>
                            Chưa có dữ liệu
                        </div>
                        <canvas id="donutChart" style="display:none;position:absolute;top:0;left:0;width:100%;height:100%;"></canvas>
                    </div>
                </div>
            </div>

            <%-- Detail table --%>
            <div class="detail-card">
                <div class="detail-header">
                    <span class="detail-title">Chi tiết hợp đồng &nbsp;&middot;&nbsp; <strong>${totalCount}</strong> bản ghi</span>
                    <form action="${pageContext.request.contextPath}/hr/report" method="POST" id="exportForm" style="margin:0;">
                        <input type="hidden" name="action"       value="exportExcel">
                        <input type="hidden" name="fromDate"     value="${fromDate}">
                        <input type="hidden" name="toDate"       value="${toDate}">
                        <input type="hidden" name="departmentId" value="${departmentId}">
                        <button type="submit" class="btn-excel" id="btnExcel">
                            <i class="fas fa-download"></i> Xuất Excel
                        </button>
                    </form>
                </div>
                <div style="overflow-x:auto;">
                    <table class="dt">
                        <thead>
                            <tr>
                                <th>Mã NV</th><th>Họ tên</th><th>Phòng ban</th>
                                <th>Loại HĐ</th><th>Ngày hết hạn</th><th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty reportData}">
                                    <tr class="empty-row">
                                        <td colspan="6">
                                            <i class="fas fa-folder-open" style="font-size:1.5rem;display:block;margin-bottom:8px;color:#cbd5e1;"></i>
                                            Không có dữ liệu trong khoảng thời gian đã chọn
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="row" items="${reportData}">
                                        <tr>
                                            <td><span class="id-chip">NV<fmt:formatNumber value="${row.userId}" pattern="0000"/></span></td>
                                            <td style="font-weight:600;">${row.fullName}</td>
                                            <td>${row.departmentName}</td>
                                            <td style="color:#475569;">${row.typeName}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${row.endDate != null}"><fmt:formatDate value="${row.endDate}" pattern="dd/MM/yyyy"/></c:when>
                                                    <c:otherwise>Vô thời hạn</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${row.daysLeft >= 99999}"><span class="sb sb-noend">Vô thời hạn</span></c:when>
                                                    <c:when test="${row.daysLeft < 0}">    <span class="sb sb-expired">Đã quá hạn</span></c:when>
                                                    <c:when test="${row.daysLeft <= 7}">   <span class="sb sb-critical">Còn ${row.daysLeft} ngày</span></c:when>
                                                    <c:when test="${row.daysLeft <= 30}">  <span class="sb sb-warning">Sắp hết hạn</span></c:when>
                                                    <c:otherwise>                          <span class="sb sb-safe">Còn hiệu lực</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><%-- end rp-body --%>
    </div><%-- end main-content --%>
</div><%-- end dashboard-wrapper --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
(function() {
    var rows     = document.querySelectorAll('.dt tbody tr:not(.empty-row)');
    var deptMap  = {};
    var typeMap  = {};

    rows.forEach(function(tr) {
        var cells = tr.querySelectorAll('td');
        if (cells.length < 6) return;
        var dept  = cells[2].textContent.trim();
        var type  = cells[3].textContent.trim();
        var badge = cells[5].textContent.trim();

        if (!deptMap[dept]) deptMap[dept] = { expired:0, expiring:0, safe:0 };
        if      (badge.includes('quá hạn'))                                    deptMap[dept].expired++;
        else if (badge.includes('ngày') || badge.includes('Sắp hết hạn'))      deptMap[dept].expiring++;
        else                                                                    deptMap[dept].safe++;

        if (!typeMap[type]) typeMap[type] = 0;
        typeMap[type]++;
    });

    var deptLabels = Object.keys(deptMap);
    var typeLabels = Object.keys(typeMap);

    if (typeof Chart === 'undefined') return;
    Chart.defaults.font.family = "'Be Vietnam Pro', sans-serif";
    Chart.defaults.font.size   = 11;

    if (deptLabels.length > 0) {
        document.getElementById('barEmpty').style.display = 'none';
        var bc = document.getElementById('barChart');
        bc.style.display = 'block';
        new Chart(bc, {
            type: 'bar',
            data: {
                labels: deptLabels,
                datasets: [
                    { label:'Đã quá hạn',   data: deptLabels.map(function(d){ return deptMap[d].expired; }),  backgroundColor:'#ef4444', borderRadius:3 },
                    { label:'Sắp hết hạn',  data: deptLabels.map(function(d){ return deptMap[d].expiring; }), backgroundColor:'#f59e0b', borderRadius:3 },
                    { label:'Còn hiệu lực', data: deptLabels.map(function(d){ return deptMap[d].safe; }),     backgroundColor:'#0d9488', borderRadius:3 }
                ]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { position:'top', labels:{ boxWidth:11, padding:12 } } },
                scales: {
                    x: { stacked:true, grid:{display:false}, ticks:{color:'#64748b'} },
                    y: { stacked:true, beginAtZero:true, grid:{color:'#f1f5f9'}, ticks:{color:'#64748b', stepSize:1} }
                }
            }
        });
    }

    if (typeLabels.length > 0) {
        document.getElementById('donutEmpty').style.display = 'none';
        var dc = document.getElementById('donutChart');
        dc.style.display = 'block';
        new Chart(dc, {
            type: 'doughnut',
            data: {
                labels: typeLabels,
                datasets: [{
                    data: typeLabels.map(function(t){ return typeMap[t]; }),
                    backgroundColor: ['#0d9488','#3b82f6','#f59e0b','#8b5cf6','#ef4444'],
                    borderWidth: 2, borderColor: '#fff', hoverOffset: 5
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false, cutout: '60%',
                plugins: {
                    legend: { position:'bottom', labels:{ boxWidth:10, padding:8, font:{size:10} } },
                    tooltip: { callbacks: { label: function(ctx) {
                        var total = ctx.dataset.data.reduce(function(a,b){ return a+b; }, 0);
                        return ' ' + ctx.label + ': ' + ctx.parsed + ' (' + Math.round(ctx.parsed/total*100) + '%)';
                    }}}
                }
            }
        });
    }

    document.getElementById('filterForm').addEventListener('submit', function() {
        var b = document.getElementById('btnFilter');
        b.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lọc...';
        b.disabled  = true;
    });
    document.getElementById('exportForm').addEventListener('submit', function() {
        var b = document.getElementById('btnExcel');
        b.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang xuất...';
        b.disabled  = true;
        setTimeout(function(){ b.innerHTML = '<i class="fas fa-download"></i> Xuất Excel'; b.disabled = false; }, 3000);
    });
})();
</script>

<jsp:include page="../footer.jsp" />

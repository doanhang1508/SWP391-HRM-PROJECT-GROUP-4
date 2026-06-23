<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Bảng Công Cá Nhân - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
:root {
    --pri: #6366f1; --pri-d: #4f46e5; --pri-l: rgba(99,102,241,.1);
    --ok: #10b981; --ok-l: rgba(16,185,129,.1);
    --ng: #ef4444; --ng-l: rgba(239,68,68,.1);
    --warn: #f59e0b; --warn-l: rgba(245,158,11,.1);
    --info: #3b82f6; --info-l: rgba(59,130,246,.1);
    --bg: #f0f2fa; --card: #fff; --txt: #1e293b;
    --muted: #64748b; --border: #e8ecf4;
}
* { box-sizing: border-box; }
body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--txt); }
.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.main-content { flex: 1; padding: 32px 36px; width: calc(100% - 260px); }

/* Page Header */
.page-header {
    display: flex; justify-content: space-between;
    align-items: flex-start; margin-bottom: 28px;
    gap: 16px; flex-wrap: wrap;
}
.page-title { font-size: 1.55rem; font-weight: 800; color: var(--txt); margin: 0; letter-spacing: -.3px; }
.breadcrumb-c { font-size: .82rem; color: var(--muted); margin: 5px 0 0; }
.breadcrumb-c a { color: var(--pri); text-decoration: none; font-weight: 500; }

/* Empty state */
.empty-state {
    text-align: center; padding: 80px 24px;
    background: var(--card); border-radius: 18px;
    border: 1px solid var(--border);
}
.empty-state i { font-size: 3.5rem; color: #cbd5e1; margin-bottom: 16px; }
.empty-state h3 { font-size: 1.1rem; font-weight: 700; color: var(--muted); }
.empty-state p { font-size: .9rem; color: #94a3b8; }

/* ─── Period Card ─── */
.period-card {
    background: var(--card);
    border-radius: 18px;
    border: 1px solid var(--border);
    box-shadow: 0 4px 24px rgba(0,0,0,.04);
    margin-bottom: 22px;
    overflow: hidden;
    transition: box-shadow .2s;
}
.period-card:hover { box-shadow: 0 8px 32px rgba(0,0,0,.08); }

/* Card Header row */
.period-head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 20px 26px; flex-wrap: wrap; gap: 14px;
    background: linear-gradient(135deg, #fafbff, #f3f5ff);
    border-bottom: 1px solid var(--border);
    cursor: pointer; user-select: none;
}
.period-head:hover { background: linear-gradient(135deg, #f5f7ff, #eef0ff); }

.period-label {
    display: flex; align-items: center; gap: 12px;
}
.period-label .p-icon {
    width: 44px; height: 44px; border-radius: 12px;
    background: linear-gradient(135deg, var(--pri), var(--pri-d));
    color: #fff; display: flex; align-items: center;
    justify-content: center; font-size: 1rem;
    box-shadow: 0 4px 12px rgba(99,102,241,.3);
    flex-shrink: 0;
}
.period-label .p-title { font-size: 1.05rem; font-weight: 800; color: var(--txt); }
.period-label .p-sub { font-size: .75rem; color: var(--muted); font-weight: 500; margin-top: 2px; }

/* Mini stat chips inline */
.period-stats {
    display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
}
.pstat {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 5px 13px; border-radius: 8px;
    font-size: .78rem; font-weight: 700;
}
.pstat-ok { background: var(--ok-l); color: var(--ok); }
.pstat-warn { background: var(--warn-l); color: #b45309; }
.pstat-ng { background: var(--ng-l); color: var(--ng); }
.pstat-info { background: var(--info-l); color: var(--info); }

/* Right side of header: dept status + toggle btn */
.period-head-right { display: flex; align-items: center; gap: 12px; }

/* Dept status pill */
.dept-pill {
    display: inline-flex; align-items: center; gap: 7px;
    padding: 5px 13px; border-radius: 50px;
    font-size: .74rem; font-weight: 600;
}
.dp-draft { background: rgba(100,116,139,.1); color: #475569; }
.dp-pending { background: var(--warn-l); color: #b45309; }
.dp-confirmed { background: var(--ok-l); color: #047857; }
.dp-approved { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
.dp-rejected { background: var(--ng-l); color: #b91c1c; }

/* Toggle button */
.btn-detail {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 9px 18px; border-radius: 9px;
    font-size: .82rem; font-weight: 600;
    border: 1.5px solid var(--pri); cursor: pointer;
    background: var(--pri-l); color: var(--pri);
    transition: all .2s; white-space: nowrap;
}
.btn-detail:hover { background: var(--pri); color: #fff; }
.btn-detail .chev { transition: transform .28s; font-size: .75rem; }
.btn-detail.is-open { background: var(--pri); color: #fff; }
.btn-detail.is-open .chev { transform: rotate(180deg); }

/* ─── Filter bar (inside each card, shown when open) ─── */
.period-filter {
    padding: 14px 26px;
    background: #fafbfe;
    border-bottom: 1px solid var(--border);
    display: none;
    align-items: center; gap: 12px; flex-wrap: wrap;
}
.period-filter.is-open { display: flex; }
.filter-label { font-size: .74rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .4px; }
.custom-sel {
    appearance: none;
    background: #fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%236366f1' stroke-width='2.5'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E") no-repeat right 9px center / 15px;
    border: 1.5px solid #dde1ef; border-radius: 8px;
    padding: 7px 32px 7px 12px;
    font-size: .82rem; font-family: 'Inter', sans-serif;
    font-weight: 500; color: var(--txt); cursor: pointer;
    transition: border-color .2s; outline: none; min-width: 120px;
}
.custom-sel:focus { border-color: var(--pri); }

/* Status chips */
.s-chips { display: flex; gap: 7px; flex-wrap: wrap; }
.schip {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 5px 12px; border-radius: 50px;
    font-size: .72rem; font-weight: 700;
    cursor: pointer; border: 1.5px solid transparent;
    transition: all .15s; user-select: none;
}
.schip-all { background: var(--pri-l); color: var(--pri); border-color: var(--pri); }
.schip-present { background: var(--ok-l); color: var(--ok); border-color: transparent; }
.schip-late { background: var(--warn-l); color: #b45309; border-color: transparent; }
.schip-absent { background: var(--ng-l); color: var(--ng); border-color: transparent; }
.schip.active.schip-present { border-color: var(--ok); }
.schip.active.schip-late { border-color: var(--warn); }
.schip.active.schip-absent { border-color: var(--ng); }
.row-cnt { font-size: .72rem; font-weight: 700; color: var(--pri); background: var(--pri-l); padding: 3px 10px; border-radius: 6px; margin-left: auto; }

/* ─── Detail collapse ─── */
.period-detail { display: none; }
.period-detail.is-open { display: block; }
.detail-inner { padding: 0 26px 26px; }

/* Table */
.ts-table { width: 100%; border-collapse: separate; border-spacing: 0 4px; }
.ts-table thead th {
    color: var(--muted); font-weight: 700; font-size: .7rem;
    text-transform: uppercase; letter-spacing: .6px;
    padding: 6px 14px; border: none; background: transparent; white-space: nowrap;
}
.ts-table tbody td {
    background: #fff; padding: 11px 14px;
    vertical-align: middle; font-size: .84rem; color: #475569;
    border-top: 1px solid #f0f3fa; border-bottom: 1px solid #f0f3fa;
    transition: background .12s;
}
.ts-table tbody td:first-child { border-left: 1px solid #f0f3fa; border-radius: 10px 0 0 10px; }
.ts-table tbody td:last-child { border-right: 1px solid #f0f3fa; border-radius: 0 10px 10px 0; }
.ts-table tbody tr:hover td { background: #f7f9ff; }
.ts-table tr.row-hidden { display: none; }
.ts-table tr.row-nodata td { background: #fcfcfc; color: #cbd5e1 !important; }

.day-num { font-weight: 700; color: var(--txt); font-size: .88rem; }
.day-name { font-size: .7rem; color: var(--muted); font-weight: 500; }

.bs {
    display: inline-flex; align-items: center; gap: 4px;
    padding: 3px 10px; border-radius: 6px;
    font-weight: 700; font-size: .7rem;
}
.bs-present { background: var(--ok-l); color: var(--ok); }
.bs-late { background: var(--warn-l); color: #b45309; }
.bs-absent { background: var(--ng-l); color: var(--ng); }
.bs-halfday { background: var(--info-l); color: var(--info); }
.bs-nodata { background: #f1f5f9; color: #94a3b8; }

.ot-badge {
    display: inline-block; padding: 2px 8px; border-radius: 5px;
    background: var(--info-l); color: var(--info); font-weight: 700; font-size: .72rem;
}

.no-results-row td { text-align: center; padding: 32px; color: var(--muted); font-size: .88rem; }

@media(max-width: 900px) {
    .main-content { width: 100%; padding: 20px 16px; }
    .period-head { flex-direction: column; align-items: flex-start; }
    .period-head-right { width: 100%; justify-content: flex-end; }
}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="personal-timesheet" />
    </jsp:include>

    <div class="main-content">

        <!-- Page Header -->
        <div class="page-header">
            <div>
                <h1 class="page-title">
                    <i class="fas fa-id-card-alt me-2" style="color:var(--pri);font-size:1.25rem;"></i>Bảng Công Cá Nhân
                </h1>
                <p class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home" style="font-size:.73rem;"></i> Bảng điều khiển</a>
                    &nbsp;›&nbsp; Bảng công của tôi
                </p>
            </div>
        </div>

        <!-- Content -->
        <c:choose>
            <c:when test="${empty periodDataList}">
                <div class="empty-state">
                    <i class="fas fa-calendar-xmark"></i>
                    <h3>Chưa có dữ liệu chấm công</h3>
                    <p>Dữ liệu chấm công của bạn chưa được nhập vào hệ thống. Vui lòng liên hệ HR.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="pd" items="${periodDataList}" varStatus="st">
                    <c:set var="cardId" value="card_${pd.year}_${pd.month}" />
                    <c:set var="detailId" value="detail_${pd.year}_${pd.month}" />
                    <c:set var="filterId" value="filter_${pd.year}_${pd.month}" />
                    <c:set var="tbodyId" value="tbody_${pd.year}_${pd.month}" />
                    <c:set var="cntId"   value="cnt_${pd.year}_${pd.month}" />
                    <c:set var="btnId"   value="btn_${pd.year}_${pd.month}" />
                    <c:set var="weekId"  value="week_${pd.year}_${pd.month}" />
                    <c:set var="chipGrp" value="chips_${pd.year}_${pd.month}" />

                    <div class="period-card" id="${cardId}">

                        <!-- ── Card Header ── -->
                        <div class="period-head" onclick="togglePeriod('${detailId}','${filterId}','${btnId}')">

                            <!-- Left: Period label + mini stats -->
                            <div style="display:flex;align-items:center;gap:20px;flex-wrap:wrap;">
                                <div class="period-label">
                                    <div class="p-icon"><i class="fas fa-calendar-days"></i></div>
                                    <div>
                                        <div class="p-title">Tháng <fmt:formatNumber value="${pd.month}" minIntegerDigits="2"/> / ${pd.year}</div>
                                        <div class="p-sub">${fn:length(pd.attendanceList)} ngày trong tháng</div>
                                    </div>
                                </div>

                                <div class="period-stats">
                                    <span class="pstat pstat-ok"><i class="fas fa-circle-check"></i> ${pd.present} đi làm</span>
                                    <span class="pstat pstat-warn"><i class="fas fa-clock"></i> ${pd.late} trễ</span>
                                    <span class="pstat pstat-ng"><i class="fas fa-circle-xmark"></i> ${pd.absent} vắng</span>
                                    <c:if test="${pd.ot > 0}">
                                        <span class="pstat pstat-info"><i class="fas fa-bolt"></i> ${pd.ot} tăng ca</span>
                                    </c:if>
                                </div>
                            </div>

                            <!-- Right: Status badge + toggle button -->
                            <div class="period-head-right" onclick="event.stopPropagation();">
                                <!-- Dept confirmation status -->
                                <c:if test="${not empty pd.confirmation}">
                                    <c:choose>
                                        <c:when test="${pd.confirmation.status == 'DRAFT'}">
                                            <span class="dept-pill dp-draft"><i class="fas fa-circle-dot"></i> Bản nháp</span>
                                        </c:when>
                                        <c:when test="${pd.confirmation.status == 'SENT_TO_DEPARTMENT'}">
                                            <span class="dept-pill dp-pending"><i class="fas fa-hourglass-half"></i> Chờ xác nhận</span>
                                        </c:when>
                                        <c:when test="${pd.confirmation.status == 'DEPARTMENT_CONFIRMED' || pd.confirmation.status == 'SENT_TO_HR_MANAGER'}">
                                            <span class="dept-pill dp-confirmed"><i class="fas fa-check"></i> Đã xác nhận PB</span>
                                        </c:when>
                                        <c:when test="${pd.confirmation.status == 'HR_MANAGER_APPROVED'}">
                                            <span class="dept-pill dp-approved"><i class="fas fa-check-double"></i> HR đã duyệt</span>
                                        </c:when>
                                        <c:when test="${pd.confirmation.status == 'HR_MANAGER_REJECTED'}">
                                            <span class="dept-pill dp-rejected"><i class="fas fa-xmark"></i> Bị từ chối</span>
                                        </c:when>
                                    </c:choose>
                                </c:if>

                                <button class="btn-detail" id="${btnId}" onclick="togglePeriod('${detailId}','${filterId}','${btnId}')">
                                    <i class="fas fa-table-list"></i>
                                    <span>Xem chi tiết</span>
                                    <i class="fas fa-chevron-down chev"></i>
                                </button>
                            </div>
                        </div>

                        <!-- ── Filter bar (hidden until open) ── -->
                        <div class="period-filter" id="${filterId}">
                            <span class="filter-label"><i class="fas fa-filter me-1"></i>Lọc</span>

                            <select class="custom-sel" id="${weekId}" onchange="applyFilter('${tbodyId}','${weekId}','${chipGrp}','${cntId}')">
                                <option value="">Tất cả tuần</option>
                                <option value="1">Tuần 1 (01–07)</option>
                                <option value="2">Tuần 2 (08–14)</option>
                                <option value="3">Tuần 3 (15–21)</option>
                                <option value="4">Tuần 4 (22–28)</option>
                                <option value="5">Tuần 5 (29+)</option>
                            </select>

                            <div class="s-chips" id="${chipGrp}">
                                <div class="schip schip-all active" data-status="all" onclick="selectChip(this,'${chipGrp}','${tbodyId}','${weekId}','${cntId}')">
                                    <i class="fas fa-border-all"></i> Tất cả
                                </div>
                                <div class="schip schip-present" data-status="PRESENT" onclick="selectChip(this,'${chipGrp}','${tbodyId}','${weekId}','${cntId}')">
                                    <i class="fas fa-circle-check"></i> Có mặt
                                </div>
                                <div class="schip schip-late" data-status="LATE" onclick="selectChip(this,'${chipGrp}','${tbodyId}','${weekId}','${cntId}')">
                                    <i class="fas fa-clock"></i> Đi trễ
                                </div>
                                <div class="schip schip-absent" data-status="ABSENT" onclick="selectChip(this,'${chipGrp}','${tbodyId}','${weekId}','${cntId}')">
                                    <i class="fas fa-circle-xmark"></i> Vắng
                                </div>
                            </div>

                            <span class="row-cnt" id="${cntId}">– ngày</span>
                        </div>

                        <!-- ── Detail table ── -->
                        <div class="period-detail" id="${detailId}">
                            <div class="detail-inner">
                                <div class="table-responsive">
                                    <table class="ts-table">
                                        <thead>
                                            <tr>
                                                <th>Ngày</th>
                                                <th>Ca Làm Việc</th>
                                                <th>Giờ Vào</th>
                                                <th>Giờ Ra</th>
                                                <th>Trạng Thái</th>
                                                <th>Tăng Ca</th>
                                                <th>Ghi Chú</th>
                                            </tr>
                                        </thead>
                                        <tbody id="${tbodyId}">
                                            <c:forEach var="a" items="${pd.attendanceList}">
                                                <c:set var="isNoData" value="${a.status == 'NO_DATA'}" />
                                                <tr class="${isNoData ? 'row-nodata' : ''}"
                                                    data-status="${a.status}"
                                                    data-day="<fmt:formatDate value='${a.workDate}' pattern='d'/>">
                                                    <td>
                                                        <div class="day-num"><fmt:formatDate value="${a.workDate}" pattern="dd/MM"/></div>
                                                        <div class="day-name"><fmt:formatDate value="${a.workDate}" pattern="EEEE"/></div>
                                                    </td>
                                                    <td style="${isNoData ? 'color:#cbd5e1' : ''}">${a.shiftName != null ? a.shiftName : '—'}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${a.checkIn != null}"><strong><fmt:formatDate value="${a.checkIn}" pattern="HH:mm"/></strong></c:when>
                                                            <c:otherwise><span style="color:#cbd5e1;">—</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${a.checkOut != null}"><fmt:formatDate value="${a.checkOut}" pattern="HH:mm"/></c:when>
                                                            <c:otherwise><span style="color:#cbd5e1;">—</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${a.status == 'PRESENT'}"><span class="bs bs-present"><i class="fas fa-circle-check"></i> Có mặt</span></c:when>
                                                            <c:when test="${a.status == 'ABSENT'}"><span class="bs bs-absent"><i class="fas fa-circle-xmark"></i> Vắng</span></c:when>
                                                            <c:when test="${a.status == 'LATE'}"><span class="bs bs-late"><i class="fas fa-clock"></i> Đi trễ</span></c:when>
                                                            <c:when test="${a.status == 'HALFDAY'}"><span class="bs bs-halfday"><i class="fas fa-circle-half-stroke"></i> Nửa ngày</span></c:when>
                                                            <c:when test="${a.status == 'NO_DATA'}"><span class="bs bs-nodata">—</span></c:when>
                                                            <c:otherwise><span class="bs bs-nodata">${a.status}</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${a.overtimeHrs > 0}"><span class="ot-badge">+${a.overtimeHrs}h</span></c:when>
                                                            <c:otherwise><span style="color:#cbd5e1;">—</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="font-size:.78rem;color:var(--muted);">${a.otReason != null ? a.otReason : '—'}</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                    </div><%-- /period-card --%>
                </c:forEach>
            </c:otherwise>
        </c:choose>

    </div><%-- /main-content --%>
</div><%-- /dashboard-wrapper --%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function togglePeriod(detailId, filterId, btnId) {
    var detail = document.getElementById(detailId);
    var filter = document.getElementById(filterId);
    var btn    = document.getElementById(btnId);

    var isOpen = detail.classList.contains('is-open');
    if (isOpen) {
        detail.classList.remove('is-open');
        filter.classList.remove('is-open');
        btn.classList.remove('is-open');
        btn.querySelector('span').textContent = 'Xem chi tiết';
    } else {
        detail.classList.add('is-open');
        filter.classList.add('is-open');
        btn.classList.add('is-open');
        btn.querySelector('span').textContent = 'Ẩn chi tiết';
        // Init count on first open
        var tbody = detail.querySelector('tbody');
        var cntEl = document.getElementById(filterId.replace('filter_', 'cnt_'));
        if (tbody && cntEl) {
            var rows = tbody.querySelectorAll('tr[data-status]');
            cntEl.textContent = rows.length + ' ngày';
        }
    }
}

function selectChip(el, chipGrpId, tbodyId, weekId, cntId) {
    var grp = document.getElementById(chipGrpId);
    grp.querySelectorAll('.schip').forEach(function(c) { c.classList.remove('active'); });
    el.classList.add('active');
    applyFilter(tbodyId, weekId, chipGrpId, cntId);
}

function applyFilter(tbodyId, weekId, chipGrpId, cntId) {
    var weekSel   = document.getElementById(weekId).value;
    var activeChip = document.querySelector('#' + chipGrpId + ' .schip.active');
    var statusFilter = activeChip ? activeChip.getAttribute('data-status') : 'all';

    var rows = document.querySelectorAll('#' + tbodyId + ' tr[data-status]');
    var visible = 0;

    rows.forEach(function(row) {
        var st  = row.getAttribute('data-status');
        var day = parseInt(row.getAttribute('data-day'), 10);

        var weekOk = true;
        if (weekSel === '1') weekOk = day >= 1 && day <= 7;
        else if (weekSel === '2') weekOk = day >= 8 && day <= 14;
        else if (weekSel === '3') weekOk = day >= 15 && day <= 21;
        else if (weekSel === '4') weekOk = day >= 22 && day <= 28;
        else if (weekSel === '5') weekOk = day >= 29;

        var statusOk = (statusFilter === 'all') || (st === statusFilter);

        if (weekOk && statusOk) {
            row.classList.remove('row-hidden');
            visible++;
        } else {
            row.classList.add('row-hidden');
        }
    });

    var cntEl = document.getElementById(cntId);
    if (cntEl) cntEl.textContent = visible + ' ngày';
}
</script>
</body>
</html>

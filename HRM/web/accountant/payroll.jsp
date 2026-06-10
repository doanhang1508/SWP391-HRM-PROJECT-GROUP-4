<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Bảng Lương - Kế Toán" scope="request"/>
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
    :root {
        --pri:  #0d9488;
        --pri-l: rgba(13,148,136,.1);
        --ok:   #10b981;
        --ok-l: rgba(16,185,129,.1);
        --warn: #f59e0b;
        --warn-l: rgba(245,158,11,.1);
        --ng:   #ef4444;
        --ng-l: rgba(239,68,68,.1);
        --blue: #3b82f6;
        --blue-l: rgba(59,130,246,.1);
        --bg:   #f1f5f9;
        --card: #fff;
        --txt:  #0f172a;
        --muted:#64748b;
    }
    footer, #chatWidget { display: none !important; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; }

    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 30px 32px; min-width: 0; }

    /* ── Page Header ── */
    .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 28px; flex-wrap: wrap; gap: 12px; }
    .page-title   { font-size: 1.5rem; font-weight: 800; color: var(--txt); margin: 0; }
    .breadcrumb-c { font-size: .82rem; color: var(--muted); margin: 4px 0 0; }
    .breadcrumb-c a { color: var(--pri); text-decoration: none; }
    .role-badge   {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 6px 14px; border-radius: 20px; font-size: .8rem; font-weight: 700;
        background: linear-gradient(135deg, #0d9488, #0369a1); color: #fff;
        box-shadow: 0 2px 8px rgba(13,148,136,.3);
    }

    /* ── Stat Cards ── */
    .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px,1fr)); gap: 18px; margin-bottom: 28px; }
    .stat-card {
        background: var(--card); border-radius: 16px; padding: 20px 22px;
        box-shadow: 0 1px 3px rgba(0,0,0,.05); border: 1px solid #e2e8f0;
        display: flex; flex-direction: column; gap: 8px;
        transition: transform .2s, box-shadow .2s;
    }
    .stat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,.08); }
    .stat-header { display: flex; justify-content: space-between; align-items: flex-start; }
    .stat-label  { font-size: .72rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .6px; }
    .stat-icon   { width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: .95rem; }
    .stat-val    { font-size: 1.9rem; font-weight: 800; color: var(--txt); line-height: 1.1; }
    .stat-sub    { font-size: .74rem; font-weight: 600; color: var(--muted); }
    .stat-card.c-teal  { border-left: 4px solid var(--pri);  } .stat-card.c-teal  .stat-icon { background: var(--pri-l);  color: var(--pri); }
    .stat-card.c-ok    { border-left: 4px solid var(--ok);   } .stat-card.c-ok    .stat-icon { background: var(--ok-l);   color: var(--ok); }
    .stat-card.c-warn  { border-left: 4px solid var(--warn); } .stat-card.c-warn  .stat-icon { background: var(--warn-l); color: var(--warn); }
    .stat-card.c-blue  { border-left: 4px solid var(--blue); } .stat-card.c-blue  .stat-icon { background: var(--blue-l); color: var(--blue); }

    /* ── Filter Panel ── */
    .filter-panel {
        background: var(--card); border-radius: 16px; padding: 20px 24px;
        border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,.04);
        margin-bottom: 20px; display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
    }
    .filter-panel label { font-size: .82rem; font-weight: 600; color: var(--muted); margin: 0; }
    .filter-panel select, .filter-panel input[type=number] {
        padding: 8px 14px; border: 1.5px solid #e2e8f0; border-radius: 8px;
        font-size: .88rem; font-family: 'Inter', sans-serif; outline: none; color: var(--txt);
        transition: border-color .2s;
    }
    .filter-panel select:focus, .filter-panel input:focus { border-color: var(--pri); }
    .btn-filter {
        background: var(--pri); color: #fff; border: none; border-radius: 8px;
        padding: 9px 20px; font-size: .88rem; font-weight: 600; cursor: pointer;
        display: inline-flex; align-items: center; gap: 7px; transition: all .2s;
    }
    .btn-filter:hover { background: #0f766e; transform: translateY(-1px); }
    .btn-mark-all {
        background: var(--ok); color: #fff; border: none; border-radius: 8px;
        padding: 9px 20px; font-size: .88rem; font-weight: 600; cursor: pointer;
        display: inline-flex; align-items: center; gap: 7px; transition: all .2s; margin-left: auto;
    }
    .btn-mark-all:hover { background: #059669; transform: translateY(-1px); }
    .btn-mark-all:disabled { background: #94a3b8; cursor: not-allowed; transform: none; }

    /* ── Table ── */
    .panel {
        background: var(--card); border-radius: 16px; padding: 24px;
        border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,.04);
    }
    .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .panel-title  { font-size: 1rem; font-weight: 700; color: var(--txt); display: flex; align-items: center; gap: 9px; }
    .panel-icon   { width: 36px; height: 36px; border-radius: 9px; background: var(--pri-l); color: var(--pri); display: flex; align-items: center; justify-content: center; }

    .search-box { position: relative; }
    .search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .82rem; }
    .search-box input { padding: 8px 14px 8px 32px; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: .87rem; font-family: 'Inter', sans-serif; outline: none; width: 220px; }
    .search-box input:focus { border-color: var(--pri); }

    .tbl { width: 100%; border-collapse: separate; border-spacing: 0 5px; }
    .tbl th { color: var(--muted); font-size: .73rem; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; padding: 10px 14px; border: none; white-space: nowrap; }
    .tbl td { background: #fff; padding: 13px 14px; font-size: .86rem; color: #475569; border-top: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
    .tbl tr td:first-child { border-left: 1px solid #f1f5f9; border-radius: 10px 0 0 10px; }
    .tbl tr td:last-child  { border-right: 1px solid #f1f5f9; border-radius: 0 10px 10px 0; }
    .tbl tbody tr:hover td { background: #f8fafc; }

    .badge { padding: 4px 11px; border-radius: 6px; font-weight: 600; font-size: .73rem; display: inline-flex; align-items: center; gap: 4px; }
    .b-draft    { background: #f1f5f9; color: #64748b; }
    .b-approved { background: var(--warn-l); color: #b45309; }
    .b-paid     { background: var(--ok-l); color: #065f46; }

    .emp-name { font-weight: 700; color: var(--txt); }
    .emp-id   { font-size: .75rem; color: var(--muted); }

    .currency { font-weight: 700; color: var(--txt); font-size: .9rem; }

    .btn-pay {
        height: 32px; padding: 0 14px; border: none; border-radius: 7px;
        background: var(--ok); color: #fff; font-size: .81rem; font-weight: 600;
        cursor: pointer; display: inline-flex; align-items: center; gap: 5px;
        transition: all .2s;
    }
    .btn-pay:hover { background: #059669; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(16,185,129,.3); }

    /* Pagination */
    .pagination-bar { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 16px; border-top: 1px solid #f1f5f9; }
    .pg-info { font-size: .83rem; color: var(--muted); }
    .pg-btns { display: flex; gap: 6px; }
    .pg-btn  { width: 32px; height: 32px; border: 1px solid #e2e8f0; background: #fff; border-radius: 7px; display: flex; align-items: center; justify-content: center; font-size: .82rem; color: var(--muted); cursor: pointer; transition: all .15s; }
    .pg-btn:hover { background: var(--pri); color: #fff; border-color: var(--pri); }
    .pg-btn:disabled { opacity: .4; cursor: not-allowed; }

    /* Alert */
    .alert-c { border: none; border-radius: 10px; padding: 12px 18px; font-size: .88rem; margin-bottom: 16px; display: flex; align-items: center; gap: 9px; }
    .a-ok  { background: #d1fae5; color: #065f46; }
    .a-err { background: #fee2e2; color: #991b1b; }

    @media (max-width: 768px) { .main-content { padding: 20px 16px; } }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="accountant-payroll"/>
    </jsp:include>

    <div class="main-content">

        <%-- ── Page Header ── --%>
        <div class="page-header">
            <div>
                <h1 class="page-title"><i class="fas fa-file-invoice-dollar" style="color:var(--pri);margin-right:8px;"></i>Quản Lý Bảng Lương</h1>
                <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/accountant/payroll">Bảng lương</a> &gt; Tháng ${month}/${year}</p>
            </div>
            <div class="role-badge"><i class="fas fa-calculator"></i> Kế Toán</div>
        </div>

        <%-- ── Thông báo ── --%>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert-c a-ok"><i class="fas fa-check-circle"></i>${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert-c a-err"><i class="fas fa-exclamation-circle"></i>${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <%-- ── Stat Cards ── --%>
        <div class="stat-grid">
            <div class="stat-card c-teal">
                <div class="stat-header">
                    <span class="stat-label">Tổng Nhân Viên</span>
                    <div class="stat-icon"><i class="fas fa-users"></i></div>
                </div>
                <div class="stat-val">${totalCount}</div>
                <div class="stat-sub">Có bảng lương tháng này</div>
            </div>
            <div class="stat-card c-warn">
                <div class="stat-header">
                    <span class="stat-label">Chờ Chuyển Khoản</span>
                    <div class="stat-icon"><i class="fas fa-clock"></i></div>
                </div>
                <div class="stat-val">${approvedCount}</div>
                <div class="stat-sub">Đã duyệt, chưa thanh toán</div>
            </div>
            <div class="stat-card c-ok">
                <div class="stat-header">
                    <span class="stat-label">Đã Chuyển Khoản</span>
                    <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                </div>
                <div class="stat-val">${paidCount}</div>
                <div class="stat-sub">Hoàn thành</div>
            </div>
            <div class="stat-card c-blue">
                <div class="stat-header">
                    <span class="stat-label">Tiến Độ</span>
                    <div class="stat-icon"><i class="fas fa-tasks"></i></div>
                </div>
                <div class="stat-val">
                    <c:choose>
                        <c:when test="${totalCount > 0}"><fmt:formatNumber value="${paidCount * 100 / totalCount}" maxFractionDigits="0"/>%</c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
                <div class="stat-sub">Tỉ lệ đã thanh toán</div>
            </div>
        </div>

        <%-- ── Filter & Actions ── --%>
        <form method="get" action="${pageContext.request.contextPath}/accountant/payroll" class="filter-panel">
            <label>Tháng:</label>
            <select name="month" id="filterMonth">
                <c:forEach begin="1" end="12" var="m">
                    <option value="${m}" ${m == month ? 'selected' : ''}>Tháng ${m}</option>
                </c:forEach>
            </select>
            <label>Năm:</label>
            <input type="number" name="year" value="${year}" min="2020" max="2099" style="width:90px;">
            <button type="submit" class="btn-filter"><i class="fas fa-search"></i> Lọc</button>

            <%-- Nút chuyển khoản tất cả --%>
            <c:if test="${approvedCount > 0}">
                <form method="post" action="${pageContext.request.contextPath}/accountant/payroll"
                      style="margin-left:auto;"
                      onsubmit="return confirm('Xác nhận đã chuyển khoản cho ${approvedCount} nhân viên tháng ${month}/${year}?')">
                    <input type="hidden" name="action" value="markAllPaid">
                    <input type="hidden" name="month" value="${month}">
                    <input type="hidden" name="year"  value="${year}">
                    <button type="submit" class="btn-mark-all">
                        <i class="fas fa-check-double"></i> Xác nhận tất cả (${approvedCount})
                    </button>
                </form>
            </c:if>
        </form>

        <%-- ── Payroll Table ── --%>
        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div class="panel-icon"><i class="fas fa-list-alt"></i></div>
                    Bảng Lương Tháng ${month}/${year}
                </h3>
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Tìm nhân viên..." oninput="filterTable()">
                </div>
            </div>

            <div class="table-responsive">
                <table class="tbl" id="payrollTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Nhân Viên</th>
                            <th>Lương Cơ Bản</th>
                            <th>Làm Việc</th>
                            <th>Thưởng</th>
                            <th>Khấu Trừ</th>
                            <th>Bảo Hiểm</th>
                            <th>Thuế</th>
                            <th style="color:var(--pri);">Thực Nhận</th>
                            <th>Trạng Thái</th>
                            <th class="text-end">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody id="payrollTbody">
                        <c:forEach var="p" items="${payrollList}" varStatus="st">
                            <tr>
                                <td style="color:var(--muted);font-size:.8rem;">${st.index + 1}</td>
                                <td>
                                    <div class="emp-name">${not empty p.fullName ? p.fullName : '—'}</div>
                                    <div class="emp-id">ID #${p.userId}</div>
                                </td>
                                <td><span class="currency"><fmt:formatNumber value="${p.baseSalary}" pattern="#,##0"/> đ</span></td>
                                <td style="text-align:center;">${p.workingDays} ngày</td>
                                <td style="color:#059669;font-weight:600;">
                                    <c:if test="${p.bonusAmount != null && p.bonusAmount > 0}">+<fmt:formatNumber value="${p.bonusAmount}" pattern="#,##0"/> đ</c:if>
                                    <c:if test="${p.bonusAmount == null || p.bonusAmount == 0}"><span style="color:var(--muted);">—</span></c:if>
                                </td>
                                <td style="color:var(--ng);font-weight:600;">
                                    <c:if test="${p.deductionAmount != null && p.deductionAmount > 0}">-<fmt:formatNumber value="${p.deductionAmount}" pattern="#,##0"/> đ</c:if>
                                    <c:if test="${p.deductionAmount == null || p.deductionAmount == 0}"><span style="color:var(--muted);">—</span></c:if>
                                </td>
                                <td style="color:var(--muted);">
                                    <c:if test="${p.insuranceAmount != null}"><fmt:formatNumber value="${p.insuranceAmount}" pattern="#,##0"/> đ</c:if>
                                </td>
                                <td style="color:var(--muted);">
                                    <c:if test="${p.taxAmount != null}"><fmt:formatNumber value="${p.taxAmount}" pattern="#,##0"/> đ</c:if>
                                </td>
                                <td>
                                    <span style="font-size:1rem;font-weight:800;color:var(--pri);">
                                        <fmt:formatNumber value="${p.netSalary}" pattern="#,##0"/> đ
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.status == 'Paid'}">
                                            <span class="badge b-paid"><i class="fas fa-check"></i> Đã TK</span>
                                        </c:when>
                                        <c:when test="${p.status == 'Approved'}">
                                            <span class="badge b-approved"><i class="fas fa-clock"></i> Chờ TK</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge b-draft"><i class="fas fa-pencil-alt"></i> Nháp</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <c:if test="${p.status == 'Approved'}">
                                        <form method="post" action="${pageContext.request.contextPath}/accountant/payroll" style="display:inline;"
                                              onsubmit="return confirm('Xác nhận đã chuyển khoản cho ${not empty p.fullName ? p.fullName : 'nhân viên này'}?')">
                                            <input type="hidden" name="action"    value="markPaid">
                                            <input type="hidden" name="payrollId" value="${p.payrollId}">
                                            <input type="hidden" name="month"     value="${month}">
                                            <input type="hidden" name="year"      value="${year}">
                                            <button type="submit" class="btn-pay"><i class="fas fa-check"></i> Đã CK</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${p.status != 'Approved'}">
                                        <span style="color:var(--muted);font-size:.8rem;">—</span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty payrollList}">
                            <tr>
                                <td colspan="11" style="text-align:center;padding:40px;color:var(--muted);">
                                    <i class="fas fa-inbox" style="font-size:2rem;display:block;margin-bottom:10px;opacity:.4;"></i>
                                    Không có bảng lương nào cho tháng ${month}/${year}
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <div class="pagination-bar">
                <span class="pg-info" id="pgInfo">Đang tải...</span>
                <div class="pg-btns">
                    <button class="pg-btn" id="btnPrev" onclick="prevPage()"><i class="fas fa-chevron-left"></i></button>
                    <button class="pg-btn" id="btnNext" onclick="nextPage()"><i class="fas fa-chevron-right"></i></button>
                </div>
            </div>
        </div>

    </div><%-- end main-content --%>
</div><%-- end dashboard-wrapper --%>

<script>
// ── Pagination & Search ──
let allRows = [], filteredRows = [], currentPage = 1;
const perPage = 10;

document.addEventListener('DOMContentLoaded', () => {
    allRows = Array.from(document.querySelectorAll('#payrollTbody tr'));
    filterTable();
});

function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    filteredRows = allRows.filter(r => r.textContent.toLowerCase().includes(q));
    currentPage = 1;
    render();
}

function render() {
    allRows.forEach(r => r.style.display = 'none');
    const total = filteredRows.length;
    const pages = Math.ceil(total / perPage) || 1;
    if (currentPage > pages) currentPage = pages;
    const start = (currentPage - 1) * perPage;
    const end   = Math.min(start + perPage, total);
    for (let i = start; i < end; i++) filteredRows[i].style.display = '';
    document.getElementById('pgInfo').textContent = total === 0
        ? 'Không có kết quả'
        : `Hiển thị ${start + 1}–${end} / ${total} bản ghi`;
    document.getElementById('btnPrev').disabled = currentPage === 1;
    document.getElementById('btnNext').disabled = currentPage === pages;
}

function prevPage() { if (currentPage > 1) { currentPage--; render(); } }
function nextPage() {
    const pages = Math.ceil(filteredRows.length / perPage) || 1;
    if (currentPage < pages) { currentPage++; render(); }
}
</script>

<jsp:include page="../footer.jsp" />

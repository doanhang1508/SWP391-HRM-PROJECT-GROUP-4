<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Duyệt Bảng Lương - Giám Đốc" scope="request"/>
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
    :root {
        --pri:  #7c3aed;
        --pri-l: rgba(124,58,237,.1);
        --ok:   #10b981;
        --ok-l: rgba(16,185,129,.1);
        --warn: #f59e0b;
        --warn-l: rgba(245,158,11,.1);
        --ng:   #ef4444;
        --ng-l: rgba(239,68,68,.1);
        --blue: #3b82f6;
        --blue-l: rgba(59,130,246,.1);
        --bg:   #f4f7fe;
        --card: #fff;
        --txt:  #0f172a;
        --muted:#64748b;
    }
    body { background: var(--bg); font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 30px 32px; min-width: 0; }

    .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 28px; flex-wrap: wrap; gap: 12px; }
    .page-title   { font-size: 1.5rem; font-weight: 800; color: var(--txt); margin: 0; }
    .breadcrumb-c { font-size: .82rem; color: var(--muted); margin: 4px 0 0; }
    .breadcrumb-c a { color: var(--pri); text-decoration: none; }
    .role-badge {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 6px 14px; border-radius: 20px; font-size: .8rem; font-weight: 700;
        background: linear-gradient(135deg, #7c3aed, #4f46e5); color: #fff;
        box-shadow: 0 2px 8px rgba(124,58,237,.3);
    }

    .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px,1fr)); gap: 16px; margin-bottom: 24px; }
    .stat-card {
        background: var(--card); border-radius: 14px; padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,.05); border: 1px solid #e2e8f0;
        display: flex; flex-direction: column; gap: 6px;
        transition: transform .2s, box-shadow .2s;
    }
    .stat-card:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,.08); }
    .stat-header { display: flex; justify-content: space-between; align-items: center; }
    .stat-label  { font-size: .7rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .5px; }
    .stat-icon   { width: 36px; height: 36px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: .9rem; }
    .stat-val    { font-size: 1.7rem; font-weight: 800; color: var(--txt); line-height: 1.1; }
    .stat-card.c-warn  { border-left: 4px solid var(--warn); } .stat-card.c-warn  .stat-icon { background: var(--warn-l); color: var(--warn); }
    .stat-card.c-ok    { border-left: 4px solid var(--ok);   } .stat-card.c-ok    .stat-icon { background: var(--ok-l);   color: var(--ok); }
    .stat-card.c-ng    { border-left: 4px solid var(--ng);   } .stat-card.c-ng    .stat-icon { background: var(--ng-l);   color: var(--ng); }
    .stat-card.c-blue  { border-left: 4px solid var(--blue); } .stat-card.c-blue  .stat-icon { background: var(--blue-l); color: var(--blue); }
    .stat-card.c-pri   { border-left: 4px solid var(--pri);  } .stat-card.c-pri   .stat-icon { background: var(--pri-l);  color: var(--pri); }

    .filter-panel {
        background: var(--card); border-radius: 14px; padding: 18px 22px;
        border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,.04);
        margin-bottom: 20px; display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
    }
    .filter-panel label { font-size: .82rem; font-weight: 600; color: var(--muted); margin: 0; }
    .filter-panel select, .filter-panel input[type=number] {
        padding: 8px 14px; border: 1.5px solid #e2e8f0; border-radius: 8px;
        font-size: .88rem; font-family: 'Inter', sans-serif; outline: none; color: var(--txt);
    }
    .filter-panel select:focus, .filter-panel input:focus { border-color: var(--pri); }
    .btn-filter {
        background: var(--pri); color: #fff; border: none; border-radius: 8px;
        padding: 9px 18px; font-size: .88rem; font-weight: 600; cursor: pointer;
        display: inline-flex; align-items: center; gap: 6px; transition: all .2s;
    }
    .btn-filter:hover { background: #6d28d9; transform: translateY(-1px); }
    .btn-approve-all {
        background: var(--ok); color: #fff; border: none; border-radius: 8px;
        padding: 9px 18px; font-size: .88rem; font-weight: 600; cursor: pointer;
        display: inline-flex; align-items: center; gap: 6px; transition: all .2s; margin-left: auto;
    }
    .btn-approve-all:hover { background: #059669; transform: translateY(-1px); }

    .panel {
        background: var(--card); border-radius: 16px; padding: 24px;
        border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,.04);
    }
    .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .panel-title  { font-size: 1rem; font-weight: 700; color: var(--txt); display: flex; align-items: center; gap: 9px; }
    .panel-icon   { width: 36px; height: 36px; border-radius: 9px; background: var(--pri-l); color: var(--pri); display: flex; align-items: center; justify-content: center; }

    .tbl { width: 100%; border-collapse: separate; border-spacing: 0 5px; }
    .tbl th { color: var(--muted); font-size: .73rem; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; padding: 10px 14px; border: none; white-space: nowrap; }
    .tbl td { background: #fff; padding: 13px 14px; font-size: .86rem; color: #475569; border-top: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
    .tbl tr td:first-child { border-left: 1px solid #f1f5f9; border-radius: 10px 0 0 10px; }
    .tbl tr td:last-child  { border-right: 1px solid #f1f5f9; border-radius: 0 10px 10px 0; }
    .tbl tbody tr:hover td { background: #f8fafc; }

    .badge-s { padding: 4px 11px; border-radius: 6px; font-weight: 600; font-size: .73rem; display: inline-flex; align-items: center; gap: 4px; }
    .b-pending  { background: var(--warn-l); color: #b45309; }
    .b-approved { background: var(--ok-l); color: #065f46; }
    .b-rejected { background: var(--ng-l); color: #991b1b; }
    .b-paid     { background: var(--blue-l); color: #1d4ed8; }
    .b-draft    { background: #f1f5f9; color: #64748b; }

    .btn-sm {
        height: 32px; padding: 0 14px; border: none; border-radius: 7px;
        color: #fff; font-size: .81rem; font-weight: 600;
        cursor: pointer; display: inline-flex; align-items: center; gap: 5px;
        transition: all .2s;
    }
    .btn-sm:hover { transform: translateY(-1px); box-shadow: 0 4px 10px rgba(0,0,0,.12); }
    .btn-approve { background: var(--ok); }
    .btn-reject  { background: var(--ng); }

    .alert-c { border: none; border-radius: 10px; padding: 12px 18px; font-size: .88rem; margin-bottom: 16px; display: flex; align-items: center; gap: 9px; }
    .a-ok  { background: #d1fae5; color: #065f46; }
    .a-err { background: #fee2e2; color: #991b1b; }

    .pagination-bar { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 16px; border-top: 1px solid #f1f5f9; }
    .pg-info { font-size: .83rem; color: var(--muted); }
    .pg-btns { display: flex; gap: 6px; }
    .pg-btn  { width: 32px; height: 32px; border: 1px solid #e2e8f0; background: #fff; border-radius: 7px; display: flex; align-items: center; justify-content: center; font-size: .82rem; color: var(--muted); cursor: pointer; }
    .pg-btn:hover { background: var(--pri); color: #fff; border-color: var(--pri); }
    .pg-btn:disabled { opacity: .4; cursor: not-allowed; }

    .emp-name { font-weight: 700; color: var(--txt); }
    .emp-id   { font-size: .75rem; color: var(--muted); }
    .currency { font-weight: 700; color: var(--txt); font-size: .88rem; }

    @media (max-width: 768px) { .main-content { padding: 20px 16px; } }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="director-payroll"/>
    </jsp:include>

    <div class="main-content">

        <%-- Page Header --%>
        <div class="page-header">
            <div>
                <h1 class="page-title"><i class="fas fa-gavel" style="color:var(--pri);margin-right:8px;"></i>Duyệt Bảng Lương</h1>
                <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/director/dashboard">Bảng điều khiển</a> &gt; Duyệt bảng lương &gt; Tháng ${month}/${year}</p>
            </div>
            <div class="role-badge"><i class="fas fa-crown"></i> Giám Đốc</div>
        </div>

        <%-- Thông báo --%>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert-c a-ok"><i class="fas fa-check-circle"></i>${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert-c a-err"><i class="fas fa-exclamation-circle"></i>${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <%-- Stat Cards --%>
        <div class="stat-grid">
            <div class="stat-card c-pri">
                <div class="stat-header">
                    <span class="stat-label">Tổng</span>
                    <div class="stat-icon"><i class="fas fa-users"></i></div>
                </div>
                <div class="stat-val">${totalCount}</div>
            </div>
            <div class="stat-card c-warn">
                <div class="stat-header">
                    <span class="stat-label">Chờ Duyệt</span>
                    <div class="stat-icon"><i class="fas fa-hourglass-half"></i></div>
                </div>
                <div class="stat-val">${pendingCount}</div>
            </div>
            <div class="stat-card c-ok">
                <div class="stat-header">
                    <span class="stat-label">Đã Duyệt</span>
                    <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                </div>
                <div class="stat-val">${approvedCount}</div>
            </div>
            <div class="stat-card c-ng">
                <div class="stat-header">
                    <span class="stat-label">Từ Chối</span>
                    <div class="stat-icon"><i class="fas fa-times-circle"></i></div>
                </div>
                <div class="stat-val">${rejectedCount}</div>
            </div>
            <div class="stat-card c-blue">
                <div class="stat-header">
                    <span class="stat-label">Đã Thanh Toán</span>
                    <div class="stat-icon"><i class="fas fa-money-check-alt"></i></div>
                </div>
                <div class="stat-val">${paidCount}</div>
            </div>
        </div>

        <%-- Filter & Actions --%>
        <form method="get" action="${pageContext.request.contextPath}/director/payroll" class="filter-panel">
            <label>Tháng:</label>
            <select name="month">
                <c:forEach begin="1" end="12" var="m">
                    <option value="${m}" ${m == month ? 'selected' : ''}>Tháng ${m}</option>
                </c:forEach>
            </select>
            <label>Năm:</label>
            <input type="number" name="year" value="${year}" min="2020" max="2099" style="width:90px;">
            <button type="submit" class="btn-filter"><i class="fas fa-search"></i> Lọc</button>

            <c:if test="${pendingCount > 0}">
                <form method="post" action="${pageContext.request.contextPath}/director/payroll"
                      style="margin-left:auto;"
                      onsubmit="return confirm('Xác nhận duyệt TẤT CẢ ${pendingCount} bảng lương Pending tháng ${month}/${year}?')">
                    <input type="hidden" name="action" value="approveAll">
                    <input type="hidden" name="month" value="${month}">
                    <input type="hidden" name="year"  value="${year}">
                    <button type="submit" class="btn-approve-all">
                        <i class="fas fa-check-double"></i> Duyệt tất cả (${pendingCount})
                    </button>
                </form>
            </c:if>
        </form>

        <%-- Payroll Table --%>
        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div class="panel-icon"><i class="fas fa-list-alt"></i></div>
                    Bảng Lương Tháng ${month}/${year}
                </h3>
            </div>

            <div class="table-responsive">
                <table class="tbl" id="payrollTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Nhân Viên</th>
                            <th>Lương Cơ Bản</th>
                            <th>Ngày Công</th>
                            <th>Tăng Ca</th>
                            <th>Thưởng</th>
                            <th>Khấu Trừ</th>
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
                                <td style="text-align:center;">${p.workingDays}</td>
                                <td style="color:#059669;font-weight:600;">
                                    <c:if test="${p.overtimeAmount != null && p.overtimeAmount > 0}">+<fmt:formatNumber value="${p.overtimeAmount}" pattern="#,##0"/> đ</c:if>
                                    <c:if test="${p.overtimeAmount == null || p.overtimeAmount == 0}"><span style="color:var(--muted);">—</span></c:if>
                                </td>
                                <td style="color:#059669;font-weight:600;">
                                    <c:if test="${p.bonusAmount != null && p.bonusAmount > 0}">+<fmt:formatNumber value="${p.bonusAmount}" pattern="#,##0"/> đ</c:if>
                                    <c:if test="${p.bonusAmount == null || p.bonusAmount == 0}"><span style="color:var(--muted);">—</span></c:if>
                                </td>
                                <td style="color:var(--ng);font-weight:600;">
                                    <c:if test="${p.deductionAmount != null && p.deductionAmount > 0}">-<fmt:formatNumber value="${p.deductionAmount}" pattern="#,##0"/> đ</c:if>
                                    <c:if test="${p.deductionAmount == null || p.deductionAmount == 0}"><span style="color:var(--muted);">—</span></c:if>
                                </td>
                                <td>
                                    <span style="font-size:1rem;font-weight:800;color:var(--pri);">
                                        <fmt:formatNumber value="${p.netSalary}" pattern="#,##0"/> đ
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.status == 'Pending'}"><span class="badge-s b-pending"><i class="fas fa-clock"></i> Chờ duyệt</span></c:when>
                                        <c:when test="${p.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-check"></i> Đã duyệt</span></c:when>
                                        <c:when test="${p.status == 'Rejected'}"><span class="badge-s b-rejected"><i class="fas fa-times"></i> Từ chối</span></c:when>
                                        <c:when test="${p.status == 'Paid'}"><span class="badge-s b-paid"><i class="fas fa-check-double"></i> Đã TK</span></c:when>
                                        <c:otherwise><span class="badge-s b-draft"><i class="fas fa-pencil-alt"></i> Nháp</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <c:if test="${p.status == 'Pending'}">
                                        <div class="d-flex justify-content-end gap-2">
                                            <form method="post" action="${pageContext.request.contextPath}/director/payroll" style="display:inline;"
                                                  onsubmit="return confirm('Xác nhận DUYỆT bảng lương của ${not empty p.fullName ? p.fullName : 'nhân viên này'}?')">
                                                <input type="hidden" name="action"    value="approve">
                                                <input type="hidden" name="payrollId" value="${p.payrollId}">
                                                <input type="hidden" name="month"     value="${month}">
                                                <input type="hidden" name="year"      value="${year}">
                                                <button type="submit" class="btn-sm btn-approve"><i class="fas fa-check"></i> Duyệt</button>
                                            </form>
                                            <button type="button" class="btn-sm btn-reject"
                                                    onclick="openRejectModal(${p.payrollId}, '${not empty p.fullName ? p.fullName : ''}')">
                                                <i class="fas fa-times"></i> Từ chối
                                            </button>
                                        </div>
                                    </c:if>
                                    <c:if test="${p.status == 'Rejected' && not empty p.rejectReason}">
                                        <span style="font-size:.78rem;color:var(--ng);cursor:help;" title="${p.rejectReason}">
                                            <i class="fas fa-info-circle"></i> Xem lý do
                                        </span>
                                    </c:if>
                                    <c:if test="${p.status != 'Pending' && p.status != 'Rejected'}">
                                        <span style="color:var(--muted);font-size:.8rem;">—</span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty payrollList}">
                            <tr>
                                <td colspan="10" style="text-align:center;padding:40px;color:var(--muted);">
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

    </div>
</div>

<%-- Reject Modal --%>
<div class="modal fade" id="rejectModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:480px;">
        <div class="modal-content" style="border-radius:16px;border:none;box-shadow:0 15px 35px rgba(0,0,0,.15);">
            <div class="modal-header" style="background:linear-gradient(135deg,var(--ng),#dc2626);color:#fff;border-radius:16px 16px 0 0;padding:20px 24px;">
                <h5 class="modal-title fw-bold"><i class="fas fa-times-circle me-2"></i>Từ Chối Bảng Lương</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/director/payroll">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="payrollId" id="rejectPayrollId">
                <input type="hidden" name="month" value="${month}">
                <input type="hidden" name="year"  value="${year}">
                <div class="modal-body" style="padding:28px;">
                    <p class="text-muted mb-3" style="font-size:.9rem;">
                        Từ chối bảng lương của <strong id="rejectEmpName"></strong>. Vui lòng nhập lý do:
                    </p>
                    <textarea name="rejectReason" class="form-control" rows="4" required
                              placeholder="Nhập lý do từ chối..."
                              style="border-radius:10px;border:1.5px solid #e2e8f0;font-family:'Inter',sans-serif;font-size:.9rem;"></textarea>
                </div>
                <div class="modal-footer" style="background:#f8fafc;border-top:1px solid #e2e8f0;border-radius:0 0 16px 16px;padding:16px 24px;">
                    <button type="button" class="btn btn-secondary px-4 fw-semibold" data-bs-dismiss="modal" style="border-radius:8px;">Hủy</button>
                    <button type="submit" class="btn-sm btn-reject px-4" style="height:38px;font-size:.88rem;">
                        <i class="fas fa-times"></i> Xác nhận Từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openRejectModal(payrollId, empName) {
    document.getElementById('rejectPayrollId').value = payrollId;
    document.getElementById('rejectEmpName').textContent = empName || 'nhân viên này';
    new bootstrap.Modal(document.getElementById('rejectModal')).show();
}

// Pagination
let allRows = [], filteredRows = [], currentPage = 1;
const perPage = 10;

document.addEventListener('DOMContentLoaded', () => {
    allRows = Array.from(document.querySelectorAll('#payrollTbody tr'));
    filteredRows = [...allRows];
    render();
});

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
        : 'Hiển thị ' + (start + 1) + '–' + end + ' / ' + total + ' bản ghi';
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

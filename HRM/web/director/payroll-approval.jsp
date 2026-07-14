<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Duyệt Bảng Lương - Giám Đốc" scope="request"/>
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
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

    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; flex-wrap: wrap; gap: 12px; }
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
        padding: 10px 20px; font-size: .88rem; font-weight: 600; cursor: pointer;
        display: inline-flex; align-items: center; gap: 6px; transition: all .2s;
    }
    .btn-approve-all:hover { background: #059669; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(16,185,129,.3); }

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

    .badge-s { padding: 5px 12px; border-radius: 6px; font-weight: 600; font-size: .74rem; display: inline-flex; align-items: center; gap: 5px; }
    .b-pending  { background: var(--warn-l); color: #b45309; }
    .b-approved { background: var(--ok-l); color: #065f46; }
    .b-rejected { background: var(--ng-l); color: #991b1b; }
    .b-paid     { background: var(--blue-l); color: #1d4ed8; }
    .b-draft    { background: #f1f5f9; color: #64748b; }

    .btn-a {
        height: 32px; display: inline-flex; align-items: center; justify-content: center;
        border-radius: 8px; border: none; color: #fff; padding: 0 12px;
        font-size: .82rem; font-weight: 500; text-decoration: none; gap: 5px;
        cursor: pointer; transition: all .2s;
    }
    .btn-a:hover { transform: translateY(-2px); box-shadow: 0 4px 10px rgba(0,0,0,.12); color: #fff; }
    .btn-approve { background: var(--ok); }
    .btn-reject  { background: var(--ng); }
    .btn-view    { background: #0d9488; }

    .alert-c { border: none; border-radius: 10px; padding: 12px 20px; font-size: .88rem; margin-bottom: 24px; display: flex; align-items: center; gap: 9px; }
    .a-ok  { background: #d1fae5; color: #065f46; }
    .a-err { background: #fee2e2; color: #991b1b; }

    .pagination-bar { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 16px; border-top: 1px solid #f1f5f9; }
    .pg-info { font-size: .83rem; color: var(--muted); }
    .pg-btns { display: flex; gap: 6px; }
    .pg-btn  { width: 32px; height: 32px; border: 1px solid #e2e8f0; background: #fff; border-radius: 7px; display: flex; align-items: center; justify-content: center; font-size: .82rem; color: var(--muted); cursor: pointer; }
    .pg-btn:hover:not(:disabled) { background: var(--pri); color: #fff; border-color: var(--pri); }
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
        <c:choose>
            <c:when test="${viewMode == 'months'}">
                <div class="page-header">
                    <div>
                        <h1 class="page-title"><i class="fas fa-gavel" style="color:var(--pri);margin-right:8px;"></i>Duyệt Bảng Lương theo Tháng</h1>
                        <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/director/dashboard">Bảng điều khiển</a> &gt; Bảng lương</p>
                    </div>
                    <div class="role-badge"><i class="fas fa-crown"></i> Giám Đốc</div>
                </div>

                <%-- Thông báo --%>
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-c a-ok alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-c a-err alert-dismissible fade show"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <div class="panel">
                    <div class="panel-header">
                        <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-list"></i></div> Danh sách kỳ lương chờ duyệt</h3>
                        <div class="d-flex gap-2 align-items-center">
                            <select id="filterMonth" onchange="filterMonthlyTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả tháng</option>
                                <c:forEach var="m" begin="1" end="12">
                                    <option value="${m}">Tháng ${m}</option>
                                </c:forEach>
                            </select>
                            <select id="filterYear" onchange="filterMonthlyTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả năm</option>
                                <option value="2024">2024</option>
                                <option value="2025">2025</option>
                                <option value="2026">2026</option>
                                <option value="2027">2027</option>
                            </select>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table id="monthlyTable" class="tbl">
                            <thead>
                                <tr>
                                    <th>Kỳ lương (Tháng/Năm)</th>
                                    <th>Số lượng nhân viên</th>
                                    <th>Tổng tiền chi trả (Net)</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty monthlySummaries}">
                                        <tr>
                                            <td colspan="5" class="text-center" style="color:var(--muted)">Chưa có dữ liệu kỳ lương nào.</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="s" items="${monthlySummaries}">
                                            <tr>
                                                <td><span class="fw-bold" style="color:var(--pri)">Tháng ${s.month} / ${s.year}</span></td>
                                                <td>${s.totalEmployees} nhân viên</td>
                                                <td><span class="fw-bold text-success"><fmt:formatNumber value="${s.totalNet}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${s.status == 'Draft'}"><span class="badge-s b-draft"><i class="fas fa-edit"></i> Draft</span></c:when>
                                                        <c:when test="${s.status == 'Pending'}"><span class="badge-s b-pending"><i class="fas fa-clock"></i> Pending</span></c:when>
                                                        <c:when test="${s.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-check"></i> Approved</span></c:when>
                                                        <c:when test="${s.status == 'Rejected'}"><span class="badge-s b-rejected"><i class="fas fa-times"></i> Rejected</span></c:when>
                                                        <c:when test="${s.status == 'Paid'}"><span class="badge-s b-paid"><i class="fas fa-check-double"></i> Paid</span></c:when>
                                                        <c:otherwise><span class="badge-s b-draft">${s.status}</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end">
                                                    <a href="${pageContext.request.contextPath}/director/payroll?month=${s.month}&year=${s.year}" class="btn-a btn-view text-white" title="Xem danh sách nhân viên">
                                                        <i class="fas fa-eye"></i> Xem danh sách nhân viên
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                        <div class="pagination-bar">
                            <span id="monthlyPageInfo" class="pg-info">Đang tải...</span>
                            <div class="pg-btns">
                                <button onclick="monthlyPrevPage()" id="btnMonthlyPrev" class="pg-btn"><i class="fas fa-chevron-left"></i></button>
                                <button onclick="monthlyNextPage()" id="btnMonthlyNext" class="pg-btn"><i class="fas fa-chevron-right"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="page-header">
                    <div>
                        <h1 class="page-title"><i class="fas fa-gavel" style="color:var(--pri);margin-right:8px;"></i>Chi Tiết Kỳ Lương: Tháng ${selectedMonth}/${selectedYear}</h1>
                        <p class="breadcrumb-c">
                            <a href="${pageContext.request.contextPath}/director/dashboard">Bảng điều khiển</a> &gt; 
                            <a href="${pageContext.request.contextPath}/director/payroll">Duyệt bảng lương</a> &gt; 
                            Chi tiết
                        </p>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/director/payroll" class="btn btn-secondary d-inline-flex align-items-center gap-2" style="border-radius:10px;padding:10px 20px;font-weight:600;font-size:.88rem;color:#475569;background:#fff;border:1px solid #e2e8f0;text-decoration:none;">
                            <i class="fas fa-arrow-left"></i> Quay lại danh sách tháng
                        </a>

                        <c:if test="${pendingCount > 0}">
                            <form method="post" action="${pageContext.request.contextPath}/director/payroll"
                                  style="display:inline;"
                                  onsubmit="showConfirmModal(event, 'Xác nhận duyệt TẤT CẢ ${pendingCount} bảng lương Pending của tháng ${selectedMonth}/${selectedYear}?', 'Duyệt tất cả bảng lương', 'fa-check-double', 'var(--ok)', 'var(--ok-l)');">
                                <input type="hidden" name="action" value="approveAll">
                                <input type="hidden" name="month" value="${selectedMonth}">
                                <input type="hidden" name="year"  value="${selectedYear}">
                                <button type="submit" class="btn-approve-all text-white">
                                    <i class="fas fa-check-double"></i> Duyệt tất cả (${pendingCount})
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>

                <%-- Thông báo --%>
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-c a-ok alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-c a-err alert-dismissible fade show"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <%-- Stat Cards --%>
                <div class="stat-grid">
                    <div class="stat-card c-pri">
                        <div class="stat-header">
                            <span class="stat-label">Tổng Nhân Viên</span>
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
                            <span class="stat-label">Đã Chi Trả</span>
                            <div class="stat-icon"><i class="fas fa-money-check-alt"></i></div>
                        </div>
                        <div class="stat-val">${paidCount}</div>
                    </div>
                </div>

                <%-- Payroll Table --%>
                <div class="panel">
                    <div class="panel-header">
                        <h3 class="panel-title">
                            <div class="panel-icon"><i class="fas fa-users"></i></div>
                            Danh sách chi tiết nhân viên trong kỳ lương
                        </h3>
                        <div class="d-flex gap-2 align-items-center">
                            <select id="filterEmpStatus" onchange="filterEmployeeTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="Pending">Pending</option>
                                <option value="Approved">Approved</option>
                                <option value="Rejected">Rejected</option>
                                <option value="Paid">Paid</option>
                            </select>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table id="employeeTable" class="tbl">
                            <thead>
                                <tr>
                                    <th>Mã NV</th>
                                    <th>Họ và tên</th>
                                    <th>Lương cơ bản</th>
                                    <th>Ngày công</th>
                                    <th style="color:var(--pri);">Thực Nhận</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty payrollList}">
                                        <tr>
                                            <td colspan="7" class="text-center" style="color:var(--muted)">Chưa có dữ liệu bảng lương cho tháng này.</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="p" items="${payrollList}">
                                            <tr>
                                                <td>#${p.userId}</td>
                                                <td>
                                                    <div class="emp-name">${not empty p.fullName ? p.fullName : '—'}</div>
                                                </td>
                                                <td><span class="currency"><fmt:formatNumber value="${p.baseSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span></td>
                                                <td>${p.workingDays}</td>
                                                <td><span class="fw-bold text-success"><fmt:formatNumber value="${p.netSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${p.status == 'Pending'}"><span class="badge-s b-pending"><i class="fas fa-clock"></i> Pending</span></c:when>
                                                        <c:when test="${p.status == 'Verified'}"><span class="badge-s b-pending" style="background:rgba(59, 130, 246, 0.1);color:#2563eb;"><i class="fas fa-user-check"></i> Verified</span></c:when>
                                                        <c:when test="${p.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-check"></i> Approved</span></c:when>
                                                        <c:when test="${p.status == 'Rejected'}"><span class="badge-s b-rejected"><i class="fas fa-times"></i> Rejected</span></c:when>
                                                        <c:when test="${p.status == 'Paid'}"><span class="badge-s b-paid"><i class="fas fa-check-double"></i> Paid</span></c:when>
                                                        <c:otherwise><span class="badge-s b-draft">${p.status}</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end">
                                                    <div class="d-flex justify-content-end gap-2 align-items-center">
                                                        <button type="button" class="btn-a btn-view text-white" 
                                                                title="Xem chi tiết"
                                                                data-bs-toggle="modal"
                                                                data-bs-target="#payrollDetailModal"
                                                                data-userid="${p.userId}"
                                                                data-fullname="${p.fullName}"
                                                                data-monthyear="${p.month}/${p.year}"
                                                                data-basesalary="<fmt:formatNumber value="${p.baseSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-workingdays="${p.workingDays}"
                                                                data-overtime="<fmt:formatNumber value="${p.overtimeAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-allowance="<fmt:formatNumber value="${p.allowanceAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-bonus="<fmt:formatNumber value="${p.bonusAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-deduction="<fmt:formatNumber value="${p.deductionAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-insurance="<fmt:formatNumber value="${p.insuranceAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-tax="<fmt:formatNumber value="${p.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-gross="<fmt:formatNumber value="${p.grossSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-net="<fmt:formatNumber value="${p.netSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-status="${p.status}"
                                                                data-insurancebase="<fmt:formatNumber value="${p.insuranceBaseAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>"
                                                                data-taxablebase="<fmt:formatNumber value="${p.taxableIncomeBase}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>">
                                                            <i class="fas fa-eye"></i> Chi tiết
                                                        </button>

                                                        <c:if test="${p.status == 'Verified'}">
                                                            <form method="post" action="${pageContext.request.contextPath}/director/payroll" style="display:inline;"
                                                                  onsubmit="showConfirmModal(event, 'Bạn có chắc chắn duyệt bảng lương cho ${p.fullName}?', 'Duyệt bảng lương', 'fa-check', 'var(--ok)', 'var(--ok-l)');">
                                                                <input type="hidden" name="action"    value="approve">
                                                                <input type="hidden" name="payrollId" value="${p.payrollId}">
                                                                <input type="hidden" name="month"     value="${selectedMonth}">
                                                                <input type="hidden" name="year"      value="${selectedYear}">
                                                                <button type="submit" class="btn-a btn-approve" title="Duyệt"><i class="fas fa-check"></i> Duyệt</button>
                                                            </form>
                                                            <button type="button" class="btn-a btn-reject"
                                                                    onclick="openRejectModal(${p.payrollId}, '${p.fullName}')">
                                                                <i class="fas fa-times"></i> Từ chối
                                                            </button>
                                                        </c:if>
                                                        <c:if test="${p.status == 'Rejected' && not empty p.rejectReason}">
                                                            <span style="font-size:.78rem;color:var(--ng);cursor:help;" title="${p.rejectReason}">
                                                                <i class="fas fa-info-circle"></i> Xem lý do
                                                            </span>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                        <div class="pagination-bar">
                            <span id="empPageInfo" class="pg-info">Đang tải...</span>
                            <div class="pg-btns">
                                <button onclick="empPrevPage()" id="btnEmpPrev" class="pg-btn"><i class="fas fa-chevron-left"></i></button>
                                <button onclick="empNextPage()" id="btnEmpNext" class="pg-btn"><i class="fas fa-chevron-right"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
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
                <input type="hidden" name="month" value="${selectedMonth}">
                <input type="hidden" name="year"  value="${selectedYear}">
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
                    <button type="submit" class="btn-a btn-reject px-4" style="height:38px;font-size:.88rem;">
                        <i class="fas fa-times"></i> Xác nhận Từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Payroll Detail Modal -->
<div class="modal fade" id="payrollDetailModal" tabindex="-1" aria-labelledby="payrollDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">
            <div class="modal-header" style="background: linear-gradient(135deg, var(--pri), #4f46e5); color: #fff; border-radius: 16px 16px 0 0; padding: 20px 24px;">
                <h5 class="modal-title fw-bold" id="payrollDetailModalLabel"><i class="fas fa-file-invoice-dollar me-2"></i> Chi Tiết Phiếu Lương</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 30px;">
                <!-- Employee Header Summary -->
                <div class="d-flex align-items-center justify-content-between p-3 mb-4" style="background: var(--bg); border-radius: 12px; border: 1px dashed rgba(124,58,237,.25)">
                    <div>
                        <h6 class="text-muted mb-1 text-uppercase fw-bold" style="font-size: 0.72rem; letter-spacing: 0.5px;">Nhân viên</h6>
                        <h5 class="fw-bold mb-0 text-primary" id="modalEmpName">Nguyễn Văn A</h5>
                    </div>
                    <div class="text-end">
                        <h6 class="text-muted mb-1 text-uppercase fw-bold" style="font-size: 0.72rem; letter-spacing: 0.5px;">Mã NV / Kỳ Lương</h6>
                        <p class="fw-bold mb-0 text-dark"><span id="modalEmpId">#0</span> | <span id="modalMonthYear">06/2026</span></p>
                    </div>
                </div>

                <!-- Details Grid -->
                <div class="row g-4">
                    <!-- Income -->
                    <div class="col-md-6">
                        <div class="p-3" style="background: rgba(16,185,129,.04); border-radius: 12px; border: 1px solid rgba(16,185,129,.1); height: 100%;">
                            <h6 class="fw-bold text-success mb-3 pb-2" style="border-bottom: 2px solid rgba(16,185,129,.2); display: flex; justify-content: space-between;">
                                <span><i class="fas fa-plus-circle me-1"></i> Các Khoản Thu Nhập</span>
                            </h6>
                            <div class="d-flex flex-column gap-2" style="font-size: 0.88rem;">
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Lương cơ bản:</span>
                                    <span class="fw-semibold text-dark" id="modalBaseSalary">0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Ngày công thực tế:</span>
                                    <span class="fw-semibold text-dark" id="modalWorkingDays">0</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Lương theo ngày công:</span>
                                    <span class="fw-semibold text-dark" id="modalBaseWorkedSalary">
                                        <span class="text-muted fst-italic" style="font-size: 0.8rem;">Đang tải...</span>
                                    </span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted" id="modalOvertimeLabel">Tiền tăng ca:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalOvertime">+ 0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Phụ cấp:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalAllowance">+ 0 ₫</span>
                                </div>
                                <div id="modalAllowanceDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Thưởng:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalBonus">+ 0 ₫</span>
                                </div>
                                <div id="modalBonusDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                                <hr style="margin: 10px 0; border-color: rgba(16,185,129,.2);">
                                <div class="d-flex justify-content-between fw-bold text-dark" style="font-size: 0.95rem;">
                                    <span>Lương Gross:</span>
                                    <span id="modalGross">0 ₫</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Deductions -->
                    <div class="col-md-6">
                        <div class="p-3" style="background: rgba(239,68,68,.04); border-radius: 12px; border: 1px solid rgba(239,68,68,.1); height: 100%;">
                            <h6 class="fw-bold text-danger mb-3 pb-2" style="border-bottom: 2px solid rgba(239,68,68,.2); display: flex; justify-content: space-between;">
                                <span><i class="fas fa-minus-circle me-1"></i> Các Khoản Khấu Trừ</span>
                            </h6>
                            <div class="d-flex flex-column gap-2" style="font-size: 0.88rem;">
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Bảo hiểm xã hội:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalInsurance">- 0 ₫</span>
                                </div>
                                <div id="modalInsuranceDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                                <!-- Dòng audit: Nền đóng BHXH = baseSalary + phụ cấp/thưởng is_bhxh_applied=1 -->
                                <div class="d-flex justify-content-between" id="modalInsuranceBaseRow"
                                     style="background: rgba(251,191,36,.08); border-radius: 6px; padding: 4px 8px; margin-top: 2px;">
                                    <span class="text-muted" style="font-size: 0.8rem;"
                                          title="Lương cơ bản + phụ cấp và thưởng có đóng BHXH">
                                        <i class="fas fa-info-circle me-1" style="color: #f59e0b;"></i>Nền đóng BHXH:
                                    </span>
                                    <span class="fw-semibold" style="color: #b45309; font-size: 0.8rem;" id="modalInsuranceBase">0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Thuế TNCN:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalTax">- 0 ₫</span>
                                </div>
                                <div id="modalTaxDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                                <!-- Dòng audit: Thu nhập chịu thuế trước giảm trừ gia cảnh -->
                                <div class="d-flex justify-content-between" id="modalTaxableBaseRow"
                                     style="background: rgba(251,191,36,.08); border-radius: 6px; padding: 4px 8px; margin-top: 2px;">
                                    <span class="text-muted" style="font-size: 0.8rem;"
                                          title="Lương theo công + OT + phụ cấp/thưởng chịu thuế (trước giảm trừ)">
                                        <i class="fas fa-info-circle me-1" style="color: #f59e0b;"></i>Thu nhập chịu thuế:
                                    </span>
                                    <span class="fw-semibold" style="color: #b45309; font-size: 0.8rem;" id="modalTaxableBase">0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Phạt / Khấu trừ khác:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalDeduction">- 0 ₫</span>
                                </div>
                                <div id="modalDeductionDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Net Salary -->
                <div class="mt-4 p-4 text-center" style="background: linear-gradient(135deg, rgba(16,185,129,.1) 0%, rgba(124,58,237,.1) 100%); border-radius: 14px; border: 1px solid rgba(16,185,129,.2);">
                    <h6 class="text-uppercase fw-bold text-muted mb-2" style="font-size: 0.8rem; letter-spacing: 0.5px;">Thực Nhận (Net Salary)</h6>
                    <h2 class="fw-extrabold text-success mb-1" style="font-size: 2.2rem; font-weight: 800;" id="modalNet">0 ₫</h2>
                    <p class="text-muted small mb-0">Trạng thái: <span class="badge-s ms-1" id="modalStatus">Pending</span></p>
                </div>
            </div>
            <div class="modal-footer" style="background: #f8fafc; border-top: 1px solid #e2e8f0; border-radius: 0 0 16px 16px; padding: 16px 24px;">
                <button type="button" class="btn btn-secondary px-4 fw-semibold" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Confirmation Modal -->
<div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 15px 35px rgba(0,0,0,0.15); overflow: hidden;">
            <div class="modal-body text-center" style="padding: 35px 24px 28px;">
                <div class="mb-3 d-inline-flex align-items-center justify-content-center" 
                     id="confirmModalIconContainer"
                     style="width: 70px; height: 70px; border-radius: 50%; background-color: var(--pri-l); color: var(--pri); font-size: 1.8rem; transition: all 0.3s ease;">
                     <i class="fas fa-paper-plane" id="confirmModalIcon"></i>
                </div>
                <h5 class="fw-bold mb-2" id="confirmModalTitle" style="color: var(--txt); font-size: 1.2rem;">Xác nhận duyệt</h5>
                <p class="text-muted mb-4" id="confirmModalMessage" style="font-size: 0.9rem; line-height: 1.5; padding: 0 10px;"></p>
                
                <div class="d-flex gap-3 justify-content-center">
                    <button type="button" 
                            class="btn px-4 py-2 fw-semibold text-secondary" 
                            data-bs-dismiss="modal" 
                            style="border-radius: 10px; background-color: #f1f5f9; border: 1px solid #e2e8f0; font-size: 0.88rem; transition: all 0.2s; min-width: 110px;">
                        Hủy
                    </button>
                    <button type="button" 
                            id="btnConfirmSubmit" 
                            class="btn px-4 py-2 fw-semibold text-white" 
                            style="border-radius: 10px; background: linear-gradient(135deg, var(--pri), #4f46e5); border: none; font-size: 0.88rem; transition: all 0.2s; box-shadow: 0 4px 12px rgba(124, 58, 237, 0.2); min-width: 110px;">
                        Xác nhận
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
let pendingFormToSubmit = null;

function showConfirmModal(event, message, title = 'Xác nhận duyệt', iconClass = 'fa-paper-plane', themeColor = 'var(--pri)', themeBg = 'var(--pri-l)') {
    event.preventDefault();
    pendingFormToSubmit = event.currentTarget || event.target;
    
    document.getElementById('confirmModalTitle').textContent = title;
    document.getElementById('confirmModalMessage').textContent = message;
    
    const iconEl = document.getElementById('confirmModalIcon');
    iconEl.className = 'fas ' + iconClass;
    
    const iconContainer = document.getElementById('confirmModalIconContainer');
    iconContainer.style.color = themeColor;
    iconContainer.style.backgroundColor = themeBg;
    
    const submitBtn = document.getElementById('btnConfirmSubmit');
    if (themeColor === 'var(--ok)') {
        submitBtn.style.background = 'linear-gradient(135deg, var(--ok), #059669)';
        submitBtn.style.boxShadow = '0 4px 12px rgba(16, 185, 129, 0.2)';
    } else {
        submitBtn.style.background = 'linear-gradient(135deg, var(--pri), #4f46e5)';
        submitBtn.style.boxShadow = '0 4px 12px rgba(124, 58, 237, 0.2)';
    }
    
    const confirmModal = new bootstrap.Modal(document.getElementById('confirmModal'));
    confirmModal.show();
}

function openRejectModal(payrollId, empName) {
    document.getElementById('rejectPayrollId').value = payrollId;
    document.getElementById('rejectEmpName').textContent = empName || 'nhân viên này';
    new bootstrap.Modal(document.getElementById('rejectModal')).show();
}

document.addEventListener("DOMContentLoaded", function() {
    const btnConfirmSubmit = document.getElementById('btnConfirmSubmit');
    if (btnConfirmSubmit) {
        btnConfirmSubmit.addEventListener('click', function() {
            if (pendingFormToSubmit) {
                pendingFormToSubmit.submit();
            }
        });
    }

    const detailModal = document.getElementById('payrollDetailModal');
    if (detailModal) {
        detailModal.addEventListener('show.bs.modal', function(event) {
            const button = event.relatedTarget;
            
            // Extract values from data-* attributes
            const userId = button.getAttribute('data-userid');
            const fullName = button.getAttribute('data-fullname');
            const monthYear = button.getAttribute('data-monthyear');
            const baseSalary = button.getAttribute('data-basesalary');
            const workingDays = button.getAttribute('data-workingdays');
            const overtime = button.getAttribute('data-overtime');
            const allowance = button.getAttribute('data-allowance');
            const bonus = button.getAttribute('data-bonus');
            const deduction = button.getAttribute('data-deduction');
            const insurance = button.getAttribute('data-insurance');
            const tax = button.getAttribute('data-tax');
            const gross = button.getAttribute('data-gross');
            const net = button.getAttribute('data-net');
            const status = button.getAttribute('data-status');
            const insuranceBase = button.getAttribute('data-insurancebase') || '0 ₫';
            const taxableBase = button.getAttribute('data-taxablebase') || '0 ₫';

            // Populate Modal Fields
            document.getElementById('modalEmpName').textContent = fullName;
            document.getElementById('modalEmpId').textContent = '#' + userId;
            document.getElementById('modalMonthYear').textContent = monthYear;
            document.getElementById('modalBaseSalary').textContent = baseSalary;
            document.getElementById('modalWorkingDays').textContent = workingDays;
            document.getElementById('modalOvertime').textContent = '+ ' + overtime;
            document.getElementById('modalAllowance').textContent = '+ ' + allowance;
            document.getElementById('modalBonus').textContent = '+ ' + bonus;
            document.getElementById('modalGross').textContent = gross;
            document.getElementById('modalInsurance').textContent = '- ' + insurance;
            document.getElementById('modalTax').textContent = '- ' + tax;
            document.getElementById('modalDeduction').textContent = '- ' + deduction;
            document.getElementById('modalNet').textContent = net;
            document.getElementById('modalInsuranceBase').textContent = insuranceBase;
            document.getElementById('modalTaxableBase').textContent = taxableBase;

            const contextPath = '${pageContext.request.contextPath}';
            const [month, year] = monthYear.split('/');
            
            let deductionDetailsEl = document.getElementById('modalDeductionDetails');
            if (deductionDetailsEl) {
                deductionDetailsEl.innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                deductionDetailsEl.style.display = 'block';
            }
            let taxDetailsEl = document.getElementById('modalTaxDetails');
            if (taxDetailsEl) {
                taxDetailsEl.innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                taxDetailsEl.style.display = 'block';
            }
            let allowanceDetailsEl = document.getElementById('modalAllowanceDetails');
            if (allowanceDetailsEl) {
                allowanceDetailsEl.innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                allowanceDetailsEl.style.display = 'block';
            }
            let bonusDetailsEl = document.getElementById('modalBonusDetails');
            if (bonusDetailsEl) {
                bonusDetailsEl.innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                bonusDetailsEl.style.display = 'block';
            }
            let insuranceDetailsEl = document.getElementById('modalInsuranceDetails');
            if (insuranceDetailsEl) {
                insuranceDetailsEl.innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                insuranceDetailsEl.style.display = 'block';
            }
            let baseWorkedEl = document.getElementById('modalBaseWorkedSalary');
            if (baseWorkedEl) {
                baseWorkedEl.innerHTML = '<span class="text-muted fst-italic" style="font-size: 0.8rem;">Đang tải...</span>';
            }

            fetch(contextPath + '/hr/payroll?action=details_json&userId=' + userId + '&month=' + month + '&year=' + year)
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        console.error("Lỗi:", data.error);
                        return;
                    }

                    if (baseWorkedEl && data.baseWorkedSalary !== undefined) {
                        baseWorkedEl.textContent = new Intl.NumberFormat('vi-VN').format(Math.round(data.baseWorkedSalary)) + ' ₫';
                    }
                    if (data.insuranceBaseAmount !== undefined) {
                        document.getElementById('modalInsuranceBase').textContent = new Intl.NumberFormat('vi-VN').format(Math.round(data.insuranceBaseAmount)) + ' ₫';
                    }
                    if (data.taxableIncomeBase !== undefined) {
                        document.getElementById('modalTaxableBase').textContent = new Intl.NumberFormat('vi-VN').format(Math.round(data.taxableIncomeBase)) + ' ₫';
                    }

                    if (allowanceDetailsEl) {
                        let allowHtml = '';
                        if (data.allowances && data.allowances.length > 0) {
                            data.allowances.forEach(a => {
                                const badge = a.isBhxh
                                    ? '<span style="font-size:0.72em;background:#fee2e2;color:#b91c1c;padding:1px 5px;border-radius:4px;margin-left:4px;">(chịu BH)</span>'
                                    : '<span style="font-size:0.72em;background:#d1fae5;color:#065f46;padding:1px 5px;border-radius:4px;margin-left:4px;">(miễn BH)</span>';
                                allowHtml += '<div class="d-flex justify-content-between text-muted" style="align-items:center;">' +
                                    '<span>- ' + a.name + ':' + badge + '</span>' +
                                    '<span>+ ' + new Intl.NumberFormat('vi-VN').format(Math.round(a.amount)) + ' ₫</span>' +
                                '</div>';
                            });
                        } else {
                            allowHtml = '<div class="text-muted fst-italic">Không có</div>';
                        }
                        allowanceDetailsEl.innerHTML = allowHtml;
                    }

                    if (bonusDetailsEl) {
                        let bonusHtml = '';
                        if (data.bonuses && data.bonuses.length > 0) {
                            data.bonuses.forEach(b => {
                                let badges = '';
                                if (b.isBhxh === false) {
                                    badges += '<span style="font-size:0.72em;background:#d1fae5;color:#065f46;padding:1px 5px;border-radius:4px;margin-left:4px;">(miễn BH)</span>';
                                } else {
                                    badges += '<span style="font-size:0.72em;background:#fee2e2;color:#b91c1c;padding:1px 5px;border-radius:4px;margin-left:4px;">(chịu BH)</span>';
                                }
                                if (b.isTaxable === false) {
                                    badges += '<span style="font-size:0.72em;background:#d1fae5;color:#065f46;padding:1px 5px;border-radius:4px;margin-left:3px;">(miễn Thuế)</span>';
                                } else {
                                    badges += '<span style="font-size:0.72em;background:#fef3c7;color:#92400e;padding:1px 5px;border-radius:4px;margin-left:3px;">(chịu Thuế)</span>';
                                }
                                bonusHtml += '<div class="d-flex justify-content-between text-muted" style="align-items:center;">' +
                                    '<span>- ' + b.name + ':' + badges + '</span>' +
                                    '<span>+ ' + new Intl.NumberFormat('vi-VN').format(Math.round(b.amount)) + ' ₫</span>' +
                                '</div>';
                            });
                        } else {
                            bonusHtml = '<div class="text-muted fst-italic">Không có</div>';
                        }
                        bonusDetailsEl.innerHTML = bonusHtml;
                    }

                    if (insuranceDetailsEl) {
                        let insHtml = '';
                        if (data.insurances && data.insurances.length > 0) {
                            data.insurances.forEach(i => {
                                insHtml += `<div class="d-flex justify-content-between text-muted">
                                    <span>- \${i.name}:</span>
                                    <span>- \${new Intl.NumberFormat('vi-VN').format(Math.round(i.amount))} ₫</span>
                                </div>`;
                            });
                        } else {
                            insHtml = '<div class="text-muted fst-italic">Không có</div>';
                        }
                        insuranceDetailsEl.innerHTML = insHtml;
                    }


                    if (deductionDetailsEl) {
                        let dedHtml = '';
                        if (data.deductions && data.deductions.length > 0) {
                            data.deductions.forEach(d => {
                                dedHtml += `<div class="d-flex justify-content-between text-muted">
                                    <span>- \${d.name}:</span>
                                    <span>- \${new Intl.NumberFormat('vi-VN').format(Math.round(d.amount))} ₫</span>
                                </div>`;
                            });
                        } else {
                            dedHtml = '<div class="text-muted fst-italic">Không có</div>';
                        }
                        deductionDetailsEl.innerHTML = dedHtml;
                    }

                    if (taxDetailsEl && data.taxProfile) {
                        let taxHtml = '';
                        taxHtml += `<div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                            <span>- Khấu trừ bản thân (Tính thuế):</span>
                            <span>\${new Intl.NumberFormat('vi-VN').format(Math.round(data.taxProfile.personalDeduction))} ₫</span>
                        </div>`;
                        if (data.taxProfile.dependentCount > 0) {
                            let depTotal = data.taxProfile.dependentDeduction * data.taxProfile.dependentCount;
                            taxHtml += `<div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                                <span>- Khấu trừ phụ thuộc (\${data.taxProfile.dependentCount} người):</span>
                                <span>\${new Intl.NumberFormat('vi-VN').format(Math.round(depTotal))} ₫</span>
                            </div>`;
                        } else {
                            taxHtml += `<div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                                <span>- Khấu trừ người phụ thuộc:</span>
                                <span>0 ₫</span>
                            </div>`;
                        }
                        taxDetailsEl.innerHTML = taxHtml;
                    }
                })
                .catch(err => console.error("Error fetching details", err));

            // Status Badge Formatting
            const statusEl = document.getElementById('modalStatus');
            statusEl.textContent = status;
            statusEl.className = 'badge-s'; // reset
            statusEl.style.backgroundColor = ''; // reset custom style
            statusEl.style.color = '';
            if (status === 'Draft') statusEl.classList.add('b-draft');
            else if (status === 'Pending') statusEl.classList.add('b-pending');
            else if (status === 'Verified') {
                statusEl.classList.add('b-pending');
                statusEl.style.backgroundColor = 'rgba(59, 130, 246, 0.1)';
                statusEl.style.color = '#2563eb';
            }
            else if (status === 'Approved') statusEl.classList.add('b-approved');
            else if (status === 'Rejected') statusEl.classList.add('b-rejected');
            else if (status === 'Paid') statusEl.classList.add('b-paid');
        });
    }

    // --- MONTHLY TABLE: FILTER + PAGINATION ---
    window.monthlyAllRows = [];
    window.monthlyFilteredRows = [];
    window.monthlyCurrentPage = 1;
    const monthlyPerPage = 10;

    var monthlyTbody = document.querySelector('#monthlyTable tbody');
    if (monthlyTbody) {
        window.monthlyAllRows = Array.from(monthlyTbody.querySelectorAll('tr'));
        filterMonthlyTable();
    }

    // --- EMPLOYEE TABLE: FILTER + PAGINATION ---
    window.empAllRows = [];
    window.empFilteredRows = [];
    window.empCurrentPage = 1;
    const empPerPage = 10;

    var empTbody = document.querySelector('#employeeTable tbody');
    if (empTbody) {
        window.empAllRows = Array.from(empTbody.querySelectorAll('tr'));
        filterEmployeeTable();
    }
});

// Monthly table helpers
function filterMonthlyTable() {
    var selMonth = document.getElementById('filterMonth');
    var selYear  = document.getElementById('filterYear');
    var monthVal = selMonth ? selMonth.value : 'all';
    var yearVal  = selYear  ? selYear.value  : 'all';

    var monthlyTbody = document.querySelector('#monthlyTable tbody');
    if (!monthlyTbody) return;
    if (!window.monthlyAllRows || window.monthlyAllRows.length === 0) {
        window.monthlyAllRows = Array.from(monthlyTbody.querySelectorAll('tr'));
    }
    window.monthlyFilteredRows = window.monthlyAllRows.filter(function(row) {
        var text = row.cells[0] ? row.cells[0].textContent.trim() : '';
        // text is like "Tháng 6 / 2026"
        var mMatch = (monthVal === 'all') || (text.match(/Tháng\s*(\d+)/) && RegExp.$1 === monthVal);
        var yMatch = (yearVal  === 'all') || text.includes(yearVal);
        return mMatch && yMatch;
    });
    window.monthlyCurrentPage = 1;
    updateMonthlyPagination();
}

function updateMonthlyPagination() {
    var allRows = window.monthlyAllRows || [];
    var filtered = window.monthlyFilteredRows || allRows;
    allRows.forEach(function(r){ r.style.display = 'none'; });
    var total = filtered.length;
    var totalPages = Math.ceil(total / 10) || 1;
    var page = window.monthlyCurrentPage || 1;
    if (page > totalPages) page = totalPages;
    if (page < 1) page = 1;
    window.monthlyCurrentPage = page;
    var start = (page - 1) * 10;
    var end   = Math.min(start + 10, total);
    for (var i = start; i < end; i++) { filtered[i].style.display = ''; }
    var info = document.getElementById('monthlyPageInfo');
    if (info) info.textContent = total === 0 ? 'Không tìm thấy kết quả.' : 'Hiển thị ' + (start + 1) + ' - ' + end + ' trong số ' + total + ' kỳ lương.';
    var btnPrev = document.getElementById('btnMonthlyPrev');
    var btnNext = document.getElementById('btnMonthlyNext');
    if (btnPrev) btnPrev.disabled = (page === 1);
    if (btnNext) btnNext.disabled = (page === totalPages);
}

function monthlyPrevPage() {
    if ((window.monthlyCurrentPage || 1) > 1) { window.monthlyCurrentPage--; updateMonthlyPagination(); }
}
function monthlyNextPage() {
    var totalPages = Math.ceil(((window.monthlyFilteredRows || window.monthlyAllRows || []).length) / 10) || 1;
    if ((window.monthlyCurrentPage || 1) < totalPages) { window.monthlyCurrentPage++; updateMonthlyPagination(); }
}

// Employee table helpers
function filterEmployeeTable() {
    var selStatus = document.getElementById('filterEmpStatus');
    var statusVal = selStatus ? selStatus.value : 'all';

    var empTbody = document.querySelector('#employeeTable tbody');
    if (!empTbody) return;
    if (!window.empAllRows || window.empAllRows.length === 0) {
        window.empAllRows = Array.from(empTbody.querySelectorAll('tr'));
    }
    window.empFilteredRows = window.empAllRows.filter(function(row) {
        if (statusVal === 'all') return true;
        var badge = row.querySelector('.badge-s');
        return badge && badge.textContent.trim().includes(statusVal);
    });
    window.empCurrentPage = 1;
    updateEmpPagination();
}

function updateEmpPagination() {
    var allRows = window.empAllRows || [];
    var filtered = window.empFilteredRows || allRows;
    allRows.forEach(function(r){ r.style.display = 'none'; });
    var total = filtered.length;
    var totalPages = Math.ceil(total / 10) || 1;
    var page = window.empCurrentPage || 1;
    if (page > totalPages) page = totalPages;
    if (page < 1) page = 1;
    window.empCurrentPage = page;
    var start = (page - 1) * 10;
    var end   = Math.min(start + 10, total);
    for (var i = start; i < end; i++) { filtered[i].style.display = ''; }
    var info = document.getElementById('empPageInfo');
    if (info) info.textContent = total === 0 ? 'Không tìm thấy kết quả.' : 'Hiển thị ' + (start + 1) + ' - ' + end + ' trong số ' + total + ' nhân viên.';
    var btnPrev = document.getElementById('btnEmpPrev');
    var btnNext = document.getElementById('btnEmpNext');
    if (btnPrev) btnPrev.disabled = (page === 1);
    if (btnNext) btnNext.disabled = (page === totalPages);
}

function empPrevPage() {
    if ((window.empCurrentPage || 1) > 1) { window.empCurrentPage--; updateEmpPagination(); }
}
function empNextPage() {
    var totalPages = Math.ceil(((window.empFilteredRows || window.empAllRows || []).length) / 10) || 1;
    if ((window.empCurrentPage || 1) < totalPages) { window.empCurrentPage++; updateEmpPagination(); }
}
</script>

<jsp:include page="../footer.jsp" />


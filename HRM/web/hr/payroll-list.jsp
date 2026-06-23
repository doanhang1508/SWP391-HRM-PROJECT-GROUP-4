<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý bảng lương (HR) - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root{
        --pri:#6366f1;
        --pri-l:rgba(99,102,241,.1);
        --ok:#10b981;
        --ok-l:rgba(16,185,129,.1);
        --ng:#ef4444;
        --ng-l:rgba(239,68,68,.1);
        --warn:#f59e0b;
        --bg:#f4f7fe;
        --card:#fff;
        --txt:#1e293b;
        --muted:#64748b;
    }
    body{
        background:var(--bg);
        font-family:'Inter',sans-serif
    }
    .dashboard-wrapper{
        display:flex;
        min-height:calc(100vh - 64px)
    }
    .main-content{
        flex:1;
        padding:30px;
        width:calc(100% - 260px)
    }
    .page-header{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:28px;
        flex-wrap:wrap;
        gap:12px
    }
    .page-title{
        font-size:1.5rem;
        font-weight:700;
        color:var(--txt);
        margin:0
    }
    .breadcrumb-c{
        font-size:.85rem;
        color:var(--muted);
        margin:4px 0 0
    }
    .breadcrumb-c a{
        color:var(--pri);
        text-decoration:none
    }
    .btn-add{
        background:var(--pri);
        color:#fff;
        border:none;
        border-radius:10px;
        padding:10px 20px;
        font-weight:600;
        font-size:.88rem;
        display:inline-flex;
        align-items:center;
        gap:8px;
        cursor:pointer;
        transition:all .2s;
        text-decoration:none
    }
    .btn-add:hover{
        background:#4f46e5;
        transform:translateY(-2px);
        box-shadow:0 6px 20px rgba(99,102,241,.3);
        color:#fff
    }
    .btn-submit-all{
        background:var(--ok);
        color:#fff;
        border:none;
        border-radius:10px;
        padding:10px 20px;
        font-weight:600;
        font-size:.88rem;
        display:inline-flex;
        align-items:center;
        gap:8px;
        cursor:pointer;
        transition:all .2s;
        text-decoration:none
    }
    .btn-submit-all:hover{
        background:#059669;
        transform:translateY(-2px);
        box-shadow:0 6px 20px rgba(16,185,129,.3);
        color:#fff
    }
    .admin-panel{
        background:var(--card);
        border-radius:16px;
        padding:24px;
        box-shadow:0 4px 20px rgba(0,0,0,.03);
        border:1px solid rgba(0,0,0,.04);
        margin-bottom:24px
    }
    .panel-header{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:20px;
        padding-bottom:15px;
        border-bottom:1px solid #f1f5f9;
        flex-wrap:wrap;
        gap:10px
    }
    .panel-title{
        font-size:1.1rem;
        font-weight:700;
        color:var(--txt);
        margin:0;
        display:flex;
        align-items:center;
        gap:10px
    }
    .panel-icon{
        width:40px;
        height:40px;
        border-radius:10px;
        background:var(--pri-l);
        color:var(--pri);
        display:flex;
        align-items:center;
        justify-content:center
    }
    .tbl{
        width:100%;
        border-collapse:separate;
        border-spacing:0 6px
    }
    .tbl th{
        background:transparent;
        color:var(--muted);
        font-weight:600;
        font-size:.78rem;
        text-transform:uppercase;
        letter-spacing:.5px;
        padding:10px 14px;
        border:none;
        white-space:nowrap
    }
    .tbl td{
        background:#fff;
        padding:13px 14px;
        vertical-align:middle;
        color:#475569;
        font-size:.87rem;
        border-top:1px solid #f1f5f9;
        border-bottom:1px solid #f1f5f9
    }
    .tbl tr td:first-child{
        border-left:1px solid #f1f5f9;
        border-radius:10px 0 0 10px
    }
    .tbl tr td:last-child{
        border-right:1px solid #f1f5f9;
        border-radius:0 10px 10px 0
    }
    .tbl tbody tr:hover td{
        background:#f8fafc
    }
    .badge-s{
        padding:5px 12px;
        border-radius:6px;
        font-weight:600;
        font-size:.74rem;
        display:inline-flex;
        align-items:center;
        gap:5px
    }
    .b-draft{
        background:rgba(100, 116, 139, 0.1);
        color:#475569
    }
    .b-pending{
        background:rgba(245,158,11,.1);
        color:#d97706
    }
    .b-approved{
        background:var(--ok-l);
        color:var(--ok)
    }
    .b-rejected{
        background:var(--ng-l);
        color:var(--ng)
    }
    .b-paid{
        background:rgba(59, 130, 246, 0.1);
        color:#2563eb
    }
    .alert-c{
        border:none;
        border-radius:10px;
        font-size:.88rem;
        padding:12px 20px
    }
    .a-ok{
        background:#d1fae5;
        color:#065f46
    }
    .a-err{
        background:#fee2e2;
        color:#991b1b
    }
    .btn-a{
        height:32px;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        border-radius:8px;
        border:none;
        color:#fff;
        padding:0 12px;
        font-size:.82rem;
        font-weight:500;
        text-decoration:none;
        gap:5px;
        cursor:pointer;
        transition:all .2s
    }
    .btn-a:hover{
        transform:translateY(-2px);
        box-shadow:0 4px 10px rgba(0,0,0,.12);
        color:#fff
    }
    .btn-edit{
        background:#3b82f6
    }
    .btn-submit{
        background:var(--ok)
    }
    .btn-view{
        background:#0d9488
    }
    @media(max-width:768px){
        .main-content{
            width:100%!important;
            padding:20px 16px!important
        }
        .page-header{
            flex-direction:column;
            align-items:flex-start
        }
    }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="payroll" />
    </jsp:include>


    <div class="main-content">
        <c:choose>
            <c:when test="${viewMode == 'months'}">
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Quản Lý Bảng Lương theo Tháng</h1>
                        <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Bảng lương</p>
                    </div>
                    
                    <c:if test="${sessionScope.currentUser.roleId == 5}">
                        <div class="d-flex gap-2">
                            <button type="button"
                                    class="btn-add"
                                    data-bs-toggle="modal"
                                    data-bs-target="#generatePayrollModal">
                                <i class="fas fa-magic"></i> Khởi tạo kỳ lương
                            </button>
                        </div>
                    </c:if>
                </div>

                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-c a-ok alert-dismissible fade show mb-4"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-c a-err alert-dismissible fade show mb-4"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <div class="admin-panel">
                    <div class="panel-header">
                        <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-list"></i></div> Danh sách kỳ lương</h3>
                        <div class="d-flex gap-2 align-items-center">
                            <select id="filterMonth" onchange="filterMonthlyTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả tháng</option>
                                <option value="1">Tháng 1</option>
                                <option value="2">Tháng 2</option>
                                <option value="3">Tháng 3</option>
                                <option value="4">Tháng 4</option>
                                <option value="5">Tháng 5</option>
                                <option value="6">Tháng 6</option>
                                <option value="7">Tháng 7</option>
                                <option value="8">Tháng 8</option>
                                <option value="9">Tháng 9</option>
                                <option value="10">Tháng 10</option>
                                <option value="11">Tháng 11</option>
                                <option value="12">Tháng 12</option>
                            </select>
                            <select id="filterYear" onchange="filterMonthlyTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả năm</option>
                                <option value="2024">2024</option>
                                <option value="2025">2025</option>
                                <option value="2026">2026</option>
                                <option value="2027">2027</option>
                                <option value="2028">2028</option>
                                <option value="2029">2029</option>
                                <option value="2030">2030</option>
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
                                    <th>Trạng thái chung</th>
                                    <th class="text-end">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty monthlySummaries}">
                                        <tr>
                                            <td colspan="5" class="text-center" style="color:var(--muted)">Chưa có dữ liệu bảng lương nào được khởi tạo. Vui lòng chọn thời gian ở góc trên và bấm Khởi tạo.</td>
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
                                                        <c:when test="${s.status == 'Verified'}"><span class="badge-s b-pending" style="background:rgba(59, 130, 246, 0.1);color:#2563eb;"><i class="fas fa-user-check"></i> Verified</span></c:when>
                                                        <c:when test="${s.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-check"></i> Approved</span></c:when>
                                                        <c:when test="${s.status == 'Rejected'}"><span class="badge-s b-rejected"><i class="fas fa-times"></i> Rejected</span></c:when>
                                                        <c:when test="${s.status == 'Paid'}"><span class="badge-s b-paid"><i class="fas fa-check-double"></i> Paid</span></c:when>
                                                        <c:otherwise><span class="badge-s b-draft">${s.status}</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end">
                                                    <div class="d-flex justify-content-end gap-2">
                                                        <a href="${pageContext.request.contextPath}/hr/payroll?month=${s.month}&year=${s.year}" class="btn-a btn-view text-white" title="Xem danh sách nhân viên">
                                                            <i class="fas fa-eye"></i> Xem danh sách nhân viên
                                                        </a>
                                                        <c:if test="${(s.status == 'Draft' || s.status == 'Rejected') && sessionScope.currentUser.roleId == 5}">
                                                            <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;" onsubmit="showConfirmModal(event, 'Bạn có chắc muốn gửi duyệt tất cả bảng lương của tháng ${s.month}/${s.year}?');">
                                                                <input type="hidden" name="action" value="submit">
                                                                <input type="hidden" name="month" value="${s.month}">
                                                                <input type="hidden" name="year" value="${s.year}">
                                                                <button type="submit" class="btn-a btn-submit" title="Gửi duyệt toàn bộ"><i class="fas fa-paper-plane"></i> Gửi duyệt</button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${s.status == 'Pending' && sessionScope.currentUser.roleId == 2}">
                                                            <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;" onsubmit="showConfirmModal(event, 'Bạn có chắc muốn duyệt tất cả bảng lương của tháng ${s.month}/${s.year}?', 'Duyệt toàn bộ');">
                                                                <input type="hidden" name="action" value="hrApproveAll">
                                                                <input type="hidden" name="month" value="${s.month}">
                                                                <input type="hidden" name="year" value="${s.year}">
                                                                <button type="submit" class="btn-a btn-submit" style="background:var(--ok);" title="Duyệt toàn bộ"><i class="fas fa-check-double"></i> Duyệt toàn bộ</button>
                                                            </form>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;">
                            <span id="monthlyPageInfo" style="font-size:0.85rem;color:#64748b;">Đang tải...</span>
                            <div style="display:flex;gap:8px;">
                                <button onclick="monthlyPrevPage()" id="btnMonthlyPrev" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-left"></i></button>
                                <button onclick="monthlyNextPage()" id="btnMonthlyNext" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-right"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Chi Tiết Bảng Lương: Tháng ${selectedMonth}/${selectedYear}</h1>
                        <p class="breadcrumb-c">
                            <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; 
                            <a href="${pageContext.request.contextPath}/hr/payroll">Bảng lương</a> &gt; 
                            Chi tiết
                        </p>
                    </div>
                    
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/hr/payroll" class="btn btn-secondary d-inline-flex align-items-center gap-2" style="border-radius:10px;padding:10px 20px;font-weight:600;font-size:.88rem;color:#475569;background:#fff;border:1px solid #e2e8f0;text-decoration:none;">
                            <i class="fas fa-arrow-left"></i> Quay lại danh sách tháng
                        </a>
                        
                        <c:if test="${not empty payrollList}">
                            <a href="${pageContext.request.contextPath}/hr/payroll?action=exportExcel&month=${selectedMonth}&year=${selectedYear}" 
                               class="btn btn-info d-inline-flex align-items-center gap-2" 
                               style="border-radius:10px;padding:10px 20px;font-weight:600;font-size:.88rem;color:#fff;background:#0d9488;border:none;text-decoration:none;">
                                <i class="fas fa-file-excel"></i> Xuất Excel
                            </a>
                            <c:if test="${sessionScope.currentUser.roleId == 5 && (draftCount > 0 || rejectedCount > 0)}">
                                <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;" onsubmit="showConfirmModal(event, 'Bạn có chắc muốn gửi duyệt tất cả bảng lương của tháng này?');">
                                    <input type="hidden" name="action" value="submit">
                                    <input type="hidden" name="month" value="${selectedMonth}">
                                    <input type="hidden" name="year" value="${selectedYear}">
                                    <button type="submit" class="btn-submit-all">
                                        <i class="fas fa-paper-plane"></i> Gửi duyệt toàn bộ (${draftCount + rejectedCount})
                                    </button>
                                </form>
                            </c:if>
                            <c:if test="${sessionScope.currentUser.roleId == 2 && pendingCount > 0}">
                                <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;" onsubmit="showConfirmModal(event, 'Bạn có chắc muốn duyệt tất cả bảng lương Pending của tháng này?', 'Duyệt toàn bộ');">
                                    <input type="hidden" name="action" value="hrApproveAll">
                                    <input type="hidden" name="month" value="${selectedMonth}">
                                    <input type="hidden" name="year" value="${selectedYear}">
                                    <button type="submit" class="btn-submit-all" style="background:var(--ok);">
                                        <i class="fas fa-check-double"></i> Duyệt toàn bộ (${pendingCount})
                                    </button>
                                </form>
                            </c:if>
                        </c:if>
                    </div>
                </div>

                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-c a-ok alert-dismissible fade show mb-4"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-c a-err alert-dismissible fade show mb-4"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <div class="admin-panel">
                    <div class="panel-header">
                        <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-users"></i></div> Danh sách nhân viên trong kỳ lương</h3>
                        <div class="d-flex gap-2 align-items-center">
                            <select id="filterEmpStatus" onchange="filterEmployeeTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="Draft">Draft</option>
                                <option value="Pending">Pending</option>
                                <option value="Verified">Verified</option>
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
                                    <th>NV ID</th>
                                    <th>Họ và tên</th>
                                    <th>Tháng/Năm</th>
                                    <th>Ngày công</th>
                                    <th>Thực nhận (Net)</th>
                                    <th>Trạng thái</th>
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
                                                <td><span class="fw-bold" style="color:var(--pri)">${userNames[p.userId]}</span></td>
                                                <td>${p.month}/${p.year}</td>
                                                <td><span class="fw-semibold text-primary"><i class="fas fa-calendar-check me-1"></i>${p.workingDays}</span></td>
                                                <td><span class="fw-bold text-success"><fmt:formatNumber value="${p.netSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${p.status == 'Draft'}"><span class="badge-s b-draft"><i class="fas fa-edit"></i> Draft</span></c:when>
                                                        <c:when test="${p.status == 'Pending'}"><span class="badge-s b-pending"><i class="fas fa-clock"></i> Pending</span></c:when>
                                                        <c:when test="${p.status == 'Verified'}"><span class="badge-s b-pending" style="background:rgba(59, 130, 246, 0.1);color:#2563eb;"><i class="fas fa-user-check"></i> Verified</span></c:when>
                                                        <c:when test="${p.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-check"></i> Approved</span></c:when>
                                                        <c:when test="${p.status == 'Rejected'}"><span class="badge-s b-rejected"><i class="fas fa-times"></i> Rejected</span></c:when>
                                                        <c:when test="${p.status == 'Paid'}"><span class="badge-s b-paid"><i class="fas fa-check-double"></i> Paid</span></c:when>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end">
                                                    <div class="d-flex justify-content-end gap-2 align-items-center">
                                                        <button type="button" class="btn-a btn-view text-white" 
                                                                title="Xem chi tiết"
                                                                data-bs-toggle="modal"
                                                                data-bs-target="#payrollDetailModal"
                                                                data-userid="${p.userId}"
                                                                data-fullname="${userNames[p.userId]}"
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
                                                                data-status="${p.status}">
                                                            <i class="fas fa-eye"></i> Chi tiết
                                                        </button>
                                                        <c:if test="${sessionScope.currentUser.roleId == 5}">
                                                            <c:choose>
                                                                <c:when test="${p.status == 'Draft' || p.status == 'Rejected'}">
                                                                    <a href="${pageContext.request.contextPath}/hr/payroll?action=edit&id=${p.payrollId}" class="btn-a btn-edit" title="Chỉnh sửa"><i class="fas fa-edit"></i> Sửa</a>
                                                                    <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;" onsubmit="showConfirmModal(event, 'Bạn có chắc muốn gửi duyệt bảng lương của nhân viên này?');">
                                                                        <input type="hidden" name="action" value="submit">
                                                                        <input type="hidden" name="payrollId" value="${p.payrollId}">
                                                                        <button type="submit" class="btn-a btn-submit" title="Gửi duyệt"><i class="fas fa-paper-plane"></i> Gửi duyệt</button>
                                                                    </form>
                                                                </c:when>
                                                            </c:choose>
                                                        </c:if>
                                                        <c:if test="${sessionScope.currentUser.roleId == 2}">
                                                            <c:choose>
                                                                <c:when test="${p.status == 'Pending'}">
                                                                    <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;" onsubmit="showConfirmModal(event, 'Bạn có chắc muốn duyệt bảng lương của nhân viên này?', 'Duyệt bảng lương', 'fa-check', 'var(--ok)', 'var(--ok-l)');">
                                                                        <input type="hidden" name="action" value="hrApprove">
                                                                        <input type="hidden" name="payrollId" value="${p.payrollId}">
                                                                        <input type="hidden" name="month" value="${selectedMonth}">
                                                                        <input type="hidden" name="year" value="${selectedYear}">
                                                                        <button type="submit" class="btn-a btn-submit" style="background:var(--ok);" title="Duyệt"><i class="fas fa-check"></i> Duyệt</button>
                                                                    </form>
                                                                    <button type="button" class="btn-a btn-reject" style="background:var(--ng);" onclick="openRejectModal(${p.payrollId}, '${userNames[p.userId]}')">
                                                                        <i class="fas fa-times"></i> Từ chối
                                                                    </button>
                                                                </c:when>
                                                            </c:choose>
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
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;">
                            <span id="empPageInfo" style="font-size:0.85rem;color:#64748b;">Đang tải...</span>
                            <div style="display:flex;gap:8px;">
                                <button onclick="empPrevPage()" id="btnEmpPrev" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-left"></i></button>
                                <button onclick="empNextPage()" id="btnEmpNext" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-right"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>


<!-- Generate Payroll Modal -->
<div class="modal fade" id="generatePayrollModal" tabindex="-1" aria-labelledby="generatePayrollModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;border:none;box-shadow:0 10px 30px rgba(0,0,0,.12);">
            <div class="modal-header" style="background:linear-gradient(135deg,var(--pri),#4f46e5);color:#fff;border-radius:16px 16px 0 0;padding:20px 24px;">
                <h5 class="modal-title fw-bold" id="generatePayrollModalLabel">
                    <i class="fas fa-magic me-2"></i> Khởi tạo kỳ lương mới
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" onsubmit="confirmGeneratePayroll(event);">
                <input type="hidden" name="action" value="generateDraft">

                <div class="modal-body" style="padding:28px;">
                    <p class="text-muted mb-4" style="font-size:.9rem;">
                        Chọn tháng và năm để hệ thống khởi tạo bảng lương nháp cho kỳ lương mới.
                    </p>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Chọn kỳ công (Có dữ liệu chấm công)</label>
                        <select id="periodSelect" name="period" class="form-select" style="border-radius:10px;padding:10px 12px;" onchange="updateMonthYearValues()">
                            <c:forEach var="p" items="${attendancePeriods}">
                                <option value="${p.month}-${p.year}">Tháng ${p.month} / Năm ${p.year}</option>
                            </c:forEach>
                            <c:if test="${empty attendancePeriods}">
                                <option value="">-- Không có dữ liệu chấm công khả dụng --</option>
                            </c:if>
                        </select>
                        <input type="hidden" id="generateMonth" name="month" value="">
                        <input type="hidden" id="generateYear" name="year" value="">
                    </div>
                    <script>
                        function updateMonthYearValues() {
                            const select = document.getElementById('periodSelect');
                            const val = select.value;
                            if (val) {
                                const parts = val.split('-');
                                if (parts.length === 2) {
                                    document.getElementById('generateMonth').value = parts[0];
                                    document.getElementById('generateYear').value = parts[1];
                                    return;
                                }
                            }
                            document.getElementById('generateMonth').value = '';
                            document.getElementById('generateYear').value = '';
                        }
                        // Run on load
                        document.addEventListener("DOMContentLoaded", function() {
                            updateMonthYearValues();
                        });
                    </script>

                    <div class="mt-4 p-3" style="background:#f8fafc;border:1px dashed #cbd5e1;border-radius:12px;">
                        <div class="fw-semibold mb-1" style="color:var(--txt);">
                            <i class="fas fa-circle-info me-1 text-primary"></i> Lưu ý
                        </div>
                        <div class="text-muted" style="font-size:.86rem;">
                            Sau khi khởi tạo, bảng lương sẽ ở trạng thái <b>Draft</b> và có thể kiểm tra trước khi gửi duyệt. 
                            <br/><i class="fas fa-check-circle text-success mt-1"></i> Hệ thống sẽ tự động tổng hợp <b>ngày công</b> và <b>nghỉ phép có lương</b> để tính lương thực tế.
                        </div>
                    </div>
                </div>

                <div class="modal-footer" style="background:#f8fafc;border-top:1px solid #e2e8f0;border-radius:0 0 16px 16px;padding:16px 24px;">
                    <button type="button"
                            class="btn btn-secondary px-4 fw-semibold"
                            data-bs-dismiss="modal"
                            style="border-radius:8px;">
                        Hủy
                    </button>
                    <button type="submit" class="btn-add" style="border-radius:8px;">
                        <i class="fas fa-magic"></i> Khởi tạo
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
                <div class="d-flex align-items-center justify-content-between p-3 mb-4" style="background: var(--bg); border-radius: 12px; border: 1px dashed rgba(99,102,241,.25)">
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
                    <!-- Thu nhập (Income) -->
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
                                    <span class="text-muted">Tiền tăng ca:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalOvertime">+ 0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Phụ cấp:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalAllowance">+ 0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Thưởng:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalBonus">+ 0 ₫</span>
                                </div>
                                <hr style="margin: 10px 0; border-color: rgba(16,185,129,.2);">
                                <div class="d-flex justify-content-between fw-bold text-dark" style="font-size: 0.95rem;">
                                    <span>Lương Gross:</span>
                                    <span id="modalGross">0 ₫</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Khấu trừ & Thuế (Deductions) -->
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
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Thuế TNCN:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalTax">- 0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Khấu trừ khác / Phạt:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalDeduction">- 0 ₫</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Net Salary Highlight Card -->
                <div class="mt-4 p-4 text-center" style="background: linear-gradient(135deg, rgba(16,185,129,.1) 0%, rgba(99,102,241,.1) 100%); border-radius: 14px; border: 1px solid rgba(16,185,129,.2);">
                    <h6 class="text-uppercase fw-bold text-muted mb-2" style="font-size: 0.8rem; letter-spacing: 0.5px;">Thực Nhận (Net Salary)</h6>
                    <h2 class="fw-extrabold text-success mb-1" style="font-size: 2.2rem; font-weight: 800;" id="modalNet">0 ₫</h2>
                    <p class="text-muted small mb-0">Trạng thái: <span class="badge-s ms-1" id="modalStatus">Draft</span></p>
                </div>
            </div>
            <div class="modal-footer" style="background: #f8fafc; border-top: 1px solid #e2e8f0; border-radius: 0 0 16px 16px; padding: 16px 24px;">
                <button type="button" class="btn btn-secondary px-4 fw-semibold" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Reject Modal -->
<div class="modal fade" id="rejectModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:480px;">
        <div class="modal-content" style="border-radius:16px;border:none;box-shadow:0 15px 35px rgba(0,0,0,.15);">
            <div class="modal-header" style="background:linear-gradient(135deg,var(--ng),#dc2626);color:#fff;border-radius:16px 16px 0 0;padding:20px 24px;">
                <h5 class="modal-title fw-bold"><i class="fas fa-times-circle me-2"></i>Từ Chối Bảng Lương</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/hr/payroll">
                <input type="hidden" name="action" value="hrReject">
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
                    <button type="submit" class="btn-a btn-reject px-4" style="height:38px;font-size:.88rem;background:var(--ng);">
                        <i class="fas fa-times"></i> Xác nhận Từ chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Custom Confirmation Modal -->
<div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 15px 35px rgba(0,0,0,0.15); overflow: hidden;">
            <div class="modal-body text-center" style="padding: 35px 24px 28px;">
                <div class="mb-3 d-inline-flex align-items-center justify-content-center" 
                     id="confirmModalIconContainer"
                     style="width: 70px; height: 70px; border-radius: 50%; background-color: var(--pri-l); color: var(--pri); font-size: 1.8rem; transition: all 0.3s ease;">
                    <i class="fas fa-paper-plane" id="confirmModalIcon"></i>
                </div>
                <h5 class="fw-bold mb-2" id="confirmModalTitle" style="color: var(--txt); font-size: 1.2rem;">Xác nhận gửi duyệt</h5>
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
                            style="border-radius: 10px; background: linear-gradient(135deg, var(--pri), #4f46e5); border: none; font-size: 0.88rem; transition: all 0.2s; box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2); min-width: 110px;">
                        Xác nhận
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script>
let pendingFormToSubmit = null;

function showConfirmModal(event, message, title = 'Xác nhận gửi duyệt', iconClass = 'fa-paper-plane', themeColor = 'var(--pri)', themeBg = 'var(--pri-l)') {
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
        submitBtn.style.boxShadow = '0 4px 12px rgba(99, 102, 241, 0.2)';
    }
    
    const confirmModal = new bootstrap.Modal(document.getElementById('confirmModal'));
    confirmModal.show();
}

function confirmGeneratePayroll(event) {
    const month = document.getElementById('generateMonth').value;
    const year = document.getElementById('generateYear').value;
    showConfirmModal(event, 'Bạn có chắc muốn khởi tạo bảng lương tháng ' + month + '/' + year + '?', 'Khởi tạo kỳ lương', 'fa-magic', 'var(--ok)', 'var(--ok-l)');
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
    var monthlyAllRows = [];
    var monthlyFilteredRows = [];
    var monthlyCurrentPage = 1;
    const monthlyPerPage = 10;

    var monthlyTbody = document.querySelector('#monthlyTable tbody');
    if (monthlyTbody) {
        monthlyAllRows = Array.from(monthlyTbody.querySelectorAll('tr'));
        filterMonthlyTable();
    }

    // --- EMPLOYEE TABLE: FILTER + PAGINATION ---
    var empAllRows = [];
    var empFilteredRows = [];
    var empCurrentPage = 1;
    const empPerPage = 10;

    var empTbody = document.querySelector('#employeeTable tbody');
    if (empTbody) {
        empAllRows = Array.from(empTbody.querySelectorAll('tr'));
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

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
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
        <div class="page-header">
            <div>
                <h1 class="page-title">Quản Lý Bảng Lương</h1>
                <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Bảng lương</p>
            </div>
            
            <div class="d-flex gap-2">
                <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;">
                    <input type="hidden" name="action" value="generateDraft">
                    <input type="hidden" name="month" value="${selectedMonth}">
                    <input type="hidden" name="year" value="${selectedYear}">
                    <button type="submit" class="btn-add">
                        <i class="fas fa-magic"></i> Khởi tạo bảng lương
                    </button>
                </form>
                
                <c:if test="${not empty payrollList}">
                    <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn gửi duyệt tất cả bảng lương của tháng này?');">
                        <input type="hidden" name="action" value="submit">
                        <input type="hidden" name="month" value="${selectedMonth}">
                        <input type="hidden" name="year" value="${selectedYear}">
                        <button type="submit" class="btn-submit-all">
                            <i class="fas fa-paper-plane"></i> Gửi duyệt toàn bộ
                        </button>
                    </form>
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
                <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-calendar-alt"></i></div> Chọn thời gian</h3>
                <form action="${pageContext.request.contextPath}/hr/payroll" method="GET" class="d-flex gap-2 align-items-center">
                    <input type="hidden" name="action" value="list">
                    <select name="month" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}" ${m == selectedMonth ? 'selected' : ''}>Tháng ${m}</option>
                        </c:forEach>
                    </select>
                    <select name="year" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                        <c:forEach var="y" begin="2020" end="2030">
                            <option value="${y}" ${y == selectedYear ? 'selected' : ''}>Năm ${y}</option>
                        </c:forEach>
                    </select>
                    <button type="submit" class="btn btn-primary" style="border-radius:8px;padding:9px 20px;font-weight:600">Xem</button>
                </form>
            </div>

            <div class="table-responsive">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th>NV ID</th>
                            <th>Họ và tên</th>
                            <th>Tháng/Năm</th>
                            <th>Lương cơ bản</th>
                            <th>Ngày công</th>
                            <th>Tăng ca</th>
                            <th>Phụ cấp</th>
                            <th>Thưởng</th>
                            <th>Khấu trừ</th>
                            <th>Bảo hiểm</th>
                            <th>Thuế</th>
                            <th>Gross</th>
                            <th>Net</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty payrollList}">
                                <tr>
                                    <td colspan="15" class="text-center" style="color:var(--muted)">Chưa có dữ liệu bảng lương cho tháng này. Bấm nút Khởi tạo để generate nháp.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="p" items="${payrollList}">
                                    <tr>
                                        <td>#${p.userId}</td>
                                        <td><span class="fw-bold" style="color:var(--pri)">${userNames[p.userId]}</span></td>
                                        <td>${p.month}/${p.year}</td>
                                        <td><fmt:formatNumber value="${p.baseSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        <td>${p.workingDays}</td>
                                        <td><fmt:formatNumber value="${p.overtimeAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        <td><fmt:formatNumber value="${p.allowanceAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        <td><fmt:formatNumber value="${p.bonusAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        <td><fmt:formatNumber value="${p.deductionAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        <td><fmt:formatNumber value="${p.insuranceAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        <td><fmt:formatNumber value="${p.taxAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                        <td><span class="fw-bold"><fmt:formatNumber value="${p.grossSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span></td>
                                        <td><span class="fw-bold text-success"><fmt:formatNumber value="${p.netSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.status == 'Draft'}"><span class="badge-s b-draft"><i class="fas fa-edit"></i> Draft</span></c:when>
                                                <c:when test="${p.status == 'Pending'}"><span class="badge-s b-pending"><i class="fas fa-clock"></i> Pending</span></c:when>
                                                <c:when test="${p.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-check"></i> Approved</span></c:when>
                                                <c:when test="${p.status == 'Rejected'}"><span class="badge-s b-rejected"><i class="fas fa-times"></i> Rejected</span></c:when>
                                                <c:when test="${p.status == 'Paid'}"><span class="badge-s b-paid"><i class="fas fa-check-double"></i> Paid</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-2">
                                                <c:choose>
                                                    <c:when test="${p.status == 'Draft' || p.status == 'Rejected'}">
                                                        <a href="${pageContext.request.contextPath}/hr/payroll?action=edit&id=${p.payrollId}" class="btn-a btn-edit" title="Chỉnh sửa"><i class="fas fa-edit"></i> Sửa</a>
                                                        <form action="${pageContext.request.contextPath}/hr/payroll" method="POST" style="display:inline;">
                                                            <input type="hidden" name="action" value="submit">
                                                            <input type="hidden" name="payrollId" value="${p.payrollId}">
                                                            <button type="submit" class="btn-a btn-submit" title="Gửi duyệt"><i class="fas fa-paper-plane"></i> Gửi duyệt</button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted" style="font-size: 0.8rem">Không thao tác</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

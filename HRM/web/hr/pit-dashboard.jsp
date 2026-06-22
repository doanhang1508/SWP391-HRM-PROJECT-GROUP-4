<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý PIT Lũy tiến - Enterprise HRM" scope="request" />
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
        --warn:#f59e0b;
        --bg:#f4f7fe;
        --card:#fff;
        --txt:#1e293b;
        --muted:#64748b;
    }
    body{background:var(--bg);font-family:'Inter',sans-serif;}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px);}
    .main-content{flex:1;padding:30px;width:calc(100% - 260px);}
    .page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:28px;}
    .page-title{font-size:1.5rem;font-weight:700;color:var(--txt);margin:0;}
    .breadcrumb-c{font-size:.85rem;color:var(--muted);margin:4px 0 0;}
    .breadcrumb-c a{color:var(--pri);text-decoration:none;}
    .admin-panel{background:var(--card);border-radius:16px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);margin-bottom:24px;}
    .panel-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:1px solid #f1f5f9;}
    .panel-title{font-size:1.1rem;font-weight:700;margin:0;display:flex;align-items:center;gap:10px;}
    .panel-icon{width:40px;height:40px;border-radius:10px;background:var(--pri-l);color:var(--pri);display:flex;align-items:center;justify-content:center;}
    .tbl{width:100%;border-collapse:separate;border-spacing:0 6px;}
    .tbl th{color:var(--muted);font-weight:600;font-size:.78rem;text-transform:uppercase;padding:10px 14px;}
    .tbl td{background:#fff;padding:13px 14px;font-size:.87rem;border-top:1px solid #f1f5f9;border-bottom:1px solid #f1f5f9;}
    .tbl tr td:first-child{border-left:1px solid #f1f5f9;border-radius:10px 0 0 10px;}
    .tbl tr td:last-child{border-right:1px solid #f1f5f9;border-radius:0 10px 10px 0;}
    .tbl tbody tr:hover td{background:#f8fafc;}
    .btn-action{background:var(--pri);color:#fff;border:none;border-radius:8px;padding:8px 16px;font-weight:600;font-size:.85rem;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .2s;}
    .btn-action:hover{transform:translateY(-2px);box-shadow:0 4px 12px rgba(99,102,241,.3);color:#fff;}
    .stat-card{background:#fff;padding:20px;border-radius:16px;border:1px solid #e2e8f0;display:flex;align-items:center;gap:20px;}
    .stat-icon{width:60px;height:60px;border-radius:16px;display:flex;align-items:center;justify-content:center;font-size:1.5rem;}
    .alert-c{border-radius:10px;font-size:.88rem;padding:12px 20px;border:none;}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="pit" />
    </jsp:include>

    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Quản Lý PIT Lũy Tiến</h1>
                <p class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a> &gt; 
                    Tính thuế TNCN
                </p>
            </div>
            <div class="d-flex gap-2">
                <c:if test="${sessionScope.currentUser.roleId == 2}">
                    <a href="${pageContext.request.contextPath}/admin/tax?action=rules" class="btn-action" style="background:#64748b;"><i class="fas fa-sliders-h"></i> Cấu hình Thuế</a>
                </c:if>
                <a href="?action=taxProfiles" class="btn-action" style="background:#0d9488;"><i class="fas fa-users"></i> Hồ sơ Thuế NV</a>
                <c:if test="${sessionScope.currentUser.roleId == 2}">
                    <a href="${pageContext.request.contextPath}/admin/tax?action=auditLog" class="btn-action" style="background:#8b5cf6;"><i class="fas fa-history"></i> Lịch sử Audit</a>
                </c:if>
            </div>
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-c alert-success alert-dismissible fade show mb-4"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-c alert-danger alert-dismissible fade show mb-4"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <div class="row mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:var(--pri-l);color:var(--pri);"><i class="fas fa-users"></i></div>
                    <div>
                        <div class="text-muted" style="font-size:0.85rem;font-weight:600;text-transform:uppercase;">Nhân viên</div>
                        <h3 class="mb-0 fw-bold">${totalEmployees}</h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(59,130,246,.1);color:#3b82f6;"><i class="fas fa-wallet"></i></div>
                    <div>
                        <div class="text-muted" style="font-size:0.85rem;font-weight:600;text-transform:uppercase;">Tổng Lương Gross</div>
                        <h4 class="mb-0 fw-bold"><fmt:formatNumber value="${totalGross}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(239,68,68,.1);color:var(--ng);"><i class="fas fa-file-invoice-dollar"></i></div>
                    <div>
                        <div class="text-muted" style="font-size:0.85rem;font-weight:600;text-transform:uppercase;">Tổng Thuế PIT</div>
                        <h4 class="mb-0 fw-bold"><fmt:formatNumber value="${totalPIT}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h4>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:var(--ok-l);color:var(--ok);"><i class="fas fa-hand-holding-dollar"></i></div>
                    <div>
                        <div class="text-muted" style="font-size:0.85rem;font-weight:600;text-transform:uppercase;">Tổng Thực Nhận</div>
                        <h4 class="mb-0 fw-bold"><fmt:formatNumber value="${totalNet}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h4>
                    </div>
                </div>
            </div>
        </div>

        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-calculator"></i></div> Tính & Quản lý Thuế Kỳ ${selectedMonth}/${selectedYear}</h3>
                <div class="d-flex gap-2">
                    <form method="GET" action="pit" class="d-flex gap-2">
                        <select name="month" class="form-select" style="width:120px;border-radius:8px;">
                            <c:forEach var="m" begin="1" end="12">
                                <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                            </c:forEach>
                        </select>
                        <select name="year" class="form-select" style="width:120px;border-radius:8px;">
                            <c:forEach var="y" begin="2024" end="2030">
                                <option value="${y}" ${selectedYear == y ? 'selected' : ''}>Năm ${y}</option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn btn-outline-secondary" style="border-radius:8px;">Xem</button>
                    </form>
                    <c:if test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 2 || sessionScope.currentUser.roleId == 5}">
                        <form method="POST" action="pit" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn tính lại thuế cho toàn bộ nhân viên trong kỳ ${selectedMonth}/${selectedYear}? Việc này sẽ cập nhật lại bảng lương (nếu chưa chốt).');">
                            <input type="hidden" name="action" value="calculate">
                            <input type="hidden" name="month" value="${selectedMonth}">
                            <input type="hidden" name="year" value="${selectedYear}">
                            <button type="submit" class="btn-action" style="height:38px;"><i class="fas fa-play"></i> Tính PIT Toàn Bộ</button>
                        </form>
                    </c:if>
                </div>
            </div>

            <div class="table-responsive">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Gross</th>
                            <th>Bảo hiểm</th>
                            <th>Giảm trừ</th>
                            <th>Thu nhập tính thuế</th>
                            <th>Thuế PIT</th>
                            <th>Thực nhận</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${results}">
                            <tr>
                                <td>
                                    <div class="fw-bold text-dark">NV #${r.payroll.userId}</div>
                                </td>
                                <td class="fw-semibold"><fmt:formatNumber value="${r.taxResult.grossIncome}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                <td class="text-danger">-<fmt:formatNumber value="${r.taxResult.insuranceAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                <td class="text-muted">-<fmt:formatNumber value="${r.taxResult.totalDeduction}" type="currency" currencySymbol="₫" maxFractionDigits="0"/> <br><small>(${r.taxResult.dependentCount} NPT)</small></td>
                                <td class="fw-bold"><fmt:formatNumber value="${r.taxResult.taxableIncome}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                <td class="fw-bold text-danger"><fmt:formatNumber value="${r.taxResult.pitAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                <td class="fw-bold text-success"><fmt:formatNumber value="${r.taxResult.netSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></td>
                                <td class="text-end">
                                    <a href="?action=employeeTaxDetail&userId=${r.payroll.userId}&month=${selectedMonth}&year=${selectedYear}" class="btn-action" style="background:#0ea5e9;padding:6px 12px;font-size:0.8rem;">
                                        <i class="fas fa-search"></i> Chi tiết
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty results}">
                            <tr><td colspan="8" class="text-center text-muted">Chưa có bảng lương cho tháng này.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

</body>
</html>

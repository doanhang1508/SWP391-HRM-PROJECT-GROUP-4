<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Cấu hình Tham số Lương - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    :root {
        --pri: #6366f1; --ok: #10b981; --ng: #ef4444;
        --warn: #f59e0b; --bg: #f4f7fe; --card: #fff; --txt: #1e293b; --muted: #64748b;
    }
    body { background: var(--bg); font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 30px; max-width: 1000px; }
    .page-title { font-size: 1.5rem; font-weight: 700; color: var(--txt); margin: 0 0 4px; }
    .breadcrumb-c { font-size: .85rem; color: var(--muted); margin-bottom: 24px; }
    .breadcrumb-c a { color: var(--pri); text-decoration: none; }
    
    .panel {
        background: var(--card); border-radius: 16px; padding: 24px;
        box-shadow: 0 4px 20px rgba(0,0,0,.03); margin-bottom: 24px;
    }
    .panel-title { font-size: 1.1rem; font-weight: 700; color: var(--txt); margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
    .panel-title i { color: var(--pri); }
    
    .tbl { width: 100%; border-collapse: separate; border-spacing: 0 6px; }
    .tbl th { color: #64748b; font-weight: 600; font-size: .85rem; padding: 10px 14px; text-align: left; }
    .tbl td { background: #fff; padding: 12px 14px; font-size: .9rem; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
    .tbl tr:hover td { background: #fafbff; }
    
    .form-control {
        border: 1px solid #e2e8f0; border-radius: 8px; padding: 8px 12px;
        font-size: .9rem; color: var(--txt); width: 100%; max-width: 200px; outline: none; transition: all .2s;
    }
    .form-control:focus { border-color: var(--pri); box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    
    .btn-submit {
        background: var(--pri); color: #fff; border: none; border-radius: 8px;
        padding: 10px 24px; font-weight: 600; font-size: .9rem;
        display: inline-flex; align-items: center; gap: 8px; cursor: pointer; transition: all .2s; margin-top: 10px;
    }
    .btn-submit:hover { background: #4f46e5; transform: translateY(-1px); }
    
    .alert { padding: 14px 18px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; font-size: .88rem; font-weight: 500; }
    .alert-success { background: rgba(16,185,129,.1); color: #065f46; border: 1px solid #a7f3d0; }
    .alert-error { background: rgba(239,68,68,.1); color: #991b1b; border: 1px solid #fecaca; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="payroll-configs"/>
    </jsp:include>

    <div class="main-content">
        <h1 class="page-title"><i class="fas fa-cogs" style="color:var(--pri);margin-right:8px"></i>Cấu hình Tham số Lương</h1>
        <div class="breadcrumb-c">
            <a href="${pageContext.request.contextPath}/hr/dashboard">Dashboard</a> /
            <a href="${pageContext.request.contextPath}/hr/payroll">Lương & Thưởng</a> / Cấu hình
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <div class="panel">
            <div class="panel-title"><i class="fas fa-sliders-h"></i> Các Tham số Tính toán (Payroll Rules)</div>
            
            <form action="${pageContext.request.contextPath}/hr/payroll-configs" method="post">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th width="30%">Mã Tham số (Key)</th>
                            <th width="40%">Mô tả chi tiết</th>
                            <th width="30%">Giá trị thiết lập</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${configs}" var="c">
                            <tr>
                                <td>
                                    <strong>${c.configKey}</strong>
                                    <input type="hidden" name="configId" value="${c.id}">
                                </td>
                                <td style="color:var(--muted)">${c.description}</td>
                                <td>
                                    <input type="number" step="0.0001" name="configValue_${c.id}" value="${c.configValue}" class="form-control" required>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty configs}">
                            <tr><td colspan="3" style="text-align:center;color:var(--muted);padding:20px;">Chưa có dữ liệu cấu hình.</td></tr>
                        </c:if>
                    </tbody>
                </table>
                <div style="text-align: right; margin-top: 15px;">
                    <button type="submit" class="btn-submit"><i class="fas fa-save"></i> Lưu Thay Đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý khiếu nại lương - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --pri: #6366f1;
        --pri-l: rgba(99, 102, 241, 0.1);
        --ok: #10b981;
        --ok-l: rgba(16, 185, 129, 0.1);
        --ng: #ef4444;
        --ng-l: rgba(239, 68, 68, 0.1);
        --warn: #f59e0b;
        --bg: #f4f7fe;
        --card: #ffffff;
        --txt: #1e293b;
        --muted: #64748b;
    }
    body {
        background: var(--bg);
        font-family: 'Inter', sans-serif;
    }
    .dashboard-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .main-content {
        flex: 1;
        padding: 30px;
        width: calc(100% - 260px);
    }
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 28px;
    }
    .page-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--txt);
        margin: 0;
    }
    .breadcrumb-c {
        font-size: 0.85rem;
        color: var(--muted);
        margin: 4px 0 0;
    }
    .breadcrumb-c a {
        color: var(--pri);
        text-decoration: none;
    }
    .admin-panel {
        background: var(--card);
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
        border: 1px solid rgba(0, 0, 0, 0.04);
    }
    .panel-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 1px solid #f1f5f9;
    }
    .panel-title {
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--txt);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .panel-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        background: var(--pri-l);
        color: var(--pri);
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .tbl {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 6px;
    }
    .tbl th {
        color: var(--muted);
        font-weight: 600;
        font-size: 0.78rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 10px 14px;
        border: none;
    }
    .tbl td {
        background: #fff;
        padding: 14px;
        vertical-align: middle;
        color: #475569;
        font-size: 0.87rem;
        border-top: 1px solid #f1f5f9;
        border-bottom: 1px solid #f1f5f9;
    }
    .tbl tr td:first-child {
        border-left: 1px solid #f1f5f9;
        border-radius: 10px 0 0 10px;
    }
    .tbl tr td:last-child {
        border-right: 1px solid #f1f5f9;
        border-radius: 0 10px 10px 0;
    }
    .tbl tbody tr:hover td {
        background: #f8fafc;
    }
    .badge-s {
        padding: 5px 12px;
        border-radius: 6px;
        font-weight: 600;
        font-size: 0.74rem;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .b-pending {
        background: rgba(245, 158, 11, 0.1);
        color: #d97706;
    }
    .b-resolved {
        background: var(--ok-l);
        color: var(--ok);
    }
    .btn-resolve {
        background: var(--ok);
        color: #fff;
        border: none;
        border-radius: 8px;
        padding: 8px 16px;
        font-weight: 600;
        font-size: 0.82rem;
        cursor: pointer;
        transition: all 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .btn-resolve:hover {
        background: #059669;
        transform: translateY(-1px);
    }
</style>

<div class="dashboard-wrapper">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="payroll" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Yêu Cầu Khiếu Nại Lương</h1>
                <p class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <i class="fas fa-chevron-right mx-2" style="font-size: 0.7rem; color: var(--muted);"></i>
                    <span>Khiếu nại lương</span>
                </p>
            </div>
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.toastSuccess}">
            <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.toastSuccess}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="toastSuccess" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div class="panel-icon"><i class="fas fa-exclamation-circle"></i></div>
                    Danh sách khiếu nại phiếu lương
                </h3>
            </div>

            <div class="table-responsive">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Kỳ lương khiếu nại</th>
                            <th>Lý do khiếu nại</th>
                            <th>Ngày gửi</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty claims}">
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-4">Chưa có yêu cầu khiếu nại lương nào.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="c" items="${claims}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark">${c.fullName}</div>
                                            <div class="small text-muted">${c.email}</div>
                                        </td>
                                        <td><span class="fw-semibold">Tháng ${c.month} / ${c.year}</span></td>
                                        <td><div style="max-width: 300px; white-space: normal; word-break: break-all;">${c.reason}</div></td>
                                        <td><fmt:formatDate value="${c.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td>
                                            <span class="badge-s ${c.status eq 'Resolved' ? 'b-resolved' : 'b-pending'}">
                                                <i class="fas ${c.status eq 'Resolved' ? 'fa-check-circle' : 'fa-clock'}"></i>
                                                ${c.status}
                                            </span>
                                        </td>
                                        <td class="text-end">
                                            <c:if test="${c.status eq 'Pending'}">
                                                <form action="${pageContext.request.contextPath}/hr/resolve-claim" method="POST" style="display: inline-block;">
                                                    <input type="hidden" name="claimId" value="${c.claimId}" />
                                                    <button type="submit" class="btn-resolve">
                                                        <i class="fas fa-check"></i> Duyệt & Tính lại Lương
                                                    </button>
                                                </form>
                                            </c:if>
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

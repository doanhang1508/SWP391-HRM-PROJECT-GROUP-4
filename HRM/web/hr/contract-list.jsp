<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<jsp:include page="../header.jsp" />

<style>
    /* Enterprise SaaS Minimalist Theme */
    body { background-color: #f8f9fa; font-family: 'Be Vietnam Pro', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 24px; width: calc(100% - 260px); }
    
    .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
    .header-title { font-size: 1.25rem; font-weight: 700; color: #1a1a1a; margin: 0 0 4px 0; }
    .header-breadcrumb { font-size: 0.85rem; color: #6b7280; }
    
    .header-actions { display: flex; gap: 12px; align-items: center; }
    .search-input {
        padding: 8px 16px 8px 36px;
        border: 1px solid #e5e7eb;
        border-radius: 6px;
        font-size: 0.875rem;
        width: 250px;
        background: #fff url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="%239ca3af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>') no-repeat 10px center;
    }
    .filter-select {
        padding: 8px 30px 8px 12px;
        border: 1px solid #e5e7eb;
        border-radius: 6px;
        font-size: 0.875rem;
        background: #fff url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="%236b7280" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>') no-repeat right 10px center;
        appearance: none;
        color: #4b5563;
        cursor: pointer;
        outline: none;
    }
    .btn-primary-saas {
        background: #fff;
        border: 1px solid #e5e7eb;
        color: #1a1a1a;
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 0.875rem;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
    }
    .btn-primary-saas:hover { background: #f9fafb; }
    
    .stat-cards-container {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    .stat-card {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        padding: 16px;
        display: flex;
        flex-direction: column;
    }
    .stat-card-header { display: flex; align-items: center; gap: 8px; font-size: 0.85rem; color: #6b7280; margin-bottom: 12px; font-weight: 500; }
    .stat-card-value { font-size: 1.5rem; font-weight: 700; color: #1a1a1a; margin-bottom: 8px; }
    .stat-card-sub { font-size: 0.75rem; padding: 4px 8px; border-radius: 12px; display: inline-block; width: max-content; font-weight: 500; }
    
    .sc-blue .stat-card-header i { color: #3b82f6; }
    .sc-blue .stat-card-sub { background: #eff6ff; color: #2563eb; }
    
    .sc-green .stat-card-header i { color: #10b981; }
    .sc-green .stat-card-sub { background: #ecfdf5; color: #059669; }
    
    .sc-orange .stat-card-header i { color: #f59e0b; }
    .sc-orange .stat-card-sub { background: #fffbeb; color: #d97706; }
    
    .sc-red .stat-card-header i { color: #ef4444; }
    .sc-red .stat-card-sub { background: #fef2f2; color: #dc2626; }
    
    .dashboard-grid {
        display: block;
    }
    
    .card-panel {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        padding: 20px;
    }
    
    .panel-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        padding-bottom: 16px;
        border-bottom: 1px solid #f3f4f6;
    }
    .panel-title { font-size: 1rem; font-weight: 600; color: #1a1a1a; display: flex; align-items: center; gap: 8px; }
    .panel-title i { color: #3b82f6; }
    
    .filter-tabs { display: flex; gap: 8px; }
    .filter-tab {
        padding: 6px 12px;
        border: 1px solid #e5e7eb;
        border-radius: 6px;
        font-size: 0.85rem;
        color: #4b5563;
        text-decoration: none;
        background: #fff;
        font-weight: 500;
    }
    .filter-tab.active { background: #f9fafb; font-weight: 600; color: #1a1a1a; border-color: #d1d5db; }
    .filter-tab span { color: #9ca3af; margin-left: 4px; font-size: 0.8rem; }
    
    .saas-table { width: 100%; border-collapse: collapse; min-width: 1000px; }
    .saas-table th {
        padding: 16px 20px;
        text-align: left;
        font-size: 0.85rem;
        font-weight: 600;
        color: #6b7280;
        border-bottom: 2px solid #f3f4f6;
        white-space: nowrap;
    }
    .saas-table td {
        padding: 16px 20px;
        font-size: 0.875rem;
        color: #1a1a1a;
        border-bottom: 1px solid #f3f4f6;
        vertical-align: middle;
    }
    .saas-table tr:hover td { background: #f9fafb; }
    
    .emp-cell { display: flex; align-items: center; gap: 12px; }
    .emp-avatar {
        width: 36px; height: 36px; border-radius: 50%;
        background: #e0e7ff; color: #4338ca;
        display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 0.85rem;
    }
    .emp-info { display: flex; flex-direction: column; }
    .emp-name { font-weight: 600; color: #1a1a1a; margin-bottom: 2px; }
    .emp-code { font-size: 0.75rem; color: #6b7280; }
    
    .badge-status {
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 0.75rem;
        font-weight: 600;
    }
    .b-active { background: #ecfdf5; color: #059669; }
    .b-expiring { background: #fffbeb; color: #d97706; }
    .b-expired { background: #fef2f2; color: #dc2626; }
    .b-pending { background: #eff6ff; color: #2563eb; }
    
    .action-btns {
        display: flex; gap: 8px; justify-content: flex-end;
    }
    .action-btn {
        width: 32px; height: 32px; border-radius: 50%;
        border: 1px solid #e5e7eb; background: #fff;
        color: #6b7280; display: flex; align-items: center; justify-content: center;
        cursor: pointer; text-decoration: none;
    }
    .action-btn:hover { background: #f3f4f6; color: #1a1a1a; }
    
    .pagination-bar {
        display: flex; justify-content: space-between; align-items: center;
        padding-top: 16px; margin-top: 16px; border-top: 1px solid #e5e7eb;
    }
    .page-info { font-size: 0.85rem; color: #6b7280; }
    .page-controls { display: flex; gap: 4px; }
    .page-btn {
        min-width: 32px; height: 32px; border-radius: 4px;
        border: 1px solid #e5e7eb; background: #fff; color: #374151;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.85rem; text-decoration: none; cursor: pointer;
    }
    .page-btn.active { border-color: #3b82f6; background: #eff6ff; color: #2563eb; font-weight: 600; }
    .page-btn:hover:not(.active) { background: #f9fafb; }
    
    .widget-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid #f3f4f6;
    }
    .widget-item:last-child { border-bottom: none; }
    
    .wi-left .wi-title { font-size: 0.875rem; font-weight: 600; color: #1a1a1a; margin-bottom: 2px; }
    .wi-left .wi-sub { font-size: 0.75rem; color: #6b7280; }
    .wi-right { text-align: right; }
    .wi-right .wi-val { font-size: 0.875rem; font-weight: 600; color: #1a1a1a; }
    .wi-right .wi-date { font-size: 0.75rem; color: #d97706; }
    
    .type-bar-bg { width: 100%; height: 4px; background: #f3f4f6; border-radius: 2px; margin-top: 6px; }
    .type-bar-fill { height: 100%; background: #3b82f6; border-radius: 2px; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="contract-management" />
    </jsp:include>

    <div class="main-content">
        <form action="${pageContext.request.contextPath}/hr/contracts" method="GET" id="filterForm">
            <input type="hidden" name="status" value="${currentFilter}" id="statusInput">
            
            <div class="page-header">
                <div>
                    <h1 class="header-title">Quản lý hợp đồng</h1>
                    <div class="header-breadcrumb">HRM / Hợp đồng lao động</div>
                </div>
                <div class="header-actions">
                    <a href="${pageContext.request.contextPath}/hr/employees" class="btn-primary-saas" title="Chuyển đến Danh sách nhân viên để chọn người cần ký hợp đồng">
                        <i class="fas fa-user-check"></i> Chọn nhân viên ký HĐ
                    </a>
                </div>
            </div>

            <!-- 4 Stat Cards -->
            <div class="stat-cards-container">
                <div class="stat-card sc-blue">
                    <div class="stat-card-header"><i class="fas fa-file-contract"></i> Tổng hợp đồng</div>
                    <div class="stat-card-value">${counts['all']}</div>
                    <div class="stat-card-sub">Tất cả loại</div>
                </div>
                <div class="stat-card sc-green">
                    <div class="stat-card-header"><i class="fas fa-check-circle"></i> Đang hiệu lực</div>
                    <div class="stat-card-value">${counts['active']}</div>
                    <div class="stat-card-sub">Đã ký kết</div>
                </div>
                <div class="stat-card sc-orange">
                    <div class="stat-card-header"><i class="fas fa-exclamation-triangle"></i> Sắp hết hạn</div>
                    <div class="stat-card-value">${counts['expiring']}</div>
                    <div class="stat-card-sub">Trong 30 ngày</div>
                </div>
                <div class="stat-card sc-red">
                    <div class="stat-card-header"><i class="fas fa-times-circle"></i> Đã hết hạn</div>
                    <div class="stat-card-value">${counts['expired']}</div>
                    <div class="stat-card-sub">Cần xử lý</div>
                </div>
            </div>

            <div class="dashboard-grid">
                <!-- Main Table Area -->
                <div class="card-panel">
                    <div class="panel-header">
                        <div class="filter-tabs">
                            <a href="#" onclick="setFilter('all')" class="filter-tab ${currentFilter == 'all' ? 'active' : ''}">Tất cả <span>${counts['all']}</span></a>
                            <a href="#" onclick="setFilter('active')" class="filter-tab ${currentFilter == 'active' ? 'active' : ''}">Hiệu lực <span>${counts['active']}</span></a>
                            <a href="#" onclick="setFilter('expiring')" class="filter-tab ${currentFilter == 'expiring' ? 'active' : ''}">Sắp hết hạn <span>${counts['expiring']}</span></a>
                            <a href="#" onclick="setFilter('expired')" class="filter-tab ${currentFilter == 'expired' ? 'active' : ''}">Hết hạn <span>${counts['expired']}</span></a>
                        </div>
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <input type="text" name="search" class="search-input" placeholder="Tìm tên, mã NV..." value="${currentSearch}">
                            <select name="deptFilter" class="filter-select">
                                <option value="">Tất cả phòng ban</option>
                                <option value="1">Hành chính</option>
                                <option value="2">Nhân sự</option>
                                <option value="3">Kế toán</option>
                                <option value="4">Kinh doanh</option>
                                <option value="5">Sản xuất</option>
                            </select>
                            <select name="typeFilter" class="filter-select">
                                <option value="">Loại hợp đồng</option>
                                <option value="1">Thử việc</option>
                                <option value="2">Có thời hạn 1 năm</option>
                                <option value="3">Có thời hạn 3 năm</option>
                                <option value="4">Vô thời hạn</option>
                            </select>
                            <button type="submit" style="display:none;"></button>
                        </div>
                    </div>
                    
                    <div style="overflow-x: auto; padding-bottom: 16px;">
                        <table class="saas-table">
                            <thead>
                                <tr>
                                    <th>Nhân viên</th>
                                    <th>Loại hợp đồng</th>
                                    <th>Phòng ban</th>
                                    <th>Ngày bắt đầu</th>
                                    <th>Ngày kết thúc</th>
                                    <th>Trạng thái</th>
                                    <th style="text-align: right;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty contracts}">
                                        <tr>
                                            <td colspan="8" style="text-align: center; color: #6b7280; padding: 40px;">
                                                Không có dữ liệu hợp đồng.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="c" items="${contracts}">
                                            <c:set var="badgeClass" value="b-expired"/>
                                            <c:set var="badgeText" value="Hết hạn"/>
                                            <c:if test="${c.status == 'Active'}">
                                                <c:set var="badgeClass" value="b-active"/>
                                                <c:set var="badgeText" value="Hiệu lực"/>
                                                <c:if test="${c.endDate != null}">
                                                    <jsp:useBean id="now" class="java.util.Date"/>
                                                    <c:choose>
                                                        <c:when test="${(c.endDate.time - now.time) < 0}">
                                                            <c:set var="badgeClass" value="b-expired"/>
                                                            <c:set var="badgeText" value="Hết hạn"/>
                                                        </c:when>
                                                        <c:when test="${(c.endDate.time - now.time) <= (30 * 24 * 60 * 60 * 1000)}">
                                                            <c:set var="badgeClass" value="b-expiring"/>
                                                            <c:set var="badgeText" value="Sắp hết hạn"/>
                                                        </c:when>
                                                    </c:choose>
                                                </c:if>
                                            </c:if>
                                            <c:if test="${c.status == 'Pending'}">
                                                <c:set var="badgeClass" value="b-pending"/>
                                                <c:set var="badgeText" value="Chờ duyệt"/>
                                            </c:if>
                                            
                                            <tr>
                                                <td>
                                                    <div class="emp-cell">
                                                        <c:set var="initials" value=""/>
                                                        <c:if test="${not empty c.employeeName}">
                                                            <c:set var="parts" value="${fn:split(c.employeeName, ' ')}"/>
                                                            <c:set var="lastPart" value="${parts[fn:length(parts) - 1]}"/>
                                                            <c:set var="initials" value="${fn:substring(lastPart, 0, 1)}"/>
                                                        </c:if>
                                                        <div class="emp-avatar">${initials}</div>
                                                        <div class="emp-info">
                                                            <div class="emp-name">${c.employeeName}</div>
                                                            <div class="emp-code">${c.employeeCode}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div style="max-width: 150px; white-space: normal; line-height: 1.4;">${c.contractTypeName}</div>
                                                </td>
                                                <td>
                                                    <div style="max-width: 120px; white-space: normal; line-height: 1.4;">
                                                        ${c.departmentName != null ? c.departmentName : 'Chưa xếp phòng'}
                                                    </div>
                                                </td>
                                                <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${c.endDate != null}">
                                                            <fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/>
                                                        </c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                    <c:if test="${badgeClass == 'b-expiring' || badgeClass == 'b-expired'}">
                                                        <div style="font-size:0.75rem; color:#dc2626; margin-top:4px;">
                                                            ${badgeText}
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <span class="badge-status ${badgeClass}">${badgeText}</span>
                                                </td>
                                                <td>
                                                    <div class="action-btns">
                                                        <a href="${pageContext.request.contextPath}/hr/employee-contracts?userId=${c.userId}" class="action-btn" title="Quản lý Hợp đồng">
                                                            <i class="far fa-file-alt"></i>
                                                        </a>
                                                        <c:if test="${c.status == 'Pending' && (sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 2 || sessionScope.currentUser.roleId == 4)}">
                                                            <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST" style="display:inline;">
                                                                <input type="hidden" name="action" value="approve">
                                                                <input type="hidden" name="contractId" value="${c.contractId}">
                                                                <input type="hidden" name="userId" value="${c.userId}">
                                                                <button type="submit" class="action-btn" title="Phê duyệt" style="color: #059669; border-color: #059669; background: #ecfdf5;">
                                                                    <i class="fas fa-check"></i>
                                                                </button>
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
                    </div>
                    
                    <div class="pagination-bar">
                        <div class="page-info">1-${contracts.size()} / ${counts['all']} hợp đồng</div>
                        <div class="page-controls">
                            <a href="#" class="page-btn" style="color: #d1d5db; pointer-events: none;"><i class="fas fa-chevron-left"></i></a>
                            <a href="#" class="page-btn active">1</a>
                            <a href="#" class="page-btn" style="color: #d1d5db; pointer-events: none;"><i class="fas fa-chevron-right"></i></a>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    function setFilter(status) {
        document.getElementById('statusInput').value = status;
        document.getElementById('filterForm').submit();
    }
</script>

<jsp:include page="../footer.jsp" />

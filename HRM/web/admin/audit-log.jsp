<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="PIT Audit Log - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    :root{ --bg:#f4f7fe; --card:#fff; --txt:#1e293b; --pri:#6366f1;}
    body{background:var(--bg);font-family:'Inter',sans-serif;}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px);}
    .main-content{flex:1;padding:30px;}
    .admin-panel{background:var(--card);border-radius:16px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);}
    .tbl{width:100%;border-collapse:separate;border-spacing:0 6px;}
    .tbl th{color:#64748b;font-weight:600;font-size:.85rem;padding:10px 14px;}
    .tbl td{background:#fff;padding:13px 14px;font-size:.88rem;border-bottom:1px solid #f1f5f9; vertical-align:middle;}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="admin-audit-log" />
    </jsp:include>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1" style="color:var(--txt);">Lịch Sử Hệ Thống PIT (Audit Log)</h2>
                <p class="text-muted mb-0"><a href="${pageContext.request.contextPath}/admin/tax?action=rules" style="text-decoration:none;color:var(--pri);">Thuế TNCN</a> &gt; Audit Log</p>
            </div>
            <form method="GET" action="${pageContext.request.contextPath}/admin/tax" class="d-flex gap-2">
                <input type="hidden" name="action" value="auditLog">
                <select name="entityType" class="form-select" style="border-radius:8px;" onchange="this.form.submit()">
                    <option value="">-- Tất cả loại --</option>
                    <option value="payroll" ${entityType == 'payroll' ? 'selected' : ''}>Payroll (Lương)</option>
                    <option value="payroll_batch" ${entityType == 'payroll_batch' ? 'selected' : ''}>Payroll Batch</option>
                    <option value="employee_tax_profile" ${entityType == 'employee_tax_profile' ? 'selected' : ''}>Tax Profile</option>
                </select>
            </form>
        </div>

        <div class="admin-panel">
            <div class="table-responsive">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th>Log ID</th>
                            <th>Thời gian</th>
                            <th>Người thực hiện</th>
                            <th>Đối tượng</th>
                            <th>Hành động</th>
                            <th>IP Address</th>
                            <th style="width:40%">Chi tiết (Description)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${auditLogs}">
                            <tr>
                                <td class="text-muted">#${log.logId}</td>
                                <td class="fw-bold text-dark"><fmt:formatDate value="${log.changedAt}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                <td class="fw-bold text-primary">${log.changedByName} <span class="text-muted fw-normal">(${log.changedBy})</span></td>
                                <td><span class="badge bg-secondary bg-opacity-10 text-secondary">${log.entityType} #${log.entityId}</span></td>
                                <td><span class="badge bg-primary bg-opacity-10 text-primary">${log.action}</span></td>
                                <td><code>${log.ipAddress}</code></td>
                                <td class="text-muted" style="font-size:0.8rem;">${log.description}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty auditLogs}">
                            <tr><td colspan="7" class="text-center text-muted">Chưa có dữ liệu log.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>


<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Hợp Đồng Sắp Hết Hạn - Enterprise HRM" scope="request" />
<jsp:include page="../../header.jsp" />

<style>
    .expired-layout {
        display: flex;
        min-height: calc(100vh - 64px);
        background: #f0ede8;
        padding: 30px;
    }
    .expired-card {
        background: #ffffff;
        border-radius: 16px;
        padding: 32px;
        box-shadow: 0 4px 20px rgba(10,37,64,0.06);
        width: 100%;
    }
    .expired-header {
        border-bottom: 1px solid #e2e8f0;
        padding-bottom: 20px;
        margin-bottom: 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .expired-header h2 {
        margin: 0;
        font-size: 1.25rem;
        color: #0f172a;
    }
    .expired-table {
        width: 100%;
        border-collapse: collapse;
    }
    .expired-table th, .expired-table td {
        padding: 14px 18px;
        border-bottom: 1px solid #f1f5f9;
        text-align: left;
    }
    .expired-table th {
        background: #f8fafc;
        font-weight: 600;
        font-size: 0.85rem;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .expired-table tbody tr:hover { background: #f8fafc; }
    .status-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 600;
    }
    .status-expired { background: #fee2e2; color: #991b1b; }
    .status-expiring { background: #ffedd5; color: #9a3412; }
    .btn-action {
        background: #2563eb;
        color: white;
        padding: 6px 12px;
        border-radius: 6px;
        text-decoration: none;
        font-size: 0.8rem;
    }
    .btn-action:hover { opacity: 0.85; transition: opacity 0.2s; }
</style>

<div class="expired-layout">
    <div class="expired-card">
        
        <div class="expired-header">
            <h2><i class="fas fa-file-signature"></i> Hợp Đồng Sắp & Đã Hết Hạn</h2>
            <a href="${pageContext.request.contextPath}/hr/dashboard" style="color: #64748b; text-decoration: none;"><i class="fas fa-arrow-left"></i> Quay lại Dashboard</a>
        </div>

        <table class="expired-table">
            <thead>
                <tr>
                    <th>Nhân viên</th>
                    <th>Loại hợp đồng</th>
                    <th>Ngày bắt đầu</th>
                    <th>Ngày kết thúc</th>
                    <th>Tình trạng</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="c" items="${expiringContracts}">
                    <jsp:useBean id="today" class="java.util.Date"/>
                    <tr>
                        <td>
                            <strong>${c.employeeName}</strong>
                        </td>
                        <td>${c.contractTypeName}</td>
                        <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
                        <td><strong><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></strong></td>
                        <td>
                            <c:choose>
                                <c:when test="${c.endDate.time < today.time}">
                                    <span class="status-badge status-expired">Đã hết hạn</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge status-expiring">Sắp hết hạn</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td style="display: flex; gap: 6px; align-items: center;">
                            <a href="${pageContext.request.contextPath}/hr/employee-contracts?userId=${c.userId}" 
                               class="btn-action" style="background:#2563eb;">Xem HĐ</a>
                            <a href="${pageContext.request.contextPath}/hr/employee-contracts?userId=${c.userId}" 
                               class="btn-action" style="background:#16a34a;" title="Tạo hợp đồng gia hạn cho nhân viên này">Gia hạn</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty expiringContracts}">
                    <tr>
                        <td colspan="6" style="text-align: center; color: #94a3b8; padding: 20px;">Không có hợp đồng nào sắp hết hạn trong 30 ngày tới.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>

    </div>
</div>

<jsp:include page="../../footer.jsp" />

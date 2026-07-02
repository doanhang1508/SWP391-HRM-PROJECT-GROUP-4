<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Checklist Bàn Giao - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    .checklist-layout {
        display: flex;
        min-height: calc(100vh - 64px);
        background: #f0ede8;
        padding: 30px;
    }
    .checklist-card {
        background: #ffffff;
        border-radius: 16px;
        padding: 32px;
        box-shadow: 0 4px 20px rgba(10,37,64,0.06);
        width: 100%;
        max-width: 900px;
        margin: 0 auto;
    }
    .checklist-header {
        border-bottom: 1px solid #e2e8f0;
        padding-bottom: 20px;
        margin-bottom: 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .checklist-header h2 {
        margin: 0;
        font-size: 1.25rem;
        color: #0f172a;
    }
    .checklist-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
    }
    .checklist-table th, .checklist-table td {
        padding: 12px;
        border-bottom: 1px solid #e2e8f0;
        text-align: left;
    }
    .checklist-table th {
        background: #f8fafc;
        font-weight: 600;
        color: #475569;
    }
    .btn-add, .btn-save, .btn-complete-all, .btn-delete {
        padding: 8px 16px;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        font-weight: 500;
        font-size: 0.9rem;
    }
    .btn-add { background: #2563eb; color: #fff; }
    .btn-save { background: #10b981; color: #fff; }
    .btn-complete-all { background: #0f172a; color: #fff; }
    .btn-delete { background: #ef4444; color: #fff; }
    .alert-success { background: #d1fae5; color: #065f46; padding: 10px; border-radius: 8px; margin-bottom: 20px; }
    .alert-danger { background: #fee2e2; color: #991b1b; padding: 10px; border-radius: 8px; margin-bottom: 20px; }
</style>

<div class="checklist-layout">
    <div class="checklist-card">
        
        <div class="checklist-header">
            <h2><i class="fas fa-list-check"></i> Checklist Bàn Giao - ${resignationRequest.employeeName}</h2>
            <a href="${pageContext.request.contextPath}/hr/resignation-approval" style="color: #64748b; text-decoration: none;"><i class="fas fa-arrow-left"></i> Quay lại</a>
        </div>
        
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert-success">${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert-danger">${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <form action="${pageContext.request.contextPath}/hr/resignation-checklist" method="post" style="margin-bottom: 24px; display: flex; gap: 10px;">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="resignationId" value="${resignationRequest.resignationId}">
            <input type="text" name="itemName" placeholder="Tên tài sản / Công việc..." required style="flex: 1; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
            <button type="submit" class="btn-add"><i class="fas fa-plus"></i> Thêm mục</button>
        </form>

        <table class="checklist-table">
            <thead>
                <tr>
                    <th width="30%">Tên hạng mục</th>
                    <th width="15%">Hoàn thành</th>
                    <th width="20%">Ghi chú</th>
                    <th width="20%">Người xác nhận</th>
                    <th width="15%">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${checklist}">
                    <tr>
                        <form action="${pageContext.request.contextPath}/hr/resignation-checklist" method="post">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="resignationId" value="${resignationRequest.resignationId}">
                            <input type="hidden" name="checklistId" value="${item.checklistId}">
                            
                            <td><strong>${item.itemName}</strong></td>
                            <td>
                                <input type="checkbox" name="isCompleted" ${item.completed ? 'checked' : ''} style="width: 18px; height: 18px;">
                            </td>
                            <td>
                                <input type="text" name="note" value="${item.note}" style="width: 100%; padding: 6px; border: 1px solid #cbd5e1; border-radius: 6px;">
                            </td>
                            <td style="font-size: 0.85rem; color: #64748b;">
                                <c:if test="${item.completed}">
                                    ${item.completedByName}<br>
                                    <fmt:formatDate value="${item.completedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </c:if>
                            </td>
                            <td style="display: flex; gap: 6px;">
                                <button type="submit" class="btn-save"><i class="fas fa-save"></i></button>
                            </td>
                        </form>
                        <form action="${pageContext.request.contextPath}/hr/resignation-checklist" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="resignationId" value="${resignationRequest.resignationId}">
                            <input type="hidden" name="checklistId" value="${item.checklistId}">
                            <td>
                                <button type="submit" class="btn-delete"><i class="fas fa-trash"></i></button>
                            </td>
                        </form>
                    </tr>
                </c:forEach>
                <c:if test="${empty checklist}">
                    <tr>
                        <td colspan="5" style="text-align: center; color: #94a3b8; padding: 20px;">Chưa có hạng mục bàn giao nào.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <form action="${pageContext.request.contextPath}/hr/resignation-checklist" method="post" style="text-align: right; margin-top: 20px;" onsubmit="return confirm('Bạn có chắc chắn muốn hoàn thành toàn bộ thủ tục và đánh dấu Đơn nghỉ việc là COMPLETED?');">
            <input type="hidden" name="action" value="completeAll">
            <input type="hidden" name="resignationId" value="${resignationRequest.resignationId}">
            <button type="submit" class="btn-complete-all" ${empty checklist ? 'disabled' : ''}><i class="fas fa-check-double"></i> Hoàn tất thủ tục (COMPLETED)</button>
        </form>

    </div>
</div>

<jsp:include page="../footer.jsp" />

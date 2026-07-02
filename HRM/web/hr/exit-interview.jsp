<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Phỏng Vấn Thôi Việc - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    .interview-layout {
        display: flex;
        min-height: calc(100vh - 64px);
        background: #f0ede8;
        padding: 30px;
    }
    .interview-card {
        background: #ffffff;
        border-radius: 16px;
        padding: 32px;
        box-shadow: 0 4px 20px rgba(10,37,64,0.06);
        width: 100%;
        max-width: 700px;
        margin: 0 auto;
    }
    .interview-header {
        border-bottom: 1px solid #e2e8f0;
        padding-bottom: 20px;
        margin-bottom: 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .interview-header h2 {
        margin: 0;
        font-size: 1.25rem;
        color: #0f172a;
    }
    .form-group {
        margin-bottom: 20px;
    }
    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: 600;
        color: #334155;
    }
    .form-control {
        width: 100%;
        padding: 10px;
        border-radius: 8px;
        border: 1px solid #cbd5e1;
    }
    .btn-submit {
        background: #2563eb;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
    }
    .alert-success { background: #d1fae5; color: #065f46; padding: 10px; border-radius: 8px; margin-bottom: 20px; }
    .alert-danger { background: #fee2e2; color: #991b1b; padding: 10px; border-radius: 8px; margin-bottom: 20px; }
</style>

<div class="interview-layout">
    <div class="interview-card">
        
        <div class="interview-header">
            <h2><i class="fas fa-comments"></i> Phỏng Vấn Thôi Việc - ${resignationRequest.employeeName}</h2>
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

        <c:choose>
            <c:when test="${not empty exitInterview}">
                <div style="background: #f8fafc; padding: 20px; border-radius: 8px;">
                    <h4>Kết quả phỏng vấn đã được ghi nhận</h4>
                    <p><strong>Lý do chính:</strong> ${exitInterview.reasonCategory}</p>
                    <p><strong>Ghi chú/Phản hồi:</strong> ${exitInterview.comment}</p>
                    <p><strong>Ngày ghi nhận:</strong> <fmt:formatDate value="${exitInterview.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                </div>
            </c:when>
            <c:otherwise>
                <form action="${pageContext.request.contextPath}/hr/exit-interview" method="post">
                    <input type="hidden" name="resignationId" value="${resignationRequest.resignationId}">
                    
                    <div class="form-group">
                        <label>Lý do chính xin nghỉ</label>
                        <select name="reasonCategory" class="form-control" required>
                            <option value="">-- Chọn lý do --</option>
                            <option value="Salary">Mức lương / Chế độ đãi ngộ</option>
                            <option value="Career">Cơ hội thăng tiến / Phát triển sự nghiệp</option>
                            <option value="Study">Đi học / Nâng cao trình độ</option>
                            <option value="Family">Lý do gia đình / Cá nhân</option>
                            <option value="Health">Sức khỏe</option>
                            <option value="Other">Khác</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Ghi chú chi tiết / Phản hồi của nhân viên</label>
                        <textarea name="comment" class="form-control" rows="5" placeholder="Ghi nhận lại những chia sẻ của nhân viên..."></textarea>
                    </div>

                    <div style="text-align: right;">
                        <button type="submit" class="btn-submit"><i class="fas fa-save"></i> Lưu Kết Quả</button>
                    </div>
                </form>
            </c:otherwise>
        </c:choose>

    </div>
</div>

<jsp:include page="../footer.jsp" />

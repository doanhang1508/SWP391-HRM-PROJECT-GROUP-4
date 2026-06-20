<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Gửi khiếu nại lương - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --pri: #0d9488;
        --pri-l: rgba(13, 148, 136, 0.1);
        --bg: #f4f7fe;
        --card: #ffffff;
        --txt: #1e293b;
        --muted: #64748b;
    }
    body {
        background: var(--bg);
        font-family: 'Inter', sans-serif;
    }
    .emp-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .emp-content {
        flex: 1;
        padding: 30px;
        width: calc(100% - 260px);
        overflow-y: auto;
    }
    .page-header {
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
    .card-custom {
        background: var(--card);
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
        padding: 30px;
        max-width: 600px;
        margin: 0 auto;
    }
    .form-group {
        margin-bottom: 20px;
    }
    .form-label {
        font-weight: 600;
        color: var(--txt);
        font-size: 0.9rem;
        margin-bottom: 8px;
    }
    .form-control-c {
        width: 100%;
        padding: 12px;
        border-radius: 10px;
        border: 1px solid #cbd5e1;
        font-size: 0.9rem;
        outline: none;
        transition: all 0.2s;
    }
    .form-control-c:focus {
        border-color: var(--pri);
        box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.1);
    }
    .btn-submit {
        background: var(--pri);
        color: #fff;
        border: none;
        border-radius: 10px;
        padding: 12px 24px;
        font-weight: 600;
        font-size: 0.9rem;
        cursor: pointer;
        transition: all 0.2s;
        width: 100%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }
    .btn-submit:hover {
        background: #0f766e;
    }
    .payroll-summary {
        background: var(--bg);
        border-radius: 12px;
        padding: 18px;
        margin-bottom: 24px;
        border: 1px solid #e2e8f0;
    }
</style>

<div class="emp-layout">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="payroll" />
    </jsp:include>

    <!-- Main Content -->
    <div class="emp-content">
        <div class="page-header">
            <h1 class="page-title">Gửi Khiếu Nại Phiếu Lương</h1>
            <p class="breadcrumb-c">
                <a href="${pageContext.request.contextPath}/employee/payroll">Phiếu lương</a>
                <i class="fas fa-chevron-right mx-2" style="font-size: 0.7rem;"></i>
                <span>Gửi khiếu nại</span>
            </p>
        </div>

        <div class="card-custom">
            <div class="payroll-summary">
                <h5 class="fw-bold mb-3 text-dark"><i class="fas fa-file-invoice-dollar me-2 text-primary"></i>Thông tin phiếu lương khiếu nại</h5>
                <div class="row g-2 small">
                    <div class="col-6 text-muted">Kỳ lương:</div>
                    <div class="col-6 fw-semibold text-dark">Tháng ${payroll.month} / ${payroll.year}</div>
                    <div class="col-6 text-muted">Lương cơ bản:</div>
                    <div class="col-6 fw-semibold text-dark"><fmt:formatNumber value="${payroll.baseSalary}" type="number" groupingUsed="true"/> ₫</div>
                    <div class="col-6 text-muted">Thực nhận (Net):</div>
                    <div class="col-6 fw-bold text-success"><fmt:formatNumber value="${payroll.netSalary}" type="number" groupingUsed="true"/> ₫</div>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert">
                    ${errorMsg}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/employee/payroll-claim" method="post">
                <input type="hidden" name="payrollId" value="${payroll.payrollId}" />
                
                <div class="form-group">
                    <label class="form-label" for="complaintType">Loại khiếu nại <span class="text-danger">*</span></label>
                    <select id="complaintType" name="complaintType" class="form-control-c" required>
                        <option value="">-- Chọn loại khiếu nại --</option>
                        <option value="Sai ngày công">Sai ngày công</option>
                        <option value="Sai OT">Sai OT</option>
                        <option value="Thiếu phụ cấp">Thiếu phụ cấp</option>
                        <option value="Sai khấu trừ">Sai khấu trừ</option>
                        <option value="Sai thưởng/phạt">Sai thưởng/phạt</option>
                        <option value="Chưa nhận được tiền">Chưa nhận được tiền (Khiếu nại chuyển khoản)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="descriptionInput">Mô tả chi tiết <span class="text-danger">*</span></label>
                    <textarea id="descriptionInput" name="description" rows="5" class="form-control-c" 
                              placeholder="Vui lòng mô tả chi tiết lỗi (ví dụ: ngày 10/06 làm OT 4h nhưng chỉ tính 2h...)" required></textarea>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu Khiếu Nại
                </button>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

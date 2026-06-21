<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chỉnh sửa bảng lương nháp - Enterprise HRM" scope="request" />
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
    .admin-panel{
        background:var(--card);
        border-radius:16px;
        padding:24px;
        box-shadow:0 4px 20px rgba(0,0,0,.03);
        border:1px solid rgba(0,0,0,.04);
        margin-bottom:24px;
        max-width: 800px;
    }
    .panel-header{
        display:flex;
        align-items:center;
        margin-bottom:20px;
        padding-bottom:15px;
        border-bottom:1px solid #f1f5f9;
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
    .form-label {
        font-weight: 600;
        color: #475569;
        margin-bottom: 6px;
    }
    .form-control {
        padding: 10px 14px;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        font-size: 0.9rem;
    }
    .form-control:focus {
        border-color: var(--pri);
        box-shadow: 0 0 0 3px var(--pri-l);
    }
    .note-box {
        background: rgba(99, 102, 241, 0.05);
        border-left: 4px solid var(--pri);
        border-radius: 6px;
        padding: 12px 16px;
        margin-bottom: 20px;
        font-size: 0.88rem;
        color: #4f46e5;
    }
    .btn-save {
        background: var(--pri);
        color: #fff;
        border: none;
        border-radius: 8px;
        padding: 10px 24px;
        font-weight: 600;
        font-size: 0.9rem;
        cursor: pointer;
        transition: all 0.2s;
    }
    .btn-save:hover {
        background: #4f46e5;
        transform: translateY(-2px);
    }
    .btn-back {
        background: #fff;
        color: var(--muted);
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 10px 24px;
        font-weight: 500;
        font-size: 0.9rem;
        text-decoration: none;
        display: inline-block;
        transition: all 0.2s;
    }
    .btn-back:hover {
        background: #f8fafc;
        color: var(--txt);
    }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="payroll" />
    </jsp:include>

    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Chỉnh Sửa Bảng Lương Nháp</h1>
                <p class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; 
                    <a href="${pageContext.request.contextPath}/hr/payroll">Bảng lương</a> &gt; Chỉnh sửa
                </p>
            </div>
        </div>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show mb-4" style="border-radius: 10px">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <div class="admin-panel">
            <div class="panel-header">
                <div class="panel-icon"><i class="fas fa-edit"></i></div>
                <h3 class="panel-title">Chỉnh sửa bảng lương tháng ${payroll.month}/${payroll.year} của ${employeeName}</h3>
            </div>

            <form action="${pageContext.request.contextPath}/hr/payroll" method="POST">
                <input type="hidden" name="action" value="updateDraft">
                <input type="hidden" name="payrollId" value="${payroll.payrollId}">

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Mã nhân viên</label>
                        <input type="text" class="form-control bg-light" value="#${payroll.userId}" readonly>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Họ và tên</label>
                        <input type="text" class="form-control bg-light" value="${employeeName}" readonly>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-4">
                        <label class="form-label">Tháng / Năm</label>
                        <input type="text" class="form-control bg-light" value="${payroll.month} / ${payroll.year}" readonly>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Lương cơ bản</label>
                        <div class="input-group">
                            <input type="text" class="form-control bg-light text-end" value="<fmt:formatNumber value="${payroll.baseSalary}" type="number" maxFractionDigits="0"/>" readonly>
                            <span class="input-group-text bg-light">₫</span>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Trạng thái hiện tại</label>
                        <input type="text" class="form-control bg-light text-bold" value="${payroll.status}" readonly style="font-weight:700">
                    </div>
                </div>

                <hr style="border-color: #f1f5f9; margin: 24px 0">

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Số ngày công thực tế <span class="text-danger">*</span></label>
                        <input type="number" name="workingDays" class="form-control" value="${payroll.workingDays}" required min="0" max="31">
                        <small class="text-muted d-block mt-1"><i class="fas fa-magic"></i> Giá trị khởi tạo được tổng hợp tự động từ hệ thống chấm công và nghỉ phép có lương.</small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Tiền làm thêm giờ (Tăng ca) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="text" name="overtimeAmount" class="form-control text-end" value="<fmt:formatNumber value="${payroll.overtimeAmount}" type="number" maxFractionDigits="0"/>" required>
                            <span class="input-group-text">₫</span>
                        </div>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Phụ cấp <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="text" name="allowanceAmount" class="form-control text-end" value="<fmt:formatNumber value="${payroll.allowanceAmount}" type="number" maxFractionDigits="0"/>" required>
                            <span class="input-group-text">₫</span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Tiền thưởng khác <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="text" name="bonusAmount" class="form-control text-end" value="<fmt:formatNumber value="${payroll.bonusAmount}" type="number" maxFractionDigits="0"/>" required>
                            <span class="input-group-text">₫</span>
                        </div>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-4">
                        <label class="form-label">Khấu trừ <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="text" name="deductionAmount" class="form-control text-end" value="<fmt:formatNumber value="${payroll.deductionAmount}" type="number" maxFractionDigits="0"/>" required>
                            <span class="input-group-text">₫</span>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Bảo hiểm (nhân viên đóng) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="text" name="insuranceAmount" class="form-control text-end" value="<fmt:formatNumber value="${payroll.insuranceAmount}" type="number" maxFractionDigits="0"/>" required>
                            <span class="input-group-text">₫</span>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Thuế TNCN <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="text" name="taxAmount" class="form-control text-end" value="<fmt:formatNumber value="${payroll.taxAmount}" type="number" maxFractionDigits="0"/>" required>
                            <span class="input-group-text">₫</span>
                        </div>
                    </div>
                </div>

                <div class="note-box">
                    <i class="fas fa-info-circle me-1"></i>
                    <strong>Ghi chú:</strong> Lương Gross (`Lương cơ bản` + `Tăng ca` + `Phụ cấp` + `Thưởng`) và lương Net (`Gross` - `Khấu trừ` - `Bảo hiểm` - `Thuế`) sẽ được hệ thống tự động tính toán lại sau khi lưu thành công.
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn-save"><i class="fas fa-save me-1"></i>Lưu lại</button>
                    <a href="${pageContext.request.contextPath}/hr/payroll?month=${payroll.month}&year=${payroll.year}" class="btn-back"><i class="fas fa-arrow-left me-1"></i>Quay lại</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Format numeric input with commas on typing/focusout if needed, or keep simple.
    // Clean up commas before submitting just in case.
    document.querySelector('form').addEventListener('submit', function() {
        const moneyInputs = ['overtimeAmount', 'allowanceAmount', 'bonusAmount', 'deductionAmount', 'insuranceAmount', 'taxAmount'];
        moneyInputs.forEach(name => {
            const input = document.querySelector(`input[name="${name}"]`);
            if (input) {
                input.value = input.value.replace(/,/g, '');
            }
        });
    });
</script>

<jsp:include page="../footer.jsp" />

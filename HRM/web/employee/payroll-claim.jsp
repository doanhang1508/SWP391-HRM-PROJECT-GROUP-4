<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Gửi khiếu nại lương - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --pri: #0d9488; /* Teal theme for employee role */
        --pri-l: rgba(13, 148, 136, 0.1);
        --ok: #10b981;
        --ng: #ef4444;
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
        max-width: 700px;
    }
    .page-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--txt);
        margin: 0 0 4px;
    }
    .breadcrumb-c {
        font-size: 0.85rem;
        color: var(--muted);
    }
    .breadcrumb-c a {
        color: var(--pri);
        text-decoration: none;
    }
    .panel {
        background: var(--card);
        border-radius: 16px;
        padding: 28px;
        box-shadow: 0 4px 20px rgba(0,0,0,.04);
        border: 1px solid rgba(0,0,0,.05);
        margin-bottom: 24px;
    }
    .panel-title {
        font-size: 1rem;
        font-weight: 700;
        color: var(--txt);
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .panel-title i {
        color: var(--pri);
    }
    .payroll-summary {
        background: var(--bg);
        border-radius: 12px;
        padding: 18px;
        margin-bottom: 24px;
        border: 1px solid #e2e8f0;
    }
    .form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
        margin-bottom: 18px;
    }
    .form-group label {
        font-size: .82rem;
        font-weight: 600;
        color: var(--muted);
    }
    .form-control-c {
        border: 1.5px solid #e2e8f0;
        border-radius: 8px;
        padding: 10px 14px;
        font-size: .88rem;
        font-family: 'Inter', sans-serif;
        color: var(--txt);
        outline: none;
        transition: border-color .2s;
        background: #fff;
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
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        width: 100%;
    }
    .btn-submit:hover {
        background: #0f766e;
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
        <div style="margin-bottom:24px">
            <h1 class="page-title"><i class="fas fa-flag" style="color:var(--pri);margin-right:10px"></i>Khiếu Nại Phiếu Lương</h1>
            <div class="breadcrumb-c">
                <a href="${pageContext.request.contextPath}/employee/payroll">Phiếu lương</a> / Gửi khiếu nại
            </div>
        </div>

        <div class="panel">
            <div class="panel-title">
                <i class="fas fa-file-invoice-dollar"></i> Thông tin phiếu lương khiếu nại
            </div>
            
            <div class="payroll-summary">
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
                <div class="alert alert-danger p-3 rounded mb-3" role="alert">
                    ${errorMsg}
                </div>
            </c:if>

            <form id="claimForm" action="${pageContext.request.contextPath}/employee/payroll-claim" method="post">
                <input type="hidden" name="payrollId" value="${payroll.payrollId}" />
                
                <div class="form-group">
                    <label for="complaintType">Loại khiếu nại <span class="text-danger">*</span></label>
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
                    <label for="descriptionInput">Mô tả chi tiết <span class="text-danger">*</span></label>
                    <textarea id="descriptionInput" name="description" rows="5" class="form-control-c" 
                              placeholder="Vui lòng mô tả chi tiết lỗi (ví dụ: ngày 10/06 làm OT 4h nhưng chỉ tính 2h...)" required></textarea>
                </div>

                <button type="button" class="btn-submit" onclick="showConfirmPopup()">
                    <i class="fas fa-paper-plane"></i> Gửi Yêu Cầu Khiếu Nại
                </button>
            </form>
        </div>
    </div>
</div>

<!-- Confirm Popup Overlay -->
<div id="confirmOverlay" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.45);backdrop-filter:blur(3px);align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:16px;padding:32px 28px;width:420px;max-width:90vw;box-shadow:0 20px 50px rgba(0,0,0,.2);text-align:center;animation:popIn .25s ease-out;">
        <div style="width:56px;height:56px;background:linear-gradient(135deg,#0d9488,#14b8a6);border-radius:14px;display:flex;align-items:center;justify-content:center;margin:0 auto 18px;">
            <i class="fas fa-paper-plane" style="color:#fff;font-size:1.3rem;"></i>
        </div>
        <h5 style="margin:0 0 8px;font-weight:700;color:#1e293b;font-size:1.05rem;">Xác nhận gửi khiếu nại?</h5>
        <p style="margin:0 0 24px;color:#64748b;font-size:.88rem;line-height:1.5;">Bạn chắc chắn muốn gửi yêu cầu khiếu nại lương này? Sau khi gửi, khiếu nại sẽ được chuyển đến HR để xử lý.</p>
        <div style="display:flex;gap:12px;justify-content:center;">
            <button type="button" onclick="hideConfirmPopup()" style="flex:1;padding:10px 20px;background:#f1f5f9;color:#64748b;border:none;border-radius:10px;font-weight:600;font-size:.88rem;cursor:pointer;transition:background .2s;font-family:'Inter',sans-serif;" onmouseover="this.style.background='#e2e8f0'" onmouseout="this.style.background='#f1f5f9'">
                <i class="fas fa-times me-1"></i>Hủy
            </button>
            <button type="button" onclick="submitClaim()" style="flex:1;padding:10px 20px;background:linear-gradient(135deg,#0d9488,#14b8a6);color:#fff;border:none;border-radius:10px;font-weight:600;font-size:.88rem;cursor:pointer;transition:transform .2s,box-shadow .2s;font-family:'Inter',sans-serif;" onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 4px 14px rgba(13,148,136,.4)'" onmouseout="this.style.transform='none';this.style.boxShadow='none'">
                <i class="fas fa-check me-1"></i>Gửi khiếu nại
            </button>
        </div>
    </div>
</div>

<style>
    @keyframes popIn {
        from { opacity:0; transform:scale(.9) translateY(10px); }
        to { opacity:1; transform:scale(1) translateY(0); }
    }
</style>

<script>
    function showConfirmPopup() {
        var form = document.getElementById('claimForm');
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }
        var overlay = document.getElementById('confirmOverlay');
        overlay.style.display = 'flex';
    }
    function hideConfirmPopup() {
        document.getElementById('confirmOverlay').style.display = 'none';
    }
    function submitClaim() {
        document.getElementById('claimForm').submit();
    }
    document.getElementById('confirmOverlay').addEventListener('click', function(e) {
        if (e.target === this) hideConfirmPopup();
    });
</script>

<jsp:include page="../footer.jsp" />


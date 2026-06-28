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
    body{background:var(--bg);font-family:'Inter',sans-serif}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px)}
    .main-content{flex:1;padding:30px;width:calc(100% - 260px)}
    .page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:28px;flex-wrap:wrap;gap:12px}
    .page-title{font-size:1.5rem;font-weight:700;color:var(--txt);margin:0}
    .breadcrumb-c{font-size:.85rem;color:var(--muted);margin:4px 0 0}
    .breadcrumb-c a{color:var(--pri);text-decoration:none}
    .edit-grid{display:grid;grid-template-columns:1fr 340px;gap:24px;align-items:start}
    @media(max-width:992px){.edit-grid{grid-template-columns:1fr}}
    .admin-panel{
        background:var(--card);border-radius:16px;padding:24px;
        box-shadow:0 4px 20px rgba(0,0,0,.03);border:1px solid rgba(0,0,0,.04);margin-bottom:24px;
    }
    .panel-header{display:flex;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:1px solid #f1f5f9;gap:10px}
    .panel-title{font-size:1.1rem;font-weight:700;color:var(--txt);margin:0;display:flex;align-items:center;gap:10px}
    .panel-icon{width:40px;height:40px;border-radius:10px;background:var(--pri-l);color:var(--pri);display:flex;align-items:center;justify-content:center}
    .form-label{font-weight:600;color:#475569;margin-bottom:6px}
    .form-control{padding:10px 14px;border-radius:8px;border:1px solid #e2e8f0;font-size:.9rem;transition:border-color .2s,box-shadow .2s}
    .form-control:focus{border-color:var(--pri);box-shadow:0 0 0 3px var(--pri-l)}
    .form-control.auto-field{background:#f8fafc;color:#475569;font-weight:600;cursor:not-allowed;border-style:dashed}
    .auto-badge{display:inline-flex;align-items:center;gap:4px;font-size:.7rem;background:var(--ok-l);color:#059669;padding:2px 8px;border-radius:20px;font-weight:600;margin-left:6px}
    .note-box{background:rgba(99,102,241,.05);border-left:4px solid var(--pri);border-radius:6px;padding:12px 16px;margin-bottom:20px;font-size:.88rem;color:#4f46e5}
    .btn-save{background:var(--pri);color:#fff;border:none;border-radius:8px;padding:10px 24px;font-weight:600;font-size:.9rem;cursor:pointer;transition:all .2s}
    .btn-save:hover{background:#4f46e5;transform:translateY(-2px)}
    .btn-back{background:#fff;color:var(--muted);border:1px solid #e2e8f0;border-radius:8px;padding:10px 24px;font-weight:500;font-size:.9rem;text-decoration:none;display:inline-block;transition:all .2s}
    .btn-back:hover{background:#f8fafc;color:var(--txt)}

    /* Live Preview Panel */
    .preview-panel{position:sticky;top:90px}
    .preview-panel .panel-icon{background:var(--ok-l);color:#059669}
    .preview-row{display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid #f1f5f9;font-size:.88rem}
    .preview-row:last-child{border-bottom:none}
    .preview-label{color:var(--muted);font-weight:500}
    .preview-value{font-weight:700;color:var(--txt);font-variant-numeric:tabular-nums;transition:color .3s}
    .preview-value.changed{color:var(--pri);animation:pulse-value .4s ease}
    .preview-divider{border:none;border-top:2px dashed #e2e8f0;margin:4px 0}
    .preview-total{font-size:1rem}
    .preview-total .preview-value{font-size:1.15rem}
    .preview-net{background:linear-gradient(135deg,#f0fdf4,#dcfce7);border-radius:10px;padding:14px;margin-top:8px}
    .preview-net .preview-label{color:#166534;font-weight:600}
    .preview-net .preview-value{color:#15803d;font-size:1.2rem}
    .recalc-indicator{display:none;align-items:center;gap:6px;font-size:.78rem;color:var(--pri);margin-top:10px}
    .recalc-indicator.active{display:flex}
    .recalc-indicator .spinner{width:14px;height:14px;border:2px solid var(--pri-l);border-top:2px solid var(--pri);border-radius:50%;animation:spin .6s linear infinite}
    @keyframes spin{to{transform:rotate(360deg)}}
    @keyframes pulse-value{0%{transform:scale(1)}50%{transform:scale(1.05)}100%{transform:scale(1)}}
    .section-label{font-size:.78rem;font-weight:700;color:var(--pri);text-transform:uppercase;letter-spacing:.5px;margin:16px 0 8px;display:flex;align-items:center;gap:6px}
    .section-label i{font-size:.7rem}
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

        <div class="edit-grid">
            <!-- LEFT: Edit Form -->
            <div class="admin-panel">
                <div class="panel-header">
                    <div class="panel-icon"><i class="fas fa-edit"></i></div>
                    <h3 class="panel-title">Chỉnh sửa bảng lương tháng ${payroll.month}/${payroll.year} của ${employeeName}</h3>
                </div>

                <form id="editPayrollForm" action="${pageContext.request.contextPath}/hr/payroll" method="POST">
                    <input type="hidden" name="action" value="updateDraft">
                    <input type="hidden" name="payrollId" id="payrollId" value="${payroll.payrollId}">

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

                    <div class="section-label"><i class="fas fa-pen"></i> Khoản HR có thể chỉnh sửa</div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Số ngày công thực tế <span class="text-danger">*</span></label>
                            <input type="number" step="any" name="workingDays" class="form-control" value="${payroll.workingDays}" required min="0" max="31">
                            <small class="text-muted d-block mt-1"><i class="fas fa-magic"></i> Giá trị khởi tạo được tổng hợp tự động từ hệ thống chấm công và nghỉ phép có lương.</small>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Tiền làm thêm giờ (Tăng ca) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="text" name="overtimeAmount" id="overtimeAmount" class="form-control text-end editable-amount" value="<fmt:formatNumber value="${payroll.overtimeAmount}" type="number" maxFractionDigits="0"/>" required>
                                <span class="input-group-text">₫</span>
                            </div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Phụ cấp <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="text" name="allowanceAmount" id="allowanceAmount" class="form-control text-end editable-amount" value="<fmt:formatNumber value="${payroll.allowanceAmount}" type="number" maxFractionDigits="0"/>" required>
                                <span class="input-group-text">₫</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Tiền thưởng khác <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="text" name="bonusAmount" id="bonusAmount" class="form-control text-end editable-amount" value="<fmt:formatNumber value="${payroll.bonusAmount}" type="number" maxFractionDigits="0"/>" required>
                                <span class="input-group-text">₫</span>
                            </div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Khấu trừ (Kỷ luật / Phạt) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="text" name="deductionAmount" id="deductionAmount" class="form-control text-end editable-amount" value="<fmt:formatNumber value="${payroll.deductionAmount}" type="number" maxFractionDigits="0"/>" required>
                                <span class="input-group-text">₫</span>
                            </div>
                        </div>
                    </div>

                    <hr style="border-color: #f1f5f9; margin: 24px 0">

                    <div class="section-label"><i class="fas fa-calculator"></i> Hệ thống tự động tính toán</div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Bảo hiểm (BHXH + BHYT + BHTN) <span class="auto-badge"><i class="fas fa-robot"></i> Tự động</span></label>
                            <div class="input-group">
                                <input type="text" id="insuranceDisplay" class="form-control text-end auto-field" value="<fmt:formatNumber value="${payroll.insuranceAmount}" type="number" maxFractionDigits="0"/>" readonly>
                                <span class="input-group-text" style="border-style:dashed">₫</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Thuế TNCN (PIT lũy tiến) <span class="auto-badge"><i class="fas fa-robot"></i> Tự động</span></label>
                            <div class="input-group">
                                <input type="text" id="taxDisplay" class="form-control text-end auto-field" value="<fmt:formatNumber value="${payroll.taxAmount}" type="number" maxFractionDigits="0"/>" readonly>
                                <span class="input-group-text" style="border-style:dashed">₫</span>
                            </div>
                        </div>
                    </div>

                    <div class="note-box">
                        <i class="fas fa-info-circle me-1"></i>
                        <strong>Lưu ý:</strong> Bảo hiểm và Thuế TNCN được hệ thống <strong>tự động tính toán lại</strong> dựa trên Gross Salary khi bạn thay đổi các khoản thưởng, phụ cấp hoặc khấu trừ. Bảng preview bên phải sẽ cập nhật trực tiếp.
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn-save" id="btnSave"><i class="fas fa-save me-1"></i>Lưu & Tính toán lại</button>
                        <a href="${pageContext.request.contextPath}/hr/payroll?month=${payroll.month}&year=${payroll.year}" class="btn-back"><i class="fas fa-arrow-left me-1"></i>Quay lại</a>
                    </div>
                </form>
            </div>

            <!-- RIGHT: Live Preview Panel -->
            <div class="admin-panel preview-panel">
                <div class="panel-header">
                    <div class="panel-icon"><i class="fas fa-chart-pie"></i></div>
                    <h3 class="panel-title">Xem trước kết quả</h3>
                </div>

                <div class="preview-row">
                    <span class="preview-label"><i class="fas fa-wallet me-1"></i> Lương cơ bản</span>
                    <span class="preview-value" id="pvBase"><fmt:formatNumber value="${payroll.baseSalary}" type="number" maxFractionDigits="0"/></span>
                </div>
                <div class="preview-row">
                    <span class="preview-label"><i class="fas fa-clock me-1"></i> Tăng ca</span>
                    <span class="preview-value" id="pvOvertime"><fmt:formatNumber value="${payroll.overtimeAmount}" type="number" maxFractionDigits="0"/></span>
                </div>
                <div class="preview-row">
                    <span class="preview-label"><i class="fas fa-hand-holding-usd me-1"></i> Phụ cấp</span>
                    <span class="preview-value" id="pvAllowance"><fmt:formatNumber value="${payroll.allowanceAmount}" type="number" maxFractionDigits="0"/></span>
                </div>
                <div class="preview-row">
                    <span class="preview-label"><i class="fas fa-gift me-1"></i> Thưởng</span>
                    <span class="preview-value" id="pvBonus"><fmt:formatNumber value="${payroll.bonusAmount}" type="number" maxFractionDigits="0"/></span>
                </div>

                <hr class="preview-divider">

                <div class="preview-row preview-total">
                    <span class="preview-label"><strong>Gross Salary</strong></span>
                    <span class="preview-value" id="pvGross" style="color:var(--pri)"><fmt:formatNumber value="${payroll.grossSalary}" type="number" maxFractionDigits="0"/></span>
                </div>

                <hr class="preview-divider">

                <div class="preview-row">
                    <span class="preview-label"><i class="fas fa-shield-alt me-1"></i> Bảo hiểm</span>
                    <span class="preview-value" id="pvInsurance" style="color:#dc2626">-<fmt:formatNumber value="${payroll.insuranceAmount}" type="number" maxFractionDigits="0"/></span>
                </div>
                <div class="preview-row">
                    <span class="preview-label"><i class="fas fa-receipt me-1"></i> Thuế TNCN</span>
                    <span class="preview-value" id="pvTax" style="color:#dc2626">-<fmt:formatNumber value="${payroll.taxAmount}" type="number" maxFractionDigits="0"/></span>
                </div>
                <div class="preview-row">
                    <span class="preview-label"><i class="fas fa-minus-circle me-1"></i> Khấu trừ</span>
                    <span class="preview-value" id="pvDeduction" style="color:#dc2626">-<fmt:formatNumber value="${payroll.deductionAmount}" type="number" maxFractionDigits="0"/></span>
                </div>

                <div class="preview-net">
                    <div class="preview-row" style="border:none;padding:0">
                        <span class="preview-label"><i class="fas fa-money-bill-wave me-1"></i> NET SALARY</span>
                        <span class="preview-value" id="pvNet"><fmt:formatNumber value="${payroll.netSalary}" type="number" maxFractionDigits="0"/></span>
                    </div>
                </div>

                <div class="recalc-indicator" id="recalcIndicator">
                    <div class="spinner"></div>
                    <span>Đang tính toán lại...</span>
                </div>

            </div>

        </div>
    </div>
</div>

<script>
(function() {
    const contextPath = '${pageContext.request.contextPath}';
    const payrollId = document.getElementById('payrollId').value;
    const editableInputs = document.querySelectorAll('.editable-amount');
    let debounceTimer = null;

    // Format number with commas
    function formatNumber(num) {
        if (num == null || isNaN(num)) return '0';
        return Math.round(num).toLocaleString('vi-VN');
    }

    // Parse number from formatted string
    function parseNum(str) {
        if (!str) return 0;
        return parseFloat(str.replace(/,/g, '').replace(/\./g, '')) || 0;
    }

    // Trigger recalculate via AJAX
    function recalculate() {
        const overtime = parseNum(document.getElementById('overtimeAmount').value);
        const allowance = parseNum(document.getElementById('allowanceAmount').value);
        const bonus = parseNum(document.getElementById('bonusAmount').value);
        const deduction = parseNum(document.getElementById('deductionAmount').value);

        // Update editable preview values immediately
        document.getElementById('pvOvertime').textContent = formatNumber(overtime);
        document.getElementById('pvAllowance').textContent = formatNumber(allowance);
        document.getElementById('pvBonus').textContent = formatNumber(bonus);
        document.getElementById('pvDeduction').textContent = '-' + formatNumber(deduction);

        // Show loading indicator
        document.getElementById('recalcIndicator').classList.add('active');

        const url = contextPath + '/hr/payroll?action=recalculate' +
            '&payrollId=' + payrollId +
            '&overtimeAmount=' + overtime +
            '&allowanceAmount=' + allowance +
            '&bonusAmount=' + bonus +
            '&deductionAmount=' + deduction;

        fetch(url)
            .then(r => r.json())
            .then(data => {
                if (data.error) {
                    console.error(data.error);
                    return;
                }

                // Update auto-calculated form fields
                document.getElementById('insuranceDisplay').value = formatNumber(data.insuranceAmount);
                document.getElementById('taxDisplay').value = formatNumber(data.taxAmount);

                // Update preview panel with animation
                animateValue('pvInsurance', '-' + formatNumber(data.insuranceAmount));
                animateValue('pvTax', '-' + formatNumber(data.taxAmount));
                animateValue('pvGross', formatNumber(data.grossSalary));
                animateValue('pvNet', formatNumber(data.netSalary));
            })
            .catch(err => console.error('Recalculate error:', err))
            .finally(() => {
                document.getElementById('recalcIndicator').classList.remove('active');
            });
    }

    function animateValue(elementId, newValue) {
        const el = document.getElementById(elementId);
        if (el.textContent !== newValue) {
            el.textContent = newValue;
            el.classList.add('changed');
            setTimeout(() => el.classList.remove('changed'), 400);
        }
    }

    // Debounced recalculate on input change
    editableInputs.forEach(input => {
        input.addEventListener('input', function() {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(recalculate, 500);
        });
        input.addEventListener('change', function() {
            clearTimeout(debounceTimer);
            recalculate();
        });
    });

    // Clean up commas before submitting
    document.getElementById('editPayrollForm').addEventListener('submit', function() {
        editableInputs.forEach(input => {
            input.value = input.value.replace(/,/g, '');
        });
    });
})();
</script>

<jsp:include page="../footer.jsp" />

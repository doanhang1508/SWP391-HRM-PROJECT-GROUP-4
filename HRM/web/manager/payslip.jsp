<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Phiếu lương cá nhân - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --pri: #0d9488; /* Teal theme for employee role */
        --pri-l: rgba(13, 148, 136, 0.1);
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
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 28px;
        flex-wrap: wrap;
        gap: 12px;
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
    .btn-export {
        background: var(--pri);
        color: #fff;
        border: none;
        border-radius: 10px;
        padding: 10px 20px;
        font-weight: 600;
        font-size: 0.88rem;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
    }
    .btn-export:hover {
        background: #0f766e;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(13, 148, 136, 0.3);
        color: #fff;
    }
    .card-custom {
        background: var(--card);
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
        padding: 24px;
        margin-bottom: 24px;
    }
    .filter-section {
        display: flex;
        gap: 16px;
        flex-wrap: wrap;
        align-items: center;
        margin-bottom: 20px;
    }
    .form-select-c {
        padding: 8px 16px;
        border-radius: 8px;
        border: 1px solid #cbd5e1;
        font-size: 0.88rem;
        color: var(--txt);
        outline: none;
        background-color: #fff;
    }
    .table-responsive {
        border-radius: 12px;
        overflow: hidden;
        border: 1px solid #edf2f7;
    }
    .table-custom {
        width: 100%;
        margin-bottom: 0;
        border-collapse: collapse;
    }
    .table-custom th {
        background-color: #f8fafc;
        color: var(--muted);
        font-weight: 700;
        font-size: 0.78rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 14px 20px;
        border-bottom: 2px solid #edf2f7;
        text-align: left;
    }
    .table-custom td {
        padding: 16px 20px;
        border-bottom: 1px solid #edf2f7;
        font-size: 0.88rem;
        color: var(--txt);
        vertical-align: middle;
    }
    .table-custom tbody tr:hover {
        background-color: #f8fafc;
    }
    .badge-s {
        font-size: 0.72rem;
        font-weight: 700;
        padding: 6px 12px;
        border-radius: 9999px;
        display: inline-block;
        text-transform: uppercase;
    }
    .b-approved { background-color: var(--ok-l); color: var(--ok); }
    .b-paid { background-color: rgba(37, 99, 235, 0.1); color: #2563eb; }
    
    .btn-action {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: none;
        cursor: pointer;
        transition: all 0.2s;
    }
    .btn-view {
        background-color: var(--pri-l);
        color: var(--pri);
    }
    .btn-view:hover {
        background-color: var(--pri);
        color: #fff;
    }
    .btn-pdf {
        background-color: var(--ng-l);
        color: var(--ng);
        text-decoration: none;
    }
    .btn-pdf:hover {
        background-color: var(--ng);
        color: #fff;
    }
    
    /* Pagination Styles */
    .pagination-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 20px;
    }
    .pagination-info {
        font-size: 0.82rem;
        color: var(--muted);
    }
    .pagination-buttons {
        display: flex;
        gap: 8px;
    }
    .btn-pag {
        padding: 8px 14px;
        border-radius: 8px;
        border: 1px solid #cbd5e1;
        background: #fff;
        font-size: 0.82rem;
        font-weight: 600;
        color: var(--txt);
        cursor: pointer;
        transition: all 0.2s;
    }
    .btn-pag:hover:not(:disabled) {
        background: #f1f5f9;
        border-color: #94a3b8;
    }
    .btn-pag:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
</style>

<div class="emp-layout">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="personal-payslip" />
    </jsp:include>

    <!-- Main Content -->
    <div class="emp-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Lịch Sử Phiếu Lương</h1>
                <p class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard">Tổng quan</a>
                    <i class="fas fa-chevron-right mx-2" style="font-size: 0.7rem;"></i>
                    <span>Phiếu lương cá nhân</span>
                </p>
            </div>
        </div>

        <div class="card-custom">
            <!-- Filter section -->
            <div class="filter-section">
                <div>
                    <label for="filterMonth" class="form-label fw-semibold text-muted small mb-1">Tháng</label>
                    <select id="filterMonth" class="form-select-c" onchange="filterPayslipTable()">
                        <option value="all">Tất cả tháng</option>
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}">Tháng ${m}</option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label for="filterYear" class="form-label fw-semibold text-muted small mb-1">Năm</label>
                    <select id="filterYear" class="form-select-c" onchange="filterPayslipTable()">
                        <option value="all">Tất cả năm</option>
                        <option value="2024">2024</option>
                        <option value="2025">2025</option>
                        <option value="2026">2026</option>
                    </select>
                </div>
            </div>

            <!-- Table -->
            <div class="table-responsive">
                <table class="table-custom" id="payslipTable">
                    <thead>
                        <tr>
                            <th>Kỳ Lương</th>
                            <th>Lương Cơ Bản</th>
                            <th>Ngày Công Thực Tế</th>
                            <th>Tổng Thu Nhập (Gross)</th>
                            <th>Thực Nhận (Net)</th>
                            <th>Trạng Thái</th>
                            <th style="width: 120px; text-align: center;">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${payslipList}">
                            <tr>
                                <td class="fw-semibold">Tháng ${p.month} / ${p.year}</td>
                                <td><fmt:formatNumber value="${p.baseSalary}" type="number" groupingUsed="true"/> ₫</td>
                                <td>${p.workingDays} ngày</td>
                                <td class="fw-semibold"><fmt:formatNumber value="${p.grossSalary}" type="number" groupingUsed="true"/> ₫</td>
                                <td class="fw-bold text-success"><fmt:formatNumber value="${p.netSalary}" type="number" groupingUsed="true"/> ₫</td>
                                <td>
                                    <span class="badge-s ${p.status eq 'Approved' ? 'b-approved' : 'b-paid'}">
                                        ${p.status}
                                    </span>
                                </td>
                                <td style="text-align: center; white-space: nowrap;">
                                    <button class="btn-action btn-view" 
                                            data-bs-toggle="modal" 
                                            data-bs-target="#payrollDetailModal"
                                            data-userid="${p.userId}"
                                            data-fullname="${employeeName}"
                                            data-monthyear="${p.month}/${p.year}"
                                            data-basesalary="<fmt:formatNumber value='${p.baseSalary}' type='number' groupingUsed='true'/> ₫"
                                            data-workingdays="${p.workingDays}"
                                            data-overtime="<fmt:formatNumber value='${p.overtimeAmount != null ? p.overtimeAmount : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-allowance="<fmt:formatNumber value='${p.allowanceAmount != null ? p.allowanceAmount : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-bonus="<fmt:formatNumber value='${p.bonusAmount != null ? p.bonusAmount : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-deduction="<fmt:formatNumber value='${p.deductionAmount != null ? p.deductionAmount : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-insurance="<fmt:formatNumber value='${p.insuranceAmount != null ? p.insuranceAmount : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-tax="<fmt:formatNumber value='${p.taxAmount != null ? p.taxAmount : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-gross="<fmt:formatNumber value='${p.grossSalary != null ? p.grossSalary : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-net="<fmt:formatNumber value='${p.netSalary != null ? p.netSalary : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-insurancebenefit="<fmt:formatNumber value='${p.insuranceBenefit != null ? p.insuranceBenefit : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-insurancebase="<fmt:formatNumber value='${p.insuranceBaseAmount != null ? p.insuranceBaseAmount : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-taxablebase="<fmt:formatNumber value='${p.taxableIncomeBase != null ? p.taxableIncomeBase : 0}' type='number' groupingUsed='true'/> ₫"
                                            data-status="${p.status}">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/manager/payslip?action=print&month=${p.month}&year=${p.year}" 
                                       target="_blank" 
                                       class="btn-action btn-pdf ms-1" 
                                       title="Xuất file PDF">
                                        <i class="fas fa-file-pdf"></i>
                                    </a>

                                </td>
                            </tr>


                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Pagination container -->
            <div class="pagination-container">
                <div class="pagination-info" id="pageInfo">
                    Hiển thị 0 - 0 trong số 0 phiếu lương.
                </div>
                <div class="pagination-buttons">
                    <button class="btn-pag" id="btnPrev" onclick="prevPage()"><i class="fas fa-chevron-left me-1"></i>Trước</button>
                    <button class="btn-pag" id="btnNext" onclick="nextPage()">Sau<i class="fas fa-chevron-right ms-1"></i></button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Payroll Detail Modal -->
<div class="modal fade" id="payrollDetailModal" tabindex="-1" aria-labelledby="payrollDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">
            <div class="modal-header" style="background: linear-gradient(135deg, var(--pri), #0f766e); color: #fff; border-radius: 16px 16px 0 0; padding: 20px 24px;">
                <h5 class="modal-title fw-bold" id="payrollDetailModalLabel"><i class="fas fa-file-invoice-dollar me-2"></i> Chi Tiết Phiếu Lương</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 30px;">
                <!-- Employee Header Summary -->
                <div class="d-flex align-items-center justify-content-between p-3 mb-4" style="background: var(--bg); border-radius: 12px; border: 1px dashed rgba(13,148,136,.25)">
                    <div>
                        <h6 class="text-muted mb-1 text-uppercase fw-bold" style="font-size: 0.72rem; letter-spacing: 0.5px;">Nhân viên</h6>
                        <h5 class="fw-bold mb-0 text-primary" id="modalEmpName">Nguyễn Văn A</h5>
                    </div>
                    <div class="text-end">
                        <h6 class="text-muted mb-1 text-uppercase fw-bold" style="font-size: 0.72rem; letter-spacing: 0.5px;">Mã NV / Kỳ Lương</h6>
                        <p class="fw-bold mb-0 text-dark"><span id="modalEmpId">#0</span> | <span id="modalMonthYear">06/2026</span></p>
                    </div>
                </div>

                <!-- Details Grid -->
                <div class="row g-4">
                    <!-- Thu nhập (Income) -->
                    <div class="col-md-6">
                        <div class="p-3" style="background: rgba(16,185,129,.04); border-radius: 12px; border: 1px solid rgba(16,185,129,.1); height: 100%;">
                            <h6 class="fw-bold text-success mb-3 pb-2" style="border-bottom: 2px solid rgba(16,185,129,.2); display: flex; justify-content: space-between;">
                                <span><i class="fas fa-plus-circle me-1"></i> Các Khoản Thu Nhập</span>
                            </h6>
                            <div class="d-flex flex-column gap-2" style="font-size: 0.88rem;">
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Lương cơ bản:</span>
                                    <span class="fw-semibold text-dark" id="modalBaseSalary">0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Ngày công thực tế:</span>
                                    <span class="fw-semibold text-dark" id="modalWorkingDays">0</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Lương theo ngày công:</span>
                                    <span class="fw-semibold text-dark" id="modalBaseWorkedSalary">
                                        <span class="text-muted fst-italic" style="font-size: 0.8rem;">Đang tải...</span>
                                    </span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted" id="modalOvertimeLabel">Tiền tăng ca:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalOvertime">+ 0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Phụ cấp:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalAllowance">+ 0 ₫</span>
                                </div>
                                <div id="modalAllowanceDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Thưởng:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalBonus">+ 0 ₫</span>
                                </div>
                                <div id="modalBonusDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                                <div class="d-flex justify-content-between" id="modalInsuranceBenefitRow" style="display: none !important;">
                                    <span class="text-muted">Trợ cấp BHXH (Thai sản/Ốm đau...):</span>
                                    <span class="fw-semibold text-dark text-success" id="modalInsuranceBenefit">+ 0 ₫</span>
                                </div>
                                <hr style="margin: 10px 0; border-color: rgba(16,185,129,.2);">
                                <div class="d-flex justify-content-between fw-bold text-dark" style="font-size: 0.95rem;">
                                    <span>Lương Gross:</span>
                                    <span id="modalGross">0 ₫</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Khấu trừ & Thuế (Deductions) -->
                    <div class="col-md-6">
                        <div class="p-3" style="background: rgba(239,68,68,.04); border-radius: 12px; border: 1px solid rgba(239,68,68,.1); height: 100%;">
                            <h6 class="fw-bold text-danger mb-3 pb-2" style="border-bottom: 2px solid rgba(239,68,68,.2); display: flex; justify-content: space-between;">
                                <span><i class="fas fa-minus-circle me-1"></i> Các Khoản Khấu Trừ</span>
                            </h6>
                            <div class="d-flex flex-column gap-2" style="font-size: 0.88rem;">
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Bảo hiểm xã hội:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalInsurance">- 0 ₫</span>
                                </div>
                                <div id="modalInsuranceDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                                <!-- Dòng audit: Nền đóng BHXH = baseSalary + phụ cấp/thưởng is_bhxh_applied=1 -->
                                <div class="d-flex justify-content-between" id="modalInsuranceBaseRow"
                                     style="background: rgba(251,191,36,.08); border-radius: 6px; padding: 4px 8px; margin-top: 2px;">
                                    <span class="text-muted" style="font-size: 0.8rem;"
                                          title="Lương cơ bản + phụ cấp và thưởng có đóng BHXH">
                                        <i class="fas fa-info-circle me-1" style="color: #f59e0b;"></i>Nền đóng BHXH:
                                    </span>
                                    <span class="fw-semibold" style="color: #b45309; font-size: 0.8rem;" id="modalInsuranceBase">0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Thuế TNCN:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalTax">- 0 ₫</span>
                                </div>
                                <div id="modalTaxDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                                <!-- Dòng audit: Thu nhập chịu thuế trước giảm trừ gia cảnh -->
                                <div class="d-flex justify-content-between" id="modalTaxableBaseRow"
                                     style="background: rgba(251,191,36,.08); border-radius: 6px; padding: 4px 8px; margin-top: 2px;">
                                    <span class="text-muted" style="font-size: 0.8rem;"
                                          title="Lương theo công + OT + phụ cấp/thưởng chịu thuế (trước giảm trừ)">
                                        <i class="fas fa-info-circle me-1" style="color: #f59e0b;"></i>Thu nhập chịu thuế:
                                    </span>
                                    <span class="fw-semibold" style="color: #b45309; font-size: 0.8rem;" id="modalTaxableBase">0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Phạt / Khấu trừ khác:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalDeduction">- 0 ₫</span>
                                </div>
                                <div id="modalDeductionDetails" style="padding-left: 15px; font-size: 0.8rem; display: none;"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Net Salary Highlight Card -->
                <div class="mt-4 p-4 text-center" style="background: linear-gradient(135deg, rgba(13,148,136,.1) 0%, rgba(16,185,129,.1) 100%); border-radius: 14px; border: 1px solid rgba(13,148,136,.25);">
                    <h6 class="text-uppercase fw-bold text-muted mb-2" style="font-size: 0.8rem; letter-spacing: 0.5px;">Thực Nhận (Net Salary)</h6>
                    <h2 class="fw-extrabold text-success mb-1" style="font-size: 2.2rem; font-weight: 800;" id="modalNet">0 ₫</h2>
                    <p class="text-muted small mb-0">Trạng thái: <span class="badge-s ms-1" id="modalStatus">Draft</span></p>
                </div>
            </div>
            <div class="modal-footer" style="background: #f8fafc; border-top: 1px solid #e2e8f0; border-radius: 0 0 16px 16px; padding: 16px 24px;">
                <button type="button" class="btn btn-secondary px-4 fw-semibold" data-bs-dismiss="modal" style="border-radius: 8px;">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Handle loading data into details modal dynamically
        const detailModal = document.getElementById('payrollDetailModal');
        if (detailModal) {
            detailModal.addEventListener('show.bs.modal', function(event) {
                const button = event.relatedTarget;
                
                // Extract values from data-* attributes
                const userId = button.getAttribute('data-userid');
                const fullName = button.getAttribute('data-fullname');
                const monthYear = button.getAttribute('data-monthyear');
                const baseSalary = button.getAttribute('data-basesalary');
                const workingDays = button.getAttribute('data-workingdays');
                const overtime = button.getAttribute('data-overtime');
                const allowance = button.getAttribute('data-allowance');
                const bonus = button.getAttribute('data-bonus');
                const deduction = button.getAttribute('data-deduction');
                const insurance = button.getAttribute('data-insurance');
                const tax = button.getAttribute('data-tax');
                const gross = button.getAttribute('data-gross');
                const net = button.getAttribute('data-net');
                const insuranceBenefit = button.getAttribute('data-insurancebenefit') || '0 ₫';
                const insuranceBase   = button.getAttribute('data-insurancebase')   || '0 ₫';
                const taxableBase     = button.getAttribute('data-taxablebase')     || '0 ₫';
                const status = button.getAttribute('data-status');

                // Populate Modal Fields
                document.getElementById('modalEmpName').textContent = fullName;
                document.getElementById('modalEmpId').textContent = '#' + userId;
                document.getElementById('modalMonthYear').textContent = monthYear;
                document.getElementById('modalBaseSalary').textContent = baseSalary;
                document.getElementById('modalWorkingDays').textContent = workingDays;
                document.getElementById('modalOvertime').textContent = '+ ' + overtime;
                document.getElementById('modalAllowance').textContent = '+ ' + allowance;
                document.getElementById('modalBonus').textContent = '+ ' + bonus;
                document.getElementById('modalGross').textContent = gross;
                document.getElementById('modalInsurance').textContent = '- ' + insurance;
                document.getElementById('modalTax').textContent = '- ' + tax;
                document.getElementById('modalDeduction').textContent = '- ' + deduction;
                document.getElementById('modalNet').textContent = net;
                // Audit breakdown: nền đóng BHXH và thu nhập chịu thuế
                document.getElementById('modalInsuranceBase').textContent = insuranceBase;
                document.getElementById('modalTaxableBase').textContent = taxableBase;

                document.getElementById('modalInsuranceBenefit').textContent = '+ ' + insuranceBenefit;
                const numericBenefit = parseFloat(insuranceBenefit.replace(/[^\d]/g, '')) || 0;
                if (numericBenefit > 0) {
                    document.getElementById('modalInsuranceBenefitRow').style.setProperty('display', 'flex', 'important');
                } else {
                    document.getElementById('modalInsuranceBenefitRow').style.setProperty('display', 'none', 'important');
                }

                // Fetch detailed breakdowns
                const contextPath = '${pageContext.request.contextPath}';
                const [month, year] = monthYear.split('/');
                
                document.getElementById('modalAllowanceDetails').innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                document.getElementById('modalAllowanceDetails').style.display = 'block';
                document.getElementById('modalBonusDetails').innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                document.getElementById('modalBonusDetails').style.display = 'block';
                document.getElementById('modalInsuranceDetails').innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                document.getElementById('modalInsuranceDetails').style.display = 'block';
                document.getElementById('modalDeductionDetails').innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                document.getElementById('modalDeductionDetails').style.display = 'block';
                document.getElementById('modalBaseWorkedSalary').innerHTML = '<span class="text-muted fst-italic" style="font-size: 0.8rem;">Đang tải...</span>';
                
                const taxDetailsEl = document.getElementById('modalTaxDetails');
                if (taxDetailsEl) {
                    taxDetailsEl.innerHTML = '<div class="text-muted fst-italic">Đang tải...</div>';
                    taxDetailsEl.style.display = 'block';
                }

                fetch(contextPath + '/manager/payslip?action=details_json&userId=' + userId + '&month=' + month + '&year=' + year)
                    .then(response => response.json())
                    .then(data => {
                        if (data.error) {
                            console.error("Lỗi:", data.error);
                            return;
                        }

                                            if (data.overtimeHours !== undefined) {
                        const otLabel = document.getElementById('modalOvertimeLabel');
                        if (otLabel) {
                            otLabel.innerHTML = `Tiền tăng ca <span style="font-size: 0.8rem;">(${data.overtimeHours} giờ)</span>:`;
                        }
                    }
                    const baseWorkedEl = document.getElementById('modalBaseWorkedSalary');
                        if (baseWorkedEl && data.baseWorkedSalary !== undefined) {
                            baseWorkedEl.textContent = new Intl.NumberFormat('vi-VN').format(Math.round(data.baseWorkedSalary)) + ' ₫';
                        }
                        
                        if (data.insuranceBenefit !== undefined) {
                            if (data.insuranceBenefit > 0) {
                                document.getElementById('modalInsuranceBenefit').textContent = '+ ' + new Intl.NumberFormat('vi-VN').format(Math.round(data.insuranceBenefit)) + ' ₫';
                                document.getElementById('modalInsuranceBenefitRow').style.setProperty('display', 'flex', 'important');
                            } else {
                                document.getElementById('modalInsuranceBenefitRow').style.setProperty('display', 'none', 'important');
                            }
                        }
                        
                        let allowHtml = '';
                        if (data.allowances && data.allowances.length > 0) {
                            data.allowances.forEach(a => {
                                const badge = a.isBhxh
                                    ? '<span style="font-size:0.72em;background:#fee2e2;color:#b91c1c;padding:1px 5px;border-radius:4px;margin-left:4px;">(chịu BH)</span>'
                                    : '<span style="font-size:0.72em;background:#d1fae5;color:#065f46;padding:1px 5px;border-radius:4px;margin-left:4px;">(miễn BH)</span>';
                                allowHtml += '<div class="d-flex justify-content-between text-muted" style="align-items:center;">' +
                                    '<span>- ' + a.name + ':' + badge + '</span>' +
                                    '<span>+ ' + new Intl.NumberFormat('vi-VN').format(Math.round(a.amount)) + ' ₫</span>' +
                                '</div>';
                            });
                        } else {
                            allowHtml = '<div class="text-muted fst-italic">Không có</div>';
                        }
                        document.getElementById('modalAllowanceDetails').innerHTML = allowHtml;

                        let bonusHtml = '';
                        if (data.bonuses && data.bonuses.length > 0) {
                            data.bonuses.forEach(b => {
                                let badges = '';
                                if (b.isBhxh === false) {
                                    badges += '<span style="font-size:0.72em;background:#d1fae5;color:#065f46;padding:1px 5px;border-radius:4px;margin-left:4px;">(miễn BH)</span>';
                                } else {
                                    badges += '<span style="font-size:0.72em;background:#fee2e2;color:#b91c1c;padding:1px 5px;border-radius:4px;margin-left:4px;">(chịu BH)</span>';
                                }
                                if (b.isTaxable === false) {
                                    badges += '<span style="font-size:0.72em;background:#d1fae5;color:#065f46;padding:1px 5px;border-radius:4px;margin-left:3px;">(miễn Thuế)</span>';
                                } else {
                                    badges += '<span style="font-size:0.72em;background:#fef3c7;color:#92400e;padding:1px 5px;border-radius:4px;margin-left:3px;">(chịu Thuế)</span>';
                                }
                                bonusHtml += '<div class="d-flex justify-content-between text-muted" style="align-items:center;">' +
                                    '<span>- ' + b.name + ':' + badges + '</span>' +
                                    '<span>+ ' + new Intl.NumberFormat('vi-VN').format(Math.round(b.amount)) + ' ₫</span>' +
                                '</div>';
                            });
                        } else {
                            bonusHtml = '<div class="text-muted fst-italic">Không có</div>';
                        }
                        document.getElementById('modalBonusDetails').innerHTML = bonusHtml;

                        let insHtml = '';
                        if (data.insurances && data.insurances.length > 0) {
                            data.insurances.forEach(i => {
                                insHtml += `<div class="d-flex justify-content-between text-muted">
                                    <span>- \${i.name}:</span>
                                    <span>- \${new Intl.NumberFormat('vi-VN').format(Math.round(i.amount))} ₫</span>
                                </div>`;
                            });
                        } else {
                            insHtml = '<div class="text-muted fst-italic">Không có</div>';
                        }
                        document.getElementById('modalInsuranceDetails').innerHTML = insHtml;

                        let dedHtml = '';
                        if (data.deductions && data.deductions.length > 0) {
                            data.deductions.forEach(d => {
                                dedHtml += `<div class="d-flex justify-content-between text-muted">
                                    <span>- \${d.name}:</span>
                                    <span>- \${new Intl.NumberFormat('vi-VN').format(Math.round(d.amount))} ₫</span>
                                </div>`;
                            });
                        } else {
                            dedHtml = '<div class="text-muted fst-italic">Không có</div>';
                        }
                        document.getElementById('modalDeductionDetails').innerHTML = dedHtml;

                        const taxEl = document.getElementById('modalTaxDetails');
                        if (taxEl && data.taxProfile) {
                            let taxHtml = '';
                            taxHtml += `<div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                                <span>- Khấu trừ bản thân (Tính thuế):</span>
                                <span>\${new Intl.NumberFormat('vi-VN').format(Math.round(data.taxProfile.personalDeduction))} ₫</span>
                            </div>`;
                            if (data.taxProfile.dependentCount > 0) {
                                let depTotal = data.taxProfile.dependentDeduction * data.taxProfile.dependentCount;
                                taxHtml += `<div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                                    <span>- Khấu trừ phụ thuộc (\${data.taxProfile.dependentCount} người):</span>
                                    <span>\${new Intl.NumberFormat('vi-VN').format(Math.round(depTotal))} ₫</span>
                                </div>`;
                            } else {
                                taxHtml += `<div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                                    <span>- Khấu trừ người phụ thuộc:</span>
                                    <span>0 ₫</span>
                                </div>`;
                            }
                            taxEl.innerHTML = taxHtml;
                        }
                    })
                    .catch(err => console.error("Error fetching details", err));

                // Status Badge Formatting
                const statusEl = document.getElementById('modalStatus');
                statusEl.textContent = status;
                statusEl.className = 'badge-s'; // reset
                if (status === 'Approved') statusEl.classList.add('b-approved');
                else if (status === 'Paid') statusEl.classList.add('b-paid');
            });
        }

        // Initialize table listing features
        var table = document.getElementById('payslipTable');
        if (table) {
            window.allRows = Array.from(table.querySelector('tbody').querySelectorAll('tr'));
            filterPayslipTable();
        }
    });

    // Pagination and Filtering Logic
    window.allRows = [];
    window.filteredRows = [];
    window.currentPage = 1;
    const rowsPerPage = 10;

    function filterPayslipTable() {
        var monthVal = document.getElementById('filterMonth').value;
        var yearVal  = document.getElementById('filterYear').value;

        var table = document.getElementById('payslipTable');
        if (!table) return;

        var tbody = table.querySelector('tbody');
        if (window.allRows.length === 0) {
            window.allRows = Array.from(tbody.querySelectorAll('tr'));
        }

        window.filteredRows = window.allRows.filter(function(row) {
            var cellText = row.cells[0].textContent.trim(); // "Tháng M / Y"
            var parts = cellText.replace('Tháng', '').trim().split('/');
            var rowMonth = parts[0] ? parts[0].trim() : '';
            var rowYear  = parts[1] ? parts[1].trim() : '';

            var mMatch = (monthVal === 'all') || (rowMonth === monthVal);
            var yMatch = (yearVal  === 'all') || (rowYear === yearVal);

            return mMatch && yMatch;
        });

        window.currentPage = 1;
        updatePagination();
    }

    function updatePagination() {
        var all = window.allRows || [];
        var filtered = window.filteredRows || all;
        all.forEach(function(r) { r.style.display = 'none'; });

        var total = filtered.length;
        var totalPages = Math.ceil(total / rowsPerPage) || 1;
        var page = window.currentPage || 1;

        if (page > totalPages) page = totalPages;
        if (page < 1) page = 1;
        window.currentPage = page;

        var start = (page - 1) * rowsPerPage;
        var end   = Math.min(start + rowsPerPage, total);

        for (var i = start; i < end; i++) {
            filtered[i].style.display = '';
        }

        var info = document.getElementById('pageInfo');
        if (info) {
            info.textContent = total === 0 ? 'Không tìm thấy kết quả.' : 'Hiển thị ' + (start + 1) + ' - ' + end + ' trong số ' + total + ' phiếu lương.';
        }

        var btnPrev = document.getElementById('btnPrev');
        var btnNext = document.getElementById('btnNext');
        if (btnPrev) btnPrev.disabled = (page === 1);
        if (btnNext) btnNext.disabled = (page === totalPages);
    }

    function prevPage() {
        if ((window.currentPage || 1) > 1) {
            window.currentPage--;
            updatePagination();
        }
    }

    function nextPage() {
        var total = (window.filteredRows || []).length;
        var totalPages = Math.ceil(total / rowsPerPage) || 1;
        if ((window.currentPage || 1) < totalPages) {
            window.currentPage++;
            updatePagination();
        }
    }
</script>

<jsp:include page="../footer.jsp" />


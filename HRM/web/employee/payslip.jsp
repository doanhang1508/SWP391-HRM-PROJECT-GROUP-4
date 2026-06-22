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
        <jsp:param name="activeMenu" value="payroll" />
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
                                            data-status="${p.status}">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/employee/payroll?action=print&month=${p.month}&year=${p.year}" 
                                       target="_blank" 
                                       class="btn-action btn-pdf ms-1" 
                                       title="Xuất file PDF">
                                        <i class="fas fa-file-pdf"></i>
                                    </a>
                                    <c:set var="matchedClaim" value="${null}" />
                                    <c:forEach var="cl" items="${claims}">
                                        <c:if test="${cl.payrollId == p.payrollId}">
                                            <c:set var="matchedClaim" value="${cl}" />
                                        </c:if>
                                    </c:forEach>
                                    <c:choose>
                                        <c:when test="${not empty matchedClaim}">
                                            <button class="btn-action ms-1" 
                                                    style="background-color: #dbeafe; color: #1e40af; border: none;"
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#claimDetailModal-${matchedClaim.claimId}"
                                                    title="Xem chi tiết khiếu nại (Trạng thái: ${matchedClaim.status})">
                                                <i class="fas fa-info-circle"></i>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/employee/payroll-claim?payrollId=${p.payrollId}" 
                                               class="btn-action btn-view ms-1" 
                                               style="background-color: #fef3c7; color: #d97706;"
                                               title="Khiếu nại lương">
                                                <i class="fas fa-exclamation-triangle"></i>
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>

                            <c:if test="${not empty matchedClaim}">
                                <!-- Modal Chi tiết Khiếu nại cho Employee -->
                                <div class="modal fade" id="claimDetailModal-${matchedClaim.claimId}" tabindex="-1" aria-labelledby="claimDetailModalLabel-${matchedClaim.claimId}" aria-hidden="true">
                                    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
                                        <div class="modal-content" style="border:none;border-radius:18px;overflow:hidden;box-shadow:0 25px 60px rgba(0,0,0,.18);">
                                            <!-- Gradient Header (Teal for employee) -->
                                            <div class="modal-header" style="background:linear-gradient(135deg,#0d9488 0%,#14b8a6 50%,#5eead4 100%);padding:18px 22px;position:relative;border:none;">
                                                <div style="position:absolute;top:0;right:0;width:100px;height:100px;background:rgba(255,255,255,.08);border-radius:0 0 0 100%;"></div>
                                                <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                                                    <div>
                                                        <div style="display:flex;align-items:center;gap:10px;margin-bottom:4px;">
                                                            <div style="width:34px;height:34px;background:rgba(255,255,255,.2);border-radius:9px;display:flex;align-items:center;justify-content:center;">
                                                                <i class="fas fa-file-invoice-dollar" style="color:#fff;font-size:.9rem;"></i>
                                                            </div>
                                                            <h5 style="margin:0;color:#fff;font-weight:700;font-size:1.05rem;">Chi Tiết Khiếu Nại Lương</h5>
                                                        </div>
                                                        <p style="margin:0;color:rgba(255,255,255,.75);font-size:.78rem;">Mã khiếu nại: #${matchedClaim.claimId}</p>
                                                    </div>
                                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close" style="margin:0;"></button>
                                                </div>
                                            </div>

                                            <div class="modal-body" style="padding:16px 20px;background:#f8fffe;">
                                                <!-- Payroll Period & Complaint Type Cards -->
                                                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px;">
                                                    <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:12px;">
                                                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
                                                            <div style="width:28px;height:28px;background:#f0fdf4;border-radius:7px;display:flex;align-items:center;justify-content:center;">
                                                                <i class="fas fa-calendar-alt" style="color:#0d9488;font-size:.75rem;"></i>
                                                            </div>
                                                            <span style="font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Kỳ lương</span>
                                                        </div>
                                                        <div style="font-weight:700;color:#1e293b;font-size:.88rem;">Tháng ${matchedClaim.month} / ${matchedClaim.year}</div>
                                                    </div>
                                                    <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:12px;">
                                                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
                                                            <div style="width:28px;height:28px;background:#fef3c7;border-radius:7px;display:flex;align-items:center;justify-content:center;">
                                                                <i class="fas fa-tag" style="color:#d97706;font-size:.75rem;"></i>
                                                            </div>
                                                            <span style="font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Loại khiếu nại</span>
                                                        </div>
                                                        <span style="display:inline-block;background:#fef3c7;color:#92400e;padding:4px 12px;border-radius:7px;font-weight:600;font-size:.8rem;">${matchedClaim.complaintType}</span>
                                                    </div>
                                                </div>

                                                <!-- Description Card -->
                                                <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:14px;margin-bottom:12px;">
                                                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px;">
                                                        <div style="width:28px;height:28px;background:#eff6ff;border-radius:7px;display:flex;align-items:center;justify-content:center;">
                                                            <i class="fas fa-align-left" style="color:#3b82f6;font-size:.75rem;"></i>
                                                        </div>
                                                        <span style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Mô tả khiếu nại</span>
                                                    </div>
                                                    <div style="background:#f8fafc;padding:12px 14px;border-radius:10px;border:1px solid #e2e8f0;white-space:pre-wrap;font-size:.85rem;color:#334155;line-height:1.6;">${matchedClaim.description}</div>
                                                </div>

                                                <!-- Status Card -->
                                                <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:14px;margin-bottom:12px;">
                                                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px;">
                                                        <div style="width:28px;height:28px;background:#faf5ff;border-radius:7px;display:flex;align-items:center;justify-content:center;">
                                                            <i class="fas fa-info-circle" style="color:#8b5cf6;font-size:.75rem;"></i>
                                                        </div>
                                                        <span style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Trạng thái hiện tại</span>
                                                    </div>
                                                    <c:choose>
                                                        <c:when test="${matchedClaim.status eq 'Pending'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(245,158,11,.1);color:#d97706;padding:6px 16px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-clock"></i>Chờ HR tiếp nhận</span></c:when>
                                                        <c:when test="${matchedClaim.status eq 'Accountant Checking'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(59,130,246,.1);color:#2563eb;padding:6px 16px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-calculator"></i>Kế toán kiểm tra số liệu</span></c:when>
                                                        <c:when test="${matchedClaim.status eq 'HR Manager Reviewing'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(99,102,241,.1);color:#6366f1;padding:6px 16px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-user-tie"></i>HR Manager đang xem xét</span></c:when>
                                                        <c:when test="${matchedClaim.status eq 'Director Reviewing'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(245,158,11,.1);color:#d97706;padding:6px 16px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-user-shield"></i>Giám đốc đang xem xét</span></c:when>
                                                        <c:when test="${matchedClaim.status eq 'Resolved'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(16,185,129,.1);color:#059669;padding:6px 16px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-check-circle"></i>Đã giải quyết & tính lại lương</span></c:when>
                                                        <c:when test="${matchedClaim.status eq 'Rejected'}"><span style="display:inline-flex;align-items:center;gap:5px;background:rgba(239,68,68,.1);color:#dc2626;padding:6px 16px;border-radius:8px;font-weight:600;font-size:.82rem;"><i class="fas fa-times-circle"></i>Đã từ chối</span></c:when>
                                                        <c:otherwise><span style="display:inline-block;background:#f1f5f9;color:#475569;padding:6px 16px;border-radius:8px;font-weight:600;font-size:.82rem;">${matchedClaim.status}</span></c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <!-- Processing Timeline (Notes) -->
                                                <c:if test="${not empty matchedClaim.hrStaffNote || not empty matchedClaim.accountantNote || not empty matchedClaim.hrManagerNote || not empty matchedClaim.directorNote}">
                                                    <div style="background:#fff;border:1px solid #e8eaf0;border-radius:10px;padding:14px;">
                                                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:14px;">
                                                            <div style="width:28px;height:28px;background:#eff6ff;border-radius:7px;display:flex;align-items:center;justify-content:center;">
                                                                <i class="fas fa-reply" style="color:#3b82f6;font-size:.75rem;"></i>
                                                            </div>
                                                            <span style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:#94a3b8;">Phản hồi từ ban quản lý</span>
                                                        </div>
                                                        <div style="display:flex;flex-direction:column;gap:0;position:relative;padding-left:18px;">
                                                            <c:if test="${not empty matchedClaim.hrStaffNote}">
                                                                <div style="position:relative;padding-bottom:14px;">
                                                                    <div style="position:absolute;left:-18px;top:4px;width:10px;height:10px;background:#0d9488;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 2px #0d9488;z-index:1;"></div>
                                                                    <c:if test="${not empty matchedClaim.accountantNote || not empty matchedClaim.hrManagerNote || not empty matchedClaim.directorNote}">
                                                                        <div style="position:absolute;left:-14px;top:14px;bottom:0;width:2px;background:#e2e8f0;"></div>
                                                                    </c:if>
                                                                    <div style="font-weight:700;color:#1e293b;font-size:.82rem;margin-bottom:3px;">${not empty matchedClaim.hrStaffName ? matchedClaim.hrStaffName : 'HR Staff'}</div>
                                                                    <div style="background:#f8fafc;padding:8px 12px;border-radius:8px;border-left:3px solid #0d9488;font-size:.82rem;color:#475569;line-height:1.5;">${matchedClaim.hrStaffNote}</div>
                                                                </div>
                                                            </c:if>
                                                            <c:if test="${not empty matchedClaim.accountantNote}">
                                                                <div style="position:relative;padding-bottom:14px;">
                                                                    <div style="position:absolute;left:-18px;top:4px;width:10px;height:10px;background:#0ea5e9;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 2px #0ea5e9;z-index:1;"></div>
                                                                    <c:if test="${not empty matchedClaim.hrManagerNote || not empty matchedClaim.directorNote}">
                                                                        <div style="position:absolute;left:-14px;top:14px;bottom:0;width:2px;background:#e2e8f0;"></div>
                                                                    </c:if>
                                                                    <div style="font-weight:700;color:#1e293b;font-size:.82rem;margin-bottom:3px;">${not empty matchedClaim.accountantName ? matchedClaim.accountantName : 'Kế toán'}</div>
                                                                    <div style="background:#f8fafc;padding:8px 12px;border-radius:8px;border-left:3px solid #0ea5e9;font-size:.82rem;color:#475569;line-height:1.5;">${matchedClaim.accountantNote}</div>
                                                                </div>
                                                            </c:if>
                                                            <c:if test="${not empty matchedClaim.hrManagerNote}">
                                                                <div style="position:relative;padding-bottom:14px;">
                                                                    <div style="position:absolute;left:-18px;top:4px;width:10px;height:10px;background:#f59e0b;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 2px #f59e0b;z-index:1;"></div>
                                                                    <c:if test="${not empty matchedClaim.directorNote}">
                                                                        <div style="position:absolute;left:-14px;top:14px;bottom:0;width:2px;background:#e2e8f0;"></div>
                                                                    </c:if>
                                                                    <div style="font-weight:700;color:#1e293b;font-size:.82rem;margin-bottom:3px;">${not empty matchedClaim.hrManagerName ? matchedClaim.hrManagerName : 'HR Manager'}</div>
                                                                    <div style="background:#f8fafc;padding:8px 12px;border-radius:8px;border-left:3px solid #f59e0b;font-size:.82rem;color:#475569;line-height:1.5;">${matchedClaim.hrManagerNote}</div>
                                                                </div>
                                                            </c:if>
                                                            <c:if test="${not empty matchedClaim.directorNote}">
                                                                <div style="position:relative;padding-bottom:0;">
                                                                    <div style="position:absolute;left:-18px;top:4px;width:10px;height:10px;background:#ef4444;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 2px #ef4444;z-index:1;"></div>
                                                                    <div style="font-weight:700;color:#1e293b;font-size:.82rem;margin-bottom:3px;">${not empty matchedClaim.directorName ? matchedClaim.directorName : 'Giám đốc'}</div>
                                                                    <div style="background:#f8fafc;padding:8px 12px;border-radius:8px;border-left:3px solid #ef4444;font-size:.82rem;color:#475569;line-height:1.5;">${matchedClaim.directorNote}</div>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </div>

                                            <!-- Footer -->
                                            <div class="modal-footer" style="padding:10px 20px;background:#fff;border-top:1px solid #f1f5f9;display:flex;justify-content:flex-end;">
                                                <button type="button" data-bs-dismiss="modal" style="padding:8px 18px;background:#f1f5f9;color:#64748b;border:none;border-radius:8px;font-weight:600;font-size:.84rem;cursor:pointer;transition:background .2s;" onmouseover="this.style.background='#e2e8f0'" onmouseout="this.style.background='#f1f5f9'">Đóng</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
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
                                    <span class="text-muted">Tiền tăng ca:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalOvertime">+ 0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Phụ cấp:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalAllowance">+ 0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Thưởng:</span>
                                    <span class="fw-semibold text-dark text-success" id="modalBonus">+ 0 ₫</span>
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
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Thuế TNCN:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalTax">- 0 ₫</span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted">Khấu trừ khác / Phạt:</span>
                                    <span class="fw-semibold text-dark text-danger" id="modalDeduction">- 0 ₫</span>
                                </div>
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

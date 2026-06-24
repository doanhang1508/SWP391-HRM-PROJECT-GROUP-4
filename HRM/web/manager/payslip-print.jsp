<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Phieu_Luong_Thang_${payroll.month}_${payroll.year}</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            color: #1e293b;
            margin: 0;
            padding: 30px;
            background: #ffffff;
        }
        .payslip-box {
            max-width: 800px;
            margin: 0 auto;
            border: 1px solid #e2e8f0;
            padding: 40px;
            border-radius: 8px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 3px double #cbd5e1;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .company-info h2 {
            margin: 0 0 5px;
            font-size: 1.4rem;
            color: #0d9488;
            font-weight: 800;
        }
        .company-info p {
            margin: 0;
            font-size: 0.85rem;
            color: #64748b;
        }
        .payslip-title {
            text-align: right;
        }
        .payslip-title h1 {
            margin: 0 0 5px;
            font-size: 1.6rem;
            color: #1e293b;
            font-weight: 800;
            letter-spacing: -0.5px;
        }
        .payslip-title p {
            margin: 0;
            font-size: 0.95rem;
            color: #0d9488;
            font-weight: 700;
        }
        .employee-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            background: #f8fafc;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border: 1px solid #edf2f7;
            font-size: 0.9rem;
        }
        .detail-item {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px dashed #e2e8f0;
            padding-bottom: 5px;
        }
        .detail-item span:first-child {
            color: #64748b;
            font-weight: 500;
        }
        .detail-item span:last-child {
            color: #1e293b;
            font-weight: 600;
        }
        .grids-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }
        .grid-box {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 20px;
        }
        .income-box {
            background-color: rgba(16, 185, 129, 0.02);
            border-color: rgba(16, 185, 129, 0.15);
        }
        .deduction-box {
            background-color: rgba(239, 68, 68, 0.02);
            border-color: rgba(239, 68, 68, 0.15);
        }
        .grid-box h3 {
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 1rem;
            padding-bottom: 10px;
            border-bottom: 2px solid #edf2f7;
        }
        .income-box h3 { color: #059669; border-color: rgba(16, 185, 129, 0.15); }
        .deduction-box h3 { color: #dc2626; border-color: rgba(239, 68, 68, 0.15); }
        
        .row-item {
            display: flex;
            justify-content: space-between;
            font-size: 0.88rem;
            margin-bottom: 10px;
        }
        .row-item span:first-child {
            color: #64748b;
        }
        .row-item span:last-child {
            font-weight: 600;
            color: #1e293b;
        }
        .total-row-item {
            display: flex;
            justify-content: space-between;
            font-size: 0.95rem;
            font-weight: 700;
            border-top: 1px solid #cbd5e1;
            padding-top: 10px;
            margin-top: 10px;
        }
        .net-salary-container {
            background: linear-gradient(135deg, rgba(13, 148, 136, 0.08) 0%, rgba(16, 185, 129, 0.08) 100%);
            border: 1px solid rgba(13, 148, 136, 0.2);
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 40px;
        }
        .net-salary-container h4 {
            margin: 0 0 5px;
            text-transform: uppercase;
            font-size: 0.8rem;
            color: #64748b;
            letter-spacing: 1px;
        }
        .net-salary-container h2 {
            margin: 0;
            font-size: 2rem;
            color: #0d9488;
            font-weight: 800;
        }
        .signatures {
            display: flex;
            justify-content: space-between;
            margin-top: 50px;
            padding: 0 30px;
        }
        .signature-block {
            text-align: center;
            width: 200px;
        }
        .signature-block p:first-child {
            font-weight: 700;
            font-size: 0.9rem;
            margin-bottom: 70px;
        }
        .signature-block p:last-child {
            font-style: italic;
            font-size: 0.8rem;
            color: #64748b;
        }
        @media print {
            body {
                padding: 0;
                background: #fff;
            }
            .payslip-box {
                border: none;
                padding: 0;
            }
            @page {
                size: A4 portrait;
                margin: 20mm;
            }
        }
    </style>
</head>
<body>

<div class="payslip-box">
    <!-- Header -->
    <div class="header">
        <div class="company-info">
            <h2>ENTERPRISE HRM</h2>
            <p>Hệ thống Quản lý Nhân sự & Lương</p>
        </div>
        <div class="payslip-title">
            <h1>PHIẾU THANH TOÁN LƯƠNG</h1>
            <p>Kỳ Lương: Tháng ${payroll.month} / ${payroll.year}</p>
        </div>
    </div>

    <!-- Employee Info -->
    <div class="employee-details">
        <div class="detail-item">
            <span>Mã nhân viên:</span>
            <span>#${payroll.userId}</span>
        </div>
        <div class="detail-item">
            <span>Họ và tên:</span>
            <span>${employeeName}</span>
        </div>
        <div class="detail-item">
            <span>Trạng thái phiếu:</span>
            <span style="color: #0d9488;">${payroll.status}</span>
        </div>
        <div class="detail-item">
            <span>Ngày xuất phiếu:</span>
            <span>
                <jsp:useBean id="now" class="java.util.Date" />
                <fmt:formatDate value="${now}" pattern="dd/MM/yyyy HH:mm"/>
            </span>
        </div>
    </div>

    <!-- Breakdown Grid -->
    <div class="grids-container">
        <!-- Thu nhập -->
        <div class="grid-box income-box">
            <h3>CÁC KHOẢN THU NHẬP</h3>
            <div class="row-item">
                <span>Lương cơ bản:</span>
                <span><fmt:formatNumber value="${payroll.baseSalary}" type="number" groupingUsed="true"/> ₫</span>
            </div>
            <div class="row-item">
                <span>Ngày công làm việc:</span>
                <span>${payroll.workingDays} ngày</span>
            </div>
            <div class="row-item">
                <span>Lương tăng ca (OT):</span>
                <span>+ <fmt:formatNumber value="${payroll.overtimeAmount != null ? payroll.overtimeAmount : 0}" type="number" groupingUsed="true"/> ₫</span>
            </div>
            <div class="row-item">
                <span>Phụ cấp:</span>
                <span>+ <fmt:formatNumber value="${payroll.allowanceAmount != null ? payroll.allowanceAmount : 0}" type="number" groupingUsed="true"/> ₫</span>
            </div>
            <div class="row-item">
                <span>Thưởng:</span>
                <span>+ <fmt:formatNumber value="${payroll.bonusAmount != null ? payroll.bonusAmount : 0}" type="number" groupingUsed="true"/> ₫</span>
            </div>
            <div class="total-row-item text-success">
                <span>Lương Gross:</span>
                <span><fmt:formatNumber value="${payroll.grossSalary}" type="number" groupingUsed="true"/> ₫</span>
            </div>
        </div>

        <!-- Khấu trừ -->
        <div class="grid-box deduction-box">
            <h3>CÁC KHOẢN KHẤU TRỪ</h3>
            <div class="row-item">
                <span>Bảo hiểm xã hội:</span>
                <span style="color: #dc2626;">- <fmt:formatNumber value="${payroll.insuranceAmount != null ? payroll.insuranceAmount : 0}" type="number" groupingUsed="true"/> ₫</span>
            </div>
            <div class="row-item">
                <span>Thuế TNCN:</span>
                <span style="color: #dc2626;">- <fmt:formatNumber value="${payroll.taxAmount != null ? payroll.taxAmount : 0}" type="number" groupingUsed="true"/> ₫</span>
            </div>
            <div class="row-item">
                <span>Khấu trừ khác / Phạt:</span>
                <span style="color: #dc2626;">- <fmt:formatNumber value="${payroll.deductionAmount != null ? payroll.deductionAmount : 0}" type="number" groupingUsed="true"/> ₫</span>
            </div>
            <div class="total-row-item text-danger" style="border-top: 1px solid #cbd5e1; padding-top: 10px; margin-top: auto;">
                <span>Tổng khấu trừ:</span>
                <span>
                    <c:set var="totalDeductions" value="${(payroll.insuranceAmount != null ? payroll.insuranceAmount : 0) + (payroll.taxAmount != null ? payroll.taxAmount : 0) + (payroll.deductionAmount != null ? payroll.deductionAmount : 0)}" />
                    <fmt:formatNumber value="${totalDeductions}" type="number" groupingUsed="true"/> ₫
                </span>
            </div>
        </div>
    </div>

    <!-- Net Salary Highlight -->
    <div class="net-salary-container">
        <h4>Thực Nhận (Net Salary)</h4>
        <h2><fmt:formatNumber value="${payroll.netSalary}" type="number" groupingUsed="true"/> ₫</h2>
    </div>

    <!-- Signatures -->
    <div class="signatures">
        <div class="signature-block">
            <p>Người nhận lương</p>
            <p>(Ký, ghi rõ họ tên)</p>
        </div>
        <div class="signature-block">
            <p>Bộ phận nhân sự/Kế toán</p>
            <p>(Ký duyệt)</p>
        </div>
    </div>
</div>

<script>
    window.onload = function() {
        window.print();
        // Close window shortly after print dialog completes
        setTimeout(function() {
            window.close();
        }, 1500);
    };
</script>

</body>
</html>

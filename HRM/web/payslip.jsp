<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Payslip</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .payslip-container {
            max-width: 800px;
            margin: 40px auto;
            background: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .payslip-header {
            border-bottom: 2px solid #007bff;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .amount {
            font-weight: bold;
            text-align: right;
        }
        .total-row {
            font-size: 1.2rem;
            font-weight: bold;
            background-color: #f1f8ff;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="payslip-container">
        <div class="payslip-header text-center">
            <h2>Company HRM</h2>
            <h4>Payslip for <c:out value="${month}"/>/<c:out value="${year}"/></h4>
            <p class="text-muted">Employee ID: <c:out value="${userId}"/></p>
        </div>

        <c:choose>
            <c:when test="${not empty payroll}">
                <table class="table table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>Description</th>
                            <th class="text-end">Amount (VND)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Base Salary</td>
                            <td class="amount"><fmt:formatNumber value="${payroll.baseSalary}" type="number" groupingUsed="true"/></td>
                        </tr>
                        <tr>
                            <td>Total Bonuses</td>
                            <td class="amount text-success">+ <fmt:formatNumber value="${payroll.bonusAmount}" type="number" groupingUsed="true"/></td>
                        </tr>
                        <tr>
                            <td>Gross Salary</td>
                            <td class="amount"><fmt:formatNumber value="${payroll.grossSalary}" type="number" groupingUsed="true"/></td>
                        </tr>
                        <tr>
                            <td>Total Deductions (Disciplinary/Taxes)</td>
                            <td class="amount text-danger">- <fmt:formatNumber value="${payroll.deductionAmount}" type="number" groupingUsed="true"/></td>
                        </tr>
                        <tr class="total-row">
                            <td>Net Salary</td>
                            <td class="amount text-primary"><fmt:formatNumber value="${payroll.netSalary}" type="number" groupingUsed="true"/></td>
                        </tr>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="alert alert-warning text-center">
                    No payroll record found for this month. 
                </div>
            </c:otherwise>
        </c:choose>

        <div class="mt-4 text-center">
            <a href="payroll?action=calculate&userId=${userId}&month=${month}&year=${year}" class="btn btn-primary">Recalculate Payroll</a>
            <button class="btn btn-secondary" onclick="window.print()">Print Payslip</button>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

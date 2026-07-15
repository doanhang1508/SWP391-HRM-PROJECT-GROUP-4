<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo Bảng lương Tổng hợp - HRM</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* ─── Page header ─────────────────────────────────────────── */
        .page-header-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
            gap: 16px;
            flex-wrap: wrap;
        }
        .page-title-group h1 { margin: 0; font-size: 1.6rem; font-weight: 800; color: #0f172a; }
        .page-title-group p  { margin: 6px 0 0; color: #64748b; font-size: 0.9rem; }

        /* ─── Summary cards ─────────────────────────────────────────── */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(190px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .summary-card {
            background: #fff;
            border-radius: 12px;
            padding: 18px 20px;
            box-shadow: 0 1px 4px rgba(0,0,0,.08);
            display: flex;
            flex-direction: column;
            gap: 6px;
            border-left: 4px solid transparent;
        }
        .summary-card.blue   { border-color: #3b82f6; }
        .summary-card.green  { border-color: #10b981; }
        .summary-card.orange { border-color: #f59e0b; }
        .summary-card.red    { border-color: #ef4444; }
        .summary-card.teal   { border-color: #0d9488; }
        .summary-card .sc-label { font-size: 0.78rem; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: .5px; }
        .summary-card .sc-value { font-size: 1.2rem; font-weight: 800; color: #0f172a; }
        .summary-card .sc-count { font-size: 0.82rem; color: #94a3b8; }

        /* ─── Filter box ─────────────────────────────────────────────── */
        .filter-box {
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,.08);
            margin-bottom: 24px;
            display: flex;
            gap: 16px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        .filter-group { display: flex; flex-direction: column; gap: 6px; }
        .filter-group label { font-size: 0.82rem; font-weight: 600; color: #4b5563; }
        .filter-group select,
        .filter-group input {
            padding: 8px 12px;
            border: 1.5px solid #e2e8f0;
            border-radius: 8px;
            font-family: inherit;
            font-size: 0.88rem;
            background: #f8fafc;
            color: #0f172a;
            min-width: 120px;
            transition: border-color .2s;
        }
        .filter-group select:focus,
        .filter-group input:focus { outline: none; border-color: #0d9488; }

        .btn-filter {
            padding: 9px 20px;
            background: linear-gradient(135deg, #0d9488, #0284c7);
            color: #fff;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.88rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: opacity .2s;
            height: 38px;
        }
        .btn-filter:hover { opacity: .88; }

        .btn-export {
            padding: 9px 18px;
            background: #fff;
            color: #059669;
            border: 1.5px solid #059669;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.88rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all .2s;
            height: 38px;
        }
        .btn-export:hover { background: #f0fdf4; }

        /* ─── Result bar ─────────────────────────────────────────────── */
        .result-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .result-count { font-size: 1rem; font-weight: 600; color: #1e293b; }
        .result-count span { color: #0d9488; }

        /* ─── Table ─────────────────────────────────────────────────── */
        .report-table-wrap {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,.08);
            overflow: auto;
        }
        .report-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.87rem;
            min-width: 1100px;
        }
        .report-table thead tr th {
            background: #0f172a;
            color: #e2e8f0;
            padding: 12px 14px;
            text-align: left;
            font-weight: 700;
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: .4px;
            white-space: nowrap;
        }
        .report-table thead tr th:first-child { border-radius: 0; }
        .report-table tbody tr { transition: background .15s; }
        .report-table tbody tr:hover { background: #f0fdfa; }
        .report-table tbody tr:nth-child(even) { background: #f8fafc; }
        .report-table tbody tr:nth-child(even):hover { background: #f0fdfa; }
        .report-table td { padding: 10px 14px; border-bottom: 1px solid #f1f5f9; color: #1e293b; white-space: nowrap; }

        /* Dòng tổng cộng */
        .report-table tfoot tr td {
            background: #0f172a;
            color: #f1f5f9;
            font-weight: 800;
            padding: 12px 14px;
            font-size: 0.88rem;
        }

        /* Cột số tiền */
        .money { text-align: right; font-variant-numeric: tabular-nums; }

        /* Badges */
        .badge-dept {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            background: #ede9fe;
            color: #6d28d9;
            font-size: 0.78rem;
            font-weight: 600;
        }
        .badge-paid {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            background: #d1fae5;
            color: #065f46;
            font-size: 0.78rem;
            font-weight: 600;
        }
        .badge-approved {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            background: #dbeafe;
            color: #1e40af;
            font-size: 0.78rem;
            font-weight: 600;
        }

        /* Responsive notice */
        .scroll-hint {
            font-size: 0.78rem;
            color: #94a3b8;
            margin-bottom: 6px;
            display: none;
        }
        @media (max-width: 900px) { .scroll-hint { display: block; } }

        /* Empty state */
        .empty-state {
            padding: 60px 24px;
            text-align: center;
            color: #94a3b8;
        }
        .empty-state i { font-size: 3rem; margin-bottom: 12px; display: block; color: #cbd5e1; }
        .empty-state p { font-size: 0.95rem; margin: 0; }
    </style>
</head>
<body class="app-layout">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="master-payroll-report"/>
    </jsp:include>

    <div class="main-content">
        <jsp:include page="../header.jsp" />

        <div class="content-wrapper" style="padding: 28px 32px;">

            <!-- ═══ Page header ═══════════════════════════════════════════ -->
            <div class="page-header-row">
                <div class="page-title-group">
                    <h1><i class="fas fa-chart-bar" style="color:#0d9488;margin-right:10px;"></i>Báo cáo Bảng lương Tổng hợp</h1>
                    <p>Xem chi tiết và xuất Excel bảng lương đã duyệt (Approved / Paid) theo tháng và phòng ban.</p>
                </div>
            </div>

            <!-- ═══ Filter ════════════════════════════════════════════════ -->
            <form action="${pageContext.request.contextPath}/hr/master-payroll-report" method="GET" class="filter-box">
                <div class="filter-group">
                    <label><i class="fas fa-calendar-alt"></i> Tháng</label>
                    <select name="month" id="fMonth">
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="filter-group">
                    <label><i class="fas fa-calendar"></i> Năm</label>
                    <input type="number" name="year" id="fYear" value="${selectedYear}" min="2020" max="2035" style="width:90px;">
                </div>
                <div class="filter-group">
                    <label><i class="fas fa-building"></i> Phòng ban</label>
                    <select name="departmentId" id="fDept">
                        <option value="-1" ${selectedDepartmentId == -1 ? 'selected' : ''}>Tất cả phòng ban</option>
                        <c:forEach var="d" items="${departments}">
                            <option value="${d.departmentId}" ${selectedDepartmentId == d.departmentId ? 'selected' : ''}>${d.departmentName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="filter-group">
                    <label>&nbsp;</label>
                    <button type="submit" class="btn-filter" id="btnFilter">
                        <i class="fas fa-filter"></i> Xem báo cáo
                    </button>
                </div>
            </form>

            <!-- ═══ Summary cards ═════════════════════════════════════════ -->
            <div class="summary-grid">
                <div class="summary-card blue">
                    <span class="sc-label"><i class="fas fa-users"></i> Số nhân viên</span>
                    <span class="sc-value">${reportData.size()}</span>
                    <span class="sc-count">Approved + Paid</span>
                </div>
                <div class="summary-card green">
                    <span class="sc-label"><i class="fas fa-money-bill-wave"></i> Tổng thực lĩnh</span>
                    <span class="sc-value">
                        <fmt:formatNumber value="${totalNet}" type="number" groupingUsed="true"/> ₫
                    </span>
                    <span class="sc-count">Tháng ${selectedMonth}/${selectedYear}</span>
                </div>
                <div class="summary-card orange">
                    <span class="sc-label"><i class="fas fa-hand-holding-usd"></i> Tổng phụ cấp</span>
                    <span class="sc-value">
                        <fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/> ₫
                    </span>
                    <span class="sc-count">&nbsp;</span>
                </div>
                <div class="summary-card teal">
                    <span class="sc-label"><i class="fas fa-award"></i> Tổng thưởng</span>
                    <span class="sc-value">
                        <fmt:formatNumber value="${totalBonus}" type="number" groupingUsed="true"/> ₫
                    </span>
                    <span class="sc-count">&nbsp;</span>
                </div>
                <div class="summary-card red">
                    <span class="sc-label"><i class="fas fa-minus-circle"></i> Tổng khấu trừ</span>
                    <span class="sc-value">
                        <fmt:formatNumber value="${totalDeduction}" type="number" groupingUsed="true"/> ₫
                    </span>
                    <span class="sc-count">Phạt + BHXH + Thuế</span>
                </div>
            </div>

            <!-- ═══ Result bar + Export ════════════════════════════════════ -->
            <div class="result-bar">
                <div class="result-count">
                    Kết quả: <span>${reportData.size()} nhân viên</span>
                    — Tháng <strong>${selectedMonth}/${selectedYear}</strong>
                    <c:if test="${selectedDepartmentId != -1}">
                        <c:forEach var="d" items="${departments}">
                            <c:if test="${d.departmentId == selectedDepartmentId}">
                                — PB: <strong>${d.departmentName}</strong>
                            </c:if>
                        </c:forEach>
                    </c:if>
                </div>
                <form action="${pageContext.request.contextPath}/hr/master-payroll-report" method="GET" style="display:inline;">
                    <input type="hidden" name="action"       value="exportExcel">
                    <input type="hidden" name="month"        value="${selectedMonth}">
                    <input type="hidden" name="year"         value="${selectedYear}">
                    <input type="hidden" name="departmentId" value="${selectedDepartmentId}">
                    <button type="submit" class="btn-export" id="btnExport">
                        <i class="fas fa-file-excel"></i> Xuất Excel (.xlsx)
                    </button>
                </form>
            </div>

            <!-- ═══ Table ════════════════════════════════════════════════ -->
            <p class="scroll-hint"><i class="fas fa-arrows-alt-h"></i> Kéo ngang để xem đầy đủ bảng</p>
            <div class="report-table-wrap">
                <table class="report-table" id="masterPayrollTable">
                    <thead>
                        <tr>
                            <th style="width:42px;">#</th>
                            <th>Mã NV</th>
                            <th>Họ và tên</th>
                            <th>Phòng ban</th>
                            <th class="money">Lương cơ bản</th>
                            <th class="money">Thưởng</th>
                            <th class="money">Phụ cấp</th>
                            <th class="money">Khấu trừ/Phạt</th>
                            <th class="money">Bảo hiểm NV</th>
                            <th class="money">Thuế TNCN</th>
                            <th class="money" style="background:#1e3a5f;">Tổng khoản trừ</th>
                            <th class="money" style="background:#14532d;">Thực lĩnh</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty reportData}">
                                <tr>
                                    <td colspan="13">
                                        <div class="empty-state">
                                            <i class="fas fa-file-excel"></i>
                                            <p>Không có dữ liệu lương đã duyệt (Approved / Paid) cho Tháng ${selectedMonth}/${selectedYear}.<br>
                                               Vui lòng kiểm tra lại bộ lọc hoặc trạng thái phê duyệt bảng lương.</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:set var="stt" value="1"/>
                                <c:forEach var="p" items="${reportData}">
                                    <tr>
                                        <td style="color:#94a3b8;font-size:0.8rem;">${stt}</td>
                                        <td style="font-weight:600;color:#0d9488;">NV<fmt:formatNumber value="${p.userId}" minIntegerDigits="4" groupingUsed="false"/></td>
                                        <td style="font-weight:600;">${p.fullName}</td>
                                        <td><span class="badge-dept">${not empty p.departmentName ? p.departmentName : '—'}</span></td>
                                        <td class="money"><fmt:formatNumber value="${p.baseSalary}"      type="number" groupingUsed="true"/></td>
                                        <td class="money"><fmt:formatNumber value="${p.bonusAmount}"     type="number" groupingUsed="true"/></td>
                                        <td class="money"><fmt:formatNumber value="${p.allowanceAmount}" type="number" groupingUsed="true"/></td>
                                        <td class="money" style="color:#b45309;"><fmt:formatNumber value="${p.deductionAmount}" type="number" groupingUsed="true"/></td>
                                        <td class="money" style="color:#b45309;"><fmt:formatNumber value="${p.insuranceAmount}" type="number" groupingUsed="true"/></td>
                                        <td class="money" style="color:#b45309;"><fmt:formatNumber value="${p.taxAmount}"       type="number" groupingUsed="true"/></td>
                                        <td class="money" style="color:#dc2626;font-weight:700;"><fmt:formatNumber value="${p.totalDeductionAll}" type="number" groupingUsed="true"/></td>
                                        <td class="money" style="color:#059669;font-weight:800;"><fmt:formatNumber value="${p.netSalary}" type="number" groupingUsed="true"/> ₫</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.status eq 'Paid'}">
                                                    <span class="badge-paid"><i class="fas fa-check-circle"></i> Đã chi lương</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-approved"><i class="fas fa-thumbs-up"></i> Đã duyệt</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                    <c:set var="stt" value="${stt + 1}"/>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                    <c:if test="${not empty reportData}">
                    <tfoot>
                        <tr>
                            <td colspan="4" style="text-align:right;letter-spacing:.5px;">TỔNG CỘNG</td>
                            <td class="money"><fmt:formatNumber value="${totalBase}"      type="number" groupingUsed="true"/></td>
                            <td class="money"><fmt:formatNumber value="${totalBonus}"     type="number" groupingUsed="true"/></td>
                            <td class="money"><fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/></td>
                            <td class="money" colspan="3">—</td>
                            <td class="money"><fmt:formatNumber value="${totalDeduction}" type="number" groupingUsed="true"/></td>
                            <td class="money"><fmt:formatNumber value="${totalNet}"       type="number" groupingUsed="true"/> ₫</td>
                            <td>—</td>
                        </tr>
                    </tfoot>
                    </c:if>
                </table>
            </div>

        </div><!-- /content-wrapper -->
    </div><!-- /main-content -->
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo Hợp đồng Nhân sự - Tập đoàn HRM</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .report-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        .filter-box {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 24px;
            display: flex;
            gap: 16px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .filter-group label {
            font-size: 0.85rem;
            font-weight: 600;
            color: #4b5563;
        }
        .filter-group input, .filter-group select {
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-family: inherit;
        }
        .report-table-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .report-table {
            width: 100%;
            border-collapse: collapse;
        }
        .report-table th {
            background: #f9fafb;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            color: #4b5563;
            font-size: 0.85rem;
            border-bottom: 1px solid #e5e7eb;
        }
        .report-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #e5e7eb;
            color: #1f2937;
            font-size: 0.9rem;
        }
        .days-warning {
            color: #b91c1c;
            background: #fee2e2;
            padding: 2px 8px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 0.8rem;
        }
        .days-safe {
            color: #047857;
            background: #d1fae5;
            padding: 2px 8px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 0.8rem;
        }
    </style>
</head>
<body class="app-layout">
    <jsp:include page="../includes/sidebar.jsp" />

    <div class="main-content">
        <jsp:include page="../includes/header.jsp" />

        <div class="content-wrapper">
            <div class="report-header">
                <div>
                    <h1 class="page-title">Báo cáo Hợp đồng sắp hết hạn</h1>
                    <p style="color: #6b7280; margin-top: 4px;">Danh sách nhân viên có hợp đồng cần tái ký theo điều kiện lọc.</p>
                </div>
            </div>

            <!-- Form Lọc -->
            <form action="${pageContext.request.contextPath}/hr/report" method="GET" class="filter-box">
                <div class="filter-group">
                    <label>Hết hạn Từ ngày</label>
                    <input type="date" name="fromDate" value="${fromDate}">
                </div>
                <div class="filter-group">
                    <label>Đến ngày</label>
                    <input type="date" name="toDate" value="${toDate}">
                </div>
                <div class="filter-group">
                    <label>Phòng ban</label>
                    <select name="departmentId">
                        <option value="-1">Tất cả phòng ban</option>
                        <c:forEach var="d" items="${departments}">
                            <option value="${d.departmentId}" ${departmentId == d.departmentId ? 'selected' : ''}>${d.departmentName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="filter-group">
                    <button type="submit" class="btn-primary" style="height: 38px;"><i class="fas fa-filter"></i> Lọc báo cáo</button>
                </div>
            </form>

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="font-size: 1.1rem; margin: 0;">Kết quả truy vấn: <span style="color: #2563eb;">${reportData.size()} hợp đồng</span></h3>
                
                <!-- Nút Xuất Excel -->
                <form action="${pageContext.request.contextPath}/hr/report" method="POST">
                    <input type="hidden" name="action" value="exportExcel">
                    <input type="hidden" name="fromDate" value="${fromDate}">
                    <input type="hidden" name="toDate" value="${toDate}">
                    <input type="hidden" name="departmentId" value="${departmentId}">
                    <button type="submit" class="btn-outline" style="color: #059669; border-color: #059669; background: white; font-weight: 600;">
                        <i class="fas fa-file-excel"></i> Xuất file Excel (CSV)
                    </button>
                </form>
            </div>

            <div class="report-table-container">
                <table class="report-table">
                    <thead>
                        <tr>
                            <th>Mã NV</th>
                            <th>Tên nhân viên</th>
                            <th>Phòng ban</th>
                            <th>Loại hợp đồng</th>
                            <th>Ngày hết hạn</th>
                            <th>Tình trạng</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty reportData}">
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 32px; color: #6b7280; font-style: italic;">Không có hợp đồng nào sắp hết hạn trong khoảng thời gian này.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="row" items="${reportData}">
                                    <tr>
                                        <td style="font-weight: 500; color: #4b5563;">NV${String.format("%04d", row.userId)}</td>
                                        <td style="font-weight: 600;">${row.fullName}</td>
                                        <td>${row.departmentName}</td>
                                        <td>${row.typeName}</td>
                                        <td style="font-weight: 500;"><fmt:formatDate value="${row.endDate}" pattern="dd/MM/yyyy"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${row.daysLeft < 0}">
                                                    <span class="days-warning">Đã quá hạn ${-row.daysLeft} ngày</span>
                                                </c:when>
                                                <c:when test="${row.daysLeft <= 15}">
                                                    <span class="days-warning">Còn ${row.daysLeft} ngày (Gấp)</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="days-safe">Còn ${row.daysLeft} ngày</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</body>
</html>

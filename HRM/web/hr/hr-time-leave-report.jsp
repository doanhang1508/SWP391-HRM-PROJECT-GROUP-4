<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Báo cáo Công & Phép" scope="request" />
<jsp:include page="../header.jsp" />

<!-- Google Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    body { background-color: #f8fafc; font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 40px; width: calc(100% - 260px); }
    
    .admin-panel {
        background: #fff; border-radius: 20px; padding: 30px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03); border: 1px solid #e2e8f0;
    }
    .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .panel-title { font-size: 1.25rem; font-weight: 700; color: #0f172a; margin: 0; display: flex; align-items: center; gap: 12px; }
    .panel-title-icon { width: 32px; height: 32px; background: #eff6ff; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #3b82f6; font-size: 0.9rem; }
    
    .table-custom { width: 100%; border-collapse: collapse; }
    .table-custom th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 0.8rem; text-transform: uppercase; padding: 16px 20px; border-bottom: 1px solid #e2e8f0; }
    .table-custom td { padding: 16px 20px; vertical-align: middle; color: #0f172a; font-size: 0.95rem; border-bottom: 1px solid #e2e8f0; }
    
    .row-highlight { background-color: #fef2f2 !important; }
    
    /* Pagination Styles */
    .pagination-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 24px;
        padding-top: 16px;
        border-top: 1px solid #e2e8f0;
    }
    .pagination-info {
        font-size: 0.85rem;
        color: #64748b;
    }
    .pagination-buttons {
        display: flex;
        gap: 8px;
    }
    .btn-pag {
        width: 38px;
        height: 38px;
        border-radius: 8px;
        border: 1px solid #cbd5e1;
        background: #fff;
        color: #1e293b;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
    }
    .btn-pag:hover:not(.disabled) {
        background: #f1f5f9;
        border-color: #94a3b8;
        color: #1e293b;
    }
    .btn-pag.disabled {
        opacity: 0.5;
        cursor: not-allowed;
        pointer-events: none;
    }
    
    @media(max-width:768px){.main-content{width:100%!important;padding:20px 16px!important;}}

    .chart-card { background:#fff; border:1px solid #e2e8f0; border-radius:16px; padding:20px 24px; height:100%; }
    .chart-card h6 { font-weight:700; color:#0f172a; margin-bottom:16px; display:flex; align-items:center; gap:8px; }
    .chart-scroll-wrapper { overflow-x: auto; padding-bottom: 4px; }
    .chart-scroll-inner { height: 260px; }
    .chart-scroll-hint { font-size: 0.72rem; color: #94a3b8; margin-top: 6px; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="time-leave-report" />
    </jsp:include>

    <div class="main-content">
        <div class="admin-panel">
            <div class="panel-header">
                <h2 class="panel-title">
                    <div class="panel-title-icon"><i class="fas fa-file-excel"></i></div>
                    Báo cáo Tổng hợp Công & Phép
                </h2>
                <div>
                    <!-- Form xuất excel -->
                    <form action="${pageContext.request.contextPath}/hr/time-leave-report" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="exportExcel">
                        <input type="hidden" name="month" value="${selectedMonth}">
                        <input type="hidden" name="year" value="${selectedYear}">
                        <input type="hidden" name="departmentId" value="${selectedDepartmentId}">
                        <button type="submit" class="btn btn-success btn-sm">
                            <i class="fas fa-file-excel"></i> Xuất báo cáo chuyên cần tháng (Excel)
                        </button>
                    </form>
                </div>
            </div>

            <!-- Filter -->
            <form action="${pageContext.request.contextPath}/hr/time-leave-report" method="get" class="row g-3 align-items-center mb-4">
                <div class="col-md-2">
                    <label class="form-label" style="font-size: 0.85rem; font-weight: 600; color: #475569;">Tháng</label>
                    <select name="month" class="form-select">
                        <c:forEach var="m" begin="1" end="12">
                            <option value="${m}" ${selectedMonth == m ? 'selected' : ''}>Tháng ${m}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label" style="font-size: 0.85rem; font-weight: 600; color: #475569;">Năm</label>
                    <select name="year" class="form-select">
                        <c:forEach var="y" begin="2020" end="2030">
                            <option value="${y}" ${selectedYear == y ? 'selected' : ''}>${y}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label" style="font-size: 0.85rem; font-weight: 600; color: #475569;">Phòng ban</label>
                    <select name="departmentId" class="form-select">
                        <option value="">Tất cả phòng ban</option>
                        <c:forEach var="d" items="${departments}">
                            <option value="${d.departmentId}" ${selectedDepartmentId == d.departmentId ? 'selected' : ''}>${d.departmentName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100" style="height: 38px;">Lọc</button>
                </div>
            </form>

            <!-- Biểu đồ tổng hợp: dùng chartDataList (toàn bộ nhân viên theo bộ lọc), không phụ thuộc phân trang -->
            <c:if test="${not empty chartDataList}">
                <div class="row g-4 mb-4">
                    <div class="col-lg-7">
                        <div class="chart-card">
                            <h6>
                                <i class="fas fa-chart-bar" style="color:#3b82f6;"></i> Công chuẩn &amp; Công thực tế theo nhân viên
                            </h6>
                            <div class="chart-scroll-wrapper">
                                <div class="chart-scroll-inner" id="scrollWrapWorkDays">
                                    <canvas id="chartWorkDays"></canvas>
                                </div>
                            </div>
                            <div class="chart-scroll-hint"><i class="fas fa-arrows-alt-h"></i> Kéo ngang để xem thêm nhân viên (tổng: ${fn:length(chartDataList)} người)</div>
                        </div>
                    </div>
                    <div class="col-lg-5">
                        <div class="chart-card">
                            <h6>
                                <i class="fas fa-chart-pie" style="color:#7c3aed;"></i> Cơ cấu ngày nghỉ (Phép/Ốm/Thai sản)
                            </h6>
                            <canvas id="chartLeaveBreakdown" height="220"></canvas>
                        </div>
                    </div>
                    <div class="col-lg-12">
                        <div class="chart-card">
                            <h6>
                                <i class="fas fa-business-time" style="color:#ea580c;"></i> Giờ tăng ca (OT) theo nhân viên
                            </h6>
                            <div class="chart-scroll-wrapper">
                                <div class="chart-scroll-inner" id="scrollWrapOt">
                                    <canvas id="chartOtHours"></canvas>
                                </div>
                            </div>
                            <div class="chart-scroll-hint"><i class="fas fa-arrows-alt-h"></i> Kéo ngang để xem thêm nhân viên (tổng: ${fn:length(chartDataList)} người)</div>
                        </div>
                    </div>
                </div>
            </c:if>

            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>Mã NV</th>
                            <th>Họ Tên</th>
                            <th class="text-center">Công chuẩn</th>
                            <th class="text-center">Công thực tế</th>
                            <th class="text-center">OT thường (h)</th>
                            <th class="text-center">OT CN (h)</th>
                            <th class="text-center">OT Lễ (h)</th>
                            <th class="text-center">Đi trễ (lần)</th>
                            <th class="text-center">Phép năm (ngày)</th>
                            <th class="text-center">Nghỉ ốm (ngày)</th>
                            <th class="text-center">Nghỉ thai sản (ngày)</th>
                            <th class="text-center">Phép năm còn lại</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty reportList}">
                                <tr>
                                    <td colspan="8" class="text-center py-4 text-muted">
                                        Không có dữ liệu cho tháng ${selectedMonth}/${selectedYear}
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="r" items="${reportList}">
                                    <tr style="${r.lateCount >= 3 ? 'background-color: #fee2e2;' : ''}">
                                        <td style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}"><strong>NV${r.userId}</strong></td>
                                        <td style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}">
                                            <div style="font-weight: 600;">${r.userName}</div>
                                        </td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}">${r.standardWorkDays}</td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}"><span class="badge bg-primary rounded-pill"><fmt:formatNumber value="${r.actualWorkDays}" maxFractionDigits="1"/></span></td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}">
                                            <c:choose><c:when test="${r.regularOtHrs > 0}"><span class="badge bg-info text-dark rounded-pill"><fmt:formatNumber value="${r.regularOtHrs}" pattern="#,##0.#"/></span></c:when><c:otherwise><span class="text-muted">-</span></c:otherwise></c:choose>
                                        </td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}">
                                            <c:choose><c:when test="${r.sundayOtHrs > 0}"><span class="badge bg-warning text-dark rounded-pill"><fmt:formatNumber value="${r.sundayOtHrs}" pattern="#,##0.#"/></span></c:when><c:otherwise><span class="text-muted">-</span></c:otherwise></c:choose>
                                        </td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}">
                                            <c:choose><c:when test="${r.holidayOtHrs > 0}"><span class="badge bg-danger rounded-pill"><fmt:formatNumber value="${r.holidayOtHrs}" pattern="#,##0.#"/></span></c:when><c:otherwise><span class="text-muted">-</span></c:otherwise></c:choose>
                                        </td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}"><span class="badge ${r.lateCount >= 3 ? 'bg-danger' : 'bg-warning text-dark'} rounded-pill">${r.lateCount}</span></td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}">
                                            <c:choose><c:when test="${r.annualLeaveDays > 0}"><fmt:formatNumber value="${r.annualLeaveDays}" pattern="#,##0.#"/></c:when><c:otherwise><span class="text-muted">-</span></c:otherwise></c:choose>
                                        </td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}">
                                            <c:choose><c:when test="${r.sickLeaveDays > 0}"><fmt:formatNumber value="${r.sickLeaveDays}" pattern="#,##0.#"/></c:when><c:otherwise><span class="text-muted">-</span></c:otherwise></c:choose>
                                        </td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}">
                                            <c:choose><c:when test="${r.maternityLeaveDays > 0}"><fmt:formatNumber value="${r.maternityLeaveDays}" pattern="#,##0.#"/></c:when><c:otherwise><span class="text-muted">-</span></c:otherwise></c:choose>
                                        </td>
                                        <td class="text-center" style="${r.lateCount >= 3 ? 'background-color: transparent;' : ''}"><span class="badge bg-success rounded-pill"><fmt:formatNumber value="${r.remainingAnnualLeave}" pattern="#,##0.#"/></span></td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Pagination container -->
            <div class="pagination-container">
                <div class="pagination-info">
                    <c:choose>
                        <c:when test="${empty totalRecords || totalRecords == 0}">
                            Hiển thị 0 - 0 trong số 0 nhân viên.
                        </c:when>
                        <c:otherwise>
                            Hiển thị ${(currentPage - 1) * 15 + 1} - ${currentPage * 15 > totalRecords ? totalRecords : currentPage * 15} trong số ${totalRecords} nhân viên.
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="pagination-buttons">
                    <a href="?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDepartmentId}&page=${currentPage - 1}" 
                       class="btn-pag ${currentPage == 1 ? 'disabled' : ''}" 
                       title="Trang trước">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                    <a href="?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDepartmentId}&page=${currentPage + 1}" 
                       class="btn-pag ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''}" 
                       title="Trang sau">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<c:if test="${not empty chartDataList}">
<script>
    // Dữ liệu biểu đồ lấy từ chartDataList: TOÀN BỘ nhân viên theo tháng/năm/phòng ban đang lọc,
    // không phụ thuộc phân trang của bảng (reportList) bên dưới.
    const empNames = [
        <c:forEach var="r" items="${chartDataList}">'${fn:escapeXml(r.userName)}',</c:forEach>
    ];
    const standardDays = [<c:forEach var="r" items="${chartDataList}">${r.standardWorkDays},</c:forEach>];
    const actualDays   = [<c:forEach var="r" items="${chartDataList}">${r.actualWorkDays},</c:forEach>];
    const regularOt = [<c:forEach var="r" items="${chartDataList}">${r.regularOtHrs},</c:forEach>];
    const sundayOt   = [<c:forEach var="r" items="${chartDataList}">${r.sundayOtHrs},</c:forEach>];
    const holidayOt  = [<c:forEach var="r" items="${chartDataList}">${r.holidayOtHrs},</c:forEach>];

    let totalAnnual = 0, totalSick = 0, totalMaternity = 0;
    <c:forEach var="r" items="${chartDataList}">
        totalAnnual += ${r.annualLeaveDays};
        totalSick += ${r.sickLeaveDays};
        totalMaternity += ${r.maternityLeaveDays};
    </c:forEach>

    // Với số lượng nhân viên lớn, cột sẽ quá chật nếu ép vừa khung cố định.
    // Thay vào đó: cho canvas rộng theo tỉ lệ số nhân viên và cuộn ngang trong khung chứa.
    const PX_PER_EMPLOYEE = 55;
    function sizeScrollableChart(wrapperId, canvasId, count) {
        const wrapper = document.getElementById(wrapperId);
        const canvas = document.getElementById(canvasId);
        const containerWidth = wrapper.parentElement.clientWidth;
        const neededWidth = count * PX_PER_EMPLOYEE;
        const finalWidth = Math.max(containerWidth, neededWidth);
        wrapper.style.width = finalWidth + 'px';
        canvas.style.width = finalWidth + 'px';
        canvas.style.height = '100%';
    }
    sizeScrollableChart('scrollWrapWorkDays', 'chartWorkDays', empNames.length);
    sizeScrollableChart('scrollWrapOt', 'chartOtHours', empNames.length);

    // 1) Công chuẩn vs Công thực tế
    new Chart(document.getElementById('chartWorkDays'), {
        type: 'bar',
        data: {
            labels: empNames,
            datasets: [
                { label: 'Công chuẩn', data: standardDays, backgroundColor: '#cbd5e1', borderRadius: 4 },
                { label: 'Công thực tế', data: actualDays, backgroundColor: '#3b82f6', borderRadius: 4 }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: 'bottom' } },
            scales: { y: { beginAtZero: true } }
        }
    });

    // 2) Cơ cấu ngày nghỉ (tổng hợp toàn bộ, không phụ thuộc số lượng nhân viên)
    new Chart(document.getElementById('chartLeaveBreakdown'), {
        type: 'doughnut',
        data: {
            labels: ['Phép năm', 'Nghỉ ốm', 'Thai sản'],
            datasets: [{
                data: [totalAnnual, totalSick, totalMaternity],
                backgroundColor: ['#22c55e', '#f59e0b', '#ec4899']
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { position: 'bottom' } }
        }
    });

    // 3) Giờ OT theo nhân viên (stacked)
    new Chart(document.getElementById('chartOtHours'), {
        type: 'bar',
        data: {
            labels: empNames,
            datasets: [
                { label: 'OT thường', data: regularOt, backgroundColor: '#38bdf8', stack: 'ot' },
                { label: 'OT Chủ nhật', data: sundayOt, backgroundColor: '#facc15', stack: 'ot' },
                { label: 'OT Lễ', data: holidayOt, backgroundColor: '#ef4444', stack: 'ot' }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: 'bottom' } },
            scales: { x: { stacked: true }, y: { stacked: true, beginAtZero: true } }
        }
    });
</script>
</c:if>
</body>
</html>

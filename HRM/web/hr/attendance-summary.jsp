<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Tổng hợp chấm công" scope="request" />
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
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="attendance-summary" />
    </jsp:include>

    <div class="main-content">
        <div class="admin-panel">
            <div class="panel-header">
                <h2 class="panel-title">
                    <div class="panel-title-icon"><i class="fas fa-clipboard-list"></i></div>
                    Tổng Hợp Chấm Công
                </h2>
                <div>
                    <a href="${pageContext.request.contextPath}/hr/attendance-management?action=detail&month=${selectedMonth}&year=${selectedYear}" class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-list"></i> Chi tiết chấm công
                    </a>
                </div>
            </div>

            <!-- Filter Month/Year -->
            <form action="${pageContext.request.contextPath}/hr/attendance-management" method="get" class="row g-3 align-items-center mb-4">
                <input type="hidden" name="action" value="summary">
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
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100" style="height: 38px;">Lọc</button>
                </div>
            </form>

            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>Mã NV</th>
                            <th>Họ Tên</th>
                            <th>Phòng Ban</th>
                            <th class="text-center">Số công (Hiện diện/Trễ)</th>
                            <th class="text-center">Đi trễ (Lần)</th>
                            <th class="text-center">Vắng (Lần)</th>
                            <th class="text-center">Tăng ca (Giờ)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty summaryList}">
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">
                                        Không có dữ liệu chấm công cho tháng ${selectedMonth}/${selectedYear}
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="s" items="${summaryList}">
                                    <tr>
                                        <td><strong>NV${s.userId}</strong></td>
                                        <td>
                                            <div style="font-weight: 600;">${s.userName}</div>
                                        </td>
                                        <td>${s.department != null ? s.department : '-'}</td>
                                        <td class="text-center"><span class="badge bg-primary rounded-pill">${s.presentCount + s.lateCount}</span></td>
                                        <td class="text-center"><span class="badge bg-warning text-dark rounded-pill">${s.lateCount}</span></td>
                                        <td class="text-center"><span class="badge bg-danger rounded-pill">${s.absentCount}</span></td>
                                        <td class="text-center"><span class="badge bg-success rounded-pill">${s.totalOvertimeHrs}</span></td>
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
                    <a href="?action=summary&month=${selectedMonth}&year=${selectedYear}&page=${currentPage - 1}" 
                       class="btn-pag ${currentPage == 1 ? 'disabled' : ''}" 
                       title="Trang trước">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                    <a href="?action=summary&month=${selectedMonth}&year=${selectedYear}&page=${currentPage + 1}" 
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
</body>
</html>

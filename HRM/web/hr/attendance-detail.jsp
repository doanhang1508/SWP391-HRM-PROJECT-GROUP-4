<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chi tiết chấm công" scope="request" />
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
    
    .badge-soft { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
    .badge-soft.PRESENT { background: #d1fae5; color: #059669; }
    .badge-soft.LATE { background: #fef3c7; color: #d97706; }
    .badge-soft.ABSENT { background: #fee2e2; color: #dc2626; }
    
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
        <jsp:param name="activeMenu" value="attendance-detail" />
    </jsp:include>

    <div class="main-content">
        <div class="admin-panel">
            <div class="panel-header">
                <h2 class="panel-title">
                    <div class="panel-title-icon"><i class="fas fa-list"></i></div>
                    Chi Tiết Chấm Công
                </h2>
                <div>
                    <a href="${pageContext.request.contextPath}/hr/attendance-management?action=summary&month=${selectedMonth}&year=${selectedYear}" class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-clipboard-list"></i> Tổng hợp chấm công
                    </a>
                </div>
            </div>

            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>

            <!-- Filter Month/Year/User -->
            <form action="${pageContext.request.contextPath}/hr/attendance-management" method="get" class="row g-3 align-items-center mb-4">
                <input type="hidden" name="action" value="detail">
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
                <div class="col-md-2">
                    <label class="form-label" style="font-size: 0.85rem; font-weight: 600; color: #475569;">Tên nhân viên</label>
                    <input type="text" name="userName" class="form-control" value="${selectedUserName}" placeholder="Nhập tên...">
                </div>
                <div class="col-md-2">
                    <label class="form-label" style="font-size: 0.85rem; font-weight: 600; color: #475569;">Ngày</label>
                    <input type="date" name="workDate" class="form-control" value="${selectedWorkDate}">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100" style="height: 38px;">Lọc</button>
                </div>
            </form>

            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>Ngày</th>
                            <th>Họ Tên</th>
                            <th>Ca Làm Việc</th>
                            <th>Giờ Vào</th>
                            <th>Giờ Ra</th>
                            <th>Trạng Thái</th>
                            <th>Tăng Ca (Giờ)</th>
                            <th>Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty detailList}">
                                <tr>
                                    <td colspan="8" class="text-center py-4 text-muted">
                                        Không có dữ liệu chi tiết cho tháng ${selectedMonth}/${selectedYear}
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="a" items="${detailList}">
                                    <tr>
                                        <td><fmt:formatDate value="${a.workDate}" pattern="dd/MM/yyyy"/></td>
                                        <td><strong>${a.userName}</strong></td>
                                        <td>${a.shiftName}</td>
                                        <td><c:choose><c:when test="${not empty a.checkIn}">${a.checkIn}</c:when><c:otherwise><span class="text-muted">-</span></c:otherwise></c:choose></td>
                                        <td><c:choose><c:when test="${not empty a.checkOut}">${a.checkOut}</c:when><c:otherwise><span class="text-muted">-</span></c:otherwise></c:choose></td>
                                        <td>
                                            <span class="badge-soft ${a.status}">
                                                ${a.status}
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.overtimeHrs > 0}">
                                                    <span class="badge bg-success"><fmt:formatNumber value="${a.overtimeHrs}" pattern="#,##0.##"/></span>
                                                </c:when>
                                                <c:otherwise><span class="text-muted">-</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-warning" data-bs-toggle="modal" data-bs-target="#editModal${a.attendanceId}">
                                                <i class="fas fa-edit"></i> Sửa
                                            </button>
                                            
                                            <!-- Modal Edit -->
                                            <div class="modal fade" id="editModal${a.attendanceId}" tabindex="-1" aria-labelledby="editModalLabel${a.attendanceId}" aria-hidden="true">
                                                <div class="modal-dialog">
                                                    <div class="modal-content">
                                                        <form action="${pageContext.request.contextPath}/hr/attendance-management" method="post">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title" id="editModalLabel${a.attendanceId}">Sửa chấm công - ${a.userName}</h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                            </div>
                                                            <div class="modal-body">
                                                                <input type="hidden" name="action" value="update">
                                                                <input type="hidden" name="attendanceId" value="${a.attendanceId}">
                                                                <input type="hidden" name="month" value="${selectedMonth}">
                                                                <input type="hidden" name="year" value="${selectedYear}">
                                                                <input type="hidden" name="userName" value="${selectedUserName}">
                                                                <input type="hidden" name="workDate" value="${selectedWorkDate}">
                                                                
                                                                <div class="mb-3">
                                                                    <label class="form-label">Ngày làm việc</label>
                                                                    <input type="text" class="form-control" value="<fmt:formatDate value="${a.workDate}" pattern="dd/MM/yyyy"/>" disabled>
                                                                </div>
                                                                <div class="mb-3">
                                                                    <label class="form-label">Giờ vào</label>
                                                                    <input type="time" class="form-control" name="checkIn" value="${a.checkIn}">
                                                                </div>
                                                                <div class="mb-3">
                                                                    <label class="form-label">Giờ ra</label>
                                                                    <input type="time" class="form-control" name="checkOut" value="${a.checkOut}">
                                                                </div>
                                                                <div class="mb-3">
                                                                    <label class="form-label">Trạng thái</label>
                                                                    <select class="form-select" name="status">
                                                                        <option value="PRESENT" ${a.status == 'PRESENT' ? 'selected' : ''}>PRESENT</option>
                                                                        <option value="LATE" ${a.status == 'LATE' ? 'selected' : ''}>LATE</option>
                                                                        <option value="ABSENT" ${a.status == 'ABSENT' ? 'selected' : ''}>ABSENT</option>
                                                                        <option value="MISSING" ${a.status == 'MISSING' ? 'selected' : ''}>MISSING</option>
                                                                        <option value="HALFDAY" ${a.status == 'HALFDAY' ? 'selected' : ''}>HALFDAY</option>
                                                                        <option value="LEAVE" ${a.status == 'LEAVE' ? 'selected' : ''}>LEAVE</option>
                                                                        <option value="SICK_LEAVE" ${a.status == 'SICK_LEAVE' ? 'selected' : ''}>SICK_LEAVE</option>

                                                                    </select>
                                                                </div>
                                                                <div class="mb-3">
                                                                    <label class="form-label">Giờ OT</label>
                                                                    <input type="number" class="form-control" name="overtimeHrs"
                                                                           value="${a.overtimeHrs}" min="0" max="24" step="0.25">
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                                                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
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
                            Hiển thị 0 - 0 trong số 0 bản ghi.
                        </c:when>
                        <c:otherwise>
                            Hiển thị ${(currentPage - 1) * 15 + 1} - ${currentPage * 15 > totalRecords ? totalRecords : currentPage * 15} trong số ${totalRecords} bản ghi.
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="pagination-buttons">
                    <a href="?action=detail&month=${selectedMonth}&year=${selectedYear}&userName=${selectedUserName}&workDate=${selectedWorkDate}&page=${currentPage - 1}" 
                       class="btn-pag ${currentPage == 1 ? 'disabled' : ''}" 
                       title="Trang trước">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                    <a href="?action=detail&month=${selectedMonth}&year=${selectedYear}&userName=${selectedUserName}&workDate=${selectedWorkDate}&page=${currentPage + 1}" 
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

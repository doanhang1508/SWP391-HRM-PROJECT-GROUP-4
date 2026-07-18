<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="pageTitle" value="Lịch sử đánh giá KPI" />
<%@include file="../header.jsp"%>

<style>
    .page-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .page-main {
        flex: 1;
        padding: 32px 36px;
        overflow-x: hidden;
    }
    .history-card {
        border-radius: 16px;
        background: var(--th-surface, #ffffff);
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        border: none;
    }
    .filter-section {
        background: #f8fafc;
        border-radius: 12px;
        border: 1px solid #e2e8f0;
    }
    .badge-status {
        font-weight: 600;
        padding: 6px 12px;
        border-radius: 8px;
        font-size: 0.85rem;
    }
    #historyTable th {
        font-size: 0.82rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        vertical-align: middle;
        background: #f8f9fa;
        border-bottom: 2px solid #dee2e6;
        color: #495057;
    }
    #historyTable tbody tr {
        transition: all 0.2s ease;
    }
    #historyTable tbody tr:hover {
        background-color: rgba(99, 179, 237, 0.05);
    }
    .stat-box {
        border-radius: 12px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        transition: all 0.3s ease;
    }
    .stat-box:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="kpi-history" />
    </jsp:include>

    <main class="page-main">
        <div class="container-fluid py-4">
            <!-- Header Section -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
                <div>
                    <h2 class="fw-bold mb-1 text-dark" style="font-family: 'Be Vietnam Pro', sans-serif;">Lịch sử Đánh giá KPI</h2>
                    <p class="text-muted mb-0">Tra cứu và xem lại các kết quả đánh giá KPI lịch sử của nhân sự</p>
                </div>
            </div>

            <!-- Filters Section -->
            <div class="card history-card mb-4">
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/manager/kpi-history" method="GET" class="row g-3 align-items-end">
                        <!-- Month Filter -->
                        <div class="col-md-3">
                            <label for="month" class="form-label fw-bold text-secondary small">Tháng</label>
                            <select name="month" id="month" class="form-select px-3 py-2" style="border-radius: 8px;">
                                <option value="">-- Tất cả tháng --</option>
                                <c:forEach var="m" items="${months}">
                                    <option value="${m}" ${m == selectedMonth ? 'selected' : ''}>Tháng ${m}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Year Filter -->
                        <div class="col-md-3">
                            <label for="year" class="form-label fw-bold text-secondary small">Năm</label>
                            <select name="year" id="year" class="form-select px-3 py-2" style="border-radius: 8px;">
                                <option value="">-- Tất cả năm --</option>
                                <c:forEach var="y" items="${years}">
                                    <option value="${y}" ${y == selectedYear ? 'selected' : ''}>Năm ${y}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Department Filter -->
                        <div class="col-md-4">
                            <label for="departmentId" class="form-label fw-bold text-secondary small">Phòng ban</label>
                            <c:choose>
                                <c:when test="${viewAllCompany}">
                                    <select name="departmentId" id="departmentId" class="form-select px-3 py-2" style="border-radius: 8px;">
                                        <option value="">-- Tất cả phòng ban --</option>
                                        <c:forEach var="dept" items="${departments}">
                                            <option value="${dept.departmentId}" ${dept.departmentId == selectedDeptId ? 'selected' : ''}>
                                                ${dept.departmentName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <!-- Restricted role, read-only display -->
                                    <c:forEach var="dept" items="${departments}">
                                        <c:if test="${dept.departmentId == selectedDeptId}">
                                            <input type="text" class="form-control px-3 py-2 bg-light" value="${dept.departmentName}" readonly style="border-radius: 8px;" />
                                            <input type="hidden" name="departmentId" value="${selectedDeptId}" />
                                        </c:if>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Filter Buttons -->
                        <div class="col-md-2 d-flex gap-2">
                            <button type="submit" class="btn btn-primary px-3 py-2 flex-grow-1 fw-semibold d-flex align-items-center justify-content-center gap-2" style="border-radius: 8px;">
                                <i class="fas fa-filter"></i> Lọc
                            </button>
                            <a href="${pageContext.request.contextPath}/manager/kpi-history" class="btn btn-outline-secondary px-3 py-2 fw-semibold d-flex align-items-center justify-content-center" style="border-radius: 8px;" title="Reset bộ lọc">
                                <i class="fas fa-undo"></i>
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- List Table of KPI History -->
            <div class="card history-card">
                <div class="card-body p-4">
                    <div class="table-responsive">
                        <table class="table align-middle mb-0" id="historyTable">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" style="width: 10%;">Mã NV</th>
                                    <th scope="col" style="width: 18%;">Họ tên nhân viên</th>
                                    <th scope="col" style="width: 14%;">Phòng ban</th>
                                    <th scope="col" style="width: 18%;">Đợt đánh giá</th>
                                    <th scope="col" style="width: 8%;" class="text-center">Điểm TB</th>
                                    <th scope="col" style="width: 8%;" class="text-center">Điểm TS</th>
                                    <th scope="col" style="width: 12%;" class="text-center">Trạng thái</th>
                                    <th scope="col" style="width: 12%;" class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="eval" items="${evaluations}">
                                    <tr>
                                        <td><code class="fw-bold">${eval.employeeCode}</code></td>
                                        <td><strong class="text-dark">${eval.employeeName}</strong></td>
                                        <td><span class="text-secondary small">${eval.departmentName}</span></td>
                                        <td>
                                            <span class="fw-semibold text-secondary-emphasis">${eval.cycleName}</span>
                                        </td>
                                        <td class="text-center fw-semibold text-dark">${eval.score}</td>
                                        <td class="text-center fw-bold text-primary">${eval.weightedScore}</td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${eval.status == 'APPROVED'}">
                                                    <span class="badge-status bg-success-subtle text-success">Đã phê duyệt</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status bg-warning-subtle text-warning">Nháp</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <!-- Construct URL with existing filter parameters to maintain context -->
                                            <a href="${pageContext.request.contextPath}/manager/kpi-history?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDeptId}&viewId=${eval.evaluationId}" class="btn btn-outline-primary btn-sm px-3 py-1.5 fw-semibold" style="border-radius: 6px;">
                                                <i class="fas fa-eye me-1"></i> Chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty evaluations}">
                                    <tr>
                                        <td colspan="8" class="text-center py-5 text-muted">
                                            <i class="fas fa-history fa-2x mb-3 opacity-50"></i>
                                            <p class="mb-0 fw-semibold">Không tìm thấy lịch sử đánh giá nào.</p>
                                            <span class="small text-secondary">Hãy thử điều chỉnh bộ lọc ở trên.</span>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Modal Detail view -->
<c:if test="${detailEval != null}">
    <div class="modal fade" id="detailModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content border-0 shadow" style="border-radius: 20px; background: var(--th-surface);">
                <div class="modal-header border-0 px-4 pt-4">
                    <div>
                        <h4 class="modal-title fw-bold mb-1" style="font-family: 'Be Vietnam Pro', sans-serif;">
                            Chi tiết đánh giá KPI - ${detailEval.employeeName}
                        </h4>
                        <span class="text-muted small">Mã nhân viên: <code>${detailEval.employeeCode}</code> | Phòng ban: ${detailEval.departmentName}</span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="window.location.href = '${pageContext.request.contextPath}/manager/kpi-history?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDeptId}'"></button>
                </div>

                <div class="modal-body px-4 pb-4">
                    <!-- Basic Info & Stats Row -->
                    <div class="row g-3 mb-4">
                        <div class="col-md-3 col-sm-6">
                            <div class="p-3 stat-box text-center">
                                <span class="text-muted small d-block mb-1">Chu kỳ</span>
                                <strong class="text-dark">${detailEval.cycleName}</strong>
                            </div>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <div class="p-3 stat-box text-center">
                                <span class="text-muted small d-block mb-1">Người đánh giá</span>
                                <strong class="text-dark">${detailEval.managerName}</strong>
                            </div>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <div class="p-3 stat-box text-center">
                                <span class="text-muted small d-block mb-1">Điểm Trung bình</span>
                                <strong class="text-dark fs-5">${detailEval.score}</strong>
                            </div>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <div class="p-3 stat-box text-center">
                                <span class="text-muted small d-block mb-1">Điểm Trọng số</span>
                                <strong class="text-primary fs-5">${detailEval.weightedScore}</strong>
                            </div>
                        </div>
                    </div>

                    <!-- Criteria Breakdown Table -->
                    <div class="table-responsive mb-4">
                        <table class="table align-middle border-0">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" style="width: 25%;">Tiêu chí</th>
                                    <th scope="col" style="width: 50%;">Mô tả tiêu chuẩn & Ý kiến nhận xét</th>
                                    <th scope="col" style="width: 10%;" class="text-center">Trọng số</th>
                                    <th scope="col" style="width: 15%;" class="text-center">Điểm số (0-10)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${detailItems}">
                                    <tr>
                                        <td><strong class="text-primary-emphasis">${item.criterionName}</strong></td>
                                        <td>
                                            <div class="text-muted small mb-2">${item.criterionDescription}</div>
                                            <div class="bg-light p-2 rounded text-dark small" style="border-left: 3px solid #63b3ed;">
                                                <em>Nhận xét:</em> ${not empty item.comment ? item.comment : 'Chưa có ý kiến nhận xét chi tiết.'}
                                            </div>
                                        </td>
                                        <td class="text-center fw-semibold text-secondary">${item.weight}%</td>
                                        <td class="text-center fw-bold text-dark fs-5">${item.score}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- General Comments -->
                    <div class="mb-4 p-3 rounded" style="background: #f8fafc; border: 1px solid #e2e8f0;">
                        <span class="fw-bold d-block mb-2 text-dark"><i class="fas fa-comment-dots text-primary me-2"></i>Ý kiến nhận xét chung của Quản lý:</span>
                        <p class="mb-0 text-secondary">
                            ${not empty detailEval.comment ? detailEval.comment : 'Không có nhận xét chung.'}
                        </p>
                    </div>

                    <!-- Approval History & Audit Logs -->
                    <div class="row g-4 mt-2">
                        <!-- Status history flow -->
                        <div class="col-md-6">
                            <h6 class="fw-bold mb-3"><i class="fas fa-history text-secondary me-2"></i>Lịch sử phê duyệt</h6>
                            <div class="list-group list-group-flush border rounded overflow-hidden" style="max-height: 250px; overflow-y: auto;">
                                <c:forEach var="h" items="${statusHistory}">
                                    <div class="list-group-item p-3">
                                        <div class="d-flex justify-content-between mb-1">
                                            <span class="fw-bold text-dark">${h.changedByName}</span>
                                            <span class="text-muted small"><fmt:formatDate value="${h.changedAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                        </div>
                                        <div class="small mb-1">
                                            Trạng thái: <span class="badge bg-light text-secondary border">${h.fromStatus}</span> &rarr; <span class="badge bg-primary-subtle text-primary border">${h.toStatus}</span>
                                        </div>
                                        <c:if test="${not empty h.note}">
                                            <div class="small text-secondary bg-light p-2 rounded mt-2 border-start border-danger">
                                                <strong>Ghi chú:</strong> ${h.note}
                                            </div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty statusHistory}">
                                    <div class="p-3 text-center text-muted small">Không tìm thấy lịch sử thay đổi trạng thái.</div>
                                </c:if>
                            </div>
                        </div>

                        <!-- Activity log traces -->
                        <div class="col-md-6">
                            <h6 class="fw-bold mb-3"><i class="fas fa-clipboard-list text-secondary me-2"></i>Nhật ký hoạt động (Audit Logs)</h6>
                            <div class="list-group list-group-flush border rounded overflow-hidden" style="max-height: 250px; overflow-y: auto;">
                                <c:forEach var="a" items="${auditLogs}">
                                    <div class="list-group-item p-3">
                                        <div class="d-flex justify-content-between mb-1">
                                            <span class="fw-semibold text-dark small">${a.changedByName}</span>
                                            <span class="text-muted small" style="font-size: 0.75rem;"><fmt:formatDate value="${a.changedAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                        </div>
                                        <div class="small">
                                            Thao tác: <code class="text-info-emphasis fw-bold">${a.action}</code>
                                        </div>
                                        <div style="font-size: 0.75rem;" class="text-muted text-truncate mt-1">
                                            Cũ: [${a.oldValue}] &rarr; Mới: [${a.newValue}]
                                        </div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty auditLogs}">
                                    <div class="p-3 text-center text-muted small">Không tìm thấy nhật ký hoạt động.</div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer border-0 px-4 pb-4">
                    <button type="button" class="btn btn-secondary px-4 py-2" data-bs-dismiss="modal" onclick="window.location.href = '${pageContext.request.contextPath}/manager/kpi-history?month=${selectedMonth}&year=${selectedYear}&departmentId=${selectedDeptId}'" style="border-radius: 8px;">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Script to auto trigger details modal -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var detailModalEl = document.getElementById('detailModal');
            if (detailModalEl) {
                var myModal = new bootstrap.Modal(detailModalEl);
                myModal.show();
            }
        });
    </script>
</c:if>

<%@include file="../footer.jsp"%>

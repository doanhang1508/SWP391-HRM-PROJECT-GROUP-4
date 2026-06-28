<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Phê duyệt KPI Nhân viên" />
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
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="kpi-approvals" />
    </jsp:include>

    <main class="page-main">
        <div class="container-fluid py-4">
    <!-- Title & Select Cycle -->
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
        <div>
            <h2 class="fw-bold mb-1">Phê duyệt Đánh giá KPI</h2>
            <p class="text-muted mb-0">Xét duyệt và thông qua các kết quả đánh giá KPI của nhân sự</p>
        </div>
        
        <div class="d-flex align-items-center gap-3">
            <form action="${pageContext.request.contextPath}/manager/kpi-approvals" method="GET" class="d-flex align-items-center gap-2">
                <label for="cycleSelect" class="text-nowrap fw-bold mb-0">Đợt đánh giá:</label>
                <select name="cycleId" id="cycleSelect" class="form-select px-3" style="border-radius: 8px; min-width: 250px;" onchange="this.form.submit()">
                    <option value="">-- Chọn đợt đánh giá --</option>
                    <c:forEach var="c" items="${cycles}">
                        <option value="${c.cycleId}" ${c.cycleId == selectedCycleId ? 'selected' : ''}>
                            ${c.name}
                        </option>
                    </c:forEach>
                </select>
            </form>
        </div>
    </div>

    <c:if test="${param.success == 'approved'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Đã phê duyệt đánh giá KPI thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'rejected'}">
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i> Đã từ chối và trả lại bản đánh giá KPI!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i> Có lỗi xảy ra trong quá trình phê duyệt hoặc từ chối.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Submitted Evaluations Table -->
    <div class="card border-0 shadow-sm" style="border-radius: 16px; background: var(--th-surface);">
        <div class="card-body p-4">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="approvalsTable">
                    <thead class="table-light">
                        <tr>
                            <th scope="col" style="width: 10%;">Mã NV</th>
                            <th scope="col" style="width: 18%;">Họ tên nhân viên</th>
                            <th scope="col" style="width: 14%;">Phòng ban</th>
                            <th scope="col" style="width: 16%;">Người đánh giá</th>
                            <th scope="col" style="width: 10%;" class="text-center">Điểm TB</th>
                            <th scope="col" style="width: 10%;" class="text-center">Điểm weighted</th>
                            <th scope="col" style="width: 10%;" class="text-center">Trạng thái</th>
                            <th scope="col" style="width: 12%;" class="text-center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="eval" items="${evaluations}">
                            <tr>
                                <td><code class="fw-bold">${eval.employeeCode}</code></td>
                                <td><strong class="text-primary-emphasis">${eval.employeeName}</strong></td>
                                <td><span class="text-muted small">${eval.departmentName}</span></td>
                                <td><span class="fw-semibold text-secondary">${eval.managerName}</span></td>
                                <td class="text-center fw-semibold">${eval.score}</td>
                                <td class="text-center fw-semibold text-success">${eval.weightedScore}</td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${eval.status == 'SUBMITTED'}">
                                            <span class="badge bg-warning-subtle text-warning px-3 py-2" style="border-radius: 8px;">Chờ duyệt</span>
                                        </c:when>
                                        <c:when test="${eval.status == 'APPROVED'}">
                                            <span class="badge bg-success-subtle text-success px-3 py-2" style="border-radius: 8px;">Đã duyệt</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger-subtle text-danger px-3 py-2" style="border-radius: 8px;">Bị từ chối</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${eval.status == 'SUBMITTED'}">
                                            <a href="${pageContext.request.contextPath}/manager/kpi-approvals?cycleId=${selectedCycleId}&viewId=${eval.evaluationId}" class="btn btn-warning btn-sm px-3 py-1.5 fw-bold" style="border-radius: 6px;">
                                                <i class="fas fa-check-double me-1"></i> Phê duyệt
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/manager/kpi-approvals?cycleId=${selectedCycleId}&viewId=${eval.evaluationId}" class="btn btn-outline-secondary btn-sm px-3 py-1.5" style="border-radius: 6px;">
                                                <i class="fas fa-eye me-1"></i> Chi tiết
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty evaluations}">
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="fas fa-clipboard-check fa-2x mb-2 opacity-50"></i>
                                    <p class="mb-0">Không có bản đánh giá nào cần phê duyệt trong chu kỳ này.</p>
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

<!-- Modal Approval details -->
<c:if test="${detailEval != null}">
    <div class="modal fade" id="approvalModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content border-0 shadow" style="border-radius: 20px; background: var(--th-surface);">
                <div class="modal-header border-0 px-4 pt-4">
                    <div>
                        <h4 class="modal-title fw-bold mb-1">
                            Phê duyệt KPI - ${detailEval.employeeName}
                        </h4>
                        <span class="text-muted small">Mã nhân viên: <code>${detailEval.employeeCode}</code> | Phòng: ${detailEval.departmentName}</span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="window.location.href='${pageContext.request.contextPath}/manager/kpi-approvals?cycleId=${selectedCycleId}'"></button>
                </div>
                
                <div class="modal-body px-4 pb-4">
                    <!-- Basic Stats Row -->
                    <div class="row g-3 mb-4">
                        <div class="col-sm-4">
                            <div class="p-3 border rounded text-center" style="background: var(--th-surface2);">
                                <span class="text-muted small d-block mb-1">Người đánh giá</span>
                                <strong class="text-dark">${detailEval.managerName}</strong>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="p-3 border rounded text-center" style="background: var(--th-surface2);">
                                <span class="text-muted small d-block mb-1">Điểm Trung bình</span>
                                <strong class="text-dark fs-5">${detailEval.score}</strong>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="p-3 border rounded text-center" style="background: var(--th-surface2);">
                                <span class="text-muted small d-block mb-1">Điểm Trọng số</span>
                                <strong class="text-success fs-5">${detailEval.weightedScore}</strong>
                            </div>
                        </div>
                    </div>

                    <!-- Criteria details table -->
                    <div class="table-responsive mb-4">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" style="width: 30%;">Tiêu chí</th>
                                    <th scope="col" style="width: 45%;">Mô tả tiêu chuẩn & Ý kiến quản lý</th>
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
                                            <div class="bg-light p-2 rounded text-dark small">
                                                <em>Nhận xét của Quản lý:</em> ${not empty item.comment ? item.comment : 'Chưa có nhận xét.'}
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
                    <div class="mb-4 p-3 border rounded" style="background: var(--th-surface2); border-radius: 10px;">
                        <span class="fw-bold d-block mb-2">Ý kiến, đánh giá chung của Quản lý trực tiếp:</span>
                        <p class="mb-0 text-secondary">
                            ${not empty detailEval.comment ? detailEval.comment : 'Không có nhận xét chung.'}
                        </p>
                    </div>

                    <!-- Reviewer Action Form -->
                    <c:choose>
                        <c:when test="${detailEval.status == 'SUBMITTED'}">
                            <form id="approvalForm" action="${pageContext.request.contextPath}/manager/kpi-approvals" method="POST" class="mb-4">
                                <input type="hidden" name="evaluationId" value="${detailEval.evaluationId}" />
                                <input type="hidden" id="approvalAction" name="action" value="" />
                                
                                <div class="mb-3">
                                    <label for="approvalNote" class="form-label fw-bold">Ghi chú phê duyệt / Lý do từ chối <span class="text-danger">*</span></label>
                                    <textarea class="form-control px-3 py-2" id="approvalNote" name="note" rows="3" placeholder="Nhập nhận xét phê duyệt hoặc lý do từ chối nếu không thông qua..." required style="border-radius: 10px;"></textarea>
                                    <div class="form-text text-muted">Lưu ý: Bắt buộc nhập khi từ chối đánh giá.</div>
                                </div>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <!-- View mode history & logs -->
                            <div class="row g-4 mt-2">
                                <div class="col-md-6">
                                    <h6 class="fw-bold mb-3"><i class="fas fa-history text-muted me-2"></i>Lịch sử phê duyệt</h6>
                                    <div class="list-group list-group-flush border rounded overflow-hidden" style="max-height: 200px; overflow-y: auto;">
                                        <c:forEach var="h" items="${statusHistory}">
                                            <div class="list-group-item p-3">
                                                <div class="d-flex justify-content-between mb-1">
                                                    <span class="fw-bold text-primary-emphasis">${h.changedByName}</span>
                                                    <span class="text-muted small"><fmt:formatDate value="${h.changedAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                                </div>
                                                <div class="small mb-1">
                                                    Thay đổi: <span class="badge bg-secondary">${h.oldStatus}</span> &rarr; <span class="badge bg-primary">${h.newStatus}</span>
                                                </div>
                                                <c:if test="${not empty h.note}">
                                                    <div class="small text-danger bg-danger-subtle p-1.5 rounded mt-1"><strong>Ghi chú:</strong> ${h.note}</div>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                        <c:if test="${empty statusHistory}">
                                            <div class="p-3 text-center text-muted small">Chưa có lịch sử phê duyệt</div>
                                        </c:if>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="fw-bold mb-3"><i class="fas fa-file-signature text-muted me-2"></i>Nhật ký hoạt động</h6>
                                    <div class="list-group list-group-flush border rounded overflow-hidden" style="max-height: 200px; overflow-y: auto;">
                                        <c:forEach var="a" items="${auditLogs}">
                                            <div class="list-group-item p-2.5">
                                                <div class="d-flex justify-content-between mb-0.5">
                                                    <span class="fw-medium text-dark small">${a.changedByName}</span>
                                                    <span class="text-muted small" style="font-size: 0.75rem;"><fmt:formatDate value="${a.changedAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                                </div>
                                                <div style="font-size: 0.78rem;">
                                                    Thao tác: <code class="text-info-emphasis">${a.action}</code>
                                                </div>
                                                <div style="font-size: 0.75rem;" class="text-muted text-truncate">
                                                    Cũ: [${a.oldValue}] &rarr; Mới: [${a.newValue}]
                                                </div>
                                            </div>
                                        </c:forEach>
                                        <c:if test="${empty auditLogs}">
                                            <div class="p-3 text-center text-muted small">Chưa có nhật ký hoạt động</div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                
                <div class="modal-footer border-0 px-4 pb-4">
                    <button type="button" class="btn btn-light px-4 py-2" data-bs-dismiss="modal" onclick="window.location.href='${pageContext.request.contextPath}/manager/kpi-approvals?cycleId=${selectedCycleId}'" style="border-radius: 8px;">Đóng</button>
                    
                    <c:if test="${detailEval.status == 'SUBMITTED'}">
                        <button type="button" id="btnReject" class="btn btn-outline-danger px-4 py-2" style="border-radius: 8px;">
                            <i class="fas fa-times me-1"></i> Từ chối duyệt
                        </button>
                        
                        <button type="button" id="btnApprove" class="btn btn-success px-4 py-2" style="border-radius: 8px;">
                            <i class="fas fa-check me-1"></i> Đồng ý phê duyệt
                        </button>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <!-- Trigger Modal & Control Form submission -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var myModal = new bootstrap.Modal(document.getElementById('approvalModal'));
            myModal.show();

            var btnApprove = document.getElementById('btnApprove');
            var btnReject = document.getElementById('btnReject');
            var approvalAction = document.getElementById('approvalAction');
            var approvalForm = document.getElementById('approvalForm');
            var approvalNote = document.getElementById('approvalNote');

            if (btnApprove && btnReject) {
                btnApprove.addEventListener('click', function() {
                    approvalAction.value = 'approve';
                    if (approvalNote.value.trim() === '') {
                        approvalNote.value = 'Đồng ý phê duyệt kết quả KPI.';
                    }
                    approvalForm.submit();
                });

                btnReject.addEventListener('click', function() {
                    approvalAction.value = 'reject';
                    if (approvalNote.value.trim() === '') {
                        alert('Vui lòng nhập lý do từ chối phê duyệt vào ô ghi chú!');
                        approvalNote.focus();
                        return;
                    }
                    approvalForm.submit();
                });
            }
        });
    </script>
</c:if>

<%@include file="../footer.jsp"%>

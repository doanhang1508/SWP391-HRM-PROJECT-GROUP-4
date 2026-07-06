<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="pageTitle" value="Đánh giá KPI Nhân viên" />
<%@include file="../header.jsp"%>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="employee-kpi" />
    </jsp:include>

    <main class="page-main">
        <div class="container-fluid py-4">
    <!-- Title & Select Cycle -->
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
        <div>
            <div class="d-flex align-items-center gap-2">
                <h2 class="fw-bold mb-1">Đánh giá KPI Nhân sự</h2>
                <c:if test="${selectedCycle.status == 'LOCKED' || selectedCycle.status == 'CLOSED'}">
                    <span class="badge bg-danger px-2.5 py-1.5" style="border-radius: 6px; font-size: 0.85rem;"><i class="fas fa-lock me-1"></i> ĐÃ KHÓA SỔ</span>
                </c:if>
            </div>
            <p class="text-muted mb-0">Chấm điểm hiệu suất làm việc của các thành viên trong bộ phận</p>
        </div>
        
        <div class="d-flex align-items-center gap-3">
            <form action="${pageContext.request.contextPath}/manager/employee-kpi" method="GET" class="d-flex align-items-center gap-2">
                <label for="cycleSelect" class="text-nowrap fw-bold mb-0">Đợt đánh giá:</label>
                <select name="cycleId" id="cycleSelect" class="form-select px-3" style="border-radius: 8px; min-width: 250px;" onchange="this.form.submit()">
                    <option value="">-- Chọn đợt đánh giá --</option>
                    <c:forEach var="c" items="${activeCycles}">
                        <option value="${c.cycleId}" ${c.cycleId == selectedCycleId ? 'selected' : ''}>
                            ${c.name}
                        </option>
                    </c:forEach>
                </select>
                <c:if test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 2 || sessionScope.currentUser.roleId == 4}">
                    <div class="form-check form-switch ms-3 mb-0 text-nowrap">
                        <input class="form-check-input" type="checkbox" name="viewAll" id="viewAllSwitch" value="true" <c:if test="${viewAll}">checked</c:if> onchange="this.form.submit()">
                        <label class="form-check-label fw-bold" for="viewAllSwitch">Xem toàn bộ công ty</label>
                    </div>
                </c:if>
            </form>
        </div>
    </div>

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
        /* Premium Spreadsheet Grid Styles */
        #evaluationsTable th {
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            vertical-align: middle;
            background: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }
        
        #evaluationsTable tbody tr {
            transition: all 0.2s ease;
        }
        
        /* Highlight missing evaluations */
        #evaluationsTable tbody tr.row-missing-eval {
            border-left: 4px solid var(--bs-warning) !important;
            background-color: rgba(255, 193, 7, 0.02) !important;
        }
        
        /* Focused and active cells */
        .grid-score-input, .grid-comment-input {
            border: 1px solid transparent;
            background: rgba(0, 0, 0, 0.02);
            transition: all 0.15s ease;
            font-size: 0.88rem;
        }
        
        .grid-score-input:hover, .grid-comment-input:hover {
            background: rgba(0, 0, 0, 0.04);
            border-color: #ced4da;
        }
        
        .grid-score-input:focus, .grid-comment-input:focus {
            background: #fff;
            border-color: var(--bs-primary);
            box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.15);
            outline: none;
        }
        
        /* Locked rows visual treatment */
        tr.row-locked {
            background: rgba(0, 0, 0, 0.01);
            opacity: 0.9;
        }
        
        tr.row-locked .grid-score-display {
            font-weight: 600;
            color: #495057;
        }

        /* Guide styling */
        .guide-box {
            background: linear-gradient(135deg, rgba(13, 110, 253, 0.05), rgba(13, 202, 240, 0.05));
            border: 1px solid rgba(13, 110, 253, 0.1);
            border-radius: 12px;
            padding: 15px;
            margin-bottom: 20px;
        }
    </style>

    <c:if test="${param.success == 'submitted'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Báo cáo KPI đã được nộp phê duyệt thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'bulk_submitted'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Đã nộp thành công ${param.count} bản đánh giá KPI cho phòng ban!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i> Có lỗi xảy ra trong quá trình xử lý dữ liệu.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty selectedCycleId || selectedCycleId <= 0}">
            <div class="card border-0 shadow-sm p-5 text-center" style="border-radius: 16px; background: var(--th-surface);">
                <i class="fas fa-clipboard-list fa-3x text-muted mb-3 opacity-40"></i>
                <h4 class="fw-bold mb-2">Chưa chọn đợt đánh giá KPI</h4>
                <p class="text-muted mb-0">Vui lòng chọn một đợt đánh giá ở danh sách phía trên để bắt đầu chấm điểm.</p>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Guide and Bulk actions -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-3">
                <div class="guide-box flex-grow-1 mb-0 py-2 px-3">
                    <div class="d-flex align-items-center gap-2 text-primary small fw-semibold">
                        <i class="fas fa-info-circle"></i>
                        <span>Bảng nhập điểm nhanh:</span>
                        <span class="text-muted fw-normal">Dùng phím mũi tên hoặc Enter/Tab để chuyển ô. Có thể copy ô điểm từ Excel rồi Ctrl+V. Hệ thống tự lưu nháp liên tục.</span>
                    </div>
                </div>
                
                <c:if test="${not empty evaluations}">
                    <c:set var="hasDraft" value="false" />
                    <c:forEach var="e" items="${evaluations}">
                        <c:if test="${e.status == 'DRAFT' || e.status == 'REJECTED'}">
                            <c:set var="hasDraft" value="true" />
                        </c:if>
                    </c:forEach>
                    <c:if test="${hasDraft && selectedCycle.status != 'LOCKED' && selectedCycle.status != 'CLOSED'}">
                        <form action="${pageContext.request.contextPath}/manager/employee-kpi" method="POST" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn nộp tất cả bản đánh giá KPI dạng Nháp/Từ chối của đợt này? Sau khi nộp sẽ không thể chỉnh sửa.')">
                            <input type="hidden" name="action" value="bulk-submit" />
                            <input type="hidden" name="cycleId" value="${selectedCycleId}" />
                            <button type="submit" class="btn btn-primary d-flex align-items-center gap-2 px-3 py-2 fw-semibold" style="border-radius: 8px;">
                                <i class="fas fa-paper-plane"></i> Nộp tất cả bản đánh giá
                            </button>
                        </form>
                    </c:if>
                </c:if>
            </div>

            <!-- Subordinates Evaluations Table -->
            <div class="card border-0 shadow-sm" style="border-radius: 16px; background: var(--th-surface);">
                <div class="card-body p-4">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" id="evaluationsTable" style="border-collapse: collapse;">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" style="width: 8%;">Mã NV</th>
                                    <th scope="col" style="width: 15%;">Họ tên nhân viên</th>
                                    <th scope="col" style="width: 10%;">Phòng ban</th>
                                    <!-- Dynamic headers for criteria -->
                                    <c:forEach var="crit" items="${criteria}">
                                        <th scope="col" class="text-center" style="width: 10%; cursor: help;" title="${crit.description}">
                                            ${crit.criterionName}
                                            <div class="small text-muted fw-normal" style="font-size: 0.72rem;">${crit.weight}%</div>
                                        </th>
                                    </c:forEach>
                                    <th scope="col" style="width: 18%;">Nhận xét chung</th>
                                    <th scope="col" style="width: 8%;" class="text-center">Điểm TB</th>
                                    <th scope="col" style="width: 8%;" class="text-center">Điểm TS</th>
                                    <th scope="col" style="width: 10%;" class="text-center">Trạng thái</th>
                                    <th scope="col" style="width: 13%;" class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="eval" items="${evaluations}" varStatus="rowStatus">
                                    <tr id="row-${eval.evaluationId}" 
                                        class="evaluation-row ${eval.status == 'SUBMITTED' || eval.status == 'APPROVED' ? 'row-locked' : ''}" 
                                        data-eval-id="${eval.evaluationId}" 
                                        data-row-idx="${rowStatus.index}"
                                        data-status="${eval.status}">
                                        <td><code class="fw-bold">${eval.employeeCode}</code></td>
                                        <td>
                                            <div class="fw-bold text-dark">${eval.employeeName}</div>
                                            <!-- Row status / autosave indicator -->
                                            <span class="autosave-row-indicator" id="autosave-indicator-${eval.evaluationId}"></span>
                                        </td>
                                        <td><span class="text-muted small">${eval.departmentName}</span></td>
                                        
                                        <!-- Criteria Columns -->
                                        <c:forEach var="crit" items="${criteria}" varStatus="colStatus">
                                            <c:set var="matchedItem" value="" />
                                            <c:forEach var="item" items="${eval.evaluationItems}">
                                                <c:if test="${item.templateItemId == crit.itemId}">
                                                    <c:set var="matchedItem" value="${item}" />
                                                </c:if>
                                            </c:forEach>
                                            
                                            <td class="text-center p-1">
                                                <c:choose>
                                                    <c:when test="${(eval.status == 'DRAFT' || eval.status == 'REJECTED') && selectedCycle.status != 'LOCKED' && selectedCycle.status != 'CLOSED'}">
                                                        <input type="number" 
                                                               name="score_${eval.evaluationId}_${crit.itemId}"
                                                               class="form-control text-center grid-score-input fw-semibold p-1 mb-1" 
                                                               style="width: 70px; margin: 0 auto; border-radius: 6px;"
                                                               min="0" max="10" step="0.1" 
                                                               value="${not empty matchedItem ? matchedItem.score : '0.0'}"
                                                               data-eval-id="${eval.evaluationId}"
                                                               data-crit-id="${crit.itemId}"
                                                               data-weight="${crit.weight}"
                                                               data-row-idx="${rowStatus.index}"
                                                               data-col-idx="${colStatus.index}" />
<!--                                                        <input type="text"
                                                               name="comment_${eval.evaluationId}_${crit.itemId}"
                                                               class="form-control text-center grid-item-comment-input p-0.5"
                                                               style="width: 76px; margin: 0 auto; border-radius: 4px; font-size: 0.65rem; min-height: 22px;"
                                                               placeholder="Ghi chú..."
                                                               value="${not empty matchedItem ? matchedItem.comment : ''}"
                                                               data-eval-id="${eval.evaluationId}"
                                                               data-crit-id="${crit.itemId}"
                                                               title="Nhận xét riêng cho tiêu chí ${crit.criterionName}" />-->
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="fw-semibold grid-score-display text-muted d-block" data-crit-id="${crit.itemId}">${not empty matchedItem ? matchedItem.score : '0.0'}</span>
                                                        <c:if test="${not empty matchedItem && not empty matchedItem.comment}">
                                                            <span class="text-muted d-block text-truncate small" style="font-size: 0.68rem; max-width: 76px; margin: 0 auto;" title="${matchedItem.comment}">${matchedItem.comment}</span>
                                                        </c:if>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </c:forEach>
                                        
                                        <!-- General Comment Column -->
                                        <td class="p-1">
                                            <c:choose>
                                                <c:when test="${(eval.status == 'DRAFT' || eval.status == 'REJECTED') && selectedCycle.status != 'LOCKED' && selectedCycle.status != 'CLOSED'}">
                                                    <input type="text" 
                                                           name="comment_${eval.evaluationId}"
                                                           class="form-control grid-comment-input small p-1" 
                                                           style="min-width: 150px; border-radius: 6px;"
                                                           placeholder="Nhận xét chung của quản lý..."
                                                           value="${eval.comment}"
                                                           data-eval-id="${eval.evaluationId}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="small text-muted grid-comment-display text-truncate d-inline-block" style="max-width: 180px;" title="${eval.comment}">${not empty eval.comment ? eval.comment : 'Chưa có nhận xét'}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        
                                        <!-- Summary columns -->
                                        <td class="text-center fw-semibold score-raw font-monospace" id="avg-score-${eval.evaluationId}">${eval.score}</td>
                                        <td class="text-center fw-bold text-success score-weighted font-monospace" id="weighted-score-${eval.evaluationId}">${eval.weightedScore}</td>
                                        
                                        <!-- Status badge -->
                                        <td class="text-center" id="status-badge-${eval.evaluationId}">
                                            <c:choose>
                                                <c:when test="${eval.status == 'DRAFT'}">
                                                    <span class="badge bg-warning-subtle text-warning px-2.5 py-1.5" style="border-radius: 6px;">Nháp</span>
                                                </c:when>
                                                <c:when test="${eval.status == 'SUBMITTED'}">
                                                    <span class="badge bg-primary-subtle text-primary px-2.5 py-1.5" style="border-radius: 6px;">Chờ duyệt</span>
                                                </c:when>
                                                <c:when test="${eval.status == 'APPROVED'}">
                                                    <span class="badge bg-success-subtle text-success px-2.5 py-1.5" style="border-radius: 6px;">Đã duyệt</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger-subtle text-danger px-2.5 py-1.5" style="border-radius: 6px;">Bị từ chối</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        
                                        <!-- Actions column -->
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-1">
                                                <c:choose>
                                                    <c:when test="${(eval.status == 'DRAFT' || eval.status == 'REJECTED') && selectedCycle.status != 'LOCKED' && selectedCycle.status != 'CLOSED'}">
                                                        <form action="${pageContext.request.contextPath}/manager/employee-kpi" method="POST" class="d-inline" onsubmit="return confirm('Bạn có chắc muốn nộp bản đánh giá KPI của nhân viên này? Sau khi nộp sẽ không thể chỉnh sửa.')">
                                                            <input type="hidden" name="action" value="submit" />
                                                            <input type="hidden" name="evaluationId" value="${eval.evaluationId}" />
                                                            <input type="hidden" name="note" value="Nộp báo cáo đánh giá KPI" />
                                                            <button type="submit" class="btn btn-primary btn-sm px-2 py-1" style="border-radius: 5px;" title="Nộp báo cáo">
                                                                <i class="fas fa-paper-plane"></i>
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                </c:choose>
                                                <!-- Detail View button to open modal for details, status history, audit logs -->
                                                <a href="${pageContext.request.contextPath}/manager/employee-kpi?cycleId=${selectedCycleId}&viewId=${eval.evaluationId}${viewAll ? '&viewAll=true' : ''}" 
                                                   class="btn btn-outline-secondary btn-sm px-2 py-1" 
                                                   style="border-radius: 5px;" 
                                                   title="Xem chi tiết & lịch sử">
                                                    <i class="fas fa-history"></i> Chi tiết
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty evaluations}">
                                    <tr>
                                        <td colspan="${fn:length(criteria) + 8}" class="text-center py-5 text-muted">
                                            <i class="fas fa-users-cog fa-2x mb-2 opacity-50"></i>
                                            <p class="mb-0">Không tìm thấy bản đánh giá nào trong chu kỳ này.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
        </div>
    </main>
</div>

<!-- Modal Evaluation Details / Edit -->
<c:if test="${detailEval != null}">
    <c:set var="redirectUrl" value="${pageContext.request.contextPath}/manager/employee-kpi?cycleId=${selectedCycleId}" />
    <c:if test="${viewAll}">
        <c:set var="redirectUrl" value="${redirectUrl}&viewAll=true" />
    </c:if>
    <div class="modal fade" id="evaluationModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content border-0 shadow" style="border-radius: 20px; background: var(--th-surface);">
                <div class="modal-header border-0 px-4 pt-4">
                    <div>
                        <h4 class="modal-title fw-bold mb-1">
                            ${isEditMode ? 'Chấm điểm KPI' : 'Chi tiết Đánh giá KPI'} - ${detailEval.employeeName}
                        </h4>
                        <span class="text-muted small">Mã nhân viên: <code>${detailEval.employeeCode}</code> | Phòng: ${detailEval.departmentName}</span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="window.location.href='${redirectUrl}'"></button>
                </div>
                
                <div class="modal-body px-4 pb-4">
                    <form id="evaluationForm">
                        <input type="hidden" name="evaluationId" id="evaluationId" value="${detailEval.evaluationId}" />
                        
                        <!-- Criteria table -->
                        <div class="table-responsive mb-4">
                            <table class="table align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th scope="col" style="width: 30%;">Tiêu chí</th>
                                        <th scope="col" style="width: 40%;">Mô tả tiêu chuẩn</th>
                                        <th scope="col" style="width: 10%;" class="text-center">Trọng số</th>
                                        <th scope="col" style="width: 10%;" class="text-center">Điểm (0-10)</th>
                                        <th scope="col" style="width: 10%;" class="text-center">Điểm weighted</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${detailItems}">
                                        <tr class="criterion-row">
                                            <input type="hidden" name="templateItemId" value="${item.templateItemId}" />
                                            <td><strong class="text-primary-emphasis">${item.criterionName}</strong></td>
                                            <td>
                                                <div class="text-muted small mb-2">${item.criterionDescription}</div>
                                                <c:choose>
                                                    <c:when test="${isEditMode}">
                                                        <input type="text" name="itemComment" class="form-control form-control-sm px-2" placeholder="Nhận xét riêng cho tiêu chí này..." value="${item.comment}" style="border-radius: 6px;" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="bg-light p-2 rounded text-dark small" style="min-height: 32px;">
                                                            <em>Nhận xét:</em> ${not empty item.comment ? item.comment : 'Chưa có nhận xét.'}
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center fw-medium text-secondary">
                                                <span class="item-weight">${item.weight}</span>%
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${isEditMode}">
                                                        <input type="number" name="score" class="form-control px-2 text-center item-score fw-bold" min="0" max="10" step="0.1" required value="${item.score}" style="border-radius: 8px; width: 80px; margin: 0 auto;" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="fw-bold text-dark item-score-val">${item.score}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center fw-semibold text-success item-weighted-score">0.0</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                                <tfoot>
                                    <tr class="table-light">
                                        <td colspan="2" class="fw-bold">TỔNG CỘNG / TRUNG BÌNH</td>
                                        <td class="text-center fw-bold">100%</td>
                                        <td class="text-center fw-bold text-dark" id="avgScore">0.0</td>
                                        <td class="text-center fw-bold text-success" id="weightedScore">0.0</td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <!-- General Manager Comments -->
                        <div class="mb-4">
                            <label for="generalComment" class="form-label fw-bold">Ý kiến, đánh giá chung của Quản lý</label>
                            <c:choose>
                                <c:when test="${isEditMode}">
                                    <textarea class="form-control px-3 py-2" id="generalComment" name="comment" rows="3" placeholder="Nhập các nhận xét, đề xuất khen thưởng hoặc đào tạo..." style="border-radius: 10px;">${detailEval.comment}</textarea>
                                </c:when>
                                <c:otherwise>
                                    <div class="p-3 border rounded" style="background: var(--th-surface2); border-radius: 10px;">
                                        ${not empty detailEval.comment ? detailEval.comment : 'Chưa có ý kiến chung.'}
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </form>
                    
                    <!-- Audit Logs / Status History for View Mode -->
                    <c:if test="${not isEditMode}">
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
                                                Thay đổi: <span class="badge bg-secondary">${h.fromStatus}</span> &rarr; <span class="badge bg-primary">${h.toStatus}</span>
                                            </div>
                                            <c:if test="${not empty h.note}">
                                                <div class="small text-danger bg-danger-subtle p-1.5 rounded mt-1"><strong>Lý do:</strong> ${h.note}</div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${empty statusHistory}">
                                        <div class="p-3 text-center text-muted small">Chưa có lịch sử trạng thái</div>
                                    </c:if>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <h6 class="fw-bold mb-3"><i class="fas fa-file-signature text-muted me-2"></i>Nhật ký chỉnh sửa (Audit Log)</h6>
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
                    </c:if>

                    <!-- Comments Section -->
                    <div class="card border-0 shadow-sm mt-4" style="background: var(--th-surface1); border-radius: 12px;">
                        <div class="card-header bg-transparent border-0 pt-4 px-4 d-flex align-items-center">
                            <h5 class="fw-bold mb-0 text-primary-emphasis"><i class="fas fa-comments me-2"></i>Trao đổi & Phản hồi</h5>
                        </div>
                        <div class="card-body px-4 pb-4">
                            <!-- Comment stream -->
                            <div class="comment-stream mb-3 p-3 rounded" style="background: var(--th-surface2); max-height: 250px; overflow-y: auto; display: flex; flex-direction: column; gap: 1rem;">
                                <c:forEach var="c" items="${comments}">
                                    <div class="comment-bubble d-flex flex-column p-2.5 rounded-3 ${c.userId == currentUser.userId ? 'align-self-end bg-primary text-white' : 'align-self-start bg-light text-dark'}" style="max-width: 85%; box-shadow: 0 2px 4px rgba(0,0,0,0.05); min-width: 250px;">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <span class="fw-bold small ${c.userId == currentUser.userId ? 'text-white-50' : 'text-primary'}">${c.userName}</span>
                                            <span class="badge ${c.type == 'EMPLOYEE' ? 'bg-info text-dark' : c.type == 'MANAGER' ? 'bg-warning text-dark' : 'bg-secondary text-white'}" style="font-size: 0.62rem;">
                                                <c:choose>
                                                    <c:when test="${c.type == 'EMPLOYEE'}">Nhân viên</c:when>
                                                    <c:when test="${c.type == 'MANAGER'}">Quản lý</c:when>
                                                    <c:otherwise>${c.type}</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="comment-text fw-medium" style="word-break: break-word; font-size: 0.85rem;">${c.commentText}</div>
                                        <div class="align-self-end text-end mt-1 text-muted" style="font-size: 0.62rem; ${c.userId == currentUser.userId ? 'color: rgba(255,255,255,0.7) !important;' : ''}">
                                            <fmt:formatDate value="${c.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                        </div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty comments}">
                                    <div class="text-center text-muted my-3 small">Chưa có bình luận nào cho bản đánh giá này.</div>
                                </c:if>
                            </div>

                            <!-- Comment Form -->
                            <c:choose>
                                <c:when test="${detailEval.cycleStatus == 'LOCKED' || detailEval.cycleStatus == 'CLOSED'}">
                                    <div class="alert alert-warning mb-0 text-center py-2 px-3 small" style="border-radius: 8px;">
                                        <i class="fas fa-lock me-1"></i> Đợt đánh giá này đã khóa sổ (LOCKED). Không thể gửi thêm ý kiến trao đổi.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/manager/employee-kpi" method="POST" class="mt-2">
                                        <input type="hidden" name="action" value="addComment" />
                                        <input type="hidden" name="evaluationId" value="${detailEval.evaluationId}" />
                                        <input type="hidden" name="viewAll" value="${param.viewAll}" />
                                        <div class="input-group">
                                            <textarea class="form-control" name="commentText" placeholder="Nhập phản hồi, câu hỏi hoặc hướng dẫn..." rows="2" style="border-radius: 8px 0 0 8px; resize: none; font-size: 0.85rem;" required></textarea>
                                            <button class="btn btn-primary px-4" type="submit" style="border-radius: 0 8px 8px 0;">
                                                <i class="fas fa-paper-plane me-1"></i> Gửi
                                            </button>
                                        </div>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                
                <div class="modal-footer border-0 px-4 pb-4">
                    <span id="saveStatus" class="me-auto text-success fw-bold small"></span>
                    
                    <button type="button" class="btn btn-light px-4 py-2" data-bs-dismiss="modal" onclick="window.location.href='${redirectUrl}'" style="border-radius: 8px;">Đóng</button>
                    
                    <c:if test="${isEditMode}">
                        <button type="button" id="btnAutosave" class="btn btn-outline-success px-4 py-2" style="border-radius: 8px;">
                            <i class="fas fa-save me-1"></i> Lưu tạm
                        </button>
                        
                        <form action="${pageContext.request.contextPath}/manager/employee-kpi" method="POST" class="d-inline" id="submitKpiForm">
                            <input type="hidden" name="action" value="submit" />
                            <input type="hidden" name="evaluationId" value="${detailEval.evaluationId}" />
                            <input type="hidden" name="note" value="Nộp báo cáo đánh giá KPI" />
                            <button type="button" id="btnSubmitKpi" class="btn btn-primary px-4 py-2" style="border-radius: 8px;">
                                <i class="fas fa-paper-plane me-1"></i> Nộp báo cáo
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <!-- Live calculation & AJAX Autosave Logic -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var myModal = new bootstrap.Modal(document.getElementById('evaluationModal'));
            myModal.show();

            var isEditMode = ${isEditMode};

            function calculateTotals() {
                var totalWeight = 0;
                var totalWeightedScore = 0;
                var totalRawScore = 0;
                var count = 0;

                var rows = document.querySelectorAll('.criterion-row');
                rows.forEach(function(row) {
                    var weight = parseFloat(row.querySelector('.item-weight').textContent) || 0;
                    var score = 0;
                    
                    if (isEditMode) {
                        score = parseFloat(row.querySelector('.item-score').value) || 0;
                    } else {
                        score = parseFloat(row.querySelector('.item-score-val').textContent) || 0;
                    }

                    var itemWeighted = (score * weight) / 100.0;
                    row.querySelector('.item-weighted-score').textContent = itemWeighted.toFixed(2);

                    totalWeight += weight;
                    totalWeightedScore += score * weight;
                    totalRawScore += score;
                    count++;
                });

                var avg = count > 0 ? (totalRawScore / count) : 0.0;
                var finalWeighted = totalWeight > 0 ? (totalWeightedScore / 100.0) : 0.0;

                document.getElementById('avgScore').textContent = avg.toFixed(2);
                document.getElementById('weightedScore').textContent = finalWeighted.toFixed(2);
            }

            // Bind input change listeners for dynamic recalculation
            if (isEditMode) {
                document.querySelectorAll('.item-score').forEach(function(input) {
                    input.addEventListener('input', function() {
                        calculateTotals();
                    });
                });

                // AJAX Autosave implementation
                var btnAutosave = document.getElementById('btnAutosave');
                btnAutosave.addEventListener('click', function() {
                    btnAutosave.disabled = true;
                    btnAutosave.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Đang lưu...';
                    
                    var formData = new URLSearchParams();
                    formData.append('action', 'autosave');
                    formData.append('evaluationId', document.getElementById('evaluationId').value);
                    formData.append('comment', document.getElementById('generalComment').value);

                    var rows = document.querySelectorAll('.criterion-row');
                    rows.forEach(function(row) {
                        formData.append('templateItemId', row.querySelector('input[name="templateItemId"]').value);
                        formData.append('score', row.querySelector('.item-score').value);
                        formData.append('itemComment', row.querySelector('input[name="itemComment"]').value);
                    });

                    fetch('${pageContext.request.contextPath}/manager/employee-kpi', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                        },
                        body: formData.toString()
                    })
                    .then(response => response.json())
                    .then(data => {
                        btnAutosave.disabled = false;
                        btnAutosave.innerHTML = '<i class="fas fa-save me-1"></i> Lưu tạm';
                        
                        if (data.status === 'success') {
                            var statusText = document.getElementById('saveStatus');
                            statusText.innerHTML = '✓ Đã lưu nháp thành công lúc ' + new Date().toLocaleTimeString();
                            
                            // Update values in the main table row
                            var evalId = document.getElementById('evaluationId').value;
                            var mainRow = document.getElementById('row-' + evalId);
                            if (mainRow) {
                                mainRow.querySelector('.score-raw').textContent = data.score.toFixed(2);
                                mainRow.querySelector('.score-weighted').textContent = data.weightedScore.toFixed(2);
                            }
                            
                            setTimeout(function() {
                                statusText.innerHTML = '';
                            }, 3000);
                        } else {
                            alert('Lỗi: ' + data.message);
                        }
                    })
                    .catch(error => {
                        btnAutosave.disabled = false;
                        btnAutosave.innerHTML = '<i class="fas fa-save me-1"></i> Lưu tạm';
                        alert('Không thể kết nối đến máy chủ.');
                    });
                });

                // Submit confirmation
                var btnSubmit = document.getElementById('btnSubmitKpi');
                btnSubmit.addEventListener('click', function() {
                    if (confirm('Bạn có chắc chắn muốn nộp báo cáo KPI này không? Sau khi nộp sẽ không thể chỉnh sửa điểm.')) {
                        // First autosave, then submit
                        var saveStatus = document.getElementById('saveStatus');
                        saveStatus.innerHTML = 'Đang lưu trước khi nộp...';
                        
                        var formData = new URLSearchParams();
                        formData.append('action', 'autosave');
                        formData.append('evaluationId', document.getElementById('evaluationId').value);
                        formData.append('comment', document.getElementById('generalComment').value);

                        var rows = document.querySelectorAll('.criterion-row');
                        rows.forEach(function(row) {
                            formData.append('templateItemId', row.querySelector('input[name="templateItemId"]').value);
                            formData.append('score', row.querySelector('.item-score').value);
                            formData.append('itemComment', row.querySelector('input[name="itemComment"]').value);
                        });

                        fetch('${pageContext.request.contextPath}/manager/employee-kpi', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                            },
                            body: formData.toString()
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.status === 'success') {
                                document.getElementById('submitKpiForm').submit();
                            } else {
                                alert('Lỗi: ' + data.message);
                            }
                        })
                        .catch(error => {
                            alert('Không thể kết nối lưu trữ.');
                        });
                    }
                });
            }

            // Initial calculation
            calculateTotals();
        });
    </script>
    </c:if>

    <!-- Spreadsheet Grid Interactive Handlers -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // If there's a detail modal, show it
            const modalEl = document.getElementById('evaluationModal');
            if (modalEl) {
                var myModal = new bootstrap.Modal(modalEl);
                myModal.show();
            }

            // Keyboard navigation setup
            setupKeyboardNavigation();

            // Excel Paste setup
            setupExcelPaste();

            // Initialize change/input listeners for score & comment inputs on the grid
            setupGridChangeListeners();

            // Initial highlight for all rows on load
            document.querySelectorAll('.evaluation-row').forEach(row => {
                highlightMissing(row);
            });
        });

        // 1. Debounce and save queue
        const saveDebounces = {};
        function queueSaveRow(evalId) {
            if (saveDebounces[evalId]) {
                clearTimeout(saveDebounces[evalId]);
            }
            
            const indicator = document.getElementById('autosave-indicator-' + evalId);
            if (indicator) {
                indicator.innerHTML = '<span class="text-warning fw-normal ms-2" style="font-size:0.75rem;">Chờ lưu...</span>';
            }
            
            saveDebounces[evalId] = setTimeout(() => {
                saveRow(evalId);
            }, 1000);
        }

        // 2. Perform AJAX save
        function saveRow(evalId) {
            const row = document.getElementById('row-' + evalId);
            if (!row) return;

            const indicator = document.getElementById('autosave-indicator-' + evalId);
            if (indicator) {
                indicator.innerHTML = '<span class="spinner-border spinner-border-sm text-primary ms-2" role="status" aria-hidden="true"></span>';
            }

            const formData = new URLSearchParams();
            formData.append('action', 'autosave');
            formData.append('evaluationId', evalId);

            // Get general comment input
            const commentInput = row.querySelector('.grid-comment-input');
            formData.append('comment', commentInput ? commentInput.value : '');

            // Get all score inputs in this row
            const scoreInputs = row.querySelectorAll('.grid-score-input');
            let hasError = false;
            scoreInputs.forEach(input => {
                if (!validateScoreInput(input)) {
                    hasError = true;
                }
                const critId = input.getAttribute('data-crit-id');
                const commentInput = row.querySelector(`input[name="comment_${evalId}_${critId}"]`);
                const itemCommentVal = commentInput ? commentInput.value : '';

                formData.append('templateItemId', critId);
                formData.append('score', input.value || '0.0');
                formData.append('itemComment', itemCommentVal);
            });

            if (hasError) {
                if (indicator) {
                    indicator.innerHTML = '<span class="text-danger fw-semibold ms-2" style="font-size:0.75rem;">Lỗi điểm số (0-10)</span>';
                }
                return;
            }

            fetch('${pageContext.request.contextPath}/manager/employee-kpi', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                },
                body: formData.toString()
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    if (indicator) {
                        indicator.innerHTML = '<span class="text-success ms-2" title="Đã tự động lưu nháp"><i class="fas fa-check-circle"></i> Đã lưu</span>';
                        setTimeout(() => {
                            if (indicator.innerHTML.includes('fa-check-circle')) {
                                indicator.innerHTML = '';
                            }
                        }, 2500);
                    }
                    // Update displayed average and weighted score
                    const avgSpan = document.getElementById('avg-score-' + evalId);
                    const wSpan = document.getElementById('weighted-score-' + evalId);
                    if (avgSpan) avgSpan.textContent = data.score.toFixed(2);
                    if (wSpan) wSpan.textContent = data.weightedScore.toFixed(2);
                    
                    highlightMissing(row);
                } else {
                    if (indicator) {
                        indicator.innerHTML = '<span class="text-danger fw-semibold ms-2" style="font-size:0.75rem;"><i class="fas fa-exclamation-circle"></i> Lỗi: ' + data.message + '</span>';
                    }
                }
            })
            .catch(error => {
                if (indicator) {
                    indicator.innerHTML = '<span class="text-danger fw-semibold ms-2" style="font-size:0.75rem;"><i class="fas fa-exclamation-circle"></i> Lỗi mạng</span>';
                }
            });
        }

        // 3. Grid Change Listeners
        function setupGridChangeListeners() {
            const table = document.getElementById('evaluationsTable');
            if (!table) return;

            // Score inputs
            table.querySelectorAll('.grid-score-input').forEach(input => {
                const evalId = input.getAttribute('data-eval-id');
                
                input.addEventListener('input', function() {
                    validateScoreInput(input);
                    calculateRowTotals(evalId);
                    queueSaveRow(evalId);
                });
                
                input.addEventListener('blur', function() {
                    validateScoreInput(input);
                    // Force instant save on blur
                    if (saveDebounces[evalId]) {
                        clearTimeout(saveDebounces[evalId]);
                    }
                    saveRow(evalId);
                });
            });

            // Comment inputs
            table.querySelectorAll('.grid-comment-input').forEach(input => {
                const evalId = input.getAttribute('data-eval-id');
                
                input.addEventListener('input', function() {
                    queueSaveRow(evalId);
                });
                
                input.addEventListener('blur', function() {
                    // Force instant save on blur
                    if (saveDebounces[evalId]) {
                        clearTimeout(saveDebounces[evalId]);
                    }
                    saveRow(evalId);
                });
            });

            // Item Comment inputs
            table.querySelectorAll('.grid-item-comment-input').forEach(input => {
                const evalId = input.getAttribute('data-eval-id');
                
                input.addEventListener('input', function() {
                    queueSaveRow(evalId);
                });
                
                input.addEventListener('blur', function() {
                    // Force instant save on blur
                    if (saveDebounces[evalId]) {
                        clearTimeout(saveDebounces[evalId]);
                    }
                    saveRow(evalId);
                });
            });
        }

        // 4. Validate score input
        function validateScoreInput(input) {
            const val = parseFloat(input.value);
            if (isNaN(val) || val < 0 || val > 10) {
                input.classList.add('is-invalid');
                return false;
            } else {
                input.classList.remove('is-invalid');
                return true;
            }
        }

        // 5. Calculate totals client-side
        function calculateRowTotals(evalId) {
            const row = document.getElementById('row-' + evalId);
            if (!row) return;

            let totalWeight = 0;
            let totalWeightedScore = 0;
            let totalRawScore = 0;
            let count = 0;

            const scoreInputs = row.querySelectorAll('.grid-score-input');
            scoreInputs.forEach(input => {
                const weight = parseFloat(input.getAttribute('data-weight')) || 0;
                const score = parseFloat(input.value) || 0;
                
                totalWeight += weight;
                totalWeightedScore += score * weight;
                totalRawScore += score;
                count++;
            });

            const avg = count > 0 ? (totalRawScore / count) : 0.0;
            const finalWeighted = totalWeight > 0 ? (totalWeightedScore / 100.0) : 0.0;

            const avgSpan = document.getElementById('avg-score-' + evalId);
            const wSpan = document.getElementById('weighted-score-' + evalId);
            if (avgSpan) avgSpan.textContent = avg.toFixed(2);
            if (wSpan) wSpan.textContent = finalWeighted.toFixed(2);
            
            highlightMissing(row);
        }

        // 6. Highlight missing rows
        function highlightMissing(row) {
            const status = row.getAttribute('data-status');
            if (status !== 'DRAFT' && status !== 'REJECTED') {
                row.classList.remove('row-missing-eval');
                return;
            }
            
            let isMissing = false;
            const inputs = row.querySelectorAll('.grid-score-input');
            inputs.forEach(input => {
                const val = parseFloat(input.value) || 0;
                if (val === 0) {
                    isMissing = true;
                }
            });
            
            if (isMissing) {
                row.classList.add('row-missing-eval');
            } else {
                row.classList.remove('row-missing-eval');
            }
        }

        // 7. Keyboard navigation
        function setupKeyboardNavigation() {
            const table = document.getElementById('evaluationsTable');
            if (!table) return;

            table.addEventListener('keydown', function(e) {
                const target = e.target;
                if (!target.classList.contains('grid-score-input') && !target.classList.contains('grid-comment-input')) {
                    return;
                }

                const isScore = target.classList.contains('grid-score-input');
                const row = target.closest('tr');
                const rowIdx = parseInt(row.getAttribute('data-row-idx'));

                let nextInput = null;

                if (e.key === 'ArrowDown' || (e.key === 'Enter' && !e.shiftKey)) {
                    e.preventDefault();
                    const nextRow = table.querySelector('tr[data-row-idx="' + (rowIdx + 1) + '"]');
                    if (nextRow) {
                        if (isScore) {
                            const critId = target.getAttribute('data-crit-id');
                            nextInput = nextRow.querySelector('.grid-score-input[data-crit-id="' + critId + '"]');
                        } else {
                            nextInput = nextRow.querySelector('.grid-comment-input');
                        }
                    }
                } else if (e.key === 'ArrowUp' || (e.key === 'Enter' && e.shiftKey)) {
                    e.preventDefault();
                    const prevRow = table.querySelector('tr[data-row-idx="' + (rowIdx - 1) + '"]');
                    if (prevRow) {
                        if (isScore) {
                            const critId = target.getAttribute('data-crit-id');
                            nextInput = prevRow.querySelector('.grid-score-input[data-crit-id="' + critId + '"]');
                        } else {
                            nextInput = prevRow.querySelector('.grid-comment-input');
                        }
                    }
                } else if (e.key === 'ArrowRight' && isScore) {
                    const colIdx = parseInt(target.getAttribute('data-col-idx'));
                    nextInput = row.querySelector('.grid-score-input[data-col-idx="' + (colIdx + 1) + '"]');
                    if (!nextInput) {
                        nextInput = row.querySelector('.grid-comment-input');
                    }
                } else if (e.key === 'ArrowLeft') {
                    if (isScore) {
                        const colIdx = parseInt(target.getAttribute('data-col-idx'));
                        nextInput = row.querySelector('.grid-score-input[data-col-idx="' + (colIdx - 1) + '"]');
                    } else {
                        const scoreInputs = row.querySelectorAll('.grid-score-input');
                        if (scoreInputs.length > 0) {
                            nextInput = scoreInputs[scoreInputs.length - 1];
                        }
                    }
                }

                if (nextInput) {
                    nextInput.focus();
                    if (nextInput.select) {
                        nextInput.select();
                    }
                }
            });
        }

        // 8. Excel Paste
        function setupExcelPaste() {
            const table = document.getElementById('evaluationsTable');
            if (!table) return;

            table.addEventListener('paste', function(e) {
                const target = e.target;
                if (!target.classList.contains('grid-score-input')) {
                    return;
                }

                const clipboardData = e.clipboardData || window.clipboardData;
                if (!clipboardData) return;

                const pastedText = clipboardData.getData('text');
                if (!pastedText) return;

                const rowsData = pastedText.split(/\r?\n/).map(row => row.split('\t'));
                if (rowsData.length > 1 && rowsData[rowsData.length - 1].length === 1 && rowsData[rowsData.length - 1][0] === '') {
                    rowsData.pop();
                }

                if (rowsData.length === 0) return;

                e.preventDefault();

                const startRowIdx = parseInt(target.closest('tr').getAttribute('data-row-idx'));
                const startColIdx = parseInt(target.getAttribute('data-col-idx'));

                const affectedEvalIds = new Set();

                rowsData.forEach((rowCells, rOffset) => {
                    const targetRowIdx = startRowIdx + rOffset;
                    const targetRow = table.querySelector('tr[data-row-idx="' + targetRowIdx + '"]');
                    if (!targetRow) return;

                    const evalId = targetRow.getAttribute('data-eval-id');
                    const status = targetRow.getAttribute('data-status');
                    
                    if (status !== 'DRAFT' && status !== 'REJECTED') return;

                    rowCells.forEach((cellVal, cOffset) => {
                        const targetColIdx = startColIdx + cOffset;
                        const scoreInput = targetRow.querySelector('.grid-score-input[data-col-idx="' + targetColIdx + '"]');
                        if (scoreInput) {
                            let cleanedVal = cellVal.trim().replace(',', '.');
                            let score = parseFloat(cleanedVal);
                            if (!isNaN(score)) {
                                score = Math.max(0, Math.min(10, score));
                                scoreInput.value = score.toFixed(1);
                                affectedEvalIds.add(evalId);
                            }
                        }
                    });
                });

                affectedEvalIds.forEach(evalId => {
                    calculateRowTotals(evalId);
                    queueSaveRow(evalId);
                });
            });
        }
    </script>
<%@include file="../footer.jsp"%>

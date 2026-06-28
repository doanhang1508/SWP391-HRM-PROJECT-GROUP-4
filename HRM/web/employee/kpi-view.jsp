<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Lịch sử đánh giá KPI của tôi" />
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
        <jsp:param name="activeMenu" value="employee-kpi-view" />
    </jsp:include>

    <main class="page-main">
        <div class="container-fluid py-4">
    <div class="row g-4">
        <!-- Left Side: List of My Evaluations -->
        <div class="col-lg-5">
            <div class="mb-4">
                <h3 class="fw-bold mb-1">KPI của tôi</h3>
                <p class="text-muted mb-0">Theo dõi điểm hiệu suất và ý kiến phản hồi qua các đợt đánh giá</p>
            </div>

            <div class="card border-0 shadow-sm" style="border-radius: 16px; background: var(--th-surface);">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-3"><i class="fas fa-list-ul me-2 text-secondary"></i>Các đợt đánh giá</h5>
                    <div class="list-group list-group-flush gap-2">
                        <c:forEach var="eval" items="${evaluations}">
                            <a href="${pageContext.request.contextPath}/employee/kpi-view?id=${eval.evaluationId}" 
                               class="list-group-item list-group-item-action p-3 border rounded-3 d-flex flex-column gap-2 transition-all ${eval.evaluationId == selectedEval.evaluationId ? 'border-primary bg-primary-subtle' : 'border-light'}" 
                               style="border-radius: 12px !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="fw-bold text-dark text-truncate" style="max-width: 70%;">${eval.cycleName}</span>
                                    <c:choose>
                                        <c:when test="${eval.status == 'SUBMITTED'}">
                                            <span class="badge bg-warning-subtle text-warning px-2.5 py-1.5" style="font-size: 0.72rem; border-radius: 6px;">Chờ duyệt</span>
                                        </c:when>
                                        <c:when test="${eval.status == 'APPROVED'}">
                                            <span class="badge bg-success-subtle text-success px-2.5 py-1.5" style="font-size: 0.72rem; border-radius: 6px;">Đã duyệt</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger-subtle text-danger px-2.5 py-1.5" style="font-size: 0.72rem; border-radius: 6px;">Bị từ chối</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="d-flex justify-content-between align-items-center mt-1">
                                    <span class="text-muted small"><i class="fas fa-user-tie me-1"></i> Quản lý: ${eval.managerName}</span>
                                    <div class="fw-bold text-dark-emphasis">
                                        Điểm: <span class="text-primary">${eval.weightedScore}</span>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                        <c:if test="${empty evaluations}">
                            <div class="text-center py-5 text-muted">
                                <i class="fas fa-history fa-2x mb-2 opacity-50"></i>
                                <p class="mb-0">Chưa có bản đánh giá nào được công bố cho bạn.</p>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Side: Selected Evaluation Details -->
        <div class="col-lg-7">
            <c:choose>
                <c:when test="${selectedEval != null}">
                    <div class="card border-0 shadow-sm mb-4" style="border-radius: 16px; background: var(--th-surface);">
                        <div class="card-header border-0 bg-transparent px-4 pt-4 pb-0 d-flex justify-content-between align-items-center">
                            <div>
                                <h4 class="fw-bold text-dark mb-1">${selectedEval.cycleName}</h4>
                                <span class="text-muted small">Người đánh giá trực tiếp: <strong>${selectedEval.managerName}</strong></span>
                            </div>
                            <div class="text-end">
                                <span class="text-muted small d-block mb-1">Tổng điểm Trọng số</span>
                                <span class="fs-3 fw-bold text-success">${selectedEval.weightedScore}</span>
                            </div>
                        </div>

                        <div class="card-body p-4">
                            <!-- Ratings Table -->
                            <h6 class="fw-bold mb-3"><i class="fas fa-tasks text-muted me-2"></i>Điểm số chi tiết từng tiêu chí</h6>
                            <div class="table-responsive mb-4">
                                <table class="table align-middle table-sm border-light">
                                    <thead class="table-light">
                                        <tr>
                                            <th scope="col" style="width: 35%;">Tiêu chí</th>
                                            <th scope="col" style="width: 45%;">Nhận xét của quản lý</th>
                                            <th scope="col" style="width: 10%;" class="text-center">Trọng số</th>
                                            <th scope="col" style="width: 10%;" class="text-center">Điểm số</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${items}">
                                            <tr>
                                                <td>
                                                    <strong class="text-primary-emphasis d-block" style="font-size: 0.9rem;">${item.criterionName}</strong>
                                                    <span class="text-muted small" style="font-size: 0.75rem;">${item.criterionDescription}</span>
                                                </td>
                                                <td>
                                                    <div class="p-2 rounded bg-light small" style="min-height: 36px; font-size: 0.8rem;">
                                                        ${not empty item.comment ? item.comment : '<em>Không có nhận xét.</em>'}
                                                    </div>
                                                </td>
                                                <td class="text-center text-muted small">${item.weight}%</td>
                                                <td class="text-center fw-bold text-dark fs-6">${item.score}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <!-- General comment -->
                            <div class="p-3 rounded border mb-4" style="background: var(--th-surface2); border-radius: 10px;">
                                <strong class="d-block mb-1 small text-dark"><i class="far fa-comment-dots me-1"></i> Nhận xét chung của Quản lý:</strong>
                                <p class="mb-0 small text-secondary" style="line-height: 1.5;">
                                    ${not empty selectedEval.comment ? selectedEval.comment : 'Không có nhận xét chung.'}
                                </p>
                            </div>

                            <hr class="my-4 text-muted opacity-25">

                            <!-- Feedback/Appeal Discussion thread -->
                            <h5 class="fw-bold mb-3"><i class="far fa-comments text-muted me-2"></i>Trao đổi & Phản hồi</h5>
                            
                            <div class="d-flex flex-column gap-3 mb-4 p-3 border rounded-3" style="background: var(--th-surface2); max-height: 300px; overflow-y: auto;">
                                <c:forEach var="cmt" items="${comments}">
                                    <div class="d-flex flex-column p-2.5 rounded-3 ${cmt.userId == sessionScope.currentUser.userId ? 'align-self-end bg-primary-subtle border border-primary-subtle text-end' : 'align-self-start bg-light border border-light text-start'}" style="max-width: 85%; min-width: 50%;">
                                        <div class="d-flex justify-content-between align-items-center gap-4 mb-1 small">
                                            <span class="fw-bold text-dark-emphasis">${cmt.userId == sessionScope.currentUser.userId ? 'Tôi' : cmt.userName}</span>
                                            <span class="text-muted" style="font-size: 0.7rem;"><fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                        </div>
                                        <div class="text-dark small" style="white-space: pre-line;">${cmt.commentText}</div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty comments}">
                                    <div class="text-center py-4 text-muted small">
                                        <i class="far fa-comment-alt fa-2x mb-2 opacity-25"></i>
                                        <p class="mb-0">Chưa có phản hồi nào. Bạn có thể gửi ý kiến phản hồi hoặc thắc mắc về kết quả KPI tại đây.</p>
                                    </div>
                                </c:if>
                            </div>

                            <!-- Comment Input Form -->
                            <form action="${pageContext.request.contextPath}/employee/kpi-view" method="POST" class="d-flex flex-column gap-2">
                                <input type="hidden" name="action" value="addComment" />
                                <input type="hidden" name="evaluationId" value="${selectedEval.evaluationId}" />
                                
                                <div class="form-group">
                                    <textarea class="form-control px-3 py-2" name="commentText" rows="2" placeholder="Gõ ý kiến đóng góp hoặc thắc mắc của bạn..." style="border-radius: 8px;" required></textarea>
                                </div>
                                <div class="text-end">
                                    <button type="submit" class="btn btn-primary px-4 py-2" style="border-radius: 8px;">
                                        Gửi phản hồi <i class="fas fa-paper-plane ms-1"></i>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card border-0 shadow-sm py-5 text-center" style="border-radius: 16px; background: var(--th-surface);">
                        <div class="card-body">
                            <i class="fas fa-info-circle fa-3x text-muted mb-3 opacity-25"></i>
                            <h5 class="fw-bold text-secondary">Chọn đợt đánh giá</h5>
                            <p class="text-muted px-4">Hãy chọn một đợt đánh giá ở danh sách bên trái để xem kết quả chi tiết, nhận xét của quản lý và tham gia thảo luận phản hồi.</p>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
        </div>
    </main>
</div>

<%@include file="../footer.jsp"%>

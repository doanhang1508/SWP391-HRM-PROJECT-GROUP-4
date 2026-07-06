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
                                    <h5 class="fw-bold mb-3"><i class="fas fa-comments text-muted me-2"></i>Trao đổi & Phản hồi</h5>

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

                                    <!-- Comment Input Form -->
                                    <c:choose>
                                        <c:when test="${selectedEval.cycleStatus == 'LOCKED' || selectedEval.cycleStatus == 'CLOSED'}">
                                            <div class="alert alert-warning mb-0 text-center py-2 px-3 small" style="border-radius: 8px;">
                                                <i class="fas fa-lock me-1"></i> Đợt đánh giá này đã khóa sổ (LOCKED). Không thể gửi thêm ý kiến trao đổi.
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <form action="${pageContext.request.contextPath}/employee/kpi-view" method="POST" class="mt-2">
                                                <input type="hidden" name="action" value="addComment" />
                                                <input type="hidden" name="evaluationId" value="${selectedEval.evaluationId}" />
                                                <div class="input-group">
                                                    <textarea class="form-control" name="commentText" placeholder="Nhập phản hồi, câu hỏi hoặc thắc mắc..." rows="2" style="border-radius: 8px 0 0 8px; resize: none; font-size: 0.85rem;" required></textarea>
                                                    <button class="btn btn-primary px-4" type="submit" style="border-radius: 0 8px 8px 0;">
                                                        <i class="fas fa-paper-plane me-1"></i> Gửi
                                                    </button>
                                                </div>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
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

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Quản lý Mẫu KPI" />
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
        <jsp:param name="activeMenu" value="kpi-templates" />
    </jsp:include>

    <main class="page-main">
        <div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1">Mẫu đánh giá KPI</h2>
            <p class="text-muted mb-0">Quản lý các tiêu chuẩn đánh giá năng lực của nhân sự</p>
        </div>
        <button class="btn btn-primary px-4 py-2" data-bs-toggle="modal" data-bs-target="#createTemplateModal" style="border-radius: 8px;">
            <i class="fas fa-plus me-2"></i> Tạo mẫu mới
        </button>
    </div>

    <c:if test="${param.success == '1'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Thao tác thực hiện thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i> Có lỗi xảy ra. Vui lòng kiểm tra lại thông tin.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Templates Grid -->
    <div class="row g-4">
        <c:forEach var="template" items="${templates}">
            <div class="col-md-6 col-lg-4">
                <div class="card h-100 border-0 shadow-sm" style="border-radius: 16px; background: var(--th-surface);">
                    <div class="card-body p-4 d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <span class="badge ${template.status == 1 ? 'bg-success-subtle text-success' : 'bg-secondary-subtle text-secondary'} px-3 py-2" style="border-radius: 8px; font-size: 0.8rem;">
                                <i class="fas ${template.status == 1 ? 'fa-check' : 'fa-ban'} me-1"></i>
                                ${template.status == 1 ? 'Đang hoạt động' : 'Tạm khóa'}
                            </span>
                            <div class="dropdown">
                                <button class="btn btn-link text-muted p-0" type="button" data-bs-toggle="dropdown">
                                    <i class="fas fa-ellipsis-v"></i>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="border-radius: 10px;">
                                    <li>
                                        <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/hr/kpi-templates/edit?id=${template.templateId}">
                                            <i class="fas fa-edit text-primary me-2"></i> Cài đặt tiêu chí
                                        </a>
                                    </li>
                                    <li>
                                        <form action="${pageContext.request.contextPath}/hr/kpi-templates" method="POST" onsubmit="return confirm('Xác nhận thay đổi trạng thái mẫu đánh giá?')">
                                            <input type="hidden" name="action" value="toggleStatus" />
                                            <input type="hidden" name="id" value="${template.templateId}" />
                                            <button type="submit" class="dropdown-item py-2">
                                                <i class="fas ${template.status == 1 ? 'fa-eye-slash text-warning' : 'fa-eye text-success'} me-2"></i>
                                                ${template.status == 1 ? 'Tạm ẩn' : 'Kích hoạt'}
                                            </button>
                                        </form>
                                    </li>
                                </ul>
                            </div>
                        </div>

                        <h4 class="fw-bold mb-2 text-truncate-2" style="min-height: 48px;">${template.name}</h4>
                        <p class="text-muted small mb-4 flex-grow-1" style="min-height: 40px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                            ${template.description}
                        </p>

                        <div class="border-top pt-3 mt-auto">
                            <div class="d-flex justify-content-between align-items-center text-muted small">
                                <span>Tạo lúc:</span>
                                <span class="fw-medium">
                                    <fmt:formatDate value="${template.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
        <c:if var="isEmpty" test="${empty templates}">
            <div class="col-12 text-center py-5">
                <div class="py-5" style="background: var(--th-surface); border-radius: 16px;">
                    <i class="fas fa-clipboard-list fa-3x text-muted mb-3" style="opacity: 0.3;"></i>
                    <h5 class="fw-bold">Chưa có mẫu KPI nào</h5>
                    <p class="text-muted">Nhấp vào nút phía trên bên phải để tạo mẫu KPI đầu tiên của bạn.</p>
                </div>
            </div>
        </c:if>
    </div>
        </div>
    </main>
</div>

<!-- Create Template Modal -->
<div class="modal fade" id="createTemplateModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 20px; background: var(--th-surface);">
            <div class="modal-header border-0 px-4 pt-4">
                <h5 class="modal-title fw-bold" id="exampleModalLabel">Tạo mẫu đánh giá KPI mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/hr/kpi-templates" method="POST">
                <input type="hidden" name="action" value="create" />
                <div class="modal-body px-4 pb-4">
                    <div class="mb-3">
                        <label for="name" class="form-label fw-bold">Tên mẫu đánh giá <span class="text-danger">*</span></label>
                        <input type="text" class="form-control px-3 py-2" id="name" name="name" required placeholder="Ví dụ: Đánh giá KPI khối Văn phòng Q2/2026" style="border-radius: 8px;" />
                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label fw-bold">Mô tả chi tiết</label>
                        <textarea class="form-control px-3 py-2" id="description" name="description" rows="4" placeholder="Mô tả phạm vi áp dụng, đối tượng đánh giá..." style="border-radius: 8px;"></textarea>
                    </div>
                    <div class="mb-3">
                        <label for="status" class="form-label fw-bold">Trạng thái</label>
                        <select class="form-select px-3 py-2" id="status" name="status" style="border-radius: 8px;">
                            <option value="1">Kích hoạt ngay (Hoạt động)</option>
                            <option value="0">Tạm lưu nháp (Tạm khóa)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 px-4 pb-4">
                    <button type="button" class="btn btn-light px-4 py-2" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary px-4 py-2" style="border-radius: 8px;">Lưu & tạo tiêu chí</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@include file="../footer.jsp"%>

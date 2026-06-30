<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="pageTitle" value="Thiết lập Tiêu chí KPI" />
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
    <!-- Back to list link -->
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/hr/kpi-templates" class="text-decoration-none text-muted">
            <i class="fas fa-arrow-left me-2"></i> Quay lại Danh sách mẫu KPI
        </a>
    </div>

    <!-- Header details -->
    <div class="card border-0 shadow-sm mb-4" style="border-radius: 16px; background: var(--th-surface);">
        <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                <div>
                    <div class="d-flex align-items-center flex-wrap gap-2 mb-2">
                        <h3 class="fw-bold mb-0">${template.name}</h3>
                        <button class="btn btn-outline-secondary btn-sm ms-2" data-bs-toggle="modal" data-bs-target="#editTemplateModal" style="border-radius: 8px;">
                            <i class="fas fa-edit me-1"></i> Chỉnh sửa
                        </button>
                    </div>
                    <div class="mb-2">
                        <c:choose>
                            <c:when test="${empty template.departmentName}">
                                <span class="badge bg-secondary-subtle text-secondary px-2.5 py-1.5" style="border-radius: 6px;">
                                    <i class="fas fa-globe me-1"></i>Áp dụng chung
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-primary-subtle text-primary px-2.5 py-1.5" style="border-radius: 6px;">
                                    <i class="fas fa-building me-1"></i>Phòng ban: ${template.departmentName}
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <p class="text-muted mb-0">${template.description}</p>
                </div>
                <span class="badge ${template.status == 1 ? 'bg-success-subtle text-success' : 'bg-secondary-subtle text-secondary'} px-3 py-2" style="border-radius: 8px;">
                    <i class="fas ${template.status == 1 ? 'fa-check' : 'fa-ban'} me-1"></i>
                    ${template.status == 1 ? 'Đang hoạt động' : 'Tạm khóa'}
                </span>
            </div>
        </div>
    </div>

    <c:if test="${param.success == 'item_added'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Thêm tiêu chí đánh giá thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'item_deleted'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Đã xóa tiêu chí đánh giá thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'header_updated'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Cập nhật thông tin mẫu đánh giá thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'weight_overflow'}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i> Không thể thêm tiêu chí: Tổng trọng số các tiêu chí không được vượt quá 100%.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error != null && param.error != 'weight_overflow' && param.error != 'invalid_weight'}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i> Đã xảy ra lỗi hệ thống. Vui lòng kiểm tra lại.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Criteria list table -->
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm h-100" style="border-radius: 16px; background: var(--th-surface);">
                <div class="card-header bg-transparent border-0 px-4 pt-4 pb-2 d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold mb-0">Danh sách Tiêu chí Đánh giá</h5>
                    <c:set var="totalWeight" value="0" />
                    <c:forEach var="item" items="${items}">
                        <c:set var="totalWeight" value="${totalWeight + item.weight}" />
                    </c:forEach>
                    <span class="badge ${totalWeight == 100 ? 'bg-success' : 'bg-warning text-dark'} px-3 py-2" style="border-radius: 8px; font-size: 0.9rem;">
                        Tổng trọng số: ${totalWeight}%
                    </span>
                </div>
                <div class="card-body px-4 pb-4">
                    <c:if test="${totalWeight != 100}">
                        <div class="alert alert-warning border-0 mb-4" style="border-radius: 10px;">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            <strong>Lưu ý:</strong> Tổng trọng số hiện tại là <b>${totalWeight}%</b>. Vui lòng thêm/điều chỉnh để tổng trọng số bằng đúng <b>100%</b> để đảm bảo tính toán KPI chính xác khi tạo đợt đánh giá.
                        </div>
                    </c:if>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" style="width: 5%;" class="text-center">STT</th>
                                    <th scope="col" style="width: 30%;">Tiêu chí</th>
                                    <th scope="col" style="width: 45%;">Mô tả & Chỉ tiêu</th>
                                    <th scope="col" style="width: 10%;" class="text-center">Trọng số</th>
                                    <th scope="col" style="width: 10%;" class="text-center">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${items}" varStatus="status">
                                    <tr>
                                        <td class="text-center fw-bold text-muted">${status.index + 1}</td>
                                        <td><strong class="text-primary-emphasis">${item.criterionName}</strong></td>
                                        <td class="text-muted small">${item.description}</td>
                                        <td class="text-center fw-semibold text-success">${item.weight}%</td>
                                        <td class="text-center">
                                            <form action="${pageContext.request.contextPath}/hr/kpi-templates/edit" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn xóa tiêu chí này?')">
                                                <input type="hidden" name="action" value="deleteItem" />
                                                <input type="hidden" name="id" value="${template.templateId}" />
                                                <input type="hidden" name="itemId" value="${item.itemId}" />
                                                <button type="submit" class="btn btn-outline-danger btn-sm border-0" style="border-radius: 6px;">
                                                    <i class="fas fa-trash-alt"></i>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty items}">
                                    <tr>
                                        <td colspan="5" class="text-center py-5 text-muted">
                                            <i class="fas fa-folder-open fa-2x mb-2 opacity-50"></i>
                                            <p class="mb-0">Chưa có tiêu chí nào. Vui lòng thêm tiêu chí bên phải.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add criterion form side panel -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm" style="border-radius: 16px; background: var(--th-surface);">
                <div class="card-header bg-transparent border-0 px-4 pt-4 pb-2">
                    <h5 class="fw-bold mb-0">Thêm tiêu chí mới</h5>
                </div>
                <div class="card-body px-4 pb-4">
                    <form action="${pageContext.request.contextPath}/hr/kpi-templates/edit" method="POST">
                        <input type="hidden" name="action" value="addItem" />
                        <input type="hidden" name="id" value="${template.templateId}" />
                        
                        <div class="mb-3">
                            <label for="itemName" class="form-label fw-bold">Tên tiêu chí <span class="text-danger">*</span></label>
                            <input type="text" class="form-control px-3 py-2" id="itemName" name="name" required placeholder="Ví dụ: Hiệu suất công việc" style="border-radius: 8px;" />
                        </div>
                        
                        <div class="mb-3">
                            <label for="itemDesc" class="form-label fw-bold">Mô tả chi tiết & KPI đích</label>
                            <textarea class="form-control px-3 py-2" id="itemDesc" name="description" rows="3" placeholder="Ví dụ: Hoàn thành 100% công việc được giao đúng hạn." style="border-radius: 8px;"></textarea>
                        </div>
                        
                        <div class="mb-4">
                            <label for="itemWeight" class="form-label fw-bold">Trọng số (%) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" class="form-control px-3 py-2" id="itemWeight" name="weight" min="1" max="100" required placeholder="Ví dụ: 30" style="border-top-left-radius: 8px; border-bottom-left-radius: 8px;" />
                                <span class="input-group-text" style="border-top-right-radius: 8px; border-bottom-right-radius: 8px;">%</span>
                            </div>
                            <div class="form-text text-muted small">Khuyên dùng: 10% - 50%</div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2.5 fw-semibold" style="border-radius: 8px;" ${totalWeight >= 100 ? 'disabled' : ''}>
                            <i class="fas fa-plus me-2"></i> Thêm tiêu chí
                        </button>
                        
                        <c:if test="${totalWeight >= 100}">
                            <div class="text-danger text-center small mt-2">Tổng trọng số đã đạt 100%.</div>
                        </c:if>
                    </form>
                </div>
            </div>
    </div>
        </div>
    </main>
</div>

<!-- Edit Template Modal -->
<div class="modal fade" id="editTemplateModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 20px; background: var(--th-surface);">
            <div class="modal-header border-0 px-4 pt-4">
                <h5 class="modal-title fw-bold">Chỉnh sửa thông tin mẫu đánh giá</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/hr/kpi-templates/edit" method="POST">
                <input type="hidden" name="action" value="updateHeader" />
                <input type="hidden" name="id" value="${template.templateId}" />
                <div class="modal-body px-4 pb-4">
                    <div class="mb-3">
                        <label for="edit_name" class="form-label fw-bold">Tên mẫu đánh giá <span class="text-danger">*</span></label>
                        <input type="text" class="form-control px-3 py-2" id="edit_name" name="name" required value="${template.name}" style="border-radius: 8px;" />
                    </div>
                    <div class="mb-3">
                        <label for="edit_description" class="form-label fw-bold">Mô tả chi tiết</label>
                        <textarea class="form-control px-3 py-2" id="edit_description" name="description" rows="3" style="border-radius: 8px;">${template.description}</textarea>
                    </div>
                    <div class="mb-3">
                        <label for="edit_departmentId" class="form-label fw-bold">Phòng ban áp dụng</label>
                        <select class="form-select px-3 py-2" id="edit_departmentId" name="departmentId" style="border-radius: 8px;">
                            <option value="all" ${empty template.departmentId ? 'selected' : ''}>Áp dụng cho tất cả phòng ban</option>
                            <c:forEach var="dept" items="${departments}">
                                <option value="${dept.departmentId}" ${template.departmentId == dept.departmentId ? 'selected' : ''}>${dept.departmentName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="edit_status" class="form-label fw-bold">Trạng thái</label>
                        <select class="form-select px-3 py-2" id="edit_status" name="status" style="border-radius: 8px;">
                            <option value="1" ${template.status == 1 ? 'selected' : ''}>Đang hoạt động</option>
                            <option value="0" ${template.status == 0 ? 'selected' : ''}>Tạm khóa</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 px-4 pb-4">
                    <button type="button" class="btn btn-light px-4 py-2" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary px-4 py-2" style="border-radius: 8px;">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@include file="../footer.jsp"%>

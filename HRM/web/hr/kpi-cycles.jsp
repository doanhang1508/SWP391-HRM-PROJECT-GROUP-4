<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Quản lý Chu kỳ Đánh giá KPI" />
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
        <jsp:param name="activeMenu" value="kpi-cycles" />
    </jsp:include>

    <main class="page-main">
        <div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1">Chu kỳ đánh giá KPI</h2>
            <p class="text-muted mb-0">Quản lý các đợt đánh giá hiệu suất nhân viên định kỳ</p>
        </div>
        <button class="btn btn-primary px-4 py-2" data-bs-toggle="modal" data-bs-target="#createCycleModal" style="border-radius: 8px;">
            <i class="fas fa-plus me-2"></i> Tạo chu kỳ mới
        </button>
    </div>

    <c:if test="${param.success == '1'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Tạo chu kỳ đánh giá mới thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.success == 'status_updated'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> Trạng thái chu kỳ đã được cập nhật thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i> Thao tác không thành công. Vui lòng kiểm tra lại dữ liệu.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Cycle Table -->
    <div class="card border-0 shadow-sm" style="border-radius: 16px; background: var(--th-surface);">
        <div class="card-body p-4">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th scope="col" style="width: 25%;">Tên đợt đánh giá</th>
                            <th scope="col" style="width: 15%;">Mẫu tiêu chuẩn</th>
                            <th scope="col" style="width: 12%;">Ngày bắt đầu</th>
                            <th scope="col" style="width: 12%;">Ngày kết thúc</th>
                            <th scope="col" style="width: 12%;">Hạn tự đánh giá</th>
                            <th scope="col" style="width: 12%;" class="text-center">Trạng thái</th>
                            <th scope="col" style="width: 12%;" class="text-center">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cycle" items="${cycleList}">
                            <tr>
                                <td><strong class="text-primary-emphasis">${cycle.name}</strong></td>
                                <td>
                                    <span class="badge bg-secondary-subtle text-secondary px-2.5 py-1.5" style="border-radius: 6px;">
                                        <i class="fas fa-clipboard-list me-1"></i> ${cycle.templateName}
                                    </span>
                                    <br/>
                                    <small class="text-muted">
                                        <i class="fas fa-building me-1"></i>
                                        <c:choose>
                                            <c:when test="${cycle.templateDepartmentName != null}">${cycle.templateDepartmentName}</c:when>
                                            <c:otherwise>Toàn công ty</c:otherwise>
                                        </c:choose>
                                    </small>
                                </td>
                                <td><fmt:formatDate value="${cycle.startDate}" pattern="dd/MM/yyyy" /></td>
                                <td><fmt:formatDate value="${cycle.endDate}" pattern="dd/MM/yyyy" /></td>
                                <td><fmt:formatDate value="${cycle.evaluationDeadline}" pattern="dd/MM/yyyy" /></td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${cycle.status == 'DRAFT'}">
                                            <span class="badge bg-warning-subtle text-warning px-3 py-2" style="border-radius: 8px;">Nháp</span>
                                        </c:when>
                                        <c:when test="${cycle.status == 'ACTIVE'}">
                                            <span class="badge bg-success-subtle text-success px-3 py-2" style="border-radius: 8px;">Kích hoạt</span>
                                        </c:when>
                                        <c:when test="${cycle.status == 'LOCKED'}">
                                            <span class="badge bg-danger-subtle text-danger px-3 py-2" style="border-radius: 8px;">Khóa</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary-subtle text-secondary px-3 py-2" style="border-radius: 8px;">Lưu trữ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${cycle.status == 'DRAFT'}">
                                            <form action="${pageContext.request.contextPath}/hr/kpi-cycles" method="POST" class="d-inline" onsubmit="return confirm('Kích hoạt chu kỳ này sẽ tự động khởi tạo bảng đánh giá cho toàn bộ nhân viên hoạt động. Tiếp tục?')">
                                                <input type="hidden" name="action" value="updateStatus" />
                                                <input type="hidden" name="id" value="${cycle.cycleId}" />
                                                <input type="hidden" name="status" value="ACTIVE" />
                                                <button type="submit" class="btn btn-outline-success btn-sm px-2.5 py-1.5" style="border-radius: 6px;">
                                                    <i class="fas fa-play me-1"></i> Mở đợt
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:when test="${cycle.status == 'ACTIVE'}">
                                            <form action="${pageContext.request.contextPath}/hr/kpi-cycles" method="POST" class="d-inline" onsubmit="return confirm('Xác nhận khóa chỉnh sửa đợt đánh giá này?')">
                                                <input type="hidden" name="action" value="updateStatus" />
                                                <input type="hidden" name="id" value="${cycle.cycleId}" />
                                                <input type="hidden" name="status" value="LOCKED" />
                                                <button type="submit" class="btn btn-outline-danger btn-sm px-2.5 py-1.5" style="border-radius: 6px;">
                                                    <i class="fas fa-lock me-1"></i> Khóa sổ
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:when test="${cycle.status == 'LOCKED'}">
                                            <form action="${pageContext.request.contextPath}/hr/kpi-cycles" method="POST" class="d-inline" onsubmit="return confirm('Lưu trữ đợt đánh giá này?')">
                                                <input type="hidden" name="action" value="updateStatus" />
                                                <input type="hidden" name="id" value="${cycle.cycleId}" />
                                                <input type="hidden" name="status" value="CLOSED" />
                                                <button type="submit" class="btn btn-outline-secondary btn-sm px-2.5 py-1.5" style="border-radius: 6px;">
                                                    <i class="fas fa-archive me-1"></i> Đóng đợt
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small">Đã lưu trữ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty cycleList}">
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="fas fa-history fa-2x mb-2 opacity-50"></i>
                                    <p class="mb-0">Chưa có chu kỳ đánh giá nào. Bấm nút phía trên để tạo chu kỳ.</p>
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

<!-- Create Cycle Modal -->
<div class="modal fade" id="createCycleModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 20px; background: var(--th-surface);">
            <div class="modal-header border-0 px-4 pt-4">
                <h5 class="modal-title fw-bold">Tạo Chu kỳ đánh giá mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/hr/kpi-cycles" method="POST">
                <input type="hidden" name="action" value="create" />
                <div class="modal-body px-4 pb-4">
                    <div class="mb-3">
                        <label for="cycleName" class="form-label fw-bold">Tên chu kỳ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control px-3 py-2" id="cycleName" name="name" required placeholder="Ví dụ: Đánh giá KPI Quý 2 - Năm 2026" style="border-radius: 8px;" />
                    </div>
                    
                    <div class="mb-3">
                        <label for="templateId" class="form-label fw-bold">Mẫu đánh giá chuẩn <span class="text-danger">*</span></label>
                        <select class="form-select px-3 py-2" id="templateId" name="templateId" required style="border-radius: 8px;">
                            <option value="">-- Chọn mẫu tiêu chuẩn --</option>
                            <c:forEach var="template" items="${templateList}">
                                <option value="${template.templateId}">
                                    ${template.name}
                                    <c:choose>
                                        <c:when test="${template.departmentId != null}"> — [${template.departmentName}]</c:when>
                                        <c:otherwise> — [Toàn công ty]</c:otherwise>
                                    </c:choose>
                                </option>
                            </c:forEach>
                        </select>
                        <div class="form-text text-muted">
                            <i class="fas fa-info-circle me-1"></i>Mẫu gắn phòng ban sẽ chỉ tạo bảng đánh giá cho nhân viên thuộc phòng ban đó.
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="quarterSelect" class="form-label fw-bold">Chọn quý <span class="text-muted fw-normal">(tùy chọn)</span></label>
                        <select class="form-select px-3 py-2" id="quarterSelect" style="border-radius: 8px;">
                            <option value="">-- Chọn quý để tự điền ngày --</option>
                        </select>
                        <div class="form-text text-muted">Chọn quý để hệ thống tự động điền ngày bắt đầu và kết thúc.</div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="startDate" class="form-label fw-bold">Ngày bắt đầu <span class="text-danger">*</span></label>
                            <input type="date" class="form-control px-3 py-2" id="startDate" name="startDate" required style="border-radius: 8px;" />
                        </div>
                        <div class="col-md-6">
                            <label for="endDate" class="form-label fw-bold">Ngày kết thúc <span class="text-danger">*</span></label>
                            <input type="date" class="form-control px-3 py-2" id="endDate" name="endDate" required style="border-radius: 8px;" />
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="deadline" class="form-label fw-bold">Hạn tự đánh giá của NV <span class="text-danger">*</span></label>
                        <input type="date" class="form-control px-3 py-2" id="deadline" name="deadline" required style="border-radius: 8px;" />
                    </div>

                    <div class="mb-3">
                        <label for="status" class="form-label fw-bold">Trạng thái khởi tạo</label>
                        <select class="form-select px-3 py-2" id="status" name="status" style="border-radius: 8px;">
                            <option value="DRAFT">Lưu nháp (Chưa kích hoạt)</option>
                            <option value="ACTIVE">Kích hoạt ngay (Tự khởi tạo bảng điểm)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 px-4 pb-4">
                    <button type="button" class="btn btn-light px-4 py-2" data-bs-dismiss="modal" style="border-radius: 8px;">Hủy</button>
                    <button type="submit" class="btn btn-primary px-4 py-2" style="border-radius: 8px;">Tạo chu kỳ</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
(function() {
    const quarterSelect = document.getElementById('quarterSelect');
    const startDateInput = document.getElementById('startDate');
    const endDateInput   = document.getElementById('endDate');
    const cycleNameInput = document.getElementById('cycleName');

    // Build quarter options for current year and next year
    const now  = new Date();
    const currentYear = now.getFullYear();
    const years = [currentYear, currentYear + 1];

    const quarterDefs = [
        { label: 'Quý 1', q: 1, startMonth: '01', startDay: '01', endMonth: '03', endDay: '31' },
        { label: 'Quý 2', q: 2, startMonth: '04', startDay: '01', endMonth: '06', endDay: '30' },
        { label: 'Quý 3', q: 3, startMonth: '07', startDay: '01', endMonth: '09', endDay: '30' },
        { label: 'Quý 4', q: 4, startMonth: '10', startDay: '01', endMonth: '12', endDay: '31' }
    ];

    years.forEach(function(year) {
        quarterDefs.forEach(function(qd) {
            const opt = document.createElement('option');
            opt.value = year + '-Q' + qd.q;
            opt.textContent = qd.label + ' - Năm ' + year
                + ' (' + qd.startDay + '/' + qd.startMonth + ' \u2013 ' + qd.endDay + '/' + qd.endMonth + ')';
            opt.dataset.startDate = year + '-' + qd.startMonth + '-' + qd.startDay;
            opt.dataset.endDate   = year + '-' + qd.endMonth   + '-' + qd.endDay;
            opt.dataset.suggestedName = '\u0110\u00e1nh gi\u00e1 KPI ' + qd.label + ' - N\u0103m ' + year;
            quarterSelect.appendChild(opt);
        });
    });

    quarterSelect.addEventListener('change', function() {
        const selected = this.options[this.selectedIndex];
        if (!selected.value) return;

        startDateInput.value = selected.dataset.startDate;
        endDateInput.value   = selected.dataset.endDate;

        // Auto-suggest a cycle name if the field is empty
        if (!cycleNameInput.value.trim()) {
            cycleNameInput.value = selected.dataset.suggestedName;
        }
    });
})();
</script>

<%@include file="../footer.jsp"%>

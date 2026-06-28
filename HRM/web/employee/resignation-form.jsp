<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Đơn Xin Nghỉ Việc - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    /* ── Layout ── */
    .resign-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }

    .resign-content {
        flex: 1;
        padding: 30px;
        overflow-y: auto;
        background: #f0ede8;
    }

    /* ── Page Banner ── */
    .page-banner {
        background: linear-gradient(135deg, #0a2540 0%, #7c1c3a 100%);
        color: white;
        border-radius: 14px;
        padding: 26px 32px;
        margin-bottom: 24px;
        position: relative;
        overflow: hidden;
    }

    .page-banner::after {
        content: '';
        position: absolute;
        top: -70px;
        right: -70px;
        width: 240px;
        height: 240px;
        background: rgba(255, 255, 255, 0.04);
        border-radius: 50%;
        pointer-events: none;
    }

    .page-banner::before {
        content: '';
        position: absolute;
        bottom: -40px;
        left: 30%;
        width: 140px;
        height: 140px;
        background: rgba(255, 255, 255, 0.03);
        border-radius: 50%;
        pointer-events: none;
    }

    .page-banner h2 {
        font-size: 1.45rem;
        font-weight: 800;
        margin: 0 0 6px;
        letter-spacing: -0.3px;
    }

    .page-banner p {
        margin: 0;
        opacity: 0.72;
        font-size: 0.9rem;
    }

    .breadcrumb {
        font-size: 0.78rem;
        margin-bottom: 10px;
        opacity: 0.7;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .breadcrumb a {
        color: rgba(255,255,255,0.85);
        text-decoration: none;
    }

    /* ── Alert messages ── */
    .alert {
        padding: 14px 20px;
        border-radius: 12px;
        font-size: 0.9rem;
        font-weight: 500;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .alert-success {
        background: #d1fae5;
        border: 1px solid #a7f3d0;
        color: #065f46;
    }

    .alert-danger {
        background: #fff1f2;
        border: 1px solid #fecdd3;
        color: #9f1239;
    }

    /* ── Form Card ── */
    .resign-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 32px 36px;
        margin-bottom: 28px;
        box-shadow: 0 4px 20px rgba(10,37,64,0.06);
    }

    .card-header-row {
        display: flex;
        align-items: center;
        gap: 14px;
        margin-bottom: 26px;
        padding-bottom: 20px;
        border-bottom: 1px solid #f1f5f9;
    }

    .card-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        flex-shrink: 0;
    }

    .card-icon.danger {
        background: #fff1f2;
        color: #e11d48;
    }

    .card-icon.history {
        background: #eff6ff;
        color: #2563eb;
    }

    .card-header-text h3 {
        font-size: 1.1rem;
        font-weight: 700;
        color: #0a2540;
        margin: 0 0 3px;
    }

    .card-header-text p {
        font-size: 0.83rem;
        color: #64748b;
        margin: 0;
    }

    /* ── Warning Box ── */
    .warning-box {
        background: #fffbeb;
        border: 1px solid #fde68a;
        border-left: 4px solid #f59e0b;
        border-radius: 10px;
        padding: 14px 18px;
        margin-bottom: 24px;
        display: flex;
        gap: 12px;
        align-items: flex-start;
    }

    .warning-box i {
        color: #d97706;
        font-size: 1.1rem;
        margin-top: 2px;
        flex-shrink: 0;
    }

    .warning-box div {
        font-size: 0.85rem;
        color: #78350f;
        line-height: 1.6;
    }

    .warning-box strong {
        display: block;
        margin-bottom: 3px;
    }

    /* ── Form Elements ── */
    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .form-group {
        margin-bottom: 20px;
    }

    .form-group.full-width {
        grid-column: 1 / -1;
    }

    .form-label {
        display: block;
        font-size: 0.85rem;
        font-weight: 600;
        color: #0a2540;
        margin-bottom: 8px;
    }

    .form-label .required {
        color: #e11d48;
        margin-left: 2px;
    }

    .form-control {
        width: 100%;
        padding: 12px 14px;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        font-size: 0.9rem;
        font-family: 'Inter', sans-serif;
        outline: none;
        transition: all 0.2s;
        background: #f8fafc;
        color: #0f172a;
    }

    .form-control:focus {
        border-color: #e11d48;
        box-shadow: 0 0 0 3px rgba(225,29,72,0.1);
        background: #ffffff;
    }

    textarea.form-control {
        resize: vertical;
        min-height: 120px;
        line-height: 1.6;
    }

    /* ── Submit Button ── */
    .btn-submit {
        background: linear-gradient(135deg, #e11d48, #be123c);
        color: #fff;
        border: none;
        padding: 14px 28px;
        border-radius: 10px;
        font-weight: 700;
        font-size: 0.95rem;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        transition: all 0.2s;
        font-family: 'Inter', sans-serif;
        box-shadow: 0 4px 14px rgba(225,29,72,0.25);
    }

    .btn-submit:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 18px rgba(225,29,72,0.35);
    }

    /* ── History Table ── */
    .table-wrapper {
        overflow-x: auto;
        border-radius: 10px;
        border: 1px solid #e2e8f0;
    }

    table.resign-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.875rem;
    }

    .resign-table thead th {
        background: #f8fafc;
        padding: 12px 16px;
        text-align: left;
        font-weight: 600;
        font-size: 0.78rem;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #e2e8f0;
        white-space: nowrap;
    }

    .resign-table tbody tr {
        border-bottom: 1px solid #f1f5f9;
        transition: background 0.15s;
    }

    .resign-table tbody tr:last-child {
        border-bottom: none;
    }

    .resign-table tbody tr:hover {
        background: #f8fafc;
    }

    .resign-table tbody td {
        padding: 14px 16px;
        color: #0f172a;
        vertical-align: top;
    }

    .reason-text {
        max-width: 260px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        display: block;
    }

    /* ── Status Badges ── */
    .badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 600;
        white-space: nowrap;
    }

    .badge-pending {
        background: #fffbeb;
        color: #92400e;
        border: 1px solid #fde68a;
    }

    .badge-approved {
        background: #d1fae5;
        color: #065f46;
        border: 1px solid #a7f3d0;
    }

    .badge-rejected {
        background: #fff1f2;
        color: #9f1239;
        border: 1px solid #fecdd3;
    }

    /* ── Empty state ── */
    .empty-state {
        text-align: center;
        padding: 48px 24px;
        color: #94a3b8;
    }

    .empty-state i {
        font-size: 2.5rem;
        margin-bottom: 14px;
        display: block;
    }

    .empty-state p {
        font-size: 0.9rem;
        margin: 0;
    }

    /* ── Confirm Modal ── */
    .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.5);
        z-index: 9000;
        align-items: center;
        justify-content: center;
    }

    .modal-overlay.active {
        display: flex;
    }

    .modal-box {
        background: #fff;
        border-radius: 16px;
        padding: 32px 36px;
        max-width: 440px;
        width: 90%;
        box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        animation: modalIn 0.25s ease;
    }

    @keyframes modalIn {
        from { transform: scale(0.92); opacity: 0; }
        to   { transform: scale(1);    opacity: 1; }
    }

    .modal-icon {
        width: 56px;
        height: 56px;
        background: #fff1f2;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        color: #e11d48;
        margin: 0 auto 18px;
    }

    .modal-box h4 {
        font-size: 1.1rem;
        font-weight: 800;
        color: #0a2540;
        text-align: center;
        margin: 0 0 10px;
    }

    .modal-box p {
        font-size: 0.85rem;
        color: #64748b;
        text-align: center;
        margin: 0 0 24px;
        line-height: 1.6;
    }

    .modal-actions {
        display: flex;
        gap: 12px;
    }

    .btn-modal-cancel {
        flex: 1;
        padding: 12px;
        border-radius: 9px;
        border: 1px solid #e2e8f0;
        background: #f8fafc;
        font-weight: 600;
        font-size: 0.9rem;
        cursor: pointer;
        color: #475569;
        transition: background 0.15s;
        font-family: 'Inter', sans-serif;
    }

    .btn-modal-cancel:hover { background: #f1f5f9; }

    .btn-modal-confirm {
        flex: 1;
        padding: 12px;
        border-radius: 9px;
        border: none;
        background: #e11d48;
        color: #fff;
        font-weight: 700;
        font-size: 0.9rem;
        cursor: pointer;
        transition: background 0.15s;
        font-family: 'Inter', sans-serif;
    }

    .btn-modal-confirm:hover { background: #be123c; }

    @media (max-width: 768px) {
        .resign-content { padding: 20px 16px; }
        .resign-card { padding: 22px 18px; }
        .form-row { grid-template-columns: 1fr; }
    }
</style>

<div class="resign-layout">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="resignation" />
    </jsp:include>

    <div class="resign-content">

        <!-- Page Banner -->
        <div class="page-banner">
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                <span>/</span>
                <span>Xin Nghỉ Việc</span>
            </div>
            <h2><i class="fas fa-door-open" style="margin-right:10px;"></i>Đơn Xin Nghỉ Việc</h2>
            <p>Nộp đơn xin nghỉ việc và theo dõi trạng thái xem xét từ phòng Nhân sự.</p>
        </div>

        <!-- Flash Messages -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle" style="font-size:1.1rem;"></i>
                ${sessionScope.successMessage}
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle" style="font-size:1.1rem;"></i>
                ${sessionScope.errorMessage}
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <!-- Form Card -->
        <div class="resign-card">
            <div class="card-header-row">
                <div class="card-icon danger">
                    <i class="fas fa-file-signature"></i>
                </div>
                <div class="card-header-text">
                    <h3>Nộp Đơn Xin Nghỉ Việc</h3>
                    <p>Điền đầy đủ thông tin bên dưới. Đơn sẽ được gửi đến HR để xem xét.</p>
                </div>
            </div>

            <c:choose>
                <c:when test="${hasPending}">
                    <!-- Đã có đơn đang chờ duyệt -->
                    <div style="background:#fffbeb;border:1px solid #fde68a;border-left:4px solid #f59e0b;border-radius:10px;padding:16px 20px;display:flex;gap:14px;align-items:center;">
                        <i class="fas fa-clock" style="color:#d97706;font-size:1.3rem;flex-shrink:0;"></i>
                        <div>
                            <strong style="display:block;color:#78350f;margin-bottom:4px;">Bạn đã có đơn đang chờ duyệt</strong>
                            <span style="font-size:0.88rem;color:#92400e;">
                                Đơn xin nghỉ việc của bạn đang được HR xem xét. Bạn không thể nộp thêm đơn mới cho đến khi đơn hiện tại được xử lý.
                                Nếu cần rút đơn, vui lòng liên hệ HR trực tiếp.
                            </span>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="warning-box">
                        <i class="fas fa-exclamation-circle"></i>
                        <div>
                            <strong>Lưu ý quan trọng</strong>
                            Khi đơn được HR duyệt, tài khoản của bạn sẽ bị vô hiệu hóa và bạn sẽ không thể đăng nhập hệ thống nữa.
                            Hãy chắc chắn trước khi nộp đơn. Bạn vẫn có thể liên hệ HR để rút đơn khi đơn đang ở trạng thái <strong>Chờ duyệt</strong>.
                        </div>
                    </div>

                    <form id="resignForm" action="${pageContext.request.contextPath}/employee/resignation" method="post">
                        <div class="form-row">
                            <div class="form-group">
                                <label for="desiredLastDate" class="form-label">
                                    Ngày muốn nghỉ <span class="required">*</span>
                                </label>
                                <input type="date" id="desiredLastDate" name="desiredLastDate"
                                       class="form-control" required
                                       min="${pageContext.request.contextPath != null ? '' : ''}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="reason" class="form-label">
                                Lý do xin nghỉ việc <span class="required">*</span>
                            </label>
                            <textarea id="reason" name="reason" class="form-control"
                                      placeholder="Vui lòng mô tả lý do xin nghỉ việc của bạn (có thể nhà riêng, gia đình, sức khỏe, cơ hội mới...)"
                                      required minlength="10"></textarea>
                        </div>

                        <button type="button" class="btn-submit" onclick="openConfirmModal()">
                            <i class="fas fa-paper-plane"></i> Gửi Đơn Xin Nghỉ
                        </button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- History Card -->
        <div class="resign-card">
            <div class="card-header-row">
                <div class="card-icon history">
                    <i class="fas fa-history"></i>
                </div>
                <div class="card-header-text">
                    <h3>Lịch Sử Đơn Đã Nộp</h3>
                    <p>Danh sách tất cả các đơn xin nghỉ việc bạn đã nộp.</p>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty resignationHistory}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <p>Bạn chưa nộp đơn xin nghỉ việc nào.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-wrapper">
                        <table class="resign-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Ngày nộp</th>
                                    <th>Ngày muốn nghỉ</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                    <th>Người duyệt</th>
                                    <th>Ghi chú HR</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rr" items="${resignationHistory}" varStatus="st">
                                    <tr>
                                        <td style="color:#94a3b8;font-weight:500;">${st.index + 1}</td>
                                        <td>
                                            <fmt:formatDate value="${rr.submittedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td>
                                            <strong><fmt:formatDate value="${rr.desiredLastDate}" pattern="dd/MM/yyyy"/></strong>
                                        </td>
                                        <td>
                                            <span class="reason-text" title="${rr.reason}">${rr.reason}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rr.status == 'PENDING'}">
                                                    <span class="badge badge-pending">
                                                        <i class="fas fa-clock"></i> Chờ duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${rr.status == 'APPROVED'}">
                                                    <span class="badge badge-approved">
                                                        <i class="fas fa-check-circle"></i> Đã duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${rr.status == 'REJECTED'}">
                                                    <span class="badge badge-rejected">
                                                        <i class="fas fa-times-circle"></i> Từ chối
                                                    </span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty rr.reviewerName}">
                                                    ${rr.reviewerName}
                                                    <br>
                                                    <span style="font-size:0.75rem;color:#94a3b8;">
                                                        <fmt:formatDate value="${rr.reviewedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#94a3b8;">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty rr.hrNote}">
                                                    <span style="font-size:0.85rem;color:#475569;">${rr.hrNote}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#94a3b8;">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>

<!-- Confirmation Modal -->
<div class="modal-overlay" id="confirmModal">
    <div class="modal-box">
        <div class="modal-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h4>Xác Nhận Nộp Đơn</h4>
        <p>
            Sau khi được HR duyệt, tài khoản của bạn sẽ bị vô hiệu hóa vĩnh viễn
            và bạn sẽ không thể đăng nhập lại.<br><br>
            Bạn có chắc chắn muốn nộp đơn xin nghỉ việc không?
        </p>
        <div class="modal-actions">
            <button class="btn-modal-cancel" onclick="closeConfirmModal()">
                <i class="fas fa-arrow-left"></i> Quay lại
            </button>
            <button class="btn-modal-confirm" onclick="document.getElementById('resignForm').submit()">
                <i class="fas fa-paper-plane"></i> Xác nhận gửi
            </button>
        </div>
    </div>
</div>

<script>
    // Đặt min date cho input ngày nghỉ = hôm nay (chỉ khi form tồn tại)
    document.addEventListener('DOMContentLoaded', function () {
        const dateInput = document.getElementById('desiredLastDate');
        if (dateInput) {
            const today = new Date().toISOString().split('T')[0];
            dateInput.setAttribute('min', today);
        }
    });

    function openConfirmModal() {
        const form = document.getElementById('resignForm');
        if (!form) return;
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }
        document.getElementById('confirmModal').classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function closeConfirmModal() {
        document.getElementById('confirmModal').classList.remove('active');
        document.body.style.overflow = '';
    }

    // Close modal khi click ngoài
    const modal = document.getElementById('confirmModal');
    if (modal) {
        modal.addEventListener('click', function (e) {
            if (e.target === this) closeConfirmModal();
        });
    }
</script>

<jsp:include page="../footer.jsp" />

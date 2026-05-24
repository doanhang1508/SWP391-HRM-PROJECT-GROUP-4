<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="displayUser" value="${sessionScope.currentUser}" />

<c:set var="pageTitle" value="Hồ sơ cá nhân - HRM" scope="request" />
<jsp:include page="header.jsp" />

<style>
    body { background-color: #f0f4f8; }

    .profile-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .profile-content {
        flex: 1;
        padding: 30px;
        overflow-y: auto;
    }

    /* Page Header */
    .profile-page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
    }
    .profile-page-title {
        font-size: 1.4rem;
        font-weight: 700;
        color: #2b2b2b;
        margin: 0;
    }
    .profile-breadcrumb {
        font-size: 0.85rem;
        color: #8f9fbc;
        margin: 4px 0 0;
    }
    .profile-breadcrumb a { color: #4361ee; text-decoration: none; }

    /* Profile Hero Card */
    .profile-hero {
        background: linear-gradient(135deg, #0a2540 0%, #1a3a6b 100%);
        border-radius: 16px;
        padding: 32px;
        color: white;
        margin-bottom: 24px;
        position: relative;
        overflow: hidden;
    }
    .profile-hero::after {
        content: '';
        position: absolute;
        top: -80px; right: -80px;
        width: 260px; height: 260px;
        background: rgba(255,255,255,0.04);
        border-radius: 50%;
        pointer-events: none;
    }
    .profile-hero-inner {
        display: flex;
        align-items: center;
        gap: 24px;
        position: relative;
        z-index: 1;
    }
    .profile-avatar-wrap {
        position: relative;
        flex-shrink: 0;
    }
    .profile-avatar-wrap img {
        width: 100px;
        height: 100px;
        border-radius: 16px;
        object-fit: cover;
        border: 3px solid rgba(255,255,255,0.3);
        box-shadow: 0 8px 20px rgba(0,0,0,0.2);
    }
    .profile-avatar-wrap .avatar-placeholder {
        width: 100px;
        height: 100px;
        border-radius: 16px;
        background: linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 2.5rem;
        font-weight: 800;
        color: #fff;
        border: 3px solid rgba(255,255,255,0.3);
        box-shadow: 0 8px 20px rgba(0,0,0,0.2);
    }
    .avatar-upload-btn {
        position: absolute;
        bottom: -4px;
        right: -4px;
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: #4361ee;
        color: white;
        border: 2px solid white;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        font-size: 0.75rem;
        transition: transform 0.2s;
    }
    .avatar-upload-btn:hover { transform: scale(1.1); }
    .profile-hero-info h2 {
        margin: 0 0 4px;
        font-size: 1.5rem;
        font-weight: 700;
    }
    .profile-hero-info .role-badge {
        display: inline-block;
        padding: 4px 14px;
        border-radius: 20px;
        font-size: 0.78rem;
        font-weight: 600;
        background: rgba(255,255,255,0.15);
        backdrop-filter: blur(4px);
        margin-bottom: 8px;
    }
    .profile-hero-info .meta-row {
        display: flex;
        gap: 20px;
        font-size: 0.85rem;
        opacity: 0.8;
        margin-top: 6px;
    }
    .profile-hero-info .meta-row i { margin-right: 5px; }

    /* Info Card */
    .info-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 28px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }
    .info-card-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #edf2f7;
    }
    .info-card-title {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 1.05rem;
        font-weight: 700;
        color: #2d3748;
        margin: 0;
    }
    .info-card-title .icon-box {
        width: 36px; height: 36px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.9rem;
    }

    /* Form fields */
    .info-field {
        margin-bottom: 20px;
    }
    .info-field label {
        display: block;
        font-size: 0.78rem;
        font-weight: 700;
        color: #8f9fbc;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 6px;
    }
    .info-field .field-value {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 12px 16px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        font-size: 0.95rem;
        color: #2d3748;
        font-weight: 500;
        transition: all 0.2s;
    }
    .info-field .field-value i {
        color: #8f9fbc;
        width: 18px;
        text-align: center;
    }
    .info-field .field-value.editable {
        background: #fff;
        border-color: #4361ee;
        box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.08);
    }

    /* Edit form inputs */
    .info-field input.edit-input {
        flex: 1;
        border: none;
        background: transparent;
        font-size: 0.95rem;
        color: #2d3748;
        font-weight: 500;
        outline: none;
        font-family: inherit;
    }
    .info-field input.edit-input:read-only {
        cursor: default;
    }

    /* Buttons */
    .btn-edit-profile {
        padding: 8px 20px;
        border-radius: 8px;
        font-size: 0.85rem;
        font-weight: 600;
        border: 1px solid #e2e8f0;
        background: white;
        color: #4a5568;
        cursor: pointer;
        transition: all 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .btn-edit-profile:hover {
        border-color: #4361ee;
        color: #4361ee;
        background: rgba(67, 97, 238, 0.04);
    }
    .btn-save-profile {
        padding: 10px 28px;
        border-radius: 10px;
        font-size: 0.9rem;
        font-weight: 700;
        border: none;
        background: linear-gradient(135deg, #4361ee, #4895ef);
        color: white;
        cursor: pointer;
        transition: all 0.3s;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 4px 15px rgba(67, 97, 238, 0.3);
    }
    .btn-save-profile:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(67, 97, 238, 0.4);
    }

    /* Quick Links */
    .quick-links {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
        margin-top: 24px;
    }
    .quick-link-card {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 18px 20px;
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        text-decoration: none;
        color: inherit;
        transition: all 0.2s;
    }
    .quick-link-card:hover {
        border-color: #4361ee;
        box-shadow: 0 4px 12px rgba(67, 97, 238, 0.08);
        transform: translateY(-2px);
    }
    .quick-link-card .ql-icon {
        width: 42px; height: 42px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
    }
    .quick-link-card h6 { margin: 0; font-weight: 700; font-size: 0.88rem; color: #2d3748; }
    .quick-link-card p { margin: 2px 0 0; font-size: 0.76rem; color: #8f9fbc; }

    /* Responsive */
    @media (max-width: 991px) {
        .profile-layout { flex-direction: column; }
        .profile-content { padding: 20px; }
        .profile-hero-inner { flex-direction: column; text-align: center; }
        .profile-hero-info .meta-row { justify-content: center; flex-wrap: wrap; }
    }
</style>

<script>
    function previewImage(event) {
        const reader = new FileReader();
        const avatar = document.getElementById('profileAvatar');
        const placeholder = document.getElementById('avatarPlaceholder');
        
        reader.onload = function() {
            if (avatar) {
                avatar.src = reader.result;
                avatar.style.display = 'block';
            }
            if (placeholder) placeholder.style.display = 'none';
            console.log("Ảnh mới đã sẵn sàng để upload!");
        }
        
        if (event.target.files[0]) {
            reader.readAsDataURL(event.target.files[0]);
        }
    }

    function toggleEdit() {
        const inputs = document.querySelectorAll('.edit-input[name]');
        const saveBtn = document.getElementById('saveBtn');
        const editBtn = document.getElementById('editBtn');
        const fieldValues = document.querySelectorAll('.field-value.can-edit');
        
        inputs.forEach(input => {
            if (input.hasAttribute('readonly')) {
                input.removeAttribute('readonly');
            } else {
                input.setAttribute('readonly', true);
            }
        });

        fieldValues.forEach(fv => fv.classList.toggle('editable'));

        if (saveBtn.classList.contains('d-none')) {
            saveBtn.classList.remove('d-none');
            editBtn.innerHTML = '<i class="fas fa-times"></i> Hủy';
        } else {
            saveBtn.classList.add('d-none');
            editBtn.innerHTML = '<i class="fas fa-edit"></i> Chỉnh sửa';
        }
    }
</script>

<div class="profile-layout">
    <!-- Sidebar: tự chọn đúng sidebar dựa trên roleId -->
    <c:choose>
        <c:when test="${sessionScope.currentUser.roleId == 1}">
            <jsp:include page="admin/sidebar.jsp">
                <jsp:param name="activeMenu" value="profile" />
            </jsp:include>
        </c:when>
        <c:otherwise>
            <jsp:include page="employee/sidebar.jsp">
                <jsp:param name="activeMenu" value="profile" />
            </jsp:include>
        </c:otherwise>
    </c:choose>

    <!-- Main Content -->
    <div class="profile-content">

        <!-- Alert Messages -->
        <c:if test="${not empty msgSuccess}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 12px; background: #d1fae5; color: #065f46;">
                <i class="fas fa-check-circle me-2"></i> ${msgSuccess}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty msgError}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 12px; background: #fee2e2; color: #991b1b;">
                <i class="fas fa-exclamation-triangle me-2"></i> ${msgError}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Page Header -->
        <div class="profile-page-header">
            <div>
                <h1 class="profile-page-title">Hồ sơ cá nhân</h1>
                <p class="profile-breadcrumb">
                    <a href="${pageContext.request.contextPath}/home">Trang chủ</a> &nbsp;>&nbsp; Hồ sơ cá nhân
                </p>
            </div>
        </div>

        <!-- Profile Hero -->
        <div class="profile-hero">
            <div class="profile-hero-inner">
                <div class="profile-avatar-wrap">
                    <c:choose>
                        <c:when test="${not empty displayUser.avatarUrl}">
                            <img src="${displayUser.avatarUrl}" id="profileAvatar" alt="Avatar">
                        </c:when>
                        <c:otherwise>
                            <div class="avatar-placeholder" id="avatarPlaceholder">
                                ${displayUser.fullName.substring(0,1)}
                            </div>
                            <img src="" id="profileAvatar" alt="Avatar" style="display:none; width:100px; height:100px; border-radius:16px; object-fit:cover; border:3px solid rgba(255,255,255,0.3); box-shadow: 0 8px 20px rgba(0,0,0,0.2);">
                        </c:otherwise>
                    </c:choose>
                    <label for="avatarUpload" class="avatar-upload-btn">
                        <i class="fas fa-camera"></i>
                    </label>
                    <input type="file" id="avatarUpload" class="d-none" accept="image/*" onchange="previewImage(event)">
                </div>
                <div class="profile-hero-info">
                    <span class="role-badge">
                        <i class="fas fa-shield-alt me-1"></i>
                        <c:choose>
                            <c:when test="${displayUser.roleId == 1}">Quản trị viên</c:when>
                            <c:when test="${displayUser.roleId == 2}">Quản lý</c:when>
                            <c:when test="${displayUser.roleId == 4}">HR Staff</c:when>
                            <c:when test="${displayUser.roleId == 5}">Kế toán</c:when>
                            <c:when test="${displayUser.roleId == 6}">Trưởng phòng</c:when>
                            <c:otherwise>Nhân viên</c:otherwise>
                        </c:choose>
                    </span>
                    <h2>${displayUser.fullName}</h2>
                    <div class="meta-row">
                        <span><i class="fas fa-envelope"></i> ${displayUser.email}</span>
                        <c:if test="${not empty displayUser.phone}">
                            <span><i class="fas fa-phone"></i> ${displayUser.phone}</span>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <!-- Info Card -->
        <div class="info-card">
            <div class="info-card-header">
                <h3 class="info-card-title">
                    <span class="icon-box" style="background: rgba(67, 97, 238, 0.1); color: #4361ee;">
                        <i class="fas fa-user"></i>
                    </span>
                    Thông tin cá nhân
                </h3>
                <button class="btn-edit-profile" onclick="toggleEdit()" id="editBtn">
                    <i class="fas fa-edit"></i> Chỉnh sửa
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/profile" method="POST">
                <input type="hidden" name="action" value="update_profile">

                <div class="row">
                    <div class="col-md-6">
                        <div class="info-field">
                            <label>Họ và tên</label>
                            <div class="field-value can-edit">
                                <i class="fas fa-user"></i>
                                <input type="text" class="edit-input" name="fullName" value="${displayUser.fullName}" readonly>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="info-field">
                            <label>Email</label>
                            <div class="field-value">
                                <i class="fas fa-envelope"></i>
                                <input type="email" class="edit-input" value="${displayUser.email}" disabled style="color: #8f9fbc;">
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="info-field">
                            <label>Số điện thoại</label>
                            <div class="field-value can-edit">
                                <i class="fas fa-phone"></i>
                                <input type="tel" class="edit-input" name="phone" value="${displayUser.phone}" readonly>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="info-field">
                            <label>Mã nhân viên</label>
                            <div class="field-value">
                                <i class="fas fa-id-card"></i>
                                <span>EMP-${displayUser.userId}</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="info-field">
                            <label>Vai trò</label>
                            <div class="field-value">
                                <i class="fas fa-user-tag"></i>
                                <span>
                                    <c:choose>
                                        <c:when test="${displayUser.roleId == 1}">Quản trị viên (Admin)</c:when>
                                        <c:when test="${displayUser.roleId == 2}">Quản lý (Manager)</c:when>
                                        <c:when test="${displayUser.roleId == 4}">HR Staff</c:when>
                                        <c:when test="${displayUser.roleId == 5}">Kế toán (Accountant)</c:when>
                                        <c:when test="${displayUser.roleId == 6}">Trưởng phòng (Dept. Head)</c:when>
                                        <c:otherwise>Nhân viên (Employee)</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="info-field">
                            <label>Trạng thái</label>
                            <div class="field-value">
                                <i class="fas fa-circle" style="font-size: 8px; color: ${displayUser.status == 1 ? '#38a169' : '#e53e3e'};"></i>
                                <span>${displayUser.status == 1 ? 'Đang làm việc' : 'Ngừng hoạt động'}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-end mt-2">
                    <button type="submit" class="btn-save-profile d-none" id="saveBtn">
                        <i class="fas fa-save"></i> Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>

        <!-- Quick Navigation Links -->
        <div class="quick-links">
            <a href="${pageContext.request.contextPath}/work-history" class="quick-link-card">
                <div class="ql-icon" style="background: #ebf8ff; color: #3182ce;">
                    <i class="fas fa-briefcase"></i>
                </div>
                <div>
                    <h6>Lịch sử công tác</h6>
                    <p>Xem quá trình làm việc</p>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/settings" class="quick-link-card">
                <div class="ql-icon" style="background: #fff5f5; color: #e53e3e;">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <div>
                    <h6>Cài đặt bảo mật</h6>
                    <p>Đổi mật khẩu, bảo mật tài khoản</p>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/employee/dashboard" class="quick-link-card">
                <div class="ql-icon" style="background: #f0fff4; color: #38a169;">
                    <i class="fas fa-chart-pie"></i>
                </div>
                <div>
                    <h6>Bảng điều khiển</h6>
                    <p>Quay lại trang chính</p>
                </div>
            </a>
        </div>

    </div><!-- end .profile-content -->
</div><!-- end .profile-layout -->

<jsp:include page="footer.jsp" />
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Cài đặt bảo mật - HRM" scope="request" />
<jsp:include page="header.jsp" />

<style>
    body { background-color: #f0f4f8; }

    .settings-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .settings-content {
        flex: 1;
        padding: 30px;
        overflow-y: auto;
        max-width: 900px;
    }

    /* Page Header */
    .settings-page-header {
        margin-bottom: 24px;
    }
    .settings-page-title {
        font-size: 1.4rem;
        font-weight: 700;
        color: #2b2b2b;
        margin: 0;
    }
    .settings-breadcrumb {
        font-size: 0.85rem;
        color: #8f9fbc;
        margin: 4px 0 0;
    }
    .settings-breadcrumb a { color: #4361ee; text-decoration: none; }

    /* Settings Card */
    .settings-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 28px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        margin-bottom: 24px;
    }
    .settings-card-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #edf2f7;
    }
    .settings-card-header .icon-box {
        width: 40px; height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
    }
    .settings-card-header h3 {
        margin: 0;
        font-size: 1.05rem;
        font-weight: 700;
        color: #2d3748;
    }
    .settings-card-header p {
        margin: 2px 0 0;
        font-size: 0.8rem;
        color: #8f9fbc;
    }

    /* Password Form */
    .password-field {
        margin-bottom: 18px;
    }
    .password-field label {
        display: block;
        font-size: 0.82rem;
        font-weight: 700;
        color: #4a5568;
        margin-bottom: 6px;
    }
    .password-input-wrap {
        position: relative;
    }
    .password-input-wrap input {
        width: 100%;
        padding: 12px 44px 12px 16px;
        border: 1.5px solid #e2e8f0;
        border-radius: 10px;
        font-size: 0.95rem;
        font-family: inherit;
        color: #2d3748;
        background: #f8fafc;
        transition: all 0.2s;
    }
    .password-input-wrap input:focus {
        outline: none;
        border-color: #4361ee;
        background: #fff;
        box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.08);
    }
    .password-toggle {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #8f9fbc;
        cursor: pointer;
        padding: 4px;
        font-size: 0.9rem;
        transition: color 0.2s;
    }
    .password-toggle:hover { color: #4361ee; }

    /* Password Strength */
    .password-strength {
        display: flex;
        gap: 4px;
        margin-top: 8px;
    }
    .strength-bar {
        height: 4px;
        flex: 1;
        border-radius: 2px;
        background: #e2e8f0;
        transition: background 0.3s;
    }
    .strength-bar.active.weak { background: #e53e3e; }
    .strength-bar.active.medium { background: #dd6b20; }
    .strength-bar.active.strong { background: #38a169; }
    .strength-text {
        font-size: 0.75rem;
        font-weight: 600;
        margin-top: 4px;
    }

    /* Submit Button */
    .btn-change-password {
        padding: 12px 28px;
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
    .btn-change-password:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(67, 97, 238, 0.4);
    }

    /* Notification Settings */
    .notif-option {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 16px 0;
        border-bottom: 1px solid #f1f5f9;
    }
    .notif-option:last-child { border-bottom: none; }
    .notif-option-info h6 {
        margin: 0;
        font-size: 0.9rem;
        font-weight: 700;
        color: #2d3748;
    }
    .notif-option-info p {
        margin: 2px 0 0;
        font-size: 0.8rem;
        color: #8f9fbc;
    }

    /* Toggle Switch */
    .toggle-switch {
        position: relative;
        width: 44px;
        height: 24px;
        flex-shrink: 0;
    }
    .toggle-switch input { opacity: 0; width: 0; height: 0; }
    .toggle-slider {
        position: absolute;
        top: 0; left: 0; right: 0; bottom: 0;
        background: #cbd5e0;
        border-radius: 24px;
        cursor: pointer;
        transition: background 0.3s;
    }
    .toggle-slider::before {
        content: '';
        position: absolute;
        width: 18px; height: 18px;
        left: 3px; bottom: 3px;
        background: white;
        border-radius: 50%;
        transition: transform 0.3s;
        box-shadow: 0 1px 3px rgba(0,0,0,0.15);
    }
    .toggle-switch input:checked + .toggle-slider {
        background: #4361ee;
    }
    .toggle-switch input:checked + .toggle-slider::before {
        transform: translateX(20px);
    }

    /* Security Info */
    .security-info {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 16px;
        background: #f8fafc;
        border-radius: 12px;
        border: 1px solid #edf2f7;
    }
    .security-info .si-icon {
        width: 40px; height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        font-size: 0.9rem;
    }
    .security-info h6 { margin: 0; font-size: 0.85rem; font-weight: 700; color: #2d3748; }
    .security-info p { margin: 2px 0 0; font-size: 0.78rem; color: #8f9fbc; }

    /* Responsive */
    @media (max-width: 991px) {
        .settings-layout { flex-direction: column; }
        .settings-content { padding: 20px; max-width: 100%; }
    }
</style>

<div class="settings-layout">
    <!-- Sidebar -->
    <c:choose>
        <c:when test="${sessionScope.currentUser.roleId == 1}">
            <jsp:include page="admin/sidebar.jsp">
                <jsp:param name="activeMenu" value="settings" />
            </jsp:include>
        </c:when>
        <c:otherwise>
            <jsp:include page="employee/sidebar.jsp">
                <jsp:param name="activeMenu" value="settings" />
            </jsp:include>
        </c:otherwise>
    </c:choose>

    <!-- Main Content -->
    <div class="settings-content">

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
        <div class="settings-page-header">
            <h1 class="settings-page-title">Cài đặt bảo mật</h1>
            <p class="settings-breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Trang chủ</a> &nbsp;>&nbsp; Cài đặt bảo mật
            </p>
        </div>

        <!-- 1. Change Password Card -->
        <div class="settings-card">
            <div class="settings-card-header">
                <div class="icon-box" style="background: rgba(229, 62, 62, 0.1); color: #e53e3e;">
                    <i class="fas fa-key"></i>
                </div>
                <div>
                    <h3>Đổi mật khẩu</h3>
                    <p>Cập nhật mật khẩu để bảo vệ tài khoản của bạn</p>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/changePassword" method="POST" id="changePasswordForm">
                <div class="password-field">
                    <label>Mật khẩu hiện tại</label>
                    <div class="password-input-wrap">
                        <input type="password" name="oldPassword" id="oldPassword" required placeholder="Nhập mật khẩu hiện tại">
                        <button type="button" class="password-toggle" onclick="togglePassword('oldPassword', this)">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="password-field">
                    <label>Mật khẩu mới</label>
                    <div class="password-input-wrap">
                        <input type="password" name="newPassword" id="newPassword" required minlength="6" placeholder="Nhập mật khẩu mới (tối thiểu 6 ký tự)" oninput="checkStrength(this.value)">
                        <button type="button" class="password-toggle" onclick="togglePassword('newPassword', this)">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                    <div class="password-strength" id="strengthBars">
                        <div class="strength-bar"></div>
                        <div class="strength-bar"></div>
                        <div class="strength-bar"></div>
                        <div class="strength-bar"></div>
                    </div>
                    <div class="strength-text" id="strengthText"></div>
                </div>

                <div class="password-field">
                    <label>Xác nhận mật khẩu mới</label>
                    <div class="password-input-wrap">
                        <input type="password" name="confirmPassword" id="confirmPassword" required minlength="6" placeholder="Nhập lại mật khẩu mới">
                        <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword', this)">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="d-flex justify-content-end mt-3">
                    <button type="submit" class="btn-change-password">
                        <i class="fas fa-check"></i> Xác nhận đổi mật khẩu
                    </button>
                </div>
            </form>
        </div>

        <!-- 2. Notification Settings Card -->
        <div class="settings-card">
            <div class="settings-card-header">
                <div class="icon-box" style="background: rgba(49, 130, 206, 0.1); color: #3182ce;">
                    <i class="fas fa-bell"></i>
                </div>
                <div>
                    <h3>Cài đặt thông báo</h3>
                    <p>Quản lý cách bạn nhận thông báo từ hệ thống</p>
                </div>
            </div>

            <div class="notif-option">
                <div class="notif-option-info">
                    <h6><i class="fas fa-envelope me-2 text-primary"></i>Thông báo qua Email</h6>
                    <p>Nhận email khi có đơn nghỉ phép được duyệt, bảng lương mới, v.v.</p>
                </div>
                <label class="toggle-switch">
                    <input type="checkbox" checked>
                    <span class="toggle-slider"></span>
                </label>
            </div>

            <div class="notif-option">
                <div class="notif-option-info">
                    <h6><i class="fas fa-desktop me-2 text-success"></i>Thông báo trên Hệ thống</h6>
                    <p>Hiển thị thông báo trong chuông thông báo khi đăng nhập</p>
                </div>
                <label class="toggle-switch">
                    <input type="checkbox" checked>
                    <span class="toggle-slider"></span>
                </label>
            </div>

            <div class="notif-option">
                <div class="notif-option-info">
                    <h6><i class="fas fa-bullhorn me-2 text-warning"></i>Thông báo nội bộ</h6>
                    <p>Nhận thông báo về tin tức, sự kiện công ty</p>
                </div>
                <label class="toggle-switch">
                    <input type="checkbox" checked>
                    <span class="toggle-slider"></span>
                </label>
            </div>

            <div class="notif-option">
                <div class="notif-option-info">
                    <h6><i class="fas fa-calendar-check me-2 text-info"></i>Nhắc nhở chấm công</h6>
                    <p>Nhận nhắc nhở khi quên chấm công vào/ra</p>
                </div>
                <label class="toggle-switch">
                    <input type="checkbox">
                    <span class="toggle-slider"></span>
                </label>
            </div>
        </div>

        <!-- 3. Session Info Card -->
        <div class="settings-card">
            <div class="settings-card-header">
                <div class="icon-box" style="background: rgba(56, 161, 105, 0.1); color: #38a169;">
                    <i class="fas fa-laptop"></i>
                </div>
                <div>
                    <h3>Phiên đăng nhập</h3>
                    <p>Quản lý các thiết bị đang đăng nhập tài khoản của bạn</p>
                </div>
            </div>

            <div class="security-info mb-3">
                <div class="si-icon" style="background: rgba(56, 161, 105, 0.1); color: #38a169;">
                    <i class="fas fa-desktop"></i>
                </div>
                <div style="flex: 1;">
                    <h6><i class="fas fa-circle text-success me-1" style="font-size: 6px; vertical-align: middle;"></i> Thiết bị hiện tại</h6>
                    <p>Trình duyệt web · Đăng nhập gần nhất: Hôm nay</p>
                </div>
                <span class="badge" style="background: #d1fae5; color: #065f46; font-size: 0.72rem; padding: 4px 10px; border-radius: 6px;">Đang hoạt động</span>
            </div>

            <div class="text-muted" style="font-size: 0.82rem; padding: 12px 0;">
                <i class="fas fa-info-circle me-1"></i>
                Nếu bạn phát hiện phiên đăng nhập bất thường, hãy đổi mật khẩu ngay lập tức.
            </div>
        </div>

    </div><!-- end .settings-content -->
</div><!-- end .settings-layout -->

<script>
    // Toggle password visibility
    function togglePassword(inputId, btn) {
        const input = document.getElementById(inputId);
        const icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    }

    // Password strength checker
    function checkStrength(password) {
        const bars = document.querySelectorAll('#strengthBars .strength-bar');
        const text = document.getElementById('strengthText');
        let strength = 0;

        if (password.length >= 6) strength++;
        if (password.length >= 10) strength++;
        if (/[A-Z]/.test(password) && /[a-z]/.test(password)) strength++;
        if (/[0-9]/.test(password) && /[^A-Za-z0-9]/.test(password)) strength++;

        const levels = ['', 'Yếu', 'Trung bình', 'Khá', 'Mạnh'];
        const colors = ['', 'weak', 'medium', 'medium', 'strong'];
        const textColors = ['', '#e53e3e', '#dd6b20', '#dd6b20', '#38a169'];

        bars.forEach((bar, i) => {
            bar.className = 'strength-bar';
            if (i < strength) {
                bar.classList.add('active', colors[strength]);
            }
        });

        if (password.length > 0) {
            text.textContent = 'Độ mạnh: ' + levels[strength];
            text.style.color = textColors[strength];
        } else {
            text.textContent = '';
        }
    }

    // Client-side form validation
    document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
        const newPwd = document.getElementById('newPassword').value;
        const confirmPwd = document.getElementById('confirmPassword').value;

        if (newPwd !== confirmPwd) {
            e.preventDefault();
            alert('Mật khẩu mới và xác nhận không khớp!');
            document.getElementById('confirmPassword').focus();
        }
    });
</script>

<jsp:include page="footer.jsp" />

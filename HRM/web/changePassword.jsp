<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Đổi mật khẩu - HRM" scope="request" />
<jsp:include page="header.jsp" />

<style>
    body { background-color: var(--th-bg); }
    
    .cp-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    
    .cp-content {
        flex: 1;
        padding: 30px;
        overflow-y: auto;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .cp-card {
        background: var(--th-surface);
        border: 1px solid var(--th-border);
        border-radius: 16px;
        padding: 40px;
        width: 100%;
        max-width: 500px;
        box-shadow: var(--th-card-shadow);
    }
    
    .cp-header {
        text-align: center;
        margin-bottom: 30px;
    }
    .cp-icon {
        width: 56px; height: 56px;
        background: rgba(229, 62, 62, 0.1);
        color: #e53e3e;
        border-radius: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        margin: 0 auto 16px;
    }
    .cp-header h3 {
        margin: 0;
        font-size: 1.4rem;
        font-weight: 700;
        color: var(--th-text);
    }
    .cp-header p {
        margin: 6px 0 0;
        font-size: 0.85rem;
        color: var(--th-muted);
    }

    /* Password Form */
    .password-field {
        margin-bottom: 20px;
    }
    .password-field label {
        display: block;
        font-size: 0.85rem;
        font-weight: 700;
        color: var(--th-text);
        margin-bottom: 8px;
    }
    .password-input-wrap {
        position: relative;
    }
    .password-input-wrap input {
        width: 100%;
        padding: 12px 44px 12px 16px;
        border: 1.5px solid var(--th-border);
        border-radius: 10px;
        font-size: 0.95rem;
        font-family: inherit;
        color: var(--th-text);
        background: var(--th-surface2);
        transition: all 0.2s;
    }
    .password-input-wrap input:focus {
        outline: none;
        border-color: #4361ee;
        background: var(--th-surface);
        box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.08);
    }
    .password-toggle {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: var(--th-muted);
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
        background: var(--th-border);
        transition: background 0.3s;
    }
    .strength-bar.active.weak { background: #e53e3e; }
    .strength-bar.active.medium { background: #dd6b20; }
    .strength-bar.active.strong { background: #38a169; }
    .strength-text {
        font-size: 0.75rem;
        font-weight: 600;
        margin-top: 6px;
    }

    /* Submit Button */
    .btn-change-password {
        width: 100%;
        padding: 14px;
        border-radius: 10px;
        font-size: 0.95rem;
        font-weight: 700;
        border: none;
        background: linear-gradient(135deg, #4361ee, #4895ef);
        color: white;
        cursor: pointer;
        transition: all 0.3s;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        box-shadow: 0 4px 15px rgba(67, 97, 238, 0.3);
        margin-top: 10px;
    }
    .btn-change-password:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(67, 97, 238, 0.4);
    }
    
    .btn-back {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        color: var(--th-muted);
        text-decoration: none;
        font-size: 0.85rem;
        font-weight: 600;
        margin-bottom: 20px;
        transition: color 0.2s;
    }
    .btn-back:hover {
        color: var(--th-text);
    }
</style>

<div class="cp-layout">
    <div class="cp-content">
        <div>
            <a href="${pageContext.request.contextPath}/settings.jsp" class="btn-back">
                <i class="fas fa-arrow-left"></i> Quay lại cài đặt
            </a>
            <div class="cp-card">
                <div class="cp-header">
                    <div class="cp-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h3>Đổi mật khẩu</h3>
                    <p>Mật khẩu của bạn nên có ít nhất 6 ký tự, bao gồm cả chữ và số để tăng cường bảo mật.</p>
                </div>
                
                <!-- Alert Messages -->
                <c:if test="${not empty msgSuccess}">
                    <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #d1fae5; color: #065f46; font-size: 0.85rem;">
                        <i class="fas fa-check-circle me-2"></i> ${msgSuccess}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="padding: 1rem;"></button>
                    </div>
                </c:if>
                <c:if test="${not empty msgError}">
                    <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #fee2e2; color: #991b1b; font-size: 0.85rem;">
                        <i class="fas fa-exclamation-triangle me-2"></i> ${msgError}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="padding: 1rem;"></button>
                    </div>
                </c:if>

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
                            <input type="password" name="newPassword" id="newPassword" required minlength="6" placeholder="Nhập mật khẩu mới" oninput="checkStrength(this.value)">
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

                    <button type="submit" class="btn-change-password">
                        <i class="fas fa-save"></i> Cập nhật mật khẩu
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

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

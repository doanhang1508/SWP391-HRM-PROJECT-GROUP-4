
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập | Hệ thống HRM Nội bộ</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link
            href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&display=swap"
            rel="stylesheet">

        <style>
            *,
            *::before,
            *::after {
                box-sizing: border-box;
            }

            body {
                font-family: 'Be Vietnam Pro', sans-serif;
                min-height: 100vh;
                margin: 0;
                display: flex;
                background: #0a2540;
            }

            /* ── LEFT PANEL ── */
            .panel-left {
                width: 55%;
                min-height: 100vh;
                position: relative;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding: 50px 60px;
            }

            .panel-left-bg {
                position: absolute;
                inset: 0;
                background: url('https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?q=80&w=1200&auto=format&fit=crop') center/cover;
                filter: grayscale(30%) contrast(1.1);
            }

            .panel-left-overlay {
                position: absolute;
                inset: 0;
                background: linear-gradient(135deg, rgba(10, 37, 64, .88) 0%, rgba(10, 37, 64, .7) 100%);
            }

            .panel-left-content {
                position: relative;
                z-index: 2;
                color: #fff;
            }

            /* Logo */
            .login-logo {
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 800;
                font-size: 1rem;
                letter-spacing: 1px;
                text-transform: uppercase;
                color: #fff;
            }

            .login-logo i {
                color: #63b3ed;
            }

            /* Tagline */
            .panel-tagline {
                font-size: clamp(2rem, 3.5vw, 3rem);
                font-weight: 800;
                line-height: 1.1;
                letter-spacing: -1px;
                color: #fff;
                margin-bottom: 20px;
            }

            .panel-tagline em {
                color: #63b3ed;
                font-style: normal;
            }

            .panel-desc {
                color: rgba(255, 255, 255, .6);
                font-size: .95rem;
                line-height: 1.7;
                max-width: 400px;
                margin-bottom: 50px;
            }

            /* Stats */
            .panel-stats {
                display: flex;
                gap: 40px;
                padding-top: 30px;
                border-top: 1px solid rgba(255, 255, 255, .12);
            }

            .pstat-n {
                font-size: 1.8rem;
                font-weight: 800;
                color: #fff;
                letter-spacing: -1px;
                display: block;
            }

            .pstat-l {
                font-size: .75rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: rgba(255, 255, 255, .45);
            }

            /* ── RIGHT PANEL ── */
            .panel-right {
                width: 45%;
                min-height: 100vh;
                background: #f0ede8;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 60px 50px;
            }

            .form-box {
                width: 100%;
                max-width: 400px;
            }

            .form-heading {
                font-size: 1.8rem;
                font-weight: 800;
                color: #0a2540;
                letter-spacing: -1px;
                margin-bottom: 8px;
            }

            .form-subheading {
                color: #718096;
                font-size: .88rem;
                margin-bottom: 36px;
                line-height: 1.6;
            }

            .form-subheading a {
                color: #2b6cb0;
                font-weight: 600;
                text-decoration: none;
            }

            .form-subheading a:hover {
                text-decoration: underline;
            }

            /* Error */
            .alert-error {
                background: #fff5f5;
                border-left: 3px solid #e53e3e;
                color: #c53030;
                padding: 12px 16px;
                font-size: .85rem;
                margin-bottom: 24px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            /* Input fields */
            .field-label {
                font-size: .8rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: #4a5568;
                margin-bottom: 8px;
                display: block;
            }

            .field-wrap {
                position: relative;
                margin-bottom: 20px;
            }

            .field-wrap i.field-icon {
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                color: #a0aec0;
                font-size: .85rem;
                pointer-events: none;
            }

            .field-input {
                width: 100%;
                border: 1px solid #e2e8f0;
                background: #fff;
                padding: 13px 16px 13px 40px;
                font-family: 'Be Vietnam Pro', sans-serif;
                font-size: .9rem;
                color: #1a202c;
                outline: none;
                transition: border-color .2s, box-shadow .2s;
                border-radius: 0;
                appearance: none;
            }

            .field-input:focus {
                border-color: #0a2540;
                box-shadow: 0 0 0 3px rgba(10, 37, 64, .08);
            }

            .field-input::placeholder {
                color: #c4cdd8;
            }

            .eye-toggle {
                position: absolute;
                right: 14px;
                top: 50%;
                transform: translateY(-50%);
                background: none;
                border: none;
                cursor: pointer;
                color: #a0aec0;
                padding: 0;
                font-size: .85rem;
            }

            .eye-toggle:hover {
                color: #4a5568;
            }

            .field-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 8px;
            }

            /* Checkbox */
            .check-wrap {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 28px;
            }

            .check-box {
                width: 16px;
                height: 16px;
                accent-color: #0a2540;
                cursor: pointer;
            }

            .check-label {
                font-size: .85rem;
                color: #4a5568;
                cursor: pointer;
            }

            /* Submit button */
            .btn-submit {
                width: 100%;
                background: #0a2540;
                color: #fff;
                border: none;
                padding: 14px;
                font-family: 'Be Vietnam Pro', sans-serif;
                font-size: .95rem;
                font-weight: 700;
                letter-spacing: .5px;
                cursor: pointer;
                transition: all .3s;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
            }

            .btn-submit:hover {
                background: #1a365d;
            }

            /* Divider */
            .divider {
                display: flex;
                align-items: center;
                gap: 12px;
                margin: 24px 0;
                color: #c4cdd8;
                font-size: .8rem;
            }

            .divider::before,
            .divider::after {
                content: '';
                flex: 1;
                height: 1px;
                background: #e2e8f0;
            }

            /* Google */
            .btn-google {
                width: 100%;
                background: #fff;
                color: #4a5568;
                border: 1px solid #e2e8f0;
                padding: 13px;
                font-family: 'Be Vietnam Pro', sans-serif;
                font-size: .88rem;
                font-weight: 600;
                cursor: pointer;
                transition: all .2s;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                text-decoration: none;
                border-radius: 0;
            }

            .btn-google:hover {
                background: #f7f7f7;
                border-color: #c4cdd8;
                color: #1a202c;
            }

            /* Back link */
            .back-link {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                margin-top: 28px;
                color: #a0aec0;
                font-size: .82rem;
                font-weight: 500;
                text-decoration: none;
                transition: color .2s;
            }

            .back-link:hover {
                color: #0a2540;
            }

            @media (max-width: 768px) {
                body {
                    display: block;
                }

                .panel-left {
                    display: none;
                }

                .panel-right {
                    width: 100%;
                    min-height: 100vh;
                    padding: 40px 24px;
                }
            }
        </style>
    </head>

    <body>

        <!-- LEFT PANEL -->
        <div class="panel-left">
            <div class="panel-left-bg"></div>
            <div class="panel-left-overlay"></div>

            <!-- Top logo -->
            <div class="panel-left-content">
                <div class="login-logo">
                    <i class="fas fa-industry"></i>
                    <span>Tập đoàn HRM</span>
                </div>
            </div>

            <!-- Center text -->
            <div class="panel-left-content">
                <h1 class="panel-tagline">
                    Cổng Nội Bộ<br>
                    <em>Dành Riêng</em><br>
                    Cho Bạn.
                </h1>
                <p class="panel-desc">
                    Đăng nhập để truy cập bảng lương, lịch ca kíp, nghỉ phép và toàn bộ thông tin nhân sự của bạn
                    tại một nơi duy nhất.
                </p>

                <div class="panel-stats">
                    <div>
                        <span class="pstat-n">24/7</span>
                        <span class="pstat-l">Vận hành</span>
                    </div>
                    <div>
                        <span class="pstat-n">99.9%</span>
                        <span class="pstat-l">Uptime</span>
                    </div>
                    <div>
                        <span class="pstat-n">10K+</span>
                        <span class="pstat-l">Nhân sự</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- RIGHT PANEL -->
        <div class="panel-right">
            <div class="form-box">

                <h2 class="form-heading">Đăng nhập</h2>
                <p class="form-subheading">
                    Chưa có tài khoản?
                    <a href="${pageContext.request.contextPath}/register">Liên hệ Phòng HCNS</a>
                </p>

                <!-- Error message -->
                <c:if test="${not empty errorMsg}">   
                    <div class="alert-error">
                        <i class="fas fa-exclamation-circle"></i>
                        ${errorMsg}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="post">
                    <!-- Email -->
                    <div>
                        <label class="field-label">Email công việc</label>
                        <div class="field-wrap">
                            <i class="fas fa-envelope field-icon"></i>
                            <input type="email" name="email" class="field-input"
                                   placeholder="nguyenvana@company.com" required value="${email}">
                        </div>
                    </div>

                    <!-- Password -->
                    <div>
                        <div class="field-row">
                            <label class="field-label" style="margin-bottom:0">Mật khẩu</label>
                            <a href="${pageContext.request.contextPath}/forgot-password"
                               style="font-size:.8rem;color:#2b6cb0;font-weight:600;text-decoration:none">Quên mật
                                khẩu?</a>
                        </div>
                        <div class="field-wrap">
                            <i class="fas fa-lock field-icon"></i>
                            <input type="password" id="passwordInput" name="password" class="field-input"
                                   placeholder="Nhập mật khẩu" required>
                            <button type="button" class="eye-toggle" onclick="togglePassword()">
                                <i class="fas fa-eye" id="eyeIcon"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Remember -->
                    <div class="check-wrap">
                        <input type="checkbox" class="check-box" id="remember" name="remember" ${rememberChecked}>
                        <label class="check-label" for="remember">Ghi nhớ phiên đăng nhập</label>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fas fa-sign-in-alt"></i> Truy cập Hệ thống
                    </button>
                </form>

                <div class="divider">hoặc</div>

                <a href="${not empty googleLoginUrl ? googleLoginUrl : '#'}" class="btn-google">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg"
                         width="18" alt="Google">
                    Đăng nhập bằng Google (SSO)
                </a>

                <a href="${pageContext.request.contextPath}/home" class="back-link">
                    <i class="fas fa-arrow-left"></i> Quay về Cổng thông tin
                </a>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                function togglePassword() {
                                    const input = document.getElementById('passwordInput');
                                    const icon = document.getElementById('eyeIcon');
                                    if (input.type === 'password') {
                                        input.type = 'text';
                                        icon.classList.replace('fa-eye', 'fa-eye-slash');
                                    } else {
                                        input.type = 'password';
                                        icon.classList.replace('fa-eye-slash', 'fa-eye');
                                    }
                                }
        </script>
    </body>

</html>

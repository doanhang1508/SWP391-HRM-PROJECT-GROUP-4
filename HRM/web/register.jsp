<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký nhân viên | Group4 HRM</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            min-height: 100vh; margin: 0; display: flex; align-items: center; justify-content: center;
            background-color: #f8f9ff;
            background-image: radial-gradient(at 0% 0%, #e0c3fc 0, transparent 50%), radial-gradient(at 100% 0%, #fbc2eb 0, transparent 50%);
            position: relative; overflow: hidden; padding: 2rem 0;
        }

        /* Bong bóng 3D */
        .bubble {
            position: absolute; border-radius: 50%; background: rgba(255, 255, 255, 0.4);
            box-shadow: inset -10px -10px 15px rgba(0,0,0,0.05), inset 10px 10px 15px rgba(255,255,255,0.8), 0 20px 30px rgba(0,0,0,0.05);
            backdrop-filter: blur(2px); animation: floatUp 15s linear infinite; z-index: 1;
        }
        .bubble::after { content: ''; position: absolute; top: 20%; left: 25%; width: 25%; height: 20%; background: rgba(255, 255, 255, 0.6); border-radius: 50%; transform: rotate(-30deg); }
        @keyframes floatUp { 0% { transform: translateY(110vh) translateX(0); opacity: 0; } 50% { opacity: 0.8; } 100% { transform: translateY(-20vh) translateX(50px); opacity: 0; } }

        /* Khung Card bao ngoài */
        .login-wrapper {
            position: relative; z-index: 10; background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5); border-radius: 24px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
            width: 100%; max-width: 1000px; overflow: hidden;
        }

        /* CỘT TRÁI (BANNER) */
        .auth-banner {
            position: relative; padding: 3rem; color: white; display: flex; flex-direction: column; justify-content: space-between;
            min-height: 100%; background: url('https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=1000&auto=format&fit=crop') center/cover;
        }
        .auth-banner-overlay {
            position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(135deg, rgba(118, 75, 162, 0.9) 0%, rgba(216, 123, 189, 0.85) 100%); z-index: 1;
        }
        .auth-banner-content { position: relative; z-index: 2; }
        .auth-banner h2 { font-weight: 800; font-size: 2.2rem; letter-spacing: -1px; margin-bottom: 1rem; }
        .auth-banner p { font-size: 1.05rem; opacity: 0.9; font-weight: 500; line-height: 1.6; }

        /* CỘT PHẢI (FORM) */
        .auth-form-container {
            padding: 3rem 4rem; background: white; display: flex; flex-direction: column; justify-content: center;
            max-height: 90vh; overflow-y: auto; /* Cho phép cuộn nếu màn hình nhỏ */
        }
        
        /* Tùy chỉnh thanh cuộn cho form */
        .auth-form-container::-webkit-scrollbar { width: 6px; }
        .auth-form-container::-webkit-scrollbar-thumb { background: #d87bbd; border-radius: 10px; }

        .auth-title { font-weight: 800; color: #1a1a1a; letter-spacing: -1px; margin-bottom: 0.5rem; }
        .form-label { font-weight: 700; color: #111; margin-bottom: 0.4rem; font-size: 0.85rem; }
        .input-group-text { background: transparent; border-right: none; color: #666; }
        .form-control, .form-select { border-left: none; padding: 10px 16px 10px 0; font-weight: 600; color: #1a1a1a; }
        .input-group:focus-within { border-color: #764ba2; box-shadow: 0 0 0 0.2rem rgba(118, 75, 162, 0.15); border-radius: 6px; }
        .input-group:focus-within .input-group-text, .input-group:focus-within .form-control { border-color: #764ba2; }

        /* Mật khẩu & Lỗi */
        .strength-meter { display: flex; gap: 4px; margin-top: 8px; }
        .strength-bar { height: 4px; flex: 1; border-radius: 2px; background: #e5e7eb; transition: all 0.3s ease; }
        .strength-bar.weak { background: #ef4444; } .strength-bar.medium { background: #f59e0b; } .strength-bar.strong { background: #10b981; }
        
        .field-inline-error { display: block; color: #dc2626; font-size: 0.75rem; font-weight: 600; margin-top: 0.25rem; }
        .field-inline-ok { display: block; color: #059669; font-size: 0.75rem; font-weight: 600; margin-top: 0.25rem; }

        .btn-login-submit {
            background: linear-gradient(135deg, #764ba2 0%, #d87bbd 100%);
            border: none; color: white; font-weight: 700; padding: 12px; border-radius: 8px;
            box-shadow: 0 8px 20px rgba(118, 75, 162, 0.2); transition: 0.3s;
        }
        .btn-login-submit:hover { transform: translateY(-2px); box-shadow: 0 10px 25px rgba(118, 75, 162, 0.4); color: white; }
    </style>
</head>
<body>

    <div class="bubble" style="width: 120px; height: 120px; left: 5%; animation-duration: 18s;"></div>
    <div class="bubble" style="width: 80px; height: 80px; right: 10%; animation-duration: 15s; animation-delay: 2s;"></div>

    <div class="container d-flex justify-content-center">
        <div class="row g-0 login-wrapper">
            
            <div class="col-lg-5 auth-banner d-none d-lg-flex">
                <div class="auth-banner-overlay"></div>
                <div class="auth-banner-content">
                    <div class="d-inline-flex align-items-center gap-2 mb-4 bg-white bg-opacity-25 px-3 py-2 rounded-pill border border-white border-opacity-25">
                        <i class="fas fa-users-cog"></i> <span class="fw-bold">Group4 HRM</span>
                    </div>
                </div>
                <div class="auth-banner-content">
                    <h2>Gia nhập hệ thống!</h2>
                    <p>Tạo tài khoản để trải nghiệm nền tảng quản trị nhân sự tối ưu, hiện đại và minh bạch.</p>
                    <div class="mt-4">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="fas fa-check-circle fs-5" style="color: #fbc2eb;"></i> <span>Quản lý hồ sơ dễ dàng</span>
                        </div>
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="fas fa-check-circle fs-5" style="color: #fbc2eb;"></i> <span>Tự động hóa chấm công</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="fas fa-check-circle fs-5" style="color: #fbc2eb;"></i> <span>Theo dõi lương minh bạch</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-7 auth-form-container">
                <div class="text-center mb-4">
                    <h2 class="auth-title">Đăng ký tài khoản</h2>
                    <p class="text-muted small">
                        Đã có tài khoản? <a href="login" class="text-decoration-none fw-bold" style="color: #764ba2;">Đăng nhập ngay</a>
                    </p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger border-0 rounded-3 small mb-3 py-2" style="background: rgba(220, 53, 69, 0.1); color: #dc3545; font-weight: 700;">
                        <i class="fas fa-exclamation-circle me-2"></i> ${error}
                    </div>
                </c:if>

                <form id="registerForm" action="register" method="POST">
                    
                    <div class="mb-3">
                        <label class="form-label">Họ và tên</label>
                        <div class="input-group border rounded">
                            <span class="input-group-text"><i class="fas fa-user"></i></span>
                            <input type="text" name="fullName" required placeholder="Nguyễn Văn A" class="form-control" value="${param.fullName}">
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Email công ty</label>
                        <div class="input-group border rounded">
                            <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                            <input type="email" id="email" name="email" required placeholder="name@grupo4.com" class="form-control" value="${param.email}">
                        </div>
                        <small id="emailFeedback"></small>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Số điện thoại</label>
                        <div class="input-group border rounded">
                            <span class="input-group-text"><i class="fas fa-phone"></i></span>
                            <input type="tel" name="phone" placeholder="0901234567" class="form-control" value="${param.phone}">
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-6">
                            <label class="form-label">Ngày sinh</label>
                            <div class="input-group border rounded">
                                <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                                <input type="date" id="birthDate" name="birthDate" required class="form-control" value="${param.birthDate}">
                            </div>
                            <small id="birthDateFeedback"></small>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Giới tính</label>
                            <select name="gender" class="form-select border rounded" style="padding-left: 10px;">
                                <option value="" selected>Chọn</option>
                                <option value="1">Nam</option>
                                <option value="0">Nữ</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Mật khẩu</label>
                        <div class="input-group border rounded">
                            <span class="input-group-text"><i class="fas fa-lock"></i></span>
                            <input type="password" id="password" name="password" required placeholder="Tối thiểu 8 ký tự" class="form-control" onkeyup="checkStrength(this.value)">
                            <span class="input-group-text" style="cursor: pointer;" onclick="togglePassword('password', 'eyeIcon1')">
                                <i class="fas fa-eye text-muted" id="eyeIcon1"></i>
                            </span>
                        </div>
                        <div class="strength-meter">
                            <div class="strength-bar" id="bar1"></div><div class="strength-bar" id="bar2"></div>
                            <div class="strength-bar" id="bar3"></div><div class="strength-bar" id="bar4"></div>
                        </div>
                        <small id="strengthText" class="text-muted fw-bold mt-1 d-block"></small>
                    </div>

                    <div class="mb-4">
                        <label class="form-label">Xác nhận mật khẩu</label>
                        <div class="input-group border rounded">
                            <span class="input-group-text"><i class="fas fa-lock"></i></span>
                            <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Nhập lại mật khẩu" class="form-control">
                            <span class="input-group-text" style="cursor: pointer;" onclick="togglePassword('confirmPassword', 'eyeIcon2')">
                                <i class="fas fa-eye text-muted" id="eyeIcon2"></i>
                            </span>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-login-submit w-100 mb-3">
                        Tạo tài khoản nhân viên <i class="fas fa-arrow-right ms-2"></i>
                    </button>
                    
                    <div class="text-center">
                        <a href="home" class="text-decoration-none small text-muted fw-bold">
                            <i class="fas fa-arrow-left me-1"></i> Quay về trang chủ
                        </a>
                    </div>
                </form>
            </div>

        </div>
    </div>

    <script>
        // 1. Chức năng Ẩn/Hiện mật khẩu (đã sửa dùng chung cho cả 2 ô)
        function togglePassword(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        }

        // 2. Chức năng thanh đo độ mạnh mật khẩu
        function checkStrength(password) {
            let strength = 0;
            if (password.length >= 8) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            
            const bars = [document.getElementById('bar1'), document.getElementById('bar2'), document.getElementById('bar3'), document.getElementById('bar4')];
            const text = document.getElementById('strengthText');
            
            bars.forEach((bar, i) => {
                bar.className = 'strength-bar';
                if (i < strength) {
                    if (strength <= 1) bar.classList.add('weak');
                    else if (strength <= 2) bar.classList.add('medium');
                    else bar.classList.add('strong');
                }
            });
            
            if (strength === 0) text.textContent = '';
            else if (strength === 1) { text.textContent = 'Yếu (Nên thêm số và chữ hoa)'; text.className = 'small text-danger fw-bold'; }
            else if (strength === 2) { text.textContent = 'Trung bình'; text.className = 'small text-warning fw-bold'; }
            else if (strength >= 3) { text.textContent = 'Mạnh'; text.className = 'small text-success fw-bold'; }
        }

        // 3. Ràng buộc: Tuổi phải trên 16 (Dành cho người đi làm)
        const birthDateInput = document.getElementById('birthDate');
        if (birthDateInput) {
            const today = new Date();
            const maxDate = new Date(today.getFullYear() - 16, today.getMonth(), today.getDate());
            const maxDateStr = maxDate.toISOString().split('T')[0];
            birthDateInput.max = maxDateStr; // Khóa không cho chọn ngày quá 16 tuổi

            birthDateInput.addEventListener('change', function() {
                const feedback = document.getElementById('birthDateFeedback');
                const selected = new Date(this.value);
                if (selected > maxDate) {
                    feedback.textContent = 'Nhân viên phải từ 16 tuổi trở lên!';
                    feedback.className = 'field-inline-error';
                    this.style.borderColor = '#dc3545';
                } else {
                    feedback.textContent = '';
                    this.style.borderColor = '#10b981';
                }
            });
        }

        // 4. Gợi ý gõ sai đuôi Email (VD: @gamil.com -> @gmail.com)
        const emailInput = document.getElementById('email');
        if (emailInput) {
            emailInput.addEventListener('blur', function() {
                const email = this.value.trim().toLowerCase();
                const feedback = document.getElementById('emailFeedback');
                const typoMap = { 'mgail.com': 'gmail.com', 'gamil.com': 'gmail.com', 'gnail.com': 'gmail.com', 'yaho.com': 'yahoo.com' };
                
                if (email.includes('@')) {
                    const domain = email.split('@')[1];
                    if (typoMap[domain]) {
                        feedback.textContent = 'Có phải bạn muốn nhập: ' + email.split('@')[0] + '@' + typoMap[domain] + '?';
                        feedback.className = 'field-inline-error';
                        this.style.borderColor = '#f59e0b';
                        return;
                    }
                }
                feedback.textContent = '';
                this.style.borderColor = '#ddd';
            });
        }
    </script>
</body>
</html>
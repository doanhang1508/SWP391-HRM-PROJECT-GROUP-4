<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu | HRM System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; }
        body {
            font-family: 'Be Vietnam Pro', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #0a2540 0%, #1e3a5f 100%);
        }
        .card-forgot {
            background: white;
            border-radius: 20px;
            padding: 48px 40px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 25px 60px rgba(0,0,0,0.3);
        }
        .icon-circle {
            width: 70px; height: 70px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 28px; margin: 0 auto 24px;
        }
        .icon-circle.blue   { background: #e0f2fe; color: #0284c7; }
        .icon-circle.yellow { background: #fef9c3; color: #ca8a04; }
        .icon-circle.green  { background: #dcfce7; color: #16a34a; }
        .icon-circle.purple { background: #f3e8ff; color: #7c3aed; }
        .form-control-hrm {
            border: 1.5px solid #e2e8f0; border-radius: 10px;
            padding: 12px 16px; font-size: 15px;
            transition: all 0.2s; width: 100%;
        }
        .form-control-hrm:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
            outline: none;
        }
        .btn-primary-hrm {
            background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
            color: white; border: none; border-radius: 10px;
            padding: 13px; font-size: 15px; font-weight: 700;
            width: 100%; transition: all 0.2s; cursor: pointer;
        }
        .btn-primary-hrm:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(30,41,59,0.3);
        }
        .btn-primary-hrm:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        .otp-input {
            letter-spacing: 8px; font-size: 22px; font-weight: 800;
            text-align: center;
        }
        .step-badge {
            font-size: 12px; font-weight: 700; letter-spacing: 1px;
            color: #64748b; text-transform: uppercase; margin-bottom: 8px;
            text-align: center;
        }
        a.back-link { color: #64748b; text-decoration: none; font-size: 14px; }
        a.back-link:hover { color: #1e293b; }
        label { font-weight: 600; font-size: 14px; margin-bottom: 6px; display: block; }

        /* Timer countdown styles */
        .timer-container {
            text-align: center;
            margin-bottom: 16px;
        }
        .timer-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        .timer-badge.active {
            background: #fef3c7;
            color: #92400e;
        }
        .timer-badge.expired {
            background: #fee2e2;
            color: #991b1b;
        }
        .timer-badge i {
            font-size: 12px;
        }
    </style>
</head>
<body>
<div class="card-forgot">

    <%-- ══ BƯỚC THÀNH CÔNG ══ --%>
    <c:if test="${step == 'success'}">
        <div class="icon-circle green"><i class="fas fa-check"></i></div>
        <h5 class="fw-bold text-center mb-2">Đặt lại mật khẩu thành công!</h5>
        <p class="text-center text-muted small mb-4">
            Mật khẩu đã được cập nhật. Hãy đăng nhập với mật khẩu mới.
        </p>
        <a href="${pageContext.request.contextPath}/login"
           class="btn-primary-hrm d-block text-center text-decoration-none">
            <i class="fas fa-sign-in-alt me-2"></i> Đăng nhập ngay
        </a>
    </c:if>

    <%-- ══ BƯỚC 3: NHẬP MẬT KHẨU MỚI (sau khi OTP đã xác minh) ══ --%>
    <c:if test="${step == 'new_password'}">
        <div class="icon-circle purple"><i class="fas fa-key"></i></div>
        <div class="step-badge">Bước 3 / 3</div>
        <h5 class="fw-bold text-center mb-1">Đặt mật khẩu mới</h5>
        <p class="text-center text-muted small mb-4">
            OTP đã xác minh thành công cho<br>
            <strong class="text-dark">${otpEmail}</strong>
        </p>

        <c:if test="${not empty msgError}">
            <div class="alert alert-danger py-2 small">
                <i class="fas fa-exclamation-triangle me-2"></i>${msgError}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <input type="hidden" name="step" value="reset_password">

            <div class="mb-3">
                <label>Mật khẩu mới</label>
                <input type="password" name="newPassword"
                       class="form-control form-control-hrm"
                       placeholder="Tối thiểu 6 ký tự" required minlength="6" autofocus>
            </div>

            <div class="mb-4">
                <label>Xác nhận mật khẩu mới</label>
                <input type="password" name="confirmPassword"
                       class="form-control form-control-hrm"
                       placeholder="Nhập lại mật khẩu mới" required minlength="6">
            </div>

            <button type="submit" class="btn-primary-hrm">
                <i class="fas fa-check-circle me-2"></i> Đặt lại mật khẩu
            </button>
        </form>
    </c:if>

    <%-- ══ BƯỚC 2: NHẬP OTP (chỉ xác minh OTP, chưa nhập mật khẩu) ══ --%>
    <c:if test="${step == 'verify_otp'}">
        <div class="icon-circle yellow"><i class="fas fa-envelope-open-text"></i></div>
        <div class="step-badge">Bước 2 / 3</div>
        <h5 class="fw-bold text-center mb-1">Xác minh mã OTP</h5>
        <p class="text-center text-muted small mb-3">
            Mã OTP 6 chữ số đã được gửi tới<br>
            <strong class="text-dark">${otpEmail}</strong>
        </p>

        <%-- Timer đếm ngược --%>
        <div class="timer-container">
            <div class="timer-badge active" id="timerBadge">
                <i class="fas fa-clock"></i>
                <span id="timerText">Còn lại: 1:00</span>
            </div>
        </div>

        <c:if test="${not empty msgError}">
            <div class="alert alert-danger py-2 small">
                <i class="fas fa-exclamation-triangle me-2"></i>${msgError}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="POST" id="otpForm">
            <input type="hidden" name="step" value="verify_otp">

            <div class="mb-4">
                <label>Nhập mã OTP</label>
                <input type="text" name="otpCode"
                       class="form-control form-control-hrm otp-input"
                       placeholder="000000" maxlength="6" required autofocus
                       autocomplete="one-time-code" id="otpInput">
            </div>

            <button type="submit" class="btn-primary-hrm" id="verifyBtn">
                <i class="fas fa-shield-alt me-2"></i> Xác minh OTP
            </button>
        </form>

        <div class="text-center mt-3">
            <a href="${pageContext.request.contextPath}/forgot-password" class="back-link">
                <i class="fas fa-redo me-1"></i> Gửi lại mã OTP
            </a>
        </div>

        <script>
            (function() {
                // Timer 60 giây (1 phút)
                var totalSeconds = 60;
                var timerBadge = document.getElementById('timerBadge');
                var timerText = document.getElementById('timerText');
                var verifyBtn = document.getElementById('verifyBtn');
                var otpInput = document.getElementById('otpInput');

                var countdown = setInterval(function() {
                    totalSeconds--;
                    var minutes = Math.floor(totalSeconds / 60);
                    var seconds = totalSeconds % 60;
                    timerText.textContent = 'Còn lại: ' + minutes + ':' + (seconds < 10 ? '0' : '') + seconds;

                    if (totalSeconds <= 0) {
                        clearInterval(countdown);
                        timerBadge.classList.remove('active');
                        timerBadge.classList.add('expired');
                        timerText.textContent = 'Mã OTP đã hết hạn!';
                        verifyBtn.disabled = true;
                        otpInput.disabled = true;
                    }
                }, 1000);
            })();
        </script>
    </c:if>

    <%-- ══ BƯỚC 1: NHẬP EMAIL (Mặc định) ══ --%>
    <c:if test="${empty step or step == 'enter_email'}">
        <div class="icon-circle blue"><i class="fas fa-lock"></i></div>
        <div class="step-badge">Bước 1 / 3</div>
        <h5 class="fw-bold text-center mb-1">Quên mật khẩu?</h5>
        <p class="text-center text-muted small mb-4">
            Nhập email công việc để nhận mã OTP đặt lại mật khẩu.
        </p>

        <c:if test="${not empty msgError}">
            <div class="alert alert-danger py-2 small">
                <i class="fas fa-exclamation-triangle me-2"></i>${msgError}
            </div>
        </c:if>
        <c:if test="${not empty msgSuccess}">
            <div class="alert alert-success py-2 small">
                <i class="fas fa-check-circle me-2"></i>${msgSuccess}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <input type="hidden" name="step" value="send_otp">

            <div class="mb-4">
                <label>Email công việc</label>
                <%-- FIX: value="${inputEmail}" giữ lại email đã nhập khi có lỗi --%>
                <input type="email" name="email"
                       class="form-control form-control-hrm"
                       placeholder="email@congty.com"
                       value="${inputEmail}"
                       required autofocus>
            </div>

            <button type="submit" class="btn-primary-hrm">
                <i class="fas fa-paper-plane me-2"></i> Gửi mã OTP
            </button>
        </form>

        <div class="text-center mt-3">
            <a href="${pageContext.request.contextPath}/login" class="back-link">
                <i class="fas fa-arrow-left me-1"></i> Quay lại đăng nhập
            </a>
        </div>
    </c:if>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

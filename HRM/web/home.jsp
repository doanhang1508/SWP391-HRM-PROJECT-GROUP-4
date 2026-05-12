<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Trang chủ - Group4 HRM" scope="request" />
<jsp:include page="header.jsp" />

<style>
    :root {
        /* Tông màu sáng, trong trẻo như Ticketbox */
        --bg-main: #f8f9ff;
        --aura-1: #e0c3fc; /* Tím nhẹ */
        --aura-2: #8ec5fc; /* Xanh nhạt */
        --aura-3: #fbc2eb; /* Hồng phấn */
    }
    /* Navbar phong cách kính mờ xuyên thấu */
    .navbar-custom {
        background: rgba(255, 255, 255, 0.6) !important;
        backdrop-filter: blur(15px); /* Hiệu ứng mờ nền */
        -webkit-backdrop-filter: blur(15px);
        border-bottom: 1px solid rgba(255, 255, 255, 0.3);
        transition: all 0.3s ease;
    }

    /* Logo chữ Gradient */
    .navbar-brand {
        font-weight: 800 !important;
        font-size: 1.5rem;
        background: linear-gradient(135deg, #764ba2 0%, #a18cd1 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }

    /* Link menu mềm mại */
    .nav-link {
        color: #555 !important;
        font-weight: 500;
        margin: 0 10px;
        transition: 0.3s;
        position: relative;
    }
    .nav-link:hover {
        color: #764ba2 !important;
    }
    /* Hiệu ứng gạch chân khi hover */
    .nav-link::after {
        content: '';
        position: absolute;
        width: 0;
        height: 2px;
        bottom: 0;
        left: 50%;
        background: #a18cd1;
        transition: 0.3s;
        transform: translateX(-50%);
    }
    .nav-link:hover::after {
        width: 80%;
    }

    /* Nút Đăng nhập - Kiểu chữ thanh thoát */
    .btn-login {
        color: #764ba2 !important;
        font-weight: 600;
        border: none;
        background: transparent;
        transition: 0.3s;
    }
    .btn-login:hover {
        opacity: 0.7;
    }

    /* Nút Đăng ký - Cùng tông với nút Tìm kiếm */
    .btn-register {
        background: linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%);
        color: white !important;
        font-weight: 600;
        border-radius: 50px;
        padding: 8px 25px !important;
        border: none;
        box-shadow: 0 4px 15px rgba(161, 140, 209, 0.2);
        transition: 0.3s;
    }
    .btn-register:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(161, 140, 209, 0.4);
        color: white !important;
    }
    .hero-section {
        background-color: var(--bg-main);
        background-image: 
            radial-gradient(at 0% 0%, var(--aura-1) 0, transparent 50%), 
            radial-gradient(at 50% 0%, var(--aura-2) 0, transparent 50%),
            radial-gradient(at 100% 0%, var(--aura-3) 0, transparent 50%);
        min-height: 100vh;
        position: relative;
        overflow: hidden;
        display: flex;
        align-items: center;
    }

    /* Bong bóng 3D có đổ bóng và vết sáng */
    .bubble {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.4);
        /* Tạo độ khối 3D cho bong bóng */
        box-shadow: 
            inset -10px -10px 15px rgba(0, 0, 0, 0.05), 
            inset 10px 10px 15px rgba(255, 255, 255, 0.8),
            0 20px 30px rgba(0, 0, 0, 0.05);
        backdrop-filter: blur(2px);
        animation: floatUp 15s linear infinite;
        z-index: 1;
    }

    /* Thêm vết sáng trắng trên bong bóng cho thật */
    .bubble::after {
        content: '';
        position: absolute;
        top: 20%;
        left: 25%;
        width: 25%;
        height: 20%;
        background: rgba(255, 255, 255, 0.6);
        border-radius: 50%;
        transform: rotate(-30deg);
    }

    /* Ngôi sao lấp lánh nhiểu kiểu dáng */
    .sparkle {
        position: absolute;
        color: #fff;
        text-shadow: 0 0 10px #fff;
        animation: twinkle 2s infinite ease-in-out;
        z-index: 2;
    }

    @keyframes floatUp {
        0% { transform: translateY(110vh) translateX(0); opacity: 0; }
        10% { opacity: 0.8; }
        90% { opacity: 0.8; }
        100% { transform: translateY(-20vh) translateX(50px); opacity: 0; }
    }

    @keyframes twinkle {
        0%, 100% { opacity: 0.2; transform: scale(0.8); }
        50% { opacity: 1; transform: scale(1.2); }
    }

    /* Text & Content style sáng sủa */
    .hero-content {
        position: relative;
        z-index: 10;
        text-align: center;
    }
    .main-title {
        font-size: 4rem;
        font-weight: 800;
        color: #3a3a3a;
        letter-spacing: -2px;
    }
    .gradient-text {
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    
    /* Search Bar mềm mại kiểu Ticketbox */
    .search-box {
        background: white;
        border-radius: 50px;
        padding: 5px; /* Giảm padding để nút ôm sát hơn */
        box-shadow: 0 15px 35px rgba(0,0,0,0.05);
        display: flex;
        max-width: 600px;
        margin: 0 auto;
        border: 1px solid rgba(0,0,0,0.05); /* Thêm viền mờ cho sang */
    }

    .search-box input {
        border: none;
        padding-left: 25px;
        border-radius: 50px;
        background: transparent;
    }

    .search-box button {
        border-radius: 50% !important; /* Ép nút thành hình tròn */
        background: linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%);
        border: none;
        color: white;
        font-size: 1.1rem;
        transition: 0.3s all;
    }

    .search-box button:hover {
        transform: rotate(15deg) scale(1.1); /* Xoay nhẹ kính lúp khi di chuột vào */
        box-shadow: 0 5px 15px rgba(161, 140, 209, 0.4);
    }
    
</style>
<nav class="navbar navbar-expand-lg navbar-light fixed-top navbar-custom">
    <div class="container">
        <a class="navbar-brand" href="home">
            <i class="fas fa-users-cog me-2"></i>Group4 HRM
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav mx-auto">
                <li class="nav-item">
                    <a class="nav-link" href="home">Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#features">Tính năng</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#about">Về chúng tôi</a>
                </li>
            </ul>

            <div class="d-flex align-items-center gap-3">
                <a href="login" class="btn btn-login">Đăng nhập</a>
                <a href="register" class="btn btn-register">Đăng ký</a>
            </div>
        </div>
    </div>
</nav>
<section class="hero-section">
    <div class="bubble" style="width: 100px; height: 100px; left: 5%; animation-duration: 18s;"></div>
    <div class="bubble" style="width: 60px; height: 60px; left: 15%; animation-duration: 12s; animation-delay: 2s;"></div>
    <div class="bubble" style="width: 150px; height: 150px; left: 30%; animation-duration: 25s; animation-delay: 5s;"></div>
    <div class="bubble" style="width: 80px; height: 80px; right: 10%; animation-duration: 15s; animation-delay: 1s;"></div>
    <div class="bubble" style="width: 120px; height: 120px; right: 25%; animation-duration: 20s; animation-delay: 8s;"></div>
    <div class="bubble" style="width: 40px; height: 40px; right: 40%; animation-duration: 10s; animation-delay: 3s;"></div>

    <span class="sparkle" style="top: 15%; left: 10%; font-size: 20px;">✦</span>
    <span class="sparkle" style="top: 30%; right: 15%; font-size: 15px; animation-delay: 0.5s;">✧</span>
    <span class="sparkle" style="bottom: 20%; left: 40%; font-size: 25px; animation-delay: 1s;">✦</span>

    <div class="container hero-content">
        <div class="badge rounded-pill px-4 py-2 mb-4" style="background: white; color: #764ba2; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
             Nền tảng Quản trị Nhân sự Thế hệ mới
        </div>
        
        <h1 class="main-title mb-4">
            Tối ưu hóa <span class="gradient-text">Nguồn lực</span> <br>
            Bứt phá <span class="gradient-text">Hiệu suất</span>
        </h1>
        
        <p class="text-muted lead mb-5">
            Sáng tạo không giới hạn với hệ thống quản lý thông minh, <br> mang lại trải nghiệm làm việc hạnh phúc cho doanh nghiệp.
        </p>

        <div class="search-box">
    <input type="text" class="form-control shadow-none" placeholder="Tìm kiếm...">
    
    <button class="btn btn-primary d-flex align-items-center justify-content-center" 
            style="width: 50px; height: 50px; padding: 0; min-width: 50px;">
        <i class="fas fa-search"></i>
    </button>
</div>
    </div>
</section>

<section class="py-5 bg-white">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="fw-bold mb-1" style="color: var(--primary-hrm);">
                <i class="fas fa-th-large me-2"></i>Tiện ích nội bộ
            </h2>
            <p class="text-muted mb-0">Truy cập nhanh các chức năng nghiệp vụ thường dùng</p>
        </div>

        <div class="row g-4 text-center">
            <div class="col-6 col-md-3">
                <a href="profile" class="text-decoration-none">
                    <div class="hover-lift-card p-4 rounded-4 shadow-sm h-100">
                        <div class="icon-box mx-auto"><i class="fas fa-id-badge"></i></div>
                        <h5 class="text-dark fw-bold mt-3">Hồ sơ cá nhân</h5>
                        <small class="text-muted">Cập nhật thông tin, CV</small>
                    </div>
                </a>
            </div>
            <div class="col-6 col-md-3">
                <a href="attendance" class="text-decoration-none">
                    <div class="hover-lift-card p-4 rounded-4 shadow-sm h-100">
                        <div class="icon-box mx-auto"><i class="fas fa-clock"></i></div>
                        <h5 class="text-dark fw-bold mt-3">Chấm công</h5>
                        <small class="text-muted">Lịch sử check-in/out</small>
                    </div>
                </a>
            </div>
            <div class="col-6 col-md-3">
                <a href="leave" class="text-decoration-none">
                    <div class="hover-lift-card p-4 rounded-4 shadow-sm h-100">
                        <div class="icon-box mx-auto"><i class="fas fa-calendar-minus"></i></div>
                        <h5 class="text-dark fw-bold mt-3">Nghỉ phép</h5>
                        <small class="text-muted">Gửi và duyệt đơn từ</small>
                    </div>
                </a>
            </div>
            <div class="col-6 col-md-3">
                <a href="payroll" class="text-decoration-none">
                    <div class="hover-lift-card p-4 rounded-4 shadow-sm h-100">
                        <div class="icon-box mx-auto"><i class="fas fa-file-invoice-dollar"></i></div>
                        <h5 class="text-dark fw-bold mt-3">Phiếu lương</h5>
                        <small class="text-muted">Xem lương & phụ cấp</small>
                    </div>
                </a>
            </div>
        </div>
    </div>
</section>

<section class="py-5" style="background-color: #f8fbff;">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1">
                    <i class="fas fa-bullhorn text-danger me-2"></i>Bảng tin nội bộ
                </h2>
                <p class="text-muted mb-0">Cập nhật tin tức và quyết định mới nhất từ Ban giám đốc</p>
            </div>
            <a href="news" class="text-decoration-none fw-bold d-inline-flex align-items-center gap-2" style="color: var(--primary-hrm);">
                Xem tất cả <i class="fas fa-arrow-right"></i>
            </a>
        </div>

        <div class="row g-4">
            <div class="col-md-6 col-lg-4">
                <div class="card h-100 shadow-sm border-0 rounded-4 overflow-hidden">
                    <img src="https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=600" class="card-img-top" alt="News">
                    <div class="card-body p-4">
                        <span class="badge bg-danger mb-2">QUYẾT ĐỊNH</span>
                        <h5 class="fw-bold mb-3"><a href="#" class="text-dark text-decoration-none">Bổ nhiệm Trưởng phòng Kỹ thuật mới</a></h5>
                        <p class="text-muted small mb-0"><i class="far fa-calendar-alt me-2"></i>12/05/2026</p>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-lg-4">
                <div class="card h-100 shadow-sm border-0 rounded-4 overflow-hidden">
                    <img src="https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=600" class="card-img-top" alt="News">
                    <div class="card-body p-4">
                        <span class="badge bg-info mb-2">SỰ KIỆN</span>
                        <h5 class="fw-bold mb-3"><a href="#" class="text-dark text-decoration-none">Khám sức khỏe định kỳ năm 2026 cho toàn bộ nhân viên</a></h5>
                        <p class="text-muted small mb-0"><i class="far fa-calendar-alt me-2"></i>10/05/2026</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="footer.jsp" />
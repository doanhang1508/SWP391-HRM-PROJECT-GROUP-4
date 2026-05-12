<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Trang chủ - Group4 HRM" scope="request" />
<jsp:include page="header.jsp" />

<style>
    :root {
        --primary-hrm: #0B2447; 
        --secondary-hrm: #19376D;
        --accent-hrm: #576CBC; 
        --highlight: #A5D7E8;
    }
    .hero-section {
        background: linear-gradient(135deg, var(--primary-hrm) 0%, var(--secondary-hrm) 100%);
        padding: 120px 0 80px 0;
        position: relative;
        overflow: hidden;
    }
    /* Các khối sáng lơ lửng tạo chiều sâu */
    .glow-blob-1 {
        position: absolute; top: -10%; left: -5%; width: 400px; height: 400px;
        background: var(--accent-hrm); filter: blur(120px); opacity: 0.6; border-radius: 50%; z-index: 0;
    }
    .glow-blob-2 {
        position: absolute; bottom: -20%; right: -5%; width: 500px; height: 500px;
        background: var(--highlight); filter: blur(150px); opacity: 0.3; border-radius: 50%; z-index: 0;
    }
    /* Glassmorphism dành riêng cho nền tối */
    .hero-glass {
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(255, 255, 255, 0.2);
        box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
    }
    .btn-gradient-hrm {
        background: linear-gradient(to right, var(--accent-hrm), #6a82d6);
        color: white; border: none; font-weight: 600;
    }
    .btn-gradient-hrm:hover { opacity: 0.9; color: white; transform: translateY(-1px); }
    .hover-lift-card {
        transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        border: 1px solid rgba(0,0,0,0.05);
        background: #ffffff;
    }
    .hover-lift-card:hover {
        transform: translateY(-12px);
        box-shadow: 0 20px 40px rgba(11, 36, 71, 0.08) !important;
        border-color: rgba(87, 108, 188, 0.2);
    }
    .icon-box {
        transition: all 0.4s ease;
    }
    /* Đổi màu icon khi di chuột vào thẻ */
    .hover-lift-card:hover .icon-box {
        background: var(--primary-hrm);
        color: white;
        transform: scale(1.1) rotate(5deg);
    }
</style>

<section class="hero-section position-relative overflow-hidden">
    <div class="glow-blob-1"></div>
    <div class="glow-blob-2"></div>
    
    <div class="container position-relative" style="z-index: 10;">
        <div class="row justify-content-center text-center">
            <div class="col-lg-8">
                <div class="d-inline-flex align-items-center gap-2 hero-glass px-4 py-2 rounded-pill mb-4 text-white">
                    <i class="fas fa-check-circle" style="color: var(--highlight);"></i>
                    <span class="fw-medium small">Nền tảng Quản trị Nhân sự Toàn diện</span>
                </div>

                <h1 class="display-4 fw-bold mb-4 text-white">
                    <span>Tối ưu hóa nguồn lực</span> <br>
                    <span style="color: var(--highlight);">Bứt phá hiệu suất</span>
                </h1>

                <p class="lead mb-5" style="color: rgba(255, 255, 255, 0.8);">
                    Giải pháp quản lý hồ sơ, tự động hóa chấm công và tính lương thông minh dành riêng cho doanh nghiệp hiện đại.
                </p>

                <div class="hero-glass p-3 rounded-4 mb-5 mx-auto" style="max-width: 700px;">
                    <form action="directory" method="get" class="d-flex flex-column flex-sm-row gap-2">
                        <div class="flex-grow-1 d-flex align-items-center bg-white rounded-3 px-3 py-2">
                            <i class="fas fa-search text-muted me-2"></i>
                            <input type="text" name="keyword" class="form-control border-0 shadow-none bg-transparent" 
                                   placeholder="Tra cứu danh bạ nhân viên, phòng ban...">
                        </div>
                        <button type="submit" class="btn btn-gradient-hrm rounded-3 px-4 py-2">
                            <i class="fas fa-search me-2"></i>Tìm kiếm
                        </button>
                    </form>
                </div>

                <div class="d-flex justify-content-center gap-4 gap-md-5 flex-wrap mt-4">
                    <div class="text-center">
                        <h2 class="fw-bold mb-0 text-white">150+</h2>
                        <div class="small" style="color: rgba(255, 255, 255, 0.7);">Nhân sự</div>
                    </div>
                    <div class="text-center">
                        <h2 class="fw-bold mb-0 text-white">12</h2>
                        <div class="small" style="color: rgba(255, 255, 255, 0.7);">Phòng ban</div>
                    </div>
                    <div class="text-center">
                        <h2 class="fw-bold mb-0 text-white">5</h2>
                        <div class="small" style="color: rgba(255, 255, 255, 0.7);">Chi nhánh</div>
                    </div>
                </div>
            </div>
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
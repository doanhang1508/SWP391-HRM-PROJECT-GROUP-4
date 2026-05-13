<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Trang chủ - Group4 HRM" scope="request" />
<jsp:include page="header.jsp" />

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

<section class="py-5" style="background-color: transparent; position: relative; z-index: 2;">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="fw-bold" style="color: #1a1a1a;">Giải pháp <span class="gradient-text">Toàn diện</span></h2>
            <p class="text-muted" style="font-weight: 500;">Mọi công cụ bạn cần để xây dựng đội ngũ vững mạnh</p>
        </div>

        <div class="row g-4">
    <div class="col-md-4">
        <div class="feature-card">
            <div class="feature-icon"><i class="fas fa-clock"></i></div>
            <h4 class="fw-bold">Chấm công tự động</h4>
            <p class="text-muted">Quản lý thời gian nhân viên chính xác, tự động hóa 100%.</p>
        </div>
    </div>
    <div class="col-md-4">
        <div class="feature-card">
            <div class="feature-icon"><i class="fas fa-file-invoice-dollar"></i></div>
            <h4 class="fw-bold">Tính lương nhanh</h4>
            <p class="text-muted">Tính lương chính xác, xuất phiếu lương chỉ trong vài giây.</p>
        </div>
    </div>
    <div class="col-md-4">
        <div class="feature-card">
            <div class="feature-icon"><i class="fas fa-user-shield"></i></div>
            <h4 class="fw-bold">Bảo mật tối đa</h4>
            <p class="text-muted">Dữ liệu doanh nghiệp được mã hóa an toàn tuyệt đối.</p>
        </div>
    </div>
</div>
    </div>
</section>
<section class="py-5">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6">
                <h2 class="fw-bold mb-4">Giải pháp HRM tối ưu cho <span class="gradient-text">Doanh nghiệp</span></h2>
                <p class="text-muted mb-4">Không còn nỗi lo quản lý thủ công. Hệ thống giúp bạn số hóa toàn bộ quy trình nhân sự, tiết kiệm 70% thời gian hành chính để tập trung vào tăng trưởng kinh doanh.</p>
                <ul class="list-unstyled">
                    <li class="mb-3"><i class="fas fa-check-circle text-primary me-2"></i> Thiết lập nhanh chóng, không cần hạ tầng phức tạp</li>
                    <li class="mb-3"><i class="fas fa-check-circle text-primary me-2"></i> Giao diện thân thiện, nhân viên sử dụng ngay không cần đào tạo</li>
                    <li class="mb-3"><i class="fas fa-check-circle text-primary me-2"></i> Chi phí tối ưu, phù hợp với quy mô doanh nghiệp vừa và nhỏ</li>
                </ul>
            </div>
            <div class="col-lg-6">
                <img src="https://images.unsplash.com/photo-1552664730-d307ca884978?w=800" class="img-fluid rounded-4 shadow-lg" alt="HRM Solution">
            </div>
        </div>
    </div>
</section>
<section class="py-5 bg-light border-top border-bottom">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="fw-bold mb-2" style="color: #1a1a1a; letter-spacing: -1px;">
                Đồng hành cùng sự <span class="gradient-text">Thành công</span> của bạn
            </h2>
            <div class="mx-auto" style="width: 60px; height: 4px; background: linear-gradient(90deg, #8569bf, #d87bbd); border-radius: 2px;"></div>
            <p class="text-muted mt-3 fw-medium">Hệ thống tin dùng bởi các tập đoàn và doanh nghiệp dẫn đầu</p>
        </div>

        <div class="row g-4 justify-content-center align-items-center logo-trust-row mb-5">
            <div class="col-6 col-md-auto px-4">
                <div class="d-flex align-items-center gap-2 brand-item">
                    <i class="fab fa-fort-awesome fa-2x text-primary"></i>
                    <span class="fw-bold fs-5 text-muted">FPT CORP</span>
                </div>
            </div>
            <div class="col-6 col-md-auto px-4">
                <div class="d-flex align-items-center gap-2 brand-item">
                    <i class="fas fa-broadcast-tower fa-2x text-danger"></i>
                    <span class="fw-bold fs-5 text-muted">VIETTEL</span>
                </div>
            </div>
            <div class="col-6 col-md-auto px-4">
                <div class="d-flex align-items-center gap-2 brand-item">
                    <i class="fas fa-building fa-2x text-info"></i>
                    <span class="fw-bold fs-5 text-muted">VINGROUP</span>
                </div>
            </div>
            <div class="col-6 col-md-auto px-4">
                <div class="d-flex align-items-center gap-2 brand-item">
                    <i class="fas fa-university fa-2x text-warning"></i>
                    <span class="fw-bold fs-5 text-muted">TPBANK</span>
                </div>
            </div>
            <div class="col-6 col-md-auto px-4">
                <div class="d-flex align-items-center gap-2 brand-item">
                    <i class="fas fa-shield-alt fa-2x text-success"></i>
                    <span class="fw-bold fs-5 text-muted">MBBANK</span>
                </div>
            </div>
        </div>

        <div class="row g-3 justify-content-center text-center my-5 counter-section">
            <div class="col-6 col-md-2">
                <h3 class="fw-800 gradient-text mb-0">500+</h3>
                <p class="text-muted x-small fw-bold">Doanh nghiệp</p>
            </div>
            <div class="col-6 col-md-2">
                <h3 class="fw-800 gradient-text mb-0">10.000+</h3>
                <p class="text-muted x-small fw-bold">Nhân viên</p>
            </div>
            <div class="col-6 col-md-2">
                <h3 class="fw-800 gradient-text mb-0">99%</h3>
                <p class="text-muted x-small fw-bold">Hài lòng</p>
            </div>
            <div class="col-6 col-md-2">
                <h3 class="fw-800 gradient-text mb-0">24/7</h3>
                <p class="text-muted x-small fw-bold">Hỗ trợ</p>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-6">
                <div class="testimonial-card p-4 rounded-4 shadow-sm bg-white border-0 h-100">
                    <div class="d-flex text-warning mb-3">
                        <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i>
                    </div>
                    <p class="italic text-secondary mb-4" style="font-size: 0.95rem; line-height: 1.7;">"Grupo4 HRM đã thay đổi hoàn toàn cách chúng tôi quản lý nhân sự. Hệ thống tự động hóa giúp tiết kiệm hàng chục giờ làm việc mỗi tháng."</p>
                    <div class="d-flex align-items-center gap-3 border-top pt-3">
                        <img src="https://ui-avatars.com/api/?name=An+Nguyen&background=8569bf&color=fff" class="rounded-circle shadow-sm" width="45">
                        <div>
                            <h6 class="mb-0 fw-bold">Nguyễn Văn An</h6>
                            <small class="text-muted">HR Director - Tech Corp</small>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="testimonial-card p-4 rounded-4 shadow-sm bg-white border-0 h-100">
                    <div class="d-flex text-warning mb-3">
                        <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i>
                    </div>
                    <p class="italic text-secondary mb-4" style="font-size: 0.95rem; line-height: 1.7;">"Giải pháp tối ưu cho doanh nghiệp vừa và nhỏ. Chi phí hợp lý nhưng tính năng cực kỳ mạnh mẽ và bảo mật tuyệt đối."</p>
                    <div class="d-flex align-items-center gap-3 border-top pt-3">
                        <img src="https://ui-avatars.com/api/?name=Hang+Tran&background=d87bbd&color=fff" class="rounded-circle shadow-sm" width="45">
                        <div>
                            <h6 class="mb-0 fw-bold">Trần Minh Hằng</h6>
                            <small class="text-muted">CEO - Green Logistics</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
<section class="py-5 text-center" style="background: linear-gradient(135deg, #5b328a 0%, #8569bf 100%); color: white;">
    <div class="container py-4">
        <h2 class="fw-bold mb-3">Sẵn sàng nâng tầm quản trị nhân sự?</h2>
        <p class="mb-4">Hơn 500+ doanh nghiệp đã tin dùng Group4 HRM. Đăng ký dùng thử miễn phí ngay hôm nay!</p>
        <a href="register" class="btn btn-light btn-lg rounded-pill px-5 fw-bold text-primary">Đăng ký trải nghiệm</a>
    </div>
</section>

<jsp:include page="footer.jsp" />
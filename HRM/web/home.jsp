<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Trang chủ" scope="request" />
<jsp:include page="header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

<style>
*{box-sizing:border-box}
body{background:#f0ede8;font-family:'Inter',sans-serif;overflow-x:hidden}

/* ── MARQUEE TICKER ── */
.ticker{background:#0a2540;color:#fff;padding:12px 0;overflow:hidden;white-space:nowrap}
.ticker-track{display:inline-flex;animation:ticker 30s linear infinite}
.ticker-track span{padding:0 60px;font-size:.8rem;font-weight:600;letter-spacing:2px;text-transform:uppercase;color:#90cdf4}
.ticker-track span::after{content:'◆';margin-left:60px;color:#2b6cb0}
@keyframes ticker{0%{transform:translateX(0)}100%{transform:translateX(-50%)}}

/* ── HERO SPLIT ── */
.hero-split{display:grid;grid-template-columns:1fr 1fr;height:580px}
.hero-left{background:#0a2540;display:flex;flex-direction:column;justify-content:center;padding:50px 50px;position:relative;overflow:hidden}
.hero-left-bg{position:absolute;inset:0;background:url('https://images.unsplash.com/photo-1565610222536-ce1255ffee28?q=80&w=900') center/cover;opacity:.12;mix-blend-mode:luminosity}
.hero-year{position:absolute;top:40px;left:60px;font-family:'Be Vietnam Pro',sans-serif;font-size:.85rem;font-weight:700;letter-spacing:3px;color:rgba(255,255,255,.3);text-transform:uppercase}
.hero-title{font-family:'Be Vietnam Pro',sans-serif;font-size:clamp(2rem,3.5vw,3.5rem);font-weight:800;color:#fff;line-height:1.05;letter-spacing:-2px;position:relative;z-index:2;margin:0 0 20px}
.hero-title em{color:#63b3ed;font-style:normal}
.hero-subtitle{color:rgba(255,255,255,.65);font-size:.9rem;line-height:1.7;max-width:400px;position:relative;z-index:2;margin-bottom:30px}
.hero-cta-row{display:flex;align-items:center;gap:30px;position:relative;z-index:2}
.btn-hero{display:inline-flex;align-items:center;gap:12px;background:#fff;color:#0a2540;padding:18px 36px;font-weight:700;font-size:.95rem;text-decoration:none;letter-spacing:.5px;transition:all .3s;clip-path:polygon(0 0,calc(100% - 16px) 0,100% 50%,calc(100% - 16px) 100%,0 100%);padding-right:50px}
.btn-hero:hover{background:#63b3ed;color:#fff}
.hero-scroll-hint{color:rgba(255,255,255,.35);font-size:.8rem;letter-spacing:1px}

.hero-right{background:#f0ede8;display:flex;flex-direction:column;justify-content:space-between;padding:0;overflow:hidden}
.hero-img-wrap{flex:1;overflow:hidden;position:relative;background:url('https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?q=80&w=1200&auto=format&fit=crop') center/cover no-repeat}
.hero-img-wrap:hover{background-size:105%}
.hero-img-label{position:absolute;bottom:24px;right:24px;background:#0a2540;color:#fff;font-size:.75rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;padding:10px 20px}
.hero-stats-bar{display:flex;background:#fff;border-top:3px solid #0a2540}
.hstat{flex:1;padding:20px 18px;border-right:1px solid #e2e8f0}
.hstat:last-child{border-right:none}
.hstat-n{font-family:'Be Vietnam Pro',sans-serif;font-size:1.5rem;font-weight:800;color:#0a2540;letter-spacing:-1px}
.hstat-l{font-size:.7rem;font-weight:600;text-transform:uppercase;letter-spacing:1px;color:#718096;margin-top:4px}

/* ── BRAND STRIP ── */
.brand-strip{background:#fff;border-bottom:1px solid #e2e8f0;padding:20px 0;display:flex;align-items:center;overflow:hidden}
.brand-strip-inner{display:flex;gap:80px;animation:slide 20s linear infinite}
.brand-strip-inner img,.brand-logo-text{opacity:.4;transition:opacity .3s;filter:grayscale(1)}
.brand-logo-text{font-family:'Be Vietnam Pro',sans-serif;font-weight:800;font-size:1.2rem;color:#0a2540;white-space:nowrap}
.brand-logo-text:hover{opacity:.8}
@keyframes slide{from{transform:translateX(0)}to{transform:translateX(-50%)}}

/* ── MANIFESTO ── */
.manifesto{background:#0a2540;padding:70px 0;text-align:center;position:relative;overflow:hidden}
.manifesto::before{content:'HRM';position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-family:'Be Vietnam Pro',sans-serif;font-size:20rem;font-weight:800;color:rgba(255,255,255,.02);pointer-events:none;letter-spacing:-10px}
.manifesto-sub{font-size:.85rem;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:#63b3ed;margin-bottom:30px}
.manifesto-text{font-family:'Be Vietnam Pro',sans-serif;font-size:clamp(1.5rem,2.5vw,2.5rem);font-weight:800;color:#fff;line-height:1.25;letter-spacing:-.5px;max-width:800px;margin:0 auto 40px}
.manifesto-text span{color:#63b3ed}
.manifesto-link{color:#fff;text-decoration:none;font-size:1.1rem;font-weight:600;border-bottom:2px solid #2b6cb0;padding-bottom:6px;transition:border-color .3s}
.manifesto-link:hover{border-bottom-color:#63b3ed;color:#63b3ed}

/* ── FEATURES BAND ── */
.features-band{padding:70px 0;background:#f0ede8}
.features-header{display:flex;align-items:flex-end;justify-content:space-between;margin-bottom:40px}
.features-header h2{font-family:'Be Vietnam Pro',sans-serif;font-size:2rem;font-weight:800;color:#0a2540;letter-spacing:-.5px;line-height:1}
.feat-count{font-family:'Be Vietnam Pro',sans-serif;font-size:3.5rem;font-weight:800;color:#e2d9cc;letter-spacing:-2px}

.feat-list{display:flex;flex-direction:column}
.feat-item{display:flex;align-items:center;gap:30px;padding:28px 0;border-top:1px solid #d1c9bd;transition:all .4s;cursor:default}
.feat-item:hover{padding-left:20px;border-top-color:#0a2540}
.feat-num{font-family:'Be Vietnam Pro',sans-serif;font-size:1.2rem;font-weight:800;color:#b8ae9f;min-width:60px}
.feat-item:hover .feat-num{color:#2b6cb0}
.feat-icon-wrap{width:44px;height:44px;border:1.5px solid #0a2540;display:flex;align-items:center;justify-content:center;font-size:1rem;color:#0a2540;transition:all .3s;flex-shrink:0}
.feat-item:hover .feat-icon-wrap{background:#0a2540;color:#fff}
.feat-info h3{font-family:'Be Vietnam Pro',sans-serif;font-size:1.1rem;font-weight:800;color:#0a2540;margin:0 0 4px;letter-spacing:-.3px}
.feat-info p{color:#718096;font-size:.85rem;line-height:1.5;margin:0;max-width:500px}
.feat-arrow{margin-left:auto;font-size:1.5rem;color:#c8bfb5;transition:all .4s;transform:translateX(-10px);opacity:0}
.feat-item:hover .feat-arrow{color:#0a2540;transform:translateX(0);opacity:1}

/* ── PHOTO GRID ── */
.photo-grid{display:grid;grid-template-columns:2fr 1fr 1fr;grid-template-rows:200px 200px;gap:3px;background:#0a2540}
.photo-cell{overflow:hidden;position:relative}
.photo-cell:first-child{grid-row:1/3}
.photo-cell img{width:100%;height:100%;object-fit:cover;filter:grayscale(30%) contrast(1.1);transition:all .6s}
.photo-cell:hover img{filter:grayscale(0%) contrast(1);transform:scale(1.05)}
.photo-cell-label{position:absolute;bottom:0;left:0;right:0;padding:24px;background:linear-gradient(to top,rgba(10,37,64,.8),transparent);color:#fff;font-size:.8rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;opacity:0;transition:opacity .4s}
.photo-cell:hover .photo-cell-label{opacity:1}

/* ── NEWS ── */
.news-section{padding:70px 0;background:#fff}
.news-header{display:flex;align-items:baseline;justify-content:space-between;margin-bottom:60px;padding-bottom:30px;border-bottom:3px solid #0a2540}
.news-header h2{font-family:'Be Vietnam Pro',sans-serif;font-size:2rem;font-weight:800;color:#0a2540;letter-spacing:-.5px}
.news-header a{color:#2b6cb0;font-weight:600;font-size:.9rem;text-decoration:none;letter-spacing:1px}
.news-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:0;border:1px solid #e2e8f0}
.news-card{padding:40px 36px;border-right:1px solid #e2e8f0;position:relative;overflow:hidden;transition:background .3s}
.news-card:last-child{border-right:none}
.news-card::after{content:'';position:absolute;bottom:0;left:0;width:0;height:3px;background:#0a2540;transition:width .4s}
.news-card:hover{background:#f8f7f5}
.news-card:hover::after{width:100%}
.news-tag2{display:inline-block;font-size:.72rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:#2b6cb0;margin-bottom:20px}
.news-date2{display:block;font-size:.8rem;color:#a0aec0;margin-bottom:12px}
.news-title2{font-family:'Be Vietnam Pro',sans-serif;font-size:1rem;font-weight:700;color:#1a202c;line-height:1.3;margin-bottom:16px;letter-spacing:-.2px}
.news-arrow2{font-size:1.3rem;color:#c8bfb5;transition:all .3s}
.news-card:hover .news-arrow2{color:#0a2540;transform:translateX(6px);display:inline-block}

/* ── CTA FINAL ── */
.final-cta{background:#0a2540;min-height:50vh;display:flex;align-items:center;justify-content:center;text-align:center;position:relative;overflow:hidden}
.final-cta::before{content:'';position:absolute;top:-200px;left:50%;transform:translateX(-50%);width:800px;height:800px;border-radius:50%;background:rgba(43,108,176,.08);border:1px solid rgba(43,108,176,.15)}
.final-cta-inner{position:relative;z-index:2}
.final-cta h2{font-family:'Be Vietnam Pro',sans-serif;font-size:clamp(2rem,3.5vw,3.5rem);font-weight:800;color:#fff;letter-spacing:-1px;line-height:1.1;margin-bottom:35px}
.final-cta h2 em{color:#63b3ed;font-style:normal}
.btn-final{display:inline-flex;align-items:center;gap:16px;background:transparent;color:#fff;border:1.5px solid rgba(255,255,255,.35);padding:20px 50px;font-family:'Be Vietnam Pro',sans-serif;font-weight:700;font-size:1.1rem;text-decoration:none;letter-spacing:1px;text-transform:uppercase;transition:all .3s}
.btn-final:hover{background:#fff;color:#0a2540;border-color:#fff}

@media(max-width:768px){
.hero-split{grid-template-columns:1fr}
.hero-right{display:none}
.photo-grid{grid-template-columns:1fr;grid-template-rows:auto}
.photo-cell:first-child{grid-row:auto}
.news-grid{grid-template-columns:1fr}
.news-card{border-right:none;border-bottom:1px solid #e2e8f0}
}
</style>

<!-- TICKER -->
<div class="ticker">
    <div class="ticker-track">
        <span>Chấm công tự động</span><span>Bảng lương số hóa</span>
        <span>Quản lý ca kíp</span><span>Đánh giá KPI</span>
        <span>Nghỉ phép trực tuyến</span><span>Hồ sơ nhân sự</span>
        <span>Chấm công tự động</span><span>Bảng lương số hóa</span>
        <span>Quản lý ca kíp</span><span>Đánh giá KPI</span>
        <span>Nghỉ phép trực tuyến</span><span>Hồ sơ nhân sự</span>
    </div>
</div>

<!-- HERO SPLIT -->
<section class="hero-split">
    <div class="hero-left">
        <div class="hero-left-bg"></div>
        <span class="hero-year">Est. 2010 &nbsp;/&nbsp; HRM SYSTEM v3.0</span>
        <h1 class="hero-title">Quản Trị<br><em>Vượt Trội.</em></h1>
        <p class="hero-subtitle">Hệ thống Quản trị Nhân lực toàn diện cho doanh nghiệp sản xuất — từ dây chuyền đến ban lãnh đạo, tất cả trên một nền tảng thống nhất.</p>
        <div class="hero-cta-row">
            <a href="${pageContext.request.contextPath}/login" class="btn-hero">
                Đăng nhập Nội bộ <i class="fas fa-arrow-right"></i>
            </a>
            <span class="hero-scroll-hint">↓ Cuộn để khám phá</span>
        </div>
    </div>
    <div class="hero-right">
        <div class="hero-img-wrap">
            <div class="hero-img-label">Nhà máy — Bắc Ninh</div>
        </div>
        <div class="hero-stats-bar">
            <div class="hstat">
                <div class="hstat-n">10K+</div>
                <div class="hstat-l">Nhân sự</div>
            </div>
            <div class="hstat">
                <div class="hstat-n">03</div>
                <div class="hstat-l">Nhà máy</div>
            </div>
            <div class="hstat">
                <div class="hstat-n">15+</div>
                <div class="hstat-l">Năm hoạt động</div>
            </div>
        </div>
    </div>
</section>

<!-- BRAND STRIP -->
<div class="brand-strip">
    <div style="padding:0 40px;font-size:.75rem;font-weight:700;letter-spacing:2px;color:#aaa;white-space:nowrap">ĐỐI TÁC</div>
    <div class="brand-strip-inner">
        <span class="brand-logo-text">SAMSUNG</span>
        <span class="brand-logo-text">TOYOTA</span>
        <span class="brand-logo-text">HONDA</span>
        <span class="brand-logo-text">LG ELECTRONICS</span>
        <span class="brand-logo-text">BOSCH</span>
        <span class="brand-logo-text">PANASONIC</span>
        <span class="brand-logo-text">SAMSUNG</span>
        <span class="brand-logo-text">TOYOTA</span>
        <span class="brand-logo-text">HONDA</span>
        <span class="brand-logo-text">LG ELECTRONICS</span>
        <span class="brand-logo-text">BOSCH</span>
        <span class="brand-logo-text">PANASONIC</span>
    </div>
</div>

<!-- MANIFESTO -->
<section class="manifesto">
    <div class="container">
        <p class="manifesto-sub">Tầm nhìn doanh nghiệp</p>
        <h2 class="manifesto-text">
            Con người là <span>tài sản lớn nhất</span>.<br>
            Quản trị thông minh là <span>lợi thế cạnh tranh</span>.
        </h2>
        <a href="${pageContext.request.contextPath}/login" class="manifesto-link">
            Vào Hệ thống ngay &rarr;
        </a>
    </div>
</section>

<!-- FEATURES BAND -->
<section class="features-band">
    <div class="container">
        <div class="features-header">
            <h2>Phân hệ<br>chức năng</h2>
            <span class="feat-count">06</span>
        </div>
        <div class="feat-list">
            <div class="feat-item">
                <span class="feat-num">01</span>
                <div class="feat-icon-wrap"><i class="fas fa-user-tie"></i></div>
                <div class="feat-info">
                    <h3>Hồ sơ & Hợp đồng Nhân sự</h3>
                    <p>Số hóa toàn bộ hồ sơ CBCNV — từ bằng cấp, chứng chỉ nghề đến lịch sử phân công tại các phân xưởng.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">02</span>
                <div class="feat-icon-wrap"><i class="fas fa-fingerprint"></i></div>
                <div class="feat-info">
                    <h3>Chấm công & Quản lý Ca kíp</h3>
                    <p>Tích hợp thiết bị vân tay, nhận diện khuôn mặt. Quản lý 3 ca sản xuất 24/7 tự động, không sai sót.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">03</span>
                <div class="feat-icon-wrap"><i class="fas fa-money-check-alt"></i></div>
                <div class="feat-info">
                    <h3>Tính lương & C&B Tự động</h3>
                    <p>Tổng hợp lương cơ bản, phụ cấp độc hại, tăng ca, BHXH — xuất bảng lương chính xác trong 15 phút.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">04</span>
                <div class="feat-icon-wrap"><i class="fas fa-calendar-check"></i></div>
                <div class="feat-info">
                    <h3>Nghỉ phép & Phúc lợi</h3>
                    <p>Duyệt phép qua ứng dụng, theo dõi quota realtime, tích hợp bảo hiểm sức khỏe ngoại trú nội trú.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">05</span>
                <div class="feat-icon-wrap"><i class="fas fa-chart-bar"></i></div>
                <div class="feat-info">
                    <h3>KPI & Đánh giá Hiệu suất</h3>
                    <p>Dashboard theo dõi năng suất theo phân xưởng, cá nhân. Tự động xếp hạng và kết nối thưởng KPI.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">06</span>
                <div class="feat-icon-wrap"><i class="fas fa-graduation-cap"></i></div>
                <div class="feat-info">
                    <h3>Đào tạo & ATVSLĐ</h3>
                    <p>Quản lý chứng chỉ an toàn lao động bắt buộc, lịch đào tạo nghề, nhắc gia hạn tự động.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
        </div>
    </div>
</section>

<!-- PHOTO GRID -->
<div class="photo-grid">
    <div class="photo-cell">
        <img src="https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?q=80&w=1200&auto=format&fit=crop" alt="Nhà máy">
        <div class="photo-cell-label">Dây chuyền sản xuất</div>
    </div>
    <div class="photo-cell">
        <img src="https://images.unsplash.com/photo-1581092160562-40aa08e78837?q=80&w=600&auto=format&fit=crop" alt="Kỹ sư">
        <div class="photo-cell-label">Đội ngũ kỹ sư</div>
    </div>
    <div class="photo-cell">
        <img src="https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=600&auto=format&fit=crop" alt="Văn phòng">
        <div class="photo-cell-label">Trung tâm quản lý</div>
    </div>
    <div class="photo-cell">
        <img src="https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=600&auto=format&fit=crop" alt="Nhân viên">
        <div class="photo-cell-label">Bộ phận HR</div>
    </div>
    <div class="photo-cell">
        <img src="https://images.unsplash.com/photo-1521737711867-e3b97375f902?q=80&w=600&auto=format&fit=crop" alt="Teamwork">
        <div class="photo-cell-label">Đội nhóm xuất sắc</div>
    </div>
</div>

<!-- NEWS -->
<section class="news-section">
    <div class="container">
        <div class="news-header">
            <h2>Bản tin<br>Nội bộ</h2>
            <a href="#">Xem tất cả &rarr;</a>
        </div>
        <div class="news-grid">
            <div class="news-card">
                <span class="news-tag2">Phúc lợi</span>
                <span class="news-date2">10 tháng 05, 2026</span>
                <h3 class="news-title2">Nâng cấp Bảo hiểm Sức khỏe Đặc biệt cho toàn thể CBCNV khối Sản xuất</h3>
                <span class="news-arrow2">&rarr;</span>
            </div>
            <div class="news-card">
                <span class="news-tag2">Sức khỏe</span>
                <span class="news-date2">02 tháng 05, 2026</span>
                <h3 class="news-title2">Lịch Khám sức khỏe định kỳ Quý II — Bắt buộc 100% nhân sự đăng ký</h3>
                <span class="news-arrow2">&rarr;</span>
            </div>
            <div class="news-card" style="background:#0a2540">
                <span class="news-tag2" style="color:#63b3ed">🔥 Tuyển dụng</span>
                <span class="news-date2" style="color:rgba(255,255,255,.5)">Đang tuyển</span>
                <h3 class="news-title2" style="color:#fff">Tuyển 50 Kỹ sư Tự động hoá & Vận hành CNC — KCN Bắc Ninh</h3>
                <span class="news-arrow2" style="color:#63b3ed">&rarr;</span>
            </div>
        </div>
    </div>
</section>

<!-- FINAL CTA -->
<section class="final-cta">
    <div class="final-cta-inner">
        <h2>Bạn là<br><em>nhân viên</em><br>của chúng tôi?</h2>
        <a href="${pageContext.request.contextPath}/login" class="btn-final">
            <i class="fas fa-lock-open"></i> ĐĂNG NHẬP HỆ THỐNG NỘI BỘ
        </a>
    </div>
</section>

<jsp:include page="footer.jsp" />
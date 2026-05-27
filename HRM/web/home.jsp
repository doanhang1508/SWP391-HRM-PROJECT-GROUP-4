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
.hero-cta-row{display:flex;align-items:center;gap:16px;position:relative;z-index:2;flex-wrap:wrap}

/* Nút hero */
.btn-hero-main{
    display:inline-flex;align-items:center;gap:10px;
    background:#2b6cb0;color:#fff;border:none;
    padding:13px 28px;
    font-family:'Be Vietnam Pro',sans-serif;font-size:.9rem;font-weight:700;
    text-decoration:none;letter-spacing:.3px;
    transition:all .25s;
}
.btn-hero-main:hover{background:#1e4e8c;color:#fff;transform:translateY(-1px)}
.btn-hero-ghost{
    display:inline-flex;align-items:center;gap:10px;
    background:transparent;color:rgba(255,255,255,.75);
    border:1px solid rgba(255,255,255,.25);
    padding:13px 24px;
    font-family:'Be Vietnam Pro',sans-serif;font-size:.88rem;font-weight:600;
    text-decoration:none;transition:all .25s;
}
.btn-hero-ghost:hover{background:rgba(255,255,255,.08);color:#fff;border-color:rgba(255,255,255,.5)}

/* Badge chào mừng */
.hero-user-badge{
    display:inline-flex;align-items:center;gap:10px;
    background:rgba(255,255,255,.07);
    border:1px solid rgba(255,255,255,.12);
    padding:8px 16px;margin-bottom:22px;
    position:relative;z-index:2;
}
.online-dot{width:8px;height:8px;background:#48bb78;border-radius:50%;flex-shrink:0;box-shadow:0 0 0 2px rgba(72,187,120,.3)}
.hero-user-badge span{font-size:.82rem;color:rgba(255,255,255,.7);font-weight:500}
.hero-user-badge b{color:#fff}

.hero-right{background:#f0ede8;display:flex;flex-direction:column;justify-content:space-between;padding:0;overflow:hidden}
.hero-img-wrap{flex:1;overflow:hidden;position:relative;background:url('https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?q=80&w=1200&auto=format&fit=crop') center/cover no-repeat;transition:background-size .6s}
.hero-img-wrap:hover{background-size:105%}
.hero-img-label{position:absolute;bottom:24px;right:24px;background:#0a2540;color:#fff;font-size:.75rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;padding:10px 20px}
.hero-stats-bar{display:flex;background:#fff;border-top:3px solid #0a2540}
.hstat{flex:1;padding:20px 18px;border-right:1px solid #e2e8f0}
.hstat:last-child{border-right:none}
.hstat-n{font-family:'Be Vietnam Pro',sans-serif;font-size:1.5rem;font-weight:800;color:#0a2540;letter-spacing:-1px}
.hstat-l{font-size:.7rem;font-weight:600;text-transform:uppercase;letter-spacing:1px;color:#718096;margin-top:4px}

/* ── VALUES STRIP ── */
.values-strip{background:#fff;border-bottom:1px solid #e2e8f0;padding:20px 0;display:flex;align-items:center;overflow:hidden}
.values-strip-inner{display:flex;gap:80px;animation:slide 25s linear infinite}
.values-text{font-family:'Be Vietnam Pro',sans-serif;font-weight:800;font-size:1.1rem;color:#0a2540;white-space:nowrap;opacity:.35;transition:opacity .3s}
.values-text:hover{opacity:.8}
@keyframes slide{from{transform:translateX(0)}to{transform:translateX(-50%)}}

/* ── MANIFESTO ── */
.manifesto{background:#0a2540;padding:70px 0;text-align:center;position:relative;overflow:hidden}
.manifesto::before{content:'GROUP4';position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-family:'Be Vietnam Pro',sans-serif;font-size:16rem;font-weight:800;color:rgba(255,255,255,.02);pointer-events:none;letter-spacing:-10px}
.manifesto-sub{font-size:.85rem;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:#63b3ed;margin-bottom:30px}
.manifesto-text{font-family:'Be Vietnam Pro',sans-serif;font-size:clamp(1.5rem,2.5vw,2.5rem);font-weight:800;color:#fff;line-height:1.25;letter-spacing:-.5px;max-width:800px;margin:0 auto}
.manifesto-text span{color:#63b3ed}

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

/* ── THÔNG BÁO NỘI BỘ ── */
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
        <span>Công ty CP Sản Xuất &amp; Thương Mại Group4</span><span>Chất lượng — Uy tín — Phát triển bền vững</span>
        <span>Hệ thống nội bộ dành cho CBCNV</span><span>ISO 9001:2015</span>
        <span>An toàn lao động là trên hết</span><span>Đồng hành cùng phát triển</span>
        <span>Công ty CP Sản Xuất &amp; Thương Mại Group4</span><span>Chất lượng — Uy tín — Phát triển bền vững</span>
        <span>Hệ thống nội bộ dành cho CBCNV</span><span>ISO 9001:2015</span>
        <span>An toàn lao động là trên hết</span><span>Đồng hành cùng phát triển</span>
    </div>
</div>

<!-- HERO SPLIT -->
<section class="hero-split">
    <div class="hero-left">
        <div class="hero-left-bg"></div>
        <span class="hero-year">Thành lập 2010 &nbsp;/&nbsp; Group4 Corp.</span>

        <c:choose>
            <c:when test="${sessionScope.currentUser != null}">
                <%-- Đã đăng nhập: chào tên --%>
                <div class="hero-user-badge">
                    <div class="online-dot"></div>
                    <span>Xin chào, <b>${sessionScope.currentUser.fullName}</b> &mdash; Bạn đang đăng nhập</span>
                </div>
                <h1 class="hero-title">Cổng Thông Tin<br><em>Nội Bộ.</em></h1>
                <p class="hero-subtitle">Tra cứu lương, chấm công, nghỉ phép và toàn bộ hồ sơ nhân sự của bạn tại một nơi duy nhất.</p>
            </c:when>
            <c:otherwise>
                <%-- Chưa đăng nhập --%>
                <h1 class="hero-title">Cổng Thông Tin<br><em>Nội Bộ.</em></h1>
                <p class="hero-subtitle">Chào mừng bạn đến với hệ thống quản trị nhân sự của Công ty CP Sản Xuất &amp; Thương Mại Group4 — nơi kết nối toàn bộ cán bộ công nhân viên trên một nền tảng duy nhất.</p>
                <div class="hero-cta-row">
                    <a href="${pageContext.request.contextPath}/login" class="btn-hero-main">
                        <i class="fas fa-sign-in-alt"></i> Đăng nhập hệ thống
                    </a>
                    <span style="color:rgba(255,255,255,.3);font-size:.8rem;letter-spacing:1px">Tài khoản do Phòng HCNS cấp</span>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="hero-right">
        <div class="hero-img-wrap">
            <div class="hero-img-label">Nhà máy — KCN Bắc Ninh</div>
        </div>
        <div class="hero-stats-bar">
            <div class="hstat">
                <div class="hstat-n">500+</div>
                <div class="hstat-l">Nhân sự</div>
            </div>
            <div class="hstat">
                <div class="hstat-n">08</div>
                <div class="hstat-l">Phòng ban</div>
            </div>
            <div class="hstat">
                <div class="hstat-n">15+</div>
                <div class="hstat-l">Năm hoạt động</div>
            </div>
        </div>
    </div>
</section>

<!-- VALUES STRIP -->
<div class="values-strip">
    <div style="padding:0 40px;font-size:.75rem;font-weight:700;letter-spacing:2px;color:#aaa;white-space:nowrap">GIÁ TRỊ CỐT LÕI</div>
    <div class="values-strip-inner">
        <span class="values-text">CHÍNH TRỰC</span>
        <span class="values-text">SÁNG TẠO</span>
        <span class="values-text">CHẤT LƯỢNG</span>
        <span class="values-text">ĐOÀN KẾT</span>
        <span class="values-text">TRÁCH NHIỆM</span>
        <span class="values-text">PHÁT TRIỂN BỀN VỮNG</span>
        <span class="values-text">CHÍNH TRỰC</span>
        <span class="values-text">SÁNG TẠO</span>
        <span class="values-text">CHẤT LƯỢNG</span>
        <span class="values-text">ĐOÀN KẾT</span>
        <span class="values-text">TRÁCH NHIỆM</span>
        <span class="values-text">PHÁT TRIỂN BỀN VỮNG</span>
    </div>
</div>

<!-- MANIFESTO -->
<section class="manifesto">
    <div class="container">
        <p class="manifesto-sub">Sứ mệnh của chúng tôi</p>
        <h2 class="manifesto-text">
            Xây dựng môi trường làm việc <span>chuyên nghiệp, an toàn</span>,<br>
            nơi mỗi nhân viên được <span>tôn trọng và phát triển</span>.
        </h2>
    </div>
</section>

<!-- FEATURES BAND -->
<section class="features-band">
    <div class="container">
        <div class="features-header">
            <h2>Tính năng<br>dành cho<br>nhân viên</h2>
            <span class="feat-count">06</span>
        </div>
        <div class="feat-list">
            <div class="feat-item">
                <span class="feat-num">01</span>
                <div class="feat-icon-wrap"><i class="fas fa-id-card"></i></div>
                <div class="feat-info">
                    <h3>Hồ sơ Nhân sự Cá nhân</h3>
                    <p>Xem và cập nhật thông tin cá nhân, hợp đồng lao động, lịch sử công tác trực tiếp trên hệ thống.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">02</span>
                <div class="feat-icon-wrap"><i class="fas fa-fingerprint"></i></div>
                <div class="feat-info">
                    <h3>Chấm công &amp; Ca kíp</h3>
                    <p>Chấm công trực tuyến, theo dõi lịch phân ca 3 ca sản xuất, xem lịch sử chấm công chi tiết.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">03</span>
                <div class="feat-icon-wrap"><i class="fas fa-money-check-alt"></i></div>
                <div class="feat-info">
                    <h3>Phiếu lương &amp; Thu nhập</h3>
                    <p>Tra cứu phiếu lương hàng tháng: lương cơ bản, phụ cấp, tăng ca, các khoản trích BHXH, thuế TNCN.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">04</span>
                <div class="feat-icon-wrap"><i class="fas fa-paper-plane"></i></div>
                <div class="feat-info">
                    <h3>Đơn Nghỉ phép Trực tuyến</h3>
                    <p>Gửi đơn xin nghỉ phép, theo dõi trạng thái duyệt, kiểm tra số ngày phép còn lại trong năm.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">05</span>
                <div class="feat-icon-wrap"><i class="fas fa-bullhorn"></i></div>
                <div class="feat-info">
                    <h3>Thông báo Nội bộ</h3>
                    <p>Nhận thông báo từ Ban Giám đốc, phòng HCNS về chính sách mới, lịch nghỉ lễ, sự kiện công ty.</p>
                </div>
                <span class="feat-arrow">&rarr;</span>
            </div>
            <div class="feat-item">
                <span class="feat-num">06</span>
                <div class="feat-icon-wrap"><i class="fas fa-shield-alt"></i></div>
                <div class="feat-info">
                    <h3>An toàn Lao động &amp; Đào tạo</h3>
                    <p>Tra cứu chứng chỉ ATLĐ, lịch huấn luyện định kỳ, nội quy nhà máy và quy trình ứng phó sự cố.</p>
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
        <div class="photo-cell-label">Đội ngũ kỹ thuật</div>
    </div>
    <div class="photo-cell">
        <img src="https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=600&auto=format&fit=crop" alt="Văn phòng">
        <div class="photo-cell-label">Văn phòng công ty</div>
    </div>
    <div class="photo-cell">
        <img src="https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=600&auto=format&fit=crop" alt="Phòng HCNS">
        <div class="photo-cell-label">Phòng Hành chính Nhân sự</div>
    </div>
    <div class="photo-cell">
        <img src="https://images.unsplash.com/photo-1521737711867-e3b97375f902?q=80&w=600&auto=format&fit=crop" alt="Team">
        <div class="photo-cell-label">Hoạt động Team Building</div>
    </div>
</div>

<!-- THÔNG BÁO NỘI BỘ -->
<section class="news-section">
    <div class="container">
        <div class="news-header">
            <h2>Thông báo<br>Nội bộ</h2>
            <a href="${pageContext.request.contextPath}/notifications">Xem tất cả &rarr;</a>
        </div>
        <div class="news-grid">
            <div class="news-card">
                <span class="news-tag2">Phúc lợi</span>
                <span class="news-date2">10 tháng 05, 2026</span>
                <h3 class="news-title2">Nâng mức hỗ trợ bữa ăn ca và phụ cấp xăng xe cho CBCNV từ tháng 06/2026</h3>
                <span class="news-arrow2">&rarr;</span>
            </div>
            <div class="news-card">
                <span class="news-tag2">Sức khỏe</span>
                <span class="news-date2">02 tháng 05, 2026</span>
                <h3 class="news-title2">Lịch khám sức khỏe định kỳ Quý II — Bắt buộc 100% nhân sự đăng ký trước 20/05</h3>
                <span class="news-arrow2">&rarr;</span>
            </div>
            <div class="news-card" style="background:#0a2540">
                <span class="news-tag2" style="color:#63b3ed">🔔 Thông báo hệ thống</span>
                <span class="news-date2" style="color:rgba(255,255,255,.5)">27 tháng 05, 2026</span>
                <h3 class="news-title2" style="color:#fff">Bảo trì hệ thống chấm công vào 22:00 thứ 7, 31/05/2026 — Dự kiến 2 giờ</h3>
                <span class="news-arrow2" style="color:#63b3ed">&rarr;</span>
            </div>
        </div>
    </div>
</section>

<jsp:include page="footer.jsp" />
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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


@media(max-width:768px){
.hero-split{grid-template-columns:1fr}
.hero-right{display:none}
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

<jsp:include page="footer.jsp" />

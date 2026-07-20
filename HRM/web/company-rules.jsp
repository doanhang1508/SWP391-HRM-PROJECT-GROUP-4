<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="pageTitle" value="Nội quy & Quy định Công ty" scope="request" />
<jsp:include page="/header.jsp"/>

<style>
    .dashboard-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .main-content {
        flex: 1;
        min-width: 0;
        overflow-x: hidden;
    }
    .rules-hero {
        background: linear-gradient(135deg, #0a2540 0%, #1a3a5c 60%, #1e4976 100%);
        color: #fff;
        padding: 48px 32px 40px;
        position: relative;
        overflow: hidden;
    }
    .rules-hero::before {
        content: '';
        position: absolute;
        top: -60px; right: -60px;
        width: 300px; height: 300px;
        background: rgba(99,179,237,.08);
        border-radius: 50%;
        pointer-events: none;
    }
    .rules-hero::after {
        content: '';
        position: absolute;
        bottom: -80px; left: -40px;
        width: 240px; height: 240px;
        background: rgba(99,179,237,.05);
        border-radius: 50%;
        pointer-events: none;
    }
    .rules-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(99,179,237,.18);
        color: #63b3ed;
        font-size: .78rem;
        font-weight: 700;
        letter-spacing: 1.5px;
        text-transform: uppercase;
        padding: 5px 14px;
        border-radius: 20px;
        margin-bottom: 16px;
    }
    .rules-card {
        background: var(--th-surface, #fff);
        border-radius: 14px;
        border: 1px solid var(--th-border, #e2e8f0);
        box-shadow: var(--th-card-shadow, 0 2px 12px rgba(0,0,0,.06));
        overflow: hidden;
        margin-bottom: 24px;
        transition: box-shadow .25s, background-color .3s;
    }
    .rules-card:hover { box-shadow: 0 6px 24px rgba(10,37,64,.12); }
    .rules-card-header {
        background: linear-gradient(90deg, #0a2540, #1a3a5c);
        color: #fff;
        padding: 18px 28px;
        display: flex;
        align-items: center;
        gap: 14px;
    }
    .rules-card-header .icon-wrap {
        width: 40px; height: 40px;
        background: rgba(99,179,237,.2);
        border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.1rem;
        color: #63b3ed;
        flex-shrink: 0;
    }
    .rules-card-body { padding: 24px 28px; }
    .rule-item {
        display: flex;
        align-items: flex-start;
        gap: 14px;
        padding: 13px 0;
        border-bottom: 1px solid var(--th-border, #f1f5f9);
    }
    .rule-item:last-child { border-bottom: none; }
    .rule-num {
        width: 26px; height: 26px;
        background: #ebf4ff;
        color: #0a2540;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: .75rem;
        font-weight: 700;
        flex-shrink: 0;
        margin-top: 2px;
    }
    .rule-text { font-size: .9rem; color: var(--th-text2, #2d3748); line-height: 1.65; }
    .rule-text strong { color: var(--th-text, #0a2540); }
    .toc-card {
        background: var(--th-surface, #f8fafc);
        border: 1px solid var(--th-border, #e2e8f0);
        border-radius: 12px;
        padding: 22px 24px;
        position: sticky;
        top: 84px;
    }
    .toc-card h6 {
        font-size: .75rem;
        font-weight: 700;
        letter-spacing: 1.5px;
        text-transform: uppercase;
        color: var(--th-muted, rgba(10,37,64,.45));
        margin-bottom: 16px;
    }
    .toc-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 8px 10px;
        border-radius: 8px;
        text-decoration: none;
        color: var(--th-text2, #4a5568);
        font-size: .875rem;
        transition: all .2s;
        margin-bottom: 2px;
    }
    .toc-link:hover { background: var(--th-hover-bg, #e2e8f0); color: var(--th-text, #0a2540); }
    .toc-link i { width: 16px; text-align: center; color: #63b3ed; }
    .highlight-box {
        background: linear-gradient(135deg, #ebf8ff, #e6fffa);
        border-left: 4px solid #63b3ed;
        border-radius: 0 10px 10px 0;
        padding: 16px 20px;
        margin-bottom: 24px;
        font-size: .875rem;
        color: #2d3748;
        line-height: 1.7;
    }
    .version-badge {
        display: inline-block;
        background: #ebf4ff;
        color: #0a2540;
        font-size: .75rem;
        font-weight: 600;
        padding: 3px 10px;
        border-radius: 20px;
        margin-left: 8px;
        vertical-align: middle;
    }

    @media (max-width: 991px) {
        .toc-card {
            position: static;
            margin-bottom: 24px;
        }
        .rules-hero {
            padding: 36px 20px 30px;
        }
    }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="/shared/sidebar.jsp"/>

    <div class="main-content">
        <!-- Hero -->
        <div class="rules-hero">
            <div class="container-fluid px-4 px-lg-5" style="position:relative;z-index:1">
                <div class="rules-badge"><i class="fas fa-shield-alt"></i> Văn bản nội bộ</div>
                <h1 style="font-family:'Be Vietnam Pro',sans-serif;font-weight:800;font-size:2rem;margin-bottom:10px">
                    Nội quy &amp; Quy định Công ty
                </h1>
                <p style="color:rgba(255,255,255,.65);font-size:.95rem;max-width:560px;margin:0">
                    Tập hợp các quy định, chính sách nhân sự và hướng dẫn hành vi áp dụng cho toàn thể cán bộ,
                    nhân viên Tập đoàn HRM. Có hiệu lực từ <strong style="color:#63b3ed">01/01/2025</strong>.
                    <span class="version-badge">Phiên bản 3.2</span>
                </p>
            </div>
        </div>

        <div class="container-fluid p-4 p-lg-5">
            <div class="row g-4">
                <!-- TOC -->
                <div class="col-lg-3">
                    <div class="toc-card">
                        <h6>Mục lục</h6>
                        <a href="#section-1" class="toc-link"><i class="fas fa-clock"></i> Giờ làm việc</a>
                        <a href="#section-2" class="toc-link"><i class="fas fa-calendar-times"></i> Nghỉ phép &amp; vắng mặt</a>
                        <a href="#section-3" class="toc-link"><i class="fas fa-user-tie"></i> Trang phục &amp; diện mạo</a>
                        <a href="#section-4" class="toc-link"><i class="fas fa-laptop"></i> Sử dụng tài sản</a>
                        <a href="#section-5" class="toc-link"><i class="fas fa-comments"></i> Giao tiếp &amp; ứng xử</a>
                        <a href="#section-6" class="toc-link"><i class="fas fa-lock"></i> Bảo mật thông tin</a>
                        <a href="#section-7" class="toc-link"><i class="fas fa-gavel"></i> Kỷ luật &amp; xử lý vi phạm</a>
                        <a href="#section-8" class="toc-link"><i class="fas fa-star"></i> Khen thưởng</a>
                        <hr style="margin:16px 0;border-color:var(--th-border, #e2e8f0)">
                        <p style="font-size:.78rem;color:var(--th-muted, #94a3b8);line-height:1.5;margin:0">
                            Cập nhật lần cuối:<br>
                            <strong style="color:var(--th-text2, #4a5568)">15/12/2024</strong>
                        </p>
                    </div>
                </div>

                <!-- Content -->
                <div class="col-lg-9">
                    <div class="highlight-box">
                        <i class="fas fa-info-circle" style="color:#63b3ed;margin-right:8px"></i>
                        Tài liệu này áp dụng cho <strong>tất cả nhân viên chính thức, hợp đồng thời vụ và thực tập sinh</strong>
                        của Tập đoàn HRM. Mọi thắc mắc liên hệ HR qua email
                        <a href="mailto:systemhrm4@gmail.com" style="color:#0a2540;font-weight:600">systemhrm4@gmail.com</a>.
                    </div>

                    <!-- Section 1 -->
                    <div class="rules-card" id="section-1">
                        <div class="rules-card-header">
                            <div class="icon-wrap"><i class="fas fa-clock"></i></div>
                            <div>
                                <div style="font-weight:700;font-size:1rem">Chương I — Giờ làm việc &amp; Chấm công</div>
                                <div style="font-size:.8rem;color:rgba(255,255,255,.5)">Điều 1–8</div>
                            </div>
                        </div>
                        <div class="rules-card-body">
                            <div class="rule-item"><div class="rule-num">1</div><div class="rule-text"><strong>Giờ làm việc tiêu chuẩn:</strong> 08:00–17:30, nghỉ trưa 12:00–13:30 (Thứ Hai đến Thứ Bảy). Chủ nhật là ngày nghỉ chính thức.</div></div>
                            <div class="rule-item"><div class="rule-num">2</div><div class="rule-text"><strong>Chấm công:</strong> Bắt buộc chấm công vào/ra mỗi ngày. Quên chấm phải nộp đơn điều chỉnh trước 17:00 cùng ngày qua hệ thống HRM.</div></div>
                            <div class="rule-item"><div class="rule-num">3</div><div class="rule-text"><strong>Đi muộn:</strong> Muộn dưới 15 phút tối đa 3 lần/tháng. Từ lần thứ 4 hoặc muộn trên 15 phút sẽ bị trừ lương theo quy chế.</div></div>
                            <div class="rule-item"><div class="rule-num">4</div><div class="rule-text"><strong>Làm thêm giờ (OT):</strong> Phải được cấp trên phê duyệt trước qua hệ thống. OT không phê duyệt sẽ không được tính lương tăng ca.</div></div>
                            <div class="rule-item"><div class="rule-num">5</div><div class="rule-text"><strong>Làm việc từ xa (WFH):</strong> Tối đa 4 ngày/tháng, cần Quản lý phê duyệt trước 1 ngày. Vẫn phải chấm công đúng giờ trên hệ thống.</div></div>
                        </div>
                    </div>

                    <!-- Section 2 -->
                    <div class="rules-card" id="section-2">
                        <div class="rules-card-header">
                            <div class="icon-wrap"><i class="fas fa-calendar-times"></i></div>
                            <div>
                                <div style="font-weight:700;font-size:1rem">Chương II — Nghỉ phép &amp; Vắng mặt</div>
                                <div style="font-size:.8rem;color:rgba(255,255,255,.5)">Điều 9–18</div>
                            </div>
                        </div>
                        <div class="rules-card-body">
                            <div class="rule-item"><div class="rule-num">6</div><div class="rule-text"><strong>Nghỉ phép năm:</strong> 12 ngày/năm với nhân viên đủ 12 tháng. Mỗi năm thâm niên thêm 1 ngày (tối đa 18 ngày). Phép không chuyển sang năm sau.</div></div>
                            <div class="rule-item"><div class="rule-num">7</div><div class="rule-text"><strong>Đăng ký nghỉ:</strong> 1–2 ngày: báo trước 2 ngày làm việc. Từ 3 ngày: báo trước 1 tuần và bàn giao công việc đầy đủ.</div></div>
                            <div class="rule-item"><div class="rule-num">8</div><div class="rule-text"><strong>Nghỉ ốm:</strong> Thông báo Quản lý trước 08:30. Nghỉ liên tiếp từ 2 ngày cần xuất trình giấy xác nhận y tế.</div></div>
                            <div class="rule-item"><div class="rule-num">9</div><div class="rule-text"><strong>Nghỉ đặc biệt (hưởng lương):</strong> Kết hôn (3 ngày), Tang cha/mẹ/vợ/chồng/con (3 ngày), Tang anh chị em ruột (1 ngày).</div></div>
                            <div class="rule-item"><div class="rule-num">10</div><div class="rule-text"><strong>Nghỉ không lương:</strong> Tối đa 30 ngày/năm sau khi hết phép. Cần Trưởng phòng và HR phê duyệt.</div></div>
                        </div>
                    </div>

                    <!-- Section 3 -->
                    <div class="rules-card" id="section-3">
                        <div class="rules-card-header">
                            <div class="icon-wrap"><i class="fas fa-user-tie"></i></div>
                            <div>
                                <div style="font-weight:700;font-size:1rem">Chương III — Trang phục &amp; Diện mạo</div>
                                <div style="font-size:.8rem;color:rgba(255,255,255,.5)">Điều 19–22</div>
                            </div>
                        </div>
                        <div class="rules-card-body">
                            <div class="rule-item"><div class="rule-num">11</div><div class="rule-text"><strong>Trang phục công sở:</strong> Thứ Hai–Năm: đồng phục hoặc trang phục lịch sự (áo có cổ, quần tây/váy công sở). Thứ Sáu–Bảy: Smart Casual được chấp nhận.</div></div>
                            <div class="rule-item"><div class="rule-num">12</div><div class="rule-text"><strong>Đeo thẻ nhân viên:</strong> Bắt buộc trong toàn bộ giờ làm việc và khuôn viên công ty. Mất thẻ cần báo ngay Bảo vệ và HR.</div></div>
                            <div class="rule-item"><div class="rule-num">13</div><div class="rule-text"><strong>Không được phép:</strong> Quần short, váy ngắn trên gối, áo hở vai, dép lê, trang phục có hình ảnh phản cảm trong môi trường công sở.</div></div>
                        </div>
                    </div>

                    <!-- Section 4 -->
                    <div class="rules-card" id="section-4">
                        <div class="rules-card-header">
                            <div class="icon-wrap"><i class="fas fa-laptop"></i></div>
                            <div>
                                <div style="font-weight:700;font-size:1rem">Chương IV — Sử dụng Tài sản Công ty</div>
                                <div style="font-size:.8rem;color:rgba(255,255,255,.5)">Điều 23–30</div>
                            </div>
                        </div>
                        <div class="rules-card-body">
                            <div class="rule-item"><div class="rule-num">14</div><div class="rule-text"><strong>Thiết bị công nghệ:</strong> Chỉ dùng cho mục đích công việc. Không cài phần mềm không được phép, không chia sẻ tài khoản hệ thống.</div></div>
                            <div class="rule-item"><div class="rule-num">15</div><div class="rule-text"><strong>Internet &amp; Email:</strong> Nghiêm cấm truy cập nội dung vi phạm pháp luật, mạng xã hội quá mức trong giờ làm việc cao điểm.</div></div>
                            <div class="rule-item"><div class="rule-num">16</div><div class="rule-text"><strong>Không gian làm việc:</strong> Giữ bàn làm việc gọn gàng. Khu bếp và phòng họp dọn dẹp sau khi dùng. Phòng họp đặt lịch qua hệ thống.</div></div>
                            <div class="rule-item"><div class="rule-num">17</div><div class="rule-text"><strong>Mang tài sản ra ngoài:</strong> Cần giấy phép của Trưởng bộ phận và xác nhận của Bảo vệ khi mang thiết bị công ty ra khỏi văn phòng.</div></div>
                        </div>
                    </div>

                    <!-- Section 5 -->
                    <div class="rules-card" id="section-5">
                        <div class="rules-card-header">
                            <div class="icon-wrap"><i class="fas fa-comments"></i></div>
                            <div>
                                <div style="font-weight:700;font-size:1rem">Chương V — Giao tiếp &amp; Ứng xử</div>
                                <div style="font-size:.8rem;color:rgba(255,255,255,.5)">Điều 31–38</div>
                            </div>
                        </div>
                        <div class="rules-card-body">
                            <div class="rule-item"><div class="rule-num">18</div><div class="rule-text"><strong>Văn hóa tôn trọng:</strong> Đối xử lịch sự, chuyên nghiệp với đồng nghiệp, khách hàng và đối tác. Mọi hình thức phân biệt đối xử, quấy rối đều bị nghiêm cấm.</div></div>
                            <div class="rule-item"><div class="rule-num">19</div><div class="rule-text"><strong>Giải quyết mâu thuẫn:</strong> Ưu tiên giải quyết trực tiếp, riêng tư. Nếu không tự giải quyết được, báo cáo lên Quản lý trực tiếp hoặc HR.</div></div>
                            <div class="rule-item"><div class="rule-num">20</div><div class="rule-text"><strong>Truyền thông nội bộ:</strong> Thông tin nội bộ chỉ chia sẻ qua kênh chính thức (Email, hệ thống HRM). Không phát tán thông tin chưa xác nhận.</div></div>
                            <div class="rule-item"><div class="rule-num">21</div><div class="rule-text"><strong>Mạng xã hội:</strong> Không đăng thông tin tiêu cực về công ty, đồng nghiệp, khách hàng. Nghiêm cấm đăng thông tin mật dưới mọi hình thức.</div></div>
                        </div>
                    </div>

                    <!-- Section 6 -->
                    <div class="rules-card" id="section-6">
                        <div class="rules-card-header">
                            <div class="icon-wrap"><i class="fas fa-lock"></i></div>
                            <div>
                                <div style="font-weight:700;font-size:1rem">Chương VI — Bảo mật Thông tin</div>
                                <div style="font-size:.8rem;color:rgba(255,255,255,.5)">Điều 39–46</div>
                            </div>
                        </div>
                        <div class="rules-card-body">
                            <div class="rule-item"><div class="rule-num">22</div><div class="rule-text"><strong>Thông tin mật:</strong> Dữ liệu khách hàng, tài chính, bí quyết kinh doanh, mã nguồn và thông tin nhân sự. Tuyệt đối không tiết lộ ra bên ngoài.</div></div>
                            <div class="rule-item"><div class="rule-num">23</div><div class="rule-text"><strong>Mật khẩu hệ thống:</strong> Thay đổi 90 ngày/lần. Không sử dụng mật khẩu cá nhân cho tài khoản công ty. Không chia sẻ mật khẩu với bất kỳ ai.</div></div>
                            <div class="rule-item"><div class="rule-num">24</div><div class="rule-text"><strong>Lưu trữ dữ liệu:</strong> Tài liệu mật lưu trên hệ thống nội bộ. Không lưu USB cá nhân hoặc dịch vụ đám mây không được phê duyệt.</div></div>
                            <div class="rule-item"><div class="rule-num">25</div><div class="rule-text"><strong>Sau khi nghỉ việc:</strong> Trả lại tất cả tài liệu, thiết bị và cam kết không tiết lộ thông tin mật trong 2 năm sau khi nghỉ.</div></div>
                        </div>
                    </div>

                    <!-- Section 7 -->
                    <div class="rules-card" id="section-7">
                        <div class="rules-card-header">
                            <div class="icon-wrap"><i class="fas fa-gavel"></i></div>
                            <div>
                                <div style="font-weight:700;font-size:1rem">Chương VII — Kỷ luật &amp; Xử lý Vi phạm</div>
                                <div style="font-size:.8rem;color:rgba(255,255,255,.5)">Điều 47–58</div>
                            </div>
                        </div>
                        <div class="rules-card-body">
                            <div class="rule-item"><div class="rule-num">26</div><div class="rule-text"><strong>Hình thức kỷ luật:</strong> (1) Nhắc nhở; (2) Cảnh cáo văn bản; (3) Khấu trừ lương/thưởng; (4) Điều chuyển công tác; (5) Sa thải.</div></div>
                            <div class="rule-item"><div class="rule-num">27</div><div class="rule-text"><strong>Vi phạm bị sa thải ngay:</strong> Tiết lộ thông tin mật gây thiệt hại, gian lận tài chính, quấy rối tình dục, bạo lực hoặc vi phạm pháp luật nghiêm trọng.</div></div>
                            <div class="rule-item"><div class="rule-num">28</div><div class="rule-text"><strong>Quy trình xử lý:</strong> Hội đồng kỷ luật gồm HR, Quản lý trực tiếp và đại diện bộ phận. Nhân viên có quyền trình bày trong 5 ngày làm việc.</div></div>
                            <div class="rule-item"><div class="rule-num">29</div><div class="rule-text"><strong>Phúc khiếu:</strong> Khiếu nại lên BGĐ trong 10 ngày làm việc kể từ ngày nhận thông báo. Quyết định của BGĐ là quyết định cuối cùng.</div></div>
                        </div>
                    </div>

                    <!-- Section 8 -->
                    <div class="rules-card" id="section-8">
                        <div class="rules-card-header">
                            <div class="icon-wrap"><i class="fas fa-star"></i></div>
                            <div>
                                <div style="font-weight:700;font-size:1rem">Chương VIII — Khen thưởng &amp; Công nhận</div>
                                <div style="font-size:.8rem;color:rgba(255,255,255,.5)">Điều 59–65</div>
                            </div>
                        </div>
                        <div class="rules-card-body">
                            <div class="rule-item"><div class="rule-num">30</div><div class="rule-text"><strong>Thưởng hiệu suất:</strong> Đánh giá KPI hàng quý. Đạt từ 90% được xét thưởng 0.5–3 tháng lương cơ bản tùy xếp loại.</div></div>
                            <div class="rule-item"><div class="rule-num">31</div><div class="rule-text"><strong>Thưởng sáng kiến:</strong> Sáng kiến được ban hành chính thức: 500.000–5.000.000 VNĐ tùy mức độ tiết kiệm chi phí cho công ty.</div></div>
                            <div class="rule-item"><div class="rule-num">32</div><div class="rule-text"><strong>Nhân viên xuất sắc:</strong> Bình chọn hàng quý (1 người/phòng ban). Phần thưởng: bằng khen, 1 ngày phép + 2.000.000 VNĐ, và xét tăng lương sớm.</div></div>
                            <div class="rule-item"><div class="rule-num">33</div><div class="rule-text"><strong>Phúc lợi khác:</strong> Bảo hiểm sức khỏe toàn diện, khám sức khỏe định kỳ, hỗ trợ học phí tối đa 5.000.000 VNĐ/năm, team building hàng quý.</div></div>
                        </div>
                    </div>

                    <!-- Footer note -->
                    <div style="background:var(--th-surface,#f8fafc);border:1px solid var(--th-border,#e2e8f0);border-radius:12px;padding:20px 24px;display:flex;gap:16px;align-items:flex-start">
                        <i class="fas fa-file-signature" style="color:#63b3ed;font-size:1.3rem;margin-top:2px"></i>
                        <div>
                            <div style="font-weight:700;color:var(--th-text,#0a2540);margin-bottom:6px">Cam kết thực hiện</div>
                            <p style="font-size:.875rem;color:var(--th-text2,#4a5568);margin:0;line-height:1.7">
                                Khi bắt đầu làm việc tại Tập đoàn HRM, mọi nhân viên đã ký xác nhận đọc, hiểu và đồng ý tuân thủ
                                toàn bộ nội quy này. Tài liệu có hiệu lực từ <strong>01/01/2025</strong>. Để báo cáo vi phạm,
                                liên hệ <a href="mailto:systemhrm4@gmail.com" style="color:#0a2540;font-weight:600">systemhrm4@gmail.com</a>.
                            </p>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/footer.jsp"/>


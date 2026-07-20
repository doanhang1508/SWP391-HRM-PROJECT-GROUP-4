<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        </main>

        <style>
            .social-link {
                width: 36px;
                height: 36px;
                border: 1px solid rgba(255,255,255,.15);
                display: flex;
                align-items: center;
                justify-content: center;
                color: rgba(255,255,255,.5);
                text-decoration: none;
                transition: all .3s;
            }
            .social-link:hover,
            .social-link:focus {
                border-color: #63b3ed;
                color: #63b3ed;
                outline: none;
            }
            .footer-link {
                color: rgba(255,255,255,.6);
                text-decoration: none;
                font-size: .88rem;
                transition: color .2s;
            }
            .footer-link:hover,
            .footer-link:focus {
                color: #fff;
                outline: none;
            }
            .footer-bottom-link {
                color: rgba(255,255,255,.3);
                font-size: .8rem;
                text-decoration: none;
                transition: color .2s;
            }
            .footer-bottom-link:hover,
            .footer-bottom-link:focus {
                color: rgba(255,255,255,.6);
                outline: none;
            }
        </style>

        <footer style="background:#0a2540;color:#fff">
            <div style="height:1px;background:rgba(255,255,255,.08)"></div>

            <div class="container py-5">
                <div class="row g-5">
                    <!-- Brand -->
                    <div class="col-lg-4">
                        <div style="display:flex;align-items:center;gap:10px;margin-bottom:20px">
                            <i class="fas fa-industry" style="color:#63b3ed;font-size:1.4rem"></i>
                            <span
                                style="font-family:'Be Vietnam Pro',sans-serif;font-weight:800;font-size:1.2rem;letter-spacing:-.5px">TẬP
                                ĐOÀN HRM</span>
                        </div>
                        <p
                            style="color:rgba(255,255,255,.5);font-size:.88rem;line-height:1.7;max-width:280px;margin-bottom:25px">
                            Hệ thống Quản trị Nhân lực toàn diện — số hóa mọi quy trình từ chấm công, tính lương đến
                            phát triển năng lực đội ngũ.
                        </p>
                        <div style="display:flex;gap:12px">
                            <a href="#" class="social-link">
                                <i class="fab fa-linkedin-in" style="font-size:.85rem"></i>
                            </a>
                            <a href="#" class="social-link">
                                <i class="fab fa-facebook-f" style="font-size:.85rem"></i>
                            </a>
                        </div>
                    </div>

                    <!-- Links 1 -->
                    <div class="col-6 col-lg-2">
                        <h6
                            style="font-size:.75rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,.35);margin-bottom:20px">
                            Phân hệ</h6>
                        <ul style="list-style:none;padding:0;margin:0">
                            <li style="margin-bottom:14px"><a href="${pageContext.request.contextPath}/hr/employees" class="footer-link">Hồ sơ nhân sự</a></li>
                            <li style="margin-bottom:14px"><a href="${pageContext.request.contextPath}/hr/attendance-management" class="footer-link">Chấm công ca kíp</a></li>
                            <li style="margin-bottom:14px"><a href="${pageContext.request.contextPath}/hr/payroll" class="footer-link">Bảng lương &amp; C&amp;B</a></li>
                            <li style="margin-bottom:14px"><a href="${pageContext.request.contextPath}/hr/kpi-performance-report" class="footer-link">Báo cáo &amp; KPI</a></li>
                        </ul>
                    </div>

                    <!-- Links 2 -->
                    <div class="col-6 col-lg-2">
                        <h6
                            style="font-size:.75rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,.35);margin-bottom:20px">
                            Nhân viên</h6>
                        <ul style="list-style:none;padding:0;margin:0">
                            <li style="margin-bottom:14px"><a href="${pageContext.request.contextPath}/employee/timesheet" class="footer-link">Sổ tay nhân viên</a></li>
                            <li style="margin-bottom:14px"><a href="${pageContext.request.contextPath}/company-rules.jsp" class="footer-link">Quy định công ty</a></li>
                            <li style="margin-bottom:14px"><a href="${pageContext.request.contextPath}/employee/leave" class="footer-link">Biểu mẫu xin nghỉ</a></li>
                            <li style="margin-bottom:14px"><a href="${pageContext.request.contextPath}/employee/schedule" class="footer-link">Lịch làm việc</a></li>
                        </ul>
                    </div>

                    <!-- Contact -->
                    <div class="col-lg-4">
                        <h6
                            style="font-size:.75rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,.35);margin-bottom:20px">
                            Liên hệ</h6>
                        <ul style="list-style:none;padding:0;margin:0">
                            <li style="margin-bottom:16px;display:flex;align-items:center;gap:12px">
                                <i class="fas fa-envelope" style="color:#63b3ed;width:16px"></i>
                                <a href="mailto:systemhrm4@gmail.com" class="footer-link">systemhrm4@gmail.com</a>
                            </li>
                            <li style="margin-bottom:16px;display:flex;align-items:center;gap:12px">
                                <i class="fas fa-headset" style="color:#63b3ed;width:16px"></i>
                                <span style="color:rgba(255,255,255,.6);font-size:.88rem">Hotline IT: 1900 1008</span>
                            </li>
                            <li style="display:flex;align-items:flex-start;gap:12px">
                                <i class="fas fa-map-marker-alt" style="color:#63b3ed;width:16px;margin-top:3px"></i>
                                <span style="color:rgba(255,255,255,.6);font-size:.88rem">Khu CNC Hòa Lạc, Thạch Thất,
                                    Hà Nội</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <div style="border-top:1px solid rgba(255,255,255,.08)">
                <div class="container py-4 d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <p style="color:rgba(255,255,255,.3);font-size:.8rem;margin:0">
                        &copy; <%= java.time.Year.now().getValue() %> Nhóm 4 — Dự án SWP391 ĐH FPT. All rights reserved.
                    </p>
                    <a href="#" class="footer-bottom-link">Chính sách bảo mật nội bộ</a>
                </div>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

        <c:if test="${not empty sessionScope.currentUser}">
            <div id="chatWidget" style="position:fixed;bottom:24px;right:24px;z-index:9999;">
                <button onclick="document.getElementById('chatWindow').style.display='block'"
                    style="width:54px;height:54px;background:#0a2540;border:1px solid rgba(255,255,255,.2);color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;">
                    <i class="fas fa-headset"></i>
                </button>
                <div id="chatWindow"
                    style="display:none;position:absolute;bottom:65px;right:0;width:320px;background:#fff;border:1px solid #e2e8f0;box-shadow:0 8px 30px rgba(0,0,0,.1);">
                    <div
                        style="background:#0a2540;padding:16px 20px;display:flex;align-items:center;justify-content:space-between">
                        <span style="color:#fff;font-weight:700;font-size:.9rem"><i
                                class="fas fa-laptop-medical me-2"></i>Hỗ trợ IT Nội bộ</span>
                        <button onclick="document.getElementById('chatWindow').style.display='none'"
                            style="background:none;border:none;color:rgba(255,255,255,.6);cursor:pointer"><i
                                class="fas fa-times"></i></button>
                    </div>
                    <div style="padding:30px 20px;text-align:center">
                        <i class="fas fa-tools fa-2x text-muted mb-3 d-block" style="opacity:.4"></i>
                        <p style="font-size:.85rem;color:#4a5568">Xin chào
                            <b>${sessionScope.currentUser.fullName}</b>,<br>Bạn đang gặp sự cố về máy tính hay tài khoản
                            phần mềm?</p>
                        <button
                            style="background:#0a2540;color:#fff;border:none;padding:8px 24px;font-size:.85rem;font-weight:600;cursor:pointer;margin-top:8px">Tạo
                            Ticket Hỗ trợ</button>
                    </div>
                </div>
            </div>
        </c:if>
        </body>

        </html>

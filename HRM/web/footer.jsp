<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

    </main>
    
    <footer class="mt-auto bg-white border-top pt-5">
        <div class="container pb-4">
            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="d-flex align-items-center gap-2 mb-3">
                        <div class="rounded-3 d-flex align-items-center justify-content-center text-white bg-gradient-hrm" style="width: 40px; height: 40px;">
                            <i class="fas fa-users-cog"></i>
                        </div>
                        <span class="fw-bold fs-5 text-gradient-hrm">Grupo4 HRM</span>
                    </div>
                    <p class="text-muted small mb-4" style="max-width: 280px;">
                        Nền tảng Quản trị Nhân sự toàn diện. Tối ưu hóa quy trình chấm công, tính lương và phát triển nguồn nhân lực cho doanh nghiệp.
                    </p>
                    <div class="d-flex gap-2">
                        <a href="#" class="btn btn-sm btn-light rounded-circle" style="width:35px;height:35px;"><i class="fab fa-linkedin-in text-primary"></i></a>
                        <a href="#" class="btn btn-sm btn-light rounded-circle" style="width:35px;height:35px;"><i class="fab fa-facebook-f text-primary"></i></a>
                        <a href="#" class="btn btn-sm btn-light rounded-circle" style="width:35px;height:35px;"><i class="fas fa-globe text-primary"></i></a>
                    </div>
                </div>
                
                <div class="col-6 col-lg-3">
                    <h6 class="fw-bold mb-3 text-dark">Phân hệ chức năng</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary"><i class="fas fa-users me-2"></i>Quản lý nhân sự</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary"><i class="fas fa-clock me-2"></i>Chấm công tự động</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary"><i class="fas fa-file-invoice-dollar me-2"></i>Xử lý bảng lương</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary"><i class="fas fa-chart-bar me-2"></i>Báo cáo thống kê</a></li>
                    </ul>
                </div>
                
                <div class="col-6 col-lg-2">
                    <h6 class="fw-bold mb-3 text-dark">Dành cho nhân viên</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary">Sổ tay nhân viên</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary">Quy định công ty</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary">Biểu mẫu xin nghỉ</a></li>
                        <li class="mb-2"><a href="#" class="text-muted text-decoration-none hover-primary">Cổng Helpdesk IT</a></li>
                    </ul>
                </div>
                
                <div class="col-12 col-lg-3">
                    <h6 class="fw-bold mb-3 text-dark">Trung tâm hỗ trợ</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-3">
                            <a href="mailto:admin@grupo4.com" class="text-muted text-decoration-none d-flex align-items-center gap-2 hover-primary">
                                <i class="fas fa-envelope text-primary"></i>admin@group4.com
                            </a>
                        </li>
                        <li class="mb-3">
                            <span class="text-muted d-flex align-items-center gap-2">
                                <i class="fas fa-headset text-primary"></i>Hotline IT: 1900 1008
                            </span>
                        </li>
                        <li>
                            <span class="text-muted d-flex align-items-start gap-2">
                                <i class="fas fa-map-marker-alt text-primary mt-1"></i>
                                <span>Khu CNC Hòa Lạc, Thạch Thất, Hà Nội</span>
                            </span>
                        </li>
                    </ul>
                </div>
            </div>
            
            <hr class="my-4 text-muted">
            
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3">
                <p class="small text-muted mb-0">&copy; <%= java.time.Year.now().getValue() %> Nhóm 4 - Dự án SWP391 ĐH FPT. All rights reserved.</p>
                <div class="d-flex gap-3">
                    <a href="#" class="small text-muted text-decoration-none hover-primary">Chính sách bảo mật nội bộ</a>
                </div>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <c:if test="${not empty sessionScope.account}">
    <div id="chatWidget" style="position:fixed;bottom:24px;right:24px;z-index:9999;">
        <button onclick="document.getElementById('chatWindow').style.display='block'" class="btn rounded-circle shadow-lg text-white" 
            style="width:60px;height:60px;background:var(--primary-hrm);border:none;position:relative;">
            <i class="fas fa-headset fa-lg"></i>
        </button>
        <div id="chatWindow" class="shadow-lg rounded-4 overflow-hidden" 
            style="display:none;position:absolute;bottom:75px;right:0;width:350px;background:#fff;border:1px solid rgba(0,0,0,0.1);">
            <div class="d-flex align-items-center justify-content-between p-3 bg-gradient-hrm text-white">
                <div class="d-flex align-items-center gap-2">
                    <i class="fas fa-laptop-medical"></i>
                    <strong class="small">Hỗ trợ IT Nội bộ</strong>
                </div>
                <button onclick="document.getElementById('chatWindow').style.display='none'" class="btn btn-sm p-0 text-white"><i class="fas fa-times"></i></button>
            </div>
            <div class="p-4 text-center" style="height:250px; background:#f8fbff;">
                <i class="fas fa-tools fa-3x mb-3 text-muted opacity-50"></i>
                <p class="small text-muted">Xin chào <b>${sessionScope.account.fullName}</b>,<br>Bạn đang gặp sự cố về máy tính hay tài khoản phần mềm?</p>
                <button class="btn btn-sm btn-outline-primary rounded-pill mt-2">Tạo Ticket Hỗ trợ</button>
            </div>
        </div>
    </div>
    </c:if>
</body>
</html>
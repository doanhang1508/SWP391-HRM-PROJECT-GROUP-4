<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<style>
    /* Custom CSS để đồng bộ với hệ thống HRM */
    .glass-card { 
        background: rgba(255, 255, 255, 0.95); 
        backdrop-filter: blur(15px); 
        border-radius: 20px; 
        border: 1px solid rgba(255,255,255,0.3); 
        box-shadow: 0 10px 30px rgba(0,0,0,0.08); 
    }
    .profile-nav .nav-link { 
        color: #666; font-weight: 600; border-radius: 12px; padding: 12px 20px; 
        transition: all 0.3s ease; 
    }
    .profile-nav .nav-link.active { 
        background: linear-gradient(135deg, #764ba2 0%, #d87bbd 100%); 
        color: white; 
    }
    .nav-link:hover:not(.active) { background: rgba(118, 75, 162, 0.05); }
    .btn-save-changes {
    background: linear-gradient(135deg, #764ba2 0%, #d87bbd 100%);
    color: white;
    padding: 12px 30px;
    border-radius: 50px; /* Bo tròn hoàn toàn */
    font-weight: 700;
    border: none;
    box-shadow: 0 8px 20px rgba(118, 75, 162, 0.25);
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
}

.btn-save-changes:hover {
    transform: translateY(-3px);
    box-shadow: 0 12px 25px rgba(118, 75, 162, 0.4);
    color: white;
    background: linear-gradient(135deg, #8569bf 0%, #e08cc7 100%);
}
</style>
<script>
    function previewImage(event) {
        const reader = new FileReader();
        const avatar = document.getElementById('profileAvatar');
        
        reader.onload = function() {
            // Hiển thị ảnh vừa chọn lên thẻ img
            avatar.src = reader.result;
            // Ở đây sau này Hằng sẽ thêm đoạn code gửi file lên server (AJAX)
            console.log("Ảnh mới đã sẵn sàng để upload!");
        }
        
        if (event.target.files[0]) {
            reader.readAsDataURL(event.target.files[0]);
        }
    }
</script>
<script>
    function toggleEdit() {
        // Lấy danh sách tất cả các ô input/select trong form
        const inputs = document.querySelectorAll('#info input, #info select');
        const saveBtn = document.getElementById('saveBtn');
        
        // Duyệt qua từng ô để bỏ hoặc thêm lại thuộc tính disabled
        inputs.forEach(input => {
            input.disabled = !input.disabled;
        });

        // Hiện hoặc ẩn nút Lưu thay đổi
        if (saveBtn.classList.contains('d-none')) {
            saveBtn.classList.remove('d-none'); // Hiện nút Lưu
        } else {
            saveBtn.classList.add('d-none'); // Ẩn nút Lưu
        }
    }
</script>
<div class="container py-5">
    <c:if test="${not empty msgSuccess}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i> ${msgSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty msgError}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i> ${msgError}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <div class="row g-4">
        <div class="col-lg-3">
            <div class="glass-card p-4 text-center sticky-top" style="top: 100px;">
                <div class="position-relative d-inline-block mb-3">
    <img src="${sessionScope.currentUser.avatarUrl != null ? sessionScope.currentUser.avatarUrl : 'assets/img/default-avatar.png'}" 
         id="profileAvatar"
         class="rounded-circle border border-3 border-white shadow-sm" 
         width="120" height="120" style="object-fit: cover;">
    
    <label for="avatarUpload" class="position-absolute bottom-0 end-0 bg-primary text-white rounded-circle p-2 shadow-sm" 
           style="cursor: pointer; border: 2px solid white;">
        <i class="fas fa-camera"></i>
    </label>
    
    <input type="file" id="avatarUpload" class="d-none" accept="image/*" onchange="previewImage(event)">
</div>
                <h5 class="fw-bold mb-1">${sessionScope.currentUser.fullName}</h5>
                <p class="text-muted small">
                    ${sessionScope.currentUser.roleId == 1 ? 'Quản trị viên' : (sessionScope.currentUser.roleId == 2 ? 'Quản lý' : 'Nhân viên')}
                </p>
                
            </div>

            <div class="glass-card p-2 mt-4 profile-nav">
                <div class="nav flex-column nav-pills" id="v-pills-tab" role="tablist">
                    <button class="nav-link active" data-bs-toggle="pill" data-bs-target="#info"><i class="fas fa-info-circle me-2"></i>Thông tin chung</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#work"><i class="fas fa-briefcase me-2"></i>Lịch sử công việc</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#security"><i class="fas fa-shield-alt me-2"></i>Bảo mật</button>
                </div>
            </div>
        </div>

        <div class="col-lg-9">
            <div class="glass-card p-4">
                <div class="tab-content" id="v-pills-tabContent">
                    <div class="tab-pane fade show active" id="info">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h5 class="fw-bold mb-0">Thông tin cá nhân</h5>
        <button class="btn btn-outline-primary btn-sm rounded-pill px-3" onclick="toggleEdit()">
            <i class="fas fa-edit me-1"></i> Chỉnh sửa
        </button>
    </div>
                        
    
    <form action="${pageContext.request.contextPath}/profile" method="POST">
        <input type="hidden" name="action" value="update_profile">
        <div class="row g-3">
            <div class="col-md-6">
                <label class="small fw-bold mb-1">Họ và tên</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fas fa-user text-primary"></i></span>
                    <input type="text" class="form-control border-start-0 ps-0" name="fullName" value="${sessionScope.currentUser.fullName}" disabled id="input-fullName">
                </div>
            </div>
            <div class="col-md-6">
                <label class="small fw-bold mb-1">Email</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fas fa-envelope text-primary"></i></span>
                    <!-- Email không cho phép sửa -->
                    <input type="email" class="form-control border-start-0 ps-0" value="${sessionScope.currentUser.email}" disabled>
                </div>
               
            </div>
            <div class="col-md-6">
                <label class="small fw-bold mb-1">Số điện thoại</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fas fa-phone text-primary"></i></span>
                    <input type="tel" class="form-control border-start-0 ps-0" name="phone" value="${sessionScope.currentUser.phone}" disabled id="input-phone">
                </div>
            </div>
            <!-- Đã loại bỏ ngày sinh và giới tính do chưa có trong Database -->
        </div>
        <div class="d-flex justify-content-end mt-4">
    <button type="submit" class="btn btn-save-changes d-none" id="saveBtn">
        <i class="fas fa-save me-2"></i> Lưu thay đổi
    </button>
</div>
    </form>
</div>

                    <div class="tab-pane fade" id="work">
                        <h5 class="fw-bold mb-4">Quá trình công tác</h5>
                        <div class="list-group list-group-flush">
                            <div class="list-group-item bg-transparent">
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-0">Thực tập sinh Software Engineering</h6>
                                    <span class="badge bg-success">Hiện tại</span>
                                </div>
                                <small class="text-muted">Từ 01/2026</small>
                            </div>
                        </div>
                    </div>

                    <!-- TAB BẢO MẬT (ĐỔI MẬT KHẨU) -->
                    <div class="tab-pane fade" id="security">
                        <h5 class="fw-bold mb-4"><i class="fas fa-key me-2 text-warning"></i>Đổi mật khẩu</h5>
                        <form action="${pageContext.request.contextPath}/changePassword" method="POST">
                            
                            <div class="mb-3">
                                <label class="small fw-bold mb-1">Mật khẩu cũ</label>
                                <input type="password" name="oldPassword" class="form-control" required>
                            </div>
                            
                            <div class="mb-3">
                                <label class="small fw-bold mb-1">Mật khẩu mới</label>
                                <input type="password" name="newPassword" class="form-control" required minlength="6">
                            </div>
                            
                            <div class="mb-4">
                                <label class="small fw-bold mb-1">Xác nhận mật khẩu mới</label>
                                <input type="password" name="confirmPassword" class="form-control" required minlength="6">
                            </div>
                            
                            <button type="submit" class="btn btn-save-changes">
                                <i class="fas fa-check me-2"></i> Xác nhận đổi
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Admin Control Center - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<!-- Tích hợp Chart.js từ CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    body { background-color: #f4f7f6; }
    .dashboard-container { margin-top: 80px; padding-bottom: 50px; }
    
    .admin-welcome {
        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        color: white; border-radius: 12px; padding: 25px 30px;
        box-shadow: 0 10px 20px rgba(15, 23, 42, 0.2); margin-bottom: 25px;
        display: flex; justify-content: space-between; align-items: center;
    }
    
    /* Stat Cards */
    .stat-card {
        background: white; border-radius: 12px; padding: 20px;
        display: flex; align-items: center; justify-content: space-between;
        box-shadow: 0 4px 6px rgba(0,0,0,0.02); border: 1px solid #e2e8f0;
        transition: transform 0.2s;
    }
    .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 15px rgba(0,0,0,0.05); }
    .stat-info h3 { margin: 0; font-size: 1.8rem; font-weight: 800; color: #1e293b; }
    .stat-info span { font-size: 0.85rem; color: #64748b; font-weight: 600; text-transform: uppercase; }
    .stat-icon {
        width: 50px; height: 50px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; font-size: 1.5rem;
    }
    
    /* Panels */
    .admin-panel {
        background: white; border-radius: 12px; padding: 20px;
        border: 1px solid #e2e8f0; margin-bottom: 25px; height: 100%;
    }
    .panel-header {
        font-weight: 700; color: #0f172a; font-size: 1.1rem;
        margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #f1f5f9;
        display: flex; justify-content: space-between; align-items: center;
    }
    
    /* Quick Actions */
    .quick-action-btn {
        display: flex; align-items: center; padding: 12px 15px;
        background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px;
        color: #334155; font-weight: 600; text-decoration: none; margin-bottom: 10px;
        transition: all 0.2s;
    }
    .quick-action-btn i { font-size: 1.2rem; width: 30px; text-align: center; margin-right: 10px; }
    .quick-action-btn:hover { background: #e2e8f0; color: #0f172a; }
</style>

<div class="container dashboard-container">
    
    <!-- Admin Header -->
    <div class="row">
        <div class="col-12">
            <div class="admin-welcome">
                <div>
                    <h3 class="fw-bold mb-1"><i class="fas fa-shield-alt text-warning me-2"></i> SYSTEM CONTROL CENTER</h3>
                    <p class="mb-0 opacity-75">Quản trị viên: ${sessionScope.currentUser.fullName}</p>
                </div>
                <div class="text-end">
                    <div class="small opacity-75">Trạng thái Server</div>
                    <div class="fw-bold text-success"><i class="fas fa-circle ms-1" style="font-size: 10px;"></i> ONLINE - Mượt mà</div>
                </div>
            </div>
        </div>
    </div>

    <!-- 4 Stat Cards -->
    <div class="row g-4 mb-4">
        <div class="col-md-3 col-sm-6">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${totalUsers}</h3>
                    <span>Tổng Nhân Sự</span>
                </div>
                <div class="stat-icon" style="background: #e0f2fe; color: #0284c7;">
                    <i class="fas fa-users"></i>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${pendingLeaves}</h3>
                    <span>Yêu Cầu Nghỉ Phép</span>
                </div>
                <div class="stat-icon" style="background: #fef08a; color: #a16207;">
                    <i class="fas fa-envelope-open-text"></i>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${totalDepartments}</h3>
                    <span>Phòng Ban</span>
                </div>
                <div class="stat-icon" style="background: #dcfce7; color: #15803d;">
                    <i class="fas fa-building"></i>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>${totalRoles}</h3>
                    <span>Vai Trò Hệ Thống</span>
                </div>
                <div class="stat-icon" style="background: #f3e8ff; color: #7e22ce;">
                    <i class="fas fa-user-shield"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Biểu đồ & Thao tác nhanh -->
    <div class="row g-4">
        <!-- Cột Trái: Chart -->
        <div class="col-lg-8">
            <div class="admin-panel">
                <div class="panel-header">
                    <span><i class="fas fa-chart-line text-primary me-2"></i> Tỉ Lệ Chấm Công (7 Ngày Qua)</span>
                    <button class="btn btn-sm btn-outline-secondary">Xuất báo cáo</button>
                </div>
                <!-- Container cho Biểu đồ -->
                <div style="height: 350px;">
                    <canvas id="attendanceChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Cột Phải: Thao tác & Logs -->
        <div class="col-lg-4">
            <div class="admin-panel mb-4">
                <div class="panel-header">
                    <span><i class="fas fa-bolt text-warning me-2"></i> Thao Tác Nhanh</span>
                </div>
                <a href="${pageContext.request.contextPath}/admin/employees/add" class="quick-action-btn">
                    <i class="fas fa-user-plus text-success"></i> Thêm mới Nhân viên
                </a>
                <a href="${pageContext.request.contextPath}/admin/roles" class="quick-action-btn">
                    <i class="fas fa-key text-primary"></i> Quản lý Phân Quyền
                </a>
                <a href="${pageContext.request.contextPath}/admin/payroll/generate" class="quick-action-btn">
                    <i class="fas fa-money-check-alt text-warning"></i> Chốt Lương Tháng
                </a>
            </div>

            <div class="admin-panel">
                <div class="panel-header">
                    <span><i class="fas fa-history text-secondary me-2"></i> Lịch Sử Hệ Thống</span>
                </div>
                <ul class="list-unstyled mb-0 small">
                    <li class="mb-3 border-bottom pb-2">
                        <strong class="text-dark">admin@hrm.com</strong> vừa cập nhật phân quyền cho Role Manager.
                        <div class="text-muted mt-1" style="font-size: 0.75rem;">10 phút trước</div>
                    </li>
                    <li class="mb-3 border-bottom pb-2">
                        <strong class="text-dark">Hệ Thống</strong> tự động sao lưu Database thành công.
                        <div class="text-muted mt-1" style="font-size: 0.75rem;">02:00 AM</div>
                    </li>
                    <li class="mb-0">
                        <strong class="text-dark">manager@hrm.com</strong> duyệt 3 đơn xin nghỉ phép.
                        <div class="text-muted mt-1" style="font-size: 0.75rem;">Hôm qua</div>
                    </li>
                </ul>
            </div>
        </div>
    </div>

</div>

<!-- Cấu hình Chart.js -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const ctx = document.getElementById('attendanceChart').getContext('2d');
        
        // Dữ liệu giả lập
        const labels = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
        const dataPresent = [240, 245, 238, 242, 248, 120, 10]; // Số người đi làm
        const dataAbsent = [8, 3, 10, 6, 0, 128, 238];          // Số người vắng/nghỉ

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Đi làm',
                        data: dataPresent,
                        backgroundColor: '#3b82f6', // Xanh blue
                        borderRadius: 4
                    },
                    {
                        label: 'Vắng / Nghỉ phép',
                        data: dataAbsent,
                        backgroundColor: '#ef4444', // Đỏ
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        stacked: true,
                        grid: { display: false }
                    },
                    y: {
                        stacked: true,
                        beginAtZero: true,
                        suggestedMax: 250
                    }
                },
                plugins: {
                    legend: {
                        position: 'top',
                    }
                }
            }
        });
    });
</script>

<jsp:include page="../footer.jsp" />

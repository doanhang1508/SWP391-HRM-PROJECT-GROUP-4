<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Hồ sơ nhân sự - HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f0f4f8; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 30px; }
    
    .profile-hero {
        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        border-radius: 16px; padding: 32px; color: white; margin-bottom: 24px; display: flex; align-items: center; gap: 24px;
    }
    .profile-avatar {
        width: 100px; height: 100px; border-radius: 16px; background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        display: flex; align-items: center; justify-content: center; font-size: 2.5rem; font-weight: 800; color: #fff;
        box-shadow: 0 8px 20px rgba(0,0,0,0.2);
    }
    .profile-info h2 { margin: 0 0 8px; font-size: 1.8rem; font-weight: 700; }
    .profile-meta { display: flex; gap: 20px; font-size: 0.95rem; opacity: 0.8; }
    .profile-meta i { margin-right: 6px; }

    .info-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 24px; margin-bottom: 24px; }
    .info-card-header { font-size: 1.1rem; font-weight: 700; color: #1e293b; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; }
    
    .data-row { display: flex; margin-bottom: 16px; }
    .data-label { width: 150px; font-weight: 600; color: #64748b; font-size: 0.9rem; }
    .data-value { font-weight: 500; color: #0f172a; font-size: 0.95rem; }
    
    .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
    .status-active { background: #d1fae5; color: #059669; }
    .status-inactive { background: #fee2e2; color: #dc2626; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6 ? 'my-employees' : 'employees'}" />
    </jsp:include>

    <div class="main-content">
        <div style="margin-bottom: 20px;">
            <a href="javascript:history.back()" style="text-decoration: none; color: #64748b; font-weight: 600;">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>

        <div class="profile-hero">
            <div class="profile-avatar">${employee.fullName.substring(0,1)}</div>
            <div class="profile-info">
                <h2>${employee.fullName}</h2>
                <div class="profile-meta">
                    <span><i class="fas fa-id-badge"></i> EMP-${employee.userId}</span>
                    <span><i class="fas fa-envelope"></i> ${employee.email}</span>
                    <span>
                        <span class="status-badge ${employee.status == 1 ? 'status-active' : 'status-inactive'}">
                            ${employee.status == 1 ? 'Đang làm việc' : 'Đã nghỉ'}
                        </span>
                    </span>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <div class="info-card">
                    <div class="info-card-header">
                        <i class="fas fa-briefcase text-primary"></i> Thông tin công tác
                    </div>
                    <div class="data-row">
                        <div class="data-label">Phòng ban:</div>
                        <div class="data-value">${empDept != null ? empDept.departmentName : 'Chưa phân bổ'}</div>
                    </div>
                    <div class="data-row">
                        <div class="data-label">Chức vụ:</div>
                        <div class="data-value">${empPos != null ? empPos.positionName : 'Chưa phân bổ'}</div>
                    </div>
                    <div class="data-row">
                        <div class="data-label">Vai trò HT:</div>
                        <div class="data-value">
                            <c:choose>
                                <c:when test="${employee.roleId == 1}">Quản trị viên (Admin)</c:when>
                                <c:when test="${employee.roleId == 2}">HR Manager</c:when>
                                <c:when test="${employee.roleId == 3}">Quản đốc</c:when>
                                <c:when test="${employee.roleId == 4}">Giám đốc</c:when>
                                <c:when test="${employee.roleId == 5}">HR Staff</c:when>
                                <c:when test="${employee.roleId == 6}">Trưởng phòng</c:when>
                                <c:otherwise>Nhân viên</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="data-row">
                        <div class="data-label">Ngày vào làm:</div>
                        <div class="data-value"><fmt:formatDate value="${employee.createdAt}" pattern="dd/MM/yyyy"/></div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="info-card">
                    <div class="info-card-header">
                        <i class="fas fa-address-book text-success"></i> Liên hệ
                    </div>
                    <div class="data-row">
                        <div class="data-label">Điện thoại:</div>
                        <div class="data-value">${not empty employee.phone ? employee.phone : 'Chưa cập nhật'}</div>
                    </div>
                    <div class="data-row">
                        <div class="data-label">Email:</div>
                        <div class="data-value">${employee.email}</div>
                    </div>
                    <div class="data-row">
                        <div class="data-label">Username:</div>
                        <div class="data-value">${employee.username}</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-2">
            <div class="col-12">
                <div class="info-card" style="background: #f8fafc; border-style: dashed;">
                    <div class="info-card-header" style="color: #64748b; border-bottom: none;">
                        <i class="fas fa-clock"></i> Nghiệp vụ Nhân sự (Dự kiến Iteration 2)
                    </div>
                    <div style="display: flex; gap: 16px;">
                        <button class="btn btn-outline-secondary" disabled><i class="fas fa-file-signature"></i> Xem Hợp đồng</button>
                        <button class="btn btn-outline-secondary" disabled><i class="fas fa-money-bill-wave"></i> Bảng Lương</button>
                        <button class="btn btn-outline-secondary" disabled><i class="fas fa-calendar-check"></i> Lịch sử Nghỉ phép</button>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../footer.jsp" />

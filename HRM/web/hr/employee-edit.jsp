<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chỉnh sửa Hồ sơ Nhân sự" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f1f5f9; font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 24px 32px; width: calc(100% - 260px); }

    /* Breadcrumb & Header */
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .breadcrumb-title { font-size: 1.25rem; font-weight: 700; color: #0f172a; margin: 0; }
    .breadcrumb-title span { color: #64748b; font-weight: 500; font-size: 1rem; }
    .btn-back { display: inline-flex; align-items: center; gap: 8px; color: #64748b; text-decoration: none; font-weight: 600; font-size: 0.9rem; transition: color 0.2s; }
    .btn-back:hover { color: #0f172a; }

    /* Content Card */
    .content-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 32px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); max-width: 900px; margin: 0 auto; }
    .section-title { font-size: 1.1rem; font-weight: 700; color: #0f172a; margin: 0 0 24px; display: flex; align-items: center; gap: 10px; padding-bottom: 12px; border-bottom: 1px solid #e2e8f0; }
    .section-title i { color: #2563eb; }
    
    /* Form Grid */
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 32px; }
    .form-group { display: flex; flex-direction: column; gap: 8px; }
    .form-group.full-width { grid-column: span 2; }
    .form-label { font-size: 0.9rem; font-weight: 600; color: #334155; }
    .form-label span.required { color: #ef4444; margin-left: 4px; }
    
    .form-control { background: #fff; border: 1px solid #cbd5e1; padding: 12px 16px; border-radius: 8px; font-size: 0.95rem; color: #0f172a; transition: all 0.2s; width: 100%; box-sizing: border-box; }
    .form-control:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
    .form-control:disabled { background: #f8fafc; color: #94a3b8; cursor: not-allowed; }
    
    .form-select { appearance: none; background: #fff url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e") no-repeat right 12px center/12px 12px; }
    
    /* Form Actions */
    .form-actions { display: flex; justify-content: flex-end; gap: 16px; border-top: 1px solid #e2e8f0; padding-top: 24px; }
    .btn { padding: 10px 24px; border-radius: 8px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.2s; border: none; text-decoration: none; display: inline-block; }
    .btn-cancel { background: #f1f5f9; color: #475569; }
    .btn-cancel:hover { background: #e2e8f0; color: #0f172a; }
    .btn-save { background: #2563eb; color: #fff; }
    .btn-save:hover { background: #1d4ed8; }

</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="employees" />
    </jsp:include>

    <div class="main-content">
        <!-- Header -->
        <div class="page-header">
            <div>
                <a href="${pageContext.request.contextPath}/hr/employee-detail?userId=${employee.userId}" class="btn-back" style="margin-bottom: 12px;">
                    <i class="fas fa-arrow-left"></i> Quay lại hồ sơ
                </a>
                <h1 class="breadcrumb-title">Chỉnh sửa Hồ sơ Nhân sự <span>/ ${employee.fullName}</span></h1>
            </div>
        </div>

        <div class="content-card">
            <form action="${pageContext.request.contextPath}/hr/employee-edit" method="POST">
                <input type="hidden" name="userId" value="${employee.userId}" />
                
                <h3 class="section-title"><i class="fas fa-user"></i> Thông tin cơ bản</h3>
                <div class="form-grid">
                    <div class="form-group full-width">
                        <label class="form-label">Họ và tên <span class="required">*</span></label>
                        <input type="text" class="form-control" name="fullName" value="${employee.fullName}" required />
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Tài khoản (Username)</label>
                        <input type="text" class="form-control" value="${employee.username}" disabled title="Không thể đổi Username" />
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Mã nhân viên</label>
                        <input type="text" class="form-control" value="EMP-${employee.userId}" disabled />
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Email <span class="required">*</span></label>
                        <input type="email" class="form-control" name="email" value="${employee.email}" required />
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Số điện thoại</label>
                        <input type="text" class="form-control" name="phone" value="${employee.phone}" />
                    </div>
                </div>

                <h3 class="section-title" style="margin-top: 40px;"><i class="fas fa-briefcase"></i> Vị trí &amp; Tổ chức</h3>
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Phòng ban (Department)</label>
                        <select name="departmentId" class="form-control form-select">
                            <option value="">-- Chọn phòng ban --</option>
                            <c:forEach var="d" items="${deptList}">
                                <option value="${d.departmentId}" ${employee.departmentId == d.departmentId ? 'selected' : ''}>${d.departmentName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Chức vụ (Position)</label>
                        <select name="positionId" class="form-control form-select">
                            <option value="">-- Chọn chức vụ --</option>
                            <c:forEach var="p" items="${posList}">
                                <option value="${p.positionId}" ${employee.positionId == p.positionId ? 'selected' : ''}>${p.positionName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Phân quyền (Role) <span class="required">*</span></label>
                        <select name="roleId" class="form-control form-select" required>
                            <c:forEach var="r" items="${roleList}">
                                <option value="${r.roleId}" ${employee.roleId == r.roleId ? 'selected' : ''}>${r.roleName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Trạng thái làm việc</label>
                        <select name="status" class="form-control form-select">
                            <option value="1" ${employee.status == 1 ? 'selected' : ''}>Đang làm việc</option>
                            <option value="0" ${employee.status == 0 ? 'selected' : ''}>Đã nghỉ việc / Khóa</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/hr/employee-detail?userId=${employee.userId}" class="btn btn-cancel">Hủy bỏ</a>
                    <button type="submit" class="btn btn-save"><i class="fas fa-save me-1"></i> Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

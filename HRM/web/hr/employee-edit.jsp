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

    /* Alert */
    .alert-success { background: #dcfce7; border: 1px solid #a7f3d0; color: #065f46; padding: 14px 20px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; font-weight: 500; }
    .alert-error { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; padding: 14px 20px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; font-weight: 500; }

    /* Content Card */
    .content-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 32px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); max-width: 960px; margin: 0 auto; }
    .section-title { font-size: 1.05rem; font-weight: 700; color: #0f172a; margin: 0 0 20px; display: flex; align-items: center; gap: 10px; padding-bottom: 12px; border-bottom: 1px solid #e2e8f0; }
    .section-title i { color: #2563eb; }
    .section-gap { margin-top: 36px; }
    
    /* Form Grid */
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 8px; }
    .form-group { display: flex; flex-direction: column; gap: 8px; }
    .form-group.full-width { grid-column: span 2; }
    .form-label { font-size: 0.88rem; font-weight: 600; color: #334155; }
    .form-label span.required { color: #ef4444; margin-left: 4px; }
    
    .form-control { background: #fff; border: 1px solid #cbd5e1; padding: 11px 16px; border-radius: 8px; font-size: 0.93rem; color: #0f172a; transition: all 0.2s; width: 100%; box-sizing: border-box; }
    .form-control:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
    .form-control:disabled { background: #f8fafc; color: #94a3b8; cursor: not-allowed; }
    
    .form-select { appearance: none; background: #fff url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e") no-repeat right 12px center/12px 12px; }
    
    /* Form Actions */
    .form-actions { display: flex; justify-content: flex-end; gap: 16px; border-top: 1px solid #e2e8f0; padding-top: 24px; margin-top: 24px; }
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

        <!-- Alert messages -->
        <c:if test="${param.msg == 'update_success'}">
            <div class="alert-success"><i class="fas fa-check-circle"></i> Cập nhật thông tin nhân viên thành công!</div>
        </c:if>
        <c:if test="${param.error == 'save_failed'}">
            <div class="alert-error"><i class="fas fa-exclamation-circle"></i> Lưu thất bại. Vui lòng thử lại.</div>
        </c:if>

        <div class="content-card">
            <form action="${pageContext.request.contextPath}/hr/employee-edit" method="POST">
                <input type="hidden" name="userId" value="${employee.userId}" />
                
                <!-- PHẦN 1: THÔNG TIN CƠ BẢN -->
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

                    <div class="form-group">
                        <label class="form-label">CMND/CCCD</label>
                        <input type="text" class="form-control" name="idCard" value="${empProfile != null ? empProfile.idCard : ''}" placeholder="Số CMND hoặc CCCD" />
                    </div>

                    <div class="form-group">
                        <label class="form-label">Giới tính</label>
                        <select name="gender" class="form-control form-select">
                            <option value="">-- Chọn --</option>
                            <option value="1" ${empProfile != null && empProfile.gender == 1 ? 'selected' : ''}>Nam</option>
                            <option value="0" ${empProfile != null && empProfile.gender == 0 ? 'selected' : ''}>Nữ</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Ngày sinh</label>
                        <input type="date" class="form-control" name="dob"
                               value="${empProfile != null && empProfile.dob != null ? empProfile.dob : ''}" />
                    </div>

                    <div class="form-group">
                        <label class="form-label">Ngày vào làm</label>
                        <input type="date" class="form-control" name="hireDate"
                               value="${empProfile != null && empProfile.hireDate != null ? empProfile.hireDate : ''}" />
                    </div>

                    <div class="form-group full-width">
                        <label class="form-label">Địa chỉ</label>
                        <input type="text" class="form-control" name="address" value="${empProfile != null ? empProfile.address : ''}" placeholder="Địa chỉ hiện tại" />
                    </div>
                </div>

                <!-- PHẦN 2: VỊ TRÍ & TỔ CHỨC -->
                <h3 class="section-title section-gap"><i class="fas fa-briefcase"></i> Vị trí &amp; Tổ chức</h3>
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

                <!-- PHẦN 3: HỢP ĐỒNG & LƯƠNG -->
                <h3 class="section-title section-gap"><i class="fas fa-file-contract" style="color:#d97706;"></i> Hợp đồng &amp; Lương</h3>
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Loại hợp đồng</label>
                        <select name="contractTypeId" class="form-control form-select">
                            <option value="">-- Chọn loại hợp đồng --</option>
                            <c:forEach var="ct" items="${contractTypeList}">
                                <option value="${ct.contractTypeId}"
                                    ${empProfile != null && empProfile.contractTypeId == ct.contractTypeId ? 'selected' : ''}>
                                    ${ct.typeName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Ngạch lương (Salary Grade)</label>
                        <select name="salaryGradeId" class="form-control form-select">
                            <option value="">-- Chọn ngạch lương --</option>
                            <c:forEach var="sg" items="${salaryGradeList}">
                                <option value="${sg.salaryGradeId}"
                                    ${empProfile != null && empProfile.salaryGradeId == sg.salaryGradeId ? 'selected' : ''}>
                                    ${sg.gradeName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mã số thuế</label>
                        <input type="text" class="form-control" name="taxCode" value="${empProfile != null ? empProfile.taxCode : ''}" placeholder="Mã số thuế cá nhân" />
                    </div>

                    <div class="form-group">
                        <label class="form-label">Số sổ BHXH</label>
                        <input type="text" class="form-control" name="socialInsuranceNo" value="${empProfile != null ? empProfile.socialInsuranceNo : ''}" placeholder="Số sổ bảo hiểm xã hội" />
                    </div>
                </div>

                <!-- PHẦN 4: NGÂN HÀNG -->
                <h3 class="section-title section-gap"><i class="fas fa-university" style="color:#3b82f6;"></i> Tài khoản Ngân hàng</h3>
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Tên Ngân hàng</label>
                        <input type="text" class="form-control" name="bankName" value="${empProfile != null ? empProfile.bankName : ''}" placeholder="Vd: Vietcombank, BIDV..." />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số tài khoản</label>
                        <input type="text" class="form-control" name="bankAccount" value="${empProfile != null ? empProfile.bankAccount : ''}" placeholder="Số tài khoản nhận lương" />
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

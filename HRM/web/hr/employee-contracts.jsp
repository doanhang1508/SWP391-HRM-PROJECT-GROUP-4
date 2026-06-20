<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Hợp đồng & Lương - Hồ sơ Nhân sự" scope="request" />
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

    /* Profile Card */
    .profile-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 24px; display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
    .profile-left { display: flex; align-items: center; gap: 20px; }
    .avatar-lg { width: 80px; height: 80px; border-radius: 50%; background: #e0e7ff; color: #3730a3; display: flex; align-items: center; justify-content: center; font-size: 2rem; font-weight: 700; }
    .profile-name { font-size: 1.4rem; font-weight: 800; color: #0f172a; margin: 0 0 4px; }
    .profile-role { color: #64748b; font-size: 0.95rem; margin: 0 0 8px; }
    .status-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
    .status-active { background: #dcfce7; color: #166534; }
    .status-inactive { background: #fee2e2; color: #991b1b; }

    .btn-edit { background: #fff; border: 1px solid #cbd5e1; color: #334155; padding: 8px 16px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 8px; text-decoration: none; }
    .btn-edit:hover { background: #f8fafc; border-color: #94a3b8; color: #0f172a; }

    /* Tabs */
    .nav-tabs-custom { display: flex; border-bottom: 2px solid #e2e8f0; margin-bottom: 24px; gap: 32px; }
    .nav-tab { padding: 12px 0; font-size: 0.95rem; font-weight: 600; color: #64748b; cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -2px; transition: all 0.2s; text-decoration: none; display: inline-block; }
    .nav-tab:hover { color: #0f172a; }
    .nav-tab.active { color: #2563eb; border-bottom-color: #2563eb; }

    /* Content Card */
    .content-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 24px; }
    .section-title { font-size: 1.1rem; font-weight: 700; color: #0f172a; margin: 0 0 20px; display: flex; align-items: center; gap: 10px; }
    .section-title i { color: #f59e0b; }
    
    /* Form Grid */
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px; }
    .form-group { display: flex; flex-direction: column; gap: 8px; }
    .form-group.full-width { grid-column: span 2; }
    .form-label { font-size: 0.85rem; font-weight: 700; color: #475569; }
    .form-control-view { background: #f8fafc; border: 1px solid #e2e8f0; padding: 10px 16px; border-radius: 8px; font-size: 0.95rem; color: #0f172a; font-weight: 500; width: 100%; min-height: 42px; display: flex; align-items: center; }
    .text-muted-italic { color: #94a3b8; font-style: italic; }

    /* Salary highlight */
    .salary-value { font-size: 1.1rem; font-weight: 800; color: #16a34a; }
    .contract-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 700; background: #dbeafe; color: #1e40af; }
    .no-profile-alert { background: #fef9c3; border: 1px solid #fde68a; border-radius: 12px; padding: 20px 24px; display: flex; align-items: center; gap: 14px; color: #92400e; font-size: 0.9rem; margin-bottom: 24px; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6 ? 'my-employees' : 'employees'}" />
    </jsp:include>

    <div class="main-content">
        <!-- Header -->
        <div class="page-header">
            <div>
                <a href="javascript:history.back()" class="btn-back" style="margin-bottom: 12px;">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
                <h1 class="breadcrumb-title">Quản lý Hồ sơ Nhân sự <span>/ Hợp đồng &amp; Lương</span></h1>
            </div>
        </div>

        <!-- Profile Hero Card -->
        <div class="profile-card">
            <div class="profile-left">
                <div class="avatar-lg">${employee.fullName.substring(0,1)}</div>
                <div>
                    <h2 class="profile-name">${employee.fullName}</h2>
                    <p class="profile-role">
                        ${empPos != null ? empPos.positionName : 'Chưa cập nhật'} | 
                        ${empDept != null ? empDept.departmentName : 'Chưa phân bổ'}
                    </p>
                    <span class="status-badge ${employee.status == 1 ? 'status-active' : 'status-inactive'}">
                        <i class="fas ${employee.status == 1 ? 'fa-check-circle' : 'fa-lock'} me-1"></i>
                        ${employee.status == 1 ? 'Đang làm việc' : 'Đã nghỉ/Khóa'}
                    </span>
                </div>
            </div>
            <c:if test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 2 || sessionScope.currentUser.roleId == 5}">
                <div>
                    <a href="${pageContext.request.contextPath}/hr/employee-edit?userId=${employee.userId}" class="btn-edit">
                        <i class="fas fa-pencil-alt"></i> Chỉnh sửa
                    </a>
                </div>
            </c:if>
        </div>

        <!-- Tabs -->
        <c:choose>
            <c:when test="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6}">
                <c:set var="profilePrefix" value="/manager" />
            </c:when>
            <c:otherwise>
                <c:set var="profilePrefix" value="/hr" />
            </c:otherwise>
        </c:choose>
        <div class="nav-tabs-custom">
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-detail?userId=${employee.userId}" class="nav-tab">Thông tin cá nhân</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-job-info?userId=${employee.userId}" class="nav-tab">Thông tin công việc</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-work-history?userId=${employee.userId}" class="nav-tab">Lịch sử công tác</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-contracts?userId=${employee.userId}" class="nav-tab active">Hợp đồng &amp; Lương</a>
        </div>

        <!-- Alert nếu chưa có hồ sơ -->
        <c:if test="${empProfile == null}">
            <div class="no-profile-alert">
                <i class="fas fa-exclamation-triangle" style="font-size: 1.4rem; color: #d97706;"></i>
                <span>Nhân viên này chưa có hồ sơ chi tiết trong hệ thống. Vui lòng cập nhật thông tin qua chức năng <strong>Chỉnh sửa</strong>.</span>
            </div>
        </c:if>

        <!-- Tab Content: Hợp đồng -->
        <div class="content-card">
            <h3 class="section-title"><i class="fas fa-file-contract" style="color:#d97706;"></i> Thông tin Hợp đồng</h3>
            
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Loại hợp đồng</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && not empty empProfile.contractTypeName}">
                                <span class="contract-badge"><i class="fas fa-file-signature me-1"></i>${empProfile.contractTypeName}</span>
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tình trạng hợp đồng</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && not empty empProfile.employmentStatusName}">
                                ${empProfile.employmentStatusName}
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Ngày vào làm (Hire Date)</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && empProfile.hireDate != null}">
                                <fmt:formatDate value="${empProfile.hireDate}" pattern="dd/MM/yyyy"/>
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Trạng thái làm việc</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${employee.status == 1}">
                                <span style="color:#16a34a; font-weight:700;"><i class="fas fa-circle me-1" style="font-size:8px;vertical-align:middle;"></i> Đang làm việc</span>
                            </c:when>
                            <c:otherwise>
                                <span style="color:#dc2626; font-weight:700;"><i class="fas fa-circle me-1" style="font-size:8px;vertical-align:middle;"></i> Đã nghỉ / Khóa</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab Content: Lương & Thuế -->
        <div class="content-card">
            <h3 class="section-title"><i class="fas fa-money-bill-wave" style="color:#10b981;"></i> Thông tin Lương &amp; Thuế</h3>
            
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Ngạch lương (Salary Grade)</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && not empty empProfile.salaryGradeName}">
                                ${empProfile.salaryGradeName}
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Mức lương cơ bản</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && empProfile.baseSalary != null}">
                                <span class="salary-value">
                                    <fmt:formatNumber value="${empProfile.baseSalary}" type="number" groupingUsed="true"/> VNĐ
                                </span>
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Mã số thuế (Tax Code)</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && not empty empProfile.taxCode}">
                                ${empProfile.taxCode}
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Số sổ BHXH (Insurance No)</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && not empty empProfile.socialInsuranceNo}">
                                ${empProfile.socialInsuranceNo}
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab Content: Ngân hàng -->
        <div class="content-card">
            <h3 class="section-title"><i class="fas fa-university" style="color:#3b82f6;"></i> Tài khoản Ngân hàng</h3>
            
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Tên Ngân hàng</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && not empty empProfile.bankName}">
                                <i class="fas fa-building-columns me-2" style="color:#64748b;"></i>${empProfile.bankName}
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Số tài khoản</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${empProfile != null && not empty empProfile.bankAccount}">
                                <i class="fas fa-credit-card me-2" style="color:#64748b;"></i>${empProfile.bankAccount}
                            </c:when>
                            <c:otherwise><span class="text-muted-italic">Chưa cập nhật</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../footer.jsp" />

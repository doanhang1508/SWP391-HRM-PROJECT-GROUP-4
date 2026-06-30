<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="pageTitle" value="Hop dong nhan vien" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f0f4f8; font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 28px 36px; width: calc(100% - 260px); }

    /* ── Back & header ── */
    .btn-back {
        display: inline-flex; align-items: center; gap: 6px;
        color: #64748b; text-decoration: none; font-weight: 600; font-size: 0.85rem;
        margin-bottom: 14px; transition: color .2s;
    }
    .btn-back:hover { color: #1e293b; }
    .page-header {
        display: flex; justify-content: space-between; align-items: flex-start;
        margin-bottom: 24px;
    }
    .page-title { font-size: 1.3rem; font-weight: 800; color: #0f172a; margin: 0; }
    .page-title span { color: #94a3b8; font-weight: 500; font-size: 1rem; }

    /* ── Hero card ── */
    .hero-card {
        background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%);
        border-radius: 20px; padding: 28px 32px;
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 24px; box-shadow: 0 8px 32px rgba(59,130,246,.25);
        position: relative; overflow: hidden;
    }
    .hero-card::before {
        content: ''; position: absolute; top: -40px; right: -40px;
        width: 200px; height: 200px; border-radius: 50%;
        background: rgba(255,255,255,.07);
    }
    .hero-card::after {
        content: ''; position: absolute; bottom: -60px; right: 120px;
        width: 150px; height: 150px; border-radius: 50%;
        background: rgba(255,255,255,.05);
    }
    .hero-left { display: flex; align-items: center; gap: 20px; }
    .avatar-hero {
        width: 88px; height: 88px; border-radius: 50%;
        background: rgba(255,255,255,.2); border: 3px solid rgba(255,255,255,.4);
        color: #fff; display: flex; align-items: center; justify-content: center;
        font-size: 2.2rem; font-weight: 800; flex-shrink: 0;
    }
    .hero-name { font-size: 1.5rem; font-weight: 800; color: #fff; margin: 0 0 4px; }
    .hero-sub  { color: rgba(255,255,255,.75); font-size: 0.9rem; margin: 0 0 10px; }
    .hero-badges { display: flex; gap: 8px; flex-wrap: wrap; }
    .badge-white {
        background: rgba(255,255,255,.18); color: #fff;
        padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700;
        border: 1px solid rgba(255,255,255,.3);
    }
    .badge-green { background: #dcfce7; color: #166534; }
    .badge-red   { background: #fee2e2; color: #991b1b; }
    .badge-pill  { padding: 4px 14px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }

    /* ── Tabs ── */
    .nav-tabs-custom {
        display: flex; gap: 4px; margin-bottom: 24px;
        background: #fff; border-radius: 12px; padding: 6px;
        box-shadow: 0 1px 4px rgba(0,0,0,.06); width: fit-content;
    }
    .nav-tab {
        padding: 9px 20px; font-size: 0.875rem; font-weight: 600;
        color: #64748b; cursor: pointer; border-radius: 8px;
        transition: all .2s; text-decoration: none; display: inline-flex; align-items: center; gap: 7px;
    }
    .nav-tab:hover { color: #1e293b; background: #f1f5f9; }
    .nav-tab.active { color: #fff; background: #2563eb; box-shadow: 0 2px 8px rgba(37,99,235,.35); }

    /* --- OLD STYLES FOR THE REST OF THE PAGE --- */
    .card-panel { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; margin-bottom: 20px; }
    .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; padding-bottom: 16px; border-bottom: 1px solid #f3f4f6; }
    .panel-title { font-size: 1rem; font-weight: 600; color: #1a1a1a; display: flex; align-items: center; gap: 8px; }
    .panel-title i { color: #3b82f6; }
    .contract-detail-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
    .detail-item { padding: 12px 16px; background: #f8fafc; border-radius: 8px; border: 1px solid #e5e7eb; }
    .detail-label { font-size: 0.72rem; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; font-weight: 600; }
    .detail-value { font-size: 0.95rem; font-weight: 700; color: #1a1a1a; }
    .detail-value.salary { color: #059669; }
    .saas-table { width: 100%; border-collapse: collapse; }
    .saas-table th { padding: 12px 16px; text-align: left; font-size: 0.82rem; font-weight: 600; color: #6b7280; border-bottom: 2px solid #f3f4f6; white-space: nowrap; }
    .saas-table td { padding: 13px 16px; font-size: 0.875rem; color: #1a1a1a; border-bottom: 1px solid #f3f4f6; vertical-align: middle; }
    .saas-table tr:hover td { background: #f9fafb; }
    .table-wrapper { overflow-x: auto; }
    .btn-primary { background: #0d9488; color: #fff; border: none; padding: 9px 18px; border-radius: 7px; font-size: 0.875rem; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 7px; text-decoration: none; }
    .btn-primary:hover { background: #0f766e; color: #fff; }
    .btn-outline { background: #fff; border: 1px solid #e5e7eb; color: #374151; padding: 9px 18px; border-radius: 7px; font-size: 0.875rem; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 7px; text-decoration: none; }
    .btn-outline:hover { background: #f9fafb; border-color: #9ca3af; color: #374151; }
    .btn-sm { padding: 6px 12px; font-size: 0.8rem; border-radius: 6px; }
    .allowance-row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #f3f4f6; }
    .allowance-row:last-child { border-bottom: none; }
    .allowance-name { font-size: 0.875rem; color: #374151; display: flex; align-items: center; gap: 8px; }
    .allowance-amount { font-size: 0.9rem; font-weight: 700; color: #059669; }
    .alert-success { background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; border-radius: 8px; padding: 12px 18px; margin-bottom: 16px; font-size: 0.875rem; display: flex; align-items: center; gap: 10px; }
    .alert-danger { background: #fef2f2; border: 1px solid #fca5a5; color: #991b1b; border-radius: 8px; padding: 12px 18px; margin-bottom: 16px; font-size: 0.875rem; display: flex; align-items: center; gap: 10px; }
    .empty-state { text-align: center; padding: 40px 20px; color: #6b7280; }
    .empty-state i { font-size: 2.5rem; margin-bottom: 12px; color: #d1d5db; display: block; }
    .empty-state p { margin: 0; font-size: 0.9rem; }
    .role-notice { background: #fffbeb; border: 1px solid #fde68a; color: #92400e; border-radius: 8px; padding: 12px 16px; font-size: 0.82rem; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
    .salary-breakdown { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 16px; }
    .sb-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 0.875rem; }
    .sb-row:not(:last-child) { border-bottom: 1px dashed #d1fae5; }
    .sb-row .sb-label { color: #374151; }
    .sb-row .sb-value { font-weight: 600; color: #1a1a1a; }
    .sb-row.total .sb-label { color: #065f46; font-weight: 700; }
    .sb-row.total .sb-value { color: #059669; font-weight: 800; }
    .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.55); z-index: 9999; align-items: center; justify-content: center; }
    .modal-overlay.open { display: flex; }
    .modal-box { background: #fff; border-radius: 12px; padding: 28px 32px; width: 640px; max-width: 95vw; max-height: 90vh; overflow-y: auto; box-shadow: 0 25px 60px rgba(0,0,0,0.2); }
    .modal-title { font-size: 1.05rem; font-weight: 700; color: #1a1a1a; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid #f3f4f6; padding-bottom: 16px; }
    .modal-title i { color: #0d9488; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-group.full { grid-column: 1 / -1; }
    .form-label { font-size: 0.82rem; font-weight: 600; color: #374151; }
    .form-label .required { color: #dc2626; margin-left: 2px; }
    .form-control { border: 1px solid #d1d5db; border-radius: 6px; padding: 9px 12px; font-size: 0.875rem; font-family: inherit; outline: none; }
    .form-control:focus { border-color: #0d9488; }
    .form-hint { font-size: 0.75rem; color: #9ca3af; }
    .modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; padding-top: 16px; border-top: 1px solid #f3f4f6; }
    .allowance-check-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; max-height: 180px; overflow-y: auto; border: 1px solid #e5e7eb; border-radius: 6px; padding: 10px; background: #f8fafc; }
    .allowance-check-item { display: flex; align-items: center; gap: 8px; padding: 6px 8px; border-radius: 6px; }
    .allowance-check-item label { font-size: 0.82rem; color: #374151; cursor: pointer; flex: 1; }
    .alw-amount { font-size: 0.75rem; color: #059669; font-weight: 600; }
    .badge-status { padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 600; white-space: nowrap; display: inline-flex; align-items: center; gap: 4px; }
    .b-active { background: #ecfdf5; color: #059669; }
    .b-pending { background: #eff6ff; color: #2563eb; }
    .b-expired { background: #fef2f2; color: #dc2626; }
    .b-terminated { background: #f3f4f6; color: #6b7280; }
    .contract-detail-box {
        background: #fff; border: 1px solid #e5e7eb; border-radius: 12px;
        padding: 32px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }
    .detail-grid {
        display: grid; grid-template-columns: 220px 1fr; row-gap: 16px; font-size: 0.95rem;
    }
    .dl-label { color: #6b7280; font-weight: 500; }
    .dl-value { color: #1a1a1a; font-weight: 600; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6 ? 'my-employees' : 'employees'}" />
    </jsp:include>

    <div class="main-content">
        <a href="${pageContext.request.contextPath}/hr/employees" class="btn-back">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
        <c:if test="${not empty sessionScope.successMsg}">
        <div class="alert-success"><i class="fas fa-check-circle"></i> <c:out value="${sessionScope.successMsg}"/></div>
        <% session.removeAttribute("successMsg"); %>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
        <div class="alert-danger"><i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.errorMsg}"/></div>
        <% session.removeAttribute("errorMsg"); %>
        </c:if>

        <div class="page-header" style="display:flex; justify-content:space-between; align-items:center;">
            <h1 class="page-title">Hồ sơ Nhân sự <span>/ Hợp đồng & Lương</span></h1>
            <c:if test="${sessionScope.currentUser.roleId == 5}">
                <button class="btn-primary" onclick="openModal('createContractModal')"><i class="fas fa-plus"></i> Tạo hợp đồng</button>
            </c:if>
        </div>

        <!-- Hero Card -->
        <div class="hero-card">
            <div class="hero-left">
                <div class="avatar-hero"><c:choose><c:when test="${not empty employee.fullName}">${fn:substring(employee.fullName, 0, 1)}</c:when><c:otherwise>?</c:otherwise></c:choose></div>
                <div>
                    <h2 class="hero-name">${employee.fullName}</h2>
                    <p class="hero-sub">
                        <i class="fas fa-briefcase me-1"></i>
                        ${empPos != null ? empPos.positionName : 'Chưa cập nhật'}
                        &nbsp;|&nbsp;
                        <i class="fas fa-building me-1"></i>
                        ${empDept != null ? empDept.departmentName : 'Chưa phân bổ'}
                    </p>
                    <div class="hero-badges">
                        <span class="badge-white"><i class="fas fa-id-badge me-1"></i>EMP-${employee.userId}</span>
                        <span class="badge-pill ${employee.status == 1 ? 'badge-green' : 'badge-red'}">
                            <i class="fas ${employee.status == 1 ? 'fa-check-circle' : 'fa-lock'} me-1"></i>
                            ${employee.status == 1 ? 'Đang làm việc' : 'Đã nghỉ / Khóa'}
                        </span>
                    </div>
                </div>
            </div>
            <div>
                <c:choose>
                    <c:when test="${not empty currentContract && currentContract.status == 'Active'}"><span class="badge-status b-active" style="background:#fff;">Hợp đồng hiệu lực</span></c:when>
                    <c:when test="${not empty currentContract && currentContract.status == 'Pending'}"><span class="badge-status b-pending" style="background:#fff;">Hợp đồng chờ duyệt</span></c:when>
                    <c:otherwise><span class="badge-status b-terminated" style="background:#fff;">Chưa có hợp đồng</span></c:otherwise>
                </c:choose>
            </div>
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
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-detail?userId=${employee.userId}"    class="nav-tab"><i class="fas fa-user"></i> Thông tin cá nhân</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-job-info?userId=${employee.userId}"  class="nav-tab"><i class="fas fa-briefcase"></i> Thông tin công việc</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-work-history?userId=${employee.userId}" class="nav-tab"><i class="fas fa-history"></i> Lịch sử công tác</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-contracts?userId=${employee.userId}" class="nav-tab active"><i class="fas fa-file-contract"></i> Hợp đồng & Lương</a>
        </div>

<c:if test="${sessionScope.currentUser.roleId == 2}">
<div class="role-notice"><i class="fas fa-info-circle"></i> HR Manager chi co quyen phe duyet. Viec tao moi do HR Staff thuc hien.</div>
</c:if>

<div style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom: 16px;">
    <h3 style="font-size: 1.1rem; font-weight: 700; color: #1a1a1a; margin: 0;"><i class="fas fa-file-contract" style="color: #6b7280; margin-right: 6px;"></i> Chi tiết Hợp đồng Hiện tại</h3>
    <c:if test="${not empty currentContract && sessionScope.currentUser.roleId == 5}">
      <button class="btn-outline btn-sm" onclick="openModal('addendumModal')"><i class="fas fa-plus"></i> Tạo phụ lục</button>
    </c:if>
</div>

<div class="contract-detail-box" style="margin: 0 0 32px 0; max-width: 100%;">
  <c:choose>
    <c:when test="${empty currentContract}">
      <div class="empty-state">
        <i class="fas fa-file-circle-question"></i>
        <p>Nhân viên này chưa có hợp đồng đang hiệu lực.</p>
        <c:if test="${sessionScope.currentUser.roleId == 5}">
          <button class="btn-primary" style="margin-top:12px;margin:12px auto 0;" onclick="openModal('createContractModal')"><i class="fas fa-plus"></i> Tạo hợp đồng ngay</button>
        </c:if>
      </div>
    </c:when>
    <c:otherwise>
        <div class="detail-grid">
            <!-- 1. Thông tin HĐ -->
            <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 10px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                1. Thông tin Hợp đồng
            </div>
            
            <div class="dl-label">Mã hợp đồng</div>
            <div class="dl-value">HĐ-${currentContract.startDate.year + 1900}-<fmt:formatNumber value="${currentContract.contractId}" pattern="0000"/></div>
            
            <div class="dl-label">Loại hợp đồng</div>
            <div class="dl-value"><c:forEach var="ct" items="${contractTypes}"><c:if test="${ct.contractTypeId == currentContract.contractTypeId}"><c:out value="${ct.typeName}"/></c:if></c:forEach></div>
            
            <div class="dl-label">Ngày bắt đầu</div>
            <div class="dl-value"><fmt:formatDate value="${currentContract.startDate}" pattern="dd/MM/yyyy"/></div>
            
            <div class="dl-label">Ngày kết thúc</div>
            <div class="dl-value">
                <c:choose>
                    <c:when test="${not empty currentContract.endDate}"><fmt:formatDate value="${currentContract.endDate}" pattern="dd/MM/yyyy"/></c:when>
                    <c:otherwise>Vô thời hạn</c:otherwise>
                </c:choose>
            </div>
            
            <div class="dl-label">Trạng thái HĐ</div>
            <div class="dl-value">
                <c:choose>
                    <c:when test="${currentContract.status == 'Active'}"><span style="color: #16a34a; font-weight: 600;">Đang hiệu lực</span></c:when>
                    <c:when test="${currentContract.status == 'Pending'}"><span style="color: #d97706; font-weight: 600;">Chờ duyệt</span></c:when>
                    <c:otherwise><span style="color: #64748b; font-weight: 600;">${currentContract.status}</span></c:otherwise>
                </c:choose>
            </div>

            <!-- 2. Thông tin công việc -->
            <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                2. Thông tin công việc
            </div>
            
            <div class="dl-label">Phòng ban</div>
            <div class="dl-value">${empDept != null ? empDept.departmentName : 'Chưa cập nhật'}</div>

            <div class="dl-label">Chức vụ</div>
            <div class="dl-value">${empPos != null ? empPos.positionName : 'Chưa cập nhật'}</div>

            <!-- 3. Lương -->
            <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                3. Lương &amp; Phụ cấp
            </div>
            
            <div class="dl-label">Lương cơ bản</div>
            <div class="dl-value" style="font-weight: 500;"><fmt:formatNumber value="${currentContract.baseSalary}" type="number" groupingUsed="true"/> VNĐ</div>
            
            <div class="dl-label">Các khoản phụ cấp</div>
            <div>
                <c:choose>
                    <c:when test="${empty allowanceList}">
                        <div class="dl-value" style="color: #64748b;">Không có phụ cấp</div>
                    </c:when>
                    <c:otherwise>
                        <div class="dl-value" style="font-weight: 500;">+ <fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/> VNĐ</div>
                        <div style="margin-top: 8px; background: #f8fafc; padding: 8px 12px; border-radius: 6px; border: 1px solid #e2e8f0; font-size: 0.85rem;">
                            <ul style="margin: 0; padding-left: 16px; color: #475569;">
                                <c:forEach var="alw" items="${allowanceList}">
                                    <li>${alw.name}: <fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/> đ</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <div class="dl-label" style="color: #2563eb; font-weight: 700;">Lương Gross (Dự kiến)</div>
            <div class="dl-value" style="color: #2563eb; font-size: 1.15rem; font-weight: 700;"><fmt:formatNumber value="${currentContract.baseSalary.doubleValue() + totalAllowance}" type="number" groupingUsed="true"/> VNĐ</div>
            
            <!-- 4. Trạng thái ký -->
            <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                4. Trạng thái ký kết
            </div>
            
            <div class="dl-label">Người đại diện (Cty)</div>
            <div class="dl-value">Giám đốc nhân sự</div>
            
            <div class="dl-label">Ngày ký</div>
            <div class="dl-value"><fmt:formatDate value="${currentContract.startDate}" pattern="dd/MM/yyyy"/></div>
        </div>
        <c:if test="${sessionScope.currentUser.roleId == 2 && currentContract.status == 'Pending'}">
            <div style="margin-top:24px;padding-top:20px;border-top:1px solid #e5e7eb;">
              <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST" style="display:inline;">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="contractId" value="${currentContract.contractId}">
                <input type="hidden" name="userId" value="${employee.userId}">
                <button type="submit" class="btn-primary" onclick="return confirm('Xác nhận phê duyệt hợp đồng này?')"><i class="fas fa-check-circle"></i> Phê duyệt hợp đồng</button>
              </form>
            </div>
        </c:if>
    </c:otherwise>
  </c:choose>
</div>

<div style="margin-bottom: 16px;">
    <h3 style="font-size: 1.1rem; font-weight: 700; color: #1a1a1a; margin: 0;"><i class="fas fa-history" style="color: #6b7280; margin-right: 6px;"></i> Lịch sử Hợp đồng & Lương</h3>
</div>

<div class="contract-detail-box" style="margin: 0; max-width: 100%; padding: 0; overflow: hidden;">
  <c:choose>
    <c:when test="${empty contracts}">
      <div class="empty-state" style="padding: 40px; text-align: center;"><i class="fas fa-folder-open" style="font-size: 2rem; color: #d1d5db; margin-bottom: 12px; display: block;"></i><p style="color: #6b7280; margin: 0;">Chưa có hợp đồng nào.</p></div>
    </c:when>
    <c:otherwise>
      <div class="table-wrapper">
        <table style="width: 100%; border-collapse: collapse; text-align: left;">
          <thead style="background: #f9fafb;">
            <tr>
              <th style="padding: 16px 20px; color: #4b5563; font-size: 0.85rem; font-weight: 600; border-bottom: 1px solid #e5e7eb;">Loại HĐ</th>
              <th style="padding: 16px 20px; color: #4b5563; font-size: 0.85rem; font-weight: 600; border-bottom: 1px solid #e5e7eb;">Từ ngày - Đến ngày</th>
              <th style="padding: 16px 20px; color: #4b5563; font-size: 0.85rem; font-weight: 600; border-bottom: 1px solid #e5e7eb;">Lương Gross</th>
              <th style="padding: 16px 20px; color: #4b5563; font-size: 0.85rem; font-weight: 600; border-bottom: 1px solid #e5e7eb;">Trạng thái</th>
              <th style="padding: 16px 20px; color: #4b5563; font-size: 0.85rem; font-weight: 600; border-bottom: 1px solid #e5e7eb;">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="c" items="${contracts}" varStatus="s">
            <tr style="border-bottom: 1px solid #f3f4f6;"
                data-cid="${c.contractId}" 
                data-type="<c:forEach var='ct' items='${contractTypes}'><c:if test='${ct.contractTypeId == c.contractTypeId}'>${ct.typeName}</c:if></c:forEach>"
                data-dept="${c.departmentName}"
                data-pos="${c.positionName}"
                data-start="<fmt:formatDate value='${c.startDate}' pattern='dd/MM/yyyy'/>"
                data-end="<c:choose><c:when test='${empty c.endDate}'>Không giới hạn</c:when><c:otherwise><fmt:formatDate value='${c.endDate}' pattern='dd/MM/yyyy'/></c:otherwise></c:choose>"
                data-base="${c.baseSalary}"
                data-gross="${c.grossSalary}"
                data-alw-html="${fn:escapeXml(c.allowanceHtml)}"
                data-tax="<c:choose><c:when test='${c.taxCalcType == 1}'>Biểu thuế lũy tiến</c:when><c:when test='${c.taxCalcType == 2}'>Khấu trừ 10%</c:when><c:otherwise>Miễn thuế</c:otherwise></c:choose>">
              <td style="padding: 16px 20px; font-weight: 600; color: #1a1a1a; font-size: 0.9rem;">
                <c:choose>
                    <c:when test="${c.docType == 'ADDENDUM'}">
                        <span style="color: #d97706; font-weight: 700;"><i class="fas fa-file-signature me-1"></i> Phụ lục Hợp đồng</span>
                        <div style="font-size: 0.8rem; font-weight: 500; color: #64748b; margin-top: 4px;">Lý do: ${not empty c.addendumReason ? fn:substring(c.addendumReason,0,30) : 'Không có'}</div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="ct" items="${contractTypes}"><c:if test="${ct.contractTypeId == c.contractTypeId}"><c:out value="${ct.typeName}"/></c:if></c:forEach>
                    </c:otherwise>
                </c:choose>
              </td>
              <td style="padding: 16px 20px; color: #4b5563; font-size: 0.9rem;">
                <fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/> &ndash; 
                <c:choose><c:when test="${empty c.endDate}">Vô thời hạn</c:when><c:otherwise><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></c:otherwise></c:choose>
              </td>
              <td style="padding: 16px 20px; font-weight: 700; color: #1a1a1a; font-size: 0.9rem;">
                <fmt:formatNumber value="${c.grossSalary}" type="number" groupingUsed="true"/> đ
              </td>
              <td style="padding: 16px 20px; font-size: 0.9rem;">
                <c:choose><c:when test="${c.status == 'Active'}"><span style="background: #ecfdf5; color: #059669; padding: 2px 8px; border-radius: 10px; font-size: 0.75rem; font-weight: 600;">Đang hiệu lực</span></c:when><c:when test="${c.status == 'Pending'}"><span style="background: #fffbeb; color: #d97706; padding: 2px 8px; border-radius: 10px; font-size: 0.75rem; font-weight: 600;">Chờ duyệt</span></c:when><c:when test="${c.status == 'Expired'}"><span style="background: #fef2f2; color: #dc2626; padding: 2px 8px; border-radius: 10px; font-size: 0.75rem; font-weight: 600;">Hết hạn</span></c:when><c:otherwise><span style="color: #6b7280; font-weight: 600;">&bull; <c:out value="${c.status}"/></span></c:otherwise></c:choose>
              </td>
              <td style="padding: 16px 20px;">
                <button type="button"
                    onclick="viewHistoryModal(this.closest('tr'))"
                    style="padding: 4px 10px; background: #eff6ff; color: #2563eb; border: 1px solid #bfdbfe; border-radius: 6px; font-size: 0.75rem; font-weight: 600; cursor: pointer; white-space: nowrap;">
                    <i class="fas fa-eye me-1"></i> Xem chi tiết
                </button>
              </td>
            </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</div>

</div></div>

<div class="modal-overlay" id="createContractModal">
  <div class="modal-box">
    <div class="modal-title"><i class="fas fa-file-signature"></i> Tạo hợp đồng mới</div>
    <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST">
      <input type="hidden" name="action" value="create">
      <input type="hidden" name="userId" value="${employee.userId}">
      <div class="form-grid">
        <div class="form-group"><label class="form-label">Loại hợp đồng <span class="required">*</span></label><select name="contractTypeId" class="form-control" required onchange="updateSalaryHint(this)"><option value="">-- Chọn --</option><c:forEach var="ct" items="${contractTypes}"><option value="${ct.contractTypeId}"><c:out value="${ct.typeName}"/></option></c:forEach></select></div>
        <div class="form-group"><label class="form-label">Bậc lương <span class="required">*</span></label><select name="salaryGradeId" class="form-control" required onchange="prefillSalary(this)"><option value="">-- Chọn --</option><c:forEach var="sg" items="${salaryGrades}"><option value="${sg.salaryGradeId}" data-base="${sg.minSalary}"><c:out value="${sg.gradeName}"/> (<fmt:formatNumber value="${sg.minSalary}" type="number" groupingUsed="true"/>đ - <fmt:formatNumber value="${sg.maxSalary}" type="number" groupingUsed="true"/>đ)</option></c:forEach></select></div>
        <div class="form-group"><label class="form-label">Phòng ban <span class="required">*</span></label><select name="departmentId" class="form-control" required><c:forEach var="d" items="${departments}"><option value="${d.departmentId}" ${d.departmentId==employee.departmentId?'selected':''}><c:out value="${d.departmentName}"/></option></c:forEach></select></div>
        <div class="form-group"><label class="form-label">Chức vụ <span class="required">*</span></label><select name="positionId" class="form-control" required><c:forEach var="p" items="${positions}"><option value="${p.positionId}" ${p.positionId==employee.positionId?'selected':''}><c:out value="${p.positionName}"/></option></c:forEach></select></div>
        <div class="form-group"><label class="form-label">Ngày bắt đầu <span class="required">*</span></label><input type="date" name="startDate" class="form-control" required></div>
        <div class="form-group"><label class="form-label">Ngày kết thúc</label><input type="date" name="endDate" class="form-control"><span class="form-hint">Để trống nếu không thời hạn</span></div>
        <div class="form-group"><label class="form-label">Lương cơ bản (đ) <span class="required">*</span></label><input type="text" name="baseSalary" id="baseSalaryInput" class="form-control" required placeholder="VD: 10000000"><span class="form-hint" id="salaryHint"></span></div>
        <div class="form-group"><label class="form-label">Tính thuế <span class="required">*</span></label><select name="taxCalcType" class="form-control" required><option value="1">Lũy tiến</option><option value="2">Khấu trừ 10%</option><option value="3">Miễn thuế</option></select></div>
        <c:if test="${not empty availableAllowances}">
          <div class="form-group full"><label class="form-label">Phụ cấp đi kèm</label><div class="allowance-check-grid"><c:forEach var="alw" items="${availableAllowances}"><div class="allowance-check-item"><input type="checkbox" name="allowanceIds" value="${alw.allowanceId}" id="alw_${alw.allowanceId}"><label for="alw_${alw.allowanceId}"><c:out value="${alw.allowanceName}"/></label><span class="alw-amount"><fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/>đ</span></div></c:forEach></div></div>
        </c:if>
      </div>
      <div class="modal-actions"><button type="button" class="btn-outline" onclick="closeModal('createContractModal')">Hủy</button><button type="submit" class="btn-primary"><i class="fas fa-save"></i> Tạo hợp đồng</button></div>
    </form>
  </div>
</div>

<c:if test="${not empty currentContract}">
<div class="modal-overlay" id="addendumModal">
  <div class="modal-box">
    <div class="modal-title"><i class="fas fa-file-alt"></i> Tạo phụ lục hợp đồng</div>
    <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST">
      <input type="hidden" name="action" value="createAddendum">
      <input type="hidden" name="userId" value="${employee.userId}">
      <input type="hidden" name="parentContractId" value="${currentContract.contractId}">
      <input type="hidden" name="contractTypeId" value="${currentContract.contractTypeId}">
      <input type="hidden" name="taxCalcType" value="${currentContract.taxCalcType}">
      <input type="hidden" name="positionId" value="${currentContract.positionId}">
      <input type="hidden" name="departmentId" value="${currentContract.departmentId}">
      <c:if test="${not empty currentContract.endDate}"><input type="hidden" name="endDate" value="${currentContract.endDate}"></c:if>
      <div class="form-grid">
        <div class="form-group"><label class="form-label">Ngày hiệu lực phụ lục <span class="required">*</span></label><input type="date" name="startDate" class="form-control" required></div>
        <div class="form-group"><label class="form-label">Lương cơ bản mới (đ) <span class="required">*</span></label><input type="text" name="baseSalary" class="form-control" required value="<fmt:formatNumber value='${currentContract.baseSalary}' type='number' groupingUsed='false'/>"></div>
        <div class="form-group full"><label class="form-label">Lý do / Nội dung phụ lục <span class="required">*</span></label><textarea name="addendumReason" class="form-control" required rows="3" placeholder="Mô tả lý do điều chỉnh..."></textarea></div>
        <c:if test="${not empty availableAllowances}">
          <div class="form-group full"><label class="form-label">Phụ cấp áp dụng theo phụ lục</label><div class="allowance-check-grid"><c:forEach var="alw" items="${availableAllowances}"><div class="allowance-check-item"><input type="checkbox" name="allowanceIds" value="${alw.allowanceId}" id="add_alw_${alw.allowanceId}"><label for="add_alw_${alw.allowanceId}"><c:out value="${alw.allowanceName}"/></label><span class="alw-amount"><fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/>đ</span></div></c:forEach></div></div>
        </c:if>
      </div>
      <div class="modal-actions"><button type="button" class="btn-outline" onclick="closeModal('addendumModal')">Hủy</button><button type="submit" class="btn-primary"><i class="fas fa-paper-plane"></i> Gửi phụ lục</button></div>
    </form>
  </div>
</div>
</c:if>

<div class="modal-overlay" id="historyModal">
  <div class="modal-box" style="max-width: 650px; padding: 0; overflow: hidden; background: #fff; border-radius: 12px; box-shadow: 0 20px 60px rgba(0,0,0,0.15);">
    <div style="padding: 20px 24px; border-bottom: 1px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; background: #f9fafb;">
      <h3 style="margin: 0; font-size: 1.1rem; font-weight: 700; color: #1a1a1a;">
        <i class="fas fa-file-contract" style="color: #6b7280; margin-right: 8px;"></i>
        Chi tiết Hợp đồng Lịch sử
      </h3>
      <button type="button" onclick="closeModal('historyModal')" style="background: transparent; border: none; font-size: 1.4rem; color: #9ca3af; cursor: pointer;">&times;</button>
    </div>
    <div style="padding: 24px; max-height: 70vh; overflow-y: auto;">
        <div class="detail-grid" style="grid-template-columns: 160px 1fr; row-gap: 12px;">
            <!-- 1. Thông tin HĐ -->
            <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 5px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                1. Thông tin Hợp đồng
            </div>
            
            <div class="dl-label">Mã hợp đồng</div><div class="dl-value" id="hmId"></div>
            <div class="dl-label">Loại hợp đồng</div><div class="dl-value" id="hmType"></div>
            <div class="dl-label">Ngày bắt đầu</div><div class="dl-value" id="hmStart"></div>
            <div class="dl-label">Ngày kết thúc</div><div class="dl-value" id="hmEnd"></div>
            
            <!-- 2. Thông tin công việc -->
            <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                2. Thông tin công việc
            </div>
            
            <div class="dl-label">Phòng ban</div><div class="dl-value" id="hmDept"></div>
            <div class="dl-label">Chức vụ</div><div class="dl-value" id="hmPos"></div>

            <!-- 3. Lương -->
            <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                3. Lương &amp; Phụ cấp
            </div>
            
            <div class="dl-label">Lương cơ bản</div><div class="dl-value" style="font-weight: 500;" id="hmBase"></div>
            <div class="dl-label">Chi tiết Phụ cấp</div>
            <div id="hmAlw" style="font-weight: 500; color: #4b5563; font-size: 0.9rem; white-space: pre-wrap;"></div>
            
            <div class="dl-label" style="font-weight: 700; color: #2563eb; margin-top: 4px;">Lương Gross</div>
            <div class="dl-value" style="font-weight: 800; font-size: 1.05rem; color: #2563eb; margin-top: 4px;" id="hmGross"></div>
            
            <!-- 4. Trạng thái ký kết -->
            <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                4. Trạng thái ký kết
            </div>
            
            <div class="dl-label">Người đại diện (Cty)</div><div class="dl-value">Giám đốc nhân sự</div>
            <div class="dl-label">Ngày ký</div><div class="dl-value" id="hmSigned"></div>
        </div>
    </div>
    <div style="padding: 16px 24px; border-top: 1px solid #e5e7eb; background: #f9fafb; text-align: right;">
        <button type="button" class="btn-outline" onclick="closeModal('historyModal')">Đóng</button>
    </div>
  </div>
</div>

<script>
function viewHistoryModal(row) {
    var d = row.dataset;
    var year = d.start ? d.start.split('/')[2] : new Date().getFullYear();
    document.getElementById('hmId').textContent = 'HĐ-' + year + '-' + String(d.cid).padStart(4, '0');
    document.getElementById('hmType').textContent = d.type || '';
    document.getElementById('hmStart').textContent = d.start || '';
    document.getElementById('hmEnd').textContent = d.end || '';
    document.getElementById('hmDept').textContent = d.dept || 'Chưa cập nhật';
    document.getElementById('hmPos').textContent = d.pos || 'Chưa cập nhật';
    document.getElementById('hmSigned').textContent = d.start || '';
    document.getElementById('hmBase').textContent = parseFloat(d.base).toLocaleString('vi-VN') + ' VNĐ';
    document.getElementById('hmGross').textContent = parseFloat(d.gross).toLocaleString('vi-VN') + ' VNĐ';
    
    // Convert unescaped text correctly, handling escaped newlines if any
    var alwHtml = d.alwHtml || 'Không có phụ cấp';
    alwHtml = alwHtml.replace(/&#013;/g, '\n').replace(/&#10;/g, '\n');
    document.getElementById('hmAlw').textContent = alwHtml;
    
    openModal('historyModal');
}

function openModal(id){var m=document.getElementById(id);if(m){m.classList.add('open');document.body.style.overflow='hidden';}}
function closeModal(id){var m=document.getElementById(id);if(m){m.classList.remove('open');document.body.style.overflow='';}}
document.querySelectorAll('.modal-overlay').forEach(function(m){m.addEventListener('click',function(e){if(e.target===m)closeModal(m.id);});});
document.addEventListener('keydown',function(e){if(e.key==='Escape')document.querySelectorAll('.modal-overlay.open').forEach(function(m){closeModal(m.id);});});
function prefillSalary(sel){var b=sel.options[sel.selectedIndex].getAttribute('data-base');if(b)document.getElementById('baseSalaryInput').value=b;}
function updateSalaryHint(sel){var h=document.getElementById('salaryHint');if(h){h.textContent=(sel.value=='1')?'Hop dong thu viec: luong thuc nhan = 85% luong nhap.':'';h.style.color='#d97706';}}

</script>

<jsp:include page="../footer.jsp" />

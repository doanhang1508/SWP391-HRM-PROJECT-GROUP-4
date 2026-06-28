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
            <div style="flex:1;">
                <a href="javascript:history.back()" class="btn-back" style="margin-bottom: 12px;">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
                <h1 class="breadcrumb-title">Quản lý Hồ sơ Nhân sự <span>/ Hợp đồng &amp; Lương</span></h1>
            </div>
            <c:if test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 2 || (sessionScope.currentUser.roleId == 5 && sessionScope.currentUser.userId != employee.userId)}">
                <button type="button" class="btn-primary" onclick="openAddContractModal()" style="padding: 10px 20px; background: #2563eb; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 8px; font-size: 0.95rem;">
                    <i class="fas fa-plus"></i> Gia hạn / Ký mới Hợp đồng
                </button>
            </c:if>
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

        <!-- Hiển thị chi tiết Hợp đồng hiện tại -->
        <c:set var="currentContract" value="${null}" />
        <c:forEach var="c" items="${contracts}">
            <c:if test="${c.status == 'Active' || c.status == 'Pending'}">
                <c:set var="currentContract" value="${c}" />
            </c:if>
        </c:forEach>

        <c:if test="${not empty currentContract}">
            <div class="content-card" style="margin-bottom: 24px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h3 class="section-title" style="margin: 0;"><i class="fas fa-file-signature" style="color:#2563eb;"></i> Chi tiết Hợp đồng Hiện tại</h3>
                    <c:if test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 2 || (sessionScope.currentUser.roleId == 5 && sessionScope.currentUser.userId != employee.userId)}">
                        <button type="button" onclick="openAddendumModal()" style="padding: 6px 12px; background: #d97706; color: white; border: none; border-radius: 6px; font-weight: 500; cursor: pointer; font-size: 0.85rem;"><i class="fas fa-file-contract"></i> Tạo Phụ lục</button>
                    </c:if>
                </div>
                
                <div style="display: grid; grid-template-columns: 200px 1fr; row-gap: 16px; font-size: 0.95rem; margin-top: 16px;">
                    <div style="color: #6b7280; font-weight: 500;">Loại hợp đồng</div>
                    <div style="color: #1a1a1a; font-weight: 600;">${currentContract.contractTypeName}</div>
                    
                    <div style="color: #6b7280; font-weight: 500;">Ngày bắt đầu</div>
                    <div style="color: #1a1a1a; font-weight: 600;"><fmt:formatDate value="${currentContract.startDate}" pattern="dd/MM/yyyy"/></div>
                    
                    <div style="color: #6b7280; font-weight: 500;">Ngày kết thúc</div>
                    <div style="color: #1a1a1a; font-weight: 600;">
                        <c:choose>
                            <c:when test="${not empty currentContract.endDate}"><fmt:formatDate value="${currentContract.endDate}" pattern="dd/MM/yyyy"/></c:when>
                            <c:otherwise>Không giới hạn</c:otherwise>
                        </c:choose>
                    </div>
                    
                    <div style="grid-column: span 2; border-top: 1px dashed #e5e7eb; margin: 8px 0;"></div>
                    
                    <div style="color: #6b7280; font-weight: 500;">Lương cơ bản</div>
                    <div style="color: #1a1a1a; font-weight: 600;"><fmt:formatNumber value="${currentContract.baseSalary}" type="number" groupingUsed="true"/> VNĐ</div>
                    
                    <div style="color: #6b7280; font-weight: 500;">Tổng Phụ cấp</div>
                    <div>
                        <div style="color: #1a1a1a; font-weight: 600;">+ <fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/> VNĐ</div>
                        <c:if test="${not empty allowanceList}">
                            <div style="margin-top: 8px; background: #f8fafc; padding: 8px 12px; border-radius: 6px; border: 1px solid #e2e8f0; font-size: 0.85rem;">
                                <ul style="margin: 0; padding-left: 16px; color: #475569;">
                                    <c:forEach var="alw" items="${allowanceList}">
                                        <li>${alw.name}: <fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/> đ</li>
                                    </c:forEach>
                                </ul>
                            </div>
                        </c:if>
                    </div>
                    
                    <div style="color: #2563eb; font-weight: 700;">Lương Gross (Dự kiến)</div>
                    <div style="color: #2563eb; font-size: 1.15rem; font-weight: 700;"><fmt:formatNumber value="${currentContract.baseSalary + totalAllowance}" type="number" groupingUsed="true"/> VNĐ</div>
                    
                    <div style="color: #6b7280; font-weight: 500;">Mức đóng Bảo hiểm</div>
                    <div style="color: #1a1a1a; font-weight: 600;">BHXH: ${currentContract.bhxhRate}% | BHYT: ${currentContract.bhytRate}% | BHTN: ${currentContract.bhtnRate}%</div>
                    
                    <div style="color: #6b7280; font-weight: 500;">Loại tính thuế TNCN</div>
                    <div style="color: #1a1a1a; font-weight: 600;">
                        <c:choose>
                            <c:when test="${currentContract.taxCalcType == 1}">Biểu thuế lũy tiến</c:when>
                            <c:when test="${currentContract.taxCalcType == 2}">Khấu trừ 10%</c:when>
                            <c:when test="${currentContract.taxCalcType == 3}">Không tính thuế</c:when>
                        </c:choose>
                    </div>
                    
                    <div style="color: #6b7280; font-weight: 500;">Trạng thái</div>
                    <div>
                        <c:choose>
                            <c:when test="${currentContract.status == 'Active'}">
                                <span class="status-badge status-active"><i class="fas fa-check-circle me-1" style="font-size:10px;"></i> Đang áp dụng</span>
                            </c:when>
                            <c:when test="${currentContract.status == 'Pending'}">
                                <span class="status-badge" style="background:#eff6ff; color:#2563eb; border: 1px solid #bfdbfe;"><i class="fas fa-clock me-1" style="font-size:10px;"></i> Chờ duyệt</span>
                            </c:when>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Tab Content: Lịch sử Hợp đồng -->
        <div class="content-card">
            <h3 class="section-title"><i class="fas fa-history" style="color:#2563eb;"></i> Lịch sử Hợp đồng &amp; Lương</h3>
            
            <c:if test="${not empty successMsg}">
                <div style="background: #dcfce7; color: #166534; padding: 12px 16px; border-radius: 8px; margin-bottom: 16px;">
                    <i class="fas fa-check-circle me-2"></i>${successMsg}
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div style="background: #fee2e2; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 16px;">
                    <i class="fas fa-exclamation-circle me-2"></i>${errorMsg}
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>

            <table class="data-table" style="width: 100%; border-collapse: collapse; text-align: left;">
                <thead style="background: #f8fafc; border-bottom: 2px solid #e2e8f0;">
                    <tr>
                        <th style="padding: 12px 16px; color: #475569; font-weight: 600; font-size: 0.85rem;">Loại HĐ</th>
                        <th style="padding: 12px 16px; color: #475569; font-weight: 600; font-size: 0.85rem;">Từ ngày - Đến ngày</th>
                        <th style="padding: 12px 16px; color: #475569; font-weight: 600; font-size: 0.85rem;">Lương Gross</th>
                        <th style="padding: 12px 16px; color: #475569; font-weight: 600; font-size: 0.85rem;">Bảo hiểm (%)</th>
                        <th style="padding: 12px 16px; color: #475569; font-weight: 600; font-size: 0.85rem;">Thuế TNCN</th>
                        <th style="padding: 12px 16px; color: #475569; font-weight: 600; font-size: 0.85rem;">Trạng thái</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty contracts}">
                            <tr>
                                <td colspan="6" style="padding: 24px; text-align: center; color: #94a3b8; font-style: italic;">
                                    Chưa có hợp đồng nào được lưu cho nhân viên này.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="c" items="${contracts}">
                                <tr style="border-bottom: 1px solid #e2e8f0; ${c.status == 'Active' ? 'background: #f0fdf4;' : ''}">
                                    <td style="padding: 12px 16px; font-weight: 500; color: #0f172a;">
                                        ${c.contractTypeName}
                                    </td>
                                    <td style="padding: 12px 16px; font-size: 0.9rem; color: #475569;">
                                        <fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/> - 
                                        <c:choose>
                                            <c:when test="${c.endDate != null}"><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></c:when>
                                            <c:otherwise>Vô thời hạn</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px 16px; font-weight: 700; color: #16a34a;">
                                        <fmt:formatNumber value="${c.baseSalary + totalAllowance}" type="number" groupingUsed="true"/> đ
                                    </td>
                                    <td style="padding: 12px 16px; font-size: 0.85rem; color: #475569;">
                                        XH: ${c.bhxhRate}% | YT: ${c.bhytRate}% | TN: ${c.bhtnRate}%
                                    </td>
                                    <td style="padding: 12px 16px; font-size: 0.9rem; color: #475569;">
                                        <c:choose>
                                            <c:when test="${c.taxCalcType == 1}">Lũy tiến</c:when>
                                            <c:when test="${c.taxCalcType == 2}">Khấu trừ 10%</c:when>
                                            <c:when test="${c.taxCalcType == 3}">Không tính thuế</c:when>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px 16px;">
                                        <c:choose>
                                            <c:when test="${c.status == 'Active'}">
                                                <span class="status-badge status-active"><i class="fas fa-circle me-1" style="font-size:8px;"></i> Đang áp dụng</span>
                                            </c:when>
                                            <c:when test="${c.status == 'Pending'}">
                                                <span class="status-badge" style="background:#eff6ff; color:#2563eb;"><i class="fas fa-clock me-1" style="font-size:8px;"></i> Chờ duyệt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge" style="background:#f1f5f9; color:#64748b;"><i class="fas fa-history me-1" style="font-size:8px;"></i> Đã hết hạn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal Thêm Hợp Đồng -->
<div id="addContractModal" style="display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.5); z-index: 9999; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
    <div style="background: #fff; width: 650px; border-radius: 16px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); display: flex; flex-direction: column; max-height: 90vh;">
        <div style="padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; flex-shrink: 0;">
            <h3 style="margin: 0; font-size: 1.25rem; font-weight: 700; color: #0f172a;"><i class="fas fa-file-signature me-2" style="color: #2563eb;"></i> Gia hạn / Ký mới Hợp đồng</h3>
            <button type="button" onclick="closeAddContractModal()" style="background: transparent; border: none; font-size: 1.5rem; color: #94a3b8; cursor: pointer;">&times;</button>
        </div>
        
        <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST" style="display: flex; flex-direction: column; overflow: hidden;">
            <div style="padding: 24px; overflow-y: auto;">
                <input type="hidden" name="action" value="create">
                <input type="hidden" name="userId" value="${employee.userId}">
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                <div class="form-group">
                    <label class="form-label" style="display: block; margin-bottom: 8px;">Loại Hợp đồng <span style="color:red">*</span></label>
                    <select name="contractTypeId" required style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
                        <c:forEach var="ct" items="${contractTypes}">
                            <option value="${ct.contractTypeId}">${ct.typeName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" style="display: block; margin-bottom: 8px;">Lương cơ bản (VNĐ) <span style="color:red">*</span></label>
                    <input type="text" name="baseSalary" required placeholder="VD: 15,000,000" style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
                    <small id="probationHint" style="color: #d97706; font-size: 0.8rem; display: none; margin-top: 4px; font-weight: 500;">
                        * Hệ thống sẽ tự động tính mức lương bằng 85% lương nhập vào đối với HĐ Thử việc.
                    </small>
                </div>
                
                <div class="form-group">
                    <label class="form-label" style="display: block; margin-bottom: 8px;">Ngày bắt đầu <span style="color:red">*</span></label>
                    <input type="date" name="startDate" required style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
                </div>
                <div class="form-group">
                    <label class="form-label" style="display: block; margin-bottom: 8px;">Ngày kết thúc</label>
                    <input type="date" name="endDate" style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
                    <small style="color: #64748b; font-size: 0.8rem;">(Bỏ trống nếu HĐ Vô thời hạn)</small>
                </div>
            </div>
            
            <div style="background: #f1f5f9; padding: 16px; border-radius: 12px; margin-bottom: 20px;">
                <h4 style="margin: 0 0 16px; font-size: 0.95rem; font-weight: 700; color: #334155;">Thiết lập Thuế &amp; Bảo hiểm (Mặc định tự động điền)</h4>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                    <c:set var="defaultBHXH" value="8" />
                    <c:set var="defaultBHYT" value="1.5" />
                    <c:set var="defaultBHTN" value="1" />
                    <c:forEach var="ir" items="${activeRates}">
                        <c:if test="${ir.insuranceCode == 'BHXH'}"><c:set var="defaultBHXH" value="${ir.employeeRate}" /></c:if>
                        <c:if test="${ir.insuranceCode == 'BHYT'}"><c:set var="defaultBHYT" value="${ir.employeeRate}" /></c:if>
                        <c:if test="${ir.insuranceCode == 'BHTN'}"><c:set var="defaultBHTN" value="${ir.employeeRate}" /></c:if>
                    </c:forEach>
                    
                    <div class="form-group">
                        <label class="form-label" style="font-size: 0.8rem;">Tỷ lệ BHXH NV (%)</label>
                        <input type="number" step="0.01" name="bhxhRate" value="${defaultBHXH}" required style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px;">
                    </div>
                    <div class="form-group">
                        <label class="form-label" style="font-size: 0.8rem;">Tỷ lệ BHYT NV (%)</label>
                        <input type="number" step="0.01" name="bhytRate" value="${defaultBHYT}" required style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px;">
                    </div>
                    <div class="form-group">
                        <label class="form-label" style="font-size: 0.8rem;">Tỷ lệ BHTN NV (%)</label>
                        <input type="number" step="0.01" name="bhtnRate" value="${defaultBHTN}" required style="width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px;">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label" style="font-size: 0.85rem;">Loại tính thuế TNCN</label>
                    <select name="taxCalcType" required style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
                        <option value="1">Biểu thuế Lũy tiến từng phần (Áp dụng HĐ chính thức)</option>
                        <option value="2">Khấu trừ 10% (Áp dụng HĐ Thử việc / Dưới 3 tháng)</option>
                        <option value="3">Không tính thuế</option>
                    </select>
                </div>
            </div>

            <div style="background: #f1f5f9; padding: 16px; border-radius: 12px; margin-bottom: 20px;">
                <h4 style="margin: 0 0 16px; font-size: 0.95rem; font-weight: 700; color: #334155;">Phụ cấp áp dụng</h4>
                <div style="display: flex; flex-wrap: wrap; gap: 16px;">
                    <c:forEach var="a" items="${availableAllowances}">
                        <label style="display: flex; align-items: center; gap: 8px; font-size: 0.9rem; color: #475569; cursor: pointer;">
                            <input type="checkbox" name="allowanceIds" value="${a.allowanceId}" 
                                   ${(a.allowanceId == 1 || a.allowanceId == 2) ? 'checked' : ''}
                                   style="width: 16px; height: 16px; cursor: pointer;">
                            ${a.allowanceName} (<fmt:formatNumber value="${a.amount}" type="number" groupingUsed="true"/> đ)
                        </label>
                    </c:forEach>
                </div>
            </div>

            </div>
            </div>
            <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: flex-end; gap: 12px; flex-shrink: 0;">
                <button type="button" onclick="closeAddContractModal()" style="padding: 10px 20px; border: 1px solid #cbd5e1; background: #fff; border-radius: 8px; font-weight: 600; color: #475569; cursor: pointer;">Hủy bỏ</button>
                <button type="submit" style="padding: 10px 24px; border: none; background: #2563eb; color: #fff; border-radius: 8px; font-weight: 600; cursor: pointer;">Lưu Hợp đồng</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Thêm Phụ Lục -->
<c:if test="${not empty currentContract}">
<div id="addAddendumModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; padding: 20px;">
    <div style="background: #fff; width: 100%; max-width: 700px; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); display: flex; flex-direction: column; max-height: 90vh;">
        <div style="padding: 16px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; border-radius: 12px 12px 0 0; flex-shrink: 0;">
            <h3 style="margin: 0; font-size: 1.2rem; color: #1e293b;"><i class="fas fa-file-contract" style="color: #d97706; margin-right: 8px;"></i>Tạo Phụ lục Hợp đồng</h3>
            <button type="button" onclick="closeAddendumModal()" style="background: none; border: none; font-size: 1.5rem; color: #94a3b8; cursor: pointer;">&times;</button>
        </div>
        
        <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST" style="margin: 0; display: flex; flex-direction: column; overflow: hidden;">
            <div style="padding: 24px; overflow-y: auto;">
                <input type="hidden" name="action" value="createAddendum">
                <input type="hidden" name="userId" value="${employee.userId}">
                
                <!-- Kế thừa từ Hợp đồng gốc -->
                <input type="hidden" name="parentContractId" value="${currentContract.contractId}">
                <input type="hidden" name="contractTypeId" value="${currentContract.contractTypeId}">
                <c:if test="${not empty currentContract.endDate}">
                    <input type="hidden" name="endDate" value="${currentContract.endDate}">
                </c:if>
                <input type="hidden" name="bhxhRate" value="${currentContract.bhxhRate}">
                <input type="hidden" name="bhytRate" value="${currentContract.bhytRate}">
                <input type="hidden" name="bhtnRate" value="${currentContract.bhtnRate}">
                <input type="hidden" name="taxCalcType" value="${currentContract.taxCalcType}">
            
            <div style="display: grid; grid-template-columns: 1fr; gap: 20px; margin-bottom: 20px;">
                <div class="form-group">
                    <label class="form-label" style="display: block; margin-bottom: 8px;">Lý do tạo Phụ lục <span style="color:red">*</span></label>
                    <input type="text" name="addendumReason" required placeholder="VD: Tăng lương định kỳ năm 2026" style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
                </div>
            </div>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                <div class="form-group">
                    <label class="form-label" style="display: block; margin-bottom: 8px;">Mức Lương cơ bản mới (VNĐ) <span style="color:red">*</span></label>
                    <input type="text" name="baseSalary" required placeholder="VD: 15,000,000" value="<fmt:formatNumber value="${currentContract.baseSalary}" pattern="0"/>" style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
                </div>
                <div class="form-group">
                    <label class="form-label" style="display: block; margin-bottom: 8px;">Ngày bắt đầu hiệu lực <span style="color:red">*</span></label>
                    <input type="date" name="startDate" required style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;">
                </div>
            </div>

            <div style="background: #f1f5f9; padding: 16px; border-radius: 12px; margin-bottom: 20px;">
                <h4 style="margin: 0 0 16px; font-size: 0.95rem; font-weight: 700; color: #334155;">Phụ cấp áp dụng cho Phụ lục mới</h4>
                <div style="display: flex; flex-wrap: wrap; gap: 16px;">
                    <c:forEach var="a" items="${availableAllowances}">
                        <label style="display: flex; align-items: center; gap: 8px; font-size: 0.9rem; color: #475569; cursor: pointer;">
                            <input type="checkbox" name="allowanceIds" value="${a.allowanceId}" 
                                   <c:forEach var="ca" items="${allowanceList}">
                                       <c:if test="${ca.allowanceName == a.allowanceName}">checked</c:if>
                                   </c:forEach>
                                   style="width: 16px; height: 16px; cursor: pointer;">
                            ${a.allowanceName} (<fmt:formatNumber value="${a.amount}" type="number" groupingUsed="true"/> đ)
                        </label>
                    </c:forEach>
                </div>
            </div>

            </div>
            <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: flex-end; gap: 12px; flex-shrink: 0;">
                <button type="button" onclick="closeAddendumModal()" style="padding: 10px 20px; border: 1px solid #cbd5e1; background: #fff; border-radius: 8px; font-weight: 600; color: #475569; cursor: pointer;">Hủy bỏ</button>
                <button type="submit" style="padding: 10px 24px; border: none; background: #d97706; color: #fff; border-radius: 8px; font-weight: 600; cursor: pointer;">Lưu Phụ lục</button>
            </div>
        </form>
    </div>
</div>
</c:if>

<script>
    function openAddendumModal() {
        document.getElementById('addAddendumModal').style.display = 'flex';
    }
    function closeAddendumModal() {
        document.getElementById('addAddendumModal').style.display = 'none';
    }

    function openAddContractModal() {
        document.getElementById('addContractModal').style.display = 'flex';
    }
    function closeAddContractModal() {
        document.getElementById('addContractModal').style.display = 'none';
    }
    
    // Toggle probation hint
    const contractTypeSelect = document.querySelector('select[name="contractTypeId"]');
    const probationHint = document.getElementById('probationHint');
    if(contractTypeSelect && probationHint) {
        contractTypeSelect.addEventListener('change', function() {
            if(this.value === '1') { // 1 = Thử việc
                probationHint.style.display = 'block';
            } else {
                probationHint.style.display = 'none';
            }
        });
        if(contractTypeSelect.value === '1') probationHint.style.display = 'block';
    }
    
    // Auto format number with commas
    const salaryInput = document.querySelector('input[name="baseSalary"]');
    if(salaryInput) {
        salaryInput.addEventListener('input', function(e) {
            let value = this.value.replace(/,/g, '').replace(/[^\d]/g, '');
            if(value) {
                this.value = parseInt(value).toLocaleString('en-US');
            } else {
                this.value = '';
            }
        });
    }
</script>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Lịch sử công tác - Hồ sơ Nhân sự" scope="request" />
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

    /* Timeline */
    .content-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 28px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
    .section-title { font-size: 1.1rem; font-weight: 700; color: #0f172a; margin: 0 0 24px; display: flex; align-items: center; gap: 10px; }
    .section-title i { color: #2563eb; }

    .timeline { position: relative; padding-left: 32px; }
    .timeline::before { content: ''; position: absolute; left: 11px; top: 8px; bottom: 8px; width: 2px; background: linear-gradient(to bottom, #2563eb, #e2e8f0); border-radius: 2px; }
    .timeline-item { position: relative; margin-bottom: 28px; padding-bottom: 28px; border-bottom: 1px dashed #f1f5f9; }
    .timeline-item:last-child { margin-bottom: 0; padding-bottom: 0; border-bottom: none; }

    .timeline-dot { position: absolute; left: -32px; top: 4px; width: 22px; height: 22px; border-radius: 50%; background: #fff; border: 3px solid #2563eb; z-index: 1; display: flex; align-items: center; justify-content: center; }
    .timeline-dot.current { background: #2563eb; border-color: #2563eb; box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.15); }
    .timeline-dot.current::after { content: ''; width: 8px; height: 8px; border-radius: 50%; background: white; }
    .timeline-dot.past { border-color: #cbd5e0; background: #cbd5e0; }
    .timeline-dot.past::after { content: '\f00c'; font-family: 'Font Awesome 6 Free'; font-weight: 900; font-size: 0.5rem; color: white; }

    .timeline-date { font-size: 0.78rem; font-weight: 700; color: #2563eb; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
    .timeline-title { font-size: 1rem; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
    .timeline-subtitle { font-size: 0.85rem; color: #64748b; margin: 0 0 8px; display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
    .timeline-subtitle i { font-size: 0.8rem; }
    .timeline-desc { font-size: 0.85rem; color: #475569; line-height: 1.6; background: #f8fafc; padding: 12px 16px; border-radius: 10px; border-left: 3px solid #e2e8f0; }

    .timeline-badge { display: inline-block; padding: 3px 10px; border-radius: 6px; font-size: 0.72rem; font-weight: 700; margin-left: 8px; }
    .badge-current { background: #dcfce7; color: #166534; }
    .badge-completed { background: #dbeafe; color: #1e40af; }

    /* Empty state */
    .empty-state { text-align: center; padding: 60px 20px; color: #94a3b8; }
    .empty-state i { font-size: 2.5rem; margin-bottom: 12px; display: block; color: #cbd5e1; }
    .empty-state p { margin: 0; font-size: 0.9rem; }
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
                <h1 class="breadcrumb-title">Quản lý Hồ sơ Nhân sự <span>/ Lịch sử công tác</span></h1>
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
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-work-history?userId=${employee.userId}" class="nav-tab active">Lịch sử công tác</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-contracts?userId=${employee.userId}" class="nav-tab">Hợp đồng &amp; Lương</a>
        </div>

        <!-- Tab Content: Lịch sử công tác -->
        <div class="content-card">
            <h3 class="section-title">
                <i class="fas fa-route"></i> Quá trình vị trí &amp; phòng ban
            </h3>

            <c:choose>
                <c:when test="${empty workHistory}">
                    <div class="empty-state">
                        <i class="fas fa-history"></i>
                        <p>Chưa có dữ liệu lịch sử công tác cho nhân viên này</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="timeline">
                        <c:forEach var="wh" items="${workHistory}">
                            <div class="timeline-item">
                                <div class="timeline-dot ${wh.current ? 'current' : 'past'}"></div>
                                <div class="timeline-date">
                                    <fmt:formatDate value="${wh.startDate}" pattern="MM/yyyy" /> — 
                                    <c:choose>
                                        <c:when test="${wh.current || empty wh.endDate}">Hiện tại</c:when>
                                        <c:otherwise><fmt:formatDate value="${wh.endDate}" pattern="MM/yyyy" /></c:otherwise>
                                    </c:choose>
                                </div>
                                <h4 class="timeline-title">
                                    ${wh.positionTitle}
                                    <c:if test="${wh.current}">
                                        <span class="timeline-badge badge-current">Hiện tại</span>
                                    </c:if>
                                    <c:if test="${!wh.current}">
                                        <span class="timeline-badge badge-completed">Hoàn thành</span>
                                    </c:if>
                                </h4>
                                <div class="timeline-subtitle">
                                    <span><i class="fas fa-building me-1"></i>${wh.companyName}</span>
                                    <c:if test="${not empty wh.location}">
                                        <span><i class="fas fa-map-marker-alt me-1"></i>${wh.location}</span>
                                    </c:if>
                                </div>
                                <c:if test="${not empty wh.description}">
                                    <div class="timeline-desc">${wh.description}</div>
                                </c:if>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>

<jsp:include page="../footer.jsp" />

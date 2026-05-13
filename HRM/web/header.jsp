<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <c:choose>
            <c:when test="${not empty pageTitle}">
                <c:out value="${pageTitle} | Grupo4 HRM"/>
            </c:when>
            <c:otherwise>
                Grupo4 HRM - Hệ thống Quản trị Nhân sự toàn diện
            </c:otherwise>
        </c:choose>
    </title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body class="d-flex flex-column min-vh-100" data-context-path="${pageContext.request.contextPath}">
    
    <nav class="navbar navbar-expand-lg fixed-top navbar-custom" id="mainNavbar">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/home">
                <i class="fas fa-users-cog" style="color: #5b328a;"></i>
                <span>Group4 HRM</span>
            </a>
            
            <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mx-auto mb-2 mb-lg-0 gap-1">
                    <li class="nav-item">
                        <a class="nav-link px-3" href="${pageContext.request.contextPath}/home">Trang chủ</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-3" href="${pageContext.request.contextPath}/features">Tính năng</a>
                    </li>
                    <c:if test="${sessionScope.account != null}">
                        <li class="nav-item">
                            <a class="nav-link px-3" href="${pageContext.request.contextPath}/dashboard">
                                <i class="fas fa-chart-line me-1"></i>Bảng điều khiển
                            </a>
                        </li>
                    </c:if>
                </ul>
                
                <div class="d-flex align-items-center gap-3">
                    <c:choose>
                        <%-- TRƯỜNG HỢP 1: ĐÃ ĐĂNG NHẬP --%>
                        <c:when test="${sessionScope.account != null}">
                            <a href="${pageContext.request.contextPath}/notifications" class="btn btn-link position-relative p-1 me-1 text-dark" style="text-decoration: none;">
                                <i class="fas fa-bell fs-5" style="color: #5b328a;"></i>
                                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size:0.6rem;">3</span>
                            </a>
                            
                            <div class="dropdown">
                                <button class="btn d-flex align-items-center gap-2 p-0 border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                                    <div class="rounded-circle text-white d-flex align-items-center justify-content-center" style="width: 35px; height: 35px; font-weight: bold; background: linear-gradient(135deg, #8569bf 0%, #d87bbd 100%);">
                                        ${sessionScope.account.fullName.substring(0,1)}
                                    </div>
                                    <span class="fw-medium small d-none d-md-inline text-dark">${sessionScope.account.fullName}</span>
                                    <i class="fas fa-chevron-down small text-muted"></i>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end border-0 rounded-4 p-2 mt-2 shadow-lg" style="min-width: 240px;">
                                    <li><h6 class="dropdown-header text-muted">Quản lý cá nhân</h6></li>
                                    <li><a class="dropdown-item rounded-3 py-2" href="${pageContext.request.contextPath}/profile"><i class="fas fa-id-badge me-2" style="color: #8569bf;"></i>Hồ sơ nhân viên</a></li>
                                    <li><a class="dropdown-item rounded-3 py-2" href="${pageContext.request.contextPath}/attendance"><i class="fas fa-clock text-success me-2"></i>Lịch sử chấm công</a></li>
                                    <li><a class="dropdown-item rounded-3 py-2" href="${pageContext.request.contextPath}/payroll"><i class="fas fa-file-invoice-dollar text-warning me-2"></i>Phiếu lương</a></li>
                                    
                                    <c:if test="${sessionScope.account.role == 'admin'}">
                                        <li><hr class="dropdown-divider my-2"></li>
                                        <li><h6 class="dropdown-header text-muted">Hệ thống</h6></li>
                                        <li><a class="dropdown-item rounded-3 py-2" href="${pageContext.request.contextPath}/admin/employees"><i class="fas fa-users text-info me-2"></i>Quản lý nhân sự</a></li>
                                        <li><a class="dropdown-item rounded-3 py-2" href="${pageContext.request.contextPath}/admin/settings"><i class="fas fa-cog text-secondary me-2"></i>Cài đặt hệ thống</a></li>
                                    </c:if>
                                    
                                    <li><hr class="dropdown-divider my-2"></li>
                                    <li><a class="dropdown-item rounded-3 py-2 text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i>Đăng xuất</a></li>
                                </ul>
                            </div>
                        </c:when>
                        
                        <%-- TRƯỜNG HỢP 2: CHƯA ĐĂNG NHẬP --%>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-login">Đăng nhập</a>
                            <a href="${pageContext.request.contextPath}/register" class="btn btn-register">Đăng ký</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </nav>
    
    <div style="height: 76px;"></div>
    
    <c:if test="${not empty sessionScope.toastMessage}">
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        alert("${fn:escapeXml(sessionScope.toastMessage)}"); 
    });
    </script>
    <% session.removeAttribute("toastMessage"); session.removeAttribute("toastType"); %>
    </c:if>

    <main class="flex-grow-1">
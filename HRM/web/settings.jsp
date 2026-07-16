<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Cài đặt bảo mật - HRM" scope="request"/>
<jsp:include page="header.jsp"/>

<style>
    body {
        background-color: var(--th-bg);
    }

    .settings-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }

    .settings-content {
        flex: 1;
        padding: 30px;
        overflow-y: auto;
        max-width: 900px;
    }

    /* Page Header */
    .settings-page-header {
        margin-bottom: 24px;
    }

    .settings-page-title {
        font-size: 1.4rem;
        font-weight: 700;
        color: var(--th-text);
        margin: 0;
    }

    .settings-breadcrumb {
        font-size: 0.85rem;
        color: var(--th-muted);
        margin: 4px 0 0;
    }

    .settings-breadcrumb a {
        color: #4361ee;
        text-decoration: none;
    }

    /* Settings Card */
    .settings-card {
        background: var(--th-surface);
        border: 1px solid var(--th-border);
        border-radius: 16px;
        padding: 28px;
        box-shadow: var(--th-card-shadow);
        margin-bottom: 24px;
    }

    .settings-card-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid var(--th-border);
    }

    .settings-card-header .icon-box {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
    }

    .settings-card-header h3 {
        margin: 0;
        font-size: 1.05rem;
        font-weight: 700;
        color: var(--th-text);
    }

    .settings-card-header p {
        margin: 2px 0 0;
        font-size: 0.8rem;
        color: var(--th-muted);
    }

    /* Security Info */
    .security-info {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 16px;
        background: var(--th-surface2);
        border-radius: 12px;
        border: 1px solid var(--th-border);
    }

    .security-info .si-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        font-size: 0.9rem;
    }

    .security-info h6 {
        margin: 0;
        font-size: 0.85rem;
        font-weight: 700;
        color: var(--th-text);
    }

    .security-info p {
        margin: 2px 0 0;
        font-size: 0.78rem;
        color: var(--th-muted);
    }

    /* Responsive */
    @media (max-width: 991px) {
        .settings-layout {
            flex-direction: column;
        }

        .settings-content {
            padding: 20px;
            max-width: 100%;
        }
    }
</style>

<div class="settings-layout">
    <!-- Sidebar chung phân quyền theo role -->
    <jsp:include page="shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="settings"/>
    </jsp:include>

    <!-- Main Content -->
    <div class="settings-content">

        <!-- Alert Messages -->
        <c:if test="${not empty msgSuccess}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert"
                 style="border-radius: 12px; background: #d1fae5; color: #065f46;">
                <i class="fas fa-check-circle me-2"></i> ${msgSuccess}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty msgError}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert"
                 style="border-radius: 12px; background: #fee2e2; color: #991b1b;">
                <i class="fas fa-exclamation-triangle me-2"></i> ${msgError}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Page Header -->
        <div class="settings-page-header">
            <h1 class="settings-page-title">Cài đặt bảo mật</h1>
            <p class="settings-breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Trang chủ</a> &nbsp;>&nbsp; Cài đặt bảo mật
            </p>
        </div>

        <!-- 1. Change Password Card -->
        <div class="settings-card"
             style="display: flex; align-items: center; justify-content: space-between; padding: 24px;">
            <div style="display: flex; align-items: center; gap: 16px;">
                <div class="icon-box"
                     style="width: 46px; height: 46px; border-radius: 12px; background: rgba(229, 62, 62, 0.1); color: #e53e3e; display: flex; align-items: center; justify-content: center; font-size: 1.2rem;">
                    <i class="fas fa-key"></i>
                </div>
                <div>
                    <h3 style="margin: 0; font-size: 1.05rem; font-weight: 700; color: #2d3748;">Đổi mật khẩu</h3>
                    <p style="margin: 2px 0 0; font-size: 0.85rem; color: #8f9fbc;">Cập nhật mật khẩu để bảo vệ tài
                        khoản của bạn</p>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/changePassword.jsp" class="btn btn-outline-primary"
               style="border-radius: 8px; font-weight: 600; padding: 8px 20px; font-size: 0.85rem;">
                Thay đổi
            </a>
        </div>

        <!-- 3. Session Info Card -->
        <div class="settings-card">
            <div class="settings-card-header">
                <div class="icon-box" style="background: rgba(56, 161, 105, 0.1); color: #38a169;">
                    <i class="fas fa-laptop"></i>
                </div>
                <div>
                    <h3>Phiên đăng nhập</h3>
                    <p>Quản lý các thiết bị đang đăng nhập tài khoản của bạn</p>
                </div>
            </div>

            <div class="security-info mb-3">
                <div class="si-icon" style="background: rgba(56, 161, 105, 0.1); color: #38a169;">
                    <i class="fas fa-desktop"></i>
                </div>
                <div style="flex: 1;">
                    <h6><i class="fas fa-circle text-success me-1" style="font-size: 6px; vertical-align: middle;"></i>
                        Thiết bị hiện tại</h6>
                    <p>Trình duyệt web · Đăng nhập gần nhất: Hôm nay</p>
                </div>
                <span class="badge"
                      style="background: #d1fae5; color: #065f46; font-size: 0.72rem; padding: 4px 10px; border-radius: 6px;">Đang hoạt động</span>
            </div>

            <div class="text-muted" style="font-size: 0.82rem; padding: 12px 0;">
                <i class="fas fa-info-circle me-1"></i>
                Nếu bạn phát hiện phiên đăng nhập bất thường, hãy đổi mật khẩu ngay lập tức.
            </div>
        </div>

    </div><!-- end .settings-content -->
</div>
<!-- end .settings-layout -->

<jsp:include page="footer.jsp"/>

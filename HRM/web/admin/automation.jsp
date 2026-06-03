<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Tác vụ Tự động - Admin" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
/* ── Reset portal footer cho trang admin ── */
footer, #chatWidget {
    display: none !important;
}

body {
    background-color: #f1f5f9 !important;
    font-family: 'Inter', sans-serif !important;
    padding-top: 0 !important;
    min-height: 100vh;
    overflow-x: hidden;
}

/* ── Layout ── */
.dashboard-wrapper {
    display: flex;
    min-height: calc(100vh - 64px);
}

/* ── Main Area ── */
.dash-main {
    flex: 1;
    min-width: 0;
    background: #f1f5f9;
}

/* ── Content Area ── */
.dash-content {
    padding: 28px 32px;
    display: flex;
    flex-direction: column;
    gap: 28px;
}

/* ── Breadcrumb / Page Title ── */
.dash-page-header {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.dash-breadcrumb {
    font-size: 0.78rem;
    color: #94a3b8;
    display: flex;
    align-items: center;
    gap: 6px;
}

.dash-breadcrumb a {
    color: #0d9488;
    text-decoration: none;
}

.dash-breadcrumb a:hover { text-decoration: underline; }

.dash-page-title {
    font-size: 1.5rem;
    font-weight: 800;
    color: #0f172a;
    letter-spacing: -0.5px;
}

/* ── Cards ── */
.dash-card {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05);
    border: 1px solid #e2e8f0;
}

.dash-card-header {
    margin-bottom: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.dash-card-title {
    font-size: 1.1rem;
    font-weight: 700;
    color: #0f172a;
    display: flex;
    align-items: center;
    gap: 8px;
}

.dash-card-title-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    flex-shrink: 0;
}

.dot-teal   { background: #0d9488; }
.dot-blue   { background: #3b82f6; }

/* ── Form Elements ── */
.form-group {
    margin-bottom: 15px;
}

.form-label {
    display: block;
    font-size: 0.85rem;
    font-weight: 600;
    color: #475569;
    margin-bottom: 6px;
}

.form-control {
    width: 100%;
    padding: 10px 14px;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    font-size: 0.9rem;
    color: #0f172a;
    transition: all 0.2s;
}

.form-control:focus {
    border-color: #0d9488;
    box-shadow: 0 0 0 3px rgba(13,148,136,0.15);
    outline: none;
}

.dash-btn {
    padding: 10px 18px;
    font-size: 0.9rem;
    font-weight: 600;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.dash-btn-primary { background: #0d9488; color: #fff; }
.dash-btn-primary:hover { background: #0f766e; }

.alert {
    padding: 15px;
    border-radius: 8px;
    font-size: 0.9rem;
    font-weight: 500;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
}
.alert-success { background: #d1fae5; color: #065f46; border: 1px solid #34d399; }
.alert-danger { background: #fee2e2; color: #991b1b; border: 1px solid #f87171; }

.automation-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
}

.helper-text {
    font-size: 0.8rem;
    color: #64748b;
    margin-top: 4px;
    margin-bottom: 16px;
}

@media (max-width: 768px) {
    .dash-content { padding: 20px 16px; }
}
</style>

<div class="dashboard-wrapper">
    <%-- Sidebar chung --%>
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="automation" />
    </jsp:include>

    <%-- Main Content Area --%>
    <div class="dash-main">
        <div class="dash-content">

            <%-- Page Header --%>
            <div class="dash-page-header">
                <div class="dash-breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <span>Tác vụ Tự động</span>
                </div>
                <div class="dash-page-title">Tự Động Hóa Hệ Thống (Khen Thưởng / Kỷ Luật)</div>
            </div>

            <c:if test="${not empty message}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> ${message}
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                </div>
            </c:if>

            <div class="automation-grid">
                <%-- Attendance Automation Card --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-teal"></div>
                            Chạy Kịch Bản Chấm Công Tự Động
                        </h3>
                    </div>
                    <p class="helper-text">Tính toán các khoản phạt đi muộn và thưởng chuyên cần dựa trên dữ liệu logs chấm công tháng.</p>
                    
                    <form action="${pageContext.request.contextPath}/admin/automation" method="post">
                        <input type="hidden" name="action" value="attendance">
                        
                        <div class="form-group">
                            <label class="form-label">User ID (ID Nhân viên)</label>
                            <input type="number" class="form-control" name="userId" placeholder="Nhập ID nhân viên..." required>
                        </div>
                        
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                            <div class="form-group">
                                <label class="form-label">Tháng</label>
                                <input type="number" class="form-control" name="month" min="1" max="12" placeholder="Ví dụ: 5" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Năm</label>
                                <input type="number" class="form-control" name="year" min="2020" placeholder="Ví dụ: 2026" required>
                            </div>
                        </div>
                        
                        <button type="submit" class="dash-btn dash-btn-primary" style="margin-top: 10px;">
                            <i class="fas fa-play"></i> Thực Thi Tự Động Hóa
                        </button>
                    </form>
                </div>

                <%-- 13th Month Salary Card --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">
                            <div class="dash-card-title-dot dot-blue"></div>
                            Kích Hoạt Tính Thưởng Tháng 13
                        </h3>
                    </div>
                    <p class="helper-text">Hệ thống sẽ tự động đối chiếu `hire_date` (Ngày bắt đầu vào làm) để tính tỷ lệ (prorated) thưởng tháng 13 một cách tự động.</p>
                    
                    <form action="${pageContext.request.contextPath}/admin/automation" method="post">
                        <input type="hidden" name="action" value="13th_month">
                        
                        <div class="form-group">
                            <label class="form-label">User ID (ID Nhân viên)</label>
                            <input type="number" class="form-control" name="userId" placeholder="Nhập ID nhân viên..." required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Năm Tính Thưởng</label>
                            <input type="number" class="form-control" name="year" min="2020" placeholder="Ví dụ: 2026" required>
                        </div>
                        
                        <button type="submit" class="dash-btn dash-btn-primary" style="margin-top: 10px; background-color: #3b82f6;">
                            <i class="fas fa-gift"></i> Tạo Thưởng Tháng 13
                        </button>
                    </form>
                </div>
            </div>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div><%-- end dashboard-wrapper --%>

<jsp:include page="../footer.jsp" />

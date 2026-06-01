<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Danh Mục Thưởng / Phạt" scope="request" />
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
}

.dashboard-wrapper {
    display: flex;
    min-height: calc(100vh - 64px);
}

.dash-main {
    flex: 1;
    min-width: 0;
    background: #f1f5f9;
}

.dash-content {
    padding: 28px 32px;
    display: flex;
    flex-direction: column;
    gap: 28px;
}

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

.dash-page-title {
    font-size: 1.5rem;
    font-weight: 800;
    color: #0f172a;
}

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
}

.dash-btn {
    padding: 8px 16px;
    font-size: 0.85rem;
    font-weight: 600;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: #fff;
    background: #0d9488;
}

.dash-table {
    width: 100%;
    border-collapse: collapse;
}

.dash-table th {
    padding: 12px 16px;
    border-bottom: 1px solid #e2e8f0;
    color: #64748b;
    font-size: 0.75rem;
    text-transform: uppercase;
    background: #fafbfc;
    text-align: left;
}

.dash-table td {
    padding: 15px 16px;
    border-bottom: 1px solid #f1f5f9;
    font-size: 0.9rem;
    color: #0f172a;
}

.badge {
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 700;
}

.badge-reward { background: #d1fae5; color: #059669; }
.badge-discipline { background: #fee2e2; color: #dc2626; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="reward-disciplines" />
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">
            <div class="dash-page-header">
                <div class="dash-breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <span>Thưởng & Kỷ luật</span>
                </div>
                <div class="dash-page-title">Quản Lý Danh Mục Thưởng / Phạt</div>
            </div>

            <div class="dash-card">
                <div class="dash-card-header">
                    <h3 class="dash-card-title">Danh mục các hạng mục</h3>
                    <button class="dash-btn" onclick="alert('Chức năng thêm mới đang được cập nhật!')">
                        <i class="fas fa-plus"></i> Thêm Hạng Mục
                    </button>
                </div>
                
                <table class="dash-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Hạng Mục</th>
                            <th>Phân Loại</th>
                            <th>Mô tả</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${categories}">
                            <tr>
                                <td>#${item.id}</td>
                                <td style="font-weight: 500;">${item.name}</td>
                                <td>
                                    <c:if test="${item.type == 'Reward'}">
                                        <span class="badge badge-reward">Thưởng</span>
                                    </c:if>
                                    <c:if test="${item.type == 'Discipline'}">
                                        <span class="badge badge-discipline">Kỷ Luật</span>
                                    </c:if>
                                </td>
                                <td style="color: #64748b;">${item.description}</td>
                                <td>
                                    <a href="#" style="color: #3b82f6; margin-right: 10px;"><i class="fas fa-edit"></i></a>
                                    <a href="#" style="color: #ef4444;"><i class="fas fa-trash"></i></a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

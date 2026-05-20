<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Lịch sử công tác - HRM" scope="request" />
<jsp:include page="header.jsp" />

<style>
    body { background-color: #f0f4f8; }

    .wh-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .wh-content {
        flex: 1;
        padding: 30px;
        overflow-y: auto;
    }

    /* Page Header */
    .wh-page-header { margin-bottom: 24px; }
    .wh-page-title {
        font-size: 1.4rem;
        font-weight: 700;
        color: #2b2b2b;
        margin: 0;
    }
    .wh-breadcrumb {
        font-size: 0.85rem;
        color: #8f9fbc;
        margin: 4px 0 0;
    }
    .wh-breadcrumb a { color: #4361ee; text-decoration: none; }

    /* Summary Stats */
    .wh-stats {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
        gap: 16px;
        margin-bottom: 24px;
    }
    .wh-stat {
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        padding: 20px;
        display: flex;
        align-items: center;
        gap: 14px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.03);
    }
    .wh-stat-icon {
        width: 44px; height: 44px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.1rem;
        flex-shrink: 0;
    }
    .wh-stat h4 {
        margin: 0;
        font-size: 1.3rem;
        font-weight: 800;
        color: #1a202c;
        line-height: 1;
    }
    .wh-stat span {
        font-size: 0.76rem;
        color: #8f9fbc;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.3px;
    }

    /* Card */
    .wh-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 28px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        margin-bottom: 24px;
    }
    .wh-card-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #edf2f7;
    }
    .wh-card-header .icon-box {
        width: 40px; height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
    }
    .wh-card-header h3 {
        margin: 0;
        font-size: 1.05rem;
        font-weight: 700;
        color: #2d3748;
    }

    /* Timeline */
    .timeline {
        position: relative;
        padding-left: 32px;
    }
    .timeline::before {
        content: '';
        position: absolute;
        left: 11px;
        top: 8px;
        bottom: 8px;
        width: 2px;
        background: linear-gradient(to bottom, #4361ee, #e2e8f0);
        border-radius: 2px;
    }
    .timeline-item {
        position: relative;
        margin-bottom: 28px;
        padding-bottom: 28px;
        border-bottom: 1px dashed #f1f5f9;
    }
    .timeline-item:last-child {
        margin-bottom: 0;
        padding-bottom: 0;
        border-bottom: none;
    }
    .timeline-dot {
        position: absolute;
        left: -32px;
        top: 4px;
        width: 22px;
        height: 22px;
        border-radius: 50%;
        background: #fff;
        border: 3px solid #4361ee;
        z-index: 1;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .timeline-dot.current {
        background: #4361ee;
        border-color: #4361ee;
        box-shadow: 0 0 0 4px rgba(67, 97, 238, 0.15);
    }
    .timeline-dot.current::after {
        content: '';
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: white;
    }
    .timeline-dot.past {
        border-color: #cbd5e0;
        background: #cbd5e0;
    }
    .timeline-dot.past::after {
        content: '\f00c';
        font-family: 'Font Awesome 6 Free';
        font-weight: 900;
        font-size: 0.5rem;
        color: white;
    }

    .timeline-date {
        font-size: 0.78rem;
        font-weight: 700;
        color: #4361ee;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 6px;
    }
    .timeline-title {
        font-size: 1rem;
        font-weight: 700;
        color: #2d3748;
        margin: 0 0 4px;
    }
    .timeline-subtitle {
        font-size: 0.85rem;
        color: #718096;
        margin: 0 0 8px;
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .timeline-subtitle i { font-size: 0.8rem; }
    .timeline-desc {
        font-size: 0.85rem;
        color: #4a5568;
        line-height: 1.6;
        background: #f8fafc;
        padding: 12px 16px;
        border-radius: 10px;
        border-left: 3px solid #e2e8f0;
    }
    .timeline-badge {
        display: inline-block;
        padding: 3px 10px;
        border-radius: 6px;
        font-size: 0.72rem;
        font-weight: 700;
    }
    .badge-current { background: #d1fae5; color: #065f46; }
    .badge-completed { background: #ebf8ff; color: #2b6cb0; }

    /* Contract Table */
    .contract-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 6px;
    }
    .contract-table th {
        font-size: 0.78rem;
        font-weight: 700;
        color: #8f9fbc;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 10px 14px;
        border: none;
    }
    .contract-table td {
        padding: 14px;
        font-size: 0.88rem;
        color: #4a5568;
        background: #f8fafc;
        border-top: 1px solid #edf2f7;
        border-bottom: 1px solid #edf2f7;
    }
    .contract-table tr td:first-child {
        border-left: 1px solid #edf2f7;
        border-radius: 8px 0 0 8px;
    }
    .contract-table tr td:last-child {
        border-right: 1px solid #edf2f7;
        border-radius: 0 8px 8px 0;
    }
    .contract-table tr:hover td { background: #edf2f7; }

    /* Empty state */
    .wh-empty {
        text-align: center;
        padding: 48px 20px;
        color: #a0aec0;
    }
    .wh-empty i {
        font-size: 2.5rem;
        margin-bottom: 12px;
        display: block;
        color: #cbd5e0;
    }
    .wh-empty p {
        margin: 0;
        font-size: 0.9rem;
    }

    /* Responsive */
    @media (max-width: 991px) {
        .wh-layout { flex-direction: column; }
        .wh-content { padding: 20px; }
    }
</style>

<div class="wh-layout">
    <!-- Sidebar -->
    <c:choose>
        <c:when test="${sessionScope.currentUser.roleId == 1}">
            <jsp:include page="admin/sidebar.jsp">
                <jsp:param name="activeMenu" value="work-history" />
            </jsp:include>
        </c:when>
        <c:otherwise>
            <jsp:include page="employee/sidebar.jsp">
                <jsp:param name="activeMenu" value="work-history" />
            </jsp:include>
        </c:otherwise>
    </c:choose>

    <!-- Main Content -->
    <div class="wh-content">

        <!-- Page Header -->
        <div class="wh-page-header">
            <h1 class="wh-page-title">Lịch sử công tác</h1>
            <p class="wh-breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Trang chủ</a> &nbsp;>&nbsp; Lịch sử công tác
            </p>
        </div>

        <!-- Summary Stats -->
        <div class="wh-stats">
            <div class="wh-stat">
                <div class="wh-stat-icon" style="background: #ebf8ff; color: #3182ce;">
                    <i class="fas fa-calendar-alt"></i>
                </div>
                <div>
                    <h4>1</h4>
                    <span>Năm làm việc</span>
                </div>
            </div>
            <div class="wh-stat">
                <div class="wh-stat-icon" style="background: #f0fff4; color: #38a169;">
                    <i class="fas fa-arrow-up"></i>
                </div>
                <div>
                    <h4>1</h4>
                    <span>Lần thăng tiến</span>
                </div>
            </div>
            <div class="wh-stat">
                <div class="wh-stat-icon" style="background: #fffaf0; color: #dd6b20;">
                    <i class="fas fa-file-contract"></i>
                </div>
                <div>
                    <h4>1</h4>
                    <span>Hợp đồng</span>
                </div>
            </div>
            <div class="wh-stat">
                <div class="wh-stat-icon" style="background: #faf5ff; color: #805ad5;">
                    <i class="fas fa-award"></i>
                </div>
                <div>
                    <h4>0</h4>
                    <span>Khen thưởng</span>
                </div>
            </div>
        </div>

        <!-- 1. Position History Timeline -->
        <div class="wh-card">
            <div class="wh-card-header">
                <div class="icon-box" style="background: rgba(67, 97, 238, 0.1); color: #4361ee;">
                    <i class="fas fa-route"></i>
                </div>
                <h3>Quá trình vị trí & phòng ban</h3>
            </div>

            <div class="timeline">
                <c:choose>
                    <c:when test="${empty workHistory}">
                        <div class="wh-empty" style="padding-top: 20px;">
                            <i class="fas fa-history" style="font-size: 2rem; color: #cbd5e0; margin-bottom: 10px; display: block;"></i>
                            <p style="color: #a0aec0; margin: 0; font-size: 0.9rem;">Chưa có dữ liệu lịch sử công tác</p>
                        </div>
                    </c:when>
                    <c:otherwise>
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
                                        <span class="timeline-badge badge-current ms-2">Hiện tại</span>
                                    </c:if>
                                    <c:if test="${!wh.current}">
                                        <span class="timeline-badge badge-completed ms-2">Hoàn thành</span>
                                    </c:if>
                                </h4>
                                <div class="timeline-subtitle">
                                    <span><i class="fas fa-building me-1"></i>${wh.companyName}</span>
                                    <span><i class="fas fa-map-marker-alt me-1"></i>${wh.location}</span>
                                </div>
                                <c:if test="${not empty wh.description}">
                                    <div class="timeline-desc">
                                        ${wh.description}
                                    </div>
                                </c:if>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 2. Contracts -->
        <div class="wh-card">
            <div class="wh-card-header">
                <div class="icon-box" style="background: rgba(221, 107, 32, 0.1); color: #dd6b20;">
                    <i class="fas fa-file-contract"></i>
                </div>
                <h3>Hợp đồng lao động</h3>
            </div>

            <div class="table-responsive">
                <table class="contract-table">
                    <thead>
                        <tr>
                            <th>Loại hợp đồng</th>
                            <th>Ngày bắt đầu</th>
                            <th>Ngày kết thúc</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>
                                <strong style="color: #2d3748;">Hợp đồng chính thức</strong>
                                <div class="text-muted" style="font-size: 0.78rem;">Toàn thời gian · Full-time</div>
                            </td>
                            <td>01/01/2026</td>
                            <td>31/12/2026</td>
                            <td>
                                <span style="display: inline-flex; align-items: center; gap: 5px; padding: 4px 12px; border-radius: 6px; font-size: 0.78rem; font-weight: 700; background: #d1fae5; color: #065f46;">
                                    <i class="fas fa-circle" style="font-size: 5px;"></i> Đang hiệu lực
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong style="color: #2d3748;">Hợp đồng thử việc</strong>
                                <div class="text-muted" style="font-size: 0.78rem;">Thử việc · Probation</div>
                            </td>
                            <td>01/06/2025</td>
                            <td>31/12/2025</td>
                            <td>
                                <span style="display: inline-flex; align-items: center; gap: 5px; padding: 4px 12px; border-radius: 6px; font-size: 0.78rem; font-weight: 700; background: #e2e8f0; color: #4a5568;">
                                    <i class="fas fa-circle" style="font-size: 5px;"></i> Đã kết thúc
                                </span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 3. Rewards & Disciplinary -->
        <div class="wh-card">
            <div class="wh-card-header">
                <div class="icon-box" style="background: rgba(128, 90, 213, 0.1); color: #805ad5;">
                    <i class="fas fa-award"></i>
                </div>
                <h3>Khen thưởng & Kỷ luật</h3>
            </div>

            <div class="wh-empty">
                <i class="fas fa-trophy"></i>
                <p>Chưa có dữ liệu khen thưởng hoặc kỷ luật</p>
            </div>
        </div>

    </div><!-- end .wh-content -->
</div><!-- end .wh-layout -->

<jsp:include page="footer.jsp" />

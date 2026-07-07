<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:choose>
    <c:when test="${currentUser.roleId == 6}">
        <c:set var="pageTitle" value="Bảng Điều Khiển Trưởng Phòng" scope="request"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageTitle" value="Bảng Điều Khiển Quản Lý" scope="request"/>
    </c:otherwise>
</c:choose>
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
footer, #chatWidget { display: none !important; }

body {
    background-color: #f1f5f9 !important;
    font-family: 'Inter', sans-serif !important;
    padding-top: 0 !important;
    min-height: 100vh;
    overflow-x: hidden;
}

/* ── Layout ── */
.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.dash-main { flex: 1; min-width: 0; background: #f1f5f9; }
.dash-content { padding: 28px 32px; display: flex; flex-direction: column; gap: 28px; }

/* ── Page Header ── */
.dash-page-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; }
.dash-page-header-left { display: flex; flex-direction: column; gap: 4px; }
.dash-breadcrumb { font-size: 0.78rem; color: #94a3b8; display: flex; align-items: center; gap: 6px; }
.dash-breadcrumb a { color: #0d9488; text-decoration: none; }
.dash-breadcrumb a:hover { text-decoration: underline; }
.dash-page-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; letter-spacing: -0.5px; }
.dash-role-badge {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 14px; border-radius: 20px;
    font-size: 0.8rem; font-weight: 700;
    background: linear-gradient(135deg, #0d9488, #0369a1);
    color: #fff; box-shadow: 0 2px 8px rgba(13,148,136,0.3);
}

/* ── Stat Cards ── */
.dash-stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; }
.dash-stat-card {
    background: #fff; border-radius: 16px; padding: 22px 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e2e8f0;
    display: flex; flex-direction: column; gap: 10px;
    transition: transform 0.2s, box-shadow 0.2s;
}
.dash-stat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
.dash-stat-header { display: flex; justify-content: space-between; align-items: flex-start; }
.dash-stat-title { font-size: 0.75rem; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.6px; }
.dash-stat-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1rem; }
.dash-stat-val { font-size: 2rem; font-weight: 800; color: #0f172a; line-height: 1.1; }
.dash-stat-change { font-size: 0.75rem; font-weight: 600; display: flex; align-items: center; gap: 4px; }
.dash-stat-change.up { color: #10b981; }
.dash-stat-change.down { color: #ef4444; }
.dash-stat-change.neutral { color: #94a3b8; }

.dash-stat-card.stat-warning { border-left: 4px solid #f59e0b; }
.dash-stat-card.stat-warning .dash-stat-icon { background: #fef3c7; color: #d97706; }
.dash-stat-card.stat-danger { border-left: 4px solid #ef4444; }
.dash-stat-card.stat-danger .dash-stat-icon { background: #fee2e2; color: #dc2626; }
.dash-stat-card.stat-success { border-left: 4px solid #10b981; }
.dash-stat-card.stat-success .dash-stat-icon { background: #d1fae5; color: #059669; }
.dash-stat-card.stat-teal { border-left: 4px solid #0d9488; }
.dash-stat-card.stat-teal .dash-stat-icon { background: #ccfbf1; color: #0d9488; }
.dash-stat-card.stat-blue { border-left: 4px solid #3b82f6; }
.dash-stat-card.stat-blue .dash-stat-icon { background: #dbeafe; color: #2563eb; }
.dash-stat-card.stat-purple { border-left: 4px solid #8b5cf6; }
.dash-stat-card.stat-purple .dash-stat-icon { background: #ede9fe; color: #7c3aed; }

/* ── Charts ── */
.dash-charts-grid { display: grid; grid-template-columns: 1.6fr 1fr; gap: 20px; }
@media (max-width: 1100px) { .dash-charts-grid { grid-template-columns: 1fr; } }

.dash-card {
    background: #fff; border-radius: 16px; padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e2e8f0;
}
.dash-card-header { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
.dash-card-title { font-size: 0.95rem; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 8px; }
.dash-card-title-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.dot-teal { background: #0d9488; } .dot-blue { background: #3b82f6; } .dot-orange { background: #f59e0b; }

/* ── Table ── */
.dash-table-container { width: 100%; overflow-x: auto; }
.dash-table { width: 100%; border-collapse: collapse; text-align: left; }
.dash-table th {
    padding: 12px 16px; border-bottom: 1px solid #e2e8f0;
    color: #64748b; font-size: 0.73rem; font-weight: 700;
    text-transform: uppercase; letter-spacing: 0.6px; background: #fafbfc;
}
.dash-table td { padding: 15px 16px; border-bottom: 1px solid #f1f5f9; color: #0f172a; font-size: 0.88rem; vertical-align: middle; }
.dash-table tbody tr:last-child td { border-bottom: none; }
.dash-table tbody tr:hover td { background: #f8fafc; }
.dash-btn {
    padding: 6px 14px; font-size: 0.8rem; font-weight: 700;
    border-radius: 8px; border: none; cursor: pointer;
    transition: all 0.2s; text-decoration: none; display: inline-block;
}
.dash-btn-primary { background: #0d9488; color: #fff; }
.dash-btn-primary:hover { background: #0f766e; }
.dash-btn-secondary { background: #f1f5f9; color: #475569; }
.dash-btn-secondary:hover { background: #e2e8f0; }

/* ── TuVV: Department Manager — Styles bổ sung ── */
.dept-section-divider {
    display: flex; align-items: center; gap: 12px;
    margin-top: 8px;
}
.dept-section-divider .divider-line { flex: 1; height: 2px; background: linear-gradient(90deg, #0d9488, transparent); }
.dept-section-title {
    font-size: 1.1rem; font-weight: 800; color: #0f172a;
    display: flex; align-items: center; gap: 8px;
    white-space: nowrap;
}
.dept-section-title i { color: #0d9488; font-size: 1rem; }

.kpi-progress-container {
    background: #fff; border-radius: 16px; padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #e2e8f0;
}
.kpi-progress-bar-wrapper {
    background: #e2e8f0; border-radius: 12px; height: 24px; overflow: hidden; margin: 16px 0 8px;
}
.kpi-progress-bar-fill {
    height: 100%; border-radius: 12px;
    background: linear-gradient(90deg, #0d9488, #06b6d4);
    transition: width 0.6s ease; display: flex; align-items: center; justify-content: center;
    font-size: 0.72rem; font-weight: 700; color: #fff; min-width: 30px;
}
.kpi-progress-stats {
    display: flex; justify-content: space-between; align-items: center;
    font-size: 0.82rem; color: #64748b; font-weight: 500;
}
.kpi-progress-stats strong { color: #0f172a; }

.kpi-deadline-badge {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 700;
}
.deadline-safe { background: #d1fae5; color: #059669; }
.deadline-warn { background: #fef3c7; color: #d97706; }
.deadline-danger { background: #fee2e2; color: #dc2626; }
.deadline-overdue { background: #fecaca; color: #991b1b; }

.dash-badge { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 20px; font-size: 0.73rem; font-weight: 700; }
.badge-draft { background: #f1f5f9; color: #64748b; }
.badge-submitted { background: #dbeafe; color: #2563eb; }
.badge-approved { background: #d1fae5; color: #059669; }

@media (max-width: 768px) { .dash-content { padding: 20px 16px; } }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <div class="dash-main">
        <div class="dash-content">

            <%-- ── Page Header — Badge hiển thị động theo role ── --%>
            <div class="dash-page-header">
                <div class="dash-page-header-left">
                    <div class="dash-breadcrumb">
                        <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                        <span>/</span>
                        <span>Dashboard</span>
                    </div>
                    <div class="dash-page-title">
                        Tổng Quan Hoạt Động
                    </div>
                </div>
                <div class="dash-role-badge">
                    <c:choose>
                        <c:when test="${currentUser.roleId == 6}">
                            <i class="fas fa-user-shield"></i> Trưởng Phòng
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-briefcase"></i> Quản lý
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <%-- ══════════════════════════════════════════════════════════════════ --%>
            <%-- ── Phần chung: Stat cards + Charts — hiển thị cho CẢ HAI role ── --%>
            <%-- ══════════════════════════════════════════════════════════════════ --%>

            <%-- ── FACTORY / DEPT MANAGER STATS ── --%>
            <div class="dash-stat-grid">
                <div class="dash-stat-card stat-teal">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Nhân Sự Quản Lý</span>
                        <div class="dash-stat-icon"><i class="fas fa-users-cog"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty totalEmployees ? totalEmployees : '—'}</div>
                    <div class="dash-stat-change up">Nhân viên / Công nhân</div>
                </div>
                <div class="dash-stat-card stat-success">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Chấm Công Hôm Nay</span>
                        <div class="dash-stat-icon"><i class="fas fa-user-clock"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty todayAttendance ? todayAttendance : '0'}</div>
                    <div class="dash-stat-change neutral">Đã điểm danh</div>
                </div>
                <div class="dash-stat-card stat-warning">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Yêu Cầu Làm Thêm (OT)</span>
                        <div class="dash-stat-icon"><i class="fas fa-business-time"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty pendingOT ? pendingOT : '0'}</div>
                    <div class="dash-stat-change down">Chờ phê duyệt</div>
                </div>
                <div class="dash-stat-card stat-danger">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Đơn Xin Nghỉ Phép</span>
                        <div class="dash-stat-icon"><i class="fas fa-calendar-times"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty pendingLeaves ? pendingLeaves : '0'}</div>
                    <div class="dash-stat-change neutral">Chờ duyệt</div>
                </div>
            </div>

            <%-- Manager Charts --%>
            <div class="dash-charts-grid">
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">Tỷ Lệ Điểm Danh 7 Ngày Qua</h3>
                    </div>
                    <div style="height:300px;"><canvas id="performanceChart"></canvas></div>
                </div>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3 class="dash-card-title">Phân Bổ Ca Làm Việc Hôm Nay</h3>
                    </div>
                    <div style="height:300px;"><canvas id="shiftChart"></canvas></div>
                </div>
            </div>

            <%-- ══════════════════════════════════════════════════════════════════════ --%>
            <%-- ── TuVV: DEPARTMENT MANAGER (roleId == 6): Điều chuyển + KPI ──────── --%>
            <%-- ══════════════════════════════════════════════════════════════════════ --%>
            <c:if test="${currentUser.roleId == 6}">

            <%-- Section divider --%>
            <div class="dept-section-divider">
                <div class="dept-section-title">
                    <i class="fas fa-tasks"></i> Công Việc Cần Xử Lý Của Trưởng Phòng
                </div>
                <div class="divider-line"></div>
            </div>

            <%-- ── Dept Manager: Stat Cards ── --%>
            <div class="dash-stat-grid">
                <div class="dash-stat-card stat-purple">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Điều Chuyển Chờ Duyệt</span>
                        <div class="dash-stat-icon"><i class="fas fa-exchange-alt"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty pendingTransferCount ? pendingTransferCount : '0'}</div>
                    <div class="dash-stat-change neutral"><i class="fas fa-user-check"></i> NV đã xác nhận, chờ TP xử lý</div>
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals" class="dash-btn dash-btn-secondary" style="margin-top:4px; text-align:center;">Xem & duyệt</a>
                </div>
                <div class="dash-stat-card stat-blue">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Điều Chuyển Sắp Hiệu Lực</span>
                        <div class="dash-stat-icon"><i class="fas fa-calendar-check"></i></div>
                    </div>
                    <div class="dash-stat-val">${not empty upcomingTransferCount ? upcomingTransferCount : '0'}</div>
                    <div class="dash-stat-change neutral"><i class="fas fa-clock"></i> Trong 7 ngày tới</div>
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals" class="dash-btn dash-btn-secondary" style="margin-top:4px; text-align:center;">Xem chi tiết</a>
                </div>
                <div class="dash-stat-card <c:choose><c:when test='${activeKpiCycle == null}'>stat-teal</c:when><c:when test='${kpiDaysLeft < 0}'>stat-danger</c:when><c:when test='${kpiDaysLeft <= 2}'>stat-danger</c:when><c:when test='${kpiDaysLeft <= 7}'>stat-warning</c:when><c:otherwise>stat-success</c:otherwise></c:choose>">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">Hạn Đánh Giá KPI</span>
                        <div class="dash-stat-icon"><i class="fas fa-chart-line"></i></div>
                    </div>
                    <c:choose>
                        <c:when test="${activeKpiCycle != null}">
                            <div class="dash-stat-val">
                                <fmt:formatDate value="${activeKpiCycle.deadline}" pattern="dd/MM"/>
                            </div>
                            <div class="dash-stat-change <c:choose><c:when test='${kpiDaysLeft < 0}'>down</c:when><c:when test='${kpiDaysLeft <= 7}'>down</c:when><c:otherwise>up</c:otherwise></c:choose>">
                                <c:choose>
                                    <c:when test="${kpiDaysLeft < 0}">
                                        <i class="fas fa-exclamation-circle"></i> Quá hạn ${-kpiDaysLeft} ngày
                                    </c:when>
                                    <c:when test="${kpiDaysLeft == 0}">
                                        <i class="fas fa-bell"></i> Hôm nay là hạn cuối!
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fas fa-hourglass-half"></i> Còn ${kpiDaysLeft} ngày
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="dash-stat-val" style="font-size:1rem;">—</div>
                            <div class="dash-stat-change neutral">Chưa có kỳ KPI đang mở</div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="dash-stat-card stat-warning">
                    <div class="dash-stat-header">
                        <span class="dash-stat-title">KPI Chưa Đánh Giá</span>
                        <div class="dash-stat-icon"><i class="fas fa-clipboard-list"></i></div>
                    </div>
                    <c:choose>
                        <c:when test="${activeKpiCycle != null}">
                            <div class="dash-stat-val">${kpiPendingCount}/${kpiTotalCount}</div>
                            <div class="dash-stat-change <c:choose><c:when test='${kpiPendingCount > 0}'>down</c:when><c:otherwise>up</c:otherwise></c:choose>">
                                <c:choose>
                                    <c:when test="${kpiPendingCount > 0}">
                                        <i class="fas fa-user-clock"></i> ${kpiPendingCount} nhân viên chưa đánh giá
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fas fa-check-double"></i> Đã hoàn thành tất cả
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <a href="${pageContext.request.contextPath}/manager/kpi-approvals" class="dash-btn dash-btn-secondary" style="margin-top:4px; text-align:center;">Đánh giá KPI</a>
                        </c:when>
                        <c:otherwise>
                            <div class="dash-stat-val" style="font-size:1rem;">—</div>
                            <div class="dash-stat-change neutral">Chưa có dữ liệu KPI đang mở</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <%-- ── Dept Manager: Thanh tiến độ KPI ── --%>
            <div class="kpi-progress-container">
                <div class="dash-card-header" style="margin-bottom:8px;">
                    <h3 class="dash-card-title">
                        <div class="dash-card-title-dot dot-teal"></div>
                        Tiến Độ Đánh Giá KPI Tháng Hiện Tại
                    </h3>
                    <c:if test="${activeKpiCycle != null}">
                        <span class="kpi-deadline-badge <c:choose><c:when test='${kpiDaysLeft < 0}'>deadline-overdue</c:when><c:when test='${kpiDaysLeft <= 2}'>deadline-danger</c:when><c:when test='${kpiDaysLeft <= 7}'>deadline-warn</c:when><c:otherwise>deadline-safe</c:otherwise></c:choose>">
                            <i class="fas fa-calendar-alt"></i> ${activeKpiCycle.name}
                        </span>
                    </c:if>
                </div>
                <c:choose>
                    <c:when test="${activeKpiCycle != null && kpiTotalCount > 0}">
                        <div class="kpi-progress-bar-wrapper">
                            <div class="kpi-progress-bar-fill" style="width: ${kpiProgressPercent}%;">
                                ${kpiProgressPercent}%
                            </div>
                        </div>
                        <div class="kpi-progress-stats">
                            <span><strong>${kpiCompletedCount}</strong> / ${kpiTotalCount} đã hoàn thành</span>
                            <span><strong>${kpiPendingCount}</strong> còn chưa đánh giá</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align:center; padding:24px; color:#94a3b8;">
                            <i class="fas fa-chart-pie" style="font-size:2rem; margin-bottom:8px; display:block; opacity:0.5;"></i>
                            Chưa có dữ liệu KPI đang mở
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- ── Dept Manager: Bảng nhân viên cần đánh giá KPI ── --%>
            <div class="dash-card">
                <div class="dash-card-header">
                    <h3 class="dash-card-title">
                        <div class="dash-card-title-dot dot-orange"></div>
                        Nhân Viên Cần Đánh Giá KPI
                    </h3>
                    <c:if test="${activeKpiCycle != null}">
                        <a href="${pageContext.request.contextPath}/manager/kpi-approvals?cycleId=${activeKpiCycle.cycleId}" class="dash-btn dash-btn-secondary">Xem tất cả</a>
                    </c:if>
                </div>
                <div class="dash-table-container">
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>Nhân viên</th>
                                <th>Phòng ban</th>
                                <th>Trạng thái</th>
                                <th>Hạn đánh giá</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty pendingKpiEvaluations}">
                                    <c:forEach items="${pendingKpiEvaluations}" var="eval">
                                        <tr>
                                            <td style="font-weight:600;">${eval.employeeName}</td>
                                            <td style="color:#64748b;">${not empty eval.departmentName ? eval.departmentName : '—'}</td>
                                            <td>
                                                <span class="dash-badge badge-draft">
                                                    <i class="fas fa-edit"></i> ${eval.status}
                                                </span>
                                            </td>
                                            <td>
                                                <c:if test="${activeKpiCycle != null}">
                                                    <fmt:formatDate value="${activeKpiCycle.deadline}" pattern="dd/MM/yyyy"/>
                                                </c:if>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/manager/kpi-approvals?cycleId=${eval.cycleId}&viewId=${eval.evaluationId}" class="dash-btn dash-btn-primary">Đánh giá</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" style="text-align:center; color:#94a3b8; padding:30px;">
                                            <i class="fas fa-check-double" style="font-size:1.5rem; margin-bottom:8px; display:block;"></i>
                                            <c:choose>
                                                <c:when test="${activeKpiCycle == null}">Chưa có kỳ KPI đang mở</c:when>
                                                <c:otherwise>Đã đánh giá tất cả nhân viên!</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            </c:if><%-- end roleId == 6 --%>

        </div><%-- end dash-content --%>
    </div><%-- end dash-main --%>
</div><%-- end dashboard-wrapper --%>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    const perfLabels = [
        <c:forEach var="lbl" items="${perfLabels}" varStatus="status">
            '${lbl}'${not status.last ? ',' : ''}
        </c:forEach>
    ];
    const perfTarget = [
        <c:forEach var="tgt" items="${perfTarget}" varStatus="status">
            ${tgt}${not status.last ? ',' : ''}
        </c:forEach>
    ];
    const perfActual = [
        <c:forEach var="act" items="${perfActual}" varStatus="status">
            ${act}${not status.last ? ',' : ''}
        </c:forEach>
    ];

    const shiftLabels = [
        <c:forEach var="lbl" items="${shiftLabels}" varStatus="status">
            '${lbl}'${not status.last ? ',' : ''}
        </c:forEach>
    ];
    const shiftData = [
        <c:forEach var="val" items="${shiftData}" varStatus="status">
            ${val}${not status.last ? ',' : ''}
        </c:forEach>
    ];

    new Chart(document.getElementById('performanceChart').getContext('2d'), {
        type: 'bar',
        data: {
            labels: perfLabels,
            datasets: [
                { label:'Mục tiêu (Tổng nhân sự)', data: perfTarget, backgroundColor:'rgba(148,163,184,0.3)', borderRadius:4 },
                { label:'Thực tế (Có mặt)', data: perfActual, backgroundColor:'#0d9488', borderRadius:4 }
            ]
        },
        options: { 
            responsive:true, 
            maintainAspectRatio:false,
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        precision: 0
                    }
                }
            }
        }
    });

    new Chart(document.getElementById('shiftChart').getContext('2d'), {
        type: 'pie',
        data: {
            labels: shiftLabels,
            datasets: [{ 
                data: shiftData, 
                backgroundColor: ['#10b981','#f59e0b','#6366f1','#dd6b20','#3b82f6','#ec4899','#6b7280'], 
                borderWidth:2 
            }]
        },
        options: { responsive:true, maintainAspectRatio:false, plugins:{ legend:{ position:'right' } } }
    });
});
</script>

<jsp:include page="../footer.jsp" />

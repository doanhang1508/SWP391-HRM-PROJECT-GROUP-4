<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Khóa Bảng Chấm Công - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root {
        --pri: #6366f1; --ok: #10b981; --ng: #ef4444;
        --warn: #f59e0b; --bg: #f4f7fe; --card: #fff; --txt: #1e293b; --muted: #64748b;
    }
    body { background: var(--bg); font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 30px; }
    .page-title { font-size: 1.5rem; font-weight: 700; color: var(--txt); margin: 0 0 4px; }
    .breadcrumb-c { font-size: .85rem; color: var(--muted); }
    .breadcrumb-c a { color: var(--pri); text-decoration: none; }

    /* Current month summary card */
    .summary-card {
        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        border-radius: 16px; padding: 28px; margin-bottom: 24px;
        display: flex; justify-content: space-between; align-items: center; gap: 20px;
        flex-wrap: wrap;
    }
    .summary-info h3 { font-size: 1rem; font-weight: 600; color: #94a3b8; margin: 0 0 6px; }
    .summary-info h2 { font-size: 1.8rem; font-weight: 800; color: #fff; margin: 0 0 4px; }
    .summary-info p { font-size: .85rem; color: #64748b; margin: 0; }
    .summary-stat {
        text-align: center; padding: 16px 24px; background: rgba(255,255,255,.05);
        border-radius: 12px; border: 1px solid rgba(255,255,255,.08);
    }
    .summary-stat h4 { font-size: 2rem; font-weight: 800; color: #fff; margin: 0 0 4px; }
    .summary-stat span { font-size: .78rem; color: #64748b; font-weight: 600; text-transform: uppercase; }

    /* Lock form */
    .panel {
        background: var(--card); border-radius: 16px; padding: 24px;
        box-shadow: 0 4px 20px rgba(0,0,0,.04); border: 1px solid rgba(0,0,0,.05); margin-bottom: 24px;
    }
    .panel-title { font-size: 1rem; font-weight: 700; color: var(--txt); margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
    .panel-title i { color: var(--pri); }
    .form-row { display: flex; gap: 14px; align-items: flex-end; flex-wrap: wrap; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-group label { font-size: .82rem; font-weight: 600; color: var(--muted); }
    .form-group select, .form-group input[type="text"] {
        border: 1.5px solid #e2e8f0; border-radius: 8px; padding: 8px 12px;
        font-size: .88rem; font-family: 'Inter', sans-serif; color: var(--txt); outline: none;
    }
    .form-group select:focus, .form-group input:focus { border-color: var(--pri); }

    .btn-lock {
        background: #0f172a; color: #fff; border: none; border-radius: 9px;
        padding: 10px 22px; font-weight: 700; font-size: .88rem; cursor: pointer;
        display: inline-flex; align-items: center; gap: 8px; transition: all .2s;
    }
    .btn-lock:hover { background: #1e293b; transform: translateY(-1px); }

    /* Alerts */
    .alert {
        padding: 14px 18px; border-radius: 10px; margin-bottom: 20px;
        display: flex; align-items: center; gap: 10px; font-size: .88rem; font-weight: 500;
    }
    .alert-success { background: rgba(16,185,129,.1); color: #065f46; border: 1px solid #a7f3d0; }
    .alert-error { background: rgba(239,68,68,.1); color: #991b1b; border: 1px solid #fecaca; }
    .alert-warn { background: rgba(245,158,11,.1); color: #92400e; border: 1px solid #fde68a; }

    /* Lock history table */
    table { width: 100%; border-collapse: collapse; }
    thead th {
        background: #f8fafc; padding: 11px 16px; text-align: left;
        font-size: .76rem; font-weight: 700; color: var(--muted);
        text-transform: uppercase; border-bottom: 1px solid #e2e8f0;
    }
    tbody td {
        padding: 13px 16px; font-size: .87rem; color: var(--txt);
        border-bottom: 1px solid #f8fafc; vertical-align: middle;
    }
    tbody tr:hover td { background: #fafbff; }

    .badge-locked { background: rgba(239,68,68,.1); color: #991b1b; }
    .badge-unlocked { background: rgba(16,185,129,.1); color: #065f46; }
    .badge {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 4px 10px; border-radius: 20px; font-size: .74rem; font-weight: 700;
    }
    .btn-unlock {
        color: var(--pri); font-size: .8rem; font-weight: 600; background: none;
        border: 1px solid #c7d2fe; border-radius: 7px; padding: 4px 12px; cursor: pointer;
        transition: all .2s;
    }
    .btn-unlock:hover { background: var(--pri); color: #fff; }
    .empty-state { text-align: center; padding: 50px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 14px; color: #cbd5e1; display: block; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="timesheet-lock"/>
    </jsp:include>

    <div class="main-content">
        <div style="margin-bottom:24px">
            <h1 class="page-title"><i class="fas fa-lock" style="color:var(--pri);margin-right:10px"></i>Khóa Bảng Chấm Công</h1>
            <div class="breadcrumb-c"><a href="${pageContext.request.contextPath}/hr/dashboard">Dashboard</a> / Khóa chấm công</div>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <!-- Current month summary -->
        <div class="summary-card">
            <div class="summary-info">
                <h3>Tháng hiện tại</h3>
                <h2>Tháng ${currentMonth}/${currentYear}</h2>
                <p>
                    <c:choose>
                        <c:when test="${isCurrentLocked}">
                            <span style="color:#f87171"><i class="fas fa-lock"></i> Đã khóa — không thể import hoặc chỉnh sửa</span>
                        </c:when>
                        <c:otherwise>
                            <span style="color:#4ade80"><i class="fas fa-lock-open"></i> Đang mở — có thể import và chỉnh sửa</span>
                        </c:otherwise>
                    </c:choose>
                </p>
            </div>
            <div class="summary-stat">
                <h4>${currentRecordCount}</h4>
                <span>Bản ghi chấm công</span>
            </div>
        </div>

        <div class="alert alert-warn">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Sau khi khóa, dữ liệu chấm công sẽ <strong>không thể import hoặc chỉnh sửa</strong>. Chỉ Admin mới có thể mở khóa.</span>
        </div>

        <!-- Lock form -->
        <div class="panel">
            <div class="panel-title"><i class="fas fa-calendar-check"></i> Khóa Tháng Mới</div>
            <form method="post" action="${pageContext.request.contextPath}/hr/timesheet-lock"
                  onsubmit="return confirm('Bạn chắc chắn muốn khóa tháng này? Hành động này không thể hoàn tác (chỉ Admin mở được).')">
                <input type="hidden" name="action" value="lock">
                <div class="form-row">
                    <div class="form-group">
                        <label>Tháng</label>
                        <select name="month" required>
                            <c:forEach begin="1" end="12" var="m">
                                <option value="${m}" ${m == currentMonth ? 'selected' : ''}>Tháng ${m}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Năm</label>
                        <select name="year" required>
                            <option value="2026">2026</option>
                            <option value="2025">2025</option>
                            <option value="2024">2024</option>
                        </select>
                    </div>
                    <div class="form-group" style="flex:1;min-width:200px">
                        <label>Ghi chú (tuỳ chọn)</label>
                        <input type="text" name="note" placeholder="Ví dụ: Chốt lương tháng 6/2026">
                    </div>
                    <button type="submit" class="btn-lock">
                        <i class="fas fa-lock"></i> Khóa Tháng
                    </button>
                </div>
            </form>
        </div>

        <!-- Lock history -->
        <div class="panel">
            <div class="panel-title"><i class="fas fa-history"></i> Lịch Sử Khóa</div>
            <c:choose>
                <c:when test="${empty locks}">
                    <div class="empty-state">
                        <i class="fas fa-lock-open"></i>
                        <p style="margin:0;font-weight:600">Chưa có tháng nào được khóa</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Tháng/Năm</th><th>Trạng thái</th><th>Khóa bởi</th>
                                <th>Thời gian khóa</th><th>Ghi chú</th>
                                <c:if test="${sessionScope.currentUser.roleId == 1}"><th>Thao tác</th></c:if>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${locks}" var="lk">
                            <tr>
                                <td style="font-weight:700;font-size:1rem">
                                    Tháng ${lk.month}/${lk.year}
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${lk.status == 'LOCKED'}">
                                            <span class="badge badge-locked"><i class="fas fa-lock"></i> Đã khóa</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-unlocked"><i class="fas fa-lock-open"></i> Đã mở</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="font-weight:600">${lk.lockedByName}</td>
                                <td style="font-size:.82rem;color:var(--muted)">
                                    <fmt:formatDate value="${lk.lockedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </td>
                                <td style="font-size:.82rem;color:var(--muted)">${lk.note}</td>
                                <c:if test="${sessionScope.currentUser.roleId == 1}">
                                    <td>
                                        <c:if test="${lk.status == 'LOCKED'}">
                                            <form method="post" action="${pageContext.request.contextPath}/hr/timesheet-lock"
                                                  onsubmit="return confirm('Mở khóa tháng ${lk.month}/${lk.year}?')" style="display:inline">
                                                <input type="hidden" name="action" value="unlock">
                                                <input type="hidden" name="month" value="${lk.month}">
                                                <input type="hidden" name="year" value="${lk.year}">
                                                <button type="submit" class="btn-unlock">
                                                    <i class="fas fa-unlock"></i> Mở khóa
                                                </button>
                                            </form>
                                        </c:if>
                                    </td>
                                </c:if>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

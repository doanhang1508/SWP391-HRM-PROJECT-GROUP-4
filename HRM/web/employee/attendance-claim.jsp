<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Khiếu Nại Chấm Công - Enterprise HRM" scope="request" />
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
    .main-content { flex: 1; padding: 30px; max-width: 900px; }
    .page-title { font-size: 1.5rem; font-weight: 700; color: var(--txt); margin: 0 0 4px; }
    .breadcrumb-c { font-size: .85rem; color: var(--muted); }
    .breadcrumb-c a { color: var(--pri); text-decoration: none; }

    .panel {
        background: var(--card); border-radius: 16px; padding: 28px;
        box-shadow: 0 4px 20px rgba(0,0,0,.04); border: 1px solid rgba(0,0,0,.05); margin-bottom: 24px;
    }
    .panel-title { font-size: 1rem; font-weight: 700; color: var(--txt); margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
    .panel-title i { color: var(--pri); }

    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-group.full { grid-column: 1/-1; }
    .form-group label { font-size: .82rem; font-weight: 600; color: var(--muted); }
    .form-group input, .form-group select, .form-group textarea {
        border: 1.5px solid #e2e8f0; border-radius: 8px; padding: 9px 12px;
        font-size: .88rem; font-family: 'Inter', sans-serif; color: var(--txt);
        outline: none; transition: border-color .2s;
    }
    .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: var(--pri); }
    .form-group textarea { resize: vertical; min-height: 90px; }
    .char-count { font-size: .75rem; color: var(--muted); text-align: right; margin-top: 2px; }

    .btn-submit {
        background: var(--pri); color: #fff; border: none; border-radius: 10px;
        padding: 11px 24px; font-weight: 600; font-size: .9rem;
        display: inline-flex; align-items: center; gap: 8px; cursor: pointer; transition: all .2s;
    }
    .btn-submit:hover { background: #4f46e5; transform: translateY(-1px); }

    .alert {
        padding: 14px 18px; border-radius: 10px; margin-bottom: 20px;
        display: flex; align-items: center; gap: 10px; font-size: .88rem; font-weight: 500;
    }
    .alert-success { background: rgba(16,185,129,.1); color: #065f46; border: 1px solid #a7f3d0; }
    .alert-error { background: rgba(239,68,68,.1); color: #991b1b; border: 1px solid #fecaca; }

    /* History table */
    table { width: 100%; border-collapse: collapse; }
    thead th {
        background: #f8fafc; padding: 11px 16px; text-align: left;
        font-size: .78rem; font-weight: 700; color: var(--muted);
        text-transform: uppercase; border-bottom: 1px solid #e2e8f0;
    }
    tbody td {
        padding: 12px 16px; font-size: .87rem; color: var(--txt);
        border-bottom: 1px solid #f8fafc; vertical-align: middle;
    }
    tbody tr:hover td { background: #fafbff; }
    .badge {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 3px 10px; border-radius: 20px; font-size: .74rem; font-weight: 700;
    }
    .badge-pending { background: rgba(245,158,11,.1); color: #92400e; }
    .badge-approved { background: rgba(16,185,129,.1); color: #065f46; }
    .badge-rejected { background: rgba(239,68,68,.1); color: #991b1b; }
    .empty-state { text-align: center; padding: 40px; color: var(--muted); }
    .empty-state i { font-size: 2.5rem; margin-bottom: 10px; color: #cbd5e1; display: block; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="attendance-claim"/>
    </jsp:include>

    <div class="main-content">
        <div style="margin-bottom:24px">
            <h1 class="page-title"><i class="fas fa-flag" style="color:var(--pri);margin-right:10px"></i>Khiếu Nại Chấm Công</h1>
            <div class="breadcrumb-c">
                <a href="${pageContext.request.contextPath}/employee/dashboard">Dashboard</a> /
                <a href="${pageContext.request.contextPath}/employee/attendance">Chấm công</a> / Khiếu nại
            </div>
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

        <!-- Submit Claim Form -->
        <div class="panel">
            <div class="panel-title"><i class="fas fa-paper-plane"></i> Gửi Đơn Khiếu Nại</div>

            <form method="post" action="${pageContext.request.contextPath}/employee/attendance-claim">
                <input type="hidden" name="action" value="submit">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Mã bản ghi chấm công (Attendance ID) *</label>
                        <input type="number" name="attendanceId" required min="1"
                               value="${prefillAttendanceId}" placeholder="Nhập ID từ bảng chấm công">
                    </div>
                    <div class="form-group">
                        <label>Ngày làm việc *</label>
                        <input type="date" name="workDate" required value="${prefillWorkDate}">
                    </div>
                    <div class="form-group">
                        <label>Loại khiếu nại *</label>
                        <select name="claimType" required>
                            <option value="">-- Chọn loại --</option>
                            <option value="MISSING">Thiếu dữ liệu chấm công</option>
                            <option value="WRONG_STATUS">Trạng thái không đúng</option>
                            <option value="WRONG_TIME">Giờ vào/ra không đúng</option>
                            <option value="OTHER">Khác</option>
                        </select>
                    </div>
                    <div class="form-group full">
                        <label>Mô tả chi tiết * (10–500 ký tự)</label>
                        <textarea name="description" maxlength="500" id="descField"
                                  placeholder="Mô tả rõ vấn đề, ví dụ: Ngày 01/06 tôi có mặt đúng giờ 08:00 nhưng hệ thống ghi ABSENT..."
                                  oninput="document.getElementById('charCount').textContent=this.value.length + '/500'"></textarea>
                        <div class="char-count"><span id="charCount">0/500</span></div>
                    </div>
                </div>
                <button type="submit" class="btn-submit" style="margin-top:8px">
                    <i class="fas fa-paper-plane"></i> Gửi Khiếu Nại
                </button>
            </form>
        </div>

        <!-- History -->
        <div class="panel">
            <div class="panel-title"><i class="fas fa-history"></i> Lịch Sử Khiếu Nại</div>
            <c:choose>
                <c:when test="${empty myClaims}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <p style="margin:0;font-weight:600">Chưa có đơn khiếu nại nào</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Ngày</th><th>Ca</th><th>Loại</th><th>Mô tả</th>
                                <th>Trạng thái</th><th>Ghi chú HR</th><th>Ngày gửi</th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${myClaims}" var="c">
                            <tr>
                                <td style="font-weight:600"><fmt:formatDate value="${c.workDate}" pattern="dd/MM/yyyy"/></td>
                                <td>${c.shiftName}</td>
                                <td style="font-size:.8rem">
                                    <c:choose>
                                        <c:when test="${c.claimType == 'MISSING'}">Thiếu dữ liệu</c:when>
                                        <c:when test="${c.claimType == 'WRONG_STATUS'}">Sai trạng thái</c:when>
                                        <c:when test="${c.claimType == 'WRONG_TIME'}">Sai giờ</c:when>
                                        <c:otherwise>Khác</c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="max-width:200px;font-size:.82rem;color:var(--muted)">${c.description}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${c.status == 'PENDING'}"><span class="badge badge-pending"><i class="fas fa-hourglass-half"></i> Chờ xử lý</span></c:when>
                                        <c:when test="${c.status == 'APPROVED'}"><span class="badge badge-approved"><i class="fas fa-check"></i> Đã duyệt</span></c:when>
                                        <c:when test="${c.status == 'REJECTED'}"><span class="badge badge-rejected"><i class="fas fa-times"></i> Từ chối</span></c:when>
                                    </c:choose>
                                </td>
                                <td style="font-size:.82rem;color:var(--muted)">${c.hrNote}</td>
                                <td style="font-size:.8rem;color:var(--muted)">
                                    <fmt:formatDate value="${c.createdAt}" pattern="dd/MM HH:mm"/>
                                </td>
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

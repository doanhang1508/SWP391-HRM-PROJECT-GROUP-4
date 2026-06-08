<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Đơn nghỉ phép / OT - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    /* ── Layout wrapper ── */
    .emp-layout {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .emp-content {
        flex: 1;
        padding: 30px;
        overflow-y: auto;
    }

    /* ── Page Header ── */
    .page-banner {
        background: linear-gradient(135deg, #0a2540 0%, #1a3a6b 100%);
        color: white;
        border-radius: 14px;
        padding: 24px 32px;
        margin-bottom: 24px;
        position: relative;
        overflow: hidden;
    }
    .page-banner::after {
        content: '';
        position: absolute;
        top: -60px; right: -60px;
        width: 220px; height: 220px;
        background: rgba(255,255,255,0.04);
        border-radius: 50%;
        pointer-events: none;
    }
    .page-banner h2 { font-size: 1.4rem; font-weight: 700; margin: 0 0 6px; }
    .page-banner p  { margin: 0; opacity: 0.72; font-size: 0.9rem; }

    /* ── Cards ── */
    .leave-card {
        background: var(--th-surface, #ffffff);
        border: 1px solid var(--th-border, #e2e8f0);
        border-radius: 14px;
        box-shadow: var(--th-card-shadow, 0 2px 8px rgba(0,0,0,0.06));
        transition: box-shadow 0.2s;
        overflow: hidden;
        height: 100%;
    }
    .leave-card:hover { box-shadow: 0 6px 18px rgba(0,0,0,0.07); }

    .leave-card-header {
        padding: 18px 22px;
        font-weight: 700;
        font-size: 1rem;
        display: flex;
        align-items: center;
        gap: 10px;
        color: #fff;
    }
    .leave-card-header.bg-leave { background: linear-gradient(135deg, #2b6cb0, #4299e1); }
    .leave-card-header.bg-ot    { background: linear-gradient(135deg, #276749, #48bb78); }

    .leave-card-body {
        padding: 22px;
    }

    /* ── Info Badge ── */
    .info-badge {
        display: flex;
        align-items: center;
        gap: 10px;
        background: rgba(49, 130, 206, 0.08);
        border: 1px solid rgba(49, 130, 206, 0.15);
        border-radius: 10px;
        padding: 12px 16px;
        margin-bottom: 20px;
        color: var(--th-text, #1a202c);
    }
    .info-badge i { color: #3182ce; font-size: 1.2rem; }
    .info-badge strong { font-size: 1.1rem; color: #2b6cb0; }

    /* ── Form styling ── */
    .leave-form .form-label {
        font-weight: 600;
        font-size: 0.85rem;
        color: var(--th-text2, #2d3748);
        text-transform: uppercase;
        letter-spacing: 0.03em;
    }
    .leave-form .form-control,
    .leave-form .form-select {
        border-radius: 8px;
        border: 1.5px solid var(--th-input-border, #e2e8f0);
        background: var(--th-input-bg, #f8fafc);
        padding: 10px 14px;
        font-size: 0.9rem;
        transition: border-color 0.2s, box-shadow 0.2s;
        color: var(--th-text, #1a202c);
    }
    .leave-form .form-control:focus,
    .leave-form .form-select:focus {
        border-color: #3182ce;
        box-shadow: 0 0 0 3px rgba(49, 130, 206, 0.12);
    }

    .btn-submit-leave {
        background: linear-gradient(135deg, #2b6cb0, #4299e1);
        color: #fff;
        border: none;
        border-radius: 10px;
        padding: 12px;
        font-weight: 700;
        font-size: 0.95rem;
        width: 100%;
        cursor: pointer;
        transition: transform 0.15s, box-shadow 0.2s;
    }
    .btn-submit-leave:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(43, 108, 176, 0.3);
    }

    .btn-submit-ot {
        background: linear-gradient(135deg, #276749, #48bb78);
        color: #fff;
        border: none;
        border-radius: 10px;
        padding: 12px;
        font-weight: 700;
        font-size: 0.95rem;
        width: 100%;
        cursor: pointer;
        transition: transform 0.15s, box-shadow 0.2s;
    }
    .btn-submit-ot:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(39, 103, 73, 0.3);
    }

    /* ── History Tabs ── */
    .history-section {
        background: var(--th-surface, #ffffff);
        border: 1px solid var(--th-border, #e2e8f0);
        border-radius: 14px;
        box-shadow: var(--th-card-shadow, 0 2px 8px rgba(0,0,0,0.06));
        overflow: hidden;
        margin-top: 24px;
    }
    .history-section .nav-tabs {
        border-bottom: 2px solid var(--th-border, #e2e8f0);
        padding: 0 22px;
        background: var(--th-surface2, #f8fafc);
    }
    .history-section .nav-tabs .nav-link {
        border: none;
        font-weight: 600;
        font-size: 0.88rem;
        color: var(--th-muted, #718096);
        padding: 14px 20px;
        border-bottom: 2px solid transparent;
        margin-bottom: -2px;
        transition: all 0.2s;
    }
    .history-section .nav-tabs .nav-link.active {
        color: #3182ce;
        border-bottom-color: #3182ce;
        background: transparent;
    }
    .history-section .tab-content { padding: 22px; }

    .table th {
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        color: var(--th-muted, #718096);
        font-weight: 700;
        border-bottom-width: 2px;
    }
    .table td {
        font-size: 0.88rem;
        color: var(--th-text2, #2d3748);
        vertical-align: middle;
    }

    /* ── Responsive ── */
    @media (max-width: 991px) {
        .emp-layout { flex-direction: column; }
        .emp-content { padding: 20px; }
    }
</style>

<div class="emp-layout">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="leave" />
    </jsp:include>

    <!-- Main Content -->
    <div class="emp-content">

        <!-- Page Banner -->
        <div class="page-banner">
            <h2><i class="fas fa-paper-plane me-2"></i>Đơn nghỉ phép</h2>
            <p>Gửi yêu cầu nghỉ phép. Theo dõi lịch sử và trạng thái xử lý.</p>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show" style="border-radius:10px;">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" style="border-radius:10px;">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <!-- Row: Leave Form -->
        <div class="row g-4 justify-content-center">
            <!-- LEAVE REQUEST -->
            <div class="col-lg-8">
                <div class="leave-card">
                    <div class="leave-card-header bg-leave">
                        <i class="fas fa-umbrella-beach"></i> Gửi đơn nghỉ phép
                    </div>
                    <div class="leave-card-body">
                        <div class="info-badge" id="annualLeaveBadge">
                            <i class="fas fa-info-circle"></i>
                            <div>
                                Phép còn lại: <strong id="dynamicBalanceText">...</strong>
                            </div>
                        </div>
                        <form action="${pageContext.request.contextPath}/employee/leave" method="POST" class="leave-form">
                            <input type="hidden" name="action" value="submitLeave">

                            <div class="mb-3">
                                <label for="leaveTypeId" class="form-label">Loại nghỉ phép</label>
                                <select class="form-select" id="leaveTypeId" name="leaveTypeId" required>
                                    <option value="" disabled selected>-- Chọn loại nghỉ phép --</option>
                                    <c:forEach var="lType" items="${leaveTypes}">
                                        <c:choose>
                                            <c:when test="${lType.paidLeave == 1}">
                                                <option value="${lType.leaveTypeId}">${lType.typeName} (Có lương)</option>
                                            </c:when>
                                            <c:otherwise>
                                                <option value="${lType.leaveTypeId}">${lType.typeName} (Không lương)</option>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="startDate" class="form-label">Ngày bắt đầu</label>
                                    <input type="date" class="form-control" id="startDate" name="startDate" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="endDate" class="form-label">Ngày kết thúc</label>
                                    <input type="date" class="form-control" id="endDate" name="endDate" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="totalDays" class="form-label">Tổng số ngày</label>
                                <input type="number" step="0.5" class="form-control" id="totalDays" name="totalDays" required placeholder="Ví dụ: 1.5">
                            </div>

                            <div class="mb-3">
                                <label for="reason" class="form-label">Lý do</label>
                                <textarea class="form-control" id="reason" name="reason" rows="3" required placeholder="Nhập lý do nghỉ phép..."></textarea>
                            </div>

                            <button type="submit" class="btn-submit-leave">
                                <i class="fas fa-paper-plane me-2"></i>Gửi đơn nghỉ phép
                            </button>
                        </form>
                    </div>
                </div>
            </div>



        <!-- History Section -->
        <div class="history-section">
            <ul class="nav nav-tabs" id="historyTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="leave-tab" data-bs-toggle="tab" data-bs-target="#leaveHistory" type="button" role="tab">
                        <i class="fas fa-umbrella-beach me-1"></i>Lịch sử nghỉ phép
                    </button>
                </li>
            </ul>

            <div class="tab-content" id="historyTabsContent">
                <!-- Leave History -->
                <div class="tab-pane fade show active" id="leaveHistory" role="tabpanel">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Loại</th>
                                    <th>Ngày bắt đầu</th>
                                    <th>Ngày kết thúc</th>
                                    <th>Số ngày</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="lr" items="${leaveHistory}">
                                    <tr>
                                        <td>${lr.leaveTypeName}</td>
                                        <td>${lr.startDate}</td>
                                        <td>${lr.endDate}</td>
                                        <td>${lr.totalDays}</td>
                                        <td>${lr.reason}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${lr.status == 'Approved'}">
                                                    <span class="badge bg-success" style="border-radius:6px;padding:5px 10px;">${lr.status}</span>
                                                </c:when>
                                                <c:when test="${lr.status == 'Rejected'}">
                                                    <span class="badge bg-danger" style="border-radius:6px;padding:5px 10px;">${lr.status}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning text-dark" style="border-radius:6px;padding:5px 10px;">${lr.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty leaveHistory}">
                                    <tr><td colspan="6" class="text-center text-muted py-4"><i class="fas fa-inbox me-2"></i>Chưa có đơn nghỉ phép nào.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
        </div>

    </div><!-- end .emp-content -->
</div><!-- end .emp-layout -->

<script>
// Auto-calculate total days when dates change
(function() {
    const startDate = document.getElementById('startDate');
    const endDate = document.getElementById('endDate');
    const totalDays = document.getElementById('totalDays');

    // Set min date to today
    const today = new Date().toISOString().split('T')[0];
    if (startDate) startDate.setAttribute('min', today);
    if (endDate) endDate.setAttribute('min', today);

    function calcDays() {
        if (startDate && endDate && startDate.value && endDate.value) {
            const s = new Date(startDate.value);
            const e = new Date(endDate.value);
            if (e >= s) {
                let current = new Date(s);
                let diffDays = 0;
                while (current <= e) {
                    const day = current.getDay();
                    // 0 is Sunday, 6 is Saturday
                    if (day !== 0 && day !== 6) {
                        diffDays++;
                    }
                    current.setDate(current.getDate() + 1);
                }
                if (totalDays) totalDays.value = diffDays;
            }
            // Also enforce endDate >= startDate
            if (endDate) endDate.setAttribute('min', startDate.value);
        }
    }

    if (startDate) startDate.addEventListener('change', calcDays);
    if (endDate) endDate.addEventListener('change', calcDays);

    // Leave Balances Map from backend
    <%
        // Fallback scriptlet to force evaluation even if Tomcat caches the old Controller class
        dao.LeaveRequestDAO ls = new dao.LeaveRequestDAOImpl();
        model.User currentUser = (model.User) session.getAttribute("currentUser");
        java.util.Map<Integer, Double> bMap = new java.util.HashMap<>();
        if (currentUser != null && request.getAttribute("leaveTypes") != null) {
            for (model.LeaveType t : (java.util.List<model.LeaveType>)request.getAttribute("leaveTypes")) {
                try {
                    bMap.put(t.getLeaveTypeId(), ls.checkRemainingLeaveBalance(currentUser.getUserId(), t.getLeaveTypeId()));
                } catch(Exception e) {
                    bMap.put(t.getLeaveTypeId(), 0.0);
                }
            }
        }
        request.setAttribute("fallbackBalances", bMap);
    %>
    const leaveBalances = {
        <c:forEach var="entry" items="${fallbackBalances}">
            "${entry.key}": ${entry.value},
        </c:forEach>
    };

    const leaveTypeSelect = document.getElementById('leaveTypeId');
    const dynamicBalanceText = document.getElementById('dynamicBalanceText');
    const annualLeaveBadge = document.getElementById('annualLeaveBadge');
    
    function toggleBadge() {
        if (leaveTypeSelect && dynamicBalanceText) {
            const typeId = leaveTypeSelect.value;
            if (typeId) {
                const bal = leaveBalances[typeId];
                if (bal !== undefined && bal < 900) { // Assuming 999 is unbounded
                    dynamicBalanceText.innerText = bal + " ngày";
                    annualLeaveBadge.style.display = 'flex';
                } else {
                    dynamicBalanceText.innerText = "Không giới hạn / Theo quy định";
                    annualLeaveBadge.style.display = 'flex';
                }
            } else {
                annualLeaveBadge.style.display = 'none';
            }
        }
    }
    
    if (leaveTypeSelect) {
        leaveTypeSelect.addEventListener('change', toggleBadge);
        toggleBadge();
    }
})();
</script>

<jsp:include page="../footer.jsp" />


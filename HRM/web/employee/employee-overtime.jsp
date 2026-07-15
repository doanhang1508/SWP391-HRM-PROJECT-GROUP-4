<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Tăng Ca Của Tôi - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    .emp-layout { display: flex; min-height: calc(100vh - 64px); }
    .emp-content { flex: 1; padding: 30px; overflow-y: auto; }

    /* ── Page Banner ── */
    .page-banner {
        background: linear-gradient(135deg, #0a2540 0%, #1a3a6b 100%);
        color: white; border-radius: 14px; padding: 24px 32px;
        margin-bottom: 24px; position: relative; overflow: hidden;
    }
    .page-banner::after {
        content: ''; position: absolute; top: -60px; right: -60px;
        width: 220px; height: 220px;
        background: rgba(255,255,255,0.04); border-radius: 50%; pointer-events: none;
    }
    .page-banner h2 { font-size: 1.4rem; font-weight: 700; margin: 0 0 6px; }
    .page-banner p  { margin: 0; opacity: .72; font-size: .9rem; }

    /* ── Alert banner ── */
    .alert-box {
        border-radius: 10px; padding: 12px 18px; margin-bottom: 20px;
        font-size: .9rem; display: flex; align-items: center; gap: 10px;
    }
    .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
    .alert-error   { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

    /* ── Section card ── */
    .section-card {
        background: var(--th-surface, #fff);
        border: 1px solid var(--th-border, #e2e8f0);
        border-radius: 14px; padding: 24px; margin-bottom: 24px;
        box-shadow: 0 1px 4px rgba(0,0,0,.05);
    }
    .section-title {
        font-size: 1rem; font-weight: 700; margin: 0 0 16px;
        display: flex; align-items: center; gap: 8px; color: var(--th-text, #1a202c);
    }
    .section-title .badge {
        background: #e0f2fe; color: #0369a1; font-size: .75rem;
        padding: 2px 9px; border-radius: 999px; font-weight: 600;
    }

    /* ── Table ── */
    .ot-table { width: 100%; border-collapse: collapse; font-size: .875rem; }
    .ot-table thead th {
        background: #f8fafc; color: #64748b; font-weight: 600;
        padding: 10px 14px; border-bottom: 2px solid #e2e8f0;
        text-align: left; white-space: nowrap;
    }
    .ot-table tbody td {
        padding: 11px 14px; border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }
    .ot-table tbody tr:last-child td { border-bottom: none; }
    .ot-table tbody tr:hover { background: #f8fafc; }

    /* ── Status badges ── */
    .badge-status {
        display: inline-block; padding: 3px 10px; border-radius: 999px;
        font-size: .75rem; font-weight: 600; white-space: nowrap;
    }
    .badge-pending    { background: #fef9c3; color: #854d0e; }
    .badge-approved   { background: #dcfce7; color: #166534; }
    .badge-cancelled  { background: #f1f5f9; color: #64748b; }

    /* Employee response badges */
    .emp-badge-pending   { background: #e0f2fe; color: #0369a1; }
    .emp-badge-accepted  { background: #d1fae5; color: #065f46; }
    .emp-badge-declined  { background: #fee2e2; color: #991b1b; }

    /* ── Action buttons ── */
    .btn-accept {
        background: #10b981; color: #fff; border: none; border-radius: 7px;
        padding: 6px 14px; font-size: .82rem; font-weight: 600; cursor: pointer;
        transition: background .15s;
    }
    .btn-accept:hover { background: #059669; }
    .btn-decline {
        background: #fff; color: #ef4444; border: 1.5px solid #ef4444;
        border-radius: 7px; padding: 6px 14px; font-size: .82rem;
        font-weight: 600; cursor: pointer; transition: all .15s;
    }
    .btn-decline:hover { background: #fef2f2; }

    /* ── Empty state ── */
    .empty-state {
        text-align: center; padding: 36px 20px;
        color: #94a3b8; font-size: .9rem;
    }
    .empty-state i { font-size: 2rem; display: block; margin-bottom: 8px; }

    /* ── Modal ── */
    .modal-overlay {
        display: none; position: fixed; inset: 0;
        background: rgba(0,0,0,.45); z-index: 1000;
        align-items: center; justify-content: center;
    }
    .modal-overlay.active { display: flex; }
    .modal-box {
        background: #fff; border-radius: 16px; padding: 28px 32px;
        width: 420px; max-width: 95vw; box-shadow: 0 20px 60px rgba(0,0,0,.2);
        animation: slideUp .2s ease;
    }
    @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    .modal-title { font-size: 1.1rem; font-weight: 700; margin: 0 0 12px; color: #1a202c; }
    .modal-subtitle { font-size: .85rem; color: #64748b; margin: 0 0 16px; }
    .modal-textarea {
        width: 100%; border: 1.5px solid #e2e8f0; border-radius: 8px;
        padding: 10px 12px; font-size: .875rem; resize: vertical;
        min-height: 90px; outline: none; box-sizing: border-box;
        transition: border-color .15s;
    }
    .modal-textarea:focus { border-color: #6366f1; }
    .modal-footer { display: flex; gap: 10px; justify-content: flex-end; margin-top: 16px; }
    .btn-cancel-modal {
        background: #f1f5f9; color: #475569; border: none; border-radius: 8px;
        padding: 8px 18px; font-weight: 600; cursor: pointer;
    }
    .btn-confirm-decline {
        background: #ef4444; color: #fff; border: none; border-radius: 8px;
        padding: 8px 18px; font-weight: 600; cursor: pointer;
    }
    .btn-confirm-decline:hover { background: #dc2626; }
</style>

<div class="emp-layout">
    <jsp:include page="../sidebar.jsp" />

    <div class="emp-content">

        <!-- ── Page Banner ── -->
        <div class="page-banner">
            <h2>&#128337; Tăng Ca Của Tôi</h2>
            <p>Xem lịch tăng ca được phân công và phản hồi xác nhận</p>
        </div>

        <!-- ── Flash messages ── -->
        <c:if test="${not empty param.message}">
            <div class="alert-box alert-success">&#10004; ${param.message}</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert-box alert-error">&#10006; ${param.error}</div>
        </c:if>

        <!-- ════════════════════════════════════════════
             UPCOMING OT (cần phản hồi / sắp tới)
        ═════════════════════════════════════════════ -->
        <div class="section-card">
            <div class="section-title">
                &#128197; Lịch Tăng Ca Sắp Tới
                <span class="badge">${fn:length(upcomingOT)}</span>
            </div>

            <c:choose>
                <c:when test="${empty upcomingOT}">
                    <div class="empty-state">
                        <i>&#128339;</i>
                        Không có lịch tăng ca nào trong thời gian tới.
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x:auto;">
                        <table class="ot-table" id="upcoming-ot-table">
                            <thead>
                                <tr>
                                    <th>Ngày</th>
                                    <th>Mô tả kế hoạch</th>
                                    <th>Số giờ được phân công</th>
                                    <th>Trạng thái đơn</th>
                                    <th>Phản hồi của bạn</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="ot" items="${upcomingOT}">
                                    <tr>
                                        <td><strong><fmt:formatDate value="${ot.targetDate}" pattern="dd/MM/yyyy" /></strong></td>
                                        <td>${ot.planDescription}</td>
                                        <td style="text-align:center;"><strong>${ot.assignedHours}h</strong></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ot.status == 'Approved'}">
                                                    <span class="badge-status badge-approved">Đã duyệt</span>
                                                </c:when>
                                                <c:when test="${ot.status == 'Cancelled'}">
                                                    <span class="badge-status badge-cancelled">Đã hủy</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status badge-pending">Chờ duyệt</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ot.employeeResponse == 'ACCEPTED'}">
                                                    <span class="badge-status emp-badge-accepted">&#10003; Đã chấp nhận</span>
                                                </c:when>
                                                <c:when test="${ot.employeeResponse == 'DECLINED'}">
                                                    <span class="badge-status emp-badge-declined" title="${ot.employeeResponseNote}">&#10007; Đã từ chối</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status emp-badge-pending">Chưa phản hồi</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${ot.employeeResponse == 'PENDING' and ot.status != 'Cancelled'}">
                                                <!-- Accept -->
                                                <form method="post" action="${pageContext.request.contextPath}/employee/overtime"
                                                      style="display:inline;"
                                                      onsubmit="return confirm('Xác nhận chấp nhận tăng ca ngày này?');">
                                                    <input type="hidden" name="action" value="accept" />
                                                    <input type="hidden" name="assignmentId" value="${ot.assignmentId}" />
                                                    <button type="submit" class="btn-accept" id="accept-btn-${ot.assignmentId}">&#10003; Chấp nhận</button>
                                                </form>
                                                <!-- Decline (opens modal) -->
                                                <button type="button" class="btn-decline"
                                                        id="decline-btn-${ot.assignmentId}"
                                                        onclick="openDeclineModal(${ot.assignmentId})">&#10007; Từ chối</button>
                                            </c:if>
                                            <c:if test="${ot.status == 'Cancelled'}">
                                                <span style="color:#94a3b8;font-size:.8rem;">—</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ════════════════════════════════════════════
             PAST OT (lịch sử)
        ═════════════════════════════════════════════ -->
        <div class="section-card">
            <div class="section-title">
                &#128203; Lịch Sử Tăng Ca
            </div>
            <c:choose>
                <c:when test="${empty pastOT}">
                    <div class="empty-state">
                        <i>&#128203;</i>
                        Chưa có lịch sử tăng ca.
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x:auto;">
                        <table class="ot-table" id="past-ot-table">
                            <thead>
                                <tr>
                                    <th>Ngày</th>
                                    <th>Mô tả</th>
                                    <th>Giờ phân công</th>
                                    <th>Giờ được duyệt</th>
                                    <th>Trạng thái đơn</th>
                                    <th>Phản hồi</th>
                                    <th>Lý do từ chối</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="ot" items="${pastOT}">
                                    <tr>
                                        <td><fmt:formatDate value="${ot.targetDate}" pattern="dd/MM/yyyy" /></td>
                                        <td>${ot.planDescription}</td>
                                        <td style="text-align:center;">${ot.assignedHours}h</td>
                                        <td style="text-align:center;">
                                            <c:choose>
                                                <c:when test="${not empty ot.approvedHours}">${ot.approvedHours}h</c:when>
                                                <c:otherwise><span style="color:#94a3b8;">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ot.status == 'Approved'}">
                                                    <span class="badge-status badge-approved">Đã duyệt</span>
                                                </c:when>
                                                <c:when test="${ot.status == 'Cancelled'}">
                                                    <span class="badge-status badge-cancelled">Đã hủy</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status badge-pending">Chờ duyệt</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ot.employeeResponse == 'ACCEPTED'}">
                                                    <span class="badge-status emp-badge-accepted">Chấp nhận</span>
                                                </c:when>
                                                <c:when test="${ot.employeeResponse == 'DECLINED'}">
                                                    <span class="badge-status emp-badge-declined">Từ chối</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status emp-badge-pending">Chưa PH</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="max-width:200px;white-space:normal;">
                                            <c:if test="${not empty ot.employeeResponseNote}">
                                                <span style="font-size:.8rem;color:#64748b;">${ot.employeeResponseNote}</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div><!-- /emp-content -->
</div><!-- /emp-layout -->

<!-- ── Decline Modal ── -->
<div class="modal-overlay" id="declineModal">
    <div class="modal-box">
        <div class="modal-title">&#10007; Từ chối tăng ca</div>
        <div class="modal-subtitle">Vui lòng nhập lý do từ chối để quản lý nắm được tình hình.</div>
        <form method="post" action="${pageContext.request.contextPath}/employee/overtime" id="declineForm">
            <input type="hidden" name="action" value="decline" />
            <input type="hidden" name="assignmentId" id="declineAssignmentId" />
            <textarea class="modal-textarea" name="note" id="declineNote"
                      placeholder="Nhập lý do từ chối..." required></textarea>
            <div class="modal-footer">
                <button type="button" class="btn-cancel-modal" onclick="closeDeclineModal()">Hủy bỏ</button>
                <button type="submit" class="btn-confirm-decline"
                        onclick="return validateDeclineForm()">Xác nhận từ chối</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openDeclineModal(assignmentId) {
        document.getElementById('declineAssignmentId').value = assignmentId;
        document.getElementById('declineNote').value = '';
        document.getElementById('declineModal').classList.add('active');
        setTimeout(function() { document.getElementById('declineNote').focus(); }, 150);
    }
    function closeDeclineModal() {
        document.getElementById('declineModal').classList.remove('active');
    }
    function validateDeclineForm() {
        var note = document.getElementById('declineNote').value.trim();
        if (!note) {
            alert('Vui lòng nhập lý do từ chối.');
            return false;
        }
        return true;
    }
    // Close modal on overlay click
    document.getElementById('declineModal').addEventListener('click', function(e) {
        if (e.target === this) closeDeclineModal();
    });
</script>

<jsp:include page="../footer.jsp" />

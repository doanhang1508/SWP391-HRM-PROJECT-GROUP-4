<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Giải Quyết Khiếu Nại Chấm Công - HR Staff" scope="request" />
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
    .role-badge {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 7px 16px; border-radius: 20px; font-size: 0.82rem; font-weight: 700;
        background: linear-gradient(135deg, #6366f1, #4f46e5); color: #fff;
        box-shadow: 0 2px 8px rgba(99,102,241,0.3);
    }

    /* Tabs */
    .tabs { display: flex; gap: 4px; margin-bottom: 20px; background: var(--card); border-radius: 12px; padding: 6px; border: 1px solid #f1f5f9; width: fit-content; }
    .tab { padding: 8px 18px; border-radius: 8px; font-size: .85rem; font-weight: 600; text-decoration: none; color: var(--muted); transition: all .2s; }
    .tab.active { background: var(--pri); color: #fff; }
    .tab:hover:not(.active) { background: #f1f5f9; color: var(--txt); }

    /* Alerts */
    .alert { padding: 14px 18px; border-radius: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; font-size: .88rem; font-weight: 500; }
    .alert-success { background: rgba(16,185,129,.1); color: #065f46; border: 1px solid #a7f3d0; }
    .alert-error   { background: rgba(239,68,68,.1);  color: #991b1b; border: 1px solid #fecaca; }

    /* Table */
    .table-panel { background: var(--card); border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,.04); border: 1px solid rgba(0,0,0,.05); overflow: hidden; }
    table { width: 100%; border-collapse: collapse; }
    thead th { background: #f8fafc; padding: 12px 14px; text-align: left; font-size: .76rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid #e2e8f0; }
    tbody td { padding: 13px 14px; font-size: .87rem; color: var(--txt); border-bottom: 1px solid #f8fafc; vertical-align: middle; }
    tbody tr:hover td { background: #fafbff; }

    .badge { display: inline-flex; align-items: center; gap: 5px; padding: 3px 10px; border-radius: 20px; font-size: .74rem; font-weight: 700; }
    .badge-pending  { background: rgba(245,158,11,.12); color: #92400e; }
    .badge-approved { background: rgba(16,185,129,.12); color: #065f46; }
    .badge-rejected { background: rgba(239,68,68,.12);  color: #991b1b; }

    .btn-resolve {
        display: inline-flex; align-items: center; gap: 6px;
        background: var(--pri); color: #fff; border: none; border-radius: 8px;
        padding: 7px 14px; font-size: .82rem; font-weight: 600; cursor: pointer;
        transition: all .2s; white-space: nowrap;
    }
    .btn-resolve:hover { background: #4f46e5; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(99,102,241,.35); }

    .empty-state { text-align: center; padding: 50px; color: var(--muted); }
    .empty-state i { font-size: 3rem; margin-bottom: 14px; color: #cbd5e1; display: block; }

    /* ══ MODAL ══ */
    .modal-overlay {
        display: none; position: fixed; inset: 0;
        background: rgba(15,23,42,.55); backdrop-filter: blur(4px);
        z-index: 9999; align-items: center; justify-content: center;
    }
    .modal-overlay.show { display: flex; animation: fadeIn .18s ease; }
    @keyframes fadeIn { from { opacity:0; } to { opacity:1; } }

    .modal {
        background: var(--card); border-radius: 20px; padding: 32px;
        width: 540px; max-width: 96vw; max-height: 90vh; overflow-y: auto;
        box-shadow: 0 24px 64px rgba(0,0,0,.22);
        animation: slideUp .22s cubic-bezier(.22,1,.36,1);
    }
    @keyframes slideUp { from { transform:translateY(24px); opacity:0; } to { transform:translateY(0); opacity:1; } }

    .modal-header { display: flex; align-items: center; gap: 12px; margin-bottom: 6px; }
    .modal-icon {
        width: 44px; height: 44px; border-radius: 12px;
        background: rgba(99,102,241,.12); color: var(--pri);
        display: flex; align-items: center; justify-content: center;
        font-size: 1.1rem; flex-shrink: 0;
    }
    .modal-title { font-size: 1.15rem; font-weight: 800; color: var(--txt); }

    .modal-info {
        background: #f8fafc; border-radius: 10px; padding: 12px 16px;
        margin: 14px 0 20px; font-size: .84rem; color: var(--muted);
        border-left: 3px solid var(--pri); line-height: 1.6;
    }
    .modal-info strong { color: var(--txt); }

    .form-group { display: flex; flex-direction: column; gap: 6px; margin-bottom: 16px; }
    .form-group label { font-size: .79rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .5px; }
    .form-group select,
    .form-group textarea,
    .form-group input[type="time"] {
        border: 1.5px solid #e2e8f0; border-radius: 9px; padding: 10px 13px;
        font-size: .88rem; font-family: 'Inter', sans-serif; color: var(--txt);
        outline: none; transition: border-color .2s, box-shadow .2s; background: #fff;
    }
    .form-group select:focus,
    .form-group textarea:focus,
    .form-group input[type="time"]:focus { border-color: var(--pri); box-shadow: 0 0 0 3px rgba(99,102,241,.12); }
    .form-group textarea { min-height: 88px; resize: vertical; }

    .time-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .time-note { font-size: .75rem; color: var(--muted); margin-top: 3px; }

    .divider { border: none; border-top: 1px solid #f1f5f9; margin: 18px 0; }

    .modal-actions { display: flex; gap: 10px; justify-content: flex-end; flex-wrap: wrap; }
    .btn-cancel  { background: #f1f5f9; color: var(--txt); border: none; border-radius: 10px; padding: 10px 18px; font-weight: 600; font-size: .88rem; cursor: pointer; transition: background .2s; }
    .btn-cancel:hover { background: #e2e8f0; }
    .btn-reject  {
        display: inline-flex; align-items: center; gap: 6px;
        background: var(--ng); color: #fff; border: none; border-radius: 10px;
        padding: 10px 20px; font-weight: 700; font-size: .88rem; cursor: pointer; transition: all .2s;
    }
    .btn-reject:hover  { background: #dc2626; }
    .btn-approve {
        display: inline-flex; align-items: center; gap: 6px;
        background: var(--ok); color: #fff; border: none; border-radius: 10px;
        padding: 10px 20px; font-weight: 700; font-size: .88rem; cursor: pointer; transition: all .2s;
    }
    .btn-approve:hover { background: #059669; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="hr-attendance-claims"/>
    </jsp:include>

    <div class="main-content">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:24px;flex-wrap:wrap;gap:12px">
            <div>
                <h1 class="page-title">
                    <i class="fas fa-tasks" style="color:var(--pri);margin-right:10px"></i>Giải Quyết Khiếu Nại Chấm Công
                </h1>
                <div class="breadcrumb-c">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a> / Khiếu nại chấm công
                </div>
            </div>
            <div class="role-badge"><i class="fas fa-user-tie"></i> Nhân viên HR</div>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <%-- Tabs --%>
        <div class="tabs">
            <a href="?status=PENDING" class="tab ${statusFilter == 'PENDING' ? 'active' : ''}">
                <i class="fas fa-hourglass-half"></i> Chờ xử lý
                <c:if test="${not empty pendingClaims}">
                    <span style="background:var(--ng);color:#fff;border-radius:12px;padding:1px 7px;font-size:.72rem;margin-left:4px">${pendingClaims.size()}</span>
                </c:if>
            </a>
            <a href="?status=APPROVED" class="tab ${statusFilter == 'APPROVED' ? 'active' : ''}">
                <i class="fas fa-check"></i> Đã duyệt
            </a>
            <a href="?status=REJECTED" class="tab ${statusFilter == 'REJECTED' ? 'active' : ''}">
                <i class="fas fa-times"></i> Từ chối
            </a>
            <a href="?status=" class="tab ${statusFilter == '' ? 'active' : ''}">
                <i class="fas fa-list"></i> Tất cả
            </a>
        </div>

        <%-- Table --%>
        <div class="table-panel">
            <c:choose>
                <c:when test="${empty claims}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <p style="margin:0;font-weight:600">Không có đơn khiếu nại</p>
                        <p style="font-size:.83rem;margin:4px 0 0">Trong danh mục này</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th><th>Nhân viên</th><th>Phòng ban</th><th>Ngày</th>
                                <th>Ca</th><th>Loại</th><th>Mô tả</th>
                                <th>TT hiện tại</th><th>Trạng thái</th><th>Ngày gửi</th>
                                <c:if test="${statusFilter == 'PENDING'}"><th>Thao tác</th></c:if>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${claims}" var="cl">
                            <%-- Format ngày vào biến JSTL trước, tránh dùng fmt bên trong onclick --%>
                            <c:set var="fmtWorkDate"><fmt:formatDate value="${cl.workDate}" pattern="dd/MM/yyyy"/></c:set>
                            <tr>
                                <td style="font-weight:700;color:var(--muted)">#${cl.claimId}</td>
                                <td style="font-weight:600">${cl.userName}</td>
                                <td style="font-size:.82rem;color:var(--muted)">${cl.userDept}</td>
                                <td style="font-weight:600">${fmtWorkDate}</td>
                                <td style="font-size:.82rem">${cl.shiftName}</td>
                                <td style="font-size:.8rem">
                                    <c:choose>
                                        <c:when test="${cl.claimType == 'MISSING'}">Thiếu dữ liệu</c:when>
                                        <c:when test="${cl.claimType == 'WRONG_STATUS'}">Sai trạng thái</c:when>
                                        <c:when test="${cl.claimType == 'WRONG_TIME'}">Sai giờ</c:when>
                                        <c:otherwise>Khác</c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="max-width:180px;font-size:.82rem;color:var(--muted)">${cl.description}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cl.currentStatus == 'PRESENT'}"><span style="color:var(--ok);font-weight:600;font-size:.82rem">Có mặt</span></c:when>
                                        <c:when test="${cl.currentStatus == 'LATE'}"><span style="color:var(--warn);font-weight:600;font-size:.82rem">Đi trễ</span></c:when>
                                        <c:when test="${cl.currentStatus == 'ABSENT'}"><span style="color:var(--ng);font-weight:600;font-size:.82rem">Vắng</span></c:when>
                                        <c:otherwise><span style="font-size:.82rem">${cl.currentStatus}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cl.status == 'PENDING'}"><span class="badge badge-pending"><i class="fas fa-hourglass-half"></i> Chờ</span></c:when>
                                        <c:when test="${cl.status == 'APPROVED'}"><span class="badge badge-approved"><i class="fas fa-check"></i> Đã duyệt</span></c:when>
                                        <c:when test="${cl.status == 'REJECTED'}"><span class="badge badge-rejected"><i class="fas fa-times"></i> Từ chối</span></c:when>
                                    </c:choose>
                                </td>
                                <td style="font-size:.8rem;color:var(--muted)">
                                    <fmt:formatDate value="${cl.createdAt}" pattern="dd/MM HH:mm"/>
                                </td>
                                <c:if test="${statusFilter == 'PENDING'}">
                                    <td>
                                        <%-- Dùng data-* attributes thay vì nhúng fmt bên trong onclick --%>
                                        <button class="btn-resolve"
                                                data-claim-id="${cl.claimId}"
                                                data-name="${cl.userName}"
                                                data-date="${fmtWorkDate}"
                                                data-type="${cl.claimType}"
                                                data-desc="${cl.description}"
                                                data-dept="${cl.userDept}"
                                                onclick="openModal(this)">
                                            <i class="fas fa-gavel"></i> Giải quyết
                                        </button>
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

<%-- ══ RESOLVE MODAL ══ --%>
<div class="modal-overlay" id="resolveModal">
    <div class="modal">
        <div class="modal-header">
            <div class="modal-icon"><i class="fas fa-gavel"></i></div>
            <div class="modal-title">Giải Quyết Khiếu Nại</div>
        </div>

        <div class="modal-info" id="modalInfo">—</div>

        <form method="post" action="${pageContext.request.contextPath}/hr/resolve-claim" id="resolveForm"
              accept-charset="UTF-8">
            <input type="hidden" name="action"  value="resolve">
            <input type="hidden" name="claimId" id="modalClaimId">

            <div class="form-group">
                <label>Cập nhật trạng thái chấm công (nếu Duyệt)</label>
                <select name="newAttendanceStatus" id="newStatusSelect" onchange="toggleTimeSection(this.value)">
                    <option value="">— Giữ nguyên —</option>
                    <option value="PRESENT">&#10003; PRESENT &mdash; Có mặt</option>
                    <option value="LATE">&#128336; LATE &mdash; Đi trễ</option>
                    <option value="HALFDAY">&#9681; HALFDAY &mdash; Nửa ngày</option>
                </select>
            </div>

            <div id="timeCorrectionSection" style="display:none">
                <div class="form-group">
                    <label>Chỉnh giờ vào / ra thực tế (tuỳ chọn)</label>
                    <div class="time-row">
                        <div>
                            <input type="time" name="correctedCheckIn" id="correctedCheckIn">
                            <div class="time-note"><i class="fas fa-sign-in-alt"></i> Giờ vào</div>
                        </div>
                        <div>
                            <input type="time" name="correctedCheckOut" id="correctedCheckOut">
                            <div class="time-note"><i class="fas fa-sign-out-alt"></i> Giờ ra</div>
                        </div>
                    </div>
                </div>
            </div>

            <hr class="divider">

            <div class="form-group">
                <label>Ghi chú HR <span style="color:var(--ng)">*</span></label>
                <textarea name="hrNote" id="hrNoteField"
                          placeholder="Nhập lý do duyệt hoặc từ chối đơn khiếu nại này..."></textarea>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeModal()">
                    <i class="fas fa-times"></i> Hủy
                </button>
                <button type="submit" name="decision" value="REJECTED" class="btn-reject" id="btnReject"
                        onclick="return validateAndSubmit('từ chối', this)">
                    <i class="fas fa-times-circle"></i> Từ chối
                </button>
                <button type="submit" name="decision" value="APPROVED" class="btn-approve" id="btnApprove"
                        onclick="return validateAndSubmit('duyệt', this)">
                    <i class="fas fa-check-circle"></i> Duyệt
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    var typeLabels = {
        MISSING:      'Thiếu dữ liệu chấm công',
        WRONG_STATUS: 'Sai trạng thái',
        WRONG_TIME:   'Sai giờ vào/ra',
        OTHER:        'Khác'
    };

    function openModal(btn) {
        var claimId = btn.getAttribute('data-claim-id');
        var name    = btn.getAttribute('data-name')  || '';
        var date    = btn.getAttribute('data-date')  || '';
        var type    = btn.getAttribute('data-type')  || '';
        var desc    = btn.getAttribute('data-desc')  || '';
        var dept    = btn.getAttribute('data-dept')  || '';

        document.getElementById('modalClaimId').value = claimId;

        var infoHtml =
            '<strong>' + escHtml(name) + '</strong>' +
            (dept ? ' &nbsp;&middot;&nbsp; ' + escHtml(dept) : '') +
            ' &nbsp;&middot;&nbsp; Ngày: <strong>' + date + '</strong>' +
            ' &nbsp;&middot;&nbsp; Loại: <strong>' + (typeLabels[type] || type) + '</strong>';
        if (desc) {
            infoHtml += '<br><span style="margin-top:4px;display:inline-block;color:#475569">&#128221; ' + escHtml(desc) + '</span>';
        }
        document.getElementById('modalInfo').innerHTML = infoHtml;

        // Reset form
        document.getElementById('newStatusSelect').value   = '';
        document.getElementById('hrNoteField').value       = '';
        document.getElementById('correctedCheckIn').value  = '';
        document.getElementById('correctedCheckOut').value = '';
        document.getElementById('timeCorrectionSection').style.display = 'none';

        document.getElementById('resolveModal').classList.add('show');
        document.body.style.overflow = 'hidden';
    }

    function closeModal() {
        document.getElementById('resolveModal').classList.remove('show');
        document.body.style.overflow = '';
    }

    function toggleTimeSection(val) {
        document.getElementById('timeCorrectionSection').style.display = val ? 'block' : 'none';
    }

    function validateAndSubmit(action, btn) {
        var note = document.getElementById('hrNoteField').value.trim();
        if (!note) {
            alert('Vui lòng nhập Ghi chú HR trước khi ' + action + '.');
            document.getElementById('hrNoteField').focus();
            return false;
        }
        var confirmed = confirm('Xác nhận ' + action + ' đơn khiếu nại này?');
        if (!confirmed) return false;

        // Vô hiệu hóa các nút để tránh double-submit
        document.getElementById('btnApprove').disabled = true;
        document.getElementById('btnReject').disabled = true;
        if (btn) { btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang xử lý...'; }
        return true;
    }

    function escHtml(str) {
        if (!str) return '';
        return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // Click backdrop to close
    document.getElementById('resolveModal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });

    // Escape key: ưu tiên đóng modal nếu đang mở
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            var modal = document.getElementById('resolveModal');
            if (modal.classList.contains('show')) {
                e.stopImmediatePropagation();
                closeModal();
            }
        }
    }, true); // capture phase để chạy trước listener của sidebar
</script>

<jsp:include page="../footer.jsp" />

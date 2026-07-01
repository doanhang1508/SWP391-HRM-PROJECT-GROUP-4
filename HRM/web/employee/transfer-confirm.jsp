<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Xác Nhận Điều Chuyển" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --navy:    #0a2540;
        --blue:    #2b6cb0;
        --bg:      #f0ede8;
        --surface: #ffffff;
        --border:  #e2e8f0;
        --text:    #0f172a;
        --muted:   #64748b;
        --pri:     #6366f1;
        --pri-dark:#4f46e5;
        --ok:      #10b981;
        --ok-dark: #059669;
        --ng:      #ef4444;
        --ng-dark: #dc2626;
        --warn:    #f59e0b;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }

    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    /* TOP BAR */
    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb  { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }

    /* ALERTS */
    .alert { padding: 14px 20px; border-radius: 12px; font-size: 0.9rem; font-weight: 500; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
    .alert-success { background: #d1fae5; border: 1px solid #a7f3d0; color: #065f46; }
    .alert-danger  { background: #fee2e2; border: 1px solid #fecdd3; color: #9f1239; }
    .alert-info    { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }

    /* WORKFLOW BANNER */
    .workflow-banner {
        background: linear-gradient(135deg, rgba(99, 102, 241, 0.06) 0%, rgba(16, 185, 129, 0.06) 100%);
        border: 1px solid rgba(99, 102, 241, 0.15);
        border-radius: 16px;
        padding: 20px 24px;
        margin-bottom: 28px;
        display: flex;
        align-items: center;
        gap: 20px;
        flex-wrap: wrap;
    }
    .workflow-step { display: flex; align-items: center; gap: 10px; }
    .step-num { width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.85rem; }
    .step-num.active { background: var(--pri); color: #fff; box-shadow: 0 0 0 4px rgba(99,102,241,0.2); }
    .step-num.waiting { background: #e2e8f0; color: var(--muted); }
    .step-label { font-size: 0.82rem; font-weight: 600; }
    .step-label.active { color: var(--pri); }
    .step-label.waiting { color: var(--muted); }
    .step-arrow { color: var(--muted); font-size: 1rem; }

    /* EMPTY STATE */
    .empty-state { text-align: center; padding: 60px 40px; background: var(--surface); border: 1px solid var(--border); border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.02); }
    .empty-icon { font-size: 3rem; color: #cbd5e1; margin-bottom: 16px; }
    .empty-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.2rem; font-weight: 700; color: var(--navy); margin-bottom: 8px; }
    .empty-sub { font-size: 0.88rem; color: var(--muted); }

    /* TRANSFER CARD */
    .transfer-card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 16px;
        padding: 28px 32px;
        margin-bottom: 24px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        position: relative;
        transition: box-shadow .2s;
    }
    .transfer-card:hover { box-shadow: 0 8px 30px rgba(0,0,0,0.07); }
    .transfer-card-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; margin-bottom: 20px; flex-wrap: wrap; }
    .transfer-card-id { font-size: 0.78rem; color: var(--muted); font-weight: 600; background: #f1f5f9; padding: 4px 10px; border-radius: 6px; }
    .transfer-card-date { font-size: 0.78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }

    /* COMPARE GRID */
    .compare-grid { display: flex; gap: 0; border: 1px solid var(--border); border-radius: 12px; overflow: hidden; margin-bottom: 20px; }
    .compare-side { flex: 1; padding: 18px 20px; }
    .compare-side.old { background: #f8fafc; border-right: 1px solid var(--border); }
    .compare-side.new { background: #f0fdf4; }
    .compare-side-title { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; color: var(--muted); margin-bottom: 12px; letter-spacing: 0.5px; display: flex; align-items: center; gap: 6px; }
    .compare-item { margin-bottom: 10px; }
    .compare-item:last-child { margin-bottom: 0; }
    .compare-label { font-size: 0.72rem; color: var(--muted); margin-bottom: 2px; }
    .compare-val { font-size: 0.9rem; font-weight: 700; color: var(--navy); }
    .compare-val.new-val { color: var(--ok-dark); }

    /* REASON BOX */
    .reason-box { background: #f8fafc; border: 1px solid var(--border); border-radius: 10px; padding: 14px 16px; margin-bottom: 20px; font-size: 0.875rem; line-height: 1.6; color: #334155; }
    .reason-label { font-weight: 700; font-size: 0.72rem; color: var(--navy); text-transform: uppercase; margin-bottom: 6px; letter-spacing: 0.5px; }

    /* SALARY INFO */
    .salary-info { background: rgba(99,102,241,0.05); border: 1px solid rgba(99,102,241,0.2); border-radius: 10px; padding: 14px 16px; margin-bottom: 20px; font-size: 0.875rem; }
    .salary-info-title { font-weight: 700; font-size: 0.72rem; color: var(--pri-dark, #4f46e5); text-transform: uppercase; margin-bottom: 6px; letter-spacing: 0.5px; }

    /* ACTIONS */
    .action-area { border-top: 1px solid #f1f5f9; padding-top: 20px; display: flex; gap: 12px; flex-wrap: wrap; align-items: flex-start; }
    .btn-accept { background: var(--ok); color: #fff; border: none; padding: 11px 22px; border-radius: 10px; font-weight: 700; font-size: 0.9rem; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: all .2s; box-shadow: 0 4px 12px rgba(16,185,129,0.2); font-family: 'Inter', sans-serif; }
    .btn-accept:hover { background: var(--ok-dark); transform: translateY(-1px); box-shadow: 0 6px 15px rgba(16,185,129,0.3); }
    .btn-reject-toggle { background: rgba(239,68,68,0.08); color: var(--ng); border: 1.5px solid rgba(239,68,68,0.2); padding: 11px 22px; border-radius: 10px; font-weight: 700; font-size: 0.9rem; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: all .2s; font-family: 'Inter', sans-serif; }
    .btn-reject-toggle:hover { background: var(--ng); color: #fff; border-color: var(--ng); }

    /* REJECT FORM */
    .reject-form-wrap { display: none; width: 100%; margin-top: 12px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 20px; animation: fadeSlideIn .2s ease; }
    .reject-form-wrap.open { display: block; }
    @keyframes fadeSlideIn { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }
    .form-label { display: block; font-size: 0.82rem; font-weight: 600; color: #92400e; margin-bottom: 8px; }
    .form-control { width: 100%; padding: 11px 14px; border: 1px solid #fde68a; border-radius: 10px; font-size: 0.9rem; font-family: 'Inter', sans-serif; outline: none; transition: all .2s; background: #fff; color: var(--text); resize: vertical; min-height: 90px; }
    .form-control:focus { border-color: var(--ng); box-shadow: 0 0 0 3px rgba(239,68,68,0.15); }
    .reject-btn-row { display: flex; gap: 10px; justify-content: flex-end; margin-top: 14px; }
    .btn-cancel-reject { background: #f1f5f9; color: #475569; border: none; padding: 9px 18px; border-radius: 9px; font-weight: 600; font-size: 0.85rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .15s; }
    .btn-cancel-reject:hover { background: #e2e8f0; }
    .btn-confirm-reject { background: var(--ng); color: #fff; border: none; padding: 9px 20px; border-radius: 9px; font-weight: 700; font-size: 0.85rem; cursor: pointer; font-family: 'Inter', sans-serif; transition: all .2s; box-shadow: 0 3px 8px rgba(239,68,68,0.2); }
    .btn-confirm-reject:hover { background: var(--ng-dark); transform: translateY(-1px); }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .transfer-card { padding: 20px; }
        .compare-grid { flex-direction: column; }
        .compare-side.old { border-right: none; border-bottom: 1px solid var(--border); }
        .workflow-banner { flex-direction: column; align-items: flex-start; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="transfer-confirm" />
    </jsp:include>

    <div class="page-main">
        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <span>Xác nhận điều chuyển</span>
                </div>
                <h1><i class="fas fa-exchange-alt" style="color:var(--pri);margin-right:10px;font-size:1.3rem;"></i>Xác Nhận Yêu Cầu Điều Chuyển</h1>
            </div>
        </div>

        <!-- ALERTS -->
        <c:if test="${param.msg eq 'accept_success'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle" style="font-size:1.2rem;"></i>
                Bạn đã xác nhận đồng ý điều chuyển. Hệ thống đang thông báo cho Trưởng phòng phê duyệt.
            </div>
        </c:if>
        <c:if test="${param.msg eq 'reject_success'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle" style="font-size:1.2rem;"></i>
                Bạn đã từ chối yêu cầu điều chuyển. HR Staff sẽ nhận được thông báo.
            </div>
        </c:if>
        <c:if test="${param.msg eq 'accept_error' or param.msg eq 'reject_error'}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle" style="font-size:1.2rem;"></i>
                Thao tác không thành công. Yêu cầu có thể đã được xử lý hoặc không thuộc về bạn.
            </div>
        </c:if>
        <c:if test="${param.msg eq 'reject_reason_required'}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle" style="font-size:1.2rem;"></i>
                Vui lòng nhập lý do từ chối.
            </div>
        </c:if>

        <!-- WORKFLOW BANNER -->
        <div class="workflow-banner">
            <div class="workflow-step">
                <div class="step-num waiting"><i class="fas fa-user-tie"></i></div>
                <div class="step-label waiting">HR tạo đơn</div>
            </div>
            <span class="step-arrow">→</span>
            <div class="workflow-step">
                <div class="step-num active">1</div>
                <div class="step-label active">Bạn xác nhận</div>
            </div>
            <span class="step-arrow">→</span>
            <div class="workflow-step">
                <div class="step-num waiting">2</div>
                <div class="step-label waiting">Trưởng phòng duyệt</div>
            </div>
            <span class="step-arrow">→</span>
            <div class="workflow-step">
                <div class="step-num waiting">3</div>
                <div class="step-label waiting">HR Manager duyệt cuối</div>
            </div>
            <span class="step-arrow">→</span>
            <div class="workflow-step">
                <div class="step-num waiting"><i class="fas fa-check"></i></div>
                <div class="step-label waiting">Hoàn tất</div>
            </div>
        </div>

        <!-- CONTENT -->
        <c:choose>
            <c:when test="${empty pendingTransfers}">
                <div class="empty-state">
                    <div class="empty-icon"><i class="fas fa-clipboard-check"></i></div>
                    <div class="empty-title">Không có yêu cầu điều chuyển nào cần xác nhận</div>
                    <div class="empty-sub">Khi HR Staff tạo yêu cầu điều chuyển cho bạn, yêu cầu đó sẽ xuất hiện ở đây để bạn xác nhận.</div>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach items="${pendingTransfers}" var="tr" varStatus="vs">
                    <div class="transfer-card" id="card-${tr.transferRequestId}">
                        <div class="transfer-card-header">
                            <div>
                                <span class="transfer-card-id"><i class="fas fa-hashtag"></i> Yêu cầu #${tr.transferRequestId}</span>
                            </div>
                            <div class="transfer-card-date">
                                <i class="far fa-calendar-alt"></i>
                                Ngày hiệu lực: <strong style="color:var(--pri)"><fmt:formatDate value="${tr.effectiveDate}" pattern="dd/MM/yyyy" /></strong>
                            </div>
                        </div>

                        <!-- COMPARE GRID -->
                        <div class="compare-grid">
                            <div class="compare-side old">
                                <div class="compare-side-title"><i class="fas fa-map-marker-alt"></i> Vị trí hiện tại của bạn</div>
                                <div class="compare-item">
                                    <div class="compare-label">Phòng ban</div>
                                    <div class="compare-val">${tr.oldDepartmentName}</div>
                                </div>
                                <div class="compare-item">
                                    <div class="compare-label">Chức vụ</div>
                                    <div class="compare-val">${tr.oldPositionName}</div>
                                </div>
                            </div>
                            <div class="compare-side new">
                                <div class="compare-side-title" style="color:var(--ok-dark)"><i class="fas fa-route"></i> Vị trí sau điều chuyển</div>
                                <div class="compare-item">
                                    <div class="compare-label">Phòng ban mới</div>
                                    <div class="compare-val new-val">${tr.newDepartmentName}</div>
                                </div>
                                <div class="compare-item">
                                    <div class="compare-label">Chức vụ mới</div>
                                    <div class="compare-val new-val">${tr.newPositionName}</div>
                                </div>
                            </div>
                        </div>

                        <!-- SALARY INFO nếu có -->
                        <c:if test="${tr.newBaseSalary != null}">
                            <div class="salary-info">
                                <div class="salary-info-title"><i class="fas fa-coins"></i> Thay đổi lương đi kèm</div>
                                Lương cơ bản mới: <strong><fmt:formatNumber value="${tr.newBaseSalary}" type="currency" currencySymbol="" minFractionDigits="0" maxFractionDigits="0" /> VNĐ</strong>
                            </div>
                        </c:if>

                        <!-- REASON -->
                        <div class="reason-box">
                            <div class="reason-label"><i class="far fa-comment-dots"></i> Lý do điều chuyển từ HR</div>
                            ${tr.reason}
                        </div>

                        <!-- REQUESTER INFO -->
                        <div style="font-size:0.78rem; color:var(--muted); margin-bottom:20px;">
                            <i class="fas fa-user-edit" style="margin-right:4px;"></i>
                            Yêu cầu được tạo bởi: <strong>${tr.requestedByName}</strong>
                            &nbsp;·&nbsp;
                            <i class="far fa-clock" style="margin-right:4px;"></i>
                            <fmt:formatDate value="${tr.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                        </div>

                        <!-- ACTION BUTTONS -->
                        <div class="action-area">
                            <!-- Xác nhận -->
                            <form method="post"
                                  action="${pageContext.request.contextPath}/employee/transfer-confirm/accept"
                                  style="margin:0"
                                  onsubmit="return confirm('Bạn xác nhận ĐỒNG Ý với yêu cầu điều chuyển này? Sau đó Trưởng phòng sẽ tiến hành phê duyệt.');">
                                <input type="hidden" name="requestId" value="${tr.transferRequestId}">
                                <button type="submit" class="btn-accept">
                                    <i class="fas fa-check-circle"></i> Xác nhận đồng ý
                                </button>
                            </form>

                            <!-- Từ chối toggle -->
                            <button type="button" class="btn-reject-toggle"
                                    onclick="toggleRejectForm('reject-form-${tr.transferRequestId}', this)">
                                <i class="fas fa-times-circle"></i> Từ chối
                            </button>

                            <!-- Reject form (hidden) -->
                            <div class="reject-form-wrap" id="reject-form-${tr.transferRequestId}">
                                <form method="post"
                                      action="${pageContext.request.contextPath}/employee/transfer-confirm/reject"
                                      style="margin:0">
                                    <input type="hidden" name="requestId" value="${tr.transferRequestId}">
                                    <label class="form-label" for="rejectReason-${tr.transferRequestId}">
                                        <i class="fas fa-comment-slash"></i> Lý do từ chối <span style="color:var(--ng)">*</span>
                                    </label>
                                    <textarea id="rejectReason-${tr.transferRequestId}"
                                              name="rejectReason"
                                              class="form-control"
                                              placeholder="Vui lòng giải thích lý do bạn từ chối yêu cầu điều chuyển này..."
                                              required></textarea>
                                    <div class="reject-btn-row">
                                        <button type="button" class="btn-cancel-reject"
                                                onclick="toggleRejectForm('reject-form-${tr.transferRequestId}', null)">
                                            Huỷ bỏ
                                        </button>
                                        <button type="submit" class="btn-confirm-reject">
                                            <i class="fas fa-times"></i> Xác nhận từ chối
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
    function toggleRejectForm(formId, triggerBtn) {
        var form = document.getElementById(formId);
        var isOpen = form.classList.contains('open');
        if (isOpen) {
            form.classList.remove('open');
        } else {
            form.classList.add('open');
            // Scroll đến form
            setTimeout(function() {
                form.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }, 50);
        }
    }
</script>

<jsp:include page="../footer.jsp" />

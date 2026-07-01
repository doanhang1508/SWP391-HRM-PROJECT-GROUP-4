<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chi Tiết Phê Duyệt Điều Chuyển" scope="request" />
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
        --indigo:  #4f46e5;
        --danger-light: #fff1f2;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }

    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb  { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }

    .alert { padding: 14px 20px; border-radius: 12px; font-size: 0.9rem; font-weight: 500; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; }
    .alert-danger  { background: var(--danger-light); border: 1px solid #fecdd3; color: #9f1239; }

    /* LAYOUT */
    .detail-layout { display: flex; gap: 24px; align-items: flex-start; }
    .panel-main    { flex: 1; min-width: 0; }
    .panel-side    { width: 320px; flex-shrink: 0; }

    /* PANEL */
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 28px 32px; box-shadow: 0 6px 20px rgba(10,37,64,0.05); margin-bottom: 20px; }

    .panel-icon-wrap { width: 52px; height: 52px; background: rgba(99,102,241,0.1); border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; color: var(--pri); margin: 0 auto 18px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.2rem; font-weight: 800; color: var(--navy); margin: 0 0 6px; text-align: center; }
    .panel-subtitle { font-size: 0.83rem; color: var(--muted); text-align: center; margin-bottom: 24px; }

    /* TIMELINE */
    .timeline { display: flex; flex-direction: column; gap: 0; }
    .tl-item  { display: flex; gap: 16px; position: relative; }
    .tl-item:not(:last-child) .tl-line { position: absolute; left: 19px; top: 40px; bottom: -8px; width: 2px; background: #e2e8f0; }
    .tl-dot   { width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1rem; flex-shrink: 0; z-index: 1; }
    .tl-dot.done    { background: var(--ok); color: #fff; }
    .tl-dot.active  { background: var(--pri); color: #fff; box-shadow: 0 0 0 4px rgba(99,102,241,0.2); }
    .tl-dot.pending { background: #e2e8f0; color: var(--muted); }
    .tl-body  { flex: 1; padding-bottom: 24px; }
    .tl-label { font-weight: 700; font-size: 0.88rem; color: var(--navy); margin-bottom: 2px; }
    .tl-sub   { font-size: 0.78rem; color: var(--muted); }
    .tl-sub strong { color: var(--navy); }

    /* COMPARE CARD */
    .compare-card { display: flex; border: 1px solid var(--border); border-radius: 12px; margin-bottom: 20px; overflow: hidden; }
    .compare-side { flex: 1; padding: 18px; }
    .compare-side.old { background: #f8fafc; border-right: 1px solid var(--border); }
    .compare-side.new { background: #f0fdf4; }
    .compare-side-title { font-size: 0.71rem; font-weight: 700; text-transform: uppercase; color: var(--muted); margin-bottom: 10px; letter-spacing: 0.5px; }
    .compare-item { margin-bottom: 10px; }
    .compare-item:last-child { margin-bottom: 0; }
    .compare-label { font-size: 0.73rem; color: var(--muted); margin-bottom: 2px; }
    .compare-val   { font-size: 0.92rem; font-weight: 700; color: var(--navy); }

    /* DETAIL LIST */
    .detail-row { display: flex; justify-content: space-between; border-bottom: 1px solid #f1f5f9; padding: 11px 0; font-size: 0.85rem; }
    .detail-row:last-child { border-bottom: none; }
    .detail-label { color: var(--muted); font-weight: 500; }
    .detail-val   { color: var(--navy); font-weight: 600; text-align: right; max-width: 60%; word-break: break-word; }

    .reason-box { background: #f8fafc; border: 1px solid var(--border); border-radius: 10px; padding: 14px; margin-bottom: 20px; font-size: 0.88rem; line-height: 1.5; color: #334155; }
    .reason-box-title { font-weight: 700; font-size: 0.8rem; color: var(--navy); text-transform: uppercase; margin-bottom: 6px; letter-spacing: 0.5px; }

    /* FORMS */
    .form-group  { margin-bottom: 14px; }
    .form-label  { display: block; font-size: .84rem; font-weight: 600; color: var(--navy); margin-bottom: 7px; }
    .form-control { width: 100%; padding: 11px 13px; border: 1px solid var(--border); border-radius: 10px; font-size: .88rem; font-family: 'Inter', sans-serif; outline: none; transition: all .2s; background: #f8fafc; color: var(--text); }
    .form-control:focus { border-color: var(--ng); box-shadow: 0 0 0 3px rgba(239,68,68,0.15); background: #fff; }
    textarea.form-control { resize: vertical; min-height: 80px; }

    .btn-approve  { background: var(--ok); color: #fff; border: none; padding: 12px 20px; border-radius: 10px; font-weight: 700; font-size: .9rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; transition: all .2s; width: 100%; box-shadow: 0 4px 12px rgba(16,185,129,.2); }
    .btn-approve:hover  { background: var(--ok-dark); transform: translateY(-1px); }
    .btn-confirm { background: var(--indigo); color: #fff; border: none; padding: 12px 20px; border-radius: 10px; font-weight: 700; font-size: .9rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; transition: all .2s; width: 100%; box-shadow: 0 4px 12px rgba(79,70,229,.2); }
    .btn-confirm:hover  { background: #4338ca; transform: translateY(-1px); }
    .btn-reject  { background: var(--ng); color: #fff; border: none; padding: 12px 20px; border-radius: 10px; font-weight: 700; font-size: .9rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; transition: all .2s; width: 100%; box-shadow: 0 4px 12px rgba(239,68,68,.2); }
    .btn-reject:hover   { background: var(--ng-dark); transform: translateY(-1px); }
    .btn-back { display: inline-flex; align-items: center; gap: 8px; background: rgba(100,116,139,0.1); color: var(--muted); border: none; padding: 10px 18px; border-radius: 10px; font-weight: 600; font-size: .85rem; text-decoration: none; transition: all .2s; }
    .btn-back:hover { background: #e2e8f0; color: var(--text); }

    .divider { height: 1px; background: var(--border); margin: 20px 0; }
    .readonly-notice { background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px; padding: 12px 16px; font-size: 0.83rem; color: #92400e; display: flex; gap: 10px; align-items: flex-start; margin-top: 16px; }

    @media (max-width:1024px) {
        .detail-layout { flex-direction: column; }
        .panel-side { width: 100%; }
    }
    @media (max-width:700px) {
        .page-main { padding: 20px 16px; }
        .panel { padding: 20px; }
        .compare-card { flex-direction: column; }
        .compare-side.old { border-right: none; border-bottom: 1px solid var(--border); }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="transfer-approvals" />
    </jsp:include>

    <div class="page-main">
        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/manager/transfer-approvals">Phê duyệt</a>
                    <span>/</span>
                    <span>Chi tiết yêu cầu</span>
                </div>
                <h1><i class="fas fa-clipboard-list" style="color:var(--pri);margin-right:10px;font-size:1.3rem;"></i>Chi Tiết Yêu Cầu Điều Chuyển</h1>
            </div>
            <a href="${pageContext.request.contextPath}/manager/transfer-approvals" class="btn-back">
                <i class="fas fa-arrow-left"></i> Quay lại danh sách
            </a>
        </div>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle" style="font-size:1.2rem;"></i>
                ${sessionScope.errorMessage}
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <div class="detail-layout">
            <!-- LEFT: Thông tin yêu cầu -->
            <div class="panel-main">
                <div class="panel">
                    <div class="panel-icon-wrap"><i class="fas fa-user-tag"></i></div>
                    <h2 class="panel-title">Chi Tiết Đề Xuất Điều Chuyển</h2>
                    <p class="panel-subtitle">Yêu cầu #${req.transferRequestId} — Tạo lúc <fmt:formatDate value="${req.createdAt}" pattern="HH:mm dd/MM/yyyy" /></p>

                    <!-- BASIC INFO -->
                    <div class="detail-row">
                        <span class="detail-label">Nhân viên được điều chuyển:</span>
                        <span class="detail-val">${req.employeeName} (#${req.employeeId})</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Người đề xuất (HR):</span>
                        <span class="detail-val">${req.requestedByName}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Ngày hiệu lực dự kiến:</span>
                        <span class="detail-val" style="color:var(--pri)">
                            <fmt:formatDate value="${req.effectiveDate}" pattern="dd/MM/yyyy" />
                        </span>
                    </div>

                    <div class="divider"></div>

                    <!-- COMPARISON -->
                    <div class="compare-card">
                        <div class="compare-side old">
                            <div class="compare-side-title"><i class="fas fa-history"></i> Vị trí hiện tại</div>
                            <div class="compare-item">
                                <div class="compare-label">Phòng ban</div>
                                <div class="compare-val">${req.oldDepartmentName}</div>
                            </div>
                            <div class="compare-item">
                                <div class="compare-label">Chức vụ</div>
                                <div class="compare-val">${req.oldPositionName}</div>
                            </div>
                            <div class="compare-item">
                                <div class="compare-label">Quyền hạn</div>
                                <div class="compare-val">${not empty req.oldRoleName ? req.oldRoleName : '—'}</div>
                            </div>
                        </div>
                        <div class="compare-side new">
                            <div class="compare-side-title" style="color:var(--ok-dark)"><i class="fas fa-route"></i> Vị trí điều chuyển</div>
                            <div class="compare-item">
                                <div class="compare-label">Phòng ban mới</div>
                                <div class="compare-val" style="color:var(--ok-dark)">${req.newDepartmentName}</div>
                            </div>
                            <div class="compare-item">
                                <div class="compare-label">Chức vụ mới</div>
                                <div class="compare-val" style="color:var(--ok-dark)">${req.newPositionName}</div>
                            </div>
                            <div class="compare-item">
                                <div class="compare-label">Quyền hạn mới</div>
                                <div class="compare-val" style="color:var(--ok-dark)">${req.newRoleName}</div>
                            </div>
                        </div>
                    </div>

                    <!-- SALARY (if changed) -->
                    <c:if test="${req.newSalaryGradeId != null}">
                        <div class="reason-box" style="border-color:rgba(99,102,241,0.3);background:rgba(99,102,241,0.04)">
                            <div class="reason-box-title" style="color:var(--pri)"><i class="fas fa-coins"></i> Thay đổi ngạch lương</div>
                            <div>Ngạch mới: <strong>#${req.newSalaryGradeId}</strong>
                            <c:if test="${req.newBaseSalary != null}">
                                — Lương cơ bản mới: <strong><fmt:formatNumber value="${req.newBaseSalary}" type="currency" currencySymbol="" minFractionDigits="0" maxFractionDigits="0" /> VNĐ</strong>
                            </c:if>
                            </div>
                        </div>
                    </c:if>

                    <!-- REASON -->
                    <div class="reason-box">
                        <div class="reason-box-title"><i class="far fa-comment-alt"></i> Lý do điều chuyển</div>
                        <div>${req.reason}</div>
                    </div>

                    <!-- REJECT REASON (if any) -->
                    <c:if test="${not empty req.rejectReason}">
                        <div class="reason-box" style="background:#fff1f2;border-color:#fecdd3;">
                            <div class="reason-box-title" style="color:var(--ng)"><i class="fas fa-times-circle"></i> Lý do từ chối</div>
                            <div>${req.rejectReason}</div>
                        </div>
                    </c:if>

                    <!-- WORK HISTORY LINK -->
                    <div style="text-align:center;margin-top:8px;">
                        <a href="${pageContext.request.contextPath}/manager/employee-work-history?userId=${req.employeeId}" target="_blank"
                           style="color:var(--blue);font-weight:700;text-decoration:none;font-size:0.85rem;">
                            <i class="fas fa-history"></i> Xem lịch sử công tác của nhân viên này
                        </a>
                    </div>
                </div>
            </div>

            <!-- RIGHT: Timeline + Action -->
            <div class="panel-side">
                <!-- TIMELINE PANEL -->
                <div class="panel">
                    <h3 style="font-family:'Be Vietnam Pro',sans-serif;font-size:1rem;font-weight:800;color:var(--navy);margin:0 0 20px;">
                        <i class="fas fa-route" style="color:var(--pri);margin-right:8px;"></i>Tiến trình duyệt
                    </h3>
                    <div class="timeline">
                        <!-- Step 0: Tạo đơn -->
                        <div class="tl-item">
                            <div class="tl-line"></div>
                            <div class="tl-dot done"><i class="fas fa-pen"></i></div>
                            <div class="tl-body">
                                <div class="tl-label">HR tạo yêu cầu</div>
                                <div class="tl-sub">Bởi <strong>${req.requestedByName}</strong><br>
                                    <fmt:formatDate value="${req.createdAt}" pattern="HH:mm dd/MM/yyyy" /></div>
                            </div>
                        </div>

                        <!-- Step 1: Trưởng phòng -->
                        <c:choose>
                            <c:when test="${req.status eq 'PENDING'}">
                                <div class="tl-item">
                                    <div class="tl-line"></div>
                                    <div class="tl-dot active"><i class="fas fa-user-tie"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label">Trưởng phòng duyệt</div>
                                        <div class="tl-sub" style="color:var(--warn);font-weight:600;">Đang chờ phê duyệt...</div>
                                    </div>
                                </div>
                                <div class="tl-item">
                                    <div class="tl-dot pending"><i class="fas fa-user-shield"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label" style="color:var(--muted);">HR Manager xác nhận cuối</div>
                                        <div class="tl-sub">Chưa đến lượt</div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${req.status eq 'MANAGER_APPROVED'}">
                                <div class="tl-item">
                                    <div class="tl-line"></div>
                                    <div class="tl-dot done"><i class="fas fa-user-check"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label">Trưởng phòng đã duyệt</div>
                                        <div class="tl-sub">Bởi <strong>${req.managerApprovedByName}</strong><br>
                                            <fmt:formatDate value="${req.managerApprovedAt}" pattern="HH:mm dd/MM/yyyy" /></div>
                                    </div>
                                </div>
                                <div class="tl-item">
                                    <div class="tl-dot active"><i class="fas fa-user-shield"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label">HR Manager xác nhận cuối</div>
                                        <div class="tl-sub" style="color:var(--indigo);font-weight:600;">Đang chờ xác nhận...</div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${req.status eq 'APPROVED'}">
                                <div class="tl-item">
                                    <div class="tl-line"></div>
                                    <div class="tl-dot done"><i class="fas fa-user-check"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label">Trưởng phòng đã duyệt</div>
                                        <div class="tl-sub">Bởi <strong>${req.managerApprovedByName}</strong><br>
                                            <fmt:formatDate value="${req.managerApprovedAt}" pattern="HH:mm dd/MM/yyyy" /></div>
                                    </div>
                                </div>
                                <div class="tl-item">
                                    <div class="tl-dot done"><i class="fas fa-check-double"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label" style="color:var(--ok);">Điều chuyển hoàn tất ✓</div>
                                        <div class="tl-sub">Xác nhận bởi <strong>${req.approvedByName}</strong><br>
                                            <fmt:formatDate value="${req.approvedAt}" pattern="HH:mm dd/MM/yyyy" /></div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${req.status eq 'REJECTED'}">
                                <div class="tl-item">
                                    <div class="tl-dot" style="background:var(--ng);color:#fff;"><i class="fas fa-times"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label" style="color:var(--ng);">Trưởng phòng từ chối</div>
                                        <div class="tl-sub">Bởi <strong>${req.approvedByName}</strong><br>
                                            <fmt:formatDate value="${req.approvedAt}" pattern="HH:mm dd/MM/yyyy" /></div>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise><%-- HR_REJECTED --%>
                                <div class="tl-item">
                                    <div class="tl-line"></div>
                                    <div class="tl-dot done"><i class="fas fa-user-check"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label">Trưởng phòng đã duyệt</div>
                                        <div class="tl-sub">Bởi <strong>${req.managerApprovedByName}</strong><br>
                                            <fmt:formatDate value="${req.managerApprovedAt}" pattern="HH:mm dd/MM/yyyy" /></div>
                                    </div>
                                </div>
                                <div class="tl-item">
                                    <div class="tl-dot" style="background:var(--ng);color:#fff;"><i class="fas fa-times"></i></div>
                                    <div class="tl-body">
                                        <div class="tl-label" style="color:var(--ng);">HR Manager từ chối</div>
                                        <div class="tl-sub">Bởi <strong>${req.approvedByName}</strong><br>
                                            <fmt:formatDate value="${req.approvedAt}" pattern="HH:mm dd/MM/yyyy" /></div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- ACTION PANEL -->
                <c:choose>
                    <%-- Đơn đã kết thúc (không cần hành động) --%>
                    <c:when test="${req.status eq 'APPROVED' or req.status eq 'REJECTED' or req.status eq 'HR_REJECTED' or req.status eq 'CANCELLED'}">
                        <div class="panel">
                            <c:choose>
                                <c:when test="${req.status eq 'APPROVED'}">
                                    <div style="text-align:center;color:var(--ok);padding:20px 0;">
                                        <i class="fas fa-check-circle" style="font-size:2.5rem;"></i>
                                        <div style="font-weight:700;margin-top:10px;">Điều chuyển đã hoàn tất</div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="text-align:center;color:var(--ng);padding:20px 0;">
                                        <i class="fas fa-times-circle" style="font-size:2.5rem;"></i>
                                        <div style="font-weight:700;margin-top:10px;">Yêu cầu đã bị từ chối</div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:when>

                    <%--
                        BƯỚC 1: Duyệt Trưởng phòng — hiển thị khi:
                        a) Trưởng phòng thuần (role 3/6, đơn PENDING, cùng phòng)
                        b) HR Manager kiêm Trưởng phòng (hrActingAsDeptHead=true, đơn PENDING)
                    --%>
                    <c:when test="${req.status eq 'PENDING' and ((currentRoleId eq 3 or currentRoleId eq 6) or hrActingAsDeptHead)}">
                        <div class="panel">
                            <h3 style="font-family:'Be Vietnam Pro',sans-serif;font-size:1rem;font-weight:800;color:var(--navy);margin:0 0 16px;">
                                <i class="fas fa-gavel" style="color:var(--pri);margin-right:8px;"></i>Hành động (Bước 1 — Trưởng phòng)
                            </h3>

                            <c:if test="${hrActingAsDeptHead}">
                                <div style="background:rgba(245,158,11,0.1);border:1px solid rgba(245,158,11,0.3);border-radius:10px;padding:12px 14px;margin-bottom:16px;font-size:0.82rem;color:#92400e;">
                                    <i class="fas fa-info-circle"></i>
                                    Bạn đang duyệt bước 1 <strong>với tư cách Trưởng phòng</strong> (vì bạn là HR Manager kiêm quản lý phòng này).
                                    Sau khi duyệt bước 1, bạn cần quay lại để <strong>xác nhận cuối (bước 2) với tư cách HR Manager</strong>.
                                </div>
                            </c:if>

                            <!-- APPROVE STEP 1 -->
                            <form action="${pageContext.request.contextPath}/manager/transfer-approval/approve" method="post"
                                  onsubmit="return confirm('Bạn xác nhận DUYỆT bước 1 cho yêu cầu này? Đơn sẽ được chuyển lên HR Manager xác nhận cuối.');">
                                <input type="hidden" name="requestId" value="${req.transferRequestId}">
                                <button type="submit" class="btn-approve">
                                    <i class="fas fa-check-circle"></i> Duyệt — chuyển HR Manager
                                </button>
                            </form>

                            <div class="divider"></div>

                            <!-- REJECT STEP 1 -->
                            <button type="button" class="btn-reject" onclick="toggleRejectForm()">
                                <i class="fas fa-times-circle"></i> Từ chối yêu cầu
                            </button>

                            <div id="rejectFormContainer" style="display:none;margin-top:16px;padding:16px;border:1px solid var(--border);border-radius:12px;background:#fffbeb;">
                                <form action="${pageContext.request.contextPath}/manager/transfer-approval/reject" method="post">
                                    <input type="hidden" name="requestId" value="${req.transferRequestId}">
                                    <div class="form-group">
                                        <label class="form-label" for="rejectReason1" style="color:#92400e;">Lý do từ chối *</label>
                                        <textarea id="rejectReason1" name="rejectReason" class="form-control" placeholder="Nhập lý do từ chối..." required></textarea>
                                    </div>
                                    <div style="display:flex;gap:10px;justify-content:flex-end;">
                                        <button type="button" style="background:#e2e8f0;color:#475569;border:none;padding:9px 14px;border-radius:8px;font-weight:600;cursor:pointer;" onclick="toggleRejectForm()">Huỷ bỏ</button>
                                        <button type="submit" class="btn-reject" style="width:auto;">Xác nhận từ chối</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:when>

                    <%-- BƯỚC 2: HR Manager xác nhận cuối (role 2, đơn MANAGER_APPROVED) --%>
                    <c:when test="${currentRoleId eq 2 and req.status eq 'MANAGER_APPROVED'}">
                        <div class="panel">
                            <h3 style="font-family:'Be Vietnam Pro',sans-serif;font-size:1rem;font-weight:800;color:var(--navy);margin:0 0 16px;">
                                <i class="fas fa-gavel" style="color:var(--indigo);margin-right:8px;"></i>Hành động (Bước 2 — Xác nhận cuối)
                            </h3>
                            <p style="font-size:0.82rem;color:var(--muted);margin-bottom:16px;">
                                <i class="fas fa-info-circle"></i>
                                Đơn đã được Trưởng phòng <strong>${req.managerApprovedByName}</strong> duyệt bước 1.
                                Xác nhận sẽ <strong>thực thi ngay lập tức</strong>: cập nhật hồ sơ, lịch sử công tác và hợp đồng.
                            </p>

                            <!-- CONFIRM (FINAL APPROVE) -->
                            <form action="${pageContext.request.contextPath}/manager/transfer-approval/approve" method="post"
                                  onsubmit="return confirm('Bạn xác nhận HOÀN TẤT yêu cầu điều chuyển này? Hành động này sẽ cập nhật hồ sơ nhân viên, lịch sử công tác và tạo phụ lục hợp đồng ngay lập tức.');">
                                <input type="hidden" name="requestId" value="${req.transferRequestId}">
                                <button type="submit" class="btn-confirm">
                                    <i class="fas fa-check-double"></i> Xác nhận &amp; Thực thi điều chuyển
                                </button>
                            </form>

                            <div class="divider"></div>

                            <!-- HR REJECT -->
                            <button type="button" class="btn-reject" onclick="toggleRejectForm()">
                                <i class="fas fa-times-circle"></i> Từ chối (HR Manager)
                            </button>

                            <div id="rejectFormContainer" style="display:none;margin-top:16px;padding:16px;border:1px solid var(--border);border-radius:12px;background:#fffbeb;">
                                <form action="${pageContext.request.contextPath}/manager/transfer-approval/reject" method="post">
                                    <input type="hidden" name="requestId" value="${req.transferRequestId}">
                                    <div class="form-group">
                                        <label class="form-label" for="rejectReason2" style="color:#92400e;">Lý do từ chối (HR Manager) *</label>
                                        <textarea id="rejectReason2" name="rejectReason" class="form-control" placeholder="Nhập lý do HR Manager từ chối..." required></textarea>
                                    </div>
                                    <div style="display:flex;gap:10px;justify-content:flex-end;">
                                        <button type="button" style="background:#e2e8f0;color:#475569;border:none;padding:9px 14px;border-radius:8px;font-weight:600;cursor:pointer;" onclick="toggleRejectForm()">Huỷ bỏ</button>
                                        <button type="submit" class="btn-reject" style="width:auto;">Xác nhận từ chối</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:when>

                    <%-- Read-only --%>
                    <c:otherwise>
                        <div class="panel">
                            <div class="readonly-notice">
                                <i class="fas fa-eye" style="margin-top:2px;"></i>
                                <div>Bạn đang xem ở chế độ <strong>Chỉ đọc</strong>. Đơn này không ở trạng thái cần bạn xử lý.</div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<script>
    function toggleRejectForm() {
        var form = document.getElementById("rejectFormContainer");
        if (!form) return;
        form.style.display = (form.style.display === "none" || form.style.display === "") ? "block" : "none";
        if (form.style.display === "block") form.scrollIntoView({ behavior: 'smooth' });
    }
</script>

<jsp:include page="../footer.jsp" />

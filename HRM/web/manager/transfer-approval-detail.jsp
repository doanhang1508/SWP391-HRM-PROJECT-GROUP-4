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
        --accent:  #3ecf8e;
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
        --danger-light: #fff1f2;
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
    .alert-danger { background: var(--danger-light); border: 1px solid #fecdd3; color: #9f1239; }

    /* PANEL */
    .panel-container { display: flex; justify-content: center; align-items: flex-start; margin-top: 20px; }
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 36px 40px; width: 100%; max-width: 700px; box-shadow: 0 10px 25px rgba(10,37,64,0.05); }

    .panel-icon-wrap { width: 56px; height: 56px; background: rgba(99, 102, 241, 0.1); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; color: var(--pri); margin: 0 auto 20px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.3rem; font-weight: 800; color: var(--navy); margin: 0 0 8px; text-align: center; }
    .panel-subtitle { font-size: 0.85rem; color: var(--muted); text-align: center; margin-bottom: 30px; }

    /* COMPARISON GRID */
    .compare-card { display: flex; border: 1px solid var(--border); border-radius: 12px; margin-bottom: 24px; overflow: hidden; }
    .compare-side { flex: 1; padding: 20px; }
    .compare-side.old { background: #f8fafc; border-right: 1px solid var(--border); }
    .compare-side.new { background: #f0fdf4; }
    .compare-side-title { font-size: 0.72rem; font-weight: 700; text-transform: uppercase; color: var(--muted); margin-bottom: 12px; letter-spacing: 0.5px; }
    .compare-item { margin-bottom: 12px; }
    .compare-item:last-child { margin-bottom: 0; }
    .compare-label { font-size: 0.75rem; color: var(--muted); margin-bottom: 2px; }
    .compare-val { font-size: 0.95rem; font-weight: 700; color: var(--navy); }
    
    /* DETAIL LIST */
    .detail-row { display: flex; justify-content: space-between; border-bottom: 1px solid #f1f5f9; padding: 12px 0; font-size: 0.88rem; }
    .detail-row:last-child { border-bottom: none; }
    .detail-label { color: var(--muted); font-weight: 500; }
    .detail-val { color: var(--navy); font-weight: 600; text-align: right; }

    .reason-box { background: #f8fafc; border: 1px solid var(--border); border-radius: 10px; padding: 16px; margin-bottom: 28px; font-size: 0.9rem; line-height: 1.5; color: #334155; }
    .reason-box-title { font-weight: 700; font-size: 0.82rem; color: var(--navy); text-transform: uppercase; margin-bottom: 8px; letter-spacing: 0.5px; }

    /* FORMS */
    .form-group { margin-bottom: 16px; }
    .form-label { display: block; font-size: .85rem; font-weight: 600; color: var(--navy); margin-bottom: 8px; }
    .form-control { width: 100%; padding: 12px 14px; border: 1px solid var(--border); border-radius: 10px; font-size: .9rem; font-family: 'Inter', sans-serif; outline: none; transition: all .2s; background: #f8fafc; color: var(--text); }
    .form-control:focus { border-color: var(--ng); box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15); background: #ffffff; }
    textarea.form-control { resize: vertical; min-height: 80px; }

    .btn-approve { background: var(--ok); color: #fff; border: none; padding: 12px 20px; border-radius: 10px; font-weight: 700; font-size: .9rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; transition: all .2s; width: 100%; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2); }
    .btn-approve:hover { background: var(--ok-dark); transform: translateY(-1px); box-shadow: 0 6px 15px rgba(16, 185, 129, 0.3); }

    .btn-reject { background: var(--ng); color: #fff; border: none; padding: 12px 20px; border-radius: 10px; font-weight: 700; font-size: .9rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; transition: all .2s; width: 100%; box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2); }
    .btn-reject:hover { background: var(--ng-dark); transform: translateY(-1px); box-shadow: 0 6px 15px rgba(239, 68, 68, 0.3); }

    .divider { height: 1px; background: var(--border); margin: 24px 0; }
    .btn-back { display: inline-flex; align-items: center; gap: 8px; background: rgba(100,116,139,0.1); color: var(--muted); border: none; padding: 10px 18px; border-radius: 10px; font-weight: 600; font-size: .85rem; text-decoration: none; transition: all .2s; }
    .btn-back:hover { background: #e2e8f0; color: var(--text); }
    
    .status-banner { text-align: center; padding: 16px; border-radius: 12px; font-weight: 700; font-size: 0.95rem; margin-top: 12px; }
    .status-banner.approved { background: rgba(16, 185, 129, 0.1); color: var(--ok-dark); border: 1px solid rgba(16, 185, 129, 0.3); }
    .status-banner.rejected { background: rgba(239, 68, 68, 0.1); color: var(--ng-dark); border: 1px solid rgba(239, 68, 68, 0.3); }
    .status-banner.pending-hr { background: rgba(99, 102, 241, 0.1); color: var(--pri-dark); border: 1px solid rgba(99, 102, 241, 0.3); }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .panel { padding: 24px; }
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

        <div class="panel-container">
            <div class="panel">
                <div class="panel-icon-wrap">
                    <i class="fas fa-user-tag"></i>
                </div>
                <h2 class="panel-title">Chi Tiết Đề Xuất Điều Chuyển</h2>
                <p class="panel-subtitle">Vui lòng kiểm tra kỹ thông tin trước khi ra quyết định duyệt hoặc từ chối.</p>

                <!-- EMPLOYEE DETAILS -->
                <div class="detail-row">
                    <span class="detail-label">Nhân viên đề xuất:</span>
                    <span class="detail-val">${req.employeeName} (#${req.employeeId})</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Người đề xuất (HR):</span>
                    <span class="detail-val">${req.requestedByName}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Ngày hiệu lực dự kiến:</span>
                    <span class="detail-val" style="color: var(--pri)">
                        <fmt:formatDate value="${req.effectiveDate}" pattern="dd/MM/yyyy" />
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Thời gian tạo yêu cầu:</span>
                    <span class="detail-val">
                        <fmt:formatDate value="${req.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                    </span>
                </div>

                <div class="divider"></div>

                <!-- DEPT & POSITION COMPARISON -->
                <div class="compare-card">
                    <!-- OLD POSITION -->
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
                            <div class="compare-val">${req.oldRoleName != null ? req.oldRoleName : '-'}</div>
                        </div>
                    </div>
                    
                    <!-- NEW POSITION -->
                    <div class="compare-side new">
                        <div class="compare-side-title" style="color: var(--ok-dark)"><i class="fas fa-route"></i> Vị trí điều chuyển</div>
                        <div class="compare-item">
                            <div class="compare-label">Phòng ban mới</div>
                            <div class="compare-val" style="color: var(--ok-dark)">${req.newDepartmentName}</div>
                        </div>
                        <div class="compare-item">
                            <div class="compare-label">Chức vụ mới</div>
                            <div class="compare-val" style="color: var(--ok-dark)">${req.newPositionName}</div>
                        </div>
                        <div class="compare-item">
                            <div class="compare-label">Quyền hạn mới</div>
                            <div class="compare-val" style="color: var(--ok-dark)">${req.newRoleName}</div>
                        </div>
                    </div>
                </div>

                <!-- SALARY CHANGE IF APPLICABLE -->
                <c:if test="${req.newSalaryGradeId != null}">
                    <div class="reason-box" style="border-color: rgba(99,102,241,0.3); background: rgba(99,102,241,0.04);">
                        <div class="reason-box-title" style="color: var(--pri);"><i class="fas fa-coins"></i> Thay đổi ngạch lương</div>
                        <div>Ngạch mới: <strong>#${req.newSalaryGradeId}</strong>
                        <c:if test="${req.newBaseSalary != null}">
                            — Lương cơ bản mới: <strong><fmt:formatNumber value="${req.newBaseSalary}" type="currency" currencySymbol="" minFractionDigits="0" maxFractionDigits="0" /> VNĐ</strong>
                        </c:if>
                        </div>
                    </div>
                </c:if>

                <!-- REASON BOX -->
                <div class="reason-box">
                    <div class="reason-box-title"><i class="far fa-comment-alt"></i> Lý do điều chuyển</div>
                    <div>${req.reason}</div>
                </div>

                <!-- EMPLOYEE CONFIRMATION STATUS -->
                <c:choose>
                    <c:when test="${req.employeeConfirmedAt != null}">
                        <div class="reason-box" style="border-color: rgba(16,185,129,0.3); background: rgba(16,185,129,0.04);">
                            <div class="reason-box-title" style="color: var(--ok-dark);"><i class="fas fa-user-check"></i> Nhân viên đã xác nhận đồng ý</div>
                            <div>Vào lúc: <strong><fmt:formatDate value="${req.employeeConfirmedAt}" pattern="dd/MM/yyyy HH:mm" /></strong></div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="reason-box" style="border-color: rgba(245,158,11,0.3); background: rgba(245,158,11,0.04);">
                            <div class="reason-box-title" style="color: #92400e;"><i class="far fa-clock"></i> Chưa có phản hồi từ nhân viên</div>
                            <div>Nhân viên chưa xác nhận hoặc từ chối yêu cầu này.</div>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- VIEW WORK HISTORY LINK -->
                <div class="form-group" style="text-align: center; margin-bottom: 24px;">
                    <a href="${pageContext.request.contextPath}/manager/employee-work-history?userId=${req.employeeId}" target="_blank" style="color: var(--blue); font-weight: 700; text-decoration: none; font-size: 0.88rem;">
                        <i class="fas fa-history"></i> Xem Lịch sử công tác của nhân viên này
                    </a>
                </div>

                <div class="divider"></div>

                <!-- DYNAMIC ACTION FORMS BASED ON STATUS -->
                <c:choose>
                    <%-- 1. Đã hoàn tất áp dụng --%>
                    <c:when test="${req.status eq 'COMPLETED'}">
                        <div class="status-banner approved">
                            <i class="fas fa-check-double"></i> Điều chuyển đã được áp dụng.
                            <c:if test="${req.appliedAt != null}">
                                <div style="font-weight:normal; font-size:0.85rem; margin-top:6px;">
                                    Áp dụng lúc: <fmt:formatDate value="${req.appliedAt}" pattern="dd/MM/yyyy HH:mm" />
                                </div>
                            </c:if>
                        </div>
                    </c:when>
                    <%-- 2. Đã duyệt — chờ ngày hiệu lực --%>
                    <c:when test="${req.status eq 'APPROVED'}">
                        <div class="status-banner pending-hr" style="background: rgba(2,132,199,0.07); color: #0369a1; border-color: rgba(2,132,199,0.3);">
                            <i class="fas fa-hourglass-half"></i> Đã phê duyệt — chờ đến ngày hiệu lực
                            (<fmt:formatDate value="${req.effectiveDate}" pattern="dd/MM/yyyy" />).
                            Hệ thống sẽ tự động cập nhật vào ngày đó.
                        </div>
                    </c:when>
                    <%-- 3. Hoàn tất (cũ - giữ backward compat) --%>
                    <c:when test="${req.status eq 'APPROVED' and false}">
                        <div class="status-banner approved">
                            <i class="fas fa-check-circle"></i> Yêu cầu điều chuyển đã được hoàn tất phê duyệt &amp; thực thi.
                        </div>
                    </c:when>
                    <c:when test="${req.status eq 'REJECTED'}">
                        <div class="status-banner rejected">
                            <i class="fas fa-times-circle"></i> Yêu cầu đã bị từ chối.
                            <c:if test="${not empty req.rejectReason}">
                                <div style="font-weight:normal; font-size:0.85rem; margin-top:6px;">Lý do: ${req.rejectReason}</div>
                            </c:if>
                        </div>
                    </c:when>
                    <c:when test="${req.status eq 'EMPLOYEE_REJECTED'}">
                        <div class="status-banner rejected">
                            <i class="fas fa-user-times"></i> Nhân viên đã từ chối yêu cầu điều chuyển.
                            <c:if test="${not empty req.employeeRejectReason}">
                                <div style="font-weight:normal; font-size:0.85rem; margin-top:6px;">Lý do: ${req.employeeRejectReason}</div>
                            </c:if>
                        </div>
                    </c:when>
                    <c:when test="${req.status eq 'CANCELLED'}">
                        <div class="status-banner rejected" style="background:#e2e8f0; color:#475569; border-color:#cbd5e1;">
                            <i class="fas fa-ban"></i> Yêu cầu đã được huỷ bỏ bởi người tạo.
                        </div>
                    </c:when>
                    <c:when test="${req.status eq 'PENDING'}">
                        <div class="status-banner pending-hr">
                            <i class="fas fa-user-clock"></i> Đang chờ nhân viên xác nhận. Bạn chưa thể phê duyệt ở bước này.
                        </div>
                    </c:when>

                    <%-- 2. Read only notice --%>
                    <c:when test="${readOnly}">
                        <div class="status-banner pending-hr" style="background: #fffbeb; color: #b45309; border-color: #fde68a;">
                            <i class="fas fa-eye"></i> Bạn đang xem ở chế độ chỉ đọc.
                        </div>
                    </c:when>

                    <%-- 3. Trưởng phòng duyệt Bước 1 (EMPLOYEE_CONFIRMED) - tất cả role 2/3/6 đều được --%>
                    <c:when test="${req.status eq 'EMPLOYEE_CONFIRMED'}">
                        <div style="display: flex; gap: 16px;">
                            <div style="flex: 1;">
                                <form action="${pageContext.request.contextPath}/manager/transfer-approval/approve" method="post" onsubmit="return confirm('Bạn xác nhận DUYỆT bước 1? Đơn sẽ chuyển tiếp cho HR Manager xem xét lần cuối.');">
                                    <input type="hidden" name="requestId" value="${req.transferRequestId}">
                                    <button type="submit" class="btn-approve">
                                        <i class="fas fa-check-circle"></i> Duyệt
                                    </button>
                                </form>
                            </div>
                            <div style="flex: 1;">
                                <button type="button" class="btn-reject" onclick="toggleRejectForm()">
                                    <i class="fas fa-times-circle"></i> Từ chối duyệt
                                </button>
                            </div>
                        </div>
                    </c:when>

                    <%-- 4. HR Manager duyệt cuối (MANAGER_APPROVED) --%>
                    <c:when test="${req.status eq 'MANAGER_APPROVED' and currentRoleId eq 2}">
 
                        <div style="display: flex; gap: 16px;">
                            <div style="flex: 1;">
                                <form action="${pageContext.request.contextPath}/manager/transfer-approval/approve" method="post" onsubmit="return confirm('Bạn xác nhận PHÊ DUYỆT CUỐI cùng?\n\nNếu ngày hiệu lực đã tới: hồ sơ sẽ được cập nhật ngay.\nNếu ngày hiệu lực chưa tới: hệ thống sẽ tự động cập nhật đúng ngày.');">
                                    <input type="hidden" name="requestId" value="${req.transferRequestId}">
                                    <button type="submit" class="btn-approve">
                                        <i class="fas fa-check-circle"></i> Phê duyệt cuối
                                    </button>
                                </form>
                            </div>
                            <div style="flex: 1;">
                                <button type="button" class="btn-reject" onclick="toggleRejectForm()">
                                    <i class="fas fa-times-circle"></i> Từ chối duyệt
                                </button>
                            </div>
                        </div>
                    </c:when>
                </c:choose>

                <!-- REJECT FORM (HIDDEN BY DEFAULT) -->
                <div id="rejectFormContainer" style="display: none; margin-top: 24px; padding: 20px; border: 1px solid var(--border); border-radius: 12px; background: #fffbeb;">
                    <form action="${pageContext.request.contextPath}/manager/transfer-approval/reject" method="post">
                        <input type="hidden" name="requestId" value="${req.transferRequestId}">
                        
                        <div class="form-group">
                            <label class="form-label" for="rejectReason" style="color: #92400e;">Lý do từ chối *</label>
                            <textarea id="rejectReason" name="rejectReason" class="form-control" placeholder="Vui lòng nhập lý do từ chối yêu cầu..." required></textarea>
                        </div>
                        
                        <div style="display: flex; gap: 12px; justify-content: flex-end;">
                            <button type="button" class="btn-back" style="background: #e2e8f0; color: #475569; padding: 8px 16px;" onclick="toggleRejectForm()">Huỷ bỏ</button>
                            <button type="submit" class="btn-reject" style="width: auto; padding: 8px 20px;">Xác nhận từ chối</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function toggleRejectForm() {
        var form = document.getElementById("rejectFormContainer");
        if (form.style.display === "none" || form.style.display === "") {
            form.style.display = "block";
            form.scrollIntoView({ behavior: 'smooth' });
        } else {
            form.style.display = "none";
        }
    }
</script>

<jsp:include page="../footer.jsp" />
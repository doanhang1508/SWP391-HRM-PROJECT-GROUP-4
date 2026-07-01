<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Danh Sách Yêu Cầu Điều Chuyển" scope="request" />
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
        --pri-l:   rgba(99, 102, 241, 0.1);
        --ok:      #10b981;
        --ok-l:    rgba(16, 185, 129, 0.1);
        --ng:      #ef4444;
        --ng-l:    rgba(239, 68, 68, 0.1);
        --warn:    #f59e0b;
        --warn-l:  rgba(245, 158, 11, 0.1);
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

    /* BUTTON */
    .btn-create { display: inline-flex; align-items: center; gap: 8px; background: var(--pri); color: #fff; text-decoration: none; padding: 11px 20px; border-radius: 10px; font-weight: 700; font-size: 0.88rem; box-shadow: 0 4px 12px rgba(99,102,241,.2); transition: all .2s; }
    .btn-create:hover { background: #4f46e5; transform: translateY(-2px); box-shadow: 0 6px 15px rgba(99,102,241,.3); color: #fff; }

    /* ALERTS */
    .alert { padding: 14px 20px; border-radius: 12px; font-size: 0.9rem; font-weight: 500; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
    .alert-success { background: #d1fae5; border: 1px solid #a7f3d0; color: #065f46; }

    /* TABLE CARD */
    .card-table { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.02); }
    
    .tbl { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
    .tbl th { background: transparent; color: var(--muted); font-weight: 600; font-size: .75rem; text-transform: uppercase; letter-spacing: .5px; padding: 12px 16px; border: none; }
    .tbl td { background: #fff; padding: 14px 16px; vertical-align: middle; color: #334155; font-size: .875rem; border-top: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9; }
    .tbl tr td:first-child { border-left: 1px solid #f1f5f9; border-radius: 10px 0 0 10px; }
    .tbl tr td:last-child { border-right: 1px solid #f1f5f9; border-radius: 0 10px 10px 0; }
    .tbl tbody tr:hover td { background: #f8fafc; }

    /* BADGES */
    .badge-s { padding: 5px 12px; border-radius: 6px; font-weight: 700; font-size: .72rem; display: inline-flex; align-items: center; gap: 6px; }
    .b-pending   { background: var(--warn-l); color: var(--warn); }
    .b-emp-conf  { background: rgba(99, 102, 241, 0.1); color: #4f46e5; }
    .b-emp-rej   { background: var(--ng-l); color: var(--ng); }
    .b-mgr-appr  { background: rgba(59, 130, 246, 0.1); color: #1d4ed8; }
    .b-approved  { background: var(--ok-l); color: var(--ok); }
    .b-rejected  { background: var(--ng-l); color: var(--ng); }
    .b-cancelled { background: rgba(100, 116, 139, 0.1); color: #475569; }

    .transfer-arrow { color: var(--muted); margin: 0 6px; font-size: 0.8rem; }
    .btn-action { display: inline-flex; align-items: center; gap: 6px; background: rgba(59, 130, 246, 0.08); color: var(--blue); border: none; padding: 6px 12px; border-radius: 8px; font-weight: 600; font-size: .78rem; text-decoration: none; transition: all .2s; }
    .btn-action:hover { background: var(--blue); color: #fff; }
    /* [FIX #4] Nút Hủy request */
    .btn-cancel-req { display: inline-flex; align-items: center; gap: 6px; background: rgba(239, 68, 68, 0.08); color: var(--ng); border: none; padding: 6px 12px; border-radius: 8px; font-weight: 600; font-size: .78rem; cursor: pointer; transition: all .2s; font-family: 'Inter', sans-serif; }
    .btn-cancel-req:hover { background: var(--ng); color: #fff; }
    .td-actions { display: flex; flex-direction: column; gap: 6px; }

    .text-empty { text-align: center; color: var(--muted); padding: 40px 0; font-style: italic; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .card-table { padding: 16px; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="transfer-list" />
    </jsp:include>

    <div class="page-main">
        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <span>Yêu cầu điều chuyển</span>
                </div>
                <h1><i class="fas fa-exchange-alt" style="color:var(--pri);margin-right:10px;font-size:1.3rem;"></i>Lịch Sử Điều Chuyển Nhân Sự</h1>
            </div>
            
            <a href="${pageContext.request.contextPath}/hr/transfer-request/create" class="btn-create">
                <i class="fas fa-plus"></i> Tạo yêu cầu mới
            </a>
        </div>

        <c:if test="${param.msg eq 'create_success'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle" style="font-size:1.2rem;"></i>
                Gửi yêu cầu điều chuyển nội bộ thành công! Chờ bộ phận quản lý phê duyệt.
            </div>
        </c:if>
        <c:if test="${param.msg eq 'cancel_success'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle" style="font-size:1.2rem;"></i>
                Yêu cầu điều chuyển đã được hủy thành công.
            </div>
        </c:if>
        <c:if test="${param.msg eq 'cancel_error'}">
            <div class="alert" style="background:#fee2e2;border:1px solid #fecdd3;color:#9f1239;">
                <i class="fas fa-exclamation-circle" style="font-size:1.2rem;"></i>
                Không thể hủy yêu cầu. Yêu cầu có thể không còn ở trạng thái Chờ duyệt hoặc bạn không có quyền hủy.
            </div>
        </c:if>

        <!-- TABLE CARD -->
        <div class="card-table">
            <div class="table-responsive">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th style="width: 18%">Nhân viên</th>
                            <th style="width: 25%">Phòng ban (Cũ <i class="fas fa-arrow-right"></i> Mới)</th>
                            <th style="width: 25%">Chức vụ (Cũ <i class="fas fa-arrow-right"></i> Mới)</th>
                            <th style="width: 10%">Ngày hiệu lực</th>
                            <th style="width: 10%">Trạng thái</th>
                            <th style="width: 12%">Người yêu cầu</th>
                            <th style="width: 10%">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty transferList}">
                                <tr>
                                    <td colspan="7" class="text-empty">Không tìm thấy yêu cầu điều chuyển nào trong hệ thống.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${transferList}" var="tr">
                                    <tr>
                                        <td>
                                            <strong>${tr.employeeName}</strong>
                                            <div style="font-size: 0.75rem; color: var(--muted)">ID: #${tr.employeeId}</div>
                                        </td>
                                        <td>
                                            <span>${tr.oldDepartmentName}</span>
                                            <i class="fas fa-arrow-right transfer-arrow"></i>
                                            <strong>${tr.newDepartmentName}</strong>
                                        </td>
                                        <td>
                                            <span>${tr.oldPositionName}</span>
                                            <i class="fas fa-arrow-right transfer-arrow"></i>
                                            <strong>${tr.newPositionName}</strong>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${tr.effectiveDate}" pattern="dd/MM/yyyy" />
                                        </td>
                                        <td>
                                             <c:choose>
                                              <c:when test="${tr.status eq 'PENDING'}">
                                                  <span class="badge-s b-pending"><i class="far fa-clock"></i> Chờ NV xác nhận</span>
                                              </c:when>
                                              <c:when test="${tr.status eq 'EMPLOYEE_CONFIRMED'}">
                                                  <span class="badge-s b-emp-conf"><i class="fas fa-user-check"></i> NV đã xác nhận</span>
                                              </c:when>
                                              <c:when test="${tr.status eq 'MANAGER_APPROVED'}">
                                                  <span class="badge-s b-mgr-appr"><i class="fas fa-thumbs-up"></i> TP đã duyệt</span>
                                              </c:when>
                                              <c:when test="${tr.status eq 'APPROVED'}">
                                                  <span class="badge-s b-approved"><i class="fas fa-check"></i> Đã duyệt</span>
                                              </c:when>
                                              <c:when test="${tr.status eq 'EMPLOYEE_REJECTED'}">
                                                  <span class="badge-s b-emp-rej" title="${tr.employeeRejectReason}"><i class="fas fa-user-times"></i> NV từ chối</span>
                                              </c:when>
                                              <c:when test="${tr.status eq 'REJECTED' or tr.status eq 'HR_REJECTED'}">
                                                  <span class="badge-s b-rejected" title="${tr.rejectReason}"><i class="fas fa-times"></i> Bị từ chối</span>
                                              </c:when>
                                              <c:otherwise>
                                                  <span class="badge-s b-cancelled"><i class="fas fa-ban"></i> Đã huỷ</span>
                                              </c:otherwise>
                                          </c:choose>
                                        </td>
                                        <td>
                                            ${tr.requestedByName}
                                            <div style="font-size: 0.72rem; color: var(--muted)">
                                                <fmt:formatDate value="${tr.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </div>
                                        </td>
                                        <td>
                                            <div class="td-actions">
                                                <a href="${pageContext.request.contextPath}/hr/employee-work-history?userId=${tr.employeeId}" class="btn-action" title="Xem lịch sử công tác">
                                                    <i class="fas fa-history"></i> Lịch sử
                                                </a>
                                                 <%-- [FIX #4] Nút Hủy: hiện khi PENDING và (người tạo == currentUser HOẶC Admin/HR Manager) --%>
                                                 <c:if test="${tr.status eq 'PENDING' or tr.status eq 'EMPLOYEE_CONFIRMED'}">
                                                     <c:set var="cu" value="${sessionScope.currentUser}" />
                                                     <c:if test="${tr.requestedBy eq cu.userId or cu.roleId eq 1 or cu.roleId eq 2}">
                                                         <form method="post" action="${pageContext.request.contextPath}/hr/transfer-request/cancel"
                                                               onsubmit="return confirm('Bạn có chắc chắn muốn HỦY yêu cầu điều chuyển này không?');" style="margin:0">
                                                             <input type="hidden" name="requestId" value="${tr.transferRequestId}">
                                                             <button type="submit" class="btn-cancel-req" title="Hủy yêu cầu">
                                                                 <i class="fas fa-ban"></i> Hủy yêu cầu
                                                             </button>
                                                         </form>
                                                     </c:if>
                                                 </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

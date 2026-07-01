<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Xác Nhận Cuối Điều Chuyển (HR Manager)" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --navy: #0a2540;
        --blue: #2b6cb0;
        --bg: #f0ede8;
        --surface: #ffffff;
        --border: #e2e8f0;
        --text: #0f172a;
        --muted: #64748b;
        --pri: #6366f1;
        --pri-l: rgba(99, 102, 241, 0.1);
        --ok: #10b981;
        --ok-l: rgba(16, 185, 129, 0.1);
        --ng: #ef4444;
        --ng-l: rgba(239, 68, 68, 0.1);
        --warn: #f59e0b;
        --warn-l: rgba(245, 158, 11, 0.1);
        --indigo: #4f46e5;
    }

    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }

    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }

    .alert { padding: 14px 20px; border-radius: 12px; font-size: 0.9rem; font-weight: 500; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
    .alert-success { background: #d1fae5; border: 1px solid #a7f3d0; color: #065f46; }
    .alert-danger { background: #fee2e2; border: 1px solid #fecdd3; color: #9f1239; }

    /* HR CONFIRM BANNER */
    .hr-confirm-banner {
        background: linear-gradient(135deg, rgba(79, 70, 229, 0.08) 0%, rgba(99, 102, 241, 0.12) 100%);
        border: 1px solid rgba(79, 70, 229, 0.25);
        border-radius: 16px;
        padding: 20px 24px;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .hr-confirm-banner .banner-icon {
        width: 48px; height: 48px;
        background: var(--indigo);
        border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.3rem; color: #fff;
        flex-shrink: 0;
    }
    .hr-confirm-banner .banner-text h3 {
        font-family: 'Be Vietnam Pro', sans-serif;
        font-weight: 800; font-size: 1rem; color: var(--indigo);
        margin: 0 0 4px;
    }
    .hr-confirm-banner .banner-text p {
        font-size: 0.82rem; color: #5b21b6; margin: 0;
    }

    /* WORKFLOW STEPS */
    .workflow-steps {
        display: flex; align-items: center; gap: 12px;
        background: #fff; border: 1px solid var(--border);
        border-radius: 12px; padding: 14px 20px;
        margin-bottom: 24px; flex-wrap: wrap;
    }
    .wf-step { display: flex; align-items: center; gap: 8px; }
    .wf-num { width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.8rem; }
    .wf-num.done { background: var(--ok); color: #fff; }
    .wf-num.active { background: var(--indigo); color: #fff; }
    .wf-label { font-size: 0.8rem; font-weight: 600; }
    .wf-label.done { color: var(--ok); }
    .wf-label.active { color: var(--indigo); }
    .wf-arrow { color: var(--muted); font-size: 1rem; }

    /* TABLE CARD */
    .card-table { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.02); }
    .mode-chip { display: inline-flex; align-items: center; gap: 8px; padding: 6px 14px; border-radius: 20px; font-size: 0.8rem; font-weight: 700; margin-bottom: 16px; background: rgba(79, 70, 229, 0.1); color: var(--indigo); }

    .tbl { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
    .tbl th { background: transparent; color: var(--muted); font-weight: 600; font-size: .75rem; text-transform: uppercase; letter-spacing: .5px; padding: 12px 16px; border: none; }
    .tbl td { background: #fff; padding: 14px 16px; vertical-align: middle; color: #334155; font-size: .875rem; border-top: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9; }
    .tbl tr td:first-child { border-left: 1px solid #f1f5f9; border-radius: 10px 0 0 10px; }
    .tbl tr td:last-child { border-right: 1px solid #f1f5f9; border-radius: 0 10px 10px 0; }
    .tbl tbody tr:hover td { background: #f8fafc; }

    .transfer-arrow { color: var(--muted); margin: 0 6px; font-size: 0.8rem; }

    .badge-s { padding: 4px 10px; border-radius: 6px; font-weight: 700; font-size: .71rem; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; }
    .b-mgr-appr { background: rgba(79, 70, 229, 0.1); color: var(--indigo); }
    .b-approved { background: var(--ok-l); color: var(--ok); }
    .b-rejected { background: var(--ng-l); color: var(--ng); }

    .btn-action-group { display: flex; gap: 8px; flex-wrap: wrap; }
    .btn-detail { display: inline-flex; align-items: center; gap: 6px; background: var(--indigo); color: #fff; border: none; padding: 7px 14px; border-radius: 8px; font-weight: 700; font-size: .78rem; text-decoration: none; transition: all .2s; }
    .btn-detail:hover { background: #3730a3; color: #fff; transform: translateY(-1px); }
    .btn-history { display: inline-flex; align-items: center; gap: 6px; background: rgba(59,130,246,0.08); color: var(--blue); border: none; padding: 7px 14px; border-radius: 8px; font-weight: 600; font-size: .78rem; text-decoration: none; transition: all .2s; }
    .btn-history:hover { background: var(--blue); color: #fff; }

    .text-empty { text-align: center; color: var(--muted); padding: 40px 0; font-style: italic; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .card-table { padding: 16px; }
        .workflow-steps { flex-direction: column; align-items: flex-start; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="hr-transfer-confirm" />
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
                    <span>Xác nhận cuối điều chuyển</span>
                </div>
                <h1><i class="fas fa-user-shield" style="color:var(--indigo);margin-right:10px;font-size:1.3rem;"></i>Xác Nhận Cuối — HR Manager</h1>
            </div>
        </div>

        <!-- ALERTS -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle" style="font-size:1.2rem;"></i>
                ${sessionScope.successMessage}
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle" style="font-size:1.2rem;"></i>
                ${sessionScope.errorMessage}
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <!-- TABLE CARD -->
        <div class="card-table">
            <div class="mode-chip">
                <i class="fas fa-user-shield"></i> Danh sách đơn chờ xác nhận cuối (Trưởng phòng đã duyệt)
            </div>

            <div class="table-responsive">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th style="width:14%">Nhân viên</th>
                            <th style="width:20%">Phòng ban (Cũ → Mới)</th>
                            <th style="width:20%">Chức vụ (Cũ → Mới)</th>
                            <th style="width:10%">Ngày hiệu lực</th>
                            <th style="width:14%">Người tạo đơn</th>
                            <th style="width:13%">Trưởng phòng duyệt</th>
                            <th style="width:5%">TT</th>
                            <th style="width:12%">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty approvals}">
                                <tr>
                                    <td colspan="8" class="text-empty">
                                        <i class="fas fa-inbox" style="font-size:2rem;display:block;margin-bottom:8px;"></i>
                                        Không có đơn nào đang chờ bạn xác nhận cuối.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${approvals}" var="tr">
                                    <tr>
                                        <td>
                                            <strong>${tr.employeeName}</strong>
                                            <div style="font-size:0.75rem;color:var(--muted)">ID: #${tr.employeeId}</div>
                                        </td>
                                        <td>
                                            <span style="color:var(--muted)">${tr.oldDepartmentName}</span>
                                            <i class="fas fa-arrow-right transfer-arrow"></i>
                                            <strong style="color:var(--navy)">${tr.newDepartmentName}</strong>
                                        </td>
                                        <td>
                                            <span style="color:var(--muted)">${tr.oldPositionName}</span>
                                            <i class="fas fa-arrow-right transfer-arrow"></i>
                                            <strong style="color:var(--navy)">${tr.newPositionName}</strong>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${tr.effectiveDate}" pattern="dd/MM/yyyy" />
                                        </td>
                                        <td>
                                            ${tr.requestedByName}
                                            <div style="font-size:0.72rem;color:var(--muted)">
                                                <fmt:formatDate value="${tr.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </div>
                                        </td>
                                        <td>
                                            <strong>${tr.managerApprovedByName}</strong>
                                            <div style="font-size:0.72rem;color:var(--muted)">
                                                <fmt:formatDate value="${tr.managerApprovedAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge-s b-mgr-appr">
                                                <i class="fas fa-user-check"></i> TP duyệt
                                            </span>
                                        </td>
                                        <td>
                                            <div class="btn-action-group">
                                                <a href="${pageContext.request.contextPath}/manager/hr-transfer-confirm-detail?id=${tr.transferRequestId}"
                                                   class="btn-detail" title="Xác nhận cuối">
                                                    <i class="fas fa-check-double"></i> Xác nhận
                                                </a>
                                                <a href="${pageContext.request.contextPath}/manager/employee-work-history?userId=${tr.employeeId}"
                                                   class="btn-history" title="Xem lịch sử công tác">
                                                    <i class="fas fa-history"></i>
                                                </a>
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

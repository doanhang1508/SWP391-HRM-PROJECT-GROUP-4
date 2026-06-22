<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Quản lý Tăng Ca - HRM" scope="request" />
<jsp:include page="../header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root{--pri:#6366f1;--pri-l:rgba(99,102,241,.1);--ok:#10b981;--ok-l:rgba(16,185,129,.1);--ng:#ef4444;--ng-l:rgba(239,68,68,.1);--warn:#f59e0b;--warn-l:rgba(245,158,11,.1);--bg:#f4f7fe;--card:#fff;--txt:#1e293b;--muted:#64748b}
    body{background:var(--bg);font-family:'Inter',sans-serif}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px)}
    .main-content{flex:1;padding:30px;width:calc(100% - 260px)}
    .page-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:28px;flex-wrap:wrap;gap:12px}
    .page-title{font-size:1.5rem;font-weight:700;color:var(--txt);margin:0}
    .breadcrumb-c{font-size:.85rem;color:var(--muted);margin:4px 0 0}
    .breadcrumb-c a{color:var(--pri);text-decoration:none}
    .btn-add{background:var(--pri);color:#fff;border:none;border-radius:10px;padding:10px 20px;font-weight:600;font-size:.88rem;display:inline-flex;align-items:center;gap:8px;cursor:pointer;transition:all .2s;text-decoration:none}
    .btn-add:hover{background:#4f46e5;transform:translateY(-2px);box-shadow:0 6px 20px rgba(99,102,241,.3);color:#fff}
    .admin-panel{background:var(--card);border-radius:16px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);border:1px solid rgba(0,0,0,.04);margin-bottom:24px}
    .panel-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:1px solid #f1f5f9;flex-wrap:wrap;gap:10px}
    .panel-title{font-size:1.1rem;font-weight:700;color:var(--txt);margin:0;display:flex;align-items:center;gap:10px}
    .panel-icon{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center}
    .tbl{width:100%;border-collapse:separate;border-spacing:0 6px}
    .tbl th{background:transparent;color:var(--muted);font-weight:600;font-size:.78rem;text-transform:uppercase;letter-spacing:.5px;padding:10px 14px;border:none;white-space:nowrap}
    .tbl td{background:#fff;padding:13px 14px;vertical-align:middle;color:#475569;font-size:.87rem;border-top:1px solid #f1f5f9;border-bottom:1px solid #f1f5f9}
    .tbl tr td:first-child{border-left:1px solid #f1f5f9;border-radius:10px 0 0 10px}
    .tbl tr td:last-child{border-right:1px solid #f1f5f9;border-radius:0 10px 10px 0}
    .tbl tbody tr:hover td{background:#f8fafc}
    .badge-s{padding:5px 12px;border-radius:6px;font-weight:600;font-size:.74rem;display:inline-flex;align-items:center;gap:5px}
    .b-active,.b-approved{background:var(--ok-l);color:var(--ok)}
    .b-pending{background:var(--warn-l);color:#b45309}
    .b-cancelled{background:var(--ng-l);color:var(--ng)}
    .btn-a{height:32px;display:inline-flex;align-items:center;justify-content:center;border-radius:8px;border:none;color:#fff;padding:0 12px;font-size:.82rem;font-weight:500;text-decoration:none;gap:5px;cursor:pointer;transition:all .2s}
    .btn-a:hover{transform:translateY(-2px);box-shadow:0 4px 10px rgba(0,0,0,.12);color:#fff}
    .btn-approve{background:var(--ok)}
    .btn-cancel-ot{background:var(--ng)}
    .btn-view{background:#3b82f6}
    .alert-c{border:none;border-radius:10px;font-size:.88rem;padding:12px 20px}
    .a-ok{background:#d1fae5;color:#065f46}
    .a-err{background:#fee2e2;color:#991b1b}
    .stat-card{background:var(--card);border-radius:14px;padding:20px;border:1px solid rgba(0,0,0,.04);text-align:center}
    .stat-num{font-size:1.8rem;font-weight:800;margin:0}
    .stat-label{font-size:.8rem;color:var(--muted);margin:4px 0 0}
    .modal-content{border-radius:16px;border:none;box-shadow:0 20px 60px rgba(0,0,0,.15)}
    .modal-header{border-bottom:1px solid #f1f5f9;padding:20px 24px}
    .modal-title{font-weight:700;font-size:1.1rem;color:var(--txt)}
    .modal-body{padding:24px}
    .modal-footer{border-top:1px solid #f1f5f9;padding:16px 24px}
    .form-label{font-weight:600;font-size:.85rem;color:var(--txt);margin-bottom:6px}
    .form-control,.form-select{border-radius:8px;border:1px solid #e2e8f0;padding:10px 14px;font-size:.88rem}
    .form-control:focus,.form-select:focus{border-color:var(--pri);box-shadow:0 0 0 3px var(--pri-l)}
    @media(max-width:768px){.main-content{width:100%!important;padding:20px 16px!important}}
</style>
<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp"><jsp:param name="activeMenu" value="overtime"/></jsp:include>
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title"><i class="fas fa-clock me-2" style="color:var(--pri)"></i>Quản Lý Tăng Ca</h1>
                <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Tăng ca</p>
            </div>
            <button class="btn-add" data-bs-toggle="modal" data-bs-target="#planModal"><i class="fas fa-plus"></i> Tạo Kế Hoạch OT</button>
        </div>

        <c:if test="${not empty param.message}"><div class="alert alert-c a-ok alert-dismissible fade show" role="alert"><i class="fas fa-check-circle me-2"></i>${param.message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
        <c:if test="${not empty param.error}"><div class="alert alert-c a-err alert-dismissible fade show" role="alert"><i class="fas fa-exclamation-circle me-2"></i>${param.error}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

        <!-- Stats Row -->
        <div class="row mb-4 g-3">
            <div class="col-md-3"><div class="stat-card"><p class="stat-num" style="color:var(--pri)">${plans.size()}</p><p class="stat-label">Kế hoạch OT</p></div></div>
            <div class="col-md-3"><div class="stat-card"><p class="stat-num" style="color:var(--warn)">${pendingAssignments.size()}</p><p class="stat-label">Chờ duyệt</p></div></div>
            <div class="col-md-3"><div class="stat-card"><p class="stat-num" style="color:var(--ok)">${allAssignments.size()}</p><p class="stat-label">Tổng phân công</p></div></div>
            <div class="col-md-3"><div class="stat-card"><p class="stat-num" style="color:#8b5cf6">${workers.size()}</p><p class="stat-label">Nhân viên</p></div></div>
        </div>

        <!-- OT Plans -->
        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-icon" style="background:var(--pri-l);color:var(--pri)"><i class="fas fa-calendar-alt"></i></div> Kế Hoạch Tăng Ca</h3>
            </div>
            <c:choose>
                <c:when test="${empty plans}">
                    <div style="text-align:center;padding:40px;color:var(--muted)"><i class="fas fa-calendar-times d-block" style="font-size:2.5rem;margin-bottom:12px;opacity:.3"></i><p>Chưa có kế hoạch tăng ca.</p></div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="tbl">
                            <thead><tr><th>ID</th><th>Ngày</th><th>Mô tả</th><th>Số NV</th><th>Trạng thái</th><th class="text-end">Hành động</th></tr></thead>
                            <tbody>
                                <c:forEach var="p" items="${plans}">
                                    <tr>
                                        <td class="fw-bold" style="color:var(--txt)">#${p.planId}</td>
                                        <td><span class="fw-bold" style="color:var(--pri)">${p.targetDate}</span></td>
                                        <td>${p.description}</td>
                                        <td><span class="badge-s b-active">${p.assignmentCount} người</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.status == 'Active'}"><span class="badge-s b-active"><i class="fas fa-circle" style="font-size:6px"></i> Hoạt động</span></c:when>
                                                <c:when test="${p.status == 'Cancelled'}"><span class="badge-s b-cancelled"><i class="fas fa-circle" style="font-size:6px"></i> Đã hủy</span></c:when>
                                                <c:otherwise><span class="badge-s b-pending">${p.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-2">
                                                <a href="${pageContext.request.contextPath}/manager/overtime?action=viewPlan&planId=${p.planId}" class="btn-a btn-view" title="Xem chi tiết"><i class="fas fa-eye"></i></a>
                                                <c:if test="${p.status == 'Active'}">
                                                    <button class="btn-a btn-approve" onclick="openAssignModal(${p.planId},'${p.targetDate}','${p.description}')" title="Phân công"><i class="fas fa-user-plus"></i></button>
                                                    <form action="${pageContext.request.contextPath}/manager/overtime" method="POST" style="display:inline" onsubmit="return confirm('Hủy kế hoạch này?')">
                                                        <input type="hidden" name="action" value="cancelPlan"><input type="hidden" name="planId" value="${p.planId}">
                                                        <button type="submit" class="btn-a btn-cancel-ot" title="Hủy kế hoạch"><i class="fas fa-times"></i></button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Pending Approval Queue -->
        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-icon" style="background:var(--warn-l);color:#b45309"><i class="fas fa-hourglass-half"></i></div> Hàng Chờ Duyệt</h3>
                <span style="font-size:.85rem;color:var(--muted)"><i class="fas fa-info-circle me-1"></i><strong>${pendingAssignments.size()}</strong> phân công chờ duyệt</span>
            </div>
            <c:choose>
                <c:when test="${empty pendingAssignments}">
                    <div style="text-align:center;padding:40px;color:var(--muted)"><i class="fas fa-check-double d-block" style="font-size:2.5rem;margin-bottom:12px;opacity:.3"></i><p>Không có phân công nào chờ duyệt.</p></div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="tbl">
                            <thead><tr><th>Nhân viên</th><th>Ngày OT</th><th>Mô tả KH</th><th>Số giờ</th><th>Trạng thái</th><th class="text-end">Hành động</th></tr></thead>
                            <tbody>
                                <c:forEach var="a" items="${pendingAssignments}">
                                    <tr>
                                        <td><span class="fw-bold" style="color:var(--txt)">${a.employeeName}</span></td>
                                        <td>${a.targetDate}</td>
                                        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${a.planDescription}</td>
                                        <td><span style="background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;padding:4px 12px;border-radius:20px;font-weight:700;font-size:.82rem">${a.assignedHours}h</span></td>
                                        <td><span class="badge-s b-pending"><i class="fas fa-circle" style="font-size:6px"></i> Chờ duyệt</span></td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-2">
                                                <form action="${pageContext.request.contextPath}/manager/overtime" method="POST" style="display:inline" onsubmit="return confirm('Duyệt tăng ca cho ${a.employeeName}?')">
                                                    <input type="hidden" name="action" value="approve"><input type="hidden" name="assignmentId" value="${a.assignmentId}">
                                                    <button type="submit" class="btn-a btn-approve" title="Duyệt"><i class="fas fa-check"></i> Duyệt</button>
                                                </form>
                                                <form action="${pageContext.request.contextPath}/manager/overtime" method="POST" style="display:inline" onsubmit="return confirm('Hủy phân công OT cho ${a.employeeName}?')">
                                                    <input type="hidden" name="action" value="cancel"><input type="hidden" name="assignmentId" value="${a.assignmentId}">
                                                    <button type="submit" class="btn-a btn-cancel-ot" title="Hủy"><i class="fas fa-times"></i> Hủy</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- All Assignments -->
        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title"><div class="panel-icon" style="background:var(--ok-l);color:var(--ok)"><i class="fas fa-list-check"></i></div> Tất Cả Phân Công OT</h3>
            </div>
            <c:if test="${not empty allAssignments}">
                <div class="table-responsive">
                    <table class="tbl">
                        <thead><tr><th>ID</th><th>Nhân viên</th><th>Ngày</th><th>Số giờ</th><th>Trạng thái</th></tr></thead>
                        <tbody>
                            <c:forEach var="a" items="${allAssignments}">
                                <tr>
                                    <td class="fw-bold">#${a.assignmentId}</td>
                                    <td class="fw-bold" style="color:var(--txt)">${a.employeeName}</td>
                                    <td>${a.targetDate}</td>
                                    <td><span style="background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;padding:4px 12px;border-radius:20px;font-weight:700;font-size:.82rem">${a.assignedHours}h</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${a.status == 'Approved'}"><span class="badge-s b-approved"><i class="fas fa-circle" style="font-size:6px"></i> Đã duyệt</span></c:when>
                                            <c:when test="${a.status == 'Pending'}"><span class="badge-s b-pending"><i class="fas fa-circle" style="font-size:6px"></i> Chờ duyệt</span></c:when>
                                            <c:when test="${a.status == 'Cancelled'}"><span class="badge-s b-cancelled"><i class="fas fa-circle" style="font-size:6px"></i> Đã hủy</span></c:when>
                                            <c:otherwise><span class="badge-s b-pending">${a.status}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Create Plan Modal -->
<div class="modal fade" id="planModal" tabindex="-1"><div class="modal-dialog modal-dialog-centered"><div class="modal-content">
    <form action="${pageContext.request.contextPath}/manager/overtime" method="POST">
        <input type="hidden" name="action" value="createPlan">
        <div class="modal-header"><h5 class="modal-title"><i class="fas fa-calendar-plus me-2" style="color:var(--pri)"></i>Tạo Kế Hoạch Tăng Ca</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
        <div class="modal-body">
            <div class="mb-3"><label class="form-label">Ngày Tăng Ca <span class="text-danger">*</span></label><input type="date" class="form-control" name="targetDate" required></div>
            <div class="mb-3"><label class="form-label">Mô Tả <span class="text-danger">*</span></label><textarea class="form-control" name="description" rows="3" required placeholder="VD: Tăng ca hoàn thành đơn hàng xuất khẩu"></textarea></div>
        </div>
        <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px">Hủy</button><button type="submit" class="btn" style="background:var(--pri);color:#fff;border:none;border-radius:8px;font-weight:600"><i class="fas fa-plus me-1"></i>Tạo</button></div>
    </form>
</div></div></div>

<!-- Assign OT Modal -->
<div class="modal fade" id="assignModal" tabindex="-1"><div class="modal-dialog modal-dialog-centered"><div class="modal-content">
    <form action="${pageContext.request.contextPath}/manager/overtime" method="POST">
        <input type="hidden" name="action" value="assign">
        <input type="hidden" name="planId" id="assignPlanId">
        <div class="modal-header"><h5 class="modal-title"><i class="fas fa-user-plus me-2" style="color:var(--ok)"></i>Phân Công Tăng Ca</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
        <div class="modal-body">
            <div class="mb-3"><label class="form-label">Kế hoạch</label><input type="text" class="form-control" id="assignPlanInfo" readonly style="background:#f8fafc"></div>
            <div class="mb-3"><label class="form-label">Nhân viên <span class="text-danger">*</span></label>
                <select class="form-select" name="userId" required>
                    <option value="">-- Chọn nhân viên --</option>
                    <c:forEach var="w" items="${workers}"><option value="${w.userId}">${w.fullName}</option></c:forEach>
                </select>
            </div>
            <div class="mb-3"><label class="form-label">Số giờ OT <span class="text-danger">*</span></label><input type="number" step="0.5" min="0.5" max="4" class="form-control" name="assignedHours" required placeholder="Tối đa 4 giờ/ngày"></div>
        </div>
        <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px">Hủy</button><button type="submit" class="btn" style="background:var(--ok);color:#fff;border:none;border-radius:8px;font-weight:600"><i class="fas fa-check me-1"></i>Phân công</button></div>
    </form>
</div></div></div>

<script>
function openAssignModal(planId, date, desc) {
    document.getElementById('assignPlanId').value = planId;
    document.getElementById('assignPlanInfo').value = '#' + planId + ' — ' + date + ' — ' + desc;
    new bootstrap.Modal(document.getElementById('assignModal')).show();
}
</script>
<jsp:include page="../footer.jsp"/>

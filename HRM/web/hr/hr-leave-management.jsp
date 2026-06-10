<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý nghỉ phép (HR) - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root{
        --pri:#6366f1;
        --pri-l:rgba(99,102,241,.1);
        --ok:#10b981;
        --ok-l:rgba(16,185,129,.1);
        --ng:#ef4444;
        --ng-l:rgba(239,68,68,.1);
        --warn:#f59e0b;
        --bg:#f4f7fe;
        --card:#fff;
        --txt:#1e293b;
        --muted:#64748b;
    }
    body{
        background:var(--bg);
        font-family:'Inter',sans-serif
    }
    .dashboard-wrapper{
        display:flex;
        min-height:calc(100vh - 64px)
    }
    .main-content{
        flex:1;
        padding:30px;
        width:calc(100% - 260px)
    }
    .page-header{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:28px;
        flex-wrap:wrap;
        gap:12px
    }
    .page-title{
        font-size:1.5rem;
        font-weight:700;
        color:var(--txt);
        margin:0
    }
    .breadcrumb-c{
        font-size:.85rem;
        color:var(--muted);
        margin:4px 0 0
    }
    .breadcrumb-c a{
        color:var(--pri);
        text-decoration:none
    }
    .btn-add{
        background:var(--pri);
        color:#fff;
        border:none;
        border-radius:10px;
        padding:10px 20px;
        font-weight:600;
        font-size:.88rem;
        display:inline-flex;
        align-items:center;
        gap:8px;
        cursor:pointer;
        transition:all .2s;
        text-decoration:none
    }
    .btn-add:hover{
        background:#4f46e5;
        transform:translateY(-2px);
        box-shadow:0 6px 20px rgba(99,102,241,.3);
        color:#fff
    }
    .admin-panel{
        background:var(--card);
        border-radius:16px;
        padding:24px;
        box-shadow:0 4px 20px rgba(0,0,0,.03);
        border:1px solid rgba(0,0,0,.04);
        margin-bottom:24px
    }
    .panel-header{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:20px;
        padding-bottom:15px;
        border-bottom:1px solid #f1f5f9;
        flex-wrap:wrap;
        gap:10px
    }
    .panel-title{
        font-size:1.1rem;
        font-weight:700;
        color:var(--txt);
        margin:0;
        display:flex;
        align-items:center;
        gap:10px
    }
    .panel-icon{
        width:40px;
        height:40px;
        border-radius:10px;
        background:var(--pri-l);
        color:var(--pri);
        display:flex;
        align-items:center;
        justify-content:center
    }
    .nav-tabs {
        border-bottom: 2px solid #e2e8f0;
        margin-bottom: 20px;
    }
    .nav-tabs .nav-link {
        border: none;
        color: var(--muted);
        font-weight: 600;
        padding: 12px 20px;
        margin-bottom: -2px;
        border-bottom: 2px solid transparent;
        transition: all 0.2s;
    }
    .nav-tabs .nav-link:hover {
        color: var(--pri);
        border-color: transparent;
    }
    .nav-tabs .nav-link.active {
        color: var(--pri);
        border-color: var(--pri);
        background: transparent;
    }
    .tbl{
        width:100%;
        border-collapse:separate;
        border-spacing:0 6px
    }
    .tbl th{
        background:transparent;
        color:var(--muted);
        font-weight:600;
        font-size:.78rem;
        text-transform:uppercase;
        letter-spacing:.5px;
        padding:10px 14px;
        border:none;
        white-space:nowrap
    }
    .tbl td{
        background:#fff;
        padding:13px 14px;
        vertical-align:middle;
        color:#475569;
        font-size:.87rem;
        border-top:1px solid #f1f5f9;
        border-bottom:1px solid #f1f5f9
    }
    .tbl tr td:first-child{
        border-left:1px solid #f1f5f9;
        border-radius:10px 0 0 10px
    }
    .tbl tr td:last-child{
        border-right:1px solid #f1f5f9;
        border-radius:0 10px 10px 0
    }
    .tbl tbody tr:hover td{
        background:#f8fafc
    }
    .badge-s{
        padding:5px 12px;
        border-radius:6px;
        font-weight:600;
        font-size:.74rem;
        display:inline-flex;
        align-items:center;
        gap:5px
    }
    .b-active{
        background:var(--ok-l);
        color:var(--ok)
    }
    .b-inactive{
        background:var(--ng-l);
        color:var(--ng)
    }
    .b-warn{
        background:rgba(245,158,11,.1);
        color:#d97706
    }
    .alert-c{
        border:none;
        border-radius:10px;
        font-size:.88rem;
        padding:12px 20px
    }
    .a-ok{
        background:#d1fae5;
        color:#065f46
    }
    .a-err{
        background:#fee2e2;
        color:#991b1b
    }
    .btn-a{
        height:32px;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        border-radius:8px;
        border:none;
        color:#fff;
        padding:0 12px;
        font-size:.82rem;
        font-weight:500;
        text-decoration:none;
        gap:5px;
        cursor:pointer;
        transition:all .2s
    }
    .btn-a:hover{
        transform:translateY(-2px);
        box-shadow:0 4px 10px rgba(0,0,0,.12);
        color:#fff
    }
    .btn-edit{
        background:#3b82f6
    }
    .btn-del{
        background:var(--ng)
    }
    @media(max-width:768px){
        .main-content{
            width:100%!important;
            padding:20px 16px!important
        }
        .page-header{
            flex-direction:column;
            align-items:flex-start
        }
    }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="leaveManagement" />
    </jsp:include>

    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Quản Lý Nghỉ Phép</h1>
                <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Nghỉ phép</p>
            </div>
            <div class="d-flex gap-2">
                <button class="btn-add" data-bs-toggle="modal" data-bs-target="#addTypeModal">
                    <i class="fas fa-plus"></i> Thêm Loại Mới
                </button>
            </div>
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-c a-ok alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-c a-err alert-dismissible fade show"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <ul class="nav nav-tabs" id="hrTabs">
            <li class="nav-item">
                <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#leaveTypes">Cấu hình Loại nghỉ phép</button>
            </li>
            <li class="nav-item">
                <button class="nav-link" data-bs-toggle="tab" data-bs-target="#allRequests">Danh sách Đơn xin nghỉ</button>
            </li>
        </ul>

        <div class="tab-content">
            <!-- Leave Types Tab -->
            <div class="tab-pane fade show active" id="leaveTypes">
                <div class="admin-panel">
                    <div class="panel-header">
                        <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-list-alt"></i></div> Danh sách Loại nghỉ phép</h3>
                        <div class="d-flex gap-2 align-items-center">
                            <div style="position:relative;flex:1;min-width:200px;">
                                <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:.85rem;"></i>
                                <input type="text" id="typeSearch" placeholder="Tìm tên loại..." oninput="filterTypeTable()" style="width:100%;padding:9px 14px 9px 36px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;font-family:'Inter',sans-serif;">
                            </div>
                            <select id="typeStatus" onchange="filterTypeTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả</option>
                                <option value="Hoạt động">Hoạt động</option>
                                <option value="Đã xóa">Đã xóa</option>
                            </select>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="tbl" id="typeTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên loại</th>
                                    <th>Mô tả</th>
                                    <th>Có lương?</th>
                                    <th>Tối đa (Ngày/Năm)</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Hành tác</th>
                                </tr>
                            </thead>
                            <tbody id="typeTbody">
                                <c:forEach var="leaveTypeItem" items="${leaveTypes}">
                                    <tr>
                                        <td class="fw-bold" style="color:var(--txt)">#${leaveTypeItem.leaveTypeId}</td>
                                        <td><span class="fw-bold" style="color:var(--pri)">${leaveTypeItem.typeName}</span></td>
                                        <td>${leaveTypeItem.description}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${leaveTypeItem.paidLeave == 1}"><span class="badge-s b-active"><i class="fas fa-dollar-sign"></i> Có</span></c:when>
                                                <c:otherwise><span class="badge-s b-inactive"><i class="fas fa-times"></i> Không</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span style="font-weight:600">${empty leaveTypeItem.maxDaysPerYear ? 'Không giới hạn' : leaveTypeItem.maxDaysPerYear}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${leaveTypeItem.status == 1}"><span class="badge-s b-active"><i class="fas fa-circle" style="font-size:6px"></i> Hoạt động</span></c:when>
                                                <c:otherwise><span class="badge-s b-inactive"><i class="fas fa-circle" style="font-size:6px"></i> Đã xóa</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-2">
                                                <button class="btn-a btn-edit" title="Sửa" 
                                                    onclick="editType('${leaveTypeItem.leaveTypeId}', '${leaveTypeItem.typeName}', '${leaveTypeItem.description}', '${leaveTypeItem.paidLeave}', '${leaveTypeItem.maxDaysPerYear}', '${leaveTypeItem.status}')" 
                                                    data-bs-toggle="modal" data-bs-target="#editTypeModal"><i class="fas fa-pen"></i></button>
                                                <c:if test="${leaveTypeItem.status == 1}">
                                                    <form action="${pageContext.request.contextPath}/hr/leave" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="deleteType">
                                                        <input type="hidden" name="leaveTypeId" value="${leaveTypeItem.leaveTypeId}">
                                                        <button type="submit" class="btn-a btn-del" onclick="return confirm('Bạn có chắc muốn xóa loại nghỉ phép này?');" title="Xóa"><i class="fas fa-trash-alt"></i></button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;">
                            <span id="typePageInfo" style="font-size: 0.85rem; color: #64748b;">Đang tải...</span>
                            <div style="display:flex;gap:8px;">
                                <button onclick="typePrevPage()" id="btnTypePrev" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-left"></i></button>
                                <button onclick="typeNextPage()" id="btnTypeNext" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-right"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- All Requests Tab -->
            <div class="tab-pane fade" id="allRequests">
                <div class="admin-panel">
                    <div class="panel-header">
                        <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-file-alt"></i></div> Toàn bộ Đơn xin nghỉ phép (Toàn công ty)</h3>
                        <div class="d-flex gap-2 align-items-center">
                            <div style="position:relative;flex:1;min-width:200px;">
                                <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:.85rem;"></i>
                                <input type="text" id="reqSearch" placeholder="Tìm nhân viên, loại..." oninput="filterReqTable()" style="width:100%;padding:9px 14px 9px 36px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;font-family:'Inter',sans-serif;">
                            </div>
                            <select id="reqDept" onchange="filterReqTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả phòng ban</option>
                                <c:forEach var="d" items="${departments}">
                                    <option value="${d.departmentName}">${d.departmentName}</option>
                                </c:forEach>
                            </select>
                            <select id="reqStatus" onchange="filterReqTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="Chờ duyệt">Chờ duyệt</option>
                                <option value="Đã duyệt">Đã duyệt</option>
                                <option value="Từ chối">Từ chối</option>
                            </select>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="tbl" id="reqTable">
                            <thead>
                                <tr>
                                    <th>Nhân viên</th>
                                    <th>Phòng ban</th>
                                    <th>Loại nghỉ</th>
                                    <th>Từ ngày</th>
                                    <th>Đến ngày</th>
                                    <th>Số ngày</th>
                                    <th>Đính kèm</th>
                                    <th>Ngày gửi</th>
                                    <th>Trạng thái</th>
                                    <th>Người duyệt</th>
                                </tr>
                            </thead>
                            <tbody id="reqTbody">
                                <c:forEach var="r" items="${allRequests}">
                                    <tr>
                                        <td><span class="fw-bold" style="color:var(--pri)">${r.userName}</span></td>
                                        <td>${empty r.departmentName ? '-' : r.departmentName}</td>
                                        <td>${r.leaveTypeName}</td>
                                        <td>${r.startDate}</td>
                                        <td>${r.endDate}</td>
                                        <td><span style="font-weight:600">${r.totalDays}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty r.attachment}">
                                                    <a href="${pageContext.request.contextPath}/${r.attachment}" target="_blank" class="badge-s b-active" style="text-decoration:none;">
                                                        <i class="fas fa-file-download"></i> Xem
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:var(--muted);">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="color:var(--muted);font-size:0.85rem;">
                                            <fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.status == 'Approved'}"><span class="badge-s b-active"><i class="fas fa-check"></i> Đã duyệt</span></c:when>
                                                <c:when test="${r.status == 'Rejected'}"><span class="badge-s b-inactive"><i class="fas fa-times"></i> Từ chối</span></c:when>
                                                <c:otherwise><span class="badge-s b-warn"><i class="fas fa-clock"></i> Chờ duyệt</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span class="fw-bold" style="color:var(--muted)">${r.approvedBy > 0 ? r.approvedBy : '-'}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;">
                            <span id="reqPageInfo" style="font-size: 0.85rem; color: #64748b;">Đang tải...</span>
                            <div style="display:flex;gap:8px;">
                                <button onclick="reqPrevPage()" id="btnReqPrev" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-left"></i></button>
                                <button onclick="reqNextPage()" id="btnReqNext" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-right"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add Modal -->
<div class="modal fade" id="addTypeModal">
    <div class="modal-dialog">
        <form action="${pageContext.request.contextPath}/hr/leave" method="POST" class="modal-content" style="border-radius:16px;border:none">
            <input type="hidden" name="action" value="addType">
            <div class="modal-header" style="border-bottom:1px solid #f1f5f9;padding:20px 24px"><h5 class="modal-title" style="font-weight:700;color:var(--txt)"><i class="fas fa-plus-circle me-2" style="color:var(--pri)"></i>Thêm Loại Nghỉ Phép</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body" style="padding:24px">
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Tên loại <span class="text-danger">*</span></label><input type="text" name="typeName" class="form-control" style="padding:10px 14px;border-radius:8px" required></div>
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Mô tả</label><input type="text" name="description" class="form-control" style="padding:10px 14px;border-radius:8px"></div>
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Có lương?</label>
                    <select name="paidLeave" class="form-select" style="padding:10px 14px;border-radius:8px">
                        <option value="1">Có</option>
                        <option value="0">Không</option>
                    </select>
                </div>
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Số ngày tối đa/năm (để trống nếu không giới hạn)</label><input type="number" name="maxDaysPerYear" class="form-control" style="padding:10px 14px;border-radius:8px"></div>
            </div>
            <div class="modal-footer" style="border-top:1px solid #f1f5f9;padding:16px 24px"><button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px;font-weight:500">Hủy</button><button type="submit" class="btn btn-primary" style="border-radius:8px;font-weight:600;background:var(--pri);border:none;padding:8px 20px">Lưu</button></div>
        </form>
    </div>
</div>

<!-- Edit Modal -->
<div class="modal fade" id="editTypeModal">
    <div class="modal-dialog">
        <form action="${pageContext.request.contextPath}/hr/leave" method="POST" class="modal-content" style="border-radius:16px;border:none">
            <input type="hidden" name="action" value="editType">
            <input type="hidden" name="leaveTypeId" id="editId">
            <div class="modal-header" style="border-bottom:1px solid #f1f5f9;padding:20px 24px"><h5 class="modal-title" style="font-weight:700;color:var(--txt)"><i class="fas fa-pen me-2" style="color:var(--pri)"></i>Cập nhật Loại Nghỉ Phép</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body" style="padding:24px">
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Tên loại <span class="text-danger">*</span></label><input type="text" name="typeName" id="editName" class="form-control" style="padding:10px 14px;border-radius:8px" required></div>
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Mô tả</label><input type="text" name="description" id="editDesc" class="form-control" style="padding:10px 14px;border-radius:8px"></div>
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Có lương?</label>
                    <select name="paidLeave" id="editPaid" class="form-select" style="padding:10px 14px;border-radius:8px">
                        <option value="1">Có</option>
                        <option value="0">Không</option>
                    </select>
                </div>
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Số ngày tối đa/năm</label><input type="number" name="maxDaysPerYear" id="editMax" class="form-control" style="padding:10px 14px;border-radius:8px"></div>
                <div class="mb-3"><label class="form-label" style="font-weight:600;color:#475569">Trạng thái</label>
                    <select name="status" id="editStatus" class="form-select" style="padding:10px 14px;border-radius:8px">
                        <option value="1">Hoạt động</option>
                        <option value="0">Đã xóa (Vô hiệu)</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer" style="border-top:1px solid #f1f5f9;padding:16px 24px"><button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px;font-weight:500">Hủy</button><button type="submit" class="btn btn-primary" style="border-radius:8px;font-weight:600;background:var(--pri);border:none;padding:8px 20px">Cập nhật</button></div>
        </form>
    </div>
</div>

<script>
function editType(id, name, desc, paid, max, status) {
    document.getElementById('editId').value = id;
    document.getElementById('editName').value = name;
    document.getElementById('editDesc').value = desc;
    document.getElementById('editPaid').value = paid;
    document.getElementById('editMax').value = max;
    document.getElementById('editStatus').value = status;
}

// --- LEAVE TYPES PAGINATION & FILTERING ---
let typeAllRows = [];
let typeFilteredRows = [];
let typeCurrentPage = 1;
const typeItemsPerPage = 10;

document.addEventListener('DOMContentLoaded', function() {
    const tbodyType = document.getElementById('typeTbody');
    if (tbodyType) {
        typeAllRows = Array.from(tbodyType.querySelectorAll('tr'));
        filterTypeTable(); // init
    }
});

function filterTypeTable() {
    const query = document.getElementById('typeSearch').value.toLowerCase();
    const status = document.getElementById('typeStatus').value;

    typeFilteredRows = typeAllRows.filter(row => {
        const textMatch = row.textContent.toLowerCase().includes(query);
        let statusMatch = true;
        if (status !== 'all') {
            const badges = row.querySelectorAll('.badge-s');
            // Status badge is the second badge in the row (index 1)
            if (badges.length > 1) {
                const rowStatus = badges[1].textContent.replace('Hoạt động', 'Hoạt động').replace('Đã xóa', 'Đã xóa').trim();
                statusMatch = (rowStatus.includes(status));
            }
        }
        return textMatch && statusMatch;
    });

    typeCurrentPage = 1;
    updateTypePagination();
}

function updateTypePagination() {
    typeAllRows.forEach(row => row.style.display = 'none');

    const totalItems = typeFilteredRows.length;
    const totalPages = Math.ceil(totalItems / typeItemsPerPage) || 1;
    
    if (typeCurrentPage > totalPages) typeCurrentPage = totalPages;
    if (typeCurrentPage < 1) typeCurrentPage = 1;

    const startIdx = (typeCurrentPage - 1) * typeItemsPerPage;
    const endIdx = Math.min(startIdx + typeItemsPerPage, totalItems);

    for (let i = startIdx; i < endIdx; i++) {
        typeFilteredRows[i].style.display = '';
    }

    const info = document.getElementById('typePageInfo');
    if (totalItems === 0) {
        info.textContent = 'Không tìm thấy kết quả nào.';
    } else {
        info.textContent = 'Hiển thị ' + (startIdx + 1) + ' - ' + endIdx + ' trong số ' + totalItems + ' loại.';
    }

    document.getElementById('btnTypePrev').disabled = (typeCurrentPage === 1);
    document.getElementById('btnTypeNext').disabled = (typeCurrentPage === totalPages);
}

function typePrevPage() {
    if (typeCurrentPage > 1) {
        typeCurrentPage--;
        updateTypePagination();
    }
}

function typeNextPage() {
    const totalPages = Math.ceil(typeFilteredRows.length / typeItemsPerPage) || 1;
    if (typeCurrentPage < totalPages) {
        typeCurrentPage++;
        updateTypePagination();
    }
}
</script>

<script>
// --- LEAVE REQUESTS PAGINATION & FILTERING ---
let reqAllRows = [];
let reqFilteredRows = [];
let reqCurrentPage = 1;
const reqItemsPerPage = 10;

document.addEventListener('DOMContentLoaded', function() {
    const tbody = document.getElementById('reqTbody');
    if (tbody) {
        reqAllRows = Array.from(tbody.querySelectorAll('tr'));
        filterReqTable(); // init
    }
});

function filterReqTable() {
    const query = document.getElementById('reqSearch').value.toLowerCase();
    const status = document.getElementById('reqStatus').value;
    const dept = document.getElementById('reqDept') ? document.getElementById('reqDept').value : 'all';

    reqFilteredRows = reqAllRows.filter(row => {
        const textMatch = row.textContent.toLowerCase().includes(query);
        let statusMatch = true;
        if (status !== 'all') {
            const badge = row.querySelector('.badge-s');
            if (badge) {
                const rowStatus = badge.textContent.trim();
                statusMatch = (rowStatus.includes(status));
            }
        }
        let deptMatch = true;
        if (dept !== 'all') {
            const deptCell = row.cells[1];
            if (deptCell) {
                deptMatch = (deptCell.textContent.trim() === dept);
            }
        }
        return textMatch && statusMatch && deptMatch;
    });

    reqCurrentPage = 1;
    updateReqPagination();
}

function updateReqPagination() {
    reqAllRows.forEach(row => row.style.display = 'none');

    const totalItems = reqFilteredRows.length;
    const totalPages = Math.ceil(totalItems / reqItemsPerPage) || 1;
    
    if (reqCurrentPage > totalPages) reqCurrentPage = totalPages;
    if (reqCurrentPage < 1) reqCurrentPage = 1;

    const startIdx = (reqCurrentPage - 1) * reqItemsPerPage;
    const endIdx = Math.min(startIdx + reqItemsPerPage, totalItems);

    for (let i = startIdx; i < endIdx; i++) {
        reqFilteredRows[i].style.display = '';
    }

    const info = document.getElementById('reqPageInfo');
    if (totalItems === 0) {
        info.textContent = 'Không tìm thấy kết quả nào.';
    } else {
        info.textContent = 'Hiển thị ' + (startIdx + 1) + ' - ' + endIdx + ' trong số ' + totalItems + ' đơn.';
    }

    document.getElementById('btnReqPrev').disabled = (reqCurrentPage === 1);
    document.getElementById('btnReqNext').disabled = (reqCurrentPage === totalPages);
}

function reqPrevPage() {
    if (reqCurrentPage > 1) {
        reqCurrentPage--;
        updateReqPagination();
    }
}

function reqNextPage() {
    const totalPages = Math.ceil(reqFilteredRows.length / reqItemsPerPage) || 1;
    if (reqCurrentPage < totalPages) {
        reqCurrentPage++;
        updateReqPagination();
    }
}
</script>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Quản lý Ca làm việc - HRM" scope="request" />
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
        --night:#8b5cf6;
        --night-l:rgba(139,92,246,.12);
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
    .b-night{
        background:var(--night-l);
        color:var(--night);
        padding:4px 10px;
        border-radius:6px;
        font-weight:600;
        font-size:.72rem;
        display:inline-flex;
        align-items:center;
        gap:5px
    }
    .b-day{
        background:rgba(245,158,11,.1);
        color:#d97706;
        padding:4px 10px;
        border-radius:6px;
        font-weight:600;
        font-size:.72rem;
        display:inline-flex;
        align-items:center;
        gap:5px
    }
    .time-d{
        font-weight:600;
        color:var(--txt);
        font-size:.88rem;
        font-variant-numeric:tabular-nums
    }
    .time-a{
        color:var(--muted);
        margin:0 4px;
        font-size:.75rem
    }
    .hours-p{
        background:linear-gradient(135deg,#6366f1,#8b5cf6);
        color:#fff;
        padding:4px 12px;
        border-radius:20px;
        font-weight:700;
        font-size:.82rem;
        display:inline-block
    }
    .coeff{
        background:rgba(245,158,11,.1);
        color:#b45309;
        padding:3px 8px;
        border-radius:6px;
        font-weight:600;
        font-size:.72rem
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
    .btn-tog-on{
        background:var(--warn);
        width:32px;
        padding:0
    }
    .btn-tog-off{
        background:#1e293b;
        width:32px;
        padding:0
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
    .modal-content{
        border-radius:16px;
        border:none;
        box-shadow:0 20px 60px rgba(0,0,0,.15)
    }
    .modal-header{
        border-bottom:1px solid #f1f5f9;
        padding:20px 24px
    }
    .modal-title{
        font-weight:700;
        font-size:1.1rem;
        color:var(--txt)
    }
    .modal-body{
        padding:24px
    }
    .modal-footer{
        border-top:1px solid #f1f5f9;
        padding:16px 24px
    }
    .form-label{
        font-weight:600;
        font-size:.85rem;
        color:var(--txt);
        margin-bottom:6px
    }
    .form-control{
        border-radius:8px;
        border:1px solid #e2e8f0;
        padding:10px 14px;
        font-size:.88rem
    }
    .form-control:focus{
        border-color:var(--pri);
        box-shadow:0 0 0 3px var(--pri-l)
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
    <jsp:include page="../shared/sidebar.jsp"><jsp:param name="activeMenu" value="shifts"/></jsp:include>
        <div class="main-content">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Quản Lý Ca Làm Việc</h1>
                    <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Ca làm việc</p>
            </div>
            <div class="d-flex gap-2">
                <button class="btn-add" data-bs-toggle="modal" data-bs-target="#deptShiftModal" style="background:#10b981"><i class="fas fa-building"></i> Gán Ca Cho PB</button>
                <button class="btn-add" data-bs-toggle="modal" data-bs-target="#shiftModal" onclick="openCreateModal()"><i class="fas fa-plus"></i> Thêm Ca Mới</button>
            </div>
        </div>

        <c:if test="${not empty sessionScope.message}"><div class="alert alert-c a-ok alert-dismissible fade show" role="alert"><i class="fas fa-check-circle me-2"></i>${sessionScope.message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><c:remove var="message" scope="session"/></c:if>
        <c:if test="${not empty sessionScope.error}"><div class="alert alert-c a-err alert-dismissible fade show" role="alert"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.error}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><c:remove var="error" scope="session"/></c:if>


            <div class="admin-panel">
                <div class="panel-header">
                    <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-clock"></i></div> Danh Sách Ca Làm Việc</h3>
                    <span style="font-size:.85rem;color:var(--muted)"><i class="fas fa-info-circle me-1"></i>Tổng: <strong>${shifts.size()}</strong> ca</span>
            </div>
            <!-- SEARCH & FILTER BAR -->
            <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;margin-bottom:18px;">
                <div style="position:relative;flex:1;min-width:200px;">
                    <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:.85rem;"></i>
                    <input type="text" id="searchInput" placeholder="Tìm ca làm việc..." oninput="filterTable()" style="width:100%;padding:9px 14px 9px 36px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;font-family:'Inter',sans-serif;">
                </div>
                <select id="statusFilter" onchange="filterTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;min-width:160px;font-family:'Inter',sans-serif;">
                    <option value="all">Tất cả trạng thái</option>
                    <option value="active">Hoạt động</option>
                    <option value="inactive">Vô hiệu</option>
                </select>
                <select id="typeFilter" onchange="filterTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;cursor:pointer;min-width:140px;font-family:'Inter',sans-serif;">
                    <option value="all">Tất cả loại</option>
                    <option value="day">Ca Ngày</option>
                    <option value="night">Ca Đêm</option>
                </select>
            </div>
            <c:choose>
                <c:when test="${empty shifts}">
                    <div style="text-align:center;padding:60px 20px;color:var(--muted)"><i class="fas fa-calendar-times d-block" style="font-size:3rem;margin-bottom:16px;opacity:.3"></i><p>Chưa có ca làm việc nào.</p></div>
                        </c:when>
                        <c:otherwise>
                    <div class="table-responsive">
                        <table class="tbl">
                            <thead><tr><th>ID</th><th>Tên Ca</th><th>Phòng Ban Áp Dụng</th><th>Thời Gian</th><th>Nghỉ Giữa Ca</th><th>Loại</th><th>Giờ Làm</th><th>Hệ số</th><th>Trạng Thái</th><th class="text-end">Hành Động</th></tr></thead>
                            <tbody>
                                <c:forEach var="s" items="${shifts}" varStatus="i">
                                    <tr>
                                        <td class="fw-bold" style="color:var(--txt)">#${s.shiftId}</td>
                                        <td><span class="fw-bold" style="color:var(--pri)">${s.shiftName}</span></td>
                                        <td>
                                            <div class="d-flex flex-wrap gap-1">
                                                <c:set var="hasDept" value="false" />
                                                <c:forEach var="ds" items="${deptShifts}">
                                                    <c:if test="${ds.shiftId == s.shiftId}">
                                                        <c:set var="hasDept" value="true" />
                                                        <span class="badge" style="background:#f1f5f9;color:var(--txt);border:1px solid #e2e8f0;padding:5px 8px;font-weight:500;font-size:0.75rem;">
                                                            ${ds.departmentName}
                                                            <form action="${pageContext.request.contextPath}/hr/shifts" method="POST" style="display:inline;margin-left:6px;" onsubmit="return confirm('Xóa ca mặc định này khỏi phòng ban ${ds.departmentName}?');">
                                                                <input type="hidden" name="action" value="removeDeptShift">
                                                                <input type="hidden" name="deptShiftId" value="${ds.id}">
                                                                <button type="submit" style="background:none;border:none;color:var(--ng);padding:0;cursor:pointer;" title="Xóa"><i class="fas fa-times"></i></button>
                                                            </form>
                                                        </span>
                                                    </c:if>
                                                </c:forEach>
                                                <c:if test="${!hasDept}">
                                                    <span style="color:var(--muted);font-size:.82rem">—</span>
                                                </c:if>
                                            </div>
                                        </td>
                                        <td><span class="time-d">${s.startTime}</span><span class="time-a"><i class="fas fa-arrow-right"></i></span><span class="time-d">${s.endTime}</span></td>
                                        <td><c:choose><c:when test="${not empty s.breakStart and not empty s.breakEnd}"><span class="time-d" style="font-size:.85rem">${s.breakStart} - ${s.breakEnd}</span></c:when><c:otherwise><span style="color:var(--muted);font-size:.82rem">—</span></c:otherwise></c:choose></td>
                                        <td><c:choose><c:when test="${nightShifts[i.index]}"><span class="b-night"><i class="fas fa-moon"></i> Ca Đêm</span></c:when><c:otherwise><span class="b-day"><i class="fas fa-sun"></i> Ca Ngày</span></c:otherwise></c:choose></td>
                                        <td><span class="hours-p">${workingHours[i.index]}h</span></td>
                                        <td><span class="coeff">x${s.coefficient}</span></td>
                                        <td><c:choose><c:when test="${s.status == 1}"><span class="badge-s b-active"><i class="fas fa-circle" style="font-size:6px"></i> Hoạt động</span></c:when><c:otherwise><span class="badge-s b-inactive"><i class="fas fa-circle" style="font-size:6px"></i> Vô hiệu</span></c:otherwise></c:choose></td>
                                                <td class="text-end">
                                                    <div class="d-flex justify-content-end gap-2">
                                                            <button class="btn-a btn-edit" title="Chỉnh sửa thông tin ca làm việc này" onclick="openEditModal(${s.shiftId}, '${s.shiftName}', '${s.startTime}', '${s.endTime}', '${s.breakStart}', '${s.breakEnd}',${s.nightShift},${s.coefficient})"><i class="fas fa-edit"></i></button>
                                                <form action="${pageContext.request.contextPath}/hr/shifts" method="POST" style="display:inline;" onsubmit="return confirm('${s.status==1?'Bạn có chắc chắn muốn KHÓA (Vô hiệu hóa) ca làm việc này không?':'Bạn có chắc chắn muốn MỞ KHÓA (Kích hoạt) ca làm việc này không?'}');">
                                                    <input type="hidden" name="action" value="toggleStatus">
                                                    <input type="hidden" name="shiftId" value="${s.shiftId}">
                                                    <button type="submit" class="btn-a ${s.status==1?'btn-tog-on':'btn-tog-off'}" title="${s.status==1?'Khóa (Vô hiệu hóa) ca làm việc này':'Mở khóa (Kích hoạt) ca làm việc này'}">
                                                        <i class="fas ${s.status==1?'fa-lock':'fa-unlock'}"></i>
                                                    </button>
                                                </form>
                                                <form action="${pageContext.request.contextPath}/hr/shifts" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn XÓA VĨNH VIỄN ca làm việc này không? Hành động này không thể hoàn tác!');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="shiftId" value="${s.shiftId}">
                                                    <button type="submit" class="btn-a btn-del" title="Xóa vĩnh viễn ca làm việc này">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- PAGINATION -->
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #f1f5f9;">
                        <div style="font-size:.85rem;color:var(--muted);">Hiển thị <span id="pageStart" style="font-weight:600;color:var(--txt);">0</span> - <span id="pageEnd" style="font-weight:600;color:var(--txt);">0</span> trong tổng số <span id="totalItems" style="font-weight:600;color:var(--txt);">0</span> ca</div>
                        <div style="display:flex;gap:8px;">
                            <button id="btnPrevPage" onclick="prevPage()" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-left"></i></button>
                            <div id="pageNumbers" style="display:flex;gap:4px;"></div>
                            <button id="btnNextPage" onclick="nextPage()" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--muted);cursor:pointer;"><i class="fas fa-chevron-right"></i></button>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Create/Edit Modal -->
<div class="modal fade" id="shiftModal" tabindex="-1"><div class="modal-dialog modal-dialog-centered"><div class="modal-content">
            <form id="shiftForm" method="POST">
                <div class="modal-header"><h5 class="modal-title" id="modalTitle">Thêm Ca Mới</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body">
                    <input type="hidden" name="shiftId" id="fId"/>
                    <div class="mb-3"><label class="form-label">Tên Ca <span class="text-danger">*</span></label><input type="text" class="form-control" name="shiftName" id="fName" maxlength="50" required></div>
                    <div class="row mb-3"><div class="col-6"><label class="form-label">Giờ Bắt Đầu *</label><input type="time" class="form-control" name="startTime" id="fStart" required></div><div class="col-6"><label class="form-label">Giờ Kết Thúc *</label><input type="time" class="form-control" name="endTime" id="fEnd" required></div></div>
                    <div class="row mb-3"><div class="col-6"><label class="form-label">Nghỉ Từ</label><input type="time" class="form-control" name="breakStart" id="fBS"></div><div class="col-6"><label class="form-label">Nghỉ Đến</label><input type="time" class="form-control" name="breakEnd" id="fBE"></div></div>
                    <div class="row mb-3"><div class="col-6"><label class="form-label">Hệ số lương</label><input type="number" step="0.1" min="1.0" max="5.0" class="form-control" name="coefficient" id="fCoeff" value="1.0"></div><div class="col-6 d-flex align-items-end"><div class="form-check form-switch mb-0"><input class="form-check-input" type="checkbox" name="isNightShift" id="fNight"><label class="form-check-label" for="fNight" style="font-weight:600;font-size:.85rem">Ca Đêm</label></div></div></div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px">Hủy</button><button type="submit" class="btn" id="modalBtn" style="background:var(--pri);color:#fff;border:none;border-radius:8px;font-weight:600"><i class="fas fa-save me-1"></i>Lưu</button></div>
            </form>
        </div></div></div>

<!-- Assign Dept Shift Modal -->
<div class="modal fade" id="deptShiftModal" tabindex="-1"><div class="modal-dialog modal-dialog-centered"><div class="modal-content">
    <form action="${pageContext.request.contextPath}/hr/shifts" method="POST">
        <input type="hidden" name="action" value="assignDept">
        <div class="modal-header"><h5 class="modal-title"><i class="fas fa-building me-2" style="color:var(--ok)"></i>Gán Ca Mặc Định Cho Phòng Ban</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
        <div class="modal-body">
            <div class="mb-3"><label class="form-label">Ca Làm Việc <span class="text-danger">*</span></label>
                <select class="form-select" name="shiftId" id="assignShiftId" onchange="onShiftSelect()" required>
                    <option value="">-- Chọn ca làm việc --</option>
                    <c:forEach var="s" items="${activeShifts}"><option value="${s.shiftId}">${s.shiftName}</option></c:forEach>
                </select>
            </div>
            <div class="mb-3"><label class="form-label">Phòng Ban <span class="text-danger">*</span></label>
                <select class="form-select" name="departmentId" id="assignDeptId" required>
                    <option value="">-- Chọn phòng ban --</option>
                    <c:forEach var="d" items="${departments}"><option value="${d.departmentId}">${d.departmentName}</option></c:forEach>
                </select>
            </div>
        </div>
        <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px">Hủy</button><button type="submit" class="btn" style="background:var(--ok);color:#fff;border:none;border-radius:8px;font-weight:600"><i class="fas fa-check me-1"></i>Gán Ca</button></div>
    </form>
</div></div></div>

<script>
    // Context path từ JSP, dùng cho các request AJAX nếu cần
    const ctx = '${pageContext.request.contextPath}';

// Biến toàn cục
    let currentPage = 1;       // Trang hiện tại, bắt đầu từ 1
    const itemsPerPage = 8;    // Số dòng hiển thị trên mỗi trang
    let filteredRows = [];     // Mảng các dòng thỏa điều kiện lọc
    let allRows = [];          // Mảng toàn bộ dòng trong bảng, cache một lần duy nhất

// Khởi tạo khi DOM load xong
// Lý do: đảm bảo bảng đã render trước khi query
    document.addEventListener('DOMContentLoaded', function () {
        // Cache toàn bộ dòng vào allRows, không query DOM lại ở các hàm khác
        allRows = Array.from(document.querySelectorAll('.tbl tbody tr'));

        // Chạy lọc lần đầu để hiển thị đúng trang 1
        filterTable();
    });

// Lọc bảng theo ô tìm kiếm, dropdown status và dropdown type
    function filterTable() {
        // Lấy giá trị tìm kiếm, chuyển về chữ thường để so khớp không phân biệt hoa thường
        const query = document.getElementById('searchInput').value.toLowerCase();

        // Lấy giá trị filter status: 'all', 'active', hoặc 'inactive'
        const statusVal = document.getElementById('statusFilter').value;

        // Lấy giá trị filter type: 'all', 'day', hoặc 'night'
        const typeVal = document.getElementById('typeFilter').value;

        // Lọc từ allRows đã cache, không query DOM lại
        filteredRows = allRows.filter(function (row) {
            // Kiểm tra dòng có chứa text tìm kiếm không
            const matchText = row.textContent.toLowerCase().includes(query);

            // Tìm badge status trong dòng để xác định active/inactive
            const statusBadge = row.querySelector('.badge-s');

            // Mặc định là 'active', ghi đè nếu badge có class 'b-inactive'
            let rowStatus = 'active';
            if (statusBadge && statusBadge.classList.contains('b-inactive'))
                rowStatus = 'inactive';

            // Khớp nếu filter là 'all' hoặc trùng với trạng thái dòng
            const matchStatus = statusVal === 'all' || rowStatus === statusVal;

            // Tìm badge type trong dòng để xác định day/night
            const typeBadge = row.querySelector('.b-night, .b-day');

            // Mặc định là 'day', ghi đè nếu badge có class 'b-night'
            let rowType = 'day';
            if (typeBadge && typeBadge.classList.contains('b-night'))
                rowType = 'night';

            // Khớp nếu filter là 'all' hoặc trùng với loại ca
            const matchType = typeVal === 'all' || rowType === typeVal;

            // Dòng chỉ hiển thị khi thỏa cả ba điều kiện
            return matchText && matchStatus && matchType;
        });

        // Reset về trang 1 sau mỗi lần lọc
        currentPage = 1;

        // Cập nhật giao diện phân trang
        updatePagination();
    }

// Cập nhật hiển thị bảng và các nút phân trang
    function updatePagination() {
        // Ẩn toàn bộ dòng trước, chỉ hiện lại các dòng thuộc trang hiện tại
        allRows.forEach(row => row.style.display = 'none');

        // Trường hợp không có dòng nào thỏa điều kiện
        if (filteredRows.length === 0) {
            // Reset thông tin hiển thị về 0
            document.getElementById('pageStart').textContent = 0;
            document.getElementById('pageEnd').textContent = 0;
            document.getElementById('totalItems').textContent = 0;

            // Xóa các nút số trang
            document.getElementById('pageNumbers').innerHTML = '';

            // Vô hiệu hóa cả hai nút Prev và Next
            document.getElementById('btnPrevPage').disabled = true;
            document.getElementById('btnNextPage').disabled = true;
            return;
        }

        // Tính tổng số trang dựa trên số dòng lọc được
        const totalPages = Math.ceil(filteredRows.length / itemsPerPage);

        // Giới hạn currentPage trong khoảng hợp lệ [1, totalPages]
        if (currentPage > totalPages)
            currentPage = totalPages;
        if (currentPage < 1)
            currentPage = 1;

        // Tính chỉ số dòng đầu và cuối của trang hiện tại
        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = Math.min(startIndex + itemsPerPage, filteredRows.length);

        // Hiện các dòng thuộc trang hiện tại
        for (let i = startIndex; i < endIndex; i++) {
            filteredRows[i].style.display = '';
        }

        // Cập nhật thông tin "Hiển thị X - Y / Z mục"
        document.getElementById('pageStart').textContent = startIndex + 1;
        document.getElementById('pageEnd').textContent = endIndex;
        document.getElementById('totalItems').textContent = filteredRows.length;

        // Render các nút số trang
        let pageHtml = '';
        for (let i = 1; i <= totalPages; i++) {
            // Trang hiện tại dùng màu --pri, các trang khác màu trắng
            pageHtml += '<button style="background:' + (i === currentPage ? 'var(--pri)' : '#fff') + ';border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:' + (i === currentPage ? 'white' : 'var(--muted)') + ';cursor:pointer;" onclick="goToPage(' + i + ')">' + i + '</button>';
        }
        document.getElementById('pageNumbers').innerHTML = pageHtml;

        // Vô hiệu hóa nút Prev nếu đang ở trang đầu
        document.getElementById('btnPrevPage').disabled = currentPage === 1;

        // Vô hiệu hóa nút Next nếu đang ở trang cuối
        document.getElementById('btnNextPage').disabled = currentPage === totalPages;
    }

// Nhảy thẳng đến trang chỉ định khi click vào nút số trang
    function goToPage(page) {
        currentPage = page;
        updatePagination();
    }

// Lùi về trang trước, không vượt quá trang 1
    function prevPage() {
        if (currentPage > 1) {
            currentPage--;
            updatePagination();
        }
    }

// Tiến đến trang sau, không vượt quá trang cuối
    function nextPage() {
        const tp = Math.ceil(filteredRows.length / itemsPerPage);
        if (currentPage < tp) {
            currentPage++;
            updatePagination();
        }
    }

    function openCreateModal() {
        document.getElementById('modalTitle').textContent = 'Thêm Ca Mới';
        document.getElementById('shiftForm').action = ctx + '/hr/shifts?action=create';
        ['fId', 'fName', 'fStart', 'fEnd', 'fBS', 'fBE'].forEach(id => document.getElementById(id).value = '');
        document.getElementById('fCoeff').value = '1.0';
        document.getElementById('fNight').checked = false;
        document.getElementById('modalBtn').innerHTML = '<i class="fas fa-plus me-1"></i>Thêm';
    }
    function openEditModal(id, n, st, en, bs, be, night, coeff) {
        document.getElementById('modalTitle').textContent = 'Chỉnh Sửa Ca';
        document.getElementById('shiftForm').action = ctx + '/hr/shifts?action=update';
        document.getElementById('fId').value = id;
        document.getElementById('fName').value = n;
        document.getElementById('fStart').value = st;
        document.getElementById('fEnd').value = en;
        document.getElementById('fBS').value = (bs === 'null' ? '' : bs);
        document.getElementById('fBE').value = (be === 'null' ? '' : be);
        document.getElementById('fNight').checked = night;
        document.getElementById('fCoeff').value = coeff;
        document.getElementById('modalBtn').innerHTML = '<i class="fas fa-save me-1"></i>Cập Nhật';
        new bootstrap.Modal(document.getElementById('shiftModal')).show();
    }

    document.addEventListener('DOMContentLoaded', function () {
        filteredRows = Array.from(document.querySelectorAll('.tbl tbody tr'));
        updatePagination();
    });

    const deptShiftsData = [
<c:forEach var="ds" items="${deptShifts}" varStatus="st">
    { deptId: ${ds.departmentId}, shiftId: ${ds.shiftId} }${!st.last ? ',' : ''}
</c:forEach>
    ];

    function onShiftSelect() {
        const shiftId = document.getElementById('assignShiftId').value;
        const deptSelect = document.getElementById('assignDeptId');
        
        Array.from(deptSelect.options).forEach(opt => {
            opt.style.display = '';
        });

        if(shiftId) {
            const assignedDeptIds = deptShiftsData.filter(ds => ds.shiftId == shiftId).map(ds => ds.deptId);
            Array.from(deptSelect.options).forEach(opt => {
                if(opt.value && assignedDeptIds.includes(parseInt(opt.value))) {
                    opt.style.display = 'none';
                }
            });
            if(deptSelect.options[deptSelect.selectedIndex].style.display === 'none') {
                deptSelect.value = '';
            }
        }
    }
</script>
<jsp:include page="../footer.jsp"/>

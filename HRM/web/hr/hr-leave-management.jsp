<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý nghỉ phép (HR) - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    .hr-layout { display: flex; min-height: calc(100vh - 64px); }
    .hr-content { flex: 1; padding: 30px; overflow-y: auto; }
    .page-banner {
        background: linear-gradient(135deg, #1e3a8a, #3b82f6);
        color: white; border-radius: 14px; padding: 24px; margin-bottom: 24px;
    }
    .page-banner h2 { margin: 0 0 5px; font-weight: 700; }
    .page-banner p { margin: 0; opacity: 0.8; }
    
    .nav-tabs .nav-link { font-weight: 600; color: #64748b; }
    .nav-tabs .nav-link.active { color: #1e3a8a; border-bottom: 2px solid #1e3a8a; }
    .card { border-radius: 14px; border: 1px solid #e2e8f0; margin-top: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
    .card-header { background: #f8fafc; font-weight: 700; border-bottom: 1px solid #e2e8f0; padding: 15px 20px; }
    .table th { background: #f1f5f9; text-transform: uppercase; font-size: 0.8rem; color: #475569; }
</style>

<div class="hr-layout">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="leaveManagement" />
    </jsp:include>

    <div class="hr-content">
        <div class="page-banner">
            <h2><i class="fas fa-umbrella-beach"></i> Quản lý nghỉ phép toàn hệ thống</h2>
            <p>Cấu hình loại nghỉ phép và xem toàn bộ đơn xin nghỉ phép của nhân viên.</p>
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
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
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <span>Danh sách Loại nghỉ phép</span>
                        <div class="d-flex gap-2 align-items-center">
                            <input type="text" id="typeSearch" class="form-control form-control-sm" placeholder="Tìm tên loại, mô tả..." oninput="filterTypeTable()" style="max-width: 200px;">
                            <select id="typeStatus" class="form-select form-select-sm" onchange="filterTypeTable()" style="max-width: 140px;">
                                <option value="all">Tất cả</option>
                                <option value="Hoạt động">Hoạt động</option>
                                <option value="Đã xóa">Đã xóa</option>
                            </select>
                            <button class="btn btn-primary btn-sm text-nowrap" data-bs-toggle="modal" data-bs-target="#addTypeModal">
                                <i class="fas fa-plus"></i> Thêm mới
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <table class="table table-hover align-middle" id="typeTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên loại</th>
                                    <th>Mô tả</th>
                                    <th>Có lương?</th>
                                    <th>Tối đa (Ngày/Năm)</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody id="typeTbody">
                                <c:forEach var="leaveTypeItem" items="${leaveTypes}">
                                    <tr>
                                        <td>${leaveTypeItem.leaveTypeId}</td>
                                        <td><strong>${leaveTypeItem.typeName}</strong></td>
                                        <td>${leaveTypeItem.description}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${leaveTypeItem.paidLeave == 1}"><span class="badge bg-success">Có</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary">Không</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${empty leaveTypeItem.maxDaysPerYear ? 'Không giới hạn' : leaveTypeItem.maxDaysPerYear}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${leaveTypeItem.status == 1}"><span class="badge bg-primary">Hoạt động</span></c:when>
                                                <c:otherwise><span class="badge bg-danger">Đã xóa</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-primary" 
                                                onclick="editType('${leaveTypeItem.leaveTypeId}', '${leaveTypeItem.typeName}', '${leaveTypeItem.description}', '${leaveTypeItem.paidLeave}', '${leaveTypeItem.maxDaysPerYear}', '${leaveTypeItem.status}')" 
                                                data-bs-toggle="modal" data-bs-target="#editTypeModal">Sửa</button>
                                            <c:if test="${leaveTypeItem.status == 1}">
                                                <form action="${pageContext.request.contextPath}/hr/leave" method="POST" style="display:inline;">
                                                    <input type="hidden" name="action" value="deleteType">
                                                    <input type="hidden" name="leaveTypeId" value="${leaveTypeItem.leaveTypeId}">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Bạn có chắc muốn xóa loại nghỉ phép này?');">Xóa</button>
                                                </form>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        <div class="d-flex justify-content-between align-items-center mt-3" id="typePaginationWrapper">
                            <span id="typePageInfo" style="font-size: 0.85rem; color: #64748b;">Đang tải...</span>
                            <div class="btn-group">
                                <button class="btn btn-sm btn-outline-secondary" onclick="typePrevPage()" id="btnTypePrev">Trước</button>
                                <button class="btn btn-sm btn-outline-secondary" onclick="typeNextPage()" id="btnTypeNext">Sau</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- All Requests Tab -->
            <div class="tab-pane fade" id="allRequests">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <span>Toàn bộ Đơn xin nghỉ phép (Toàn công ty)</span>
                        <div class="d-flex gap-2">
                            <input type="text" id="reqSearch" class="form-control form-control-sm" placeholder="Tìm nhân viên, loại..." oninput="filterReqTable()" style="max-width: 200px;">
                            <select id="reqStatus" class="form-select form-select-sm" onchange="filterReqTable()" style="max-width: 150px;">
                                <option value="all">Tất cả trạng thái</option>
                                <option value="Chờ duyệt">Chờ duyệt</option>
                                <option value="Đã duyệt">Đã duyệt</option>
                                <option value="Từ chối">Từ chối</option>
                            </select>
                        </div>
                    </div>
                    <div class="card-body">
                        <table class="table table-hover align-middle" id="reqTable">
                            <thead>
                                <tr>
                                    <th>Nhân viên</th>
                                    <th>Loại nghỉ</th>
                                    <th>Từ ngày</th>
                                    <th>Đến ngày</th>
                                    <th>Số ngày</th>
                                    <th>Trạng thái</th>
                                    <th>Người duyệt</th>
                                </tr>
                            </thead>
                            <tbody id="reqTbody">
                                <c:forEach var="r" items="${allRequests}">
                                    <tr>
                                        <td>${r.userName}</td>
                                        <td>${r.leaveTypeName}</td>
                                        <td>${r.startDate}</td>
                                        <td>${r.endDate}</td>
                                        <td>${r.totalDays}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.status == 'Approved'}"><span class="badge bg-success">Đã duyệt</span></c:when>
                                                <c:when test="${r.status == 'Rejected'}"><span class="badge bg-danger">Từ chối</span></c:when>
                                                <c:otherwise><span class="badge bg-warning text-dark">Chờ duyệt</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${r.approvedBy > 0 ? r.approvedBy : '-'}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        <div class="d-flex justify-content-between align-items-center mt-3" id="reqPaginationWrapper">
                            <span id="reqPageInfo" style="font-size: 0.85rem; color: #64748b;">Đang tải...</span>
                            <div class="btn-group">
                                <button class="btn btn-sm btn-outline-secondary" onclick="reqPrevPage()" id="btnReqPrev">Trước</button>
                                <button class="btn btn-sm btn-outline-secondary" onclick="reqNextPage()" id="btnReqNext">Sau</button>
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
        <form action="${pageContext.request.contextPath}/hr/leave" method="POST" class="modal-content">
            <input type="hidden" name="action" value="addType">
            <div class="modal-header">
                <h5 class="modal-title">Thêm Loại Nghỉ Phép</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3"><label>Tên loại</label><input type="text" name="typeName" class="form-control" required></div>
                <div class="mb-3"><label>Mô tả</label><input type="text" name="description" class="form-control"></div>
                <div class="mb-3"><label>Có lương?</label>
                    <select name="paidLeave" class="form-select">
                        <option value="1">Có</option>
                        <option value="0">Không</option>
                    </select>
                </div>
                <div class="mb-3"><label>Số ngày tối đa/năm (để trống nếu không giới hạn)</label><input type="number" name="maxDaysPerYear" class="form-control"></div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-primary">Lưu</button></div>
        </form>
    </div>
</div>

<!-- Edit Modal -->
<div class="modal fade" id="editTypeModal">
    <div class="modal-dialog">
        <form action="${pageContext.request.contextPath}/hr/leave" method="POST" class="modal-content">
            <input type="hidden" name="action" value="editType">
            <input type="hidden" name="leaveTypeId" id="editId">
            <div class="modal-header">
                <h5 class="modal-title">Cập nhật Loại Nghỉ Phép</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3"><label>Tên loại</label><input type="text" name="typeName" id="editName" class="form-control" required></div>
                <div class="mb-3"><label>Mô tả</label><input type="text" name="description" id="editDesc" class="form-control"></div>
                <div class="mb-3"><label>Có lương?</label>
                    <select name="paidLeave" id="editPaid" class="form-select">
                        <option value="1">Có</option>
                        <option value="0">Không</option>
                    </select>
                </div>
                <div class="mb-3"><label>Số ngày tối đa/năm</label><input type="number" name="maxDaysPerYear" id="editMax" class="form-control"></div>
                <div class="mb-3"><label>Trạng thái</label>
                    <select name="status" id="editStatus" class="form-select">
                        <option value="1">Hoạt động</option>
                        <option value="0">Đã xóa (Vô hiệu)</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-primary">Cập nhật</button></div>
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
            const badges = row.querySelectorAll('.badge');
            // Status badge is the second badge in the row (index 1)
            if (badges.length > 1) {
                const rowStatus = badges[1].textContent.trim();
                statusMatch = (rowStatus === status);
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

    reqFilteredRows = reqAllRows.filter(row => {
        const textMatch = row.textContent.toLowerCase().includes(query);
        let statusMatch = true;
        if (status !== 'all') {
            const rowStatus = row.querySelector('.badge').textContent.trim();
            statusMatch = (rowStatus === status);
        }
        return textMatch && statusMatch;
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

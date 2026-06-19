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
                    <h1 class="page-title">Danh Sách Ca Làm Việc Mặc Định</h1>
                    <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; Ca làm việc</p>
            </div>
        </div>

        <c:if test="${not empty sessionScope.message}"><div class="alert alert-c a-ok alert-dismissible fade show" role="alert"><i class="fas fa-check-circle me-2"></i>${sessionScope.message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><c:remove var="message" scope="session"/></c:if>
        <c:if test="${not empty sessionScope.error}"><div class="alert alert-c a-err alert-dismissible fade show" role="alert"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.error}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><c:remove var="error" scope="session"/></c:if>

            <div class="admin-panel">
                <div class="panel-header">
                    <h3 class="panel-title"><div class="panel-icon"><i class="fas fa-clock"></i></div> Thông Tin Các Ca</h3>
                    <span style="font-size:.85rem;color:var(--muted)"><i class="fas fa-info-circle me-1"></i>Hệ thống đã thiết lập mặc định</span>
            </div>
            <!-- SEARCH & FILTER BAR -->
            <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;margin-bottom:18px;">
                <div style="position:relative;flex:1;min-width:200px;">
                    <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:.85rem;"></i>
                    <input type="text" id="searchInput" placeholder="Tìm ca làm việc..." oninput="filterTable()" style="width:100%;padding:9px 14px 9px 36px;border:1px solid #e2e8f0;border-radius:8px;font-size:.88rem;outline:none;font-family:'Inter',sans-serif;">
                </div>
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
                            <thead><tr><th>ID</th><th>Tên Ca</th><th>Phạm Vi</th><th>Thời Gian</th><th>Nghỉ Giữa Ca</th><th>Loại</th><th>Giờ Làm</th><th>Hệ số</th><th>Trạng Thái</th></tr></thead>
                            <tbody>
                                <c:forEach var="s" items="${shifts}" varStatus="i">
                                    <tr>
                                        <td class="fw-bold" style="color:var(--txt)">#${s.shiftId}</td>
                                        <td><span class="fw-bold" style="color:var(--pri)">${s.shiftName}</span></td>
                                        <td>
                                            <span class="badge" style="background:#f1f5f9;color:var(--txt);border:1px solid #e2e8f0;padding:5px 8px;font-weight:500;font-size:0.75rem;">
                                                <c:choose>
                                                    <c:when test="${nightShifts[i.index]}">Nhân Viên (Employee)</c:when>
                                                    <c:otherwise>Tất cả phòng ban</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td><span class="time-d">${s.startTime}</span><span class="time-a"><i class="fas fa-arrow-right"></i></span><span class="time-d">${s.endTime}</span></td>
                                        <td><c:choose><c:when test="${not empty s.breakStart and not empty s.breakEnd}"><span class="time-d" style="font-size:.85rem">${s.breakStart} - ${s.breakEnd}</span></c:when><c:otherwise><span style="color:var(--muted);font-size:.82rem">—</span></c:otherwise></c:choose></td>
                                        <td><c:choose><c:when test="${nightShifts[i.index]}"><span class="b-night"><i class="fas fa-moon"></i> Ca Đêm</span></c:when><c:otherwise><span class="b-day"><i class="fas fa-sun"></i> Ca Ngày</span></c:otherwise></c:choose></td>
                                        <td><span class="hours-p">${workingHours[i.index]}h</span></td>
                                        <td><span class="coeff">x${s.coefficient}</span></td>
                                        <td><c:choose><c:when test="${s.status == 1}"><span class="badge-s b-active"><i class="fas fa-circle" style="font-size:6px"></i> Hoạt động</span></c:when><c:otherwise><span class="badge-s b-inactive"><i class="fas fa-circle" style="font-size:6px"></i> Vô hiệu</span></c:otherwise></c:choose></td>
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

<script>
    let currentPage = 1;       
    const itemsPerPage = 8;    
    let filteredRows = [];     
    let allRows = [];          

    document.addEventListener('DOMContentLoaded', function () {
        allRows = Array.from(document.querySelectorAll('.tbl tbody tr'));
        filterTable();
    });

    function filterTable() {
        const query = document.getElementById('searchInput').value.toLowerCase();
        const typeVal = document.getElementById('typeFilter').value;

        filteredRows = allRows.filter(function (row) {
            const matchText = row.textContent.toLowerCase().includes(query);
            const typeBadge = row.querySelector('.b-night, .b-day');
            let rowType = 'day';
            if (typeBadge && typeBadge.classList.contains('b-night')) rowType = 'night';
            const matchType = typeVal === 'all' || rowType === typeVal;

            return matchText && matchType;
        });

        currentPage = 1;
        updatePagination();
    }

    function updatePagination() {
        allRows.forEach(row => row.style.display = 'none');

        if (filteredRows.length === 0) {
            document.getElementById('pageStart').textContent = 0;
            document.getElementById('pageEnd').textContent = 0;
            document.getElementById('totalItems').textContent = 0;
            document.getElementById('pageNumbers').innerHTML = '';
            document.getElementById('btnPrevPage').disabled = true;
            document.getElementById('btnNextPage').disabled = true;
            return;
        }

        const totalPages = Math.ceil(filteredRows.length / itemsPerPage);
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = Math.min(startIndex + itemsPerPage, filteredRows.length);

        for (let i = startIndex; i < endIndex; i++) {
            filteredRows[i].style.display = '';
        }

        document.getElementById('pageStart').textContent = startIndex + 1;
        document.getElementById('pageEnd').textContent = endIndex;
        document.getElementById('totalItems').textContent = filteredRows.length;

        let pageHtml = '';
        for (let i = 1; i <= totalPages; i++) {
            pageHtml += '<button style="background:' + (i === currentPage ? 'var(--pri)' : '#fff') + ';border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:' + (i === currentPage ? 'white' : 'var(--muted)') + ';cursor:pointer;" onclick="goToPage(' + i + ')">' + i + '</button>';
        }
        document.getElementById('pageNumbers').innerHTML = pageHtml;
        document.getElementById('btnPrevPage').disabled = currentPage === 1;
        document.getElementById('btnNextPage').disabled = currentPage === totalPages;
    }

    function goToPage(page) { currentPage = page; updatePagination(); }
    function prevPage() { if (currentPage > 1) { currentPage--; updatePagination(); } }
    function nextPage() { const tp = Math.ceil(filteredRows.length / itemsPerPage); if (currentPage < tp) { currentPage++; updatePagination(); } }
</script>
<jsp:include page="../footer.jsp"/>

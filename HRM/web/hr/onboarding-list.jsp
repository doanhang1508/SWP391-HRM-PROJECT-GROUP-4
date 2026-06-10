<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Danh Sách Yêu Cầu Onboarding" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
:root{--navy:#0a2540;--blue:#2563eb;--teal:#0d9488;--accent:#f97316;--bg:#f0ede8;--surface:#fff;--border:#e2e8f0;--text:#0f172a;--muted:#64748b;--success:#16a34a;--danger:#dc2626;}
*{box-sizing:border-box;}
body{background:var(--bg);font-family:'Inter',sans-serif;color:var(--text);}
.ob-wrapper{display:flex;min-height:calc(100vh - 64px);}
.ob-main{flex:1;padding:32px 36px;overflow-x:hidden;}

.page-topbar{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:28px;flex-wrap:wrap;gap:12px;}
.breadcrumb-txt{font-size:.78rem;color:var(--muted);display:flex;align-items:center;gap:6px;margin-bottom:6px;}
.breadcrumb-txt a{color:var(--blue);text-decoration:none;}
.page-title{font-family:'Be Vietnam Pro',sans-serif;font-size:1.6rem;font-weight:800;color:var(--navy);letter-spacing:-.5px;margin:0;}

.btn{display:inline-flex;align-items:center;gap:8px;padding:10px 20px;border-radius:12px;font-size:.88rem;font-weight:700;cursor:pointer;border:none;transition:all .2s;text-decoration:none;}
.btn-primary{background:linear-gradient(135deg,var(--navy),#1e40af);color:#fff;box-shadow:0 4px 14px rgba(10,37,64,.3);}
.btn-primary:hover{transform:translateY(-2px);}

/* Summary cards */
.summary-row{display:flex;gap:14px;margin-bottom:24px;flex-wrap:wrap;}
.sum-card{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:16px 20px;display:flex;align-items:center;gap:14px;min-width:140px;flex:1;}
.sum-icon{width:42px;height:42px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;}
.si-orange{background:linear-gradient(135deg,#ffedd5,#fed7aa);color:var(--accent);}
.si-blue{background:linear-gradient(135deg,#dbeafe,#bfdbfe);color:var(--blue);}
.si-green{background:linear-gradient(135deg,#dcfce7,#bbf7d0);color:var(--success);}
.si-red{background:linear-gradient(135deg,#fee2e2,#fecaca);color:var(--danger);}
.sum-val{font-family:'Be Vietnam Pro',sans-serif;font-size:1.5rem;font-weight:800;color:var(--navy);line-height:1;}
.sum-label{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);margin-top:3px;}

/* Panel */
.panel{background:var(--surface);border:1px solid var(--border);border-radius:18px;overflow:hidden;}
.panel-header{display:flex;align-items:center;justify-content:space-between;padding:20px 24px;border-bottom:1px solid var(--border);}
.panel-title{font-family:'Be Vietnam Pro',sans-serif;font-size:1rem;font-weight:800;color:var(--navy);margin:0;display:flex;align-items:center;gap:10px;}
.dot-orange{width:8px;height:8px;border-radius:50%;background:var(--accent);}

/* Filter tabs */
.filter-tabs{display:flex;gap:8px;padding:16px 24px;border-bottom:1px solid var(--border);flex-wrap:wrap;}
.ftab{padding:7px 16px;border-radius:20px;font-size:.8rem;font-weight:700;border:1.5px solid var(--border);background:transparent;color:var(--muted);cursor:pointer;transition:all .2s;display:flex;align-items:center;gap:6px;text-decoration:none;}
.ftab:hover,.ftab.active{background:var(--navy);border-color:var(--navy);color:#fff;}
.ftab .cnt{background:rgba(255,255,255,.2);padding:1px 7px;border-radius:10px;font-size:.7rem;}
.ftab:not(.active) .cnt{background:#f1f5f9;color:var(--navy);}

/* Table */
.req-table{width:100%;border-collapse:collapse;}
.req-table thead th{font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--muted);padding:12px 16px;border-bottom:2px solid var(--border);text-align:left;background:#fafbfc;white-space:nowrap;}
.req-table tbody td{padding:14px 16px;font-size:.875rem;border-bottom:1px solid #f8fafc;vertical-align:middle;}
.req-table tbody tr:last-child td{border-bottom:none;}
.req-table tbody tr{transition:background .15s;}
.req-table tbody tr:hover td{background:#f8fafc;}

.emp-cell{display:flex;align-items:center;gap:10px;}
.emp-av{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.9rem;flex-shrink:0;color:#fff;}

/* Status badges */
.sbadge{display:inline-flex;align-items:center;gap:5px;padding:4px 12px;border-radius:20px;font-size:.75rem;font-weight:700;}
.s-draft{background:#f1f5f9;color:#475569;}
.s-pending{background:#eff6ff;color:#1d4ed8;}
.s-approved{background:#f0fdf4;color:var(--success);}
.s-rejected{background:#fef2f2;color:var(--danger);}

/* Action buttons */
.act-btns{display:flex;gap:6px;}
.abtn{padding:6px 14px;border-radius:8px;border:none;font-size:.78rem;font-weight:700;cursor:pointer;transition:all .15s;display:flex;align-items:center;gap:5px;text-decoration:none;}
.abtn-edit{background:#f1f5f9;color:var(--navy);}
.abtn-edit:hover{background:var(--navy);color:#fff;}
.abtn-submit{background:#eff6ff;color:var(--blue);}
.abtn-submit:hover{background:var(--blue);color:#fff;}

/* Alert */
.alert{padding:12px 16px;border-radius:10px;font-size:.85rem;font-weight:600;margin-bottom:20px;display:flex;align-items:center;gap:10px;}
.alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#14532d;}

/* Empty state */
.empty-state{padding:60px 20px;text-align:center;}
.empty-icon{font-size:3rem;color:#cbd5e0;margin-bottom:16px;}
.empty-title{font-family:'Be Vietnam Pro',sans-serif;font-size:1.1rem;font-weight:700;color:var(--navy);margin-bottom:8px;}
.empty-sub{font-size:.88rem;color:var(--muted);}

@media(max-width:768px){.ob-main{padding:20px 16px;}.col-hide{display:none;}}
</style>

<div class="ob-wrapper">
  <jsp:include page="../shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="onboarding" />
  </jsp:include>

  <div class="ob-main">

    <!-- TOP BAR -->
    <div class="page-topbar">
      <div>
        <div class="breadcrumb-txt">
          <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
          <span>/</span><span>Tiếp nhận nhân viên</span>
        </div>
        <h1 class="page-title"><i class="fas fa-user-clock" style="color:var(--teal);margin-right:8px;"></i>Yêu Cầu Tuyển Dụng Của Tôi</h1>
      </div>
      <a href="${pageContext.request.contextPath}/hr/onboarding/upload" class="btn btn-primary">
        <i class="fas fa-plus"></i> Tạo yêu cầu mới
      </a>
    </div>

    <!-- ALERT -->
    <c:if test="${not empty param.msg}">
      <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${param.msg}"/></div>
    </c:if>

    <!-- SUMMARY -->
    <div class="summary-row">
      <div class="sum-card">
        <div class="sum-icon si-orange"><i class="fas fa-list"></i></div>
        <div><div class="sum-val">${requests.size()}</div><div class="sum-label">Tổng yêu cầu</div></div>
      </div>
      <div class="sum-card">
        <div class="sum-icon si-blue"><i class="fas fa-hourglass-half"></i></div>
        <div>
          <div class="sum-val">
            <c:set var="cntPending" value="0"/>
            <c:forEach var="r" items="${requests}"><c:if test="${r.status=='PENDING'}"><c:set var="cntPending" value="${cntPending+1}"/></c:if></c:forEach>
            ${cntPending}
          </div>
          <div class="sum-label">Chờ duyệt</div>
        </div>
      </div>
      <div class="sum-card">
        <div class="sum-icon si-green"><i class="fas fa-check-circle"></i></div>
        <div>
          <div class="sum-val">
            <c:set var="cntApproved" value="0"/>
            <c:forEach var="r" items="${requests}"><c:if test="${r.status=='APPROVED'}"><c:set var="cntApproved" value="${cntApproved+1}"/></c:if></c:forEach>
            ${cntApproved}
          </div>
          <div class="sum-label">Đã duyệt</div>
        </div>
      </div>
      <div class="sum-card">
        <div class="sum-icon si-red"><i class="fas fa-times-circle"></i></div>
        <div>
          <div class="sum-val">
            <c:set var="cntRejected" value="0"/>
            <c:forEach var="r" items="${requests}"><c:if test="${r.status=='REJECTED'}"><c:set var="cntRejected" value="${cntRejected+1}"/></c:if></c:forEach>
            ${cntRejected}
          </div>
          <div class="sum-label">Bị từ chối</div>
        </div>
      </div>
    </div>

    <!-- PANEL -->
    <div class="panel">
      <div class="panel-header">
        <h3 class="panel-title"><div class="dot-orange"></div> Danh sách yêu cầu</h3>
        <div style="display:flex; gap:10px; align-items:center;">
            <select id="deptFilter" onchange="filterTable()" style="padding:8px 16px;border:1.5px solid var(--border);border-radius:8px;font-family:'Inter',sans-serif;font-size:0.85rem;outline:none;background:#fff;transition:border-color 0.2s;" onfocus="this.style.borderColor='var(--navy)'" onblur="this.style.borderColor='var(--border)'">
                <option value="">Tất cả phòng ban</option>
                <c:forEach var="d" items="${departments}">
                    <option value="${d.departmentName}">${d.departmentName}</option>
                </c:forEach>
            </select>
            <div class="search-box" style="position:relative;">
                <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:0.85rem;"></i>
                <input type="text" id="searchInput" placeholder="Tìm kiếm ứng viên, SĐT..." onkeyup="filterTable()" style="padding:8px 16px 8px 34px;border:1.5px solid var(--border);border-radius:8px;font-family:'Inter',sans-serif;font-size:0.85rem;outline:none;width:250px;transition:border-color 0.2s;" onfocus="this.style.borderColor='var(--navy)'" onblur="this.style.borderColor='var(--border)'">
            </div>
        </div>
      </div>
      <div style="overflow-x:auto;">
        <table class="req-table table-custom">
          <thead>
            <tr>
              <th>#</th><th>Ứng viên</th><th class="col-hide">Email</th>
              <th class="col-hide">Phòng ban</th><th>Trạng thái</th>
              <th class="col-hide">Ngày gửi</th><th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty requests}">
                <tr class="empty-state-row"><td colspan="7">
                  <div class="empty-state">
                    <div class="empty-icon"><i class="fas fa-folder-open"></i></div>
                    <div class="empty-title">Chưa có yêu cầu nào</div>
                    <div class="empty-sub">Nhấn "+ Tạo yêu cầu mới" để bắt đầu quy trình onboarding.</div>
                  </div>
                </td></tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="r" items="${requests}" varStatus="loop">
                  <c:set var="avColors" value="linear-gradient(135deg,#667eea,#764ba2),linear-gradient(135deg,#f093fb,#f5576c),linear-gradient(135deg,#4facfe,#00f2fe),linear-gradient(135deg,#43e97b,#38f9d7),linear-gradient(135deg,#fa709a,#fee140)"/>
                  <tr>
                    <td style="color:var(--muted);font-weight:700;font-size:.8rem;">${String.format('%02d', loop.index + 1)}</td>
                    <td>
                      <div class="emp-cell">
                        <div class="emp-av" style="background:${loop.index % 2 == 0 ? 'linear-gradient(135deg,#667eea,#764ba2)' : 'linear-gradient(135deg,#4facfe,#00f2fe)'};">
                          <c:out value="${r.initial}"/>
                        </div>
                        <div>
                          <div style="font-weight:700;color:var(--navy);"><c:out value="${r.fullName}"/></div>
                          <div style="font-size:.75rem;color:var(--muted);"><c:out value="${r.phone}"/></div>
                        </div>
                      </div>
                    </td>
                    <td class="col-hide" style="color:var(--muted);font-size:.83rem;"><c:out value="${r.email}"/></td>
                    <td class="col-hide" style="font-size:.83rem;"><c:out value="${not empty r.departmentName ? r.departmentName : '—'}"/></td>
                    <td>
                      <c:choose>
                        <c:when test="${r.status=='DRAFT'}">    <span class="sbadge s-draft"><i class="fas fa-pencil-alt"></i> Bản nháp</span></c:when>
                        <c:when test="${r.status=='PENDING'}">  <span class="sbadge s-pending"><i class="fas fa-clock"></i> Chờ duyệt</span></c:when>
                        <c:when test="${r.status=='APPROVED'}"> <span class="sbadge s-approved"><i class="fas fa-check-circle"></i> Đã duyệt</span></c:when>
                        <c:when test="${r.status=='REJECTED'}"> <span class="sbadge s-rejected"><i class="fas fa-times-circle"></i> Từ chối</span></c:when>
                      </c:choose>
                    </td>
                    <td class="col-hide" style="font-size:.82rem;color:var(--muted);">
                      <fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy"/>
                    </td>
                    <td>
                      <div class="act-btns">
                        <c:if test="${r.status=='DRAFT' || r.status=='REJECTED'}">
                          <a href="${pageContext.request.contextPath}/hr/onboarding/edit?id=${r.id}" class="abtn abtn-edit">
                            <i class="fas fa-edit"></i> Sửa
                          </a>
                        </c:if>
                        <c:if test="${r.status=='REJECTED'}">
                          <span style="font-size:.75rem;color:var(--danger);padding:4px 8px;background:#fef2f2;border-radius:6px;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="${r.rejectReason}">
                            <i class="fas fa-info-circle"></i> <c:out value="${r.rejectReason}"/>
                          </span>
                        </c:if>
                        <c:if test="${r.status=='PENDING' || r.status=='APPROVED'}">
                          <span style="font-size:.78rem;color:var(--muted);padding:4px 8px;">
                            <i class="fas fa-lock"></i> Đã gửi
                          </span>
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

      <!-- PAGINATION -->
      <div class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-top: 1px solid var(--border);">
          <div class="pagination-info" style="font-size: 0.85rem; color: var(--muted);">
              Hiển thị <span id="pageStart" style="font-weight: 600; color: var(--navy);">0</span> - <span id="pageEnd" style="font-weight: 600; color: var(--navy);">0</span> trong tổng số <span id="totalItems" style="font-weight: 600; color: var(--navy);">0</span> yêu cầu
          </div>
          <div class="pagination-controls" style="display: flex; gap: 8px;">
              <button class="btn-page" id="btnPrevPage" onclick="prevPage()"><i class="fas fa-chevron-left"></i></button>
              <div id="pageNumbers" style="display: flex; gap: 4px;"></div>
              <button class="btn-page" id="btnNextPage" onclick="nextPage()"><i class="fas fa-chevron-right"></i></button>
          </div>
      </div>
    </div>
  </div>
</div>

<style>
/* PAGINATION STYLES */
.btn-page { background: #fff; border: 1px solid var(--border); border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-size: 0.85rem; color: var(--muted); cursor: pointer; transition: all 0.2s; font-family: 'Inter', sans-serif; }
.btn-page:hover:not(:disabled) { border-color: var(--blue); color: var(--blue); }
.btn-page.active { background: var(--blue); border-color: var(--blue); color: white; }
.btn-page:disabled { opacity: 0.5; cursor: not-allowed; }
</style>

<script>
// Pagination & Search Logic
let currentPage = 1;
const itemsPerPage = 6;
let allRows = [];
let filteredRows = [];

document.addEventListener('DOMContentLoaded', function() {
    initPagination();
});

function initPagination() {
    const rows = document.querySelectorAll('.table-custom tbody tr:not(.empty-state-row)');
    allRows = Array.from(rows);
    filteredRows = [...allRows];
    updatePagination();
}

function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    const selDept = document.getElementById('deptFilter').value;
    
    filteredRows = allRows.filter(row => {
        const textMatch = q === '' || row.textContent.toLowerCase().includes(q);
        const deptName = row.children[3].textContent.trim();
        const deptMatch = selDept === '' || deptName === selDept;
        return textMatch && deptMatch;
    });
    
    currentPage = 1;
    updatePagination();
}

function updatePagination() {
    // Hide all rows first
    allRows.forEach(row => row.style.display = 'none');
    
    if(filteredRows.length === 0) {
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

    // Show only rows for current page
    for (let i = startIndex; i < endIndex; i++) {
        filteredRows[i].style.display = '';
    }

    document.getElementById('pageStart').textContent = startIndex + 1;
    document.getElementById('pageEnd').textContent = endIndex;
    document.getElementById('totalItems').textContent = filteredRows.length;

    let pageHtml = '';
    for (let i = 1; i <= totalPages; i++) {
        if (i === currentPage) {
            pageHtml += '<button class="btn-page active">' + i + '</button>';
        } else {
            pageHtml += '<button class="btn-page" onclick="goToPage(' + i + ')">' + i + '</button>';
        }
    }
    document.getElementById('pageNumbers').innerHTML = pageHtml;
    document.getElementById('btnPrevPage').disabled = currentPage === 1;
    document.getElementById('btnNextPage').disabled = currentPage === totalPages;
}

function goToPage(page) { currentPage = page; updatePagination(); }
function prevPage() { if (currentPage > 1) { currentPage--; updatePagination(); } }
function nextPage() { const totalPages = Math.ceil(filteredRows.length / itemsPerPage); if (currentPage < totalPages) { currentPage++; updatePagination(); } }
</script>

<jsp:include page="../footer.jsp" />

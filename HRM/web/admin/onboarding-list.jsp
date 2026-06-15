<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản Lý Yêu Cầu Onboarding" scope="request" />
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

/* Stats */
.stat-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;}
.stat-card{background:var(--surface);border:1px solid var(--border);border-radius:16px;padding:18px 20px;display:flex;align-items:center;gap:14px;cursor:pointer;transition:all .2s;text-decoration:none;}
.stat-card:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,.08);}
.stat-card.active-filter{box-shadow:0 0 0 2px var(--navy);}
.stat-icon{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;}
.si-all{background:linear-gradient(135deg,#e0e7ff,#c7d2fe);color:#4338ca;}
.si-pending{background:linear-gradient(135deg,#dbeafe,#bfdbfe);color:var(--blue);}
.si-approved{background:linear-gradient(135deg,#dcfce7,#bbf7d0);color:var(--success);}
.si-rejected{background:linear-gradient(135deg,#fee2e2,#fecaca);color:var(--danger);}
.stat-num{font-family:'Be Vietnam Pro',sans-serif;font-size:1.6rem;font-weight:800;color:var(--navy);line-height:1;}
.stat-lbl{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);margin-top:3px;}

/* Panel */
.panel{background:var(--surface);border:1px solid var(--border);border-radius:18px;overflow:hidden;}
.filter-strip{display:flex;gap:8px;padding:16px 24px;border-bottom:1px solid var(--border);flex-wrap:wrap;align-items:center;}
.ftab{padding:7px 16px;border-radius:20px;font-size:.8rem;font-weight:700;border:1.5px solid var(--border);background:transparent;color:var(--muted);cursor:pointer;transition:all .2s;display:flex;align-items:center;gap:6px;text-decoration:none;}
.ftab.active,.ftab:hover{background:var(--navy);border-color:var(--navy);color:#fff;}
.ftab .cnt{background:rgba(255,255,255,.2);padding:1px 7px;border-radius:10px;font-size:.7rem;}
.ftab:not(.active) .cnt{background:#f1f5f9;color:var(--navy);}

/* Table */
.req-table{width:100%;border-collapse:collapse;}
.req-table thead th{font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--muted);padding:12px 16px;border-bottom:2px solid var(--border);text-align:left;background:#fafbfc;white-space:nowrap;}
.req-table tbody td{padding:14px 16px;font-size:.875rem;border-bottom:1px solid #f8fafc;vertical-align:middle;}
.req-table tbody tr:last-child td{border-bottom:none;}
.req-table tbody tr:hover td{background:#f8fafc;}
.emp-cell{display:flex;align-items:center;gap:10px;}
.emp-av{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.9rem;color:#fff;flex-shrink:0;}

/* Badges */
.sbadge{display:inline-flex;align-items:center;gap:5px;padding:4px 12px;border-radius:20px;font-size:.75rem;font-weight:700;}
.s-draft{background:#f1f5f9;color:#475569;}
.s-pending{background:#eff6ff;color:#1d4ed8;}
.s-approved{background:#f0fdf4;color:var(--success);}
.s-rejected{background:#fef2f2;color:var(--danger);}

/* Buttons */
.btn{display:inline-flex;align-items:center;gap:6px;padding:7px 16px;border-radius:8px;font-size:.8rem;font-weight:700;border:none;cursor:pointer;transition:all .15s;text-decoration:none;}
.btn-detail{background:#f1f5f9;color:var(--navy);}
.btn-detail:hover{background:var(--navy);color:#fff;}
.btn-approve-sm{background:#dcfce7;color:var(--success);}
.btn-approve-sm:hover{background:var(--success);color:#fff;transform:translateY(-1px);}
.btn-reject-sm{background:#fee2e2;color:var(--danger);}
.btn-reject-sm:hover{background:var(--danger);color:#fff;transform:translateY(-1px);}

/* Alert */
.alert{padding:12px 16px;border-radius:10px;font-size:.85rem;font-weight:600;margin-bottom:20px;display:flex;align-items:center;gap:10px;}
.alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#14532d;}
.alert-danger{background:#fef2f2;border:1px solid #fecaca;color:#991b1b;}

/* Empty */
.empty-state{padding:60px;text-align:center;}
.empty-icon{font-size:3rem;color:#cbd5e0;margin-bottom:16px;}
.empty-title{font-family:'Be Vietnam Pro',sans-serif;font-size:1.1rem;font-weight:700;color:var(--navy);margin-bottom:8px;}
.empty-sub{font-size:.88rem;color:var(--muted);}

@media(max-width:900px){.stat-grid{grid-template-columns:1fr 1fr;}.ob-main{padding:20px 16px;}.col-hide{display:none;}}
@media(max-width:600px){.stat-grid{grid-template-columns:1fr 1fr;}}
</style>

<div class="ob-wrapper">
  <jsp:include page="../shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="onboarding-admin" />
  </jsp:include>

  <div class="ob-main">

    <!-- TOP BAR -->
    <div class="page-topbar">
      <div>
        <div class="breadcrumb-txt">
          <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
          <span>/</span><span>Yêu cầu tuyển dụng</span>
        </div>
        <h1 class="page-title"><i class="fas fa-user-check" style="color:var(--teal);margin-right:8px;"></i>Duyệt Yêu Cầu Tuyển Dụng</h1>
      </div>
    </div>

    <!-- ALERT -->
    <c:if test="${not empty param.msg}">
      <c:choose>
        <c:when test="${param.msg == 'approved'}">
          <div class="alert alert-success" style="display:flex; flex-direction:column; align-items:flex-start; gap:4px;">
            <div><i class="fas fa-check-circle"></i> Đã duyệt và tạo tài khoản thành công cho <strong>${param.name}</strong>!</div>
            <c:choose>
              <c:when test="${param.emailStatus == 'success'}">
                <span style="font-size:0.8rem; color:#15803d; margin-top:4px;"><i class="fas fa-envelope-open-text"></i> Đã gửi email chứa mật khẩu thành công.</span>
              </c:when>
              <c:when test="${param.emailStatus == 'failed'}">
                <span style="font-size:0.8rem; color:#b91c1c; margin-top:4px;"><i class="fas fa-exclamation-circle"></i> Gửi email thất bại. Lỗi: ${param.emailError}</span>
              </c:when>
            </c:choose>
          </div>
        </c:when>
        <c:when test="${param.msg == 'rejected'}">
          <div class="alert alert-success" style="background:#fef3c7;border-color:#fde68a;color:#92400e;"><i class="fas fa-ban"></i> Đã từ chối yêu cầu.</div>
        </c:when>
      </c:choose>
    </c:if>
    <c:if test="${not empty param.error}">
      <div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i>
        <c:choose>
          <c:when test="${param.error=='approve_failed'}">Tạo tài khoản thất bại. Email có thể đã trùng.</c:when>
          <c:when test="${param.error=='not_pending'}">Yêu cầu này không ở trạng thái Chờ duyệt.</c:when>
          <c:otherwise>Có lỗi xảy ra: ${param.error}</c:otherwise>
        </c:choose>
      </div>
    </c:if>

    <!-- STATS -->
    <div class="stat-grid">
      <a href="${pageContext.request.contextPath}/admin/onboarding/list" class="stat-card ${empty statusFilter || statusFilter=='ALL' ? 'active-filter' : ''}">
        <div class="stat-icon si-all"><i class="fas fa-list-alt"></i></div>
        <div><div class="stat-num">${totalAll}</div><div class="stat-lbl">Tất cả</div></div>
      </a>
      <a href="${pageContext.request.contextPath}/admin/onboarding/list?status=PENDING" class="stat-card ${statusFilter=='PENDING' ? 'active-filter' : ''}">
        <div class="stat-icon si-pending"><i class="fas fa-hourglass-half"></i></div>
        <div><div class="stat-num">${totalPending}</div><div class="stat-lbl">Chờ duyệt</div></div>
      </a>
      <a href="${pageContext.request.contextPath}/admin/onboarding/list?status=APPROVED" class="stat-card ${statusFilter=='APPROVED' ? 'active-filter' : ''}">
        <div class="stat-icon si-approved"><i class="fas fa-user-check"></i></div>
        <div><div class="stat-num">${totalApproved}</div><div class="stat-lbl">Đã duyệt</div></div>
      </a>
      <a href="${pageContext.request.contextPath}/admin/onboarding/list?status=REJECTED" class="stat-card ${statusFilter=='REJECTED' ? 'active-filter' : ''}">
        <div class="stat-icon si-rejected"><i class="fas fa-user-times"></i></div>
        <div><div class="stat-num">${totalRejected}</div><div class="stat-lbl">Từ chối</div></div>
      </a>
    </div>

    <!-- TABLE -->
    <div class="panel">
      <div class="panel-header" style="display:flex;align-items:center;justify-content:space-between;padding:16px 24px;border-bottom:1px solid var(--border);">
        <h3 class="panel-title" style="margin:0;font-family:'Be Vietnam Pro',sans-serif;font-size:1rem;font-weight:800;color:var(--navy);">Danh sách ứng viên</h3>
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
              <th>#</th><th>Ứng viên</th>
              <th class="col-hide">Email</th>
              <th class="col-hide">Phòng ban</th>
              <th class="col-hide">HR gửi</th>
              <th>Trạng thái</th>
              <th class="col-hide">Ngày gửi</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty requests}">
                <tr class="empty-state-row"><td colspan="8">
                  <div class="empty-state">
                    <div class="empty-icon"><i class="fas fa-inbox"></i></div>
                    <div class="empty-title">Không có yêu cầu nào</div>
                    <div class="empty-sub">
                      <c:choose>
                        <c:when test="${statusFilter=='PENDING'}">Hiện tại không có yêu cầu nào đang chờ duyệt.</c:when>
                        <c:otherwise>Chưa có yêu cầu onboarding nào được gửi lên.</c:otherwise>
                      </c:choose>
                    </div>
                  </div>
                </td></tr>
              </c:when>
              <c:otherwise>
                <c:set var="gradients" value="linear-gradient(135deg,#667eea,#764ba2)|linear-gradient(135deg,#f093fb,#f5576c)|linear-gradient(135deg,#4facfe,#00f2fe)|linear-gradient(135deg,#43e97b,#38f9d7)|linear-gradient(135deg,#fa709a,#fee140)|linear-gradient(135deg,#a18cd1,#fbc2eb)"/>
                <c:forEach var="r" items="${requests}" varStatus="loop">
                  <c:set var="grad" value="${loop.index % 2 == 0 ? 'linear-gradient(135deg,#667eea,#764ba2)' : 'linear-gradient(135deg,#4facfe,#00f2fe)'}"/>
                  <tr>
                    <td style="color:var(--muted);font-weight:700;font-size:.8rem;">${String.format('%02d', loop.index+1)}</td>
                    <td>
                      <div class="emp-cell">
                        <div class="emp-av" style="background:${grad};"><c:out value="${r.initial}"/></div>
                        <div>
                          <div style="font-weight:700;color:var(--navy);"><c:out value="${r.fullName}"/></div>
                          <div style="font-size:.74rem;color:var(--muted);"><c:out value="${r.phone}"/></div>
                        </div>
                      </div>
                    </td>
                    <td class="col-hide" style="font-size:.83rem;color:var(--muted);"><c:out value="${r.email}"/></td>
                    <td class="col-hide" style="font-size:.83rem;"><c:out value="${not empty r.departmentName ? r.departmentName : '—'}"/></td>
                    <td class="col-hide" style="font-size:.83rem;color:var(--muted);"><c:out value="${not empty r.createdByName ? r.createdByName : '—'}"/></td>
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
                      <div style="display:flex;gap:6px;flex-wrap:wrap;">
                        <a href="${pageContext.request.contextPath}/admin/onboarding/detail?id=${r.id}" class="btn btn-detail">
                          <i class="fas fa-eye"></i> Chi tiết
                        </a>
                        <c:if test="${r.status=='PENDING'}">
                          <button class="btn btn-approve-sm" onclick="quickApprove(${r.id}, '${r.fullName}')">
                            <i class="fas fa-user-plus"></i> Duyệt
                          </button>
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

<!-- Quick Approve Modal -->
<div id="approveModal" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.5);backdrop-filter:blur(4px);align-items:center;justify-content:center;">
  <div style="background:#fff;border-radius:20px;padding:32px;max-width:440px;width:90%;box-shadow:0 20px 60px rgba(0,0,0,.3);">
    <div style="text-align:center;margin-bottom:20px;">
      <div style="width:64px;height:64px;background:linear-gradient(135deg,#dcfce7,#bbf7d0);border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 12px;font-size:1.8rem;color:var(--success);">
        <i class="fas fa-user-plus"></i>
      </div>
      <h3 style="font-family:'Be Vietnam Pro',sans-serif;font-size:1.2rem;font-weight:800;color:var(--navy);margin:0 0 6px;">Xác nhận tạo tài khoản</h3>
      <p style="color:var(--muted);font-size:.88rem;margin:0;">Tạo tài khoản cho <strong id="approveName"></strong>?<br>Thông tin đăng nhập sẽ được gửi qua email.</p>
    </div>
    <form id="approveForm" method="post">
      <input type="hidden" name="requestId" id="approveReqId">
      <div style="display:flex;gap:10px;">
        <button type="submit" style="flex:1;padding:12px;border-radius:12px;background:linear-gradient(135deg,var(--success),#15803d);color:#fff;font-weight:700;border:none;cursor:pointer;font-size:.9rem;">
          <i class="fas fa-check"></i> Xác nhận tạo tài khoản
        </button>
        <button type="button" onclick="closeModal('approveModal')" style="padding:12px 20px;border-radius:12px;background:#f1f5f9;color:var(--navy);font-weight:700;border:none;cursor:pointer;">
          Hủy
        </button>
      </div>
    </form>
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
function quickApprove(id, name) {
  document.getElementById('approveReqId').value = id;
  document.getElementById('approveName').textContent = name;
  document.getElementById('approveForm').action = '${pageContext.request.contextPath}/admin/onboarding/approve';
  const m = document.getElementById('approveModal');
  m.style.display = 'flex';
}
function closeModal(id) { document.getElementById(id).style.display = 'none'; }
document.getElementById('approveModal').addEventListener('click', function(e) {
  if (e.target === this) closeModal('approveModal');
});

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

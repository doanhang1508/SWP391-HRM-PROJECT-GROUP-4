<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="pageTitle" value="Hop dong nhan vien" scope="request" />
<jsp:include page="../header.jsp" />

<style>
body { background-color: #f8f9fa; font-family: 'Be Vietnam Pro', sans-serif; }
.dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
.main-content { flex: 1; padding: 24px; width: calc(100% - 260px); }
.page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
.header-title { font-size: 1.25rem; font-weight: 700; color: #1a1a1a; margin: 0 0 4px 0; }
.header-breadcrumb { font-size: 0.85rem; color: #6b7280; }
.header-actions { display: flex; gap: 10px; align-items: center; }
.emp-profile-card { background: #fff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 20px 24px; margin-bottom: 20px; display: flex; align-items: center; gap: 20px; }
.emp-avatar-lg { width: 64px; height: 64px; border-radius: 12px; background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 1.5rem; flex-shrink: 0; }
.emp-info-main { flex: 1; }
.emp-name-lg { font-size: 1.1rem; font-weight: 700; color: #1a1a1a; margin-bottom: 4px; }
.emp-meta { display: flex; gap: 16px; flex-wrap: wrap; }
.emp-meta-item { font-size: 0.82rem; color: #6b7280; display: flex; align-items: center; gap: 5px; }
.badge-status { padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 600; white-space: nowrap; display: inline-flex; align-items: center; gap: 4px; }
.b-active { background: #ecfdf5; color: #059669; }
.b-pending { background: #eff6ff; color: #2563eb; }
.b-expired { background: #fef2f2; color: #dc2626; }
.b-terminated { background: #f3f4f6; color: #6b7280; }
.card-panel { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; margin-bottom: 20px; }
.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; padding-bottom: 16px; border-bottom: 1px solid #f3f4f6; }
.panel-title { font-size: 1rem; font-weight: 600; color: #1a1a1a; display: flex; align-items: center; gap: 8px; }
.panel-title i { color: #3b82f6; }
.contract-detail-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
.detail-item { padding: 12px 16px; background: #f8fafc; border-radius: 8px; border: 1px solid #e5e7eb; }
.detail-label { font-size: 0.72rem; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; font-weight: 600; }
.detail-value { font-size: 0.95rem; font-weight: 700; color: #1a1a1a; }
.detail-value.salary { color: #059669; }
.saas-table { width: 100%; border-collapse: collapse; }
.saas-table th { padding: 12px 16px; text-align: left; font-size: 0.82rem; font-weight: 600; color: #6b7280; border-bottom: 2px solid #f3f4f6; white-space: nowrap; }
.saas-table td { padding: 13px 16px; font-size: 0.875rem; color: #1a1a1a; border-bottom: 1px solid #f3f4f6; vertical-align: middle; }
.saas-table tr:hover td { background: #f9fafb; }
.table-wrapper { overflow-x: auto; }
.btn-primary { background: #0d9488; color: #fff; border: none; padding: 9px 18px; border-radius: 7px; font-size: 0.875rem; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 7px; text-decoration: none; }
.btn-primary:hover { background: #0f766e; color: #fff; }
.btn-outline { background: #fff; border: 1px solid #e5e7eb; color: #374151; padding: 9px 18px; border-radius: 7px; font-size: 0.875rem; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 7px; text-decoration: none; }
.btn-outline:hover { background: #f9fafb; border-color: #9ca3af; color: #374151; }
.btn-sm { padding: 6px 12px; font-size: 0.8rem; border-radius: 6px; }
.allowance-row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #f3f4f6; }
.allowance-row:last-child { border-bottom: none; }
.allowance-name { font-size: 0.875rem; color: #374151; display: flex; align-items: center; gap: 8px; }
.allowance-amount { font-size: 0.9rem; font-weight: 700; color: #059669; }
.alert-success { background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; border-radius: 8px; padding: 12px 18px; margin-bottom: 16px; font-size: 0.875rem; display: flex; align-items: center; gap: 10px; }
.alert-danger { background: #fef2f2; border: 1px solid #fca5a5; color: #991b1b; border-radius: 8px; padding: 12px 18px; margin-bottom: 16px; font-size: 0.875rem; display: flex; align-items: center; gap: 10px; }
.empty-state { text-align: center; padding: 40px 20px; color: #6b7280; }
.empty-state i { font-size: 2.5rem; margin-bottom: 12px; color: #d1d5db; display: block; }
.empty-state p { margin: 0; font-size: 0.9rem; }
.role-notice { background: #fffbeb; border: 1px solid #fde68a; color: #92400e; border-radius: 8px; padding: 12px 16px; font-size: 0.82rem; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
.salary-breakdown { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 16px; }
.sb-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 0.875rem; }
.sb-row:not(:last-child) { border-bottom: 1px dashed #d1fae5; }
.sb-row .sb-label { color: #374151; }
.sb-row .sb-value { font-weight: 600; color: #1a1a1a; }
.sb-row.total .sb-label { color: #065f46; font-weight: 700; }
.sb-row.total .sb-value { color: #059669; font-weight: 800; }
.modal-overlay { display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.55); z-index: 9999; align-items: center; justify-content: center; }
.modal-overlay.open { display: flex; }
.modal-box { background: #fff; border-radius: 12px; padding: 28px 32px; width: 640px; max-width: 95vw; max-height: 90vh; overflow-y: auto; box-shadow: 0 25px 60px rgba(0,0,0,0.2); }
.modal-title { font-size: 1.05rem; font-weight: 700; color: #1a1a1a; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid #f3f4f6; padding-bottom: 16px; }
.modal-title i { color: #0d9488; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group.full { grid-column: 1 / -1; }
.form-label { font-size: 0.82rem; font-weight: 600; color: #374151; }
.form-label .required { color: #dc2626; margin-left: 2px; }
.form-control { border: 1px solid #d1d5db; border-radius: 6px; padding: 9px 12px; font-size: 0.875rem; font-family: inherit; outline: none; }
.form-control:focus { border-color: #0d9488; }
.form-hint { font-size: 0.75rem; color: #9ca3af; }
.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; padding-top: 16px; border-top: 1px solid #f3f4f6; }
.allowance-check-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; max-height: 180px; overflow-y: auto; border: 1px solid #e5e7eb; border-radius: 6px; padding: 10px; background: #f8fafc; }
.allowance-check-item { display: flex; align-items: center; gap: 8px; padding: 6px 8px; border-radius: 6px; }
.allowance-check-item label { font-size: 0.82rem; color: #374151; cursor: pointer; flex: 1; }
.alw-amount { font-size: 0.75rem; color: #059669; font-weight: 600; }
</style>

<div class="dashboard-wrapper">
<jsp:include page="../shared/sidebar.jsp"><jsp:param name="activeMenu" value="employees" /></jsp:include>
<div class="main-content">

<c:if test="${not empty sessionScope.successMsg}">
<div class="alert-success"><i class="fas fa-check-circle"></i> <c:out value="${sessionScope.successMsg}"/></div>
<% session.removeAttribute("successMsg"); %>
</c:if>
<c:if test="${not empty sessionScope.errorMsg}">
<div class="alert-danger"><i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.errorMsg}"/></div>
<% session.removeAttribute("errorMsg"); %>
</c:if>

<div class="page-header">
  <div>
    <h1 class="header-title">Hop dong lao dong</h1>
    <div class="header-breadcrumb">
      <a href="${pageContext.request.contextPath}/hr/employees" style="color:#6b7280;text-decoration:none;">Nhan vien</a>
      &rsaquo; <c:out value="${employee.fullName}"/> &rsaquo; Hop dong
    </div>
  </div>
  <div class="header-actions">
    <a href="${pageContext.request.contextPath}/hr/employees" class="btn-outline"><i class="fas fa-arrow-left"></i> Quay lai</a>
    <c:if test="${sessionScope.currentUser.roleId == 5}">
      <button class="btn-primary" onclick="openModal('createContractModal')"><i class="fas fa-plus"></i> Tao hop dong</button>
    </c:if>
  </div>
</div>

<div class="emp-profile-card">
  <div class="emp-avatar-lg"><c:choose><c:when test="${not empty employee.fullName}">${fn:substring(employee.fullName,0,1)}</c:when><c:otherwise>?</c:otherwise></c:choose></div>
  <div class="emp-info-main">
    <div class="emp-name-lg"><c:out value="${employee.fullName}"/></div>
    <div class="emp-meta">
      <span class="emp-meta-item"><i class="fas fa-envelope"></i> <c:out value="${employee.email}"/></span>
      <c:if test="${not empty empDept}"><span class="emp-meta-item"><i class="fas fa-building"></i> <strong><c:out value="${empDept.departmentName}"/></strong></span></c:if>
      <c:if test="${not empty empPos}"><span class="emp-meta-item"><i class="fas fa-id-card-alt"></i> <strong><c:out value="${empPos.positionName}"/></strong></span></c:if>
    </div>
  </div>
  <div>
    <c:choose>
      <c:when test="${not empty currentContract && currentContract.status == 'Active'}"><span class="badge-status b-active">Dang hieu luc</span></c:when>
      <c:when test="${not empty currentContract && currentContract.status == 'Pending'}"><span class="badge-status b-pending">Cho duyet</span></c:when>
      <c:otherwise><span class="badge-status b-terminated">Chua co HD</span></c:otherwise>
    </c:choose>
  </div>
</div>

<c:if test="${sessionScope.currentUser.roleId == 2}">
<div class="role-notice"><i class="fas fa-info-circle"></i> HR Manager chi co quyen phe duyet. Viec tao moi do HR Staff thuc hien.</div>
</c:if>

<div class="card-panel">
  <div class="panel-header">
    <div class="panel-title"><i class="fas fa-file-contract"></i> Hop dong hien tai</div>
    <c:if test="${not empty currentContract && sessionScope.currentUser.roleId == 5}">
      <button class="btn-outline btn-sm" onclick="openModal('addendumModal')"><i class="fas fa-plus"></i> Tao phu luc</button>
    </c:if>
  </div>
  <c:choose>
    <c:when test="${empty currentContract}">
      <div class="empty-state">
        <i class="fas fa-file-circle-question"></i>
        <p>Nhan vien nay chua co hop dong dang hieu luc.</p>
        <c:if test="${sessionScope.currentUser.roleId == 5}">
          <button class="btn-primary" style="margin-top:12px;margin:12px auto 0;" onclick="openModal('createContractModal')"><i class="fas fa-plus"></i> Tao hop dong ngay</button>
        </c:if>
      </div>
    </c:when>
    <c:otherwise>
      <div class="contract-detail-grid">
        <div class="detail-item"><div class="detail-label">Loai hop dong</div><div class="detail-value"><c:forEach var="ct" items="${contractTypes}"><c:if test="${ct.contractTypeId == currentContract.contractTypeId}"><c:out value="${ct.typeName}"/></c:if></c:forEach></div></div>
        <div class="detail-item"><div class="detail-label">Ngay bat dau</div><div class="detail-value"><fmt:formatDate value="${currentContract.startDate}" pattern="dd/MM/yyyy"/></div></div>
        <div class="detail-item"><div class="detail-label">Ngay ket thuc</div><div class="detail-value"><c:choose><c:when test="${empty currentContract.endDate}">Khong thoi han</c:when><c:otherwise><fmt:formatDate value="${currentContract.endDate}" pattern="dd/MM/yyyy"/></c:otherwise></c:choose></div></div>
        <div class="detail-item"><div class="detail-label">Luong co ban</div><div class="detail-value salary"><fmt:formatNumber value="${currentContract.baseSalary}" type="number" groupingUsed="true"/> d</div></div>
        <div class="detail-item"><div class="detail-label">Tinh thue</div><div class="detail-value"><c:choose><c:when test="${currentContract.taxCalcType == 1}">Luy tien</c:when><c:when test="${currentContract.taxCalcType == 2}">Khau tru 10%</c:when><c:otherwise>Mien thue</c:otherwise></c:choose></div></div>
        <div class="detail-item"><div class="detail-label">Trang thai</div><div class="detail-value"><c:choose><c:when test="${currentContract.status == 'Active'}"><span class="badge-status b-active">Hieu luc</span></c:when><c:when test="${currentContract.status == 'Pending'}"><span class="badge-status b-pending">Cho duyet</span></c:when><c:otherwise><span class="badge-status b-terminated"><c:out value="${currentContract.status}"/></span></c:otherwise></c:choose></div></div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:20px;">
        <div>
          <div style="font-size:0.85rem;font-weight:600;color:#374151;margin-bottom:10px;">Phu cap</div>
          <c:choose>
            <c:when test="${empty allowanceList}"><p style="font-size:0.82rem;color:#9ca3af;margin:0;">Khong co phu cap.</p></c:when>
            <c:otherwise>
              <c:forEach var="alw" items="${allowanceList}">
                <div class="allowance-row"><span class="allowance-name"><i class="fas fa-tag"></i> <c:out value="${alw.name}"/></span><span class="allowance-amount"><fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/> d</span></div>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </div>
        <div>
          <div style="font-size:0.85rem;font-weight:600;color:#374151;margin-bottom:10px;">Uoc tinh luong Gross</div>
          <div class="salary-breakdown">
            <div class="sb-row"><span class="sb-label">Luong co ban</span><span class="sb-value"><fmt:formatNumber value="${currentContract.baseSalary}" type="number" groupingUsed="true"/> d</span></div>
            <div class="sb-row"><span class="sb-label">Tong phu cap</span><span class="sb-value"><fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/> d</span></div>
            <div class="sb-row total"><span class="sb-label">Gross du kien</span><span class="sb-value"><fmt:formatNumber value="${currentContract.baseSalary.doubleValue() + totalAllowance}" type="number" groupingUsed="true"/> d</span></div>
          </div>
        </div>
      </div>
      <c:if test="${sessionScope.currentUser.roleId == 2 && currentContract.status == 'Pending'}">
        <div style="margin-top:16px;padding-top:16px;border-top:1px solid #f3f4f6;">
          <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST" style="display:inline;">
            <input type="hidden" name="action" value="approve">
            <input type="hidden" name="contractId" value="${currentContract.contractId}">
            <input type="hidden" name="userId" value="${employee.userId}">
            <button type="submit" class="btn-primary" onclick="return confirm('Xac nhan phe duyet?')"><i class="fas fa-check-circle"></i> Phe duyet hop dong</button>
          </form>
        </div>
      </c:if>
    </c:otherwise>
  </c:choose>
</div>

<div class="card-panel">
  <div class="panel-header">
    <div class="panel-title"><i class="fas fa-history"></i> Lich su hop dong</div>
    <span style="font-size:0.82rem;color:#9ca3af;">${fn:length(contracts)} ban ghi</span>
  </div>
  <c:choose>
    <c:when test="${empty contracts}">
      <div class="empty-state"><i class="fas fa-folder-open"></i><p>Chua co hop dong nao.</p></div>
    </c:when>
    <c:otherwise>
      <div class="table-wrapper">
        <table class="saas-table">
          <thead><tr><th>#</th><th>Loai</th><th>Bat dau</th><th>Ket thuc</th><th>Luong CB</th><th>Ghi chu</th><th>Trang thai</th></tr></thead>
          <tbody>
            <c:forEach var="c" items="${contracts}" varStatus="s">
            <tr>
              <td style="color:#9ca3af;font-size:0.8rem;">${s.index+1}</td>
              <td><c:forEach var="ct" items="${contractTypes}"><c:if test="${ct.contractTypeId == c.contractTypeId}"><c:out value="${ct.typeName}"/></c:if></c:forEach><c:if test="${not empty c.docType && c.docType == 'ADDENDUM'}"><span style="font-size:0.72rem;background:#eff6ff;color:#2563eb;padding:2px 8px;border-radius:8px;margin-left:6px;">Phu luc</span></c:if></td>
              <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
              <td><c:choose><c:when test="${empty c.endDate}">-</c:when><c:otherwise><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></c:otherwise></c:choose></td>
              <td style="font-weight:600;color:#059669;"><fmt:formatNumber value="${c.baseSalary}" type="number" groupingUsed="true"/> d</td>
              <td style="max-width:160px;font-size:0.8rem;"><c:choose><c:when test="${not empty c.addendumReason}"><c:out value="${fn:substring(c.addendumReason,0,40)}"/><c:if test="${fn:length(c.addendumReason)>40}">...</c:if></c:when><c:otherwise>-</c:otherwise></c:choose></td>
              <td><c:choose><c:when test="${c.status == 'Active'}"><span class="badge-status b-active">Hieu luc</span></c:when><c:when test="${c.status == 'Pending'}"><span class="badge-status b-pending">Cho duyet</span></c:when><c:when test="${c.status == 'Expired'}"><span class="badge-status b-expired">Het han</span></c:when><c:otherwise><span class="badge-status b-terminated"><c:out value="${c.status}"/></span></c:otherwise></c:choose></td>
            </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</div>

</div></div>

<div class="modal-overlay" id="createContractModal">
  <div class="modal-box">
    <div class="modal-title"><i class="fas fa-file-signature"></i> Tao hop dong moi</div>
    <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST">
      <input type="hidden" name="action" value="create">
      <input type="hidden" name="userId" value="${employee.userId}">
      <div class="form-grid">
        <div class="form-group"><label class="form-label">Loai hop dong <span class="required">*</span></label><select name="contractTypeId" class="form-control" required onchange="updateSalaryHint(this)"><option value="">-- Chon --</option><c:forEach var="ct" items="${contractTypes}"><option value="${ct.contractTypeId}"><c:out value="${ct.typeName}"/></option></c:forEach></select></div>
        <div class="form-group"><label class="form-label">Bac luong <span class="required">*</span></label><select name="salaryGradeId" class="form-control" required onchange="prefillSalary(this)"><option value="">-- Chon --</option><c:forEach var="sg" items="${salaryGrades}"><option value="${sg.gradeId}" data-base="${sg.baseSalary}"><c:out value="${sg.gradeName}"/> -- <fmt:formatNumber value="${sg.baseSalary}" type="number" groupingUsed="true"/>d</option></c:forEach></select></div>
        <div class="form-group"><label class="form-label">Phong ban <span class="required">*</span></label><select name="departmentId" class="form-control" required><c:forEach var="d" items="${departments}"><option value="${d.departmentId}" ${d.departmentId==employee.departmentId?'selected':''}><c:out value="${d.departmentName}"/></option></c:forEach></select></div>
        <div class="form-group"><label class="form-label">Chuc vu <span class="required">*</span></label><select name="positionId" class="form-control" required><c:forEach var="p" items="${positions}"><option value="${p.positionId}" ${p.positionId==employee.positionId?'selected':''}><c:out value="${p.positionName}"/></option></c:forEach></select></div>
        <div class="form-group"><label class="form-label">Ngay bat dau <span class="required">*</span></label><input type="date" name="startDate" class="form-control" required></div>
        <div class="form-group"><label class="form-label">Ngay ket thuc</label><input type="date" name="endDate" class="form-control"><span class="form-hint">De trong neu khong thoi han</span></div>
        <div class="form-group"><label class="form-label">Luong co ban (d) <span class="required">*</span></label><input type="text" name="baseSalary" id="baseSalaryInput" class="form-control" required placeholder="VD: 10000000"><span class="form-hint" id="salaryHint"></span></div>
        <div class="form-group"><label class="form-label">Tinh thue <span class="required">*</span></label><select name="taxCalcType" class="form-control" required><option value="1">Luy tien</option><option value="2">Khau tru 10%</option><option value="3">Mien thue</option></select></div>
        <c:if test="${not empty availableAllowances}">
          <div class="form-group full"><label class="form-label">Phu cap di kem</label><div class="allowance-check-grid"><c:forEach var="alw" items="${availableAllowances}"><div class="allowance-check-item"><input type="checkbox" name="allowanceIds" value="${alw.allowanceId}" id="alw_${alw.allowanceId}"><label for="alw_${alw.allowanceId}"><c:out value="${alw.name}"/></label><span class="alw-amount"><fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/>d</span></div></c:forEach></div></div>
        </c:if>
      </div>
      <div class="modal-actions"><button type="button" class="btn-outline" onclick="closeModal('createContractModal')">Huy</button><button type="submit" class="btn-primary"><i class="fas fa-save"></i> Tao hop dong</button></div>
    </form>
  </div>
</div>

<c:if test="${not empty currentContract}">
<div class="modal-overlay" id="addendumModal">
  <div class="modal-box">
    <div class="modal-title"><i class="fas fa-file-alt"></i> Tao phu luc hop dong</div>
    <form action="${pageContext.request.contextPath}/hr/employee-contracts" method="POST">
      <input type="hidden" name="action" value="createAddendum">
      <input type="hidden" name="userId" value="${employee.userId}">
      <input type="hidden" name="parentContractId" value="${currentContract.contractId}">
      <input type="hidden" name="contractTypeId" value="${currentContract.contractTypeId}">
      <input type="hidden" name="taxCalcType" value="${currentContract.taxCalcType}">
      <input type="hidden" name="positionId" value="${currentContract.positionId}">
      <input type="hidden" name="departmentId" value="${currentContract.departmentId}">
      <c:if test="${not empty currentContract.endDate}"><input type="hidden" name="endDate" value="${currentContract.endDate}"></c:if>
      <div class="form-grid">
        <div class="form-group"><label class="form-label">Ngay hieu luc phu luc <span class="required">*</span></label><input type="date" name="startDate" class="form-control" required></div>
        <div class="form-group"><label class="form-label">Luong co ban moi (d) <span class="required">*</span></label><input type="text" name="baseSalary" class="form-control" required value="<fmt:formatNumber value='${currentContract.baseSalary}' type='number' groupingUsed='false'/>"></div>
        <div class="form-group full"><label class="form-label">Ly do / Noi dung phu luc <span class="required">*</span></label><textarea name="addendumReason" class="form-control" required rows="3" placeholder="Mo ta ly do dieu chinh..."></textarea></div>
        <c:if test="${not empty availableAllowances}">
          <div class="form-group full"><label class="form-label">Phu cap ap dung theo phu luc</label><div class="allowance-check-grid"><c:forEach var="alw" items="${availableAllowances}"><div class="allowance-check-item"><input type="checkbox" name="allowanceIds" value="${alw.allowanceId}" id="add_alw_${alw.allowanceId}"><label for="add_alw_${alw.allowanceId}"><c:out value="${alw.name}"/></label><span class="alw-amount"><fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/>d</span></div></c:forEach></div></div>
        </c:if>
      </div>
      <div class="modal-actions"><button type="button" class="btn-outline" onclick="closeModal('addendumModal')">Huy</button><button type="submit" class="btn-primary"><i class="fas fa-paper-plane"></i> Gui phu luc</button></div>
    </form>
  </div>
</div>
</c:if>

<script>
function openModal(id){var m=document.getElementById(id);if(m){m.classList.add('open');document.body.style.overflow='hidden';}}
function closeModal(id){var m=document.getElementById(id);if(m){m.classList.remove('open');document.body.style.overflow='';}}
document.querySelectorAll('.modal-overlay').forEach(function(m){m.addEventListener('click',function(e){if(e.target===m)closeModal(m.id);});});
document.addEventListener('keydown',function(e){if(e.key==='Escape')document.querySelectorAll('.modal-overlay.open').forEach(function(m){closeModal(m.id);});});
function prefillSalary(sel){var b=sel.options[sel.selectedIndex].getAttribute('data-base');if(b)document.getElementById('baseSalaryInput').value=b;}
function updateSalaryHint(sel){var h=document.getElementById('salaryHint');if(h){h.textContent=(sel.value=='1')?'Hop dong thu viec: luong thuc nhan = 85% luong nhap.':'';h.style.color='#d97706';}}

</script>

<jsp:include page="../footer.jsp" />

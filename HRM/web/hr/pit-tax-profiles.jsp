<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Hồ Sơ Thuế Nhân Viên - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    :root{ --pri:#6366f1; --bg:#f4f7fe; --card:#fff; --txt:#1e293b; }
    body{background:var(--bg);font-family:'Inter',sans-serif;}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px);}
    .main-content{flex:1;padding:30px;}
    .admin-panel{background:var(--card);border-radius:16px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);}
    .tbl{width:100%;border-collapse:separate;border-spacing:0 6px;}
    .tbl th{color:#64748b;font-weight:600;font-size:.85rem;padding:10px 14px;}
    .tbl td{background:#fff;padding:13px 14px;font-size:.9rem;border-bottom:1px solid #f1f5f9; vertical-align:middle;}
    .btn-action{background:var(--pri);color:#fff;border:none;border-radius:8px;padding:6px 12px;font-weight:600;font-size:.85rem;text-decoration:none;}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="pit" />
    </jsp:include>

    <div class="main-content">
        <h2 class="fw-bold mb-1" style="color:var(--txt);">Hồ Sơ Thuế Nhân Viên</h2>
        <p class="text-muted mb-4"><a href="pit" style="text-decoration:none;color:var(--pri);">Dashboard</a> &gt; Profiles</p>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <div class="admin-panel">
            <table class="tbl">
                <thead>
                    <tr>
                        <th>NV ID</th>
                        <th>Nhân viên</th>
                        <th>Phòng ban</th>
                        <th>Mã Số Thuế</th>
                        <th>Số NPT</th>
                        <th>Giảm trừ bản thân</th>
                        <th>Giảm trừ NPT</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${profiles}">
                        <tr>
                            <td class="fw-bold">#${p.userId}</td>
                            <td class="fw-bold text-primary">${p.fullName}</td>
                            <td>${p.departmentName}</td>
                            <td>${not empty p.taxCode ? p.taxCode : '<span class="text-muted fst-italic">Chưa cập nhật</span>'}</td>
                            <td class="fw-bold text-danger">${p.dependentCount}</td>
                            <td><fmt:formatNumber value="${p.personalDeduction}" type="number" maxFractionDigits="0"/> đ</td>
                            <td><fmt:formatNumber value="${p.dependentDeduction}" type="number" maxFractionDigits="0"/> đ/người</td>
                            <td>
                                <button class="btn-action" onclick="openEditModal(${p.taxProfileId}, '${p.taxCode}', ${p.dependentCount}, ${p.personalDeduction}, ${p.dependentDeduction}, '${p.fullName}')"><i class="fas fa-edit"></i> Sửa</button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Edit Profile Modal -->
<div class="modal fade" id="editProfileModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header bg-primary text-white" style="border-radius:12px 12px 0 0;">
                <h5 class="modal-title">Cập nhật Hồ Sơ Thuế - <span id="mFullName"></span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="pit" method="POST">
                <input type="hidden" name="action" value="updateTaxProfile">
                <input type="hidden" name="taxProfileId" id="mProfileId">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mã Số Thuế (MST)</label>
                        <input type="text" name="taxCode" id="mTaxCode" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Số người phụ thuộc (NPT)</label>
                        <input type="number" name="dependentCount" id="mDepCount" class="form-control" required min="0">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mức giảm trừ bản thân</label>
                        <input type="number" name="personalDeduction" id="mPerDed" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mức giảm trừ mỗi NPT</label>
                        <input type="number" name="dependentDeduction" id="mDepDed" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function openEditModal(id, code, dep, per, depDed, name) {
        document.getElementById('mProfileId').value = id;
        document.getElementById('mTaxCode').value = code !== 'null' ? code : '';
        document.getElementById('mDepCount').value = dep;
        document.getElementById('mPerDed').value = per;
        document.getElementById('mDepDed').value = depDed;
        document.getElementById('mFullName').innerText = name;
        new bootstrap.Modal(document.getElementById('editProfileModal')).show();
    }
</script>

<jsp:include page="../footer.jsp" />

</body>
</html>

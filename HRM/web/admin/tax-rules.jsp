<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Cấu hình Biểu Thuế - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    :root{
        --pri:#6366f1;
        --bg:#f4f7fe;
        --card:#fff;
        --txt:#1e293b;
    }
    body{background:var(--bg);font-family:'Inter',sans-serif;}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px);}
    .main-content{flex:1;padding:30px;}
    .admin-panel{background:var(--card);border-radius:16px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);margin-bottom:24px;}
    .tbl{width:100%;border-collapse:separate;border-spacing:0 6px;}
    .tbl th{color:#64748b;font-weight:600;font-size:.85rem;padding:10px 14px;border-bottom:2px solid #e2e8f0;}
    .tbl td{background:#fff;padding:13px 14px;font-size:.9rem;border-bottom:1px solid #f1f5f9;}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="admin-tax-rules" />
    </jsp:include>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold" style="color:var(--txt);">Cấu hình Biểu Thuế Lũy Tiến</h2>
                <p class="text-muted mb-0"><a href="${pageContext.request.contextPath}/admin/tax?action=rules" style="text-decoration:none;color:var(--pri);">Thuế TNCN</a> &gt; Biểu thuế</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/tax?action=auditLog" class="btn btn-secondary" style="border-radius:8px;"><i class="fas fa-history"></i> Lịch sử Audit</a>
        </div>

        <div class="row">
            <div class="col-md-8">
                <div class="admin-panel">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="fw-bold mb-0"><i class="fas fa-layer-group text-primary me-2"></i>Biểu Thuế Lũy Tiến</h5>
                        <button class="btn btn-sm btn-primary" onclick="openBracketModal()"><i class="fas fa-plus"></i> Thêm</button>
                    </div>
                    <div class="table-responsive">
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Bậc</th>
                                    <th>Từ (VNĐ)</th>
                                    <th>Đến (VNĐ)</th>
                                    <th>Thuế Suất (%)</th>
                                    <th>Ngày Áp Dụng</th>
                                    <th>Trạng Thái</th>
                                    <th>Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="b" items="${brackets}">
                                    <tr>
                                        <td class="fw-bold">Bậc ${b.bracketNo}</td>
                                        <td><fmt:formatNumber value="${b.incomeFrom}" type="number" maxFractionDigits="0"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty b.incomeTo}"><fmt:formatNumber value="${b.incomeTo}" type="number" maxFractionDigits="0"/></c:when>
                                                <c:otherwise>Trở lên</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="fw-bold text-danger">${b.rate}%</td>
                                        <td>${b.effectiveFrom}</td>
                                        <td>
                                            <c:if test="${b.status == 1}"><span class="badge bg-success bg-opacity-10 text-success">Active</span></c:if>
                                            <c:if test="${b.status == 0}"><span class="badge bg-secondary bg-opacity-10 text-secondary">Inactive</span></c:if>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-primary" onclick="editBracket(${b.bracketId}, ${b.bracketNo}, '${b.incomeFrom}', '${b.incomeTo}', '${b.rate}', '${b.effectiveFrom}', '${b.effectiveTo}', '${b.roundingRule}', ${b.status})"><i class="fas fa-edit"></i></button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="admin-panel">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="fw-bold mb-0"><i class="fas fa-minus-circle text-warning me-2"></i>Giảm Trừ</h5>
                        <button class="btn btn-sm btn-warning text-white" onclick="openDeductionModal()"><i class="fas fa-plus"></i> Thêm</button>
                    </div>
                    <div class="table-responsive">
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Loại</th>
                                    <th>Mức Giảm (VNĐ)</th>
                                    <th>Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="d" items="${deductions}">
                                    <tr>
                                        <td class="fw-bold">${d.deductionName}</td>
                                        <td class="fw-bold text-success"><fmt:formatNumber value="${d.amount}" type="number" maxFractionDigits="0"/></td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-warning" onclick="editDeduction(${d.deductionId}, '${d.deductionType}', '${d.deductionName}', '${d.amount}', '${d.effectiveFrom}', '${d.effectiveTo}', ${d.status})"><i class="fas fa-edit"></i></button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div class="alert alert-info mt-3" style="font-size:0.85rem;">
                        <i class="fas fa-info-circle me-1"></i> Các mức giảm trừ này được áp dụng tự động trong quá trình tính toán dựa trên ngày hiệu lực.
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bracket Modal -->
<div class="modal fade" id="bracketModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/tax" method="POST">
                <input type="hidden" name="action" value="saveBracket">
                <input type="hidden" name="bracketId" id="b_bracketId" value="0">
                <div class="modal-header">
                    <h5 class="modal-title" id="bracketModalTitle">Thêm Bậc Thuế</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label>Bậc số</label>
                        <input type="number" class="form-control" name="bracketNo" id="b_bracketNo" required>
                    </div>
                    <div class="mb-3">
                        <label>Từ (VNĐ)</label>
                        <input type="number" step="0.01" class="form-control" name="incomeFrom" id="b_incomeFrom" required>
                    </div>
                    <div class="mb-3">
                        <label>Đến (VNĐ) <small class="text-muted">(để trống nếu là mức cuối)</small></label>
                        <input type="number" step="0.01" class="form-control" name="incomeTo" id="b_incomeTo">
                    </div>
                    <div class="mb-3">
                        <label>Thuế suất (%)</label>
                        <input type="number" step="0.01" class="form-control" name="rate" id="b_rate" required>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label>Ngày áp dụng (Từ)</label>
                            <input type="date" class="form-control" name="effectiveFrom" id="b_effectiveFrom" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label>Ngày hết hạn (Đến)</label>
                            <input type="date" class="form-control" name="effectiveTo" id="b_effectiveTo">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label>Rounding Rule</label>
                        <select class="form-select" name="roundingRule" id="b_roundingRule">
                            <option value="HALF_UP">HALF_UP (Làm tròn nửa lên)</option>
                            <option value="UP">UP (Làm tròn lên)</option>
                            <option value="DOWN">DOWN (Làm tròn xuống)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>Trạng Thái</label>
                        <select class="form-select" name="status" id="b_status">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Deduction Modal -->
<div class="modal fade" id="deductionModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/tax" method="POST">
                <input type="hidden" name="action" value="saveDeduction">
                <input type="hidden" name="deductionId" id="d_deductionId" value="0">
                <div class="modal-header">
                    <h5 class="modal-title" id="deductionModalTitle">Thêm Giảm Trừ</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label>Loại Giảm Trừ</label>
                        <select class="form-select" name="deductionType" id="d_deductionType" required>
                            <option value="PERSONAL">Cá nhân (PERSONAL)</option>
                            <option value="DEPENDENT">Người phụ thuộc (DEPENDENT)</option>
                            <option value="OTHER">Khác (OTHER)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>Tên Giảm Trừ</label>
                        <input type="text" class="form-control" name="deductionName" id="d_deductionName" required>
                    </div>
                    <div class="mb-3">
                        <label>Mức Giảm (VNĐ)</label>
                        <input type="number" step="0.01" class="form-control" name="amount" id="d_amount" required>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label>Ngày áp dụng (Từ)</label>
                            <input type="date" class="form-control" name="effectiveFrom" id="d_effectiveFrom" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label>Ngày hết hạn (Đến)</label>
                            <input type="date" class="form-control" name="effectiveTo" id="d_effectiveTo">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label>Trạng Thái</label>
                        <select class="form-select" name="status" id="d_status">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-warning text-white">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    let bracketModal;
    let deductionModal;
    
    document.addEventListener("DOMContentLoaded", function() {
        bracketModal = new bootstrap.Modal(document.getElementById('bracketModal'));
        deductionModal = new bootstrap.Modal(document.getElementById('deductionModal'));
    });

    function openBracketModal() {
        document.getElementById('bracketModalTitle').innerText = "Thêm Bậc Thuế";
        document.getElementById('b_bracketId').value = "0";
        document.getElementById('b_bracketNo').value = "";
        document.getElementById('b_incomeFrom').value = "";
        document.getElementById('b_incomeTo').value = "";
        document.getElementById('b_rate').value = "";
        document.getElementById('b_effectiveFrom').value = "";
        document.getElementById('b_effectiveTo').value = "";
        document.getElementById('b_roundingRule').value = "HALF_UP";
        document.getElementById('b_status').value = "1";
        bracketModal.show();
    }

    function editBracket(id, no, from, to, rate, eFrom, eTo, round, status) {
        document.getElementById('bracketModalTitle').innerText = "Cập nhật Bậc Thuế";
        document.getElementById('b_bracketId').value = id;
        document.getElementById('b_bracketNo').value = no;
        document.getElementById('b_incomeFrom').value = from;
        document.getElementById('b_incomeTo').value = to !== 'null' && to !== '' ? to : '';
        document.getElementById('b_rate').value = rate;
        document.getElementById('b_effectiveFrom').value = eFrom;
        document.getElementById('b_effectiveTo').value = eTo !== 'null' && eTo !== '' ? eTo : '';
        document.getElementById('b_roundingRule').value = round !== 'null' && round !== '' ? round : 'HALF_UP';
        document.getElementById('b_status').value = status;
        bracketModal.show();
    }

    function openDeductionModal() {
        document.getElementById('deductionModalTitle').innerText = "Thêm Giảm Trừ";
        document.getElementById('d_deductionId').value = "0";
        document.getElementById('d_deductionType').value = "PERSONAL";
        document.getElementById('d_deductionName').value = "";
        document.getElementById('d_amount').value = "";
        document.getElementById('d_effectiveFrom').value = "";
        document.getElementById('d_effectiveTo').value = "";
        document.getElementById('d_status').value = "1";
        deductionModal.show();
    }

    function editDeduction(id, type, name, amount, eFrom, eTo, status) {
        document.getElementById('deductionModalTitle').innerText = "Cập nhật Giảm Trừ";
        document.getElementById('d_deductionId').value = id;
        document.getElementById('d_deductionType').value = type;
        document.getElementById('d_deductionName').value = name;
        document.getElementById('d_amount').value = amount;
        document.getElementById('d_effectiveFrom').value = eFrom;
        document.getElementById('d_effectiveTo').value = eTo !== 'null' && eTo !== '' ? eTo : '';
        document.getElementById('d_status').value = status;
        deductionModal.show();
    }
</script>

<jsp:include page="../footer.jsp" />

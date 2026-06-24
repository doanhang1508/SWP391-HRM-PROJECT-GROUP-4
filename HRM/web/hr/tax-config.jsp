<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Cấu Hình Thuế" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --navy: #0a2540; --blue: #2b6cb0; --bg: #f0ede8;
        --surface: #fff; --border: #e2e8f0; --text: #0f172a; --muted: #64748b;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }
    footer, #chatWidget { display: none !important; }

    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb  { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }

    /* PANEL */
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 24px 28px; margin-bottom: 24px; }
    .panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); }

    /* BUTTONS */
    .btn { padding: 9px 16px; border-radius: 8px; font-size: .85rem; font-weight: 600; cursor: pointer; transition: all .2s; font-family: 'Inter',sans-serif; display: inline-flex; align-items: center; gap: 6px; border: none; text-decoration: none; }
    .btn-primary { background: var(--blue); color: #fff; box-shadow: 0 4px 12px rgba(43,108,176,.2); }
    .btn-primary:hover { background: #235a91; transform: translateY(-1px); }
    .btn-icon { width: 32px; height: 32px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 6px; border: 1px solid var(--border); background: var(--surface); color: var(--text); font-size: .85rem; transition: .2s; }
    .btn-icon:hover { background: #f8fafc; border-color: #cbd5e1; color: var(--blue); }
    .btn-icon.delete:hover { color: #e11d48; border-color: #fca5a5; background: #fff1f2; }

    /* TABLE */
    .data-table { width: 100%; border-collapse: collapse; }
    .data-table thead th { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); padding: 11px 16px; border-bottom: 2px solid var(--border); text-align: left; white-space: nowrap; }
    .data-table tbody td { padding: 12px 16px; font-size: .875rem; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
    .data-table tbody tr:last-child td { border-bottom: none; }
    .data-table tbody tr:hover { background: #f8fafc; }

    /* ALERTS */
    .alert { padding: 12px 16px; border-radius: 8px; margin-bottom: 24px; font-size: .85rem; display: flex; align-items: center; gap: 8px; animation: slideIn .4s ease; }
    .alert-success { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; }
    .alert-error   { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }

    @keyframes slideIn { from{opacity:0; transform:translateY(-10px);} to{opacity:1; transform:translateY(0);} }

    /* MODAL */
    .modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15,23,42,.4); display: none; align-items: center; justify-content: center; z-index: 999; backdrop-filter: blur(4px); opacity: 0; transition: opacity .2s; }
    .modal-overlay.active { display: flex; opacity: 1; }
    .modal-box { background: var(--surface); width: 500px; border-radius: 16px; padding: 28px 32px; box-shadow: 0 20px 40px rgba(0,0,0,.1); transform: translateY(20px); transition: transform .3s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
    .modal-overlay.active .modal-box { transform: translateY(0); }
    .modal-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
    .modal-title { font-family: 'Be Vietnam Pro',sans-serif; font-size: 1.15rem; font-weight: 800; color: var(--navy); margin: 0; }
    .close-modal { background: none; border: none; font-size: 1.2rem; color: var(--muted); cursor: pointer; padding: 0; transition: .2s; }
    .close-modal:hover { color: var(--text); }
    .form-group { margin-bottom: 16px; }
    .form-group label { display: block; font-size: .8rem; font-weight: 600; color: var(--navy); margin-bottom: 6px; }
    .form-control { width: 100%; padding: 10px 14px; border: 1px solid var(--border); border-radius: 8px; font-size: .85rem; font-family: 'Inter',sans-serif; outline: none; transition: .2s; }
    .form-control:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(43,108,176,.1); }
    .form-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 28px; }
    .btn-secondary { background: var(--surface); border: 1px solid var(--border); color: var(--text); }
    .btn-secondary:hover { background: #f8fafc; }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="tax-config" />
    </jsp:include>

    <main class="page-main">
        <div class="page-topbar">
            <div class="page-topbar-left">
                <h1>Cấu Hình Thuế</h1>
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/hr/dashboard"><i class="fas fa-home"></i></a>
                    <i class="fas fa-chevron-right" style="font-size: .6rem"></i>
                    <span>Cấu hình Thuế</span>
                </div>
            </div>
        </div>

        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${sessionScope.successMsg}</div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMsg}</div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <div class="panel">
            <div class="panel-header">
                <h2 class="panel-title"><div class="dot"></div> Cấu Hình Giảm Trừ</h2>
                <button class="btn btn-primary" onclick="openDeductionModal()"><i class="fas fa-plus"></i> Thêm Giảm Trừ</button>
            </div>
            <div style="overflow-x:auto;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Loại giảm trừ</th>
                            <th>Tên giảm trừ</th>
                            <th>Mức giảm (VNĐ)</th>
                            <th>Hiệu lực từ</th>
                            <th>Hiệu lực đến</th>
                            <th style="text-align:right">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="d" items="${taxDeductionList}">
                            <tr>
                                <td>#${d.deductionId}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${d.deductionType eq 'personal'}"><span class="badge" style="background:#e0f2fe;color:#0369a1;padding:4px 8px;border-radius:4px;font-size:0.75rem;">Bản thân</span></c:when>
                                        <c:when test="${d.deductionType eq 'dependent'}"><span class="badge" style="background:#fef3c7;color:#b45309;padding:4px 8px;border-radius:4px;font-size:0.75rem;">Phụ thuộc</span></c:when>
                                        <c:otherwise><span class="badge" style="background:#f1f5f9;color:#475569;padding:4px 8px;border-radius:4px;font-size:0.75rem;">Khác</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${d.deductionName}</td>
                                <td style="font-weight:600;"><fmt:formatNumber value="${d.amount}" type="number" maxFractionDigits="0"/></td>
                                <td><fmt:formatDate value="${d.effectiveFrom}" pattern="dd/MM/yyyy"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty d.effectiveTo}">Vô thời hạn</c:when>
                                        <c:otherwise><fmt:formatDate value="${d.effectiveTo}" pattern="dd/MM/yyyy"/></c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align:right; white-space:nowrap;">
                                    <button class="btn-icon" title="Sửa" onclick="editDeduction(${d.deductionId}, '${d.deductionType}', '${d.deductionName}', ${d.amount}, '${d.effectiveFrom}', '${d.effectiveTo}')"><i class="fas fa-edit"></i></button>
                                    <form method="post" action="${pageContext.request.contextPath}/hr/tax-config" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa giảm trừ này?');">
                                        <input type="hidden" name="action" value="delete_deduction">
                                        <input type="hidden" name="deductionId" value="${d.deductionId}">
                                        <button class="btn-icon delete" title="Xóa"><i class="fas fa-trash"></i></button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <h2 class="panel-title"><div class="dot"></div> Biểu Thuế Lũy Tiến</h2>
                <button class="btn btn-primary" onclick="openBracketModal()"><i class="fas fa-plus"></i> Thêm Bậc Thuế</button>
            </div>
            <div style="overflow-x:auto;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Bậc</th>
                            <th>Thu nhập từ (VNĐ)</th>
                            <th>Thu nhập đến (VNĐ)</th>
                            <th>Thuế suất (%)</th>
                            <th>Hiệu lực từ</th>
                            <th>Hiệu lực đến</th>
                            <th style="text-align:right">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="b" items="${taxBracketList}">
                            <tr>
                                <td style="font-weight:600;color:var(--navy);">Bậc ${b.bracketNo}</td>
                                <td><fmt:formatNumber value="${b.incomeFrom}" type="number" maxFractionDigits="0"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty b.incomeTo}"><span style="color:var(--muted)">Trở lên</span></c:when>
                                        <c:otherwise><fmt:formatNumber value="${b.incomeTo}" type="number" maxFractionDigits="0"/></c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="font-weight:600;">${b.rate}%</td>
                                <td><fmt:formatDate value="${b.effectiveFrom}" pattern="dd/MM/yyyy"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty b.effectiveTo}">Vô thời hạn</c:when>
                                        <c:otherwise><fmt:formatDate value="${b.effectiveTo}" pattern="dd/MM/yyyy"/></c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align:right; white-space:nowrap;">
                                    <button class="btn-icon" title="Sửa" onclick="editBracket(${b.bracketId}, ${b.bracketNo}, ${b.incomeFrom}, ${b.incomeTo == null ? 'null' : b.incomeTo}, ${b.rate}, '${b.effectiveFrom}', '${b.effectiveTo}')"><i class="fas fa-edit"></i></button>
                                    <form method="post" action="${pageContext.request.contextPath}/hr/tax-config" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa bậc thuế này?');">
                                        <input type="hidden" name="action" value="delete_bracket">
                                        <input type="hidden" name="bracketId" value="${b.bracketId}">
                                        <button class="btn-icon delete" title="Xóa"><i class="fas fa-trash"></i></button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<!-- Modal Deduction -->
<div class="modal-overlay" id="deductionModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title" id="deductionModalTitle">Thêm Giảm Trừ</h3>
            <button class="close-modal" onclick="closeDeductionModal()"><i class="fas fa-times"></i></button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/tax-config">
            <input type="hidden" name="action" id="deductionAction" value="add_deduction">
            <input type="hidden" name="deductionId" id="modalDeductionId" value="">
            
            <div class="form-group">
                <label>Loại giảm trừ <span style="color:#e11d48">*</span></label>
                <select name="deductionType" id="modalDeductionType" class="form-control" required>
                    <option value="personal">Giảm trừ bản thân</option>
                    <option value="dependent">Giảm trừ người phụ thuộc</option>
                    <option value="other">Khác</option>
                </select>
            </div>
            <div class="form-group">
                <label>Tên giảm trừ <span style="color:#e11d48">*</span></label>
                <input type="text" name="deductionName" id="modalDeductionName" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Mức giảm (VNĐ) <span style="color:#e11d48">*</span></label>
                <input type="number" name="amount" id="modalAmount" class="form-control" required min="0" step="1000">
            </div>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">
                <div class="form-group">
                    <label>Ngày hiệu lực <span style="color:#e11d48">*</span></label>
                    <input type="date" name="effectiveFrom" id="modalDEffectiveFrom" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Ngày kết thúc (Tùy chọn)</label>
                    <input type="date" name="effectiveTo" id="modalDEffectiveTo" class="form-control">
                </div>
            </div>
            <div class="form-actions">
                <button type="button" class="btn btn-secondary" onclick="closeDeductionModal()">Hủy</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Lưu</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Bracket -->
<div class="modal-overlay" id="bracketModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title" id="bracketModalTitle">Thêm Bậc Thuế</h3>
            <button class="close-modal" onclick="closeBracketModal()"><i class="fas fa-times"></i></button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/tax-config">
            <input type="hidden" name="action" id="bracketAction" value="add_bracket">
            <input type="hidden" name="bracketId" id="modalBracketId" value="">
            
            <div class="form-group">
                <label>Bậc số <span style="color:#e11d48">*</span></label>
                <input type="number" name="bracketNo" id="modalBracketNo" class="form-control" required min="1">
            </div>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">
                <div class="form-group">
                    <label>Thu nhập từ (VNĐ) <span style="color:#e11d48">*</span></label>
                    <input type="number" name="incomeFrom" id="modalIncomeFrom" class="form-control" required min="0" step="1000">
                </div>
                <div class="form-group">
                    <label>Thu nhập đến (VNĐ)</label>
                    <input type="number" name="incomeTo" id="modalIncomeTo" class="form-control" step="1000" placeholder="Để trống nếu là bậc cao nhất">
                </div>
            </div>
            <div class="form-group">
                <label>Thuế suất (%) <span style="color:#e11d48">*</span></label>
                <input type="number" name="rate" id="modalRate" class="form-control" required min="0" max="100" step="0.01">
            </div>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">
                <div class="form-group">
                    <label>Ngày hiệu lực <span style="color:#e11d48">*</span></label>
                    <input type="date" name="effectiveFrom" id="modalBEffectiveFrom" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Ngày kết thúc (Tùy chọn)</label>
                    <input type="date" name="effectiveTo" id="modalBEffectiveTo" class="form-control">
                </div>
            </div>
            <div class="form-actions">
                <button type="button" class="btn btn-secondary" onclick="closeBracketModal()">Hủy</button>
                <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Lưu</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Deduction Script
    function openDeductionModal() {
        document.getElementById('deductionModalTitle').innerText = 'Thêm Giảm Trừ';
        document.getElementById('deductionAction').value = 'add_deduction';
        document.getElementById('modalDeductionId').value = '';
        document.getElementById('modalDeductionType').value = 'personal';
        document.getElementById('modalDeductionName').value = '';
        document.getElementById('modalAmount').value = '';
        document.getElementById('modalDEffectiveFrom').value = '';
        document.getElementById('modalDEffectiveTo').value = '';
        document.getElementById('deductionModal').classList.add('active');
    }
    function editDeduction(id, type, name, amount, eFrom, eTo) {
        document.getElementById('deductionModalTitle').innerText = 'Sửa Giảm Trừ';
        document.getElementById('deductionAction').value = 'edit_deduction';
        document.getElementById('modalDeductionId').value = id;
        document.getElementById('modalDeductionType').value = type;
        document.getElementById('modalDeductionName').value = name;
        document.getElementById('modalAmount').value = amount;
        document.getElementById('modalDEffectiveFrom').value = eFrom;
        document.getElementById('modalDEffectiveTo').value = eTo === 'null' ? '' : eTo;
        document.getElementById('deductionModal').classList.add('active');
    }
    function closeDeductionModal() {
        document.getElementById('deductionModal').classList.remove('active');
    }

    // Bracket Script
    function openBracketModal() {
        document.getElementById('bracketModalTitle').innerText = 'Thêm Bậc Thuế';
        document.getElementById('bracketAction').value = 'add_bracket';
        document.getElementById('modalBracketId').value = '';
        document.getElementById('modalBracketNo').value = '';
        document.getElementById('modalBracketNo').readOnly = false;
        document.getElementById('modalIncomeFrom').value = '';
        document.getElementById('modalIncomeTo').value = '';
        document.getElementById('modalRate').value = '';
        document.getElementById('modalBEffectiveFrom').value = '';
        document.getElementById('modalBEffectiveTo').value = '';
        document.getElementById('bracketModal').classList.add('active');
    }
    function editBracket(id, no, from, to, rate, eFrom, eTo) {
        document.getElementById('bracketModalTitle').innerText = 'Sửa Bậc Thuế';
        document.getElementById('bracketAction').value = 'edit_bracket';
        document.getElementById('modalBracketId').value = id;
        document.getElementById('modalBracketNo').value = no;
        document.getElementById('modalBracketNo').readOnly = true;
        document.getElementById('modalIncomeFrom').value = from;
        document.getElementById('modalIncomeTo').value = to === null ? '' : to;
        document.getElementById('modalRate').value = rate;
        document.getElementById('modalBEffectiveFrom').value = eFrom;
        document.getElementById('modalBEffectiveTo').value = eTo === 'null' ? '' : eTo;
        document.getElementById('bracketModal').classList.add('active');
    }
    function closeBracketModal() {
        document.getElementById('bracketModal').classList.remove('active');
    }

    // Close on overlay click
    window.onclick = function(event) {
        if (event.target == document.getElementById('deductionModal')) closeDeductionModal();
        if (event.target == document.getElementById('bracketModal')) closeBracketModal();
    }
</script>

<jsp:include page="../footer.jsp" />

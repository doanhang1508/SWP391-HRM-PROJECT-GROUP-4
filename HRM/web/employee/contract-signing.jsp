<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f8f9fa; font-family: 'Be Vietnam Pro', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 32px 40px; width: calc(100% - 260px); }
    
    .top-header {
        display: flex; justify-content: space-between; align-items: center;
        padding-bottom: 24px; border-bottom: 1px solid #e5e7eb; margin-bottom: 32px;
    }
    .header-left .ht-main { font-size: 1.25rem; font-weight: 700; color: #1a1a1a; margin-bottom: 2px; }
    .header-left .ht-sub { font-size: 0.85rem; color: #6b7280; }
    
    .contract-card {
        background: #fff; border: 1px solid #e5e7eb; border-radius: 12px;
        padding: 30px; margin-bottom: 24px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        position: relative; overflow: hidden;
    }
    .contract-card::before {
        content: ''; position: absolute; top: 0; left: 0; width: 6px; height: 100%;
        background: #0ea5e9;
    }
    .contract-card.addendum::before { background: #d97706; }
    
    .card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; border-bottom: 1px solid #f3f4f6; padding-bottom: 16px; }
    .c-title { font-size: 1.25rem; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 8px; }
    .c-meta { font-size: 0.85rem; color: #64748b; margin-top: 4px; }
    .badge {
        padding: 4px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 700;
        background: #fef3c7; color: #b45309; border: 1px solid #fde68a; display: inline-flex; align-items: center; gap: 6px;
    }
    
    .detail-grid { display: grid; grid-template-columns: 140px 1fr; row-gap: 12px; font-size: 0.95rem; margin-bottom: 24px; }
    .dl-label { color: #64748b; font-weight: 500; }
    .dl-value { color: #1e293b; font-weight: 600; }
    
    .card-actions { display: flex; gap: 12px; justify-content: flex-end; padding-top: 16px; border-top: 1px solid #f3f4f6; }
    .btn-sign { background: #059669; color: #fff; border: none; padding: 10px 24px; border-radius: 6px; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: 0.2s; }
    .btn-sign:hover { background: #047857; }
    .btn-reject { background: #fff; color: #dc2626; border: 1px solid #fca5a5; padding: 10px 24px; border-radius: 6px; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: 0.2s; }
    .btn-reject:hover { background: #fef2f2; }
    
    /* Empty State */
    .empty-state { text-align: center; padding: 60px 20px; background: #fff; border-radius: 12px; border: 1px dashed #d1d5db; color: #6b7280; }
    .empty-state i { font-size: 3rem; color: #e5e7eb; margin-bottom: 16px; }

    /* Modal overlay */
    .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.35); z-index: 999; align-items: center; justify-content: center; }
    .modal-overlay.open { display: flex; }
    .modal-box { background: #fff; border-radius: 10px; padding: 28px 32px; max-width: 440px; width: 90%; box-shadow: 0 20px 60px rgba(0,0,0,0.15); }
    .modal-title { font-size: 1rem; font-weight: 700; color: #1a1a1a; margin-bottom: 8px; }
    .modal-desc { font-size: 0.875rem; color: #6b7280; margin-bottom: 16px; }
    .modal-textarea { width: 100%; border: 1px solid #d1d5db; border-radius: 6px; padding: 10px 12px; font-size: 0.875rem; resize: vertical; min-height: 80px; font-family: inherit; outline: none; box-sizing: border-box; }
    .modal-textarea:focus { border-color: #3b82f6; }
    .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 16px; }
    .btn-outline { background: #fff; border: 1px solid #d1d5db; color: #374151; padding: 8px 16px; border-radius: 6px; font-size: 0.875rem; font-weight: 600; cursor: pointer; }

    /* Toast */
    .toast-msg { position: fixed; top: 20px; right: 20px; z-index: 1000; padding: 12px 20px; border-radius: 8px; font-size: 0.875rem; font-weight: 600; box-shadow: 0 4px 12px rgba(0,0,0,0.15); animation: fadeIn 0.3s ease; }
    .toast-success { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
    .toast-error   { background: #fef2f2; color: #991b1b; border: 1px solid #fca5a5; }
    .toast-info    { background: #eff6ff; color: #1e40af; border: 1px solid #bfdbfe; }
    @keyframes fadeIn { from { opacity:0; transform:translateY(-8px); } to { opacity:1; transform:translateY(0); } }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="contract-signing" />
    </jsp:include>

    <div class="main-content">
        <div class="top-header">
            <div class="header-left">
                <div class="ht-main">Xác nhận Hợp đồng</div>
                <div class="ht-sub">Vui lòng xem kỹ nội dung trước khi ký xác nhận</div>
            </div>
        </div>

        <c:if test="${not empty msg}">
            <div class="toast-msg ${msg == 'signed' ? 'toast-success' : (msg == 'rejected' ? 'toast-info' : 'toast-error')}" id="toastMsg">
                <c:choose>
                    <c:when test="${msg == 'signed'}"><i class="fas fa-check-circle"></i> Ký xác nhận thành công!</c:when>
                    <c:when test="${msg == 'rejected'}"><i class="fas fa-times-circle"></i> Đã từ chối. Lời nhắn đã gửi tới HR.</c:when>
                    <c:otherwise><i class="fas fa-exclamation-circle"></i> Có lỗi xảy ra, vui lòng thử lại.</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${not empty pendingContracts}">
                <c:forEach var="c" items="${pendingContracts}">
                    <div class="contract-card ${c.docType == 'ADDENDUM' ? 'addendum' : ''}">
                        <div class="card-header">
                            <div>
                                <div class="c-title">
                                    <c:choose>
                                        <c:when test="${c.docType == 'ADDENDUM'}">
                                            <i class="fas fa-file-signature" style="color: #d97706;"></i> Phụ lục Hợp đồng
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-file-contract" style="color: #0ea5e9;"></i> Hợp đồng ${c.contractTypeName}
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="c-meta">Mã HĐ: HĐ-<fmt:formatNumber value="${c.contractId}" pattern="0000"/> &bull; Tạo ngày: <fmt:formatDate value="${c.createdAt}" pattern="dd/MM/yyyy"/></div>
                            </div>
                            <span class="badge"><i class="fas fa-clock"></i> Chờ bạn ký</span>
                        </div>
                        
                        <div class="detail-grid">
                            <div class="dl-label">Hiệu lực từ ngày</div>
                            <div class="dl-value"><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></div>
                            
                            <div class="dl-label">Đến ngày</div>
                            <div class="dl-value"><c:choose><c:when test="${not empty c.endDate}"><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></c:when><c:otherwise>Vô thời hạn</c:otherwise></c:choose></div>
                            
                            <div class="dl-label">Phòng ban</div>
                            <div class="dl-value">${c.departmentName}</div>
                            
                            <div class="dl-label">Chức vụ</div>
                            <div class="dl-value">${c.positionName}</div>
                            
                            <div class="dl-label">Lương cơ bản</div>
                            <div class="dl-value" style="color: #2563eb; font-size: 1.1rem;"><fmt:formatNumber value="${c.baseSalary}" type="number" groupingUsed="true"/> VNĐ</div>
                            
                            <c:if test="${c.docType == 'ADDENDUM'}">
                                <div class="dl-label">Lý do điều chỉnh</div>
                                <div class="dl-value" style="color: #d97706; font-style: italic;">${c.addendumReason}</div>
                            </c:if>
                        </div>
                        
                        <div class="card-actions">
                            <button class="btn-reject" onclick="openRejectModal(${c.contractId})"><i class="fas fa-times"></i> Từ chối</button>
                            <button class="btn-sign" onclick="confirmSign(${c.contractId})"><i class="fas fa-check"></i> Đồng ý Ký</button>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fas fa-box-open"></i>
                    <h3>Không có yêu cầu xác nhận nào</h3>
                    <p>Bạn không có Hợp đồng hay Phụ lục nào đang chờ ký.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Modal: Từ chối -->
<div class="modal-overlay" id="rejectModal">
    <div class="modal-box">
        <div class="modal-title"><i class="fas fa-times-circle" style="color:#dc2626;"></i> Xác nhận Từ chối</div>
        <div class="modal-desc">Vui lòng cho biết lý do bạn không đồng ý với các điều khoản này.</div>
        <textarea class="modal-textarea" id="rejectReasonInput" placeholder="Nhập lý do từ chối..."></textarea>
        <form id="rejectForm" method="POST" action="${pageContext.request.contextPath}/employee/contract-signing">
            <input type="hidden" name="action" value="REJECTED">
            <input type="hidden" name="contractId" id="rejectContractId">
            <input type="hidden" name="rejectReason" id="rejectReasonHidden">
            <div class="modal-actions">
                <button type="button" class="btn-outline" onclick="closeRejectModal()">Hủy</button>
                <button type="submit" class="btn-reject" onclick="submitReject(event)">Gửi lý do</button>
            </div>
        </form>
    </div>
</div>

<!-- Form ẩn: Ký -->
<form id="signForm" method="POST" action="${pageContext.request.contextPath}/employee/contract-signing" style="display:none;">
    <input type="hidden" name="action" value="SIGNED">
    <input type="hidden" name="contractId" id="signContractId">
</form>

<script>
    function confirmSign(contractId) {
        if (confirm('Bằng việc bấm OK, bạn xác nhận đồng ý với mọi điều khoản và ký hợp đồng này.')) {
            document.getElementById('signContractId').value = contractId;
            document.getElementById('signForm').submit();
        }
    }
    function openRejectModal(contractId) {
        document.getElementById('rejectContractId').value = contractId;
        document.getElementById('rejectModal').classList.add('open');
    }
    function closeRejectModal() {
        document.getElementById('rejectModal').classList.remove('open');
    }
    function submitReject(e) {
        const reason = document.getElementById('rejectReasonInput').value.trim();
        if (!reason) { e.preventDefault(); alert('Vui lòng nhập lý do từ chối.'); return; }
        document.getElementById('rejectReasonHidden').value = reason;
    }
    const toast = document.getElementById('toastMsg');
    if (toast) setTimeout(() => toast.style.display = 'none', 5000);
</script>

<jsp:include page="../footer.jsp" />

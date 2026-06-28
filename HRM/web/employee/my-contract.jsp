<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<jsp:include page="../header.jsp" />

<style>
    /* Minimalist Enterprise SaaS Theme */
    body { background-color: #f8f9fa; font-family: 'Be Vietnam Pro', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 32px 40px; width: calc(100% - 260px); }
    
    .top-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-bottom: 24px;
        border-bottom: 1px solid #e5e7eb;
        margin-bottom: 32px;
    }
    .header-left .ht-main { font-size: 1.125rem; font-weight: 700; color: #1a1a1a; margin-bottom: 2px; }
    .header-left .ht-sub { font-size: 0.85rem; color: #6b7280; }
    .header-right { display: flex; gap: 12px; }
    
    .btn-outline {
        background: #fff;
        border: 1px solid #d1d5db;
        color: #374151;
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 0.875rem;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        transition: all 0.2s;
    }
    .btn-outline:hover { background: #f9fafb; border-color: #9ca3af; }
    
    .contract-detail-box {
        background: #fff;
        max-width: 800px;
        margin: 0 auto;
        padding: 40px;
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }
    
    .status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 10px;
        background: #ecfdf5;
        color: #059669;
        border: 1px solid #a7f3d0;
        border-radius: 14px;
        font-size: 0.75rem;
        font-weight: 600;
        margin-bottom: 16px;
    }
    
    .contract-title { font-size: 1.5rem; font-weight: 700; color: #1a1a1a; margin: 0 0 8px 0; }
    .contract-meta { font-size: 0.875rem; color: #6b7280; margin-bottom: 32px; border-bottom: 1px solid #f3f4f6; padding-bottom: 24px; }
    
    .detail-grid {
        display: grid;
        grid-template-columns: 200px 1fr;
        row-gap: 20px;
        font-size: 0.95rem;
    }
    .dl-label { color: #6b7280; font-weight: 500; }
    .dl-value { color: #1a1a1a; font-weight: 600; }
    
    /* Print optimizations */
    @media print {
        .dashboard-wrapper { display: block; }
        .sidebar, .top-header .header-right, .navbar-editorial { display: none !important; }
        .main-content { width: 100%; padding: 0; margin: 0; }
        .contract-detail-box { box-shadow: none; border: none; padding: 0; margin-top: 20px; }
        .addendum-banner, .toast-msg { display: none !important; }
    }

    /* Banner & Modal styles */
    .addendum-banner {
        display: flex; align-items: flex-start; gap: 16px;
        background: #fffbeb; border: 1px solid #fcd34d;
        border-radius: 8px; padding: 16px 20px;
        margin-bottom: 24px;
    }
    .banner-icon { font-size: 1.5rem; color: #d97706; flex-shrink: 0; padding-top: 2px; }
    .banner-body { flex: 1; }
    .banner-title { font-weight: 700; color: #92400e; margin-bottom: 4px; font-size: 0.95rem; }
    .banner-desc { font-size: 0.875rem; color: #78350f; margin-bottom: 12px; line-height: 1.5; }
    .banner-actions { display: flex; gap: 10px; }
    .btn-sign {
        background: #059669; color: #fff; border: none;
        padding: 8px 20px; border-radius: 6px;
        font-size: 0.875rem; font-weight: 600; cursor: pointer;
    }
    .btn-sign:hover { background: #047857; }
    .btn-reject {
        background: #fff; color: #dc2626; border: 1px solid #fca5a5;
        padding: 8px 20px; border-radius: 6px;
        font-size: 0.875rem; font-weight: 600; cursor: pointer;
    }
    .btn-reject:hover { background: #fef2f2; }

    /* Modal overlay */
    .modal-overlay {
        display: none; position: fixed; inset: 0;
        background: rgba(0,0,0,0.35); z-index: 999;
        align-items: center; justify-content: center;
    }
    .modal-overlay.open { display: flex; }
    .modal-box {
        background: #fff; border-radius: 10px;
        padding: 28px 32px; max-width: 440px; width: 90%;
        box-shadow: 0 20px 60px rgba(0,0,0,0.15);
    }
    .modal-title { font-size: 1rem; font-weight: 700; color: #1a1a1a; margin-bottom: 8px; }
    .modal-desc { font-size: 0.875rem; color: #6b7280; margin-bottom: 16px; }
    .modal-textarea {
        width: 100%; border: 1px solid #d1d5db;
        border-radius: 6px; padding: 10px 12px;
        font-size: 0.875rem; resize: vertical; min-height: 80px;
        font-family: inherit; outline: none; box-sizing: border-box;
    }
    .modal-textarea:focus { border-color: #3b82f6; }
    .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 16px; }

    /* Toast */
    .toast-msg {
        position: fixed; top: 20px; right: 20px; z-index: 1000;
        padding: 12px 20px; border-radius: 8px;
        font-size: 0.875rem; font-weight: 600;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        animation: fadeIn 0.3s ease;
    }
    .toast-success { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
    .toast-error   { background: #fef2f2; color: #991b1b; border: 1px solid #fca5a5; }
    .toast-info    { background: #eff6ff; color: #1e40af; border: 1px solid #bfdbfe; }
    @keyframes fadeIn { from { opacity:0; transform:translateY(-8px); } to { opacity:1; transform:translateY(0); } }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="my-contract" />
    </jsp:include>

    <div class="main-content">
        
        <div class="top-header">
            <div class="header-left">
                <div class="ht-main">Hợp đồng lao động</div>
                <div class="ht-sub">Công nhân viên / Hợp đồng</div>
            </div>
            <div class="header-right">
                <button type="button" class="btn-outline" onclick="window.print()">
                    <i class="fas fa-print"></i> In
                </button>
                <button type="button" class="btn-outline" onclick="window.print()">
                    <i class="fas fa-download"></i> Tải PDF
                </button>
            </div>
        </div>

        <c:if test="${not empty pendingAddendum}">
            <div class="addendum-banner">
                <div class="banner-icon"><i class="fas fa-file-signature"></i></div>
                <div class="banner-body">
                    <div class="banner-title">Bạn có 01 Phụ lục hợp đồng đang chờ xác nhận</div>
                    <div class="banner-desc">
                        Phụ lục số <strong>PL-<fmt:formatNumber value="${pendingAddendum.contractId}" pattern="0000"/></strong>
                        có hiệu lực từ ngày <strong><fmt:formatDate value="${pendingAddendum.startDate}" pattern="dd/MM/yyyy"/></strong>.<br/>
                        Lý do: <em>${pendingAddendum.addendumReason}</em><br/>
                        <span style="color: #d97706;">Mức lương mới: <strong><fmt:formatNumber value="${pendingAddendum.baseSalary}" type="number" groupingUsed="true"/> VNĐ</strong></span>
                    </div>
                    <div class="banner-actions">
                        <button class="btn-sign" onclick="confirmSign(${pendingAddendum.contractId})">&#10003; Xác nhận ký</button>
                        <button class="btn-reject" onclick="openRejectModal(${pendingAddendum.contractId})">&#10005; Từ chối</button>
                    </div>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty msg}">
            <div class="toast-msg ${msg == 'signed' ? 'toast-success' : (msg == 'rejected' ? 'toast-info' : 'toast-error')}" id="toastMsg">
                <c:choose>
                    <c:when test="${msg == 'signed'}"><i class="fas fa-check-circle"></i> Bạn đã xác nhận ký phụ lục thành công!</c:when>
                    <c:when test="${msg == 'rejected'}"><i class="fas fa-times-circle"></i> Bạn đã từ chối phụ lục. HR sẽ được thông báo.</c:when>
                    <c:otherwise><i class="fas fa-exclamation-circle"></i> Có lỗi xảy ra, vui lòng thử lại.</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${not empty activeContract}">
                <div class="contract-detail-box">
                    <span class="status-badge"><i class="fas fa-check-circle"></i> Đang hiệu lực</span>
                    
                    <h1 class="contract-title">Hợp đồng lao động ${activeContract.contractTypeName}</h1>
                    <div class="contract-meta">
                        Mã hợp đồng: HĐ-${activeContract.startDate.year + 1900}-<fmt:formatNumber value="${activeContract.contractId}" pattern="0000"/> &bull; 
                        Ký ngày <fmt:formatDate value="${activeContract.startDate}" pattern="dd/MM/yyyy"/>
                    </div>
                    
                    <div class="detail-grid">
                        <div class="dl-label">Vị trí</div>
                        <div class="dl-value">Nhân sự (Theo chức danh hiện tại)</div>
                        
                        <div class="dl-label">Phòng ban</div>
                        <div class="dl-value">Khối Văn phòng</div>
                        
                        <div class="dl-label">Ngày bắt đầu</div>
                        <div class="dl-value"><fmt:formatDate value="${activeContract.startDate}" pattern="dd/MM/yyyy"/></div>
                        
                        <div class="dl-label">Ngày kết thúc</div>
                        <div class="dl-value">
                            <c:choose>
                                <c:when test="${not empty activeContract.endDate}"><fmt:formatDate value="${activeContract.endDate}" pattern="dd/MM/yyyy"/></c:when>
                                <c:otherwise>Không giới hạn</c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="dl-label">Nơi làm việc</div>
                        <div class="dl-value">Trụ sở Công ty (Theo phân công)</div>
                        
                        <div class="dl-label">Thời gian làm việc</div>
                        <div class="dl-value">Ca hành chính, 08:00 - 17:00</div>
                        
                        <div class="dl-label">Người đại diện (Cty)</div>
                        <div class="dl-value">Trưởng phòng Nhân sự (Đại diện ủy quyền)</div>
                        
                        <div style="grid-column: span 2; border-top: 1px dashed #e5e7eb; margin: 8px 0;"></div>
                        
                        <div class="dl-label">Lương cơ bản</div>
                        <div class="dl-value" style="font-weight: 500;"><fmt:formatNumber value="${activeContract.baseSalary}" type="number" groupingUsed="true"/> VNĐ</div>
                        
                        <div class="dl-label">Tổng Phụ cấp</div>
                        <div>
                            <div class="dl-value" style="font-weight: 500;">+ <fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/> VNĐ</div>
                            <c:if test="${not empty allowanceList}">
                                <div style="margin-top: 8px; background: #f8fafc; padding: 8px 12px; border-radius: 6px; border: 1px solid #e2e8f0; font-size: 0.85rem;">
                                    <ul style="margin: 0; padding-left: 16px; color: #475569;">
                                        <c:forEach var="alw" items="${allowanceList}">
                                            <li>${alw.name}: <fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/> đ</li>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                        </div>
                        
                        <div class="dl-label" style="color: #2563eb; font-weight: 700;">Lương Gross (Dự kiến)</div>
                        <div class="dl-value" style="color: #2563eb; font-size: 1.15rem; font-weight: 700;"><fmt:formatNumber value="${grossSalary}" type="number" groupingUsed="true"/> VNĐ</div>
                        
                        <div style="grid-column: span 2; border-top: 1px dashed #e5e7eb; margin: 8px 0;"></div>
                        
                        <div class="dl-label">Tỷ lệ Bảo hiểm</div>
                        <div class="dl-value" style="font-weight: 500;">BHXH: ${activeContract.bhxhRate}% | BHYT: ${activeContract.bhytRate}% | BHTN: ${activeContract.bhtnRate}%</div>
                        
                        <div class="dl-label">Tính Thuế TNCN</div>
                        <div class="dl-value" style="font-weight: 500;">
                            <c:choose>
                                <c:when test="${activeContract.taxCalcType == 1}">Biểu thuế lũy tiến từng phần</c:when>
                                <c:when test="${activeContract.taxCalcType == 2}">Khấu trừ 10% tại nguồn</c:when>
                                <c:otherwise>Không khấu trừ thuế</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="contract-detail-box" style="text-align: center; color: #6b7280; padding: 60px;">
                    <i class="fas fa-folder-open" style="font-size: 3rem; color: #d1d5db; margin-bottom: 16px; display: block;"></i>
                    Hiện tại bạn chưa có hợp đồng lao động nào được ghi nhận trên hệ thống.
                </div>
            </c:otherwise>
        </c:choose>
        
        <div style="margin-top: 40px;">
            <h3 style="font-size: 1rem; font-weight: 700; color: #1a1a1a; margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                <i class="fas fa-history" style="color: #6b7280;"></i> Lịch sử hợp đồng
            </h3>
            <table style="width: 100%; border-collapse: collapse; background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; overflow: hidden;">
                <thead style="background: #f9fafb;">
                    <tr>
                        <th style="padding: 12px 16px; text-align: left; font-size: 0.8rem; font-weight: 600; color: #6b7280; border-bottom: 1px solid #e5e7eb;">Loại Hợp đồng</th>
                        <th style="padding: 12px 16px; text-align: left; font-size: 0.8rem; font-weight: 600; color: #6b7280; border-bottom: 1px solid #e5e7eb;">Thời hạn</th>
                        <th style="padding: 12px 16px; text-align: left; font-size: 0.8rem; font-weight: 600; color: #6b7280; border-bottom: 1px solid #e5e7eb;">Lương Gross</th>
                        <th style="padding: 12px 16px; text-align: left; font-size: 0.8rem; font-weight: 600; color: #6b7280; border-bottom: 1px solid #e5e7eb;">Trạng thái</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${contracts}">
                        <tr>
                            <td style="padding: 16px; font-size: 0.875rem; color: #1a1a1a; font-weight: 600; border-bottom: 1px solid #f3f4f6;">${c.contractTypeName}</td>
                            <td style="padding: 16px; font-size: 0.875rem; color: #4b5563; border-bottom: 1px solid #f3f4f6;">
                                <fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/> - 
                                <c:choose><c:when test="${not empty c.endDate}"><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></c:when><c:otherwise>Không giới hạn</c:otherwise></c:choose>
                            </td>
                            <td style="padding: 16px; font-size: 0.875rem; color: #1a1a1a; font-weight: 600; border-bottom: 1px solid #f3f4f6;">
                                <fmt:formatNumber value="${c.baseSalary + totalAllowance}" type="number" groupingUsed="true"/> đ
                            </td>
                            <td style="padding: 16px; font-size: 0.875rem; border-bottom: 1px solid #f3f4f6;">
                                <c:choose>
                                    <c:when test="${c.status == 'Active'}">
                                        <span style="background: #ecfdf5; color: #059669; padding: 2px 8px; border-radius: 10px; font-size: 0.7rem; font-weight: 600;">Hiệu lực</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="background: #fef2f2; color: #dc2626; padding: 2px 8px; border-radius: 10px; font-size: 0.7rem; font-weight: 600;">Hết hạn</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty contracts}">
                        <tr><td colspan="4" style="padding: 24px; text-align: center; color: #9ca3af; font-size: 0.875rem;">Trống</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal: Từ chối Phụ lục -->
<div class="modal-overlay" id="rejectModal">
    <div class="modal-box">
        <div class="modal-title"><i class="fas fa-times-circle" style="color:#dc2626;"></i> Xác nhận Từ chối Phụ lục</div>
        <div class="modal-desc">Vui lòng cho biết lý do bạn không đồng ý với điều khoản phụ lục này.</div>
        <textarea class="modal-textarea" id="rejectReasonInput" placeholder="Nhập lý do từ chối..."></textarea>
        <form id="rejectForm" method="POST" action="${pageContext.request.contextPath}/employee/my-contract">
            <input type="hidden" name="action" value="REJECTED">
            <input type="hidden" name="contractId" id="rejectContractId">
            <input type="hidden" name="rejectReason" id="rejectReasonHidden">
            <div class="modal-actions">
                <button type="button" class="btn-outline" onclick="closeRejectModal()">Hủy</button>
                <button type="submit" class="btn-reject" onclick="submitReject(event)">Xác nhận Từ chối</button>
            </div>
        </form>
    </div>
</div>

<!-- Form ẩn: Xác nhận ký -->
<form id="signForm" method="POST" action="${pageContext.request.contextPath}/employee/my-contract" style="display:none;">
    <input type="hidden" name="action" value="SIGNED">
    <input type="hidden" name="contractId" id="signContractId">
</form>

<script>
    function confirmSign(contractId) {
        if (confirm('Bạn xác nhận Đồng ý ký phụ lục hợp đồng này?')) {
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
    // Tự ẩn toast sau 5 giây
    const toast = document.getElementById('toastMsg');
    if (toast) setTimeout(() => toast.style.display = 'none', 5000);
</script>

<jsp:include page="../footer.jsp" />

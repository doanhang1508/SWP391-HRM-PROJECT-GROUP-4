<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

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
                        <!-- 1. Thông tin HĐ -->
                        <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 10px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                            1. Thông tin Hợp đồng
                        </div>
                        
                        <div class="dl-label">Mã hợp đồng</div>
                        <div class="dl-value">HĐ-${activeContract.startDate.year + 1900}-<fmt:formatNumber value="${activeContract.contractId}" pattern="0000"/></div>
                        
                        <div class="dl-label">Loại hợp đồng</div>
                        <div class="dl-value">${activeContract.contractTypeName}</div>
                        
                        <div class="dl-label">Ngày bắt đầu</div>
                        <div class="dl-value"><fmt:formatDate value="${activeContract.startDate}" pattern="dd/MM/yyyy"/></div>
                        
                        <div class="dl-label">Ngày kết thúc</div>
                        <div class="dl-value">
                            <c:choose>
                                <c:when test="${not empty activeContract.endDate}"><fmt:formatDate value="${activeContract.endDate}" pattern="dd/MM/yyyy"/></c:when>
                                <c:otherwise>Vô thời hạn</c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="dl-label">Trạng thái HĐ</div>
                        <div class="dl-value">
                            <c:choose>
                                <c:when test="${activeContract.status == 'Active'}"><span style="color: #16a34a; font-weight: 600;">Đang hiệu lực</span></c:when>
                                <c:otherwise><span style="color: #64748b; font-weight: 600;">${activeContract.status}</span></c:otherwise>
                            </c:choose>
                        </div>

                        <!-- 2. Thông tin công việc -->
                        <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                            2. Thông tin công việc
                        </div>
                        
                        <div class="dl-label">Phòng ban</div>
                        <div class="dl-value">${activeContract.departmentName}</div>

                        <div class="dl-label">Chức vụ</div>
                        <div class="dl-value">${activeContract.positionName}</div>

                        <!-- 3. Lương -->
                        <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                            3. Lương &amp; Phụ cấp
                        </div>
                        
                        <div class="dl-label">Lương cơ bản</div>
                        <div class="dl-value" style="font-weight: 500;"><fmt:formatNumber value="${activeContract.baseSalary}" type="number" groupingUsed="true"/> VNĐ</div>
                        
                        <div class="dl-label">Các khoản phụ cấp</div>
                        <div>
                            <c:choose>
                                <c:when test="${empty allowanceList}">
                                    <div class="dl-value" style="color: #64748b;">Không có phụ cấp</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="dl-value" style="font-weight: 500;">+ <fmt:formatNumber value="${totalAllowance}" type="number" groupingUsed="true"/> VNĐ</div>
                                    <div style="margin-top: 8px; background: #f8fafc; padding: 8px 12px; border-radius: 6px; border: 1px solid #e2e8f0; font-size: 0.85rem;">
                                        <ul style="margin: 0; padding-left: 16px; color: #475569;">
                                            <c:forEach var="alw" items="${allowanceList}">
                                                <li>${alw.name}: <fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/> đ</li>
                                            </c:forEach>
                                        </ul>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="dl-label" style="color: #2563eb; font-weight: 700;">Lương Gross (Dự kiến)</div>
                        <div class="dl-value" style="color: #2563eb; font-size: 1.15rem; font-weight: 700;"><fmt:formatNumber value="${grossSalary}" type="number" groupingUsed="true"/> VNĐ</div>
                        
                        <!-- 4. Trạng thái ký -->
                        <div class="section-heading" style="grid-column: span 2; color: #1e293b; font-size: 1.1rem; font-weight: 600; margin-top: 15px; margin-bottom: 5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 5px;">
                            4. Trạng thái ký kết
                        </div>
                        
                        <div class="dl-label">Người đại diện (Cty)</div>
                        <div class="dl-value">Giám đốc nhân sự</div>
                        
                        <div class="dl-label">Ngày ký</div>
                        <div class="dl-value"><fmt:formatDate value="${activeContract.startDate}" pattern="dd/MM/yyyy"/></div>
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
                        <th style="padding: 12px 16px; text-align: left; font-size: 0.8rem; font-weight: 600; color: #6b7280; border-bottom: 1px solid #e5e7eb;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${contracts}">
                        <tr data-contract-id="${c.contractId}"
                            data-type="${c.contractTypeName}"
                            data-dept="${c.departmentName}"
                            data-pos="${c.positionName}"
                            data-start="<fmt:formatDate value='${c.startDate}' pattern='dd/MM/yyyy'/>"
                            data-end="<c:choose><c:when test='${not empty c.endDate}'><fmt:formatDate value='${c.endDate}' pattern='dd/MM/yyyy'/></c:when><c:otherwise>Không giới hạn</c:otherwise></c:choose>"
                            data-base="<fmt:formatNumber value='${c.baseSalary}' type='number' groupingUsed='true'/>"
                            data-gross="<fmt:formatNumber value='${c.grossSalary}' type='number' groupingUsed='true'/>"
                            data-alw-html="${fn:escapeXml(c.allowanceHtml)}"
                            data-tax="${c.taxCalcType == 1 ? 'Theo biểu lũy tiến' : (c.taxCalcType == 2 ? 'Khấu trừ 10%' : 'Miễn thuế')}"
                            data-status="${c.status}">
                            <td style="padding: 16px; font-size: 0.875rem; color: #1a1a1a; font-weight: 600; border-bottom: 1px solid #f3f4f6;">
                                <c:choose>
                                    <c:when test="${c.docType == 'ADDENDUM'}">
                                        <span style="color: #d97706; font-weight: 700;"><i class="fas fa-file-signature me-1"></i> Phụ lục Hợp đồng</span>
                                        <div style="font-size: 0.8rem; font-weight: 500; color: #64748b; margin-top: 4px;">Lý do: ${c.addendumReason != null ? c.addendumReason : 'Không có'}</div>
                                    </c:when>
                                    <c:otherwise>
                                        ${c.contractTypeName}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="padding: 16px; font-size: 0.875rem; color: #4b5563; border-bottom: 1px solid #f3f4f6;">
                                <fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/> -
                                <c:choose><c:when test="${not empty c.endDate}"><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></c:when><c:otherwise>Không giới hạn</c:otherwise></c:choose>
                            </td>
                            <td style="padding: 16px; font-size: 0.875rem; color: #1a1a1a; font-weight: 600; border-bottom: 1px solid #f3f4f6;">
                                <fmt:formatNumber value="${c.grossSalary}" type="number" groupingUsed="true"/> đ
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
                            <td style="padding: 16px; border-bottom: 1px solid #f3f4f6;">
                                <button type="button"
                                    onclick="viewMyContractDetail(this.closest('tr'))"
                                    style="padding: 4px 10px; background: #eff6ff; color: #2563eb; border: 1px solid #bfdbfe; border-radius: 6px; font-size: 0.75rem; font-weight: 600; cursor: pointer; white-space: nowrap;">
                                    <i class="fas fa-eye me-1"></i> Xem chi tiết
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty contracts}">
                        <tr><td colspan="5" style="padding: 24px; text-align: center; color: #9ca3af; font-size: 0.875rem;">Trống</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>



<!-- Modal Xem Chi Tiết Hợp Đồng (Lịch sử) -->
<div id="myContractDetailModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.4); z-index:1000; align-items:center; justify-content:center;">
    <div style="background:#fff; width:560px; max-width:95vw; border-radius:10px; box-shadow:0 20px 60px rgba(0,0,0,0.15); display:flex; flex-direction:column; max-height:90vh;">
        <div style="padding:16px 24px; border-bottom:1px solid #e5e7eb; display:flex; justify-content:space-between; align-items:center; background:#f9fafb; border-radius:10px 10px 0 0;">
            <h3 style="margin:0; font-size:1rem; font-weight:700; color:#1a1a1a;">
                <i class="fas fa-file-contract me-2" style="color:#2563eb;"></i>
                Chi ti&#7871;t H&#7907;p &#273;&#7891;ng &nbsp;<span id="mcdCode" style="color:#2563eb;"></span>
            </h3>
            <button type="button" onclick="closeMyContractDetailModal()" style="background:transparent;border:none;font-size:1.4rem;color:#9ca3af;cursor:pointer;">&times;</button>
        </div>
        <div style="padding:20px 24px; overflow-y:auto; display:grid; grid-template-columns:170px 1fr; row-gap:12px; font-size:0.9rem;">
            <div style="grid-column:span 2; font-weight:700; color:#1e293b; border-bottom:1px solid #e5e7eb; padding-bottom:6px;">1. Th&#244;ng tin H&#7907;p &#273;&#7891;ng</div>
            <div style="color:#6b7280;">Lo&#7841;i h&#7907;p &#273;&#7891;ng</div>  <div id="mcdType"   style="font-weight:600;"></div>
            <div style="color:#6b7280;">Ng&#224;y b&#7855;t &#273;&#7847;u</div>   <div id="mcdStart"  style="font-weight:600;"></div>
            <div style="color:#6b7280;">Ng&#224;y k&#7871;t th&#250;c</div>       <div id="mcdEnd"    style="font-weight:600;"></div>
            <div style="color:#6b7280;">Tr&#7841;ng th&#225;i</div>             <div id="mcdStatus"></div>
            <div style="grid-column:span 2; font-weight:700; color:#1e293b; border-bottom:1px solid #e5e7eb; padding-bottom:6px; margin-top:6px;">2. Th&#244;ng tin C&#244;ng vi&#7879;c</div>
            <div style="color:#6b7280;">Ph&#242;ng ban</div>                    <div id="mcdDept"   style="font-weight:600;"></div>
            <div style="color:#6b7280;">Ch&#7913;c v&#7909;</div>               <div id="mcdPos"    style="font-weight:600;"></div>
            <div style="grid-column:span 2; font-weight:700; color:#1e293b; border-bottom:1px solid #e5e7eb; padding-bottom:6px; margin-top:6px;">3. Lương &amp; Phụ cấp</div>
            <div style="color:#6b7280;">Lương cơ bản</div> <div id="mcdBase"   style="font-weight:600;"></div>
            <div style="color:#6b7280;">Chi tiết Phụ cấp</div> <div id="mcdAlw" style="font-weight:500; color:#4b5563; font-size:0.9rem; white-space:pre-wrap;"></div>
            <div style="color:#2563eb; font-weight:700; margin-top:6px;">Lương Gross</div> <div id="mcdGross" style="font-weight:700; color:#2563eb; font-size:1.05rem; margin-top:6px;"></div>
            
            <div style="grid-column:span 2; font-weight:700; color:#1e293b; border-bottom:1px solid #e5e7eb; padding-bottom:6px; margin-top:6px;">4. Trạng thái ký kết</div>
            <div style="color:#6b7280;">Người đại diện (Cty)</div> <div>Giám đốc nhân sự</div>
            <div style="color:#6b7280;">Ngày ký</div> <div id="mcdSigned" style="font-weight:600;"></div>
        </div>
        <div style="padding:12px 24px; border-top:1px solid #e5e7eb; display:flex; justify-content:flex-end; background:#f9fafb; border-radius:0 0 10px 10px;">
            <button type="button" onclick="closeMyContractDetailModal()" class="btn-outline">&#272;&#243;ng</button>
        </div>
    </div>
</div>

<script>

    const toast = document.getElementById('toastMsg');
    if (toast) setTimeout(() => toast.style.display = 'none', 5000);

    function viewMyContractDetail(row) {
        var d = row.dataset;
        document.getElementById('mcdCode').textContent  = d.contractId ? ('HD-' + d.contractId) : '';
        document.getElementById('mcdType').textContent  = d.type  || '';
        document.getElementById('mcdStart').textContent = d.start || '';
        document.getElementById('mcdEnd').textContent   = d.end   || '';
        document.getElementById('mcdDept').textContent  = d.dept  || '';
        document.getElementById('mcdPos').textContent   = d.pos   || '';
        document.getElementById('mcdBase').textContent  = (d.base  || '0') + ' VND';
        document.getElementById('mcdGross').textContent = (d.gross || '0') + ' VND';
        document.getElementById('mcdSigned').textContent = d.start || '';
        
        var alwHtml = d.alwHtml || 'Không có phụ cấp';
        alwHtml = alwHtml.replace(/&#013;/g, '\n').replace(/&#10;/g, '\n');
        document.getElementById('mcdAlw').textContent = alwHtml;
        
        var s = document.getElementById('mcdStatus');
        if (d.status === 'Active') {
            s.innerHTML = '<span style="background:#ecfdf5;color:#059669;padding:3px 10px;border-radius:10px;font-size:0.78rem;font-weight:700;">Hiệu lực</span>';
        } else {
            s.innerHTML = '<span style="background:#fef2f2;color:#dc2626;padding:3px 10px;border-radius:10px;font-size:0.78rem;font-weight:700;">Hết hạn</span>';
        }
        document.getElementById('myContractDetailModal').style.display = 'flex';
    }
    function closeMyContractDetailModal() {
        document.getElementById('myContractDetailModal').style.display = 'none';
    }
    document.getElementById('myContractDetailModal').addEventListener('click', function(e) {
        if (e.target === this) closeMyContractDetailModal();
    });
</script>

<jsp:include page="../footer.jsp" />

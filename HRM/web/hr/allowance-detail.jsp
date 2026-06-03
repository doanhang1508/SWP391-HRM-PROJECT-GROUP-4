<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chi Tiết Phụ Cấp" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --navy:    #0a2540;
        --blue:    #2b6cb0;
        --bg:      #f0ede8;
        --surface: #ffffff;
        --border:  #e2e8f0;
        --text:    #0f172a;
        --muted:   #64748b;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }
    footer, #chatWidget { display: none !important; }

    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main    { flex: 1; padding: 32px 36px; }

    .back-btn { display: inline-flex; align-items: center; gap: 8px; color: var(--blue); font-size: .875rem; font-weight: 600; text-decoration: none; margin-bottom: 24px; transition: gap .2s; }
    .back-btn:hover { gap: 12px; }

    .detail-card { background: var(--surface); border: 1px solid var(--border); border-radius: 20px; overflow: hidden; max-width: 760px; box-shadow: 0 8px 30px rgba(10,37,64,.07); }

    /* HEADER */
    .detail-header { background: linear-gradient(135deg, #0a2540 0%, #2b6cb0 100%); padding: 32px 36px; display: flex; align-items: center; gap: 20px; }
    .detail-icon { width: 68px; height: 68px; background: rgba(255,255,255,.15); border-radius: 18px; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; color: #fff; flex-shrink: 0; }
    .detail-header-info h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.4rem; font-weight: 800; color: #fff; margin: 0 0 6px; }
    .detail-id-badge { display: inline-flex; align-items: center; gap: 6px; background: rgba(255,255,255,.18); color: rgba(255,255,255,.9); font-size: .75rem; font-weight: 600; padding: 3px 10px; border-radius: 20px; }

    /* BADGE */
    .badge-active   { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 14px; border-radius: 20px; }
    .badge-inactive { display: inline-flex; align-items: center; gap: 5px; background: #f1f5f9; color: var(--muted); font-size: .73rem; font-weight: 700; padding: 4px 14px; border-radius: 20px; }

    /* BODY */
    .detail-body { padding: 32px 36px; }

    /* AMOUNT HIGHLIGHT */
    .amount-highlight { background: linear-gradient(135deg, #f0fdf4, #dcfce7); border: 1px solid #bbf7d0; border-radius: 16px; padding: 20px 24px; margin-bottom: 28px; display: flex; align-items: center; gap: 16px; }
    .amount-icon { width: 52px; height: 52px; background: #16a34a; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; color: #fff; flex-shrink: 0; }
    .amount-label { font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #16a34a; margin-bottom: 4px; }
    .amount-value { font-family: 'Be Vietnam Pro', sans-serif; font-size: 2rem; font-weight: 800; color: #15803d; line-height: 1; }

    /* INFO GRID */
    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 24px; }
    .info-item { background: #f8fafc; border-radius: 12px; padding: 16px 18px; }
    .info-label { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); margin-bottom: 6px; display: flex; align-items: center; gap: 6px; }
    .info-value { font-size: .9rem; font-weight: 600; color: var(--navy); line-height: 1.5; }
    .info-value.empty { color: #cbd5e1; font-style: italic; font-weight: 400; }

    .info-item.full-width { grid-column: 1 / -1; }

    /* ACTIONS */
    .detail-actions { display: flex; align-items: center; gap: 10px; padding-top: 20px; border-top: 1px solid var(--border); flex-wrap: wrap; }
    .btn-edit-detail { background: var(--blue); color: #fff; border: none; padding: 10px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; display: inline-flex; align-items: center; gap: 8px; transition: background .2s; text-decoration: none; }
    .btn-edit-detail:hover { background: #1a4971; }
    .btn-deact-detail { background: none; border: 1px solid #fecaca; color: #e11d48; padding: 10px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; display: inline-flex; align-items: center; gap: 8px; transition: background .2s; text-decoration: none; }
    .btn-deact-detail:hover { background: #fff1f2; }
    .btn-act-detail { background: none; border: 1px solid #bbf7d0; color: #16a34a; padding: 10px 22px; border-radius: 8px; font-weight: 600; font-size: .875rem; cursor: pointer; font-family: 'Inter', sans-serif; display: inline-flex; align-items: center; gap: 8px; text-decoration: none; }
    .btn-act-detail:hover { background: #f0fdf4; }

    @media (max-width:600px) {
        .page-main { padding: 20px 16px; }
        .info-grid { grid-template-columns: 1fr; }
        .detail-header { padding: 22px 20px; }
        .detail-body { padding: 20px; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp" />

    <main class="page-main">
        <a href="${pageContext.request.contextPath}/hr/allowance" class="back-btn">
            <i class="fas fa-arrow-left"></i> Quay lại danh sách
        </a>

        <div class="detail-card">
            <!-- HEADER -->
            <div class="detail-header">
                <div class="detail-icon"><i class="fas fa-coins"></i></div>
                <div class="detail-header-info">
                    <h1>${allowance.allowanceName}</h1>
                    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
                        <span class="detail-id-badge"><i class="fas fa-hashtag" style="font-size:.65rem;"></i> ID: ${allowance.allowanceId}</span>
                        <c:choose>
                            <c:when test="${allowance.status}">
                                <span class="badge-active"><i class="fas fa-circle" style="font-size:.5rem;"></i> Đang hoạt động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-inactive"><i class="fas fa-circle" style="font-size:.5rem;"></i> Đã vô hiệu hóa</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- BODY -->
            <div class="detail-body">

                <!-- AMOUNT HIGHLIGHT -->
                <div class="amount-highlight">
                    <div class="amount-icon"><i class="fas fa-money-bill-wave"></i></div>
                    <div>
                        <div class="amount-label">Mức tiền phụ cấp</div>
                        <c:choose>
                            <c:when test="${allowance.amount != null && allowance.amount > 0}">
                                <div class="amount-value">
                                    <fmt:formatNumber value="${allowance.amount}" type="number" groupingUsed="true"/> đ
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="amount-value" style="color:#94a3b8;font-size:1.2rem;">Chưa cập nhật</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- INFO GRID -->
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label"><i class="fas fa-tag"></i> Tên Phụ Cấp</div>
                        <div class="info-value">${allowance.allowanceName}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label"><i class="fas fa-toggle-on"></i> Trạng Thái</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${allowance.status}">✅ Đang hoạt động</c:when>
                                <c:otherwise>⛔ Đã vô hiệu hóa</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="info-item full-width">
                        <div class="info-label"><i class="fas fa-clipboard-check"></i> Điều Kiện Hưởng</div>
                        <div class="info-value ${empty allowance.applyCondition ? 'empty' : ''}">
                            <c:choose>
                                <c:when test="${not empty allowance.applyCondition}">${allowance.applyCondition}</c:when>
                                <c:otherwise>Chưa có thông tin điều kiện hưởng</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="info-item full-width">
                        <div class="info-label"><i class="fas fa-align-left"></i> Mô Tả</div>
                        <div class="info-value ${empty allowance.description ? 'empty' : ''}">
                            <c:choose>
                                <c:when test="${not empty allowance.description}">${allowance.description}</c:when>
                                <c:otherwise>Chưa có mô tả</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- ACTIONS -->
                <div class="detail-actions">
                    <c:if test="${allowance.status}">
                        <button class="btn-edit-detail"
                                onclick="openEditFromDetail()">
                            <i class="fas fa-pen"></i> Chỉnh Sửa
                        </button>
                        <a href="${pageContext.request.contextPath}/hr/allowance?action=deactivate&id=${allowance.allowanceId}"
                           class="btn-deact-detail"
                           onclick="return confirm('Vô hiệu hóa phụ cấp này?')">
                            <i class="fas fa-ban"></i> Vô Hiệu Hóa
                        </a>
                    </c:if>
                    <c:if test="${!allowance.status}">
                        <a href="${pageContext.request.contextPath}/hr/allowance?action=activate&id=${allowance.allowanceId}"
                           class="btn-act-detail"
                           onclick="return confirm('Kích hoạt lại phụ cấp này?')">
                            <i class="fas fa-redo"></i> Kích Hoạt Lại
                        </a>
                    </c:if>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Inline edit modal reuse (redirect to list with open-edit) -->
<script>
function openEditFromDetail() {
    // Redirect về list và tự mở edit modal qua query param
    window.location.href = '${pageContext.request.contextPath}/hr/allowance?openEdit=${allowance.allowanceId}';
}
</script>

<jsp:include page="../footer.jsp" />

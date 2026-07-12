<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Cấu hình Phụ cấp theo Chức vụ" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --navy:    #0a2540;
        --blue:    #2b6cb0;
        --accent:  #0d9488;
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
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    /* TOP BAR */
    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb  { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }

    /* ALERTS */
    .alert { padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; font-size: .875rem; font-weight: 500; display: flex; align-items: center; gap: 10px; }
    .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .alert-danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    /* LAYOUT: 2 columns */
    .matrix-layout { display: grid; grid-template-columns: 300px 1fr; gap: 20px; align-items: start; }

    /* POSITION PANEL (left) */
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; overflow: hidden; }
    .panel-header { padding: 18px 22px; border-bottom: 1px solid var(--border); display: flex; align-items: center; gap: 10px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: .95rem; font-weight: 800; color: var(--navy); margin: 0; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--accent); flex-shrink: 0; }

    .pos-list { padding: 10px 8px; max-height: calc(100vh - 260px); overflow-y: auto; }
    .pos-item {
        display: flex; align-items: center; gap: 10px; padding: 10px 14px;
        border-radius: 10px; cursor: pointer; text-decoration: none;
        color: var(--text); font-size: .875rem; font-weight: 500;
        transition: background .15s, color .15s; margin-bottom: 2px;
    }
    .pos-item:hover   { background: #f1f5f9; color: var(--navy); }
    .pos-item.selected { background: var(--accent); color: #fff; }
    .pos-item.selected .pos-badge { background: rgba(255,255,255,.25); color: #fff; }
    .pos-icon { width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: .8rem; flex-shrink: 0; background: #f1f5f9; color: var(--muted); }
    .pos-item.selected .pos-icon { background: rgba(255,255,255,.2); color: #fff; }
    .pos-name { flex: 1; min-width: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .pos-badge { font-size: .68rem; font-weight: 700; padding: 2px 8px; border-radius: 20px; background: #eff6ff; color: var(--blue); flex-shrink: 0; }

    /* MATRIX PANEL (right) */
    .matrix-panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; }
    .matrix-header { padding: 18px 24px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
    .matrix-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: .95rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; gap: 10px; }

    /* EMPTY STATE */
    .empty-state { text-align: center; padding: 80px 20px; color: var(--muted); }
    .empty-state i { font-size: 3.5rem; margin-bottom: 20px; opacity: .25; display: block; color: var(--accent); }
    .empty-state p { font-size: .95rem; }

    /* ALLOWANCE GRID */
    .allowance-grid { padding: 24px; display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 14px; }

    .allowance-card {
        border: 2px solid var(--border);
        border-radius: 14px;
        padding: 16px 18px;
        display: flex;
        align-items: flex-start;
        gap: 14px;
        cursor: pointer;
        transition: border-color .2s, box-shadow .2s, background .2s;
        user-select: none;
        position: relative;
        overflow: hidden;
    }
    .allowance-card:hover { border-color: var(--accent); box-shadow: 0 4px 16px rgba(13,148,136,.1); }
    .allowance-card.checked { border-color: var(--accent); background: linear-gradient(135deg, #f0fdfa, #ccfbf1); box-shadow: 0 4px 20px rgba(13,148,136,.18); }
    .allowance-card input[type=checkbox] { display: none; }

    .card-check {
        width: 22px; height: 22px; border-radius: 6px; border: 2px solid var(--border);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        background: #f8fafc; transition: all .2s; margin-top: 2px;
    }
    .allowance-card.checked .card-check { background: var(--accent); border-color: var(--accent); }
    .allowance-card.checked .card-check i { display: block; }
    .card-check i { display: none; color: #fff; font-size: .7rem; }

    .card-body { flex: 1; min-width: 0; }
    .card-name { font-weight: 700; color: var(--navy); font-size: .9rem; margin-bottom: 4px; display: flex; align-items: center; gap: 8px; }
    .card-amount { font-family: 'Be Vietnam Pro', sans-serif; font-weight: 800; font-size: 1rem; color: #0d9488; margin-bottom: 2px; }
    .card-cond  { font-size: .77rem; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    .allowance-card.checked .card-amount { color: #0f766e; }

    /* ACTIONS */
    .matrix-actions { padding: 18px 24px; border-top: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; background: #fafbfd; border-radius: 0 0 16px 16px; }
    .sel-count { font-size: .85rem; color: var(--muted); }
    .sel-count strong { color: var(--accent); font-size: 1.1rem; }

    .btn-group { display: flex; gap: 10px; }
    .btn-outline { background: none; border: 1px solid var(--border); padding: 9px 18px; border-radius: 8px; font-size: .875rem; cursor: pointer; color: var(--muted); font-family: 'Inter', sans-serif; transition: all .2s; }
    .btn-outline:hover { background: #f1f5f9; border-color: #94a3b8; }
    .btn-accent { background: var(--accent); color: #fff; border: none; padding: 10px 24px; border-radius: 8px; font-weight: 700; font-size: .9rem; cursor: pointer; font-family: 'Inter', sans-serif; display: flex; align-items: center; gap: 8px; transition: background .2s, transform .15s; }
    .btn-accent:hover { background: #0f766e; transform: translateY(-1px); }
    .btn-accent i { font-size: .85rem; }

    /* Search in panel */
    .pos-search { padding: 8px 10px; border-bottom: 1px solid var(--border); }
    .pos-search input { width: 100%; padding: 8px 12px 8px 34px; border: 1px solid var(--border); border-radius: 8px; font-size: .83rem; font-family: 'Inter', sans-serif; outline: none; transition: border .2s; }
    .pos-search input:focus { border-color: var(--accent); }
    .pos-search-wrap { position: relative; }
    .pos-search-wrap i { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .8rem; }

    /* Highlight ribbon */
    .ribbon { position: absolute; top: 0; right: 0; background: var(--accent); color: #fff; font-size: .62rem; font-weight: 700; padding: 3px 10px 3px 14px; clip-path: polygon(8px 0,100% 0,100% 100%,0 100%); letter-spacing: .5px; display: none; }
    .allowance-card.checked .ribbon { display: block; }

    @media (max-width: 900px) {
        .matrix-layout { grid-template-columns: 1fr; }
        .page-main { padding: 20px 16px; }
        .pos-list { max-height: 220px; }
    }
</style>

<%-- Count assigned allowances per position for badge --%>
<c:set var="asnIds" value="${assignedIds}" />

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="position-allowance" />
    </jsp:include>

    <main class="page-main">

        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <h1><i class="fas fa-table" style="color:var(--accent);margin-right:10px;"></i>Cấu hình Phụ cấp theo Chức vụ</h1>
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i></a>
                    <i class="fas fa-chevron-right" style="font-size:.65rem;"></i>
                    <span>HR</span>
                    <i class="fas fa-chevron-right" style="font-size:.65rem;"></i>
                    <span>Cấu hình Phụ cấp</span>
                </div>
            </div>
            <div style="display:flex;gap:10px;align-items:center;">
                <a href="${pageContext.request.contextPath}/hr/allowance"
                   style="background:none;border:1px solid var(--border);padding:9px 16px;border-radius:8px;font-size:.85rem;font-weight:600;color:var(--muted);text-decoration:none;display:flex;align-items:center;gap:6px;transition:background .2s;"
                   onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='none'">
                    <i class="fas fa-coins"></i> Quản lý Phụ cấp
                </a>
                <a href="${pageContext.request.contextPath}/hr/position"
                   style="background:none;border:1px solid var(--border);padding:9px 16px;border-radius:8px;font-size:.85rem;font-weight:600;color:var(--muted);text-decoration:none;display:flex;align-items:center;gap:6px;transition:background .2s;"
                   onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='none'">
                    <i class="fas fa-id-card-alt"></i> Quản lý Chức vụ
                </a>
            </div>
        </div>

        <!-- ALERTS -->
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${sessionScope.successMsg}
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMsg}
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <!-- MATRIX LAYOUT -->
        <div class="matrix-layout">

            <!-- LEFT: Position List -->
            <div class="panel">
                <div class="panel-header">
                    <span class="dot"></span>
                    <h2 class="panel-title">Chức vụ</h2>
                    <span style="margin-left:auto;font-size:.75rem;color:var(--muted);">${fn:length(positionList)} chức vụ</span>
                </div>
                <div class="pos-search">
                    <div class="pos-search-wrap">
                        <i class="fas fa-search"></i>
                        <input type="text" id="posSearch" placeholder="Tìm chức vụ..." oninput="filterPositions(this.value)">
                    </div>
                </div>
                <div class="pos-list" id="posListContainer">
                    <c:forEach var="p" items="${positionList}">
                        <a href="${pageContext.request.contextPath}/hr/position-allowance?posId=${p.positionId}"
                           class="pos-item ${selectedPosId == p.positionId ? 'selected' : ''}"
                           id="posItem_${p.positionId}"
                           data-name="${fn:toLowerCase(p.positionName)}">
                            <div class="pos-icon"><i class="fas fa-id-badge"></i></div>
                            <span class="pos-name">${p.positionName}</span>
                            <span class="pos-badge" id="badge_${p.positionId}">—</span>
                        </a>
                    </c:forEach>
                    <c:if test="${empty positionList}">
                        <div style="text-align:center;padding:40px 16px;color:var(--muted);font-size:.85rem;">
                            <i class="fas fa-inbox" style="font-size:2rem;display:block;margin-bottom:10px;opacity:.3;"></i>
                            Chưa có chức vụ nào.
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- RIGHT: Allowance Matrix -->
            <div class="matrix-panel">
                <div class="matrix-header">
                    <h2 class="matrix-title">
                        <span class="dot"></span>
                        <c:choose>
                            <c:when test="${not empty selectedPosId}">
                                <c:forEach var="p" items="${positionList}">
                                    <c:if test="${p.positionId == selectedPosId}">
                                        <i class="fas fa-id-badge" style="color:var(--accent);"></i>
                                        Phụ cấp của: ${p.positionName}
                                    </c:if>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                Danh sách Phụ cấp
                            </c:otherwise>
                        </c:choose>
                    </h2>
                    <c:if test="${not empty selectedPosId}">
                        <div style="display:flex;align-items:center;gap:8px;">
                            <button type="button" id="btnSelectAll" onclick="selectAll()"
                                style="background:none;border:1px solid var(--border);padding:6px 14px;border-radius:8px;font-size:.8rem;cursor:pointer;color:var(--muted);font-family:'Inter',sans-serif;transition:background .15s;"
                                onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='none'">
                                <i class="fas fa-check-square"></i> Chọn tất cả
                            </button>
                            <button type="button" onclick="clearAll()"
                                style="background:none;border:1px solid var(--border);padding:6px 14px;border-radius:8px;font-size:.8rem;cursor:pointer;color:var(--muted);font-family:'Inter',sans-serif;transition:background .15s;"
                                onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='none'">
                                <i class="fas fa-square"></i> Bỏ chọn
                            </button>
                        </div>
                    </c:if>
                </div>

                <c:choose>
                    <c:when test="${empty selectedPosId}">
                        <div class="empty-state">
                            <i class="fas fa-hand-point-left"></i>
                            <p style="font-size:1rem;font-weight:600;color:var(--navy);margin-bottom:6px;">Chọn một chức vụ để cấu hình</p>
                            <p>Nhấn vào tên chức vụ bên trái để xem và chỉnh sửa<br>danh sách phụ cấp được hưởng.</p>
                        </div>
                    </c:when>
                    <c:when test="${empty allowanceList}">
                        <div class="empty-state">
                            <i class="fas fa-coins"></i>
                            <p style="font-size:1rem;font-weight:600;color:var(--navy);margin-bottom:6px;">Chưa có phụ cấp nào được cấu hình</p>
                            <p><a href="${pageContext.request.contextPath}/hr/allowance" style="color:var(--blue);">Thêm phụ cấp mới</a> trước khi cấu hình ma trận.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <form method="post" action="${pageContext.request.contextPath}/hr/position-allowance" id="matrixForm">
                            <input type="hidden" name="posId" value="${selectedPosId}">

                            <div class="allowance-grid" id="allowanceGrid">
                                <c:forEach var="a" items="${allowanceList}">
                                    <c:set var="isChecked" value="${not empty assignedIds and assignedIds.contains(a.allowanceId)}" />
                                    <div class="allowance-card ${isChecked ? 'checked' : ''}"
                                         id="card_${a.allowanceId}"
                                         onclick="toggleCard(${a.allowanceId})"
                                         title="${fn:escapeXml(a.allowanceName)}">
                                        <div class="ribbon">✓ GÁN</div>
                                        <div class="card-check">
                                            <i class="fas fa-check"></i>
                                        </div>
                                        <input type="checkbox" name="allowanceId" value="${a.allowanceId}"
                                               id="chk_${a.allowanceId}" ${isChecked ? 'checked' : ''}>
                                        <div class="card-body">
                                            <div class="card-name">
                                                <i class="fas fa-coins" style="color:var(--accent);font-size:.8rem;"></i>
                                                ${a.allowanceName}
                                            </div>
                                            <div class="card-amount">
                                                <fmt:formatNumber value="${a.amount}" type="number" groupingUsed="true"/> đ
                                            </div>
                                            <div class="card-cond">
                                                <c:choose>
                                                    <c:when test="${not empty a.applyCondition}">${a.applyCondition}</c:when>
                                                    <c:otherwise><span style="font-style:italic;">Không có điều kiện</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="matrix-actions">
                                <div class="sel-count">
                                    Đã chọn: <strong id="countLabel">0</strong> / ${fn:length(allowanceList)} phụ cấp
                                </div>
                                <div class="btn-group">
                                    <a href="${pageContext.request.contextPath}/hr/position-allowance?posId=${selectedPosId}"
                                       class="btn-outline" style="text-decoration:none;display:inline-flex;align-items:center;gap:6px;">
                                        <i class="fas fa-undo"></i> Khôi phục
                                    </a>
                                    <button type="submit" class="btn-accent">
                                        <i class="fas fa-save"></i> Lưu cấu hình
                                    </button>
                                </div>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>

<script>
    // ─── Checkbox matrix logic ─────────────────────────────────────────
    function toggleCard(allowanceId) {
        var card = document.getElementById('card_' + allowanceId);
        var chk  = document.getElementById('chk_' + allowanceId);
        if (!card || !chk) return;
        if (chk.checked) {
            chk.checked = false;
            card.classList.remove('checked');
        } else {
            chk.checked = true;
            card.classList.add('checked');
        }
        updateCount();
    }

    function selectAll() {
        document.querySelectorAll('.allowance-card').forEach(function(card) {
            var id  = card.id.replace('card_', '');
            var chk = document.getElementById('chk_' + id);
            if (chk) { chk.checked = true; card.classList.add('checked'); }
        });
        updateCount();
    }

    function clearAll() {
        document.querySelectorAll('.allowance-card').forEach(function(card) {
            var id  = card.id.replace('card_', '');
            var chk = document.getElementById('chk_' + id);
            if (chk) { chk.checked = false; card.classList.remove('checked'); }
        });
        updateCount();
    }

    function updateCount() {
        var count = document.querySelectorAll('.allowance-card.checked').length;
        var lbl   = document.getElementById('countLabel');
        if (lbl) lbl.textContent = count;
    }

    // Init count on load
    window.addEventListener('DOMContentLoaded', function() {
        updateCount();
        loadBadges();
    });

    // ─── Position search filter ────────────────────────────────────────
    function filterPositions(q) {
        var kw = q.toLowerCase().trim();
        document.querySelectorAll('.pos-item').forEach(function(el) {
            var name = el.getAttribute('data-name') || '';
            el.style.display = (!kw || name.indexOf(kw) >= 0) ? '' : 'none';
        });
    }

    // ─── Load badge counts per position via fetch ──────────────────────
    function loadBadges() {
        document.querySelectorAll('.pos-item').forEach(function(el) {
            var href = el.getAttribute('href');
            var match = href && href.match(/posId=(\d+)/);
            if (!match) return;
            var posId = match[1];
            var badge = document.getElementById('badge_' + posId);
            if (!badge) return;
            fetch('${pageContext.request.contextPath}/api/position-allowances?positionId=' + posId)
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    badge.textContent = Array.isArray(data) ? data.length : '0';
                })
                .catch(function() { badge.textContent = '?'; });
        });
    }
</script>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chi tiết Ngạch Lương" scope="request" />
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
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    .back-link { display: inline-flex; align-items: center; gap: 8px; color: var(--blue); text-decoration: none; font-size: .875rem; font-weight: 600; margin-bottom: 20px; transition: opacity .2s; }
    .back-link:hover { opacity: .7; }

    .detail-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 20px; margin-bottom: 28px; flex-wrap: wrap; }
    .detail-hero   { display: flex; align-items: center; gap: 18px; }
    .hero-icon     { width: 64px; height: 64px; border-radius: 18px; background: #fff7ed; color: #ea580c; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; flex-shrink: 0; }
    .hero-title    { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.6rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; }
    .hero-sub      { font-size: .82rem; color: var(--muted); display: flex; align-items: center; gap: 8px; }
    .badge-active   { display: inline-flex; align-items: center; gap: 5px; background: #dcfce7; color: #16a34a; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
    .badge-inactive { display: inline-flex; align-items: center; gap: 5px; background: #f1f5f9; color: #64748b; font-size: .73rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }

    .detail-actions { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }
    .btn-outline { border: 1.5px solid var(--border); background: var(--surface); color: var(--navy); padding: 9px 18px; border-radius: 8px; font-size: .875rem; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 7px; transition: all .2s; font-family: 'Inter', sans-serif; text-decoration: none; }
    .btn-outline:hover { border-color: var(--blue); color: var(--blue); background: #eff6ff; }
    .btn-warning-outline { border-color: #fdba74; color: #ea580c; }
    .btn-warning-outline:hover { background: #fff7ed; border-color: #ea580c; }

    /* STAT CARDS */
    .stat-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 24px; }
    .stat-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 22px 24px; }
    .stat-label { font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); margin-bottom: 8px; }
    .stat-value { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.9rem; font-weight: 800; color: var(--navy); line-height: 1.1; }
    .stat-value.green { color: #16a34a; }
    .stat-unit  { font-size: .78rem; color: var(--muted); margin-top: 4px; }

    /* DETAIL PANEL */
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 28px 32px; margin-bottom: 20px; }
    .panel-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin: 0 0 22px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid var(--border); padding-bottom: 14px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--blue); }

    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .info-item { }
    .info-item-label { font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: .8px; color: var(--muted); margin-bottom: 6px; }
    .info-item-value { font-size: .95rem; font-weight: 600; color: var(--navy); }
    .info-item-value.large { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.4rem; font-weight: 800; }
    .info-item-value.green { color: #16a34a; }
    .info-item-value.muted { color: var(--muted); font-style: italic; font-weight: 400; }

    .formula-box { background: #f8fafc; border: 1px solid var(--border); border-radius: 10px; padding: 18px 22px; margin-top: 16px; display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
    .formula-part { text-align: center; }
    .formula-num  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.2rem; font-weight: 800; color: var(--navy); }
    .formula-lbl  { font-size: .7rem; color: var(--muted); font-weight: 600; text-transform: uppercase; letter-spacing: .5px; margin-top: 2px; }
    .formula-op   { font-size: 1.6rem; color: var(--muted); font-weight: 300; }
    .formula-result { background: #dcfce7; border-radius: 8px; padding: 10px 18px; text-align: center; }
    .formula-result .formula-num { color: #16a34a; font-size: 1.4rem; }

    .employee-count-badge { display: inline-flex; align-items: center; gap: 8px; background: #eff6ff; color: var(--blue); font-size: .875rem; font-weight: 700; padding: 8px 16px; border-radius: 8px; }

    @media (max-width: 900px) {
        .page-main { padding: 20px 16px; }
        .stat-grid { grid-template-columns: 1fr 1fr; }
        .info-grid { grid-template-columns: 1fr; }
    }
    @media (max-width: 600px) {
        .stat-grid { grid-template-columns: 1fr; }
        .detail-header { flex-direction: column; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp" />

    <main class="page-main">

        <a href="${pageContext.request.contextPath}/hr/salary-grade" class="back-link">
            <i class="fas fa-arrow-left"></i> Quay lại danh sách
        </a>

        <!-- HEADER -->
        <div class="detail-header">
            <div class="detail-hero">
                <div class="hero-icon"><i class="fas fa-layer-group"></i></div>
                <div>
                    <h1 class="hero-title">${fn:escapeXml(salaryGrade.gradeName)}</h1>
                    <div class="hero-sub">
                        ID: ${salaryGrade.salaryGradeId}
                        &nbsp;·&nbsp;
                        <c:choose>
                            <c:when test="${salaryGrade.status}">
                                <span class="badge-active"><i class="fas fa-circle" style="font-size:.5rem;"></i> Hoạt động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-inactive"><i class="fas fa-circle" style="font-size:.5rem;"></i> Vô hiệu hóa</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            <div class="detail-actions">
                <c:if test="${salaryGrade.status}">
                    <button class="btn-outline" onclick="openEditModal()">
                        <i class="fas fa-pen"></i> Chỉnh sửa
                    </button>
                    <c:if test="${linkedCount == 0}">
                        <button class="btn-outline btn-warning-outline" onclick="openDeactivateModal()">
                            <i class="fas fa-ban"></i> Vô hiệu hóa
                        </button>
                    </c:if>
                </c:if>
                <c:if test="${!salaryGrade.status}">
                    <form method="post" action="${pageContext.request.contextPath}/hr/salary-grade" style="display:inline;">
                        <input type="hidden" name="action" value="activate">
                        <input type="hidden" name="id" value="${salaryGrade.salaryGradeId}">
                        <button type="submit" class="btn-outline" style="color:#16a34a;border-color:#86efac;">
                            <i class="fas fa-redo"></i> Kích hoạt lại
                        </button>
                    </form>
                </c:if>
            </div>
        </div>

        <!-- STAT CARDS -->
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-label">Lương Cơ Bản</div>
                <div class="stat-value"><fmt:formatNumber value="${salaryGrade.baseSalary}" type="number" groupingUsed="true"/></div>
                <div class="stat-unit">VND / tháng</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Hệ Số</div>
                <div class="stat-value">×&nbsp;<fmt:formatNumber value="${salaryGrade.coefficient}" maxFractionDigits="2"/></div>
                <div class="stat-unit">hệ số nhân</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Lương Thực Tế</div>
                <div class="stat-value green"><fmt:formatNumber value="${salaryGrade.baseSalary * salaryGrade.coefficient}" type="number" groupingUsed="true"/></div>
                <div class="stat-unit">VND / tháng</div>
            </div>
        </div>

        <!-- THÔNG TIN CHI TIẾT -->
        <div class="panel">
            <h2 class="panel-title"><span class="dot"></span> Thông Tin Chi Tiết</h2>
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-item-label">Tên Ngạch Lương</div>
                    <div class="info-item-value">${fn:escapeXml(salaryGrade.gradeName)}</div>
                </div>
                <div class="info-item">
                    <div class="info-item-label">Mã Ngạch</div>
                    <div class="info-item-value">#${salaryGrade.salaryGradeId}</div>
                </div>
                <div class="info-item">
                    <div class="info-item-label">Nhân Viên Đang Áp Dụng</div>
                    <div class="info-item-value">
                        <span class="employee-count-badge">
                            <i class="fas fa-users"></i>
                            ${linkedCount} nhân viên
                        </span>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-item-label">Trạng Thái</div>
                    <div class="info-item-value">
                        <c:choose>
                            <c:when test="${salaryGrade.status}">
                                <span class="badge-active"><i class="fas fa-circle" style="font-size:.5rem;"></i> Hoạt động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-inactive"><i class="fas fa-circle" style="font-size:.5rem;"></i> Vô hiệu hóa</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="info-item" style="grid-column: 1 / -1;">
                    <div class="info-item-label">Mô Tả</div>
                    <div class="info-item-value ${empty salaryGrade.description ? 'muted' : ''}">
                        <c:choose>
                            <c:when test="${not empty salaryGrade.description}">${fn:escapeXml(salaryGrade.description)}</c:when>
                            <c:otherwise>Không có mô tả</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- CÔNG THỨC TÍNH LƯƠNG -->
        <div class="panel">
            <h2 class="panel-title"><span class="dot"></span> Công Thức Tính Lương</h2>
            <p style="color:var(--muted);font-size:.875rem;margin-bottom:16px;">
                Lương thực tế được tính bằng Lương cơ bản nhân với Hệ số lương tương ứng của ngạch.
            </p>
            <div class="formula-box">
                <div class="formula-part">
                    <div class="formula-num"><fmt:formatNumber value="${salaryGrade.baseSalary}" type="number" groupingUsed="true"/> ₫</div>
                    <div class="formula-lbl">Lương Cơ Bản</div>
                </div>
                <div class="formula-op">×</div>
                <div class="formula-part">
                    <div class="formula-num"><fmt:formatNumber value="${salaryGrade.coefficient}" maxFractionDigits="2"/></div>
                    <div class="formula-lbl">Hệ Số</div>
                </div>
                <div class="formula-op">=</div>
                <div class="formula-result">
                    <div class="formula-num"><fmt:formatNumber value="${salaryGrade.baseSalary * salaryGrade.coefficient}" type="number" groupingUsed="true"/> ₫</div>
                    <div class="formula-lbl">Lương Thực Tế / Tháng</div>
                </div>
            </div>
        </div>

    </main>
</div>

<!-- MODAL SỬA (inline, pre-filled) -->
<div class="modal-overlay" id="detailEditModal">
    <div class="modal-box" style="width:520px;">
        <div class="modal-header">
            <h3 style="font-family:'Be Vietnam Pro',sans-serif;font-size:1.05rem;font-weight:800;color:var(--navy);margin:0;display:flex;align-items:center;gap:8px;">
                <i class="fas fa-pen" style="color:var(--blue);"></i> Cập Nhật Ngạch Lương
            </h3>
            <button onclick="document.getElementById('detailEditModal').classList.remove('show')" style="background:none;border:none;font-size:1.4rem;color:var(--muted);cursor:pointer;">&times;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/salary-grade">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id"     value="${salaryGrade.salaryGradeId}">
            <div style="margin-bottom:18px;">
                <label style="display:block;font-size:.82rem;font-weight:600;color:var(--muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Tên Ngạch Lương *</label>
                <input type="text" name="gradeName" value="${fn:escapeXml(salaryGrade.gradeName)}"
                       style="width:100%;padding:10px 12px;border:1px solid var(--border);border-radius:8px;font-size:.875rem;font-family:'Inter',sans-serif;outline:none;color:var(--text);"
                       required maxlength="100">
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:18px;">
                <div>
                    <label style="display:block;font-size:.82rem;font-weight:600;color:var(--muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Lương Cơ Bản (₫) *</label>
                    <input type="number" name="baseSalary" value="${salaryGrade.baseSalary}"
                           style="width:100%;padding:10px 12px;border:1px solid var(--border);border-radius:8px;font-size:.875rem;font-family:'Inter',sans-serif;outline:none;color:var(--text);"
                           required min="1" step="1000">
                </div>
                <div>
                    <label style="display:block;font-size:.82rem;font-weight:600;color:var(--muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Hệ Số *</label>
                    <input type="number" name="coefficient" value="${salaryGrade.coefficient}"
                           style="width:100%;padding:10px 12px;border:1px solid var(--border);border-radius:8px;font-size:.875rem;font-family:'Inter',sans-serif;outline:none;color:var(--text);"
                           required min="0.01" step="0.01">
                </div>
            </div>
            <div style="margin-bottom:18px;">
                <label style="display:block;font-size:.82rem;font-weight:600;color:var(--muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">Mô Tả</label>
                <textarea name="description"
                          style="width:100%;padding:10px 12px;border:1px solid var(--border);border-radius:8px;font-size:.875rem;font-family:'Inter',sans-serif;outline:none;resize:vertical;min-height:80px;color:var(--text);">${fn:escapeXml(salaryGrade.description)}</textarea>
            </div>
            <div style="display:flex;justify-content:flex-end;gap:10px;padding-top:18px;border-top:1px solid var(--border);">
                <button type="button" onclick="document.getElementById('detailEditModal').classList.remove('show')"
                        style="background:none;border:1px solid var(--border);padding:9px 18px;border-radius:8px;font-size:.875rem;cursor:pointer;color:var(--muted);font-family:'Inter',sans-serif;">Hủy</button>
                <button type="submit"
                        style="background:var(--blue);color:#fff;border:none;padding:9px 22px;border-radius:8px;font-weight:600;font-size:.875rem;cursor:pointer;font-family:'Inter',sans-serif;">
                    <i class="fas fa-save" style="margin-right:6px;"></i>Cập Nhật
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL VÔ HIỆU HÓA (từ trang chi tiết) -->
<div class="modal-overlay" id="detailDeactivateModal">
    <div class="modal-box" style="width:420px;text-align:center;">
        <div style="width:64px;height:64px;background:#fff7ed;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:1.8rem;color:#ea580c;margin:0 auto 16px;">
            <i class="fas fa-ban"></i>
        </div>
        <div style="font-family:'Be Vietnam Pro',sans-serif;font-size:1.1rem;font-weight:800;color:var(--navy);margin-bottom:8px;">Vô hiệu hóa ngạch lương</div>
        <div style="color:var(--muted);font-size:.875rem;margin-bottom:24px;line-height:1.6;">
            Bạn có chắc muốn vô hiệu hóa ngạch lương<br>
            <strong>${fn:escapeXml(salaryGrade.gradeName)}</strong>?<br><br>
            Bạn có thể kích hoạt lại bất cứ lúc nào.
        </div>
        <form method="post" action="${pageContext.request.contextPath}/hr/salary-grade">
            <input type="hidden" name="action" value="deactivate">
            <input type="hidden" name="id"     value="${salaryGrade.salaryGradeId}">
            <div style="display:flex;justify-content:center;gap:12px;">
                <button type="button" onclick="document.getElementById('detailDeactivateModal').classList.remove('show')"
                        style="background:none;border:1px solid var(--border);padding:9px 18px;border-radius:8px;font-size:.875rem;cursor:pointer;color:var(--muted);font-family:'Inter',sans-serif;">Hủy</button>
                <button type="submit"
                        style="background:#ea580c;color:#fff;border:none;padding:9px 22px;border-radius:8px;font-weight:600;font-size:.875rem;cursor:pointer;font-family:'Inter',sans-serif;">
                    <i class="fas fa-ban" style="margin-right:6px;"></i>Vô hiệu hóa
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openEditModal() {
        document.getElementById('detailEditModal').classList.add('show');
    }
    function openDeactivateModal() {
        document.getElementById('detailDeactivateModal').classList.add('show');
    }
    document.querySelectorAll('.modal-overlay').forEach(function(el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) el.classList.remove('show');
        });
    });
</script>

<jsp:include page="../footer.jsp" />

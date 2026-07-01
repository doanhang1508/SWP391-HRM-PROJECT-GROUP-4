<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Import Chấm Công - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root {
        --pri: #6366f1; --pri-l: rgba(99,102,241,.1);
        --ok: #10b981; --ok-l: rgba(16,185,129,.1);
        --ng: #ef4444; --ng-l: rgba(239,68,68,.1);
        --warn: #f59e0b; --bg: #f4f7fe; --card: #fff;
        --txt: #1e293b; --muted: #64748b;
    }
    body { background: var(--bg); font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 30px; }
    .page-header { margin-bottom: 28px; }
    .page-title { font-size: 1.5rem; font-weight: 700; color: var(--txt); margin: 0; }
    .breadcrumb-c { font-size: .85rem; color: var(--muted); margin: 4px 0 0; }
    .breadcrumb-c a { color: var(--pri); text-decoration: none; }
    .panel {
        background: var(--card); border-radius: 16px; padding: 28px;
        box-shadow: 0 4px 20px rgba(0,0,0,.04); border: 1px solid rgba(0,0,0,.05);
        margin-bottom: 24px;
    }
    .panel-title {
        font-size: 1rem; font-weight: 700; color: var(--txt);
        margin-bottom: 20px; display: flex; align-items: center; gap: 8px;
    }
    .panel-title i { color: var(--pri); }

    /* Upload zone */
    .upload-zone {
        border: 2px dashed #c7d2fe; border-radius: 12px; padding: 40px 20px;
        text-align: center; cursor: pointer; transition: all .2s; background: #fafbff;
    }
    .upload-zone:hover, .upload-zone.dragover {
        border-color: var(--pri); background: var(--pri-l);
    }
    .upload-zone i { font-size: 2.5rem; color: #a5b4fc; margin-bottom: 12px; }
    .upload-zone h4 { font-size: 1rem; font-weight: 600; color: var(--txt); margin: 0 0 6px; }
    .upload-zone p { font-size: .85rem; color: var(--muted); margin: 0; }
    #fileInput { display: none; }
    #fileName {
        margin-top: 12px; font-size: .85rem; font-weight: 600;
        color: var(--pri); display: none;
    }

    /* Form row */
    .form-row { display: flex; gap: 16px; margin-top: 20px; flex-wrap: wrap; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-group label { font-size: .82rem; font-weight: 600; color: var(--muted); }
    .form-group select, .form-group input[type="text"] {
        border: 1.5px solid #e2e8f0; border-radius: 8px; padding: 8px 12px;
        font-size: .88rem; font-family: 'Inter', sans-serif; color: var(--txt);
        outline: none; transition: border-color .2s;
    }
    .form-group select:focus, .form-group input:focus { border-color: var(--pri); }

    .btn-import {
        background: var(--pri); color: #fff; border: none; border-radius: 10px;
        padding: 11px 24px; font-weight: 600; font-size: .9rem;
        display: inline-flex; align-items: center; gap: 8px; cursor: pointer;
        transition: all .2s; margin-top: 20px;
    }
    .btn-import:hover { background: #4f46e5; transform: translateY(-1px); }
    .btn-import:disabled { background: #94a3b8; cursor: not-allowed; transform: none; }

    /* Alert */
    .alert {
        padding: 14px 18px; border-radius: 10px; margin-bottom: 20px;
        display: flex; align-items: center; gap: 10px; font-size: .88rem; font-weight: 500;
    }
    .alert-success { background: var(--ok-l); color: #065f46; border: 1px solid #a7f3d0; }
    .alert-error { background: var(--ng-l); color: #991b1b; border: 1px solid #fecaca; }
    .alert-warning { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; flex-direction: column; align-items: flex-start; }

    /* CSV format guide */
    .guide-table { width: 100%; border-collapse: collapse; font-size: .83rem; }
    .guide-table th {
        background: #f8fafc; padding: 10px 14px; text-align: left;
        font-weight: 600; color: var(--muted); border-bottom: 2px solid #e2e8f0;
    }
    .guide-table td {
        padding: 9px 14px; border-bottom: 1px solid #f1f5f9; color: var(--txt);
    }
    .guide-table tr:hover td { background: #f8fafc; }
    .badge-req {
        background: var(--ng-l); color: #991b1b; font-size: .72rem;
        font-weight: 700; padding: 2px 7px; border-radius: 20px;
    }
    .badge-opt {
        background: #f0fdf4; color: #166534; font-size: .72rem;
        font-weight: 700; padding: 2px 7px; border-radius: 20px;
    }
    code {
        background: #f1f5f9; padding: 2px 7px; border-radius: 5px;
        font-family: monospace; font-size: .82rem;
    }
    .download-link {
        display: inline-flex; align-items: center; gap: 6px;
        color: var(--pri); font-weight: 600; font-size: .85rem;
        text-decoration: none;
    }
    .download-link:hover { color: #4f46e5; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="import-attendance"/>
    </jsp:include>

    <div class="main-content">
        <div class="page-header">
            <h1 class="page-title"><i class="fas fa-file-import" style="color:var(--pri);margin-right:10px"></i>Import Chấm Công</h1>
            <div class="breadcrumb-c"><a href="${pageContext.request.contextPath}/hr/dashboard">Dashboard</a> / Import Chấm Công</div>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${sessionScope.successMessage}
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMessage}
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.fullParseErrors}">
            <div class="alert alert-warning mt-3">
                <strong><i class="fas fa-exclamation-triangle" style="margin-right:6px"></i>Chi tiết các dòng lỗi:</strong>
                <ul class="mb-0 mt-2" style="font-size:0.85rem; padding-left:20px; margin:8px 0 0; width:100%;">
                    <c:forEach var="err" items="${sessionScope.fullParseErrors}">
                        <li style="margin-bottom:4px;">${err}</li>
                    </c:forEach>
                </ul>
            </div>
            <c:remove var="fullParseErrors" scope="session"/>
        </c:if>

        <!-- Upload Panel -->
        <div class="panel">
            <div class="panel-title"><i class="fas fa-upload"></i> Upload File Excel / CSV</div>

            <form method="post" action="${pageContext.request.contextPath}/hr/import-attendance"
                  enctype="multipart/form-data" id="importForm">
                <input type="hidden" name="action" value="import">

                <div class="upload-zone" id="uploadZone" onclick="document.getElementById('fileInput').click()">
                    <i class="fas fa-file-excel" style="color:#1D6F42"></i>
                    <h4>Kéo thả hoặc click để chọn file</h4>
                    <p>Hỗ trợ file Excel (<strong>.xlsx</strong>, <strong>.xls</strong>) — tối đa 10MB</p>
                    <div id="fileName"></div>
                </div>
                <input type="file" id="fileInput" name="attendanceFile" accept=".xlsx,.xls">

                <div class="form-row">
                    <div class="form-group">
                        <label>Tháng import</label>
                        <select name="importMonth" id="importMonthSelect" required>
                            <c:forEach begin="1" end="12" var="m">
                                <option value="${m}" ${m == currentMonth ? 'selected' : ''}>Tháng ${m}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Năm</label>
                        <select name="importYear" id="importYearSelect" required>
                            <option value="2026" ${2026 == currentYear ? 'selected' : ''}>2026</option>
                            <option value="2025" ${2025 == currentYear ? 'selected' : ''}>2025</option>
                            <option value="2024" ${2024 == currentYear ? 'selected' : ''}>2024</option>
                        </select>
                    </div>
                </div>

                <button type="submit" class="btn-import" id="importBtn" disabled>
                    <i class="fas fa-cloud-upload-alt"></i> Import Dữ Liệu
                </button>
            </form>
        </div>

        <!-- Timesheet / Bảng Công Info -->
        <div class="panel">
            <div class="panel-title" style="justify-content:space-between">
                <span><i class="fas fa-calendar-check"></i> Bảng Chấm Công</span>
            </div>

            <div style="margin-bottom:16px;padding:12px 16px;background:#f0fdf4;border-radius:8px;border-left:4px solid #10b981;display:flex;align-items:flex-start;gap:10px">
                <i class="fas fa-info-circle" style="color:#10b981;margin-top:2px"></i>
                <div style="font-size:.85rem;color:#065f46">
                    <strong>Quy trình xử lý:</strong> Dữ liệu chấm công sau khi import thành công sẽ được lưu thẳng vào <strong>Bảng Công</strong>. Từ Bảng Công, hệ thống sẽ tổng hợp để tính toán ra <strong>Bảng Lương</strong> cuối tháng cho nhân viên.
                </div>
            </div>

            <p style="font-size:.85rem;color:var(--muted);margin-bottom:16px">
                Bạn có thể xem chi tiết dữ liệu công của các nhân viên và thực hiện Khóa công sau khi import dữ liệu thành công.
            </p>

        </div>
    </div>
</div>

<script>
    const fileInput = document.getElementById('fileInput');
    const uploadZone = document.getElementById('uploadZone');
    const fileNameDiv = document.getElementById('fileName');
    const importBtn = document.getElementById('importBtn');

    fileInput.addEventListener('change', function() {
        if (this.files.length > 0) {
            fileNameDiv.textContent = '✓ ' + this.files[0].name;
            fileNameDiv.style.display = 'block';
            importBtn.disabled = false;
        }
    });

    uploadZone.addEventListener('dragover', e => {
        e.preventDefault(); uploadZone.classList.add('dragover');
    });
    uploadZone.addEventListener('dragleave', () => uploadZone.classList.remove('dragover'));
    uploadZone.addEventListener('drop', e => {
        e.preventDefault(); uploadZone.classList.remove('dragover');
        fileInput.files = e.dataTransfer.files;
        fileInput.dispatchEvent(new Event('change'));
    });

    const importMonthSelect = document.getElementById('importMonthSelect');
    const importYearSelect = document.getElementById('importYearSelect');
    const sysCurrentMonth = ${currentMonth};
    const sysCurrentYear = ${currentYear};

    function validateSelection() {
        if (parseInt(importMonthSelect.value) !== sysCurrentMonth || parseInt(importYearSelect.value) !== sysCurrentYear) {
            alert("Hệ thống chỉ cho phép import chấm công cho tháng hiện tại (" + sysCurrentMonth + "/" + sysCurrentYear + "). Bạn không thể chọn tháng/năm khác!");
            importMonthSelect.value = sysCurrentMonth;
            importYearSelect.value = sysCurrentYear;
        }
    }

    importMonthSelect.addEventListener('change', validateSelection);
    importYearSelect.addEventListener('change', validateSelection);
</script>

<jsp:include page="../footer.jsp" />

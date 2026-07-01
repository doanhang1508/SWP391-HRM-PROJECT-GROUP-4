<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Tạo Yêu Cầu Điều Chuyển" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --navy:    #0a2540;
        --blue:    #2b6cb0;
        --accent:  #3ecf8e;
        --bg:      #f0ede8;
        --surface: #ffffff;
        --border:  #e2e8f0;
        --text:    #0f172a;
        --muted:   #64748b;
        --pri:     #6366f1;
        --pri-dark:#4f46e5;
        --warn:    #f59e0b;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }

    .page-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .page-main    { flex: 1; padding: 32px 36px; overflow-x: hidden; }

    /* TOP BAR */
    .page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
    .page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.55rem; font-weight: 800; color: var(--navy); margin: 0 0 4px; letter-spacing: -.4px; }
    .breadcrumb  { font-size: .78rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
    .breadcrumb a { color: var(--blue); text-decoration: none; }

    /* ALERTS */
    .alert { padding: 14px 20px; border-radius: 12px; font-size: 0.9rem; font-weight: 500; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
    .alert-danger { background: #fee2e2; border: 1px solid #fecdd3; color: #9f1239; }

    /* PANEL */
    .panel-container { display: flex; justify-content: center; align-items: flex-start; margin-top: 20px; }
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 36px 40px; width: 100%; max-width: 750px; box-shadow: 0 10px 25px rgba(10,37,64,0.05); }
    
    .panel-icon-wrap { width: 56px; height: 56px; background: rgba(99, 102, 241, 0.1); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; color: var(--pri); margin: 0 auto 20px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.3rem; font-weight: 800; color: var(--navy); margin: 0 0 8px; text-align: center; }
    .panel-subtitle { font-size: 0.85rem; color: var(--muted); text-align: center; margin-bottom: 30px; }

    /* FORM */
    .form-row { display: flex; gap: 16px; margin-bottom: 16px; }
    .form-col { flex: 1; }
    .form-group { margin-bottom: 16px; }
    .form-label { display: block; font-size: .85rem; font-weight: 600; color: var(--navy); margin-bottom: 8px; }
    .form-control { width: 100%; padding: 12px 14px; border: 1px solid var(--border); border-radius: 10px; font-size: .9rem; font-family: 'Inter', sans-serif; outline: none; transition: all .2s; background: #f8fafc; color: var(--text); }
    .form-control:focus { border-color: var(--pri); box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15); background: #ffffff; }
    .form-control[readonly] { background: #e2e8f0; color: #475569; cursor: not-allowed; }
    textarea.form-control { resize: vertical; min-height: 100px; }
    
    /* SUBMIT BTN */
    .btn-submit { background: var(--pri); color: #fff; border: none; padding: 14px 20px; border-radius: 10px; font-weight: 700; font-size: .95rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; transition: all .2s; font-family: 'Inter', sans-serif; width: 100%; margin-top: 10px; box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2); }
    .btn-submit:hover { background: var(--pri-dark); transform: translateY(-2px); box-shadow: 0 6px 15px rgba(99, 102, 241, 0.3); }

    /* ADDENDUM BLOCK — style lấy từ employee-contracts.jsp */
    .addendum-block { background: #f8fafc; border: 1px solid var(--border); border-radius: 12px; padding: 20px 22px; margin-bottom: 16px; }
    .addendum-block-title { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; font-weight: 700; font-size: .9rem; color: var(--navy); border-bottom: 1px solid var(--border); padding-bottom: 12px; }
    .addendum-block-title i { color: #0d9488; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .form-grid .form-group { margin-bottom: 0; }
    .form-grid .form-group.full { grid-column: 1 / -1; }
    /* Allowance check grid — lấy đúng từ employee-contracts.jsp */
    .allowance-check-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; max-height: 180px; overflow-y: auto; border: 1px solid #e5e7eb; border-radius: 6px; padding: 10px; background: #f8fafc; }
    .allowance-check-item { display: flex; align-items: center; gap: 8px; padding: 6px 8px; border-radius: 6px; }
    .allowance-check-item label { font-size: 0.82rem; color: #374151; cursor: pointer; flex: 1; }
    .alw-amount { font-size: 0.75rem; color: #059669; font-weight: 600; }

    /* ── EMPLOYEE PICKER ───────────────────────────────────────────────────── */
    .emp-picker { position: relative; }
    .emp-search-wrap { position: relative; }
    .emp-search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .9rem; pointer-events: none; transition: color .2s; }
    .emp-search-input { width: 100%; padding: 12px 40px 12px 40px; border: 1px solid var(--border); border-radius: 10px; font-size: .9rem; font-family: 'Inter', sans-serif; outline: none; transition: all .2s; background: #f8fafc; color: var(--text); cursor: pointer; }
    .emp-search-input:focus { border-color: var(--pri); box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15); background: #fff; }
    .emp-search-input.has-value { background: #fff; }
    .emp-clear-btn { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; color: var(--muted); cursor: pointer; padding: 4px; border-radius: 6px; display: none; font-size: .85rem; transition: all .15s; }
    .emp-clear-btn:hover { background: #f1f5f9; color: var(--ng, #ef4444); }
    .emp-clear-btn.visible { display: flex; align-items: center; }

    .emp-dropdown { position: absolute; top: calc(100% + 6px); left: 0; right: 0; background: #fff; border: 1px solid var(--border); border-radius: 12px; box-shadow: 0 8px 30px rgba(10,37,64,0.12); z-index: 999; max-height: 320px; overflow-y: auto; display: none; scroll-behavior: smooth; }
    .emp-dropdown.open { display: block; animation: dropFadeIn .15s ease; }
    @keyframes dropFadeIn { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: translateY(0); } }
    .emp-dropdown::-webkit-scrollbar { width: 5px; } .emp-dropdown::-webkit-scrollbar-track { background: #f8fafc; } .emp-dropdown::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }

    .emp-item { display: flex; align-items: center; gap: 12px; padding: 10px 14px; cursor: pointer; transition: background .12s; border-bottom: 1px solid #f8fafc; }
    .emp-item:last-child { border-bottom: none; }
    .emp-item:hover, .emp-item.focused { background: rgba(99,102,241,0.06); }
    .emp-item.focused { outline: none; }
    .emp-avatar { width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: .85rem; color: #fff; flex-shrink: 0; letter-spacing: .5px; }
    .emp-info { flex: 1; min-width: 0; }
    .emp-name { font-weight: 600; font-size: .875rem; color: var(--navy); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .emp-meta { font-size: .72rem; color: var(--muted); margin-top: 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .emp-id-badge { font-size: .7rem; font-weight: 700; background: #f1f5f9; color: #64748b; padding: 2px 7px; border-radius: 5px; flex-shrink: 0; }
    .emp-no-result { padding: 24px; text-align: center; color: var(--muted); font-size: .875rem; font-style: italic; }

    /* Card hiển thị nhân viên đã chọn */
    .emp-selected-card { display: none; margin-top: 10px; padding: 14px 16px; background: linear-gradient(135deg, rgba(99,102,241,0.06) 0%, rgba(62,207,142,0.05) 100%); border: 1.5px solid rgba(99,102,241,0.25); border-radius: 12px; align-items: center; gap: 12px; animation: dropFadeIn .2s ease; }
    .emp-selected-card.show { display: flex; }
    .emp-selected-avatar { width: 46px; height: 46px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 1rem; color: #fff; flex-shrink: 0; }
    .emp-selected-info { flex: 1; }
    .emp-selected-name { font-weight: 700; font-size: .95rem; color: var(--navy); }
    .emp-selected-tags { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
    .emp-tag { display: inline-flex; align-items: center; gap: 5px; font-size: .72rem; font-weight: 600; padding: 3px 10px; border-radius: 20px; }
    .emp-tag-dept { background: rgba(99,102,241,0.1); color: #4f46e5; }
    .emp-tag-pos  { background: rgba(16,185,129,0.1); color: #059669; }
    .emp-tag-id   { background: #f1f5f9; color: #64748b; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .panel { padding: 24px; }
        .form-row { flex-direction: column; gap: 0; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="transfer-create" />
    </jsp:include>

    <div class="page-main">
        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/hr/transfer-requests">Điều chuyển</a>
                    <span>/</span>
                    <span>Tạo yêu cầu</span>
                </div>
                <h1><i class="fas fa-exchange-alt" style="color:var(--pri);margin-right:10px;font-size:1.3rem;"></i>Tạo Yêu Cầu Điều Chuyển</h1>
            </div>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle" style="font-size:1.2rem;"></i>
                ${errorMessage}
            </div>
        </c:if>

        <div class="panel-container">
            <div class="panel">
                <div class="panel-icon-wrap">
                    <i class="fas fa-user-friends"></i>
                </div>
                <h2 class="panel-title">Phiếu đề xuất Điều chuyển Nội bộ</h2>
                <p class="panel-subtitle">Thay đổi phòng ban, chức vụ và phân lại quyền hạn cho nhân sự.</p>

                <form action="${pageContext.request.contextPath}/hr/transfer-request/create" method="post">
                    
                    <!-- EMPLOYEE PICKER (Searchable Combobox) -->
                    <div class="form-group">
                        <label class="form-label" for="empSearchInput">Chọn nhân viên điều chuyển <span style="color:var(--ng,#ef4444)">*</span></label>

                        <%-- Hidden input thực sự dùng cho form submit --%>
                        <input type="hidden" id="employeeId" name="employeeId" required>

                        <%-- Dữ liệu nhân viên được render dưới dạng JSON ẩn --%>
                        <script id="empData" type="application/json">
                        [
                            <c:forEach items="${employees}" var="emp" varStatus="loop">
                                <c:set var="empDeptName" value="Chưa phân phòng" />
                                <c:forEach items="${departments}" var="d"><c:if test="${d.departmentId == emp.departmentId}"><c:set var="empDeptName" value="${d.departmentName}" /></c:if></c:forEach>
                                <c:set var="empPosName" value="Chưa phân chức vụ" />
                                <c:forEach items="${positions}" var="p"><c:if test="${p.positionId == emp.positionId}"><c:set var="empPosName" value="${p.positionName}" /></c:if></c:forEach>
                                <c:set var="empRoleName" value="Nhân viên" />
                                <c:forEach items="${roles}" var="r"><c:if test="${r.roleId == emp.roleId}"><c:set var="empRoleName" value="${r.roleName}" /></c:if></c:forEach>
                                {"id":${emp.userId},"name":"${emp.fullName}","dept":"${empDeptName}","pos":"${empPosName}","role":"${empRoleName}","roleId":${emp.roleId}}<c:if test="${!loop.last}">,</c:if>
                            </c:forEach>
                        ]
                        </script>
                        <%-- Dữ liệu lương + phụ cấp hiện tại của từng nhân viên (để pre-fill form) --%>
                        <script id="empSalaryData" type="application/json">${empSalaryData}</script>


                        <div class="emp-picker" id="empPicker">
                            <div class="emp-search-wrap">
                                <i class="fas fa-search emp-search-icon" id="empSearchIcon"></i>
                                <input type="text" id="empSearchInput" class="emp-search-input"
                                       placeholder="Tìm theo tên hoặc mã nhân viên..."
                                       autocomplete="off" spellcheck="false">
                                <button type="button" class="emp-clear-btn" id="empClearBtn" title="Xóa lựa chọn">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                            <div class="emp-dropdown" id="empDropdown" role="listbox"></div>
                        </div>

                        <%-- Card hiển thị nhân viên đã chọn --%>
                        <div class="emp-selected-card" id="empSelectedCard">
                            <div class="emp-selected-avatar" id="empSelectedAvatar"></div>
                            <div class="emp-selected-info">
                                <div class="emp-selected-name" id="empSelectedName"></div>
                                <div class="emp-selected-tags" id="empSelectedTags"></div>
                            </div>
                        </div>
                    </div>


                    <!-- NEW DEPT, POSITION & ROLE -->
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label" for="newDepartmentId">Phòng ban mới *</label>
                                <select id="newDepartmentId" name="newDepartmentId" class="form-control" onchange="updateNewPositions()" required>
                                    <option value="">-- Chọn phòng ban mới --</option>
                                    <c:forEach items="${departments}" var="d">
                                        <option value="${d.departmentId}">${d.departmentName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label" for="newPositionId">Chức vụ mới *</label>
                                <select id="newPositionId" name="newPositionId" class="form-control" onchange="updateNewRoles()" required disabled>
                                    <option value="">-- Chọn chức vụ mới --</option>
                                    <c:forEach items="${positions}" var="p">
                                        <c:if test="${p.positionId != 2}">
                                            <option value="${p.positionId}">${p.positionName}</option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label" for="newRoleId">Quyền hạn mới (Role) *</label>
                                <select id="newRoleId" name="newRoleId" class="form-control" required disabled>
                                    <option value="">-- Chọn quyền hạn mới --</option>
                                    <c:forEach items="${roles}" var="r">
                                        <option value="${r.roleId}">${r.roleName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- ADDENDUM BLOCK: Thông tin phụ lục hợp đồng đi kèm -->
                    <div class="addendum-block">
                        <div class="addendum-block-title">
                            <i class="fas fa-file-alt"></i>
                            Thông tin phụ lục hợp đồng đi kèm
                        </div>
                        <div class="form-grid">

                            <%-- Ngày hiệu lực phụ lục — backend tự set = ngày đầu tháng sau, readonly --%>
                            <div class="form-group">
                                <label class="form-label">Ngày hiệu lực phụ lục <span style="color:#dc2626">*</span></label>
                                <input type="date"
                                       id="effectiveDate"
                                       name="effectiveDate"
                                       class="form-control"
                                       value="${nextMonthFirstDay}"
                                       readonly
                                       required>
                            </div>

                            <%-- Lương cơ bản mới — optional --%>
                            <div class="form-group">
                                <label class="form-label">Lương cơ bản mới (đ)</label>
                                <input type="text"
                                       id="newBaseSalary"
                                       name="newBaseSalary"
                                       class="form-control"
                                       placeholder="Để trống nếu giữ nguyên lương hiện tại">
                            </div>


                            <%-- Lý do / Nội dung phụ lục — required --%>
                            <div class="form-group full">
                                <label class="form-label">Lý do / Nội dung phụ lục <span style="color:#dc2626">*</span></label>
                                <textarea id="reason"
                                          name="reason"
                                          class="form-control"
                                          rows="3"
                                          placeholder="Mô tả lý do điều chuyển, thay đổi phòng ban/chức vụ/lương/phụ cấp..."
                                          required></textarea>
                            </div>

                            <%-- Phụ cấp áp dụng theo phụ lục — lấy đúng style từ employee-contracts.jsp --%>
                            <c:if test="${not empty availableAllowances}">
                                <div class="form-group full">
                                    <label class="form-label">Phụ cấp áp dụng theo phụ lục</label>
                                    <div class="allowance-check-grid">
                                        <c:forEach var="alw" items="${availableAllowances}">
                                            <div class="allowance-check-item">
                                                <input type="checkbox" name="allowanceIds" value="${alw.allowanceId}" id="tr_alw_${alw.allowanceId}">
                                                <label for="tr_alw_${alw.allowanceId}"><c:out value="${alw.allowanceName}"/></label>
                                                <span class="alw-amount"><fmt:formatNumber value="${alw.amount}" type="number" groupingUsed="true"/>đ</span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                        </div>
                    </div>

                    <!-- SUBMIT BUTTON -->
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-paper-plane"></i> Gửi yêu cầu điều chuyển
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    const deptPositions = {
        1: [1, 3, 7, 8],   // Hành chính: Giám đốc, Phó phòng, Chuyên viên, Nhân viên
        2: [3, 7, 8],      // Nhân sự: Phó phòng, Chuyên viên, Nhân viên
        3: [3, 6, 7, 8],   // Kế toán: Phó phòng, Kế toán trưởng, Chuyên viên, Nhân viên
        4: [3, 7, 8],      // Kinh doanh: Phó phòng, Chuyên viên, Nhân viên
        5: [4, 5, 9]       // Xưởng sản xuất: Quản đốc, Tổ trưởng, Công nhân
    };

    let originalPositions = [];
    let originalRoles = [];

    window.addEventListener('DOMContentLoaded', (event) => {
        var posSelect = document.getElementById("newPositionId");
        for (var i = 0; i < posSelect.options.length; i++) {
            var opt = posSelect.options[i];
            originalPositions.push({
                value: opt.value,
                text: opt.text
            });
        }

        var roleSelect = document.getElementById("newRoleId");
        for (var i = 0; i < roleSelect.options.length; i++) {
            var opt = roleSelect.options[i];
            originalRoles.push({
                value: opt.value,
                text: opt.text
            });
        }
        initEmployeePicker();
    });

    // ═══════════════════════════════════════════════════════════════════════
    // EMPLOYEE PICKER — Searchable Combobox
    // ═══════════════════════════════════════════════════════════════════════

    // Bảng màu avatar theo vần đầu (10 màu gradient)
    const AVATAR_COLORS = [
        '#6366f1','#3b82f6','#10b981','#f59e0b','#ef4444',
        '#8b5cf6','#06b6d4','#84cc16','#f97316','#ec4899'
    ];

    function getAvatarColor(name) {
        var code = 0;
        for (var i = 0; i < name.length; i++) code += name.charCodeAt(i);
        return AVATAR_COLORS[code % AVATAR_COLORS.length];
    }

    function getInitials(name) {
        var parts = name.trim().split(/\s+/);
        if (parts.length === 1) return parts[0][0].toUpperCase();
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    var empList       = [];
    var filteredList  = [];
    var focusedIndex  = -1;
    var selectedEmp   = null;
    var pickerOpen    = false;

    function initEmployeePicker() {
        try {
            empList = JSON.parse(document.getElementById('empData').textContent);
        } catch(e) { empList = []; }

        var searchInput  = document.getElementById('empSearchInput');
        var dropdown     = document.getElementById('empDropdown');
        var clearBtn     = document.getElementById('empClearBtn');
        var hiddenInput  = document.getElementById('employeeId');

        // Mở dropdown khi focus/click vào ô tìm kiếm
        searchInput.addEventListener('focus', function() {
            filteredList = empList.slice();
            renderDropdown(searchInput.value.trim());
            openDropdown();
        });

        // Lọc realtime khi gõ
        searchInput.addEventListener('input', function() {
            var q = this.value.trim().toLowerCase();
            filteredList = empList.filter(function(e) {
                return e.name.toLowerCase().includes(q) || String(e.id).includes(q);
            });
            focusedIndex = -1;
            renderDropdown(this.value.trim());
            openDropdown();
            clearBtn.classList.toggle('visible', this.value.length > 0);
        });

        // Keyboard navigation
        searchInput.addEventListener('keydown', function(e) {
            if (!pickerOpen) return;
            var items = dropdown.querySelectorAll('.emp-item');
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                focusedIndex = Math.min(focusedIndex + 1, items.length - 1);
                updateFocus(items);
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                focusedIndex = Math.max(focusedIndex - 1, 0);
                updateFocus(items);
            } else if (e.key === 'Enter') {
                e.preventDefault();
                if (focusedIndex >= 0 && focusedIndex < filteredList.length) {
                    selectEmployee(filteredList[focusedIndex]);
                }
            } else if (e.key === 'Escape') {
                closeDropdown();
                searchInput.blur();
            }
        });

        // Nút xóa lựa chọn
        clearBtn.addEventListener('click', function() {
            clearSelection();
            searchInput.focus();
        });

        // Đóng dropdown khi click ngoài
        document.addEventListener('click', function(e) {
            if (!document.getElementById('empPicker').contains(e.target)) {
                closeDropdown();
            }
        });
    }

    function renderDropdown(query) {
        var dropdown = document.getElementById('empDropdown');
        if (filteredList.length === 0) {
            dropdown.innerHTML = '<div class="emp-no-result"><i class="fas fa-search" style="margin-right:6px;opacity:.4;"></i>Không tìm thấy nhân viên phù hợp</div>';
            return;
        }
        var html = '';
        filteredList.forEach(function(emp, idx) {
            var color    = getAvatarColor(emp.name);
            var initials = getInitials(emp.name);
            var highlight = query ? highlightMatch(emp.name, query) : emp.name;
            html += '<div class="emp-item" data-idx="' + idx + '" role="option">'
                  +   '<div class="emp-avatar" style="background:' + color + '">' + initials + '</div>'
                  +   '<div class="emp-info">'
                  +     '<div class="emp-name">' + highlight + '</div>'
                  +     '<div class="emp-meta"><i class="fas fa-building" style="margin-right:4px;opacity:.6;"></i>' + escHtml(emp.dept) + ' &nbsp;·&nbsp; <i class="fas fa-briefcase" style="margin-right:4px;opacity:.6;"></i>' + escHtml(emp.pos) + '</div>'
                  +   '</div>'
                  +   '<span class="emp-id-badge">#' + emp.id + '</span>'
                  + '</div>';
        });
        dropdown.innerHTML = html;

        // Gắn sự kiện click cho từng item
        dropdown.querySelectorAll('.emp-item').forEach(function(item) {
            item.addEventListener('mousedown', function(e) {
                e.preventDefault(); // ngăn input blur trước khi click xử lý
                var idx = parseInt(this.getAttribute('data-idx'));
                selectEmployee(filteredList[idx]);
            });
            item.addEventListener('mouseover', function() {
                focusedIndex = parseInt(this.getAttribute('data-idx'));
                updateFocus(dropdown.querySelectorAll('.emp-item'));
            });
        });
    }

    function highlightMatch(text, query) {
        var safe = escHtml(text);
        var safeQ = query.replace(/[.*+?^$\{\}()|[\]\\]/g, '\\$&');
        return safe.replace(new RegExp('(' + safeQ + ')', 'gi'), '<mark style="background:rgba(99,102,241,0.18);color:inherit;border-radius:2px;padding:0 1px;">$1</mark>');
    }

    function escHtml(str) {
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function updateFocus(items) {
        items.forEach(function(item, i) {
            item.classList.toggle('focused', i === focusedIndex);
        });
        if (focusedIndex >= 0 && items[focusedIndex]) {
            items[focusedIndex].scrollIntoView({ block: 'nearest' });
        }
    }

    function selectEmployee(emp) {
        selectedEmp = emp;
        document.getElementById('employeeId').value = emp.id;
        document.getElementById('empSearchInput').value = emp.name + ' (#' + emp.id + ')';
        document.getElementById('empSearchInput').classList.add('has-value');
        document.getElementById('empClearBtn').classList.add('visible');
        closeDropdown();
        showSelectedCard(emp);
        currentEmpRoleId = emp.roleId;
        // [NEW] Pre-fill lương và phụ cấp của nhân viên được chọn
        prefillContractData(emp.id);
    }

    function showSelectedCard(emp) {
        var card    = document.getElementById('empSelectedCard');
        var avatar  = document.getElementById('empSelectedAvatar');
        var name    = document.getElementById('empSelectedName');
        var tags    = document.getElementById('empSelectedTags');
        var color   = getAvatarColor(emp.name);
        var initials = getInitials(emp.name);

        avatar.style.background = color;
        avatar.textContent = initials;
        name.textContent = emp.name;
        tags.innerHTML =
            '<span class="emp-tag emp-tag-id"><i class="fas fa-id-badge"></i>#' + emp.id + '</span>'
          + '<span class="emp-tag emp-tag-dept"><i class="fas fa-building"></i>' + escHtml(emp.dept) + '</span>'
          + '<span class="emp-tag emp-tag-pos"><i class="fas fa-briefcase"></i>' + escHtml(emp.pos) + '</span>';

        card.classList.add('show');
    }

    function clearSelection() {
        selectedEmp = null;
        currentEmpRoleId = null;
        document.getElementById('employeeId').value = '';
        document.getElementById('empSearchInput').value = '';
        document.getElementById('empSearchInput').classList.remove('has-value');
        document.getElementById('empClearBtn').classList.remove('visible');
        document.getElementById('empSelectedCard').classList.remove('show');
        filteredList = empList.slice();
        focusedIndex = -1;
        renderDropdown('');
        // [NEW] Xóa pre-fill lương và bỏ tick phụ cấp
        var salaryInput = document.getElementById('newBaseSalary');
        if (salaryInput) salaryInput.value = '';
        document.querySelectorAll('input[name="allowanceIds"]').forEach(function(cb){ cb.checked = false; });
    }

    function openDropdown() {
        document.getElementById('empDropdown').classList.add('open');
        pickerOpen = true;
    }

    function closeDropdown() {
        document.getElementById('empDropdown').classList.remove('open');
        pickerOpen = false;
        focusedIndex = -1;
    }

    // Biến lưu roleId của nhân viên đang được chọn (dùng bởi updateNewRoles)
    var currentEmpRoleId = null;
    // [NEW] JSON map lương + phụ cấp của từng nhân viên
    var empSalaryMap = {};
    try { empSalaryMap = JSON.parse(document.getElementById('empSalaryData').textContent); } catch(e) {}

    /**
     * [NEW] Pre-fill lương cơ bản (raw value) và tick các phụ cấp hiện tại khi chọn nhân viên.
     */
    function prefillContractData(empId) {
        var data = empSalaryMap[String(empId)];
        // -- Pre-fill lương (số trơn, không format dấu chấm để tương thích Servlet BigDecimal parser) --
        var salaryInput = document.getElementById('newBaseSalary');
        if (salaryInput) {
            if (data && data.salary != null) {
                salaryInput.value = data.salary;
            } else {
                salaryInput.value = '';
            }
        }
        // -- Pre-check phụ cấp --
        var activeIds = (data && data.allowanceIds) ? data.allowanceIds : [];
        document.querySelectorAll('input[name="allowanceIds"]').forEach(function(cb) {
            cb.checked = activeIds.indexOf(Number(cb.value)) !== -1;
        });
    }




    function updateNewPositions() {
        var deptSelect = document.getElementById("newDepartmentId");
        var posSelect = document.getElementById("newPositionId");
        var roleSelect = document.getElementById("newRoleId");
        var selectedDept = deptSelect.value;

        if (!selectedDept) {
            posSelect.innerHTML = '<option value="">-- Chọn chức vụ mới --</option>';
            posSelect.disabled = true;
            roleSelect.innerHTML = '<option value="">-- Chọn quyền hạn mới --</option>';
            roleSelect.disabled = true;
            return;
        }

        posSelect.disabled = false;
        var validPosIds = deptPositions[selectedDept] || [];

        // Clear existing options
        posSelect.innerHTML = '';

        // Add placeholder option
        var placeholder = document.createElement("option");
        placeholder.value = "";
        placeholder.text = "-- Chọn chức vụ mới --";
        posSelect.appendChild(placeholder);

        // Add valid options
        originalPositions.forEach(function(opt) {
            if (opt.value === "") return;
            var posId = parseInt(opt.value);
            if (validPosIds.includes(posId)) {
                var newOpt = document.createElement("option");
                newOpt.value = opt.value;
                newOpt.text = opt.text;
                posSelect.appendChild(newOpt);
            }
        });

        // Clear and disable new role select until position is chosen
        roleSelect.innerHTML = '<option value="">-- Chọn quyền hạn mới --</option>';
        roleSelect.disabled = true;
    }

    function updateNewRoles() {
        var deptSelect = document.getElementById("newDepartmentId");
        var posSelect = document.getElementById("newPositionId");
        var roleSelect = document.getElementById("newRoleId");
        
        var selectedDept = parseInt(deptSelect.value);
        var selectedPos = parseInt(posSelect.value);

        if (!selectedDept || !selectedPos) {
            roleSelect.innerHTML = '<option value="">-- Chọn quyền hạn mới --</option>';
            roleSelect.disabled = true;
            return;
        }

        roleSelect.disabled = false;

        // Establish the roles we want to make available based on selectedDept & selectedPos
        // We block Admin (1), HR Manager (2), Factory Manager (3), Director (4), Department Manager (6)
        let validRoleIds = [];

        if (selectedPos === 9 || selectedPos === 5) { // Công nhân or Tổ trưởng
            validRoleIds = [7]; // Employee
        } else if (selectedPos === 6) { // Kế toán trưởng
            validRoleIds = [8]; // Accountant
        } else if (selectedPos === 7 || selectedPos === 8) { // Chuyên viên or Nhân viên
            if (selectedDept === 2) { // Nhân sự
                validRoleIds = [5]; // HR Staff
            } else if (selectedDept === 3) { // Kế toán
                validRoleIds = [8]; // Accountant
            } else {
                validRoleIds = [7]; // Employee
            }
        } else if (selectedPos === 3) { // Phó phòng
            validRoleIds = [7]; // Employee
        }

        // Rebuild role options
        roleSelect.innerHTML = '';

        // Add placeholder option
        var placeholder = document.createElement("option");
        placeholder.value = "";
        placeholder.text = "-- Chọn quyền hạn mới --";
        roleSelect.appendChild(placeholder);

        originalRoles.forEach(function(opt) {
            if (opt.value === "") return;
            var roleId = parseInt(opt.value);
            if (validRoleIds.includes(roleId)) {
                var newOpt = document.createElement("option");
                newOpt.value = opt.value;
                newOpt.text = opt.text;
                roleSelect.appendChild(newOpt);
            }
        });

        // Auto select if only one valid option
        if (validRoleIds.length === 1) {
            roleSelect.value = validRoleIds[0];
        }
    }

    // [REMOVED] updateSalarySection() đã bị xóa — không còn ngạch lương trong form điều chuyển.
</script>

<jsp:include page="../footer.jsp" />

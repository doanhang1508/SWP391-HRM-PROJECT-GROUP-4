<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
                    
                    <!-- EMPLOYEE SELECT -->
                    <div class="form-group">
                        <label class="form-label" for="employeeSelect">Chọn nhân viên điều chuyển *</label>
                        <select id="employeeSelect" name="employeeId" class="form-control" onchange="updateEmployeeDetails()" required>
                            <option value="">-- Chọn nhân viên --</option>
                            <c:forEach items="${employees}" var="emp">
                                <c:set var="empDeptName" value="Chưa phân phòng" />
                                <c:forEach items="${departments}" var="d">
                                    <c:if test="${d.departmentId == emp.departmentId}">
                                        <c:set var="empDeptName" value="${d.departmentName}" />
                                    </c:if>
                                </c:forEach>
                                
                                <c:set var="empPosName" value="Chưa phân chức vụ" />
                                <c:forEach items="${positions}" var="p">
                                    <c:if test="${p.positionId == emp.positionId}">
                                        <c:set var="empPosName" value="${p.positionName}" />
                                    </c:if>
                                </c:forEach>

                                <c:set var="empRoleName" value="Nhân viên" />
                                <c:forEach items="${roles}" var="r">
                                    <c:if test="${r.roleId == emp.roleId}">
                                        <c:set var="empRoleName" value="${r.roleName}" />
                                    </c:if>
                                </c:forEach>
                                <option value="${emp.userId}" data-dept="${empDeptName}" data-pos="${empPosName}" data-role-id="${emp.roleId}" data-role="${empRoleName}">${emp.fullName} (#${emp.userId})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- CURRENT DEPT, POSITION & ROLE (READONLY) -->
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label">Phòng ban hiện tại</label>
                                <input type="text" id="currentDeptInput" class="form-control" readonly placeholder="Chưa chọn">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label">Chức vụ hiện tại</label>
                                <input type="text" id="currentPosInput" class="form-control" readonly placeholder="Chưa chọn">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label">Quyền hạn hiện tại (Role)</label>
                                <input type="text" id="currentRoleInput" class="form-control" readonly placeholder="Chưa chọn">
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
                                        <option value="${p.positionId}">${p.positionName}</option>
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

                    <!-- EFFECTIVE DATE -->
                    <div class="form-group">
                        <label class="form-label" for="effectiveDate">Ngày có hiệu lực *</label>
                        <input type="date" id="effectiveDate" name="effectiveDate" class="form-control" required>
                    </div>

                    <!-- REASON -->
                    <div class="form-group">
                        <label class="form-label" for="reason">Lý do điều chuyển *</label>
                        <textarea id="reason" name="reason" class="form-control" placeholder="Mô tả lý do điều chuyển nhân sự chi tiết..." required></textarea>
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
        1: [1, 2, 3, 7, 8],   // Hành chính: Giám đốc, Trưởng phòng, Phó phòng, Chuyên viên, Nhân viên
        2: [2, 3, 7, 8],      // Nhân sự: Trưởng phòng, Phó phòng, Chuyên viên, Nhân viên
        3: [2, 3, 6, 7, 8],   // Kế toán: Trưởng phòng, Phó phòng, Kế toán trưởng, Chuyên viên, Nhân viên
        4: [2, 3, 7, 8],      // Kinh doanh: Trưởng phòng, Phó phòng, Chuyên viên, Nhân viên
        5: [4, 5, 9]          // Xưởng sản xuất: Quản đốc, Tổ trưởng, Công nhân
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
    });

    function updateEmployeeDetails() {
        var select = document.getElementById("employeeSelect");
        var selectedOption = select.options[select.selectedIndex];
        
        var dept = selectedOption.getAttribute("data-dept") || "";
        var pos = selectedOption.getAttribute("data-pos") || "";
        var role = selectedOption.getAttribute("data-role") || "";
        
        document.getElementById("currentDeptInput").value = dept;
        document.getElementById("currentPosInput").value = pos;
        document.getElementById("currentRoleInput").value = role;
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
</script>

<jsp:include page="../footer.jsp" />

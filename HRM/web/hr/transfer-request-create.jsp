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
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 36px 40px; width: 100%; max-width: 650px; box-shadow: 0 10px 25px rgba(10,37,64,0.05); }
    
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
                <p class="panel-subtitle">Thay đổi phòng ban/chức vụ cho nhân sự trong công ty.</p>

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
                                <option value="${emp.userId}" data-dept="${empDeptName}" data-pos="${empPosName}">${emp.fullName} (#${emp.userId})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- CURRENT DEPT & POSITION (READONLY) -->
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label">Phòng ban hiện tại</label>
                                <input type="text" id="currentDeptInput" class="form-control" readonly placeholder="Chưa chọn nhân viên">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label">Chức vụ hiện tại</label>
                                <input type="text" id="currentPosInput" class="form-control" readonly placeholder="Chưa chọn nhân viên">
                            </div>
                        </div>
                    </div>

                    <!-- NEW DEPT & POSITION -->
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label class="form-label" for="newDepartmentId">Phòng ban mới *</label>
                                <select id="newDepartmentId" name="newDepartmentId" class="form-control" required>
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
                                <select id="newPositionId" name="newPositionId" class="form-control" required>
                                    <option value="">-- Chọn chức vụ mới --</option>
                                    <c:forEach items="${positions}" var="p">
                                        <option value="${p.positionId}">${p.positionName}</option>
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
    function updateEmployeeDetails() {
        var select = document.getElementById("employeeSelect");
        var selectedOption = select.options[select.selectedIndex];
        
        var dept = selectedOption.getAttribute("data-dept") || "";
        var pos = selectedOption.getAttribute("data-pos") || "";
        
        document.getElementById("currentDeptInput").value = dept;
        document.getElementById("currentPosInput").value = pos;
    }
</script>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Thủ tục Nghỉ việc" scope="request" />
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
        --danger:  #e11d48;
        --danger-light: #fff1f2;
        --success: #10b981;
        --success-light: #d1fae5;
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
    .alert-success { background: var(--success-light); border: 1px solid #a7f3d0; color: #065f46; }
    .alert-danger { background: var(--danger-light); border: 1px solid #fecdd3; color: #9f1239; }

    /* PANEL */
    .panel-container { display: flex; justify-content: center; align-items: flex-start; margin-top: 20px; }
    .panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 36px 40px; width: 100%; max-width: 600px; box-shadow: 0 10px 25px rgba(10,37,64,0.05); }
    
    .panel-icon-wrap { width: 56px; height: 56px; background: var(--danger-light); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; color: var(--danger); margin: 0 auto 20px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.3rem; font-weight: 800; color: var(--navy); margin: 0 0 8px; text-align: center; }
    .panel-subtitle { font-size: 0.85rem; color: var(--muted); text-align: center; margin-bottom: 30px; }

    /* FORM */
    .form-group { margin-bottom: 20px; }
    .form-label { display: block; font-size: .85rem; font-weight: 600; color: var(--navy); margin-bottom: 8px; }
    .form-control { width: 100%; padding: 12px 14px; border: 1px solid var(--border); border-radius: 10px; font-size: .9rem; font-family: 'Inter', sans-serif; outline: none; transition: all .2s; background: #f8fafc; color: var(--text); }
    .form-control:focus { border-color: var(--danger); box-shadow: 0 0 0 3px rgba(225, 29, 72, 0.1); background: #ffffff; }
    textarea.form-control { resize: vertical; min-height: 100px; }
    
    /* SUBMIT BTN */
    .btn-submit { background: var(--danger); color: #fff; border: none; padding: 14px 20px; border-radius: 10px; font-weight: 700; font-size: .95rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; transition: all .2s; font-family: 'Inter', sans-serif; width: 100%; margin-top: 10px; box-shadow: 0 4px 12px rgba(225, 29, 72, 0.2); }
    .btn-submit:hover { background: #be123c; transform: translateY(-2px); box-shadow: 0 6px 15px rgba(225, 29, 72, 0.3); }

    /* WARNING BOX */
    .warning-box { background: #fffbeb; border: 1px solid #fef08a; padding: 16px; border-radius: 10px; margin-bottom: 24px; display: flex; gap: 12px; }
    .warning-box i { color: #d97706; font-size: 1.2rem; margin-top: 2px; }
    .warning-box p { margin: 0; font-size: 0.85rem; color: #92400e; line-height: 1.5; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .panel { padding: 24px; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="termination" />
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
                    <span>Nghỉ việc</span>
                </div>
                <h1><i class="fas fa-user-minus" style="color:var(--danger);margin-right:10px;font-size:1.3rem;"></i>Thủ Tục Nghỉ Việc</h1>
            </div>
        </div>

        <c:if test="${not empty message}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle" style="font-size:1.2rem;"></i>
                ${message}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle" style="font-size:1.2rem;"></i>
                ${error}
            </div>
        </c:if>

        <div class="panel-container">
            <div class="panel">
                <div class="panel-icon-wrap">
                    <i class="fas fa-user-slash"></i>
                </div>
                <h3 class="panel-title">Hồ Sơ Nghỉ Việc</h3>
                <p class="panel-subtitle">Điền thông tin để vô hiệu hóa tài khoản và chấm dứt hợp đồng lao động.</p>

                <div class="warning-box">
                    <i class="fas fa-exclamation-circle"></i>
                    <div>
                        <strong>Lưu ý quan trọng:</strong> Hành động này sẽ khóa tài khoản hệ thống của nhân viên và ngừng tính lương kể từ ngày được chọn. Hồ sơ nhân sự vẫn được lưu trữ nguyên vẹn để tra cứu sau này.
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/hr/terminate-employee" method="post" onsubmit="return confirm('Hành động này không thể hoàn tác. Xác nhận vô hiệu hóa nhân viên này?');">
                    
                    <div class="form-group">
                        <label for="userId" class="form-label">ID Nhân viên <span style="color:var(--danger);">*</span></label>
                        <div style="position: relative;">
                            <i class="fas fa-id-badge" style="position: absolute; left: 14px; top: 14px; color: var(--muted);"></i>
                            <input type="number" class="form-control" id="userId" name="userId" placeholder="Nhập ID nhân sự" required style="padding-left: 40px;">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="terminationDate" class="form-label">Ngày hiệu lực nghỉ việc <span style="color:var(--danger);">*</span></label>
                        <input type="date" class="form-control" id="terminationDate" name="terminationDate" required>
                    </div>

                    <div class="form-group">
                        <label for="reason" class="form-label">Lý do nghỉ việc <span style="color:var(--danger);">*</span></label>
                        <textarea class="form-control" id="reason" name="reason" placeholder="Ví dụ: Hết hạn hợp đồng, Chuyển công tác, Bị sa thải do vi phạm..." required></textarea>
                    </div>
                    
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-ban"></i> Thực thi Nghỉ việc
                    </button>
                </form>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../footer.jsp" />

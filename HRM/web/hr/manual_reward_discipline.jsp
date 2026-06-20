<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Thưởng Phạt Thủ Công" scope="request" />
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
        --warning: #f59e0b;
        --warning-light: #fef3c7;
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
    
    .panel-icon-wrap { width: 56px; height: 56px; background: var(--warning-light); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; color: var(--warning); margin: 0 auto 20px; }
    .panel-title  { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.3rem; font-weight: 800; color: var(--navy); margin: 0 0 8px; text-align: center; }
    .panel-subtitle { font-size: 0.85rem; color: var(--muted); text-align: center; margin-bottom: 30px; }

    /* FORM */
    .form-group { margin-bottom: 20px; }
    .form-label { display: block; font-size: .85rem; font-weight: 600; color: var(--navy); margin-bottom: 8px; }
    .form-control { width: 100%; padding: 12px 14px; border: 1px solid var(--border); border-radius: 10px; font-size: .9rem; font-family: 'Inter', sans-serif; outline: none; transition: all .2s; background: #f8fafc; color: var(--text); }
    .form-control:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(43, 108, 176, 0.12); background: #ffffff; }
    select.form-control { cursor: pointer; appearance: none; background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e"); background-repeat: no-repeat; background-position: right 14px center; background-size: 16px; padding-right: 40px; }
    textarea.form-control { resize: vertical; min-height: 80px; }
    
    /* INPUT GROUP (for currency) */
    .input-group { position: relative; display: flex; align-items: stretch; width: 100%; }
    .input-group .form-control { border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: none; }
    .input-group-text { display: flex; align-items: center; padding: 0 16px; font-size: .9rem; font-weight: 600; color: var(--muted); background-color: #f1f5f9; border: 1px solid var(--border); border-left: none; border-top-right-radius: 10px; border-bottom-right-radius: 10px; }
    .input-group:focus-within .input-group-text { border-color: var(--blue); box-shadow: 2px 0 0 0 rgba(43, 108, 176, 0.12) inset; }

    /* SUBMIT BTN */
    .btn-submit { background: var(--blue); color: #fff; border: none; padding: 14px 20px; border-radius: 10px; font-weight: 700; font-size: .95rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; transition: all .2s; font-family: 'Inter', sans-serif; width: 100%; margin-top: 10px; box-shadow: 0 4px 12px rgba(43, 108, 176, 0.2); }
    .btn-submit:hover { background: #1a4971; transform: translateY(-2px); box-shadow: 0 6px 15px rgba(43, 108, 176, 0.3); }

    /* TWO COLUMNS */
    .row { display: flex; gap: 16px; flex-wrap: wrap; }
    .col { flex: 1; min-width: 200px; }

    @media (max-width:900px) {
        .page-main { padding: 20px 16px; }
        .panel { padding: 24px; }
    }
</style>

<div class="page-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="manual-reward" />
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
                    <span>Lương & Phúc lợi</span>
                </div>
                <h1><i class="fas fa-award" style="color:var(--warning);margin-right:10px;font-size:1.3rem;"></i>Nhập Thưởng / Phạt</h1>
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
                    <i class="fas fa-balance-scale"></i>
                </div>
                <h3 class="panel-title">Tạo Bản Ghi Thưởng / Phạt</h3>
                <p class="panel-subtitle">Ghi nhận quyết định khen thưởng hoặc kỷ luật áp dụng trực tiếp vào lương tháng.</p>

                <form action="${pageContext.request.contextPath}/hr/manual-reward-discipline" method="post">
                    
                    <div class="row">
                        <div class="col form-group">
                            <label for="userId" class="form-label">Nhân viên <span style="color:var(--danger);">*</span></label>
                            <div style="position: relative;">
                                <i class="fas fa-id-badge" style="position: absolute; left: 14px; top: 14px; color: var(--muted); z-index: 2;"></i>
                                <select class="form-control" id="userId" name="userId" required style="padding-left: 40px; position: relative; z-index: 1;">
                                    <option value="" disabled selected>-- Chọn nhân viên --</option>
                                    <c:forEach var="u" items="${users}">
                                        <option value="${u.userId}">${u.fullName} (${u.username})</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="col form-group">
                            <label for="appliedDate" class="form-label">Ngày hiệu lực <span style="color:var(--danger);">*</span></label>
                            <input type="date" class="form-control" id="appliedDate" name="appliedDate" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="rewardDisciplineId" class="form-label">Phân loại (Hạng mục) <span style="color:var(--danger);">*</span></label>
                        <select class="form-control" id="rewardDisciplineId" name="rewardDisciplineId" required>
                            <option value="" disabled selected>-- Chọn Hạng mục Thưởng / Phạt --</option>
                            <c:forEach var="type" items="${types}">
                                <option value="${type.id}">${type.name} (${type.type == 'Reward' ? 'Thưởng' : 'Phạt'})</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="amount" class="form-label">Số tiền (Mức phạt/thưởng) <span style="color:var(--danger);">*</span></label>
                        <div class="input-group">
                            <input type="number" step="0.01" class="form-control" id="amount" name="amount" placeholder="Nhập số tiền..." required>
                            <span class="input-group-text">VND</span>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="note" class="form-label">Lý do / Ghi chú <span style="color:var(--danger);">*</span></label>
                        <textarea class="form-control" id="note" name="note" placeholder="Diễn giải chi tiết lý do khen thưởng hoặc vi phạm kỷ luật..." required></textarea>
                    </div>
                    
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Lưu Bản Ghi
                    </button>
                </form>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../footer.jsp" />

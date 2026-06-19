<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Chấm dứt hợp đồng - HRM" scope="request" />
<jsp:include page="../header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<style>
    :root{
        --pri:#6366f1;
        --pri-l:rgba(99,102,241,.1);
        --ok:#10b981;
        --ok-l:rgba(16,185,129,.1);
        --ng:#ef4444;
        --ng-l:rgba(239,68,68,.1);
        --warn:#f59e0b;
        --bg:#f4f7fe;
        --card:#fff;
        --txt:#1e293b;
        --muted:#64748b;
    }
    body{
        background:var(--bg);
        font-family:'Inter',sans-serif
    }
    .dashboard-wrapper{
        display:flex;
        min-height:calc(100vh - 64px)
    }
    .main-content{
        flex:1;
        padding:30px;
        width:calc(100% - 260px)
    }
    .page-header{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:28px;
        flex-wrap:wrap;
        gap:12px
    }
    .page-title{
        font-size:1.5rem;
        font-weight:700;
        color:var(--txt);
        margin:0
    }
    .breadcrumb-c{
        font-size:.85rem;
        color:var(--muted);
        margin:4px 0 0
    }
    .breadcrumb-c a{
        color:var(--pri);
        text-decoration:none
    }
    .admin-panel{
        background:var(--card);
        border-radius:16px;
        padding:24px;
        box-shadow:0 4px 20px rgba(0,0,0,.03);
        border:1px solid rgba(0,0,0,.04);
        margin-bottom:24px;
        max-width: 800px;
        margin-left: auto;
        margin-right: auto;
    }
    .panel-header{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:20px;
        padding-bottom:15px;
        border-bottom:1px solid #f1f5f9;
        flex-wrap:wrap;
        gap:10px
    }
    .panel-title{
        font-size:1.1rem;
        font-weight:700;
        color:var(--txt);
        margin:0;
        display:flex;
        align-items:center;
        gap:10px
    }
    .panel-icon{
        width:40px;
        height:40px;
        border-radius:10px;
        background:var(--ng-l);
        color:var(--ng);
        display:flex;
        align-items:center;
        justify-content:center
    }
    .form-group {
        margin-bottom: 20px;
    }
    .form-label {
        display: block;
        font-size: 0.9rem;
        font-weight: 600;
        color: var(--txt);
        margin-bottom: 8px;
    }
    .form-control {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        font-size: 0.9rem;
        outline: none;
        font-family: 'Inter', sans-serif;
        transition: border-color 0.2s;
    }
    .form-control:focus {
        border-color: var(--pri);
        box-shadow: 0 0 0 3px var(--pri-l);
    }
    .btn-submit {
        background: var(--ng);
        color: #fff;
        border: none;
        padding: 12px 24px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.95rem;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: background 0.2s;
        width: 100%;
        justify-content: center;
    }
    .btn-submit:hover {
        background: #dc2626;
    }
    .alert-c{
        border:none;
        border-radius:10px;
        font-size:.88rem;
        padding:12px 20px;
        max-width: 800px;
        margin: 0 auto 20px auto;
    }
    .a-ok{
        background:#d1fae5;
        color:#065f46
    }
    .a-err{
        background:#fee2e2;
        color:#991b1b
    }
    @media(max-width:768px){
        .main-content{
            width:100%!important;
            padding:20px 16px!important
        }
    }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp"><jsp:param name="activeMenu" value="termination"/></jsp:include>
    <div class="main-content">
        <div class="page-header" style="max-width: 800px; margin-left: auto; margin-right: auto;">
            <div>
                <h1 class="page-title">Quản Lý Nghỉ Việc</h1>
                <p class="breadcrumb-c"><a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a> &gt; <a href="#">Nhân sự</a> &gt; Chấm dứt hợp đồng</p>
            </div>
        </div>

        <c:if test="${not empty message}">
            <div class="alert alert-c a-ok alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="message" scope="session"/>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="alert alert-c a-err alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div class="panel-icon"><i class="fas fa-user-times"></i></div> 
                    Thông Tin Chấm Dứt Hợp Đồng
                </h3>
                <span style="font-size:.85rem;color:var(--muted)"><i class="fas fa-info-circle me-1"></i>Vui lòng điền thông tin chính xác</span>
            </div>
            
            <form action="${pageContext.request.contextPath}/hr/terminate-employee" method="post">
                <div class="form-group">
                    <label class="form-label" for="userId">Mã Nhân Viên (User ID) <span style="color:var(--ng)">*</span></label>
                    <div style="position:relative;">
                        <i class="fas fa-hashtag" style="position:absolute;left:14px;top:50%;transform:translateY(-50%);color:var(--muted);"></i>
                        <input type="number" id="userId" name="userId" class="form-control" placeholder="Nhập ID nhân viên..." style="padding-left: 36px;" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="terminationDate">Ngày Nghỉ Việc (End Date) <span style="color:var(--ng)">*</span></label>
                    <div style="position:relative;">
                        <input type="date" id="terminationDate" name="terminationDate" class="form-control" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="reason">Lý Do Nghỉ Việc <span style="color:var(--ng)">*</span></label>
                    <textarea id="reason" name="reason" class="form-control" rows="4" placeholder="Nhập lý do chi tiết..." required></textarea>
                </div>

                <div class="form-group" style="margin-top: 30px; margin-bottom: 10px;">
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-check"></i> Xác Nhận Nghỉ Việc
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp"/>

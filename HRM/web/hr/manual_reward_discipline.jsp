<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Khen Thưởng / Kỷ Luật Thủ Công" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f8fafc; font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 40px; width: calc(100% - 260px); }
    
    .admin-panel {
        background: #fff; border-radius: 20px; padding: 30px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03); border: 1px solid #e2e8f0;
        max-width: 800px; margin: 0 auto;
    }
    .panel-header { margin-bottom: 24px; border-bottom: 1px solid #e2e8f0; padding-bottom: 16px; }
    .panel-title { font-size: 1.25rem; font-weight: 700; color: #0f172a; margin: 0; display: flex; align-items: center; gap: 12px; }
    .panel-title-icon { width: 32px; height: 32px; background: #eff6ff; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #2563eb; font-size: 0.9rem; }
    
    .form-label { font-weight: 600; color: #334155; }
    .form-control, .form-select { border-radius: 8px; padding: 10px 14px; border: 1px solid #cbd5e1; }
    .form-control:focus, .form-select:focus { border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
    
    .btn-submit {
        background: #2563eb; color: #fff; border: none; border-radius: 8px;
        padding: 10px 24px; font-weight: 600; transition: all 0.2s;
    }
    .btn-submit:hover { background: #1d4ed8; transform: translateY(-1px); }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="manual-reward" />
    </jsp:include>

    <div class="main-content">
        <div style="background: linear-gradient(135deg, #eff6ff, #f8fafc); border: 1px solid #e2e8f0; border-radius: 16px; padding: 24px; margin-bottom: 24px;">
            <h1 style="font-size: 1.5rem; font-weight: 800; color: #1e293b; margin-bottom: 8px;">Nhập Khen Thưởng / Kỷ Luật</h1>
            <p style="color: #64748b; margin: 0; font-size: 0.95rem;">
                <i class="fas fa-info-circle me-1"></i> Ghi nhận trực tiếp thông tin khen thưởng hoặc kỷ luật cho nhân viên.
            </p>
        </div>

        <div class="admin-panel">
            <div class="panel-header">
                <h2 class="panel-title">
                    <div class="panel-title-icon"><i class="fas fa-award"></i></div>
                    Thông tin Ghi Nhận
                </h2>
            </div>

            <c:if test="${not empty message}">
                <div class="alert alert-success d-flex align-items-center" role="alert">
                    <i class="fas fa-check-circle me-2"></i> ${message}
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger d-flex align-items-center" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i> ${error}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/hr/manual-reward-discipline" method="post">
                <div class="row g-3">
                    <div class="col-md-6 mb-3">
                        <label for="userId" class="form-label">Nhân Viên <span class="text-danger">*</span></label>
                        <select class="form-select" id="userId" name="userId" required>
                            <option value="">-- Chọn nhân viên --</option>
                            <c:forEach var="u" items="${users}">
                                <option value="${u.userId}">${u.fullName} (${u.username})</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label for="rewardDisciplineId" class="form-label">Phân Loại <span class="text-danger">*</span></label>
                        <select class="form-select" id="rewardDisciplineId" name="rewardDisciplineId" required>
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach var="type" items="${types}">
                                <option value="${type.id}">${type.name} - ${type.type == 'Reward' ? 'Thưởng' : 'Kỷ luật'}</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label for="amount" class="form-label">Số Tiền (VNĐ) <span class="text-danger">*</span></label>
                        <input type="number" step="0.01" class="form-control" id="amount" name="amount" required placeholder="Ví dụ: 500000">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="appliedDate" class="form-label">Ngày Áp Dụng <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="appliedDate" name="appliedDate" required>
                    </div>
                    
                    <div class="col-12 mb-4">
                        <label for="note" class="form-label">Ghi Chú / Lý Do <span class="text-danger">*</span></label>
                        <textarea class="form-control" id="note" name="note" rows="3" required placeholder="Nhập lý do khen thưởng / kỷ luật chi tiết"></textarea>
                    </div>
                    
                    <div class="col-12 text-end">
                        <button type="reset" class="btn btn-light me-2">Nhập Lại</button>
                        <button type="submit" class="btn btn-submit"><i class="fas fa-save me-1"></i> Lưu Thông Tin</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />

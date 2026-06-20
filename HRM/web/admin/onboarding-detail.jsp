<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chi Tiết Yêu Cầu Onboarding" scope="request" />
<jsp:include page="../header.jsp" />
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
  --bg: #f1f5f9;
  --surface: #ffffff;
  --primary: #4f46e5;
  --primary-hover: #4338ca;
  --text-main: #0f172a;
  --text-muted: #64748b;
  --border: #e2e8f0;
  --red: #ef4444;
  --red-hover: #dc2626;
  --green: #10b981;
  --green-hover: #059669;
}
body { background: var(--bg); font-family: 'Inter', Arial, sans-serif; color: var(--text-main); }
.ob-wrapper { display: flex; min-height: calc(100vh - 64px); }
.ob-main { flex: 1; padding: 50px 30px; display: flex; flex-direction: column; align-items: center; }

/* Nút quay lại */
.back-link {
  width: 100%; max-width: 850px; margin-bottom: 24px;
  display: flex; align-items: center; gap: 8px;
  font-weight: 600; color: var(--primary); text-decoration: none;
  transition: all 0.2s;
}
.back-link:hover { color: var(--primary-hover); transform: translateX(-4px); }

/* Card tổng */
.detail-container {
  background: var(--surface);
  border-radius: 24px;
  width: 100%;
  max-width: 850px;
  box-shadow: 0 20px 40px -10px rgba(0,0,0,0.1), 0 1px 3px rgba(0,0,0,0.05);
  overflow: hidden;
}

/* Header gradient */
.detail-header {
  background: linear-gradient(135deg, #312e81, #4f46e5);
  padding: 40px 50px;
  color: #fff;
  position: relative;
  display: flex;
  align-items: center;
  gap: 24px;
}
.header-avatar {
  width: 80px; height: 80px;
  border-radius: 20px;
  background: rgba(255,255,255,0.15);
  display: flex; align-items: center; justify-content: center;
  font-family: 'Be Vietnam Pro', sans-serif; font-size: 2.2rem; font-weight: 800;
  box-shadow: 0 8px 16px rgba(0,0,0,0.2);
}
.header-info h2 { margin: 0 0 8px; font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.8rem; font-weight: 800; letter-spacing: -0.5px; }
.header-info p { margin: 0; color: rgba(255,255,255,0.8); font-size: 1rem; display: flex; align-items: center; gap: 8px; }

/* Badge trạng thái */
.status-badge {
  position: absolute; top: 40px; right: 50px;
  padding: 8px 16px; border-radius: 30px; font-weight: 700; font-size: 0.85rem;
  display: flex; align-items: center; gap: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.badge-pending { background: rgba(255,255,255,0.2); color: #fff; backdrop-filter: blur(10px); }
.badge-approved { background: #10b981; color: #fff; }
.badge-rejected { background: #ef4444; color: #fff; }
.badge-draft { background: #64748b; color: #fff; }

/* Body card */
.detail-body { padding: 40px 50px; }

/* Chia cột hoặc danh sách thông tin */
.section-title {
  font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.25rem; font-weight: 800; color: var(--text-main);
  margin-bottom: 24px; display: flex; align-items: center; gap: 10px;
  padding-bottom: 12px; border-bottom: 2px solid var(--border);
}
.section-title i { color: var(--primary); }

.info-grid-2 {
  display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 40px;
}

.info-list { display: flex; flex-direction: column; gap: 16px; }
.info-item { display: flex; flex-direction: column; gap: 4px; }
.info-label { font-size: 0.8rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; }
.info-value { font-size: 1.05rem; font-weight: 600; color: var(--text-main); line-height: 1.5; }
.info-value.empty { color: #94a3b8; font-style: italic; font-weight: 400; }

/* Ghi chú hệ thống */
.system-note {
  background: #f8fafc; border: 1px solid var(--border); border-radius: 12px; padding: 20px;
  margin-bottom: 40px; display: flex; gap: 16px; align-items: flex-start;
}
.system-note i { font-size: 1.5rem; color: #3b82f6; margin-top: 2px; }
.system-note-content { font-size: 0.95rem; color: #475569; line-height: 1.6; }

/* Form Reject */
.reject-box { margin-bottom: 30px; }
.reject-title { font-weight: 700; font-size: 1rem; margin-bottom: 12px; color: var(--text-main); }
.reject-textarea {
  width: 100%; border: 2px solid var(--border); border-radius: 12px; padding: 16px;
  min-height: 120px; font-family: inherit; font-size: 0.95rem; resize: vertical;
  transition: all 0.2s; background: #f8fafc; outline: none;
}
.reject-textarea:focus { border-color: var(--primary); background: #fff; box-shadow: 0 0 0 4px rgba(79,70,229,0.1); }

/* Lịch sử từ chối */
.rejected-history {
  background: #fef2f2; border: 1px solid #fecaca; border-radius: 12px; padding: 20px; margin-bottom: 30px;
}

/* Buttons */
.button-group { display: flex; gap: 20px; border-top: 1px solid var(--border); padding-top: 30px; }
.btn-action {
  flex: 1; padding: 16px; border-radius: 12px; border: none;
  font-size: 1.1rem; font-weight: 700; color: #fff; cursor: pointer;
  display: flex; align-items: center; justify-content: center; gap: 10px;
  transition: all 0.2s;
}
.btn-action:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0,0,0,0.15); }
.btn-red { background: var(--red); }
.btn-red:hover { background: var(--red-hover); box-shadow: 0 8px 20px rgba(239,68,68,0.3); }
.btn-green { background: var(--green); }
.btn-green:hover { background: var(--green-hover); box-shadow: 0 8px 20px rgba(16,185,129,0.3); }

/* Alert */
.alert { width: 100%; max-width: 850px; padding: 16px 20px; border-radius: 12px; font-size: 0.95rem; font-weight: 600; margin-bottom: 24px; background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; display: flex; align-items: center; gap: 10px;}
</style>

<div class="ob-wrapper">
  <jsp:include page="../shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="onboarding-admin" />
  </jsp:include>

  <div class="ob-main">
    <a href="${pageContext.request.contextPath}/admin/onboarding/list" class="back-link">
      <i class="fas fa-arrow-left"></i> Quay lại danh sách yêu cầu
    </a>
    
    <c:if test="${not empty param.error}">
      <div class="alert">
        <i class="fas fa-exclamation-circle"></i>
        <c:choose>
          <c:when test="${param.error=='reason_required'}">Vui lòng nhập lý do từ chối để nhân sự biết cách chỉnh sửa.</c:when>
          <c:when test="${param.error=='not_pending'}">Yêu cầu này không còn ở trạng thái Chờ duyệt.</c:when>
          <c:when test="${param.error=='approve_failed'}">Tạo tài khoản thất bại. Có thể lỗi hệ thống hoặc email đã được sử dụng.</c:when>
          <c:otherwise>${param.error}</c:otherwise>
        </c:choose>
      </div>
    </c:if>

    <div class="detail-container">
      
      <!-- HEADER -->
      <div class="detail-header">
        <div class="header-avatar"><c:out value="${request.initial}"/></div>
        <div class="header-info">
          <h2>Chi Tiết Yêu Cầu Tạo Tài Khoản</h2>
          <p><i class="fas fa-user-circle"></i> Ứng viên: <strong><c:out value="${request.fullName}"/></strong></p>
        </div>
        
        <c:choose>
          <c:when test="${request.status=='PENDING'}">  <div class="status-badge badge-pending"><i class="fas fa-clock"></i> Chờ phê duyệt</div></c:when>
          <c:when test="${request.status=='APPROVED'}"> <div class="status-badge badge-approved"><i class="fas fa-check-circle"></i> Đã phê duyệt</div></c:when>
          <c:when test="${request.status=='REJECTED'}"> <div class="status-badge badge-rejected"><i class="fas fa-times-circle"></i> Bị từ chối</div></c:when>
          <c:when test="${request.status=='DRAFT'}">    <div class="status-badge badge-draft"><i class="fas fa-pencil-alt"></i> Đang lưu nháp</div></c:when>
        </c:choose>
      </div>

      <!-- BODY -->
      <div class="detail-body">
        
        <div class="info-grid-2">
          <!-- CỘT 1: THÔNG TIN CÁ NHÂN -->
          <div>
            <h3 class="section-title"><i class="fas fa-id-card"></i> Thông tin cá nhân</h3>
            <div class="info-list">
              <div class="info-item">
                <div class="info-label">Số CCCD / CMND</div>
                <div class="info-value ${empty request.cccdNumber ? 'empty' : ''}">
                  <c:out value="${not empty request.cccdNumber ? request.cccdNumber : 'Chưa cập nhật'}"/>
                </div>
              </div>
              <div class="info-item">
                <div class="info-label">Ngày sinh</div>
                <div class="info-value ${empty request.dateOfBirth ? 'empty' : ''}">
                  <c:choose>
                    <c:when test="${not empty request.dateOfBirth}"><fmt:formatDate value="${request.dateOfBirth}" pattern="dd/MM/yyyy"/></c:when>
                    <c:otherwise>Chưa cập nhật</c:otherwise>
                  </c:choose>
                </div>
              </div>
              <div class="info-item">
                <div class="info-label">Giới tính</div>
                <div class="info-value ${empty request.genderLabel ? 'empty' : ''}">
                  <c:out value="${not empty request.genderLabel ? request.genderLabel : 'Chưa cập nhật'}"/>
                </div>
              </div>
              <div class="info-item">
                <div class="info-label">Địa chỉ liên hệ</div>
                <div class="info-value ${empty request.address ? 'empty' : ''}">
                  <c:out value="${not empty request.address ? request.address : 'Chưa cập nhật'}"/>
                </div>
              </div>
            </div>
          </div>

          <!-- CỘT 2: THÔNG TIN CÔNG VIỆC & LIÊN HỆ -->
          <div>
            <h3 class="section-title"><i class="fas fa-briefcase"></i> Công việc & Liên hệ</h3>
            <div class="info-list">
              <div class="info-item">
                <div class="info-label">Vị trí công việc</div>
                <div class="info-value ${empty request.positionName ? 'empty' : ''}">
                  <c:out value="${not empty request.positionName ? request.positionName : 'Chưa cập nhật'}"/>
                </div>
              </div>
              <div class="info-item">
                <div class="info-label">Thuộc phòng ban</div>
                <div class="info-value ${empty request.departmentName ? 'empty' : ''}">
                  <c:out value="${not empty request.departmentName ? request.departmentName : 'Chưa cập nhật'}"/>
                </div>
              </div>
              <div class="info-item">
                <div class="info-label">Email cá nhân (Dùng để gửi mật khẩu)</div>
                <div class="info-value">
                  <a href="mailto:${request.email}" style="color:var(--primary);text-decoration:none;">
                    <c:out value="${request.email}"/>
                  </a>
                </div>
              </div>
              <div class="info-item">
                <div class="info-label">Số điện thoại</div>
                <div class="info-value ${empty request.phone ? 'empty' : ''}">
                  <c:out value="${not empty request.phone ? request.phone : 'Chưa cập nhật'}"/>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="system-note">
          <i class="fas fa-info-circle"></i>
          <div class="system-note-content">
            <strong>Ghi chú hệ thống:</strong> Hồ sơ yêu cầu được lập bởi chuyên viên Nhân sự 
            <strong><c:out value="${not empty request.createdByName ? request.createdByName : 'N/A'}"/></strong> 
            vào ngày <strong><fmt:formatDate value="${request.createdAt}" pattern="dd/MM/yyyy 'lúc' HH:mm"/></strong>. 
      
          </div>
        </div>
        
        <c:choose>
          <c:when test="${request.status == 'PENDING'}">
            <form method="post" action="${pageContext.request.contextPath}/admin/onboarding/reject" id="rejectForm">
              <input type="hidden" name="requestId" value="${request.id}">
              <div class="reject-box">
                <div class="reject-title">Nếu phát hiện sai sót, vui lòng nhập lý do từ chối để HR sửa lại:</div>
                <textarea name="rejectReason" id="rejectReason" class="reject-textarea" placeholder="Ví dụ: Thiếu số điện thoại liên hệ, thông tin ngày sinh bị sai lệch so với CCCD..."></textarea>
              </div>
            </form>
          </c:when>
          <c:when test="${request.status == 'REJECTED'}">
            <div class="rejected-history">
              <div class="reject-title" style="color:var(--red);"><i class="fas fa-ban"></i> Lý do từ chối trước đó:</div>
              <div style="color:#7f1d1d; font-size: 1rem; line-height: 1.5;"><c:out value="${request.rejectReason}"/></div>
              <div style="margin-top:10px; font-size:0.85rem; color:#b91c1c; font-weight: 600;">
                Người từ chối: <c:out value="${not empty request.processedByName ? request.processedByName : 'Admin'}"/>
              </div>
            </div>
          </c:when>
        </c:choose>

        <c:if test="${request.status == 'PENDING'}">
          <div class="button-group">
            <button type="button" class="btn-action btn-red" onclick="submitReject()">
              <i class="fas fa-times-circle"></i> Từ chối & Yêu cầu sửa
            </button>
            <form method="post" action="${pageContext.request.contextPath}/admin/onboarding/approve" style="flex:1;">
              <input type="hidden" name="requestId" value="${request.id}">
              <button type="submit" class="btn-action btn-green" style="width:100%;" onclick="return confirm('Bạn chắc chắn muốn tạo tài khoản tự động cho ứng viên này?');">
                <i class="fas fa-user-check"></i> Tạo tài khoản & Gửi Email
              </button>
            </form>
          </div>
        </c:if>

      </div>
    </div>
  </div>
</div>

<script>
function submitReject() {
  const reason = document.getElementById('rejectReason').value.trim();
  if (!reason) {
    alert("Vui lòng nhập lý do từ chối ở khung phía trên.");
    document.getElementById('rejectReason').focus();
    return;
  }
  if (confirm("Bạn chắc chắn muốn từ chối yêu cầu này?")) {
    document.getElementById('rejectForm').submit();
  }
}
</script>

<jsp:include page="../footer.jsp" />

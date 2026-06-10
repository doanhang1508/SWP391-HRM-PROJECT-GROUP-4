<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Yêu Cầu Tuyển Dụng Mới" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
  --navy: #0f172a;
  --blue: #3b82f6;
  --indigo: #6366f1;
  --teal: #14b8a6;
  --emerald: #10b981;
  --accent: #f59e0b;
  --bg-gradient: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  --surface: rgba(255, 255, 255, 0.85);
  --border: rgba(203, 213, 225, 0.6);
  --text: #1e293b;
  --muted: #64748b;
  --success: #10b981;
  --danger: #ef4444;
}
* { box-sizing: border-box; }
body {
  background: var(--bg-gradient);
  background-attachment: fixed;
  font-family: 'Inter', sans-serif;
  color: var(--text);
  position: relative;
}

.ob-wrapper {
  display: flex;
  min-height: calc(100vh - 64px);
  position: relative;
  z-index: 1;
}

/* Decorative background blurs */
.ob-wrapper::before {
  content: '';
  position: absolute;
  top: -100px;
  right: -100px;
  width: 400px;
  height: 400px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(99, 102, 241, 0.15) 0%, rgba(99, 102, 241, 0) 70%);
  z-index: -1;
  pointer-events: none;
}
.ob-wrapper::after {
  content: '';
  position: absolute;
  bottom: -150px;
  left: -50px;
  width: 500px;
  height: 500px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(20, 184, 166, 0.1) 0%, rgba(20, 184, 166, 0) 70%);
  z-index: -1;
  pointer-events: none;
}

.ob-main {
  flex: 1;
  padding: 40px 48px;
  overflow-x: hidden;
  max-width: 960px;
  margin: 0 auto;
}

/* Breadcrumb + Title */
.page-topbar { margin-bottom: 36px; }
.breadcrumb-txt {
  font-size: 0.8rem;
  color: var(--muted);
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  font-weight: 500;
}
.breadcrumb-txt a { color: var(--indigo); text-decoration: none; transition: color 0.2s; }
.breadcrumb-txt a:hover { color: var(--navy); }
.page-title {
  font-family: 'Be Vietnam Pro', sans-serif;
  font-size: 2rem;
  font-weight: 800;
  color: var(--navy);
  letter-spacing: -0.5px;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 12px;
}
.page-title i {
  background: linear-gradient(135deg, var(--teal), var(--indigo));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  font-size: 1.8rem;
}

/* Progress Steps */
.steps-bar {
  display: flex;
  align-items: center;
  gap: 0;
  margin-bottom: 40px;
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(8px);
  padding: 16px 24px;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
}
.step { display: flex; align-items: center; gap: 12px; }
.step-circle {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  font-weight: 800;
  flex-shrink: 0;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}
.step-circle.done {
  background: linear-gradient(135deg, var(--teal), var(--emerald));
  color: #fff;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}
.step-circle.active {
  background: linear-gradient(135deg, var(--indigo), var(--blue));
  color: #fff;
  box-shadow: 0 0 0 6px rgba(99, 102, 241, 0.15);
}
.step-circle.wait { background: #f1f5f9; color: var(--muted); border: 2px solid #e2e8f0; }
.step-label { font-size: 0.85rem; font-weight: 600; color: var(--muted); letter-spacing: 0.2px; }
.step-label.active { color: var(--navy); font-weight: 700; }
.step-divider { flex: 1; height: 3px; background: rgba(203, 213, 225, 0.5); margin: 0 16px; border-radius: 2px; }
.step-divider.done { background: linear-gradient(90deg, var(--emerald), var(--teal)); }

/* Glassmorphism Card */
.form-card {
  background: var(--surface);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 24px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.04), 0 1px 3px rgba(0, 0, 0, 0.02);
  margin-bottom: 32px;
  overflow: hidden;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.form-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 15px 50px rgba(0, 0, 0, 0.06), 0 2px 6px rgba(0, 0, 0, 0.03);
}
.form-card-header {
  padding: 24px 32px;
  border-bottom: 1px solid rgba(203, 213, 225, 0.3);
  display: flex;
  align-items: center;
  gap: 16px;
  background: rgba(255, 255, 255, 0.4);
}
.form-card-icon {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.3rem;
  flex-shrink: 0;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}
.icon-blue { background: linear-gradient(135deg, #e0e7ff, #c7d2fe); color: var(--indigo); }
.icon-teal { background: linear-gradient(135deg, #ccfbf1, #99f6e4); color: var(--teal); }
.form-card-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.15rem; font-weight: 800; color: var(--navy); margin: 0; display: flex; align-items: center; flex-wrap: wrap; gap: 10px; }
.form-card-sub { font-size: 0.85rem; color: var(--muted); margin-top: 4px; font-weight: 500; }
.form-card-body { padding: 32px; }

/* Grid */
.ob-grid { display: grid; gap: 28px; width: 100%; }
.ob-col-2 { grid-template-columns: 1fr 1fr; }

/* Form Fields */
.ob-field { display: flex; flex-direction: column; gap: 8px; width: 100%; }
.ob-field label {
  font-size: 0.88rem;
  font-weight: 700;
  color: var(--navy);
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 2px;
}
.ob-field label .req { color: var(--danger); font-size: 0.9rem; }
.ob-field input, .ob-field select, .ob-field textarea {
  width: 100%;
  padding: 14px 16px;
  border: 1px solid var(--border);
  border-radius: 12px;
  font-size: 0.95rem;
  color: var(--text);
  background: rgba(255, 255, 255, 0.7);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  outline: none;
  font-family: 'Inter', sans-serif;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.01);
}
.ob-field input:focus, .ob-field select:focus, .ob-field textarea:focus {
  border-color: var(--indigo);
  background: #fff;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.1), 0 0 0 3px rgba(99, 102, 241, 0.15);
  transform: translateY(-1px);
}
.ob-field input:hover, .ob-field select:hover, .ob-field textarea:hover {
  background: rgba(255, 255, 255, 0.95);
}
.ob-field input.error, .ob-field select.error { border-color: var(--danger); box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15); }
.ob-field textarea { resize: vertical; min-height: 110px; }

/* Alert */
.alert {
  padding: 16px 20px;
  border-radius: 16px;
  font-size: 0.9rem;
  font-weight: 600;
  margin-bottom: 28px;
  display: flex;
  align-items: center;
  gap: 12px;
  backdrop-filter: blur(8px);
}
.alert-danger { background: rgba(254, 242, 242, 0.9); border: 1px solid #fca5a5; color: #991b1b; box-shadow: 0 4px 12px rgba(239, 68, 68, 0.1); }
.alert-success { background: rgba(240, 253, 244, 0.9); border: 1px solid #86efac; color: #166534; box-shadow: 0 4px 12px rgba(34, 197, 94, 0.1); }
.alert-info { background: rgba(239, 246, 255, 0.9); border: 1px solid #93c5fd; color: #1e40af; }

/* Action Bar */
.action-bar { display: flex; gap: 16px; align-items: center; margin-top: 16px; flex-wrap: wrap; }
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 14px 28px;
  border-radius: 14px;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  border: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  text-decoration: none;
  font-family: 'Be Vietnam Pro', sans-serif;
}
.btn-primary {
  background: linear-gradient(135deg, var(--indigo), var(--blue));
  color: #fff;
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.3);
}
.btn-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 25px rgba(99, 102, 241, 0.4);
}
.btn-teal {
  background: linear-gradient(135deg, var(--teal), var(--emerald));
  color: #fff;
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.3);
}
.btn-teal:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 25px rgba(16, 185, 129, 0.4);
}
.btn-outline {
  background: rgba(255, 255, 255, 0.8);
  border: 1.5px solid var(--border);
  color: var(--navy);
  backdrop-filter: blur(8px);
}
.btn-outline:hover {
  border-color: var(--indigo);
  color: var(--indigo);
  background: #fff;
  transform: translateY(-1px);
}

/* OCR Badge */
.ocr-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.15), rgba(20, 184, 166, 0.2));
  color: #047857;
  padding: 4px 12px;
  border-radius: 30px;
  font-size: 0.75rem;
  font-weight: 800;
  border: 1px solid rgba(16, 185, 129, 0.3);
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.15);
  animation: pulse-glow 2s infinite alternate;
}
@keyframes pulse-glow {
  0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.4); }
  100% { box-shadow: 0 0 0 4px rgba(16, 185, 129, 0); }
}

/* Status badge */
.status-badge { display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 20px; font-size: 0.78rem; font-weight: 700; }
.s-draft { background: #f1f5f9; color: #475569; }
.s-rejected { background: #fef2f2; color: var(--danger); }

@media(max-width: 768px) {
  .ob-main { padding: 24px 20px; }
  .ob-col-2 { grid-template-columns: 1fr; }
  .steps-bar { display: none; }
  .action-bar { flex-direction: column; }
  .btn { width: 100%; }
}
</style>

<div class="ob-wrapper">
  <jsp:include page="../shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="onboarding" />
  </jsp:include>

  <div class="ob-main">

    <!-- TOP BAR -->
    <div class="page-topbar">
      <div class="breadcrumb-txt">
        <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
        <span>/</span>
        <a href="${pageContext.request.contextPath}/hr/onboarding/list">Tiếp nhận nhân viên</a>
        <span>/</span>
        <span>${formData != null && formData.id > 0 ? 'Chỉnh sửa yêu cầu #'.concat(String.valueOf(formData.id)) : 'Tạo yêu cầu mới'}</span>
      </div>
      <h1 class="page-title">
        <i class="fas fa-user-plus" style="color:var(--teal);margin-right:8px;font-size:1.4rem;"></i>
        ${formData != null && formData.id > 0 ? 'Chỉnh Sửa Yêu Cầu' : 'Tạo Yêu Cầu Tuyển Dụng Mới'}
      </h1>
    </div>

    <!-- PROGRESS STEPS -->
    <div class="steps-bar">
      <div class="step">
        <div class="step-circle done"><i class="fas fa-id-card"></i></div>
        <span class="step-label">Thông tin ứng viên</span>
      </div>
      <div class="step-divider done"></div>
      <div class="step">
        <div class="step-circle active">2</div>
        <span class="step-label active">Điền hồ sơ</span>
      </div>
      <div class="step-divider"></div>
      <div class="step">
        <div class="step-circle wait">3</div>
        <span class="step-label">Admin duyệt</span>
      </div>
    </div>

    <!-- ALERT -->
    <c:if test="${not empty error}">
      <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${error}</div>
    </c:if>
    <c:if test="${not empty formData && formData.status == 'REJECTED' && not empty formData.rejectReason}">
      <div class="alert alert-danger">
        <i class="fas fa-ban"></i>
        <div><strong>Yêu cầu bị từ chối:</strong> ${formData.rejectReason} — Hãy chỉnh sửa và gửi lại.</div>
      </div>
    </c:if>
    <c:if test="${not empty param.ocr}">
      <div class="alert alert-success"><i class="fas fa-magic"></i> Đã trích xuất dữ liệu từ CCCD thành công! Kiểm tra và bổ sung thêm thông tin.</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/hr/onboarding/save" method="post" id="onboardingForm" novalidate>
      <input type="hidden" name="id" value="${formData != null ? formData.id : ''}">

      <!-- CARD 1: Thông tin cá nhân -->
      <div class="form-card">
        <div class="form-card-header">
          <div class="form-card-icon icon-blue"><i class="fas fa-user"></i></div>
          <div>
            <div class="form-card-title">Thông tin cá nhân
              <c:if test="${not empty sessionScope.ocr_name}">
                <span class="ocr-badge"><i class="fas fa-magic"></i> Từ OCR CCCD</span>
              </c:if>
            </div>
            <div class="form-card-sub">Thông tin cơ bản của ứng viên</div>
          </div>
        </div>
        <div class="form-card-body">
          <div class="ob-grid ob-col-2">
            <div class="ob-field">
              <label>Họ và tên <span class="req">*</span></label>
              <input type="text" name="fullName" id="fullName" placeholder="Nguyễn Văn An"
                     value="<c:out value='${not empty formData.fullName ? formData.fullName : (not empty sessionScope.ocr_name ? sessionScope.ocr_name : "")}'/>"
                     required>
            </div>
            <div class="ob-field">
              <label>Email <span class="req">*</span></label>
              <input type="email" name="email" id="email" placeholder="email@example.com"
                     value="<c:out value='${formData.email}'/>" required>
            </div>
            <div class="ob-field">
              <label>Số điện thoại</label>
              <input type="tel" name="phone" placeholder="0912 345 678"
                     value="<c:out value='${formData.phone}'/>">
            </div>
            <div class="ob-field">
              <label>Số CCCD / CMND
                <c:if test="${not empty sessionScope.ocr_id}">
                  <span class="ocr-badge"><i class="fas fa-check"></i> OCR</span>
                </c:if>
              </label>
              <input type="text" name="cccdNumber" placeholder="012345678901"
                     value="<c:out value='${not empty formData.cccdNumber ? formData.cccdNumber : (not empty sessionScope.ocr_id ? sessionScope.ocr_id : "")}'/>">
            </div>
            <div class="ob-field">
              <label>Ngày sinh
                <c:if test="${not empty sessionScope.ocr_dob}">
                  <span class="ocr-badge"><i class="fas fa-check"></i> OCR</span>
                </c:if>
              </label>
              <input type="date" name="dateOfBirth"
                     value="<c:out value='${not empty formData.dateOfBirth ? formData.dateOfBirth : (not empty sessionScope.ocr_dob ? sessionScope.ocr_dob : "")}'/>">
            </div>
            <div class="ob-field">
              <label>Giới tính
                <c:if test="${not empty sessionScope.ocr_gender}">
                  <span class="ocr-badge"><i class="fas fa-check"></i> OCR</span>
                </c:if>
              </label>
              <select name="gender">
                <option value="">— Chọn giới tính —</option>
                <option value="1" <c:if test="${formData.gender == 1 || sessionScope.ocr_gender == '1'}">selected</c:if>>Nam</option>
                <option value="0" <c:if test="${(formData.gender == 0 && formData.gender != null) || sessionScope.ocr_gender == '0'}">selected</c:if>>Nữ</option>
              </select>
            </div>
          </div>
          <div class="ob-grid" style="margin-top:24px;">
            <div class="ob-field">
              <label>Địa chỉ
                <c:if test="${not empty sessionScope.ocr_address}">
                  <span class="ocr-badge"><i class="fas fa-check"></i> OCR</span>
                </c:if>
              </label>
              <textarea name="address" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố"><c:out value='${not empty formData.address ? formData.address : (not empty sessionScope.ocr_address ? sessionScope.ocr_address : "")}'/></textarea>
            </div>
          </div>
        </div>
      </div>

      <!-- CARD 2: Vị trí công việc -->
      <div class="form-card">
        <div class="form-card-header">
          <div class="form-card-icon icon-teal"><i class="fas fa-briefcase"></i></div>
          <div>
            <div class="form-card-title">Vị trí công việc dự kiến</div>
            <div class="form-card-sub">Phòng ban và chức vụ sẽ được giao</div>
          </div>
        </div>
        <div class="form-card-body">
          <div class="ob-grid ob-col-2">
            <div class="ob-field">
              <label>Phòng ban</label>
              <select name="departmentId">
                <option value="">— Chọn phòng ban —</option>
                <c:forEach var="dept" items="${departments}">
                  <option value="${dept.departmentId}"
                    <c:if test="${formData.departmentId == dept.departmentId}">selected</c:if>>
                    <c:out value="${dept.departmentName}"/>
                  </option>
                </c:forEach>
              </select>
            </div>
            <div class="ob-field">
              <label>Chức vụ</label>
              <select name="positionId">
                <option value="">— Chọn chức vụ —</option>
                <c:forEach var="pos" items="${positions}">
                  <option value="${pos.positionId}"
                    <c:if test="${formData.positionId == pos.positionId}">selected</c:if>>
                    <c:out value="${pos.positionName}"/>
                  </option>
                </c:forEach>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- ACTION BAR -->
      <div class="action-bar">
        <button type="submit" name="action" value="PENDING" class="btn btn-primary" id="btnSubmit">
          <i class="fas fa-paper-plane"></i> Gửi yêu cầu lên Admin
        </button>
        <button type="submit" name="action" value="DRAFT" class="btn btn-teal" id="btnDraft">
          <i class="fas fa-save"></i> Lưu nháp
        </button>
        <a href="${pageContext.request.contextPath}/hr/onboarding/list" class="btn btn-outline">
          <i class="fas fa-arrow-left"></i> Quay lại
        </a>
      </div>
    </form>
  </div>
</div>

<script>
// Client-side validation cơ bản
document.getElementById('onboardingForm').addEventListener('submit', function(e) {
  const fullName = document.getElementById('fullName').value.trim();
  const email    = document.getElementById('email').value.trim();
  const action   = e.submitter && e.submitter.value;

  if (!fullName) {
    e.preventDefault();
    document.getElementById('fullName').classList.add('error');
    document.getElementById('fullName').focus();
    return;
  }
  if (!email && action !== 'DRAFT') {
    e.preventDefault();
    document.getElementById('email').classList.add('error');
    document.getElementById('email').focus();
    return;
  }

  // Bổ sung hidden input mang giá trị action vì khi disable button, trình duyệt sẽ không gửi value của button đó lên server
  const hiddenAction = document.createElement('input');
  hiddenAction.type = 'hidden';
  hiddenAction.name = 'action';
  hiddenAction.value = action;
  this.appendChild(hiddenAction);

  // Disable buttons để tránh double submit
  document.getElementById('btnSubmit').disabled = true;
  document.getElementById('btnDraft').disabled   = true;
});

document.querySelectorAll('.ob-field input, .ob-field select').forEach(function(el) {
  el.addEventListener('input', function() { this.classList.remove('error'); });
});
</script>

<jsp:include page="../footer.jsp" />

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="Tải lên CCCD" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
  --navy:#0a2540; --blue:#2563eb; --teal:#0d9488; --bg:#f0ede8;
  --surface:#fff; --border:#e2e8f0; --text:#0f172a; --muted:#64748b;
}
*{box-sizing:border-box;}
body{background:var(--bg);font-family:'Inter',sans-serif;color:var(--text);}
.ob-wrapper{display:flex;min-height:calc(100vh - 64px);}
.ob-main{flex:1;padding:40px;display:flex;flex-direction:column;align-items:center;}

.upload-container {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 24px;
  width: 100%;
  max-width: 600px;
  padding: 40px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.04);
}

.upload-header {
  text-align: center;
  margin-bottom: 30px;
}
.upload-icon {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #ccfbf1, #99f6e4);
  color: var(--teal);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  margin: 0 auto 16px;
  box-shadow: 0 8px 16px rgba(13, 148, 136, 0.2);
}
.upload-title {
  font-family: 'Be Vietnam Pro', sans-serif;
  font-size: 1.5rem;
  font-weight: 800;
  color: var(--navy);
  margin: 0 0 8px;
}
.upload-sub {
  color: var(--muted);
  font-size: 0.9rem;
}

/* Upload Area */
.drop-zone {
  border: 2px dashed #cbd5e1;
  border-radius: 16px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
  background: #f8fafc;
  position: relative;
  overflow: hidden;
}
.drop-zone:hover, .drop-zone.dragover {
  border-color: var(--blue);
  background: #eff6ff;
}
.drop-zone i.fa-cloud-upload-alt {
  font-size: 3rem;
  color: #94a3b8;
  margin-bottom: 12px;
  transition: color 0.2s;
}
.drop-zone:hover i.fa-cloud-upload-alt, .drop-zone.dragover i.fa-cloud-upload-alt {
  color: var(--blue);
}
.drop-zone-text {
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--navy);
  margin-bottom: 6px;
}
.drop-zone-sub {
  font-size: 0.8rem;
  color: var(--muted);
}
.file-input {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  opacity: 0;
  cursor: pointer;
}

/* Preview */
.preview-container {
  display: none;
  margin-top: 20px;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid var(--border);
  position: relative;
}
.preview-container img {
  width: 100%;
  display: block;
}
.btn-remove {
  position: absolute;
  top: 10px;
  right: 10px;
  background: rgba(0,0,0,0.6);
  color: white;
  border: none;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}
.btn-remove:hover {
  background: var(--danger);
}

/* Buttons */
.btn-submit {
  width: 100%;
  padding: 14px;
  border-radius: 12px;
  background: linear-gradient(135deg, var(--navy), #1e40af);
  color: white;
  font-family: 'Be Vietnam Pro', sans-serif;
  font-size: 1rem;
  font-weight: 700;
  border: none;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  box-shadow: 0 4px 14px rgba(10,37,64,.3);
}
.btn-submit:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(10,37,64,.4);
}
.btn-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.skip-link {
  display: block;
  text-align: center;
  margin-top: 16px;
  color: var(--muted);
  font-size: 0.85rem;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.2s;
}
.skip-link:hover {
  color: var(--navy);
}

/* Alert */
.alert {
  padding: 12px 16px;
  border-radius: 10px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #991b1b;
}

/* Loader */
.loader-overlay {
  display: none;
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(255,255,255,0.9);
  z-index: 10;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-radius: 24px;
}
.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e2e8f0;
  border-top-color: var(--blue);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}
@keyframes spin { 100% { transform: rotate(360deg); } }
.loader-text {
  font-family: 'Be Vietnam Pro', sans-serif;
  font-size: 1rem;
  font-weight: 700;
  color: var(--navy);
}
.loader-sub {
  font-size: 0.8rem;
  color: var(--muted);
  margin-top: 4px;
}
</style>

<div class="ob-wrapper">
  <jsp:include page="../shared/sidebar.jsp">
    <jsp:param name="activeMenu" value="onboarding" />
  </jsp:include>

  <div class="ob-main">
    <div class="upload-container" style="position:relative;">

      <!-- Loader -->
      <div class="loader-overlay" id="loader">
        <div class="spinner"></div>
        <div class="loader-text">AI đang trích xuất dữ liệu...</div>
        <div class="loader-sub">Vui lòng đợi trong giây lát</div>
      </div>

      <div class="upload-header">
        <div class="upload-icon"><i class="fas fa-id-card"></i></div>
        <h1 class="upload-title">Tải lên CCCD mặt trước</h1>
        <div class="upload-sub">Hệ thống sẽ tự động trích xuất thông tin ứng viên bằng AI</div>
      </div>

      <c:if test="${not empty error}">
        <div class="alert"><i class="fas fa-exclamation-triangle"></i> ${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/hr/onboarding/upload" method="post" enctype="multipart/form-data" id="uploadForm">
        <div class="drop-zone" id="dropZone">
          <i class="fas fa-cloud-upload-alt"></i>
          <div class="drop-zone-text">Kéo thả ảnh vào đây hoặc click để chọn file</div>
          <div class="drop-zone-sub">Định dạng hỗ trợ: JPG, PNG, JPEG. Tối đa 5MB.</div>
          <input type="file" name="cccdImage" id="fileInput" class="file-input" accept="image/png, image/jpeg, image/jpg" required>
        </div>

        <div class="preview-container" id="previewContainer">
          <img id="imagePreview" src="" alt="Preview">
          <button type="button" class="btn-remove" id="btnRemove" title="Xóa ảnh"><i class="fas fa-times"></i></button>
        </div>

        <button type="submit" class="btn-submit" id="btnSubmit" disabled>
          <i class="fas fa-magic"></i> Bắt đầu trích xuất AI
        </button>

        <a href="${pageContext.request.contextPath}/hr/onboarding/new" class="skip-link">
          Nhập thông tin thủ công (Bỏ qua Upload)
        </a>
      </form>
    </div>
  </div>
</div>

<script>
  const fileInput = document.getElementById('fileInput');
  const dropZone = document.getElementById('dropZone');
  const previewContainer = document.getElementById('previewContainer');
  const imagePreview = document.getElementById('imagePreview');
  const btnRemove = document.getElementById('btnRemove');
  const btnSubmit = document.getElementById('btnSubmit');
  const uploadForm = document.getElementById('uploadForm');
  const loader = document.getElementById('loader');

  // Xử lý kéo thả
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, preventDefaults, false);
  });

  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  ['dragenter', 'dragover'].forEach(eventName => {
    dropZone.addEventListener(eventName, () => dropZone.classList.add('dragover'), false);
  });

  ['dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, () => dropZone.classList.remove('dragover'), false);
  });

  dropZone.addEventListener('drop', (e) => {
    let dt = e.dataTransfer;
    let files = dt.files;
    if (files.length > 0) {
      fileInput.files = files;
      handleFiles(files[0]);
    }
  });

  // Xử lý chọn file qua click
  fileInput.addEventListener('change', function() {
    if (this.files && this.files[0]) {
      handleFiles(this.files[0]);
    }
  });

  function handleFiles(file) {
    if (!file.type.startsWith('image/')) {
      alert('Vui lòng chọn file hình ảnh (JPG, PNG).');
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      alert('Kích thước file vượt quá giới hạn 5MB.');
      return;
    }

    const reader = new FileReader();
    reader.onload = function(e) {
      imagePreview.src = e.target.result;
      dropZone.style.display = 'none';
      previewContainer.style.display = 'block';
      btnSubmit.disabled = false;
    }
    reader.readAsDataURL(file);
  }

  // Xóa ảnh
  btnRemove.addEventListener('click', () => {
    fileInput.value = '';
    imagePreview.src = '';
    previewContainer.style.display = 'none';
    dropZone.style.display = 'block';
    btnSubmit.disabled = true;
  });

  // Submit form hiển thị loader
  uploadForm.addEventListener('submit', (e) => {
    if (fileInput.files.length === 0) {
      e.preventDefault();
      alert('Vui lòng chọn file trước khi trích xuất.');
      return;
    }
    btnSubmit.disabled = true;
    loader.style.display = 'flex';
  });
</script>

<jsp:include page="../footer.jsp" />

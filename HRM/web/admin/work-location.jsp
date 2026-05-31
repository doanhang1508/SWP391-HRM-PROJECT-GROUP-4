<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Địa Điểm Làm Việc" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --navy: #0a2540;
        --blue: #2b6cb0;
        --accent: #3ecf8e;
        --bg: #f0ede8;
        --surface: #ffffff;
        --border: #e2e8f0;
        --text: #0f172a;
        --muted: #64748b;
    }
    body {
        background: var(--bg);
        font-family: 'Inter', sans-serif;
        color: var(--text);
    }
    .dept-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }
    .dept-main {
        flex: 1;
        padding: 32px 36px;
        overflow-x: hidden;
    }
    .page-topbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 32px;
    }
    .page-topbar-left h1 {
        font-family: 'Be Vietnam Pro', sans-serif;
        font-size: 1.6rem;
        font-weight: 800;
        color: var(--navy);
        margin: 0 0 4px;
    }
    .btn-primary {
        background-color: var(--blue);
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    .btn-primary:hover {
        background-color: #1a4971;
        transform: translateY(-2px);
    }
    .panel {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 16px;
        padding: 26px 28px;
        margin-bottom: 24px;
    }
    .dept-table {
        width: 100%;
        border-collapse: collapse;
    }
    .dept-table thead th {
        font-size: .75rem;
        font-weight: 700;
        text-transform: uppercase;
        color: var(--muted);
        padding: 12px 16px;
        border-bottom: 2px solid var(--border);
        text-align: left;
    }
    .dept-table tbody td {
        padding: 14px 16px;
        font-size: .88rem;
        border-bottom: 1px solid #f8fafc;
    }
    .dept-table tbody tr:hover td {
        background: #f8fafc;
    }
    .action-btn {
        background: none;
        border: none;
        cursor: pointer;
        padding: 6px 10px;
        border-radius: 6px;
        font-size: 0.9rem;
        transition: background 0.2s;
    }
    .btn-edit {
        color: var(--blue);
    }
    .btn-edit:hover {
        background: #eff6ff;
    }
    .btn-delete {
        color: #e11d48;
    }
    .btn-delete:hover {
        background: #ffe4e6;
    }
</style>

<div class="dept-wrapper">
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="work-locations" />
    </jsp:include>

    <div class="dept-main">
        <div class="page-topbar">
            <div class="page-topbar-left">
                <h1>Danh Sách Địa Điểm / Chi Nhánh</h1>
            </div>
            <div>
                <button class="btn-primary" onclick="openAddModal()"><i class="fas fa-plus"></i> Thêm chi nhánh mới</button>
            </div>
        </div>

        <div class="panel">
            <div style="overflow-x:auto;">
                <table class="dept-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Chi Nhánh</th>
                            <th>Địa chỉ</th>
                            <th>Lương Tối Thiểu Vùng</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${locationList}" var="loc">
                            <tr>
                                <td style="font-weight: 600; color: var(--muted);">${loc.locationId}</td>
                                <td style="font-weight: 700; color: var(--navy);"><i class="fas fa-map-marker-alt" style="color: var(--blue); margin-right: 8px;"></i> ${loc.locationName}</td>
                                <td>${loc.address}</td>
                                <td style="font-weight: 600; color: var(--accent);">
                                    <fmt:formatNumber value="${loc.regionalMinimumWage}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                </td>
                                <td>
                                    <button class="action-btn btn-edit" title="Sửa"
                                            onclick="openEditModal('${loc.locationId}', '${loc.locationName}', '${loc.address}', '${loc.regionalMinimumWage}')"><i class="fas fa-pen"></i></button>
                                    <a href="${pageContext.request.contextPath}/admin/work-location?action=delete&id=${loc.locationId}" 
                                       class="action-btn btn-delete" title="Xóa" onclick="return confirm('Xóa chi nhánh này?');">
                                        <i class="fas fa-trash-alt"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- ==============================================
     MODAL THÊM MỚI (ADD FORM)
     ============================================== -->
<div id="addModal" class="modal" style="display: none; position: fixed; z-index: 1050; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.5);">
    <div class="modal-content" style="background-color: var(--surface); margin: 10% auto; padding: 24px 32px; border: 1px solid var(--border); width: 400px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); padding-bottom: 12px; margin-bottom: 20px;">
            <h3 style="margin: 0; color: var(--navy); font-family: 'Be Vietnam Pro', sans-serif;">Thêm Địa Điểm Mới</h3>
            <span onclick="document.getElementById('addModal').style.display = 'none'" style="cursor: pointer; font-size: 1.5rem; color: var(--muted);">&times;</span>
        </div>

        <form action="${pageContext.request.contextPath}/admin/work-location" method="POST">
            <input type="hidden" name="action" value="add">

            <div style="margin-bottom: 16px;">
                <label style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--muted); margin-bottom: 6px;">Tên Chi Nhánh</label>
                <input type="text" name="name" required style="width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 6px; font-family: 'Inter', sans-serif;">
            </div>

            <div style="margin-bottom: 16px;">
                <label style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--muted); margin-bottom: 6px;">Địa Chỉ</label>
                <input type="text" name="address" required style="width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 6px; font-family: 'Inter', sans-serif;">
            </div>

            <div style="margin-bottom: 24px;">
                <label style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--muted); margin-bottom: 6px;">Lương Tối Thiểu Vùng (VNĐ)</label>
                <input type="number" name="wage" required min="0" style="width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 6px; font-family: 'Inter', sans-serif;">
            </div>

            <div style="text-align: right;">
                <button type="button" onclick="document.getElementById('addModal').style.display = 'none'" style="background: none; border: 1px solid var(--border); padding: 8px 16px; border-radius: 6px; margin-right: 8px; cursor: pointer;">Hủy</button>
                <button type="submit" class="btn-primary" style="padding: 9px 18px;">Lưu Dữ Liệu</button>
            </div>
        </form>
    </div>
</div>

<!-- ==============================================
     MODAL CẬP NHẬT (EDIT FORM)
     ============================================== -->
<div id="editModal" class="modal" style="display: none; position: fixed; z-index: 1050; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.5);">
    <div class="modal-content" style="background-color: var(--surface); margin: 10% auto; padding: 24px 32px; border: 1px solid var(--border); width: 400px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); padding-bottom: 12px; margin-bottom: 20px;">
            <h3 style="margin: 0; color: var(--navy); font-family: 'Be Vietnam Pro', sans-serif;">Cập Nhật Địa Điểm</h3>
            <span onclick="document.getElementById('editModal').style.display = 'none'" style="cursor: pointer; font-size: 1.5rem; color: var(--muted);">&times;</span>
        </div>

        <form action="${pageContext.request.contextPath}/admin/work-location" method="POST">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="edit_id"> <!-- ID ẩn để gửi về Servlet -->

            <div style="margin-bottom: 16px;">
                <label style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--muted); margin-bottom: 6px;">Tên Chi Nhánh</label>
                <input type="text" name="name" id="edit_name" required style="width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 6px;">
            </div>

            <div style="margin-bottom: 16px;">
                <label style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--muted); margin-bottom: 6px;">Địa Chỉ</label>
                <input type="text" name="address" id="edit_address" required style="width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 6px;">
            </div>

            <div style="margin-bottom: 24px;">
                <label style="display: block; font-size: 0.85rem; font-weight: 600; color: var(--muted); margin-bottom: 6px;">Lương Tối Thiểu Vùng (VNĐ)</label>
                <input type="number" name="wage" id="edit_wage" required min="0" style="width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: 6px;">
            </div>

            <div style="text-align: right;">
                <button type="button" onclick="document.getElementById('editModal').style.display = 'none'" style="background: none; border: 1px solid var(--border); padding: 8px 16px; border-radius: 6px; margin-right: 8px; cursor: pointer;">Hủy</button>
                <button type="submit" class="btn-primary" style="padding: 9px 18px;">Cập Nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- SCRIPT XỬ LÝ MỞ MODAL -->
<script>
    // Hàm mở form thêm mới (Bạn cần sửa lại nút <button class="btn-primary"> ở trên đầu trang thành: 
    // <button class="btn-primary" onclick="openAddModal()"><i class="fas fa-plus"></i> Thêm chi nhánh mới</button>)
    function openAddModal() {
        document.getElementById('addModal').style.display = 'block';
    }

    // Hàm mở form Edit và bắn dữ liệu từ Table vào Form
    function openEditModal(id, name, address, wage) {
        document.getElementById('edit_id').value = id;
        document.getElementById('edit_name').value = name;
        document.getElementById('edit_address').value = address;
        document.getElementById('edit_wage').value = wage;

        document.getElementById('editModal').style.display = 'block';
    }
</script>

<jsp:include page="../footer.jsp" />

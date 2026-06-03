<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

        <c:set var="pageTitle" value="Quản lý Loại Nghỉ Phép" scope="request" />
        <jsp:include page="../header.jsp" />

        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
            rel="stylesheet">

        <style>
            /* ── Reset portal footer cho trang admin ── */
            footer,
            #chatWidget {
                display: none !important;
            }

            body {
                background-color: #f1f5f9 !important;
                font-family: 'Inter', sans-serif !important;
                padding-top: 0 !important;
                min-height: 100vh;
            }

            .dashboard-wrapper {
                display: flex;
                min-height: calc(100vh - 64px);
            }

            .dash-main {
                flex: 1;
                min-width: 0;
                background: #f1f5f9;
            }

            .dash-content {
                padding: 28px 32px;
                display: flex;
                flex-direction: column;
                gap: 28px;
            }

            .dash-page-header {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .dash-breadcrumb {
                font-size: 0.78rem;
                color: #94a3b8;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .dash-breadcrumb a {
                color: #0d9488;
                text-decoration: none;
            }

            .dash-page-title {
                font-size: 1.5rem;
                font-weight: 800;
                color: #0f172a;
                letter-spacing: -0.5px;
            }

            .dash-card {
                background: #fff;
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
                border: 1px solid #e2e8f0;
            }

            .dash-card-header {
                margin-bottom: 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .dash-card-title {
                font-size: 1.1rem;
                font-weight: 700;
                color: #0f172a;
            }

            .dash-btn {
                padding: 8px 16px;
                font-size: 0.85rem;
                font-weight: 600;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                color: #fff;
                background: #0d9488;
            }

            .dash-table {
                width: 100%;
                border-collapse: collapse;
            }

            .dash-table th {
                padding: 12px 16px;
                border-bottom: 1px solid #e2e8f0;
                color: #64748b;
                font-size: 0.75rem;
                text-transform: uppercase;
                background: #fafbfc;
                text-align: left;
            }

            .dash-table td {
                padding: 15px 16px;
                border-bottom: 1px solid #f1f5f9;
                font-size: 0.9rem;
                color: #0f172a;
            }

            .badge {
                padding: 4px 10px;
                border-radius: 20px;
                font-size: 0.75rem;
                font-weight: 700;
            }

            .badge-paid {
                background: #d1fae5;
                color: #059669;
            }

            .badge-unpaid {
                background: #fee2e2;
                color: #dc2626;
            }

            .modal-overlay {
                display: none;
                position: fixed;
                inset: 0;
                z-index: 1050;
                background: rgba(15, 23, 42, 0.45);
                backdrop-filter: blur(3px);
            }

            .modal-box {
                background: #ffffff;
                margin: 8% auto;
                padding: 24px 28px;
                width: 420px;
                border-radius: 14px;
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
            }

            .modal-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 16px;
                padding-bottom: 12px;
                border-bottom: 1px solid #e2e8f0;
            }

            .modal-title {
                font-size: 1rem;
                font-weight: 700;
                color: #0f172a;
                margin: 0;
            }

            .modal-close {
                background: none;
                border: none;
                font-size: 1.4rem;
                color: #64748b;
                cursor: pointer;
                line-height: 1;
                padding: 0;
            }

            .form-group {
                margin-bottom: 16px;
            }

            .form-label {
                display: block;
                font-size: 0.8rem;
                font-weight: 600;
                color: #64748b;
                margin-bottom: 6px;
            }

            .form-control {
                width: 100%;
                padding: 9px 12px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 0.9rem;
                outline: none;
            }

            .form-control:focus {
                border-color: #0d9488;
                box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.15);
            }

            .modal-footer {
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                margin-top: 18px;
            }

            .btn-cancel {
                background: none;
                border: 1px solid #e2e8f0;
                padding: 8px 16px;
                border-radius: 8px;
                font-size: 0.85rem;
                color: #64748b;
                cursor: pointer;
            }

            @media (max-width: 600px) {
                .modal-box {
                    width: 95%;
                    margin: 12% auto;
                }
            }
        </style>

        <div class="dashboard-wrapper">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activeMenu" value="leave-types" />
            </jsp:include>

            <div class="dash-main">
                <div class="dash-content">
                    <div class="dash-page-header">
                        <div class="dash-breadcrumb">
                            <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                            <span>/</span>
                            <a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a>
                            <span>/</span>
                            <span>Loại Nghỉ Phép</span>
                        </div>
                        <div class="dash-page-title">Danh Mục Nghỉ Phép</div>
                    </div>

                    <c:if test="${not empty error or not empty param.error}">
                        <div
                            style="padding:15px;border-radius:8px;background:#fee2e2;color:#991b1b;border:1px solid #f87171;margin-bottom:20px;font-size:0.9rem;font-weight:500;">
                            <i class="fas fa-exclamation-triangle"></i> ${not empty error ? error : param.error}
                        </div>
                    </c:if>

                    <div class="dash-card">
                        <div class="dash-card-header">
                            <h3 class="dash-card-title">Danh sách loại nghỉ phép</h3>
                            <button class="dash-btn" onclick="openAddModal()">
                                <i class="fas fa-plus"></i> Thêm mới
                            </button>
                        </div>

                        <!-- SEARCH & FILTER BAR -->
                        <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;margin-bottom:18px;">
                            <div style="position:relative;flex:1;min-width:200px;">
                                <i class="fas fa-search" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#94a3b8;font-size:.85rem;"></i>
                                <input type="text" id="searchInput" placeholder="Tìm loại nghỉ phép..." oninput="filterTable()" style="width:100%;padding:9px 14px 9px 36px;border:1px solid #e2e8f0;border-radius:8px;font-size:.9rem;outline:none;font-family:'Inter',sans-serif;">
                            </div>
                            <select id="paidFilter" onchange="filterTable()" style="padding:9px 14px;border:1px solid #e2e8f0;border-radius:8px;font-size:.9rem;outline:none;cursor:pointer;min-width:170px;font-family:'Inter',sans-serif;">
                                <option value="all">Tất cả</option>
                                <option value="paid">Có hưởng lương</option>
                                <option value="unpaid">Không hưởng lương</option>
                            </select>
                        </div>

                        <table class="dash-table" id="leaveTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên Loại Nghỉ Phép</th>
                                    <th>Mô tả</th>
                                    <th>Tính Lương</th>
                                    <th>Số ngày tối đa/năm</th>
                                    <th>Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="type" items="${leaveTypes}">
                                    <tr>
                                        <td>#${type.leaveTypeId}</td>
                                        <td style="font-weight: 500;">${type.typeName}</td>
                                        <td>${empty type.description ? '—' : type.description}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${type.paidLeave == 1}">
                                                    <span class="badge badge-paid">Có hưởng lương</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-unpaid">Không hưởng lương</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${type.maxDaysPerYear}</td>
                                        <td>
                                            <button
                                                type="button"
                                                class="action-btn"
                                                style="color: #3b82f6; margin-right: 10px; background: none; border: none; cursor: pointer;"
                                                onclick="openEditModal('${type.leaveTypeId}','${fn:escapeXml(type.typeName)}','${type.paidLeave}','${fn:escapeXml(type.description)}','${type.maxDaysPerYear}')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <form action="${pageContext.request.contextPath}/admin/leave-types" method="POST" style="display: inline;" onsubmit="return confirm('Xóa loại nghỉ phép \'${type.typeName}\'?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${type.leaveTypeId}">
                                                <button type="submit" style="color: #ef4444; background: none; border: none; cursor: pointer;">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>

                        <!-- PAGINATION -->
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:20px;border-top:1px solid #e2e8f0;">
                            <div style="font-size:.85rem;color:#94a3b8;">Hiển thị <span id="pageStart" style="font-weight:600;color:#0f172a;">0</span> - <span id="pageEnd" style="font-weight:600;color:#0f172a;">0</span> trong tổng số <span id="totalItems" style="font-weight:600;color:#0f172a;">0</span> mục</div>
                            <div style="display:flex;gap:8px;">
                                <button id="btnPrevPage" onclick="prevPage()" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:#94a3b8;cursor:pointer;"><i class="fas fa-chevron-left"></i></button>
                                <div id="pageNumbers" style="display:flex;gap:4px;"></div>
                                <button id="btnNextPage" onclick="nextPage()" style="background:#fff;border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:#94a3b8;cursor:pointer;"><i class="fas fa-chevron-right"></i></button>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <div class="modal-overlay" id="addModal">
            <div class="modal-box">
                <div class="modal-header">
                    <h3 class="modal-title">Thêm loại nghỉ phép</h3>
                    <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
                </div>
                <form action="${pageContext.request.contextPath}/admin/leave-types" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="form-group">
                        <label class="form-label">Tên loại nghỉ phép <span style="color:#e11d48;">*</span></label>
                        <input type="text" name="name" class="form-control" maxlength="255" placeholder="Nhập tên loại nghỉ phép" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Mô tả</label>
                        <textarea name="description" class="form-control" maxlength="500" rows="3"></textarea>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Tính lương <span style="color:#e11d48;">*</span></label>
                        <div style="display:flex; gap:12px; align-items:center;">
                            <label style="display:flex; align-items:center; gap:6px; font-size:0.9rem;">
                                <input type="radio" name="paidLeave" value="1" checked> Có hưởng lương
                            </label>
                            <label style="display:flex; align-items:center; gap:6px; font-size:0.9rem;">
                                <input type="radio" name="paidLeave" value="0"> Không hưởng lương
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số ngày tối đa/năm</label>
                        <input type="number" name="maxDaysPerYear" class="form-control" min="0" max="365" placeholder="0 - 365">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                        <button type="submit" class="dash-btn"><i class="fas fa-save"></i> Lưu</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="modal-overlay" id="editModal">
            <div class="modal-box">
                <div class="modal-header">
                    <h3 class="modal-title">Cập nhật loại nghỉ phép</h3>
                    <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
                </div>
                <form action="${pageContext.request.contextPath}/admin/leave-types" method="POST">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="edit_id">
                    <div class="form-group">
                        <label class="form-label">Tên loại nghỉ phép <span style="color:#e11d48;">*</span></label>
                        <input type="text" name="name" id="edit_name" class="form-control" maxlength="255" placeholder="Nhập tên loại nghỉ phép" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Mô tả</label>
                        <textarea name="description" id="edit_description" class="form-control" maxlength="500" rows="3"></textarea>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Tính lương <span style="color:#e11d48;">*</span></label>
                        <div style="display:flex; gap:12px; align-items:center;">
                            <label style="display:flex; align-items:center; gap:6px; font-size:0.9rem;">
                                <input type="radio" name="paidLeave" id="edit_paid_yes" value="1"> Có hưởng lương
                            </label>
                            <label style="display:flex; align-items:center; gap:6px; font-size:0.9rem;">
                                <input type="radio" name="paidLeave" id="edit_paid_no" value="0"> Không hưởng lương
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số ngày tối đa/năm</label>
                        <input type="number" name="maxDaysPerYear" id="edit_max_days" class="form-control" min="0" max="365" placeholder="0 - 365">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Hủy</button>
                        <button type="submit" class="dash-btn"><i class="fas fa-save"></i> Cập nhật</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            let currentPage = 1;
            const itemsPerPage = 8;
            let filteredRows = [];

            function filterTable() {
                const query = document.getElementById('searchInput').value.toLowerCase();
                const paidVal = document.getElementById('paidFilter').value;
                const allRows = Array.from(document.querySelectorAll('#leaveTable tbody tr'));
                filteredRows = allRows.filter(function(row) {
                    const matchText = row.textContent.toLowerCase().includes(query);
                    const paidBadge = row.querySelector('.badge-paid, .badge-unpaid');
                    let rowPaid = 'paid';
                    if (paidBadge && paidBadge.classList.contains('badge-unpaid')) rowPaid = 'unpaid';
                    const matchPaid = paidVal === 'all' || rowPaid === paidVal;
                    return matchText && matchPaid;
                });
                currentPage = 1;
                updatePagination();
            }

            function updatePagination() {
                if(filteredRows.length === 0) {
                    document.querySelectorAll('#leaveTable tbody tr').forEach(row => row.style.display = 'none');
                    document.getElementById('pageStart').textContent = 0;
                    document.getElementById('pageEnd').textContent = 0;
                    document.getElementById('totalItems').textContent = 0;
                    document.getElementById('pageNumbers').innerHTML = '';
                    document.getElementById('btnPrevPage').disabled = true;
                    document.getElementById('btnNextPage').disabled = true;
                    return;
                }
                const totalPages = Math.ceil(filteredRows.length / itemsPerPage);
                if (currentPage > totalPages) currentPage = totalPages;
                if (currentPage < 1) currentPage = 1;
                const startIndex = (currentPage - 1) * itemsPerPage;
                const endIndex = Math.min(startIndex + itemsPerPage, filteredRows.length);
                document.querySelectorAll('#leaveTable tbody tr').forEach(row => row.style.display = 'none');
                for (let i = startIndex; i < endIndex; i++) { filteredRows[i].style.display = ''; }
                document.getElementById('pageStart').textContent = startIndex + 1;
                document.getElementById('pageEnd').textContent = endIndex;
                document.getElementById('totalItems').textContent = filteredRows.length;
                let pageHtml = '';
                for (let i = 1; i <= totalPages; i++) {
                    pageHtml += '<button style="background:' + (i===currentPage ? '#0d9488' : '#fff') + ';border:1px solid #e2e8f0;border-radius:8px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:' + (i===currentPage ? 'white' : '#94a3b8') + ';cursor:pointer;" onclick="goToPage(' + i + ')">' + i + '</button>';
                }
                document.getElementById('pageNumbers').innerHTML = pageHtml;
                document.getElementById('btnPrevPage').disabled = currentPage === 1;
                document.getElementById('btnNextPage').disabled = currentPage === totalPages;
            }

            function goToPage(page) { currentPage = page; updatePagination(); }
            function prevPage() { if (currentPage > 1) { currentPage--; updatePagination(); } }
            function nextPage() { const tp = Math.ceil(filteredRows.length / itemsPerPage); if (currentPage < tp) { currentPage++; updatePagination(); } }

            function openAddModal() {
                document.getElementById('addModal').style.display = 'block';
            }

            function openEditModal(id, name, paidLeave, description, maxDays) {
                document.getElementById('edit_id').value = id;
                document.getElementById('edit_name').value = name;
                document.getElementById('edit_description').value = description || '';
                document.getElementById('edit_max_days').value = maxDays || '';
                if (paidLeave === '1') {
                    document.getElementById('edit_paid_yes').checked = true;
                } else {
                    document.getElementById('edit_paid_no').checked = true;
                }
                document.getElementById('editModal').style.display = 'block';
            }

            function closeModal(id) {
                document.getElementById(id).style.display = 'none';
            }

            document.querySelectorAll('.modal-overlay').forEach(function (overlay) {
                overlay.addEventListener('click', function (e) {
                    if (e.target === overlay) {
                        overlay.style.display = 'none';
                    }
                });
            });

            document.addEventListener('DOMContentLoaded', function() {
                filteredRows = Array.from(document.querySelectorAll('#leaveTable tbody tr'));
                updatePagination();
            });
        </script>

        <jsp:include page="../footer.jsp" />
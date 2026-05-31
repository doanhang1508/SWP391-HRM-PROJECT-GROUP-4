<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Yêu Cầu Tạo Tài Khoản" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
    --navy:    #0a2540;
    --blue:    #2b6cb0;
    --blue-lt: #63b3ed;
    --accent:  #3ecf8e;
    --bg:      #f0ede8;
    --surface: #ffffff;
    --border:  #e2e8f0;
    --text:    #0f172a;
    --muted:   #64748b;
}
* { box-sizing: border-box; }
body { background: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }

.pr-wrapper { display: flex; min-height: calc(100vh - 64px); }
.pr-main { flex: 1; padding: 32px 36px; overflow-x: hidden; }

/* TOP BAR */
.page-topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 32px; flex-wrap: wrap; gap: 16px; }
.page-topbar-left h1 { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.6rem; font-weight: 800; color: var(--navy); letter-spacing: -.5px; margin: 0 0 4px; }
.breadcrumb-txt { font-size: .8rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
.breadcrumb-txt a { color: var(--blue); text-decoration: none; }

/* PANEL */
.panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 26px 28px; }
.panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 22px; }
.panel-title { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); letter-spacing: -.3px; margin: 0; display: flex; align-items: center; gap: 10px; }
.panel-title-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.dot-orange { background: #f97316; }

/* FILTER TABS */
.filter-tabs { display: flex; gap: 8px; margin-bottom: 22px; flex-wrap: wrap; }
.filter-tab {
    padding: 8px 18px;
    border-radius: 10px;
    font-size: .84rem;
    font-weight: 700;
    border: 1.5px solid var(--border);
    background: var(--surface);
    color: var(--muted);
    cursor: pointer;
    transition: all .2s;
    display: flex;
    align-items: center;
    gap: 8px;
}
.filter-tab:hover { border-color: var(--blue); color: var(--blue); }
.filter-tab.active {
    background: var(--navy);
    border-color: var(--navy);
    color: #fff;
}
.tab-count {
    background: rgba(255,255,255,.2);
    color: #fff;
    font-size: .72rem;
    font-weight: 800;
    padding: 2px 7px;
    border-radius: 10px;
}
.filter-tab:not(.active) .tab-count {
    background: #f1f5f9;
    color: var(--navy);
}

/* TABLE */
.req-table { width: 100%; border-collapse: collapse; }
.req-table thead th {
    font-size: .72rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: var(--muted);
    padding: 12px 16px;
    border-bottom: 2px solid var(--border);
    text-align: left;
    white-space: nowrap;
    background: #fafbfc;
}
.req-table thead th:first-child { border-radius: 8px 0 0 0; }
.req-table thead th:last-child  { border-radius: 0 8px 0 0; }
.req-table tbody td {
    padding: 14px 16px;
    font-size: .88rem;
    color: var(--text);
    border-bottom: 1px solid #f8fafc;
    vertical-align: middle;
}
.req-table tbody tr:last-child td { border-bottom: none; }
.req-table tbody tr { transition: background .15s; }
.req-table tbody tr:hover td { background: #f8fafc; }

/* Employee cell */
.emp-cell { display: flex; align-items: center; gap: 12px; }
.emp-avatar {
    width: 36px; height: 36px;
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    font-weight: 800;
    font-size: .85rem;
    flex-shrink: 0;
    color: #fff;
}
.av-1 { background: linear-gradient(135deg,#667eea,#764ba2); }
.av-2 { background: linear-gradient(135deg,#f093fb,#f5576c); }
.av-3 { background: linear-gradient(135deg,#4facfe,#00f2fe); }
.av-4 { background: linear-gradient(135deg,#43e97b,#38f9d7); }
.av-5 { background: linear-gradient(135deg,#fa709a,#fee140); }
.av-6 { background: linear-gradient(135deg,#a18cd1,#fbc2eb); }
.av-7 { background: linear-gradient(135deg,#fccb90,#d57eeb); }
.emp-name { font-weight: 700; color: var(--navy); font-size: .9rem; }

/* Type badge */
.type-badge { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; border-radius: 20px; font-size: .78rem; font-weight: 700; }
.tb-leave  { background: #eff6ff; color: #1d4ed8; }
.tb-sick   { background: #fef2f2; color: #dc2626; }
.tb-health { background: #faf5ff; color: #7c3aed; }

/* Note */
.note-cell { font-size: .83rem; color: var(--muted); font-style: italic; }
.note-dash { color: #cbd5e0; }

/* Action buttons */
.action-btns { display: flex; gap: 8px; }
.btn-approve {
    padding: 7px 16px;
    border-radius: 8px;
    border: none;
    background: #dcfce7;
    color: #16a34a;
    font-size: .8rem;
    font-weight: 700;
    cursor: pointer;
    transition: all .2s;
    display: flex; align-items: center; gap: 6px;
    white-space: nowrap;
}
.btn-approve:hover { background: #16a34a; color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(22,163,74,.3); }
.btn-reject {
    padding: 7px 16px;
    border-radius: 8px;
    border: none;
    background: #fee2e2;
    color: #dc2626;
    font-size: .8rem;
    font-weight: 700;
    cursor: pointer;
    transition: all .2s;
    display: flex; align-items: center; gap: 6px;
    white-space: nowrap;
}
.btn-reject:hover { background: #dc2626; color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(220,38,38,.3); }

/* Hidden row for filtering */
.req-row { }
.req-row.hidden { display: none; }

/* Summary pills */
.summary-pills { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 20px; }
.summary-pill { background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 10px 18px; display: flex; align-items: center; gap: 10px; }
.sp-label { font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: .8px; color: var(--muted); }
.sp-val { font-family: 'Be Vietnam Pro', sans-serif; font-size: 1.3rem; font-weight: 800; color: var(--navy); }

@media (max-width: 768px) {
    .pr-main { padding: 20px 16px; }
    .req-table { font-size: .82rem; }
    .req-table thead th, .req-table tbody td { padding: 10px 10px; }
    .action-btns { flex-direction: column; gap: 4px; }
}
</style>

<div class="pr-wrapper">
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="pending-requests" />
    </jsp:include>

    <div class="pr-main">

        <!-- TOP BAR -->
        <div class="page-topbar">
            <div class="page-topbar-left">
                <div class="breadcrumb-txt">
                    <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                    <span style="color:#cbd5e0">/</span>
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
                    <span style="color:#cbd5e0">/</span>
                    <span>Yêu cầu tạo tài khoản</span>
                </div>
                <h1>Yêu Cầu Tạo Tài Khoản Từ HR</h1>
            </div>
        </div>

        <!-- SUMMARY PILLS -->
        <div class="summary-pills">
            <div class="summary-pill">
                <div><div class="sp-label">Tổng yêu cầu</div><div class="sp-val">4</div></div>
                <i class="fas fa-users" style="color:#f97316;font-size:1.4rem;"></i>
            </div>
            <div class="summary-pill">
                <div><div class="sp-label">Chờ duyệt</div><div class="sp-val">2</div></div>
                <i class="fas fa-clock" style="color:#2b6cb0;font-size:1.4rem;"></i>
            </div>
            <div class="summary-pill">
                <div><div class="sp-label">Đã hoàn thành</div><div class="sp-val">2</div></div>
                <i class="fas fa-check-circle" style="color:#16a34a;font-size:1.4rem;"></i>
            </div>
        </div>

        <!-- MAIN PANEL -->
        <div class="panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div class="panel-title-dot dot-orange"></div>
                    Danh Sách Yêu Cầu Tạo Mới
                </h3>
            </div>

            <!-- FILTER TABS -->
            <div class="filter-tabs">
                <button class="filter-tab active" id="tab-all" onclick="filterRequests('all')">
                    Tất cả <span class="tab-count">4</span>
                </button>
                <button class="filter-tab" id="tab-pending" onclick="filterRequests('pending')">
                    <i class="fas fa-clock"></i> Chờ duyệt <span class="tab-count">2</span>
                </button>
                <button class="filter-tab" id="tab-completed" onclick="filterRequests('completed')">
                    <i class="fas fa-check-circle"></i> Đã hoàn thành <span class="tab-count">2</span>
                </button>
            </div>

            <div style="overflow-x:auto;">
                <table class="req-table">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Nhân viên</th>
                            <th>Phòng ban</th>
                            <th>Trạng thái</th>
                            <th>Ngày gửi</th>
                            <th>Ghi chú</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="req-row" data-type="pending">
                            <td style="color:var(--muted);font-weight:700;">01</td>
                            <td>
                                <div class="emp-cell">
                                    <div class="emp-avatar av-1">A</div>
                                    <div class="emp-name">Alex Rivera</div>
                                </div>
                            </td>
                            <td>Kỹ thuật Sản phẩm</td>
                            <td><span class="type-badge tb-leave"><i class="fas fa-clock"></i> Chờ duyệt</span></td>
                            <td style="color:var(--muted);font-size:.85rem;">27/05/2026</td>
                            <td><span class="note-cell">Vị trí: Developer</span></td>
                            <td>
                                <div class="action-btns">
                                    <button class="btn-approve" onclick="handleApprove('Alex Rivera')"><i class="fas fa-user-plus"></i> Tạo tài khoản</button>
                                    <button class="btn-reject"  onclick="handleReject('Alex Rivera')"><i class="fas fa-times"></i> Từ chối</button>
                                </div>
                            </td>
                        </tr>
                        <tr class="req-row" data-type="pending">
                            <td style="color:var(--muted);font-weight:700;">02</td>
                            <td>
                                <div class="emp-cell">
                                    <div class="emp-avatar av-2">S</div>
                                    <div class="emp-name">Sophia Martinez</div>
                                </div>
                            </td>
                            <td>Tuyển dụng Nhân sự</td>
                            <td><span class="type-badge tb-leave"><i class="fas fa-clock"></i> Chờ duyệt</span></td>
                            <td style="color:var(--muted);font-size:.85rem;">26/05/2026</td>
                            <td><span class="note-cell">Vị trí: HR Intern</span></td>
                            <td>
                                <div class="action-btns">
                                    <button class="btn-approve" onclick="handleApprove('Sophia Martinez')"><i class="fas fa-user-plus"></i> Tạo tài khoản</button>
                                    <button class="btn-reject"  onclick="handleReject('Sophia Martinez')"><i class="fas fa-times"></i> Từ chối</button>
                                </div>
                            </td>
                        </tr>
                        <tr class="req-row" data-type="completed">
                            <td style="color:var(--muted);font-weight:700;">03</td>
                            <td>
                                <div class="emp-cell">
                                    <div class="emp-avatar av-3">D</div>
                                    <div class="emp-name">David Chen</div>
                                </div>
                            </td>
                            <td>Tài chính Kế toán</td>
                            <td><span class="type-badge tb-health" style="background:#f0fdf4; color:#16a34a;"><i class="fas fa-check-circle"></i> Hoàn thành</span></td>
                            <td style="color:var(--muted);font-size:.85rem;">25/05/2026</td>
                            <td><span class="note-cell">Vị trí: Accountant</span></td>
                            <td>
                                <div class="action-btns">
                                    <button class="btn-reject" style="background:#f1f5f9; color:#94a3b8; cursor:not-allowed;" disabled><i class="fas fa-check"></i> Đã tạo</button>
                                </div>
                            </td>
                        </tr>
                        <tr class="req-row" data-type="completed">
                            <td style="color:var(--muted);font-weight:700;">04</td>
                            <td>
                                <div class="emp-cell">
                                    <div class="emp-avatar av-4">E</div>
                                    <div class="emp-name">Emma Watson</div>
                                </div>
                            </td>
                            <td>Marketing Chiến lược</td>
                            <td><span class="type-badge tb-health" style="background:#f0fdf4; color:#16a34a;"><i class="fas fa-check-circle"></i> Hoàn thành</span></td>
                            <td style="color:var(--muted);font-size:.85rem;">24/05/2026</td>
                            <td><span class="note-cell">Vị trí: Marketer</span></td>
                            <td>
                                <div class="action-btns">
                                    <button class="btn-reject" style="background:#f1f5f9; color:#94a3b8; cursor:not-allowed;" disabled><i class="fas fa-check"></i> Đã tạo</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<script>
function filterRequests(type) {
    // Update active tab
    document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
    document.getElementById('tab-' + type).classList.add('active');

    // Show/hide rows
    document.querySelectorAll('.req-row').forEach(function(row) {
        if (type === 'all') {
            row.classList.remove('hidden');
        } else if (type === 'pending') {
            row.classList.toggle('hidden', row.dataset.type !== 'pending');
        } else if (type === 'completed') {
            row.classList.toggle('hidden', row.dataset.type !== 'completed');
        }
    });
}

function handleApprove(name) {
    if (confirm('Bạn có chắc chắn muốn TẠO TÀI KHOẢN cho ' + name + ' không?')) {
        alert('✅ Đã tạo tài khoản cho ' + name + ' thành công!\n(Trong thực tế, trang sẽ chuyển đến form nhập thông tin hoặc gửi mail tự động.)');
    }
}

function handleReject(name) {
    if (confirm('Bạn có chắc chắn muốn TỪ CHỐI yêu cầu tạo tài khoản của ' + name + ' không?')) {
        alert('❌ Đã từ chối yêu cầu của ' + name + '!\n(Trong thực tế, trang sẽ gửi request đến server để cập nhật trạng thái.)');
    }
}
</script>

<jsp:include page="../footer.jsp" />

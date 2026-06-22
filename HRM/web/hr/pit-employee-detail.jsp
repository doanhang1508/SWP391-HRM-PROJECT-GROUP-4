<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Chi Tiết Thuế NV - Enterprise HRM" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    :root{ --pri:#6366f1; --bg:#f4f7fe; --card:#fff; --txt:#1e293b; --danger:#ef4444; --success:#10b981;}
    body{background:var(--bg);font-family:'Inter',sans-serif;}
    .dashboard-wrapper{display:flex;min-height:calc(100vh - 64px);}
    .main-content{flex:1;padding:30px;}
    .admin-panel{background:var(--card);border-radius:16px;padding:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);margin-bottom:24px;}
    .card-detail{border:1px solid #e2e8f0;border-radius:12px;padding:20px;height:100%;}
    .val-item{display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px dashed #e2e8f0;}
    .val-item:last-child{border-bottom:none;}
    .val-label{color:#64748b;font-size:0.9rem;}
    .val-value{font-weight:600;color:var(--txt);}
    .tbl{width:100%;border-collapse:separate;border-spacing:0 6px;}
    .tbl th{color:#64748b;font-weight:600;font-size:.85rem;padding:10px 14px;border-bottom:2px solid #e2e8f0;}
    .tbl td{background:#fff;padding:13px 14px;font-size:.9rem;border-bottom:1px solid #f1f5f9;}
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="pit" />
    </jsp:include>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1" style="color:var(--txt);">Chi Tiết Tính Thuế TNCN</h2>
                <p class="text-muted mb-0">
                    <a href="pit" style="text-decoration:none;color:var(--pri);">Dashboard</a> &gt; 
                    <a href="pit?month=${selectedMonth}&year=${selectedYear}" style="text-decoration:none;color:var(--pri);">Kỳ ${selectedMonth}/${selectedYear}</a> &gt; 
                    NV #${userId}
                </p>
            </div>
            <form method="POST" action="pit" style="display:inline;">
                <input type="hidden" name="action" value="calculateSingle">
                <input type="hidden" name="userId" value="${userId}">
                <input type="hidden" name="month" value="${selectedMonth}">
                <input type="hidden" name="year" value="${selectedYear}">
                <button type="submit" class="btn btn-primary px-4 fw-bold" style="border-radius:8px;background:var(--pri);border:none;">
                    <i class="fas fa-sync-alt"></i> Tính Lại / Áp dụng
                </button>
            </form>
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show"><i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <c:if test="${taxResult.hasWarning}">
            <div class="alert alert-warning mb-4">
                <i class="fas fa-exclamation-triangle me-2"></i> <strong>Cảnh báo:</strong> ${taxResult.warningMessage}
            </div>
        </c:if>

        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="card-detail">
                    <h5 class="fw-bold mb-3"><i class="fas fa-user-circle text-primary me-2"></i>Thông tin hồ sơ thuế</h5>
                    <div class="val-item">
                        <span class="val-label">Mã số thuế:</span>
                        <span class="val-value text-primary">${not empty taxProfile.taxCode ? taxProfile.taxCode : 'N/A'}</span>
                    </div>
                    <div class="val-item">
                        <span class="val-label">Số NPT:</span>
                        <span class="val-value text-danger">${taxResult.dependentCount} người</span>
                    </div>
                    <div class="val-item">
                        <span class="val-label">Giảm trừ bản thân:</span>
                        <span class="val-value"><fmt:formatNumber value="${taxResult.personalDeduction}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </div>
                    <div class="val-item">
                        <span class="val-label">Giảm trừ NPT:</span>
                        <span class="val-value"><fmt:formatNumber value="${taxResult.dependentDeduction}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </div>
                    <div class="val-item pt-2 mt-2" style="border-top:2px solid #e2e8f0;border-bottom:none;">
                        <span class="val-label fw-bold">Tổng Giảm Trừ:</span>
                        <span class="val-value fw-bold text-success" style="font-size:1.1rem;"><fmt:formatNumber value="${taxResult.totalDeduction}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-detail" style="background:#f8fafc;">
                    <h5 class="fw-bold mb-3"><i class="fas fa-calculator text-success me-2"></i>Tổng hợp Thu nhập</h5>
                    <div class="val-item">
                        <span class="val-label">Tổng Gross:</span>
                        <span class="val-value"><fmt:formatNumber value="${taxResult.grossIncome}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </div>
                    <div class="val-item">
                        <span class="val-label">Trừ Bảo hiểm (-):</span>
                        <span class="val-value text-danger">-<fmt:formatNumber value="${taxResult.insuranceAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </div>
                    <div class="val-item">
                        <span class="val-label">Trừ Giảm trừ GTGC (-):</span>
                        <span class="val-value text-muted">-<fmt:formatNumber value="${taxResult.totalDeduction}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </div>
                    <div class="val-item pt-2 mt-2" style="border-top:2px solid #e2e8f0;border-bottom:none;">
                        <span class="val-label fw-bold">Thu Nhập Tính Thuế:</span>
                        <span class="val-value fw-bold text-primary" style="font-size:1.1rem;"><fmt:formatNumber value="${taxResult.taxableIncome}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-detail text-center d-flex flex-column justify-content-center" style="background:linear-gradient(135deg,#0f172a,#1e293b);color:#fff;border:none;">
                    <h6 class="text-uppercase mb-2 text-muted fw-bold">Tổng Thuế Phải Nộp (PIT)</h6>
                    <h1 class="fw-bold mb-4" style="color:#f43f5e;"><fmt:formatNumber value="${taxResult.pitAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h1>
                    
                    <h6 class="text-uppercase mb-2 text-muted fw-bold">Thực Nhận (Net Salary)</h6>
                    <h1 class="fw-bold text-success"><fmt:formatNumber value="${taxResult.netSalary}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></h1>
                </div>
            </div>
        </div>

        <div class="admin-panel">
            <h5 class="fw-bold mb-4"><i class="fas fa-layer-group text-primary me-2"></i>Chi tiết tính Thuế (Phân bổ theo Bậc)</h5>
            <div class="table-responsive">
                <table class="tbl" id="breakdownTable">
                    <thead>
                        <tr>
                            <th>Bậc</th>
                            <th>Mức Thu Nhập (VNĐ)</th>
                            <th>Thuế Suất</th>
                            <th>Thu Nhập Chịu Thuế (VNĐ)</th>
                            <th>Tiền Thuế (VNĐ)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Rendered by JS -->
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="3" class="text-end fw-bold">TỔNG CỘNG:</td>
                            <td class="fw-bold text-primary" id="tdTotalTaxable"></td>
                            <td class="fw-bold text-danger" id="tdTotalPit" style="font-size:1.1rem;"></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>

        <div class="admin-panel">
            <h5 class="fw-bold mb-4"><i class="fas fa-history text-muted me-2"></i>Lịch sử thao tác (Audit Log)</h5>
            <div class="table-responsive">
                <table class="tbl">
                    <thead>
                        <tr>
                            <th>Thời gian</th>
                            <th>Người thực hiện</th>
                            <th>Hành động</th>
                            <th>Chi tiết</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${auditLogs}">
                            <tr>
                                <td><fmt:formatDate value="${log.changedAt}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                <td class="fw-bold">${log.changedByName}</td>
                                <td><span class="badge bg-secondary">${log.action}</span></td>
                                <td style="font-size:0.85rem;" class="text-muted">${log.description}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty auditLogs}">
                            <tr><td colspan="4" class="text-center text-muted">Chưa có lịch sử.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    // Xử lý chuỗi JSON từ backend để render table
    document.addEventListener("DOMContentLoaded", function() {
        const breakdownJson = '${taxResult.pitBreakdown}';
        const tbody = document.querySelector('#breakdownTable tbody');
        
        if (breakdownJson && breakdownJson !== '[]') {
            try {
                const breakdown = JSON.parse(breakdownJson);
                let html = '';
                let totalTaxable = 0;
                let totalPit = 0;
                
                breakdown.forEach(item => {
                    totalTaxable += item.taxableAmount;
                    totalPit += item.pitAmount;
                    
                    const fromStr = new Intl.NumberFormat('vi-VN').format(item.from);
                    const toStr = item.to !== null ? new Intl.NumberFormat('vi-VN').format(item.to) : 'Trở lên';
                    
                    html += `<tr>
                        <td class="fw-bold">Bậc \${item.bracket}</td>
                        <td>\${fromStr} - \${toStr}</td>
                        <td class="text-danger fw-bold">\${item.rate}%</td>
                        <td class="fw-bold text-primary">\${new Intl.NumberFormat('vi-VN').format(item.taxableAmount)} ₫</td>
                        <td class="fw-bold text-danger">\${new Intl.NumberFormat('vi-VN').format(item.pitAmount)} ₫</td>
                    </tr>`;
                });
                
                tbody.innerHTML = html;
                document.getElementById('tdTotalTaxable').innerText = new Intl.NumberFormat('vi-VN').format(totalTaxable) + ' ₫';
                document.getElementById('tdTotalPit').innerText = new Intl.NumberFormat('vi-VN').format(totalPit) + ' ₫';
            } catch (e) {
                console.error("Error parsing breakdown JSON", e);
                tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Lỗi hiển thị chi tiết.</td></tr>';
            }
        } else {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">Không phát sinh thuế.</td></tr>';
            document.getElementById('tdTotalTaxable').innerText = '0 ₫';
            document.getElementById('tdTotalPit').innerText = '0 ₫';
        }
    });
</script>


</body>
</html>

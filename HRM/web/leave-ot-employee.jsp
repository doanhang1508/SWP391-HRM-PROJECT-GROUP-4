<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Leave & Overtime Management - Employee</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
        <jsp:include page="header.jsp" />

        <div class="container mt-5">
            <h2 class="mb-4">Leave & Overtime Management</h2>

            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show">
                    ${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show">
                    ${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <div class="row">
                <!-- LEAVE REQUEST SECTION -->
                <div class="col-md-6 mb-4">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-primary text-white">
                            <h4 class="mb-0">Submit Leave Request</h4>
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info">
                                <strong>Remaining Annual Leave:</strong>
                                <fmt:formatNumber value="${remainingAnnualLeave}" maxFractionDigits="1"/> Days
                            </div>
                            <form action="${pageContext.request.contextPath}/employee/leave-ot" method="POST">
                                <input type="hidden" name="action" value="submitLeave">

                                <div class="mb-3">
                                    <label for="leaveTypeId" class="form-label">Leave Type</label>
                                    <select class="form-select" id="leaveTypeId" name="leaveTypeId" required>
                                        <option value="" disabled selected>Select Leave Type</option>
                                        <c:forEach var="lType" items="${leaveTypes}">
                                            <c:choose>
                                                <c:when test="${lType.paidLeave}">
                                                    <option value="${lType.leaveTypeId}">${lType.typeName} (Paid)</option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="${lType.leaveTypeId}">${lType.typeName} (Unpaid)</option>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="startDate" class="form-label">Start Date</label>
                                        <input type="date" class="form-control" id="startDate" name="startDate" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="endDate" class="form-label">End Date</label>
                                        <input type="date" class="form-control" id="endDate" name="endDate" required>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="totalDays" class="form-label">Total Days</label>
                                    <input type="number" step="0.5" class="form-control" id="totalDays" name="totalDays" required placeholder="e.g., 1.5">
                                </div>

                                <div class="mb-3">
                                    <label for="reason" class="form-label">Reason</label>
                                    <textarea class="form-control" id="reason" name="reason" rows="3" required></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary w-100">Submit Leave Request</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- OVERTIME REQUEST SECTION -->
                <div class="col-md-6 mb-4">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-success text-white">
                            <h4 class="mb-0">Submit Overtime Request</h4>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/employee/leave-ot" method="POST">
                                <input type="hidden" name="action" value="submitOT">

                                <div class="mb-3">
                                    <label for="workDate" class="form-label">Work Date</label>
                                    <input type="date" class="form-control" id="workDate" name="workDate" required>
                                </div>

                                <div class="mb-3">
                                    <label for="shiftId" class="form-label">Shift ID (Related Shift)</label>
                                    <input type="number" class="form-control" id="shiftId" name="shiftId" required>
                                </div>

                                <div class="mb-3">
                                    <label for="estimatedHours" class="form-label">Estimated OT Hours</label>
                                    <input type="number" step="0.5" class="form-control" id="estimatedHours" name="estimatedHours" required>
                                </div>

                                <div class="mb-3">
                                    <label for="otReason" class="form-label">Description / Reason</label>
                                    <textarea class="form-control" id="otReason" name="otReason" rows="3" required></textarea>
                                </div>

                                <button type="submit" class="btn btn-success w-100">Submit OT Request</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- HISTORY TABLES -->
            <ul class="nav nav-tabs mt-4" id="historyTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="leave-tab" data-bs-toggle="tab" data-bs-target="#leaveHistory" type="button" role="tab">Leave History</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="ot-tab" data-bs-toggle="tab" data-bs-target="#otHistory" type="button" role="tab">Overtime History</button>
                </li>
            </ul>

            <div class="tab-content border border-top-0 p-3 bg-white mb-5" id="historyTabsContent">
                <!-- Leave History -->
                <div class="tab-pane fade show active" id="leaveHistory" role="tabpanel">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Type</th>
                                    <th>Start Date</th>
                                    <th>End Date</th>
                                    <th>Days</th>
                                    <th>Reason</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="lr" items="${leaveHistory}">
                                    <tr>
                                        <td>${lr.leaveTypeName}</td>
                                        <td>${lr.startDate}</td>
                                        <td>${lr.endDate}</td>
                                        <td>${lr.totalDays}</td>
                                        <td>${lr.reason}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${lr.status == 'Approved'}">
                                                    <span class="badge bg-success">${lr.status}</span>
                                                </c:when>
                                                <c:when test="${lr.status == 'Rejected'}">
                                                    <span class="badge bg-danger">${lr.status}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning">${lr.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty leaveHistory}">
                                    <tr><td colspan="6" class="text-center text-muted">No leave requests found.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- OT History -->
                <div class="tab-pane fade" id="otHistory" role="tabpanel">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Date</th>
                                    <th>Shift</th>
                                    <th>OT Hours</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="ot" items="${otHistory}">
                                    <tr>
                                        <td>${ot.workDate}</td>
                                        <td>${ot.shiftName}</td>
                                        <td>${ot.overtimeHrs}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ot.status == 'Present'}">
                                                    <span class="badge bg-success">Approved</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning">${ot.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty otHistory}">
                                    <tr><td colspan="4" class="text-center text-muted">No overtime requests found.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>

        <jsp:include page="footer.jsp" />
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
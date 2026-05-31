<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Leave & Overtime Approvals - Manager</title>
            <!-- Add standard CSS links here, e.g., Bootstrap -->
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        </head>

        <body>
            <jsp:include page="header.jsp" />

            <div class="container mt-5">
                <h2 class="mb-4">Department Approvals</h2>

                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-dismissible fade show">
                        ${sessionScope.successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="successMessage" scope="session" />
                </c:if>

                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        ${sessionScope.errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="errorMessage" scope="session" />
                </c:if>

                <ul class="nav nav-tabs" id="approvalTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="leave-tab" data-bs-toggle="tab"
                            data-bs-target="#leaveApprovals" type="button" role="tab">Pending Leave Requests</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="ot-tab" data-bs-toggle="tab" data-bs-target="#otApprovals"
                            type="button" role="tab">Pending OT Requests</button>
                    </li>
                </ul>

                <div class="tab-content border border-top-0 p-3 bg-white mb-5" id="approvalTabsContent">
                    <!-- Leave Approvals -->
                    <div class="tab-pane fade show active" id="leaveApprovals" role="tabpanel">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>Employee</th>
                                        <th>Type</th>
                                        <th>Dates</th>
                                        <th>Days</th>
                                        <th>Reason</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="lr" items="${pendingLeaves}">
                                        <tr>
                                            <td><strong>${lr.userName}</strong></td>
                                            <td>${lr.leaveTypeName}</td>
                                            <td>${lr.startDate} to ${lr.endDate}</td>
                                            <td>${lr.totalDays}</td>
                                            <td>${lr.reason}</td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/manager/leave-ot"
                                                    method="POST" class="d-inline">
                                                    <input type="hidden" name="type" value="leave">
                                                    <input type="hidden" name="id" value="${lr.requestId}">
                                                    <button type="submit" name="action" value="approve"
                                                        class="btn btn-sm btn-success">Approve</button>
                                                    <button type="submit" name="action" value="reject"
                                                        class="btn btn-sm btn-danger">Reject</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty pendingLeaves}">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted">No pending leave requests.
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- OT Approvals -->
                    <div class="tab-pane fade" id="otApprovals" role="tabpanel">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>Employee</th>
                                        <th>Work Date</th>
                                        <th>Shift</th>
                                        <th>Requested Hours</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="ot" items="${pendingOTs}">
                                        <tr>
                                            <td><strong>${ot.userName}</strong></td>
                                            <td>${ot.workDate}</td>
                                            <td>${ot.shiftName}</td>
                                            <td>${ot.overtimeHrs}</td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/manager/leave-ot"
                                                    method="POST" class="d-inline">
                                                    <input type="hidden" name="type" value="ot">
                                                    <input type="hidden" name="id" value="${ot.attendanceId}">
                                                    <button type="submit" name="action" value="approve"
                                                        class="btn btn-sm btn-success">Approve</button>
                                                    <button type="submit" name="action" value="reject"
                                                        class="btn btn-sm btn-danger">Reject</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty pendingOTs}">
                                        <tr>
                                            <td colspan="5" class="text-center text-muted">No pending overtime requests.
                                            </td>
                                        </tr>
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
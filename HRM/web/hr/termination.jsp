<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Employee Termination Workflow</title>
</head>
<body>
    <h2>HR: Terminate Employee Workflow</h2>
    
    <c:if test="${not empty message}">
        <p style="color: green;">${message}</p>
    </c:if>
    <c:if test="${not empty error}">
        <p style="color: red;">${error}</p>
    </c:if>

    <div style="border: 1px solid #ccc; padding: 10px;">
        <form action="${pageContext.request.contextPath}/hr/terminate-employee" method="post">
            User ID: <input type="number" name="userId" required><br><br>
            Reason for Termination: <br>
            <textarea name="reason" rows="3" cols="30" required></textarea><br><br>
            Termination Date (End Date): <input type="date" name="terminationDate" required><br><br>
            <button type="submit" style="color: white; background-color: red;">Execute Termination</button>
        </form>
    </div>

    <br>
    <a href="test_dashboard.jsp">Back to Dashboard</a>
</body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manual Reward & Discipline Entry</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f4f7f6; }
        .form-container {
            max-width: 600px;
            margin: 50px auto;
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>

<div class="container">
    <div class="form-container">
        <h3 class="mb-4 text-center">Enter Reward / Discipline</h3>

        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <form action="manual-reward-discipline" method="post">
            <div class="mb-3">
                <label for="userId" class="form-label">Employee ID</label>
                <input type="number" class="form-control" id="userId" name="userId" required>
            </div>
            
            <div class="mb-3">
                <label for="rewardDisciplineId" class="form-label">Type</label>
                <select class="form-select" id="rewardDisciplineId" name="rewardDisciplineId" required>
                    <option value="">Select Category...</option>
                    <c:forEach var="type" items="${types}">
                        <option value="${type.id}">${type.name} (${type.type})</option>
                    </c:forEach>
                </select>
            </div>
            
            <div class="mb-3">
                <label for="amount" class="form-label">Amount (VND)</label>
                <input type="number" step="0.01" class="form-control" id="amount" name="amount" required>
            </div>
            
            <div class="mb-3">
                <label for="note" class="form-label">Note / Reason</label>
                <textarea class="form-control" id="note" name="note" rows="3" required></textarea>
            </div>
            
            <div class="mb-3">
                <label for="appliedDate" class="form-label">Applied Date</label>
                <input type="date" class="form-control" id="appliedDate" name="appliedDate" required>
            </div>
            
            <div class="d-grid gap-2">
                <button type="submit" class="btn btn-primary">Submit Record</button>
            </div>
        </form>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

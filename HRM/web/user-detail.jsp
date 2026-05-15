<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Detail</title>

    <style>
        body{
            font-family: Arial;
            margin: 30px;
        }

        .box{
            width: 400px;
            border: 1px solid gray;
            padding: 20px;
            border-radius: 10px;
        }

        p{
            font-size: 18px;
        }

        a{
            text-decoration: none;
            color: blue;
        }
    </style>

</head>
<body>

    <%
    User u = (User) request.getAttribute("user");

    if(u == null){
%>

    <h2>User not found!</h2>

<%
        return;
    }
%>

    <h1>User Detail</h1>

    <div class="box">

        <p><b>ID:</b> <%=u.getId()%></p>

        <p><b>Full Name:</b> <%=u.getFullName()%></p>

        <p><b>Email:</b> <%=u.getEmail()%></p>
        
        <p><b>Department:</b> <%=u.getDepartment()%></p>

        <p><b>Role:</b> <%=u.getRole()%></p>

        <p><b>Status:</b>
            <%=u.isStatus() ? "Active" : "Inactive"%>
        </p>

    </div>

    <br>

    <a href="user-list">Back to User List</a>

</body>
</html>

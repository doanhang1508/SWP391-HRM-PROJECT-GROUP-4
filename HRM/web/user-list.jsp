<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.User"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User List</title>

    <style>
        body{
            font-family: Arial;
            margin: 30px;
        }

        table{
            width: 100%;
            border-collapse: collapse;
        }

        th, td{
            border: 1px solid black;
            padding: 10px;
            text-align: center;
        }

        th{
            background-color: #f2f2f2;
        }

        a{
            text-decoration: none;
            color: blue;
        }

        .btn{
            padding: 8px 15px;
            background-color: green;
            color: white;
            border-radius: 5px;
        }
    </style>

</head>
<body>

    <h1>User List</h1>

    <br>

    <a class="btn" href="add-user">
        Add New User
    </a>

    <br><br>

    <table>

        <tr>
            <th>ID</th>
            <th>Full Name</th>
            <th>Email</th>
            <th>Department</th>
            <th>Role</th>
            <th>Status</th>
            <th>Action</th>
        </tr>

        <%
            List<User> list =
                    (List<User>) request.getAttribute("userList");

            if(list != null){

                for(User u : list){
        %>

        <tr>

            <td><%=u.getId()%></td>

            <td><%=u.getFullName()%></td>

            <td><%=u.getEmail()%></td>
            
            <td><%=u.getDepartment()%></td>

            <td><%=u.getRole()%></td>

            <td>
                <%=u.isStatus() ? "Active" : "Inactive"%>
            </td>

            <td>
                <a href="user-detail/<%=u.getId()%>">
                    View
                </a>
            </td>

        </tr>

        <%
                }
            }
        %>

    </table>

</body>
</html>

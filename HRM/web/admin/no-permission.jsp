<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    public String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
%>

<%
    String error = (String) request.getAttribute("error");

    if (error == null) {
        error = "Bạn không có quyền truy cập chức năng này.";
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>No Permission</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            padding: 30px;
        }

        .box {
            background: white;
            max-width: 600px;
            margin: auto;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        h2 {
            color: #d63031;
        }

        a {
            color: #0984e3;
            text-decoration: none;
        }
    </style>
</head>

<body>
<div class="box">
    <h2>Access Denied</h2>
    <p><%= h(error) %></p>
    <a href="home.jsp">Quay lại trang chủ</a>
</div>
</body>
</html>

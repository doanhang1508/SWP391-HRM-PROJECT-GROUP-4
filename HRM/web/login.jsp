<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Đây là file MOCK LOGIN (để test nhanh)
    // Controller yêu cầu phải có session("user") nên ta set cứng ở đây để bypass phần kiểm tra đăng nhập
    session.setAttribute("user", "admin_test");
    response.sendRedirect("admin_dashboard.jsp");
%>

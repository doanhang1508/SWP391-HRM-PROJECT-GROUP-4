<%@page import="java.sql.Connection"%>
<%@page import="java.sql.Statement"%>
<%@page import="util.DBContext"%>
<%@page import="java.io.File"%>
<%@page import="java.nio.file.Files"%>
<%@page import="java.nio.file.Paths"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Chạy Migration</title>
</head>
<body>
    <h2>Đang chạy script cập nhật Database...</h2>
    <%
        try {
            // Đọc file SQL
            String sqlFilePath = application.getRealPath("/") + "../../database/resignation_v2_migration.sql";
            File file = new File(sqlFilePath);
            if (!file.exists()) {
                out.println("<p style='color:red'>Không tìm thấy file: " + file.getAbsolutePath() + "</p>");
            } else {
                String sqlContent = new String(Files.readAllBytes(Paths.get(sqlFilePath)), "UTF-8");
                String[] queries = sqlContent.split(";");

                try (Connection conn = DBContext.getConnection();
                     Statement stmt = conn.createStatement()) {
                    
                    for (String query : queries) {
                        String q = query.trim();
                        if (!q.isEmpty() && !q.startsWith("--") && !q.startsWith("/*")) {
                            // Bỏ qua các khối lệnh PREPARE/EXECUTE trong JDBC vì JDBC không cần thiết hoặc không hỗ trợ tốt nhiều statements
                            // Xử lý thủ công cho các lệnh tạo bảng và cập nhật cột
                            try {
                                stmt.execute(q);
                                out.println("<p style='color:green'>Chạy thành công: " + q.substring(0, Math.min(q.length(), 50)) + "...</p>");
                            } catch (Exception e) {
                                out.println("<p style='color:orange'>Bỏ qua/Lỗi (có thể đã tồn tại): " + e.getMessage() + "</p>");
                            }
                        }
                    }
                    out.println("<h3><span style='color:blue'>Hoàn thành! Bạn có thể quay lại hệ thống để sử dụng tính năng xin nghỉ việc.</span></h3>");
                }
            }
        } catch (Exception e) {
            out.println("<p style='color:red'>Lỗi hệ thống: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    %>
</body>
</html>

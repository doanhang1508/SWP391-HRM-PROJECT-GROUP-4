<%@page import="java.sql.Connection"%>
<%@page import="java.sql.Statement"%>
<%@page import="util.DBContext"%>
<%
    try {
        Connection conn = DBContext.getConnection();
        Statement stmt = conn.createStatement();

        // === Giảm trừ 2026 (Luật 109/2025/QH15) ===
        // Đóng mức cũ nếu còn active
        stmt.executeUpdate("UPDATE tax_deductions SET status=0, effective_to='2025-12-31' WHERE effective_from='2020-07-01' AND status=1");
        // Chèn mức mới
        stmt.executeUpdate("INSERT IGNORE INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, status, created_by) VALUES ('PERSONAL', 'Giảm trừ bản thân (Luật 109/2025)', 15500000, '2026-01-01', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, status, created_by) VALUES ('DEPENDENT', 'Giảm trừ người phụ thuộc (Luật 109/2025)', 6200000, '2026-01-01', 1, 1)");

        // === Biểu thuế 5 bậc 2026 ===
        // Đóng 7 bậc cũ nếu còn active
        stmt.executeUpdate("UPDATE tax_brackets SET status=0, effective_to='2025-12-31' WHERE effective_from='2020-01-01' AND status=1");
        // Chèn 5 bậc mới
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (1, 0, 10000000, 5.00, '2026-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (2, 10000000, 30000000, 10.00, '2026-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (3, 30000000, 60000000, 20.00, '2026-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (4, 60000000, 100000000, 30.00, '2026-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (5, 100000000, NULL, 35.00, '2026-01-01', 'HALF_UP', 1, 1)");

        // === Đồng bộ employee_tax_profiles ===
        stmt.executeUpdate("UPDATE employee_tax_profiles SET personal_deduction=15500000, dependent_deduction=6200000, updated_at=NOW() WHERE status=1");

        out.println("SEED 2026 SUCCESS!");
    } catch (Exception e) {
        out.println("SEED FAILED: " + e.getMessage());
    }
%>

<%@page import="java.sql.Connection"%>
<%@page import="java.sql.Statement"%>
<%@page import="util.DBContext"%>
<%
    try {
        Connection conn = DBContext.getConnection();
        Statement stmt = conn.createStatement();
        
        // Seed Deductions
        stmt.executeUpdate("INSERT IGNORE INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, status, created_by) VALUES ('PERSONAL', 'Giảm trừ bản thân', 11000000, '2020-01-01', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, status, created_by) VALUES ('DEPENDENT', 'Giảm trừ người phụ thuộc', 4400000, '2020-01-01', 1, 1)");
        
        // Seed Brackets
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (1, 0, 5000000, 5.00, '2020-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (2, 5000000, 10000000, 10.00, '2020-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (3, 10000000, 18000000, 15.00, '2020-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (4, 18000000, 32000000, 20.00, '2020-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (5, 32000000, 52000000, 25.00, '2020-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (6, 52000000, 80000000, 30.00, '2020-01-01', 'HALF_UP', 1, 1)");
        stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (7, 80000000, NULL, 35.00, '2020-01-01', 'HALF_UP', 1, 1)");
        
        out.println("SEED SUCCESS!");
    } catch (Exception e) {
        out.println("SEED FAILED: " + e.getMessage());
    }
%>

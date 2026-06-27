import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class SeedData {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/hrm_system";
        String user = "root";
        String password = "123456";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            Statement stmt = conn.createStatement();
            
            // Create Table tax_brackets
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS tax_brackets (" +
                "bracket_id INT PRIMARY KEY AUTO_INCREMENT, " +
                "bracket_no INT NOT NULL, " +
                "income_from DECIMAL(15,2) NOT NULL, " +
                "income_to DECIMAL(15,2) NULL, " +
                "rate DECIMAL(5,2) NOT NULL, " +
                "effective_from DATE NOT NULL, " +
                "effective_to DATE NULL, " +
                "rounding_rule VARCHAR(20) NOT NULL DEFAULT 'HALF_UP', " +
                "status TINYINT(1) NOT NULL DEFAULT 1, " +
                "created_by INT NULL, " +
                "updated_by INT NULL, " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
                
            // Create Table tax_deductions
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS tax_deductions (" +
                "deduction_id INT PRIMARY KEY AUTO_INCREMENT, " +
                "deduction_type VARCHAR(50) NOT NULL, " +
                "deduction_name VARCHAR(100) NOT NULL, " +
                "amount DECIMAL(15,2) NOT NULL, " +
                "effective_from DATE NOT NULL, " +
                "effective_to DATE NULL, " +
                "status TINYINT(1) NOT NULL DEFAULT 1, " +
                "created_by INT NULL, " +
                "updated_by INT NULL, " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
            
            // Seed Deductions
            stmt.executeUpdate("INSERT IGNORE INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, status, created_by) VALUES ('personal', 'Giảm trừ bản thân', 11000000, '2020-01-01', 1, 1)");
            stmt.executeUpdate("INSERT IGNORE INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, status, created_by) VALUES ('dependent', 'Giảm trừ người phụ thuộc', 4400000, '2020-01-01', 1, 1)");
            
            // Seed Brackets
            stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (1, 0, 5000000, 5.00, '2020-01-01', 'HALF_UP', 1, 1)");
            stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (2, 5000000, 10000000, 10.00, '2020-01-01', 'HALF_UP', 1, 1)");
            stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (3, 10000000, 18000000, 15.00, '2020-01-01', 'HALF_UP', 1, 1)");
            stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (4, 18000000, 32000000, 20.00, '2020-01-01', 'HALF_UP', 1, 1)");
            stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (5, 32000000, 52000000, 25.00, '2020-01-01', 'HALF_UP', 1, 1)");
            stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (6, 52000000, 80000000, 30.00, '2020-01-01', 'HALF_UP', 1, 1)");
            stmt.executeUpdate("INSERT IGNORE INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES (7, 80000000, NULL, 35.00, '2020-01-01', 'HALF_UP', 1, 1)");
            
            System.out.println("SEED SUCCESS!");
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

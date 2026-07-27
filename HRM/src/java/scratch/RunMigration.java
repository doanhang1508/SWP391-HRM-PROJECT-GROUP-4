package scratch;

import util.DBContext;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.SQLException;

public class RunMigration {
    public static void main(String[] args) {
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             Statement stmt = conn.createStatement()) {
            
            stmt.executeUpdate("DELETE FROM attendance_claims WHERE user_id = 27");
            stmt.executeUpdate("DELETE FROM attendance WHERE user_id = 27");
            stmt.executeUpdate("DELETE FROM leave_requests WHERE user_id = 27");
            stmt.executeUpdate("DELETE FROM payroll WHERE user_id = 27");
            stmt.executeUpdate("DELETE FROM shift_assignments WHERE user_id = 27");
            stmt.executeUpdate("DELETE FROM employee_contracts WHERE user_id = 27");
            stmt.executeUpdate("DELETE FROM employee_profiles WHERE user_id = 27");
            stmt.executeUpdate("DELETE FROM users WHERE user_id = 27");
            stmt.executeUpdate("DELETE FROM leave_requests WHERE leave_type_id = 3");
            stmt.executeUpdate("DELETE FROM leave_insurance_rates WHERE leave_type_id = 3");
            stmt.executeUpdate("DELETE FROM leave_types WHERE leave_type_id = 3");

            System.out.println("Successfully removed user 27 and leave type 3.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

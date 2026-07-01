package scratch;

import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class TestDB {
    public static void main(String[] args) {
        try (Connection conn = DBContext.getConnection()) {
            String sql = "SELECT contract_id, contract_type_id, status FROM employee_contracts WHERE user_id = 20";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                java.sql.ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    System.out.println("ID: " + rs.getInt("contract_id") + " Type: " + rs.getInt("contract_type_id") + " Status: " + rs.getString("status"));
                }
            }
            
            // Just update all where contract_id != the newest one (let's say 25 is newest)
            // Wait, let's just set the lowest contract_id to Terminated
            String updateSql = "UPDATE employee_contracts SET status = 'Active' WHERE contract_id = 12";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                int rows = ps.executeUpdate();
                System.out.println("Reverted " + rows + " contracts back to Active");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

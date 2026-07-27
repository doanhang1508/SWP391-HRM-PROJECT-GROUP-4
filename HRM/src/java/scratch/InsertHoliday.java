package scratch;
import java.sql.Connection;
import java.sql.PreparedStatement;
import util.DBContext;

public class InsertHoliday {
    public static void main(String[] args) {
        String sql = "INSERT IGNORE INTO holidays (holiday_name, holiday_date, holiday_year, source, calendar_type, ot_multiplier, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setString(1, "Nghỉ lễ theo yêu cầu (15/07)");
            ps.setString(2, "2026-07-15");
            ps.setInt(3, 2026);
            ps.setString(4, "MANUAL");
            ps.setString(5, "SOLAR");
            ps.setDouble(6, 3.00); 
            ps.setInt(7, 1);
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("Thêm thành công ngày lễ 15/07/2026 vào cơ sở dữ liệu!");
            } else {
                System.out.println("Ngày lễ 15/07/2026 đã tồn tại trong cơ sở dữ liệu.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

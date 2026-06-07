import util.DBContext;
import java.sql.Connection;
import java.sql.Statement;

public class DBUpdate {
    public static void main(String[] args) {
        try (Connection c = DBContext.getConnection();
             Statement stmt = c.createStatement()) {
            
            try {
                stmt.execute("CREATE INDEX idx_user_id ON shift_assignments(user_id)");
                System.out.println("Added idx_user_id");
            } catch(Exception e) {
                System.out.println("Could not add idx_user_id: " + e.getMessage());
            }

            try {
                stmt.execute("ALTER TABLE shift_assignments DROP INDEX idx_user_date");
                System.out.println("Dropped idx_user_date");
            } catch(Exception e) {
                System.out.println("Could not drop idx_user_date: " + e.getMessage());
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

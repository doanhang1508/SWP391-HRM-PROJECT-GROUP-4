package scheduler;

import dao.UserDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import util.DBContext;
import java.sql.ResultSet;

@WebListener
public class ResignationSchedulerListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        
        // Chạy lúc khởi động và lặp lại mỗi ngày
        scheduler.scheduleAtFixedRate(this::processDailyTasks, 0, 1, TimeUnit.DAYS);
    }

    private void processDailyTasks() {
        System.out.println("[Scheduler] Bắt đầu chạy các tác vụ hàng ngày (Resignation & Contract)...");
        try {
            processExpiredContracts();
            processNoticePeriodEnds();
        } catch (Exception e) {
            System.err.println("[Scheduler] Lỗi khi chạy tác vụ hàng ngày: " + e.getMessage());
        }
    }
    
    private void processExpiredContracts() {
        // Tự động chuyển hợp đồng đã quá hạn end_date sang trạng thái Expired (nếu chưa được gia hạn)
        String sql = "UPDATE employee_contracts SET status = 'Expired' WHERE status = 'Active' AND end_date IS NOT NULL AND end_date < CURDATE()";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int updated = ps.executeUpdate();
            if (updated > 0) {
                System.out.println("[Scheduler] Đã cập nhật " + updated + " hợp đồng thành Expired.");
            }
        } catch (Exception e) {
            System.err.println("[Scheduler] processExpiredContracts error: " + e.getMessage());
        }
    }
    
    private void processNoticePeriodEnds() {
        // Tìm các nhân viên đang trong NoticePeriod (status_id = 5) mà resignation request được duyệt (COMPLETED hoặc APPROVED)
        // và ngày last_working_day <= hôm nay, thì vô hiệu hóa tài khoản và terminate hợp đồng.
        String sql = "SELECT r.user_id, r.last_working_day " +
                     "FROM resignation_requests r " +
                     "JOIN employee_profiles ep ON r.user_id = ep.user_id " +
                     "WHERE (r.status = 'APPROVED' OR r.status = 'COMPLETED') " +
                     "  AND ep.employment_status_id = 5 " +
                     "  AND r.last_working_day IS NOT NULL " +
                     "  AND r.last_working_day <= CURDATE()";
                     
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            UserDAO userDAO = new UserDAO();
            while (rs.next()) {
                int userId = rs.getInt("user_id");
                java.sql.Date lastWorkingDay = rs.getDate("last_working_day");
                
                boolean success = userDAO.approveResignation(userId, lastWorkingDay);
                if (success) {
                    System.out.println("[Scheduler] Đã vô hiệu hóa tài khoản và terminate hợp đồng cho userId=" + userId);
                }
            }
        } catch (Exception e) {
            System.err.println("[Scheduler] processNoticePeriodEnds error: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
            System.out.println("[Scheduler] Đã dừng scheduled tasks.");
        }
    }
}

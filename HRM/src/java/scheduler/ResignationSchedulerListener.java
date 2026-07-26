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
            notifyExpiringProbation();
        } catch (Exception e) {
            System.err.println("[Scheduler] Lỗi khi chạy tác vụ hàng ngày: " + e.getMessage());
        }
    }
    
    public static void processExpiredContracts() {
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
    
    public static void processNoticePeriodEnds() {
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

    /**
     * Gửi thông báo cho HR Staff và HR Manager khi hợp đồng thử việc sắp hết hạn trong 7 ngày.
     * Theo BLLĐ 2019 Điều 25: phải thông báo kết quả thử việc trước khi hết hạn.
     */
    public static void notifyExpiringProbation() {
        String sql = "SELECT ec.contract_id, ec.user_id, ec.end_date, u.full_name " +
                     "FROM employee_contracts ec " +
                     "JOIN users u ON ec.user_id = u.user_id " +
                     "WHERE ec.status = 'Active' " +
                     "  AND ec.contract_type_id = 1 " +
                     "  AND ec.end_date IS NOT NULL " +
                     "  AND ec.end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            dao.notificationDAO notifDao = new dao.notificationDAO();
            while (rs.next()) {
                String employeeName = rs.getString("full_name");
                java.sql.Date endDate = rs.getDate("end_date");
                String msg = "Hợp đồng thử việc của " + employeeName + " sẽ hết hạn vào " + endDate
                           + ". Cần ký hợp đồng chính thức hoặc thông báo kết quả thử việc (BLLĐ 2019 Điều 25).";
                notifDao.createForRoles(new int[]{2, 5}, "contract",
                    "⚠️ Hợp đồng thử việc sắp hết hạn: " + employeeName, msg,
                    "/hr/contract-expired");
                System.out.println("[Scheduler] Đã gửi cảnh báo thử việc hết hạn cho: " + employeeName);
            }
        } catch (Exception e) {
            System.err.println("[Scheduler] notifyExpiringProbation error: " + e.getMessage());
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

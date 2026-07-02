ackage scheduler;

import dao.TransferRequestDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * TransferSchedulerListener — Xu ly don dieu chuyen theo effective_date.
 *
 * Moi ngay, scheduler se quet cac don co:
 *   status = 'APPROVED' AND applied_at IS NULL AND effective_date <= CURDATE()
 * va goi TransferRequestDAO.processElapsedEffectiveTransfers() de ap dung.
 *
 * Pattern giong ResignationSchedulerListener.java.
 */
@WebListener
public class TransferSchedulerListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "transfer-effective-date-scheduler");
            t.setDaemon(true);
            return t;
        });

        // Chay ngay khi server khoi dong (delay=0), sau do moi 24 gio mot lan
        scheduler.scheduleAtFixedRate(() -> {
            try {
                System.out.println("[TransferScheduler] Bat dau quet don dieu chuyen can ap dung...");
                TransferRequestDAO dao = new TransferRequestDAO();
                int count = dao.processElapsedEffectiveTransfers();
                System.out.println("[TransferScheduler] Da xu ly " + count + " don dieu chuyen co hieu luc.");
            } catch (Exception e) {
                System.err.println("[TransferScheduler] Loi khi chay scheduler: " + e.getMessage());
                e.printStackTrace();
            }
        }, 0, 1, TimeUnit.DAYS);

        System.out.println("[TransferScheduler] Scheduler khoi dong thanh cong.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            System.out.println("[TransferScheduler] Scheduler da dung.");
        }
    }
}

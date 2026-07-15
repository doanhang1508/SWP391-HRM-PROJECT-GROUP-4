package listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import service.HolidayGeneratorService;

import java.time.LocalDate;

@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AppStartupListener] Application started. Initializing background tasks...");
        
        try {
            HolidayGeneratorService holidayService = new HolidayGeneratorService();
            int currentYear = LocalDate.now().getYear();
            
            // Generate for current year
            if (holidayService.generateHolidaysForYear(currentYear)) {
                System.out.println("[AppStartupListener] Automatically generated holidays for year: " + currentYear);
            } else {
                System.out.println("[AppStartupListener] Holidays for year " + currentYear + " already exist.");
            }
            
            // Generate for next year (proactive)
            if (holidayService.generateHolidaysForYear(currentYear + 1)) {
                System.out.println("[AppStartupListener] Automatically generated holidays for year: " + (currentYear + 1));
            } else {
                System.out.println("[AppStartupListener] Holidays for year " + (currentYear + 1) + " already exist.");
            }
        } catch (Exception e) {
            System.err.println("[AppStartupListener] Error generating holidays on startup:");
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AppStartupListener] Application context destroyed.");
    }
}

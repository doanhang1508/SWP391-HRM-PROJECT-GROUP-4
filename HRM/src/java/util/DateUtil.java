package util;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;

public class DateUtil {
    
    /**
     * TÃ­nh sá»‘ ngÃ y cÃ´ng chuáº©n trong má»™t thÃ¡ng vÃ  nÄƒm cá»¥ thá»ƒ.
     * Quy táº¯c: Tá»•ng sá»‘ ngÃ y trong thÃ¡ng - Sá»‘ ngÃ y Chá»§ Nháº­t.
     * 
     * @param month ThÃ¡ng (1-12)
     * @param year NÄƒm
     * @return Sá»‘ ngÃ y cÃ´ng chuáº©n
     */
    public static int getStandardWorkDays(int month, int year) {
        YearMonth yearMonth = YearMonth.of(year, month);
        int daysInMonth = yearMonth.lengthOfMonth();
        int sundays = 0;
        
        for (int i = 1; i <= daysInMonth; i++) {
            LocalDate date = LocalDate.of(year, month, i);
            if (date.getDayOfWeek() == DayOfWeek.SUNDAY) {
                sundays++;
            }
        }
        
        return daysInMonth - sundays;
    }
}

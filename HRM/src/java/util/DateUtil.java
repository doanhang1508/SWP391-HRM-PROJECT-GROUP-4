package util;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;

public class DateUtil {
    
  
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

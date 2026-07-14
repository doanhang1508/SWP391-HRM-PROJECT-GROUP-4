package util;

/**
 * Thuật toán tính lịch âm Việt Nam của Hồ Ngọc Đức.
 * Tham khảo từ mã nguồn mở (public domain).
 */
public class LunarCalendarConverter {
    
    // =========================================================================
    // Các hằng số thiên văn (thay đổi theo từng múi giờ)
    // VN múi giờ +7, timezone = 7.
    // =========================================================================
    
    private static final double PI = Math.PI;
    private static final int TIMEZONE = 7;
    
    public static int[] convertLunar2Solar(int lunarDay, int lunarMonth, int lunarYear, int lunarLeap, int timeZone) {
        if (lunarMonth == 0) {
            return new int[]{0, 0, 0};
        }
        
        int k, a11, b11, off, leapOff, leapMonth, monthStart;
        if (lunarMonth < 11) {
            a11 = getLunarMonth11(lunarYear - 1, timeZone);
            b11 = getLunarMonth11(lunarYear, timeZone);
        } else {
            a11 = getLunarMonth11(lunarYear, timeZone);
            b11 = getLunarMonth11(lunarYear + 1, timeZone);
        }
        k = (int) (0.5 + (a11 - 2415021.076998695) / 29.530588853);
        off = k + lunarMonth - 11;
        if (lunarMonth < 11) off++;
        if (hasLeapMonth(a11, b11)) {
            leapMonth = getLeapMonthOffset(a11, timeZone);
            leapOff = leapMonth - 11;
            if (leapMonth < 11) leapOff++;
            if (lunarLeap != 0 && lunarMonth == leapMonth) {
                off = k + leapOff + 1;
            } else if (lunarMonth > leapMonth || (lunarMonth == leapMonth && lunarLeap == 0)) {
                off = k + lunarMonth - 11;
                if (lunarMonth < 11) off++;
                if (off >= k + leapOff) off++;
            }
        }
        monthStart = getNewMoonDay(off, timeZone);
        return jdToDate(monthStart + lunarDay - 1);
    }
    
    public static int[] convertSolar2Lunar(int dd, int mm, int yy, int timeZone) {
        int dayNumber, k, a11, b11, monthStart, leapMonth, leapOff, lunarDay, lunarMonth, lunarYear, lunarLeap;
        
        dayNumber = jdFromDate(dd, mm, yy);
        k = (int) Math.floor((dayNumber - 2415021.076998695) / 29.530588853);
        monthStart = getNewMoonDay(k + 1, timeZone);
        if (monthStart > dayNumber) {
            monthStart = getNewMoonDay(k, timeZone);
        } else {
            k++;
        }
        a11 = getLunarMonth11(yy, timeZone);
        b11 = a11;
        if (a11 >= monthStart) {
            lunarYear = yy;
            a11 = getLunarMonth11(yy - 1, timeZone);
        } else {
            lunarYear = yy + 1;
            b11 = getLunarMonth11(yy + 1, timeZone);
        }
        lunarDay = dayNumber - monthStart + 1;
        int diff = k - (int) (0.5 + (a11 - 2415021.076998695) / 29.530588853);
        lunarLeap = 0;
        lunarMonth = diff + 11;
        if (hasLeapMonth(a11, b11)) {
            leapMonth = getLeapMonthOffset(a11, timeZone);
            leapOff = leapMonth - 11;
            if (leapMonth < 11) {
                leapOff++;
            }
            if (diff == leapOff + 1) {
                lunarLeap = 1;
                lunarMonth = leapMonth;
            } else if (diff > leapOff + 1) {
                lunarMonth = diff + 10;
            }
        }
        if (lunarMonth > 12) lunarMonth -= 12;
        if (lunarMonth >= 11 && diff < 4) lunarYear--;
        
        return new int[]{lunarDay, lunarMonth, lunarYear, lunarLeap};
    }

    private static double getSunLongitude(double jdn, int timeZone) {
        double T = (jdn - 2451545.0) / 36525.0;
        double L0 = 280.46646 + T * (36000.76983 + T * 0.0003032);
        double M = 357.52911 + T * (35999.05029 - T * 0.0001537);
        double e = 0.016708634 - T * (0.000042037 + 0.0000001267 * T);
        double C = (1.914602 - T * (0.004817 + 0.000014 * T)) * Math.sin(M * PI / 180) +
                   (0.019993 - 0.000101 * T) * Math.sin(2 * M * PI / 180) +
                   0.000289 * Math.sin(3 * M * PI / 180);
        double theta = L0 + C;
        return theta - 360 * Math.floor(theta / 360);
    }
    
    private static int getNewMoonDay(int k, int timeZone) {
        double T, T2, T3, dr, J, M, Mpr, F, C1, pt;
        T = k / 1236.85;
        T2 = T * T;
        T3 = T2 * T;
        dr = PI / 180;
        J = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3
            + 0.00033 * Math.sin((166.56 + 132.87 * T - 0.009173 * T2) * dr);
        M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3;
        Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3;
        F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3;
        C1 = (0.1734 - 0.000393 * T) * Math.sin(M * dr)
             + 0.0021 * Math.sin(2 * M * dr)
             - 0.4068 * Math.sin(Mpr * dr)
             + 0.0161 * Math.sin(2 * Mpr * dr)
             - 0.0004 * Math.sin(3 * Mpr * dr)
             + 0.0104 * Math.sin(2 * F * dr)
             - 0.0051 * Math.sin((M + Mpr) * dr)
             - 0.0074 * Math.sin((M - Mpr) * dr)
             + 0.0004 * Math.sin((2 * F + M) * dr)
             - 0.0004 * Math.sin((2 * F - M) * dr)
             - 0.0006 * Math.sin((2 * F + Mpr) * dr)
             + 0.0010 * Math.sin((2 * F - Mpr) * dr)
             + 0.0005 * Math.sin((M + 2 * Mpr) * dr);
        pt = J + C1;
        return (int) Math.floor(pt + 0.5 + timeZone / 24.0);
    }
    
    private static int getSunLongitudeExt(double jdn, int timeZone) {
        return (int) Math.floor(getSunLongitude(jdn - 0.5 - timeZone / 24.0, timeZone) / 30.0);
    }
    
    private static int getLunarMonth11(int yy, int timeZone) {
        int off = jdFromDate(31, 12, yy) - 2415021;
        int k = (int) Math.floor(off / 29.530588853);
        int nm = getNewMoonDay(k, timeZone);
        int sunLong = getSunLongitudeExt(nm, timeZone);
        if (sunLong >= 9) nm = getNewMoonDay(k - 1, timeZone);
        return nm;
    }
    
    private static int getLeapMonthOffset(int a11, int timeZone) {
        int k, last, arc, i;
        k = (int) Math.floor((a11 - 2415021.076998695) / 29.530588853);
        last = 0;
        i = 1;
        arc = getSunLongitudeExt(getNewMoonDay(k + i, timeZone), timeZone);
        do {
            last = arc;
            i++;
            arc = getSunLongitudeExt(getNewMoonDay(k + i, timeZone), timeZone);
        } while (arc != last && i < 14);
        return i - 1;
    }
    
    private static boolean hasLeapMonth(int a11, int b11) {
        return (int) Math.floor(b11 + 0.5) - (int) Math.floor(a11 + 0.5) > 355;
    }
    
    private static int jdFromDate(int dd, int mm, int yy) {
        int a, y, m;
        a = (14 - mm) / 12;
        y = yy + 4800 - a;
        m = mm + 12 * a - 3;
        return dd + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
    }
    
    private static int[] jdToDate(int jd) {
        int a, b, c, d, e, m, day, month, year;
        a = jd + 32044;
        b = (4 * a + 3) / 146097;
        c = a - (146097 * b) / 4;
        d = (4 * c + 3) / 1461;
        e = c - (1461 * d) / 4;
        m = (5 * e + 2) / 153;
        day = e - (153 * m + 2) / 5 + 1;
        month = m + 3 - 12 * (m / 10);
        year = b * 100 + d - 4800 + m / 10;
        return new int[]{day, month, year};
    }
    
    // =========================================================================
    // Các phương thức tiện ích bọc gọn (sử dụng mặc định múi giờ = 7)
    // =========================================================================
    
    public static int[] convertLunar2Solar(int lunarDay, int lunarMonth, int lunarYear, int lunarLeap) {
        return convertLunar2Solar(lunarDay, lunarMonth, lunarYear, lunarLeap, TIMEZONE);
    }
    
    public static int[] convertSolar2Lunar(int day, int month, int year) {
        return convertSolar2Lunar(day, month, year, TIMEZONE);
    }
    
    public static void main(String[] args) {
        // Test 1: Tết 2026 (17/02/2026) -> Mùng 1 Tháng 1 Năm Bính Ngọ (Âm lịch)
        int[] lunar = convertSolar2Lunar(17, 2, 2026);
        System.out.println("Tết 2026 Solar (17/2/2026) -> Lunar: " + lunar[0] + "/" + lunar[1] + "/" + lunar[2]);
        
        // Test 2: Mùng 1 Tháng 1 Năm 2026 (Âm lịch) -> 17/02/2026 (Dương lịch)
        int[] solar = convertLunar2Solar(1, 1, 2026, 0);
        System.out.println("Tết 2026 Lunar (1/1/2026) -> Solar: " + solar[0] + "/" + solar[1] + "/" + solar[2]);
        
        // Test 3: Giỗ Tổ 2026 (26/04/2026) -> Mùng 10 Tháng 3 Năm Bính Ngọ (Âm lịch)
        int[] solarGioTo = convertLunar2Solar(10, 3, 2026, 0);
        System.out.println("Giỗ Tổ 2026 Lunar (10/3/2026) -> Solar: " + solarGioTo[0] + "/" + solarGioTo[1] + "/" + solarGioTo[2]);
    }
}

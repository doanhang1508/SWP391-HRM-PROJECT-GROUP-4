import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class TestDate {
    public static void main(String[] args) {
        String dateStr = "01/06/2026";
        try {
            LocalDate ld = LocalDate.parse(dateStr, DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            System.out.println(ld);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

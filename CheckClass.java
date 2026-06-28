import java.nio.file.Files;
import java.nio.file.Paths;

public class CheckClass {
    public static void main(String[] args) throws Exception {
        byte[] bytes = Files.readAllBytes(Paths.get("HRM/build/web/WEB-INF/classes/controller/hr/ImportAttendanceController.class"));
        String content = new String(bytes, "UTF-8");
        System.out.println("Contains Sai? " + content.contains("Sai"));
    }
}

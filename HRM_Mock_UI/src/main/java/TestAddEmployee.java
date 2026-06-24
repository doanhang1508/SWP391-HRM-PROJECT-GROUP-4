import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.Select;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;

/**
 * Test tự động chức năng: THÊM NHÂN VIÊN MỚI
 *
 * Cột H trong Excel = Expected Result (nội dung cụ thể, do người dùng tự nhập)
 * Cột I trong Excel = Actual Result  (Selenium tự điền sau khi chạy)
 *
 * Cách so sánh:
 *   Nếu Expected = "CANNOT FILL"  → Khi tool không điền được Dropdown → PASS
 *   Nếu Expected = nội dung khác  → So sánh với thông báo thực tế trên màn hình
 *       Khớp nhau  → PASS
 *       Không khớp → FAIL
 */
public class TestAddEmployee {

    public static void main(String[] args) throws Exception {

        // ==============================================================
        // BƯỚC 1: Khởi động Chrome
        // ==============================================================
        WebDriver driver = new ChromeDriver();
        driver.manage().window().maximize();

        // ==============================================================
        // BƯỚC 2: Đường dẫn file HTML và Excel
        // ==============================================================
        String baseDir = System.getProperty("user.dir");
        String htmlPath  = "file:///" + baseDir.replace("\\", "/") + "/add_employee_mock.html";
        String dataPath  = baseDir + "\\testdata\\Data_Employee-v2.xlsx";
        String resultPath= baseDir + "\\testdata\\TestResult_Employee.xlsx";

        // ==============================================================
        // BƯỚC 3: Đọc file Excel data
        // ==============================================================
        FileInputStream fis      = new FileInputStream(dataPath);
        Workbook        workbook = new XSSFWorkbook(fis);
        Sheet           sheet    = workbook.getSheetAt(0);

        int totalRows  = sheet.getLastRowNum();
        int passCount  = 0;
        int failCount  = 0;
        int cannotFill = 0;

        // Danh sách lưu kết quả để ghi vào file TestResult
        // Mỗi phần tử: [STT, Họ Tên, Email, Expected Result, Actual Result, Status]
        ArrayList<String[]> results = new ArrayList<>();

        System.out.println("=============================================");
        System.out.println("  BẮT ĐẦU CHẠY TEST - THÊM NHÂN VIÊN MỚI");
        System.out.println("  Tổng số test case: " + totalRows);
        System.out.println("=============================================\n");

        // ==============================================================
        // BƯỚC 4: Vòng lặp qua từng dòng trong Excel
        // ==============================================================
        for (int i = 1; i <= totalRows; i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;

            // Đọc dữ liệu từ các cột A → H
            String stt      = getCell(row, 0); // Cột A: STT
            String fullname = getCell(row, 1); // Cột B: Họ Tên
            String email    = getCell(row, 2); // Cột C: Email
            String phone    = getCell(row, 3); // Cột D: SĐT
            String dob      = getCell(row, 4); // Cột E: Ngày sinh
            String gender   = getCell(row, 5); // Cột F: Giới tính
            String dept     = getCell(row, 6); // Cột G: Phòng ban
            String expected = getCell(row, 7); // Cột H: Expected Result (người dùng tự nhập)

            System.out.println("--- Test Case #" + stt + " ---");
            System.out.println("Họ Tên    : " + fullname);
            System.out.println("Email     : " + email);
            System.out.println("Giới tính : " + gender);
            System.out.println("Phòng ban : " + dept);
            System.out.println("Expected  : " + expected);

            // Mở lại trang HTML để reset form về trạng thái ban đầu
            driver.get(htmlPath);
            Thread.sleep(1000);

            // ----------------------------------------------------------
            // BƯỚC 4a: Điền các ô nhập chữ (Text fields)
            // Các ô này luôn điền được dù giá trị trống hay sai
            // ----------------------------------------------------------
            driver.findElement(By.id("fullname")).sendKeys(fullname);
            driver.findElement(By.id("email")).sendKeys(email);
            driver.findElement(By.id("phone")).sendKeys(phone);
            driver.findElement(By.id("dob")).sendKeys(dob);

            // ----------------------------------------------------------
            // BƯỚC 4b: Chọn Dropdown "Giới tính"
            //
            // ⚠ LÝ DO TOOL KHÔNG ĐIỀN ĐƯỢC (CANNOT FILL):
            //   Hàm selectByVisibleText() tìm kiếm đúng chữ trong danh sách <option>.
            //   Nếu Excel ghi "Khác" nhưng HTML chỉ có "Nam" và "Nữ"
            //   → Selenium ném NoSuchElementException → không bấm Submit được.
            // ----------------------------------------------------------
            try {
                new Select(driver.findElement(By.id("gender"))).selectByVisibleText(gender);
            } catch (Exception e) {
                // Tool không tìm thấy option → CANNOT FILL
                String actualMsg = "Giá trị Giới tính '" + gender + "' không có trong Dropdown!";
                String status    = "CANNOT FILL";
                System.out.println("⚠ Actual   : CANNOT FILL - " + actualMsg);
                System.out.println("  Status   : " + status);
                System.out.println();
                results.add(new String[]{stt, fullname, email, expected, "CANNOT FILL - " + actualMsg, status});
                cannotFill++;
                continue;
            }

            // ----------------------------------------------------------
            // BƯỚC 4c: Chọn Dropdown "Phòng ban"
            //
            // ⚠ LÝ DO TOOL KHÔNG ĐIỀN ĐƯỢC (CANNOT FILL):
            //   Tương tự Giới tính — nếu Excel ghi "Kế toán" nhưng HTML
            //   chỉ có "IT" và "Nhân sự" → selectByVisibleText ném Exception.
            // ----------------------------------------------------------
            try {
                new Select(driver.findElement(By.id("department"))).selectByVisibleText(dept);
            } catch (Exception e) {
                // Tool không tìm thấy option → CANNOT FILL
                String actualMsg = "Giá trị Phòng ban '" + dept + "' không có trong Dropdown!";
                String status    = "CANNOT FILL";
                System.out.println("⚠ Actual   : CANNOT FILL - " + actualMsg);
                System.out.println("  Status   : " + status);
                System.out.println();
                results.add(new String[]{stt, fullname, email, expected, "CANNOT FILL - " + actualMsg, status});
                cannotFill++;
                continue;
            }

            // ----------------------------------------------------------
            // BƯỚC 4d: Bấm nút "Lưu Nhân Viên" và đọc thông báo
            // ----------------------------------------------------------
            driver.findElement(By.id("btnSubmit")).click();
            Thread.sleep(1000);

            // Đọc thông báo kết quả thực tế hiển thị trên màn hình
            String actual = driver.findElement(By.id("result-box")).getText();

            // ----------------------------------------------------------
            // BƯỚC 4e: So sánh Actual với Expected (Chuẩn Testing)
            //   - Khớp nhau  → PASS (Hệ thống đúng)
            //   - Khác nhau  → FAIL (Hệ thống sai so với kỳ vọng)
            // ----------------------------------------------------------
            boolean isPass = actual.trim().equalsIgnoreCase(expected.trim());
            String status  = isPass ? "PASS" : "FAIL";

            System.out.println("Actual    : " + actual);
            System.out.println("Status    : " + status);
            System.out.println();

            results.add(new String[]{stt, fullname, email, expected, actual, status});
            if (isPass) passCount++; else failCount++;
        }

        fis.close();
        workbook.close();

        // ==============================================================
        // BƯỚC 5: Tạo file TestResult_Employee.xlsx với màu sắc rõ ràng
        // ==============================================================
        Workbook resultWB = new XSSFWorkbook();
        Sheet    resultS  = resultWB.createSheet("Test Results");

        // --- Style HEADER: nền tím, chữ trắng đậm ---
        CellStyle hStyle = resultWB.createCellStyle();
        Font hFont = resultWB.createFont();
        hFont.setBold(true);
        hFont.setColor(IndexedColors.WHITE.getIndex());
        hStyle.setFont(hFont);
        hStyle.setFillForegroundColor(IndexedColors.VIOLET.getIndex());
        hStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        // --- Style PASS: nền xanh lá ---
        CellStyle passStyle = resultWB.createCellStyle();
        passStyle.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
        passStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        // --- Style FAIL: nền đỏ nhạt ---
        CellStyle failStyle = resultWB.createCellStyle();
        failStyle.setFillForegroundColor(IndexedColors.ROSE.getIndex());
        failStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        // --- Style CANNOT FILL: nền vàng ---
        CellStyle warnStyle = resultWB.createCellStyle();
        warnStyle.setFillForegroundColor(IndexedColors.YELLOW.getIndex());
        warnStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        // Ghi dòng Header
        String[] headers = {"STT", "Họ Tên", "Email", "Expected Result", "Actual Result", "Status"};
        Row headerRow = resultS.createRow(0);
        for (int c = 0; c < headers.length; c++) {
            Cell cell = headerRow.createCell(c);
            cell.setCellValue(headers[c]);
            cell.setCellStyle(hStyle);
        }

        // Ghi từng dòng kết quả
        for (int r = 0; r < results.size(); r++) {
            Row row = resultS.createRow(r + 1);
            String[] data = results.get(r);
            for (int c = 0; c < data.length; c++) {
                row.createCell(c).setCellValue(data[c]);
            }
            // Tô màu cột Status (cột cuối = index 5)
            Cell statusCell = row.getCell(5);
            switch (data[5]) {
                case "PASS":
                    statusCell.setCellStyle(passStyle);
                    break;
                case "FAIL":
                    statusCell.setCellStyle(failStyle);
                    break;
            }
            // Tô màu vàng cột Actual Result nếu là CANNOT FILL
            if (data[4].startsWith("CANNOT FILL")) {
                row.getCell(4).setCellStyle(warnStyle);
            }
        }

        // Ghi dòng tổng kết
        int sumRow = results.size() + 2;
        resultS.createRow(sumRow).createCell(0).setCellValue("TỔNG KẾT:");
        resultS.createRow(sumRow + 1).createCell(0)
               .setCellValue("PASS: " + passCount + "  |  FAIL: " + failCount
                           + "  |  CANNOT FILL: " + cannotFill
                           + "  /  Tổng: " + totalRows);

        // T tự căn độ rộng cột
        for (int c = 0; c < 6; c++) resultS.autoSizeColumn(c);

        // Lưu file kết quả
        FileOutputStream fos = new FileOutputStream(resultPath);
        resultWB.write(fos);
        fos.close();
        resultWB.close();

        System.out.println("=============================================");
        System.out.println("  KẾT QUẢ TỔNG KẾT");
        System.out.println("  PASS        : " + passCount + "/" + totalRows);
        System.out.println("  FAIL        : " + failCount + "/" + totalRows);
        System.out.println("  CANNOT FILL : " + cannotFill + "/" + totalRows);
        System.out.println("  ✅ File kết quả: " + resultPath);
        System.out.println("=============================================");

        // Không đóng trình duyệt tự động để xem kết quả trên màn hình
        // driver.quit();
    }

    // Đọc giá trị từ 1 ô Excel (hỗ trợ cả ô Text lẫn ô Số)
    static String getCell(Row row, int col) {
        Cell cell = row.getCell(col);
        if (cell == null) return "";
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                return String.valueOf((long) cell.getNumericCellValue());
            default:
                return "";
        }
    }
}

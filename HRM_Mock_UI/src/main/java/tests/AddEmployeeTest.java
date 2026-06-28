package tests;

import base.BaseTest;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import pages.AddEmployeePage;
import utils.ExcelUtils;

import java.util.ArrayList;

public class AddEmployeeTest extends BaseTest {

    public static void main(String[] args) throws Exception {
        AddEmployeeTest test = new AddEmployeeTest();
        test.runTests();
    }

    public void runTests() throws Exception {
        // ==============================================================
        // BƯỚC 1: Khởi động Chrome từ BaseTest
        // ==============================================================
        setUp();
        AddEmployeePage page = new AddEmployeePage(driver);

        // ==============================================================
        // BƯỚC 2: Đường dẫn file HTML và Excel
        // ==============================================================
        String baseDir = System.getProperty("user.dir");
        String htmlPath = "file:///" + baseDir.replace("\\", "/") + "/add_employee_mock.html";
        String dataPath = baseDir + "\\testdata\\Data_Employee-v2.xlsx";
        String resultPath = baseDir + "\\testdata\\TestResult_Employee.xlsx";

        // ==============================================================
        // BƯỚC 3: Đọc file Excel data
        // ==============================================================
        Workbook workbook = ExcelUtils.openWorkbook(dataPath);
        Sheet sheet = workbook.getSheetAt(0);

        int totalRows = sheet.getLastRowNum();
        int passCount = 0;
        int failCount = 0;
        int cannotFill = 0;

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

            String stt = ExcelUtils.getCell(row, 0);
            String fullname = ExcelUtils.getCell(row, 1);
            String email = ExcelUtils.getCell(row, 2);
            String phone = ExcelUtils.getCell(row, 3);
            String dob = ExcelUtils.getCell(row, 4);
            String gender = ExcelUtils.getCell(row, 5);
            String dept = ExcelUtils.getCell(row, 6);
            String address = ExcelUtils.getCell(row, 7);
            String expected = ExcelUtils.getCell(row, 8);

            System.out.println("--- Test Case #" + stt + " ---");
            System.out.println("Họ Tên    : " + fullname);
            System.out.println("Expected  : " + expected);

            // Mở lại trang web
            page.openPage(htmlPath);
            Thread.sleep(1000);

            // Điền dữ liệu
            page.enterFullName(fullname);
            page.enterEmail(email);
            page.enterPhone(phone);
            page.enterDob(dob);
            page.enterAddress(address);

            // Chọn Giới tính
            try {
                page.selectGender(gender);
            } catch (Exception e) {
                String actualMsg = "Giá trị Giới tính '" + gender + "' không có trong Dropdown!";
                String status = "CANNOT FILL";
                System.out.println("⚠ Actual   : CANNOT FILL - " + actualMsg);
                results.add(new String[]{stt, fullname, email, phone, dob, gender, dept, address, expected, "CANNOT FILL - " + actualMsg, status});
                cannotFill++;
                continue;
            }

            // Chọn Phòng ban
            try {
                page.selectDepartment(dept);
            } catch (Exception e) {
                String actualMsg = "Giá trị Phòng ban '" + dept + "' không có trong Dropdown!";
                String status = "CANNOT FILL";
                System.out.println("⚠ Actual   : CANNOT FILL - " + actualMsg);
                results.add(new String[]{stt, fullname, email, phone, dob, gender, dept, address, expected, "CANNOT FILL - " + actualMsg, status});
                cannotFill++;
                continue;
            }

            // Bấm Submit
            page.clickSubmit();
            Thread.sleep(1000);

            // Lấy kết quả
            String actual = page.getResultMessage();
            boolean isPass = actual.trim().equalsIgnoreCase(expected.trim());
            String status = isPass ? "PASS" : "FAIL";

            System.out.println("Actual    : " + actual);
            System.out.println("Status    : " + status + "\n");

            results.add(new String[]{stt, fullname, email, phone, dob, gender, dept, address, expected, actual, status});
            if (isPass) passCount++; else failCount++;
        }

        // ==============================================================
        // BƯỚC 5: Gọi tiện ích tạo file Excel kết quả trên nền file gốc
        // ==============================================================
        ExcelUtils.generateReport(workbook, sheet, resultPath, results, passCount, failCount, cannotFill, totalRows);

        System.out.println("=============================================");
        System.out.println("  KẾT QUẢ TỔNG KẾT");
        System.out.println("  PASS        : " + passCount + "/" + totalRows);
        System.out.println("  FAIL        : " + failCount + "/" + totalRows);
        System.out.println("  CANNOT FILL : " + cannotFill + "/" + totalRows);
        System.out.println("  ✅ File kết quả: " + resultPath);
        System.out.println("=============================================");

        // Đóng trình duyệt
        tearDown();
    }
}

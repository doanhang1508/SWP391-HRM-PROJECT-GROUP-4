package tests;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class AttendancePayrollTest {

    private WebDriver driver;
    private WebDriverWait wait;

    private static final String BASE_URL = "http://localhost:8080/HRM";
    private static final String DB_URL = "jdbc:mysql://localhost:3306/hrm_system";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "1234";

    @BeforeEach
    public void setUp() {
        driver = new ChromeDriver();
        driver.manage().window().maximize();
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));
    }

    @AfterEach
    public void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }

    private void cleanUpTestData() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                // Delete payroll first (if any)
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM payroll WHERE month = 6 AND year = 2026")) {
                    ps.executeUpdate();
                }
                // Delete attendance
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM attendance WHERE MONTH(work_date) = 6 AND YEAR(work_date) = 2026")) {
                    ps.executeUpdate();
                }
                System.out.println("Cleaned up database for month 6 / year 2026 successfully.");
            }
        } catch (Exception e) {
            System.err.println("Clean up failed: " + e.getMessage());
        }
    }

    private void login(String username, String password) {
        driver.get(BASE_URL + "/login.jsp");
        WebElement userField = wait.until(ExpectedConditions.visibilityOfElementLocated(By.name("username")));
        WebElement passField = driver.findElement(By.name("password"));
        WebElement loginBtn = driver.findElement(By.tagName("button"));

        userField.clear();
        userField.sendKeys(username);
        passField.clear();
        passField.sendKeys(password);
        loginBtn.click();

        // Wait until redirect occurs (i.e. URL is no longer login.jsp)
        wait.until(ExpectedConditions.not(ExpectedConditions.urlContains("login.jsp")));
    }

    @Test
    public void testImportAttendanceSuccessWithoutAutoPayroll() {
        // 1. Clean up old data to ensure test reproducibility
        cleanUpTestData();

        // 2. Log in as HR Staff (role_id = 5)
        login("hr_staff_01", "@123456");

        // 3. Go to Import Attendance page
        driver.get(BASE_URL + "/hr/import-attendance");

        // 4. Select month = 6, year = 2026
        WebElement monthSelect = wait.until(ExpectedConditions.presenceOfElementLocated(By.name("importMonth")));
        new Select(monthSelect).selectByValue("6");

        WebElement yearSelect = driver.findElement(By.name("importYear"));
        new Select(yearSelect).selectByValue("2026");

        // 5. Select the Excel file to upload
        WebElement fileInput = driver.findElement(By.id("fileInput"));
        // Resolve path to the Excel file in project root
        File excelFile = new File("../Bang_Cham_Cong_HRM_Thang06_2026.xlsx");
        assertTrue(excelFile.exists(), "Excel attendance template should exist at: " + excelFile.getAbsolutePath());
        fileInput.sendKeys(excelFile.getAbsolutePath());

        // 6. Submit the form
        WebElement importBtn = driver.findElement(By.id("importBtn"));
        wait.until(ExpectedConditions.elementToBeClickable(importBtn));
        importBtn.click();

        // 7. Verify success alert is shown and doesn't mention auto-generating payroll draft
        WebElement successAlert = wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("alert-success")));
        String alertText = successAlert.getText();
        assertTrue(alertText.contains("Import thành công"), "Alert should indicate success: " + alertText);
        assertFalse(alertText.contains("bảng lương nháp") || alertText.contains("tự động tạo"), 
                "Alert should not mention automatic generation of payroll draft.");

        // 8. Go to payroll page and verify that no payroll draft was created for 06/2026
        driver.get(BASE_URL + "/hr/payroll?month=6&year=2026");
        
        // Wait for page or verify table is empty
        WebElement bodyElement = wait.until(ExpectedConditions.visibilityOfElementLocated(By.tagName("body")));
        assertTrue(bodyElement.getText().contains("Chưa có bảng lương cho kỳ này."), 
                "There should be no payroll records for June 2026 immediately after import.");
    }

    @Test
    public void testManualGeneratePayrollAfterAttendance() {
        // 1. Clean up old data and import attendance first
        cleanUpTestData();
        login("hr_staff_01", "@123456");

        driver.get(BASE_URL + "/hr/import-attendance");
        WebElement monthSelect = wait.until(ExpectedConditions.presenceOfElementLocated(By.name("importMonth")));
        new Select(monthSelect).selectByValue("6");
        WebElement yearSelect = driver.findElement(By.name("importYear"));
        new Select(yearSelect).selectByValue("2026");

        WebElement fileInput = driver.findElement(By.id("fileInput"));
        File excelFile = new File("../Bang_Cham_Cong_HRM_Thang06_2026.xlsx");
        fileInput.sendKeys(excelFile.getAbsolutePath());

        WebElement importBtn = driver.findElement(By.id("importBtn"));
        wait.until(ExpectedConditions.elementToBeClickable(importBtn));
        importBtn.click();
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("alert-success")));

        // 2. Now go to the Payroll page and generate the draft manually
        driver.get(BASE_URL + "/hr/payroll");

        // Click "Khởi tạo kỳ lương" button
        WebElement initBtn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(text(), 'Khởi tạo kỳ lương')] | //button[contains(., 'Khởi tạo kỳ lương')]")));
        initBtn.click();

        // Select period in the modal
        WebElement periodSelect = wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("periodSelect")));
        new Select(periodSelect).selectByValue("6-2026");

        // Click generate button in the modal
        WebElement modalGenerateBtn = driver.findElement(By.xpath("//form[@action='/HRM/hr/payroll']//button[@type='submit']"));
        modalGenerateBtn.click();

        // Confirm generation in the confirmation modal
        WebElement confirmBtn = wait.until(ExpectedConditions.elementToBeClickable(By.id("btnConfirmSubmit")));
        confirmBtn.click();

        // 3. Verify success redirect and success message
        WebElement successAlert = wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("alert-c")));
        assertTrue(successAlert.getText().contains("Khởi tạo bảng lương tháng 6/2026 thành công") || successAlert.getText().contains("thành công"),
                "Success message should be displayed. Got: " + successAlert.getText());

        // 4. Verify employee table has active draft entries
        WebElement tableBody = driver.findElement(By.cssSelector("#employeeTable tbody"));
        assertTrue(tableBody.findElements(By.tagName("tr")).size() > 0, "There should be payroll records generated.");
        assertTrue(tableBody.getText().contains("Draft"), "The generated records should be in 'Draft' status.");
    }
}

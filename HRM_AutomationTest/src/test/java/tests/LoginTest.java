package tests;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import utils.ExcelUtils;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class LoginTest {

    private WebDriver driver;
    private WebDriverWait wait;
    
    // TODO: Change this to the URL of your local HRM application
    private static final String BASE_URL = "http://localhost:8080/HRM/login.jsp"; 
    private static final String EXCEL_FILE_PATH = "src/test/resources/testdata.xlsx";

    @BeforeEach
    public void setUp() {
        // Selenium 4.x automatically manages the ChromeDriver with Selenium Manager
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

    /**
     * Provides test data from the first sheet of the Excel file.
     * Each row is represented as a Map<String, String>.
     */
    static Stream<Map<String, String>> getLoginData() {
        List<Map<String, String>> data = ExcelUtils.getExcelDataAsMap(EXCEL_FILE_PATH);
        return data.stream();
    }

    @ParameterizedTest(name = "Test login with User: {0}")
    @MethodSource("getLoginData")
    public void testLogin(Map<String, String> rowData) {
        // 1. Navigate to Login Page
        driver.get(BASE_URL);

        // Lấy dữ liệu dựa theo đúng TÊN CỘT trong Excel của bạn
        String username = rowData.get("Username");
        String password = rowData.get("Mật khẩu");

        // Nếu dòng trắng thì bỏ qua
        if (username == null || username.trim().isEmpty()) {
            return;
        }

        // 2. Locate elements (Update these IDs/names based on your actual login.jsp)
        // Ví dụ: thẻ input username có name="username", password có name="password"
        WebElement userField = wait.until(ExpectedConditions.visibilityOfElementLocated(By.name("username")));
        WebElement passField = driver.findElement(By.name("password"));
        WebElement loginBtn = driver.findElement(By.tagName("button")); // Hoặc By.id("btnLogin")

        // 3. Perform actions
        userField.clear();
        userField.sendKeys(username);

        passField.clear();
        passField.sendKeys(password);

        loginBtn.click();

        // 4. Verify results
        // Vì file Excel của bạn là danh sách nhân viên hợp lệ, ta kỳ vọng login thành công.
        // Đợi URL thay đổi (không còn ở trang login nữa)
        boolean isRedirected = wait.until(ExpectedConditions.not(ExpectedConditions.urlContains("login.jsp")));
        assertTrue(isRedirected, "Login failed for user: " + username);
    }
    
    @Test
    public void testSimpleOpenPage() {
        driver.get(BASE_URL);
        assertTrue(driver.getTitle().contains("Login") || driver.getPageSource().contains("Login"), "Page should load successfully");
    }
}

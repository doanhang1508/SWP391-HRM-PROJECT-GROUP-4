package base;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

public class BaseTest {
    protected WebDriver driver;

    public void setUp() {
        driver = new ChromeDriver();
        driver.manage().window().maximize();
    }

    public void tearDown() {
        if (driver != null) {
            // Uncomment next line if you want the browser to close automatically after running
            // driver.quit();
        }
    }
}

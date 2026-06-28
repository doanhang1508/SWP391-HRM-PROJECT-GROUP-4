package pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.support.ui.Select;

public class AddEmployeePage {
    private WebDriver driver;

    // Locators
    private By fullnameInput = By.id("fullname");
    private By emailInput = By.id("email");
    private By phoneInput = By.id("phone");
    private By dobInput = By.id("dob");
    private By genderSelect = By.id("gender");
    private By departmentSelect = By.id("department");
    private By addressInput = By.id("address");
    private By submitButton = By.id("btnSubmit");
    private By resultBox = By.id("result-box");

    public AddEmployeePage(WebDriver driver) {
        this.driver = driver;
    }

    // Actions
    public void enterFullName(String fullname) {
        driver.findElement(fullnameInput).clear();
        driver.findElement(fullnameInput).sendKeys(fullname);
    }

    public void enterEmail(String email) {
        driver.findElement(emailInput).clear();
        driver.findElement(emailInput).sendKeys(email);
    }

    public void enterPhone(String phone) {
        driver.findElement(phoneInput).clear();
        driver.findElement(phoneInput).sendKeys(phone);
    }

    public void enterDob(String dob) {
        JavascriptExecutor js = (JavascriptExecutor) driver;
        js.executeScript("arguments[0].value='" + dob + "';", driver.findElement(dobInput));
    }

    public void enterAddress(String address) {
        driver.findElement(addressInput).clear();
        driver.findElement(addressInput).sendKeys(address);
    }

    public void selectGender(String gender) {
        new Select(driver.findElement(genderSelect)).selectByVisibleText(gender);
    }

    public void selectDepartment(String department) {
        new Select(driver.findElement(departmentSelect)).selectByVisibleText(department);
    }

    public void clickSubmit() {
        driver.findElement(submitButton).click();
    }

    public String getResultMessage() {
        return driver.findElement(resultBox).getText();
    }

    public void openPage(String url) {
        driver.get(url);
    }
}

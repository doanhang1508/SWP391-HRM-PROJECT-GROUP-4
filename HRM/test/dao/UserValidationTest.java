package dao;

import model.User;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit Test cho hàm User.validate()
 * KHÔNG cần Database, KHÔNG cần chạy server.
 * Chỉ cần file User.java và thư viện JUnit 4.
 */
public class UserValidationTest {
    private static final String NAME = "testuser";
    // ==========================================
    // CONDITION 1: Dữ liệu hợp lệ -> kỳ vọng validate() trả về null
    // ==========================================

    @Test
    public void tC01ValidUserShouldReturnNull() {
        User u = new User();
        u.setUsername("nguyenvana");
        u.setPassword("123456");
        u.setFullName("Nguyen Van A");
        u.setEmail("nguyenvana@gmail.com");
        u.setPhone("0901234567");
        u.setRoleId(2);
        u.setStatus(1);
        assertNull("Dữ liệu hợp lệ, validate phải trả null", User.validate(u));
    }

    @Test
    public void tC02ValidUserStatusZeroShouldReturnNull() {
        User u = new User();
        u.setUsername("tranthib");
        u.setPassword("pass123");
        u.setFullName("Tran Thi B");
        u.setEmail("tranthib@gmail.com");
        u.setRoleId(3);
        u.setStatus(0); // Status = 0 (inactive) vẫn hợp lệ
        assertNull("Status = 0 vẫn hợp lệ", User.validate(u));
    }

    // ==========================================
    // CONDITION 2: Thiếu dữ liệu bắt buộc -> kỳ vọng trả về thông báo lỗi
    // ==========================================

    @Test
    public void TC03NullUsernameShouldReturnError() {
        User u = new User();
        u.setUsername(NAME);
        u.setPassword("123456");
        u.setEmail("test@gmail.com");
        u.setRoleId(2);
        u.setStatus(1);
        assertNotNull("Username null phải báo lỗi", User.validate(u));
    }

    @Test
    public void TC04EmptyUsernameShouldReturnError() {
        User u = new User();
        u.setUsername(" "); // Chỉ có dấu cách
        u.setPassword("123456");
        u.setEmail("test@gmail.com");
        u.setRoleId(2);
        u.setStatus(1);
        assertNotNull("Username rỗng phải báo lỗi", User.validate(u));
    }

    @Test
    public void TC05NullPasswordShouldReturnError() {
        User u = new User();
        u.setUsername(NAME);
        u.setPassword(null);
        u.setEmail("test@gmail.com");
        u.setRoleId(2);
        u.setStatus(1);
        assertNotNull("Password null phải báo lỗi", User.validate(u));
    }

    @Test
    public void TC06NullEmailShouldReturnError() {
        User u = new User();
        u.setUsername(NAME);
        u.setPassword("123456");
        u.setEmail(null);
        u.setRoleId(2);
        u.setStatus(1);
        assertNotNull("Email null phải báo lỗi", User.validate(u));
    }

    @Test
    public void TC07InvalidEmailFormatShouldReturnError() {
        User u = new User();
        u.setUsername(NAME);
        u.setPassword("123456");
        u.setEmail("emailkhongcoat"); // Không có ký tự @
        u.setRoleId(2);
        u.setStatus(1);
        assertNotNull("Email sai định dạng phải báo lỗi", User.validate(u));
    }

    // ==========================================
    // CONDITION 3: Dữ liệu sai logic/ràng buộc -> kỳ vọng trả về thông báo lỗi
    // ==========================================

    @Test
    public void TC08InvalidRoleIdShouldReturnError() {
        User u = new User();
        u.setUsername(NAME);
        u.setPassword("123456");
        u.setEmail("test@gmail.com");
        u.setRoleId(-1); // RoleId âm = sai
        u.setStatus(1);
        assertNotNull("RoleId âm phải báo lỗi", User.validate(u));
    }

    @Test
    public void TC09InvalidStatusShouldReturnError() {
        User u = new User();
        u.setUsername(NAME);
        u.setPassword("123456");
        u.setEmail("test@gmail.com");
        u.setRoleId(2);
        u.setStatus(99); // Status chỉ được là 0 hoặc 1
        assertNotNull("Status = 99 phải báo lỗi", User.validate(u));
    }

    @Test
    public void TC10PhoneTooLongShouldReturnError() {
        User u = new User();
        u.setUsername(NAME);
        u.setPassword("123456");
        u.setEmail("test@gmail.com");
        u.setRoleId(2);
        u.setStatus(1);
        u.setPhone("0123456789012345678"); // Dài hơn 15 ký tự
        assertNotNull("Số điện thoại quá dài phải báo lỗi", User.validate(u));
    }
}

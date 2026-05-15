package model;

public class User {

    private int id;
    private String fullName;
    private String email;
    private String password;
    private String department;
    private String role;
    private boolean status;

    // Constructor rỗng
    public User() {
    }

    // Constructor đầy đủ
    public User(int id, String fullName, String email,
            String password, String role,String department, boolean status) {

        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.department = department;
        this.role = role;
        this.status = status;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }
}

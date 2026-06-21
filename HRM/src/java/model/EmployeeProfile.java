package model;

import java.sql.Date;

/**
 * Model ánh xạ bảng employee_profiles.
 * Chứa thêm các trường JOIN từ contract_types, salary_grades để tiện hiển thị.
 */
public class EmployeeProfile {

    private int profileId;
    private int userId;
    private int departmentId;

    // Thông tin cá nhân mở rộng
    private String idCard;          // id_card — CMND/CCCD
    private Date dob;               // date of birth
    private Integer gender;         // 1 = Nam, 0 = Nữ, null = chưa cập nhật
    private String address;

    // Thông tin hợp đồng/lương
    private Date hireDate;
    private String taxCode;
    private String socialInsuranceNo;
    private String bankAccount;
    private String bankName;
    private Integer contractTypeId;
    private Integer salaryGradeId;
    private Integer employmentStatusId;
    private Integer educationLevelId;

    // Trường JOIN — tên loại hợp đồng, tên bậc lương (load từ query JOIN)
    private String contractTypeName;
    private String salaryGradeName;
    private java.math.BigDecimal baseSalary;
    private String employmentStatusName;

    public EmployeeProfile() {}

    // ── Getters & Setters ──────────────────────────────────────────────────────

    public int getProfileId() { return profileId; }
    public void setProfileId(int profileId) { this.profileId = profileId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }

    public String getIdCard() { return idCard; }
    public void setIdCard(String idCard) { this.idCard = idCard; }

    public Date getDob() { return dob; }
    public void setDob(Date dob) { this.dob = dob; }

    public Integer getGender() { return gender; }
    public void setGender(Integer gender) { this.gender = gender; }

    /** Trả về "Nam", "Nữ", hoặc null nếu chưa cập nhật */
    public String getGenderLabel() {
        if (gender == null) return null;
        return gender == 1 ? "Nam" : "Nữ";
    }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Date getHireDate() { return hireDate; }
    public void setHireDate(Date hireDate) { this.hireDate = hireDate; }

    public String getTaxCode() { return taxCode; }
    public void setTaxCode(String taxCode) { this.taxCode = taxCode; }

    public String getSocialInsuranceNo() { return socialInsuranceNo; }
    public void setSocialInsuranceNo(String socialInsuranceNo) { this.socialInsuranceNo = socialInsuranceNo; }

    public String getBankAccount() { return bankAccount; }
    public void setBankAccount(String bankAccount) { this.bankAccount = bankAccount; }

    public String getBankName() { return bankName; }
    public void setBankName(String bankName) { this.bankName = bankName; }

    public Integer getContractTypeId() { return contractTypeId; }
    public void setContractTypeId(Integer contractTypeId) { this.contractTypeId = contractTypeId; }

    public Integer getSalaryGradeId() { return salaryGradeId; }
    public void setSalaryGradeId(Integer salaryGradeId) { this.salaryGradeId = salaryGradeId; }

    public Integer getEmploymentStatusId() { return employmentStatusId; }
    public void setEmploymentStatusId(Integer employmentStatusId) { this.employmentStatusId = employmentStatusId; }

    public Integer getEducationLevelId() { return educationLevelId; }
    public void setEducationLevelId(Integer educationLevelId) { this.educationLevelId = educationLevelId; }

    // JOIN fields
    public String getContractTypeName() { return contractTypeName; }
    public void setContractTypeName(String contractTypeName) { this.contractTypeName = contractTypeName; }

    public String getSalaryGradeName() { return salaryGradeName; }
    public void setSalaryGradeName(String salaryGradeName) { this.salaryGradeName = salaryGradeName; }

    public java.math.BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(java.math.BigDecimal baseSalary) { this.baseSalary = baseSalary; }

    public String getEmploymentStatusName() { return employmentStatusName; }
    public void setEmploymentStatusName(String employmentStatusName) { this.employmentStatusName = employmentStatusName; }
}

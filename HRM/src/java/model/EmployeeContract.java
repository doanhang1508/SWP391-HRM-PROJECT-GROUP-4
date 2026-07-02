package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model class đại diện cho bảng employee_contracts.
 * Hỗ trợ cả Hợp đồng gốc (CONTRACT) và Phụ lục (ADDENDUM).
 */
public class EmployeeContract {

    private int contractId;
    private int userId;
    private int contractTypeId;
    private int positionId;
    private int departmentId;
    private int salaryGradeId;
    private Date startDate;
    private Date endDate;
    private Date actualEndDate;
    private String terminationReason;
    private BigDecimal baseSalary;
    private int taxCalcType;         // 1=Lũy tiến, 2=Khấu trừ 10%, 3=Không thuế
    private String filePath;
    private String docType;          // 'CONTRACT' | 'ADDENDUM'
    private Integer parentContractId;
    private String addendumReason;
    private String status;           // 'Active', 'Pending', 'Expired', 'Terminated'
    private String signStatus;       // 'N/A', 'PENDING', 'SIGNED', 'REJECTED'
    private Timestamp signedAt;
    private String rejectReason;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // === Fields bổ sung từ JOIN (không có trong bảng, dùng cho hiển thị) ===
    private String contractTypeName;
    private String positionName;
    private String departmentName;
    private String salaryGradeName;
    private String fullName;         // Tên nhân viên

    // === Fields bổ sung cho hiển thị Lịch sử (Transient) ===
    private BigDecimal grossSalary;
    private String allowanceHtml;

    // =========================================================================
    // Constructors
    // =========================================================================

    public EmployeeContract() {}

    // =========================================================================
    // Getters & Setters
    // =========================================================================

    public int getContractId() { return contractId; }
    public void setContractId(int contractId) { this.contractId = contractId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getContractTypeId() { return contractTypeId; }
    public void setContractTypeId(int contractTypeId) { this.contractTypeId = contractTypeId; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }

    public int getSalaryGradeId() { return salaryGradeId; }
    public void setSalaryGradeId(int salaryGradeId) { this.salaryGradeId = salaryGradeId; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public Date getActualEndDate() { return actualEndDate; }
    public void setActualEndDate(Date actualEndDate) { this.actualEndDate = actualEndDate; }

    public String getTerminationReason() { return terminationReason; }
    public void setTerminationReason(String terminationReason) { this.terminationReason = terminationReason; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }

    public int getTaxCalcType() { return taxCalcType; }
    public void setTaxCalcType(int taxCalcType) { this.taxCalcType = taxCalcType; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public String getDocType() { return docType; }
    public void setDocType(String docType) { this.docType = docType; }

    public Integer getParentContractId() { return parentContractId; }
    public void setParentContractId(Integer parentContractId) { this.parentContractId = parentContractId; }

    public String getAddendumReason() { return addendumReason; }
    public void setAddendumReason(String addendumReason) { this.addendumReason = addendumReason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getSignStatus() { return signStatus; }
    public void setSignStatus(String signStatus) { this.signStatus = signStatus; }

    public Timestamp getSignedAt() { return signedAt; }
    public void setSignedAt(Timestamp signedAt) { this.signedAt = signedAt; }

    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // === JOIN fields ===

    public String getContractTypeName() { return contractTypeName; }
    public void setContractTypeName(String contractTypeName) { this.contractTypeName = contractTypeName; }

    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getSalaryGradeName() { return salaryGradeName; }
    public void setSalaryGradeName(String salaryGradeName) { this.salaryGradeName = salaryGradeName; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public BigDecimal getGrossSalary() { return grossSalary; }
    public void setGrossSalary(BigDecimal grossSalary) { this.grossSalary = grossSalary; }

    public String getAllowanceHtml() { return allowanceHtml; }
    public void setAllowanceHtml(String allowanceHtml) { this.allowanceHtml = allowanceHtml; }

    // =========================================================================
    // Utility
    // =========================================================================

    public boolean isAddendum() {
        return "ADDENDUM".equalsIgnoreCase(docType);
    }

    public boolean isActive() {
        return "Active".equalsIgnoreCase(status);
    }

    public boolean isPending() {
        return "Pending".equalsIgnoreCase(status);
    }

    @Override
    public String toString() {
        return "EmployeeContract{contractId=" + contractId
                + ", userId=" + userId
                + ", status=" + status
                + ", docType=" + docType
                + ", baseSalary=" + baseSalary + "}";
    }
}

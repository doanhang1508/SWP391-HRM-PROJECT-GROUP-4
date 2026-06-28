package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class EmployeeContract {
    private int contractId;
    private int userId;
    private int contractTypeId;
    private Date startDate;
    private Date endDate;
    private BigDecimal baseSalary;
    private BigDecimal bhxhRate;
    private BigDecimal bhytRate;
    private BigDecimal bhtnRate;
    private int taxCalcType;
    private String status;
    private Timestamp createdAt;
    
    // For joining data display
    private String contractTypeName;
    private String employeeName;
    private String departmentName;
    private String employeeCode;

    public EmployeeContract() {}

    public EmployeeContract(int contractId, int userId, int contractTypeId, Date startDate, Date endDate,
                            BigDecimal baseSalary, BigDecimal bhxhRate, BigDecimal bhytRate, BigDecimal bhtnRate,
                            int taxCalcType, String status, Timestamp createdAt) {
        this.contractId = contractId;
        this.userId = userId;
        this.contractTypeId = contractTypeId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.baseSalary = baseSalary;
        this.bhxhRate = bhxhRate;
        this.bhytRate = bhytRate;
        this.bhtnRate = bhtnRate;
        this.taxCalcType = taxCalcType;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getContractId() {
        return contractId;
    }

    public void setContractId(int contractId) {
        this.contractId = contractId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getContractTypeId() {
        return contractTypeId;
    }

    public void setContractTypeId(int contractTypeId) {
        this.contractTypeId = contractTypeId;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public BigDecimal getBaseSalary() {
        return baseSalary;
    }

    public void setBaseSalary(BigDecimal baseSalary) {
        this.baseSalary = baseSalary;
    }

    public BigDecimal getBhxhRate() {
        return bhxhRate;
    }

    public void setBhxhRate(BigDecimal bhxhRate) {
        this.bhxhRate = bhxhRate;
    }

    public BigDecimal getBhytRate() {
        return bhytRate;
    }

    public void setBhytRate(BigDecimal bhytRate) {
        this.bhytRate = bhytRate;
    }

    public BigDecimal getBhtnRate() {
        return bhtnRate;
    }

    public void setBhtnRate(BigDecimal bhtnRate) {
        this.bhtnRate = bhtnRate;
    }

    public int getTaxCalcType() {
        return taxCalcType;
    }

    public void setTaxCalcType(int taxCalcType) {
        this.taxCalcType = taxCalcType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getContractTypeName() {
        return contractTypeName;
    }

    public void setContractTypeName(String contractTypeName) {
        this.contractTypeName = contractTypeName;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }

    // ── Phụ lục hợp đồng (Addendum) fields ──────────────────────────────────
    /** 'CONTRACT' hoặc 'ADDENDUM' */
    private String docType = "CONTRACT";
    /** contract_id của hợp đồng gốc (nếu đây là phụ lục) */
    private Integer parentContractId;
    /** Lý do tạo phụ lục: Tăng lương / Thăng tiến / Điều chuyển */
    private String addendumReason;
    /** 'N/A' | 'PENDING' | 'SIGNED' | 'REJECTED' */
    private String signStatus = "N/A";
    /** Thời điểm nhân viên bấm Xác nhận/Từ chối */
    private Timestamp signedAt;
    /** Lý do nhân viên từ chối ký phụ lục */
    private String rejectReason;

    public String getDocType() { return docType; }
    public void setDocType(String docType) { this.docType = docType; }

    public Integer getParentContractId() { return parentContractId; }
    public void setParentContractId(Integer parentContractId) { this.parentContractId = parentContractId; }

    public String getAddendumReason() { return addendumReason; }
    public void setAddendumReason(String addendumReason) { this.addendumReason = addendumReason; }

    public String getSignStatus() { return signStatus; }
    public void setSignStatus(String signStatus) { this.signStatus = signStatus; }

    public Timestamp getSignedAt() { return signedAt; }
    public void setSignedAt(Timestamp signedAt) { this.signedAt = signedAt; }

    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }

    /** Tiện ích: kiểm tra đây có phải phụ lục đang chờ ký không */
    public boolean isPendingAddendum() {
        return "ADDENDUM".equals(docType) && "PENDING".equals(signStatus);
    }
}

package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class TransferRequest {
    private int transferRequestId;
    private int employeeId;
    private String employeeName;
    private int oldDepartmentId;
    private String oldDepartmentName;
    private int oldPositionId;
    private String oldPositionName;
    private int newDepartmentId;
    private String newDepartmentName;
    private int newPositionId;
    private String newPositionName;
    private String reason;
    private Date effectiveDate;
    private String status;
    private int requestedBy;
    private String requestedByName;
    private Integer approvedBy; // can be null
    private String approvedByName;
    private Timestamp approvedAt;
    private String rejectReason;
    private Integer oldRoleId;
    private String oldRoleName;
    private int newRoleId;
    private String newRoleName;
    // [FIX #2] Thông tin lương mới — nullable, null = giữ nguyên lương hiện tại
    private Integer newSalaryGradeId;
    private BigDecimal newBaseSalary;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    // [2-STEP] Bước 1: Trưởng phòng duyệt
    private Integer managerApprovedBy; // nullable
    private String  managerApprovedByName;
    private Timestamp managerApprovedAt; // nullable
    // [NEW FLOW] Bước 0: Nhân viên xác nhận
    private Timestamp employeeConfirmedAt; // nullable
    private String    employeeRejectReason; // nullable

    public TransferRequest() {
    }

    // Getters and Setters
    public int getTransferRequestId() {
        return transferRequestId;
    }

    public void setTransferRequestId(int transferRequestId) {
        this.transferRequestId = transferRequestId;
    }

    public int getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }

    public int getOldDepartmentId() {
        return oldDepartmentId;
    }

    public void setOldDepartmentId(int oldDepartmentId) {
        this.oldDepartmentId = oldDepartmentId;
    }

    public String getOldDepartmentName() {
        return oldDepartmentName;
    }

    public void setOldDepartmentName(String oldDepartmentName) {
        this.oldDepartmentName = oldDepartmentName;
    }

    public int getOldPositionId() {
        return oldPositionId;
    }

    public void setOldPositionId(int oldPositionId) {
        this.oldPositionId = oldPositionId;
    }

    public String getOldPositionName() {
        return oldPositionName;
    }

    public void setOldPositionName(String oldPositionName) {
        this.oldPositionName = oldPositionName;
    }

    public int getNewDepartmentId() {
        return newDepartmentId;
    }

    public void setNewDepartmentId(int newDepartmentId) {
        this.newDepartmentId = newDepartmentId;
    }

    public String getNewDepartmentName() {
        return newDepartmentName;
    }

    public void setNewDepartmentName(String newDepartmentName) {
        this.newDepartmentName = newDepartmentName;
    }

    public int getNewPositionId() {
        return newPositionId;
    }

    public void setNewPositionId(int newPositionId) {
        this.newPositionId = newPositionId;
    }

    public String getNewPositionName() {
        return newPositionName;
    }

    public void setNewPositionName(String newPositionName) {
        this.newPositionName = newPositionName;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Date getEffectiveDate() {
        return effectiveDate;
    }

    public void setEffectiveDate(Date effectiveDate) {
        this.effectiveDate = effectiveDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getRequestedBy() {
        return requestedBy;
    }

    public void setRequestedBy(int requestedBy) {
        this.requestedBy = requestedBy;
    }

    public String getRequestedByName() {
        return requestedByName;
    }

    public void setRequestedByName(String requestedByName) {
        this.requestedByName = requestedByName;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public String getApprovedByName() {
        return approvedByName;
    }

    public void setApprovedByName(String approvedByName) {
        this.approvedByName = approvedByName;
    }

    public Timestamp getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(Timestamp approvedAt) {
        this.approvedAt = approvedAt;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getOldRoleId() {
        return oldRoleId;
    }

    public void setOldRoleId(Integer oldRoleId) {
        this.oldRoleId = oldRoleId;
    }

    public String getOldRoleName() {
        return oldRoleName;
    }

    public void setOldRoleName(String oldRoleName) {
        this.oldRoleName = oldRoleName;
    }

    public int getNewRoleId() {
        return newRoleId;
    }

    public void setNewRoleId(int newRoleId) {
        this.newRoleId = newRoleId;
    }

    public String getNewRoleName() {
        return newRoleName;
    }

    public void setNewRoleName(String newRoleName) {
        this.newRoleName = newRoleName;
    }

    // [FIX #2] Getters/Setters cho thông tin lương mới (optional)
    public Integer getNewSalaryGradeId() {
        return newSalaryGradeId;
    }

    public void setNewSalaryGradeId(Integer newSalaryGradeId) {
        this.newSalaryGradeId = newSalaryGradeId;
    }

    public BigDecimal getNewBaseSalary() {
        return newBaseSalary;
    }

    public void setNewBaseSalary(BigDecimal newBaseSalary) {
        this.newBaseSalary = newBaseSalary;
    }

    // [2-STEP] Getters/Setters cho thông tin duyệt bước 1 (Trưởng phòng)
    public Integer getManagerApprovedBy() {
        return managerApprovedBy;
    }

    public void setManagerApprovedBy(Integer managerApprovedBy) {
        this.managerApprovedBy = managerApprovedBy;
    }

    public String getManagerApprovedByName() {
        return managerApprovedByName;
    }

    public void setManagerApprovedByName(String managerApprovedByName) {
        this.managerApprovedByName = managerApprovedByName;
    }

    public Timestamp getManagerApprovedAt() {
        return managerApprovedAt;
    }

    public void setManagerApprovedAt(Timestamp managerApprovedAt) {
        this.managerApprovedAt = managerApprovedAt;
    }

    // [NEW FLOW] Getters/Setters cho thông tin xác nhận của Nhân viên
    public Timestamp getEmployeeConfirmedAt() {
        return employeeConfirmedAt;
    }

    public void setEmployeeConfirmedAt(Timestamp employeeConfirmedAt) {
        this.employeeConfirmedAt = employeeConfirmedAt;
    }

    public String getEmployeeRejectReason() {
        return employeeRejectReason;
    }

    public void setEmployeeRejectReason(String employeeRejectReason) {
        this.employeeRejectReason = employeeRejectReason;
    }
}

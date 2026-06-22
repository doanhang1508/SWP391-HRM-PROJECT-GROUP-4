package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class PayrollClaim {
    private int claimId;
    private int payrollId;
    private String complaintType;
    private String description;
    private BigDecimal expectedAmount;
    private String evidence;
    private String status;
    private String hrStaffNote;
    private String accountantNote;
    private BigDecimal proposedAdjustment;
    private String hrManagerNote;
    private String directorNote;
    private Timestamp createdAt;

    // Display fields (join)
    private String fullName;
    private int month;
    private int year;
    private String email;

    private Integer hrStaffId;
    private Integer accountantId;
    private Integer hrManagerId;
    private Integer directorId;

    private String hrStaffName;
    private String accountantName;
    private String hrManagerName;
    private String directorName;

    public PayrollClaim() {}

    public int getClaimId() { return claimId; }
    public void setClaimId(int claimId) { this.claimId = claimId; }

    public int getPayrollId() { return payrollId; }
    public void setPayrollId(int payrollId) { this.payrollId = payrollId; }

    public String getComplaintType() { return complaintType; }
    public void setComplaintType(String complaintType) { this.complaintType = complaintType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getExpectedAmount() { return expectedAmount; }
    public void setExpectedAmount(BigDecimal expectedAmount) { this.expectedAmount = expectedAmount; }

    public String getEvidence() { return evidence; }
    public void setEvidence(String evidence) { this.evidence = evidence; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getHrStaffNote() { return hrStaffNote; }
    public void setHrStaffNote(String hrStaffNote) { this.hrStaffNote = hrStaffNote; }

    public String getAccountantNote() { return accountantNote; }
    public void setAccountantNote(String accountantNote) { this.accountantNote = accountantNote; }

    public BigDecimal getProposedAdjustment() { return proposedAdjustment; }
    public void setProposedAdjustment(BigDecimal proposedAdjustment) { this.proposedAdjustment = proposedAdjustment; }

    public String getHrManagerNote() { return hrManagerNote; }
    public void setHrManagerNote(String hrManagerNote) { this.hrManagerNote = hrManagerNote; }

    public String getDirectorNote() { return directorNote; }
    public void setDirectorNote(String directorNote) { this.directorNote = directorNote; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Integer getHrStaffId() { return hrStaffId; }
    public void setHrStaffId(Integer hrStaffId) { this.hrStaffId = hrStaffId; }

    public Integer getAccountantId() { return accountantId; }
    public void setAccountantId(Integer accountantId) { this.accountantId = accountantId; }

    public Integer getHrManagerId() { return hrManagerId; }
    public void setHrManagerId(Integer hrManagerId) { this.hrManagerId = hrManagerId; }

    public Integer getDirectorId() { return directorId; }
    public void setDirectorId(Integer directorId) { this.directorId = directorId; }

    public String getHrStaffName() { return hrStaffName; }
    public void setHrStaffName(String hrStaffName) { this.hrStaffName = hrStaffName; }

    public String getAccountantName() { return accountantName; }
    public void setAccountantName(String accountantName) { this.accountantName = accountantName; }

    public String getHrManagerName() { return hrManagerName; }
    public void setHrManagerName(String hrManagerName) { this.hrManagerName = hrManagerName; }

    public String getDirectorName() { return directorName; }
    public void setDirectorName(String directorName) { this.directorName = directorName; }
}

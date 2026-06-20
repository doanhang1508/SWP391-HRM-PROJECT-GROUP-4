package model;

import java.sql.Timestamp;

public class PayrollClaim {
    private int claimId;
    private int payrollId;
    private String reason;
    private String status; // "Pending", "Resolved"
    private Timestamp createdAt;

    // Display fields (join)
    private String fullName;
    private int month;
    private int year;
    private String email;

    public PayrollClaim() {}

    public int getClaimId() { return claimId; }
    public void setClaimId(int claimId) { this.claimId = claimId; }

    public int getPayrollId() { return payrollId; }
    public void setPayrollId(int payrollId) { this.payrollId = payrollId; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

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
}

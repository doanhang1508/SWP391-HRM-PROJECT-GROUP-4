package model;

import java.sql.Timestamp;

/**
 * DepartmentShift Entity — maps to the `department_shifts` table.
 * Pure data carrier: represents the mapping of a default shift to a department.
 * All business logic resides in the Service layer.
 *
 * Schema: id, department_id, shift_id, created_at
 */
public class DepartmentShift {

    private int id;
    private int departmentId;
    private int shiftId;
    private Timestamp createdAt;

    // ── Transient: joined display fields ──
    private String departmentName;
    private String shiftName;

    // ── No-arg constructor ──
    public DepartmentShift() {
    }

    // ── Full-arg constructor ──
    public DepartmentShift(int id, int departmentId, int shiftId, Timestamp createdAt) {
        this.id = id;
        this.departmentId = departmentId;
        this.shiftId = shiftId;
        this.createdAt = createdAt;
    }

    // ── Getters & Setters ──
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }

    public int getShiftId() { return shiftId; }
    public void setShiftId(int shiftId) { this.shiftId = shiftId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }
}

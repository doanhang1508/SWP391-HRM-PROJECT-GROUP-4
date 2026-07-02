package model;

/**
 * Ánh xạ tới bảng employment_statuses trong database.
 * Project dùng lookup table, không dùng Enum thuần ở entity, 
 * nhưng cần class này để map tên dễ đọc sang ID trong logic code.
 */
public enum EmploymentStatusCode {
    PROBATION(1),
    FULL_TIME(2),
    PART_TIME(3),
    RESIGNED(4),
    NOTICE_PERIOD(5),
    CONTRACT_EXPIRED(6),
    TERMINATE(7);

    private final int statusId;

    EmploymentStatusCode(int statusId) {
        this.statusId = statusId;
    }

    public int getStatusId() {
        return statusId;
    }
}

package service;

import dao.DepartmentShiftDAO;
import dao.DepartmentShiftDAOImpl;
import dao.ShiftDAO;
import dao.ShiftDAOImpl;
import model.DepartmentShift;
import model.Shift;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import dao.UserDAO;
import model.User;
import dao.ShiftAssignmentDAO;
import dao.ShiftAssignmentDAOImpl;

/**
 * ShiftServiceImpl — ALL business logic for Shift management.
 *
 * Implements Use Case Diagram relationships:
 *   <<include>> Validate Shift Data   → validateShiftData()
 *   <<extend>>  Auto Detect Night Shift → autoDetectNightShift()
 *
 * Also handles midnight crossing, grace periods, lateness, OT prevention,
 * and Department Shift mapping.
 */
public class ShiftServiceImpl implements ShiftService {

    /**
     * Configurable grace period in minutes (HR policy)
     */
    private static final int GRACE_PERIOD_MINUTES = 5;

    private final ShiftDAO shiftDAO;
    private final DepartmentShiftDAO departmentShiftDAO;

    public ShiftServiceImpl() {
        this.shiftDAO = new ShiftDAOImpl();
        this.departmentShiftDAO = new DepartmentShiftDAOImpl();
    }

    public ShiftServiceImpl(ShiftDAO shiftDAO) {
        this.shiftDAO = shiftDAO;
        this.departmentShiftDAO = new DepartmentShiftDAOImpl();
    }

    // ═══════════════════════════════════════════════════════════════
    // CRUD Delegates
    // ═══════════════════════════════════════════════════════════════
    @Override
    public List<Shift> getAllShifts() {
        return shiftDAO.getAllShifts();
    }

    @Override
    public List<Shift> getActiveShifts() {
        return shiftDAO.getActiveShifts();
    }

    @Override
    public Shift getShiftById(int id) {
        return shiftDAO.getShiftById(id);
    }

    @Override
    public boolean addShift(Shift s) {
        return shiftDAO.addShift(s);
    }

    @Override
    public boolean updateShift(Shift s) {
        return shiftDAO.updateShift(s);
    }

    @Override
    public boolean deleteShift(int id) {
        return shiftDAO.deleteShift(id);
    }

    @Override
    public boolean toggleShiftStatus(int id) {
        return shiftDAO.toggleShiftStatus(id);
    }

    @Override
    public boolean isShiftNameExists(String n, int exId) {
        return shiftDAO.isShiftNameExists(n, exId);
    }

    @Override
    public int findOrCreateCustomShift(LocalTime startTime, LocalTime endTime) {
        List<Shift> all = shiftDAO.getAllShifts();
        for (Shift s : all) {
            if (s.getStartTime() != null && s.getEndTime() != null
                    && s.getStartTime().equals(startTime) && s.getEndTime().equals(endTime)
                    && s.getShiftName() != null && s.getShiftName().startsWith("Tăng ca (")) {
                return s.getShiftId();
            }
        }
        
        // Not found, create new one
        Shift newShift = new Shift();
        newShift.setShiftName("Tăng ca (" + startTime.toString() + " - " + endTime.toString() + ")");
        newShift.setStartTime(startTime);
        newShift.setEndTime(endTime);
        autoDetectNightShift(newShift);
        newShift.setCoefficient(1.5f); // Overtime default multiplier
        newShift.setStatus(1); // Active
        
        shiftDAO.addShift(newShift);
        
        // Fetch it again to get the generated ID
        all = shiftDAO.getAllShifts();
        int maxId = -1;
        for (Shift s : all) {
            if (s.getShiftId() > maxId) {
                maxId = s.getShiftId();
            }
        }
        return maxId;
    }

    // ═══════════════════════════════════════════════════════════════
    // <<include>> Validate Shift Data
    //
    // Use Case: Called by both "Create Shift" and "Edit Shift".
    // Ensures data integrity before persisting to database.
    // ═══════════════════════════════════════════════════════════════
    @Override
    public String validateShiftData(Shift shift, int excludeShiftId) {
        // 1. Null check
        if (shift == null) {
            return "Dữ liệu ca làm việc không được null";
        }

        // 2. Shift name validation
        if (shift.getShiftName() == null || shift.getShiftName().trim().isEmpty()) {
            return "Tên ca làm việc không được để trống";
        }
        if (shift.getShiftName().trim().length() > 50) {
            return "Tên ca làm việc không được vượt quá 50 ký tự";
        }

        // 3. Time format validation
        if (shift.getStartTime() == null) {
            return "Giờ bắt đầu không được để trống";
        }
        if (shift.getEndTime() == null) {
            return "Giờ kết thúc không được để trống";
        }

        // 4. Coefficient validation
        if (shift.getCoefficient() <= 0) {
            return "Hệ số lương phải lớn hơn 0";
        }

        // 5. Break time validation
        if (shift.getBreakStart() != null && shift.getBreakEnd() != null) {
            if (!shift.getBreakStart().isBefore(shift.getBreakEnd())) {
                return "Giờ bắt đầu nghỉ phải trước giờ kết thúc nghỉ";
            }
        }

        // 6. Duplicate name check (DB query)
        if (shiftDAO.isShiftNameExists(shift.getShiftName().trim(), excludeShiftId)) {
            return "Tên ca làm việc đã tồn tại trong hệ thống";
        }

        return null; // null = valid
    }

    // ═══════════════════════════════════════════════════════════════
    // <<extend>> Auto Detect Night Shift
    //
    // Use Case: Conditionally triggered by "Create Shift" and "Edit Shift".
    // If end_time.isBefore(start_time), this is a night shift that crosses
    // midnight. The system automatically sets:
    //   - isNightShift = true
    //   - coefficient = 1.3 (night shift premium)
    // ═══════════════════════════════════════════════════════════════
    @Override
    public void autoDetectNightShift(Shift shift) {
        if (shift == null || shift.getStartTime() == null || shift.getEndTime() == null) {
            return;
        }

        if (shift.getEndTime().isBefore(shift.getStartTime())) {
            // End time before start time → crosses midnight → Night Shift
            shift.setNightShift(true);
            shift.setCoefficient(1.3f);
        } else {
            shift.setNightShift(false);
            // Keep coefficient as specified by user (default 1.0)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Department Shift Mapping
    // ═══════════════════════════════════════════════════════════════
    @Override
    public List<DepartmentShift> getAllDepartmentShifts() {
        return departmentShiftDAO.getAll();
    }

    @Override
    public List<DepartmentShift> getDepartmentShiftsByDeptId(int deptId) {
        return departmentShiftDAO.getByDepartmentId(deptId);
    }

    @Override
    public boolean assignDefaultShiftToDepartment(int departmentId, int shiftId) {
        boolean ok = departmentShiftDAO.add(departmentId, shiftId);
        if (ok) {
            // Automatically assign this shift to all users in the department 
            // for Monday to Friday, spanning the next 90 days.
            UserDAO userDAO = new UserDAO();
            List<User> users = userDAO.getByDepartment(departmentId);
            ShiftAssignmentDAO saDAO = new ShiftAssignmentDAOImpl();
            
            LocalDate today = LocalDate.now();
            LocalDate end = today.plusDays(90); // default to 90 days ahead
            
            for (User u : users) {
                saDAO.batchAssignWeekdays(u.getUserId(), shiftId, today, end);
            }
        }
        return ok;
    }

    @Override
    public boolean removeDepartmentShift(int id) {
        return departmentShiftDAO.delete(id);
    }

    // ═══════════════════════════════════════════════════════════════
    // Business Logic
    // ═══════════════════════════════════════════════════════════════
    /**
     * Calculate net working hours.
     *
     * Normal: 08:00→17:00, break 12:00-13:00 → 9h - 1h = 8.0h Night:
     * 22:00→06:00, no break → (24-22)+6 = 8.0h
     *
     * Algorithm: 1. Compute raw minutes = Duration.between(start,
     * end).toMinutes() 2. If end.isBefore(start) OR is_night_shift flag → add
     * 1440 minutes 3. Subtract break minutes (same midnight-safe logic) 4.
     * Ensure non-negative result
     */
    @Override
    public double calculateTotalWorkingHours(Shift shift) {
        if (shift == null || shift.getStartTime() == null || shift.getEndTime() == null) {
            return 0.0;
        }

        LocalTime start = shift.getStartTime();
        LocalTime end = shift.getEndTime();

        // Step 1: Raw duration
        long shiftMinutes = Duration.between(start, end).toMinutes();

        // Step 2: Midnight correction
        // Use BOTH the explicit flag AND the time comparison for safety
        if (end.isBefore(start) || shift.isNightShift()) {
            if (shiftMinutes <= 0) {
                shiftMinutes += 24 * 60;
            }
        }

        // Step 3: Subtract break
        long breakMinutes = 0;
        if (shift.getBreakStart() != null && shift.getBreakEnd() != null) {
            breakMinutes = Duration.between(shift.getBreakStart(), shift.getBreakEnd()).toMinutes();
            if (shift.getBreakEnd().isBefore(shift.getBreakStart())) {
                breakMinutes += 24 * 60;
            }
        }

        // Step 4: Net result, never negative
        long netMinutes = Math.max(0, shiftMinutes - breakMinutes);
        return netMinutes / 60.0;
    }

    /**
     * A shift is a night shift if: - The is_night_shift flag is explicitly set
     * in the DB, OR - The end_time is chronologically before start_time
     * (crosses midnight)
     */
    @Override
    public boolean isNightShift(Shift shift) {
        if (shift == null || shift.getStartTime() == null || shift.getEndTime() == null) {
            return false;
        }
        return shift.isNightShift() || shift.getEndTime().isBefore(shift.getStartTime());
    }

    /**
     * HR Rule: "The check-in date OWNS the shift."
     *
     * For a night shift (22:00 May 31 → 06:00 Jun 1): → work_date =
     * assigned_date (May 31)
     *
     * For a day shift: assigned_date is the work_date itself.
     */
    @Override
    public LocalDate resolveWorkDate(Shift shift, LocalDate assignedDate) {
        // The assigned_date is always the check-in date, which IS the work_date.
        // Night shifts don't change this — the checkout happens on assignedDate + 1,
        // but the work record belongs to assignedDate.
        return assignedDate;
    }

    /**
     * Check if clock-in is within grace period.
     *
     * On-time = clockIn is between (shiftStart - any early) and (shiftStart +
     * gracePeriod). Example: shift 08:00, grace 5 min → clock-in at 08:04 → ON
     * TIME ✓ shift 08:00, grace 5 min → clock-in at 08:06 → LATE ✗
     */
    @Override
    public boolean isWithinGracePeriod(LocalTime shiftStart, LocalTime clockIn) {
        if (shiftStart == null || clockIn == null) {
            return false;
        }

        long diffMinutes = Duration.between(shiftStart, clockIn).toMinutes();

        // Handle midnight crossing for the comparison
        if (diffMinutes < -720) {  // More than 12h "early" = actually late across midnight
            diffMinutes += 24 * 60;
        }

        // On-time: arrived early (diff ≤ 0) or within grace period
        return diffMinutes <= GRACE_PERIOD_MINUTES;
    }

    /**
     * Calculate how many minutes late the employee is. Returns 0 if on-time or
     * early. Subtracts the grace period from the raw lateness.
     */
    @Override
    public long calculateLatenessMinutes(LocalTime shiftStart, LocalTime clockIn) {
        if (shiftStart == null || clockIn == null) {
            return 0;
        }

        long diffMinutes = Duration.between(shiftStart, clockIn).toMinutes();

        // Handle midnight crossing
        if (diffMinutes < -720) {
            diffMinutes += 24 * 60;
        }

        // If within grace or early, not late
        if (diffMinutes <= GRACE_PERIOD_MINUTES) {
            return 0;
        }

        // Late by (diff - grace) minutes
        return diffMinutes - GRACE_PERIOD_MINUTES;
    }

    /**
     * Early check-in OT prevention.
     *
     * If employee clocks in at 07:50 for an 08:00 shift, that's 10 minutes
     * early. Those 10 minutes do NOT count as overtime UNLESS an official OT
     * request exists.
     *
     * @return overtime minutes (0 if no OT request is linked).
     */
    @Override
    public long calculateEarlyCheckInOvertimeMinutes(LocalTime shiftStart, LocalTime clockIn,
            boolean hasOvertimeRequest) {
        if (shiftStart == null || clockIn == null) {
            return 0;
        }

        long diffMinutes = Duration.between(clockIn, shiftStart).toMinutes();

        // Handle midnight crossing
        if (diffMinutes < -720) {
            diffMinutes += 24 * 60;
        }

        // Only positive diff means the employee arrived early
        if (diffMinutes <= 0) {
            return 0;
        }

        // Early arrival is only OT if there's an approved request
        return hasOvertimeRequest ? diffMinutes : 0;
    }
}

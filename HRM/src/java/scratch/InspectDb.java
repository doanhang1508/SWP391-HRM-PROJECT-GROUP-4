package scratch;

import java.time.LocalDate;
import java.util.List;
import model.ShiftAssignment;
import dao.ShiftAssignmentDAOImpl;

public class InspectDb {
    public static void main(String[] args) {
        ShiftAssignmentDAOImpl service = new ShiftAssignmentDAOImpl();
        LocalDate weekStart = LocalDate.of(2026, 7, 6);
        LocalDate weekEnd = weekStart.plusDays(6);

        System.out.println("=== GetByUserAndDateRange ===");
        List<ShiftAssignment> list = service.getByUserAndDateRange(5, weekStart, weekEnd);
        for (ShiftAssignment sa : list) {
            System.out.printf("Date: %s | Shift: %s | Coeff: %.2f | Start: %s | End: %s\n",
                sa.getAssignedDate(), sa.getShiftName(), sa.getCoefficient(),
                sa.getStartTime(), sa.getEndTime());
        }
        System.out.println("Count: " + list.size());
    }
}

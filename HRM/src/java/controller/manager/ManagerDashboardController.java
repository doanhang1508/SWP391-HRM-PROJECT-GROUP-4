package controller.manager;

import dao.DepartmentDAO;
import dao.KpiDAO;
import dao.TransferRequestDAO;
import dao.UserDAO;
import dao.OvertimeAssignmentDAO;
import dao.OvertimeAssignmentDAOImpl;
import dao.LeaveRequestDAO;
import dao.LeaveRequestDAOImpl;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.KpiCycle;
import model.KpiEvaluation;
import model.User;
import util.DBContext;

@WebServlet(name = "ManagerDashboardController", urlPatterns = {"/manager/dashboard"})
public class ManagerDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (currentUser.getRoleId() != 3 && currentUser.getRoleId() != 6) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        int deptId = currentUser.getDepartmentId();

        UserDAO userDAO = new UserDAO();
        OvertimeAssignmentDAO otDAO = new OvertimeAssignmentDAOImpl();
        LeaveRequestDAO leaveDAO = new LeaveRequestDAOImpl();

        int totalEmployees = 0;
        int todayAttendance = 0;
        int pendingOT = 0;
        int pendingLeaves = 0;

        List<String> perfLabels = new ArrayList<>();
        List<Integer> perfTarget = new ArrayList<>();
        List<Integer> perfActual = new ArrayList<>();

        List<String> shiftLabels = new ArrayList<>();
        List<Integer> shiftData = new ArrayList<>();

        LocalDate today = LocalDate.now();

        if (deptId > 0) {
            // 1. Total active employees in department
            totalEmployees = userDAO.getByDepartment(deptId).size();

            // 2. Today's attendance in department (PRESENT, LATE, HALFDAY)
            String sqlTodayAttendance = "SELECT COUNT(*) FROM attendance a " +
                                        "JOIN users u ON a.user_id = u.user_id " +
                                        "WHERE u.department_id = ? AND a.work_date = ? " +
                                        "AND a.status IN ('PRESENT', 'LATE', 'HALFDAY')";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlTodayAttendance)) {
                ps.setInt(1, deptId);
                ps.setDate(2, java.sql.Date.valueOf(today));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        todayAttendance = rs.getInt(1);
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            // 3. Pending overtime requests in department
            pendingOT = otDAO.getPendingAssignmentsByDepartment(deptId).size();

            // 4. Pending leave requests in department
            pendingLeaves = leaveDAO.getPendingLeavesByDepartment(deptId).size();

            // 5. 7-Day Attendance Trend
            String sqlPerf = "SELECT a.work_date, " +
                             "SUM(CASE WHEN a.status IN ('PRESENT', 'LATE', 'HALFDAY') THEN 1 ELSE 0 END) AS present_count " +
                             "FROM attendance a " +
                             "JOIN users u ON a.user_id = u.user_id " +
                             "WHERE u.department_id = ? " +
                             "  AND a.work_date BETWEEN ? AND ? " +
                             "GROUP BY a.work_date";

            java.util.Map<LocalDate, Integer> attendanceMap = new java.util.HashMap<>();
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlPerf)) {
                LocalDate startDate = today.minusDays(6);
                ps.setInt(1, deptId);
                ps.setDate(2, java.sql.Date.valueOf(startDate));
                ps.setDate(3, java.sql.Date.valueOf(today));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LocalDate d = rs.getDate("work_date").toLocalDate();
                        int count = rs.getInt("present_count");
                        attendanceMap.put(d, count);
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM");
            for (int i = 6; i >= 0; i--) {
                LocalDate date = today.minusDays(i);
                perfLabels.add(date.format(dtf));
                perfTarget.add(totalEmployees);
                perfActual.add(attendanceMap.getOrDefault(date, 0));
            }

            // 6. Shift Allocation Today
            String sqlShifts = "SELECT s.shift_name, " +
                               "       (SELECT COUNT(*) FROM shift_assignments sa " +
                               "        JOIN users u ON sa.user_id = u.user_id " +
                               "        WHERE sa.shift_id = s.shift_id " +
                               "          AND sa.assigned_date = ? " +
                               "          AND u.department_id = ? " +
                               "          AND u.status = 1) AS cnt " +
                               "FROM shifts s " +
                               "WHERE s.status = 1";

            int totalAssignedToday = 0;
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlShifts)) {
                ps.setDate(1, java.sql.Date.valueOf(today));
                ps.setInt(2, deptId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String name = rs.getString("shift_name");
                        int count = rs.getInt("cnt");
                        shiftLabels.add(name);
                        shiftData.add(count);
                        totalAssignedToday += count;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            shiftLabels.add("Nghỉ");
            int offCount = Math.max(0, totalEmployees - totalAssignedToday);
            shiftData.add(offCount);

        } else {
            // Defaults/fallback if deptId <= 0
            for (int i = 6; i >= 0; i--) {
                perfLabels.add(today.minusDays(i).format(DateTimeFormatter.ofPattern("dd/MM")));
                perfTarget.add(0);
                perfActual.add(0);
            }
            shiftLabels.add("Nghỉ");
            shiftData.add(0);
        }

        request.setAttribute("totalEmployees", totalEmployees);
        request.setAttribute("todayAttendance", todayAttendance);
        request.setAttribute("pendingOT", pendingOT);
        request.setAttribute("pendingLeaves", pendingLeaves);

        request.setAttribute("perfLabels", perfLabels);
        request.setAttribute("perfTarget", perfTarget);
        request.setAttribute("perfActual", perfActual);
        request.setAttribute("shiftLabels", shiftLabels);
        request.setAttribute("shiftData", shiftData);

        // ── TuVV: Department Manager Dashboard — thêm attribute khi roleId == 6 ──
        if (currentUser.getRoleId() == 6) {
            try {
                TransferRequestDAO transferDAO = new TransferRequestDAO();
                KpiDAO kpiDAO = new KpiDAO();
                int managerId = currentUser.getUserId();

                // Card: Điều chuyển chờ duyệt
                int pendingTransferCount = transferDAO.getEmployeeConfirmedRequestsForManager(deptId).size();
                request.setAttribute("pendingTransferCount", pendingTransferCount);

                // Card: Điều chuyển sắp có hiệu lực (7 ngày tới)
                int upcomingTransferCount = transferDAO.countUpcomingEffectiveTransfers(deptId, 7);
                request.setAttribute("upcomingTransferCount", upcomingTransferCount);

                // Card: Hạn đánh giá KPI
                KpiCycle activeCycle = kpiDAO.getNearestActiveCycle();
                request.setAttribute("activeKpiCycle", activeCycle);

                long kpiDaysLeft = 0;
                if (activeCycle != null && activeCycle.getDeadline() != null) {
                    LocalDate deadline = activeCycle.getDeadline().toLocalDate();
                    kpiDaysLeft = ChronoUnit.DAYS.between(today, deadline);
                }
                request.setAttribute("kpiDaysLeft", kpiDaysLeft);

                // Card + Thanh tiến độ: KPI chưa đánh giá
                int kpiTotalCount = 0;
                int kpiPendingCount = 0;  // DRAFT = chưa đánh giá
                int kpiCompletedCount = 0;
                int kpiProgressPercent = 0;
                List<KpiEvaluation> pendingKpiEvaluations = new ArrayList<>();

                if (activeCycle != null) {
                    List<KpiEvaluation> allEvals = kpiDAO.getEvaluationsByCycleAndManager(
                            activeCycle.getCycleId(), managerId);
                    kpiTotalCount = allEvals.size();

                    for (KpiEvaluation eval : allEvals) {
                        if ("DRAFT".equals(eval.getStatus())) {
                            kpiPendingCount++;
                            // Lấy tối đa 5 evaluation DRAFT cho bảng
                            if (pendingKpiEvaluations.size() < 5) {
                                pendingKpiEvaluations.add(eval);
                            }
                        }
                    }
                    kpiCompletedCount = kpiTotalCount - kpiPendingCount;
                    if (kpiTotalCount > 0) {
                        kpiProgressPercent = (kpiCompletedCount * 100) / kpiTotalCount;
                    }
                }

                request.setAttribute("kpiTotalCount", kpiTotalCount);
                request.setAttribute("kpiPendingCount", kpiPendingCount);
                request.setAttribute("kpiCompletedCount", kpiCompletedCount);
                request.setAttribute("kpiProgressPercent", kpiProgressPercent);
                request.setAttribute("pendingKpiEvaluations", pendingKpiEvaluations);

            } catch (Exception e) {
                // Fallback an toàn — set default nếu DAO lỗi
                e.printStackTrace();
                request.setAttribute("pendingTransferCount", 0);
                request.setAttribute("upcomingTransferCount", 0);
                request.setAttribute("activeKpiCycle", null);
                request.setAttribute("kpiDaysLeft", 0L);
                request.setAttribute("kpiTotalCount", 0);
                request.setAttribute("kpiPendingCount", 0);
                request.setAttribute("kpiCompletedCount", 0);
                request.setAttribute("kpiProgressPercent", 0);
                request.setAttribute("pendingKpiEvaluations", new ArrayList<>());
            }
        }

        request.getRequestDispatcher("/manager/dashboard.jsp").forward(request, response);
    }
}

package controller.hr;

import dao.AttendanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Attendance;
import model.User;

import java.io.*;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller xử lý Import Attendance từ file Excel (CSV format).
 * URL: /hr/import-attendance
 * Roles: HR (2), Admin (1)
 *
 * Expected CSV columns (header row):
 *   user_id, shift_id, work_date (yyyy-MM-dd), check_in (HH:mm), check_out (HH:mm),
 *   status (PRESENT/LATE/ABSENT/HALFDAY), overtime_hrs, ot_reason
 */
@WebServlet(name = "ImportAttendanceController", urlPatterns = {"/hr/import-attendance"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB max
public class ImportAttendanceController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/hr/import-attendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("import".equals(action)) {
            Part filePart = request.getPart("attendanceFile");
            if (filePart == null || filePart.getSize() == 0) {
                session.setAttribute("errorMessage", "Vui lòng chọn file để import.");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            String fileName = filePart.getSubmittedFileName();
            if (!fileName.toLowerCase().endsWith(".csv")) {
                session.setAttribute("errorMessage", "Chỉ hỗ trợ file CSV. Vui lòng export Excel sang CSV trước.");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            // Parse month/year from form to check lock status
            String monthStr = request.getParameter("importMonth");
            String yearStr = request.getParameter("importYear");
            int month = monthStr != null ? Integer.parseInt(monthStr) : LocalDate.now().getMonthValue();
            int year = yearStr != null ? Integer.parseInt(yearStr) : LocalDate.now().getYear();

            // Check lock
            if (attendanceDAO.isMonthLocked(month, year)) {
                session.setAttribute("errorMessage",
                    "Tháng " + month + "/" + year + " đã bị khóa. Không thể import.");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            // Parse CSV
            List<Attendance> records = new ArrayList<>();
            List<String> parseErrors = new ArrayList<>();
            int rowNum = 0;

            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(filePart.getInputStream(), "UTF-8"))) {
                String line;
                boolean firstLine = true;
                while ((line = reader.readLine()) != null) {
                    rowNum++;
                    if (firstLine) { firstLine = false; continue; } // skip header
                    if (line.trim().isEmpty()) continue;

                    String[] cols = line.split(",");
                    try {
                        Attendance a = new Attendance();
                        a.setUserId(Integer.parseInt(cols[0].trim()));
                        a.setShiftId(Integer.parseInt(cols[1].trim()));
                        a.setWorkDate(Date.valueOf(cols[2].trim()));
                        a.setCheckIn(cols[3].trim().isEmpty() ? null : Time.valueOf(cols[3].trim() + ":00"));
                        a.setCheckOut(cols[4].trim().isEmpty() ? null : Time.valueOf(cols[4].trim() + ":00"));
                        String status = cols[5].trim().toUpperCase();
                        if (!status.matches("PRESENT|LATE|ABSENT|HALFDAY")) {
                            parseErrors.add("Dòng " + rowNum + ": Status '" + status + "' không hợp lệ.");
                            continue;
                        }
                        a.setStatus(status);
                        a.setOvertimeHrs(cols.length > 6 && !cols[6].trim().isEmpty()
                                ? Double.parseDouble(cols[6].trim()) : 0.0);
                        a.setOtReason(cols.length > 7 ? cols[7].trim() : "");
                        records.add(a);
                    } catch (Exception e) {
                        parseErrors.add("Dòng " + rowNum + ": Lỗi định dạng - " + e.getMessage());
                    }
                }
            }

            if (records.isEmpty()) {
                session.setAttribute("errorMessage",
                    "Không có dữ liệu hợp lệ để import. " +
                    (parseErrors.isEmpty() ? "" : "Lỗi: " + String.join("; ", parseErrors.subList(0, Math.min(3, parseErrors.size())))));
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            int imported = attendanceDAO.bulkImportAttendance(records);
            String msg = "Import thành công " + imported + "/" + records.size() + " bản ghi.";
            if (!parseErrors.isEmpty()) {
                msg += " Có " + parseErrors.size() + " dòng lỗi định dạng bị bỏ qua.";
            }
            session.setAttribute("successMessage", msg);
            response.sendRedirect(request.getContextPath() + "/hr/import-attendance");

        } else {
            response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
        }
    }
}

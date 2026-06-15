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

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.usermodel.WorkbookFactory;

import java.io.*;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller xử lý Import Attendance từ file Excel (.xlsx/.xls) hoặc CSV.
 * URL: /hr/import-attendance
 * Roles: HR Manager (2), Admin (1)
 *
 * Các cột (áp dụng cho cả Excel và CSV, theo thứ tự):
 * user_id, shift_id, work_date (yyyy-MM-dd), check_in (HH:mm), check_out
 * (HH:mm),
 * status (PRESENT/LATE/ABSENT/HALFDAY), overtime_hrs, ot_reason
 */
@WebServlet(name = "ImportAttendanceController", urlPatterns = { "/hr/import-attendance" })
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB max
public class ImportAttendanceController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Set current month for the form default
        LocalDate now = LocalDate.now();
        request.setAttribute("currentMonth", now.getMonthValue());
        request.setAttribute("currentYear", now.getYear());
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

            String fileName = filePart.getSubmittedFileName().toLowerCase();
            boolean isExcel = fileName.endsWith(".xlsx") || fileName.endsWith(".xls");
            boolean isCsv = fileName.endsWith(".csv");

            if (!isExcel && !isCsv) {
                session.setAttribute("errorMessage",
                        "Chỉ hỗ trợ file Excel (.xlsx, .xls) hoặc CSV (.csv).");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            // Parse month/year để kiểm tra khóa công
            String monthStr = request.getParameter("importMonth");
            String yearStr = request.getParameter("importYear");
            int month = monthStr != null ? Integer.parseInt(monthStr) : LocalDate.now().getMonthValue();
            int year = yearStr != null ? Integer.parseInt(yearStr) : LocalDate.now().getYear();

            if (attendanceDAO.isMonthLocked(month, year)) {
                session.setAttribute("errorMessage",
                        "Tháng " + month + "/" + year + " đã bị khóa. Không thể import.");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            List<Attendance> records = new ArrayList<>();
            List<String> parseErrors = new ArrayList<>();

            try {
                if (isExcel) {
                    parseExcel(filePart.getInputStream(), records, parseErrors);
                } else {
                    parseCsv(filePart.getInputStream(), records, parseErrors);
                }
            } catch (Exception ex) {
                session.setAttribute("errorMessage",
                        "Lỗi đọc file: " + ex.getMessage() +
                                ". Hãy đảm bảo file đúng định dạng Excel hoặc CSV.");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            if (records.isEmpty()) {
                session.setAttribute("errorMessage",
                        "Không có dữ liệu hợp lệ để import. " +
                                (parseErrors.isEmpty() ? ""
                                        : "Lỗi: " +
                                                String.join("; ",
                                                        parseErrors.subList(0, Math.min(3, parseErrors.size())))));
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

    // ──────────────────────────────────────────────────────────────
    // EXCEL PARSER (Apache POI)
    // ──────────────────────────────────────────────────────────────
    private void parseExcel(InputStream is, List<Attendance> records, List<String> errors)
            throws Exception {
        try (Workbook wb = WorkbookFactory.create(is)) {
            Sheet sheet = wb.getSheetAt(0);
            boolean firstRow = true;
            int rowNum = 0;
            for (Row row : sheet) {
                rowNum++;
                if (firstRow) {
                    firstRow = false;
                    continue;
                } // bỏ qua header
                if (isRowEmpty(row))
                    continue;
                try {
                    Attendance a = rowToAttendance(row, rowNum);
                    if (a != null)
                        records.add(a);
                } catch (Exception e) {
                    errors.add("Dòng " + rowNum + ": " + e.getMessage());
                }
            }
        }
    }

    private boolean isRowEmpty(Row row) {
        if (row == null)
            return true;
        for (Cell cell : row) {
            if (cell != null && cell.getCellType() != CellType.BLANK)
                return false;
        }
        return true;
    }

    private Attendance rowToAttendance(Row row, int rowNum) throws Exception {
        Attendance a = new Attendance();

        // Col 0: user_id
        a.setUserId((int) getNumericCell(row, 0, rowNum, "user_id"));

        // Col 1: shift_id
        a.setShiftId((int) getNumericCell(row, 1, rowNum, "shift_id"));

        // Col 2: work_date (yyyy-MM-dd)
        String dateStr = getStringCell(row, 2);
        if (dateStr == null || dateStr.isEmpty())
            throw new Exception("Thiếu work_date");
        // Nếu Excel tự chuyển ngày thành số (Excel date serial)
        Cell dateCell = row.getCell(2);
        if (dateCell != null && dateCell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(dateCell)) {
            java.util.Date d = dateCell.getDateCellValue();
            a.setWorkDate(new Date(d.getTime()));
        } else {
            a.setWorkDate(Date.valueOf(LocalDate.parse(dateStr.trim(), DATE_FMT)));
        }

        // Col 3: check_in (HH:mm) — tùy chọn
        String checkIn = getStringCell(row, 3);
        a.setCheckIn(checkIn != null && !checkIn.isEmpty() ? Time.valueOf(checkIn.trim() + ":00") : null);

        // Col 4: check_out (HH:mm) — tùy chọn
        String checkOut = getStringCell(row, 4);
        a.setCheckOut(checkOut != null && !checkOut.isEmpty() ? Time.valueOf(checkOut.trim() + ":00") : null);

        // Col 5: status
        String status = getStringCell(row, 5);
        if (status == null || status.isEmpty())
            throw new Exception("Thiếu status");
        status = status.trim().toUpperCase();
        if (!status.matches("PRESENT|LATE|ABSENT|HALFDAY"))
            throw new Exception("Status '" + status + "' không hợp lệ");
        a.setStatus(status);

        // Col 6: overtime_hrs — tùy chọn
        Cell otCell = row.getCell(6);
        if (otCell != null && otCell.getCellType() == CellType.NUMERIC) {
            a.setOvertimeHrs(otCell.getNumericCellValue());
        } else {
            String otStr = getStringCell(row, 6);
            a.setOvertimeHrs(otStr != null && !otStr.isEmpty() ? Double.parseDouble(otStr.trim()) : 0.0);
        }

        // Col 7: ot_reason — tùy chọn
        String otReason = getStringCell(row, 7);
        a.setOtReason(otReason != null ? otReason.trim() : "");

        return a;
    }

    private double getNumericCell(Row row, int col, int rowNum, String name) throws Exception {
        Cell cell = row.getCell(col);
        if (cell == null)
            throw new Exception("Thiếu cột " + name);
        if (cell.getCellType() == CellType.NUMERIC)
            return cell.getNumericCellValue();
        if (cell.getCellType() == CellType.STRING) {
            try {
                return Double.parseDouble(cell.getStringCellValue().trim());
            } catch (NumberFormatException e) {
                throw new Exception("Cột " + name + " phải là số");
            }
        }
        throw new Exception("Cột " + name + " không đọc được");
    }

    private String getStringCell(Row row, int col) {
        Cell cell = row.getCell(col);
        if (cell == null)
            return null;
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    // Trả về dạng HH:mm nếu là time
                    java.util.Date d = cell.getDateCellValue();
                    java.util.Calendar cal = java.util.Calendar.getInstance();
                    cal.setTime(d);
                    return String.format("%02d:%02d", cal.get(java.util.Calendar.HOUR_OF_DAY),
                            cal.get(java.util.Calendar.MINUTE));
                }
                return String.valueOf((long) cell.getNumericCellValue());
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            default:
                return null;
        }
    }

    // ──────────────────────────────────────────────────────────────
    // CSV PARSER (giữ nguyên logic cũ)
    // ──────────────────────────────────────────────────────────────
    private void parseCsv(InputStream is, List<Attendance> records, List<String> errors)
            throws IOException {
        int rowNum = 0;
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            String line;
            boolean firstLine = true;
            while ((line = reader.readLine()) != null) {
                rowNum++;
                if (firstLine) {
                    firstLine = false;
                    continue;
                }
                if (line.trim().isEmpty())
                    continue;
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
                        errors.add("Dòng " + rowNum + ": Status '" + status + "' không hợp lệ.");
                        continue;
                    }
                    a.setStatus(status);
                    a.setOvertimeHrs(cols.length > 6 && !cols[6].trim().isEmpty()
                            ? Double.parseDouble(cols[6].trim())
                            : 0.0);
                    a.setOtReason(cols.length > 7 ? cols[7].trim() : "");
                    records.add(a);
                } catch (Exception e) {
                    errors.add("Dòng " + rowNum + ": Lỗi định dạng - " + e.getMessage());
                }
            }
        }
    }
}

package controller.hr;

import dao.AttendanceDAO;
import dao.UserDAO;
import dao.ShiftDAOImpl;
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
import model.Shift;

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
 * Roles: HR Manager (2), HR Staff (5), Admin (1)
 */
@WebServlet(name = "ImportAttendanceController", urlPatterns = {"/hr/import-attendance"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class ImportAttendanceController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 5)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

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

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 5)) {
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

            if (!isExcel) {
                session.setAttribute("errorMessage", "Chỉ hỗ trợ file Excel (.xlsx, .xls).");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

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
                parseExcel(filePart.getInputStream(), records, parseErrors);
            } catch (Exception ex) {
                session.setAttribute("errorMessage",
                        "Lỗi đọc file: " + ex.getMessage() +
                                ". Hãy đảm bảo file đúng định dạng Excel.");
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
            
            // Tự động tạo bảng lương nháp dựa trên bảng công vừa import
            dao.PayrollDAO payrollDAO = new dao.PayrollDAO();
            int payrollsCreated = payrollDAO.generatePayrollDraft(month, year);
            
            String msg = "Import thành công " + imported + "/" + records.size() + " bản ghi. Đã tự động tạo " + payrollsCreated + " bảng lương nháp.";
            if (!parseErrors.isEmpty()) {
                msg += " Có " + parseErrors.size() + " dòng lỗi định dạng bị bỏ qua.";
            }
            session.setAttribute("successMessage", msg);
            response.sendRedirect(request.getContextPath() + "/hr/import-attendance");

        } else {
            response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
        }
    }

    private void parseExcel(InputStream is, List<Attendance> records, List<String> errors)
            throws Exception {
        UserDAO userDAO = new UserDAO();
        ShiftDAOImpl shiftDAO = new ShiftDAOImpl();
        List<Shift> allShifts = shiftDAO.getAllShifts();

        try (Workbook wb = WorkbookFactory.create(is)) {
            Sheet sheet = wb.getSheet("CHI_TIET_CHAM_CONG");
            if (sheet == null) {
                // Thử tìm sheet có chứa chữ CHAM_CONG hoặc lấy sheet cuối cùng
                for (int i = 0; i < wb.getNumberOfSheets(); i++) {
                    if (wb.getSheetName(i).toUpperCase().contains("CHAM_CONG")) {
                        sheet = wb.getSheetAt(i);
                        break;
                    }
                }
                if (sheet == null) sheet = wb.getSheetAt(0); // Fallback về sheet 0 nếu không tìm thấy
            }
            for (Row row : sheet) {
                if (row.getRowNum() < 3) continue; // Bỏ qua 3 dòng đầu (headers)

                if (isRowEmpty(row)) continue;
                try {
                    Attendance a = rowToAttendance(row, row.getRowNum() + 1, userDAO, allShifts);
                    if (a != null) records.add(a);
                } catch (Exception e) {
                    errors.add("Dòng " + (row.getRowNum() + 1) + ": " + e.getMessage());
                }
            }
        }
    }

    private boolean isRowEmpty(Row row) {
        if (row == null) return true;
        for (int i = 0; i < 20; i++) {
            Cell cell = row.getCell(i);
            if (cell != null && cell.getCellType() != CellType.BLANK) return false;
        }
        return true;
    }

    private Attendance rowToAttendance(Row row, int rowNum, UserDAO userDAO, List<Shift> allShifts) throws Exception {
        Attendance a = new Attendance();

        // 1. Mã NV (Cột 1)
        Cell empCodeCell = row.getCell(1);
        if (empCodeCell == null || empCodeCell.getCellType() == CellType.BLANK) {
            throw new Exception("Mã nhân viên trống.");
        }
        String employeeCode = empCodeCell.getStringCellValue().trim();
        
        User user = null;
        if (employeeCode.toUpperCase().startsWith("NV")) {
            try {
                int userId = Integer.parseInt(employeeCode.substring(2));
                user = userDAO.getUserById(userId);
            } catch (NumberFormatException e) {
                // Ignore parsing error, try username lookup next
            }
        }
        if (user == null) {
            user = userDAO.getUserByUsername(employeeCode);
        }
        
        if (user == null) {
            throw new Exception("Không tìm thấy nhân viên: " + employeeCode);
        }
        a.setUserId(user.getUserId());

        Cell dateCell = row.getCell(5);
        if (dateCell == null) throw new Exception("Thiếu Ngày làm việc");
        if (dateCell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(dateCell)) {
            java.util.Date d = dateCell.getDateCellValue();
            a.setWorkDate(new Date(d.getTime()));
        } else {
            String dateStr = getStringCell(row, 5);
            if (dateStr == null || dateStr.trim().isEmpty()) throw new Exception("Thiếu Ngày làm việc");
            a.setWorkDate(Date.valueOf(LocalDate.parse(dateStr.trim(), DATE_FMT)));
        }

        String shiftName = getStringCell(row, 7);
        if (shiftName == null || shiftName.trim().isEmpty()) {
            throw new Exception("Thiếu Ca làm việc");
        }
        shiftName = shiftName.trim();
        int shiftId = -1;
        for (Shift s : allShifts) {
            if (s.getShiftName().equalsIgnoreCase(shiftName)) {
                shiftId = s.getShiftId();
                break;
            }
        }
        if (shiftId == -1) {
            throw new Exception("Không tìm thấy Ca làm việc: " + shiftName);
        }
        a.setShiftId(shiftId);

        String checkIn = getStringCell(row, 10);
        if (checkIn != null && !checkIn.trim().isEmpty() && !checkIn.equalsIgnoreCase("BLANK")) {
            if (checkIn.length() == 5) checkIn += ":00";
            a.setCheckIn(Time.valueOf(checkIn.trim()));
        } else {
            a.setCheckIn(null);
        }

        String checkOut = getStringCell(row, 11);
        if (checkOut != null && !checkOut.trim().isEmpty() && !checkOut.equalsIgnoreCase("BLANK")) {
            if (checkOut.length() == 5) checkOut += ":00";
            a.setCheckOut(Time.valueOf(checkOut.trim()));
        } else {
            a.setCheckOut(null);
        }

        String status = getStringCell(row, 20);
        if (status == null || status.trim().isEmpty() || status.equalsIgnoreCase("BLANK")) {
             status = "A"; // default absent
        }
        status = status.trim().toUpperCase();
        switch (status) {
            case "P": a.setStatus("PRESENT"); break;
            case "A": a.setStatus("ABSENT"); break;
            case "L": a.setStatus("LATE"); break;
            case "H": a.setStatus("HALFDAY"); break;
            default: a.setStatus("PRESENT"); break; // Fallback
        }

        Cell otCell = row.getCell(16);
        if (otCell != null && otCell.getCellType() == CellType.NUMERIC) {
            a.setOvertimeHrs(otCell.getNumericCellValue());
        } else {
            String otStr = getStringCell(row, 16);
            if (otStr != null && !otStr.trim().isEmpty() && !otStr.equalsIgnoreCase("BLANK")) {
                try {
                    a.setOvertimeHrs(Double.parseDouble(otStr.trim()));
                } catch (Exception e) {
                    a.setOvertimeHrs(0.0);
                }
            } else {
                a.setOvertimeHrs(0.0);
            }
        }

        String otReason = getStringCell(row, 17);
        a.setOtReason(otReason != null && !otReason.equalsIgnoreCase("BLANK") ? otReason.trim() : "");
        
        return a;
    }

    private String getStringCell(Row row, int col) {
        Cell cell = row.getCell(col);
        if (cell == null) return null;
        switch (cell.getCellType()) {
            case STRING: return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    java.util.Date d = cell.getDateCellValue();
                    java.util.Calendar cal = java.util.Calendar.getInstance();
                    cal.setTime(d);
                    return String.format("%02d:%02d", cal.get(java.util.Calendar.HOUR_OF_DAY), cal.get(java.util.Calendar.MINUTE));
                }
                double numValue = cell.getNumericCellValue();
                if (numValue == (long) numValue) {
                    return String.format("%d", (long) numValue);
                } else {
                    return String.format("%s", numValue);
                }
            case BOOLEAN: return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                switch(cell.getCachedFormulaResultType()) {
                    case STRING: return cell.getStringCellValue();
                    case NUMERIC:
                        double numValueF = cell.getNumericCellValue();
                        if (numValueF == (long) numValueF) {
                            return String.format("%d", (long) numValueF);
                        } else {
                            return String.format("%s", numValueF);
                        }
                    case BOOLEAN: return String.valueOf(cell.getBooleanCellValue());
                    default: return null;
                }
            default: return null;
        }
    }
}

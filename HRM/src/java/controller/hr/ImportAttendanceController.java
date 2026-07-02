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

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 5)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("checkLock".equals(action)) {
            String monthStr = request.getParameter("month");
            String yearStr = request.getParameter("year");
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = null;
            try {
                out = response.getWriter();
                int month = monthStr != null ? Integer.parseInt(monthStr) : LocalDate.now().getMonthValue();
                int year = yearStr != null ? Integer.parseInt(yearStr) : LocalDate.now().getYear();
                boolean isLocked = attendanceDAO.isMonthLocked(month, year);
                out.print("{\"isLocked\": " + isLocked + "}");
            } catch (Exception e) {
                if (out != null) {
                    out.print("{\"isLocked\": false}");
                }
            } finally {
                if (out != null) {
                    out.flush();
                }
            }
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

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 5)) {
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

            String submittedFileName = filePart.getSubmittedFileName();
            if (submittedFileName == null) {
                session.setAttribute("errorMessage", "Không xác định được tên file.");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }
            String fileName = submittedFileName.toLowerCase();
            boolean isExcel = fileName.endsWith(".xlsx") || fileName.endsWith(".xls");

            if (!isExcel) {
                session.setAttribute("errorMessage", "Chỉ hỗ trợ file Excel (.xlsx, .xls).");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            String monthStr = request.getParameter("importMonth");
            String yearStr = request.getParameter("importYear");
            int month, year;
            try {
                month = monthStr != null ? Integer.parseInt(monthStr) : LocalDate.now().getMonthValue();
                year = yearStr != null ? Integer.parseInt(yearStr) : LocalDate.now().getYear();
                if (month < 1 || month > 12) {
                    throw new NumberFormatException("Month out of range");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Tháng/năm không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            boolean isLocked = attendanceDAO.isMonthLocked(month, year);
            String confirmedLocked = request.getParameter("confirmedLocked");
            if (isLocked && !"true".equals(confirmedLocked)) {
                session.setAttribute("errorMessage",
                        "Tháng " + month + "/" + year + " đã bị khóa. Vui lòng xác nhận trước khi import.");
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            List<Attendance> records = new ArrayList<>();
            List<String> parseErrors = new ArrayList<>();
            List<String> skippedRows = new ArrayList<>();

            try {
                parseExcel(filePart.getInputStream(), records, parseErrors, skippedRows, month, year);
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
                session.setAttribute("fullParseErrors", parseErrors);
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            int[] importResult = attendanceDAO.bulkImportAttendance(records);
            int inserted = importResult[0];
            int updated  = importResult[1];

            String msg;
            if (inserted > 0 && updated == 0) {
                msg = "✅ Import thành công: " + inserted + " bản ghi MỚI.";
            } else if (inserted == 0 && updated > 0) {
                msg = "🔄 Import thành công: " + updated + " bản ghi đã được CẬP NHẬT (ghi đè dữ liệu cũ).";
            } else {
                msg = "✅ Import thành công: " + inserted + " bản ghi MỚI, " + updated + " bản ghi CẬP NHẬT.";
            }
            if (!skippedRows.isEmpty()) {
                msg += " Đã bỏ qua " + skippedRows.size() + " dòng tổng hợp/header (bình thường).";
            }
            if (!parseErrors.isEmpty()) {
                msg += " ⚠️ Có " + parseErrors.size() + " dòng lỗi thực sự cần kiểm tra.";
            }
            session.setAttribute("successMessage", msg);
            session.setAttribute("fullParseErrors", parseErrors);
            response.sendRedirect(request.getContextPath() + "/hr/import-attendance");

        } else {
            response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
        }
    }

    private String removeAccents(String s) {
        if (s == null) return null;
        String normalized = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD);
        return normalized.replaceAll("\\p{M}", "").replaceAll("\\s+", "_").toUpperCase();
    }

    private boolean isRawLogFormat(Sheet sheet) {
        Row headerRow = sheet.getRow(1);
        if (headerRow == null) headerRow = sheet.getRow(2);
        if (headerRow == null) return true;
        int lastCol = headerRow.getLastCellNum();
        if (lastCol < 6) return true;
        
        boolean hasWorkDateCol = false;
        for (int c = 0; c < lastCol; c++) {
            Cell cell = headerRow.getCell(c);
            if (cell != null) {
                String val = cell.toString().toLowerCase();
                if (val.contains("ngày làm") || val.contains("ngay lam")) {
                    hasWorkDateCol = true;
                    break;
                }
            }
        }
        return !hasWorkDateCol;
    }

    private void parseExcel(InputStream is, List<Attendance> records, List<String> errors,
                             List<String> skippedRows, int month, int year)
            throws Exception {
        UserDAO userDAO = new UserDAO();
        ShiftDAOImpl shiftDAO = new ShiftDAOImpl();
        List<Shift> allShifts = shiftDAO.getAllShifts();
        List<User> allUsers = userDAO.getAllUsers();
        java.util.Map<Integer, User> userMap = new java.util.HashMap<>();
        java.util.Map<String, User> usernameMap = new java.util.HashMap<>();
        for (User u : allUsers) {
            userMap.put(u.getUserId(), u);
            if (u.getUsername() != null) {
                usernameMap.put(u.getUsername().toUpperCase(), u);
            }
        }

        try (Workbook wb = WorkbookFactory.create(is)) {
            Sheet sheet = wb.getSheet("CHI_TIET_CHAM_CONG");//tim dung File de doc
            if (sheet == null) {
                // Thử tìm sheet có chứa chữ CHAM_CONG hoặc lấy sheet ĐẦU TIÊN
                for (int i = 0; i < wb.getNumberOfSheets(); i++) {
                    String sName = removeAccents(wb.getSheetName(i));
                    if (sName != null && sName.contains("CHAM_CONG")) {
                        sheet = wb.getSheetAt(i);
                        break;
                    }
                }
                if (sheet == null) sheet = wb.getSheetAt(0); // Fallback về sheet 0
            }

            if (isRawLogFormat(sheet)) {
                // 1. Group swipe logs from Sheet 1 ("Chi Tiết Chấm Công")
                java.util.Map<String, java.util.Map<LocalDate, List<Time>>> swipeMap = new java.util.HashMap<>();
                for (Row row : sheet) {
                    if (row.getRowNum() < 2) continue; // Bỏ qua 2 dòng đầu (title, header)
                    if (isRowEmpty(row)) continue;
                    
                    String empCode = getStringCell(row, 2); // Column 2: Mã Nhân Viên
                    if (empCode == null || empCode.trim().isEmpty()) {
                        empCode = getStringCell(row, 1); // Fallback to column 1
                    }
                    if (empCode == null || empCode.trim().isEmpty()) continue;
                    empCode = empCode.trim().toUpperCase();
                    
                    Cell timeCell = row.getCell(3); // Column 3: Giờ
                    if (timeCell == null) continue;
                    
                    java.util.Date dateTime = null;
                    if (timeCell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(timeCell)) {
                        dateTime = timeCell.getDateCellValue();
                    } else {
                        String timeStr = getStringCell(row, 3);
                        if (timeStr != null && !timeStr.trim().isEmpty()) {
                            timeStr = timeStr.replace("//", "/").replace("  ", " ").trim();
                            String[] formats = {
                                "dd/MM/yyyy hh:mm a", "dd/MM/yyyy hh:mm:ss a",
                                "yyyy-MM-dd hh:mm a", "yyyy-MM-dd hh:mm:ss a",
                                "dd/MM/yyyy HH:mm:ss", "yyyy-MM-dd HH:mm:ss",
                                "dd/MM/yyyy HH:mm", "yyyy-MM-dd HH:mm",
                                "dd-MM-yyyy HH:mm:ss", "dd-MM-yyyy HH:mm"
                            };
                            for (String fmt : formats) {
                                try {
                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(fmt, java.util.Locale.ENGLISH);
                                    dateTime = sdf.parse(timeStr);
                                    break;
                                } catch (Exception ignored) {}
                            }
                        }
                    }
                    
                    if (dateTime != null) {
                        java.util.Calendar cal = java.util.Calendar.getInstance();
                        cal.setTime(dateTime);
                        LocalDate date = LocalDate.of(cal.get(java.util.Calendar.YEAR), cal.get(java.util.Calendar.MONTH) + 1, cal.get(java.util.Calendar.DAY_OF_MONTH));
                        Time time = new Time(dateTime.getTime());
                        
                        swipeMap.computeIfAbsent(empCode, k -> new java.util.HashMap<>())
                                .computeIfAbsent(date, k -> new java.util.ArrayList<>())
                                .add(time);
                    }
                }

                // 2. Parse Sheet 0 ("Bảng Công") to get employee profiles, shifts, and daily statuses
                Sheet sheet0 = wb.getSheetAt(0);
                Row row4 = sheet0.getRow(4); // Day numbers
                if (row4 == null) {
                    throw new Exception("Không tìm thấy dòng ngày (dòng 5) ở Sheet Bảng Công.");
                }
                
                int otColIdx = -1;
                Row headerRow = sheet0.getRow(3);
                if (headerRow != null) {
                    for (int c = 0; c < headerRow.getLastCellNum(); c++) {
                        String h = getStringCell(headerRow, c);
                        if (h != null && (h.toUpperCase().contains("OT") || h.toUpperCase().contains("TĂNG CA") || h.toUpperCase().contains("TANG CA"))) {
                            otColIdx = c;
                            break;
                        }
                    }
                }
                
                java.util.Map<Integer, Integer> colToDayMap = new java.util.HashMap<>();
                for (int c = 6; c < row4.getLastCellNum(); c++) {
                    Cell cell = row4.getCell(c);
                    if (cell != null) {
                        try {
                            double val = 0;
                            if (cell.getCellType() == CellType.NUMERIC) {
                                val = cell.getNumericCellValue();
                            } else {
                                val = Double.parseDouble(cell.toString().trim());
                            }
                            if (val > 0) {
                                colToDayMap.put(c, (int) val);
                            }
                        } catch (Exception ignored) {}
                    }
                }
                
                for (int r = 5; r <= sheet0.getLastRowNum(); r++) {
                    Row row = sheet0.getRow(r);
                    if (row == null || isRowEmpty(row)) continue;
                    
                    String empCode = getStringCell(row, 1); // Column 1: Mã NV
                    if (empCode == null || empCode.trim().isEmpty()) continue;
                    empCode = empCode.trim().toUpperCase();
                    
                    User user = null;
                    if (empCode.startsWith("NV")) {
                        try {
                            int userId = Integer.parseInt(empCode.substring(2));
                            user = userMap.get(userId);
                        } catch (NumberFormatException ignored) {}
                    }
                    if (user == null) {
                        user = usernameMap.get(empCode);
                    }
                    if (user == null) {
                        errors.add("Dòng " + (r + 1) + " (Sheet Bảng Công): Không tìm thấy nhân viên: " + empCode);
                        continue;
                    }
                    
                    String shiftName = getStringCell(row, 5); // Column 5: Ca làm
                    if (shiftName == null || shiftName.trim().isEmpty()) {
                        errors.add("Dòng " + (r + 1) + " (Sheet Bảng Công): Thiếu Ca làm việc cho NV " + empCode);
                        continue;
                    }
                    shiftName = shiftName.trim();
                    if (shiftName.contains("(")) {
                        shiftName = shiftName.substring(0, shiftName.indexOf("(")).trim();
                    }
                    int shiftId = -1;
                    for (Shift s : allShifts) {
                        if (s.getShiftName().equalsIgnoreCase(shiftName)) {
                            shiftId = s.getShiftId();
                            break;
                        }
                    }
                    if (shiftId == -1) {
                        errors.add("Dòng " + (r + 1) + " (Sheet Bảng Công): Không tìm thấy Ca làm việc: " + shiftName);
                        continue;
                    }
                    
                    double totalOtHrs = 0.0;
                    if (otColIdx != -1) {
                        Cell otCell = row.getCell(otColIdx);
                        if (otCell != null) {
                            try {
                                if (otCell.getCellType() == CellType.NUMERIC) {
                                    totalOtHrs = otCell.getNumericCellValue();
                                } else {
                                    totalOtHrs = Double.parseDouble(otCell.toString().trim());
                                }
                            } catch (Exception ignored) {}
                        }
                    }
                    boolean otAssigned = false;
                    Attendance lastA = null;
                    
                    for (java.util.Map.Entry<Integer, Integer> entry : colToDayMap.entrySet()) {
                        int colIdx = entry.getKey();
                        int day = entry.getValue();
                        
                        String statusChar = getStringCell(row, colIdx);
                        if (statusChar == null || statusChar.trim().isEmpty() || statusChar.equalsIgnoreCase("BLANK")) {
                            continue;
                        }
                        statusChar = statusChar.trim().toUpperCase();
                        if (statusChar.startsWith("CỘNG") || statusChar.startsWith("CONG") 
                                || statusChar.startsWith("TỔNG") || statusChar.startsWith("TONG")) {
                            continue;
                        }
                        
                        LocalDate workLocalDate = LocalDate.of(year, month, day);
                        Date workDate = Date.valueOf(workLocalDate);
                        
                        Attendance a = new Attendance();
                        a.setUserId(user.getUserId());
                        a.setShiftId(shiftId);
                        a.setWorkDate(workDate);
                        
                        String status = "ABSENT";
                        switch (statusChar) {
                            case "P":
                                status = "PRESENT"; break;
                            case "A":
                                status = "ABSENT"; break;
                            case "L":
                            case "T":
                                status = "LATE"; break;
                            case "H":
                                status = "HALFDAY"; break;
                            case "NGHI PHEP":
                            case "NP":
                                status = "LEAVE"; break;
                            default:
                                status = "PRESENT";
                        }
                        a.setStatus(status);
                        
                        java.util.Map<LocalDate, List<Time>> userSwipes = swipeMap.get(empCode);
                        if (userSwipes != null) {
                            List<Time> swipes = userSwipes.get(workLocalDate);
                            if (swipes != null && !swipes.isEmpty()) {
                                java.util.Collections.sort(swipes);
                                a.setCheckIn(swipes.get(0));
                                if (swipes.size() > 1) {
                                    a.setCheckOut(swipes.get(swipes.size() - 1));
                                } else {
                                    a.setCheckOut(null);
                                }
                            } else {
                                a.setCheckIn(null);
                                a.setCheckOut(null);
                            }
                        } else {
                            a.setCheckIn(null);
                            a.setCheckOut(null);
                        }
                        
                        a.setOvertimeHrs(0.0);
                        a.setOtReason("");
                        if (!otAssigned && totalOtHrs > 0 && "PRESENT".equals(status)) {
                            a.setOvertimeHrs(totalOtHrs);
                            a.setOtReason("Imported OT");
                            otAssigned = true;
                        }
                        
                        lastA = a;
                        records.add(a);
                    }
                    if (!otAssigned && totalOtHrs > 0 && lastA != null) {
                        lastA.setOvertimeHrs(totalOtHrs);
                        lastA.setOtReason("Imported OT");
                    }
                }
            } else {
                // 13-column format
                for (Row row : sheet) {
                    if (row.getRowNum() < 3) continue; // Bỏ qua 3 dòng đầu (headers)
                    if (isRowEmpty(row)) continue;
                    try {
                        Attendance a = rowToAttendance(row, userMap, usernameMap, allShifts);
                        if (a != null) {
                            records.add(a);
                        } else {
                            skippedRows.add("Dòng " + (row.getRowNum() + 1) + " bị bỏ qua (dòng tổng hợp/header)");
                        }
                    } catch (Exception e) {
                        errors.add("Dòng " + (row.getRowNum() + 1) + ": " + e.getMessage());
                    }
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

    private Attendance rowToAttendance(Row row, java.util.Map<Integer, User> userMap, java.util.Map<String, User> usernameMap, List<Shift> allShifts) throws Exception {
        Attendance a = new Attendance();

        // ── Scan 6 cột đầu vì dòng "Cộng:" có thể nằm ở cột bất kỳ do merged cell ──
        for (int ci = 0; ci < 6; ci++) {
            String cellVal = getStringCell(row, ci);
            if (cellVal == null) continue;
            String cellNorm = java.text.Normalizer.normalize(cellVal.trim(), java.text.Normalizer.Form.NFD)
                    .replaceAll("\\p{M}", "").toLowerCase();
            if (cellNorm.startsWith("cong:") || (cellNorm.contains("p:") && cellNorm.contains("a:"))) {
                return null; // dòng tổng hợp, bỏ qua
            }
        }
        String secondCell = getStringCell(row, 1);
        if (secondCell == null || secondCell.trim().isEmpty()) {
            return null; // dòng trống hoặc không có Mã NV, bỏ qua
        }

        // Vẫn giữ kiểm tra header / dòng tổng hợp theo nội dung cột Mã NV
        String col1Upper = secondCell.trim().toUpperCase();
        if (col1Upper.startsWith("C\u1ed8NG") || col1Upper.startsWith("CONG")
                || col1Upper.startsWith("T\u1ed4NG") || col1Upper.startsWith("TONG")
                || col1Upper.equals("M\u00c3 NV") || col1Upper.equals("MA NV")
                || col1Upper.equals("STT")) {
            return null; // dòng tổng hợp / header — không phải lỗi
        }

        // 1. Mã NV (Cột 1)
        String employeeCode = secondCell;
        employeeCode = employeeCode.trim();
        
        User user = null;
        if (employeeCode.toUpperCase().startsWith("NV")) {
            try {
                int userId = Integer.parseInt(employeeCode.substring(2));
                user = userMap.get(userId);
            } catch (NumberFormatException e) {
                // Ignore parsing error, try username lookup next
            }
        }
        if (user == null) {
            user = usernameMap.get(employeeCode.toUpperCase());
        }
        
        if (user == null) {
            throw new Exception("Kh\u00f4ng t\u00ecm th\u1ea5y nh\u00e2n vi\u00ean: " + employeeCode);
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
            dateStr = dateStr.trim();
            try {
                if (dateStr.contains("/")) {
                    a.setWorkDate(Date.valueOf(LocalDate.parse(dateStr, java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))));
                } else {
                    a.setWorkDate(Date.valueOf(LocalDate.parse(dateStr, DATE_FMT)));
                }
            } catch (Exception e) {
                throw new Exception("Sai định dạng ngày làm việc (" + dateStr + "). Cần định dạng dd/MM/yyyy hoặc yyyy-MM-dd");
            }
        }

        String shiftName = getStringCell(row, 7);
        if (shiftName == null || shiftName.trim().isEmpty()) {
            throw new Exception("Thiếu Ca làm việc");
        }
        shiftName = shiftName.trim();
        if (shiftName.contains("(")) {
            shiftName = shiftName.substring(0, shiftName.indexOf("(")).trim();
        }
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

        String checkIn = getStringCell(row, 8);
        if (checkIn != null && !checkIn.trim().isEmpty() 
                && !checkIn.equalsIgnoreCase("BLANK") && isValidTime(checkIn.trim())) {
            if (checkIn.trim().length() == 5) checkIn = checkIn.trim() + ":00";
            a.setCheckIn(Time.valueOf(checkIn.trim()));
        } else {
            a.setCheckIn(null);
        }

        String checkOut = getStringCell(row, 9);
        if (checkOut != null && !checkOut.trim().isEmpty() 
                && !checkOut.equalsIgnoreCase("BLANK") && isValidTime(checkOut.trim())) {
            if (checkOut.trim().length() == 5) checkOut = checkOut.trim() + ":00";
            a.setCheckOut(Time.valueOf(checkOut.trim()));
        } else {
            a.setCheckOut(null);
        }

        String status = getStringCell(row, 10);
        if (status == null || status.trim().isEmpty() || status.equalsIgnoreCase("BLANK")) {
             status = "A"; // default absent
        }
        status = status.trim();

        if (status.contains("P:") || status.contains("A:")) {
            return null; // Bỏ qua dòng tổng hợp
        }

        // Chữ "Đ" (U+0110) không tách được bằng NFD nên phải replace thủ công trước
        String statusPrep = status.replace("Đ", "D").replace("đ", "d");
        String normStatus = java.text.Normalizer.normalize(statusPrep, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")   // bỏ dấu
                .toUpperCase()              // uppercase
                .trim();

        // Loại bỏ text thừa sau dấu phẩy (vd: "DI TRE, BI GHI NHAN" → "DI TRE")
        if (normStatus.contains(",")) {
            normStatus = normStatus.substring(0, normStatus.indexOf(",")).trim();
        }

        switch (normStatus) {
            case "P":
            case "CO MAT":
                a.setStatus("PRESENT"); break;
            case "A":
            case "VANG MAT":
            case "VANG MAT (KP)":
                a.setStatus("ABSENT"); break;
            case "L":
            case "T":
            case "DI TRE":
                a.setStatus("LATE"); break;
            case "H":
                a.setStatus("HALFDAY"); break;
            case "NGHI PHEP":
                a.setStatus("LEAVE"); break;
            default: throw new Exception("Trạng thái không hợp lệ: " + status);
        }

        Cell otCell = row.getCell(11);
        if (otCell != null && otCell.getCellType() == CellType.NUMERIC) {
            a.setOvertimeHrs(otCell.getNumericCellValue());
        } else {
            String otStr = getStringCell(row, 11);
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

        String otReason = getStringCell(row, 12);
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

    private boolean isValidTime(String s) {
        if (s == null) return false;
        // Chấp nhận định dạng HH:mm hoặc HH:mm:ss, bác bỏ "—", "–", chữ...
        return s.matches("\\d{1,2}:\\d{2}(:\\d{2})?");
    }
}
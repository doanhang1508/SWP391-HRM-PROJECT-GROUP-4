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
@WebServlet(name = "ImportAttendanceController", urlPatterns = { "/hr/import-attendance" })
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

            // ── Chặn: không cho import lại các THÁNG ĐÃ QUA nếu đã có dữ liệu ──
            // Một khi đã sang tháng mới, nếu tháng cũ ĐÃ CÓ dữ liệu thì mặc định coi như đã "chốt công"
            // và KHÔNG cho phép import đè. Tuy nhiên, nếu tháng cũ CHƯA CÓ dữ liệu (ví dụ hệ thống mới tạo)
            // thì vẫn cho phép import. Chỉ khi Admin/Quản lý chủ động bấm "Mở khóa"
            // cho tháng đó ở trang Lock Timesheet thì mới được import lại dữ liệu đã có.
            LocalDate today = LocalDate.now();
            boolean isPastMonth = (year < today.getYear())
                    || (year == today.getYear() && month < today.getMonthValue());
            boolean hasData = attendanceDAO.hasAttendanceData(month, year);
            
            if (isPastMonth && hasData && !attendanceDAO.isExplicitlyUnlocked(month, year)) {
                session.setAttribute("errorMessage",
                        "Tháng " + month + "/" + year + " đã qua (hiện tại là Tháng " + today.getMonthValue()
                                + "/" + today.getYear() + ") và ĐÃ CÓ dữ liệu chấm công. "
                                + "Hệ thống tự động khóa để tránh ghi đè làm sai lệch lương. "
                                + "Nếu thực sự cần chỉnh sửa, vui lòng liên hệ Quản lý để MỞ KHÓA tháng này trước.");
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

            // ── ALL OR NOTHING VALIDATION ──
            // Chỉ cần có 1 dòng lỗi (parseErrors không rỗng), từ chối lưu toàn bộ file để tránh rác dữ liệu.
            if (!parseErrors.isEmpty() || records.isEmpty()) {
                String errorMessage;
                if (records.isEmpty() && parseErrors.isEmpty()) {
                    errorMessage = "Không có dữ liệu để import (file rỗng hoặc chỉ chứa header).";
                } else {
                    long monthMismatchCount = parseErrors.stream().filter(e -> e.contains("không thuộc Tháng")).count();
                    if (monthMismatchCount > 0 && monthMismatchCount == parseErrors.size()) {
                        errorMessage = "File bạn chọn không khớp với Tháng " + month + "/" + year + " đã chọn. Vui lòng kiểm tra lại file hoặc chọn đúng tháng/năm.";
                    } else {
                        errorMessage = "Phát hiện " + parseErrors.size() + " lỗi trong file. Để đảm bảo tính toàn vẹn dữ liệu (All-or-Nothing), hệ thống từ chối lưu. Vui lòng sửa lỗi và import lại từ đầu.";
                    }
                }
                session.setAttribute("errorMessage", errorMessage);
                session.setAttribute("fullParseErrors", parseErrors);
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }

            int[] importResult;
            try {
                importResult = attendanceDAO.bulkImportAttendance(records);
            } catch (Exception dbEx) {
                // Trước đây lỗi CSDL bị nuốt âm thầm và vẫn hiện "Import thành công: 0/0",
                // khiến HR tưởng đã xong trong khi thực chất KHÔNG có gì được ghi vào DB.
                session.setAttribute("errorMessage",
                        "Import thất bại, không có bản ghi nào được ghi vào CSDL. Lỗi: " + dbEx.getMessage());
                response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
                return;
            }
            int inserted = importResult[0];
            int updated = importResult[1];
            int unchanged = importResult.length > 2 ? importResult[2] : 0;
            int skippedTerminated = importResult.length > 3 ? importResult[3] : 0;

            String msg;
            if (inserted == 0 && updated == 0 && unchanged == 0) {
                // Có bản ghi hợp lệ được đọc từ file (records không rỗng), nhưng CUỐI CÙNG
                // không có gì được ghi vào DB — thường do toàn bộ bị loại vì nhân viên đã
                // nghỉ việc trước ngày chấm công. Đây LÀ vấn đề thật, không phải "thành công".
                if (skippedTerminated > 0 && skippedTerminated == records.size()) {
                    msg = "⚠️ Import KHÔNG có bản ghi nào được ghi vào CSDL: toàn bộ " + skippedTerminated
                            + " dòng bị bỏ qua vì thuộc về nhân viên đã nghỉ việc trước ngày chấm công trong file.";
                } else {
                    msg = "⚠️ Import KHÔNG có bản ghi nào được ghi vào CSDL dù file đọc được "
                            + records.size() + " dòng hợp lệ. Vui lòng kiểm tra lại dữ liệu (mã nhân viên, ca làm, ngày công) trong file.";
                }
            } else if (inserted == 0 && updated == 0 && unchanged > 0) {
                // Toàn bộ bản ghi đã tồn tại sẵn trong DB với dữ liệu giống hệt file import.
                // KHÔNG phải lỗi — chỉ là không có gì thay đổi so với lần import trước.
                msg = "ℹ️ " + unchanged + " bản ghi đã tồn tại và giống hệt dữ liệu trong file "
                        + "(không có bản ghi MỚI hoặc CẬP NHẬT nào vì dữ liệu không thay đổi).";
            } else if (inserted > 0 && updated == 0) {
                msg = "✅ Import thành công: " + inserted + " bản ghi MỚI.";
            } else if (inserted == 0 && updated > 0) {
                msg = "🔄 Import thành công: " + updated + " bản ghi đã được CẬP NHẬT (ghi đè dữ liệu cũ).";
            } else {
                msg = "✅ Import thành công: " + inserted + " bản ghi MỚI, " + updated + " bản ghi CẬP NHẬT.";
            }
            if (unchanged > 0 && (inserted > 0 || updated > 0)) {
                msg += " (" + unchanged + " bản ghi không đổi.)";
            }
            if (skippedTerminated > 0 && skippedTerminated != records.size()) {
                msg += " Đã bỏ qua " + skippedTerminated + " dòng của nhân viên đã nghỉ việc.";
            }
            if (!skippedRows.isEmpty()) {
                msg += " Đã bỏ qua " + skippedRows.size() + " dòng tổng hợp/header (bình thường).";
            }
            if (!parseErrors.isEmpty()) {
                msg += " ⚠️ Có " + parseErrors.size() + " dòng lỗi thực sự cần kiểm tra.";
            }
            if (inserted == 0 && updated == 0 && unchanged == 0) {
                session.setAttribute("errorMessage", msg);
            } else {
                session.setAttribute("successMessage", msg);
            }
            session.setAttribute("fullParseErrors", parseErrors);
            response.sendRedirect(request.getContextPath() + "/hr/import-attendance");

        } else {
            response.sendRedirect(request.getContextPath() + "/hr/import-attendance");
        }
    }

    private String removeAccents(String s) {
        if (s == null)
            return null;
        String normalized = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD);
        return normalized.replaceAll("\\p{M}", "").replaceAll("\\s+", "_").toUpperCase();
    }

    /**
     * Đọc 3 dòng tiêu đề đầu của Sheet "Bảng Công" để lấy Tháng/Năm THẬT SỰ của
     * file, ví dụ: "BẢNG CHẤM CÔNG THÁNG 6/2026" hoặc "Tháng: 06/2026".
     * Trả về null nếu không tìm thấy (khi đó bỏ qua kiểm tra, tránh chặn nhầm
     * các file không theo mẫu chuẩn).
     */
    private int[] extractTitleMonthYear(Sheet sheet) {
        java.util.regex.Pattern p = java.util.regex.Pattern
                .compile("th[áa]ng\\s*[:\\s]*\\s*(\\d{1,2})\\s*/\\s*(\\d{4})",
                        java.util.regex.Pattern.CASE_INSENSITIVE);
        for (int r = 0; r <= 2; r++) {
            Row row = sheet.getRow(r);
            if (row == null)
                continue;
            for (int c = 0; c < Math.min(row.getLastCellNum(), 5); c++) {
                String val = getStringCell(row, c);
                if (val == null || val.trim().isEmpty())
                    continue;
                String normalized = java.text.Normalizer.normalize(val, java.text.Normalizer.Form.NFD)
                        .replaceAll("\\p{M}", "");
                java.util.regex.Matcher m = p.matcher(normalized);
                if (m.find()) {
                    try {
                        int mo = Integer.parseInt(m.group(1));
                        int yr = Integer.parseInt(m.group(2));
                        if (mo >= 1 && mo <= 12) {
                            return new int[] { mo, yr };
                        }
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
        }
        return null;
    }

    private boolean isRawLogFormat(Sheet sheet) {
        Row headerRow = sheet.getRow(1);
        if (headerRow == null)
            headerRow = sheet.getRow(2);
        if (headerRow == null)
            return true;
        int lastCol = headerRow.getLastCellNum();
        if (lastCol < 6)
            return true;

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
        // Dùng getAllUsersForImport() để bao gồm cả NV đã nghỉ việc / inactive
        List<User> allUsers = userDAO.getAllUsersForImport();
        java.util.Map<Integer, User> userMap = new java.util.HashMap<>();
        java.util.Map<String, User> usernameMap = new java.util.HashMap<>();
        for (User u : allUsers) {
            userMap.put(u.getUserId(), u);
            if (u.getUsername() != null) {
                usernameMap.put(u.getUsername().toUpperCase(), u);
            }
            // Cũng map theo full_name để fallback tìm kiếm linh hoạt hơn
            if (u.getFullName() != null) {
                usernameMap.putIfAbsent(u.getFullName().trim().toUpperCase(), u);
            }
        }

        try (Workbook wb = WorkbookFactory.create(is)) {
            Sheet sheet = wb.getSheet("CHI_TIET_CHAM_CONG");// tim dung File de doc
            if (sheet == null) {
                // Thử tìm sheet có chứa chữ CHAM_CONG hoặc lấy sheet ĐẦU TIÊN
                for (int i = 0; i < wb.getNumberOfSheets(); i++) {
                    String sName = removeAccents(wb.getSheetName(i));
                    if (sName != null && sName.contains("CHI_TIET") && sName.contains("CHAM_CONG")) {
                        sheet = wb.getSheetAt(i);
                        break;
                    }
                }
                if (sheet == null)
                    sheet = wb.getSheetAt(0); // Fallback về sheet 0
            }

            if (isRawLogFormat(sheet)) {
                // 1. Group swipe logs from Sheet 1 ("Chi Tiết Chấm Công")
                java.util.Map<String, java.util.Map<LocalDate, List<Time>>> swipeMap = new java.util.HashMap<>();
                int skippedSwipeCount = 0;
                for (Row row : sheet) {
                    if (row.getRowNum() < 2)
                        continue; // Bỏ qua 2 dòng đầu (title, header)
                    if (isRowEmpty(row))
                        continue;

                    String empCode = getStringCell(row, 2); // Column 2: Mã Nhân Viên
                    if (empCode == null || empCode.trim().isEmpty()) {
                        empCode = getStringCell(row, 1); // Fallback to column 1
                    }
                    if (empCode == null || empCode.trim().isEmpty())
                        continue;
                    empCode = empCode.trim().toUpperCase();

                    Cell timeCell = row.getCell(3); // Column 3: Giờ
                    if (timeCell == null)
                        continue;

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
                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(fmt,
                                            java.util.Locale.ENGLISH);
                                    dateTime = sdf.parse(timeStr);
                                    break;
                                } catch (Exception ignored) {
                                }
                            }
                        }
                    }

                    if (dateTime != null) {
                        java.util.Calendar cal = java.util.Calendar.getInstance();
                        cal.setTime(dateTime);
                        LocalDate date = LocalDate.of(cal.get(java.util.Calendar.YEAR), cal.get(java.util.Calendar.MONTH) + 1, cal.get(java.util.Calendar.DAY_OF_MONTH));
                        if (date.getMonthValue() != month || date.getYear() != year) {
                            skippedSwipeCount++;
                            continue;
                        }
                        Time time = new Time(dateTime.getTime());

                        swipeMap.computeIfAbsent(empCode, k -> new java.util.HashMap<>())
                                .computeIfAbsent(date, k -> new java.util.ArrayList<>())
                                .add(time);
                    }
                }
                if (skippedSwipeCount > 0) {
                    skippedRows.add("Đã bỏ qua " + skippedSwipeCount + " swipe log không thuộc Tháng "
                            + month + "/" + year + " đã chọn.");
                }

                // 2. Parse Sheet 0 ("Bảng Công") to get employee profiles, shifts, and daily
                // statuses
                Sheet sheet0 = wb.getSheetAt(0);

                // ── Kiểm tra Tháng/Năm ghi trong tiêu đề file so với Tháng/Năm đã chọn ──
                // Định dạng "Bảng Công" không có cột ngày đầy đủ (chỉ có số ngày 1,2,3...),
                // nên PHẢI đối chiếu với tiêu đề thật của file (dòng 1-2), nếu không hệ thống
                // sẽ gán bừa mọi file vào tháng/năm người dùng chọn trên dropdown.
                int[] fileMonthYear = extractTitleMonthYear(sheet0);
                if (fileMonthYear != null
                        && (fileMonthYear[0] != month || fileMonthYear[1] != year)) {
                    throw new Exception("File bạn tải lên là bảng chấm công Tháng " + fileMonthYear[0] + "/"
                            + fileMonthYear[1] + ", không khớp với Tháng " + month + "/" + year
                            + " bạn đã chọn để import. Vui lòng chọn đúng Tháng/Năm hoặc tải đúng file.");
                }

                // ── Tìm động dòng tiêu đề và dòng ngày ──
                Row headerRow = null;
                Row daysRow = null;
                int maNvCol = 1;
                int caLamCol = 5;
                
                for (int r = 3; r <= 7; r++) {
                    Row temp = sheet0.getRow(r);
                    if (temp == null) continue;
                    
                    // Tìm dòng ngày (phải có >= 28 cột chứa số từ 1 đến 31)
                    int numericCount = 0;
                    for (int c = 0; c < temp.getLastCellNum(); c++) {
                        Cell cell = temp.getCell(c);
                        if (cell != null) {
                            try {
                                double val = -1;
                                if (cell.getCellType() == CellType.NUMERIC) {
                                    val = cell.getNumericCellValue();
                                } else {
                                    val = Double.parseDouble(cell.toString().trim());
                                }
                                if (val >= 1 && val <= 31) numericCount++;
                            } catch (Exception e) {}
                        }
                    }
                    if (numericCount >= 28) {
                        daysRow = temp;
                    }
                    
                    // Tìm cột Mã NV và Ca Làm
                    for (int c = 0; c < temp.getLastCellNum(); c++) {
                        String h = getStringCell(temp, c);
                        if (h != null) {
                            h = removeAccents(h.toUpperCase().trim());
                            if (h.contains("MA_NV") || h.contains("MA_NHAN_VIEN")) {
                                headerRow = temp;
                                maNvCol = c;
                            } else if (h.contains("CA_LAM") || h.contains("CA_LAM_VIEC")) {
                                caLamCol = c;
                            }
                        }
                    }
                }

                if (daysRow == null) {
                    // ── Fallback chế độ 1-SHEET ──
                    // Không tìm thấy dòng ngày 1-31 nghĩa là workbook không có sheet
                    // "Bảng Công" riêng (chỉ có mỗi sheet quẹt thẻ "Chi Tiết Chấm Công").
                    // Nếu file thật sự có nhiều sheet nhưng sheet Bảng Công bị sai định
                    // dạng, đây vẫn là lỗi dữ liệu thật → tiếp tục báo lỗi như cũ.
                    if (wb.getNumberOfSheets() > 1 && sheet0 != sheet) {
                        throw new Exception("Không tìm thấy dòng ngày (chứa các số từ 1-31) ở Sheet Bảng Công.");
                    }

                    // Workbook chỉ có 1 sheet: tạo bản ghi Attendance trực tiếp từ
                    // swipeMap đã đọc ở bước 1. Không có cột "Ca làm việc" tường minh
                    // nên Ca làm việc được suy luận là ca có giờ bắt đầu gần nhất với
                    // giờ quẹt vào thực tế của từng ngày. Chế độ này KHÔNG phân biệt
                    // được Nghỉ phép/Nghỉ ốm/Thai sản — mọi ngày có quẹt thẻ được ghi
                    // PRESENT, hoặc LATE nếu quẹt vào trễ hơn 15 phút so với giờ bắt
                    // đầu ca suy luận được.
                    if (allShifts.isEmpty()) {
                        throw new Exception("Không có Ca làm việc nào được cấu hình trong hệ thống để gán tự động.");
                    }

                    for (java.util.Map.Entry<String, java.util.Map<LocalDate, List<Time>>> empEntry : swipeMap
                            .entrySet()) {
                        String empCode = empEntry.getKey();

                        User user = null;
                        if (empCode.startsWith("NV")) {
                            try {
                                int userId = Integer.parseInt(empCode.substring(2));
                                user = userMap.get(userId);
                                if (user == null) {
                                    user = userDAO.getUserById(userId);
                                    if (user != null) {
                                        userMap.put(userId, user);
                                    }
                                }
                            } catch (NumberFormatException ignored) {
                            }
                        }
                        if (user == null) {
                            user = usernameMap.get(empCode);
                        }
                        if (user == null) {
                            errors.add("[Chi Tiết Chấm Công] Không tìm thấy nhân viên: " + empCode
                                    + " (Mã NV này không tồn tại trong hệ thống, vui lòng kiểm tra lại file Excel)");
                            continue;
                        }

                        for (java.util.Map.Entry<LocalDate, List<Time>> dayEntry : empEntry.getValue().entrySet()) {
                            LocalDate workLocalDate = dayEntry.getKey();
                            List<Time> swipes = dayEntry.getValue();
                            if (swipes == null || swipes.isEmpty()) {
                                continue;
                            }
                            java.util.Collections.sort(swipes);
                            Time checkIn = swipes.get(0);
                            Time checkOut = swipes.size() > 1 ? swipes.get(swipes.size() - 1) : null;

                            Shift nearestShift = findNearestShift(allShifts, checkIn);

                            Attendance a = new Attendance();
                            a.setUserId(user.getUserId());
                            a.setShiftId(nearestShift.getShiftId());
                            a.setWorkDate(Date.valueOf(workLocalDate));
                            a.setCheckIn(checkIn);
                            a.setCheckOut(checkOut);

                            String status = "PRESENT";
                            if (nearestShift.getStartTime() != null) {
                                java.time.LocalTime shiftStart = nearestShift.getStartTime();
                                java.time.LocalTime actualIn = checkIn.toLocalTime();
                                if (actualIn.isAfter(shiftStart.plusMinutes(15))) {
                                    status = "LATE";
                                }
                            }
                            a.setStatus(status);
                            a.setOvertimeHrs(0.0);
                            a.setOtReason("");
                            records.add(a);
                        }
                    }
                    return;
                }

                java.util.Map<Integer, Integer> colToDayMap = new java.util.HashMap<>();
                for (int c = 0; c < daysRow.getLastCellNum(); c++) {
                    Cell cell = daysRow.getCell(c);
                    if (cell != null) {
                        try {
                            double val = 0;
                            if (cell.getCellType() == CellType.NUMERIC) {
                                val = cell.getNumericCellValue();
                            } else {
                                val = Double.parseDouble(cell.toString().trim());
                            }
                            if (val >= 1 && val <= 31) {
                                colToDayMap.put(c, (int) val);
                            }
                        } catch (Exception ignored) {
                        }
                    }
                }

                // Read the "GIỜ OT THEO NGÀY" grid when it exists.  OT must stay on its
                // real date so the report can split regular, Sunday and holiday hours.
                java.util.Map<String, java.util.Map<Integer, Double>> dailyOvertime =
                        extractDailyOvertime(sheet0);

                int startDataRow = daysRow.getRowNum() + 1;
                for (int r = startDataRow; r <= sheet0.getLastRowNum(); r++) {
                    Row row = sheet0.getRow(r);
                    if (row == null || isRowEmpty(row))
                        continue;

                    String empCode = getStringCell(row, maNvCol); // Column Mã NV
                    if (empCode == null || empCode.trim().isEmpty())
                        continue;
                    empCode = empCode.trim().toUpperCase();
                    
                    // Nếu gặp lại header "MÃ NV" hoặc dòng Tổng, nghĩa là đã sang bảng OT ở dưới
                    if (empCode.contains("MA_NV") || empCode.contains("MÃ NV") || empCode.contains("MA NV")
                            || empCode.contains("TONG") || empCode.contains("TỔNG")
                            || empCode.contains("GIO OT") || empCode.contains("GIỜ OT")) {
                        break;
                    }

                    User user = null;
                    if (empCode.startsWith("NV")) {
                        try {
                            int userId = Integer.parseInt(empCode.substring(2));
                            user = userMap.get(userId);
                            // Fallback: query thẳng DB nếu không có trong map
                            // (trường hợp NV bị xóa cứng khỏi cache hoặc chưa sync)
                            if (user == null) {
                                user = userDAO.getUserById(userId);
                                if (user != null) {
                                    // Cache lại để các lần sau nhanh hơn
                                    userMap.put(userId, user);
                                }
                            }
                        } catch (NumberFormatException ignored) {
                        }
                    }
                    if (user == null) {
                        user = usernameMap.get(empCode);
                    }
                    if (user == null) {
                        errors.add("[V2] Dòng " + (r + 1) + " (Sheet Bảng Công): Không tìm thấy nhân viên: " + empCode
                                + " (Mã NV này không tồn tại trong hệ thống, vui lòng kiểm tra lại file Excel)");
                        continue;
                    }

                    String shiftName = getStringCell(row, caLamCol); // Column Ca làm
                    if (shiftName == null || shiftName.trim().isEmpty()) {
                        errors.add("[V2] Dòng " + (r + 1) + " (Sheet Bảng Công): Thiếu Ca làm việc cho NV " + empCode);
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
                        errors.add("[V2] Dòng " + (r + 1) + " (Sheet Bảng Công): Không tìm thấy Ca làm việc: " + shiftName);
                        continue;
                    }

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
                                status = "PRESENT";
                                break;
                            case "A":
                                status = "ABSENT";
                                break;
                            case "T":
                                status = "LATE";
                                break;
                            case "L":
                                status = "LEAVE";
                                break;
                            case "NGHI PHEP":
                            case "NP":
                                status = "LEAVE";
                                break;
                            case "S":
                                status = "SICK_LEAVE";
                                break;
                            case "M":
                                status = "MATERNITY_LEAVE";
                                break;
                            case "HALF":
                            case "HALFDAY":
                            case "H":
                                status = "HALFDAY";
                                break;
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

                        double dailyOtHrs = dailyOvertime
                                .getOrDefault(empCode, java.util.Collections.emptyMap())
                                .getOrDefault(day, 0.0);
                        a.setOvertimeHrs(dailyOtHrs);
                        a.setOtReason(dailyOtHrs > 0 ? "Imported daily OT" : "");
                        records.add(a);
                    }
                }
            } else {
                // 13-column format
                for (Row row : sheet) {
                    if (row.getRowNum() < 3)
                        continue; // Bỏ qua 3 dòng đầu (headers)
                    if (isRowEmpty(row))
                        continue;
                    try {
                        Attendance a = rowToAttendance(row, userMap, usernameMap, allShifts, month, year, userDAO);
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

    /**
     * Reads an optional per-day OT table placed below the attendance grid.
     * Expected structure: a title containing "GIO OT", then a row with employee
     * codes and day numbers, followed by one row per employee.
     */
    private java.util.Map<String, java.util.Map<Integer, Double>> extractDailyOvertime(Sheet sheet) {
        java.util.Map<String, java.util.Map<Integer, Double>> result = new java.util.HashMap<>();
        int titleRowIndex = -1;
        for (int r = 0; r <= sheet.getLastRowNum(); r++) {
            Row row = sheet.getRow(r);
            if (row == null) {
                continue;
            }
            String firstCell = getStringCell(row, 0);
            if (firstCell != null && removeAccents(firstCell).toUpperCase().contains("GIO_OT")) {
                titleRowIndex = r;
                break;
            }
        }
        if (titleRowIndex < 0 || titleRowIndex + 1 > sheet.getLastRowNum()) {
            return result;
        }

        Row header = sheet.getRow(titleRowIndex + 1);
        java.util.Map<Integer, Integer> dayByColumn = new java.util.HashMap<>();
        for (int c = 0; c < header.getLastCellNum(); c++) {
            Double day = getNumericCell(header, c);
            if (day != null && day >= 1 && day <= 31 && day == Math.floor(day)) {
                dayByColumn.put(c, day.intValue());
            }
        }

        for (int r = titleRowIndex + 2; r <= sheet.getLastRowNum(); r++) {
            Row row = sheet.getRow(r);
            if (row == null || isRowEmpty(row)) {
                continue;
            }
            String employeeCode = getStringCell(row, 1);
            if (employeeCode == null || employeeCode.trim().isEmpty()) {
                continue;
            }
            employeeCode = employeeCode.trim().toUpperCase();
            String normalized = removeAccents(employeeCode);
            if (normalized.contains("TONG") || normalized.contains("MA NV") || normalized.contains("MA_NV")) {
                break;
            }

            java.util.Map<Integer, Double> hoursByDay = new java.util.HashMap<>();
            for (java.util.Map.Entry<Integer, Integer> entry : dayByColumn.entrySet()) {
                Double value = getNumericCell(row, entry.getKey());
                if (value != null && value > 0) {
                    hoursByDay.put(entry.getValue(), value);
                }
            }
            result.put(employeeCode, hoursByDay);
        }
        return result;
    }

    private Double getNumericCell(Row row, int columnIndex) {
        if (row == null) {
            return null;
        }
        Cell cell = row.getCell(columnIndex);
        if (cell == null) {
            return null;
        }
        try {
            if (cell.getCellType() == CellType.NUMERIC) {
                return cell.getNumericCellValue();
            }
            if (cell.getCellType() == CellType.FORMULA
                    && cell.getCachedFormulaResultType() == CellType.NUMERIC) {
                return cell.getNumericCellValue();
            }
            String value = getStringCell(row, columnIndex);
            return value == null || value.trim().isEmpty() ? null : Double.parseDouble(value.trim());
        } catch (RuntimeException ignored) {
            return null;
        }
    }

    /**
     * Chọn Ca làm việc có giờ bắt đầu (start_time) gần nhất với giờ quẹt vào
     * thực tế. Dùng cho chế độ import 1-sheet, khi file không có cột "Ca làm
     * việc" tường minh để tra cứu trực tiếp như chế độ 2-sheet (Bảng Công).
     */
    private Shift findNearestShift(List<Shift> allShifts, Time checkIn) {
        if (allShifts == null || allShifts.isEmpty()) {
            return null;
        }
        if (checkIn == null) {
            return allShifts.get(0);
        }
        java.time.LocalTime actualIn = checkIn.toLocalTime();
        Shift best = null;
        long bestDiff = Long.MAX_VALUE;
        for (Shift s : allShifts) {
            if (s.getStartTime() == null) {
                continue;
            }
            long diff = Math.abs(java.time.Duration.between(s.getStartTime(), actualIn).toMinutes());
            if (diff < bestDiff) {
                bestDiff = diff;
                best = s;
            }
        }
        return best != null ? best : allShifts.get(0);
    }

    private boolean isRowEmpty(Row row) {
        if (row == null)
            return true;
        for (int i = 0; i < 20; i++) {
            Cell cell = row.getCell(i);
            if (cell != null && cell.getCellType() != CellType.BLANK)
                return false;
        }
        return true;
    }

    private Attendance rowToAttendance(Row row, java.util.Map<Integer, User> userMap, java.util.Map<String, User> usernameMap, List<Shift> allShifts, int selectedMonth, int selectedYear, UserDAO userDAO) throws Exception {
        Attendance a = new Attendance();

        // ── Scan 6 cột đầu vì dòng "Cộng:" có thể nằm ở cột bất kỳ do merged cell ──
        for (int ci = 0; ci < 6; ci++) {
            String cellVal = getStringCell(row, ci);
            if (cellVal == null)
                continue;
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
                // Fallback: query thẳng DB (bao gồm NV inactive / đã nghỉ)
                if (user == null && userDAO != null) {
                    user = userDAO.getUserById(userId);
                    if (user != null) {
                        userMap.put(userId, user); // cache lại
                    }
                }
            } catch (NumberFormatException e) {
                // Ignore parsing error, try username lookup next
            }
        }
        if (user == null) {
            user = usernameMap.get(employeeCode.toUpperCase());
        }

        if (user == null) {
            throw new Exception("Kh\u00f4ng t\u00ecm th\u1ea5y nh\u00e2n vi\u00ean: " + employeeCode
                    + " (M\u00e3 NV n\u00e0y kh\u00f4ng t\u1ed3n t\u1ea1i trong h\u1ec7 th\u1ed1ng)");
        }
        a.setUserId(user.getUserId());

        Cell dateCell = row.getCell(5);
        if (dateCell == null)
            throw new Exception("Thiếu Ngày làm việc");
        if (dateCell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(dateCell)) {
            java.util.Date d = dateCell.getDateCellValue();
            a.setWorkDate(new Date(d.getTime()));
        } else {
            String dateStr = getStringCell(row, 5);
            if (dateStr == null || dateStr.trim().isEmpty())
                throw new Exception("Thiếu Ngày làm việc");
            dateStr = dateStr.trim();
            try {
                if (dateStr.contains("/")) {
                    a.setWorkDate(Date.valueOf(
                            LocalDate.parse(dateStr, java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))));
                } else {
                    a.setWorkDate(Date.valueOf(LocalDate.parse(dateStr, DATE_FMT)));
                }
            } catch (Exception e) {
                throw new Exception(
                        "Sai định dạng ngày làm việc (" + dateStr + "). Cần định dạng dd/MM/yyyy hoặc yyyy-MM-dd");
            }
        }

        LocalDate wd = a.getWorkDate().toLocalDate();
        if (wd.getMonthValue() != selectedMonth || wd.getYear() != selectedYear) {
            throw new Exception("Ngày làm việc " + wd + " không thuộc Tháng " + selectedMonth
                    + "/" + selectedYear + " đã chọn để import.");
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
            if (checkIn.trim().length() == 5)
                checkIn = checkIn.trim() + ":00";
            a.setCheckIn(Time.valueOf(checkIn.trim()));
        } else {
            a.setCheckIn(null);
        }

        String checkOut = getStringCell(row, 9);
        if (checkOut != null && !checkOut.trim().isEmpty()
                && !checkOut.equalsIgnoreCase("BLANK") && isValidTime(checkOut.trim())) {
            if (checkOut.trim().length() == 5)
                checkOut = checkOut.trim() + ":00";
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
                .replaceAll("\\p{M}", "") // bỏ dấu
                .toUpperCase() // uppercase
                .trim();

        // Loại bỏ text thừa sau dấu phẩy (vd: "DI TRE, BI GHI NHAN" → "DI TRE")
        if (normStatus.contains(",")) {
            normStatus = normStatus.substring(0, normStatus.indexOf(",")).trim();
        }

        switch (normStatus) {
            case "P":
            case "CO MAT":
                a.setStatus("PRESENT");
                break;
            case "A":
            case "VANG MAT":
            case "VANG MAT (KP)":
                a.setStatus("ABSENT");
                break;
            case "L":
            case "T":
            case "DI TRE":
                a.setStatus("LATE");
                break;
            case "H":
                a.setStatus("HALFDAY");
                break;
            case "NGHI PHEP":
                a.setStatus("LEAVE");
                break;
            default:
                throw new Exception("Trạng thái không hợp lệ: " + status);
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
        if (cell == null)
            return null;
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    java.util.Date d = cell.getDateCellValue();
                    java.util.Calendar cal = java.util.Calendar.getInstance();
                    cal.setTime(d);
                    return String.format("%02d:%02d", cal.get(java.util.Calendar.HOUR_OF_DAY),
                            cal.get(java.util.Calendar.MINUTE));
                }
                double numValue = cell.getNumericCellValue();
                if (numValue == (long) numValue) {
                    return String.format("%d", (long) numValue);
                } else {
                    return String.format("%s", numValue);
                }
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                switch (cell.getCachedFormulaResultType()) {
                    case STRING:
                        return cell.getStringCellValue();
                    case NUMERIC:
                        double numValueF = cell.getNumericCellValue();
                        if (numValueF == (long) numValueF) {
                            return String.format("%d", (long) numValueF);
                        } else {
                            return String.format("%s", numValueF);
                        }
                    case BOOLEAN:
                        return String.valueOf(cell.getBooleanCellValue());
                    default:
                        return null;
                }
            default:
                return null;
        }
    }

    private boolean isValidTime(String s) {
        if (s == null)
            return false;
        // Chấp nhận định dạng HH:mm hoặc HH:mm:ss, bác bỏ "—", "–", chữ...
        return s.matches("\\d{1,2}:\\d{2}(:\\d{2})?");
    }
}
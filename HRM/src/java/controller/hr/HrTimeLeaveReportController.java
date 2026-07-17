package controller.hr;

import dao.AttendanceDAO;
import dao.DepartmentDAO;
import dao.HolidayDAO;
import model.AttendanceSummary;
import model.Department;
import model.User;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "HrTimeLeaveReportController", urlPatterns = {"/hr/time-leave-report"})
public class HrTimeLeaveReportController extends HttpServlet {

    private AttendanceDAO attendanceDAO;
    private DepartmentDAO departmentDAO;
    private HolidayDAO holidayDAO;

    @Override
    public void init() throws ServletException {
        attendanceDAO = new AttendanceDAO();
        departmentDAO = new DepartmentDAO();
        holidayDAO = new HolidayDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }

        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        String deptStr = request.getParameter("departmentId");
        
        LocalDate now = LocalDate.now();
        int month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : now.getMonthValue();
        int year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : now.getYear();
        Integer departmentId = (deptStr != null && !deptStr.isEmpty()) ? Integer.parseInt(deptStr) : null;

        int page = 1;
        int pageSize = 15;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { page = Integer.parseInt(pageStr); } catch (Exception e) {}
        }
        
        int totalRecords = attendanceDAO.countAdvancedAttendanceSummary(month, year, departmentId);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (page > totalPages && totalPages > 0) page = totalPages;
        int offset = (page - 1) * pageSize;
        if (offset < 0) offset = 0;

        List<AttendanceSummary> reportList = attendanceDAO.getAdvancedAttendanceSummary(month, year, departmentId, offset, pageSize);
        int standardWorkDays = holidayDAO.getPayrollStandardWorkDays(month, year);
        for (AttendanceSummary s : reportList) {
            s.setStandardWorkDays(standardWorkDays);
        }

        List<Department> departments = departmentDAO.getAll();
        
        request.setAttribute("reportList", reportList);
        request.setAttribute("departments", departments);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);
        request.setAttribute("selectedDepartmentId", departmentId);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        
        request.getRequestDispatcher("/hr/hr-time-leave-report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }

        String action = request.getParameter("action");
        if ("exportExcel".equals(action)) {
            exportExcel(request, response);
        } else {
            doGet(request, response);
        }
    }
    
    private void exportExcel(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        String deptStr = request.getParameter("departmentId");
        
        LocalDate now = LocalDate.now();
        int month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : now.getMonthValue();
        int year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : now.getYear();
        Integer departmentId = (deptStr != null && !deptStr.isEmpty()) ? Integer.parseInt(deptStr) : null;
        
        // Lấy toàn bộ dữ liệu không phân trang
        List<AttendanceSummary> list = attendanceDAO.getAdvancedAttendanceSummary(month, year, departmentId, 0, Integer.MAX_VALUE);
        int standardWorkDays = holidayDAO.getPayrollStandardWorkDays(month, year);
        for (AttendanceSummary s : list) {
            s.setStandardWorkDays(standardWorkDays);
        }
        
        String fileName = "Bao_Cao_Tong_Hop_Cong_Phep_M" + month + "_Y" + year + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Bao Cao Cong Phep");
            
            // Header Style
            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.TEAL.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            Font headerFont = workbook.createFont();
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            
            // Warning Style (Red text for Late >= 3)
            CellStyle warningStyle = workbook.createCellStyle();
            Font warningFont = workbook.createFont();
            warningFont.setColor(IndexedColors.RED.getIndex());
            warningFont.setBold(true);
            warningStyle.setFont(warningFont);

            // Number Warning Style
            CellStyle numberWarningStyle = workbook.createCellStyle();
            numberWarningStyle.setFont(warningFont);
            DataFormat format = workbook.createDataFormat();
            numberWarningStyle.setDataFormat(format.getFormat("#,##0.0"));
            
            // Number Style (Format #,##0.0)
            CellStyle numberStyle = workbook.createCellStyle();
            numberStyle.setDataFormat(format.getFormat("#,##0.0"));
            
            Row headerRow = sheet.createRow(0);
            String[] columns = {
                "Mã NV", "Họ Tên", "Phòng Ban", "Công chuẩn", "Công thực tế", 
                "OT thường (h)", "OT CN (h)", "OT Lễ (h)", "Đi trễ (lần)", 
                "Nghỉ phép năm (ngày)", "Nghỉ ốm (ngày)", "Nghỉ thai sản (ngày)", "Phép năm còn lại (ngày)"
            };
            
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 4500);
            }
            
            int rowNum = 1;
            
            for (AttendanceSummary r : list) {
                Row row = sheet.createRow(rowNum++);
                boolean isLate = r.getLateCount() >= 3;
                CellStyle currentStyle = isLate ? warningStyle : null;
                CellStyle currentNumStyle = isLate ? numberWarningStyle : numberStyle;
                
                Cell c0 = row.createCell(0);
                c0.setCellValue("NV" + r.getUserId());
                if(currentStyle != null) c0.setCellStyle(currentStyle);

                Cell c1 = row.createCell(1);
                c1.setCellValue(r.getUserName() != null ? r.getUserName() : "");
                if(currentStyle != null) c1.setCellStyle(currentStyle);
                
                Cell c2 = row.createCell(2);
                c2.setCellValue(r.getDepartment() != null ? r.getDepartment() : "—");
                if(currentStyle != null) c2.setCellStyle(currentStyle);
                
                Cell c3 = row.createCell(3);
                c3.setCellValue(r.getStandardWorkDays());
                if(currentStyle != null) c3.setCellStyle(currentStyle);

                Cell c4 = row.createCell(4);
                c4.setCellValue(r.getActualWorkDays());
                c4.setCellStyle(currentNumStyle);

                Cell c5 = row.createCell(5);
                c5.setCellValue(r.getRegularOtHrs());
                c5.setCellStyle(currentNumStyle);

                Cell c6 = row.createCell(6);
                c6.setCellValue(r.getSundayOtHrs());
                c6.setCellStyle(currentNumStyle);

                Cell c7 = row.createCell(7);
                c7.setCellValue(r.getHolidayOtHrs());
                c7.setCellStyle(currentNumStyle);

                Cell c8 = row.createCell(8);
                c8.setCellValue(r.getLateCount());
                if(currentStyle != null) c8.setCellStyle(currentStyle);

                Cell c9 = row.createCell(9);
                c9.setCellValue(r.getAnnualLeaveDays());
                c9.setCellStyle(currentNumStyle);

                Cell c10 = row.createCell(10);
                c10.setCellValue(r.getSickLeaveDays());
                c10.setCellStyle(currentNumStyle);

                Cell c11 = row.createCell(11);
                c11.setCellValue(r.getMaternityLeaveDays());
                c11.setCellStyle(currentNumStyle);

                Cell c12 = row.createCell(12);
                c12.setCellValue(r.getRemainingAnnualLeave());
                c12.setCellStyle(currentNumStyle);
            }
            
            try (OutputStream out = response.getOutputStream()) {
                workbook.write(out);
            }
        }
    }
}

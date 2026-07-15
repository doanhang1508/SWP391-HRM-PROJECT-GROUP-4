package controller.hr;

import dao.DepartmentDAO;
import dao.TimeLeaveReportDAO;
import model.Department;
import model.TimeLeaveReport;
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

    private TimeLeaveReportDAO timeLeaveReportDAO;
    private DepartmentDAO departmentDAO;

    @Override
    public void init() throws ServletException {
        timeLeaveReportDAO = new TimeLeaveReportDAO();
        departmentDAO = new DepartmentDAO();
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
        
        int totalRecords = timeLeaveReportDAO.countReport(month, year, departmentId);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (page > totalPages && totalPages > 0) page = totalPages;
        int offset = (page - 1) * pageSize;
        if (offset < 0) offset = 0;

        List<TimeLeaveReport> reportList = timeLeaveReportDAO.getReport(month, year, departmentId, offset, pageSize);
        List<Department> departments = departmentDAO.getAll();
        
        request.setAttribute("reportList", reportList);
        request.setAttribute("departments", departments);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);
        request.setAttribute("selectedDepartment", departmentId);
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
        List<TimeLeaveReport> list = timeLeaveReportDAO.getReport(month, year, departmentId, 0, 0);
        
        String fileName = "BaoCaoCongPhep_Thang" + month + "_" + year + ".xlsx";
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
            
            // Number Style (Format #,##0.0)
            CellStyle numberStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            numberStyle.setDataFormat(format.getFormat("#,##0.0"));
            
            Row headerRow = sheet.createRow(0);
            String[] columns = {"STT", "Mã NV", "Họ và tên", "Phòng ban", "Tổng ngày công", "Số lần đi trễ", "Số giờ OT", "Phép năm đã dùng", "Phép năm còn lại"};
            
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 5000);
            }
            
            int rowNum = 1;
            int stt = 1;
            
            for (TimeLeaveReport r : list) {
                Row row = sheet.createRow(rowNum++);
                
                row.createCell(0).setCellValue(stt++);
                row.createCell(1).setCellValue(r.getUserId());
                row.createCell(2).setCellValue(r.getFullName() != null ? r.getFullName() : "");
                row.createCell(3).setCellValue(r.getDepartmentName() != null ? r.getDepartmentName() : "—");
                
                // Set total work days and late count as numbers
                row.createCell(4).setCellValue(r.getTotalWorkDays());
                row.createCell(5).setCellValue(r.getLateCount());
                
                // Set formatted numbers for OT and Leave
                Cell otCell = row.createCell(6);
                otCell.setCellValue(r.getOtHours());
                otCell.setCellStyle(numberStyle);
                
                Cell usedLeaveCell = row.createCell(7);
                usedLeaveCell.setCellValue(r.getAnnualLeaveUsed());
                usedLeaveCell.setCellStyle(numberStyle);
                
                Cell remainLeaveCell = row.createCell(8);
                remainLeaveCell.setCellValue(r.getAnnualLeaveRemaining());
                remainLeaveCell.setCellStyle(numberStyle);
            }
            
            try (OutputStream out = response.getOutputStream()) {
                workbook.write(out);
            }
        }
    }
}

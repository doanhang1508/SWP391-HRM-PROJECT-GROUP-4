package controller.hr;

import dao.DepartmentDAO;
import dao.KpiDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Department;
import model.KpiCycle;
import model.KpiEvaluation;
import model.User;

import java.io.IOException;
import java.util.*;

/**
 * KpiPerformanceReportController
 * URL: /hr/kpi-performance-report
 *
 * Bao cao Danh gia Nang luc (KPI Performance Report).
 * - HR Manager (role 2): xem tat ca phong ban.
 * - Manager role (3, 6): chi xem nhan vien phong ban cua minh.
 * - Director (4), Admin (1): xem tat ca.
 *
 * GET (default)          -> Hien thi bao cao
 * GET action=exportExcel -> Xuat file Excel
 */
@WebServlet(name = "KpiPerformanceReportController", urlPatterns = {"/hr/kpi-performance-report"})
public class KpiPerformanceReportController extends HttpServlet {

    private boolean hasAccess(User user) {
        if (user == null) return false;
        int r = user.getRoleId();
        return r == 1 || r == 2 || r == 3 || r == 4 || r == 5 || r == 6;
    }

    private boolean canViewAllDepartments(User user) {
        if (user == null) return false;
        int r = user.getRoleId();
        return r == 1 || r == 2;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (!hasAccess(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("exportExcel".equals(action)) {
            exportExcel(request, response, currentUser);
            return;
        }

        KpiDAO kpiDAO = new KpiDAO();
        DepartmentDAO deptDAO = new DepartmentDAO();

        // Filters
        Integer cycleId = parseIntParam(request.getParameter("cycleId"));
        Integer departmentId = parseIntParam(request.getParameter("departmentId"));

        // Role-based department restriction
        boolean viewAll = canViewAllDepartments(currentUser);
        Integer managerDeptId = null;
        if (!viewAll) {
            managerDeptId = currentUser.getDepartmentId() > 0 ? currentUser.getDepartmentId() : null;
            departmentId = managerDeptId; // Force search filter to match manager department limit!
        }

        // Data
        List<KpiEvaluation> reportData = kpiDAO.getKpiPerformanceReport(cycleId, departmentId, managerDeptId);
        List<KpiCycle> allCycles = kpiDAO.getAllCycles();
        List<Department> departments = deptDAO.getAll();

        // Statistics
        int totalEmployees = reportData.size();
        int passCount = 0, failCount = 0;
        double totalScore = 0;
        double maxScore = Double.MIN_VALUE;
        String topPerformer = "—";
        double topPerformerScore = 0.0;

        // Grade distribution
        int gradeA = 0, gradeB = 0, gradeC = 0, gradeD = 0;

        // Score distribution for chart
        int[] scoreDistribution = new int[10]; // 0-1, 1-2, ..., 9-10

        // Department averages
        Map<String, List<Double>> deptScores = new LinkedHashMap<>();

        for (KpiEvaluation e : reportData) {
            double ws = e.getWeightedScore();
            totalScore += ws;

            if (ws >= 5.0) passCount++; else failCount++;

            if (ws > maxScore) {
                maxScore = ws;
                topPerformer = e.getEmployeeName();
                topPerformerScore = Math.round(ws * 100.0) / 100.0;
            }

            // Grade
            if (ws >= 9.0) gradeA++;
            else if (ws >= 7.0) gradeB++;
            else if (ws >= 5.0) gradeC++;
            else gradeD++;

            // Score distribution
            int bucket = Math.min((int) ws, 9);
            scoreDistribution[bucket]++;

            // Dept average
            String dept = e.getDepartmentName() != null ? e.getDepartmentName() : "Chưa phân bổ";
            deptScores.computeIfAbsent(dept, k -> new ArrayList<>()).add(ws);
        }

        double avgScore = totalEmployees > 0 ? totalScore / totalEmployees : 0;
        double passRate = totalEmployees > 0 ? (passCount * 100.0 / totalEmployees) : 0;

        // Department averages for chart
        List<String> deptNames = new ArrayList<>();
        List<Double> deptAvgs = new ArrayList<>();
        for (Map.Entry<String, List<Double>> entry : deptScores.entrySet()) {
            deptNames.add(entry.getKey());
            double sum = entry.getValue().stream().mapToDouble(Double::doubleValue).sum();
            deptAvgs.add(Math.round(sum / entry.getValue().size() * 100.0) / 100.0);
        }

        // Set attributes
        request.setAttribute("reportData", reportData);
        request.setAttribute("allCycles", allCycles);
        request.setAttribute("departments", departments);
        request.setAttribute("selectedCycleId", cycleId != null ? cycleId : -1);
        request.setAttribute("selectedDepartmentId", departmentId != null ? departmentId : -1);
        request.setAttribute("viewAll", viewAll);

        // Statistics
        request.setAttribute("totalEmployees", totalEmployees);
        request.setAttribute("passCount", passCount);
        request.setAttribute("failCount", failCount);
        request.setAttribute("avgScore", Math.round(avgScore * 100.0) / 100.0);
        request.setAttribute("passRate", Math.round(passRate * 10.0) / 10.0);
        request.setAttribute("topPerformer", topPerformer);
        request.setAttribute("topPerformerScore", topPerformerScore);
        request.setAttribute("gradeA", gradeA);
        request.setAttribute("gradeB", gradeB);
        request.setAttribute("gradeC", gradeC);
        request.setAttribute("gradeD", gradeD);

        // Chart data (JSON arrays)
        request.setAttribute("scoreDistribution", arrayToJson(scoreDistribution));
        request.setAttribute("deptNames", listToJsonStr(deptNames));
        request.setAttribute("deptAvgs", listDoubleToJson(deptAvgs));

        request.getRequestDispatcher("/hr/kpi-performance-report.jsp").forward(request, response);
    }

    // --- Export Excel ---
    private void exportExcel(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        KpiDAO kpiDAO = new KpiDAO();
        Integer cycleId = parseIntParam(request.getParameter("cycleId"));
        Integer departmentId = parseIntParam(request.getParameter("departmentId"));
        boolean viewAll = canViewAllDepartments(currentUser);
        Integer managerDeptId = null;
        if (!viewAll) {
            managerDeptId = currentUser.getDepartmentId() > 0 ? currentUser.getDepartmentId() : null;
            departmentId = managerDeptId; // Force export filter to match manager department limit!
        }

        List<KpiEvaluation> list = kpiDAO.getKpiPerformanceReport(cycleId, departmentId, managerDeptId);

        String fileName = "BaoCaoKPI_NangLuc.xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (org.apache.poi.xssf.usermodel.XSSFWorkbook workbook =
                     new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {

            org.apache.poi.xssf.usermodel.XSSFCellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(
                    org.apache.poi.ss.usermodel.IndexedColors.TEAL.getIndex());
            headerStyle.setFillPattern(
                    org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
            org.apache.poi.xssf.usermodel.XSSFFont headerFont = workbook.createFont();
            headerFont.setColor(org.apache.poi.ss.usermodel.IndexedColors.WHITE.getIndex());
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            org.apache.poi.xssf.usermodel.XSSFDataFormat fmt = workbook.createDataFormat();
            org.apache.poi.xssf.usermodel.XSSFCellStyle numberStyle = workbook.createCellStyle();
            numberStyle.setDataFormat(fmt.getFormat("0.00"));

            org.apache.poi.xssf.usermodel.XSSFSheet sheet = workbook.createSheet("Bao Cao KPI");

            String[] cols = {
                "STT", "Ma NV", "Ho va ten", "Phong ban",
                "Diem quan ly danh gia", "Xep loai",
                "De xuat thuong/phat", "Nguoi danh gia"
            };

            org.apache.poi.ss.usermodel.Row hRow = sheet.createRow(0);
            for (int i = 0; i < cols.length; i++) {
                org.apache.poi.ss.usermodel.Cell c = hRow.createCell(i);
                c.setCellValue(cols[i]);
                c.setCellStyle(headerStyle);
            }

            int rowNum = 1, stt = 1;
            for (KpiEvaluation e : list) {
                org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(stt++);
                row.createCell(1).setCellValue("NV" + String.format("%04d", e.getEmployeeId()));
                row.createCell(2).setCellValue(e.getEmployeeName() != null ? e.getEmployeeName() : "");
                row.createCell(3).setCellValue(e.getDepartmentName() != null ? e.getDepartmentName() : "-");

                org.apache.poi.ss.usermodel.Cell scoreCell = row.createCell(4);
                scoreCell.setCellValue(e.getWeightedScore());
                scoreCell.setCellStyle(numberStyle);

                row.createCell(5).setCellValue(getGrade(e.getWeightedScore()));
                row.createCell(6).setCellValue(getRecommendation(e.getWeightedScore()));
                row.createCell(7).setCellValue(e.getManagerName() != null ? e.getManagerName() : "-");
            }

            for (int i = 0; i < cols.length; i++) sheet.autoSizeColumn(i);
            workbook.write(response.getOutputStream());
        }
    }

    // --- Helpers ---
    private String getGrade(double score) {
        if (score >= 9.0) return "A";
        if (score >= 7.0) return "B";
        if (score >= 5.0) return "C";
        return "D";
    }

    private String getRecommendation(double score) {
        if (score >= 9.0) return "Thuong 10-15% luong";
        if (score >= 7.0) return "Thuong 5% luong";
        if (score >= 5.0) return "Khong thuong/phat";
        return "Xem xet ky luat";
    }

    private Integer parseIntParam(String str) {
        if (str == null || str.trim().isEmpty() || "-1".equals(str)) return null;
        try { return Integer.parseInt(str); } catch (NumberFormatException e) { return null; }
    }

    private String arrayToJson(int[] arr) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < arr.length; i++) {
            if (i > 0) sb.append(",");
            sb.append(arr[i]);
        }
        sb.append("]");
        return sb.toString();
    }

    private String listToJsonStr(List<String> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(list.get(i).replace("\"", "\\\"")).append("\"");
        }
        sb.append("]");
        return sb.toString();
    }

    private String listDoubleToJson(List<Double> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(list.get(i));
        }
        sb.append("]");
        return sb.toString();
    }
}

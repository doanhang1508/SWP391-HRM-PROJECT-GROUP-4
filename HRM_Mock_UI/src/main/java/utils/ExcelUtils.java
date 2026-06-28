package utils;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;

public class ExcelUtils {

    public static Workbook openWorkbook(String path) throws Exception {
        FileInputStream fis = new FileInputStream(path);
        return new XSSFWorkbook(fis);
    }

    // Đọc giá trị từ 1 ô Excel (hỗ trợ cả ô Text lẫn ô Số)
    public static String getCell(Row row, int col) {
        Cell cell = row.getCell(col);
        if (cell == null) return "";
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                return String.valueOf((long) cell.getNumericCellValue());
            default:
                return "";
        }
    }

    public static void generateReport(Workbook workbook, Sheet sheet, String resultPath, ArrayList<String[]> results, int passCount, int failCount, int cannotFill, int totalRows) throws Exception {
        // --- Style PASS: nền xanh lá ---
        CellStyle passStyle = workbook.createCellStyle();
        passStyle.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
        passStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        // --- Style FAIL: nền đỏ nhạt ---
        CellStyle failStyle = workbook.createCellStyle();
        failStyle.setFillForegroundColor(IndexedColors.ROSE.getIndex());
        failStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        // --- Style CANNOT FILL: nền vàng ---
        CellStyle warnStyle = workbook.createCellStyle();
        warnStyle.setFillForegroundColor(IndexedColors.YELLOW.getIndex());
        warnStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        // Ghi từng dòng kết quả (viết trực tiếp vào cột 9 và 10 của file gốc)
        for (int r = 0; r < results.size(); r++) {
            Row row = sheet.getRow(r + 1);
            if (row == null) row = sheet.createRow(r + 1);
            
            String[] data = results.get(r);
            
            // Ghi Actual Result vào cột 9 (J)
            Cell actualCell = row.getCell(9);
            if (actualCell == null) actualCell = row.createCell(9);
            actualCell.setCellValue(data[9]);
            
            // Ghi Status vào cột 10 (K)
            Cell statusCell = row.getCell(10);
            if (statusCell == null) statusCell = row.createCell(10);
            statusCell.setCellValue(data[10]);

            // Tô màu cột Status
            switch (data[10]) {
                case "PASS":
                    statusCell.setCellStyle(passStyle);
                    break;
                case "FAIL":
                    statusCell.setCellStyle(failStyle);
                    break;
            }
            
            // Tô màu vàng cột Actual Result nếu là CANNOT FILL
            if (data[9].startsWith("CANNOT FILL")) {
                actualCell.setCellStyle(warnStyle);
            }
        }

        // Tự căn độ rộng cột kết quả
        sheet.autoSizeColumn(9);
        sheet.autoSizeColumn(10);

        // Lưu ra file kết quả mới, giữ nguyên định dạng file gốc
        FileOutputStream fos = new FileOutputStream(resultPath);
        workbook.write(fos);
        fos.close();
        workbook.close();
    }
}

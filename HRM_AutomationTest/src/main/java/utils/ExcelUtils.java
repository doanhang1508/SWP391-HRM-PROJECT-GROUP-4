package utils;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExcelUtils {

    /**
     * Reads data from the first sheet of an Excel file and returns it as a List of Maps.
     * Each Map represents a row, where the key is the column header (from row 0).
     *
     * @param filePath Path to the Excel file
     * @return List of Map<String, String> where each map is a row's data
     */
    public static List<Map<String, String>> getExcelDataAsMap(String filePath) {
        List<Map<String, String>> data = new ArrayList<>();

        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {

            // Đọc sheet đầu tiên (index 0) để không cần quan tâm tên sheet là gì
            Sheet sheet = workbook.getSheetAt(0);
            
            int rowCount = sheet.getLastRowNum();
            if (rowCount <= 0) return data;

            // Lấy dòng Header (dòng đầu tiên) để làm key
            Row headerRow = sheet.getRow(0);
            int colCount = headerRow.getLastCellNum();
            List<String> headers = new ArrayList<>();
            for (int j = 0; j < colCount; j++) {
                headers.add(getCellValueAsString(headerRow.getCell(j)).trim());
            }

            // Bắt đầu đọc từ dòng thứ 2 (index 1)
            for (int i = 1; i <= rowCount; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                Map<String, String> rowData = new HashMap<>();
                for (int j = 0; j < colCount; j++) {
                    Cell cell = row.getCell(j);
                    rowData.put(headers.get(j), getCellValueAsString(cell));
                }
                data.add(rowData);
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return data;
    }

    private static String getCellValueAsString(Cell cell) {
        if (cell == null) {
            return "";
        }
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                // Xử lý số: tránh việc in ra 12345.0
                double value = cell.getNumericCellValue();
                if (value == (long) value) {
                    return String.format("%d", (long) value);
                } else {
                    return String.valueOf(value);
                }
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            case BLANK:
            default:
                return "";
        }
    }
}

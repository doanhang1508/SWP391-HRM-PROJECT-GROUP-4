package scratch;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.File;
import java.io.FileInputStream;

public class ReadExcel {
    public static void main(String[] args) {
        String filePath = "c:/Users/trung/Downloads/SWP391-HRM-PROJECT-GROUP-4/Bang_Cham_Cong_T7_2026_updated.xlsx";
        try (FileInputStream fis = new FileInputStream(new File(filePath));
             Workbook workbook = new XSSFWorkbook(fis)) {

            for (int i = 0; i < workbook.getNumberOfSheets(); i++) {
                Sheet sheet = workbook.getSheetAt(i);
                System.out.println("Sheet: " + sheet.getSheetName());
                for (Row row : sheet) {
                    StringBuilder sb = new StringBuilder();
                    sb.append("Row ").append(row.getRowNum()).append(": ");
                    for (Cell cell : row) {
                        switch (cell.getCellType()) {
                            case STRING:
                                sb.append(cell.getStringCellValue()).append(" | ");
                                break;
                            case NUMERIC:
                                if (DateUtil.isCellDateFormatted(cell)) {
                                    sb.append(cell.getDateCellValue()).append(" | ");
                                } else {
                                    sb.append(cell.getNumericCellValue()).append(" | ");
                                }
                                break;
                            case BOOLEAN:
                                sb.append(cell.getBooleanCellValue()).append(" | ");
                                break;
                            case FORMULA:
                                sb.append(cell.getCellFormula()).append(" | ");
                                break;
                            default:
                                sb.append(" | ");
                        }
                    }
                    if (sb.toString().contains("27") || sb.toString().toLowerCase().contains("thai") || sb.toString().contains("TS")) {
                        System.out.println(sb.toString());
                    } else if (row.getRowNum() < 5) {
                         System.out.println(sb.toString()); // Print first 5 rows to see structure
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

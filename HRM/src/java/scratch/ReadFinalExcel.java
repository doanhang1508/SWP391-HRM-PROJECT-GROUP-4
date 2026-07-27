package scratch;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.File;
import java.io.FileInputStream;

public class ReadFinalExcel {
    public static void main(String[] args) {
        String filePath = "c:/Users/trung/Downloads/SWP391-HRM-PROJECT-GROUP-4/Bang_Cham_Cong_T7_2026_final.xlsx";
        try (FileInputStream fis = new FileInputStream(new File(filePath));
             Workbook workbook = new XSSFWorkbook(fis)) {

            boolean hasError = false;
            
            for (int i = 0; i < workbook.getNumberOfSheets(); i++) {
                Sheet sheet = workbook.getSheetAt(i);
                System.out.println("Sheet: " + sheet.getSheetName());
                for (Row row : sheet) {
                    StringBuilder sb = new StringBuilder();
                    boolean rowHasIssue = false;
                    sb.append("Row ").append(row.getRowNum()).append(": ");
                    
                    for (Cell cell : row) {
                        String cellValue = "";
                        switch (cell.getCellType()) {
                            case STRING:
                                cellValue = cell.getStringCellValue();
                                break;
                            case NUMERIC:
                                if (DateUtil.isCellDateFormatted(cell)) {
                                    cellValue = cell.getDateCellValue().toString();
                                } else {
                                    cellValue = String.valueOf(cell.getNumericCellValue());
                                }
                                break;
                            case BOOLEAN:
                                cellValue = String.valueOf(cell.getBooleanCellValue());
                                break;
                            case FORMULA:
                                cellValue = cell.getCellFormula();
                                break;
                            case ERROR:
                                cellValue = "#ERROR(" + cell.getErrorCellValue() + ")";
                                break;
                            default:
                                cellValue = "";
                        }
                        
                        sb.append(cellValue).append(" | ");
                        
                        String lower = cellValue.toLowerCase();
                        if (lower.contains("nv0027") || lower.contains("thai sản") || lower.contains("thai san") || lower.contains("#ref!")) {
                            rowHasIssue = true;
                            hasError = true;
                        }
                    }
                    if (rowHasIssue) {
                        System.out.println("Found issue: " + sb.toString());
                    }
                }
            }
            if (!hasError) {
                System.out.println("No obvious issues found. NV0027 and Thai San seem to be removed, and no #REF! errors detected.");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

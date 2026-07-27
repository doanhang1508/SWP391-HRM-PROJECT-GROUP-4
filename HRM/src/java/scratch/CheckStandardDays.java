package scratch;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.io.File;
import java.io.FileInputStream;

public class CheckStandardDays {
    public static void main(String[] args) {
        String filePath = "c:/Users/trung/Downloads/SWP391-HRM-PROJECT-GROUP-4/Bang_Cham_Cong_T7_2026_final.xlsx";
        try (FileInputStream fis = new FileInputStream(new File(filePath));
             Workbook workbook = new XSSFWorkbook(fis)) {
            
            // Force formula evaluation
            FormulaEvaluator evaluator = workbook.getCreationHelper().createFormulaEvaluator();
            Sheet sheet = workbook.getSheetAt(0); // Bang Cham Cong T7-2026
            
            // Look at row 8 (holiday row)
            Row holidayRow = sheet.getRow(7); 
            System.out.print("Holidays (row 8): ");
            int holidayCount = 0;
            for(int c=4; c<=34; c++) {
                Cell cell = holidayRow.getCell(c);
                if(cell != null && cell.getCellType() == CellType.NUMERIC) {
                    if (cell.getNumericCellValue() == 1.0) {
                        System.out.print("Day " + (c-3) + " ");
                        holidayCount++;
                    }
                }
            }
            System.out.println("\nTotal holidays marked in row 8: " + holidayCount);
            
            Row dayOfWeekRow = sheet.getRow(6);
            System.out.print("Sundays (row 7): ");
            int sundayCount = 0;
            for(int c=4; c<=34; c++) {
                Cell cell = dayOfWeekRow.getCell(c);
                if(cell != null && cell.getCellType() == CellType.STRING) {
                    if (cell.getStringCellValue().trim().equalsIgnoreCase("CN")) {
                        System.out.print("Day " + (c-3) + " ");
                        sundayCount++;
                    }
                }
            }
            System.out.println("\nTotal Sundays marked in row 7: " + sundayCount);

            Row dataRow = sheet.getRow(14); // nv0003 or someone
            if (dataRow == null) dataRow = sheet.getRow(18); // NV0003
            
            Cell stdDaysCell = dataRow.getCell(35); // AJ (index 35) is Cong Chuan
            if (stdDaysCell != null) {
                if (stdDaysCell.getCellType() == CellType.FORMULA) {
                    CellValue cellValue = evaluator.evaluate(stdDaysCell);
                    System.out.println("Formula evaluated value for Standard Days: " + cellValue.getNumberValue());
                } else if (stdDaysCell.getCellType() == CellType.NUMERIC) {
                     System.out.println("Numeric value for Standard Days: " + stdDaysCell.getNumericCellValue());
                }
            } else {
                System.out.println("Cell 35 is null");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

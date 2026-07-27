package scratch;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.io.File;
import java.io.FileInputStream;

public class ViewOT {
    public static void main(String[] args) {
        String filePath = "c:/Users/trung/Downloads/SWP391-HRM-PROJECT-GROUP-4/Bang_Cham_Cong_T7_2026_final.xlsx";
        try (FileInputStream fis = new FileInputStream(new File(filePath));
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);
            for (int r = 16; r <= 30; r++) { // Around where OT table might be
                Row row = sheet.getRow(r);
                if (row == null) continue;
                StringBuilder sb = new StringBuilder("Row " + r + ": ");
                for (int c = 0; c < 5; c++) {
                    Cell cell = row.getCell(c);
                    if (cell != null) {
                        if (cell.getCellType() == CellType.STRING) {
                            sb.append(cell.getStringCellValue()).append(" | ");
                        } else if (cell.getCellType() == CellType.NUMERIC) {
                            sb.append(cell.getNumericCellValue()).append(" | ");
                        } else {
                            sb.append(cell.getCellType()).append(" | ");
                        }
                    } else {
                        sb.append("null | ");
                    }
                }
                System.out.println(sb.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

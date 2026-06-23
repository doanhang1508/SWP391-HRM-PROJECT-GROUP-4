import org.apache.poi.ss.usermodel.*;
import java.io.File;
import java.io.FileInputStream;

public class ReadExcelTemp {
    public static void main(String[] args) {
        try {
            FileInputStream file = new FileInputStream(new File("Bang_Cham_Cong_HRM_Thang06_2026.xlsx"));
            Workbook workbook = WorkbookFactory.create(file);
            Sheet sheet = workbook.getSheet("CHI_TIET_CHAM_CONG");
            Row row3 = sheet.getRow(3);
            if (row3 != null) {
                for (int j = 0; j < 25; j++) {
                    Cell cell = row3.getCell(j);
                    if (cell == null) System.out.print("[NULL] ");
                    else {
                        CellType type = cell.getCellType();
                        if (type == CellType.FORMULA) {
                            type = cell.getCachedFormulaResultType();
                        }
                        if (type == CellType.STRING) System.out.print("[" + j + ":" + cell.getStringCellValue() + "] ");
                        else if (type == CellType.NUMERIC) {
                            if (DateUtil.isCellDateFormatted(cell)) System.out.print("[" + j + ":" + cell.getDateCellValue() + "] ");
                            else System.out.print("[" + j + ":" + cell.getNumericCellValue() + "] ");
                        }
                        else System.out.print("[" + j + ":" + type + "] ");
                    }
                }
                System.out.println();
            }
            workbook.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

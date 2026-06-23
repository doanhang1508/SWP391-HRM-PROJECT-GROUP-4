import org.apache.poi.ss.usermodel.*;
import java.io.File;
import java.io.FileInputStream;

public class ReadExcelTemp2 {
    public static void main(String[] args) {
        try {
            FileInputStream file = new FileInputStream(new File("Bang_Cham_Cong_HRM_Thang06_2026.xlsx"));
            Workbook workbook = WorkbookFactory.create(file);
            Sheet sheet = workbook.getSheet("CHI_TIET_CHAM_CONG");
            if (sheet == null) return;
            
            Row row = sheet.getRow(3);
            for (int j = 0; j < 15; j++) {
                Cell c = row.getCell(j);
                if (c == null) {
                    System.out.println("Col " + j + ": null");
                } else {
                    System.out.println("Col " + j + ": Type=" + c.getCellType().name() + " Value=" + c.toString());
                    if (c.getCellType() == CellType.FORMULA) {
                        try {
                            System.out.println("  Cached Formula Result Type: " + c.getCachedFormulaResultType().name());
                            if (c.getCachedFormulaResultType() == CellType.STRING) {
                                System.out.println("  Cached String: " + c.getStringCellValue());
                            }
                        } catch(Exception e) {}
                    }
                }
            }
            workbook.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

import org.apache.poi.ss.usermodel.*;
import java.io.File;
import java.io.FileInputStream;

public class CheckExcel {
    public static void main(String[] args) {
        try {
            FileInputStream fis = new FileInputStream(new File("Bang_Cham_Cong_T6_2026_HRM.xlsx"));
            Workbook wb = WorkbookFactory.create(fis);
            System.out.println("Sheets:");
            for(int i=0; i<wb.getNumberOfSheets(); i++) {
                System.out.println(i + ": " + wb.getSheetName(i));
            }
            
            // Look at sheet 1 (Chi tiết chấm công)
            Sheet sheet = wb.getSheetAt(1);
            System.out.println("\n--- Headers from Sheet 1 Row 2 ---");
            Row row2 = sheet.getRow(2);
            for(int c=0; c<=20; c++) {
                Cell cell = row2.getCell(c);
                if(cell != null) {
                    System.out.println("[" + c + "] = " + cell.toString());
                }
            }

            wb.close();
            fis.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

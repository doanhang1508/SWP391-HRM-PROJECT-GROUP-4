import org.apache.poi.ss.usermodel.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

public class FixExcel {
    public static void main(String[] args) {
        try {
            File f = new File("Bang_Cham_Cong_Thang_6_2026.xlsx");
            FileInputStream fis = new FileInputStream(f);
            Workbook workbook = WorkbookFactory.create(fis);
            fis.close();
            
            // The 2nd sheet (index 1) is "Chi tiết chấm công"
            System.out.println("Old name: " + workbook.getSheetName(1));
            workbook.setSheetName(1, "CHI_TIET_CHAM_CONG");
            System.out.println("New name: " + workbook.getSheetName(1));
            
            FileOutputStream fos = new FileOutputStream(f);
            workbook.write(fos);
            fos.close();
            workbook.close();
            System.out.println("Excel file fixed!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

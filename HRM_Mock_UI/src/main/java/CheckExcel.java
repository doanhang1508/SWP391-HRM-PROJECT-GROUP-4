import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.io.FileInputStream;
import java.text.SimpleDateFormat;

public class CheckExcel {
    public static void main(String[] args) {
        try {
            FileInputStream fis = new FileInputStream("../Bang_Cham_Cong_Thang_6_2026.xlsx");
            Workbook wb = new XSSFWorkbook(fis);
            Sheet sheet = wb.getSheet("CHI_TIET_CHAM_CONG");
            if (sheet == null) {
                System.out.println("Sheet CHI_TIET_CHAM_CONG not found.");
                sheet = wb.getSheetAt(0);
                System.out.println("Using first sheet: " + sheet.getSheetName());
            }

            for (int i = 0; i < 5; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                System.out.println("Row " + i + ":");
                for (int c = 0; c <= 20; c++) {
                    Cell cell = row.getCell(c);
                    if (cell != null) {
                        System.out.print(" Col " + c + ": " + cell.toString() + " | ");
                    }
                }
                System.out.println();
            }
            wb.close();
            fis.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

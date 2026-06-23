import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileOutputStream;

public class GenerateTemplate {
    public static void main(String[] args) {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("ChamCong");

            // Tạo hàng tiêu đề
            Row headerRow = sheet.createRow(0);
            String[] columns = {"user_id", "shift_id", "work_date", "check_in", "check_out", "status", "overtime_hrs", "ot_reason"};
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
            }

            // Sample data row 1
            Row row1 = sheet.createRow(1);
            row1.createCell(0).setCellValue(2); // user_id
            row1.createCell(1).setCellValue(1); // shift_id
            row1.createCell(2).setCellValue("2026-06-01"); // work_date
            row1.createCell(3).setCellValue("07:30"); // check_in
            row1.createCell(4).setCellValue("17:30"); // check_out
            row1.createCell(5).setCellValue("PRESENT"); // status
            row1.createCell(6).setCellValue(0.0); // overtime_hrs
            row1.createCell(7).setCellValue(""); // ot_reason

            // Sample data row 2
            Row row2 = sheet.createRow(2);
            row2.createCell(0).setCellValue(2);
            row2.createCell(1).setCellValue(1);
            row2.createCell(2).setCellValue("2026-06-02");
            row2.createCell(3).setCellValue("07:45");
            row2.createCell(4).setCellValue("17:30");
            row2.createCell(5).setCellValue("LATE");
            row2.createCell(6).setCellValue(2.5);
            row2.createCell(7).setCellValue("Làm thêm dự án A");

            // Sample data row 3
            Row row3 = sheet.createRow(3);
            row3.createCell(0).setCellValue(3);
            row3.createCell(1).setCellValue(3); // Ca đêm 2
            row3.createCell(2).setCellValue("2026-06-03");
            row3.createCell(3).setCellValue(""); 
            row3.createCell(4).setCellValue(""); 
            row3.createCell(5).setCellValue("ABSENT");
            row3.createCell(6).setCellValue(0);
            row3.createCell(7).setCellValue("");

            try (FileOutputStream fileOut = new FileOutputStream("Template_Import_ChamCong.xlsx")) {
                workbook.write(fileOut);
            }
            System.out.println("File generated successfully.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

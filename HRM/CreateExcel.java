import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileOutputStream;

public class CreateExcel {
    public static void main(String[] args) {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Attendance");
            
            // Header
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("user_id");
            header.createCell(1).setCellValue("shift_id");
            header.createCell(2).setCellValue("work_date");
            header.createCell(3).setCellValue("check_in");
            header.createCell(4).setCellValue("check_out");
            header.createCell(5).setCellValue("status");
            header.createCell(6).setCellValue("overtime_hrs");
            header.createCell(7).setCellValue("ot_reason");

            Object[][] data = {
                {2, 1, "2026-06-15", "08:00", "17:00", "PRESENT", 0.0, ""},
                {2, 1, "2026-06-16", "08:15", "17:00", "LATE", 0.0, ""},
                {2, 1, "2026-06-17", "08:00", "17:00", "PRESENT", 0.0, ""},
                {3, 2, "2026-06-15", "13:00", "21:00", "PRESENT", 2.5, "Dự án gấp"},
                {3, 2, "2026-06-16", "", "", "ABSENT", 0.0, ""},
                {3, 2, "2026-06-17", "13:00", "17:00", "HALFDAY", 0.0, ""},
                {4, 1, "2026-06-15", "08:00", "17:00", "PRESENT", 0.0, ""},
                {4, 1, "2026-06-16", "08:00", "17:00", "PRESENT", 1.0, "Làm thêm giờ"},
                {4, 1, "2026-06-17", "08:00", "17:00", "PRESENT", 0.0, ""}
            };

            int rowNum = 1;
            for (Object[] rowData : data) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue((Integer) rowData[0]);
                row.createCell(1).setCellValue((Integer) rowData[1]);
                row.createCell(2).setCellValue((String) rowData[2]);
                row.createCell(3).setCellValue((String) rowData[3]);
                row.createCell(4).setCellValue((String) rowData[4]);
                row.createCell(5).setCellValue((String) rowData[5]);
                row.createCell(6).setCellValue((Double) rowData[6]);
                row.createCell(7).setCellValue((String) rowData[7]);
            }

            for(int i=0; i<8; i++) sheet.autoSizeColumn(i);

            String filePath = "C:/Users/trung/Downloads/Bang_Cham_Cong_Mau.xlsx";
            try (FileOutputStream fileOut = new FileOutputStream(filePath)) {
                workbook.write(fileOut);
            }
            System.out.println("Excel file created at: " + filePath);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

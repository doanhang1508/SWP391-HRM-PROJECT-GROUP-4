package controller.hr;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.User;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Controller xử lý Upload CCCD mặt trước để bóc tách dữ liệu qua OCR.space API
 * URL: /hr/onboarding/upload
 * Roles: HR Manager (2), HR Staff (5)
 */
@WebServlet("/hr/onboarding/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 15
)
public class UploadCCCDController extends HttpServlet {

    private static final String OCR_API_KEY = "K86086396988957";
    private static final String OCR_URL = "https://api.ocr.space/parse/image";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 5)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        session.removeAttribute("ocr_id");
        session.removeAttribute("ocr_name");
        session.removeAttribute("ocr_dob");
        session.removeAttribute("ocr_address");
        session.removeAttribute("ocr_gender");

        req.getRequestDispatcher("/hr/onboarding-upload.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 5)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Part filePart = req.getPart("cccdImage");
        if (filePart == null || filePart.getSize() == 0) {
            req.setAttribute("error", "Vui lòng chọn một ảnh CCCD hợp lệ.");
            req.getRequestDispatcher("/hr/onboarding-upload.jsp").forward(req, resp);
            return;
        }

        try {
            String parsedText = callOcrSpace(filePart);

            if (parsedText != null && !parsedText.trim().isEmpty()) {
                System.out.println("[OCR] Raw text: " + parsedText);

                String id      = extractId(parsedText);
                String name    = extractName(parsedText);
                String dob     = extractDob(parsedText);
                String address = extractAddress(parsedText);
                String gender  = extractGender(parsedText);

                String genderCode = "";
                if (gender.toLowerCase().contains("nữ") || gender.toLowerCase().contains("nu") || gender.equalsIgnoreCase("female")) {
                    genderCode = "0";
                } else if (gender.toLowerCase().contains("nam") || gender.equalsIgnoreCase("male")) {
                    genderCode = "1";
                }

                String formattedDob = formatDobToIso(dob);

                session.setAttribute("ocr_id",     id);
                session.setAttribute("ocr_name",   name);
                session.setAttribute("ocr_dob",    formattedDob);
                session.setAttribute("ocr_address", address);
                session.setAttribute("ocr_gender", genderCode);

                resp.sendRedirect(req.getContextPath() + "/hr/onboarding/new?ocr=success");
                return;

            } else {
                req.setAttribute("error", "Không thể đọc nội dung từ ảnh. Vui lòng thử ảnh rõ nét hơn hoặc nhập tay.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
        }

        req.getRequestDispatcher("/hr/onboarding-upload.jsp").forward(req, resp);
    }

    // =========================================================================
    // OCR.space API Call
    // =========================================================================

    private String callOcrSpace(Part filePart) throws IOException {
        String boundary = "----OCRBoundary" + System.currentTimeMillis();

        URL url = new URL(OCR_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setUseCaches(false);
        conn.setDoOutput(true);
        conn.setDoInput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(30000);

        try (DataOutputStream dos = new DataOutputStream(conn.getOutputStream())) {
            // API fields
            writeField(dos, boundary, "apikey",             OCR_API_KEY);
            writeField(dos, boundary, "language",           "eng");
            writeField(dos, boundary, "isOverlayRequired",  "false");
            writeField(dos, boundary, "detectOrientation",  "true");
            writeField(dos, boundary, "scale",              "true");
            writeField(dos, boundary, "OCREngine",          "2");

            // File
            String mimeType = filePart.getContentType();
            if (mimeType == null || mimeType.isEmpty()) mimeType = "image/jpeg";
            String fileName = filePart.getSubmittedFileName();
            if (fileName == null || fileName.isEmpty()) fileName = "cccd.jpg";

            dos.writeBytes("--" + boundary + "\r\n");
            dos.writeBytes("Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"\r\n");
            dos.writeBytes("Content-Type: " + mimeType + "\r\n\r\n");
            try (InputStream fis = filePart.getInputStream()) {
                byte[] buf = new byte[4096];
                int n;
                while ((n = fis.read(buf)) != -1) dos.write(buf, 0, n);
            }
            dos.writeBytes("\r\n");
            dos.writeBytes("--" + boundary + "--\r\n");
            dos.flush();
        }

        int status = conn.getResponseCode();
        InputStream is = (status == 200) ? conn.getInputStream() : conn.getErrorStream();

        if (is == null) return null;

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
        }

        JSONObject json = new JSONObject(sb.toString());
        if (json.optBoolean("IsErroredOnProcessing", false)) {
            String err = json.optString("ErrorMessage", "Lỗi OCR không xác định");
            throw new IOException("OCR.space: " + err);
        }

        JSONArray results = json.optJSONArray("ParsedResults");
        if (results != null && results.length() > 0) {
            return results.getJSONObject(0).optString("ParsedText", "");
        }
        return null;
    }

    private void writeField(DataOutputStream dos, String boundary, String name, String value) throws IOException {
        dos.writeBytes("--" + boundary + "\r\n");
        dos.writeBytes("Content-Disposition: form-data; name=\"" + name + "\"\r\n\r\n");
        dos.write(value.getBytes("UTF-8"));
        dos.writeBytes("\r\n");
    }

    // =========================================================================
    // Regex Parsers cho CCCD Việt Nam
    // =========================================================================

    /** Số CCCD: 12 chữ số (hoặc CMND 9 chữ số) */
    private String extractId(String text) {
        // Ưu tiên tìm số sau "Số/" hoặc "No."
        Matcher m = Pattern.compile("(?i)(?:Số|No)[./:\\s]+(\\d{9}|\\d{12})").matcher(text);
        if (m.find()) return m.group(1).trim();
        // Fallback: số 12 chữ số đứng một mình
        m = Pattern.compile("\\b(\\d{12})\\b").matcher(text);
        if (m.find()) return m.group(1);
        m = Pattern.compile("\\b(\\d{9})\\b").matcher(text);
        if (m.find()) return m.group(1);
        return "";
    }

    /** Họ và tên: sau "Họ và tên" hoặc "Full name" */
    private String extractName(String text) {
        String[] patterns = {
            "(?i)H[oọ]\\s*v[aà]\\s*t[eê]n[^:]*:\\s*([^\\n\\r/]+)",
            "(?i)Full\\s*name[:\\s]+([^\\n\\r/]+)"
        };
        for (String pat : patterns) {
            Matcher m = Pattern.compile(pat).matcher(text);
            if (m.find()) {
                String val = m.group(1).trim();
                // Loại bỏ phần sau "/" nếu có (song ngữ)
                if (val.contains("/")) val = val.substring(0, val.indexOf("/")).trim();
                if (!val.isEmpty()) return val;
            }
        }
        return "";
    }

    /** Ngày sinh: DD/MM/YYYY */
    private String extractDob(String text) {
        // Sau "Ngày sinh" hoặc "Date of birth"
        Matcher m = Pattern.compile("(?i)(?:Ng[aà]y\\s*sinh|Date\\s*of\\s*birth)[^\\d]*(\\d{2}/\\d{2}/\\d{4})").matcher(text);
        if (m.find()) return m.group(1);
        // Fallback: pattern ngày bất kỳ
        m = Pattern.compile("\\b(\\d{2}/\\d{2}/\\d{4})\\b").matcher(text);
        if (m.find()) return m.group(1);
        return "";
    }

    /** Giới tính: Nam / Nữ */
    private String extractGender(String text) {
        Matcher m = Pattern.compile("(?i)(?:Gi[oớ]i\\s*t[ií]nh|Sex)[:\\s]+(Nam|N[ữu]|Male|Female)").matcher(text);
        if (m.find()) return m.group(1).trim();
        if (text.contains("Nữ")) return "Nữ";
        if (Pattern.compile("\\bNam\\b").matcher(text).find()) return "Nam";
        return "";
    }

    /** Nơi thường trú: lấy đến hết dòng */
    private String extractAddress(String text) {
        Matcher m = Pattern.compile("(?i)(?:N[oơ]i\\s*th[uư][oờ]ng\\s*tr[uú]|Place\\s*of\\s*residence)[:\\s]+([^\\n\\r]+)").matcher(text);
        if (m.find()) return m.group(1).trim();
        return "";
    }

    // =========================================================================
    // Format ngày DD/MM/YYYY → YYYY-MM-DD (để input[type=date])
    // =========================================================================

    private String formatDobToIso(String dob) {
        if (dob == null || dob.trim().isEmpty()) return "";
        try {
            String[] parts = dob.trim().split("[/\\-]");
            if (parts.length == 3) {
                if (parts[0].length() == 4) return parts[0] + "-" + parts[1] + "-" + parts[2];
                return parts[2] + "-" + parts[1] + "-" + parts[0];
            }
        } catch (Exception ignored) {}
        return "";
    }
}

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

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.ByteArrayOutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Controller xử lý Upload CCCD mặt trước để bóc tách dữ liệu qua Google Gemini AI
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

    private static final String GEMINI_API_KEY = "AQ.Ab8RN6LWGiajlyW20Qr2MCpsaB9xsSETTvdrSzuy5sqWTNPYbw";
    private static final String GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=" + GEMINI_API_KEY;

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
            String jsonResponse = callGeminiAiVision(filePart);

            if (jsonResponse != null) {
                JSONObject obj = new JSONObject(jsonResponse);
                
                if (obj.has("candidates")) {
                    JSONArray candidates = obj.getJSONArray("candidates");
                    if (candidates.length() > 0) {
                        JSONObject firstCandidate = candidates.getJSONObject(0);
                        JSONObject content = firstCandidate.getJSONObject("content");
                        JSONArray parts = content.getJSONArray("parts");
                        if (parts.length() > 0) {
                            String textResponse = parts.getJSONObject(0).getString("text");
                            
                            // Gemini có thể trả về block markdown ```json ... ```, cần loại bỏ
                            textResponse = textResponse.replaceAll("```json", "").replaceAll("```", "").trim();
                            
                            try {
                                JSONObject data = new JSONObject(textResponse);
                                
                                String id = data.has("id") ? data.getString("id") : "";
                                String name = data.has("name") ? data.getString("name") : "";
                                String dob = data.has("dob") ? data.getString("dob") : "";
                                String address = data.has("address") ? data.getString("address") : "";
                                String sex = data.has("sex") ? data.getString("sex") : "";

                                String genderCode = "";
                                if (sex.toLowerCase().contains("nam")) {
                                    genderCode = "1";
                                } else if (sex.toLowerCase().contains("nữ") || sex.toLowerCase().contains("nu")) {
                                    genderCode = "0";
                                }

                                String formattedDob = formatDobToIso(dob);

                                session.setAttribute("ocr_id", id);
                                session.setAttribute("ocr_name", name);
                                session.setAttribute("ocr_dob", formattedDob);
                                session.setAttribute("ocr_address", address);
                                session.setAttribute("ocr_gender", genderCode);

                                resp.sendRedirect(req.getContextPath() + "/hr/onboarding/new?ocr=success");
                                return;
                            } catch (Exception parseEx) {
                                System.out.println("Lỗi parse JSON từ Gemini: " + textResponse);
                                req.setAttribute("error", "Không thể trích xuất dữ liệu: Định dạng trả về không hợp lệ.");
                            }
                        }
                    }
                } else if (obj.has("error")) {
                    JSONObject errorObj = obj.getJSONObject("error");
                    String errorMsg = errorObj.optString("message", "Lỗi không xác định từ Gemini AI");
                    req.setAttribute("error", "Không thể trích xuất dữ liệu: " + errorMsg);
                } else {
                    req.setAttribute("error", "Không tìm thấy dữ liệu trích xuất từ ảnh.");
                }
            } else {
                req.setAttribute("error", "Lỗi kết nối tới dịch vụ AI. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
        }

        req.getRequestDispatcher("/hr/onboarding-upload.jsp").forward(req, resp);
    }

    private String callGeminiAiVision(Part filePart) throws IOException {
        URL url = new URL(GEMINI_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setUseCaches(false);
        conn.setDoOutput(true);
        conn.setDoInput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");

        // Convert Part to Base64
        String base64Image = "";
        String mimeType = filePart.getContentType();
        if (mimeType == null || mimeType.isEmpty()) {
            mimeType = "image/jpeg";
        }
        
        try (InputStream fileInputStream = filePart.getInputStream();
             ByteArrayOutputStream buffer = new ByteArrayOutputStream()) {
            int nRead;
            byte[] data = new byte[4096];
            while ((nRead = fileInputStream.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, nRead);
            }
            buffer.flush();
            byte[] imageBytes = buffer.toByteArray();
            base64Image = Base64.getEncoder().encodeToString(imageBytes);
        }

        // Construct JSON Payload for Gemini 1.5 Flash
        JSONObject payload = new JSONObject();
        JSONArray contents = new JSONArray();
        JSONObject content = new JSONObject();
        JSONArray parts = new JSONArray();
        
        JSONObject textPart = new JSONObject();
        textPart.put("text", "Trích xuất thông tin từ ảnh Căn cước công dân Việt Nam này. Trả về DUY NHẤT một chuỗi JSON hợp lệ với các key: 'id' (Số CCCD), 'name' (Họ và tên), 'dob' (Ngày sinh DD/MM/YYYY), 'address' (Nơi thường trú), 'sex' (Giới tính: Nam hoặc Nữ). Không kèm markdown hay bất kỳ text nào khác. Nếu trường nào không rõ, để trống chuỗi đó.");
        
        JSONObject inlineDataPart = new JSONObject();
        JSONObject inlineData = new JSONObject();
        inlineData.put("mime_type", mimeType);
        inlineData.put("data", base64Image);
        inlineDataPart.put("inline_data", inlineData);
        
        parts.put(textPart);
        parts.put(inlineDataPart);
        content.put("parts", parts);
        contents.put(content);
        payload.put("contents", contents);

        // Send Request
        try (DataOutputStream request = new DataOutputStream(conn.getOutputStream())) {
            request.write(payload.toString().getBytes("UTF-8"));
            request.flush();
        }

        int status = conn.getResponseCode();
        InputStream is = (status == 200) ? conn.getInputStream() : conn.getErrorStream();

        if (is != null) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                return response.toString();
            }
        }
        return null;
    }

    private String formatDobToIso(String dob) {
        if (dob == null || dob.trim().isEmpty() || dob.equalsIgnoreCase("N/A")) return "";
        try {
            String[] parts = dob.trim().split("[/-]");
            if (parts.length == 3) {
                if (parts[0].length() == 4) {
                    return parts[0] + "-" + parts[1] + "-" + parts[2];
                }
                return parts[2] + "-" + parts[1] + "-" + parts[0];
            }
        } catch (Exception e) {}
        return "";
    }
}

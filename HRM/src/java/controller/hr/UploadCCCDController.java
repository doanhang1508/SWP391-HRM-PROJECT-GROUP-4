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
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.UUID;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Controller xử lý Upload CCCD mặt trước để bóc tách dữ liệu qua FPT.AI Vision
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

    private static final String FPT_AI_API_KEY = "S9TQC0MWh4y1Jo5qAw9diBhOpAX0lm8y";
    private static final String FPT_AI_URL = "https://api.fpt.ai/vision/idr/vnm";

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

        req.getRequestDispatcher("/hr/onboarding-upload.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
            String jsonResponse = callFptAiVision(filePart);

            if (jsonResponse != null) {
                JSONObject obj = new JSONObject(jsonResponse);
                int errorCode = obj.optInt("errorCode", -1);

                if (errorCode == 0) {
                    JSONArray dataArr = obj.getJSONArray("data");
                    if (dataArr.length() > 0) {
                        JSONObject data = dataArr.getJSONObject(0);

                        String id = data.has("id") ? data.getString("id") : "";
                        String name = data.has("name") ? data.getString("name") : "";
                        String dob = data.has("dob") ? data.getString("dob") : "";
                        String address = data.has("address") ? data.getString("address") : "";
                        String sex = data.has("sex") ? data.getString("sex") : "";

                        String genderCode = "";
                        if (sex.equalsIgnoreCase("Nam")) {
                            genderCode = "1";
                        } else if (sex.equalsIgnoreCase("Nữ") || sex.equalsIgnoreCase("Nu")) {
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
                    }
                } else {
                    System.out.println("FPT AI Error Response: " + jsonResponse);
                    String errorMsg = obj.optString("errorMessage", obj.optString("message", "Lỗi không xác định từ AI"));
                    req.setAttribute("error", "Không thể trích xuất dữ liệu: " + errorMsg);
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

    private String callFptAiVision(Part filePart) throws IOException {
        String boundary = "Boundary-" + System.currentTimeMillis();
        URL url = new URL(FPT_AI_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setUseCaches(false);
        conn.setDoOutput(true);
        conn.setDoInput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("api_key", FPT_AI_API_KEY);
        conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

        try (DataOutputStream request = new DataOutputStream(conn.getOutputStream());
             InputStream fileInputStream = filePart.getInputStream()) {

            request.writeBytes("--" + boundary + "\r\n");
            request.writeBytes("Content-Disposition: form-data; name=\"image\"; filename=\"" + getFileName(filePart) + "\"\r\n");
            request.writeBytes("Content-Type: " + filePart.getContentType() + "\r\n\r\n");

            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                request.write(buffer, 0, bytesRead);
            }
            request.writeBytes("\r\n");
            request.writeBytes("--" + boundary + "--\r\n");
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

    private String getFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                return cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "upload_" + UUID.randomUUID().toString() + ".jpg";
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

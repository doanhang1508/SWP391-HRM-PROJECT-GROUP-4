package controller;

import dao.UserDAO;
import dao.notificationDAO;
import model.User;
import model.notification;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Properties;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Google OAuth 2.0 Authentication Servlet (HRM Project).
 *
 * Luồng: 1. GET /auth/google → Redirect user đến Google Consent Screen 2.
 * Google redirect về /auth/google/callback?code=... 3. Đổi code lấy
 * access_token 4. Dùng access_token lấy thông tin user (email, name, picture)
 * 5. Nếu email đã có trong DB → đăng nhập luôn Nếu chưa có → tạo tài khoản mới
 * (roleId=2, status=1) → đăng nhập
 */
@WebServlet(name = "GoogleOAuthController", urlPatterns = {"/auth/google", "/auth/google/callback"})
public class GoogleOAuthController extends HttpServlet {

    // ── OAuth endpoints của Google ──
    private static final String GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String GOOGLE_INFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";
    private static final String SCOPE = "openid email profile";

    // ── Đọc từ google-oauth.properties ──
    private String clientId;
    private String clientSecret;
    private String redirectUri;

    @Override
    public void init() throws ServletException {
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("google-oauth.properties")) {
            if (is == null) {
                throw new ServletException("Không tìm thấy google-oauth.properties");
            }
            Properties props = new Properties();
            props.load(is);
            clientId = props.getProperty("client_id");
            clientSecret = props.getProperty("client_secret");
            redirectUri = props.getProperty("redirect_uri");
        } catch (IOException e) {
            throw new ServletException("Lỗi load google-oauth.properties: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/auth/google".equals(path)) {
            // ── BƯỚC 1: Tạo Google Consent URL và redirect ──
            handleInitiate(request, response);
        } else if ("/auth/google/callback".equals(path)) {
            // ── BƯỚC 2-5: Xử lý callback từ Google ──
            handleCallback(request, response);
        }
    }

    // ─────────────────────────────────────────────────────────
    // BƯỚC 1: Tạo URL xác thực và redirect đến Google
    // ─────────────────────────────────────────────────────────
    private void handleInitiate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // state token để chống CSRF
        String state = UUID.randomUUID().toString();
        request.getSession().setAttribute("oauth_state", state);

        String authUrl = GOOGLE_AUTH_URL
                + "?client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&response_type=code"
                + "&scope=" + URLEncoder.encode(SCOPE, StandardCharsets.UTF_8)
                + "&state=" + URLEncoder.encode(state, StandardCharsets.UTF_8)
                + "&access_type=offline"
                + "&prompt=select_account";

        response.sendRedirect(authUrl);
    }

    // ─────────────────────────────────────────────────────────
    // BƯỚC 2-5: Google callback → lấy token → lấy info → login
    // ─────────────────────────────────────────────────────────
    private void handleCallback(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("code");
        String state = request.getParameter("state");
        String error = request.getParameter("error");

        // Người dùng từ chối cấp quyền
        if (error != null || code == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=google_denied");
            return;
        }

        // Kiểm tra CSRF state
        HttpSession session = request.getSession();
        String savedState = (String) session.getAttribute("oauth_state");
        session.removeAttribute("oauth_state");
        if (savedState == null || !savedState.equals(state)) {
            response.sendRedirect(request.getContextPath() + "/login?error=invalid_state");
            return;
        }

        // BƯỚC 3: Đổi code → access_token
        String accessToken = exchangeCodeForToken(code);
        if (accessToken == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=token_error");
            return;
        }

        // BƯỚC 4: Lấy thông tin user từ Google
        String[] userInfo = getUserInfo(accessToken); // [email, name, picture]
        if (userInfo == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=userinfo_error");
            return;
        }

        String email = userInfo[0];
        String fullName = userInfo[1];
        String picture = userInfo[2];

        // BƯỚC 5: Tìm hoặc tạo user trong DB
        UserDAO userDAO = new UserDAO();
        User user = userDAO.createOrUpdateGoogleUser(email, fullName, picture);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=db_error");
            return;
        }

        // Chặn nếu tài khoản chưa được duyệt hoặc bị khóa
        if (user.getStatus() == 0) {
            response.sendRedirect(request.getContextPath() + "/login?error=pending");
            return;
        }

        // Đăng nhập thành công → set session → gửi thông báo → redirect dashboard
        session.setAttribute("currentUser", user);
        sendLoginNotification(user, request);

        // Flash message hiện toast góc dưới màn hình
        String displayName = (user.getFullName() != null && !user.getFullName().isBlank())
                ? user.getFullName() : user.getEmail();
        session.setAttribute("toastSuccess", "Đăng nhập Google thành công! Chào mừng, " + displayName + ".");

        if (user.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/employee/dashboard");
        }
    }

    // ─────────────────────────────────────────────────────────
    // Helper: Đổi authorization code → access_token
    // ─────────────────────────────────────────────────────────
    private String exchangeCodeForToken(String code) {
        try {
            String body = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8)
                    + "&client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                    + "&client_secret=" + URLEncoder.encode(clientSecret, StandardCharsets.UTF_8)
                    + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                    + "&grant_type=authorization_code";

            HttpURLConnection conn = (HttpURLConnection) new URL(GOOGLE_TOKEN_URL).openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }

            String json = readResponse(conn);
            // Trích xuất access_token từ JSON đơn giản
            return extractJsonValue(json, "access_token");

        } catch (Exception e) {
            System.err.println("Lỗi exchangeCodeForToken: " + e.getMessage());
            return null;
        }
    }

    // ─────────────────────────────────────────────────────────
    // Helper: Lấy thông tin user từ Google userinfo endpoint
    // Trả về [email, name, picture] hoặc null nếu lỗi
    // ─────────────────────────────────────────────────────────
    private String[] getUserInfo(String accessToken) {
        try {
            HttpURLConnection conn = (HttpURLConnection) new URL(GOOGLE_INFO_URL).openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);

            String json = readResponse(conn);
            String email = extractJsonValue(json, "email");
            String name = extractJsonValue(json, "name");
            String picture = extractJsonValue(json, "picture");

            if (email == null) {
                return null;
            }
            return new String[]{email, name, picture};

        } catch (Exception e) {
            System.err.println("Lỗi getUserInfo: " + e.getMessage());
            return null;
        }
    }

    // ─────────────────────────────────────────────────────────
    // Helper: Đọc response body từ HTTP connection
    // ─────────────────────────────────────────────────────────
    private String readResponse(HttpURLConnection conn) throws IOException {
        InputStream is = conn.getResponseCode() < 400
                ? conn.getInputStream()
                : conn.getErrorStream();
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    // ─────────────────────────────────────────────────────────
    // Helper: Trích xuất giá trị từ JSON string đơn giản
    // Không cần thư viện JSON (phù hợp dự án SWP391)
    // ─────────────────────────────────────────────────────────
    private String extractJsonValue(String json, String key) {
        if (json == null) {
            return null;
        }
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) {
            return null;
        }
        int colon = json.indexOf(":", idx + search.length());
        if (colon < 0) {
            return null;
        }
        int start = json.indexOf("\"", colon + 1);
        if (start < 0) {
            return null;
        }
        int end = json.indexOf("\"", start + 1);
        if (end < 0) {
            return null;
        }
        return json.substring(start + 1, end);
    }

    // ─────────────────────────────────────────────────────────
    // Gửi thông báo "Đăng nhập thành công" vào DB (giống loginController)
    // ─────────────────────────────────────────────────────────
    private void sendLoginNotification(User user, HttpServletRequest req) {
        try {
            String userAgent = req.getHeader("User-Agent");
            String device = parseDevice(userAgent);

            String ip = req.getHeader("X-Forwarded-For");
            if (ip == null || ip.isBlank()) {
                ip = req.getRemoteAddr();
            }

            String timeStr = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("HH:mm - dd/MM/yyyy"));

            notification notif = new notification();
            notif.setUserId(user.getUserId());
            notif.setType("system");
            notif.setTitle("Đăng nhập thành công (Google)");
            notif.setBody(String.format(
                    "Bạn vừa đăng nhập qua Google lúc %s từ %s (IP: %s). Nếu không phải bạn, hãy đổi mật khẩu ngay.",
                    timeStr, device, ip));
            notif.setLink("/profile/security");

            new notificationDAO().create(notif);
        } catch (Exception e) {
            // Không để lỗi thông báo ảnh hưởng luồng đăng nhập
            e.printStackTrace();
        }
    }

    private String parseDevice(String ua) {
        if (ua == null) return "Thiết bị không xác định";
        ua = ua.toLowerCase();

        String os;
        if (ua.contains("windows"))            os = "Windows";
        else if (ua.contains("macintosh") || ua.contains("mac os")) os = "macOS";
        else if (ua.contains("android"))       os = "Android";
        else if (ua.contains("iphone") || ua.contains("ipad"))     os = "iOS";
        else if (ua.contains("linux"))         os = "Linux";
        else                                   os = "Hệ điều hành khác";

        String browser;
        if (ua.contains("edg"))                browser = "Microsoft Edge";
        else if (ua.contains("opr") || ua.contains("opera")) browser = "Opera";
        else if (ua.contains("chrome"))        browser = "Chrome";
        else if (ua.contains("firefox"))       browser = "Firefox";
        else if (ua.contains("safari"))        browser = "Safari";
        else                                   browser = "Trình duyệt khác";

        return browser + " / " + os;
    }
}

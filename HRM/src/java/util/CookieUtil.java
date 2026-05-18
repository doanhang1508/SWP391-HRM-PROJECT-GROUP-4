package util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Secure cookie helper for JWT auth tokens.
 *
 * <p>All auth cookies are HttpOnly (no JS access), SameSite=Lax (CSRF protection),
 * and Secure when served over HTTPS.</p>
 */
public final class CookieUtil {

    public static final String REMEMBER_EMAIL_COOKIE = "remember_email";

    private CookieUtil() {}

    public static Cookie createSecureCookie(String name, String value, int maxAge, boolean isSecure) {
        Cookie cookie = new Cookie(name, value);
        cookie.setHttpOnly(true);
        cookie.setSecure(isSecure);
        cookie.setPath("/");
        cookie.setMaxAge(maxAge);
        return cookie;
    }

    public static void addSecureCookie(HttpServletResponse response, String name, String value,
                                       int maxAge, boolean isSecure) {
        addSecureCookie(response, name, value, maxAge, isSecure, "/");
    }

    public static void addSecureCookie(HttpServletResponse response, String name, String value,
                                       int maxAge, boolean isSecure, String cookiePath) {
        String path = normalizePath(cookiePath);
        StringBuilder sb = new StringBuilder();
        sb.append(name).append("=").append(value);
        sb.append("; Path=").append(path);
        sb.append("; HttpOnly");
        if (maxAge >= 0) {
            sb.append("; Max-Age=").append(maxAge);
        }
        if (isSecure) {
            sb.append("; Secure");
        }
        sb.append("; SameSite=Lax");
        response.addHeader("Set-Cookie", sb.toString());
    }

    public static void deleteCookie(HttpServletResponse response, String name, boolean isSecure) {
        addSecureCookie(response, name, "", 0, isSecure, "/");
    }

    public static void deleteCookie(HttpServletResponse response, String name, boolean isSecure, String cookiePath) {
        addSecureCookie(response, name, "", 0, isSecure, cookiePath);
    }

    public static String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie c : cookies) {
            if (name.equals(c.getName())) {
                return c.getValue();
            }
        }
        return null;
    }

    private static String normalizePath(String cookiePath) {
        if (cookiePath == null || cookiePath.isEmpty()) {
            return "/";
        }
        return cookiePath.startsWith("/") ? cookiePath : "/" + cookiePath;
    }
}

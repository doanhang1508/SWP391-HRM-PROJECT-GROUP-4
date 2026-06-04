package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;

/**
 * AuthFilter — Bộ lọc xác thực và phân quyền URL.
 *
 * Mapping URL được đăng ký trong web.xml:
 *   /dashboard              → role 1-6 (management)
 *   /admin/users            → role 1 (Admin only) — quản lý tài khoản
 *   /admin/automation       → role 1 (Admin only) — tác vụ tự động
 *   /admin/* (còn lại)      → role 1, 2 (Admin + HR Manager)
 *   /hr/*                   → role 2, 5 (HR Manager, HR Staff)
 *   /employee/*             → mọi role đã đăng nhập
 *   /editRolePermission     → role 1 (Admin only)
 *   /role/*                 → role 1 (Admin only)
 *
 * Role IDs:
 *   1 = Admin
 *   2 = HR Manager (Trưởng phòng nhân sự)
 *   3 = Factory Manager
 *   4 = Director
 *   5 = HR Staff
 *   6 = Department Manager
 *   7 = Employee
 */
public class AuthFilter implements Filter {

    // Role constants
    private static final int ROLE_ADMIN       = 1;
    private static final int ROLE_HR_MANAGER  = 2;
    private static final int ROLE_FACTORY_MGR = 3;
    private static final int ROLE_DIRECTOR    = 4;
    private static final int ROLE_HR_STAFF    = 5;
    private static final int ROLE_DEPT_MGR    = 6;
    private static final int ROLE_EMPLOYEE    = 7;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần khởi tạo gì thêm
    }

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  servletRequest;
        HttpServletResponse resp = (HttpServletResponse) servletResponse;

        HttpSession session  = req.getSession(false);
        User currentUser = (session != null)
                ? (User) session.getAttribute("currentUser")
                : null;

        // ── 1. Chưa đăng nhập → về login ──────────────────────────────────
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int roleId = currentUser.getRoleId();
        String uri = req.getRequestURI();          // ví dụ: /HRM/admin/users
        String ctx = req.getContextPath();          // ví dụ: /HRM
        // Lấy phần path sau context (không có context prefix)
        String path = uri.substring(ctx.length()); // ví dụ: /admin/users

        // ── 2. /admin/* → phân quyền chi tiết ─────────────────────────────
        if (path.startsWith("/admin/")) {
            // Các path CHỈ Admin (role 1) mới được vào:
            // - /admin/users    : quản lý tài khoản hệ thống
            // - /admin/automation : tác vụ tự động hệ thống
            boolean isAdminOnlyPath = path.startsWith("/admin/users")
                    || path.startsWith("/admin/automation");

            if (isAdminOnlyPath) {
                if (roleId != ROLE_ADMIN) {
                    redirectToAppropriate(req, resp, roleId);
                    return;
                }
            } else {
                // Các path HR Manager (role 2) cũng được vào:
                // /admin/department, /admin/position, /admin/contract-type,
                // /admin/shifts, /admin/leave-types, /admin/reward-disciplines,
                // /admin/pending-request, v.v.
                if (roleId != ROLE_ADMIN && roleId != ROLE_HR_MANAGER) {
                    redirectToAppropriate(req, resp, roleId);
                    return;
                }
            }
        }

        // ── 3. /editRolePermission, /role/* → chỉ Admin ───────────────────
        if (path.equals("/editRolePermission") || path.startsWith("/role")) {
            if (roleId != ROLE_ADMIN) {
                redirectToAppropriate(req, resp, roleId);
                return;
            }
        }

        // ── 4. /hr/* → HR Manager (2) hoặc HR Staff (5) ───────────────────
        if (path.startsWith("/hr/")) {
            if (roleId != ROLE_HR_MANAGER && roleId != ROLE_HR_STAFF) {
                redirectToAppropriate(req, resp, roleId);
                return;
            }
        }

        // ── 4b. /manager/* → role 1-6 (quản lý), không cho Employee (7) ──
        if (path.startsWith("/manager/")) {
            if (roleId == ROLE_EMPLOYEE || roleId == 0) {
                redirectToAppropriate(req, resp, roleId);
                return;
            }
        }

        // ── 5. /dashboard → role 1-6 (management); role 7 → employee ──────
        if (path.equals("/dashboard")) {
            if (roleId == ROLE_EMPLOYEE || roleId == 0) {
                resp.sendRedirect(ctx + "/employee/dashboard");
                return;
            }
        }

        // ── 6. /employee/* → phải đăng nhập (mọi role đều xem được) ───────
        //    (Đã check currentUser != null ở bước 1, nên chỉ cho qua)

        // ── Tất cả điều kiện pass → tiếp tục chuỗi filter ─────────────────
        chain.doFilter(servletRequest, servletResponse);
    }

    /**
     * Redirect người dùng về trang phù hợp với role của họ
     * khi họ cố truy cập URL không được phép.
     */
    private void redirectToAppropriate(HttpServletRequest req,
                                       HttpServletResponse resp,
                                       int roleId) throws IOException {
        String ctx = req.getContextPath();
        if (roleId >= ROLE_ADMIN && roleId <= ROLE_DEPT_MGR) {
            // Role 1-6: vào management dashboard
            resp.sendRedirect(ctx + "/dashboard");
        } else {
            // Role 7 (Employee) hoặc không xác định
            resp.sendRedirect(ctx + "/employee/dashboard");
        }
    }

    @Override
    public void destroy() {
        // Không cần dọn dẹp
    }
}

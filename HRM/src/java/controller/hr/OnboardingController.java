package controller.hr;

import dao.DepartmentDAO;
import dao.OnboardingDAO;
import dao.PositionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OnboardingRequest;
import model.User;

import java.io.IOException;
import java.sql.Date;

/**
 * Controller phía HR Staff cho luồng Onboarding
 * URL pattern: /hr/onboarding/*
 *
 * GET /hr/onboarding/new  → Form tạo mới
 * GET /hr/onboarding/edit?id=X → Form chỉnh sửa
 * GET /hr/onboarding/list → Danh sách yêu cầu
 * POST /hr/onboarding/save → Lưu (DRAFT hoặc PENDING)
 */
@WebServlet("/hr/onboarding/*")
public class OnboardingController extends HttpServlet {

    private final OnboardingDAO onbDAO = new OnboardingDAO();
    private final DepartmentDAO deptDAO = new DepartmentDAO();
    private final PositionDAO posDAO = new PositionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req, resp);
        if (currentUser == null) return;

        String path = getPath(req);

        switch (path) {
            case "/new":
                prepareForm(req, null);
                req.getRequestDispatcher("/hr/onboarding-form.jsp").forward(req, resp);
                break;

            case "/edit":
                int editId = parseId(req.getParameter("id"), 0);
                if (editId <= 0) {
                    resp.sendRedirect(req.getContextPath() + "/hr/onboarding/list");
                    return;
                }
                OnboardingRequest existing = onbDAO.getById(editId);
                if (existing == null || existing.getCreatedBy() != currentUser.getUserId()
                        || (!existing.getStatus().equals("DRAFT") && !existing.getStatus().equals("REJECTED"))) {
                    resp.sendRedirect(req.getContextPath() + "/hr/onboarding/list?error=forbidden");
                    return;
                }
                prepareForm(req, existing);
                req.getRequestDispatcher("/hr/onboarding-form.jsp").forward(req, resp);
                break;

            case "/list":
            default:
                req.setAttribute("requests", onbDAO.getByCreator(currentUser.getUserId()));
                req.setAttribute("departments", deptDAO.getAll());
                req.getRequestDispatcher("/hr/onboarding-list.jsp").forward(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req, resp);
        if (currentUser == null) return;

        String path = getPath(req);

        if ("/save".equals(path)) {
            boolean isDraft = "DRAFT".equals(req.getParameter("action"));
            OnboardingRequest r = buildFromRequest(req, currentUser.getUserId(), isDraft);

            String validErr = validateForm(r);
            if (validErr != null) {
                prepareForm(req, r);
                req.setAttribute("error", validErr);
                req.getRequestDispatcher("/hr/onboarding-form.jsp").forward(req, resp);
                return;
            }

            String dupErr = onbDAO.checkDuplicate(r.getCccdNumber(), r.getEmail(), r.getId());
            if (dupErr != null) {
                prepareForm(req, r);
                req.setAttribute("error", dupErr);
                req.getRequestDispatcher("/hr/onboarding-form.jsp").forward(req, resp);
                return;
            }

            boolean ok;
            if (r.getId() > 0) {
                ok = onbDAO.update(r);
            } else {
                int newId = onbDAO.create(r);
                if (newId > 0) {
                    r.setId(newId);
                    ok = true;
                } else {
                    ok = false;
                }
            }

            if (ok) {
                if (!isDraft) {
                    // Gửi thông báo cho toàn bộ Admin (role_id = 1)
                    dao.UserDAO userDAO = new dao.UserDAO();
                    dao.notificationDAO notifDAO = new dao.notificationDAO();
                    java.util.List<model.User> allUsers = userDAO.getAllUsers();
                    for (model.User admin : allUsers) {
                        if (admin.getRoleId() == 1) {
                            notifDAO.create(admin.getUserId(), "system", "Yêu cầu tuyển dụng mới", 
                                "HR " + currentUser.getFullName() + " vừa gửi yêu cầu tạo tài khoản cho ứng viên " + r.getFullName() + ".", 
                                "/admin/onboarding/detail?id=" + r.getId());
                        }
                    }
                }
                String msg = isDraft ? "Đã lưu bản nháp thành công!" : "Đã gửi yêu cầu lên Admin!";
                resp.sendRedirect(
                        req.getContextPath() + "/hr/onboarding/list?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
            } else {
                prepareForm(req, r);
                req.setAttribute("error", "Lỗi khi lưu dữ liệu, vui lòng thử lại.");
                req.getRequestDispatcher("/hr/onboarding-form.jsp").forward(req, resp);
            }
        }
    }

    // ─── Helpers ────────────────────────────────────────────────────

    private void prepareForm(HttpServletRequest req, OnboardingRequest existing) {
        req.setAttribute("formData", existing);
        req.setAttribute("departments", deptDAO.getAll());
        req.setAttribute("positions", posDAO.getAll());
    }

    private OnboardingRequest buildFromRequest(HttpServletRequest req, int createdBy, boolean isDraft) {
        OnboardingRequest r = new OnboardingRequest();

        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            try { r.setId(Integer.parseInt(idStr.trim())); } catch (NumberFormatException ignored) {}
        }

        r.setFullName(trimOrNull(req.getParameter("fullName")));
        r.setEmail(trimOrNull(req.getParameter("email")));
        r.setPhone(trimOrNull(req.getParameter("phone")));
        r.setCccdNumber(trimOrNull(req.getParameter("cccdNumber")));
        r.setAddress(trimOrNull(req.getParameter("address")));
        r.setCreatedBy(createdBy);
        r.setStatus(isDraft ? "DRAFT" : "PENDING");

        String dobStr = req.getParameter("dateOfBirth");
        if (dobStr != null && !dobStr.trim().isEmpty()) {
            try { r.setDateOfBirth(Date.valueOf(dobStr.trim())); } catch (IllegalArgumentException ignored) {}
        }

        String genderStr = req.getParameter("gender");
        if (genderStr != null && !genderStr.isEmpty()) {
            try { r.setGender(Integer.parseInt(genderStr)); } catch (NumberFormatException ignored) {}
        }

        String deptStr = req.getParameter("departmentId");
        if (deptStr != null && !deptStr.isEmpty()) {
            try { r.setDepartmentId(Integer.parseInt(deptStr)); } catch (NumberFormatException ignored) {}
        }

        String posStr = req.getParameter("positionId");
        if (posStr != null && !posStr.isEmpty()) {
            try { r.setPositionId(Integer.parseInt(posStr)); } catch (NumberFormatException ignored) {}
        }

        return r;
    }

    private String validateForm(OnboardingRequest r) {
        if (r.getFullName() == null || r.getFullName().isEmpty()) return "Họ và tên không được để trống";
        if (r.getEmail() == null || r.getEmail().isEmpty()) return "Email không được để trống";
        if (!r.getEmail().contains("@")) return "Email không đúng định dạng";
        return null;
    }

    private User getCurrentUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return null;
        }
        return user;
    }

    private String getPath(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p != null) ? p : "/list";
    }

    private int parseId(String s, int def) {
        if (s == null || s.trim().isEmpty()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}

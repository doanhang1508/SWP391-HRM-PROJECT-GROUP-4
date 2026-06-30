package controller.hr;

import dao.KpiDAO;
import dao.DepartmentDAO;
import model.KpiTemplate;
import model.KpiTemplateItem;
import model.User;
import model.Department;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "HrKpiTemplateController", urlPatterns = {"/hr/kpi-templates", "/hr/kpi-template-edit", "/hr/kpi-templates/edit"})
public class HrKpiTemplateController extends HttpServlet {

    private final KpiDAO kpiDAO = new KpiDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();

        if ("/hr/kpi-templates".equals(path)) {
            // Fetch all departments for filter & select dropdowns
            List<Department> departments = departmentDAO.getAll();
            request.setAttribute("departments", departments);

            // Filter templates by department if specified
            String deptIdStr = request.getParameter("deptId");
            List<KpiTemplate> list;
            if (deptIdStr != null && !deptIdStr.isEmpty()) {
                if ("null".equals(deptIdStr) || "all_depts".equals(deptIdStr)) {
                    List<KpiTemplate> all = kpiDAO.getAllTemplates();
                    list = new ArrayList<>();
                    for (KpiTemplate t : all) {
                        if (t.getDepartmentId() == null) {
                            list.add(t);
                        }
                    }
                } else {
                    try {
                        int deptId = Integer.parseInt(deptIdStr);
                        List<KpiTemplate> all = kpiDAO.getAllTemplates();
                        list = new ArrayList<>();
                        for (KpiTemplate t : all) {
                            if (t.getDepartmentId() != null && t.getDepartmentId() == deptId) {
                                list.add(t);
                            }
                        }
                    } catch (NumberFormatException e) {
                        list = kpiDAO.getAllTemplates();
                    }
                }
            } else {
                list = kpiDAO.getAllTemplates();
            }

            request.setAttribute("templateList", list);
            request.setAttribute("templates", list);
            request.getRequestDispatcher("/hr/kpi-templates.jsp").forward(request, response);
        } else if ("/hr/kpi-template-edit".equals(path) || "/hr/kpi-templates/edit".equals(path)) {
            // Create or edit a template
            String idStr = request.getParameter("id");
            KpiTemplate template = null;
            List<KpiTemplateItem> items = new ArrayList<>();

            if (idStr != null && !idStr.isEmpty()) {
                int templateId = Integer.parseInt(idStr);
                template = kpiDAO.getTemplateById(templateId);
                if (template != null) {
                    items = kpiDAO.getTemplateItems(templateId);
                }
            }

            List<Department> departments = departmentDAO.getAll();
            request.setAttribute("departments", departments);
            request.setAttribute("template", template);
            request.setAttribute("items", items);
            request.getRequestDispatcher("/hr/kpi-template-edit.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();
        String action = request.getParameter("action");

        if ("/hr/kpi-templates".equals(path)) {
            if ("create".equals(action)) {
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String statusStr = request.getParameter("status");
                int status = "1".equals(statusStr) ? 1 : 0;
                String deptIdStr = request.getParameter("departmentId");
                Integer departmentId = (deptIdStr == null || deptIdStr.trim().isEmpty() || "all".equals(deptIdStr)) ? null : Integer.parseInt(deptIdStr);

                KpiTemplate template = new KpiTemplate(0, name, description, status, new Timestamp(System.currentTimeMillis()), user.getUserId());
                template.setDepartmentId(departmentId);
                int templateId = kpiDAO.insertTemplate(template);
                if (templateId > 0) {
                    response.sendRedirect(request.getContextPath() + "/hr/kpi-templates/edit?id=" + templateId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/hr/kpi-templates?error=1");
                }
            } else if ("toggleStatus".equals(action)) {
                String idStr = request.getParameter("id");
                if (idStr != null && !idStr.isEmpty()) {
                    int templateId = Integer.parseInt(idStr);
                    KpiTemplate template = kpiDAO.getTemplateById(templateId);
                    if (template != null) {
                        template.setStatus(template.getStatus() == 1 ? 0 : 1);
                        kpiDAO.updateTemplate(template);
                        response.sendRedirect(request.getContextPath() + "/hr/kpi-templates?success=1");
                        return;
                    }
                }
                response.sendRedirect(request.getContextPath() + "/hr/kpi-templates?error=1");
            }
        } else if ("/hr/kpi-template-edit".equals(path) || "/hr/kpi-templates/edit".equals(path)) {
            if ("addItem".equals(action)) {
                String idStr = request.getParameter("id");
                String itemName = request.getParameter("name");
                String itemDesc = request.getParameter("description");
                String itemWeightStr = request.getParameter("weight");

                if (idStr != null && !idStr.isEmpty() && itemName != null && !itemName.trim().isEmpty() && itemWeightStr != null) {
                    int templateId = Integer.parseInt(idStr);
                    try {
                        double weight = Double.parseDouble(itemWeightStr);

                        List<KpiTemplateItem> items = kpiDAO.getTemplateItems(templateId);
                        double totalWeight = 0;
                        for (KpiTemplateItem item : items) {
                            totalWeight += item.getWeight();
                        }

                        if (totalWeight + weight > 100.0) {
                            response.sendRedirect(request.getContextPath() + "/hr/kpi-templates/edit?id=" + templateId + "&error=weight_overflow");
                        } else {
                            KpiTemplateItem newItem = new KpiTemplateItem(0, templateId, itemName.trim(), itemDesc != null ? itemDesc.trim() : "", weight);
                            kpiDAO.insertTemplateItem(newItem);
                            response.sendRedirect(request.getContextPath() + "/hr/kpi-templates/edit?id=" + templateId + "&success=item_added");
                        }
                        return;
                    } catch (NumberFormatException e) {
                        response.sendRedirect(request.getContextPath() + "/hr/kpi-templates/edit?id=" + idStr + "&error=invalid_weight");
                        return;
                    }
                }
                response.sendRedirect(request.getContextPath() + "/hr/kpi-templates?error=1");
            } else if ("deleteItem".equals(action)) {
                String idStr = request.getParameter("id");
                String itemIdStr = request.getParameter("itemId");
                if (idStr != null && !idStr.isEmpty() && itemIdStr != null && !itemIdStr.isEmpty()) {
                    int templateId = Integer.parseInt(idStr);
                    int itemId = Integer.parseInt(itemIdStr);
                    kpiDAO.deleteTemplateItem(itemId);
                    response.sendRedirect(request.getContextPath() + "/hr/kpi-templates/edit?id=" + templateId + "&success=item_deleted");
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/hr/kpi-templates?error=1");
            } else if ("updateHeader".equals(action)) {
                String idStr = request.getParameter("id");
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String statusStr = request.getParameter("status");
                int status = "1".equals(statusStr) ? 1 : 0;
                String deptIdStr = request.getParameter("departmentId");
                Integer departmentId = (deptIdStr == null || deptIdStr.trim().isEmpty() || "all".equals(deptIdStr)) ? null : Integer.parseInt(deptIdStr);

                if (idStr != null && !idStr.isEmpty()) {
                    int templateId = Integer.parseInt(idStr);
                    KpiTemplate template = kpiDAO.getTemplateById(templateId);
                    if (template != null) {
                        template.setName(name);
                        template.setDescription(description);
                        template.setStatus(status);
                        template.setDepartmentId(departmentId);
                        kpiDAO.updateTemplate(template);
                        response.sendRedirect(request.getContextPath() + "/hr/kpi-templates/edit?id=" + templateId + "&success=header_updated");
                        return;
                    }
                }
                response.sendRedirect(request.getContextPath() + "/hr/kpi-templates?error=1");
            } else {
                // Bulk save / update template header
                String idStr = request.getParameter("id");
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String statusStr = request.getParameter("status");
                int status = "1".equals(statusStr) ? 1 : 0;
                String deptIdStr = request.getParameter("departmentId");
                Integer departmentId = (deptIdStr == null || deptIdStr.trim().isEmpty() || "all".equals(deptIdStr)) ? null : Integer.parseInt(deptIdStr);

                String[] criterionNames = request.getParameterValues("criterion_name");
                String[] criterionDescriptions = request.getParameterValues("criterion_desc");
                String[] criterionWeights = request.getParameterValues("criterion_weight");

                double totalWeight = 0;
                List<KpiTemplateItem> newItems = new ArrayList<>();

                if (criterionNames != null) {
                    for (int i = 0; i < criterionNames.length; i++) {
                        String cName = criterionNames[i].trim();
                        if (cName.isEmpty()) continue;

                        String cDesc = criterionDescriptions != null && criterionDescriptions.length > i ? criterionDescriptions[i].trim() : "";
                        double cWeight = 0;
                        if (criterionWeights != null && criterionWeights.length > i) {
                            try {
                                cWeight = Double.parseDouble(criterionWeights[i]);
                            } catch (NumberFormatException ignored) {}
                        }

                        totalWeight += cWeight;
                        KpiTemplateItem item = new KpiTemplateItem();
                        item.setCriterionName(cName);
                        item.setDescription(cDesc);
                        item.setWeight(cWeight);
                        newItems.add(item);
                    }
                }

                if (criterionNames != null && Math.abs(totalWeight - 100.0) > 0.001) {
                    request.setAttribute("error", "Tổng trọng số của các tiêu chí phải bằng đúng 100%. Hiện tại: " + totalWeight + "%");

                    KpiTemplate temp = new KpiTemplate();
                    if (idStr != null && !idStr.isEmpty()) {
                        temp.setTemplateId(Integer.parseInt(idStr));
                    }
                    temp.setName(name);
                    temp.setDescription(description);
                    temp.setStatus(status);
                    temp.setDepartmentId(departmentId);

                    List<Department> departments = departmentDAO.getAll();
                    request.setAttribute("departments", departments);
                    request.setAttribute("template", temp);
                    request.setAttribute("items", newItems);
                    request.getRequestDispatcher("/hr/kpi-template-edit.jsp").forward(request, response);
                    return;
                }

                int templateId = -1;
                if (idStr != null && !idStr.isEmpty()) {
                    templateId = Integer.parseInt(idStr);
                    KpiTemplate template = kpiDAO.getTemplateById(templateId);
                    if (template != null) {
                        template.setName(name);
                        template.setDescription(description);
                        template.setStatus(status);
                        template.setDepartmentId(departmentId);
                        kpiDAO.updateTemplate(template);
                    }
                } else {
                    KpiTemplate template = new KpiTemplate(0, name, description, status, new Timestamp(System.currentTimeMillis()), user.getUserId());
                    template.setDepartmentId(departmentId);
                    templateId = kpiDAO.insertTemplate(template);
                }

                if (templateId > 0) {
                    if (criterionNames != null) {
                        kpiDAO.deleteTemplateItems(templateId);
                        for (KpiTemplateItem item : newItems) {
                            item.setTemplateId(templateId);
                            kpiDAO.insertTemplateItem(item);
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/hr/kpi-templates?success=1");
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra khi lưu mẫu đánh giá.");
                    List<Department> departments = departmentDAO.getAll();
                    request.setAttribute("departments", departments);
                    request.getRequestDispatcher("/hr/kpi-template-edit.jsp").forward(request, response);
                }
            }
        }
    }
}

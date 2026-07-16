package dao;

import model.*;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KpiDAO {

    // ==========================================
    // 1. TEMPLATES & ITEMS
    // ==========================================

    public List<KpiTemplate> getAllTemplates() {
        List<KpiTemplate> list = new ArrayList<>();
        String sql = "SELECT t.*, d.department_name FROM kpi_templates t "
                   + "LEFT JOIN departments d ON t.department_id = d.department_id "
                   + "ORDER BY t.template_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapTemplate(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public KpiTemplate getTemplateById(int templateId) {
        String sql = "SELECT t.*, d.department_name FROM kpi_templates t "
                   + "LEFT JOIN departments d ON t.department_id = d.department_id "
                   + "WHERE t.template_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, templateId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapTemplate(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<KpiTemplateItem> getTemplateItems(int templateId) {
        List<KpiTemplateItem> list = new ArrayList<>();
        String sql = "SELECT * FROM kpi_template_items WHERE template_id = ? ORDER BY item_id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, templateId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTemplateItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int insertTemplate(KpiTemplate template) {
        String sql = "INSERT INTO kpi_templates (name, description, status, created_by, department_id) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, template.getName());
            ps.setString(2, template.getDescription());
            ps.setInt(3, template.getStatus());
            ps.setInt(4, template.getCreatedBy());
            if (template.getDepartmentId() != null) {
                ps.setInt(5, template.getDepartmentId());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void updateTemplate(KpiTemplate template) {
        String sql = "UPDATE kpi_templates SET name = ?, description = ?, status = ?, department_id = ? WHERE template_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, template.getName());
            ps.setString(2, template.getDescription());
            ps.setInt(3, template.getStatus());
            if (template.getDepartmentId() != null) {
                ps.setInt(4, template.getDepartmentId());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setInt(5, template.getTemplateId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void deleteTemplateItems(int templateId) {
        String sql = "DELETE FROM kpi_template_items WHERE template_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, templateId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void deleteTemplateItem(int itemId) {
        String sql = "DELETE FROM kpi_template_items WHERE item_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    public void insertTemplateItem(KpiTemplateItem item) {
        String sql = "INSERT INTO kpi_template_items (template_id, criterion_name, description, weight) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getTemplateId());
            ps.setString(2, item.getCriterionName());
            ps.setString(3, item.getDescription());
            ps.setDouble(4, item.getWeight());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ==========================================
    // 2. CYCLES
    // ==========================================

    public List<KpiCycle> getAllCycles() {
        List<KpiCycle> list = new ArrayList<>();
        String sql = "SELECT c.*, t.name AS template_name, d.department_name AS template_department_name FROM kpi_cycles c "
                   + "LEFT JOIN kpi_templates t ON c.template_id = t.template_id "
                   + "LEFT JOIN departments d ON t.department_id = d.department_id "
                   + "ORDER BY c.cycle_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCycleWithTemplate(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<KpiCycle> getActiveCycles() {
        List<KpiCycle> list = new ArrayList<>();
        String sql = "SELECT c.*, t.name AS template_name, d.department_name AS template_department_name FROM kpi_cycles c "
                   + "LEFT JOIN kpi_templates t ON c.template_id = t.template_id "
                   + "LEFT JOIN departments d ON t.department_id = d.department_id "
                   + "WHERE c.status = 'ACTIVE' ORDER BY c.cycle_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCycleWithTemplate(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public KpiCycle getCycleById(int cycleId) {
        String sql = "SELECT c.*, t.name AS template_name, d.department_name AS template_department_name FROM kpi_cycles c "
                   + "LEFT JOIN kpi_templates t ON c.template_id = t.template_id "
                   + "LEFT JOIN departments d ON t.department_id = d.department_id "
                   + "WHERE c.cycle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cycleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCycleWithTemplate(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int insertCycle(KpiCycle cycle) {
        String sql = "INSERT INTO kpi_cycles (name, start_date, end_date, deadline, template_id, status, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, cycle.getName());
            ps.setDate(2, cycle.getStartDate());
            ps.setDate(3, cycle.getEndDate());
            ps.setDate(4, cycle.getDeadline());
            ps.setInt(5, cycle.getTemplateId());
            ps.setString(6, cycle.getStatus());
            ps.setInt(7, cycle.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean updateCycle(KpiCycle cycle) {
        String sql = "UPDATE kpi_cycles SET name = ?, start_date = ?, end_date = ?, deadline = ?, template_id = ?, status = ? WHERE cycle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cycle.getName());
            ps.setDate(2, cycle.getStartDate());
            ps.setDate(3, cycle.getEndDate());
            ps.setDate(4, cycle.getDeadline());
            ps.setInt(5, cycle.getTemplateId());
            ps.setString(6, cycle.getStatus());
            ps.setInt(7, cycle.getCycleId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCycleStatus(int cycleId, String status) {
        String sql = "UPDATE kpi_cycles SET status = ? WHERE cycle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, cycleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isCycleLocked(int cycleId) {
        String sql = "SELECT status FROM kpi_cycles WHERE cycle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cycleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    return "LOCKED".equalsIgnoreCase(status) || "CLOSED".equalsIgnoreCase(status);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isCycleLockedByEvaluationId(int evaluationId) {
        String sql = "SELECT c.status FROM kpi_evaluations e " +
                     "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
                     "WHERE e.evaluation_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, evaluationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    return "LOCKED".equalsIgnoreCase(status) || "CLOSED".equalsIgnoreCase(status);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // 3. EVALUATIONS
    // ==========================================

    public KpiEvaluation getEvaluation(int cycleId, int employeeId) {
        String sql = "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
                     "m.full_name AS manager_name, c.name AS cycle_name, c.status AS cycle_status, d.department_name " +
                     "FROM kpi_evaluations e " +
                     "JOIN users u ON e.employee_id = u.user_id " +
                     "LEFT JOIN users m ON e.manager_id = m.user_id " +
                     "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE e.cycle_id = ? AND e.employee_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cycleId);
            ps.setInt(2, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEvaluationWithHelpers(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public KpiEvaluation getEvaluationById(int evaluationId) {
        String sql = "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
                     "m.full_name AS manager_name, c.name AS cycle_name, c.status AS cycle_status, d.department_name " +
                     "FROM kpi_evaluations e " +
                     "JOIN users u ON e.employee_id = u.user_id " +
                     "LEFT JOIN users m ON e.manager_id = m.user_id " +
                     "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE e.evaluation_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, evaluationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEvaluationWithHelpers(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<KpiEvaluation> getEvaluationsByCycleAndManager(int cycleId, int managerId) {
        List<KpiEvaluation> list = new ArrayList<>();
        // Match evaluations either by direct manager_id assignment,
        // OR by department (fallback when manager_id was not set during init).
        String sql = "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
                     "m.full_name AS manager_name, c.name AS cycle_name, c.status AS cycle_status, d.department_name " +
                     "FROM kpi_evaluations e " +
                     "JOIN users u ON e.employee_id = u.user_id " +
                     "LEFT JOIN users m ON e.manager_id = m.user_id " +
                     "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE e.cycle_id = ? " +
                     "  AND ( " +
                     "    e.manager_id = ? " +
                     "    OR ( " +
                     "      e.manager_id IS NULL " +
                     "      AND u.department_id = (SELECT department_id FROM users WHERE user_id = ? AND department_id IS NOT NULL) " +
                     "    ) " +
                     "  ) " +
                     "ORDER BY u.full_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cycleId);
            ps.setInt(2, managerId);
            ps.setInt(3, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvaluationWithHelpers(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<KpiEvaluation> getEvaluationsByCycle(int cycleId) {
        List<KpiEvaluation> list = new ArrayList<>();
        String sql = "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
                     "m.full_name AS manager_name, c.name AS cycle_name, c.status AS cycle_status, d.department_name " +
                     "FROM kpi_evaluations e " +
                     "JOIN users u ON e.employee_id = u.user_id " +
                     "LEFT JOIN users m ON e.manager_id = m.user_id " +
                     "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE e.cycle_id = ? " +
                     "ORDER BY d.department_name ASC, u.full_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cycleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvaluationWithHelpers(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<KpiEvaluation> getEvaluationsByEmployee(int employeeId) {
        List<KpiEvaluation> list = new ArrayList<>();
        String sql = "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
                     "m.full_name AS manager_name, c.name AS cycle_name, c.status AS cycle_status, d.department_name " +
                     "FROM kpi_evaluations e " +
                     "JOIN users u ON e.employee_id = u.user_id " +
                     "LEFT JOIN users m ON e.manager_id = m.user_id " +
                     "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE e.employee_id = ? AND e.status IN ('SUBMITTED', 'APPROVED') " +
                     "ORDER BY c.end_date DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvaluationWithHelpers(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int insertEvaluation(KpiEvaluation evaluation) {
        String sql = "INSERT INTO kpi_evaluations (cycle_id, employee_id, manager_id, score, weighted_score, status, comment, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, evaluation.getCycleId());
            ps.setInt(2, evaluation.getEmployeeId());
            ps.setInt(3, evaluation.getManagerId());
            ps.setDouble(4, evaluation.getScore());
            ps.setDouble(5, evaluation.getWeightedScore());
            ps.setString(6, evaluation.getStatus());
            ps.setString(7, evaluation.getComment());
            ps.setInt(8, evaluation.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean updateEvaluation(KpiEvaluation evaluation) {
        if (isCycleLockedByEvaluationId(evaluation.getEvaluationId())) {
            return false;
        }
        String sql = "UPDATE kpi_evaluations SET score = ?, weighted_score = ?, status = ?, comment = ?, updated_by = ? WHERE evaluation_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, evaluation.getScore());
            ps.setDouble(2, evaluation.getWeightedScore());
            ps.setString(3, evaluation.getStatus());
            ps.setString(4, evaluation.getComment());
            ps.setInt(5, evaluation.getUpdatedBy());
            ps.setInt(6, evaluation.getEvaluationId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateEvaluationStatus(int evaluationId, String status, int userId, String note) {
        if (isCycleLockedByEvaluationId(evaluationId)) {
            return false;
        }
        KpiEvaluation oldEval = getEvaluationById(evaluationId);
        if (oldEval == null) return false;

        String oldStatus = oldEval.getStatus();
        
        String sql = "UPDATE kpi_evaluations SET status = ?, updated_by = ? ";
        if ("SUBMITTED".equals(status)) {
            sql += ", submitted_at = NOW() ";
        } else if ("APPROVED".equals(status)) {
            sql += ", approved_at = NOW(), locked_at = NOW() ";
        }
        sql += "WHERE evaluation_id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            ps.setInt(3, evaluationId);
            boolean success = ps.executeUpdate() > 0;

            if (success) {
                // Record status history
                KpiStatusHistory history = new KpiStatusHistory(0, evaluationId, oldStatus, status, userId, null, note);
                insertStatusHistory(history);
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // 4. EVALUATION ITEMS
    // ==========================================

    public List<KpiEvaluationItem> getEvaluationItems(int evaluationId) {
        List<KpiEvaluationItem> list = new ArrayList<>();
        String sql = "SELECT ei.*, ti.criterion_name, ti.description AS criterion_description, ti.weight " +
                     "FROM kpi_evaluation_items ei " +
                     "JOIN kpi_template_items ti ON ei.template_item_id = ti.item_id " +
                     "WHERE ei.evaluation_id = ? ORDER BY ti.item_id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, evaluationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvaluationItemWithHelpers(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Saves or updates evaluations and its items. This is used for Autosave or Submit.
     * Automatically recalculates the raw score (average) and weighted score.
     */
    public boolean saveOrUpdateEvaluationItems(int evaluationId, List<KpiEvaluationItem> items, int updatedBy) {
        if (isCycleLockedByEvaluationId(evaluationId)) {
            return false;
        }
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // First, fetch existing items to build audit log if anything changes
            List<KpiEvaluationItem> existingItems = new ArrayList<>();
            String fetchSql = "SELECT * FROM kpi_evaluation_items WHERE evaluation_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(fetchSql)) {
                ps.setInt(1, evaluationId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        existingItems.add(new KpiEvaluationItem(
                            rs.getInt("evaluation_item_id"),
                            rs.getInt("evaluation_id"),
                            rs.getInt("template_item_id"),
                            rs.getDouble("score"),
                            rs.getString("comment")
                        ));
                    }
                }
            }

            double totalWeightedPoints = 0.0;
            double totalWeight = 0.0;
            double totalScorePoints = 0.0;
            int scoreCount = 0;

            String upsertSql = "INSERT INTO kpi_evaluation_items (evaluation_id, template_item_id, score, comment) " +
                               "VALUES (?, ?, ?, ?) " +
                               "ON DUPLICATE KEY UPDATE score = VALUES(score), comment = VALUES(comment)";
            // Note: Since we don't have a unique constraint on (evaluation_id, template_item_id),
            // let's verify if one exists, or check if we should do manual check (select-update-insert).
            // A simple DELETE + INSERT is standard and much simpler/safer for transactions! Let's delete and re-insert.
            
            String deleteSql = "DELETE FROM kpi_evaluation_items WHERE evaluation_id = ?";
            try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                psDel.setInt(1, evaluationId);
                psDel.executeUpdate();
            }

            String insertSql = "INSERT INTO kpi_evaluation_items (evaluation_id, template_item_id, score, comment) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                for (KpiEvaluationItem item : items) {
                    // Fetch template item weight for calculation
                    double weight = 0.0;
                    String wSql = "SELECT weight FROM kpi_template_items WHERE item_id = ?";
                    try (PreparedStatement psW = conn.prepareStatement(wSql)) {
                        psW.setInt(1, item.getTemplateItemId());
                        try (ResultSet rsW = psW.executeQuery()) {
                            if (rsW.next()) {
                                weight = rsW.getDouble("weight");
                            }
                        }
                    }

                    psIns.setInt(1, evaluationId);
                    psIns.setInt(2, item.getTemplateItemId());
                    psIns.setDouble(3, item.getScore());
                    psIns.setString(4, item.getComment());
                    psIns.addBatch();

                    totalWeightedPoints += item.getScore() * weight;
                    totalWeight += weight;
                    totalScorePoints += item.getScore();
                    scoreCount++;

                    // Check if score changed vs existing to log audit
                    KpiEvaluationItem match = existingItems.stream()
                        .filter(x -> x.getTemplateItemId() == item.getTemplateItemId())
                        .findFirst().orElse(null);
                    if (match != null && (match.getScore() != item.getScore() || !java.util.Objects.equals(match.getComment(), item.getComment()))) {
                        // Score changed - logged via status history only
                    }
                }
                psIns.executeBatch();
            }

            // Calculate final scores
            double finalScore = scoreCount > 0 ? (totalScorePoints / scoreCount) : 0.0;
            double finalWeightedScore = totalWeight > 0 ? (totalWeightedPoints / totalWeight) : finalScore;

            // Round to 2 decimal places
            finalScore = Math.round(finalScore * 100.0) / 100.0;
            finalWeightedScore = Math.round(finalWeightedScore * 100.0) / 100.0;

            // Update evaluation scores
            String updateEvalSql = "UPDATE kpi_evaluations SET score = ?, weighted_score = ?, updated_by = ? WHERE evaluation_id = ?";
            try (PreparedStatement psU = conn.prepareStatement(updateEvalSql)) {
                psU.setDouble(1, finalScore);
                psU.setDouble(2, finalWeightedScore);
                psU.setInt(3, updatedBy);
                psU.setInt(4, evaluationId);
                psU.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    // ==========================================
    // 5. COMMENTS
    // ==========================================

    public List<KpiComment> getComments(int evaluationId) {
        List<KpiComment> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name AS user_name FROM kpi_comments c " +
                     "JOIN users u ON c.user_id = u.user_id " +
                     "WHERE c.evaluation_id = ? ORDER BY c.created_at ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, evaluationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapComment(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertComment(KpiComment comment) {
        if (isCycleLockedByEvaluationId(comment.getEvaluationId())) {
            return false;
        }
        String sql = "INSERT INTO kpi_comments (evaluation_id, user_id, comment_text, type) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, comment.getEvaluationId());
            ps.setInt(2, comment.getUserId());
            ps.setString(3, comment.getCommentText());
            ps.setString(4, comment.getType());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // 6. HISTORY
    // ==========================================

    public List<KpiStatusHistory> getStatusHistory(int evaluationId) {
        List<KpiStatusHistory> list = new ArrayList<>();
        String sql = "SELECT sh.*, u.full_name AS changed_by_name FROM kpi_status_history sh " +
                     "JOIN users u ON sh.changed_by = u.user_id " +
                     "WHERE sh.evaluation_id = ? ORDER BY sh.changed_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, evaluationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapStatusHistory(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    public void insertStatusHistory(KpiStatusHistory history) {
        String sql = "INSERT INTO kpi_status_history (evaluation_id, from_status, to_status, changed_by, note) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, history.getEvaluationId());
            ps.setString(2, history.getFromStatus());
            ps.setString(3, history.getToStatus());
            ps.setInt(4, history.getChangedBy());
            ps.setString(5, history.getNote());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ==========================================
    // MAPPER FUNCTIONS
    // ==========================================

    private KpiTemplate mapTemplate(ResultSet rs) throws SQLException {
        KpiTemplate t = new KpiTemplate(
            rs.getInt("template_id"),
            rs.getString("name"),
            rs.getString("description"),
            rs.getInt("status"),
            rs.getTimestamp("created_at"),
            rs.getInt("created_by")
        );
        int deptId = rs.getInt("department_id");
        if (rs.wasNull()) {
            t.setDepartmentId(null);
        } else {
            t.setDepartmentId(deptId);
        }
        try {
            t.setDepartmentName(rs.getString("department_name"));
        } catch (SQLException ignored) {}
        return t;
    }

    private KpiTemplateItem mapTemplateItem(ResultSet rs) throws SQLException {
        return new KpiTemplateItem(
            rs.getInt("item_id"),
            rs.getInt("template_id"),
            rs.getString("criterion_name"),
            rs.getString("description"),
            rs.getDouble("weight")
        );
    }

    private KpiCycle mapCycle(ResultSet rs) throws SQLException {
        return new KpiCycle(
            rs.getInt("cycle_id"),
            rs.getString("name"),
            rs.getDate("start_date"),
            rs.getDate("end_date"),
            rs.getDate("deadline"),
            rs.getInt("template_id"),
            rs.getString("status"),
            rs.getTimestamp("created_at"),
            rs.getInt("created_by"),
            rs.getTimestamp("updated_at")
        );
    }

    private KpiCycle mapCycleWithTemplate(ResultSet rs) throws SQLException {
        KpiCycle cycle = mapCycle(rs);
        try {
            cycle.setTemplateName(rs.getString("template_name"));
        } catch (SQLException ignored) {}
        try {
            cycle.setTemplateDepartmentName(rs.getString("template_department_name"));
        } catch (SQLException ignored) {}
        return cycle;
    }

    private KpiEvaluation mapEvaluationWithHelpers(ResultSet rs) throws SQLException {
        KpiEvaluation e = new KpiEvaluation(
            rs.getInt("evaluation_id"),
            rs.getInt("cycle_id"),
            rs.getInt("employee_id"),
            rs.getInt("manager_id"),
            rs.getDouble("score"),
            rs.getDouble("weighted_score"),
            rs.getString("status"),
            rs.getString("comment"),
            rs.getTimestamp("submitted_at"),
            rs.getTimestamp("approved_at"),
            rs.getTimestamp("locked_at"),
            rs.getTimestamp("created_at"),
            rs.getTimestamp("updated_at"),
            rs.getInt("created_by"),
            rs.getInt("updated_by")
        );
        e.setEmployeeName(rs.getString("employee_name"));
        e.setEmployeeCode(rs.getString("employee_code"));
        e.setManagerName(rs.getString("manager_name"));
        e.setCycleName(rs.getString("cycle_name"));
        try {
            e.setCycleStatus(rs.getString("cycle_status"));
        } catch (SQLException ignored) {}
        e.setDepartmentName(rs.getString("department_name"));
        return e;
    }

    private KpiEvaluationItem mapEvaluationItemWithHelpers(ResultSet rs) throws SQLException {
        KpiEvaluationItem item = new KpiEvaluationItem(
            rs.getInt("evaluation_item_id"),
            rs.getInt("evaluation_id"),
            rs.getInt("template_item_id"),
            rs.getDouble("score"),
            rs.getString("comment")
        );
        item.setCriterionName(rs.getString("criterion_name"));
        item.setCriterionDescription(rs.getString("criterion_description"));
        item.setWeight(rs.getDouble("weight"));
        return item;
    }

    private KpiComment mapComment(ResultSet rs) throws SQLException {
        KpiComment c = new KpiComment(
            rs.getInt("comment_id"),
            rs.getInt("evaluation_id"),
            rs.getInt("user_id"),
            rs.getString("comment_text"),
            rs.getString("type"),
            rs.getTimestamp("created_at")
        );
        c.setUserName(rs.getString("user_name"));
        return c;
    }

    private KpiStatusHistory mapStatusHistory(ResultSet rs) throws SQLException {
        KpiStatusHistory sh = new KpiStatusHistory(
            rs.getInt("history_id"),
            rs.getInt("evaluation_id"),
            rs.getString("from_status"),
            rs.getString("to_status"),
            rs.getInt("changed_by"),
            rs.getTimestamp("changed_at"),
            rs.getString("note")
        );
        sh.setChangedByName(rs.getString("changed_by_name"));
        return sh;
    }


    /**
     * Checks whether a user (manager) is authorized to view/edit a specific evaluation.
     * Returns true if:
     *   - The user's role is Admin (1), HR Manager (2), or Director (4) — they can access all evaluations.
     *   - The user is the assigned manager_id on the evaluation.
     *   - The user is a department head (role 3 or 6) in the same department as the employee.
     */
    public boolean isManagerAuthorizedForEvaluation(int userId, int userRoleId, int evaluationId) {
        // Admin, HR Manager, Director can access all evaluations
        if (userRoleId == 1 || userRoleId == 2 || userRoleId == 4) {
            return true;
        }

        String sql = "SELECT e.manager_id, u.department_id AS emp_dept_id " +
                     "FROM kpi_evaluations e " +
                     "JOIN users u ON e.employee_id = u.user_id " +
                     "WHERE e.evaluation_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, evaluationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int managerId = rs.getInt("manager_id");
                    int empDeptId = rs.getInt("emp_dept_id");

                    // Direct assignment check
                    if (managerId == userId) {
                        return true;
                    }

                    // Same-department fallback for department heads
                    if (userRoleId == 3 || userRoleId == 5 || userRoleId == 6) {
                        String deptSql = "SELECT department_id FROM users WHERE user_id = ?";
                        try (PreparedStatement ps2 = conn.prepareStatement(deptSql)) {
                            ps2.setInt(1, userId);
                            try (ResultSet rs2 = ps2.executeQuery()) {
                                if (rs2.next()) {
                                    int mgrDeptId = rs2.getInt("department_id");
                                    if (mgrDeptId > 0 && mgrDeptId == empDeptId) {
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<KpiTemplateItem> getTemplateItemsForEmployee(int employeeDepartmentId, int defaultTemplateId) {
        if (employeeDepartmentId > 0) {
            String sql = "SELECT template_id FROM kpi_templates "
                       + "WHERE department_id = ? AND status = 1 "
                       + "ORDER BY template_id DESC LIMIT 1";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, employeeDepartmentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int deptTemplateId = rs.getInt("template_id");
                        List<KpiTemplateItem> items = getTemplateItems(deptTemplateId);
                        if (!items.isEmpty()) {
                            return items;
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return getTemplateItems(defaultTemplateId);
    }

    /**
     * Initializes evaluations and default evaluation items for a given cycle.
     * If the cycle's template is department-specific (has department_id),
     * only employees from that department will receive evaluations.
     * If the template is general (department_id = NULL), all active employees are included.
     * Each employee is processed independently so one failure does not block the others.
     */
    public boolean initializeEvaluationsForCycle(int cycleId) {
        KpiCycle cycle = getCycleById(cycleId);
        if (cycle == null) return false;

        List<KpiTemplateItem> defaultTemplateItems = getTemplateItems(cycle.getTemplateId());
        if (defaultTemplateItems.isEmpty()) return false;

        // Check if the template is department-specific
        KpiTemplate template = getTemplateById(cycle.getTemplateId());
        Integer templateDeptId = (template != null) ? template.getDepartmentId() : null;

        // Load employees: filter by department if template is department-specific
        List<User> employees = new ArrayList<>();
        String empSql;
        if (templateDeptId != null) {
            empSql = "SELECT user_id, department_id, role_id FROM users WHERE status = 1 AND role_id != 1 AND department_id = ?";
        } else {
            empSql = "SELECT user_id, department_id, role_id FROM users WHERE status = 1 AND role_id != 1";
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(empSql)) {
            if (templateDeptId != null) {
                ps.setInt(1, templateDeptId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setDepartmentId(rs.getInt("department_id"));
                    u.setRoleId(rs.getInt("role_id"));
                    employees.add(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        // Find Director's ID (manager for Managers/Factory Managers)
        int directorId = 0;
        String dirSql = "SELECT user_id FROM users WHERE role_id = 4 AND status = 1 LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(dirSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                directorId = rs.getInt("user_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        int successCount = 0;
        for (User emp : employees) {
            // Skip if evaluation already exists for this employee in this cycle
            String checkSql = "SELECT evaluation_id FROM kpi_evaluations WHERE cycle_id = ? AND employee_id = ?";
            boolean exists = false;
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, cycleId);
                ps.setInt(2, emp.getUserId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) exists = true;
                }
            } catch (SQLException e) {
                e.printStackTrace();
                continue;
            }
            if (exists) {
                successCount++;
                continue;
            }

            // Determine manager for this employee
            int managerId = 0;
            if (emp.getRoleId() == 3 || emp.getRoleId() == 6) {
                // Managers and Factory Managers are managed by the Director
                managerId = directorId;
            } else {
                // Find a Manager or Department Manager in the same department
                String mgrSql = "SELECT user_id FROM users WHERE department_id = ? AND role_id IN (3, 6) AND status = 1 LIMIT 1";
                try (Connection conn = DBContext.getConnection();
                     PreparedStatement ps = conn.prepareStatement(mgrSql)) {
                    ps.setInt(1, emp.getDepartmentId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            managerId = rs.getInt("user_id");
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                // Fallback: if no manager found in dept, assign to HR Manager (role 2) or HR Staff (role 5)
                if (managerId == 0) {
                    String fallbackSql = "SELECT user_id FROM users WHERE role_id IN (2, 5) AND status = 1 LIMIT 1";
                    try (Connection conn = DBContext.getConnection();
                         PreparedStatement ps = conn.prepareStatement(fallbackSql);
                         ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            managerId = rs.getInt("user_id");
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }

            // Insert evaluation for this employee (each in its own connection/transaction)
            int evalId = -1;
            String insertEvalSql = "INSERT INTO kpi_evaluations (cycle_id, employee_id, manager_id, status, created_by) VALUES (?, ?, ?, 'DRAFT', ?)";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(insertEvalSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, cycleId);
                ps.setInt(2, emp.getUserId());
                if (managerId > 0) {
                    ps.setInt(3, managerId);
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setInt(4, cycle.getCreatedBy());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) evalId = rs.getInt(1);
                }
            } catch (SQLException e) {
                // Duplicate key or other error for this employee: skip silently
                e.printStackTrace();
                continue;
            }

            // Insert default evaluation items for each template criterion
            if (evalId > 0) {
                List<KpiTemplateItem> templateItems = getTemplateItemsForEmployee(emp.getDepartmentId(), cycle.getTemplateId());
                if (templateItems.isEmpty()) {
                    templateItems = defaultTemplateItems;
                }
                String insertItemSql = "INSERT INTO kpi_evaluation_items (evaluation_id, template_item_id, score, comment) VALUES (?, ?, 0.0, '')";
                try (Connection conn = DBContext.getConnection();
                     PreparedStatement ps = conn.prepareStatement(insertItemSql)) {
                    for (KpiTemplateItem item : templateItems) {
                        ps.setInt(1, evalId);
                        ps.setInt(2, item.getItemId());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                    successCount++;
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        return successCount > 0;
    }

    public List<KpiEvaluation> getEvaluationsHistory(Integer month, Integer year, Integer departmentId, Integer managerId, boolean viewAllCompany) {
        List<KpiEvaluation> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
            "m.full_name AS manager_name, c.name AS cycle_name, d.department_name " +
            "FROM kpi_evaluations e " +
            "JOIN users u ON e.employee_id = u.user_id " +
            "LEFT JOIN users m ON e.manager_id = m.user_id " +
            "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
            "LEFT JOIN departments d ON u.department_id = d.department_id " +
            "WHERE e.status IN ('SUBMITTED', 'APPROVED') "
        );

        List<Object> params = new ArrayList<>();

        if (month != null && month > 0) {
            sql.append("AND (MONTH(c.start_date) = ? OR MONTH(c.end_date) = ?) ");
            params.add(month);
            params.add(month);
        }
        if (year != null && year > 0) {
            sql.append("AND (YEAR(c.start_date) = ? OR YEAR(c.end_date) = ?) ");
            params.add(year);
            params.add(year);
        }
        if (departmentId != null && departmentId > 0) {
            sql.append("AND u.department_id = ? ");
            params.add(departmentId);
        }
        if (!viewAllCompany && managerId != null && managerId > 0) {
            sql.append("AND (e.manager_id = ? OR u.department_id = (SELECT department_id FROM users WHERE user_id = ? AND department_id IS NOT NULL)) ");
            params.add(managerId);
            params.add(managerId);
        }

        sql.append("ORDER BY c.end_date DESC, d.department_name ASC, u.full_name ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvaluationWithHelpers(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Integer> getUniqueCycleYears() {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT DISTINCT YEAR(start_date) as yr FROM kpi_cycles " +
                     "UNION " +
                     "SELECT DISTINCT YEAR(end_date) as yr FROM kpi_cycles " +
                     "ORDER BY yr DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int yr = rs.getInt("yr");
                if (yr > 0 && !list.contains(yr)) {
                    list.add(yr);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        if (list.isEmpty()) {
            list.add(java.util.Calendar.getInstance().get(java.util.Calendar.YEAR));
        }
        return list;
    }

    // ── TuVV: Department Manager Dashboard — lấy kỳ KPI active gần nhất ──

    /**
     * Lấy kỳ KPI đang active có deadline gần nhất.
     * Dùng cho card "Hạn đánh giá KPI" trên Department Manager Dashboard.
     * @return KpiCycle hoặc null nếu không có kỳ KPI nào đang active
     */
    public KpiCycle getNearestActiveCycle() {
        String sql = "SELECT c.*, t.name AS template_name, d.department_name AS template_department_name " +
                     "FROM kpi_cycles c " +
                     "LEFT JOIN kpi_templates t ON c.template_id = t.template_id " +
                     "LEFT JOIN departments d ON t.department_id = d.department_id " +
                     "WHERE c.status = 'ACTIVE' " +
                     "ORDER BY c.deadline ASC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return mapCycleWithTemplate(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── Thống kê cho Director Dashboard ──
    public List<java.util.Map<String, Object>> getAverageKpiScorePerCycle() {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.name, AVG(e.weighted_score) AS avg_score " +
                     "FROM kpi_evaluations e " +
                     "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
                     "WHERE e.status = 'APPROVED' " +
                     "GROUP BY c.cycle_id, c.name, c.end_date " +
                     "ORDER BY c.end_date ASC " +
                     "LIMIT 6";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("cycleName", rs.getString("name"));
                map.put("avgScore", rs.getDouble("avg_score"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * KPI Performance Report — returns APPROVED/SUBMITTED evaluations
     * with optional filters: cycleId, departmentId, manager-department restriction.
     *
     * @param cycleId       null = all cycles
     * @param departmentId  null = all departments
     * @param managerDeptId non-null = restrict to employees in this department (for non-HR managers)
     */
    public List<KpiEvaluation> getKpiPerformanceReport(Integer cycleId, Integer departmentId, Integer managerDeptId) {
        List<KpiEvaluation> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
            "m.full_name AS manager_name, c.name AS cycle_name, c.status AS cycle_status, d.department_name " +
            "FROM kpi_evaluations e " +
            "JOIN users u ON e.employee_id = u.user_id " +
            "LEFT JOIN users m ON e.manager_id = m.user_id " +
            "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
            "LEFT JOIN departments d ON u.department_id = d.department_id " +
            "WHERE e.status IN ('SUBMITTED', 'APPROVED') "
        );

        List<Object> params = new ArrayList<>();

        if (cycleId != null && cycleId > 0) {
            sql.append("AND e.cycle_id = ? ");
            params.add(cycleId);
        }
        if (departmentId != null && departmentId > 0) {
            sql.append("AND u.department_id = ? ");
            params.add(departmentId);
        }
        if (managerDeptId != null && managerDeptId > 0) {
            sql.append("AND u.department_id = ? ");
            params.add(managerDeptId);
        }

        sql.append("ORDER BY d.department_name ASC, e.weighted_score DESC, u.full_name ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvaluationWithHelpers(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
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
        String sql = "SELECT * FROM kpi_templates ORDER BY template_id DESC";
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
        String sql = "SELECT * FROM kpi_templates WHERE template_id = ?";
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
        String sql = "INSERT INTO kpi_templates (name, description, status, created_by) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, template.getName());
            ps.setString(2, template.getDescription());
            ps.setInt(3, template.getStatus());
            ps.setInt(4, template.getCreatedBy());
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
        String sql = "UPDATE kpi_templates SET name = ?, description = ?, status = ? WHERE template_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, template.getName());
            ps.setString(2, template.getDescription());
            ps.setInt(3, template.getStatus());
            ps.setInt(4, template.getTemplateId());
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
        String sql = "SELECT * FROM kpi_cycles ORDER BY cycle_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCycle(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<KpiCycle> getActiveCycles() {
        List<KpiCycle> list = new ArrayList<>();
        String sql = "SELECT * FROM kpi_cycles WHERE status = 'ACTIVE' ORDER BY cycle_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCycle(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public KpiCycle getCycleById(int cycleId) {
        String sql = "SELECT * FROM kpi_cycles WHERE cycle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cycleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCycle(rs);
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

    // ==========================================
    // 3. EVALUATIONS
    // ==========================================

    public KpiEvaluation getEvaluation(int cycleId, int employeeId) {
        String sql = "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
                     "m.full_name AS manager_name, c.name AS cycle_name, d.department_name " +
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
                     "m.full_name AS manager_name, c.name AS cycle_name, d.department_name " +
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
        String sql = "SELECT e.*, u.full_name AS employee_name, u.username AS employee_code, " +
                     "m.full_name AS manager_name, c.name AS cycle_name, d.department_name " +
                     "FROM kpi_evaluations e " +
                     "JOIN users u ON e.employee_id = u.user_id " +
                     "LEFT JOIN users m ON e.manager_id = m.user_id " +
                     "JOIN kpi_cycles c ON e.cycle_id = c.cycle_id " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE e.cycle_id = ? AND e.manager_id = ? " +
                     "ORDER BY u.full_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cycleId);
            ps.setInt(2, managerId);
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
                     "m.full_name AS manager_name, c.name AS cycle_name, d.department_name " +
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
                     "m.full_name AS manager_name, c.name AS cycle_name, d.department_name " +
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

                // Record audit log
                KpiAuditLog audit = new KpiAuditLog(0, evaluationId, userId, null, "UPDATE_STATUS", oldStatus, status);
                insertAuditLog(audit);
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
                        String oldVal = "Score: " + match.getScore() + ", Comm: " + match.getComment();
                        String newVal = "Score: " + item.getScore() + ", Comm: " + item.getComment();
                        
                        String auditSql = "INSERT INTO kpi_audit_logs (evaluation_id, changed_by, action, old_value, new_value) VALUES (?, ?, ?, ?, ?)";
                        try (PreparedStatement psAudit = conn.prepareStatement(auditSql)) {
                            psAudit.setInt(1, evaluationId);
                            psAudit.setInt(2, updatedBy);
                            psAudit.setString(3, "EDIT_CRITERION_" + item.getTemplateItemId());
                            psAudit.setString(4, oldVal);
                            psAudit.setString(5, newVal);
                            psAudit.executeUpdate();
                        }
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
    // 6. HISTORY & AUDIT LOGS
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

    public List<KpiAuditLog> getAuditLogs(int evaluationId) {
        List<KpiAuditLog> list = new ArrayList<>();
        String sql = "SELECT al.*, u.full_name AS changed_by_name FROM kpi_audit_logs al " +
                     "JOIN users u ON al.changed_by = u.user_id " +
                     "WHERE al.evaluation_id = ? ORDER BY al.changed_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, evaluationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAuditLog(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insertAuditLog(KpiAuditLog log) {
        String sql = "INSERT INTO kpi_audit_logs (evaluation_id, changed_by, action, old_value, new_value) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, log.getEvaluationId());
            ps.setInt(2, log.getChangedBy());
            ps.setString(3, log.getAction());
            ps.setString(4, log.getOldValue());
            ps.setString(5, log.getNewValue());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
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
        return new KpiTemplate(
            rs.getInt("template_id"),
            rs.getString("name"),
            rs.getString("description"),
            rs.getInt("status"),
            rs.getTimestamp("created_at"),
            rs.getInt("created_by")
        );
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

    private KpiAuditLog mapAuditLog(ResultSet rs) throws SQLException {
        KpiAuditLog al = new KpiAuditLog(
            rs.getInt("audit_id"),
            rs.getInt("evaluation_id"),
            rs.getInt("changed_by"),
            rs.getTimestamp("changed_at"),
            rs.getString("action"),
            rs.getString("old_value"),
            rs.getString("new_value")
        );
        al.setChangedByName(rs.getString("changed_by_name"));
        return al;
    }

    /**
     * Initializes evaluations and default evaluation items for all active employees for a given cycle.
     */
    public boolean initializeEvaluationsForCycle(int cycleId) {
        KpiCycle cycle = getCycleById(cycleId);
        if (cycle == null) return false;

        List<KpiTemplateItem> templateItems = getTemplateItems(cycle.getTemplateId());
        if (templateItems.isEmpty()) return false;

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // Fetch all active employees (excluding admin)
            String empSql = "SELECT user_id, department_id, role_id FROM users WHERE status = 1 AND role_id != 1";
            List<User> employees = new ArrayList<>();
            try (PreparedStatement psEmp = conn.prepareStatement(empSql);
                 ResultSet rsEmp = psEmp.executeQuery()) {
                while (rsEmp.next()) {
                    User u = new User();
                    u.setUserId(rsEmp.getInt("user_id"));
                    u.setDepartmentId(rsEmp.getInt("department_id"));
                    u.setRoleId(rsEmp.getInt("role_id"));
                    employees.add(u);
                }
            }

            // Find Director's ID for managing Managers/Factory Managers
            int directorId = 0;
            String dirSql = "SELECT user_id FROM users WHERE role_id = 4 AND status = 1 LIMIT 1";
            try (PreparedStatement psDir = conn.prepareStatement(dirSql);
                 ResultSet rsDir = psDir.executeQuery()) {
                if (rsDir.next()) {
                    directorId = rsDir.getInt("user_id");
                }
            }

            for (User emp : employees) {
                // Check if already initialized
                String checkSql = "SELECT evaluation_id FROM kpi_evaluations WHERE cycle_id = ? AND employee_id = ?";
                boolean exists = false;
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, cycleId);
                    psCheck.setInt(2, emp.getUserId());
                    try (ResultSet rsCheck = psCheck.executeQuery()) {
                        if (rsCheck.next()) {
                            exists = true;
                        }
                    }
                }

                if (exists) continue;

                // Find manager
                int managerId = 0;
                if (emp.getRoleId() == 3 || emp.getRoleId() == 6) {
                    // Manager of Manager is Director
                    managerId = directorId;
                } else {
                    // Search for Manager/Factory Manager in same department
                    String mgrSql = "SELECT user_id FROM users WHERE department_id = ? AND role_id IN (3, 6) AND status = 1 LIMIT 1";
                    try (PreparedStatement psMgr = conn.prepareStatement(mgrSql)) {
                        psMgr.setInt(1, emp.getDepartmentId());
                        try (ResultSet rsMgr = psMgr.executeQuery()) {
                            if (rsMgr.next()) {
                                managerId = rsMgr.getInt("user_id");
                            }
                        }
                    }
                }

                // Insert evaluation
                String insertEvalSql = "INSERT INTO kpi_evaluations (cycle_id, employee_id, manager_id, status, created_by) VALUES (?, ?, ?, 'DRAFT', ?)";
                int evalId = -1;
                try (PreparedStatement psInsertEval = conn.prepareStatement(insertEvalSql, Statement.RETURN_GENERATED_KEYS)) {
                    psInsertEval.setInt(1, cycleId);
                    psInsertEval.setInt(2, emp.getUserId());
                    if (managerId > 0) {
                        psInsertEval.setInt(3, managerId);
                    } else {
                        psInsertEval.setNull(3, Types.INTEGER);
                    }
                    psInsertEval.setInt(4, cycle.getCreatedBy());
                    psInsertEval.executeUpdate();
                    try (ResultSet rsKey = psInsertEval.getGeneratedKeys()) {
                        if (rsKey.next()) {
                            evalId = rsKey.getInt(1);
                        }
                    }
                }

                // Insert default items
                if (evalId > 0) {
                    String insertItemSql = "INSERT INTO kpi_evaluation_items (evaluation_id, template_item_id, score, comment) VALUES (?, ?, 0.0, '')";
                    try (PreparedStatement psInsertItem = conn.prepareStatement(insertItemSql)) {
                        for (KpiTemplateItem item : templateItems) {
                            psInsertItem.setInt(1, evalId);
                            psInsertItem.setInt(2, item.getItemId());
                            psInsertItem.addBatch();
                        }
                        psInsertItem.executeBatch();
                    }
                }
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
}

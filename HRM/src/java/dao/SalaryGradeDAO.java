package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.SalaryGrade;
import util.DBContext;

/**
 * DAO – Salary Grade Management
 * Covers: list (all / active only), detail, search, insert, update, deactivate, activate
 */
public class SalaryGradeDAO {

    // ── Helper ────────────────────────────────────────────────────────────────
    private SalaryGrade mapRow(ResultSet rs) throws Exception {
        return new SalaryGrade(
            rs.getInt("salary_grade_id"),
            rs.getString("grade_name"),
            rs.getBigDecimal("base_salary"),
            rs.getBigDecimal("coefficient"),
            rs.getString("description"),
            rs.getBoolean("status")
        );
    }

    // ── 1. View Salary Grade List (all, including inactive – for management) ──
    public List<SalaryGrade> getAll() {
        List<SalaryGrade> list = new ArrayList<>();
        String sql = "SELECT * FROM salary_grades ORDER BY status DESC, salary_grade_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm kiếm bậc lương theo tên.
     *
     * @param keyword      từ khóa tìm kiếm trong grade_name (null / blank = tất cả)
     * @param statusFilter "active" = chỉ đang hoạt động,
     *                     "inactive" = chỉ vô hiệu,
     *                     null / "all" = tất cả
     */
    public List<SalaryGrade> search(String keyword, String statusFilter) {
        List<SalaryGrade> list = new ArrayList<>();
        boolean hasKeyword   = keyword != null && !keyword.isBlank();
        boolean activeOnly   = "active".equalsIgnoreCase(statusFilter);
        boolean inactiveOnly = "inactive".equalsIgnoreCase(statusFilter);

        StringBuilder sql = new StringBuilder("SELECT * FROM salary_grades WHERE 1=1");
        if (hasKeyword)    sql.append(" AND grade_name LIKE ?");
        if (activeOnly)    sql.append(" AND status = 1");
        if (inactiveOnly)  sql.append(" AND status = 0");
        sql.append(" ORDER BY status DESC, grade_name");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (hasKeyword) ps.setString(1, "%" + keyword.trim() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── 2. View Salary Grade Details ──────────────────────────────────────────
    public SalaryGrade getById(int id) {
        String sql = "SELECT * FROM salary_grades WHERE salary_grade_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── 3. Duplicate check (exclude self when editing) ────────────────────────
    public boolean isDuplicate(String gradeName, int excludeId) {
        String sql = "SELECT COUNT(*) FROM salary_grades WHERE grade_name = ? AND salary_grade_id != ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, gradeName);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── 4. Create New Salary Grade ────────────────────────────────────────────
    public boolean insert(SalaryGrade sg) {
        String sql = "INSERT INTO salary_grades (grade_name, base_salary, coefficient, description, status) "
                   + "VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sg.getGradeName());
            ps.setBigDecimal(2, sg.getBaseSalary());
            ps.setBigDecimal(3, sg.getCoefficient());
            ps.setString(4, sg.getDescription());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── 5. Update Salary Grade ────────────────────────────────────────────────
    public boolean update(SalaryGrade sg) {
        String sql = "UPDATE salary_grades "
                   + "SET grade_name=?, base_salary=?, coefficient=?, description=? "
                   + "WHERE salary_grade_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sg.getGradeName());
            ps.setBigDecimal(2, sg.getBaseSalary());
            ps.setBigDecimal(3, sg.getCoefficient());
            ps.setString(4, sg.getDescription());
            ps.setInt(5, sg.getSalaryGradeId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── 6. Deactivate Salary Grade (soft delete, status = 0) ─────────────────
    public boolean deactivate(int id) {
        return setStatus(id, false);
    }

    // ── 7. Activate Salary Grade (restore, status = 1) ───────────────────────
    public boolean activate(int id) {
        return setStatus(id, true);
    }

    private boolean setStatus(int id, boolean active) {
        String sql = "UPDATE salary_grades SET status = ? WHERE salary_grade_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── 8. Count employees using this grade (guard before deactivate) ─────────
    public int countLinkedEmployees(int salaryGradeId) {
        String sql = "SELECT COUNT(*) FROM employee_profiles WHERE salary_grade_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, salaryGradeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}

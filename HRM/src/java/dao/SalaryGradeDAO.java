package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.SalaryGrade;
import util.DBContext;

public class SalaryGradeDAO {

    public List<SalaryGrade> getAll() {
        List<SalaryGrade> list = new ArrayList<>();
        String sql = "SELECT * FROM salary_grades WHERE status = 1 ORDER BY salary_grade_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
               list.add(new SalaryGrade(
    rs.getInt("salary_grade_id"),
    rs.getString("grade_name"),
    rs.getBigDecimal("base_salary"),   // thêm
    rs.getBigDecimal("coefficient"),   // thêm
    rs.getString("description"),
    rs.getBoolean("status")
));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public SalaryGrade getById(int id) {
    String sql = "SELECT * FROM salary_grades WHERE salary_grade_id = ?";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, id);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return new SalaryGrade(
                    rs.getInt("salary_grade_id"),
                    rs.getString("grade_name"),
                    rs.getBigDecimal("base_salary"),   // thêm
                    rs.getBigDecimal("coefficient"),   // thêm
                    rs.getString("description"),
                    rs.getBoolean("status")
                );
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}

    public boolean isDuplicate(String gradeName, int excludeId) {
        String sql = "SELECT COUNT(*) FROM salary_grades WHERE grade_name = ? AND salary_grade_id != ? AND status = 1";
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

    public void insert(SalaryGrade sg) {
    String sql = "INSERT INTO salary_grades (grade_name, base_salary, coefficient, description, status) VALUES (?, ?, ?, ?, 1)";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, sg.getGradeName());
        ps.setBigDecimal(2, sg.getBaseSalary());
        ps.setBigDecimal(3, sg.getCoefficient());
        ps.setString(4, sg.getDescription());
        ps.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
    }
}

public void update(SalaryGrade sg) {
    String sql = "UPDATE salary_grades SET grade_name=?, base_salary=?, coefficient=?, description=? WHERE salary_grade_id=?";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, sg.getGradeName());
        ps.setBigDecimal(2, sg.getBaseSalary());
        ps.setBigDecimal(3, sg.getCoefficient());
        ps.setString(4, sg.getDescription());
        ps.setInt(5, sg.getSalaryGradeId());
        ps.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
    }
}

public int countEmployees(int id) {
    return countLinkedEmployees(id);
}

    public void delete(int id) {
        String sql = "UPDATE salary_grades SET status = 0 WHERE salary_grade_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

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

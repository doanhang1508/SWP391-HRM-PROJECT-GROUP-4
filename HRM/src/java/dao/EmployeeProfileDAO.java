package dao;

import model.EmployeeProfile;
import util.DBContext;

import java.sql.*;

/**
 * DAO cho bảng employee_profiles.
 * Hỗ trợ: getByUserId (với JOIN), upsert (INSERT hoặc UPDATE), updateBasicFields.
 */
public class EmployeeProfileDAO {

    /**
     * Lấy hồ sơ nhân sự đầy đủ của một nhân viên (JOIN contract_types, salary_grades, employment_statuses).
     * Trả về null nếu chưa có hồ sơ.
     */
    public EmployeeProfile getByUserId(int userId) {
        String sql = """
            SELECT
                ep.*,
                ct.type_name  AS contract_type_name,
                sg.grade_name AS salary_grade_name,
                sg.base_salary,
                es.status_name AS employment_status_name
            FROM employee_profiles ep
            LEFT JOIN contract_types      ct ON ep.contract_type_id     = ct.contract_type_id
            LEFT JOIN salary_grades       sg ON ep.salary_grade_id       = sg.salary_grade_id
            LEFT JOIN employment_statuses es ON ep.employment_status_id  = es.status_id
            WHERE ep.user_id = ?
            """;
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("EmployeeProfileDAO.getByUserId: " + e.getMessage());
        }
        return null;
    }

    /**
     * Upsert (INSERT nếu chưa có, UPDATE nếu đã có) hồ sơ nhân sự.
     * Cập nhật các trường cơ bản: id_card, dob, gender, address, hire_date, tax_code,
     * social_insurance_no, bank_account, bank_name, contract_type_id, salary_grade_id.
     */
    public boolean upsert(EmployeeProfile ep) {
        // Kiểm tra tồn tại
        boolean exists = existsByUserId(ep.getUserId());
        if (exists) {
            return update(ep);
        } else {
            return insert(ep);
        }
    }

    private boolean existsByUserId(int userId) {
        String sql = "SELECT 1 FROM employee_profiles WHERE user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("EmployeeProfileDAO.existsByUserId: " + e.getMessage());
        }
        return false;
    }

    private boolean insert(EmployeeProfile ep) {
        String sql = """
            INSERT INTO employee_profiles
                (user_id, department_id, id_card, dob, gender, address,
                 hire_date, tax_code, social_insurance_no, bank_account, bank_name,
                 contract_type_id, salary_grade_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ep.getUserId());
            setNullableInt(ps, 2, ep.getDepartmentId() > 0 ? ep.getDepartmentId() : null);
            ps.setString(3, ep.getIdCard());
            ps.setDate(4, ep.getDob());
            setNullableInt(ps, 5, ep.getGender());
            ps.setString(6, ep.getAddress());
            ps.setDate(7, ep.getHireDate());
            ps.setString(8, ep.getTaxCode());
            ps.setString(9, ep.getSocialInsuranceNo());
            ps.setString(10, ep.getBankAccount());
            ps.setString(11, ep.getBankName());
            setNullableInt(ps, 12, ep.getContractTypeId());
            setNullableInt(ps, 13, ep.getSalaryGradeId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("EmployeeProfileDAO.insert: " + e.getMessage());
        }
        return false;
    }

    public boolean update(EmployeeProfile ep) {
        String sql = """
            UPDATE employee_profiles SET
                id_card = ?, dob = ?, gender = ?, address = ?,
                hire_date = ?, tax_code = ?, social_insurance_no = ?,
                bank_account = ?, bank_name = ?,
                contract_type_id = ?, salary_grade_id = ?
            WHERE user_id = ?
            """;
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ep.getIdCard());
            ps.setDate(2, ep.getDob());
            setNullableInt(ps, 3, ep.getGender());
            ps.setString(4, ep.getAddress());
            ps.setDate(5, ep.getHireDate());
            ps.setString(6, ep.getTaxCode());
            ps.setString(7, ep.getSocialInsuranceNo());
            ps.setString(8, ep.getBankAccount());
            ps.setString(9, ep.getBankName());
            setNullableInt(ps, 10, ep.getContractTypeId());
            setNullableInt(ps, 11, ep.getSalaryGradeId());
            ps.setInt(12, ep.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("EmployeeProfileDAO.update: " + e.getMessage());
        }
        return false;
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private EmployeeProfile mapRow(ResultSet rs) throws SQLException {
        EmployeeProfile ep = new EmployeeProfile();
        ep.setProfileId(rs.getInt("profile_id"));
        ep.setUserId(rs.getInt("user_id"));
        ep.setDepartmentId(rs.getInt("department_id"));
        ep.setIdCard(rs.getString("id_card"));
        ep.setDob(rs.getDate("dob"));

        int genderVal = rs.getInt("gender");
        ep.setGender(rs.wasNull() ? null : genderVal);

        ep.setAddress(rs.getString("address"));
        ep.setHireDate(rs.getDate("hire_date"));
        ep.setTaxCode(rs.getString("tax_code"));
        ep.setSocialInsuranceNo(rs.getString("social_insurance_no"));
        ep.setBankAccount(rs.getString("bank_account"));
        ep.setBankName(rs.getString("bank_name"));

        int ctId = rs.getInt("contract_type_id");
        ep.setContractTypeId(rs.wasNull() ? null : ctId);

        int sgId = rs.getInt("salary_grade_id");
        ep.setSalaryGradeId(rs.wasNull() ? null : sgId);

        int esId = rs.getInt("employment_status_id");
        ep.setEmploymentStatusId(rs.wasNull() ? null : esId);

        int elId = rs.getInt("education_level_id");
        ep.setEducationLevelId(rs.wasNull() ? null : elId);

        // JOIN fields (có thể null nếu LEFT JOIN không khớp)
        ep.setContractTypeName(rs.getString("contract_type_name"));
        ep.setSalaryGradeName(rs.getString("salary_grade_name"));
        ep.setBaseSalary(rs.getBigDecimal("base_salary"));
        ep.setEmploymentStatusName(rs.getString("employment_status_name"));

        return ep;
    }

    private void setNullableInt(PreparedStatement ps, int idx, Integer val) throws SQLException {
        if (val == null) {
            ps.setNull(idx, Types.INTEGER);
        } else {
            ps.setInt(idx, val);
        }
    }
}

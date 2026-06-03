package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.ContractType;
import util.DBContext;

public class ContractTypeDAO {

    public List<ContractType> getAll() {
        List<ContractType> list = new ArrayList<>();
        String sql = "SELECT * FROM contract_types ORDER BY contract_type_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int dur = rs.getInt("duration");
                Integer durationVal = rs.wasNull() ? null : dur;
                list.add(new ContractType(
                    rs.getInt("contract_type_id"),
                    rs.getString("type_name"),
                    rs.getString("description"),
                    durationVal,
                    rs.getString("duration_unit"),
                    rs.getBoolean("status"),
                    rs.getTimestamp("created_at"),
                    rs.getTimestamp("updated_at")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insert(ContractType ct) {
        String sql = "INSERT INTO contract_types (type_name, description, duration, duration_unit, status) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ct.getTypeName());
            ps.setString(2, ct.getDescription());
            if (ct.getDuration() == null) {
                ps.setNull(3, java.sql.Types.INTEGER);
            } else {
                ps.setInt(3, ct.getDuration());
            }
            ps.setString(4, ct.getDurationUnit());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(ContractType ct) {
        String sql = "UPDATE contract_types SET type_name=?, description=?, duration=?, duration_unit=? WHERE contract_type_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ct.getTypeName());
            ps.setString(2, ct.getDescription());
            if (ct.getDuration() == null) {
                ps.setNull(3, java.sql.Types.INTEGER);
            } else {
                ps.setInt(3, ct.getDuration());
            }
            ps.setString(4, ct.getDurationUnit());
            ps.setInt(5, ct.getContractTypeId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        changeStatus(id, false);
    }

    public void changeStatus(int id, boolean status) {
        String sql = "UPDATE contract_types SET status = ? WHERE contract_type_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int countEmployees(int contractTypeId) {
        String sql = "SELECT COUNT(*) FROM employee_profiles WHERE contract_type_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}

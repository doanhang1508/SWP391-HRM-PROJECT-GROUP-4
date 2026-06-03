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
        String sql = "SELECT * FROM contract_types WHERE status = 1 ORDER BY contract_type_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new ContractType(
                    rs.getInt("contract_type_id"),
                    rs.getString("type_name"),
                    rs.getString("description"),
                    rs.getBoolean("status")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insert(ContractType ct) {
        String sql = "INSERT INTO contract_types (type_name, description, status) VALUES (?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ct.getTypeName());
            ps.setString(2, ct.getDescription());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(ContractType ct) {
        String sql = "UPDATE contract_types SET type_name=?, description=? WHERE contract_type_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ct.getTypeName());
            ps.setString(2, ct.getDescription());
            ps.setInt(3, ct.getContractTypeId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "UPDATE contract_types SET status = 0 WHERE contract_type_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<ContractType> getAllIncludingInactive() {
        List<ContractType> list = new ArrayList<>();
        String sql = "SELECT * FROM contract_types ORDER BY contract_type_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new ContractType(
                    rs.getInt("contract_type_id"),
                    rs.getString("type_name"),
                    rs.getString("description"),
                    rs.getBoolean("status")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void toggleStatus(int id) {
        String sql = "UPDATE contract_types SET status = CASE WHEN status = 1 THEN 0 ELSE 1 END WHERE contract_type_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
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

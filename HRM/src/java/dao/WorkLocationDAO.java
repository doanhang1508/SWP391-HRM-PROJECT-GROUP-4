/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import util.DBContext;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import model.WorkLocation;
/**
 *
 * @author Thanh Hang
 */
public class WorkLocationDAO extends DBContext{

    public void deleteLocation(int id) {
        String sql = "UPDATE work_locations SET status = 0 WHERE location_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setInt(1, id);
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Object getAll() {
         List<WorkLocation> list = new ArrayList<>();
        String sql = "SELECT * FROM work_locations WHERE status = 1";
        
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            while (rs.next()) {
                list.add(new WorkLocation(
                    rs.getInt("location_id"),
                    rs.getString("location_name"),
                    rs.getString("address"),
                    rs.getBigDecimal("regional_minimum_wage"),
                    rs.getBoolean("status")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insertLocation(WorkLocation w) {
       String sql = """
                    INSERT INTO work_locations (location_name, address, regional_minimum_wage, status) 
                    VALUES (?, ?, ?, 1)
                    """;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setString(1, w.getLocationName());
            ps.setString(2, w.getAddress());
            ps.setBigDecimal(3, w.getRegionalMinimumWage());
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void updateLocation(WorkLocation w) {
        String sql = "UPDATE work_locations SET location_name=?, address=?, regional_minimum_wage=? WHERE location_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setString(1, w.getLocationName());
            ps.setString(2, w.getAddress());
            ps.setBigDecimal(3, w.getRegionalMinimumWage());
            ps.setInt(4, w.getLocationId());
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
}

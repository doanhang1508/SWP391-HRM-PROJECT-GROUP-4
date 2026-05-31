/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;

/**
 *
 * @author Thanh Hang
 */
public class WorkLocation {
     private int locationId;
    private String locationName;
    private String address;
    private BigDecimal regionalMinimumWage; // Lương tối thiểu vùng
    private boolean status;

    public WorkLocation() {
    }

    public WorkLocation(int locationId, String locationName, String address, BigDecimal regionalMinimumWage, boolean status) {
        this.locationId = locationId;
        this.locationName = locationName;
        this.address = address;
        this.regionalMinimumWage = regionalMinimumWage;
        this.status = status;
    }

    public int getLocationId() {
        return locationId;
    }

    public void setLocationId(int locationId) {
        this.locationId = locationId;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public BigDecimal getRegionalMinimumWage() {
        return regionalMinimumWage;
    }

    public void setRegionalMinimumWage(BigDecimal regionalMinimumWage) {
        this.regionalMinimumWage = regionalMinimumWage;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }
    
    
}

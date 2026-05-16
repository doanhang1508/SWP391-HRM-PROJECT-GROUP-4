package model;

public class Role {
    
  
    private int roleId;
    private String roleName;
    private String description;
    private int status; // 1: Active, 0: Deactive


    public Role() {
    }

    public Role(int roleId, String roleName, String description, int status) {
        this.roleId = roleId;
        this.roleName = roleName;
        this.description = description;
        this.status = status;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }


    public boolean isActive() {
        return this.status == 1;
    }
}

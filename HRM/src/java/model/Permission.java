package model;

public class Permission {

    private String permissionName;
    private String description;
    private int permissionId;

    public Permission() {
    }

    public Permission(String permissionName, String description, int permissionId) {
        this.permissionName = permissionName;
        this.description = description;
        this.permissionId = permissionId;
    }

    public int getPermissionId() {
        return permissionId;
    }

    public void setPermissionId(int permissionId) {
        this.permissionId = permissionId;
    }


    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}

public class GooglePermissionEntity {
    public String id;
    public String displayName;
    public String type;
    public String kind;
    public List<PermissionDetail> permissionDetails;
    public String photoLink;
    public String emailAddress;
    public String role;
    public Boolean allowFileDiscovery;
    public String domain;
    public String expirationTime;
    public List<TeamDrivePermissionDetail> teamDrivePermissionDetails;
    public Boolean deleted;
    public String view;
    public Boolean pendingOwner;

    public class PermissionDetail {
        public String permissionType;
        public String inheritedFrom;
        public String role;
        public Boolean inherited;
    }

    public class TeamDrivePermissionDetail {
        public String teamDrivePermissionType;
        public String inheritedFrom;
        public String role;
        public Boolean inherited;
    }
}
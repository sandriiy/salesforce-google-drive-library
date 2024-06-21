public class GDriveEntity {
    public String id { get; set; }
    public String name { get; set; }
    public String colorRgb { get; set; }
    public String kind { get; set; }
    public String backgroundImageLink { get; set; }
    public Capabilities capabilities { get; set; }
    public String themeId { get; set; }
    public BackgroundImageFile backgroundImageFile { get; set; }
    public String createdTime { get; set; }
    public Boolean hidden { get; set; }
    public Restrictions restrictions { get; set; }
    public String orgUnitId { get; set; }
    
    public class Capabilities {
        public Boolean canAddChildren { get; set; }
        public Boolean canComment { get; set; }
        public Boolean canCopy { get; set; }
        public Boolean canDeleteDrive { get; set; }
        public Boolean canDownload { get; set; }
        public Boolean canEdit { get; set; }
        public Boolean canListChildren { get; set; }
        public Boolean canManageMembers { get; set; }
        public Boolean canReadRevisions { get; set; }
        public Boolean canRename { get; set; }
        public Boolean canRenameDrive { get; set; }
        public Boolean canChangeDriveBackground { get; set; }
        public Boolean canShare { get; set; }
        public Boolean canChangeCopyRequiresWriterPermissionRestriction { get; set; }
        public Boolean canChangeDomainUsersOnlyRestriction { get; set; }
        public Boolean canChangeDriveMembersOnlyRestriction { get; set; }
        public Boolean canChangeSharingFoldersRequiresOrganizerPermissionRestriction { get; set; }
        public Boolean canResetDriveRestrictions { get; set; }
        public Boolean canDeleteChildren { get; set; }
        public Boolean canTrashChildren { get; set; }
    }
    
    public class BackgroundImageFile {
        public String id { get; set; }
        public Double xCoordinate { get; set; }
        public Double yCoordinate { get; set; }
        public Double width { get; set; }
    }
    
    public class Restrictions {
        public Boolean copyRequiresWriterPermission { get; set; }
        public Boolean domainUsersOnly { get; set; }
        public Boolean driveMembersOnly { get; set; }
        public Boolean adminManagedRestrictions { get; set; }
        public Boolean sharingFoldersRequiresOrganizerPermission { get; set; }
    }
}
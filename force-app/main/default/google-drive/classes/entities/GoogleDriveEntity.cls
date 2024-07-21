public class GoogleDriveEntity {
    public String id;
    public String name;
    public String colorRgb;
    public String kind;
    public String backgroundImageLink;
    public Capabilities capabilities;
    public String themeId;
    public BackgroundImageFile backgroundImageFile;
    public String createdTime;
    public Boolean hidden;
    public Restrictions restrictions;
    public String orgUnitId;
    
    public class Capabilities {
        public Boolean canAddChildren;
        public Boolean canComment;
        public Boolean canCopy;
        public Boolean canDeleteDrive;
        public Boolean canDownload;
        public Boolean canEdit;
        public Boolean canListChildren;
        public Boolean canManageMembers;
        public Boolean canReadRevisions;
        public Boolean canRename;
        public Boolean canRenameDrive;
        public Boolean canChangeDriveBackground;
        public Boolean canShare;
        public Boolean canChangeCopyRequiresWriterPermissionRestriction;
        public Boolean canChangeDomainUsersOnlyRestriction;
        public Boolean canChangeDriveMembersOnlyRestriction;
        public Boolean canChangeSharingFoldersRequiresOrganizerPermissionRestriction;
        public Boolean canResetDriveRestrictions;
        public Boolean canDeleteChildren;
        public Boolean canTrashChildren;
    }
    
    public class BackgroundImageFile {
        public String id;
        public Double xCoordinate;
        public Double yCoordinate;
        public Double width;
    }
    
    public class Restrictions {
        public Boolean copyRequiresWriterPermission;
        public Boolean domainUsersOnly;
        public Boolean driveMembersOnly;
        public Boolean adminManagedRestrictions;
        public Boolean sharingFoldersRequiresOrganizerPermission;
    }
}
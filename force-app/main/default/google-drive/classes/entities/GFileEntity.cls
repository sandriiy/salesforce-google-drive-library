public class GFileEntity {
    public String kind { get; set; }
    public String driveId { get; set; }
    public String fileExtension { get; set; }
    public Boolean copyRequiresWriterPermission { get; set; }
    public String md5Checksum { get; set; }
    public Boolean writersCanShare { get; set; }
    public Boolean viewedByMe { get; set; }
    public String mimeType { get; set; }
    public Map<String, String> exportLinks { get; set; }
    public List<String> parents { get; set; }
    public String thumbnailLink { get; set; }
    public String iconLink { get; set; }
    public Boolean shared { get; set; }
    public User lastModifyingUser { get; set; }
    public List<User> owners { get; set; }
    public String headRevisionId { get; set; }
    public User sharingUser { get; set; }
    public String webViewLink { get; set; }
    public String webContentLink { get; set; }
    public String size { get; set; }
    public Boolean viewersCanCopyContent { get; set; }
    public List<Permission> permissions { get; set; }
    public Boolean hasThumbnail { get; set; }
    public List<String> spaces { get; set; }
    public String folderColorRgb { get; set; }
    public String id { get; set; }
    public String name { get; set; }
    public String description { get; set; }
    public Boolean starred { get; set; }
    public Boolean trashed { get; set; }
    public Boolean explicitlyTrashed { get; set; }
    public String createdTime { get; set; }
    public String modifiedTime { get; set; }
    public String modifiedByMeTime { get; set; }
    public String viewedByMeTime { get; set; }
    public String sharedWithMeTime { get; set; }
    public String quotaBytesUsed { get; set; }
    public String version { get; set; }
    public String originalFilename { get; set; }
    public Boolean ownedByMe { get; set; }
    public String fullFileExtension { get; set; }
    public Map<String, Object> properties { get; set; }
    public Map<String, Object> appProperties { get; set; }
    public Boolean isAppAuthorized { get; set; }
    public String teamDriveId { get; set; }
    public Capabilities capabilities { get; set; }
    public Boolean hasAugmentedPermissions { get; set; }
    public User trashingUser { get; set; }
    public String thumbnailVersion { get; set; }
    public String trashedTime { get; set; }
    public Boolean modifiedByMe { get; set; }
    public List<String> permissionIds { get; set; }
    public ImageMediaMetadata imageMediaMetadata { get; set; }
    public VideoMediaMetadata videoMediaMetadata { get; set; }
    public ShortcutDetails shortcutDetails { get; set; }
    public String resourceKey { get; set; }
    public LinkShareMetadata linkShareMetadata { get; set; }
    public String sha1Checksum { get; set; }
    public String sha256Checksum { get; set; }

    public class User {
        public String displayName { get; set; }
        public String kind { get; set; }
        public Boolean me { get; set; }
        public String permissionId { get; set; }
        public String emailAddress { get; set; }
        public String photoLink { get; set; }
    }
    
    public class Permission {
        public String id { get; set; }
        public String displayName { get; set; }
        public String type { get; set; }
        public String kind { get; set; }
        public List<PermissionDetails> permissionDetails { get; set; }
        public String photoLink { get; set; }
        public String emailAddress { get; set; }
        public String role { get; set; }
        public Boolean allowFileDiscovery { get; set; }
        public String domain { get; set; }
        public String expirationTime { get; set; }
        public List<TeamDrivePermissionDetails> teamDrivePermissionDetails { get; set; }
        public Boolean deleted { get; set; }
        public String view { get; set; }
        public Boolean pendingOwner { get; set; }
    }

    public class PermissionDetails {
        public String permissionType { get; set; }
        public String inheritedFrom { get; set; }
        public String role { get; set; }
        public Boolean inherited { get; set; }
    }

    public class TeamDrivePermissionDetails {
        public String teamDrivePermissionType { get; set; }
        public String inheritedFrom { get; set; }
        public String role { get; set; }
        public Boolean inherited { get; set; }
    }
    
    public class Capabilities {
        public Boolean canChangeViewersCanCopyContent { get; set; }
        public Boolean canMoveChildrenOutOfDrive { get; set; }
        public Boolean canReadDrive { get; set; }
        public Boolean canEdit { get; set; }
        public Boolean canCopy { get; set; }
        public Boolean canComment { get; set; }
        public Boolean canAddChildren { get; set; }
        public Boolean canDelete { get; set; }
        public Boolean canDownload { get; set; }
        public Boolean canListChildren { get; set; }
        public Boolean canRemoveChildren { get; set; }
        public Boolean canRename { get; set; }
        public Boolean canTrash { get; set; }
        public Boolean canReadRevisions { get; set; }
        public Boolean canReadTeamDrive { get; set; }
        public Boolean canMoveTeamDriveItem { get; set; }
        public Boolean canChangeCopyRequiresWriterPermission { get; set; }
        public Boolean canMoveItemIntoTeamDrive { get; set; }
        public Boolean canUntrash { get; set; }
        public Boolean canModifyContent { get; set; }
        public Boolean canMoveItemWithinTeamDrive { get; set; }
        public Boolean canMoveItemOutOfTeamDrive { get; set; }
        public Boolean canDeleteChildren { get; set; }
        public Boolean canMoveChildrenOutOfTeamDrive { get; set; }
        public Boolean canMoveChildrenWithinTeamDrive { get; set; }
        public Boolean canTrashChildren { get; set; }
        public Boolean canMoveItemOutOfDrive { get; set; }
        public Boolean canAddMyDriveParent { get; set; }
        public Boolean canRemoveMyDriveParent { get; set; }
        public Boolean canMoveItemWithinDrive { get; set; }
        public Boolean canShare { get; set; }
        public Boolean canMoveChildrenWithinDrive { get; set; }
        public Boolean canModifyContentRestriction { get; set; }
        public Boolean canAddFolderFromAnotherDrive { get; set; }
        public Boolean canChangeSecurityUpdateEnabled { get; set; }
        public Boolean canAcceptOwnership { get; set; }
        public Boolean canReadLabels { get; set; }
        public Boolean canModifyLabels { get; set; }
        public Boolean canModifyEditorContentRestriction { get; set; }
        public Boolean canModifyOwnerContentRestriction { get; set; }
        public Boolean canRemoveContentRestriction { get; set; }
    }
    
    public class ImageMediaMetadata {
        public Boolean flashUsed { get; set; }
        public String meteringMode { get; set; }
        public String sensor { get; set; }
        public String exposureMode { get; set; }
        public String colorSpace { get; set; }
        public String whiteBalance { get; set; }
        public Integer width { get; set; }
        public Integer height { get; set; }
        public Location location { get; set; }
        public Integer rotation { get; set; }
        public String cameraMake { get; set; }
        public String cameraModel { get; set; }
        public Double exposureTime { get; set; }
        public Double aperture { get; set; }
        public Double focalLength { get; set; }
        public Integer isoSpeed { get; set; }
        public Double exposureBias { get; set; }
        public Double maxApertureValue { get; set; }
        public Integer subjectDistance { get; set; }
        public String lens { get; set; }
    }

    public class Location {
        public Double latitude { get; set; }
        public Double longitude { get; set; }
        public Double altitude { get; set; }
    }
    
    public class VideoMediaMetadata {
        public Integer width { get; set; }
        public Integer height { get; set; }
        public String durationMillis { get; set; }
    }
    
    public class ShortcutDetails {
        public String targetId { get; set; }
        public String targetMimeType { get; set; }
        public String targetResourceKey { get; set; }
    }

    public class LinkShareMetadata {
        public Boolean securityUpdateEligible { get; set; }
        public Boolean securityUpdateEnabled { get; set; }
    }
}
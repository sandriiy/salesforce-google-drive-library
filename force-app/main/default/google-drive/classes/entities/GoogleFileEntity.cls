public class GoogleFileEntity {
    public String kind;
    public String driveId;
    public String fileExtension;
    public String body;
    public Blob bodyAsBlob;
    public Boolean copyRequiresWriterPermission;
    public String md5Checksum;
    public Boolean writersCanShare;
    public Boolean viewedByMe;
    public String mimeType;
    public Map<String, String> exportLinks;
    public List<String> parents;
    public String thumbnailLink;
    public String iconLink;
    public Boolean shared;
    public User lastModifyingUser;
    public List<User> owners;
    public String headRevisionId;
    public User sharingUser;
    public String webViewLink;
    public String webContentLink;
    public String size;
    public Boolean viewersCanCopyContent;
    public List<Permission> permissions;
    public Boolean hasThumbnail;
    public List<String> spaces;
    public String folderColorRgb;
    public String id;
    public String name;
    public String description;
    public Boolean starred;
    public Boolean trashed;
    public Boolean explicitlyTrashed;
    public String createdTime;
    public String modifiedTime;
    public String modifiedByMeTime;
    public String viewedByMeTime;
    public String sharedWithMeTime;
    public String quotaBytesUsed;
    public String version;
    public String originalFilename;
    public Boolean ownedByMe;
    public String fullFileExtension;
    public Boolean isAppAuthorized;
    public String teamDriveId;
    public Capabilities capabilities;
    public Boolean hasAugmentedPermissions;
    public User trashingUser;
    public String thumbnailVersion;
    public String trashedTime;
    public Boolean modifiedByMe;
    public List<String> permissionIds;
    public ImageMediaMetadata imageMediaMetadata;
    public VideoMediaMetadata videoMediaMetadata;
    public ShortcutDetails shortcutDetails;
    public String resourceKey;
    public LinkShareMetadata linkShareMetadata;
    public String sha1Checksum;
    public String sha256Checksum;

    public class User {
        public String displayName;
        public String kind;
        public Boolean me;
        public String permissionId;
        public String emailAddress;
        public String photoLink;
    }
    
    public class Permission {
        public String id;
        public String displayName;
        public String type;
        public String kind;
        public List<PermissionDetails> permissionDetails;
        public String photoLink;
        public String emailAddress;
        public String role;
        public Boolean allowFileDiscovery;
        public String domain;
        public String expirationTime;
        public List<TeamDrivePermissionDetails> teamDrivePermissionDetails;
        public Boolean deleted;
        public String view;
        public Boolean pendingOwner;
    }

    public class PermissionDetails {
        public String permissionType;
        public String inheritedFrom;
        public String role;
        public Boolean inherited;
    }

    public class TeamDrivePermissionDetails {
        public String teamDrivePermissionType;
        public String inheritedFrom;
        public String role;
        public Boolean inherited;
    }
    
    public class Capabilities {
        public Boolean canChangeViewersCanCopyContent;
        public Boolean canMoveChildrenOutOfDrive;
        public Boolean canReadDrive;
        public Boolean canEdit;
        public Boolean canCopy;
        public Boolean canComment;
        public Boolean canAddChildren;
        public Boolean canDelete;
        public Boolean canDownload;
        public Boolean canListChildren;
        public Boolean canRemoveChildren;
        public Boolean canRename;
        public Boolean canTrash;
        public Boolean canReadRevisions;
        public Boolean canReadTeamDrive;
        public Boolean canMoveTeamDriveItem;
        public Boolean canChangeCopyRequiresWriterPermission;
        public Boolean canMoveItemIntoTeamDrive;
        public Boolean canUntrash;
        public Boolean canModifyContent;
        public Boolean canMoveItemWithinTeamDrive;
        public Boolean canMoveItemOutOfTeamDrive;
        public Boolean canDeleteChildren;
        public Boolean canMoveChildrenOutOfTeamDrive;
        public Boolean canMoveChildrenWithinTeamDrive;
        public Boolean canTrashChildren;
        public Boolean canMoveItemOutOfDrive;
        public Boolean canAddMyDriveParent;
        public Boolean canRemoveMyDriveParent;
        public Boolean canMoveItemWithinDrive;
        public Boolean canShare;
        public Boolean canMoveChildrenWithinDrive;
        public Boolean canModifyContentRestriction;
        public Boolean canAddFolderFromAnotherDrive;
        public Boolean canChangeSecurityUpdateEnabled;
        public Boolean canAcceptOwnership;
        public Boolean canReadLabels;
        public Boolean canModifyLabels;
        public Boolean canModifyEditorContentRestriction;
        public Boolean canModifyOwnerContentRestriction;
        public Boolean canRemoveContentRestriction;
    }
    
    public class ImageMediaMetadata {
        public Boolean flashUsed;
        public String meteringMode;
        public String sensor;
        public String exposureMode;
        public String colorSpace;
        public String whiteBalance;
        public Integer width;
        public Integer height;
        public Location location;
        public Integer rotation;
        public String cameraMake;
        public String cameraModel;
        public Double exposureTime;
        public Double aperture;
        public Double focalLength;
        public Integer isoSpeed;
        public Double exposureBias;
        public Double maxApertureValue;
        public Integer subjectDistance;
        public String lens;
    }

    public class Location {
        public Double latitude;
        public Double longitude;
        public Double altitude;
    }
    
    public class VideoMediaMetadata {
        public Integer width;
        public Integer height;
        public String durationMillis;
    }
    
    public class ShortcutDetails {
        public String targetId;
        public String targetMimeType;
        public String targetResourceKey;
    }

    public class LinkShareMetadata {
        public Boolean securityUpdateEligible;
        public Boolean securityUpdateEnabled;
    }
}
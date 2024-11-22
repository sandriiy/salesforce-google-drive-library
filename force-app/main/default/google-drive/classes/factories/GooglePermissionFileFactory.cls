public class GooglePermissionFileFactory {
    private GoogleDrive googleDriveInstance;

    public GooglePermissionFileFactory(GoogleDrive googleDriveInstance) {
        this.googleDriveInstance = googleDriveInstance;
    }

    public GoogleCreatePermissionFileBuilder create(String fileId) {
        return new GoogleCreatePermissionFileBuilder(
            this.googleDriveInstance,
            this.buildCreatePermissionFileEndpoint(fileId),
            'POST'
        );
    }

    public GoogleDeletePermissionFileBuilder remove(String fileId, String permissionId) {
        return new GoogleDeletePermissionFileBuilder(
            this.googleDriveInstance,
            this.buildDeletePermissionFileEndpoint(fileId, permissionId),
            'DELETE'
        );
    }

    private String buildCreatePermissionFileEndpoint(String fileId) {
        return String.format(GoogleConstants.NEW_PERMISSION_FILE_ENDPOINT, new List<String>{fileId});
    }

    private String buildDeletePermissionFileEndpoint(String fileId, String permissionId) {
        return String.format(
            GoogleConstants.DELETE_PERMISSION_FILE_ENDPOINT, 
            new List<String>{
                fileId,
                permissionId
            }
        );
    }
}
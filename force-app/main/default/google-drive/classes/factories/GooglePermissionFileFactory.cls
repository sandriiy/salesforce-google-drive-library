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

    private String buildCreatePermissionFileEndpoint(String fileId) {
        return String.format(GoogleConstants.NEW_PERMISSION_FILE_ENDPOINT, new List<String>{fileId});
    }
}
public with sharing class GoogleModifyFileFactory {
    private GoogleDrive googleDriveInstance;

    public GoogleModifyFileFactory(GoogleDrive googleDriveInstance) {
        this.googleDriveInstance = googleDriveInstance;
    }

     /**
     * Updates a file's metadata only (name, description, parents, etc.).
     * For more information, see https://www.googleapis.com/drive/v3/files/{fileId}
     */
    public GoogleModifyMetadataFileBuilder metadata(String fileId) {
        return new GoogleModifyMetadataFileBuilder(
            this.googleDriveInstance,
            this.buildUpdateMetadataEndpoint(GoogleConstants.UPDATE_FILE_ENDPOINT, fileId),
            'PATCH'
        );
    }

    private String buildUpdateMetadataEndpoint(String endpoint, String fileId) {
        return String.format(endpoint, new List<String>{fileId});
    }
}
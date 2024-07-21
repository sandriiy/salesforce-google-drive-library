public class GoogleRetrieveFileFactory {
    private GoogleDrive googleDriveInstance;

    public GoogleRetrieveFileFactory(GoogleDrive googleDriveInstance) {
        this.googleDriveInstance = googleDriveInstance;
    }

    /**
     * Gets a file's metadata or content by ID.
     * To download Google Docs, Sheets, and Slides use export() instead. 
     * For more information, see https://developers.google.com/drive/api/guides/manage-downloads
    */
    public GoogleDownloadFileBuilder download(String fileId) {
        return new GoogleDownloadFileBuilder(
            this.googleDriveInstance,
            this.buildRetrieveFileEndpoint(GoogleConstants.GET_FILE_ENDPOINT, fileId),
            'GET'
        );
    }

    /**
     * Exports a Google Workspace document to the requested MIME type and returns a GoogleFileEntity record. 
     * Note that the exported content is limited to 10MB.
    */
    public GoogleExportFileBuilder export(String fileId) {
        return new GoogleExportFileBuilder(
            this.googleDriveInstance,
            this.buildRetrieveFileEndpoint(GoogleConstants.EXPORT_FILE_ENDPOINT, fileId),
            'GET'
        );
    }

    private String buildRetrieveFileEndpoint(String endpoint, String fileId) {
        return String.format(endpoint, new List<String>{fileId});
    }
}
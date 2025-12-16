public class GoogleTrashFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleTrashFileBuilder(GoogleDrive googleDriveInstance, String fileId, String endpoint) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);

		this.requestGoogleBuilder.setHeader('Content-Length', 0);
        this.requestGoogleBuilder.setEndpoint(this.buildTrashFileEndpoint(endpoint, fileId));
        this.requestGoogleBuilder.setMethod('POST');
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
    }

    public GoogleTrashFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public void execute() {
        HTTPResponse trashResponse = this.requestGoogleBuilder.send();
        this.validateTrashingPermissionRequest(trashResponse);
    }

    private void validateTrashingPermissionRequest(HTTPResponse trashResponse) {
        if (!GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(trashResponse.getStatusCode())) {
            throw new GoogleCloudException(trashResponse.getBody());
        }
    }

    private String buildTrashFileEndpoint(String baseEndpoint, String fileId) {
        return String.format(baseEndpoint, new List<String>{fileId});
    }
}
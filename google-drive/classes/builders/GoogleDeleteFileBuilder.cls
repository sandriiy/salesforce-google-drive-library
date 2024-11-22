public class GoogleDeleteFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleDeleteFileBuilder(GoogleDrive googleDriveInstance, String fileId, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);

        this.requestGoogleBuilder.setEndpoint(this.buildDeleteFileEndpoint(endpoint, fileId));
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
    }

    public GoogleDeleteFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public void execute() {
        HTTPResponse deleteResponse = this.requestGoogleBuilder.send();
        this.validateDeletionPermissionRequest(deleteResponse);
    }

    private void validateDeletionPermissionRequest(HTTPResponse deleteResponse) {
        if (!GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(deleteResponse.getStatusCode())) {
            throw new CalloutException(deleteResponse.getBody());
        }
    }

    private String buildDeleteFileEndpoint(String baseEndpoint, String fileId) {
        return String.format(baseEndpoint, new List<String>{fileId});
    }
}
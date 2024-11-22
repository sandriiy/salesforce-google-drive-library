public class GoogleDeletePermissionFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleDeletePermissionFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
    }

    public GoogleDeletePermissionFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public GoogleDeletePermissionFileBuilder setDomainAdminAccess(Boolean isDomainAdminAccess) {
        this.requestGoogleBuilder.setParameter('useDomainAdminAccess', isDomainAdminAccess);
        return this;
    }

    public void execute() {
        HTTPResponse permissionResponse = this.requestGoogleBuilder.send();
        this.validateDeletionPermissionRequest(permissionResponse);
    }

    private void validateDeletionPermissionRequest(HTTPResponse permissionResponse) {
        if (!GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(permissionResponse.getStatusCode())) {
            throw new CalloutException(permissionResponse.getBody());
        }
    }
}
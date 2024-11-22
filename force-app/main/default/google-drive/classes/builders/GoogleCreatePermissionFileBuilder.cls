public class GoogleCreatePermissionFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;
    private Map<String, String> newPermission;

    public GoogleCreatePermissionFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.newPermission = new Map<String, String>();

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json');
    }

    public GoogleCreatePermissionFileBuilder setSendNotificationEmail(Boolean isSendEmail) {
        this.requestGoogleBuilder.setParameter('sendNotificationEmail', isSendEmail);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setTransferOwnership(Boolean isTransferOwnership) {
        this.requestGoogleBuilder.setParameter('transferOwnership', isTransferOwnership);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setPrincipalType(String type) {
        this.newPermission.put('type', type);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setPrincipalRole(String role) {
        this.newPermission.put('role', role);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setPrincipalEmailAddress(String emailAddress) {
        this.newPermission.put('emailAddress', emailAddress);
        return this;
    }

    public GooglePermissionEntity execute() {
        String permissionBody = this.buildPermissionFileRequestBody();
        this.requestGoogleBuilder.setHeader('Content-Length', permissionBody.length());
        this.requestGoogleBuilder.setBody(permissionBody);

        HTTPResponse permissionResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestPermissionWrapper(permissionResponse);
    }

    private GooglePermissionEntity retrieveRequestPermissionWrapper(HTTPResponse permissionResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(permissionResponse.getStatusCode())) {
            return (GooglePermissionEntity) JSON.deserialize(permissionResponse.getBody(), GooglePermissionEntity.class);
        } else {
            throw new CalloutException(permissionResponse.getBody());
        }
    }

    private String buildPermissionFileRequestBody() {
        return this.newPermission.isEmpty() ? '' : JSON.serialize(this.newPermission, true);
    }
}
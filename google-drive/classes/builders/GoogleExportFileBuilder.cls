public class GoogleExportFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleExportFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json');
    }

    public GoogleExportFileBuilder setMimeType(String mimeType) {
        this.requestGoogleBuilder.setParameter('mimeType', mimeType);
        return this;
    }

    public GoogleFileEntity execute() {
        HTTPResponse exportResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestExportWrapper(exportResponse);
    }

    private GoogleFileEntity retrieveRequestExportWrapper(HTTPResponse exportResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(exportResponse.getStatusCode())) {
            GoogleFileEntity contentFileEntity = new GoogleFileEntity();
            contentFileEntity.body = exportResponse.getBody();
            contentFileEntity.bodyAsBlob = exportResponse.getBodyAsBlob();
            return contentFileEntity;
        } else {
            throw new CalloutException(exportResponse.getBody());
        }
    }
}
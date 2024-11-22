public class GoogleCloneFileBuilder implements GoogleFileCreator {
    private GoogleRequestBuilder requestGoogleBuilder;
    private GoogleFileMetadataBuilder fileMetadataBuilder;
    
    public GoogleCloneFileBuilder(GoogleDrive googleDriveInstance, String fileId, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.fileMetadataBuilder = new GoogleFileMetadataBuilder();

        this.requestGoogleBuilder.setEndpoint(this.buildCloneFileEndpoint(endpoint, fileId));
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json');
    }

    public GoogleCloneFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleCloneFileBuilder setFileName(String fileName) {
        this.fileMetadataBuilder.setFileProperty('name', fileName);
        return this;
    }

    public GoogleCloneFileBuilder setMimeType(String mimeType) {
        this.fileMetadataBuilder.setFileProperty('mimeType', mimeType);
        return this;
    }

    public GoogleCloneFileBuilder setParentFolders(List<String> folderIds) {
        this.fileMetadataBuilder.setFileProperty('parents', folderIds);
        return this;
    }

    public GoogleFileEntity execute() {
        String cloneBody = this.fileMetadataBuilder.build();
        this.requestGoogleBuilder.setHeader('Content-Length', cloneBody.length());
        this.requestGoogleBuilder.setBody(cloneBody);

        HTTPResponse cloneResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestClonedWrapper(cloneResponse);
    }

    private GoogleFileEntity retrieveRequestClonedWrapper(HTTPResponse cloneResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(cloneResponse.getStatusCode())) {
            return (GoogleFileEntity) JSON.deserialize(cloneResponse.getBody(), GoogleFileEntity.class);
        } else {
            throw new CalloutException(cloneResponse.getBody());
        }
    }

    private String buildCloneFileEndpoint(String baseEndpoint, String fileId) {
        return String.format(baseEndpoint, new List<String>{fileId});
    }
}
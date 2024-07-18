public class GoogleCloneFileBuilder implements GoogleFileCreator {
    private GoogleRequestBuilder requestGoogleBuilder;

    private String metadataFileName;
    private String metadataMimeType;
    private List<String> metadataParentFolders;

    public GoogleCloneFileBuilder(GoogleDrive googleDriveInstance, String fileId, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.metadataParentFolders = new List<String>();

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
        this.metadataFileName = fileName;
        return this;
    }

    public GoogleCloneFileBuilder setMimeType(String mimeType) {
        this.metadataMimeType = mimeType;
        return this;
    }

    public GoogleCloneFileBuilder setParentFolders(List<String> folderIds) {
        this.metadataParentFolders = folderIds;
        return this;
    }

    public GoogleFileEntity execute() {
        String cloneBody = this.buildCloningRequestBody();
        this.requestGoogleBuilder.setHeader('Content-Length', cloneBody.length());
        this.requestGoogleBuilder.setBody(cloneBody);

        HTTPResponse cloneResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestUploadWrapper(cloneResponse);
    }

    private GoogleFileEntity retrieveRequestUploadWrapper(HTTPResponse cloneResponse) {
        if (cloneResponse.getStatusCode() == GoogleConstants.HTTP_SUCCESS_STATUS_CODE) {
            return (GoogleFileEntity) JSON.deserialize(cloneResponse.getBody(), GoogleFileEntity.class);
        } else {
            throw new CalloutException(cloneResponse.getBody());
        }
    }

    private String buildCloneFileEndpoint(String baseEndpoint, String fileId) {
        return String.format(baseEndpoint, new List<String>{fileId});
    }

    private String buildCloningRequestBody() {
        Map<String, Object> fileMetadata = new Map<String, Object>();
        this.addPairIfNotEmpty(fileMetadata, 'name', this.metadataFileName);
        this.addPairIfNotEmpty(fileMetadata, 'mimeType', this.metadataMimeType);
        this.addPairIfNotEmpty(fileMetadata, 'parents', this.metadataParentFolders);
        return fileMetadata.isEmpty() ? '' : JSON.serialize(fileMetadata, true);
    }

    private void addPairIfNotEmpty(Map<String, Object> originMap, String key, String value) {
        if (String.isNotBlank(value)) {
            originMap.put(key, value);
        }
    }

    private void addPairIfNotEmpty(Map<String, Object> originMap, String key, List<String> values) {
        if (values != null && !values.isEmpty()) {
            originMap.put(key, values);
        }
    }
}
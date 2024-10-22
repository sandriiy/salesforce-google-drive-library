public class GoogleMultipartFileBuilder implements GoogleFileCreator {
    private GoogleRequestBuilder requestGoogleBuilder;

    private String metadataFileName;
    private String metadataMimeType;
    private List<String> metadataParentFolders;
    private String dataContentType;
    private String dataTransferEncoding;
    private String dataContentBody;

    public GoogleMultipartFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.metadataParentFolders = new List<String>();

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', this.buildMultipartContentType());
        this.requestGoogleBuilder.setParameter('uploadType', 'multipart');
    }

    public GoogleMultipartFileBuilder setContentLength(String contentLength) {
        this.requestGoogleBuilder.setHeader('Content-Length', contentLength);
        return this;
    }

    public GoogleMultipartFileBuilder setContentLength(Integer contentLength) {
        this.requestGoogleBuilder.setHeader('Content-Length', contentLength);
        return this;
    }

    public GoogleMultipartFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleMultipartFileBuilder setFileName(String fileName) {
        this.metadataFileName = fileName;
        return this;
    }

    public GoogleMultipartFileBuilder setMimeType(String mimeType) {
        this.metadataMimeType = mimeType;
        return this;
    }

    public GoogleMultipartFileBuilder setParentFolders(List<String> folderIds) {
        this.metadataParentFolders = folderIds;
        return this;
    }

    public GoogleMultipartFileBuilder setBody(String contentType, String transferEncoding, String body) {
        this.dataContentType = contentType;
        this.dataTransferEncoding = transferEncoding;
        this.dataContentBody = body;
        return this;
    }

    public GoogleMultipartFileBuilder setBody(String body) {
        this.dataContentType = 'application/octet-stream';
        this.dataTransferEncoding = 'base64';
        this.dataContentBody = body;
        return this;
    }

    public GoogleFileEntity execute() {
        this.requestGoogleBuilder.setBody(this.buildMultipartRequestBody());

        HTTPResponse uploadResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestCreateWrapper(uploadResponse);
    }

    private GoogleFileEntity retrieveRequestCreateWrapper(HTTPResponse uploadResponse) {
        if (uploadResponse.getStatusCode() == GoogleConstants.HTTP_SUCCESS_STATUS_CODE) {
            return (GoogleFileEntity) JSON.deserialize(uploadResponse.getBody(), GoogleFileEntity.class);
        } else {
            throw new CalloutException(uploadResponse.getBody());
        }
    }

    private String buildMultipartContentType() {
        return String.format(
            'multipart/{0};boundary={1}',
            new List<String>{
                GoogleConstants.MULTIPART_DEFAULT_TYPE, 
                GoogleConstants.MULTIPART_REQUEST_BOUNDARY
            }
        );
    }

    private String buildMultipartRequestBody() {
        return String.format(
            '--{0}\r\n' +
            'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
            '{1}\r\n' +
            '--{0}\r\n' +
            'Content-Type: {2}\r\n' +
            'Content-Transfer-Encoding: {3}\r\n\r\n' +
            '{4}\r\n' +
            '--{0}--',
            new List<String>{
                GoogleConstants.MULTIPART_REQUEST_BOUNDARY,
                this.buildMultipartRequestMetadata(),
                this.dataContentType,
                this.dataTransferEncoding,
                this.dataContentBody
            }
        );
    }

    private String buildMultipartRequestMetadata() {
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
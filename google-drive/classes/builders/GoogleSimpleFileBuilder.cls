public class GoogleSimpleFileBuilder implements GoogleFileCreator {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleSimpleFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setParameter('uploadType', 'media');
    }

    public GoogleSimpleFileBuilder setContentType(String contentType) {
        this.requestGoogleBuilder.setHeader('Content-Type', contentType);
        return this;
    }

    public GoogleSimpleFileBuilder setContentLength(Integer contentLength) {
        this.requestGoogleBuilder.setHeader('Content-Length', contentLength);
        return this;
    }

    public GoogleSimpleFileBuilder setBody(Blob body) {
        this.requestGoogleBuilder.setBody(body);
        return this;
    }

    public GoogleSimpleFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleFileEntity execute() {
        HTTPResponse uploadResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestCreateWrapper(uploadResponse);
    }

    private GoogleFileEntity retrieveRequestCreateWrapper(HTTPResponse uploadResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(uploadResponse.getStatusCode())) {
            return (GoogleFileEntity) JSON.deserialize(uploadResponse.getBody(), GoogleFileEntity.class);
        } else {
            throw new CalloutException(uploadResponse.getBody());
        }
    }
}
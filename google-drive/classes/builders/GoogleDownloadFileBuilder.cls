public class GoogleDownloadFileBuilder {
    public enum DownloadType {METADATA, CONTENT}
    private GoogleRequestBuilder requestGoogleBuilder;
    private DownloadType selectedDownloadType;

    public GoogleDownloadFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.selectedDownloadType = DownloadType.METADATA; // By default, only metadata is retrieved

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json');
    }

    public GoogleDownloadFileBuilder setFileDownloadType(DownloadType downloadType) {
        // The default behavior is to return only the metadata of the file, 
        // with the parameter "alt=media" the returned type is the body of the file.
        this.selectedDownloadType = downloadType;
        if (downloadType == GoogleDownloadFileBuilder.DownloadType.CONTENT) {
            this.requestGoogleBuilder.setParameter('alt', 'media');
        } else if (downloadType == GoogleDownloadFileBuilder.DownloadType.METADATA) {
            this.requestGoogleBuilder.removeParameter('alt');
        }

        return this;
    }

    public GoogleDownloadFileBuilder setSearchOnAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public GoogleFileEntity execute() {
        HTTPResponse downloadResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestDownloadWrapper(downloadResponse);
    }

    private GoogleFileEntity retrieveRequestDownloadWrapper(HTTPResponse downloadResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(downloadResponse.getStatusCode())) {
            if (this.selectedDownloadType == GoogleDownloadFileBuilder.DownloadType.METADATA) {
                return (GoogleFileEntity) JSON.deserialize(downloadResponse.getBody(), GoogleFileEntity.class);
            } else {
                GoogleFileEntity contentFileEntity = new GoogleFileEntity();
                contentFileEntity.body = downloadResponse.getBody();
                contentFileEntity.bodyAsBlob = downloadResponse.getBodyAsBlob();
                return contentFileEntity;
            }
        } else {
            throw new CalloutException(downloadResponse.getBody());
        }
    }
}
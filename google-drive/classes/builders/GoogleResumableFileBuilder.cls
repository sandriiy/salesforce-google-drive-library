public with sharing class GoogleResumableFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;
    private GoogleFileMetadataBuilder fileMetadataBuilder;

    private Blob bodyChunk;
    private String sessionUri;
    private Long initialByte;
    private Long totalBytes;

    public GoogleResumableFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.fileMetadataBuilder = new GoogleFileMetadataBuilder();

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json; charset=UTF-8');
        this.requestGoogleBuilder.setParameter('uploadType', 'resumable');
    }

    public GoogleResumableFileBuilder setStartByte(Integer initialByte) {
        this.initialByte = initialByte;
        return this;
    }

    public GoogleResumableFileBuilder setStartByte(Long initialByte) {
        this.initialByte = initialByte;
        return this;
    }

    public GoogleResumableFileBuilder setTotalBytes(Integer totalBytes) {
        this.totalBytes = totalBytes;
        return this;
    }

    public GoogleResumableFileBuilder setTotalBytes(Long totalBytes) {
        this.totalBytes = totalBytes;
        return this;
    }

    public GoogleResumableFileBuilder setExistingSessionUri(String sessionUri) {
        this.sessionUri = sessionUri;
        return this;
    }

    public GoogleResumableFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleResumableFileBuilder setFileName(String fileName) {
        this.fileMetadataBuilder.setFileProperty('name', fileName);
        return this;
    }

    public GoogleResumableFileBuilder setMimeType(String mimeType) {
        this.fileMetadataBuilder.setFileProperty('mimeType', mimeType);
        return this;
    }

    public GoogleResumableFileBuilder setParentFolders(List<String> folderIds) {
        this.fileMetadataBuilder.setFileProperty('parents', folderIds);
        return this;
    }

    public GoogleResumableFileBuilder setBody(Blob bodyPart) {
        this.bodyChunk = bodyPart;
        return this;
    }

    public GoogleResumableFileBuilder setBody(String bodyPart) {
        this.bodyChunk = EncodingUtil.base64Decode(bodyPart);
        return this;
    }

    public GoogleBigFileEntity initialize() {
        this.requestGoogleBuilder.setBody(this.fileMetadataBuilder.build());
        HTTPResponse uploadResponse = this.requestGoogleBuilder.send();
        
        GoogleBigFileEntity initialBigFile = this.retrieveRequestInitializeWrapper(uploadResponse);
        this.sessionUri = initialBigFile.resumableSessionId;
        return initialBigFile;
    }

    public GoogleBigFileEntity execute() {
        this.assertValidState();

        GoogleFileEntity uploadedFile = this.uploadFileChunk();
        if (uploadedFile == null) {
            GoogleBigFileEntity partiallyUploadedBigFile = new GoogleBigFileEntity();
            partiallyUploadedBigFile.resumableSessionId = this.sessionUri;
            partiallyUploadedBigFile.resumableLatestByte = this.initialByte;
            return partiallyUploadedBigFile;
        } else {
            GoogleBigFileEntity fullyUploadedBigFile = new GoogleBigFileEntity();
            fullyUploadedBigFile.file = uploadedFile;
            return fullyUploadedBigFile;
        }
    }


    private GoogleFileEntity uploadFileChunk() {
        GoogleRequestBuilder partRequestGoogleBuilder = this.requestGoogleBuilder.duplicate();
        partRequestGoogleBuilder.setEndpoint(this.sessionUri);
        partRequestGoogleBuilder.setMethod('PUT');
        partRequestGoogleBuilder.setHeader('Content-Length', this.bodyChunk.size());
        partRequestGoogleBuilder.setHeader('Content-Range', this.buildPartContentRange(this.bodyChunk.size()));
        partRequestGoogleBuilder.setBody(this.bodyChunk);

        HTTPResponse chunkUploadResponse = partRequestGoogleBuilder.send();
        if (GoogleConstants.HTTP_INTERRUPTED_STATUS_CODES.contains(chunkUploadResponse.getStatusCode())) {
            String uploadedChunkRange = chunkUploadResponse.getHeader('Range');
            this.calculateUploadedBytes(uploadedChunkRange);
            return null;
        } else {
            return this.retrieveRequestCreateWrapper(chunkUploadResponse);
        }
    }

    private GoogleBigFileEntity retrieveRequestInitializeWrapper(HTTPResponse uploadResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(uploadResponse.getStatusCode())) {
            GoogleBigFileEntity initializedBigFile = new GoogleBigFileEntity();
            initializedBigFile.resumableSessionId = uploadResponse.getHeader('Location');
            initializedBigFile.resumableLatestByte = GoogleConstants.UPLOAD_DEFAULT_INITIAL_BYTE;
            return initializedBigFile;
        } else {
            throw new CalloutException(uploadResponse.getBody());
        }
    }

    private GoogleFileEntity retrieveRequestCreateWrapper(HTTPResponse uploadResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(uploadResponse.getStatusCode())) {
            return (GoogleFileEntity) JSON.deserialize(uploadResponse.getBody(), GoogleFileEntity.class);
        } else {
            throw new CalloutException(uploadResponse.getBody());
        }
    }

    private String buildPartContentRange(Long partSize) {
        if (this.initialByte == null && this.totalBytes == null) {
            return '*/*';
        } else if (this.initialByte == null) {
            return '*/' + this.totalBytes;
        } else {
            Long startByte = this.initialByte;
            Long endByte = this.initialByte + partSize - 1;

            String totalBytes = this.totalBytes != null ? String.valueOf(this.totalBytes) : '*';
            return 'bytes ' + startByte + '-' + endByte + '/' + totalBytes;
        }
    }

    private void calculateUploadedBytes(String uploadedRange) {
        if (String.isNotBlank(uploadedRange)) {
            String pattern = '\\d+$'; // Matches one or more digits at the end of the string
            Pattern regex = System.Pattern.compile(pattern);
            Matcher matcher = regex.matcher(uploadedRange);

            String lastInteger = '';
            if (matcher.find()) {
                lastInteger = matcher.group(0);
            }

            this.initialByte = String.isNotBlank(lastInteger) ? Long.valueOf(lastInteger) : 0;
        }
    }

    private void assertValidState() {
        // Initialize the upload if no unique resource identifier is specified
        if (String.isBlank(this.sessionUri)) {
            this.initialize();
        }
        
        // Fail fast: How can you upload a file chunk if there is no body for it?
        if (this.bodyChunk == null || this.bodyChunk.size() == 0) {
            throw new IllegalArgumentException('File chunk body is missing. Set the body using `setBody()` before sending');
        }
    }
}
/**
 * MIT License
 *
 * Copyright (c) 2024-2026 Andrii Sukhetskyi
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

public class GoogleMultipartFileBuilder implements GoogleFileCreator {
    private GoogleRequestBuilder requestGoogleBuilder;
    private GoogleFileMetadataBuilder fileMetadataBuilder;

    private String dataContentType;
    private String dataTransferEncoding;
    private String dataContentBody;

    public GoogleMultipartFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.fileMetadataBuilder = new GoogleFileMetadataBuilder();

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

	public GoogleMultipartFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public GoogleMultipartFileBuilder setFileName(String fileName) {
        this.fileMetadataBuilder.setFileProperty('name', fileName);
        return this;
    }

    public GoogleMultipartFileBuilder setMimeType(String mimeType) {
        this.fileMetadataBuilder.setFileProperty('mimeType', mimeType);
        return this;
    }

    public GoogleMultipartFileBuilder setParentFolders(List<String> folderIds) {
        this.fileMetadataBuilder.setFileProperty('parents', folderIds);
        return this;
    }

	public GoogleMultipartFileBuilder setCustomAttributes(Map<String, Object> values) {
        this.fileMetadataBuilder.setFileProperty('appProperties', values);
        return this;
    }

    public GoogleMultipartFileBuilder setShortcutTarget(String targetId) {
        this.fileMetadataBuilder.setFileProperty(
            'shortcutDetails',
            new Map<String, Object>{
                'targetId' => targetId
            }
        );

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

    public GoogleMultipartFileBuilder setKeepRevisionForever(Boolean keepRevisionForever) {
        this.requestGoogleBuilder.setParameter('keepRevisionForever', keepRevisionForever);
        return this;
    }

    public GoogleMultipartFileBuilder setUseContentAsIndexableText(Boolean useContentAsIndexableText) {
        this.requestGoogleBuilder.setParameter('useContentAsIndexableText', useContentAsIndexableText);
        return this;
    }

    public GoogleMultipartFileBuilder setOcrLanguage(String ocrLanguage) {
        this.requestGoogleBuilder.setParameter('ocrLanguage', ocrLanguage);
        return this;
    }

    public GoogleMultipartFileBuilder addParentFolders(List<String> folderIds) {
        if (folderIds != null && !folderIds.isEmpty()) {
            this.requestGoogleBuilder.setParameter('addParents', String.join(folderIds, ','));
        }

        return this;
    }

    public GoogleMultipartFileBuilder removeParentFolders(List<String> folderIds) {
        if (folderIds != null && !folderIds.isEmpty()) {
            this.requestGoogleBuilder.setParameter('removeParents', String.join(folderIds, ','));
        }

        return this;
    }

    public GoogleFileEntity execute() {
        this.requestGoogleBuilder.setBody(this.buildMultipartRequestBody());

        HTTPResponse uploadResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestCreateWrapper(uploadResponse);
    }

    private GoogleFileEntity retrieveRequestCreateWrapper(HTTPResponse uploadResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(uploadResponse.getStatusCode())) {
            return (GoogleFileEntity) JSON.deserialize(uploadResponse.getBody(), GoogleFileEntity.class);
        } else {
			throw this.requestGoogleBuilder.error(uploadResponse.getBody());
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
        String multipartRequestBody = String.format(
            '--{0}\r\n' +
            'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
            '{1}\r\n',
            new List<String>{
                GoogleConstants.MULTIPART_REQUEST_BOUNDARY,
                this.fileMetadataBuilder.build()
            }
        );

        if (this.hasBodyContent()) {
            multipartRequestBody += String.format(
                '--{0}\r\n' +
                'Content-Type: {1}\r\n' +
                'Content-Transfer-Encoding: {2}\r\n\r\n' +
                '{3}\r\n',
                new List<String>{
                    GoogleConstants.MULTIPART_REQUEST_BOUNDARY,
                    this.dataContentType,
                    this.dataTransferEncoding,
                    this.dataContentBody
                }
            );
        }

        return multipartRequestBody + '--' + GoogleConstants.MULTIPART_REQUEST_BOUNDARY + '--';
    }

    private Boolean hasBodyContent() {
        return this.dataContentBody != null && this.dataContentBody.length() > 0;
    }
}
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

public with sharing class GoogleAsyncDownloadFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleAsyncDownloadFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Length', 0);
    }

    public GoogleAsyncDownloadFileBuilder setMimeType(String mimeType) {
        this.requestGoogleBuilder.setParameter('mimeType', mimeType);
        return this;
    }

    public GoogleAsyncDownloadFileBuilder setRevisionId(String revisionId) {
        this.requestGoogleBuilder.setParameter('revisionId', revisionId);
        return this;
    }

    public GoogleAsyncDownloadFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleOperationEntity execute() {
        HTTPResponse downloadResponse = this.requestGoogleBuilder.send();
        return this.toGoogleOperationEntity(downloadResponse);
    }

    private GoogleOperationEntity toGoogleOperationEntity(HTTPResponse downloadResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(downloadResponse.getStatusCode())) {
            return (GoogleOperationEntity) JSON.deserialize(downloadResponse.getBody(), GoogleOperationEntity.class);
        } else {
            throw this.requestGoogleBuilder.error(downloadResponse.getBody());
        }
    }
}

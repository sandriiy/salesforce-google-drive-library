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

public with sharing class GoogleRetrieveRevisionBuilder {
    public enum DownloadType {METADATA, CONTENT}

    private GoogleRequestBuilder requestGoogleBuilder;
    private DownloadType selectedDownloadType;

    public GoogleRetrieveRevisionBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.selectedDownloadType = DownloadType.METADATA;

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json');
    }

    public GoogleRetrieveRevisionBuilder setRevisionDownloadType(DownloadType downloadType) {
        this.selectedDownloadType = downloadType;
        if (downloadType == GoogleRetrieveRevisionBuilder.DownloadType.CONTENT) {
            this.requestGoogleBuilder.setParameter('alt', 'media');
        } else {
            this.requestGoogleBuilder.removeParameter('alt');
        }

        return this;
    }

    public GoogleRetrieveRevisionBuilder setAcknowledgeAbuse(Boolean isAcknowledgeAbuse) {
        this.requestGoogleBuilder.setParameter('acknowledgeAbuse', isAcknowledgeAbuse);
        return this;
    }

    public GoogleRetrieveRevisionBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleRevisionEntity execute() {
        HTTPResponse revisionResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestRevisionWrapper(revisionResponse);
    }

    private GoogleRevisionEntity retrieveRequestRevisionWrapper(HTTPResponse revisionResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(revisionResponse.getStatusCode())) {
            if (this.selectedDownloadType == GoogleRetrieveRevisionBuilder.DownloadType.CONTENT) {
                GoogleRevisionEntity downloadedRevision = new GoogleRevisionEntity();
                downloadedRevision.body = revisionResponse.getBody();
                downloadedRevision.bodyAsBlob = revisionResponse.getBodyAsBlob();
                return downloadedRevision;
            }

            return (GoogleRevisionEntity) JSON.deserialize(revisionResponse.getBody(), GoogleRevisionEntity.class);
        } else {
            throw this.requestGoogleBuilder.error(revisionResponse.getBody());
        }
    }
}

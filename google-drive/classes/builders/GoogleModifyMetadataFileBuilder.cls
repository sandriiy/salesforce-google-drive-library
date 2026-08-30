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

public with sharing class GoogleModifyMetadataFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;
    private GoogleFileMetadataBuilder fileMetadataBuilder;

    public GoogleModifyMetadataFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.fileMetadataBuilder = new GoogleFileMetadataBuilder();

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json; charset=UTF-8');
    }

    public GoogleModifyMetadataFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleModifyMetadataFileBuilder setSupportsAllDrives(Boolean supportsAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', supportsAllDrives);
        return this;
    }

    public GoogleModifyMetadataFileBuilder addParentFolders(List<String> folderIds) {
        if (folderIds != null && !folderIds.isEmpty()) {
            this.requestGoogleBuilder.setParameter('addParents', String.join(folderIds, ','));
        }

        return this;
    }

    public GoogleModifyMetadataFileBuilder removeParentFolders(List<String> folderIds) {
        if (folderIds != null && !folderIds.isEmpty()) {
            this.requestGoogleBuilder.setParameter('removeParents', String.join(folderIds, ','));
        }

        return this;
    }

    public GoogleModifyMetadataFileBuilder setFileName(String fileName) {
        this.fileMetadataBuilder.setFileProperty('name', fileName);
        return this;
    }

    public GoogleModifyMetadataFileBuilder setMimeType(String mimeType) {
        this.fileMetadataBuilder.setFileProperty('mimeType', mimeType);
        return this;
    }

    public GoogleModifyMetadataFileBuilder setDescription(String description) {
        this.fileMetadataBuilder.setFileProperty('description', description);
        return this;
    }

    public GoogleModifyMetadataFileBuilder setStarred(Boolean starred) {
        this.fileMetadataBuilder.setFileProperty('starred', starred);
        return this;
    }

    public GoogleModifyMetadataFileBuilder setTrashed(Boolean trashed) {
        this.fileMetadataBuilder.setFileProperty('trashed', trashed);
        return this;
    }

    public GoogleModifyMetadataFileBuilder setCustomAttributes(Map<String, Object> values) {
        this.fileMetadataBuilder.setFileProperty('appProperties', values);
        return this;
    }

    public GoogleFileEntity execute() {
        this.requestGoogleBuilder.setBody(this.fileMetadataBuilder.build());

        HTTPResponse response = this.requestGoogleBuilder.send();
        return this.toGoogleFileEntity(response);
    }

    private GoogleFileEntity toGoogleFileEntity(HTTPResponse response) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(response.getStatusCode())) {
            return (GoogleFileEntity) JSON.deserialize(response.getBody(), GoogleFileEntity.class);
        } else {
			throw this.requestGoogleBuilder.error(response.getBody());
		}
    }
}
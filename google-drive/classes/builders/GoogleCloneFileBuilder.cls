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

	public GoogleCloneFileBuilder setCustomAttributes(Map<String, Object> values) {
        this.fileMetadataBuilder.setFileProperty('appProperties', values);
        return this;
    }

	public GoogleCloneFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
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
			throw this.requestGoogleBuilder.error(cloneResponse.getBody());
        }
    }

    private String buildCloneFileEndpoint(String baseEndpoint, String fileId) {
        return String.format(baseEndpoint, new List<String>{fileId});
    }
}
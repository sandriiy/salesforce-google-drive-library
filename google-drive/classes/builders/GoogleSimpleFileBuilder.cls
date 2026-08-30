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

	public GoogleSimpleFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
		this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
		return this;
	}

    public GoogleSimpleFileBuilder setKeepRevisionForever(Boolean keepRevisionForever) {
        this.requestGoogleBuilder.setParameter('keepRevisionForever', keepRevisionForever);
        return this;
    }

    public GoogleSimpleFileBuilder setUseContentAsIndexableText(Boolean useContentAsIndexableText) {
        this.requestGoogleBuilder.setParameter('useContentAsIndexableText', useContentAsIndexableText);
        return this;
    }

    public GoogleSimpleFileBuilder setOcrLanguage(String ocrLanguage) {
        this.requestGoogleBuilder.setParameter('ocrLanguage', ocrLanguage);
        return this;
    }

    public GoogleSimpleFileBuilder addParentFolders(List<String> folderIds) {
        if (folderIds != null && !folderIds.isEmpty()) {
            this.requestGoogleBuilder.setParameter('addParents', String.join(folderIds, ','));
        }

        return this;
    }

    public GoogleSimpleFileBuilder removeParentFolders(List<String> folderIds) {
        if (folderIds != null && !folderIds.isEmpty()) {
            this.requestGoogleBuilder.setParameter('removeParents', String.join(folderIds, ','));
        }

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
			throw this.requestGoogleBuilder.error(uploadResponse.getBody());
        }
    }
}
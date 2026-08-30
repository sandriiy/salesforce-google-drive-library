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

	public GoogleDownloadFileBuilder setPartialRange(Integer startByte, Integer endByte) {
		String downloadRange = 'bytes=' + String.valueOf(startByte) + '-' + String.valueOf(endByte);
        this.requestGoogleBuilder.setHeader('Range', downloadRange);
        return this;
    }

	public GoogleDownloadFileBuilder setPartialRange(Long startByte, Long endByte) {
		String downloadRange = 'bytes=' + String.valueOf(startByte) + '-' + String.valueOf(endByte);
        this.requestGoogleBuilder.setHeader('Range', downloadRange);
        return this;
    }

	public GoogleDownloadFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
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
			throw this.requestGoogleBuilder.error(downloadResponse.getBody());
        }
    }
}
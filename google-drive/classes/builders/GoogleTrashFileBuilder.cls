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

public class GoogleTrashFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleTrashFileBuilder(GoogleDrive googleDriveInstance, String fileId, String endpoint) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);

		this.requestGoogleBuilder.setHeader('Content-Length', 0);
        this.requestGoogleBuilder.setEndpoint(this.buildTrashFileEndpoint(endpoint, fileId));
        this.requestGoogleBuilder.setMethod('POST');
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
    }

    public GoogleTrashFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public void execute() {
        HTTPResponse trashResponse = this.requestGoogleBuilder.send();
        this.validateTrashingPermissionRequest(trashResponse);
    }

    private void validateTrashingPermissionRequest(HTTPResponse trashResponse) {
        if (!GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(trashResponse.getStatusCode())) {
			throw this.requestGoogleBuilder.error(trashResponse.getBody());
        }
    }

    private String buildTrashFileEndpoint(String baseEndpoint, String fileId) {
        return String.format(baseEndpoint, new List<String>{fileId});
    }
}
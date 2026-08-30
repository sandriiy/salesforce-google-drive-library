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

public with sharing class GoogleDeleteDriveBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleDeleteDriveBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
    }

    public GoogleDeleteDriveBuilder setDomainAdminAccess(Boolean isDomainAdminAccess) {
        this.requestGoogleBuilder.setParameter('useDomainAdminAccess', isDomainAdminAccess);
        return this;
    }

    public GoogleDeleteDriveBuilder setAllowItemDeletion(Boolean isAllowItemDeletion) {
        this.requestGoogleBuilder.setParameter('allowItemDeletion', isAllowItemDeletion);
        return this;
    }

    public void execute() {
        HTTPResponse driveResponse = this.requestGoogleBuilder.send();
        this.validateDeletionDriveRequest(driveResponse);
    }

    private void validateDeletionDriveRequest(HTTPResponse driveResponse) {
        if (!GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(driveResponse.getStatusCode())) {
            throw this.requestGoogleBuilder.error(driveResponse.getBody());
        }
    }
}

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

public with sharing class GoogleModifyDriveBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;
    private GoogleFileMetadataBuilder fileMetadataBuilder;

    public GoogleModifyDriveBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.fileMetadataBuilder = new GoogleFileMetadataBuilder();

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json; charset=UTF-8');
    }

    public GoogleModifyDriveBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleModifyDriveBuilder setDomainAdminAccess(Boolean isDomainAdminAccess) {
        this.requestGoogleBuilder.setParameter('useDomainAdminAccess', isDomainAdminAccess);
        return this;
    }

    public GoogleModifyDriveBuilder setDriveName(String driveName) {
        this.fileMetadataBuilder.setFileProperty('name', driveName);
        return this;
    }

    public GoogleModifyDriveBuilder setThemeId(String themeId) {
        this.fileMetadataBuilder.setFileProperty('themeId', themeId);
        return this;
    }

    public GoogleModifyDriveBuilder setColorRgb(String colorRgb) {
        this.fileMetadataBuilder.setFileProperty('colorRgb', colorRgb);
        return this;
    }

    public GoogleModifyDriveBuilder setRestrictions(Map<String, Object> restrictions) {
        this.fileMetadataBuilder.setFileProperty('restrictions', restrictions);
        return this;
    }

    public GoogleDriveEntity execute() {
        String requestBody = this.fileMetadataBuilder.build();
        this.requestGoogleBuilder.setBody(requestBody);
        this.requestGoogleBuilder.setHeader('Content-Length', requestBody.length());

        HTTPResponse driveResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestDriveWrapper(driveResponse);
    }

    private GoogleDriveEntity retrieveRequestDriveWrapper(HTTPResponse driveResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(driveResponse.getStatusCode())) {
            return (GoogleDriveEntity) JSON.deserialize(driveResponse.getBody(), GoogleDriveEntity.class);
        } else {
            throw this.requestGoogleBuilder.error(driveResponse.getBody());
        }
    }
}

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

public with sharing class GoogleModifyPermissionFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;
    private GoogleFileMetadataBuilder fileMetadataBuilder;

    public GoogleModifyPermissionFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.fileMetadataBuilder = new GoogleFileMetadataBuilder();

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json; charset=UTF-8');
    }

    public GoogleModifyPermissionFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleModifyPermissionFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public GoogleModifyPermissionFileBuilder setDomainAdminAccess(Boolean isDomainAdminAccess) {
        this.requestGoogleBuilder.setParameter('useDomainAdminAccess', isDomainAdminAccess);
        return this;
    }

    public GoogleModifyPermissionFileBuilder setTransferOwnership(Boolean isTransferOwnership) {
        this.requestGoogleBuilder.setParameter('transferOwnership', isTransferOwnership);
        return this;
    }

    public GoogleModifyPermissionFileBuilder setMoveToNewOwnersRoot(Boolean isMoveToNewOwnersRoot) {
        this.requestGoogleBuilder.setParameter('moveToNewOwnersRoot', isMoveToNewOwnersRoot);
        return this;
    }

    public GoogleModifyPermissionFileBuilder setRemoveExpiration(Boolean isRemoveExpiration) {
        this.requestGoogleBuilder.setParameter('removeExpiration', isRemoveExpiration);
        return this;
    }

    public GoogleModifyPermissionFileBuilder setPrincipalRole(String role) {
        this.fileMetadataBuilder.setFileProperty('role', role);
        return this;
    }

    public GoogleModifyPermissionFileBuilder setExpirationTime(String expirationTime) {
        this.fileMetadataBuilder.setFileProperty('expirationTime', expirationTime);
        return this;
    }

    public GoogleModifyPermissionFileBuilder setPendingOwner(Boolean isPendingOwner) {
        this.fileMetadataBuilder.setFileProperty('pendingOwner', isPendingOwner);
        return this;
    }

    public GooglePermissionEntity execute() {
        String requestBody = this.fileMetadataBuilder.build();
        this.requestGoogleBuilder.setBody(requestBody);
        this.requestGoogleBuilder.setHeader('Content-Length', requestBody.length());

        HTTPResponse permissionResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestPermissionWrapper(permissionResponse);
    }

    private GooglePermissionEntity retrieveRequestPermissionWrapper(HTTPResponse permissionResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(permissionResponse.getStatusCode())) {
            return (GooglePermissionEntity) JSON.deserialize(permissionResponse.getBody(), GooglePermissionEntity.class);
        } else {
            throw this.requestGoogleBuilder.error(permissionResponse.getBody());
        }
    }
}

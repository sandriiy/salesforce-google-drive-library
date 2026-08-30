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

public class GoogleCreatePermissionFileBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;
    private Map<String, String> newPermission;

    public GoogleCreatePermissionFileBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.newPermission = new Map<String, String>();

        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setHeader('Content-Type', 'application/json');
    }

    public GoogleCreatePermissionFileBuilder setSendNotificationEmail(Boolean isSendEmail) {
        this.requestGoogleBuilder.setParameter('sendNotificationEmail', isSendEmail);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setTransferOwnership(Boolean isTransferOwnership) {
        this.requestGoogleBuilder.setParameter('transferOwnership', isTransferOwnership);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setPrincipalType(String type) {
        this.newPermission.put('type', type);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setPrincipalRole(String role) {
        this.newPermission.put('role', role);
        return this;
    }

	public GoogleCreatePermissionFileBuilder setPrincipalDomain(String domain) {
        this.newPermission.put('domain', domain);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setPrincipalEmailAddress(String emailAddress) {
        this.newPermission.put('emailAddress', emailAddress);
        return this;
    }

	public GoogleCreatePermissionFileBuilder setSupportsAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public GoogleCreatePermissionFileBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GooglePermissionEntity execute() {
        String permissionBody = this.buildPermissionFileRequestBody();
        this.requestGoogleBuilder.setHeader('Content-Length', permissionBody.length());
        this.requestGoogleBuilder.setBody(permissionBody);

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

    private String buildPermissionFileRequestBody() {
        return this.newPermission.isEmpty() ? '' : JSON.serialize(this.newPermission, true);
    }
}
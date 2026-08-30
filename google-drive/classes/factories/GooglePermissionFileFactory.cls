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

public class GooglePermissionFileFactory {
    private GoogleDrive googleDriveInstance;

    public GooglePermissionFileFactory(GoogleDrive googleDriveInstance) {
        this.googleDriveInstance = googleDriveInstance;
    }

    public GoogleCreatePermissionFileBuilder create(String fileId) {
        return new GoogleCreatePermissionFileBuilder(
            this.googleDriveInstance,
            this.buildCreatePermissionFileEndpoint(fileId),
            'POST'
        );
    }

    public GoogleDeletePermissionFileBuilder remove(String fileId, String permissionId) {
        return new GoogleDeletePermissionFileBuilder(
            this.googleDriveInstance,
            this.buildDeletePermissionFileEndpoint(fileId, permissionId),
            'DELETE'
        );
    }

	public GooglePermissionSearchBuilder search(String fileId) {
        return new GooglePermissionSearchBuilder(
            this.googleDriveInstance,
            this.buildSearchPermissionsFileEndpoint(fileId),
            'GET'
        );
    }

    public GoogleRetrievePermissionFileBuilder retrieve(String fileId, String permissionId) {
        return new GoogleRetrievePermissionFileBuilder(
            this.googleDriveInstance,
            this.buildRetrievePermissionFileEndpoint(fileId, permissionId),
            'GET'
        );
    }

    public GoogleModifyPermissionFileBuilder modify(String fileId, String permissionId) {
        return new GoogleModifyPermissionFileBuilder(
            this.googleDriveInstance,
            this.buildModifyPermissionFileEndpoint(fileId, permissionId),
            'PATCH'
        );
    }

    private String buildCreatePermissionFileEndpoint(String fileId) {
        return String.format(GoogleConstants.NEW_PERMISSION_FILE_ENDPOINT, new List<String>{fileId});
    }

	private String buildSearchPermissionsFileEndpoint(String fileId) {
        return String.format(GoogleConstants.LIST_PERMISSIONS_FILE_ENDPOINT, new List<String>{fileId});
    }

    private String buildDeletePermissionFileEndpoint(String fileId, String permissionId) {
        return String.format(
            GoogleConstants.DELETE_PERMISSION_FILE_ENDPOINT, 
            new List<String>{
                fileId,
                permissionId
            }
        );
    }

    private String buildRetrievePermissionFileEndpoint(String fileId, String permissionId) {
        return String.format(
            GoogleConstants.GET_PERMISSION_FILE_ENDPOINT,
            new List<String>{
                fileId,
                permissionId
            }
        );
    }

    private String buildModifyPermissionFileEndpoint(String fileId, String permissionId) {
        return String.format(
            GoogleConstants.UPDATE_PERMISSION_FILE_ENDPOINT,
            new List<String>{
                fileId,
                permissionId
            }
        );
    }
}

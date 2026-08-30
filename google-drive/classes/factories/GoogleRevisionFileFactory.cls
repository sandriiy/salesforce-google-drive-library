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

public with sharing class GoogleRevisionFileFactory {
    private GoogleDrive googleDriveInstance;

    public GoogleRevisionFileFactory(GoogleDrive googleDriveInstance) {
        this.googleDriveInstance = googleDriveInstance;
    }

    public GoogleRevisionSearchBuilder search(String fileId) {
        return new GoogleRevisionSearchBuilder(
            this.googleDriveInstance,
            this.buildRevisionEndpoint(GoogleConstants.LIST_REVISIONS_FILE_ENDPOINT, fileId),
            'GET'
        );
    }

    public GoogleRetrieveRevisionBuilder retrieve(String fileId, String revisionId) {
        return new GoogleRetrieveRevisionBuilder(
            this.googleDriveInstance,
            this.buildRevisionEndpoint(GoogleConstants.GET_REVISION_FILE_ENDPOINT, fileId, revisionId),
            'GET'
        );
    }

    public GoogleModifyRevisionBuilder modify(String fileId, String revisionId) {
        return new GoogleModifyRevisionBuilder(
            this.googleDriveInstance,
            this.buildRevisionEndpoint(GoogleConstants.UPDATE_REVISION_FILE_ENDPOINT, fileId, revisionId),
            'PATCH'
        );
    }

    public GoogleDeleteRevisionBuilder remove(String fileId, String revisionId) {
        return new GoogleDeleteRevisionBuilder(
            this.googleDriveInstance,
            this.buildRevisionEndpoint(GoogleConstants.DELETE_REVISION_FILE_ENDPOINT, fileId, revisionId),
            'DELETE'
        );
    }

    private String buildRevisionEndpoint(String endpoint, String fileId) {
        return String.format(endpoint, new List<String>{fileId});
    }

    private String buildRevisionEndpoint(String endpoint, String fileId, String revisionId) {
        return String.format(
            endpoint,
            new List<String>{
                fileId,
                revisionId
            }
        );
    }
}

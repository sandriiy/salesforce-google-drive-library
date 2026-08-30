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

public with sharing class GoogleModifyFileFactory {
    private GoogleDrive googleDriveInstance;

    public GoogleModifyFileFactory(GoogleDrive googleDriveInstance) {
        this.googleDriveInstance = googleDriveInstance;
    }

     /**
     * Updates a file's metadata only (name, description, parents, etc.).
     * For more information, see https://www.googleapis.com/drive/v3/files/{fileId}
     */
    public GoogleModifyMetadataFileBuilder metadata(String fileId) {
        return new GoogleModifyMetadataFileBuilder(
            this.googleDriveInstance,
            this.buildUpdateMetadataEndpoint(GoogleConstants.UPDATE_FILE_ENDPOINT, fileId),
            'PATCH'
        );
    }

    /**
     * Replaces the content of an existing file with a small media body (5 MB or less),
     * keeping the same file id and adding a revision to its version history.
    */
    public GoogleSimpleFileBuilder simpleUpdate(String fileId) {
        return new GoogleSimpleFileBuilder(
            this.googleDriveInstance,
            this.buildUpdateMetadataEndpoint(GoogleConstants.VERSION_UPLOAD_FILES_ENDPOINT, fileId),
            'PATCH'
        );
    }

    /**
     * Replaces the content of an existing file and updates its metadata in a single
     * request, for bodies of 5 MB or less, keeping the same file id and version chain.
     * Parent folders cannot travel in the body of an update - use addParentFolders
     * and removeParentFolders instead of setParentFolders.
    */
    public GoogleMultipartFileBuilder multipartUpdate(String fileId) {
        return new GoogleMultipartFileBuilder(
            this.googleDriveInstance,
            this.buildUpdateMetadataEndpoint(GoogleConstants.VERSION_UPLOAD_FILES_ENDPOINT, fileId),
            'PATCH'
        );
    }

    /**
     * Replaces the content of an existing file with a body larger than 5 MB, uploaded
     * in chunks, keeping the same file id and version chain.
     * Parent folders cannot travel in the body of an update - use addParentFolders
     * and removeParentFolders instead of setParentFolders.
    */
    public GoogleResumableFileBuilder resumableUpdate(String fileId) {
        return new GoogleResumableFileBuilder(
            this.googleDriveInstance,
            this.buildUpdateMetadataEndpoint(GoogleConstants.VERSION_UPLOAD_FILES_ENDPOINT, fileId),
            'PATCH'
        );
    }

    private String buildUpdateMetadataEndpoint(String endpoint, String fileId) {
        return String.format(endpoint, new List<String>{fileId});
    }
}
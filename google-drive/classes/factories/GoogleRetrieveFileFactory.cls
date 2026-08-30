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

public class GoogleRetrieveFileFactory {
    private GoogleDrive googleDriveInstance;

    public GoogleRetrieveFileFactory(GoogleDrive googleDriveInstance) {
        this.googleDriveInstance = googleDriveInstance;
    }

    /**
     * Gets a file's metadata or content by ID.
     * To download Google Docs, Sheets, and Slides use export() instead. 
     * For more information, see https://developers.google.com/drive/api/guides/manage-downloads
    */
    public GoogleDownloadFileBuilder download(String fileId) {
        return new GoogleDownloadFileBuilder(
            this.googleDriveInstance,
            this.buildRetrieveFileEndpoint(GoogleConstants.GET_FILE_ENDPOINT, fileId),
            'GET'
        );
    }

    /**
     * Exports a Google Workspace document to the requested MIME type and returns a GoogleFileEntity record. 
     * Note that the exported content is limited to 10MB.
    */
    public GoogleExportFileBuilder export(String fileId) {
        return new GoogleExportFileBuilder(
            this.googleDriveInstance,
            this.buildRetrieveFileEndpoint(GoogleConstants.EXPORT_FILE_ENDPOINT, fileId),
            'GET'
        );
    }

    /**
     * Asks Drive for a download URL instead of the bytes, which is the way to move a file
     * larger than the Apex heap allows: the returned link goes straight to the browser or
     * an LWC, so the content never passes through Apex.
    */
    public GoogleAsyncDownloadFileBuilder downloadLink(String fileId) {
        return new GoogleAsyncDownloadFileBuilder(
            this.googleDriveInstance,
            this.buildRetrieveFileEndpoint(GoogleConstants.DOWNLOAD_FILE_ENDPOINT, fileId),
            'POST'
        );
    }

    private String buildRetrieveFileEndpoint(String endpoint, String fileId) {
        return String.format(endpoint, new List<String>{fileId});
    }
}
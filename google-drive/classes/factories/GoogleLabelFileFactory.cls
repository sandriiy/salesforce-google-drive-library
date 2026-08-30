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

public with sharing class GoogleLabelFileFactory {
    private GoogleDrive googleDriveInstance;

    public GoogleLabelFileFactory(GoogleDrive googleDriveInstance) {
        this.googleDriveInstance = googleDriveInstance;
    }

    /**
     * Lists the labels currently applied to a file, together with the values held
     * in each of their fields.
    */
    public GoogleLabelSearchBuilder search(String fileId) {
        return new GoogleLabelSearchBuilder(
            this.googleDriveInstance,
            this.buildLabelEndpoint(GoogleConstants.LIST_LABELS_FILE_ENDPOINT, fileId),
            'GET'
        );
    }

    /**
     * Applies, updates or removes labels on a file. Build each change with a
     * GoogleLabelModificationBuilder and hand it over through addLabelModification.
    */
    public GoogleModifyLabelsFileBuilder modify(String fileId) {
        return new GoogleModifyLabelsFileBuilder(
            this.googleDriveInstance,
            this.buildLabelEndpoint(GoogleConstants.MODIFY_LABELS_FILE_ENDPOINT, fileId),
            'POST'
        );
    }

    private String buildLabelEndpoint(String endpoint, String fileId) {
        return String.format(endpoint, new List<String>{fileId});
    }
}

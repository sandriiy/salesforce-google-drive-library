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

public without sharing class GoogleDrive {
    public GoogleCredential credentials;
    public String userAgentName;
	public String failureStrategy;

    private DriveList driveStream;
    private FileList fileStream;

    /**
     * The entry point to the library. Build the credential through
     * GoogleAuthorizationCodeFlow.Builder before calling this.
     *
     * @param credentials The access token used to authorize every request made through
     * this instance, as returned by GoogleAuthorizationCodeFlow.Builder.build().
     * @param applicationName The value sent as the User-Agent header on every request.
     * Google attributes traffic by it, so name the org or the application behind the calls.
    */
    public GoogleDrive(GoogleCredential credentials, String applicationName) {
        this.credentials = credentials;
        this.userAgentName = applicationName;

        this.driveStream = new DriveList(this);
        this.fileStream = new FileList(this);
    }

    /**
     * Registers a class implementing GoogleFailureStrategy, by name, to be invoked
     * whenever a request fails. The library still throws; the strategy is there for
     * cross-cutting concerns such as logging.
     *
     * @param strategyClassName The name of a public class with a no-argument constructor
     * implementing GoogleFailureStrategy. It is resolved through Type.forName, so an inner
     * class is named as OuterClass.InnerClass.
     * @return This same instance, so the call chains onto the constructor.
    */
	public GoogleDrive withFailureStrategy(String strategyClassName) {
        this.failureStrategy = strategyClassName;
		return this;
    }

    /**
     * Operations on shared drives: search, create, retrieve, modify, remove, hide, unhide.
     *
     * @return A DriveList bound to this instance.
    */
    public DriveList drives() {
        return driveStream;
    }

    /**
     * Operations on files: search, the three upload types, retrieve, modify,
     * clone, remove and trash.
     *
     * @return A FileList bound to this instance.
    */
    public FileList files() {
        return fileStream;
    }

    /**
     * Access control for a file or a shared drive.
     * Available operations: create, retrieve, modify, search and remove.
     *
     * @return A GooglePermissionFileFactory bound to this instance.
    */
	public GooglePermissionFileFactory permissions() {
		return new GooglePermissionFileFactory(this);
	}


    /**
     * The version history of a file: search, retrieve, modify and remove revisions.
     *
     * @return A GoogleRevisionFileFactory bound to this instance.
    */
    public GoogleRevisionFileFactory revisions() {
        return new GoogleRevisionFileFactory(this);
    }

    /**
     * The labels applied to a file: search what is on it, and modify what is applied.
     *
     * @return A GoogleLabelFileFactory bound to this instance.
    */
    public GoogleLabelFileFactory labels() {
        return new GoogleLabelFileFactory(this);
    }

    /**
     * Long-running operations started elsewhere in the API.
     *
     * @return A GoogleOperationFactory bound to this instance.
    */
    public GoogleOperationFactory operations() {
        return new GoogleOperationFactory(this);
    }

    public class DriveList {
        private GoogleDrive googleDriveInstance;
        public DriveList(GoogleDrive googleDriveInstance) {
            this.googleDriveInstance = googleDriveInstance;
        }

        /**
         * Lists the shared drives the caller can reach.
         *
         * @return A GoogleDriveSearchBuilder. Page size defaults to 100 until setMaxResult is used.
        */
        public GoogleDriveSearchBuilder search() {
            return new GoogleDriveSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_DRIVES_ENDPOINT, 
                'GET'
            );
        }

        /**
         * Lists the next page of shared drives, continuing from a previous result.
         *
         * @param nextPageToken The nextPageToken carried by the previous GoogleDriveSearchResult.
         * @return A GoogleDriveSearchBuilder already positioned on that page.
        */
        public GoogleDriveSearchBuilder search(String nextPageToken) {
            GoogleDriveSearchBuilder searchBuilder = new GoogleDriveSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_DRIVES_ENDPOINT, 
                'GET'
            );

            searchBuilder.setNextPageToken(nextPageToken);
            return searchBuilder;
        }

        /**
         * Creates a shared drive. A requestId is generated for you; supply your own
         * through setRequestId when retrying the same logical create.
         *
         * @return A GoogleCreateDriveBuilder. A name is required before it is executed.
        */
        public GoogleCreateDriveBuilder create() {
            return new GoogleCreateDriveBuilder(
                googleDriveInstance,
                GoogleConstants.NEW_DRIVE_ENDPOINT,
                'POST'
            );
        }

        /**
         * Gets a shared drive's metadata by id.
         *
         * @param driveId The id of the shared drive.
         * @return A GoogleRetrieveDriveBuilder for that drive.
        */
        public GoogleRetrieveDriveBuilder retrieve(String driveId) {
            return new GoogleRetrieveDriveBuilder(
                googleDriveInstance,
                String.format(GoogleConstants.GET_DRIVE_ENDPOINT, new List<String>{driveId}),
                'GET'
            );
        }

        /**
         * Updates a shared drive's name, theme, colour or restrictions.
         *
         * @param driveId The id of the shared drive to update.
         * @return A GoogleModifyDriveBuilder for that drive.
        */
        public GoogleModifyDriveBuilder modify(String driveId) {
            return new GoogleModifyDriveBuilder(
                googleDriveInstance,
                String.format(GoogleConstants.UPDATE_DRIVE_ENDPOINT, new List<String>{driveId}),
                'PATCH'
            );
        }

        /**
         * Permanently deletes a shared drive. It must already be empty unless
         * setAllowItemDeletion is used, which an administrator can do.
         *
         * @param driveId The id of the shared drive to delete.
         * @return A GoogleDeleteDriveBuilder for that drive.
        */
        public GoogleDeleteDriveBuilder remove(String driveId) {
            return new GoogleDeleteDriveBuilder(
                googleDriveInstance,
                String.format(GoogleConstants.DELETE_DRIVE_ENDPOINT, new List<String>{driveId}),
                'DELETE'
            );
        }

        /**
         * Hides a shared drive from the caller's default view. The drive itself is untouched.
         *
         * @param driveId The id of the shared drive to hide.
         * @return A GoogleHideDriveBuilder for that drive.
        */
        public GoogleHideDriveBuilder hide(String driveId) {
            return new GoogleHideDriveBuilder(
                googleDriveInstance,
                String.format(GoogleConstants.HIDE_DRIVE_ENDPOINT, new List<String>{driveId}),
                'POST'
            );
        }

        /**
         * Restores a hidden shared drive to the caller's default view.
         *
         * @param driveId The id of the shared drive to restore.
         * @return A GoogleUnhideDriveBuilder for that drive.
        */
        public GoogleUnhideDriveBuilder unhide(String driveId) {
            return new GoogleUnhideDriveBuilder(
                googleDriveInstance,
                String.format(GoogleConstants.UNHIDE_DRIVE_ENDPOINT, new List<String>{driveId}),
                'POST'
            );
        }
    }

    public class FileList {
        private GoogleDrive googleDriveInstance;
        public FileList(GoogleDrive googleDriveInstance) {
            this.googleDriveInstance = googleDriveInstance;
        }

        /**
         * Searches for files and folders the caller can reach.
         *
         * @return A GoogleFileSearchBuilder. Page size defaults to 100 until setMaxResult is used.
        */
        public GoogleFileSearchBuilder search() {
            return new GoogleFileSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_FILES_ENDPOINT, 
                'GET'
            );
        }

        /**
         * Searches for the next page of files, continuing from a previous result.
         *
         * @param nextPageToken The nextPageToken carried by the previous GoogleFileSearchResult.
         * @return A GoogleFileSearchBuilder already positioned on that page.
        */
        public GoogleFileSearchBuilder search(String nextPageToken) {
            GoogleFileSearchBuilder searchBuilder = new GoogleFileSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_FILES_ENDPOINT, 
                'GET'
            );

            searchBuilder.setNextPageToken(nextPageToken);
            return searchBuilder;
        }

        /**
         * Use this upload type to transfer a small media file (5 MB or less) without supplying metadata.
         *
         * @return A GoogleSimpleFileBuilder. It sends no metadata, so the new file cannot be
         * given a name or a parent folder and lands in the caller's My Drive.
        */
        public GoogleSimpleFileBuilder simpleCreate() {
            return new GoogleSimpleFileBuilder(
                googleDriveInstance,
                GoogleConstants.UPLOAD_FILES_ENDPOINT,
                'POST'
            );
        }

        /**
         * Use this upload type to transfer a small file (5 MB or less) 
         * along with metadata that describes the file, in a single request.
         *
         * @return A GoogleMultipartFileBuilder.
        */
        public GoogleMultipartFileBuilder multipartCreate() {
            return new GoogleMultipartFileBuilder(
                googleDriveInstance,
                GoogleConstants.UPLOAD_FILES_ENDPOINT,
                'POST'
            );
        }

         /**
          * Use this upload type for large files (greater than 5 MB) that include metadata and are uploaded in chunks.
          * Each chunk must be represented as a split blob to be sent in the body of the HTTP request.
          *
          * @return A GoogleResumableFileBuilder. Call initialize() to open the upload session
          * before sending the first chunk.
         */
         public GoogleResumableFileBuilder resumableCreate() {
            return new GoogleResumableFileBuilder(
                googleDriveInstance,
                GoogleConstants.UPLOAD_FILES_ENDPOINT,
                'POST'
            );
        }

        /**
         * Ways of reading a file back: download for its metadata or bytes, export for
         * converting a Google Workspace document to another format, downloadLink for a URL
         * that keeps the content out of the Apex heap.
         *
         * @return A GoogleRetrieveFileFactory bound to this instance.
        */
        public GoogleRetrieveFileFactory retrieve() {
            return new GoogleRetrieveFileFactory(googleDriveInstance);
        }

        /**
         * Ways of changing an existing file: its metadata, or its content as a new
         * version through one of the three upload types.
         *
         * @return A GoogleModifyFileFactory bound to this instance.
        */
		public GoogleModifyFileFactory modify() {
            return new GoogleModifyFileFactory(googleDriveInstance);
        }

        /**
         * Creates a copy of a file, optionally renaming it or placing it elsewhere.
         *
         * @param fileId The id of the file to copy.
         * @return A GoogleCloneFileBuilder for that file.
        */
        public GoogleCloneFileBuilder clone(String fileId) {
            return new GoogleCloneFileBuilder(
                googleDriveInstance,
                fileId,
                GoogleConstants.CLONE_FILE_ENDPOINT,
                'POST'
            );
        }

        /**
         * Permanently deletes a file without sending it to the trash first.
         * Deleting an item on a shared drive requires the organizer role.
         *
         * @param fileId The id of the file to delete.
         * @return A GoogleDeleteFileBuilder for that file.
        */
        public GoogleDeleteFileBuilder remove(String fileId) {
            return new GoogleDeleteFileBuilder(
                googleDriveInstance,
                fileId,
                GoogleConstants.DELETE_FILE_ENDPOINT,
                'DELETE'
            );
        }

        /**
         * Moves a file to the trash, where the owner can still restore it.
         * Uses Drive API v2. In v3, this is done via files.update with trashed=true.
         *
         * @param fileId The id of the file to move to the trash.
         * @return A GoogleTrashFileBuilder for that file.
        */
		public GoogleTrashFileBuilder trash(String fileId) {
            return new GoogleTrashFileBuilder(
                googleDriveInstance,
                fileId,
                GoogleConstants.TRASH_FILE_ENDPOINT
            );
        }

        /**
         * Access control for a file.
         *
         * @deprecated Use GoogleDrive.permissions instead.
         * @return A GooglePermissionFileFactory bound to the owning GoogleDrive instance.
        */
        public GooglePermissionFileFactory permission() {
            return new GooglePermissionFileFactory(googleDriveInstance);
        }
    }
}
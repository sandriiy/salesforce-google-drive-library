public without sharing class GoogleDrive {
    public GoogleCredential credentials;
    public String userAgentName;

    private DriveList driveStream;
    private FileList fileStream;

    public GoogleDrive(GoogleCredential credentials, String applicationName) {
        this.credentials = credentials;
        this.userAgentName = applicationName;

        this.driveStream = new DriveList(this);
        this.fileStream = new FileList(this);
    }

    public DriveList drives() {
        return driveStream;
    }

    public FileList files() {
        return fileStream;
    }


    public class DriveList {
        private GoogleDrive googleDriveInstance;
        public DriveList(GoogleDrive googleDriveInstance) {
            this.googleDriveInstance = googleDriveInstance;
        }

        public GoogleDriveSearchBuilder search() {
            return new GoogleDriveSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_DRIVES_ENDPOINT, 
                'GET'
            );
        }

        public GoogleDriveSearchBuilder search(String nextPageToken) {
            GoogleDriveSearchBuilder searchBuilder = new GoogleDriveSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_DRIVES_ENDPOINT, 
                'GET'
            );

            searchBuilder.setNextPageToken(nextPageToken);
            return searchBuilder;
        }
    }

    public class FileList {
        private GoogleDrive googleDriveInstance;
        public FileList(GoogleDrive googleDriveInstance) {
            this.googleDriveInstance = googleDriveInstance;
        }

        public GoogleFileSearchBuilder search() {
            return new GoogleFileSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_FILES_ENDPOINT, 
                'GET'
            );
        }

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
         */
         public GoogleResumableFileBuilder resumableCreate() {
            return new GoogleResumableFileBuilder(
                googleDriveInstance,
                GoogleConstants.UPLOAD_FILES_ENDPOINT,
                'POST'
            );
        }

        public GoogleRetrieveFileFactory retrieve() {
            return new GoogleRetrieveFileFactory(googleDriveInstance);
        } 

        public GoogleCloneFileBuilder clone(String fileId) {
            return new GoogleCloneFileBuilder(
                googleDriveInstance,
                fileId,
                GoogleConstants.CLONE_FILE_ENDPOINT,
                'POST'
            );
        }

        public GoogleDeleteFileBuilder remove(String fileId) {
            return new GoogleDeleteFileBuilder(
                googleDriveInstance,
                fileId,
                GoogleConstants.DELETE_FILE_ENDPOINT,
                'DELETE'
            );
        }

        public GooglePermissionFileFactory permission() {
            return new GooglePermissionFileFactory(googleDriveInstance);
        }
    }
}
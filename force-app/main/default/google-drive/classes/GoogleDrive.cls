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

        public GoogleSimpleFileBuilder simpleCreate() {
            return new GoogleSimpleFileBuilder(
                googleDriveInstance,
                GoogleConstants.UPLOAD_FILES_ENDPOINT,
                'POST'
            );
        }

        public GoogleMultipartFileBuilder multipartCreate() {
            return new GoogleMultipartFileBuilder(
                googleDriveInstance,
                GoogleConstants.UPLOAD_FILES_ENDPOINT,
                'POST'
            );
        }
    }
}
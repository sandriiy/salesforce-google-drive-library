public without sharing class GoogleDrive {
    private GoogleCredential credentials;
    private String userAgentName;

    private DriveList driveStream;
    private FileList fileStream;
    private FolderList folderStream;

    public GoogleDrive(GoogleCredential credentials, String applicationName) {
        this.credentials = credentials;
        this.userAgentName = applicationName;

        this.driveStream = new DriveList(this);
        this.fileStream = new FileList(this);
        this.folderStream = new FolderList(this);
    }

    public DriveList drives() {
        return driveStream;
    }

    public FileList files() {
        return fileStream;
    }

    public FolderList folders() {
        return folderStream;
    }


    public class DriveList {
        private GoogleDrive googleDriveInstance;
        public DriveList(GoogleDrive googleDriveInstance) {
            this.googleDriveInstance = googleDriveInstance;
        }

        public GDriveSearchResult search(Integer maxResult, String searchQuery, Boolean isDomainAdminAccess) {
            HTTPResponse searchResponse = new GoogleDrive.GoogleRequestBuilder(this.googleDriveInstance)
                .setEndpoint(GoogleConstants.SEARCH_DRIVES_ENDPOINT)
                .setMethod('GET')
                .setHeader('User-Agent', this.googleDriveInstance.userAgentName)
                .setParameter('pageSize', maxResult)
                .setParameter('q', searchQuery)
                .setParameter('useDomainAdminAccess', isDomainAdminAccess)
                .send();

            return this.retrieveRequestSearchWrapper(searchResponse);
        }

        public GDriveSearchResult search(String nextPageToken) {
            HTTPResponse searchResponse = new GoogleDrive.GoogleRequestBuilder(this.googleDriveInstance)
                .setEndpoint(GoogleConstants.SEARCH_DRIVES_ENDPOINT)
                .setMethod('GET')
                .setHeader('User-Agent', this.googleDriveInstance.userAgentName)
                .setParameter('pageToken', nextPageToken)
                .send();

            return this.retrieveRequestSearchWrapper(searchResponse);
        }

        private GDriveSearchResult retrieveRequestSearchWrapper(HTTPResponse searchResponse) {
            if (searchResponse.getStatusCode() == GoogleConstants.HTTP_SUCCESS_STATUS_CODE) {
                return (GDriveSearchResult) JSON.deserialize(searchResponse.getBody(), GDriveSearchResult.class);
            } else {
                throw new CalloutException(searchResponse.getBody());
            }
        }
    }

    public class FileList {
        private GoogleDrive googleDriveInstance;
        public FileList(GoogleDrive googleDriveInstance) {
            this.googleDriveInstance = googleDriveInstance;
        }
    }

    public class FolderList {
        private GoogleDrive googleDriveInstance;
        public FolderList(GoogleDrive googleDriveInstance) {
            this.googleDriveInstance = googleDriveInstance;
        }
    }

    public class GoogleRequestBuilder {
        private GoogleDrive googleDriveInstance;

        private String endpoint;
        private String method;
        private Map<String, String> headers;
        private Map<String, String> parameters;
        private String bodyAsString;
        private Blob bodyAsBlob;

        public GoogleRequestBuilder(GoogleDrive googleDriveInstance) {
            this.googleDriveInstance = googleDriveInstance;
            this.headers = new Map<String, String>();
            this.parameters = new Map<String, String>();
        }

        public GoogleRequestBuilder setEndpoint(String endpoint) {
            this.endpoint = endpoint;
            return this;
        }

        public GoogleRequestBuilder setMethod(String method) {
            this.method = method;
            return this;
        }

        public GoogleRequestBuilder setHeader(String key, String value) {
            this.headers.put(key, value);
            return this;
        }

        public GoogleRequestBuilder setParameter(String key, String value) {
            this.parameters.put(key, EncodingUtil.urlEncode(value, 'UTF-8'));
            return this;
        }

        public GoogleRequestBuilder setParameter(String key, Integer value) {
            this.parameters.put(key, EncodingUtil.urlEncode(String.valueOf(value), 'UTF-8'));
            return this;
        }

        public GoogleRequestBuilder setParameter(String key, Boolean value) {
            this.parameters.put(key, EncodingUtil.urlEncode(String.valueOf(value), 'UTF-8'));
            return this;
        }

        public GoogleRequestBuilder setBody(String body) {
            this.bodyAsString = body;
            return this;
        }

        public GoogleRequestBuilder setBody(Blob body) {
            this.bodyAsBlob = body;
            return this;
        }

        public HTTPResponse send() {
            HttpRequest req = new HttpRequest();
            req.setMethod(this.method);

            this.buildEndpointUrl(req);
            this.buildEndpointHeaders(req);
            this.buildEndpointBody(req);

            Http http = new Http();
            return http.send(req); // NEED TO CHECK IF REFRESH TOKEN IS THERE, IF SO - TRY TO REFRESH ACCESS TOKEN
        }

        private void buildEndpointUrl(HttpRequest req) {
            List<String> parameterKeys = new List<String>(this.parameters.keySet());
            for (Integer i = 0; i < parameterKeys.size(); i++) {
                String parameterKey = parameterKeys.get(i);
                String parameterValue = this.parameters.get(parameterKey);

                if (i == 0) {
                    this.endpoint += ('?' + parameterKey + '=' + parameterValue);
                } else {
                    this.endpoint += ('&' + parameterKey + '=' + parameterValue);
                }
            }

            req.setEndpoint(this.endpoint);
        }

        private void buildEndpointHeaders(HttpRequest req) {
            for (String headerKey : this.headers.keySet()) {
                String headerParameter = this.headers.get(headerKey);
                req.setHeader(headerKey, headerParameter);
            }

            this.buildAuthorizationHeader(req);
        }

        private void buildAuthorizationHeader(HttpRequest req) {
            req.setHeader(
                'Authorization', 
                this.googleDriveInstance.credentials.tokenType + ' ' + this.googleDriveInstance.credentials.accessToken
            );
        }

        private void buildEndpointBody(HttpRequest req) {
            if (String.isNotBlank(this.bodyAsString)) {
                req.setBody(this.bodyAsString);
            } else if (this.bodyAsBlob != null) {
                req.setBodyAsBlob(this.bodyAsBlob);
            }
        }
    }
}
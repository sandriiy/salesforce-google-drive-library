public without sharing class GoogleDrive {
    private GoogleCredential credentials;
    private String userAgentName;

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

        public DriveSearchBuilder search() {
            return new DriveSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_DRIVES_ENDPOINT, 
                'GET'
            );
        }

        public DriveSearchBuilder search(String nextPageToken) {
            DriveSearchBuilder searchBuilder = new DriveSearchBuilder(
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

        public FileSearchBuilder search() {
            return new FileSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_FILES_ENDPOINT, 
                'GET'
            );
        }

        public FileSearchBuilder search(String nextPageToken) {
            FileSearchBuilder searchBuilder = new FileSearchBuilder(
                googleDriveInstance, 
                GoogleConstants.SEARCH_FILES_ENDPOINT, 
                'GET'
            );

            searchBuilder.setNextPageToken(nextPageToken);
            return searchBuilder;
        }
    }

    public class DriveSearchBuilder {
        private GoogleRequestBuilder requestGoogleBuilder;

        public DriveSearchBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
            this.requestGoogleBuilder = new GoogleDrive.GoogleRequestBuilder(googleDriveInstance);
            this.requestGoogleBuilder.setEndpoint(endpoint);
            this.requestGoogleBuilder.setMethod(method);
            this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
            this.requestGoogleBuilder.setParameter('pageSize', GoogleConstants.SEARCH_DEFAULT_PAGE_SIZE);
        }

        public DriveSearchBuilder setMaxResult(Integer maxResult) {
            this.requestGoogleBuilder.setParameter('pageSize', maxResult);
            return this;
        }

        public DriveSearchBuilder setSearchQuery(String query) {
            this.requestGoogleBuilder.setParameter('q', query);
            return this;
        }

        public DriveSearchBuilder setDomainAdminAccess(Boolean isDomainAdminAccess) {
            this.requestGoogleBuilder.setParameter('useDomainAdminAccess', isDomainAdminAccess);
            return this;
        }

        public DriveSearchBuilder setNextPageToken(String pageToken) {
            this.requestGoogleBuilder.setParameter('pageToken', pageToken);
            return this;
        }

        public GDriveSearchResult execute() {
            HTTPResponse searchResponse = this.requestGoogleBuilder.send();
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

    public class FileSearchBuilder {
        private GoogleRequestBuilder requestGoogleBuilder;

        public FileSearchBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
            this.requestGoogleBuilder = new GoogleDrive.GoogleRequestBuilder(googleDriveInstance);
            this.requestGoogleBuilder.setEndpoint(endpoint);
            this.requestGoogleBuilder.setMethod(method);
            this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
            this.requestGoogleBuilder.setParameter('pageSize', GoogleConstants.SEARCH_DEFAULT_PAGE_SIZE);
        }

        public FileSearchBuilder setMaxResult(Integer maxResult) {
            this.requestGoogleBuilder.setParameter('pageSize', maxResult);
            return this;
        }

        public FileSearchBuilder setSearchQuery(String query) {
            this.requestGoogleBuilder.setParameter('q', query);
            return this;
        }

        public FileSearchBuilder setNextPageToken(String pageToken) {
            this.requestGoogleBuilder.setParameter('pageToken', pageToken);
            return this;
        }

        public FileSearchBuilder setOrderBy(String orderBy) {
            this.requestGoogleBuilder.setParameter('orderBy', orderBy);
            return this;
        }

        public FileSearchBuilder setDriveId(String driveId) {
            this.requestGoogleBuilder.setParameter('driveId', driveId);
            return this;
        }

        public FileSearchBuilder setSearchOnAllDrives(Boolean includeAllDrives) {
            this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
            this.requestGoogleBuilder.setParameter('includeItemsFromAllDrives', includeAllDrives);
            return this;
        }

        public GFileSearchResult execute() {
            HTTPResponse searchResponse = this.requestGoogleBuilder.send();
            return this.retrieveRequestSearchWrapper(searchResponse);
        }

        private GFileSearchResult retrieveRequestSearchWrapper(HTTPResponse searchResponse) {
            if (searchResponse.getStatusCode() == GoogleConstants.HTTP_SUCCESS_STATUS_CODE) {
                return (GFileSearchResult) JSON.deserialize(searchResponse.getBody(), GFileSearchResult.class);
            } else {
                throw new CalloutException(searchResponse.getBody());
            }
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
            return http.send(req);
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
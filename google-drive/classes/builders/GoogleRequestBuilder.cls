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

    public GoogleRequestBuilder duplicate() {
        GoogleRequestBuilder clonedGoogleRequest = this.clone();
        clonedGoogleRequest.bodyAsString = null;
        clonedGoogleRequest.bodyAsBlob = null;
        clonedGoogleRequest.headers = new Map<String, String>();
        clonedGoogleRequest.parameters = new Map<String, String>();

        return clonedGoogleRequest;
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

    public GoogleRequestBuilder setHeader(String key, Integer value) {
        this.headers.put(key, String.valueOf(value));
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

    public GoogleRequestBuilder removeParameter(String key) {
        this.parameters.remove(key);
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
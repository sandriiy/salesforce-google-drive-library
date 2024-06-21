public class GoogleDriveHttpMockGenerator implements HttpCalloutMock {
    private String mockEndpoint;
    private Integer mockStatusCode;
    private String mockBody;
    private Map<String, String> mockHeaders; 
    private HttpResponse mockResponse;

    public GoogleDriveHttpMockGenerator(String endpoint, Integer statusCode, String body) {
        this.mockEndpoint = endpoint;
        this.mockStatusCode = statusCode;
        this.mockBody = body;
    }

    public GoogleDriveHttpMockGenerator(String endpoint, Integer statusCode, String body, Map<String, String> headers) {
        this.mockEndpoint = endpoint;
        this.mockStatusCode = statusCode;
        this.mockBody = body;
        this.mockHeaders = headers;
    }

    public HTTPResponse respond(HttpRequest req) {
        return this.createMockResponse();
    }

    private HttpResponse createMockResponse() {
        HttpResponse mockResponse = new HttpResponse();
        this.buildMockResponseHeaders(mockResponse);
        this.buildMockResponseBody(mockResponse);
        this.buildMockResponseCode(mockResponse);
        return mockResponse;
    }

    private void buildMockResponseHeaders(HttpResponse mockResponse) {
        if (this.mockHeaders != null && this.mockHeaders.size() > 0) {
            for (String headerKey : this.mockHeaders.keySet()) {
                mockResponse.setHeader(headerKey, this.mockHeaders.get(headerKey));
            }
        }
    }

    private void buildMockResponseBody(HttpResponse mockResponse) {
        if (String.isNotBlank(this.mockBody)) {
            mockResponse.setBody(this.mockBody);
        }
    }

    private void buildMockResponseCode(HttpResponse mockResponse) {
        if (this.mockStatusCode != null) {
            mockResponse.setStatusCode(this.mockStatusCode);
        }
    }
}
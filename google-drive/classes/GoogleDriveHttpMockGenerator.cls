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
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
		req.setTimeout(60000);

        this.buildEndpointUrl(req);
        this.buildEndpointHeaders(req);
        this.buildEndpointBody(req);

        Http http = new Http();
        return http.send(req);
    }

	public GoogleCloudException error(String message) {
		GoogleCloudException newException = new GoogleCloudException(message);
		newException.endpoint = this.endpoint;
		newException.httpHeaders = this.headers;
		newException.httpParameters = this.parameters;

		// Invoke the configured failure strategy, if any.
		this.buildFailureStrategy(newException);

		return newException;
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
            if (this.isRejectedContentLengthHeader(headerKey)) continue;

            String headerParameter = this.headers.get(headerKey);
            req.setHeader(headerKey, headerParameter);
        }

        this.buildAuthorizationHeader(req);
    }

    /**
     * Salesforce throws a CalloutException when Content-Length is set by hand on a PATCH
     * callout, and works the value out on its own, so the header is dropped.
    */
    private Boolean isRejectedContentLengthHeader(String headerKey) {
        return 'PATCH'.equalsIgnoreCase(this.method) && 'Content-Length'.equalsIgnoreCase(headerKey);
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

	private void buildFailureStrategy(GoogleCloudException newException) {
		String failureStrategyClassName = this.googleDriveInstance.failureStrategy;
		if (String.isBlank(failureStrategyClassName)) return;
		
		Type strategyType = Type.forName(failureStrategyClassName);
		GoogleFailureStrategy strategyInstance = (GoogleFailureStrategy) strategyType.newInstance();
		strategyInstance.onFailure(newException);
	}
}
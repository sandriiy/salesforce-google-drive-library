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

public class GoogleFileSearchBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleFileSearchBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setParameter('pageSize', GoogleConstants.SEARCH_DEFAULT_PAGE_SIZE);
    }

    public GoogleFileSearchBuilder setMaxResult(Integer maxResult) {
        this.requestGoogleBuilder.setParameter('pageSize', maxResult);
        return this;
    }

    public GoogleFileSearchBuilder setSearchQuery(String query) {
        this.requestGoogleBuilder.setParameter('q', query);
        return this;
    }

    public GoogleFileSearchBuilder setNextPageToken(String pageToken) {
        this.requestGoogleBuilder.setParameter('pageToken', pageToken);
        return this;
    }

    public GoogleFileSearchBuilder setFields(String fields) {
        this.requestGoogleBuilder.setParameter('fields', fields);
        return this;
    }

    public GoogleFileSearchBuilder setOrderBy(String orderBy) {
        this.requestGoogleBuilder.setParameter('orderBy', orderBy);
        return this;
    }

    public GoogleFileSearchBuilder setDriveId(String driveId) {
        this.requestGoogleBuilder.setParameter('driveId', driveId);
        this.requestGoogleBuilder.setParameter('corpora', GoogleConstants.SEARCH_DRIVE_CORPORA);
        return this;
    }

    public GoogleFileSearchBuilder setSearchOnAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        this.requestGoogleBuilder.setParameter('includeItemsFromAllDrives', includeAllDrives);
        return this;
    }

    public GoogleFileSearchResult execute() {
        HTTPResponse searchResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestSearchWrapper(searchResponse);
    }

    private GoogleFileSearchResult retrieveRequestSearchWrapper(HTTPResponse searchResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(searchResponse.getStatusCode())) {
            return (GoogleFileSearchResult) JSON.deserialize(searchResponse.getBody(), GoogleFileSearchResult.class);
        } else {
			throw this.requestGoogleBuilder.error(searchResponse.getBody());
        }
    }
}
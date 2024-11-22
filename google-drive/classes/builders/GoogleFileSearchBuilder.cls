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
            throw new CalloutException(searchResponse.getBody());
        }
    }
}
public class GoogleDriveSearchBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GoogleDriveSearchBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setParameter('pageSize', GoogleConstants.SEARCH_DEFAULT_PAGE_SIZE);
    }

    public GoogleDriveSearchBuilder setMaxResult(Integer maxResult) {
        this.requestGoogleBuilder.setParameter('pageSize', maxResult);
        return this;
    }

    public GoogleDriveSearchBuilder setSearchQuery(String query) {
        this.requestGoogleBuilder.setParameter('q', query);
        return this;
    }

    public GoogleDriveSearchBuilder setDomainAdminAccess(Boolean isDomainAdminAccess) {
        this.requestGoogleBuilder.setParameter('useDomainAdminAccess', isDomainAdminAccess);
        return this;
    }

    public GoogleDriveSearchBuilder setNextPageToken(String pageToken) {
        this.requestGoogleBuilder.setParameter('pageToken', pageToken);
        return this;
    }

    public GoogleDriveSearchResult execute() {
        HTTPResponse searchResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestSearchWrapper(searchResponse);
    }

    private GoogleDriveSearchResult retrieveRequestSearchWrapper(HTTPResponse searchResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(searchResponse.getStatusCode())) {
            return (GoogleDriveSearchResult) JSON.deserialize(searchResponse.getBody(), GoogleDriveSearchResult.class);
        } else {
            throw new CalloutException(searchResponse.getBody());
        }
    }
}
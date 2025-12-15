public with sharing class GooglePermissionSearchBuilder {
    private GoogleRequestBuilder requestGoogleBuilder;

    public GooglePermissionSearchBuilder(GoogleDrive googleDriveInstance, String endpoint, String method) {
        this.requestGoogleBuilder = new GoogleRequestBuilder(googleDriveInstance);
        this.requestGoogleBuilder.setEndpoint(endpoint);
        this.requestGoogleBuilder.setMethod(method);
        this.requestGoogleBuilder.setHeader('User-Agent', googleDriveInstance.userAgentName);
        this.requestGoogleBuilder.setParameter('pageSize', GoogleConstants.SEARCH_DEFAULT_PAGE_SIZE);
    }

    public GooglePermissionSearchBuilder setMaxResult(Integer maxResult) {
        this.requestGoogleBuilder.setParameter('pageSize', maxResult);
        return this;
    }

    public GooglePermissionSearchBuilder setNextPageToken(String pageToken) {
        this.requestGoogleBuilder.setParameter('pageToken', pageToken);
        return this;
    }

    public GooglePermissionSearchBuilder setFields(String fields) {
		String fieldsQuery = fields.contains('permissions')
			? fields
			: 'permissions(' + fields + ')';

        this.requestGoogleBuilder.setParameter('fields', fieldsQuery);
        return this;
    }

    public GooglePermissionSearchBuilder setSearchOnAllDrives(Boolean includeAllDrives) {
        this.requestGoogleBuilder.setParameter('supportsAllDrives', includeAllDrives);
        return this;
    }

    public GooglePermissionSearchResult execute() {
        HTTPResponse searchResponse = this.requestGoogleBuilder.send();
        return this.retrieveRequestPermissionWrapper(searchResponse);
    }

    private GooglePermissionSearchResult retrieveRequestPermissionWrapper(HTTPResponse searchResponse) {
        if (GoogleConstants.HTTP_SUCCESS_STATUS_CODES.contains(searchResponse.getStatusCode())) {
            return (GooglePermissionSearchResult) JSON.deserialize(searchResponse.getBody(), GooglePermissionSearchResult.class);
        } else {
            throw new GoogleCloudException(searchResponse.getBody());
        }
    }
}
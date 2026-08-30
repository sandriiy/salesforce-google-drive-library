# Getting Started

The library presents the search result in a specialized wrapper called `GoogleDriveSearchResult`. This wrapper contains two public variables: 'nextPageToken', which indicates that there are more results than could be returned in a single request, and this token can be used to retrieve the next set of results, and 'drives' - which represents the `GoogleDriveEntity` instances, which were returned as search results.

To search for drives, we use the <a href="https://developers.google.com/drive/api/reference/rest/v3/drives/list">drives.list</a> method provided by the Google Drive API. The main feature of the Google Drive search operation is the use of a special `q` search query, which defines the conditions and types of drives to be returned. See <a href="https://developers.google.com/drive/api/guides/search-shareddrives">Search for shared drives</a> for details.

## Search for drives in Google Drive

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleDriveSearchResult result = testGoogleDrive.drives().search()
    .setMaxResult(50)
    .setSearchQuery('')
    .setDomainAdminAccess(false)
    .execute();
```
In the example above, the search result is limited to 50 drives (the maximum limit set by the Google Drive API is 100 per request). If there are more than 50 such drives, the `nextPageToken` variable will be returned filled, which can be used to get the next set of drives. See below for how to use the token to get the next set of drives.
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleDriveSearchResult result = testGoogleDrive.drives().search('4mzkteXuXufI6lXV4mzkteXuXufI6lXV')
    .execute();
```
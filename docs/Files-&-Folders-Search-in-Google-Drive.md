# Getting Started

The library presents the search result in a specialized wrapper called `GoogleFileSearchResult`. This wrapper contains two public variables: 'nextPageToken', which indicates that there are more results than could be returned in a single request and this token can be used to retrieve the next set of results, and 'files' - which represents the `GoogleFileEntity` instances that were returned as search results.

To search for files and folders (they are considered the same entity and will always be perceived as such), we use the <a href="https://developers.google.com/drive/api/reference/rest/v3/files/list">files.list</a> method provided by the Google Drive API. The main feature of the Google Drive search operation is the use of a special `q` search query, which defines the conditions and types of files and/or folders to be returned. See <a href="https://developers.google.com/drive/api/guides/search-files">Search for files and folders</a> for details.

## <span id="files-search">Search for files in Google Drive<span>

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileSearchResult result = testGoogleDrive.files().search()
    .setMaxResult(3)
    .setSearchQuery('trashed = false')
    .setSearchOnAllDrives(true)
    .setFields('files(id,name)')
    .setDriveId('1aB2cD3eF4gHIjkLMnOPqRstUvWxYz-_0')
    .setOrderBy('folder,modifiedTime desc,name')
    .execute();
```
In the example above, the search result is limited to 3 files (the maximum limit set by the Google Drive API is 100 per request). If there are more than 3 such files, the `nextPageToken` variable will be returned filled, which can be used to get the next set of files, also limited to three. Thus, sooner or later, it is possible to retrieve all search results. See below for how to use the token to get the next set of files.
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileSearchResult result = testGoogleDrive.files().search('~!!~BI9FV7ThOnDGgvVJDf_o4en1NZxEOJxjGmloO1QwivWraJd4UKiAAiFaEyV==')
    .setOrderBy('name')
    .execute();
```
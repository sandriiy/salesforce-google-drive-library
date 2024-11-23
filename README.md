<div align="center">
  <p>
    <a href="https://www.youtube.com/watch?v=Q35QwAvSrP0" target="_blank">
      <img src="https://img.shields.io/badge/%20View%20Demo-blue?style=flat-square&logo=youtube" alt="View Demo">
    </a>
    <a href="https://github.com/sandriiy/salesforce-google-drive-library/issues/new?labels=bug&template=bug_report.md">
      <img src="https://img.shields.io/badge/🐛%20Report%20Bug-red" alt="Report Bug">
    </a>
    <a href="https://github.com/sandriiy/salesforce-google-drive-library/issues/new?labels=enhancement&template=feature_request.md">
      <img src="https://img.shields.io/badge/✨%20Request%20Feature-green" alt="Request Feature">
    </a>
  </p>

  [![Watch on GitHub](https://img.shields.io/github/watchers/sandriiy/salesforce-google-drive-library.svg?style=social)](https://github.com/sandriiy/salesforce-google-drive-library/watchers)
  [![Star on GitHub](https://img.shields.io/github/stars/sandriiy/salesforce-google-drive-library.svg?style=social)](https://github.com/sandriiy/salesforce-google-drive-library/stargazers)
</div>

## <span id="getting-started">Getting Started</span>

The Salesforce Apex Google Drive Library offers programmatic access to Google Drive through API methods. This library simplifies coding against these APIs by providing robust methods for creating, cloning, downloading, sharing, and searching files, drives and permissions. Its implementation is accompanied by a newer version of the Google Drive API v3. You can read about the benefits [here](https://developers.google.com/drive/api/guides/v3versusv2)

You can find the integration configuration, including both the Google Cloud and Salesforce sides, along with all the methods, details, and challenges, in the Wiki of this repository at the [following link](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Quick-Setup-Guide)

To get started with the Apex Google Drive library, its code needs to be deployed to your environment. All the code can either be deployed directly, contained in the `google-drive` folder and fully self-contained, or the Unlocked Package can be installed for a more modular setup of the library code. If the Unlocked Package is of interest, the two buttons below, depending on the environment, can be used to install the latest version:

<div align="center" style="display: flex; justify-content: space-between;">
  <a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04tJ80000000RffIAE">
    <img src="https://img.shields.io/badge/Install%20In%20Sandbox-blue?style=for-the-badge&logo=salesforce" alt="Install the Unlocked Package in Sandbox">
  </a>
  <a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04tJ80000000RffIAE">
    <img src="https://img.shields.io/badge/Install%20In%20Production-blue?style=for-the-badge&logo=salesforce" alt="Install the Unlocked Package in Production">
  </a>
</div>
<br>

> [!NOTE]  
> I am currently consolidating all efforts to move the documentation from the README file to the GitHub Wiki, so some elements may be available in one place but not the other, and vice versa.

<br>

# Navigator
- [Getting Started](#getting-started)
- [Files and Folders Management](#files-manage)
  - [Upload a file to Google Drive](#file-upload)
  - [Clone a file to Google Drive](#file-clone)
  - [Download and Export Google Drive files](#file-downld)
  - [Delete Google Drive files](#file-deletes)
- [Files and Folders Search](#files-search)
- [Drives Search](#drives-search)
- [Permissions Management](#permissions)
- [Acknowledgments](#info)

<br>

## <span id="files-manage">Files and Folders Management</span>
The library presents the result of creating/cloning/uploading/exporting a file in a custom wrapper called `GoogleFileEntity`. This wrapper includes a set of all possible attributes that the Google Drive API can return. It also contains two attributes, `body` and `bodyAsBlob`, which were added to represent the content of the document if it was returned from Google Drive.

### <span id="file-upload">Upload a file to Google Drive</span>

This part of the documentation was migrated to the GitHub Wiki as part of the [Release-1.0.0](https://github.com/sandriiy/salesforce-google-drive-library/releases/tag/v1.0.0) which introduced a third method for uploading large files from Salesforce. See the migrated documentation [here](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Uploading-Files-to-Google-Drive)

### <span id="file-clone">Clone a file to Google Drive</span>
The library uses the existing Google Drive API capabilities to <a href="https://developers.google.com/drive/api/reference/rest/v3/files/copy">create copies<a> of the file and applies any requested updates with patch semantics.

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().clone(testFileId)
    .setFields('id, name')
    .setFileName('CopiedDocument')
    .setMimeType('application/vnd.google-apps.document')
    .setParentFolders(new List<String>{'1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw'})
    .execute();
```

### <span id="file-downld">Download and Export Google Drive files</span>
The library utilizes existing methods for retrieving files from Google Drive while providing clear and intuitive tools for this task. A key aspect of retrieving files according to the Google Drive structure is the distinction between <a href="https://developers.google.com/drive/api/guides/mime-types">Google Workspace files</a> and others. If the file in Google Drive is of the 'Google Document' type, a special endpoint called <a href="https://developers.google.com/drive/api/reference/rest/v3/files/export">export</a> is required to retrieve it. Conversely, if the file is of the 'PNG' or 'Microsoft Word' type, another endpoint called <a href="https://developers.google.com/drive/api/reference/rest/v3/files/get">get</a> is used.

#### Download a regular file from Google Drive

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().retrieve().download(testFileId)
    .setFileDownloadType(GoogleDownloadFileBuilder.DownloadType.CONTENT)
    .execute();
```
In the example above, the body of the document is downloaded from Google Drive, provided that the file is not of the Google Workspace type. Note the `setFileDownloadType()` method, which sets the return type to content. If you only need to retrieve the metadata of the file without its actual content, use the following syntax:
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().retrieve().download(testFileId)
    .setFileDownloadType(GoogleDownloadFileBuilder.DownloadType.METADATA)
    .setSearchOnAllDrives(false)
    .execute();
```

#### Export Google Workspace file from Google Drive
Exports a Google Workspace document to the desired MIME type and returns the exported byte content. Note that the exported content is limited to 10 MB. If you need to obtain a JSON representation of the file (which is possible with Google Workspace files), specify the appropriate MIME type from <a href="https://developers.google.com/drive/api/guides/mime-types">this list</a>.
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().retrieve().export(testFileId)
    .setMimeType('text/plain')
    .execute();
```

### <span id="file-deletes">Delete File from Google Drive</span>
Permanently deletes a file owned by the user without moving it to the trash. If the file belongs to a shared drive, the user must be an organizer on the parent folder. If the target is a folder, all descendants owned by the user are also deleted.
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  testGoogleDrive.files().remove(testFileId)
    .setSupportsAllDrives(true)
    .execute();
```

<br>

## <span id="files-search">Files and Folders Search<span>
The library presents the search result in a specialized wrapper called `GoogleFileSearchResult`. This wrapper contains two public variables: 'nextPageToken', which indicates that there are more results than could be returned in a single request and this token can be used to retrieve the next set of results, and 'files' - which represents the `GoogleFileEntity` records that were returned as search results.

To search for files and folders (as already mentioned, they are considered the same entity and will always be perceived as such), we use the <a href="https://developers.google.com/drive/api/reference/rest/v3/files/list">files.list</a> method provided by the Google Drive API. The main feature of the Google Drive search operation is the use of a special `q` search query, which defines the conditions and types of files and/or folders to be returned. See <a href="https://developers.google.com/drive/api/guides/search-files">Search for files and folders</a> for details.

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileSearchResult result = testGoogleDrive.files().search()
    .setMaxResult(3)
    .setSearchQuery('trashed = false')
    .setSearchOnAllDrives(true)
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

<br>

## <span id="drives-search">Drives Search</span>
The library presents the search result in a specialized wrapper called `GoogleDriveSearchResult`. This wrapper contains two public variables: 'nextPageToken', which indicates that there are more results than could be returned in a single request, and this token can be used to retrieve the next set of results, and 'drives' - which represents the `GoogleDriveEntity` records, which were returned as search results.

To search for drives, we use the <a href="https://developers.google.com/drive/api/reference/rest/v3/drives/list">drives.list</a> method provided by the Google Drive API. The main feature of the Google Drive search operation is the use of a special `q` search query, which defines the conditions and types of drives to be returned. See <a href="https://developers.google.com/drive/api/guides/search-shareddrives">Search for shared drives</a> for details.

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

<br>

## <span id="permissions">Permissions Management</span>
<b>Warning:</b> Concurrent permissions operations on the same file are not supported; only the last update is applied.

This part of the documentation was migrated to the GitHub Wiki as part of the [Release-1.0.0](https://github.com/sandriiy/salesforce-google-drive-library/releases/tag/v1.0.0) which introduced new functionality to remove previously added permissions for a specific user. See the migrated documentation [here](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Permissions-Management)

<!-- ACKNOWLEDGMENTS -->
## <span id="info">Acknowledgments</span>

* https://github.com/sandriiy/salesforce-google-drive-library/wiki
* https://developers.google.com/drive/api/reference/rest/v3
* https://developers.google.com/api-client-library
* https://www.oracle.com/corporate/features/library-in-java-best-practices.html


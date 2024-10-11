<div>
  <p align="center">
    <br />
    <a href="https://www.youtube.com/@asukhetskyi" target="_blank">View Demo</a>
    ·
    <a href="https://github.com/sandriiy/salesforce-google-drive-library/issues/new?labels=bug&template=bug_report.md">Report Bug</a>
    ·
    <a href="https://github.com/sandriiy/salesforce-google-drive-library/issues/new?labels=enhancement&template=feature_request.md">Request Feature</a>
  </p>
</div>

# Navigator
- [Getting Started](#getting-started)
- [Files and Folders Management](#files-manage)
  - [Upload a file to Google Drive](#file-upload)
  - [Clone a file to Google Drive](#file-clone)
  - [Download and Export Google Drive files](#file-downld)
- [Files and Folders Search](#files-search)
- [Drives Search](#drives-search)
- [Permissions Management](#permissions)
  - [Create a New Permission](#permissions-create)
- [Acknowledgments](#info)

<br>

## <span id="getting-started">Getting Started</span>

The library offers a comprehensive set of interactions with the Google Drive API. However, to ensure that the library is securely separated from the Salesforce environment, it is your responsibility to authenticate with Google Drive. Please refer to <a href="https://github.com/sandriiy/salesforce-google-drive-library/wiki/Connecting-Salesforce-to-Google-Drive:-A-Quick-Setup-Guide">this repository's documentation</a> to configure the Google Drive integration.

<br>

## <span id="files-manage">Files and Folders Management</span>
The library presents the result of creating/cloning/uploading/exporting a file in a custom wrapper called `GoogleFileEntity`. This wrapper includes a set of all possible attributes that the Google Drive API can return. It also contains two attributes, `body` and `bodyAsBlob`, which were added to represent the content of the document if it was returned from Google Drive.

### <span id="file-upload">Upload a file to Google Drive</span>
The library provides two ways to upload a file to Google Drive using the official API endpoints, namely: <a href="https://developers.google.com/drive/api/guides/manage-uploads#simple">Simple upload</a> and <a href="https://developers.google.com/drive/api/guides/manage-uploads#multipart">Multipart upload<a>. At the same time, the library offers all the necessary tools for interaction, even if you are not familiar with how these API work.

Please note that the Google Drive API treats folders and files as the same instance, differing only by <a href="https://developers.google.com/drive/api/guides/mime-types">mime type<a>. Therefore, the library does not separate the functionality for working with files and folders but instead treats these two entities as one integral group.

#### Simple Upload
When you perform a simple upload, basic metadata is created and some attributes are inferred from the file, such as the MIME type or modifiedTime. You can use a simple upload in cases where you have small files and file metadata isn't important.

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().simpleCreate()
    .setContentType('text/plain')
    .setContentLength(11)
    .setFields('id, name, driveId, fileExtension')
    .setContentBody('Hello World')
    .execute();
```

In the example above, a simple upload is used to create a file in Google Drive. This type of upload does not support specifying metadata, so elements such as defining the file name, parent folder, etc., are not possible.

#### Multipart Upload
A multipart upload request lets you upload metadata and data in the same request. Use this option if the data you send is small enough to upload again, in its entirety, if the connection fails.

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().multipartCreate()
    .setContentLength(11)
    .setFields('id, name, driveId, fileExtension, mimeType, parents')
    .setFileName('Multipart Upload')
    .setMimeType('application/vnd.google-apps.document')
    .setParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM', '1TLDWgrczvSFnnJpU-2OEEEXMy77OVLjM'})
    .setBody('text/plain', 'base64', 'Hello World')
    .execute();
```

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

### <span id="permissions-create">Create a New Permission</span>
Creating new access to a file, folder, or drive is implemented using the <a href="https://developers.google.com/drive/api/reference/rest/v3/permissions/create">permissions.create</a> method, which supports granting access to one user at a time while specifying their role, type, and email.
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GooglePermissionEntity result = testGoogleDrive.files().permission().create(testFileId)
    .setSendNotificationEmail(true)
    .setTransferOwnership(false)
    .setPrincipalType('user')
    .setPrincipalRole('reader')
    .setPrincipalEmailAddress('test@gmail.com')
    .execute();
```

<br>

<!-- ACKNOWLEDGMENTS -->
## <span id="info">Acknowledgments</span>

* https://developers.google.com/drive/api/reference/rest/v3
* https://developers.google.com/api-client-library
* https://www.oracle.com/corporate/features/library-in-java-best-practices.html

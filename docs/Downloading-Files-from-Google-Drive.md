## <span id="file-downld">Getting Started</span>
The library utilizes existing methods for retrieving files from Google Drive while providing clear and intuitive tools for this task. A key aspect of retrieving files according to the Google Drive structure is the distinction between <a href="https://developers.google.com/drive/api/guides/mime-types">Google Workspace files</a> and others. If the file in Google Drive is of the 'Google Document' type, a special endpoint called <a href="https://developers.google.com/drive/api/reference/rest/v3/files/export">export</a> is required to retrieve it. Conversely, if the file is of the 'PNG' or 'Microsoft Word' type, another endpoint called <a href="https://developers.google.com/drive/api/reference/rest/v3/files/get">get</a> is used.

### Download a regular file from Google Drive

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
If a Google Drive file is too large and causes an `Apex Heap Size Limit` exception in Salesforce, the library provides chunked downloads. Combined with a Lightning Component, this ensures any file, regardless of size, can be retrieved reliably. Example usage:
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().retrieve().download(testFileId)
    .setFileDownloadType(GoogleDownloadFileBuilder.DownloadType.CONTENT)
    .setPartialRange(0, 1000)
    .setFields('name, description')
    .execute();
```

Use the `setFields` method to request additional fields, since Google Drive only returns a limited default set.

### Export Google Workspace file from Google Drive
Exports a Google Workspace document to the desired MIME type and returns the exported byte content. Note that the exported content is limited to 10 MB. If you need to obtain a JSON representation of the file (which is possible with Google Workspace files), specify the appropriate MIME type from <a href="https://developers.google.com/drive/api/guides/mime-types">this list</a>.
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().retrieve().export(testFileId)
    .setMimeType('text/plain')
    .setFields('name, description')
    .execute();
```
### <span id="download-link">Get a download link instead of the bytes</span>

Chunked downloads solve the heap problem, but they still pull every byte through Apex. When the file only needs to reach a browser or a Lightning component, there is a better option: ask Drive for a **download link** and hand that link to the client. The content never enters the Apex heap at all, so file size stops being a Salesforce concern entirely.

This uses the [files.download](https://developers.google.com/workspace/drive/api/reference/rest/v3/files/download) method, which is a long-running operation rather than an ordinary request. The result is a `GoogleOperationEntity`.

**Return Type:** GoogleOperationEntity

**Returned fields:** name, done, metadata, response (downloadUri, partialDownloadAllowed), error

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleOperationEntity operation = testGoogleDrive.files().retrieve().downloadLink(testFileId)
    .execute();

  if (operation.done) {
      String linkForTheBrowser = operation.response.downloadUri;
  }
```

In practice Drive answers with a finished operation straight away, so `done` is `true` and `response.downloadUri` is ready to use. Always check `done` before doing anything else — asking Drive about an operation that has already completed returns an error, so there is nothing to poll for.

- **`setMimeType(String)`** requests a specific format, for exporting a Google Workspace document. Leave it out for a file that already has binary content.
- **`setRevisionId(String)`** asks for a link to a particular revision rather than the current content.

The returned URI points at `www.googleapis.com`, which the Remote Site Settings shipped with the library already cover, so Apex *can* fetch it directly. The point of the link, though, is to avoid exactly that — pass it to the browser and let the client do the downloading.

### <span id="operations">Checking a long-running operation</span>

If an operation ever does come back unfinished, `operations().retrieve(...)` reads its current state using the [operations.get](https://developers.google.com/workspace/drive/api/reference/rest/v3/operations/get) method. Pass the operation name from the first response.

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleOperationEntity operation = testGoogleDrive.operations().retrieve(operationName)
    .execute();

  if (operation.done && operation.error == null) {
      String linkForTheBrowser = operation.response.downloadUri;
  }
```

> [!WARNING]
> A long-running operation may take up to 24 hours, which is far longer than a single Salesforce transaction. Never poll it in a loop — you will exhaust the callout limit long before it finishes. If you need to wait for one, schedule the check from a Queueable or a scheduled job and let each attempt run in its own transaction.

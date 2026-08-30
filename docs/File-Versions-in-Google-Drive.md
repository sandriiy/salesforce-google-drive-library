# Getting Started

Every time the content of a file changes, Google Drive keeps the previous content as a **revision**. The library exposes that history through the `revisions()` category, which maps directly onto the Google Drive API [revisions](https://developers.google.com/workspace/drive/api/reference/rest/v3/revisions) resource.

Revisions are created for you — you never add one directly. They appear as a side effect of uploading new content, which is described in [Upload a New Version](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Modify-Files-in-Google-Drive#new-version). This page covers what you can do with the history once it exists: read it, pin entries so Drive does not purge them, delete an entry, and restore an earlier version.

Four operations are available:

- `.revisions().search(fileId)` — list the history of a file
- `.revisions().retrieve(fileId, revisionId)` — read one revision, its metadata or its content
- `.revisions().modify(fileId, revisionId)` — pin or publish a revision
- `.revisions().remove(fileId, revisionId)` — delete a revision permanently

> [!NOTE]
> Drive treats files with binary content (PDF, images, plain text, Microsoft Office documents) differently from Google Workspace files (Docs, Sheets, Slides). Several revision operations are only available for the former. See [Google Workspace File Limits](#workspace-limits) at the end of this page before building on them.

## <span id="list-revisions">List the Version History</span>

Lists the revisions of a file using the [revisions.list](https://developers.google.com/workspace/drive/api/reference/rest/v3/revisions/list) method. Revisions come back oldest first, so the last entry in the list is the current content of the file.

**Return Type:** GoogleRevisionSearchResult

**Returned fields:** nextPageToken, kind, revisions (List\<GoogleRevisionEntity\>)

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleRevisionSearchResult result = testGoogleDrive.revisions().search(testFileId)
    .setMaxResult(100)
    .setFields('revisions(id,modifiedTime,size,keepForever,lastModifyingUser),nextPageToken')
    .execute();

for (GoogleRevisionEntity revision : result.revisions) {
    System.debug(revision.id + ' - ' + revision.modifiedTime + ' - ' + revision.size);
}
```

As with every other search in the library, `nextPageToken` is returned when there are more revisions than the page size allows, and passing it to `setNextPageToken(...)` gets the following page. Use `setFields` to ask for more than the small default set — `size`, `keepForever` and `lastModifyingUser` are all worth requesting, and none of them is returned unless you ask.

## <span id="retrieve-revision">Retrieve a Single Revision</span>

Reads one revision through the [revisions.get](https://developers.google.com/workspace/drive/api/reference/rest/v3/revisions/get) method. Exactly like downloading a file, you choose between the metadata and the actual bytes.

**Return Type:** GoogleRevisionEntity

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleRevisionEntity metadata = testGoogleDrive.revisions().retrieve(testFileId, testRevisionId)
    .setRevisionDownloadType(GoogleRetrieveRevisionBuilder.DownloadType.METADATA)
    .setFields('id, modifiedTime, size, md5Checksum, originalFilename')
    .execute();
```

To read the content of that revision instead, switch the download type. The bytes arrive in `bodyAsBlob`, and the text form in `body`, which mirrors how `files().retrieve().download(...)` behaves.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleRevisionEntity content = testGoogleDrive.revisions().retrieve(testFileId, testRevisionId)
    .setRevisionDownloadType(GoogleRetrieveRevisionBuilder.DownloadType.CONTENT)
    .execute();

Blob previousContent = content.bodyAsBlob;
```

- **`setRevisionDownloadType(...)`** defaults to `METADATA`. The `CONTENT` option adds `alt=media` to the request, which changes the response from a JSON description into the raw bytes.
- **`setAcknowledgeAbuse(Boolean)`** is required by Drive to download a revision it has flagged as abusive.

## <span id="modify-revision">Pin or Publish a Revision</span>

Updates a revision through the [revisions.update](https://developers.google.com/workspace/drive/api/reference/rest/v3/revisions/update) method. Only four properties of a revision are writable, and the useful one in most integrations is `keepForever`.

**Return Type:** GoogleRevisionEntity

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleRevisionEntity pinned = testGoogleDrive.revisions().modify(testFileId, testRevisionId)
    .setKeepForever(true)
    .setFields('id, keepForever')
    .execute();
```

- **`setKeepForever(Boolean)`** keeps the revision even after newer content is uploaded. Without it, Drive purges an old revision 30 days after it stops being the current one. A file can hold at most 200 pinned revisions.
- **`setPublished(Boolean)`**, **`setPublishAuto(Boolean)`** and **`setPublishedOutsideDomain(Boolean)`** control publishing a revision of a Google Workspace document to the web.

A revision has no name of its own. `originalFilename` is set by Drive from the upload and cannot be changed, so renaming is a file-level operation — use `files().modify().metadata(fileId).setFileName(...)`, described in [Modify Files in Google Drive](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Modify-Files-in-Google-Drive#modify-file).

## <span id="delete-revision">Delete a Revision</span>

Permanently removes one revision using the [revisions.delete](https://developers.google.com/workspace/drive/api/reference/rest/v3/revisions/delete) method. The operation returns nothing; if it fails, an exception is thrown.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
testGoogleDrive.revisions().remove(testFileId, testRevisionId).execute();
```

This is irreversible, and Drive protects you from the two cases that would leave a file broken: the current revision cannot be deleted, and neither can the only remaining one.

## <span id="restore-version">Restore an Earlier Version</span>

The Google Drive API has no "revert" endpoint. Restoring an earlier version is done by reading that revision's content and uploading it back as a new version, which is also what the Drive web interface does behind its **Restore this version** button. The file keeps its ID, and the version you restored from stays in the history.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);

// 1. Read the content of the revision you want to go back to
GoogleRevisionEntity previous = testGoogleDrive.revisions().retrieve(testFileId, testRevisionId)
    .setRevisionDownloadType(GoogleRetrieveRevisionBuilder.DownloadType.CONTENT)
    .execute();

// 2. Upload it back as the newest version of the same file
GoogleFileEntity restored = testGoogleDrive.files().modify().simpleUpdate(testFileId)
    .setContentType('text/plain')
    .setBody(previous.bodyAsBlob)
    .setSupportsAllDrives(true)
    .setFields('id, name, version')
    .execute();
```

Both calls are separate HTTP requests, so keep the Apex callout limits in mind if you restore several files in one transaction. If the file is larger than the Apex heap allows, the same two steps work with a chunked download and `resumableUpdate` instead.

## <span id="workspace-limits">Google Workspace File Limits</span>

Google Docs, Sheets and Slides keep a revision history, but Drive restricts what the API may do with it. These are Drive's own rules, not library limitations, and they are worth knowing before you design around revisions:

| Operation | Binary file | Google Workspace file |
| --- | --- | --- |
| `search` | Supported | Supported |
| `retrieve` (metadata) | Supported | Supported |
| `retrieve` (content) | Supported | **Not supported** — Drive answers `fileNotDownloadable` |
| `modify` with `keepForever` | Supported | Accepted, then ignored |
| `modify` with `published` | Supported | Supported |
| `remove` | Supported | **Not supported** — Drive answers `403 revisionDeletionNotSupported` |

The practical consequence is that [Restore an Earlier Version](#restore-version) works for binary files but not for Docs Editors files: their revision content is only reachable through the `exportLinks` returned by `retrieve`, and the library has no builder that fetches an arbitrary export URL.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleRevisionEntity docRevision = testGoogleDrive.revisions().retrieve(testFileId, testRevisionId)
    .setFields('id, mimeType, exportLinks')
    .execute();

// exportLinks maps a MIME type to the URL that serves this revision in that format
String pdfLink = docRevision.exportLinks.get('application/pdf');
```

Every one of these operations throws a `GoogleCloudException` carrying Drive's own reason when it is refused, so you always get the exact cause rather than a generic failure. See [Library Error Handling Strategy](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Library-Error-Handling-Strategy).

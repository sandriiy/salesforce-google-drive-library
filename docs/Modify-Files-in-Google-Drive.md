## Getting Started

If you already have a file in Google Drive and need to update it, the library supports two approaches:

- **Modify file metadata** (rename, move between folders, update attributes, etc.)
- **Upload a new version** (keeps version history for improved traceability)

## <span id="modify-file">Modify File Metadata</span>

To update metadata, use the `modify()` entry point in the following form: `.files().modify().metadata(YOUR_GOOGLE_DRIVE_FILE_ID)`

This returns a `GoogleModifyMetadataFileBuilder`, which exposes a fluent API for updating file properties.

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity movedFile = testGoogleDrive.files().modify().metadata(remoteFileId)
    .addParentFolders(new List<String>{ destinationFolderId })
    .removeParentFolders(new List<String>{ existingFolderId })
    .setSupportsAllDrives(true)
    .execute();
```

This example removes the file from `existingFolderId` and adds it to `destinationFolderId`. In practice, this “moves” the file to a new location. The file ID remains the same because you are updating the existing file, not creating a new one.

### Other supported metadata updates

The builder also supports common updates such as:

- `setFileName(...)`
- `setMimeType(...)`
- `setDescription(...)`
- `setStarred(...)`
- `setTrashed(...)`

### Custom attributes

You can also attach your own metadata using: `setCustomAttributes(Map<String, Object> values)`

This is useful for storing references such as a Salesforce Record Id, a custom identifier, or any other application-level metadata. These attributes are stored in Google Drive file metadata and can be used later for searching and filtering.

## <span id="new-version">Upload a New Version</span>

You can also upload a **new version** of an existing Google Drive file. The file keeps the same ID, the same sharing and the same links, and every upload adds an entry to its version history. This is what makes changes auditable: nothing is deleted and recreated, so the trail stays intact.

Versions are uploaded through the same three approaches used for creating files, so the builder you already know is the builder you use here. Only the entry point changes:

| Method | Use it for |
| --- | --- |
| `.files().modify().simpleUpdate(fileId)` | New content only, 5 MB or less |
| `.files().modify().multipartUpdate(fileId)` | New content **and** metadata in one request, 5 MB or less |
| `.files().modify().resumableUpdate(fileId)` | Anything larger than 5 MB, uploaded in chunks |

### Replace the content of a file

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity newVersion = testGoogleDrive.files().modify().simpleUpdate(remoteFileId)
    .setContentType('text/plain')
    .setBody(Blob.valueOf('The new content of the file'))
    .setKeepRevisionForever(true)
    .setSupportsAllDrives(true)
    .setFields('id, name, version')
    .execute();
```

In the example above, the content of `remoteFileId` is replaced and a new revision is added to its history. The returned `GoogleFileEntity` carries the same `id` as before, and its `version` has moved on.

- **`setContentType(...)`** describes the bytes you are sending, exactly as with `simpleCreate()`.
- **`setKeepRevisionForever(true)`** pins the revision so Google does not purge it. Without it, an old revision is removed automatically 30 days after newer content is uploaded.
- **`setSupportsAllDrives(true)`** is required when the file lives in a Shared drive.

### Replace the content and the metadata together

`multipartUpdate` accepts everything `multipartCreate` accepts, so a rename and a new body travel in a single request.

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity newVersion = testGoogleDrive.files().modify().multipartUpdate(remoteFileId)
    .setFileName('Quarterly Report (final)')
    .setMimeType('text/plain')
    .setBody(EncodingUtil.base64Encode(Blob.valueOf('The new content of the file')))
    .setUseContentAsIndexableText(true)
    .setSupportsAllDrives(true)
    .execute();
```

> [!WARNING]
> `setParentFolders(...)` must **not** be used when updating a file. Google Drive rejects `parents` in the body of an update. To move a file while updating it, use `addParentFolders(...)` and `removeParentFolders(...)`, which send the change as request parameters instead. The same rule applies to `metadata(...)`, shown earlier on this page.

### Upload a large version in chunks

`resumableUpdate` behaves exactly like `resumableCreate`: you call `initialize()` once to open a session, then send the chunks. The only difference is that the session is opened against the existing file, so the chunks land on it rather than creating a new one.

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleBigFileEntity initResult = testGoogleDrive.files().modify().resumableUpdate(remoteFileId)
    .setMimeType('application/pdf')
    .setKeepRevisionForever(true)
    .setSupportsAllDrives(true)
    .initialize();
```

From there, uploading the chunks is identical to a resumable create — see [Resumable Upload](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Uploading-Files-to-Google-Drive#resumable-upload) for the full chunk loop.

### Additional parameters

These are available on all three version uploads:

- **`setKeepRevisionForever(Boolean)`** keeps the revision permanently. Google allows up to 200 pinned revisions per file, and the flag applies to files with binary content — Google Docs, Sheets and Slides accept it and ignore it.
- **`setUseContentAsIndexableText(Boolean)`** feeds the uploaded content into Drive's search index.
- **`setOcrLanguage(String)`** hints the language when an image is converted to text.
- **`addParentFolders(List<String>)`** / **`removeParentFolders(List<String>)`** move the file while updating it.

Once you have more than one version, the history itself is readable and editable — see [File Versions in Google Drive](https://github.com/sandriiy/salesforce-google-drive-library/wiki/File-Versions-in-Google-Drive), which also shows how to restore an earlier version.

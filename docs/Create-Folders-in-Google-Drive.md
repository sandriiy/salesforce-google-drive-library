# Getting Started

In Google Drive, folders are represented as **files** with a special MIME type: `application/vnd.google-apps.folder`. This design lets Drive manage *everything* (documents, PDFs, folders, etc.) through the same **Files** resource, with the MIME type determining what each item actually is.

The Salesforce Apex Google Drive library supports multiple upload approaches. One of them, **`multipartCreate()`**, which is being used to create folders.

## <span id="simple-upload">Create a folder in Google Drive</span>

The example below creates a new folder by:
- setting the MIME type to `application/vnd.google-apps.folder`, and
- sending an empty request body (`''`) because a folder has no binary content.

Other attributes are optional.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity createdFolder = testGoogleDrive.files().multipartCreate()
    .setFileName(entityName)
    .setMimeType('application/vnd.google-apps.folder')
    .setParentFolders(new List<String>{ parentFolderId })
    .setSupportsAllDrives(true)
    .setBody('')
    .execute();
```

This example creates a folder named `entityName` inside the folder identified by `parentFolderId`.

- **`setMimeType('application/vnd.google-apps.folder')`** tells Google Drive to create a *folder* (not a regular file).
- **`setBody('')`** is intentionally empty because folders don’t have binary content to upload.
- **`setSupportsAllDrives(true)`** ensures the request works for both **My Drive** and **Shared drives** (without it, folder creation may fail in Shared drives).
- **`setParentFolders(...)`** is strongly recommended.


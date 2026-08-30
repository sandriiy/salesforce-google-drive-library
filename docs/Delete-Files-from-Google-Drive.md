# Getting Started

To remove existing files from Google Drive, the library provides two different operations under the `files` category: **permanent deletion** and **trashing**. Each operation serves a different purpose and maps to a specific Google Drive API behavior.

Both operations do not return a result. If an operation fails, an exception is thrown.

## Delete File from Google Drive
Permanently deletes a file owned by the user without moving it to the trash. This operation is irreversible and immediately removes the file from Google Drive.

If the target is a folder, all descendant items owned by the user are also permanently deleted.

**Important:** This operation is not supported for files located in Shared Drives due to Google Drive API restrictions. Files in Shared Drives cannot be permanently deleted using this method and must be **trashed** instead.
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  testGoogleDrive.files().remove(testFileId)
    .setSupportsAllDrives(true)
    .execute();
```

## Trash File from Google Drive
Moves a file to the trash instead of permanently deleting it. Trashed files can be restored within 30 days, after which they are automatically and permanently deleted by Google Drive. If the file belongs to a Shared Drive, the user must have sufficient permissions on the parent folder. If the target is a folder, all descendants owned by the user are moved to the trash as well.

Internally, this operation uses the Google Drive API v2 files.trash endpoint.

**Note:** When working with files in Shared Drives, the `setSupportsAllDrives(true)` option is required.
```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  testGoogleDrive.files().trash(testFileId)
    .setSupportsAllDrives(true) // Lets this request target files residing in Shared Drives
    .execute();
```
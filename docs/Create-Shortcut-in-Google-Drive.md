# Getting Started

In Google Drive, shortcuts are represented as files with a special MIME type: `application/vnd.google-apps.shortcut`. A shortcut does not duplicate the original file. Instead, it creates a lightweight Drive item that points to another file using the target file ID.

The Salesforce Apex Google Drive library supports creating shortcuts through **`multipartCreate()`**. Since a shortcut does not contain binary content, no request body needs to be provided.

## <span id="create-shortcut">Create a shortcut in Google Drive</span>

The example below creates a new shortcut by:

* setting the MIME type to `application/vnd.google-apps.shortcut`,
* providing the target file ID using `setShortcutTarget(...)`, and
* placing the shortcut inside a specific parent folder.

Other attributes are optional.

```java
GoogleDrive remoteGoogleDrive = new GoogleClientApiProvider().retrieveGoogleDriveClient();

GoogleFileEntity createdShortcut = remoteGoogleDrive.files().multipartCreate()
    .setFileName('Performance Report.rtf')
    .setMimeType('application/vnd.google-apps.shortcut')
    .setParentFolders(new List<String>{ '1OvwadL1YQCjrwszioUE5Tddq29e2WPT9' })
    .setShortcutTarget('15y8CVnpctyHRFORBb2VgIhgUIkl3cvc8')
    .setSupportsAllDrives(true)
    .execute();
```

This example creates a shortcut named `Performance Report.rtf` inside the folder identified by `1OvwadL0YQCjrwszioUE5Tddq29e2WPT9`.

* **`setMimeType('application/vnd.google-apps.shortcut')`** tells Google Drive to create a *shortcut* instead of a regular file.
* **`setShortcutTarget(...)`** defines the ID of the original Google Drive file that the shortcut should point to.
* **`setParentFolders(...)`** defines where the shortcut should be created in Google Drive.
* **`setSupportsAllDrives(true)`** ensures the request works for both **My Drive** and **Shared drives**.
* **`setFileName(...)`** defines the visible name of the shortcut. It does not have to match the original file name.

The created shortcut has its own Google Drive file ID, but it points to the original file through the shortcut target.

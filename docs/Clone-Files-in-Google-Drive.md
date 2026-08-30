# Getting Started

To clone existing files in Google Drive, the library provides the `clone(String fileId)` method under the `files` category. Internally, it leverages the Google Drive API method [files.copy](https://developers.google.com/workspace/drive/api/reference/rest/v3/files/copy), which supports a range of attributes for cloning files with different characteristics and even converting them into another format if needed.

The result of this call is an instance of the `GoogleFileEntity` class, which represents the cloned file along with its fields. By default, Google Drive returns only a limited set of fields. To retrieve additional fields, use the `setFields` method.

## Clone a file in Google Drive

```java
  GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
  GoogleFileEntity result = testGoogleDrive.files().clone(testFileId)
    .setFields('id, name')
    .setFileName('CopiedDocument')
    .setMimeType('application/vnd.google-apps.document')
    .setParentFolders(new List<String>{'1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw'})
    .execute();
```
# Getting Started

The Google Drive API supports file uploads [through three approaches](https://developers.google.com/drive/api/guides/manage-uploads), chosen based on factors such as file size, content type, and the presence of metadata.

The Salesforce Apex Google Drive library supports all upload methods and offers a comprehensive set of tools and builders for seamless file uploads of varying sizes. For instance, below is an example of the [Simple Method](#simple-upload), designed for uploading media files without specifying metadata:

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity result = testGoogleDrive.files().simpleCreate()
    .setBody(Blob.valueOf('Hello World'))
    .execute();
```

In the above upload scenario, the result of the execution is an instance of the `GoogleFileEntity` class, which contains the metadata of the file uploaded to Google Drive. For both [Simple](#simple-upload) and [Multipart](#multipart-upload) Uploads, the result is an instance of this class. However, for [Resumable](#resumable-upload) upload, the result is an instance of the `GoogleBigFileEntity` class, which includes additional attributes for continuing the file upload in parts.

> [!NOTE]  
> The Google Drive API treats folders and files as the same instance, differing only by [MIME type](https://developers.google.com/drive/api/guides/mime-types). Consequently, the library does not separate functionality for working with files and folders but instead treats them as a single unified group. To create folders, use Multipart Upload, specifying all metadata and leaving the document body blank.

## <span id="simple-upload">Simple Upload</span>
Use this upload type to transfer a small media file (5 MB or less) without supplying metadata. Click [here](https://developers.google.com/drive/api/guides/manage-uploads#simple) for the reference documentation.
```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity result = testGoogleDrive.files().simpleCreate()
    .setContentType('text/plain')
    .setContentLength(11)
    .setFields('id, name, driveId, fileExtension')
    .setBody(Blob.valueOf('Hello World'))
    .execute();
```
This upload method does not support specifying metadata (such as parent folders, name, conversion type, etc.) and allows only basic parameters, such as the uploaded document's type and its size in bytes. Furthermore, these fields are not required; the only mandatory field for this upload method is `setBody`, and while specifying them is recommended, the code presented below will work just fine:
```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity result = testGoogleDrive.files().simpleCreate()
    .setBody(Blob.valueOf('Hello World'))
    .execute();
```
Additionally, special attention should be given to the `setFields` method, which is available for all three upload methods. It allows you to specify which file fields should be returned upon successful upload. By default, Google Drive returns only four fields (id, kind, name, mimeType), so if you need additional information right after the upload, without relying on the search functionality, this method is invaluable.

## <span id="multipart-upload">Multipart Upload</span>

Use this upload type to transfer a small file (5 MB or less) along with metadata that describes the file, in a single request. Click [here](https://developers.google.com/drive/api/guides/manage-uploads#multipart) for the reference documentation.
```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity result = testGoogleDrive.files().multipartCreate()
    .setFileName('Multipart Upload')
    .setMimeType('application/vnd.google-apps.document')
    .setParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM', '1TLDWgrczvSFnnJpU-2OEEEXMy77OVLjM'})
    .setBody(wordMicrosoftContent)
    .execute();
```
In the example above, we upload a file to two specific folders defined by method `setParentFolders`. During the upload, we also convert the file to the Google Document format (assuming the original format was Microsoft Word) using the `setMimeType` method. Additionally, we specify the file name and its content.

When using this upload method, special attention should be given to the document body, as it can either be a media file or not. By default, the library only accepts a **base64** encoded string. To change the standard encoding, you can use the same `setBody` method, but with its variation that accepts three parameters. As shown below, we specify the MIME type (content type) as text/plain, set the encoding to 8bit, and provide an unencoded string. In this case, everything will work as expected:
```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity result = testGoogleDrive.files().multipartCreate()
    .setContentLength(11)
    .setFields('id, name, driveId, fileExtension, mimeType, parents')
    .setFileName('Multipart Upload')
    .setMimeType('application/vnd.google-apps.document')
    .setParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM', '1TLDWgrczvSFnnJpU-2OEEEXMy77OVLjM'})
    .setBody('text/plain', '8bit', 'Hello World')
    .execute();
```

## <span id="resumable-upload">Resumable Upload</span>
Use this upload type for large files (greater than 5 MB) that you can upload in parts. Click [here](https://developers.google.com/drive/api/guides/manage-uploads#resumable) for the reference documentation.

> [!WARNING]  
> This method sends each individual part of the document as a separate HTTP request, which could lead to exceeding your API limits in case of very large files. Additionally, this method will likely require the use of UI elements + Apex Controller, as the Apex heap size limit prevents you from retrieving a large Blob value and splitting it into pieces for sending.

### Upload Initialization
You request a Uniform Resource Identifier (URI), valid for one week, which you will use to upload the file in chunks. Initialization also involves specifying metadata, as the chunked upload requires only the document body and byte count.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleBigFileEntity initResult = testGoogleDrive.files().resumableCreate()
    .setFields('*')
    .setFileName('Resumable Upload File')
    .setMimeType('application/vnd.google-apps.document')
    .setParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM'})
    .initialize();
```

Unlike the previous two methods, in this case, the returned class instance is of type `GoogleBigFileEntity`, which contains three variables: `resumableSessionId`, `resumableLatestByte`, and `file`. Upon initialization, you get the `resumableSessionId` for chunked uploads, `resumableLatestByte` is typically set to 0, and `file` does not exist yet.

### Chunk Upload
You upload the large file in chunks, specifying the starting byte for each chunk and total file bytes. While determining the total bytes is straightforward by simply getting the size of the Blob, the starting byte requires more attention. The library will return the byte from which to start the next chunk after each upload. Note that this step often requires the use of UI elements, as splitting a large Blob in Apex is not possible.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleBigFileEntity chunksResult = testGoogleDrive.files().resumableCreate()
    .setExistingSessionUri(initResult.resumableSessionId)
    .setBody(firstFileChunk)
    .setStartByte(initResult.resumableLatestByte)
    .setTotalBytes(fullFileBody.size())
    .execute();
```

As shown above, we use the data from the initialized request to set the `setExistingSessionUri`, along with the starting byte, which will be 0 for the first chunk and updated for subsequent ones. If we did not receive the session URI and directly executed the `execute` method, everything would still work, but two requests would be sent: the first for initialization, and the second for uploading the first chunk.

Additionally, keep in mind that even if we specify the chunk size as 0 to 20,000 bytes, it does not guarantee that all bytes will be uploaded. It’s possible that only 15,000 bytes will be successfully uploaded, meaning you may need to build the next chunk starting from the end of the previous one.

### Final Chunk
Once the last chunk is uploaded, as described above, Google Drive returns a file instance with the fields you specified during initialization (using the `setFields` method), or with the default fields if no additional fields were specified.

```
GoogleBigFileEntity chunksResult = testGoogleDrive.files().resumableCreate()
    .setExistingSessionUri(initResult.resumableSessionId)
    .setBody(secondFileChunk)
    .setStartByte(chunksResult.resumableLatestByte)
    .setTotalBytes(fullFileBody.size())
    .execute();
```

Although the result of the execution is a `GoogleBigFileEntity` again, for the last chunk, its `file` variable is populated with the actual file, which can now be used to retrieve the details of the uploaded file.
```
GoogleFileEntity resumableFileUploaded = chunksResult.file;
```
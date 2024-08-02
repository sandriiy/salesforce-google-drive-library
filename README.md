<!-- https://github.com/othneildrew/Best-README-Template/issues/new?labels=enhancement&template=feature-request---.md -->
<div>
  <p align="center">
    <br />
    <a href="https://www.youtube.com/@asukhetskyi">View Demo</a>
    ·
    <a href="">Report Bug</a>
    ·
    <a href="">Request Feature</a>
  </p>
</div>

<!-- ABOUT THE PROJECT -->
# About The Library

The Salesforce Google Drive Library offers programmatic access to Google Drive through API methods. This library simplifies coding against these APIs by providing robust methods for creating, cloning, downloading, sharing, and searching files and drives. Its implementation is accompanied by a newer version of the Google Drive API v3. You can read about the benefits <a href="https://developers.google.com/drive/api/guides/v3versusv2">here</a>.

To utilize this library effectively, an already configured Google Drive integration is required, as it relies on an access token for proper operation. Obtaining this token is the responsibility of the developer using the library. However, the library provides a user-friendly `GoogleCredential` interface and `GoogleAuthorizationCodeFlow` authorizer to facilitate the creation of all necessary credentials.

Here's why this library:
* The entire implementation adheres to best practices, utilizing factories, builders, and isolated code units. This ensures a reliable and secure interaction with the Google Drive API, making this library a robust and efficient choice for developers.
* The code is entirely free from dependencies, allowing immediate use of the library after deploying the elements in the `force-app/main/default/google-drive` folder. Furthermore, all the code is thoroughly tested and verified, ensuring an overall test coverage of about 90%.
* The library is open to contributions and is actively developing, continually adding new features. It guarantees constant monitoring for any errors and promptly addresses and resolves them.

Refer to the <a href="https://developers.google.com/api-client-library">Google Drive Client Libraries</a> for existing counterparts in other programming languages, as the practices and approaches used in those libraries have been applied in implementing this one.

## Navigator
<ul>
  <li><a href="#getting-started">Getting Started</a>
    <ul>
      <li><a href="#service-account">Service Account</a></li>
      <li><a href="#salesforce-token">Create a token in Salesforce</a></li>
    </ul>
  </li>
  <li><a href="#files-manage">Files and Folders Management</a>
    <ul>
      <li><a href="#file-upload">Upload a file to Google Drive</a></li>
      <li><a href="#file-clone">Clone a file to Google Drive</a></li>
      <li><a href="#file-downld">Download and Export Google Drive files</a></li>
    </ul>
  </li>
  <li><a href="#files-search">Files and Folders Search</a></li>
  <li><a href="#drives-search">Drives Search</a></li>
  <li><a href="#permissions">Permissions Management</a>
    <ul>
      <li><a href="#permissions-create">Create a New Permission</a></li>
    </ul>
  </li>
  <li><a href="#info">Acknowledgments</a></li>
</ul>

<br>

## <span id="getting-started">Getting Started</span>

The library provides a set of all possible interactions with the Google Drive API. However, to ensure a secure separation of the library from your SF environment, authentication with Google Drive is your responsibility. At the same time, the library offers best practices for organizing your integration code.

### <span id="service-account">Service Account</span>

The recommended way to set up the integration between Google Drive and Salesforce is to create a Service Account. The service account in Google Drive is a special type of Google account intended for use by applications, rather than individual users. These accounts are used to authenticate and authorize automated processes to access Google APIs securely. And once the service account has been successfully created for your project, you will receive a file containing all the necessary authorization information for Salesforce.

### <span id="salesforce-token">Create a token in Salesforce</span>
Please note, the primary objective for getting started with the library is to create an instance of the `GoogleDrive` class. This instance serves as the main and only point of interaction for you as a developer.

```java
  public GoogleDrive(GoogleCredential credentials, String applicationName) { ... }
```

To create an instance of the `GoogleCredential` class, you can use any methods and resources available in your environment without restriction. In other words, you have the flexibility to use any code or approach you prefer to create an instance of the `GoogleCredential` class manually. The `applicationName` parameter is used solely to identify the entity performing certain operations to the Google Drive API. It can be useful for logging and diagnostics, but does not impose any mandatory requirements.

Nevertheless, this library does not leave you to handle this task alone. Instead, it offers a recommended approach using the `GoogleAuthorizationCodeFlow` class and the `GoogleAuthorizer` interface.

#### Create a custom class (optinal)
First, you need to create a custom class that implements the `GoogleAuthorizer` interface. This requires implementing the `retrieveAccessToken` method, where you will use the Service Account credentials you downloaded to obtain the token.
```java
  public with sharing class CustomGoogleAuthorizer implements GoogleAuthorizer {
    private String PRIVATE_KEY = '-----BEGIN PRIVATE KEY-----\nMIIAvCIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQD6jMVRaGwLgCu8\nH3WRT5LqdzK0l+wdD3c8iVtvkD9S3RUhuTCqTyjmk7JwTzp+bPVBvKWL39R81oR9\nSMvVFYpv1HYBQXn430fM2yloBgMDdCjl0HY2VdTXmYUWozpA9tt0ZrNl9rat6LJ7\nuB7r/lKfBQuXiJr7B0J9aag4m5xPuCIIFoSVLKzwDeBwvDk1fkf/R78jd123Tmlv\nMU7rn9g/2jJyldbUTlxvaQWHIfR9QMs5abB53EMRyssd/ej8Lt1in14Y6UIvrLwe\nC9YbiODQcOIdZM8sjCgsBNUo/gOkgB4cmp3hotGNqCrI5LE7FnVvuk+lcIuEwZjJ\nlQ96CBIrAgMBAAECggEAc6cCOAs/AGoIBhzxbINyOheOiM0t2NY4QHHZCpznlgzm\nQbxVqe/DXffkYLI5unz6Ev+M3Q2TbJKq8pflOvVoAynr1LWQI2CRqI6rxNAtmO0I\nKdj5kCg7iM/dHq925uTeOQVlStZsicdFiBVb9KxfH/c4vBh7DY/y0agxVfwCgcr/\n3V7LDgtxy2JIuZsgCFsru62wBcKp/F0RxaATPATStN8tLhL44Japm4EmUCGqrP4r\nnzqgz60GLR2ITestQBLlKAGbPQGifKzEB4kUacqTgC/FU97SBSsHOO3HAzE6pvjf\nxGKLCcaKRxJsVIQ5JDLutNr9DmkuwfRXAxUultjlpQKBgQD/JSXqrfw3onhJErIP\nZJ5JYrlM8mQC+hvAxHPAdu6C2P1hpud9AOKkM28A1OD02HvsOzmTpdQfcDlzSQa8\nNRY+WZaj/2YpI4R99smaGT10cPR9/5gLM0ZI6udJco3Oh0SsdxeKUEp0liXP+xGS\ngq83qeNLkJFFv4xNA+H4n+ggJQKBgQD7Y65btLT3yT6daSjUco5Bbo44WPRbIb6O\n5YfmRO40tb7npFekM4gz0U9tM0E3TbwRt6Ocd9gKSyXmhcMADnISK9Ic435WekNx\ng2aJ2wd7Bf1WLXq7ZsNeyYQ2Q5BEwEBgH3pSn2AJwD+C2CTlHP6+iLs40wDMkiHy\nb3qWsoZwDwKBgQCY7jlF6zdMWZPjqNMVque9cPFEj90mc6eC6b2/1QmtYEav64zB\nPnCan0Gfq/mSiNfuhqlCOJlmpquo0FK7KM7GXIiQkBs5+VIG9o9sUEinrLS/eR43\nSGqOdk5flcwtyKJ/BXsUqn+WVhEgEos72B0SLkBRILwSpHeCChuHIrUCQKBgFJO\nO5rY2ls6L174PB76dqrjmHrIXRCtRqebKotgzCDD1IIg43TmTlSw1fFp05NYxxeB\n6XZkIn6URg9oggS1thFO+ZbtwMJte0FiBSNja9qShnQ9pa5Poe2Zysi9bDGmRC10\ngOcmORpYMDMVs1a0HI+jUrDzHJLd0XF/oEJQpwVvAoGAPlDasojU7FRxk2HWVrBy\nPt2I53ioe1s+z0IL+dFcwMgVID0Xrp8yAGeizrDjdtSiQQEmCzMDovGQ57ULqdWC\nF7lOdUY/B/48pUrWrsyi+uHP9oyb48yMXvKsIsjPGlni1JK7m+49oh7Ys2oomGWz\ntS4oHLE3US90wtCV2/gXaWg=\n-----END PRIVATE KEY-----\n'; 
    private String SERVICE_ACCOUNT_EMAIL = 'test-110@vital-lyceum-416627-h9.iam.gserviceaccount.com';

    // Required method from the interface
    public String retrieveAccessToken() {
        String generatedJwtToken = generateJwtToken();
        String obtainedAccessToken = generateAccessToken(generatedJwtToken);
        return obtainedAccessToken;
    }

    private String generateJwtToken() {
        Long issuedAt = DateTime.now().getTime() / 1000;
        Long expiresAt = issuedAt + 3600; // Token valid for 1 hour
        
        Map<String, Object> header = new Map<String, Object>();
        header.put('alg', 'RS256');
        header.put('typ', 'JWT');
        
        Map<String, Object> claim = new Map<String, Object>();
        claim.put('iss', SERVICE_ACCOUNT_EMAIL);
        claim.put('scope', 'https://www.googleapis.com/auth/drive');
        claim.put('aud', 'https://oauth2.googleapis.com/token');
        claim.put('exp', expiresAt);
        claim.put('iat', issuedAt);
        
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(header))).replace('+', '-').replace('/', '_').replace('=', '');
        String claimEncoded = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(claim))).replace('+', '-').replace('/', '_').replace('=', '');
        
        String signatureInput = headerEncoded + '.' + claimEncoded;
        Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(signatureInput), EncodingUtil.base64Decode(cleanPrivateKey(PRIVATE_KEY)));
        String signatureEncoded = EncodingUtil.base64Encode(signature).replace('+', '-').replace('/', '_').replace('=', '');
        
        String createdJwtToken = headerEncoded + '.' + claimEncoded + '.' + signatureEncoded;
        return createdJwtToken;
    }

    private String generateAccessToken(String jwtToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://oauth2.googleapis.com/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + jwtToken);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String accessToken = (String) responseMap.get('access_token');
        return accessToken;
    }

    private String cleanPrivateKey(String privateKey) {
        privateKey = privateKey.replace('-----BEGIN PRIVATE KEY-----', '');
        privateKey = privateKey.replace('-----END PRIVATE KEY-----', '');
        privateKey = privateKey.replace('\n', '').replace('\r', '');
        return privateKey;
    }
}
```
In the example provided above, test credentials from the Service Account are used (you will have your own credentials). For clarity, the methods have not been broken down into smaller parts, so it’s advisable to refactor the code according to your development team's best practices, as well as using other methods such as <a href="https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm&language=en_US&type=5">Named Credentials</a>. Pay special attention to the `cleanPrivateKey` method, which removes unnecessary symbols and markings from the private key you received. This step is crucial, as failing to do so may result in an authorization error from the Google Drive API.

#### Almost there (optinal)
After creating a custom class that implements the interface and returns an access token, you can use the `GoogleAuthorizationCodeFlow` to generate the `GoogleCredential` instance and fully leverage the capabilities of this library.
```java
  GoogleCredential googleDriveCredentials = new GoogleAuthorizationCodeFlow.Builder()
    .setLocalGoogleAuthorizer('CustomGoogleAuthorizer')
    .build();

  GoogleDrive googleDriveLibrary = new GoogleDrive(googleDriveCredentials, 'Apex/1.0 (Salesforce Library)');
  ...
```

Once you’ve set up the integration, created an access token, and instantiated the `GoogleDrive` class — your gateway to using the Salesforce Google Drive Library, nothing else stands in your way. From this point on, you have full access to the capabilities for working with files in Google Drive.

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

<!-- ACKNOWLEDGMENTS -->
## <span id="info">Acknowledgments</span>

* https://developers.google.com/drive/api/reference/rest/v3
* https://developers.google.com/api-client-library
* https://www.oracle.com/corporate/features/library-in-java-best-practices.html

# Getting Started

The Salesforce Apex Google Drive library is designed to fail **loudly and transparently**. It does not silently swallow errors. If the Google Drive API returns an error, the library throws an exception back into your execution flow.

To handle errors gracefully (and prevent system details from reaching end users), wrap your calls in a `try/catch` block.

```
try {
    return this.remoteGoogleDrive.files().multipartCreate()
        .setFileName(fileName)
        .setBody(contentToUpload)
        .setParentFolders(parentFolders)
        .setSupportsAllDrives(true)
        .setFields('id, name, parents')
        .execute();
} catch (GoogleCloudException ex) {
    Logger.error(ex.getMessage());
    Logger.error(ex.endpoint);
    Logger.error(JSON.serialize(ex.httpHeaders));
    Logger.error(JSON.serialize(ex.httpParameters));
}
```

## <span id="exception-type">Exception Type</span>

Google Drive API failures are represented by a custom exception type: `GoogleCloudException`.

In addition to the original error message, `GoogleCloudException` provides useful debugging context such as:

- HTTP endpoint
- HTTP headers
- HTTP parameters

This makes it easier to identify *which* request failed and *why*, especially when the Drive error message alone is not descriptive. The library is tested before each release to minimize unexpected library-level issues. However, it cannot prevent errors returned by Google Drive itself, so using `try/catch` is still recommended.

## <span id="failure-strategy">Failure Strategy Interface</span>

If you want to centralize logging or diagnostics, you can also configure a **failure strategy**. The library provides the `GoogleFailureStrategy` interface, which you implement in your org and pass when creating a `GoogleDrive` instance.

```
GoogleDrive drive = new GoogleDrive(googleDriveCredentials, DEFAULT_AGENT_NAME)
    .withFailureStrategy(YOUR_ERROR_HANDLER);
```

When an exception occurs, the library will call your `GoogleFailureStrategy` implementation **before** re-throwing the exception.

Important notes:

- A failure strategy **does not suppress** exceptions.
- The exception is still thrown after your handler runs.
- If you don’t want technical details surfaced to end users, you should still use `try/catch` around your application logic.

Below is an example of how a failure strategy might be implemented.
```
public with sharing class GoogleFileWebErrorHandler implements GoogleFailureStrategy {
    public void onFailure(GoogleCloudException ex) {
        Logger.error('Google Client for Salesforce / Google Drive API Exception: ' + ex.getMessage());
        Logger.error('Google Client for Salesforce / Google Drive API Endpoint: ' + ex.endpoint);
        Logger.error('Google Client for Salesforce / Google Drive API Headers: ' + JSON.serialize(ex.httpHeaders));
        Logger.error('Google Client for Salesforce / Google Drive API Parameters: ' + JSON.serialize(ex.httpParameters));
        Logger.saveLog();
    }
}
```

# Getting Started

A permission grants a user, group, domain, or the world access to a file or a folder hierarchy. Google Drive API offers a comprehensive set of permission operations, including creating, deleting, listing permissions, transferring file ownership, and more.

## <span id="new-permission">Create a New Permission</span>
Creating new access to a file, folder, or drive is implemented using the [permissions.create](https://developers.google.com/drive/api/reference/rest/v3/permissions/create) method, which supports granting access to one user at a time while specifying their role, type, and email.

**Return Type:** GooglePermissionEntity

**Returned fields:** id, displayName, type, kind, permissionDetails, photoLink, emailAddress, role, allowFileDiscovery, domain, expirationTime, teamDrivePermissionDetails, deleted, view, pendingOwner

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GooglePermissionEntity result = testGoogleDrive.permissions().create(testFileId)
    .setSendNotificationEmail(true)
    .setTransferOwnership(false)
    .setPrincipalType('user')
    .setPrincipalRole('reader')
    .setPrincipalEmailAddress('test@gmail.com')
    .execute();
```

You can also create a **public link** to any folder (or file) in Google Drive by adding a permission. Once the permission is created, Google Drive populates the `webViewLink` field in the file metadata.

```
// Anyone Public Link (entire internet)
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GooglePermissionEntity result = testGoogleDrive.permissions().create(testFileId)
    .setSupportsAllDrives(true)
    .setPrincipalType('anyone')
    .setPrincipalRole('reader')
    .execute();

// Domain Public Link (restricted to your domain)
GooglePermissionEntity resultDomain = testGoogleDrive.permissions().create(testFileId)
    .setSupportsAllDrives(true)
    .setPrincipalType('domain')
    .setPrincipalDomain('cloudrylabs.com')
    .setPrincipalRole('reader')
    .execute();
```

- **`setPrincipalType('anyone')`** makes the item accessible to anyone with the link.
- **`setPrincipalType('domain')`** restricts access to users within a specific Google Workspace domain.
- **`setPrincipalDomain(...)`** defines which domain is allowed (only applicable for `domain` type).
- **`setPrincipalRole('reader')`** grants view-only access.
- **`setSupportsAllDrives(true)`** is recommended so this works in both **My Drive** and **Shared drives**.

After creating the permission, you can retrieve the generated link from metadata:

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileEntity fileDetails = testGoogleDrive.files().retrieve().download(googleDriveId)
    .setFileDownloadType(GoogleDownloadFileBuilder.DownloadType.METADATA)
    .setSearchOnAllDrives(true)
    .setFields('webViewLink, webContentLink')
    .execute();
```

## <span id="retrieve-permission">Retrieve a Permission</span>
Reads a single permission using the [permissions.get](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions/get) method. You need both the file ID and the permission ID, which you get either from the response when the permission was created, or from a permission search.

**Return Type:** GooglePermissionEntity

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GooglePermissionEntity result = testGoogleDrive.permissions().retrieve(testFileId, testPermissionId)
    .setSupportsAllDrives(true)
    .setFields('id, type, role, emailAddress, expirationTime')
    .execute();
```

- **`setDomainAdminAccess(Boolean)`** reads the permission as a domain administrator, for files the account is not a member of.
- **`setFields(...)`** is worth using here as everywhere else, since Google returns a small default set.

## <span id="modify-permission">Update an Existing Permission</span>
Changes an existing permission through the [permissions.update](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions/update) method. This is how you promote a reader to a writer, set an expiry on access, or hand ownership over — without removing the permission and creating a new one, which would send another notification email.

**Return Type:** GooglePermissionEntity

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GooglePermissionEntity result = testGoogleDrive.permissions().modify(testFileId, testPermissionId)
    .setPrincipalRole('writer')
    .setSupportsAllDrives(true)
    .setFields('id, role')
    .execute();
```

Access can also be made temporary. Expiry times are RFC 3339 timestamps, must be in the future, and Google only allows them on the `reader` and `commenter` roles:

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GooglePermissionEntity result = testGoogleDrive.permissions().modify(testFileId, testPermissionId)
    .setPrincipalRole('reader')
    .setExpirationTime('2026-12-31T23:59:59.000Z')
    .execute();
```

- **`setPrincipalRole(String)`** is the new role: `owner`, `organizer`, `fileOrganizer`, `writer`, `commenter` or `reader`.
- **`setExpirationTime(String)`** sets an automatic expiry, and **`setRemoveExpiration(Boolean)`** takes one off again.
- **`setTransferOwnership(Boolean)`** is required when the new role is `owner`. Without it Drive rejects the request.
- **`setPendingOwner(Boolean)`** marks the account as a pending owner, which is how ownership transfer works between consumer accounts.
- **`setMoveToNewOwnersRoot(Boolean)`** moves the file into the new owner's My Drive as part of the transfer.
- **`setDomainAdminAccess(Boolean)`** performs the change as a domain administrator.

> [!NOTE]
> Ownership cannot be transferred out of a shared drive, and it cannot be transferred to an account in a different Google Workspace domain. In a shared drive, `organizer` is the closest equivalent to ownership.

## <span id="delete-permission">Delete an Existing Permission</span>
Removing access to a file, folder, or drive is implemented using the [permissions.delete](https://developers.google.com/drive/api/reference/rest/v3/permissions/delete) method, which allows you to revoke access for a specific user to a specific file. To do this, you need to specify the file ID and the permission ID, which can be obtained either when creating the permission or by searching for existing permissions.
```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
testGoogleDrive.permissions().remove(testFileId, testPermissionId)
    .setDomainAdminAccess(true)
    .setSupportsAllDrives(false)
    .execute();
```

## <span id="list-permission">List File Permissions</span>
Lists a file's or shared drive's permissions using the [permissions.list](https://developers.google.com/workspace/drive/api/reference/rest/v3/permissions/list) method.

**Return Type:** GooglePermissionSearchResult

**Returned fields:** nextPageToken, kind, permissions (List\<GooglePermissionEntity\>)

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GooglePermissionSearchResult result = testGoogleDrive.permissions().search(testFileId)
    .setMaxResult(10)
    .setFields('emailAddress')
    .setSearchOnAllDrives(true)
    .setNextPageToken(testPageToken) // Use if the first search returned more results than the maximum
    .execute();
```
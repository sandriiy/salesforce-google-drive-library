# Getting Started

A **shared drive** is storage owned by the organisation rather than by a person. Files in it survive an employee leaving, membership is managed at the drive level instead of file by file, and everything inside inherits that membership. For a Salesforce integration this is usually the right place to put generated documents: a service account writing into someone's My Drive creates files nobody else can reach, while the same files in a shared drive are visible to the whole team from the first moment.

The library covers the full lifecycle through the `drives()` category, mapping onto the Google Drive API [drives](https://developers.google.com/workspace/drive/api/reference/rest/v3/drives) resource:

- `.drives().create()` — create a shared drive
- `.drives().retrieve(driveId)` — read one drive's metadata
- `.drives().modify(driveId)` — rename it, restyle it, change its restrictions
- `.drives().remove(driveId)` — delete it permanently
- `.drives().hide(driveId)` / `.drives().unhide(driveId)` — control whether it appears in the caller's default view

Listing the drives you can reach is covered separately, in [Drives Search in Google Drive](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Drives-Search-in-Google-Drive).

> [!NOTE]
> Every file operation that touches a shared drive needs `setSupportsAllDrives(true)`. Without it Drive behaves as though the shared drive does not exist, and you get a confusing "not found" rather than a permission error.

## <span id="create-drive">Create a Shared Drive</span>

Creates a shared drive using the [drives.create](https://developers.google.com/workspace/drive/api/reference/rest/v3/drives/create) method. The account making the call becomes its organizer.

**Return Type:** GoogleDriveEntity

**Returned fields:** id, name, colorRgb, kind, backgroundImageLink, capabilities, themeId, backgroundImageFile, createdTime, hidden, restrictions, orgUnitId

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleDriveEntity createdDrive = testGoogleDrive.drives().create()
    .setDriveName('Finance Documents')
    .setColorRgb('#16a765')
    .setFields('id, name, colorRgb, createdTime')
    .execute();
```

- **`setDriveName(String)`** is required. Drive rejects a create without a name.
- **`setColorRgb(String)`** and **`setThemeId(String)`** are cosmetic and optional.
- **`setRequestId(String)`** is the idempotency key. The library generates one for you, so you only set it yourself when you deliberately want to retry the same logical create — sending the same request ID twice returns the drive created the first time instead of creating a second one.

> [!WARNING]
> A newly created shared drive takes a moment to become fully visible to Google's own services. Immediately after `create()` returns, `hide()` may answer `404 Shared drive not found` for an ID that `retrieve()` and `modify()` accept without complaint. If you need to act on a drive the instant it is created, be ready to retry, or move the follow-up work into a later transaction.

The account must also be allowed to create shared drives at all. If the Workspace configuration forbids it, Drive answers with `userCannotCreateTeamDrives` — that is an administrative setting, not something the library can work around.

## <span id="retrieve-drive">Retrieve a Shared Drive</span>

Reads one shared drive's metadata using the [drives.get](https://developers.google.com/workspace/drive/api/reference/rest/v3/drives/get) method.

**Return Type:** GoogleDriveEntity

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleDriveEntity driveDetails = testGoogleDrive.drives().retrieve(testDriveId)
    .setFields('id, name, hidden, restrictions, capabilities')
    .execute();
```

- **`setDomainAdminAccess(Boolean)`** lets a Workspace administrator read a drive they are not a member of. It requires domain administrator privileges.

The `capabilities` block is worth requesting before any write. `canRenameDrive`, `canDeleteDrive` and `canAddChildren` tell you what the current account may actually do, which saves a round trip that was always going to fail.

## <span id="modify-drive">Modify a Shared Drive</span>

Updates a shared drive through the [drives.update](https://developers.google.com/workspace/drive/api/reference/rest/v3/drives/update) method. Only the properties you set are sent, so a rename leaves the theme and the restrictions untouched.

**Return Type:** GoogleDriveEntity

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleDriveEntity updatedDrive = testGoogleDrive.drives().modify(testDriveId)
    .setDriveName('Finance Documents (Archive)')
    .setColorRgb('#16a765')
    .setFields('id, name, colorRgb')
    .execute();
```

Restrictions control how the drive behaves as a whole, and are passed as a map because Drive treats them as one nested object:

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleDriveEntity restrictedDrive = testGoogleDrive.drives().modify(testDriveId)
    .setRestrictions(new Map<String, Object>{
        'domainUsersOnly' => true,
        'driveMembersOnly' => true,
        'copyRequiresWriterPermission' => true
    })
    .setFields('id, name, restrictions')
    .execute();
```

- **`domainUsersOnly`** blocks sharing with anyone outside your Google Workspace domain.
- **`driveMembersOnly`** blocks sharing individual items with people who are not members of the drive.
- **`copyRequiresWriterPermission`** stops readers and commenters from downloading, copying or printing.
- **`setDomainAdminAccess(Boolean)`** applies the change as a domain administrator.

## <span id="hide-drive">Hide and Unhide a Shared Drive</span>

Hiding removes a shared drive from the caller's default view. Nothing is deleted, nobody loses access, and the drive stays fully usable through the API — this is a per-user display preference, useful for archived drives that would otherwise clutter the list.

**Return Type:** GoogleDriveEntity

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);

GoogleDriveEntity hiddenDrive = testGoogleDrive.drives().hide(testDriveId)
    .setFields('id, name, hidden')
    .execute();

GoogleDriveEntity visibleDrive = testGoogleDrive.drives().unhide(testDriveId)
    .setFields('id, name, hidden')
    .execute();
```

Both return the drive with its `hidden` flag updated, so you can confirm the change from the response alone.

## <span id="delete-drive">Delete a Shared Drive</span>

Permanently deletes a shared drive using the [drives.delete](https://developers.google.com/workspace/drive/api/reference/rest/v3/drives/delete) method. The operation returns nothing; if it fails, an exception is thrown. This is irreversible.

**The drive must be empty.** Drive refuses to delete a shared drive that still contains items, including trashed ones, so remove the contents first.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
testGoogleDrive.drives().remove(testDriveId).execute();
```

- **`setAllowItemDeletion(Boolean)`** deletes the drive together with everything inside it. It is only available to a domain administrator, and must be combined with `setDomainAdminAccess(true)`.
- **`setDomainAdminAccess(Boolean)`** performs the deletion as a domain administrator.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
testGoogleDrive.drives().remove(testDriveId)
    .setDomainAdminAccess(true)
    .setAllowItemDeletion(true)
    .execute();
```

To empty a drive yourself before deleting it, list its contents with a file search scoped to that drive, then trash or remove each item:

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleFileSearchResult contents = testGoogleDrive.files().search()
    .setDriveId(testDriveId)
    .setSearchOnAllDrives(true)
    .setSearchQuery('trashed = false')
    .setFields('files(id,name)')
    .execute();

for (GoogleFileEntity oneFile : contents.files) {
    testGoogleDrive.files().remove(oneFile.id).setSupportsAllDrives(true).execute();
}
```

> [!WARNING]
> The loop above sends one callout per file, so it will hit the Apex limit of 100 callouts per transaction on a drive of any real size. For anything beyond a handful of files, move the deletion into a Queueable and process it in batches.

## <span id="managing-access">Managing Who Can Reach a Shared Drive</span>

Membership of a shared drive is granted with the same permission operations used for files — pass the drive ID where a file ID would normally go. The roles that apply to a shared drive are `organizer`, `fileOrganizer`, `writer`, `commenter` and `reader`.

```
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GooglePermissionEntity membership = testGoogleDrive.permissions().create(testDriveId)
    .setSupportsAllDrives(true)
    .setPrincipalType('user')
    .setPrincipalRole('writer')
    .setPrincipalEmailAddress('teammate@yourdomain.com')
    .execute();
```

See [Permissions Management](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Permissions-Management) for the full set of permission operations.

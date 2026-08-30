# Getting Started

A **label** is structured metadata that a Google Workspace administrator defines once and users apply to files. The library exposes labels through the `labels()` category, which maps onto the Google Drive API [files.listLabels](https://developers.google.com/workspace/drive/api/reference/rest/v3/files/listLabels) and [files.modifyLabels](https://developers.google.com/workspace/drive/api/reference/rest/v3/files/modifyLabels) methods:

- `.labels().search(fileId)` — read the labels applied to a file, with their field values
- `.labels().modify(fileId)` — apply, update or remove labels on a file

> [!NOTE]
> Drive applies labels, but it does not define them. Creating a label, adding fields to it and publishing it are done by an administrator in the Google Admin console, or through the separate Drive Labels API. This library covers the Drive side only, so the label must already exist before you can put it on a file.

## <span id="list-labels">List the Labels on a File</span>

Returns every label currently applied to a file, together with the values held in each of its fields.

**Return Type:** GoogleLabelSearchResult

**Returned fields:** nextPageToken, kind, labels (List\<GoogleLabelEntity\>)

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleLabelSearchResult result = testGoogleDrive.labels().search(testFileId)
    .setMaxResult(100)
    .execute();

for (GoogleLabelEntity label : result.labels) {
    System.debug('Label: ' + label.id + ', revision ' + label.revisionId);

    for (String fieldId : label.fields.keySet()) {
        GoogleLabelEntity.Field field = label.fields.get(fieldId);
        System.debug('  ' + fieldId + ' (' + field.valueType + ') = ' + field.text);
    }
}
```

Each `GoogleLabelEntity` carries the label `id`, the `revisionId` of the label definition it was applied from, and a `fields` map keyed by field ID. Each entry reports its `valueType` — `text`, `selection`, `date`, `integer` or `user` — and the value itself.

- **`setMaxResult(Integer)`** limits how many labels are returned per request.
- **`setNextPageToken(String)`** continues from a previous result when a file carries more labels than one page holds.

## <span id="find-ids">Finding the Label and Field IDs</span>

Applying a label requires its ID and the ID of each field you want to populate. Both are opaque strings such as `SEND70dQN5lH71BeU4nrBgrBit6Pvst1` and `6AC8AD1AF5` — they are not the display names you see in the Drive interface, and there is no way to look a label up by name through the Drive API.

There are three practical ways to get them:

1. **Read them from a file that already carries the label.** Apply the label once through the Drive web interface, then call `labels().search(fileId)` as shown above. The response gives you the label ID and every field ID in one go. This is the quickest route when you are writing the code.
2. **Read them in the Google Admin console.** Open **Admin console → Data → Manage labels**, select the label, and the ID appears in the page URL. Each field shows its own ID on the field detail.
3. **Call the Drive Labels API.** `GET https://drivelabels.googleapis.com/v2/labels?publishedOnly=true&view=LABEL_VIEW_FULL` lists every label in the organisation. `LABEL_VIEW_FULL` matters — the default view omits the field definitions, so without it you get the label but not the field IDs. Each entry is named `labels/<LABEL_ID>`, and the part after `labels/` is what the library expects.

> [!WARNING]
> The Drive Labels API lives on a different host, `drivelabels.googleapis.com`, which is **not** covered by the two Remote Site Settings shipped with this library. It also needs the `drive.labels` scope. If you decide to call it, add the Remote Site Setting and request that scope yourself — the library does not do it for you.

## <span id="apply-label">Apply a Label</span>

Labels are changed through `labels().modify(fileId)`. Each individual change is described by a `GoogleLabelModificationBuilder` and handed over with `addLabelModification(...)`, so several labels can be changed on one file in a single request.

**Return Type:** GoogleModifyLabelsResult

**Returned fields:** kind, modifiedLabels (List\<GoogleLabelEntity\>)

Applying a label and setting its field values is one operation, not two — the values travel with the label in the same call.

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleModifyLabelsResult result = testGoogleDrive.labels().modify(testFileId)
    .addLabelModification(
        new GoogleLabelModificationBuilder()
            .setLabelId('SEND70dQN5lH71BeU4nrBgrBit6Pvst1')
            .setTextValues('6AC8AD1AF5', new List<String>{'Confidential'})
    )
    .execute();
```

In the example above, the label is attached to the file and its text field is populated in the same request. If the label is already on the file, the same call updates the field instead — there is no separate "attach" and "update" path.

- **`setLabelId(String)`** identifies the label. It is required on every modification.
- **`setTextValues(String fieldId, List<String>)`** sets a text field.
- **`setSelectionValues(String fieldId, List<String>)`** sets a selection field, using the IDs of the choices rather than their display names. A list is accepted because a selection field may allow more than one choice.
- **`setDateValues(String fieldId, List<String>)`** sets a date field, formatted as `YYYY-MM-DD`.
- **`setIntegerValues(String fieldId, List<Integer>)`** sets a number field.
- **`setUserValues(String fieldId, List<String>)`** sets a user field, using email addresses.
- **`unsetValues(String fieldId)`** clears a field without removing the label.

Each of these can be called more than once on the same builder, once per field, so a label with several fields is populated in one modification:

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleModifyLabelsResult result = testGoogleDrive.labels().modify(testFileId)
    .addLabelModification(
        new GoogleLabelModificationBuilder()
            .setLabelId('SEND70dQN5lH71BeU4nrBgrBit6Pvst1')
            .setSelectionValues('A1B2C3D4E5', new List<String>{'optionConfidential'})
            .setDateValues('F6G7H8I9J0', new List<String>{'2026-12-31'})
            .setUserValues('K1L2M3N4O5', new List<String>{'owner@yourdomain.com'})
            .setIntegerValues('P6Q7R8S9T0', new List<Integer>{7})
    )
    .setFields('modifiedLabels')
    .execute();
```

## <span id="remove-label">Remove a Label</span>

Removing a label uses the same entry point, with `setRemoveLabel(true)` in place of any field values.

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
testGoogleDrive.labels().modify(testFileId)
    .addLabelModification(
        new GoogleLabelModificationBuilder()
            .setLabelId('SEND70dQN5lH71BeU4nrBgrBit6Pvst1')
            .setRemoveLabel(true)
    )
    .execute();
```

Removing a label clears its field values as well, so re-applying it later starts from an empty label. If you intend to put the label back with the same values, read them with `labels().search(...)` first and pass them again when you re-apply it.

`modifiedLabels` reports the labels that were added or updated, so a request that only removes a label comes back with an empty list. That is expected, not an error — confirm a removal with `labels().search(...)` rather than by counting the response.

## <span id="multiple-labels">Changing Several Labels at Once</span>

`addLabelModification(...)` may be called repeatedly, and Drive applies all of the changes in one request. This is the efficient way to reclassify a file, and it costs a single callout.

```java
GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
GoogleModifyLabelsResult result = testGoogleDrive.labels().modify(testFileId)
    .addLabelModification(
        new GoogleLabelModificationBuilder()
            .setLabelId('SEND70dQN5lH71BeU4nrBgrBit6Pvst1')
            .setRemoveLabel(true)
    )
    .addLabelModification(
        new GoogleLabelModificationBuilder()
            .setLabelId('QWER70dQN5lH71BeU4nrBgrBit6Pvst2')
            .setTextValues('6AC8AD1AF5', new List<String>{'Public'})
    )
    .execute();
```

## <span id="permissions-note">Access Requirements</span>

Reading and writing labels needs more than edit access to the file. Before building on this, check that:

- The file's `capabilities.canReadLabels` and `capabilities.canModifyLabels` are `true`. Request them through `setFields('capabilities(canReadLabels,canModifyLabels)')` on `files().retrieve().download(...)`.
- The label itself is **published**. A label still in draft cannot be applied.
- The account has been granted access to the label in the Admin console. A service account is not automatically allowed to use every label in the organisation.

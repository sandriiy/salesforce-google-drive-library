@isTest
private class GoogleDriveTest {
    private static GoogleCredential testCredentials;
    private static String userAgentName;

    @isTest
    private static void testFullDriveSearch() {
        String fullDriveSearchBody = '{"kind":"drive#fileList","drives":[{"id":"drive123","name":"My Drive","colorRgb":"#FFFFFF","kind":"drive#drive","backgroundImageLink":"https://example.com/image.png","capabilities":{"canAddChildren":true,"canComment":true,"canCopy":true,"canDeleteDrive":false,"canDownload":true,"canEdit":true,"canListChildren":true,"canManageMembers":true,"canReadRevisions":true,"canRename":true,"canRenameDrive":true,"canChangeDriveBackground":true,"canShare":true,"canChangeCopyRequiresWriterPermissionRestriction":false,"canChangeDomainUsersOnlyRestriction":false,"canChangeDriveMembersOnlyRestriction":false,"canChangeSharingFoldersRequiresOrganizerPermissionRestriction":false,"canResetDriveRestrictions":false,"canDeleteChildren":false,"canTrashChildren":true},"themeId":"theme123","backgroundImageFile":{"id":"image123","xCoordinate":100.0,"yCoordinate":50.0,"width":800.0},"createdTime":"2023-06-15T10:30:00Z","hidden":false,"restrictions":{"copyRequiresWriterPermission":true,"domainUsersOnly":false,"driveMembersOnly":true,"adminManagedRestrictions":false,"sharingFoldersRequiresOrganizerPermission":true},"orgUnitId":"org123"},{"id":"drive456","name":"Not Populated Drive"}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_DRIVES_ENDPOINT,
            200,
            fullDriveSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleDriveSearchResult result = testGoogleDrive.drives().search()
            .setMaxResult(50)
            .setSearchQuery('')
            .setDomainAdminAccess(false)
            .execute();
        Assert.areEqual(2, result.drives.size());
        Test.stopTest();
    }

    @isTest
    private static void testNextPageDriveSearch() {
        String nextPageDriveSearchBody = '{"nextPageToken": "2fd620046218c04c12709a67c4879de9","kind":"drive#fileList","drives":[{"id":"drive123","name":"My Drive","colorRgb":"#FFFFFF","kind":"drive#drive","backgroundImageLink":"https://example.com/image.png","capabilities":{"canAddChildren":true,"canComment":true,"canCopy":true,"canDeleteDrive":false,"canDownload":true,"canEdit":true,"canListChildren":true,"canManageMembers":true,"canReadRevisions":true,"canRename":true,"canRenameDrive":true,"canChangeDriveBackground":true,"canShare":true,"canChangeCopyRequiresWriterPermissionRestriction":false,"canChangeDomainUsersOnlyRestriction":false,"canChangeDriveMembersOnlyRestriction":false,"canChangeSharingFoldersRequiresOrganizerPermissionRestriction":false,"canResetDriveRestrictions":false,"canDeleteChildren":false,"canTrashChildren":true},"themeId":"theme123","backgroundImageFile":{"id":"image123","xCoordinate":100.0,"yCoordinate":50.0,"width":800.0},"createdTime":"2023-06-15T10:30:00Z","hidden":false,"restrictions":{"copyRequiresWriterPermission":true,"domainUsersOnly":false,"driveMembersOnly":true,"adminManagedRestrictions":false,"sharingFoldersRequiresOrganizerPermission":true},"orgUnitId":"org123"},{"id":"drive456","name":"Not Populated Drive"}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_DRIVES_ENDPOINT,
            200,
            nextPageDriveSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleDriveSearchResult result = testGoogleDrive.drives().search('4mzkteXuXufI6lXV4mzkteXuXufI6lXV')
            .execute();
        Assert.areEqual('2fd620046218c04c12709a67c4879de9', result.nextPageToken);
        Test.stopTest();
    }

    @isTest
    private static void testDriveSearchFail() {
        String failedDriveSearchBody = '{"error": {"errors": [{"domain": "global","reason": "authError","message": "Invalid Credentials","locationType": "header","location": "Authorization"}],"code": 401,"message": "Invalid Credentials"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_DRIVES_ENDPOINT,
            GoogleConstants.HTTP_UNAUTHORIZED_STATUS_CODE,
            failedDriveSearchBody,
            new Map<String, String>()
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            GoogleDriveSearchResult result = testGoogleDrive.drives().search().execute();
        } catch (CalloutException ex) {
            Assert.areEqual(failedDriveSearchBody, ex.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    private static void testNextPageFileSearch() {
        String nextPageFileSearchBody = '{"nextPageToken": "~!!~AI9FV7ThOnDGgvVJDf_o4en1NZxTE_2tX-FVRhM-0UKO3MxOQh-dMLY4EiA==","kind": "drive#fileList","incompleteSearch": true,"files": [{"kind": "drive#file","mimeType": "application/vnd.google-apps.folder","id": "1dmEbuynf_W6064Acrx8RrpqU4EL60mRs","name": "Test"},{"kind": "drive#file","mimeType": "application/vnd.google-apps.folder","id": "1porUCOPDqUHXji8jCRqfG4cjj1gmJTVL","name": "audio"},{"kind": "drive#file","mimeType": "video/quicktime","id": "1ZqgilKNUpNIwvAotA5ss7Wc6swBmApkD","name": "Test.MOV"}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_FILES_ENDPOINT,
            200,
            nextPageFileSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileSearchResult result = testGoogleDrive.files().search('~!!~BI9FV7ThOnDGgvVJDf_o4en1NZxEOJxjGmloO1QwivWraJd4UKiAAiFaEyV==')
            .setDriveId('1QwraJd4UKiAAiFaEyV2worNpYLnbZd4')
            .setOrderBy('name')
            .execute();
        Assert.areEqual('~!!~AI9FV7ThOnDGgvVJDf_o4en1NZxTE_2tX-FVRhM-0UKO3MxOQh-dMLY4EiA==', result.nextPageToken);
        Test.stopTest();
    }

    @isTest
    private static void testFullFileSearch() {
        String fullFileSearchBody = '{"kind": "drive#fileList","incompleteSearch": false,"files": [{"kind": "drive#file","mimeType": "application/vnd.google-apps.folder","id": "1dmEbuynf_W6064Acrx8RrpqU4EL60mRs","name": "Test"},{"kind": "drive#file","mimeType": "application/vnd.google-apps.folder","id": "1porUCOPDqUHXji8jCRqfG4cjj1gmJTVL","name": "audio"},{"kind": "drive#file","mimeType": "video/quicktime","id": "1ZqgilKNUpNIwvAotA5ss7Wc6swBmApkD","name": "Test.MOV"}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_FILES_ENDPOINT,
            200,
            fullFileSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileSearchResult result = testGoogleDrive.files().search()
            .setMaxResult(3)
            .setSearchQuery('trashed = false')
            .setSearchOnAllDrives(true)
            .setFields('fields/*')
            .setOrderBy('folder,modifiedTime desc,name')
            .execute();
        Assert.areEqual(3, result.files.size());
        Test.stopTest();
    }

    @isTest
    private static void testFileSearchFail() {
        String failedFileSearchBody = '{"error": {"errors": [{"domain": "global","reason": "authError","message": "Invalid Credentials","locationType": "header","location": "Authorization"}],"code": 401,"message": "Invalid Credentials"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_FILES_ENDPOINT,
            GoogleConstants.HTTP_UNAUTHORIZED_STATUS_CODE,
            failedFileSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            GoogleFileSearchResult result = testGoogleDrive.files().search().execute();
        } catch (CalloutException ex) {
            Assert.areEqual(failedFileSearchBody, ex.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    private static void testSimpleFileUpload() {
        String successSimpleFileUpload = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","name": "My Document","driveId": "0BwwA4oUTeiV1UVNwOHItT0xfa0U","fileExtension": "docx","copyRequiresWriterPermission": false,"md5Checksum": "d41d8cd98f00b204e9800998ecf8427e","writersCanShare": true,"viewedByMe": true,"mimeType": "application/vnd.google-apps.document","exportLinks": {"application/pdf": "https://drive.google.com/uc?id=1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9&export=pdf"},"parents": ["0BwwA4oUTeiV1NHRlWE56R2EwOEU"],"thumbnailLink": "https://drive.google.com/thumbnail?id=1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","iconLink": "https://drive.google.com/icon?id=1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","shared": false,"lastModifyingUser": {"displayName": "John Doe","kind": "drive#user","me": true,"permissionId": "123456789","emailAddress": "johndoe@example.com","photoLink": "https://example.com/photo.jpg"},"owners": [{"displayName": "John Doe","kind": "drive#user","me": true,"permissionId": "123456789","emailAddress": "johndoe@example.com","photoLink": "https://example.com/photo.jpg"}],"headRevisionId": "0123456789","sharingUser": {"displayName": "Jane Doe","kind": "drive#user","me": false,"permissionId": "987654321","emailAddress": "janedoe@example.com","photoLink": "https://example.com/photo2.jpg"},"webViewLink": "https://drive.google.com/file/d/1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9/view","webContentLink": "https://drive.google.com/uc?id=1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9&export=download","size": "102400","viewersCanCopyContent": true,"permissions": [{"id": "1234567890","displayName": "Jane Doe","type": "user","kind": "drive#permission","permissionDetails": [],"photoLink": "https://example.com/photo2.jpg","emailAddress": "janedoe@example.com","role": "reader","allowFileDiscovery": false,"domain": "","expirationTime": "","teamDrivePermissionDetails": [],"deleted": false,"view": "","pendingOwner": false}],"hasThumbnail": true,"spaces": ["drive"],"folderColorRgb": "#FF0000","description": "A sample document","starred": false,"trashed": false,"explicitlyTrashed": false,"createdTime": "2024-06-29T12:00:00.000Z","modifiedTime": "2024-06-29T12:30:00.000Z","modifiedByMeTime": "2024-06-29T12:15:00.000Z","viewedByMeTime": "2024-06-29T12:20:00.000Z","sharedWithMeTime": "2024-06-29T12:10:00.000Z","quotaBytesUsed": "102400","version": "1","originalFilename": "my_document.docx","ownedByMe": true,"fullFileExtension": "docx","properties": {"key1": "value1"},"appProperties": {"key2": "value2"},"isAppAuthorized": true,"teamDriveId": "0BwwA4oUTeiV1UVNwOHItT0xfa0U","capabilities": {"canEdit": true,"canComment": true,"canShare": true},"hasAugmentedPermissions": false,"trashingUser": {"displayName": "John Doe","kind": "drive#user","me": true,"permissionId": "123456789","emailAddress": "johndoe@example.com","photoLink": "https://example.com/photo.jpg"},"thumbnailVersion": "1","trashedTime": "","modifiedByMe": true,"permissionIds": ["1234567890"],"imageMediaMetadata": {"width": 800,"height": 600},"videoMediaMetadata": {"width": 1920,"height": 1080,"durationMillis": "120000"},"shortcutDetails": {"targetId": "0BwwA4oUTeiV1UVNwOHItT0xfa0U","targetMimeType": "application/vnd.google-apps.folder","targetResourceKey": "resourceKey123"},"resourceKey": "resourceKey123","linkShareMetadata": {"securityUpdateEligible": true,"securityUpdateEnabled": true},"sha1Checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709","sha256Checksum": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.UPLOAD_FILES_ENDPOINT,
            200,
            successSimpleFileUpload
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().simpleCreate()
            .setContentType('text/plain')
            .setContentLength(11)
            .setFields('id, name, driveId, fileExtension, copyRequiresWriterPermission, md5Checksum, writersCanShare, viewedByMe, mimeType, exportLinks, parents, thumbnailLink, iconLink, shared, lastModifyingUser, owners, headRevisionId, sharingUser, webViewLink, webContentLink, size, viewersCanCopyContent, permissions, hasThumbnail, spaces, folderColorRgb, description, starred, trashed, explicitlyTrashed, createdTime, modifiedTime, modifiedByMeTime, viewedByMeTime, sharedWithMeTime, quotaBytesUsed, version, originalFilename, ownedByMe, fullFileExtension, properties, appProperties, isAppAuthorized, teamDriveId, capabilities, hasAugmentedPermissions, trashingUser, thumbnailVersion, trashedTime, modifiedByMe, permissionIds, imageMediaMetadata, videoMediaMetadata, shortcutDetails, resourceKey, linkShareMetadata, sha1Checksum, sha256Checksum')
            .setBody(Blob.valueOf('Hello World'))
            .execute();

        // Fields that are specified in "setFields()" will be received 
        // in response to the creation of the document, 
        // validation is performed only for some of them, 
        // so as not to clutter the test class.
        Assert.isNotNull(result.id);
        Assert.isNotNull(result.name);
        Assert.isNotNull(result.driveId);
        Test.stopTest();
    }

    @isTest
    private static void testMultipartFileUpload() {
        String successMultipartFileUpload = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","name": "My Document","driveId": "0BwwA4oUTeiV1UVNwOHItT0xfa0U","fileExtension": "docx","copyRequiresWriterPermission": false,"md5Checksum": "d41d8cd98f00b204e9800998ecf8427e","writersCanShare": true,"viewedByMe": true,"mimeType": "application/vnd.google-apps.document","exportLinks": {"application/pdf": "https://drive.google.com/uc?id=1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9&export=pdf"},"parents": ["0BwwA4oUTeiV1NHRlWE56R2EwOEU"],"thumbnailLink": "https://drive.google.com/thumbnail?id=1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","iconLink": "https://drive.google.com/icon?id=1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","shared": false,"lastModifyingUser": {"displayName": "John Doe","kind": "drive#user","me": true,"permissionId": "123456789","emailAddress": "johndoe@example.com","photoLink": "https://example.com/photo.jpg"},"owners": [{"displayName": "John Doe","kind": "drive#user","me": true,"permissionId": "123456789","emailAddress": "johndoe@example.com","photoLink": "https://example.com/photo.jpg"}],"headRevisionId": "0123456789","sharingUser": {"displayName": "Jane Doe","kind": "drive#user","me": false,"permissionId": "987654321","emailAddress": "janedoe@example.com","photoLink": "https://example.com/photo2.jpg"},"webViewLink": "https://drive.google.com/file/d/1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9/view","webContentLink": "https://drive.google.com/uc?id=1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9&export=download","size": "102400","viewersCanCopyContent": true,"permissions": [{"id": "1234567890","displayName": "Jane Doe","type": "user","kind": "drive#permission","permissionDetails": [],"photoLink": "https://example.com/photo2.jpg","emailAddress": "janedoe@example.com","role": "reader","allowFileDiscovery": false,"domain": "","expirationTime": "","teamDrivePermissionDetails": [],"deleted": false,"view": "","pendingOwner": false}],"hasThumbnail": true,"spaces": ["drive"],"folderColorRgb": "#FF0000","description": "A sample document","starred": false,"trashed": false,"explicitlyTrashed": false,"createdTime": "2024-06-29T12:00:00.000Z","modifiedTime": "2024-06-29T12:30:00.000Z","modifiedByMeTime": "2024-06-29T12:15:00.000Z","viewedByMeTime": "2024-06-29T12:20:00.000Z","sharedWithMeTime": "2024-06-29T12:10:00.000Z","quotaBytesUsed": "102400","version": "1","originalFilename": "my_document.docx","ownedByMe": true,"fullFileExtension": "docx","properties": {"key1": "value1"},"appProperties": {"key2": "value2"},"isAppAuthorized": true,"teamDriveId": "0BwwA4oUTeiV1UVNwOHItT0xfa0U","capabilities": {"canEdit": true,"canComment": true,"canShare": true},"hasAugmentedPermissions": false,"trashingUser": {"displayName": "John Doe","kind": "drive#user","me": true,"permissionId": "123456789","emailAddress": "johndoe@example.com","photoLink": "https://example.com/photo.jpg"},"thumbnailVersion": "1","trashedTime": "","modifiedByMe": true,"permissionIds": ["1234567890"],"imageMediaMetadata": {"width": 800,"height": 600},"videoMediaMetadata": {"width": 1920,"height": 1080,"durationMillis": "120000"},"shortcutDetails": {"targetId": "0BwwA4oUTeiV1UVNwOHItT0xfa0U","targetMimeType": "application/vnd.google-apps.folder","targetResourceKey": "resourceKey123"},"resourceKey": "resourceKey123","linkShareMetadata": {"securityUpdateEligible": true,"securityUpdateEnabled": true},"sha1Checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709","sha256Checksum": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.UPLOAD_FILES_ENDPOINT,
            200,
            successMultipartFileUpload
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().multipartCreate()
            .setContentLength(11)
            .setFields('id, name, driveId, fileExtension, copyRequiresWriterPermission, md5Checksum, writersCanShare, viewedByMe, mimeType, exportLinks, parents, thumbnailLink, iconLink, shared, lastModifyingUser, owners, headRevisionId, sharingUser, webViewLink, webContentLink, size, viewersCanCopyContent, permissions, hasThumbnail, spaces, folderColorRgb, description, starred, trashed, explicitlyTrashed, createdTime, modifiedTime, modifiedByMeTime, viewedByMeTime, sharedWithMeTime, quotaBytesUsed, version, originalFilename, ownedByMe, fullFileExtension, properties, appProperties, isAppAuthorized, teamDriveId, capabilities, hasAugmentedPermissions, trashingUser, thumbnailVersion, trashedTime, modifiedByMe, permissionIds, imageMediaMetadata, videoMediaMetadata, shortcutDetails, resourceKey, linkShareMetadata, sha1Checksum, sha256Checksum')
            .setFileName('Multipart Upload')
            .setMimeType('application/vnd.google-apps.document')
            .setParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM', '1TLDWgrczvSFnnJpU-2OEEEXMy77OVLjM'})
            .setBody('text/plain', '8bit', 'Hello World')
            .execute();

        // Fields that are specified in "setFields()" will be received 
        // in response to the creation of the document, 
        // validation is performed only for some of them, 
        // so as not to clutter the test class.
        Assert.isNotNull(result.id);
        Assert.isNotNull(result.name);
        Assert.isNotNull(result.driveId);
        Test.stopTest();
    }

    @isTest
    private static void testMultipartFileUploadFail() {
        String failedMultipartFileUpload = '{"error": {"errors": [{"domain": "global","reason": "authError","message": "Invalid Credentials","locationType": "header","location": "Authorization"}],"code": 401,"message": "Invalid Credentials"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.UPLOAD_FILES_ENDPOINT,
            GoogleConstants.HTTP_UNAUTHORIZED_STATUS_CODE,
            failedMultipartFileUpload
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            GoogleFileEntity result = testGoogleDrive.files().multipartCreate()
                .setContentLength('11')
                .setFields('id, name')
                .setFileName('Multipart Failed Upload')
                .setBody('Hello World') // The standard "base64" encoding does not match the content
                .execute();
        } catch (CalloutException ex) {
            Assert.areEqual(failedMultipartFileUpload, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testResumableFileUpload() {
        String successInitializedUri = 'https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable&upload_id=ADPycjXkG3_J2JkRhql6g9lPqXEd75CMfbk1fP4O6ZWB7wNHUpl9Tp6V0kF9';
        String successResumableFileUpload = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9"}';

        Test.startTest();
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        
        // Before uploading a file in parts, the transaction must be initialized, during which all metadata is specified
        GoogleDriveHttpMockGenerator testInitCalloutMock = new GoogleDriveHttpMockGenerator(GoogleConstants.UPLOAD_FILES_ENDPOINT, 200, '', new Map<String, String>{'Location' => successInitializedUri});
        Test.setMock(HttpCalloutMock.class, testInitCalloutMock);
        GoogleBigFileEntity initResult = testGoogleDrive.files().resumableCreate()
            .setFields('id')
            .setFileName('Resumable Upload File')
            .setMimeType('application/vnd.google-apps.document')
            .setParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM'})
            .initialize();

        // The initialization process results in an endpoint with Uniform Resource Identifier (URI)
        Assert.areEqual(successInitializedUri, initResult.resumableSessionId);

        // It is not necessary to have the complete document body (as the heap size is limited); having the total size in bytes is sufficient
        Blob fullFileBody = Blob.valueOf('Hello World');

        // Upload a portion of the document & specify the starting byte and the document's total size
        Blob firstFileChunk = Blob.valueOf('Hello');
        GoogleDriveHttpMockGenerator testChunkCalloutMock = new GoogleDriveHttpMockGenerator(initResult.resumableSessionId, 308, '', new Map<String, String>{'Range' => 'bytes=0-5'});
        Test.setMock(HttpCalloutMock.class, testChunkCalloutMock);
        GoogleBigFileEntity chunksResult = testGoogleDrive.files().resumableCreate()
            .setExistingSessionUri(initResult.resumableSessionId)
            .setBody(firstFileChunk)
            .setStartByte(0)
            .setTotalBytes(fullFileBody.size())
            .execute();

        // Uploading a chunk returns the number of bytes successfully uploaded, which may not always match the expected bytes
        Assert.areNotEqual(0, chunksResult.resumableLatestByte);

        // Upload the second part of the document by specifying a new body and starting byte
        Blob secondFileChunk = Blob.valueOf(' World');
        GoogleDriveHttpMockGenerator testUploadCalloutMock = new GoogleDriveHttpMockGenerator(initResult.resumableSessionId, 201, successResumableFileUpload);
        Test.setMock(HttpCalloutMock.class, testUploadCalloutMock);
        chunksResult = testGoogleDrive.files().resumableCreate()
            .setExistingSessionUri(initResult.resumableSessionId)
            .setBody(secondFileChunk)
            .setStartByte(chunksResult.resumableLatestByte)
            .setTotalBytes(fullFileBody.size())
            .execute();

        Assert.isNotNull(chunksResult.file);
        Test.stopTest();
    }

    @isTest
    private static void testCloneFile() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successFileCloned = '{"kind": "drive#file","id": "1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw","name": "CopiedDocument"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.CLONE_FILE_ENDPOINT, testFileId),
            200,
            successFileCloned
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().clone(testFileId)
            .setFields('id, name')
            .setFileName('CopiedDocument')
            .setMimeType('application/vnd.google-apps.document')
            .setParentFolders(new List<String>{'1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw'})
            .execute();

        // Fields that are specified in "setFields()" will be received 
        // in response to the cloning of the document
        Assert.isNotNull(result.id);
        Assert.isNotNull(result.name);
        Test.stopTest();
    }

    @isTest
    private static void testDeleteFile() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.DELETE_FILE_ENDPOINT, testFileId),
            204,
            ''
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        testGoogleDrive.files().remove(testFileId)
            .setSupportsAllDrives(true)
            .execute();
        Test.stopTest();
    }

    @isTest
    private static void testPermissionFileCreate() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successFilePermissionCreated = '{"kind": "drive#permission","id": "1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw","type": "user","emailAddress": "test@gmail.com","role": "reader","domain": "","allowFileDiscovery": false,"displayName": "Example User"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.NEW_PERMISSION_FILE_ENDPOINT, testFileId),
            200,
            successFilePermissionCreated
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GooglePermissionEntity result = testGoogleDrive.files().permission().create(testFileId)
            .setSendNotificationEmail(true)
            .setTransferOwnership(false)
            .setPrincipalType('user')
            .setPrincipalRole('reader')
            .setPrincipalEmailAddress('test@gmail.com')
            .execute();

        Assert.isNotNull(result.id);
        Test.stopTest();
    }

    @isTest
    private static void testPermissionFileDelete() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String testPermissionId = '01649911713816498250';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.NEW_PERMISSION_FILE_ENDPOINT, testFileId, testPermissionId),
            204,
            ''
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        testGoogleDrive.files().permission().remove(testFileId, testPermissionId)
            .setDomainAdminAccess(true)
            .setSupportsAllDrives(false)
            .execute();

        Test.stopTest();
    }

    @isTest
    private static void testRetrieveFileByDownloadMetadata() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successFileDownloaded = '{"kind": "drive#file","id": "1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw","name": "filename","mimeType": "application/pdf"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.GET_FILE_ENDPOINT, testFileId),
            200,
            successFileDownloaded
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().retrieve().download(testFileId)
            .setFileDownloadType(GoogleDownloadFileBuilder.DownloadType.METADATA)
            .setSearchOnAllDrives(false)
            .execute();

        Assert.isNotNull(result.id);
        Test.stopTest();
    }

    @isTest
    private static void testRetrieveFileByDownloadContent() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successFileDownloaded = 'JVBERi0xLjUKJdP0zOEKNSAwIG9iaiA8PAovQ3JlYXRvciAoQWRvYmUgUERGIGxpYn';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.GET_FILE_ENDPOINT, testFileId),
            200,
            successFileDownloaded
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().retrieve().download(testFileId)
            .setFileDownloadType(GoogleDownloadFileBuilder.DownloadType.CONTENT)
            .execute();

        Assert.isNotNull(result.body);
        Test.stopTest();
    }

    @isTest
    private static void testRetrieveFileByExport() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successFileExported = '{"body": {"content": [{"endIndex": 650, "paragraph": {"elements": [{"endIndex": 650, "startIndex": 590, "textRun": {"content": "And this is a paragraph that follows the level two heading.\n", "textStyle": {}}}], "paragraphStyle": {"direction": "LEFT_TO_RIGHT", "namedStyleType": "NORMAL_TEXT"}}, "startIndex": 590}]}, "documentId": "1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw", "documentStyle": {}, "lists": {}, "namedStyles": {"styles": []}, "revisionId": "np_INheZiecEMA", "suggestionsViewMode": "SUGGESTIONS_INLINE", "title": "Test mule"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.EXPORT_FILE_ENDPOINT, testFileId),
            200,
            successFileExported
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().retrieve().export(testFileId)
            .setMimeType('text/plain')
            .execute();

        Assert.isNotNull(result.body);
        Test.stopTest();
    }

    private static String buildFileDependentEndpoint(String baseEndpoint, String fileId) {
        return String.format(baseEndpoint, new List<String>{fileId});
    }

    private static String buildFileDependentEndpoint(String baseEndpoint, String fileId, String whateverId) {
        return String.format(baseEndpoint, new List<String>{fileId, whateverId});
    }

    private static void buildGoogleDriveInfo() {
        userAgentName = 'Google Drive/v3 test';
        testCredentials = new GoogleCredential();
        testCredentials.accessToken = 'aZ3X8kP2RtaZ3X8kP2RtaZ3X8kP2RtaZ';
        testCredentials.tokenType = 'Bearer'; 
    }
}
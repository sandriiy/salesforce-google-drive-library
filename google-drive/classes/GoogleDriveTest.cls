/**
 * MIT License
 *
 * Copyright (c) 2024-2026 Andrii Sukhetskyi
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

@isTest
private class GoogleDriveTest {
    public class TestGoogleScopedAuthorizer implements GoogleScopedAuthorizer {
        public String retrieveAccessToken(List<GoogleScope> requestedScopes) {
            GoogleDriveTest.capturedScopes = requestedScopes;
            return 'aZ3X8kP2RtaZ3X8kP2RtaZ3X8kP2RtaZ';
        }
    }

    public class TestGoogleLegacyAuthorizer implements GoogleAuthorizer {
        public String retrieveAccessToken() {
            return 'legacyaZ3X8kP2RtaZ3X8kP2RtaZ3X8kP2';
        }
    }

    private static GoogleCredential testCredentials;
    private static String userAgentName;

	@TestVisible private static Boolean failStrategyWasCalled = false;
    @TestVisible private static List<GoogleScope> capturedScopes;
	public class TestGoogleFileErrorHandler implements GoogleFailureStrategy {
		public void onFailure(GoogleCloudException ex) {
			// Your Error Processing
			System.debug(ex.getMessage());
			System.debug(ex.endpoint);
			System.debug(JSON.serialize(ex.httpHeaders));
			System.debug(JSON.serialize(ex.httpParameters));

			GoogleDriveTest.failStrategyWasCalled = true;
		}
	}

	@isTest
    private static void testFailureStrategeWithSearchFiles() {
        String failedFileSearchBody = '{"error": {"errors": [{"domain": "global","reason": "required","message": "shared drive not specified"}],"code": 400,"message": "shared drive not specified"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_FILES_ENDPOINT,
            400,
            failedFileSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName).withFailureStrategy('GoogleDriveTest.TestGoogleFileErrorHandler');
        try {
            GoogleFileSearchResult result = testGoogleDrive.files().search()
                .setSearchQuery('name contains "Test"')
                .execute();
				
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(true, GoogleDriveTest.failStrategyWasCalled);
        }
        Test.stopTest();
    }

	@isTest
    private static void testModifyExistingFileMetadata() {
        String successSimpleFileChange = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","name": "My Document","parents": ["0BwwA4oUTeiV2NHRlWE56R2EwOEU"]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.UPDATE_FILE_ENDPOINT,
            200,
            successSimpleFileChange
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

		String existingFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
		String existingParentFolderId = '0BwwA4oUTeiV1NHRlWE56R2EwOEU';
		String newParentFolderId = '0BwwA4oUTeiV2NHRlWE56R2EwOEU';

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().modify().metadata(existingFileId)
            .addParentFolders(new List<String>{newParentFolderId})
            .removeParentFolders(new List<String>{existingParentFolderId})
            .setSupportsAllDrives(true)
			.setFields('name, parents')
            .execute();

        Assert.areEqual(newParentFolderId, result.parents.get(0));
        Test.stopTest();
    }

    @isTest
    private static void testSupportsAllDrivesFlagOnFileDelete() {
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
            .setSupportsAllDrives(true) // Lets this request target files residing in Shared Drives
            .execute();
        Test.stopTest();
    }

	@isTest
    private static void testSupportsAllDrivesFlagOnFileTrash() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.TRASH_FILE_ENDPOINT, testFileId),
            200,
            ''
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        testGoogleDrive.files().trash(testFileId)
            .setSupportsAllDrives(true) // Lets this request target files residing in Shared Drives
            .execute();
        Test.stopTest();
    }

    @isTest
    private static void testSupportsAllDrivesOnFileSearch() {
        String fullFileSearchBody = '{"kind": "drive#fileList","incompleteSearch": false,"files": [{"kind": "drive#file","mimeType": "application/vnd.google-apps.folder","id": "1dmEbuynf_W6064Acrx8RrpqU4EL60mRs","name": "Test"}]}';
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
            .setSearchQuery('trashed = false')
            .setSearchOnAllDrives(true) // Enables searching items that live inside Shared Drives
            .setMaxResult(1)
            .execute();
        Assert.areEqual(1, result.files.size());
        Test.stopTest();
    }

    @isTest
    private static void testSupportsAllDrivesOnPermissionList() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String permissionsSearchBody = '{"permissions":[{"id":"0123456789abcdef","emailAddress":"user@example.com"}],"kind":"drive#permissionList"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.LIST_PERMISSIONS_FILE_ENDPOINT, testFileId),
            200,
            permissionsSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GooglePermissionSearchResult result = testGoogleDrive.permissions().search(testFileId)
            .setSearchOnAllDrives(true) // Allow permission introspection on Shared Drive items
            .setMaxResult(10)
            .execute();

        Assert.areEqual(1, result.permissions.size());
        Test.stopTest();
    }

    @isTest
    private static void testFailWhenSharedDriveNotSpecified_FileSearch() {
        String failedFileSearchBody = '{"error": {"errors": [{"domain": "global","reason": "required","message": "shared drive not specified"}],"code": 400,"message": "shared drive not specified"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_FILES_ENDPOINT,
            400,
            failedFileSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            GoogleFileSearchResult result = testGoogleDrive.files().search()
                .setSearchQuery('name contains "Test"')
                .execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            // API returns 400 when querying Shared Drive scope without indicating which drive or enabling all drives
            Assert.areEqual(failedFileSearchBody, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testFailWhenSharedDriveNotSpecified_PermissionsList() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String failedPermissionsBody = '{"error": {"errors": [{"domain": "global","reason": "required","message": "shared drive not specified"}],"code": 400,"message": "shared drive not specified"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.LIST_PERMISSIONS_FILE_ENDPOINT, testFileId),
            400,
            failedPermissionsBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            GooglePermissionSearchResult result = testGoogleDrive.permissions().search(testFileId).execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            // API expects Shared Drive awareness for permission listings of Shared Drive files
            Assert.areEqual(failedPermissionsBody, ex.getMessage());
        }
        Test.stopTest();
    }

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
        } catch (GoogleCloudException ex) {
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
            .setSearchOnAllDrives(true) // Include items from Shared Drives in search results
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
        } catch (GoogleCloudException ex) {
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
    private static void testMultipartShortcutUpload() {
        String shortcutTargetId = '1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM';
        String successMultipartFileUpload = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","name": "My Shortcut","mimeType": "application/vnd.google-apps.shortcut","shortcutDetails": {"targetId": "' + shortcutTargetId + '","targetMimeType": "application/vnd.google-apps.folder"}}';

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
            .setFileName('Shortcut Upload')
            .setMimeType('application/vnd.google-apps.shortcut')
            .setFields('id, name, mimeType, shortcutDetails')
            .setShortcutTarget(shortcutTargetId)
            .execute();

        Assert.isNotNull(result.id);
        Assert.areEqual('application/vnd.google-apps.shortcut', result.mimeType);
        Assert.isNotNull(result.shortcutDetails);
        Assert.areEqual(shortcutTargetId, result.shortcutDetails.targetId);
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
        } catch (GoogleCloudException ex) {
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
			.setCustomAttributes(new Map<String, String>{'recordId' => '1A000000000000'})
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
            .setSupportsAllDrives(true) // Allow delete operation on Shared Drive files
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
        GooglePermissionEntity result = testGoogleDrive.permissions().create(testFileId)
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
    private static void testPermissionFileDomainCreate() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successFilePermissionCreated = '{"kind": "drive#permission","id": "1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw","type": "domain"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.NEW_PERMISSION_FILE_ENDPOINT, testFileId),
            200,
            successFilePermissionCreated
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GooglePermissionEntity result = testGoogleDrive.permissions().create(testFileId)
            .setSupportsAllDrives(true)
            .setPrincipalType('domain')
            .setPrincipalRole('reader')
            .setPrincipalDomain('cloudrylabs.com')
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
        testGoogleDrive.permissions().remove(testFileId, testPermissionId)
            .setDomainAdminAccess(true)
            .setSupportsAllDrives(false)
            .execute();

        Test.stopTest();
    }

	@isTest
    private static void testPermissionFileSearch() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String permissionsSearchBody = '{"permissions":[{"id":"0123456789abcdef","emailAddress":"user@example.com"}],"kind":"drive#permissionList"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.LIST_PERMISSIONS_FILE_ENDPOINT, testFileId),
            200,
            permissionsSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GooglePermissionSearchResult result = testGoogleDrive.permissions().search(testFileId)
			.setMaxResult(10)
			.setFields('emailAddress')
			.setSearchOnAllDrives(true) // List permissions for items located in Shared Drives
			.execute();

		Assert.areEqual(1, result.permissions.size());
		Assert.areEqual('user@example.com', result.permissions.get(0).emailAddress);

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
            .setSearchOnAllDrives(false) // Restrict to My Drive only; no Shared Drives lookup
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
    private static void testRetrieveFileChunkByDownloadContent() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successFileDownloaded = 'JVBERi0xLj';
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
			.setPartialRange(0, 9)
			.setFields('name, description')
            .execute();

        Assert.isNotNull(result.body);
		Assert.areEqual(10, result.body.length());
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
			.setFields('name, description')
			.setSearchOnAllDrives(true)
            .execute();

        Assert.isNotNull(result.body);
        Test.stopTest();
    }

    @isTest
    private static void testScopedAuthorizerReceivesDeclaredScopes() {
        List<GoogleScope> declaredScopes = new List<GoogleScope>{
            GoogleScope.DRIVE_FILE,
            GoogleScope.DRIVE_METADATA_READONLY
        };

        Test.startTest();
        GoogleCredential scopedCredentials = new GoogleAuthorizationCodeFlow.Builder()
            .setLocalGoogleAuthorizer('GoogleDriveTest.TestGoogleScopedAuthorizer')
            .setRequestedScopes(declaredScopes)
            .build();

        Assert.areEqual(declaredScopes, GoogleDriveTest.capturedScopes);
        Assert.areEqual('Bearer', scopedCredentials.tokenType);
        Assert.isNotNull(scopedCredentials.accessToken);
        Test.stopTest();
    }

    @isTest
    private static void testLegacyAuthorizerStillResolvesWhenScopesAreDeclared() {
        Test.startTest();
        GoogleCredential legacyCredentials = new GoogleAuthorizationCodeFlow.Builder()
            .setLocalGoogleAuthorizer('GoogleDriveTest.TestGoogleLegacyAuthorizer')
            .setRequestedScopes(new List<GoogleScope>{GoogleScope.DRIVE})
            .build();

        Assert.areEqual('legacyaZ3X8kP2RtaZ3X8kP2RtaZ3X8kP2', legacyCredentials.accessToken);
        Test.stopTest();
    }

    @isTest
    private static void testLegacyAuthorizerResolvesWithoutScopes() {
        Test.startTest();
        GoogleCredential legacyCredentials = new GoogleAuthorizationCodeFlow.Builder()
            .setLocalGoogleAuthorizer('GoogleDriveTest.TestGoogleLegacyAuthorizer')
            .build();

        Assert.areEqual('legacyaZ3X8kP2RtaZ3X8kP2RtaZ3X8kP2', legacyCredentials.accessToken);
        Assert.areEqual('Bearer', legacyCredentials.tokenType);
        Test.stopTest();
    }

    @isTest
    private static void testEveryScopeResolvesToAnUrl() {
        Test.startTest();
        for (GoogleScope oneScope : GoogleScope.values()) {
            Assert.isNotNull(GoogleScopeResolver.toScopeUrl(oneScope), 'Unmapped scope: ' + oneScope);
        }

        Assert.areEqual(GoogleConstants.DRIVE_FILE_SCOPE_URL, GoogleScopeResolver.toScopeUrl(GoogleScope.DRIVE_FILE));
        Assert.areEqual('', GoogleScopeResolver.toScopeUrls(null));
        Test.stopTest();
    }

    @isTest
    private static void testScopeUrlsAreSortedAndDeduplicated() {
        Test.startTest();
        List<String> scopeUrls = GoogleScopeResolver.toScopeUrlList(
            new List<GoogleScope>{
                GoogleScope.DRIVE_READONLY,
                GoogleScope.DRIVE_FILE,
                GoogleScope.DRIVE_FILE
            }
        );

        Assert.areEqual(2, scopeUrls.size());
        Assert.areEqual(GoogleConstants.DRIVE_FILE_SCOPE_URL, scopeUrls[0]);
        Assert.areEqual(GoogleConstants.DRIVE_READONLY_SCOPE_URL, scopeUrls[1]);
        Test.stopTest();
    }

    @isTest
    private static void testSimpleFileVersionUpload() {
        String existingFileId = '1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9';
        String successVersionUpload = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","name": "Versioned File"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.VERSION_UPLOAD_FILES_ENDPOINT, existingFileId),
            200,
            successVersionUpload
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().modify().simpleUpdate(existingFileId)
            .setContentType('text/plain')
            .setBody(Blob.valueOf('A brand new version of the file'))
            .setKeepRevisionForever(true)
            .setFields('id,name')
            .setSupportsAllDrives(true)
            .execute();

        Assert.areEqual(existingFileId, result.id);
        Assert.areEqual('Versioned File', result.name);
        Test.stopTest();
    }

    @isTest
    private static void testMultipartFileVersionUpload() {
        String existingFileId = '1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9';
        String successVersionUpload = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","name": "Renamed Version"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.VERSION_UPLOAD_FILES_ENDPOINT, existingFileId),
            200,
            successVersionUpload
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().modify().multipartUpdate(existingFileId)
            .setFileName('Renamed Version')
            .setMimeType('text/plain')
            .setBody(EncodingUtil.base64Encode(Blob.valueOf('A brand new version of the file')))
            .setUseContentAsIndexableText(true)
            .addParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM'})
            .setFields('id,name')
            .setSupportsAllDrives(true)
            .execute();

        Assert.areEqual(existingFileId, result.id);
        Assert.areEqual('Renamed Version', result.name);
        Test.stopTest();
    }

    @isTest
    private static void testFileVersionUploadFail() {
        String existingFileId = '1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9';
        String failedVersionUpload = '{"error": {"errors": [{"domain": "global","reason": "notFound","message": "File not found"}],"code": 404,"message": "File not found"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.VERSION_UPLOAD_FILES_ENDPOINT, existingFileId),
            404,
            failedVersionUpload
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            testGoogleDrive.files().modify().simpleUpdate(existingFileId)
                .setContentType('text/plain')
                .setBody(Blob.valueOf('A brand new version of the file'))
                .execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(failedVersionUpload, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testResumableFileVersionUpload() {
        String existingFileId = '1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9';
        String successInitializedUri = 'https://www.googleapis.com/upload/drive/v3/files/1ZdR3cU?uploadType=resumable&upload_id=ADPycjXkG3_J2JkRhql6';
        String successVersionUpload = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9"}';

        Test.startTest();
        buildGoogleDriveInfo();
        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);

        GoogleDriveHttpMockGenerator testInitCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.VERSION_UPLOAD_FILES_ENDPOINT, existingFileId),
            200,
            '',
            new Map<String, String>{'Location' => successInitializedUri}
        );
        Test.setMock(HttpCalloutMock.class, testInitCalloutMock);
        GoogleBigFileEntity initResult = testGoogleDrive.files().modify().resumableUpdate(existingFileId)
            .setMimeType('text/plain')
            .setKeepRevisionForever(true)
            .setSupportsAllDrives(true)
            .initialize();

        Assert.areEqual(successInitializedUri, initResult.resumableSessionId);

        Blob newVersionBody = Blob.valueOf('A brand new version of the file');
        GoogleDriveHttpMockGenerator testUploadCalloutMock = new GoogleDriveHttpMockGenerator(
            initResult.resumableSessionId,
            200,
            successVersionUpload
        );
        Test.setMock(HttpCalloutMock.class, testUploadCalloutMock);
        GoogleBigFileEntity uploadResult = testGoogleDrive.files().modify().resumableUpdate(existingFileId)
            .setExistingSessionUri(initResult.resumableSessionId)
            .setBody(newVersionBody)
            .setStartByte(0)
            .setTotalBytes(newVersionBody.size())
            .setSupportsAllDrives(true)
            .execute();

        Assert.isNotNull(uploadResult.file);
        Assert.areEqual(existingFileId, uploadResult.file.id);
        Test.stopTest();
    }

    @isTest
    private static void testRevisionSearch() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successRevisionSearch = '{"kind": "drive#revisionList","revisions": [{"id": "1","keepForever": false,"mimeType": "text/plain"},{"id": "2","keepForever": true,"mimeType": "text/plain"}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.LIST_REVISIONS_FILE_ENDPOINT, testFileId),
            200,
            successRevisionSearch
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleRevisionSearchResult result = testGoogleDrive.revisions().search(testFileId)
            .setMaxResult(10)
            .setFields('revisions(id,keepForever,mimeType)')
            .execute();

        Assert.areEqual(2, result.revisions.size());
        Assert.areEqual(true, result.revisions[1].keepForever);
        Test.stopTest();
    }

    @isTest
    private static void testRevisionRetrieveMetadataAndContent() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String testRevisionId = '0B7uV1kQ';
        String successRevision = '{"id": "0B7uV1kQ","mimeType": "text/plain","keepForever": true}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.GET_REVISION_FILE_ENDPOINT, testFileId, testRevisionId),
            200,
            successRevision
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleRevisionEntity metadataResult = testGoogleDrive.revisions().retrieve(testFileId, testRevisionId)
            .setFields('id,mimeType,keepForever')
            .execute();

        Assert.areEqual(testRevisionId, metadataResult.id);
        Assert.isNull(metadataResult.body);

        GoogleRevisionEntity contentResult = testGoogleDrive.revisions().retrieve(testFileId, testRevisionId)
            .setRevisionDownloadType(GoogleRetrieveRevisionBuilder.DownloadType.CONTENT)
            .setAcknowledgeAbuse(false)
            .execute();

        Assert.areEqual(successRevision, contentResult.body);
        Assert.isNotNull(contentResult.bodyAsBlob);
        Test.stopTest();
    }

    @isTest
    private static void testRevisionModifyAndDelete() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String testRevisionId = '0B7uV1kQ';
        String successRevision = '{"id": "0B7uV1kQ","keepForever": true}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_REVISION_FILE_ENDPOINT, testFileId, testRevisionId),
            200,
            successRevision
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleRevisionEntity pinned = testGoogleDrive.revisions().modify(testFileId, testRevisionId)
            .setKeepForever(true)
            .setPublished(false)
            .setFields('id,keepForever')
            .execute();

        Assert.areEqual(true, pinned.keepForever);

        testGoogleDrive.revisions().remove(testFileId, testRevisionId).execute();
        Test.stopTest();
    }

    @isTest
    private static void testRevisionSearchFail() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String failedRevisionSearch = '{"error": {"errors": [{"domain": "global","reason": "notFound","message": "File not found"}],"code": 404,"message": "File not found"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.LIST_REVISIONS_FILE_ENDPOINT, testFileId),
            404,
            failedRevisionSearch
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            testGoogleDrive.revisions().search(testFileId).execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(failedRevisionSearch, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testPermissionFileRetrieve() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String testPermissionId = '01649911713816498250';
        String successPermission = '{"id": "01649911713816498250","type": "user","role": "reader","emailAddress": "someone@example.com"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.GET_PERMISSION_FILE_ENDPOINT, testFileId, testPermissionId),
            200,
            successPermission
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GooglePermissionEntity result = testGoogleDrive.permissions().retrieve(testFileId, testPermissionId)
            .setFields('id,type,role')
            .setSupportsAllDrives(true)
            .setDomainAdminAccess(false)
            .execute();

        Assert.areEqual(testPermissionId, result.id);
        Assert.areEqual('reader', result.role);
        Test.stopTest();
    }

    @isTest
    private static void testPermissionFileModify() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String testPermissionId = '01649911713816498250';
        String successPermission = '{"id": "01649911713816498250","type": "user","role": "writer"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_PERMISSION_FILE_ENDPOINT, testFileId, testPermissionId),
            200,
            successPermission
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GooglePermissionEntity result = testGoogleDrive.permissions().modify(testFileId, testPermissionId)
            .setPrincipalRole('writer')
            .setRemoveExpiration(true)
            .setSupportsAllDrives(true)
            .setFields('id,role')
            .execute();

        Assert.areEqual('writer', result.role);
        Test.stopTest();
    }

    @isTest
    private static void testPermissionFileModifyFail() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String testPermissionId = '01649911713816498250';
        String failedPermission = '{"error": {"errors": [{"domain": "global","reason": "insufficientFilePermissions","message": "The user does not have sufficient permissions for this file."}],"code": 403,"message": "The user does not have sufficient permissions for this file."}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_PERMISSION_FILE_ENDPOINT, testFileId, testPermissionId),
            403,
            failedPermission
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            testGoogleDrive.permissions().modify(testFileId, testPermissionId)
                .setPrincipalRole('owner')
                .setTransferOwnership(true)
                .execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(failedPermission, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testDriveCreateAndRetrieve() {
        String testDriveId = '0AL7IuyV26qkAUk9PVA';
        String successDrive = '{"kind": "drive#drive","id": "0AL7IuyV26qkAUk9PVA","name": "Engineering","hidden": false}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.NEW_DRIVE_ENDPOINT,
            200,
            successDrive
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);

        GoogleDriveEntity created = testGoogleDrive.drives().create()
            .setDriveName('Engineering')
            .setColorRgb('#7986cb')
            .setFields('id,name')
            .execute();
        Assert.areEqual('Engineering', created.name);

        GoogleDriveEntity retrieved = testGoogleDrive.drives().retrieve(testDriveId)
            .setFields('id,name,hidden')
            .setDomainAdminAccess(false)
            .execute();
        Assert.areEqual(testDriveId, retrieved.id);
        Assert.areEqual(false, retrieved.hidden);
        Test.stopTest();
    }

    @isTest
    private static void testDriveModifyHideAndUnhide() {
        String testDriveId = '0AL7IuyV26qkAUk9PVA';
        String successDrive = '{"kind": "drive#drive","id": "0AL7IuyV26qkAUk9PVA","name": "Engineering Renamed","hidden": true}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_DRIVE_ENDPOINT, testDriveId),
            200,
            successDrive
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleDriveEntity renamed = testGoogleDrive.drives().modify(testDriveId)
            .setDriveName('Engineering Renamed')
            .setRestrictions(new Map<String, Object>{'domainUsersOnly' => true})
            .setFields('id,name')
            .execute();
        Assert.areEqual('Engineering Renamed', renamed.name);

        GoogleDriveEntity hidden = testGoogleDrive.drives().hide(testDriveId).setFields('id,hidden').execute();
        Assert.areEqual(true, hidden.hidden);

        GoogleDriveEntity unhidden = testGoogleDrive.drives().unhide(testDriveId).setFields('id,hidden').execute();
        Assert.isNotNull(unhidden.id);
        Test.stopTest();
    }

    @isTest
    private static void testDriveDelete() {
        String testDriveId = '0AL7IuyV26qkAUk9PVA';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.DELETE_DRIVE_ENDPOINT, testDriveId),
            204,
            ''
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        testGoogleDrive.drives().remove(testDriveId)
            .setAllowItemDeletion(true)
            .setDomainAdminAccess(true)
            .execute();
        Test.stopTest();
    }

    @isTest
    private static void testDriveCreateFail() {
        String failedDrive = '{"error": {"errors": [{"domain": "global","reason": "userCannotCreateTeamDrives","message": "The authenticated user cannot create shared drives."}],"code": 403,"message": "The authenticated user cannot create shared drives."}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.NEW_DRIVE_ENDPOINT,
            403,
            failedDrive
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            testGoogleDrive.drives().create().setDriveName('Engineering').setRequestId('a-stable-request-id').execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(failedDrive, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testLabelSearch() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successLabelSearch = '{"kind": "drive#labelList","labels": [{"id": "aBcDeF","revisionId": "1","fields": {"someFieldId": {"id": "someFieldId","valueType": "text","text": ["Confidential"]}}}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.LIST_LABELS_FILE_ENDPOINT, testFileId),
            200,
            successLabelSearch
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleLabelSearchResult result = testGoogleDrive.labels().search(testFileId)
            .setMaxResult(10)
            .execute();

        Assert.areEqual(1, result.labels.size());
        Assert.areEqual('Confidential', result.labels[0].fields.get('someFieldId').text[0]);
        Test.stopTest();
    }

    @isTest
    private static void testLabelModify() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successLabelModify = '{"kind": "drive#modifyLabelsResponse","modifiedLabels": [{"id": "aBcDeF","revisionId": "2"}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.MODIFY_LABELS_FILE_ENDPOINT, testFileId),
            200,
            successLabelModify
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleLabelModificationBuilder labelModification = new GoogleLabelModificationBuilder()
            .setLabelId('aBcDeF')
            .setTextValues('someFieldId', new List<String>{'Confidential'})
            .setIntegerValues('anotherFieldId', new List<Integer>{7});

        GoogleModifyLabelsResult result = testGoogleDrive.labels().modify(testFileId)
            .addLabelModification(labelModification)
            .execute();

        Assert.areEqual(1, result.modifiedLabels.size());
        Assert.areEqual('aBcDeF', result.modifiedLabels[0].id);
        Test.stopTest();
    }

    @isTest
    private static void testLabelModificationBuildsNestedBody() {
        Test.startTest();
        Map<String, Object> builtModification = new GoogleLabelModificationBuilder()
            .setLabelId('aBcDeF')
            .setTextValues('someFieldId', new List<String>{'Confidential'})
            .unsetValues('staleFieldId')
            .build();

        Assert.areEqual('aBcDeF', builtModification.get('labelId'));
        List<Object> fieldModifications = (List<Object>) builtModification.get('fieldModifications');
        Assert.areEqual(2, fieldModifications.size());
        Test.stopTest();
    }

    @isTest
    private static void testOperationRetrieve() {
        String testOperationName = 'operations/abc123';
        String successOperation = '{"name": "operations/abc123","done": true,"response": {"downloadUri": "https://example.com/file"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.GET_OPERATION_ENDPOINT, testOperationName),
            200,
            successOperation
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleOperationEntity result = testGoogleDrive.operations().retrieve(testOperationName)
            .setFields('name,done,response')
            .execute();

        Assert.areEqual(testOperationName, result.name);
        Assert.areEqual(true, result.done);
        Assert.isNotNull(result.response);
        Assert.areEqual('https://example.com/file', result.response.downloadUri);
        Test.stopTest();
    }

    @isTest
    private static void testOperationRetrieveFail() {
        String testOperationName = 'operations/missing';
        String failedOperation = '{"error": {"errors": [{"domain": "global","reason": "notFound","message": "Operation not found"}],"code": 404,"message": "Operation not found"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.GET_OPERATION_ENDPOINT, testOperationName),
            404,
            failedOperation
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            testGoogleDrive.operations().retrieve(testOperationName).execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(failedOperation, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testFileSearchByDriveIdPairsCorpora() {
        String fullFileSearchBody = '{"kind": "drive#fileList","incompleteSearch": false,"files": [{"id": "1","name": "One"}]}';
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
            .setSearchQuery('trashed = false')
            .setSearchOnAllDrives(true)
            .setDriveId('0AL7IuyV26qkAUk9PVA')
            .setFields('files(id,name)')
            .execute();

        Assert.areEqual(1, result.files.size());
        Test.stopTest();
    }

    @isTest
    private static void testDriveSearchWithFields() {
        String fullDriveSearchBody = '{"kind": "drive#driveList","drives": [{"id": "0AL7IuyV26qkAUk9PVA","name": "Test"}]}';
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
            .setMaxResult(10)
            .setFields('drives(id,name),nextPageToken')
            .execute();

        Assert.areEqual(1, result.drives.size());
        Test.stopTest();
    }

    @isTest
    private static void testAsyncDownloadLinkAlreadyComplete() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successOperation = '{"name": "aBcD123","done": true,"metadata": {"resourceKey": "someResourceKey"},"response": {"downloadUri": "https://drive.usercontent.google.com/download?id=abc","partialDownloadAllowed": false}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.DOWNLOAD_FILE_ENDPOINT, testFileId),
            200,
            successOperation
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleOperationEntity result = testGoogleDrive.files().retrieve().downloadLink(testFileId)
            .setMimeType('application/pdf')
            .execute();

        // Drive usually answers with a finished operation, so the link is ready
        // straight away and there is nothing to poll
        Assert.areEqual(true, result.done);
        Assert.areEqual('https://drive.usercontent.google.com/download?id=abc', result.response.downloadUri);
        Assert.areEqual('someResourceKey', result.metadata.resourceKey);
        Test.stopTest();
    }

    @isTest
    private static void testAsyncDownloadLinkPendingThenPolled() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String pendingOperation = '{"name": "aBcD123","done": false}';
        String finishedOperation = '{"name": "aBcD123","done": true,"response": {"downloadUri": "https://drive.usercontent.google.com/download?id=abc"}}';

        Test.startTest();
        buildGoogleDriveInfo();
        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);

        GoogleDriveHttpMockGenerator testStartCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.DOWNLOAD_FILE_ENDPOINT, testFileId),
            200,
            pendingOperation
        );
        Test.setMock(HttpCalloutMock.class, testStartCalloutMock);
        GoogleOperationEntity startResult = testGoogleDrive.files().retrieve().downloadLink(testFileId)
            .setRevisionId('0B7uV1kQ')
            .execute();

        Assert.areEqual(false, startResult.done);
        Assert.isNull(startResult.response);

        GoogleDriveHttpMockGenerator testPollCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.GET_OPERATION_ENDPOINT, startResult.name),
            200,
            finishedOperation
        );
        Test.setMock(HttpCalloutMock.class, testPollCalloutMock);
        GoogleOperationEntity polledResult = testGoogleDrive.operations().retrieve(startResult.name).execute();

        Assert.areEqual(true, polledResult.done);
        Assert.areEqual('https://drive.usercontent.google.com/download?id=abc', polledResult.response.downloadUri);
        Test.stopTest();
    }

    @isTest
    private static void testAsyncDownloadLinkFail() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String failedOperation = '{"error": {"errors": [{"domain": "global","reason": "notFound","message": "File not found"}],"code": 404,"message": "File not found"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.DOWNLOAD_FILE_ENDPOINT, testFileId),
            404,
            failedOperation
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            testGoogleDrive.files().retrieve().downloadLink(testFileId).execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(failedOperation, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testSimpleFileVersionUploadWithOptionalParameters() {
        String existingFileId = '1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9';
        String successVersionUpload = '{"id": "1ZdR3cU-rXTxY3g8B9yJH9kR7A4kx0gk9","name": "Scanned Page"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.VERSION_UPLOAD_FILES_ENDPOINT, existingFileId),
            200,
            successVersionUpload
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        // parents cannot travel in the body of an update, so a move has to go through
        // addParentFolders and removeParentFolders instead
        GoogleFileEntity result = testGoogleDrive.files().modify().simpleUpdate(existingFileId)
            .setContentType('text/plain')
            .setContentLength(31)
            .setBody(Blob.valueOf('A brand new version of the file'))
            .setUseContentAsIndexableText(true)
            .setOcrLanguage('en')
            .addParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM'})
            .removeParentFolders(new List<String>{'1QqbWgrczvSFnnJpU-6OEEEXMy77OVAaB'})
            .execute();

        Assert.areEqual('Scanned Page', result.name);
        Test.stopTest();
    }

    @isTest
    private static void testModifyFileMetadataWithEverySetter() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successModify = '{"id": "1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw","name": "Quarterly Report","description": "Reviewed","starred": true}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_FILE_ENDPOINT, testFileId),
            200,
            successModify
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleFileEntity result = testGoogleDrive.files().modify().metadata(testFileId)
            .setFileName('Quarterly Report')
            .setMimeType('application/pdf')
            .setDescription('Reviewed')
            .setStarred(true)
            .setTrashed(false)
            .setCustomAttributes(new Map<String, Object>{'reviewedBy' => 'finance'})
            .addParentFolders(new List<String>{'1TLCWgrczvSFnnJpU-6OEEEXMy77OVLjM'})
            .removeParentFolders(new List<String>{'1QqbWgrczvSFnnJpU-6OEEEXMy77OVAaB'})
            .setSupportsAllDrives(true)
            .setFields('id,name,description,starred')
            .execute();

        Assert.areEqual('Quarterly Report', result.name);
        Assert.areEqual('Reviewed', result.description);
        Test.stopTest();
    }

    @isTest
    private static void testModifyFileMetadataFail() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String failedModify = '{"error": {"errors": [{"domain": "global","reason": "notFound","message": "File not found"}],"code": 404,"message": "File not found"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_FILE_ENDPOINT, testFileId),
            404,
            failedModify
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            testGoogleDrive.files().modify().metadata(testFileId)
                .setFileName('Quarterly Report')
                .execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(failedModify, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testLabelModificationSupportsEveryValueType() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String successModifyLabels = '{"kind": "drive#modifyLabelsResponse","modifiedLabels": [{"id": "SEND70dQN5lH71BeU4nrBgrBit6Pvst1","revisionId": "9"}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.MODIFY_LABELS_FILE_ENDPOINT, testFileId),
            200,
            successModifyLabels
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleModifyLabelsResult result = testGoogleDrive.labels().modify(testFileId)
            .addLabelModification(
                new GoogleLabelModificationBuilder()
                    .setLabelId('SEND70dQN5lH71BeU4nrBgrBit6Pvst1')
                    .setSelectionValues('selectionFieldId', new List<String>{'optionOne'})
                    .setDateValues('dateFieldId', new List<String>{'2026-08-30'})
                    .setUserValues('userFieldId', new List<String>{'someone@example.com'})
                    .setIntegerValues('integerFieldId', new List<Integer>{7})
                    .unsetValues('textFieldId')
            )
            .addLabelModification(
                new GoogleLabelModificationBuilder()
                    .setLabelId('QWEr70dQN5lH71BeU4nrBgrBit6Pvst2')
                    .setRemoveLabel(true)
            )
            .setFields('modifiedLabels')
            .execute();

        Assert.areEqual(1, result.modifiedLabels.size());
        Assert.areEqual('SEND70dQN5lH71BeU4nrBgrBit6Pvst1', result.modifiedLabels[0].id);
        Test.stopTest();
    }

    @isTest
    private static void testDriveModifyWithEverySetting() {
        String testDriveId = '0AL7IuyV26qkAUk9PVA';
        String successModify = '{"kind": "drive#drive","id": "0AL7IuyV26qkAUk9PVA","name": "Finance","themeId": "bok_choy","colorRgb": "#16a765"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_DRIVE_ENDPOINT, testDriveId),
            200,
            successModify
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GoogleDriveEntity result = testGoogleDrive.drives().modify(testDriveId)
            .setDriveName('Finance')
            .setThemeId('bok_choy')
            .setColorRgb('#16a765')
            .setRestrictions(new Map<String, Object>{'domainUsersOnly' => true})
            .setDomainAdminAccess(true)
            .setFields('id,name,themeId,colorRgb')
            .execute();

        Assert.areEqual('Finance', result.name);
        Assert.areEqual('bok_choy', result.themeId);
        Assert.areEqual('#16a765', result.colorRgb);
        Test.stopTest();
    }

    @isTest
    private static void testDriveModifyFail() {
        String testDriveId = '0AL7IuyV26qkAUk9PVA';
        String failedModify = '{"error": {"errors": [{"domain": "global","reason": "notFound","message": "Shared drive not found"}],"code": 404,"message": "Shared drive not found"}}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_DRIVE_ENDPOINT, testDriveId),
            404,
            failedModify
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        try {
            testGoogleDrive.drives().modify(testDriveId).setDriveName('Finance').execute();
            System.assert(false, 'Exception expected');
        } catch (GoogleCloudException ex) {
            Assert.areEqual(failedModify, ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testPermissionFileModifyWithEverySetting() {
        String testFileId = '1lhu72ZrlfzRljhP4t12RE5GDGa8n7Yv8LHWy20_QBqw';
        String testPermissionId = '01649911713816498250';
        String successPermission = '{"id": "01649911713816498250","type": "user","role": "owner"}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            buildFileDependentEndpoint(GoogleConstants.UPDATE_PERMISSION_FILE_ENDPOINT, testFileId, testPermissionId),
            200,
            successPermission
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        // Handing ownership over is the case that needs every one of these together
        GooglePermissionEntity result = testGoogleDrive.permissions().modify(testFileId, testPermissionId)
            .setPrincipalRole('owner')
            .setExpirationTime('2026-12-31T23:59:59.000Z')
            .setPendingOwner(true)
            .setTransferOwnership(true)
            .setMoveToNewOwnersRoot(true)
            .setDomainAdminAccess(true)
            .setSupportsAllDrives(true)
            .setFields('id,role')
            .execute();

        Assert.areEqual('owner', result.role);
        Test.stopTest();
    }

    @isTest
    private static void testScopedCacheKeyIsBuiltAfterScopesAreDeclared() {
        Test.startTest();
        GoogleCredential scopedCredentials = new GoogleAuthorizationCodeFlow.Builder()
            .setLocalGoogleAuthorizer('GoogleDriveTest.TestGoogleScopedAuthorizer')
            .setLocalPlatformCache((Cache.OrgPartition) null, 'googleDriveAccessToken')
            .setRequestedScopes(new List<GoogleScope>{GoogleScope.DRIVE_FILE})
            .build();

        Assert.areEqual('Bearer', scopedCredentials.tokenType);
        Assert.isNotNull(scopedCredentials.accessToken);
        Test.stopTest();
    }

    @isTest
    private static void testSessionCacheKeyIsBuiltWithoutScopes() {
        Test.startTest();
        GoogleCredential legacyCredentials = new GoogleAuthorizationCodeFlow.Builder()
            .setLocalGoogleAuthorizer('GoogleDriveTest.TestGoogleLegacyAuthorizer')
            .setLocalPlatformCache((Cache.SessionPartition) null, 'googleDriveAccessToken')
            .build();

        Assert.areEqual('legacyaZ3X8kP2RtaZ3X8kP2RtaZ3X8kP2', legacyCredentials.accessToken);
        Test.stopTest();
    }

    @isTest
    private static void testCacheKeyTooShortForScopeDigestIsRejected() {
        String keyLeavingNoRoom = 'a'.repeat(GoogleConstants.PLATFORM_CACHE_KEY_MAX_LENGTH);

        Test.startTest();
        try {
            new GoogleAuthorizationCodeFlow.Builder()
                .setLocalGoogleAuthorizer('GoogleDriveTest.TestGoogleScopedAuthorizer')
                .setLocalPlatformCache((Cache.OrgPartition) null, keyLeavingNoRoom)
                .setRequestedScopes(new List<GoogleScope>{GoogleScope.DRIVE_FILE})
                .build();
            System.assert(false, 'Exception expected');
        } catch (IllegalArgumentException ex) {
            Assert.isTrue(ex.getMessage().contains(String.valueOf(GoogleConstants.PLATFORM_CACHE_KEY_MAX_LENGTH)));
        }
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
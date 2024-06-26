@isTest
private class GoogleDriveTest {
    private static GoogleCredential testCredentials;
    private static String userAgentName;

    @isTest
    private static void testFullDriveSearch() {
        String fullDriveSearchBody = '{"kind":"drive#fileList","drives":[{"id":"drive123","name":"My Drive","colorRgb":"#FFFFFF","kind":"drive#drive","backgroundImageLink":"https://example.com/image.png","capabilities":{"canAddChildren":true,"canComment":true,"canCopy":true,"canDeleteDrive":false,"canDownload":true,"canEdit":true,"canListChildren":true,"canManageMembers":true,"canReadRevisions":true,"canRename":true,"canRenameDrive":true,"canChangeDriveBackground":true,"canShare":true,"canChangeCopyRequiresWriterPermissionRestriction":false,"canChangeDomainUsersOnlyRestriction":false,"canChangeDriveMembersOnlyRestriction":false,"canChangeSharingFoldersRequiresOrganizerPermissionRestriction":false,"canResetDriveRestrictions":false,"canDeleteChildren":false,"canTrashChildren":true},"themeId":"theme123","backgroundImageFile":{"id":"image123","xCoordinate":100.0,"yCoordinate":50.0,"width":800.0},"createdTime":"2023-06-15T10:30:00Z","hidden":false,"restrictions":{"copyRequiresWriterPermission":true,"domainUsersOnly":false,"driveMembersOnly":true,"adminManagedRestrictions":false,"sharingFoldersRequiresOrganizerPermission":true},"orgUnitId":"org123"},{"id":"drive456","name":"Not Populated Drive"}]}';
        GoogleDriveHttpMockGenerator testCalloutMock = new GoogleDriveHttpMockGenerator(
            GoogleConstants.SEARCH_DRIVES_ENDPOINT,
            GoogleConstants.HTTP_SUCCESS_STATUS_CODE,
            fullDriveSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GDriveSearchResult result = testGoogleDrive.drives().search()
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
            GoogleConstants.HTTP_SUCCESS_STATUS_CODE,
            nextPageDriveSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GDriveSearchResult result = testGoogleDrive.drives().search('4mzkteXuXufI6lXV4mzkteXuXufI6lXV')
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
            GDriveSearchResult result = testGoogleDrive.drives().search().execute();
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
            GoogleConstants.HTTP_SUCCESS_STATUS_CODE,
            nextPageFileSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GFileSearchResult result = testGoogleDrive.files().search('~!!~BI9FV7ThOnDGgvVJDf_o4en1NZxEOJxjGmloO1QwivWraJd4UKiAAiFaEyV==')
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
            GoogleConstants.HTTP_SUCCESS_STATUS_CODE,
            fullFileSearchBody
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, testCalloutMock);
        buildGoogleDriveInfo();

        GoogleDrive testGoogleDrive = new GoogleDrive(testCredentials, userAgentName);
        GFileSearchResult result = testGoogleDrive.files().search()
            .setMaxResult(3)
            .setSearchQuery('trashed = false')
            .setSearchOnAllDrives(true)
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
            GFileSearchResult result = testGoogleDrive.files().search().execute();
        } catch (CalloutException ex) {
            Assert.areEqual(failedFileSearchBody, ex.getMessage());
        }

        Test.stopTest();
    }

    private static void buildGoogleDriveInfo() {
        userAgentName = 'Google Drive/v3 test';
        testCredentials = new GoogleCredential();
        testCredentials.accessToken = 'aZ3X8kP2RtaZ3X8kP2RtaZ3X8kP2RtaZ';
        testCredentials.tokenType = 'Bearer'; 
    }
}
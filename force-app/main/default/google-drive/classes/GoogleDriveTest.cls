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
        GDriveSearchResult result = testGoogleDrive.drives().search(50, '', false);
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
        GDriveSearchResult result = testGoogleDrive.drives().search('4mzkteXuXufI6lXV');
        Assert.areEqual('2fd620046218c04c12709a67c4879de9', result.nextPageToken);
        Test.stopTest();
    }

    private static void buildGoogleDriveInfo() {
        userAgentName = 'Google Drive/v3 test';
        testCredentials = new GoogleCredential();
        testCredentials.accessToken = 'aZ3X8kP2Rt';
        testCredentials.refreshToken = '5DgH2pM7qZ';
        testCredentials.tokenType = 'Bearer'; 
    }
}
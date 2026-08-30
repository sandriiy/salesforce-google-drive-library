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

public class GoogleConstants {
    public static final String SEARCH_DRIVES_ENDPOINT = 'https://www.googleapis.com/drive/v3/drives';
    public static final String SEARCH_FILES_ENDPOINT = 'https://www.googleapis.com/drive/v3/files';
    public static final String UPLOAD_FILES_ENDPOINT = 'https://www.googleapis.com/upload/drive/v3/files';
	public static final String VERSION_UPLOAD_FILES_ENDPOINT = 'https://www.googleapis.com/upload/drive/v3/files/{0}';
    public static final String CLONE_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/copy';
	public static final String UPDATE_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}';
    public static final String DELETE_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}';
	public static final String TRASH_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v2/files/{0}/trash';
    public static final String NEW_PERMISSION_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/permissions';
	public static final String LIST_PERMISSIONS_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/permissions';
    public static final String DELETE_PERMISSION_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/permissions/{1}';
    public static final String EXPORT_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/export';
    public static final String GET_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}';
    public static final String DOWNLOAD_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/download';
    public static final String GET_PERMISSION_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/permissions/{1}';
    public static final String UPDATE_PERMISSION_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/permissions/{1}';
    public static final String LIST_REVISIONS_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/revisions';
    public static final String GET_REVISION_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/revisions/{1}';
    public static final String UPDATE_REVISION_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/revisions/{1}';
    public static final String DELETE_REVISION_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/revisions/{1}';
    public static final String LIST_LABELS_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/listLabels';
    public static final String MODIFY_LABELS_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/modifyLabels';
    public static final String NEW_DRIVE_ENDPOINT = 'https://www.googleapis.com/drive/v3/drives';
    public static final String GET_DRIVE_ENDPOINT = 'https://www.googleapis.com/drive/v3/drives/{0}';
    public static final String UPDATE_DRIVE_ENDPOINT = 'https://www.googleapis.com/drive/v3/drives/{0}';
    public static final String DELETE_DRIVE_ENDPOINT = 'https://www.googleapis.com/drive/v3/drives/{0}';
    public static final String HIDE_DRIVE_ENDPOINT = 'https://www.googleapis.com/drive/v3/drives/{0}/hide';
    public static final String UNHIDE_DRIVE_ENDPOINT = 'https://www.googleapis.com/drive/v3/drives/{0}/unhide';
    public static final String GET_OPERATION_ENDPOINT = 'https://www.googleapis.com/drive/v3/operations/{0}';

    public static final String DRIVE_SCOPE_URL = 'https://www.googleapis.com/auth/drive';
    public static final String DRIVE_FILE_SCOPE_URL = 'https://www.googleapis.com/auth/drive.file';
    public static final String DRIVE_READONLY_SCOPE_URL = 'https://www.googleapis.com/auth/drive.readonly';
    public static final String DRIVE_METADATA_SCOPE_URL = 'https://www.googleapis.com/auth/drive.metadata';
    public static final String DRIVE_METADATA_READONLY_SCOPE_URL = 'https://www.googleapis.com/auth/drive.metadata.readonly';
    public static final String DRIVE_APPDATA_SCOPE_URL = 'https://www.googleapis.com/auth/drive.appdata';
    public static final String DRIVE_APPS_READONLY_SCOPE_URL = 'https://www.googleapis.com/auth/drive.apps.readonly';
    public static final String DRIVE_SCRIPTS_SCOPE_URL = 'https://www.googleapis.com/auth/drive.scripts';
    public static final String DRIVE_INSTALL_SCOPE_URL = 'https://www.googleapis.com/auth/drive.install';
    public static final String DRIVE_ACTIVITY_SCOPE_URL = 'https://www.googleapis.com/auth/drive.activity';
    public static final String DRIVE_ACTIVITY_READONLY_SCOPE_URL = 'https://www.googleapis.com/auth/drive.activity.readonly';
    public static final String DRIVE_MEET_READONLY_SCOPE_URL = 'https://www.googleapis.com/auth/drive.meet.readonly';

    public static final Map<GoogleScope, String> GOOGLE_SCOPE_URLS = new Map<GoogleScope, String>{
        GoogleScope.DRIVE => DRIVE_SCOPE_URL,
        GoogleScope.DRIVE_FILE => DRIVE_FILE_SCOPE_URL,
        GoogleScope.DRIVE_READONLY => DRIVE_READONLY_SCOPE_URL,
        GoogleScope.DRIVE_METADATA => DRIVE_METADATA_SCOPE_URL,
        GoogleScope.DRIVE_METADATA_READONLY => DRIVE_METADATA_READONLY_SCOPE_URL,
        GoogleScope.DRIVE_APPDATA => DRIVE_APPDATA_SCOPE_URL,
        GoogleScope.DRIVE_APPS_READONLY => DRIVE_APPS_READONLY_SCOPE_URL,
        GoogleScope.DRIVE_SCRIPTS => DRIVE_SCRIPTS_SCOPE_URL,
        GoogleScope.DRIVE_INSTALL => DRIVE_INSTALL_SCOPE_URL,
        GoogleScope.DRIVE_ACTIVITY => DRIVE_ACTIVITY_SCOPE_URL,
        GoogleScope.DRIVE_ACTIVITY_READONLY => DRIVE_ACTIVITY_READONLY_SCOPE_URL,
        GoogleScope.DRIVE_MEET_READONLY => DRIVE_MEET_READONLY_SCOPE_URL
    };

    public static final List<Integer> HTTP_SUCCESS_STATUS_CODES = new List<Integer>{200, 201, 204, 206, 304, 308};
    public static final List<Integer> HTTP_INTERRUPTED_STATUS_CODES = new List<Integer>{503, 308};
    public static final Integer HTTP_UNAUTHORIZED_STATUS_CODE = 401;

    public static final Integer UPLOAD_DEFAULT_INITIAL_BYTE = 0;
    public static final Integer SEARCH_DEFAULT_PAGE_SIZE = 100;
	public static final Integer DEFAULT_TOKEN_EXPIRATION_SECS = 3600;

    public static final String MULTIPART_DEFAULT_TYPE = 'related';
    public static final String MULTIPART_REQUEST_BOUNDARY = 'multipart-gdrive-boundary';

    public static final String SEARCH_DRIVE_CORPORA = 'drive';
    public static final Integer PLATFORM_CACHE_KEY_MAX_LENGTH = 50;
    public static final Integer SCOPE_CACHE_KEY_DIGEST_LENGTH = 8;
}
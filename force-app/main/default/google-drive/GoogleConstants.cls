public class GoogleConstants {
    public static final String SEARCH_DRIVES_ENDPOINT = 'https://www.googleapis.com/drive/v3/drives';
    public static final String SEARCH_FILES_ENDPOINT = 'https://www.googleapis.com/drive/v3/files';
    public static final String UPLOAD_FILES_ENDPOINT = 'https://www.googleapis.com/upload/drive/v3/files';
    public static final String CLONE_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/copy';
    public static final String NEW_PERMISSION_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/permissions';
    public static final String EXPORT_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}/export';
    public static final String GET_FILE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/{0}';

    public static final Integer HTTP_SUCCESS_STATUS_CODE = 200;
    public static final Integer HTTP_UNAUTHORIZED_STATUS_CODE = 401;

    public static final Integer SEARCH_DEFAULT_PAGE_SIZE = 100;

    public static final String MULTIPART_DEFAULT_TYPE = 'related';
    public static final String MULTIPART_REQUEST_BOUNDARY = 'multipart-gdrive-boundary';
}
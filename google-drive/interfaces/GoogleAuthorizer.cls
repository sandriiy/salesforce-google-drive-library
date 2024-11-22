/** 
 * The GoogleAuthorizer manages custom control of credentials,
 * working in conjunction with GoogleAuthorizationCodeFlow.
*/
public interface GoogleAuthorizer {
    /**
     * A method to be implemented outside of the library to obtain 
     * an access token for operating with the Google Drive API.
    */
    String retrieveAccessToken();
}
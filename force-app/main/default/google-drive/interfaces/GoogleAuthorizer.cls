/** 
 * The GoogleAuthorizer manages custom control of credentials,
 * working in conjunction with GoogleAuthorizationCodeFlow.
*/
public interface GoogleAuthorizer {
    String retrieveAccessToken();
    String retieveRefreshToken();
}
# Getting Started

Once you’ve completed the Google Drive integration as described in the [Quick Setup Guide](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Quick-Setup-Guide), you have everything you need to start working with the library: the Google Drive API enabled, a Service Account created, and a certificate uploaded to Salesforce.

To begin, you must create an instance of the `GoogleDrive` class, which encapsulates all operations related to Google Drive. Creating this instance is the first step, and its constructor is defined as follows:

     public GoogleDrive(GoogleCredential credentials, String applicationName) {
        ...
    }

The constructor requires two parameters: an instance of the `GoogleCredential` class and a `String` value. The `GoogleCredential` class holds only your access token and its type. The `applicationName` parameter is used solely to identify the entity performing operations with the Google Drive API. While useful for logging and diagnostics, it is not a mandatory requirement.

## Creating a GoogleDrive instance manually

If you prefer to create a `GoogleDrive` instance manually and then use the library’s full capabilities, you first need to generate an access token as described in the [Quick Setup Guide](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Quick-Setup-Guide). You can then create the instance as follows:

     GoogleCredential yourCreds = new GoogleCredential();
     yourCreds.accessToken = yourAccessToken;
     yourCreds.tokenType = 'Bearer';

     GoogleDrive driveService = new GoogleDrive(yourCreds, 'Apex/1.0 (Salesforce Library)');
    
That’s it. From here, you can access the full range of library features by invoking the appropriate methods, as described in other documentation pages.

## Creating a GoogleDrive instance using GoogleAuthorizationCodeFlow

The Apex Google Drive Library provides you with the `GoogleAuthorizer` interface, which you can implement in your custom class. This interface requires you to implement the `retrieveAccessToken` method, in which you must include the code to obtain the access token. The specific code is entirely up to you.

    public with sharing class CustomGoogleAuthorizer2 implements GoogleAuthorizer {
        private final String SERVICE_ACCOUNT_EMAIL = 'YOUR_SERVICE_ACC_EMAIL';
        private final String CERTIFICATE_NAME = 'YOUR_CERTIFICATE_NAME';

        public String retrieveAccessToken() {
            Auth.JWT jwt = new Auth.JWT();
            jwt.setAud('https://oauth2.googleapis.com/token');
            jwt.setSub(SERVICE_ACCOUNT_EMAIL);
            jwt.setIss(SERVICE_ACCOUNT_EMAIL);
            jwt.setAdditionalClaims(new Map<String, Object>{'scope' => 'https://www.googleapis.com/auth/drive'});

            Auth.JWS jws = new Auth.JWS(jwt, CERTIFICATE_NAME);

            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(
                jwt.getAud(),
                jws
            );

            return bearer.getAccessToken();
        }
    }

Once you've created a custom class that implements the interface, the library provides a `GoogleAuthorizationCodeFlow` builder to generate the `GoogleCredential` for you. All you need to do is specify the name of your custom class, and it will be executed automatically. The access token returned by the class will be used.

    GoogleCredential googleDriveCredentials = new GoogleAuthorizationCodeFlow.Builder()
        .setLocalGoogleAuthorizer('CustomGoogleAuthorizer')
        .build();

    GoogleDrive googleDriveLibrary = new GoogleDrive(googleDriveCredentials, 'Apex/1.0 (Salesforce Library)');
    ...

You can also configure the library to use the Platform Cache (Org or Session) to store access tokens for reuse across subsequent requests, which can significantly improve performance. However, it requires special care, as the cached token’s scope may not match certain operations and can result in an operation forbidden error. Declaring the scopes up front solves this, and is described in [Library Access Scopes](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Library-Access-Scopes).

    Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.GoogleCloudClient');
    GoogleCredential googleDriveCredentials = new GoogleAuthorizationCodeFlow.Builder()
        .setLocalGoogleAuthorizer('CustomGoogleAuthorizer')
        .setLocalPlatformCache(orgPartition, 'accessToken')
        .build();

    GoogleDrive googleDriveLibrary = new GoogleDrive(googleDriveCredentials, 'Apex/1.1 (Salesforce Library)');
    ...

This approach achieves the same result as if you were creating it manually. However, the code is presented in a more structured format, allowing for better navigation and management. This method is still the recommended practice.


## Declaring what the credential is for

`GoogleAuthorizer` asks your class for a token without telling it what the token is about to be used for, which is why most implementations end up requesting the full `drive` scope for everything. If you would rather issue a narrower token, implement `GoogleScopedAuthorizer` instead and declare the scopes when you build the credential.

    GoogleCredential googleDriveCredentials = new GoogleAuthorizationCodeFlow.Builder()
        .setLocalGoogleAuthorizer('CustomScopedAuthorizer')
        .setRequestedScopes(new List<GoogleScope>{ GoogleScope.DRIVE_FILE })
        .build();

    GoogleDrive googleDriveLibrary = new GoogleDrive(googleDriveCredentials, 'Apex/1.0 (Salesforce Library)');

The library calls whichever interface your class implements, so this changes nothing for an existing `GoogleAuthorizer`. The declared scopes also take part in the Platform Cache key, which removes the mismatch warning mentioned above. See [Library Access Scopes](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Library-Access-Scopes) for the full list of scopes, what each one grants, and what it costs to ship.

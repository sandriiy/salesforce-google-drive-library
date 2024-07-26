<!-- https://github.com/othneildrew/Best-README-Template/issues/new?labels=enhancement&template=feature-request---.md -->
<div>
  <p align="center">
    <br />
    <a href="https://www.youtube.com/@asukhetskyi">View Demo</a>
    ·
    <a href="">Report Bug</a>
    ·
    <a href="">Request Feature</a>
  </p>
</div>

<!-- ABOUT THE PROJECT -->
## About The Library

The Salesforce Google Drive Library offers programmatic access to Google Drive through API methods. This library simplifies coding against these APIs by providing robust methods for creating, cloning, downloading, sharing, and searching files and drives. Its implementation is a fully decoupled code, ensuring compatibility across any Salesforce environment without the need for additional customizations or restrictions.

To utilize this library effectively, an already configured Google Drive integration is required, as it relies on an access token for proper operation. Obtaining this token is the responsibility of the developer using the library. However, the library provides a user-friendly `GoogleCredential` interface and `GoogleAuthorizationCodeFlow` authorizer to facilitate the creation of all necessary credentials.

Here's why this library:
* The entire implementation adheres to best practices, utilizing factories, builders, and isolated code units. This ensures a reliable and secure interaction with the Google Drive API, making this library a robust and efficient choice for developers.
* The code is entirely free from dependencies, allowing immediate use of the library after deploying the elements in the `force-app/main/default/google-drive` folder. Furthermore, all the code is thoroughly tested and verified, ensuring an overall test coverage of about 90%.
* The library is open to contributions and is actively developing, continually adding new features. It guarantees constant monitoring for any errors and promptly addresses and resolves them.

Refer to the <a href="https://developers.google.com/api-client-library">Google Drive Client Libraries</a> for existing counterparts in other programming languages, as the practices and approaches used in those libraries have been applied in implementing this one.

<!-- GETTING STARTED -->
## Getting Started

The library provides a set of all possible interactions with the Google Drive API. However, to ensure a secure separation of the library from your SF environment, authentication with Google Drive is your responsibility. At the same time, the library offers best practices for organizing your integration code.

### Service Account

The recommended way to set up the integration between Google Drive and Salesforce is to create a Service Account. The service account in Google Drive is a special type of Google account intended for use by applications, rather than individual users. These accounts are used to authenticate and authorize automated processes to access Google APIs securely.

Before starting, make sure that the Google Drive API is enabled. To do this, follow these steps:
1. Open your browser and navigate to the <a href="https://console.cloud.google.com/marketplace/product/google/drive.googleapis.com">Google Cloud Console</a>.
2. Create a New Project (if needed).
3. Click the “Enable” button to enable the API for your project.

After the Google Drive API is enabled for your project, you need to create a Service Account to authorize access from Salesforce.
1. Go to the <a href="https://console.cloud.google.com/projectselector2/iam-admin/serviceaccounts">Service Accounts</a> page in the Google Cloud Console.
2. Click on “Create Service Account”.
3. Enter a name and description for the service account, then click “Create”.
4. Assign roles to the service account, such as “Editor” or specific roles needed for your project. Click “Continue” and then “Done”.
5. After creating the service account, click on the service account email.
6. Navigate to the “Keys” tab.
7. Click “Add Key” > “Create New Key”.
8. Choose JSON as the key type and click “Create”.
9. The JSON key file will be downloaded to your computer.

The downloaded file will contain all the information for authorization from Salesforce. The next step is to create a JWT token and account/refresh tokens from your environment.

### Creating a token in Salesforce
```diff
Please note, the primary objective for getting started with the library is to create an instance of the `GoogleDrive` class. This instance serves as the main and only point of interaction for you as a developer.
```

To start working with the library, you need to create an instance of the `GoogleCredential` class, which will contain the access token and its type (in this case "Bearer" type all the time). This is necessary because the `GoogleDrive` class requires these parameters, along with `applicationName`, in its constructor. Please note that the `applicationName` parameter indicates to the Google Drive API who is performing certain transactions, which can be useful for diagnostics and logging.

```java
  public GoogleDrive(GoogleCredential credentials, String applicationName) { ... }
```

To create an instance of the `GoogleCredential` class, you can use the methods and resources available in your environment without limitations. However, this library provides a recommended approach to handle this task using the `GoogleAuthorizationCodeFlow` class and the `GoogleAuthorizer` interface. See below for details.

- First, you need to create a custom class that implements the `GoogleAuthorizer` interface. This requires implementing the `retrieveAccessToken` method, where you will use the Service Account credentials you downloaded to obtain the token.
```java
  public with sharing class CustomGoogleAuthorizer implements GoogleAuthorizer {
    private String PRIVATE_KEY = '-----BEGIN PRIVATE KEY-----\nMIIAvCIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQD6jMVRaGwLgCu8\nH3WRT5LqdzK0l+wdD3c8iVtvkD9S3RUhuTCqTyjmk7JwTzp+bPVBvKWL39R81oR9\nSMvVFYpv1HYBQXn430fM2yloBgMDdCjl0HY2VdTXmYUWozpA9tt0ZrNl9rat6LJ7\nuB7r/lKfBQuXiJr7B0J9aag4m5xPuCIIFoSVLKzwDeBwvDk1fkf/R78jd123Tmlv\nMU7rn9g/2jJyldbUTlxvaQWHIfR9QMs5abB53EMRyssd/ej8Lt1in14Y6UIvrLwe\nC9YbiODQcOIdZM8sjCgsBNUo/gOkgB4cmp3hotGNqCrI5LE7FnVvuk+lcIuEwZjJ\nlQ96CBIrAgMBAAECggEAc6cCOAs/AGoIBhzxbINyOheOiM0t2NY4QHHZCpznlgzm\nQbxVqe/DXffkYLI5unz6Ev+M3Q2TbJKq8pflOvVoAynr1LWQI2CRqI6rxNAtmO0I\nKdj5kCg7iM/dHq925uTeOQVlStZsicdFiBVb9KxfH/c4vBh7DY/y0agxVfwCgcr/\n3V7LDgtxy2JIuZsgCFsru62wBcKp/F0RxaATPATStN8tLhL44Japm4EmUCGqrP4r\nnzqgz60GLR2ITestQBLlKAGbPQGifKzEB4kUacqTgC/FU97SBSsHOO3HAzE6pvjf\nxGKLCcaKRxJsVIQ5JDLutNr9DmkuwfRXAxUultjlpQKBgQD/JSXqrfw3onhJErIP\nZJ5JYrlM8mQC+hvAxHPAdu6C2P1hpud9AOKkM28A1OD02HvsOzmTpdQfcDlzSQa8\nNRY+WZaj/2YpI4R99smaGT10cPR9/5gLM0ZI6udJco3Oh0SsdxeKUEp0liXP+xGS\ngq83qeNLkJFFv4xNA+H4n+ggJQKBgQD7Y65btLT3yT6daSjUco5Bbo44WPRbIb6O\n5YfmRO40tb7npFekM4gz0U9tM0E3TbwRt6Ocd9gKSyXmhcMADnISK9Ic435WekNx\ng2aJ2wd7Bf1WLXq7ZsNeyYQ2Q5BEwEBgH3pSn2AJwD+C2CTlHP6+iLs40wDMkiHy\nb3qWsoZwDwKBgQCY7jlF6zdMWZPjqNMVque9cPFEj90mc6eC6b2/1QmtYEav64zB\nPnCan0Gfq/mSiNfuhqlCOJlmpquo0FK7KM7GXIiQkBs5+VIG9o9sUEinrLS/eR43\nSGqOdk5flcwtyKJ/BXsUqn+WVhEgEos72B0SLkBRILwSpHeCChuHIrUCQKBgFJO\nO5rY2ls6L174PB76dqrjmHrIXRCtRqebKotgzCDD1IIg43TmTlSw1fFp05NYxxeB\n6XZkIn6URg9oggS1thFO+ZbtwMJte0FiBSNja9qShnQ9pa5Poe2Zysi9bDGmRC10\ngOcmORpYMDMVs1a0HI+jUrDzHJLd0XF/oEJQpwVvAoGAPlDasojU7FRxk2HWVrBy\nPt2I53ioe1s+z0IL+dFcwMgVID0Xrp8yAGeizrDjdtSiQQEmCzMDovGQ57ULqdWC\nF7lOdUY/B/48pUrWrsyi+uHP9oyb48yMXvKsIsjPGlni1JK7m+49oh7Ys2oomGWz\ntS4oHLE3US90wtCV2/gXaWg=\n-----END PRIVATE KEY-----\n'; 
    private String SERVICE_ACCOUNT_EMAIL = 'test-110@vital-lyceum-416627-h9.iam.gserviceaccount.com';

    // Required method from the interface
    public String retrieveAccessToken() {
        String generatedJwtToken = generateJwtToken();
        String obtainedAccessToken = generateAccessToken(generatedJwtToken);
        return obtainedAccessToken;
    }

    private String generateJwtToken() {
        Long issuedAt = DateTime.now().getTime() / 1000;
        Long expiresAt = issuedAt + 3600; // Token valid for 1 hour
        
        Map<String, Object> header = new Map<String, Object>();
        header.put('alg', 'RS256');
        header.put('typ', 'JWT');
        
        Map<String, Object> claim = new Map<String, Object>();
        claim.put('iss', SERVICE_ACCOUNT_EMAIL);
        claim.put('scope', 'https://www.googleapis.com/auth/drive');
        claim.put('aud', 'https://oauth2.googleapis.com/token');
        claim.put('exp', expiresAt);
        claim.put('iat', issuedAt);
        
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(header))).replace('+', '-').replace('/', '_').replace('=', '');
        String claimEncoded = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(claim))).replace('+', '-').replace('/', '_').replace('=', '');
        
        String signatureInput = headerEncoded + '.' + claimEncoded;
        Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(signatureInput), EncodingUtil.base64Decode(cleanPrivateKey(PRIVATE_KEY)));
        String signatureEncoded = EncodingUtil.base64Encode(signature).replace('+', '-').replace('/', '_').replace('=', '');
        
        String createdJwtToken = headerEncoded + '.' + claimEncoded + '.' + signatureEncoded;
        return createdJwtToken;
    }

    private String generateAccessToken(String jwtToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://oauth2.googleapis.com/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + jwtToken);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String accessToken = (String) responseMap.get('access_token');
        return accessToken;
    }

    private String cleanPrivateKey(String privateKey) {
        privateKey = privateKey.replace('-----BEGIN PRIVATE KEY-----', '');
        privateKey = privateKey.replace('-----END PRIVATE KEY-----', '');
        privateKey = privateKey.replace('\n', '').replace('\r', '');
        return privateKey;
    }
}
```
In the example provided above, test credentials from the Service Account are used (you will have your own credentials). For clarity, the methods have not been broken down into smaller parts, so it’s advisable to refactor the code according to your development team's best practices, as well as using other methods such as <a href="https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm&language=en_US&type=5">Named Credentials</a>. Pay special attention to the `cleanPrivateKey` method, which removes unnecessary symbols and markings from the private key you received. This step is crucial, as failing to do so may result in an authorization error from the Google Drive API.

- After creating a custom class that implements the interface and returns an access token, you can use the `GoogleAuthorizationCodeFlow` to generate the `GoogleCredential` instance and fully leverage the capabilities of this library.
```java
  GoogleCredential googleDriveCredentials = new GoogleAuthorizationCodeFlow.Builder()
    .setLocalGoogleAuthorizer('CustomGoogleAuthorizer')
    .build();

  GoogleDrive googleDriveLibrary = new GoogleDrive(googleDriveCredentials, 'Apex/1.0 (Salesforce Library)');
  ...
```

Once you’ve set up the integration, created an access token, and instantiated the `GoogleDrive` class — your gateway to using the Salesforce Google Drive Library, nothing else stands in your way. From this point on, you have full access to the capabilities for working with files in Google Drive.

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* Will be added soon...
* Will be added soon...
* Will be added soon...

<h1>Getting Started</h1>

> [!NOTE]  
> This library provides an SDK that offers a simplified, developer-friendly interface for working with Google Drive. Our team recently released a new project that delivers a full Google Client experience, allowing you to completely replace Salesforce Files. For more details, see here — https://github.com/sandriiy/salesforce-google-client

<p>
  This guide explains how to integrate Salesforce with Google Drive using a Service Account (Google side) and the Apex Google Drive Library (Salesforce side).
</p>

<p>
  The goal of this integration is to treat the entire Salesforce environment as a single trusted application that can securely access Google Drive
  without requiring individual user authorization.
</p>


<h2 id="table-of-contents">Table of Contents</h2>
<ul>
  <li><a href="#architecture-overview">Architecture Overview</a></li>
  <li><a href="#prerequisites">Prerequisites</a></li>
  <li><a href="#service-account-google-side">Google Side (Service Account)</a></li>
  <li><a href="#salesforce-integration-overview">Salesforce Side (JKS Certificate)</a></li>
  <li>
    <a href="#creating-a-jks-certificate">Creating a JKS Certificate</a>
  </li>
  <li><a href="#upload-certificate-to-salesforce">Upload Certificate to Salesforce</a></li>
  <li><a href="#jwt-creation-in-apex">JWT Creation in Apex</a></li>
  <li><a href="#exchange-jwt-for-access-token">Exchange JWT for Access Token</a></li>
  <li><a href="#common-errors-notes">Common Errors &amp; Notes</a></li>
  <li><a href="#what-does-the-library-do">What Does the Library Do?</a></li>
</ul>
<br>

<h2 id="architecture-overview">Architecture Overview</h2>
<p>
  At a high level, the integration works like this:
</p>
<ol>
  <li>Google issues a Service Account key (JSON or P12)</li>
  <li>The key is converted into a Salesforce-compatible certificate (JKS)</li>
  <li>Salesforce signs a JWT using that certificate</li>
  <li>Google exchanges the JWT for an access token</li>
  <li>The Apex Google Drive Library uses the access token to work with Google Drive</li>
</ol>

<p>
  This is a server-to-server setup: no user interaction, no OAuth popups, and no per-user authorization flows.
</p>

<h2 id="prerequisites">Prerequisites</h2>
<p>Before starting, ensure these tools are installed on your machine:</p>
<ul>
  <li><a href="https://slproweb.com/products/Win32OpenSSL.html">OpenSSL (certificate generation)</a></li>
  <li><a href="https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html">Java JDK 11 or 17 (required for keytool)</a></li>
  <li><a href="https://jqlang.org/download/">jq (extracting the private key from JSON)</a></li>
</ul>

<p>
  Once installed, you should be able to run:
</p>
<ul>
  <li>openssl</li>
  <li>keytool</li>
  <li>jq</li>
</ul>

<br>
<h2 id="service-account-google-side">Google Side (Service Account)</h2>
<p>
  A Service Account is a non-human Google account intended for applications rather than users.
</p>

<p>
  In this integration, your Salesforce org uses the Service Account to make authorized API calls to Google Drive when uploading, searching, sharing, or managing files.
</p>

<p>
  In Google Cloud Console, you will typically do the following:
</p>
<ol>
  <li>Create a Google Cloud Project</li>
  <li>Enable the Google Drive API</li>
  <li>Create a Service Account</li>
  <li>Create and download a key (JSON recommended, P12 also supported)</li>
</ol>

<p>
  References:
</p>
<ul>
  <li><a href="https://cloud.google.com/iam/docs/service-account-overview">Service Accounts overview</a></li>
  <li><a href="https://developers.google.com/workspace/guides/create-project">Create a Google Cloud project</a></li>
  <li><a href="https://support.google.com/googleapi/answer/6158841?hl=en">Enable Google APIs</a></li>
</ul>
<br>

<h2 id="salesforce-integration-overview">Salesforce Side (JKS Certificate)</h2>
<p>
  The Service Account key itself is not an access token. Instead, it is used to prove identity and sign a JWT assertion.
</p>

<p>
  The recommended Salesforce flow is:
</p>
<ol>
  <li>Create a JKS certificate from the Service Account key</li>
  <li>Upload the certificate to Salesforce</li>
  <li>Create and sign a JWT in Apex using the certificate</li>
  <li>Exchange the JWT for an access token</li>
</ol>

<h2 id="creating-a-jks-certificate">Creating a JKS Certificate</h2>
<p>
  Salesforce requires a JKS keystore for certificate import. The steps differ depending on whether you received a JSON key or a P12 key.
</p>

<h3 id="json-key-to-jks">Option A: JSON Key → JKS</h3>
<p>
  Use this option if you downloaded a JSON Service Account key. In this case, let's assume that the name of your JSON file is "service_account.json".
</p>
<h4>Step 1: Extract the private key from the JSON</h4>
<p>

`jq -r ".private_key" service_account.json | Set-Content -Path service_account_key.pem -Encoding utf8`

</p>
<p>
  Manual alternative (if needed): Extract the private key from the `private_key` value in the JSON file and save it as a separate file with a .PEM extension. Then, format your key correctly by ensuring it has base64 encoding, a header, a footer, and lines split by 64 characters each. This step is crucial because an incorrectly formatted key can block further steps, so double-check that it is correct.

    -----BEGIN PRIVATE KEY-----
    MIIBVwIBADANBgkqhkiG9w0BAQEFAASCATwwggE4AgEAAkE...
    ...base64-encoded content...
    ...more base64-encoded content...
    -----END PRIVATE KEY-----

</p>

<h4>Step 2: Create a certificate signing request (CSR)</h4>
<p>

`openssl req -new -key service_account_key.pem -out service_account.csr`

</p>
<p>
  During the process, OpenSSL will ask you to enter details such as:

- Country Name (2-letter code): e.g., US
- State or Province Name: e.g., California
- Locality Name (City): e.g., San Francisco
- Organization Name: e.g., Your Company
- Common Name: This is typically your Google service account’s email, like test-110@vital-lyceum-426217-h7.iam.gserviceaccount.com
- Email: This is typically your Google service account’s email, like test-110@vital-lyceum-426217-h7.iam.gserviceaccount.com
- A challenge password: Create a password that is at least 6 characters long

All other fields are optional, and you can skip them by simply pressing Enter.
</p>

<h4>Step 3: Create a self-signed certificate</h4>
<p>

`openssl x509 -req -days 365 -in service_account.csr -signkey service_account_key.pem -out service_account_cert.crt`

</p>

<h4>Step 4: Create a P12 bundle</h4>
<p>

`openssl pkcs12 -export -in service_account_cert.crt -inkey service_account_key.pem -out service_account.p12 -name "ServiceAccountName"`

</p>
<p>
  You will be prompted to set an export password. Keep it safe; you will need it again.
</p>

<h4>Step 5: Convert P12 → JKS</h4>
<p>

`keytool -importkeystore -srckeystore service_account.p12 -srcstoretype PKCS12 -destkeystore service_account.jks -deststoretype JKS`

</p>

<h3 id="p12-key-to-jks">Option B: P12 Key → JKS</h3>
<p>
  Use this option if you received a P12 key directly. Your default password received from Google will be "notasecret", use it for the JKS file too. In this case, let's assume that the name of your P12 file is "service_account.p12".
</p>
<p>

`keytool -importkeystore -srckeystore service_account.p12 -srcstoretype PKCS12 -destkeystore service_account.jks -deststoretype JKS`

</p>

<h2 id="upload-certificate-to-salesforce">Upload Certificate to Salesforce</h2>
<ol>
  <li>Go to Salesforce Setup</li>
  <li>Open Certificate and Key Management</li>
  <li>Click Import from Keystore</li>
  <li>Upload the JKS file created above</li>
  <li>Enter the keystore password</li>
</ol>

<p>
  If you encounter “The data you were trying to access could not be found”, refer to the solution: 
  <a href="https://lekkimworld.com/2018/07/03/issue-with-importing-keystore-into-salesforce/?utm_source=chatgpt.com">here</a>
</p>

<h2 id="jwt-creation-in-apex">JWT Creation in Apex</h2>
<p>
  Once the certificate is uploaded, you can generate and sign a JWT in Apex.
</p>
<p>

    Auth.JWT jwt = new Auth.JWT();
    jwt.setAud('https://oauth2.googleapis.com/token');
    jwt.setIss(SERVICE_ACCOUNT_EMAIL)
    jwt.setSub(SERVICE_ACCOUNT_EMAIL);
    jwt.setAdditionalClaims(new Map<String, Object>{'scope' => 'https://www.googleapis.com/auth/drive'});
  
    Auth.JWS jws = new Auth.JWS(jwt, CERTIFICATE_NAME);

</p>

<p>
  Notes:
</p>
<ul>
  <li>iss must be the Service Account email</li>
  <li>sub is optional and used only for domain-wide delegation (impersonation)</li>
</ul>

<h2 id="exchange-jwt-for-access-token">Exchange JWT for Access Token</h2>
<p>
  After signing the JWT, exchange it for an access token using the Auth namespace.
</p>

<p>

    Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(
        jwt.getAud(),
        jws
    );
  
    return bearer.getAccessToken();

</p>
<p>You have set up Google Drive integration. Now to start using the library with this access token, please refer <a href="#what-does-the-library-do">here</a></p>

<h2 id="common-errors-notes">Common Errors &amp; Notes</h2>

<h3>1) JKS key password mismatch</h3>
<p>
  If you see an error like:
  The Keystore contains a certificate "privatekey" whose per key password is not the same as the keystore password.
</p>
<p>
  Fix: ensure the new JKS password matches the existing key password. In practice, use the same password consistently for P12 export, JKS conversion, and Salesforce import.
</p>

<h3>2) Invalid alias when importing into Salesforce</h3>
<p>
  If you see:
  Keystore contains an entry whose alias is not acceptable for import
</p>
<p>
  Fix: see the Salesforce help article:
  <a href="https://help.salesforce.com/s/articleView?id=000387657&amp;type=1">Salesforce help article</a>
</p>

<h2 id="what-does-the-library-do">What Does the Library Do?</h2>
All elements of the integration are configured, and we are already generating an access token. The main question is: why isn't this much-touted library helping us in any way?

- First, we aimed to eliminate any concerns about the security of your data and to organize everything so that the library operates only when the entire integration process is complete. 
- Second, this non-interference allows the library to function independently of specific environment settings, making deployment easier. Using this library is so straightforward that you can simply take the folder, place it in your  repository, and deploy it. That’s it! The entire functionality of the library is at your fingertips, no manual steps, settings, or anything else required.
- Third, the library provides its interface to make your code better structured, see details [here](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Library-Authorization-Flow)

# Getting Started

An access token is not simply "valid" or "invalid" — it carries a set of **scopes** that decide what it is allowed to do. A token minted for `drive.readonly` will read files perfectly well and then fail the moment you try to upload one, with a permission error that says nothing about scopes.

The original `GoogleAuthorizer` interface has a problem here: its `retrieveAccessToken()` method takes no arguments, so your authorizer class genuinely cannot know what it is about to be used for. Faced with that, most implementations request the full `https://www.googleapis.com/auth/drive` scope for everything, because it is the only choice that always works. That is convenient, and it is also the most expensive scope Google offers.

The library therefore lets you declare, up front, what a credential is for. Your authorizer receives that declaration and can mint a token narrow enough for the job.

> [!NOTE]
> This is entirely optional and fully backward compatible. An existing class implementing `GoogleAuthorizer` keeps working exactly as before, with or without declared scopes. Nothing you already have needs to change.

## <span id="google-scope">The GoogleScope Enum</span>

`GoogleScope` lists the scopes the Drive API understands, so you name them instead of pasting URLs:

```
GoogleScope.DRIVE_FILE
GoogleScope.DRIVE_READONLY
GoogleScope.DRIVE_METADATA_READONLY
```

Google sorts its scopes into three tiers, and the tier decides what it costs you to ship. Non-sensitive scopes need nothing. Sensitive scopes require OAuth app verification. Restricted scopes require verification **and** an annual third-party security assessment, which is a real budget line rather than a formality.

| Scope | Tier | Grants |
| --- | --- | --- |
| `DRIVE_FILE` | Non-sensitive | Files your application created or the user explicitly opened with it. Google's recommended default. |
| `DRIVE_APPDATA` | Non-sensitive | Your application's own hidden configuration folder. |
| `DRIVE_INSTALL` | Non-sensitive | Appearing in the Drive "New" and "Open with" menus. |
| `DRIVE_APPS_READONLY` | Sensitive | The list of applications authorized against the user's Drive. |
| `DRIVE` | Restricted | Full read and write access to every file. The widest scope there is. |
| `DRIVE_READONLY` | Restricted | Reading and downloading every file. |
| `DRIVE_METADATA` | Restricted | Reading and writing metadata, never file content. |
| `DRIVE_METADATA_READONLY` | Restricted | Reading metadata only — enough for search, listing and folder navigation. |
| `DRIVE_SCRIPTS` | Restricted | Modifying the behaviour of Google Apps Script projects. |
| `DRIVE_ACTIVITY` | Restricted | Reading and appending to the activity record of files. |
| `DRIVE_ACTIVITY_READONLY` | Restricted | Reading the activity record of files. |
| `DRIVE_MEET_READONLY` | Restricted | Reading files created or edited by Google Meet. |

The rule of thumb is to ask for the narrowest scope that does the job. For a Salesforce integration that creates its own documents and manages them afterwards, `DRIVE_FILE` is usually enough and keeps you out of the restricted tier entirely.

## <span id="scoped-authorizer">The GoogleScopedAuthorizer Interface</span>

`GoogleScopedAuthorizer` is the scope-aware counterpart of `GoogleAuthorizer`. It is a separate interface, not an extension of the original, so implementing it is a choice rather than an obligation.

```
public with sharing class CustomScopedAuthorizer implements GoogleScopedAuthorizer {
    private final String SERVICE_ACCOUNT_EMAIL = 'YOUR_SERVICE_ACC_EMAIL';
    private final String CERTIFICATE_NAME = 'YOUR_CERTIFICATE_NAME';

    public String retrieveAccessToken(List<GoogleScope> requestedScopes) {
        Auth.JWT jwt = new Auth.JWT();
        jwt.setAud('https://oauth2.googleapis.com/token');
        jwt.setSub(SERVICE_ACCOUNT_EMAIL);
        jwt.setIss(SERVICE_ACCOUNT_EMAIL);
        jwt.setAdditionalClaims(new Map<String, Object>{
            'scope' => GoogleScopeResolver.toScopeUrls(requestedScopes)
        });

        Auth.JWS jws = new Auth.JWS(jwt, CERTIFICATE_NAME);
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(jwt.getAud(), jws);

        return bearer.getAccessToken();
    }
}
```

`GoogleScopeResolver` does the translation for you. `toScopeUrls(...)` returns the scopes as one space-delimited string, which is the form Google's token endpoint expects for the `scope` claim. `toScopeUrlList(...)` returns them as a list, and `toScopeUrl(...)` converts a single value. All three sort and de-duplicate, so the same set of scopes always produces the same string.

The list handed to your class is never `null`. If the caller declared nothing, it arrives empty, and it is up to you to decide what that means — falling back to a sensible default is reasonable.

## <span id="declaring-scopes">Declaring the Scopes</span>

Scopes are declared once, when the credential is built, using `setRequestedScopes(...)` on the `GoogleAuthorizationCodeFlow.Builder`:

```
GoogleCredential googleDriveCredentials = new GoogleAuthorizationCodeFlow.Builder()
    .setLocalGoogleAuthorizer('CustomScopedAuthorizer')
    .setRequestedScopes(new List<GoogleScope>{ GoogleScope.DRIVE_FILE })
    .build();

GoogleDrive googleDriveLibrary = new GoogleDrive(googleDriveCredentials, 'Apex/1.0 (Salesforce Library)');
```

The library then looks at the class you named and picks the right method:

- If it implements `GoogleScopedAuthorizer`, it receives the declared scopes.
- If it only implements `GoogleAuthorizer`, the original no-argument method is called, exactly as before.

A class that implements both is treated as scoped. This is why declaring scopes against an authorizer that cannot receive them is harmless — the declaration is simply not used.

Declare all of the scopes a credential will need, since one credential serves every call made through the `GoogleDrive` instance built from it:

```
GoogleCredential googleDriveCredentials = new GoogleAuthorizationCodeFlow.Builder()
    .setLocalGoogleAuthorizer('CustomScopedAuthorizer')
    .setRequestedScopes(new List<GoogleScope>{
        GoogleScope.DRIVE_FILE,
        GoogleScope.DRIVE_METADATA_READONLY
    })
    .build();
```

## <span id="scopes-and-cache">Scopes and the Platform Cache</span>

Caching access tokens is described in [Library Authorization Flow](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Library-Authorization-Flow), and it used to come with a warning: one cache key served every token, so a token cached for a read-only credential could be handed straight to an upload and fail there.

Declaring scopes fixes that. When — and only when — `setRequestedScopes(...)` is used, the library appends a short digest of the scope set to the cache key, so each set of scopes gets its own entry:

```
Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.GoogleCloudClient');

GoogleCredential readCredentials = new GoogleAuthorizationCodeFlow.Builder()
    .setLocalGoogleAuthorizer('CustomScopedAuthorizer')
    .setLocalPlatformCache(orgPartition, 'accessToken')
    .setRequestedScopes(new List<GoogleScope>{ GoogleScope.DRIVE_METADATA_READONLY })
    .build();

GoogleCredential writeCredentials = new GoogleAuthorizationCodeFlow.Builder()
    .setLocalGoogleAuthorizer('CustomScopedAuthorizer')
    .setLocalPlatformCache(orgPartition, 'accessToken')
    .setRequestedScopes(new List<GoogleScope>{ GoogleScope.DRIVE_FILE })
    .build();
```

Both use the key `accessToken`, and neither will ever receive the other's token.

If you do not declare scopes, the key stays exactly what you passed. Upgrading the library does not invalidate tokens already sitting in your cache.

> [!WARNING]
> Platform Cache keys are alphanumeric and limited to **50 characters**, and the scope digest adds 8 more. If your key is too long to take the suffix, the library throws an `IllegalArgumentException` naming the limit, rather than letting Salesforce fail with something harder to read. Keep cache keys short — `accessToken` or `gdriveToken` is plenty.

## <span id="which-scope">Which Scope for Which Operation</span>

A starting point rather than a guarantee, since the answer also depends on who owns the file and how it got there. Test against your own tenant before narrowing a scope in production.

| What you are doing | Usually enough |
| --- | --- |
| Creating files and folders, then managing what you created | `DRIVE_FILE` |
| Uploading new versions of files your integration created | `DRIVE_FILE` |
| Searching and listing files created by someone else | `DRIVE_METADATA_READONLY` |
| Downloading or exporting files created by someone else | `DRIVE_READONLY` |
| Managing permissions on files created by someone else | `DRIVE` |
| Creating, renaming or deleting shared drives | `DRIVE` |
| Reading and writing labels on a file | `DRIVE_METADATA` or `DRIVE` |

`DRIVE_FILE` is narrower than it first appears: it covers every file your integration created, for the whole life of that file. If your Salesforce org is the thing producing the documents, it is very often all you need.

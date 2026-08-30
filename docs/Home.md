# About The Library

The Salesforce Apex Google Drive Library offers programmatic access to Google Drive through API methods. This library simplifies coding against these APIs by providing robust methods for creating, cloning, downloading, sharing, and searching files and drives. Its implementation is accompanied by a newer version of the Google Drive API v3. You can read about the benefits <a href="https://developers.google.com/drive/api/guides/v3versusv2">here</a>.

To utilize this library effectively, an already configured Google Drive integration is required, as it relies on an access token for proper operation. Obtaining this token is the responsibility of the developer using the library. However, the library provides a user-friendly `GoogleCredential` interface and `GoogleAuthorizationCodeFlow` authorizer to facilitate the creation of all necessary credentials.

Here's why this library:
* The entire implementation adheres to best practices, utilizing factories, builders, and isolated code units. This ensures a reliable and secure interaction with the Google Drive API, making this library a robust and efficient choice for developers.
* The code is entirely free from dependencies, allowing immediate use of the library after deploying the elements in the `google-drive` folder. Furthermore, all the code is thoroughly tested and verified, ensuring an overall test coverage of over 90%.
* The library is open to contributions and is actively developing, continually adding new features. It guarantees constant monitoring for any errors and promptly addresses and resolves them.

Refer to the <a href="https://developers.google.com/api-client-library">Google Drive Client Libraries</a> for existing counterparts in other programming languages, as the practices and approaches used in those libraries have been applied in implementing this one.

# What You Can Do With It

Everything starts from a single `GoogleDrive` instance, which groups the API into six categories. Each one has its own page in this wiki.

| Category | Operations | Where to read |
| --- | --- | --- |
| `files()` | Upload, download, modify, clone, delete, trash, search | [Uploading](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Uploading-Files-to-Google-Drive), [Downloading](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Downloading-Files-from-Google-Drive), [Modifying](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Modify-Files-in-Google-Drive) |
| `drives()` | Create, retrieve, modify, remove, hide, unhide, search | [Shared Drives Management](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Shared-Drives-Management) |
| `permissions()` | Create, retrieve, modify, remove, search | [Permissions Management](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Permissions-Management) |
| `revisions()` | Search, retrieve, modify, remove | [File Versions](https://github.com/sandriiy/salesforce-google-drive-library/wiki/File-Versions-in-Google-Drive) |
| `labels()` | Search, modify | [Labels Management](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Labels-Management) |
| `operations()` | Retrieve | [Downloading Files](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Downloading-Files-from-Google-Drive#operations) |

New here? Start with the [Quick Setup Guide](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Quick-Setup-Guide) to get an access token, then the [Library Authorization Flow](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Library-Authorization-Flow) to create your first `GoogleDrive` instance.

# Contribute

Interested in contributing to challenging and innovative implementations? <b>You’re in the right place</b>. This, and all other open-source libraries we offer for public use, are fully open to extensions, new ideas, and fresh approaches. We have only one requirement: the code must be clean and maintainable. If you’re interested in contributing, please feel free to contact me at ansukhetskyi@gmail.com.

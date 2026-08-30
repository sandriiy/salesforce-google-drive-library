<div align="center">
  <p>
    <a href="https://www.youtube.com/watch?v=Q35QwAvSrP0" target="_blank">
      <img src="https://img.shields.io/badge/%20View%20Demo-blue?style=flat-square&logo=youtube" alt="View Demo">
    </a>
    <a href="https://github.com/sandriiy/salesforce-google-drive-library/issues/new?labels=bug&template=bug_report.md">
      <img src="https://img.shields.io/badge/🐛%20Report%20Bug-red" alt="Report Bug">
    </a>
    <a href="https://github.com/sandriiy/salesforce-google-drive-library/issues/new?labels=enhancement&template=feature_request.md">
      <img src="https://img.shields.io/badge/✨%20Request%20Feature-green" alt="Request Feature">
    </a>
  </p>

  [![Watch on GitHub](https://img.shields.io/github/watchers/sandriiy/salesforce-google-drive-library.svg?style=social)](https://github.com/sandriiy/salesforce-google-drive-library/watchers)
  [![Star on GitHub](https://img.shields.io/github/stars/sandriiy/salesforce-google-drive-library.svg?style=social)](https://github.com/sandriiy/salesforce-google-drive-library/stargazers)
</div>

## <span id="getting-started">Getting Started</span>

The Salesforce Apex Google Drive Library offers programmatic access to Google Drive through API methods. This library simplifies coding against these APIs by providing robust methods for creating, cloning, downloading, sharing, and searching files, drives and permissions. Its implementation is accompanied by a newer version of the Google Drive API v3. You can read about the benefits [here](https://developers.google.com/drive/api/guides/v3versusv2)

You can find the integration configuration, including both the Google Cloud and Salesforce sides, along with all the methods, details, and challenges, in the Wiki of this repository at the [following link](https://github.com/sandriiy/salesforce-google-drive-library/wiki/Quick-Setup-Guide)

To get started with the Apex Google Drive library, its code needs to be deployed to your environment. All the code can either be deployed directly, contained in the `google-drive` folder and fully self-contained, or the Unlocked Package can be installed for a more modular setup of the library code. If the Unlocked Package is of interest, the two buttons below, depending on the environment, can be used to install the latest version:

<div align="center" style="display: flex; justify-content: space-between;">
  <a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04tQy000000W2OTIA0">
    <img src="https://img.shields.io/badge/Install%20In%20Sandbox-blue?style=for-the-badge&logo=salesforce" alt="Install the Unlocked Package in Sandbox">
  </a>
  <a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04tQy000000W2OTIA0">
    <img src="https://img.shields.io/badge/Install%20In%20Production-blue?style=for-the-badge&logo=salesforce" alt="Install the Unlocked Package in Production">
  </a>
</div>
<br>

You can also use Salesforce CLI to install this package. To do so, run the following command:
`sf package install --wait 20 --security-type AdminsOnly --package 04tQy000000W2OTIA0`

<br>

> [!NOTE]  
> This library provides an SDK that offers a simplified, developer-friendly interface for working with Google Drive. Our team recently released a new project that delivers a full Google Client experience, allowing you to completely replace Salesforce Files. For more details, see here — https://github.com/sandriiy/salesforce-google-client

## Usage Guide

To begin using this library, you first need to set up the Google Drive integration. This includes enabling the Google Drive API in the Google Admin Console, creating a Service Account, obtaining a key, and generating a certificate to upload into Salesforce. All steps are outlined in the <a href="https://github.com/sandriiy/salesforce-google-drive-library/wiki/Quick-Setup-Guide">Quick Setup Guide</a>

Once the setup is complete, the entry point is to instantiate the `GoogleDrive` class, which provides all builders, factories, and methods for interacting with the Google Drive API in an object-oriented manner. Detailed instructions for creating this instance are available on the <a href="https://github.com/sandriiy/salesforce-google-drive-library/wiki/Library-Authorization-Flow">Library Authorization Flow page</a>

Through this instance, you gain access to six main categories: `files`, `drives`, `permissions`, `revisions`, `labels` and `operations`. Each category exposes a dedicated set of operations. The full hierarchy of available methods is shown below.

- **.files()**
  - **.search()** – `GoogleFileSearchBuilder`
  - **.search(String nextPageToken)** – `GoogleFileSearchBuilder`
  - **.modify()** – `GoogleModifyFileFactory`
    - **.metadata(String fileId)** – `GoogleModifyMetadataFileBuilder`
    - **.simpleUpdate(String fileId)** – `GoogleSimpleFileBuilder`
    - **.multipartUpdate(String fileId)** – `GoogleMultipartFileBuilder`
    - **.resumableUpdate(String fileId)** – `GoogleResumableFileBuilder`
  - **.simpleCreate()** – `GoogleSimpleFileBuilder`
  - **.multipartCreate()** – `GoogleMultipartFileBuilder`
  - **.resumableCreate()** – `GoogleResumableFileBuilder`
  - **.retrieve()** – `GoogleRetrieveFileFactory`
    - **.download(String fileId)** – `GoogleDownloadFileBuilder`
    - **.export(String fileId)** – `GoogleExportFileBuilder`
    - **.downloadLink(String fileId)** – `GoogleAsyncDownloadFileBuilder`
  - **.clone(String fileId)** – `GoogleCloneFileBuilder`
  - **.remove(String fileId)** – `GoogleDeleteFileBuilder`
  - **.trash(String fileId)** – `GoogleTrashFileBuilder`
- **.drives()**
  - **.search()** – `GoogleDriveSearchBuilder`
  - **.search(String nextPageToken)** – `GoogleDriveSearchBuilder`
  - **.create()** – `GoogleCreateDriveBuilder`
  - **.retrieve(String driveId)** – `GoogleRetrieveDriveBuilder`
  - **.modify(String driveId)** – `GoogleModifyDriveBuilder`
  - **.remove(String driveId)** – `GoogleDeleteDriveBuilder`
  - **.hide(String driveId)** – `GoogleHideDriveBuilder`
  - **.unhide(String driveId)** – `GoogleUnhideDriveBuilder`
- **.permissions()**
  - **.create(String fileId)** – `GoogleCreatePermissionFileBuilder`
  - **.retrieve(String fileId, String permissionId)** – `GoogleRetrievePermissionFileBuilder`
  - **.modify(String fileId, String permissionId)** – `GoogleModifyPermissionFileBuilder`
  - **.remove(String fileId, String permissionId)** – `GoogleDeletePermissionFileBuilder`
  - **.search(String fileId)** – `GooglePermissionSearchBuilder`
- **.revisions()**
  - **.search(String fileId)** – `GoogleRevisionSearchBuilder`
  - **.retrieve(String fileId, String revisionId)** – `GoogleRetrieveRevisionBuilder`
  - **.modify(String fileId, String revisionId)** – `GoogleModifyRevisionBuilder`
  - **.remove(String fileId, String revisionId)** – `GoogleDeleteRevisionBuilder`
- **.labels()**
  - **.search(String fileId)** – `GoogleLabelSearchBuilder`
  - **.modify(String fileId)** – `GoogleModifyLabelsFileBuilder`
- **.operations()**
  - **.retrieve(String operationName)** – `GoogleRetrieveOperationBuilder`

## <span id="info">Acknowledgments</span>

* https://github.com/sandriiy/salesforce-google-drive-library/wiki
* https://developers.google.com/drive/api/reference/rest/v3
* https://developers.google.com/api-client-library
* https://www.oracle.com/corporate/features/library-in-java-best-practices.html


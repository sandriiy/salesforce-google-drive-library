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

/**
 * The OAuth scopes the Google Drive API understands, for use with
 * GoogleAuthorizationCodeFlow.Builder.setRequestedScopes and GoogleScopedAuthorizer.
 *
 * Google sorts these into three tiers, and the tier decides what the org has to go
 * through to ship: non-sensitive scopes need nothing, sensitive scopes need OAuth app
 * verification, and restricted scopes need verification plus an annual third-party
 * security assessment. Ask for the narrowest scope that does the job - DRIVE_FILE covers
 * most integrations and is the only non-sensitive way to read and write real user files.
*/
public enum GoogleScope {
    /**
     * Full read and write access to every file in the user's Drive. Restricted.
     * The widest scope there is - only pick it when nothing narrower can work.
    */
    DRIVE,

    /**
     * Read and write access limited to the files this application created or the user
     * explicitly opened with it. Non-sensitive, and Google's recommended default.
    */
    DRIVE_FILE,

    /**
     * Read and download every file in the user's Drive. Restricted.
    */
    DRIVE_READONLY,

    /**
     * Read and write file metadata, but never file content. Restricted.
    */
    DRIVE_METADATA,

    /**
     * Read file metadata, but never file content. Restricted.
     * Enough for search, listing and folder navigation.
    */
    DRIVE_METADATA_READONLY,

    /**
     * Read and write the application's own hidden configuration folder. Non-sensitive.
    */
    DRIVE_APPDATA,

    /**
     * Read the list of applications authorized against the user's Drive. Sensitive.
    */
    DRIVE_APPS_READONLY,

    /**
     * Modify the behaviour of the user's Google Apps Script projects. Restricted.
    */
    DRIVE_SCRIPTS,

    /**
     * Let the application appear in the Drive "Open with" and "New" menus. Non-sensitive.
    */
    DRIVE_INSTALL,

    /**
     * Read and append to the activity record of files in the user's Drive. Restricted.
    */
    DRIVE_ACTIVITY,

    /**
     * Read the activity record of files in the user's Drive. Restricted.
    */
    DRIVE_ACTIVITY_READONLY,

    /**
     * Read Drive files created or edited by Google Meet. Restricted.
    */
    DRIVE_MEET_READONLY
}

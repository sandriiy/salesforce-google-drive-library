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

public class GoogleDriveEntity {
    public String id;
    public String name;
    public String colorRgb;
    public String kind;
    public String backgroundImageLink;
    public Capabilities capabilities;
    public String themeId;
    public BackgroundImageFile backgroundImageFile;
    public String createdTime;
    public Boolean hidden;
    public Restrictions restrictions;
    public String orgUnitId;
    
    public class Capabilities {
        public Boolean canAddChildren;
        public Boolean canComment;
        public Boolean canCopy;
        public Boolean canDeleteDrive;
        public Boolean canDownload;
        public Boolean canEdit;
        public Boolean canListChildren;
        public Boolean canManageMembers;
        public Boolean canReadRevisions;
        public Boolean canRename;
        public Boolean canRenameDrive;
        public Boolean canChangeDriveBackground;
        public Boolean canShare;
        public Boolean canChangeCopyRequiresWriterPermissionRestriction;
        public Boolean canChangeDomainUsersOnlyRestriction;
        public Boolean canChangeDriveMembersOnlyRestriction;
        public Boolean canChangeSharingFoldersRequiresOrganizerPermissionRestriction;
        public Boolean canResetDriveRestrictions;
        public Boolean canDeleteChildren;
        public Boolean canTrashChildren;
    }
    
    public class BackgroundImageFile {
        public String id;
        public Double xCoordinate;
        public Double yCoordinate;
        public Double width;
    }
    
    public class Restrictions {
        public Boolean copyRequiresWriterPermission;
        public Boolean domainUsersOnly;
        public Boolean driveMembersOnly;
        public Boolean adminManagedRestrictions;
        public Boolean sharingFoldersRequiresOrganizerPermission;
    }
}
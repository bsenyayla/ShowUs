using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using Amazon.S3.IO;

namespace Digiturk.Cloud.AwsS3Sync
{
    public class CustomS3Client
    {
        private string m_SynchronizerName;
        private volatile bool m_IsPaused;

        private IAmazonS3 m_AwsS3Client;
        private TransferUtility m_AwsTransferUtility;

        private string m_BucketName;
        private SyncMode m_Mode;
        private string m_SourcePath;
        private string m_FilterExpression;
        private string m_DestinationPath;

        private Hashtable m_AwsS3Objects;
        private Hashtable m_LocalObjects;

        private List<string> m_DeletionKeysFromS3;
        private List<string> m_DeletionKeysFromLocal;

        private List<string> m_UploadKeysToS3;
        private List<string> m_DownloadKeysToLocal;

        private string m_AwsS3MounthPath;
        private string m_LocalMounthPath;

        public bool IsPaused {
            get { return m_IsPaused; }
        }
        public bool IsReadyForOperation {
            get { return m_AwsS3Client != null && m_AwsTransferUtility != null; }
        }
        private bool IsUpload {
            get { return m_Mode == SyncMode.OnlyUpload || m_Mode == SyncMode.UploadAndDelete; }
        }
        private bool IsDownload {
            get { return m_Mode == SyncMode.OnlyDownload || m_Mode == SyncMode.DownloadAndDelete; }
        }
        public string AwsS3MountPath {
            get { return m_AwsS3MounthPath; }
        }
        private string LocalMountPath {
            get { return m_LocalMounthPath; }
        }

        private CustomS3Client() {
            //default-constructor
        }
        public CustomS3Client(string synchronizerName) {
            m_SynchronizerName = synchronizerName;
            m_IsPaused = false;
        }

        public void Pause() {
            m_IsPaused = true;
        }
        public void Resume() {
            m_IsPaused = false;
        }

        public void IterationInitialize() {
            string tempLocalPath = (IsDownload ? m_DestinationPath : m_SourcePath);
            tempLocalPath = Utility.FillMounthPathIfHasVariable(tempLocalPath);

            string tempS3Path = (IsDownload ? m_SourcePath : m_DestinationPath);
            tempS3Path = Utility.FillMounthPathIfHasVariable(tempS3Path);

            if (tempLocalPath != m_LocalMounthPath) {
                m_LocalMounthPath = tempLocalPath;
                CheckLocalMountDirectoryExists();
            }
            if (tempS3Path != m_AwsS3MounthPath) {
                m_AwsS3MounthPath = tempS3Path;
                CheckS3MountDirectoryExists();
            }
        }

        public void SetCoreParticules(IAmazonS3 s3Client, TransferUtility transferUtility, SynchronizationConfigurationElement syncConfigElement)
        {
            m_AwsS3Client = s3Client;
            m_AwsTransferUtility = transferUtility;

            m_BucketName = syncConfigElement.BucketName;
            m_Mode = (SyncMode)Enum.Parse(typeof(SyncMode), syncConfigElement.Mode, true);
            m_SourcePath = syncConfigElement.SourcePath;
            m_FilterExpression = syncConfigElement.FilterExpression;
            m_DestinationPath = syncConfigElement.DestinationPath;
        }

        private void CheckLocalMountDirectoryExists()
        {
            DirectoryInfo di = new DirectoryInfo(LocalMountPath);
            if (!di.Exists) {
                di.Create();
                Logger.WriteLine(m_SynchronizerName + " created a directory on local-file-system with fullname : " + di.FullName);
            }
        }

        private void CheckS3MountDirectoryExists()
        {
            if (!string.IsNullOrEmpty(AwsS3MountPath)) {
                string mountKey = Utility.PathCorrectForS3Key(AwsS3MountPath, true);
                if (string.IsNullOrEmpty(mountKey) || mountKey == "/") return;
                if (mountKey.EndsWith("/")) mountKey = mountKey.Substring(0,mountKey.Length-1);
                S3DirectoryInfo s3di = new S3DirectoryInfo(m_AwsS3Client, m_BucketName, mountKey);
                if (!s3di.Exists) {
                    s3di.Create();
                    Logger.WriteLine(m_SynchronizerName + " created a directory on S3 bucket (" + m_BucketName + ") with key : " + mountKey);
                }
            }
        }

        private bool IsExpressionOk(string pattern, string strValue)
        {
            try {
                if ( string.IsNullOrEmpty(pattern) ) return true;
                Regex rgx = new Regex(pattern, RegexOptions.IgnoreCase);
                Match m = rgx.Match(strValue);
                return m.Success;
            }
            catch (Exception exc) {
                Logger.WriteError("Error occured at CustomS3Client-->IsExpressionOk()", exc);
                return false;
            }
        }

        public void PopulateS3Objects()
        {
            ListObjectsRequest req = new ListObjectsRequest();
            req.BucketName = m_BucketName;
            //req.MaxKeys = Constants.S3ListObjectsMaxKeysCount;
            if (!string.IsNullOrEmpty(AwsS3MountPath) && AwsS3MountPath != "/") req.Prefix = AwsS3MountPath;
            
            m_AwsS3Objects = new Hashtable();
            do {
                ListObjectsResponse resp = m_AwsS3Client.ListObjects(req);
                if (resp == null && resp.S3Objects == null) return;
                foreach (S3Object obj in resp.S3Objects) {
                    string relativeKey = Utility.GetRelativePathForS3(AwsS3MountPath, obj.Key, obj.Key.EndsWith("/"));
                    if (string.IsNullOrEmpty(m_FilterExpression) || (!obj.Key.EndsWith("/") && IsExpressionOk(m_FilterExpression, relativeKey))) {
                        m_AwsS3Objects.Add(relativeKey, obj);
                    }
                    if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
                }
                if (resp.IsTruncated) {
                    req.Marker = resp.NextMarker;
                } else {
                    req = null;
                }
            } while (req != null);            
        }

        public void PopulateLocalObjects()
        {
            DirectoryInfo baseDir = new DirectoryInfo(LocalMountPath);
            m_LocalObjects = new Hashtable();
            SelectLocalFilesRecursively(baseDir);
        }

        private void SelectLocalFilesRecursively(DirectoryInfo dirInfo)
        {
            if (dirInfo.FullName != LocalMountPath) {
                if (string.IsNullOrEmpty(m_FilterExpression)) {
                    string relativeKey = Utility.GetRelativePathForS3(LocalMountPath, dirInfo.FullName, true);
                    m_LocalObjects.Add(relativeKey, dirInfo);
                }
            }
            foreach (FileInfo fi in dirInfo.GetFiles()) {
                string relativeKey = Utility.GetRelativePathForS3(LocalMountPath, fi.FullName, false);
                if (string.IsNullOrEmpty(m_FilterExpression) || IsExpressionOk(m_FilterExpression, relativeKey)) {
                    m_LocalObjects.Add(relativeKey, fi);
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            foreach (DirectoryInfo di in dirInfo.GetDirectories()) {
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
                SelectLocalFilesRecursively(di);
            }
        }

        public void CalculateDeletionsFromS3()
        {
            if (m_Mode != SyncMode.UploadAndDelete ) return;
            m_DeletionKeysFromS3 = new List<string>();
            foreach (DictionaryEntry entry in m_AwsS3Objects) {
                string key = entry.Key.ToString();
                if (!m_LocalObjects.ContainsKey(key)) m_DeletionKeysFromS3.Add(key);
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
        }

        public void CalculateUploadsToS3()
        {
            if ( !IsUpload ) return;
            m_UploadKeysToS3 = new List<string>();
            foreach (DictionaryEntry entry in m_LocalObjects) {
                string key = entry.Key.ToString();
                if (!m_AwsS3Objects.ContainsKey(key)) {
                    m_UploadKeysToS3.Add(key);
                }
                else if (!key.EndsWith("/")) {
                    FileInfo fi = (FileInfo)entry.Value;
                    S3Object obj = (S3Object)m_AwsS3Objects[key];
                    if (AreFilesChanged(fi, obj)) m_UploadKeysToS3.Add(key);
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
        }

        private bool AreFilesChanged(FileInfo fi, S3Object obj)
        {
            string md5Checksum = Utility.CalculateMD5Checksum(fi.FullName);
            if (md5Checksum != null && obj.ETag != null && md5Checksum != obj.ETag) {
                //Logger.WriteLine("  --> MD5 Checksum = " + md5Checksum + " for file = " + fi.FullName);
                //Logger.WriteLine("  --> Remote E-Tag = " + obj.ETag + " for file = " + obj.Key);
                return true;
            }
            return false;
        }

        public void CalculateDeletionsFromLocal()
        {
            if (m_Mode != SyncMode.DownloadAndDelete) return;
            m_DeletionKeysFromLocal = new List<string>();
            foreach (DictionaryEntry entry in m_LocalObjects) {
                string key = entry.Key.ToString();
                if (!m_AwsS3Objects.ContainsKey(key)) {
                    m_DeletionKeysFromLocal.Add(key);
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
        }

        public void CalculateDownloadsToLocal()
        {
            if (!IsDownload) return;
            m_DownloadKeysToLocal = new List<string>();
            foreach (DictionaryEntry entry in m_AwsS3Objects) {
                string key = entry.Key.ToString();
                if (string.IsNullOrEmpty(key)) continue;
                if (!m_LocalObjects.ContainsKey(key)) {
                    m_DownloadKeysToLocal.Add(key);
                }else if (!key.EndsWith("/")) {
                    S3Object obj = (S3Object)entry.Value;
                    FileInfo fi = (FileInfo)m_LocalObjects[key];
                    if (AreFilesChanged(fi, obj)) m_DownloadKeysToLocal.Add(key);
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
        }

        public void TraceDifferences()
        {
            if ( IsUpload ) {
                if ( (m_UploadKeysToS3 != null && m_UploadKeysToS3.Count > 0) || (m_DeletionKeysFromS3 != null && m_DeletionKeysFromS3.Count > 0 && m_Mode == SyncMode.UploadAndDelete) )
                    Logger.WriteLine("--------------------------------------------------------------");
                if( m_UploadKeysToS3 != null )
                    foreach (string key in m_UploadKeysToS3)
                        Logger.WriteLine(m_SynchronizerName + " ==> Mode-" + m_Mode + " : Found-Sync --> Upload-Key-To-S3      = " + ((FileSystemInfo)m_LocalObjects[key]).FullName);
                if( m_Mode == SyncMode.UploadAndDelete && m_DeletionKeysFromS3 != null )
                    foreach (string key in m_DeletionKeysFromS3)
                        Logger.WriteLine(m_SynchronizerName + " ==> Mode-" + m_Mode + " : Found-Sync --> Delete-Key-From-S3    = " + ((S3Object)m_AwsS3Objects[key]).Key );
                if ((m_UploadKeysToS3 != null && m_UploadKeysToS3.Count > 0) || (m_DeletionKeysFromS3 != null && m_DeletionKeysFromS3.Count > 0 && m_Mode == SyncMode.UploadAndDelete))
                    Logger.WriteLine("--------------------------------------------------------------");
            }
            else if ( IsDownload ) {
                if ( (m_DownloadKeysToLocal != null && m_DownloadKeysToLocal.Count > 0 ) || ( m_DeletionKeysFromLocal != null && m_DeletionKeysFromLocal.Count > 0 && m_Mode == SyncMode.DownloadAndDelete) )
                    Logger.WriteLine("--------------------------------------------------------------");
                if( m_DownloadKeysToLocal != null )
                    foreach (string key in m_DownloadKeysToLocal)
                        Logger.WriteLine(m_SynchronizerName + " ==> Mode-" + m_Mode + " : Found-Sync --> Download-Key-To-Local = " + ((S3Object)m_AwsS3Objects[key]).Key);
                if( m_Mode == SyncMode.DownloadAndDelete && m_DeletionKeysFromLocal != null )
                    foreach (string key in m_DeletionKeysFromLocal)
                        Logger.WriteLine(m_SynchronizerName + " ==> Mode-" + m_Mode + " : Found-Sync --> Delete-Key-From-Local = " + ((FileSystemInfo)m_LocalObjects[key]).FullName);
                if ((m_DownloadKeysToLocal != null && m_DownloadKeysToLocal.Count > 0) || (m_DeletionKeysFromLocal != null && m_DeletionKeysFromLocal.Count > 0 && m_Mode == SyncMode.DownloadAndDelete))
                    Logger.WriteLine("--------------------------------------------------------------");
            }
            if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
        }

        public void PerformUploadsToS3()
        {
            if ( !IsUpload || m_UploadKeysToS3 == null || m_UploadKeysToS3.Count <= 0 || m_LocalObjects == null) return;
            foreach (string key in m_UploadKeysToS3) {
                if (key.EndsWith("/")) {
                    object value = m_LocalObjects[key];
                    if (value.GetType() == typeof(DirectoryInfo)) {
                        string fullS3Key = Utility.CombinePaths(AwsS3MountPath, key, true);
                        DirectoryInfo di = (DirectoryInfo)value;
                        PutObjectRequest request = new PutObjectRequest();
                        request.BucketName = m_BucketName;
                        request.StorageClass = S3StorageClass.Standard;
                        request.ServerSideEncryptionMethod = ServerSideEncryptionMethod.None;
                        request.Key = fullS3Key;
                        request.ContentBody = string.Empty;
                        PutObjectResponse response = m_AwsS3Client.PutObject(request);
                        Logger.WriteLine(m_SynchronizerName + " created a directory on S3 with key = " + fullS3Key);
                    }
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            foreach (string key in m_UploadKeysToS3) {
                if (!key.EndsWith("/")) {
                    object value = m_LocalObjects[key];
                    if (value.GetType() == typeof(FileInfo)) {
                        string fullS3Key = Utility.CombinePaths(AwsS3MountPath, key, false);
                        FileInfo fi = (FileInfo)value;
                        TransferUtilityUploadRequest request = new TransferUtilityUploadRequest();
                        request.BucketName = m_BucketName;
                        //request.FilePath = Utility.GetPhysicalPathFromS3Key(LocalMountPath,key);
                        request.Key = fullS3Key;
                        request.AutoCloseStream = true;
                        string fileFullName = Utility.GetPhysicalPathFromS3Key(LocalMountPath,key);
                        request.InputStream = new FileStream(fileFullName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                        m_AwsTransferUtility.Upload(request);
                        Logger.WriteLine(m_SynchronizerName + " uploaded a file to S3 with key = " + fullS3Key);
                    }
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            Logger.WriteLine("--------------------------------------------------------------");
        }

        public void PerformDeletionsFromS3()
        {
            if (m_Mode != SyncMode.UploadAndDelete || m_DeletionKeysFromS3 == null || m_DeletionKeysFromS3.Count <= 0) return;
            List<string> s3KeyList = new List<string>();
            foreach (string key in m_DeletionKeysFromS3) {
                if (!key.EndsWith("/")) {
                    string realS3Key = Utility.CombinePaths(AwsS3MountPath, key, false);
                    s3KeyList.Add(realS3Key);
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            this.DeleteObjectsFromS3(s3KeyList, "File");
            this.CheckAndDeleteS3FoldersIfEmpty();
            s3KeyList.Clear();
            foreach (string key in m_DeletionKeysFromS3) {
                if (key.EndsWith("/")) {
                    string realS3Key = Utility.CombinePaths(AwsS3MountPath, key, true);
                    s3KeyList.Add(realS3Key);
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            this.DeleteObjectsFromS3(s3KeyList, "Folder");
            Logger.WriteLine("--------------------------------------------------------------");
        }

        private void CheckAndDeleteS3FoldersIfEmpty()
        {
            if (string.IsNullOrEmpty(m_FilterExpression)) return;
            try {
                List<string> allPossibleFolderKeys = GetAllPossibleRelativeParentFolderKeys(m_DeletionKeysFromS3);
                if( allPossibleFolderKeys == null || allPossibleFolderKeys.Count <= 0 ) return;
                foreach(string key in allPossibleFolderKeys.OrderByDescending(x => x.Length)) {
                    string fullKey = Utility.CombinePaths(AwsS3MountPath,key,true);
                    ListObjectsRequest req = new ListObjectsRequest();
                    req.BucketName = m_BucketName;
                    req.Prefix = fullKey;
                    ListObjectsResponse resp = m_AwsS3Client.ListObjects(req);
                    if (resp != null && resp.S3Objects != null && resp.S3Objects.Count == 1 && resp.S3Objects[0].Key == fullKey) {
                        DeleteObjectRequest delObjReq = new DeleteObjectRequest();
                        delObjReq.BucketName = m_BucketName;
                        delObjReq.Key = fullKey;
                        DeleteObjectResponse delObjResp = m_AwsS3Client.DeleteObject(delObjReq);
                        Logger.WriteLine(m_SynchronizerName + " has deleted an empty-folder on S3 = " + fullKey);
                    }
                }
            }catch (Exception exc) {
                Logger.WriteError(m_SynchronizerName + " can not deleted some empty folders on S3 , but not important !",exc);
            }
        }

        private List<string> GetAllPossibleRelativeParentFolderKeys(List<string> deletionKeyList)
        {
            List<string> allRelativeParentFolderKeys = new List<string>();
            foreach (string key in deletionKeyList) {
                if (key.EndsWith("/") || !key.Contains("/")) continue;
                string parentFolder = Utility.PathCorrectForS3Key(Path.GetDirectoryName(key), true);
                string tempPath = string.Empty;
                foreach (string str in parentFolder.Split('/')) {
                    if( !string.IsNullOrEmpty(str) ) {
                        tempPath = tempPath + str + "/";
                        if (!allRelativeParentFolderKeys.Contains(tempPath)) allRelativeParentFolderKeys.Add(tempPath);
                    }
                }
            }
            return allRelativeParentFolderKeys;
        }


        private void DeleteObjectsFromS3(List<string> s3KeyList, string itemType)
        {
            if (m_Mode != SyncMode.UploadAndDelete || s3KeyList == null || s3KeyList.Count <= 0) return;
            DeleteObjectsRequest multiObjectDeleteRequest = new DeleteObjectsRequest();
            multiObjectDeleteRequest.BucketName = m_BucketName;
            foreach (string key in s3KeyList) multiObjectDeleteRequest.AddKey(key);
            try
            {
                DeleteObjectsResponse response = m_AwsS3Client.DeleteObjects(multiObjectDeleteRequest);
                Logger.WriteLine(response.DeletedObjects.Count + " " + itemType + "s are successfully deleted from S3 !");
                foreach (DeletedObject deletedObject in response.DeletedObjects)
                    Logger.WriteLine("\t -> Deleted-" + itemType + "-Key : " + deletedObject.Key);
            }
            catch (DeleteObjectsException exc) 
            {
                Logger.WriteError("Error occured at CustomS3Client-->DeleteObjectFromS3()", exc);
                DeleteObjectsResponse errorResponse = exc.Response;
                Logger.WriteLine(errorResponse.DeletedObjects.Count + " " + itemType + "s are successfully deleted from S3 !");
                Logger.WriteLine(errorResponse.DeleteErrors.Count + " " + itemType + "s are failed to delete from S3 !");
                foreach (DeletedObject deletedObject in errorResponse.DeletedObjects)
                    Logger.WriteLine("\t -> Deleted-" + itemType + "-Key : " + deletedObject.Key);
                foreach (DeleteError deleteError in errorResponse.DeleteErrors)
                    Logger.WriteLine("\t -> Not-Deleted-" + itemType + "-Key : " + deleteError.Key + "\t" + deleteError.Code + "\t" + deleteError.Message);
            }
            if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
        }

        public void PerformDownloadsToLocal()
        {
            if ( !IsDownload || m_DownloadKeysToLocal == null || m_DownloadKeysToLocal.Count <= 0) return;
            foreach (string key in m_DownloadKeysToLocal) {
                if (key.EndsWith("/")) {
                    string physicalFullPath = Utility.GetPhysicalPathFromS3Key(LocalMountPath, key);
                    DirectoryInfo di = new DirectoryInfo(physicalFullPath);
                    if (!di.Exists) {
                        di.Create();
                        Logger.WriteLine("A directory is created on local-file-system = " + di.FullName);
                    }
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            foreach (string key in m_DownloadKeysToLocal) {
                if ( !string.IsNullOrEmpty(key) && !key.EndsWith("/")) {
                    string physicalFullPath = Utility.GetPhysicalPathFromS3Key(LocalMountPath,key);
                    string realS3Key = Utility.CombinePaths(AwsS3MountPath, key, false);
                    TransferUtilityDownloadRequest request = new TransferUtilityDownloadRequest();
                    request.BucketName = m_BucketName;
                    request.FilePath = physicalFullPath;
                    request.Key = realS3Key;
                    m_AwsTransferUtility.Download(request);
                    Logger.WriteLine("A file is downloaded to local-file-system = " + physicalFullPath);
                    S3Object obj = (S3Object)m_AwsS3Objects[key];
                    File.SetLastWriteTime(physicalFullPath, Utility.ConvertDateTimeFromS3ToLocal(obj.LastModified));
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            Logger.WriteLine("--------------------------------------------------------------");
        }

        public void PerformDeletionsFromLocal()
        {
            if (m_Mode != SyncMode.DownloadAndDelete || m_DeletionKeysFromLocal == null || m_DeletionKeysFromLocal.Count <= 0) return;
            List<string> deletedFileKeys = new List<string>();
            foreach (string key in m_DeletionKeysFromLocal) {
                if (!key.EndsWith("/")) {
                    string physicalFullPath = Utility.GetPhysicalPathFromS3Key(LocalMountPath, key);
                    FileInfo fi = new FileInfo(physicalFullPath);
                    if (fi.Exists) {
                        fi.Delete();
                        Logger.WriteLine("A file is deleted from local-file-system = " + fi.FullName);
                        if (!deletedFileKeys.Contains(key)) deletedFileKeys.Add(key);
                    }
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            if (!string.IsNullOrEmpty(m_FilterExpression)) CheckAndDeleteLocalFoldersIfEmpty(deletedFileKeys);
            foreach (string key in m_DeletionKeysFromLocal) {
                if (key.EndsWith("/")) {
                    string physicalFullPath = Utility.GetPhysicalPathFromS3Key(LocalMountPath, key);
                    DirectoryInfo di = new DirectoryInfo(physicalFullPath);
                    if (di.Exists) {
                        di.Delete(true);
                        Logger.WriteLine("A folder is deleted from local-file-system = " + di.FullName);
                    }
                }
                if (IsPaused) throw new Exception(m_SynchronizerName + " is paused from outside !");
            }
            Logger.WriteLine("--------------------------------------------------------------");
        }

        private void CheckAndDeleteLocalFoldersIfEmpty(List<string> parentFolderKeys)
        {
            if (string.IsNullOrEmpty(m_FilterExpression)) return;
            try {
                List<string> allPossibleFolderKeys = GetAllPossibleRelativeParentFolderKeys(parentFolderKeys);
                if( allPossibleFolderKeys == null || allPossibleFolderKeys.Count <= 0 ) return;
                foreach (string key in allPossibleFolderKeys.OrderByDescending(x => x.Length)) {
                    string fullKey = Utility.GetPhysicalPathFromS3Key(LocalMountPath, key);
                    DirectoryInfo di = new DirectoryInfo(fullKey);
                    if (di.Exists) {
                        FileSystemInfo[] array = di.GetFileSystemInfos();
                        if (array == null || array.Length == 0) {
                            string fullDirName = di.FullName;
                            di.Delete();
                            Logger.WriteLine(m_SynchronizerName + " has deleted an empty-folder on local-file-system = " + fullDirName);
                        }
                    }
                }
            }catch (Exception exc) {
                Logger.WriteError(m_SynchronizerName + " can not deleted some empty folders on local-file-system , but not important !",exc);
            }
        }

        public void ClearAllVariables()
        {
            m_LocalObjects = null;
            m_AwsS3Objects = null;
            m_DeletionKeysFromLocal = null;
            m_DeletionKeysFromS3 = null;
            m_UploadKeysToS3 = null;
            m_DownloadKeysToLocal = null;
        }

    }
}

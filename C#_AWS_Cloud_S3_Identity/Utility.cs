using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Security.Cryptography;
using System.Text;

namespace Digiturk.Cloud.AwsS3Sync
{
    public class Utility
    {
        public static bool IsPathDirectory(string fullPath)
        {
            return Directory.Exists(fullPath) && !File.Exists(fullPath);
        }

        public static bool IsPathFile(string fullPath)
        {
            return File.Exists(fullPath) && !Directory.Exists(fullPath);
        }

        public static string PathCorrectForS3Key(string oldPath, bool isFolder)
        {
            string newPath = oldPath.Replace(@"\", "/");
            if (isFolder && !newPath.EndsWith("/") ) newPath += "/";
            if (newPath.StartsWith("/")) return newPath.Substring(1);
            else return newPath;
        }

        public static string GetRelativePathForS3(string mountPath, string fullPath, bool isFolder)
        {
            string relativePath = fullPath;
            if (!string.IsNullOrEmpty(mountPath) && !string.IsNullOrEmpty(fullPath) && fullPath.StartsWith(mountPath) ) {
                if (fullPath.IndexOf(mountPath) == 0) relativePath = fullPath.Substring(mountPath.Length, fullPath.Length - mountPath.Length);
            }
            return PathCorrectForS3Key(relativePath, isFolder);
        }

        public static string GetPhysicalPathFromS3Key(string mountPath, string s3Key)
        {
            string fullPath = mountPath;
            if (mountPath.Contains(@"\")) fullPath = mountPath.Replace(@"\", "/");
            fullPath = CombinePaths(fullPath, s3Key, s3Key.EndsWith("/"));
            return fullPath.Replace("/", @"\");
        }


        public static string CombinePaths(string mountPath, string s3RelativePath, bool isFolder)
        {
            string fullS3Path = mountPath;
            if (!mountPath.EndsWith("/") && s3RelativePath.StartsWith("/")) fullS3Path += s3RelativePath;
            else if (mountPath.EndsWith("/") && !s3RelativePath.StartsWith("/")) fullS3Path += s3RelativePath;
            else if (mountPath.EndsWith("/") && s3RelativePath.StartsWith("/")) fullS3Path += s3RelativePath.Substring(1);
            else if (!mountPath.EndsWith("/") && !s3RelativePath.StartsWith("/")) fullS3Path += "/" + s3RelativePath;
            fullS3Path = PathCorrectForS3Key(fullS3Path, isFolder);
            return fullS3Path;
        }

        public static DateTime ConvertDateTimeFromS3ToLocal(DateTime s3DateTime)
        {
            return s3DateTime.ToLocalTime();
        }

        public static DateTime ConvertDateTimeFromS3ToLocal(string s3DateTimeStr)
        {
            DateTime s3DateTime = DateTime.ParseExact(s3DateTimeStr, "ddd, dd MMM yyyy HH:mm:ss 'GMT'", CultureInfo.CurrentCulture);
            return s3DateTime.ToLocalTime();
        }

        public static string CalculateMD5Checksum(string fileFullName)
        {
            string localEtag = null;
            byte[] hashValue = null;
            using (var md5 = MD5.Create()) {
                using (var stream = new FileStream(fileFullName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
                    hashValue = md5.ComputeHash(stream);
                }
            }
            if (hashValue != null) localEtag = BitConverter.ToString(hashValue).Replace("-", "").ToLower();
            if (localEtag != null) localEtag = "\"" + localEtag + "\"";
            return localEtag;
        }


        public static bool IsNetworkAvailable()
        {
            return System.Net.NetworkInformation.NetworkInterface.GetIsNetworkAvailable();
        }

        public static string GetFirstLocalIPAddress()
        {
            IPHostEntry host;
            string localIP = "";
            host = Dns.GetHostEntry(Dns.GetHostName());
            foreach (IPAddress ip in host.AddressList) {
                if (ip.AddressFamily == AddressFamily.InterNetwork) {
                    localIP = ip.ToString();
                    break;
                }
            }
            return localIP;
        }

        public static string FillMounthPathIfHasVariable(string mountPath)
        {
            if (string.IsNullOrEmpty(mountPath)) return string.Empty;
            if (!mountPath.Contains("|")) return mountPath;
            string resultPath = mountPath;
            if (resultPath.Contains("|IPADDR|") && IsNetworkAvailable()) {
                string ipAddr = GetFirstLocalIPAddress();
                resultPath = resultPath.Replace("|IPADDR|", ipAddr);
            }
            if (resultPath.Contains("|DATE|")) {
                string strDate = DateTime.Now.ToString("yyyyMMdd",CultureInfo.InvariantCulture);
                resultPath = resultPath.Replace("|DATE|", strDate);
            }
            if (resultPath.Contains("|TIME|")) {
                string strTime = DateTime.Now.ToString("HHmmss",CultureInfo.InvariantCulture);
                resultPath = resultPath.Replace("|TIME|", strTime);
            }
            if (resultPath.Contains("|DATETIME|")) {
                string strDateTime = DateTime.Now.ToString("yyyyMMddHHmmss",CultureInfo.InvariantCulture);
                resultPath = resultPath.Replace("|DATETIME|", strDateTime);
            }
            if (resultPath.Contains("|HOSTNAME|")) {
                string strHostName = Dns.GetHostName();
                resultPath = resultPath.Replace("|HOSTNAME|", strHostName);
            }
            if (resultPath.Contains("|COMPUTER|")) {
                string strFullName = Environment.GetEnvironmentVariable("COMPUTERNAME") + "." + Environment.GetEnvironmentVariable("USERDNSDOMAIN");
                resultPath = resultPath.Replace("|COMPUTER|", strFullName);
            }
            if (resultPath.Contains("|IDENTITY|")) {
                resultPath = resultPath.Replace("|IDENTITY|", Daemon.Instance.CurrentInstanceIdentity);
            }
            if (resultPath.Contains("|INSTANCE|")) {
                resultPath = resultPath.Replace("|INSTANCE|", Daemon.Instance.CurrentInstanceId);
            }
            return resultPath;
        }

    }
}

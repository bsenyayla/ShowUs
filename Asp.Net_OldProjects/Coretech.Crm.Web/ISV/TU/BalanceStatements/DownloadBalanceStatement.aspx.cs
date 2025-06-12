using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using FileStorage.Factory;
using FileStorage.Interface;
using FileStorage.Manager;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.Domain.Company;

namespace Coretech.Crm.Web.ISV.TU.BalanceStatements
{
    public partial class DownloadBalanceStatement : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var Path = GetReportName(QueryHelper.GetGuid("RecordId"));
            FileInfo fileInfo;
            IFileService fmanager = null;
            IFileFactory fileFactory = new FileFactory();
            fmanager = fileFactory.Creator(App.Params.CurrentUser.CompanyId.ToString().ToLower());
            var isTurkey = App.Params.CurrentUser.CompanyId.ToString().ToLower() == Company.TurkeyCompanyId;

            if (!isTurkey)
            {
                //fmanager = new AzureFileManager();

                var fileName = "";
                var ext = "";
                var splitArr = Path.Split('/');

                if (splitArr != null && splitArr.Length > 0)
                {
                    fileName = splitArr[splitArr.Length - 1];
                    var splitExt = fileName.Split('.');

                    if (splitExt != null && splitExt.Length > 0)
                    {
                        ext = "." + splitExt[1];
                        fileName = fileName.Replace(ext, "");
                    }
                }

                var byteArray = fmanager.GetFileStreamByteArray(Path.Replace("/" + fileName, ""), fileName, ext);

                #region //SB OldCodes

                //string localSavePath = System.IO.Path.Combine(Server.MapPath("~"), "Download");

                //if (!Directory.Exists(localSavePath))
                //    Directory.CreateDirectory(localSavePath);

                //var isFileExists = Directory.GetFiles(localSavePath, fileName);
                //if (isFileExists == null)
                //    localSavePath = System.IO.Path.Combine(localSavePath, fileName);
                //else
                //{
                //    localSavePath = System.IO.Path.Combine(localSavePath, fileName.Replace(ext, "") + DateTime.UtcNow.ToString("yyyy_MM_dd_hh_mm") + ext);
                //}
                //fmanager.DownloadFile(Path, localSavePath, fileName);
                //Path = localSavePath;

                #endregion

                Response.Clear();
                Response.ContentType = GetContentType(ext.ToLower());
                Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName + ext);
                Response.BinaryWrite(byteArray);
                Response.End();
            }
            else if (isTurkey && Path.StartsWith("\\"))
            {
                using (var impersonator = new Impersonator())
                {
                    impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                    fileInfo = new FileInfo(Path);

                    if (!fileInfo.Exists)
                    {
                        throw new FileNotFoundException("File to download was not found \n İndirmek İçin Dosya Bulunamadı.", Path);
                    }

                    Response.Clear();
                    Response.Buffer = true;
                    Response.ContentType = "application/octet-stream";
                    Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                    Response.WriteFile(fileInfo.FullName);
                    Response.End();
                }
            }
            else
            {
                fileInfo = new FileInfo(Path);

                if (!fileInfo.Exists)
                {
                    throw new FileNotFoundException("File to download was not found \n İndirmek İçin Dosya Bulunamadı.", Path);
                }

                Response.Clear();
                Response.ContentType = "application/octet-stream";
                Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                Response.WriteFile(fileInfo.FullName);
                Response.End();
            }

            #region System's Old Codes

            //var impersonator = new Impersonator();
            //impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
            //FileInfo fileInfo = new FileInfo(Path);
            //Response.Clear();
            //Response.ContentType = "application/octet-stream";
            //Response.AddHeader("Content-Disposition", "attachment; filename=" + fileInfo.Name);
            //Response.WriteFile(fileInfo.FullName);
            //Response.End();

            #endregion

            QScript("window.close();");

        }

        private string GetReportName(Guid RecordId)
        {
            string filePath = string.Empty;
            try
            {
                var sd = new StaticData();
                sd.AddParameter("RecordId", DbType.Guid, RecordId);
                DataTable dt = sd.ReturnDataset("Select new_FilePath from vNew_BalanceStatementForm(NoLock) Where New_BalanceStatementFormId = @RecordId And DeletionStateCode = 0").Tables[0];

                if (dt.Rows.Count > 0)
                {
                    filePath = ValidationHelper.GetString(dt.Rows[0]["new_FilePath"]);
                }
            }
            catch (Exception)
            {
                filePath = string.Empty;
            }

            return filePath;
        }

        private string GetContentType(string FileExtension)
        {
            Dictionary<string, string> d = new Dictionary<string, string>();
            //Images'
            d.Add(".jpeg", "image/jpeg");
            d.Add(".jpg", "image/jpeg");
            d.Add(".png", "image/png");

            //Documents'
            d.Add(".doc", "application/msword");
            d.Add(".docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document");
            d.Add(".pdf", "application/pdf");

            d.Add(".eps", "application/postscript");
            d.Add(".gif", "image/gif");
            d.Add(".tif", "image/tiff");
            d.Add(".tiff", "image/tiff");
            d.Add(".bmp", "image/bmp");
            d.Add(".raw", "image/RAW");
            d.Add(".pict", "application/octet-stream");
            d.Add(".xps", "application/oxps");

            return d[FileExtension];
        }
    }
}
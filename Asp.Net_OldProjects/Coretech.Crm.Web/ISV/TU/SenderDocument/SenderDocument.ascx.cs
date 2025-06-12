using System;
using System.Web.UI;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using TuFactory.CustAccount.Business;
using TuFactory.CustAccount.Business.Service;
using TuFactory.CustAccount.Object.Common;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Network;
using TuFactory.CustAccount.Object;
using System.IO;
using System.Collections.Generic;
using RefleXFrameWork;
using TuFactory.CourierManager;
using FileStorage.Manager;
using System.Net;
using Coretech.Crm.Factory;
using TuFactory.Domain.Company;
using FileStorage.Interface;
using FileStorage.Factory;

public partial class SenderDocument_SenderDocumentUC : UserControl
{

    protected void Page_Load(object sender, EventArgs e)
    {
        Guid senderDocumentId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
        SenderDocumentService documentService = new SenderDocumentService();
        senderDocumentFile.Value = documentService.GetSenderDocumentFileName(senderDocumentId);
    }
    protected override void OnInit(EventArgs e)
    {
        var p = this.Page as BasePage;
        if (p != null)
        {
            p.AfterSaveHandler += p_AfterSaveHandler;
        }
    }

 
    private void p_AfterSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool IsUpdate)
    {
        try
        {
            if (senderDocumentFile.HasFile)
            {
                if (!CheckContentType(senderDocumentFile.PostedFile.ContentType))
                {
                    throw new Exception("Doküman tipi geçerli değildir.");
                }
                else
                {
                    SenderDocumentService documentService = new SenderDocumentService();
                    var fileName = documentService.GenerateSenderDocumentFileName(recId);
                    SenderDocumentWriterFactory documentFactory = new SenderDocumentWriterFactory(GetFileFormat(senderDocumentFile.PostedFile.ContentType), fileName, recId);
                    //senderDocumentFile.PostedFile.ContentType == "application/pdf" ? SenderDocumentFileFormat.Extension.Pdf : (senderDocumentFile.PostedFile.ContentType == "application/ms-word" ? SenderDocumentFileFormat.Extension.doc : SenderDocumentFileFormat.Extension.docx)
                    var path = documentFactory.CreateDocument(senderDocumentFile.FileBytes);
                    documentService.UpdateSenderDocument(recId, fileName, path, senderDocumentFile.PostedFile.ContentType);
                }
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex);

            var m = new MessageBox { Width = 400, Height = 150 };
            var msg2 = ex.Message;
            m.Show("", msg2);
            return;
        }

        try
        {
            //bahadır 
            TuFactory.CourierManager.CourierFactory fn = new CourierFactory();
            var res = fn.DocumentSenderPlugin_IAfterSave(recId.ToString());
            //fn.public ServiceResponse<String> DocumentSenderPlugin_AfterSave(String vlCourierMasterId)
        }

        catch (Exception ex)
        {

        }
    }


    protected void btnDownload_OnClick(object sender, EventArgs e)
    {
        Guid senderDocumentId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
        SenderDocumentService documentService = new SenderDocumentService();
        string path = documentService.GetDocumentPath(senderDocumentId);

        try
        {
            Response.Buffer = true;
            Response.Clear();
            var isTurkey = App.Params.CurrentUser.CompanyId.ToString().ToLower() == Company.TurkeyCompanyId;
            IFileService fmanager = null;
            IFileFactory fileFactory = new FileFactory();
            fmanager = fileFactory.Creator(App.Params.CurrentUser.CompanyId.ToString().ToLower());

            if (!isTurkey)
            {
                //fmanager = new AzureFileManager();

                var fileName = "";
                var ext = "";
                var splitArr = path.Split('/');

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

                var byteArray = fmanager.GetFileStreamByteArray(path.Replace("/" + fileName + ext, ""), fileName, ext);

                #region //SB Old Codes

                //string localSavePath = Path.Combine(Server.MapPath("~"), "Download");

                //if (!Directory.Exists(localSavePath))
                //    Directory.CreateDirectory(localSavePath);

                //var isFileExists = Directory.GetFiles(localSavePath, fileName);
                //if (isFileExists == null)
                //    localSavePath = Path.Combine(localSavePath, fileName);
                //else
                //{
                //    localSavePath = Path.Combine(localSavePath, fileName.Replace(ext, "") + DateTime.UtcNow.ToString("yyyy_MM_dd_hh_mm") + ext);
                //}
                //fmanager.DownloadFile(path, localSavePath, fileName);
                //path = localSavePath;

                #endregion

                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", fileName + ext));
                Response.ContentType = GetContentType(ext.ToLower());
                Response.BinaryWrite(byteArray);
                Response.End();
            }
            else if (isTurkey && path.StartsWith("\\"))
            {
                SenderDocumentParameters parameters = new SenderDocumentParameters().GetParameter();

                using (var impersonator = new Impersonator())
                {                    
                    impersonator.Impersonate(parameters.ImporterUser, parameters.ImporterDomain, parameters.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                    var fileInfo = new FileInfo(path);

                    if (!fileInfo.Exists)
                    {
                        throw new FileNotFoundException("File to download was not found \n İndirmek İçin Dosya Bulunamadı.", path);
                    }

                    Response.ContentType = GetContentType(fileInfo.Extension.ToLower());
                    Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                    Response.WriteFile(fileInfo.FullName);
                    Response.Flush();
                    Response.End();
                    Response.Close();
                }

                #region System's Old Codes

                //Response.ContentType = GetContentType(fileInfo.Extension.ToLower());
                //Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                //Response.WriteFile(fileInfo.FullName);
                //Response.Flush();
                //Response.End();
                //Response.Close();
                #endregion
            }
            else
            {
                var fileInfo = new FileInfo(path);

                if (!fileInfo.Exists)
                {
                    throw new FileNotFoundException("File to download was not found \n İndirmek İçin Dosya Bulunamadı.", path);
                }

                Response.ContentType = GetContentType(fileInfo.Extension.ToLower());
                Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                Response.WriteFile(fileInfo.FullName);
                Response.Flush();
                Response.End();
                Response.Close();
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex);

            var m = new MessageBox { Width = 400, Height = 150 };
            var msg2 = ex.Message;
            m.Show("", msg2);
            return;
        }
    }

    private bool CheckContentType(string contentType)
    {
        bool result = false;

        switch (contentType)
        {
            case "image/jpeg":
            case "application/pdf":
            case "application/msword":
            case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            case "image/png":
            case "application/postscript":
            case "image/gif":
            case "image/tiff":
            case "image/bmp":
            case "image/x-windows-bmp":
            case "image/RAW":
            case "application/octet-stream":
            case "application/oxps":
            case "text/plain":
                result = true;
                break;
            default:
                result = false;
                break;
        }

        return result;
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
        d.Add(".txt", "text/plain");
           
        return d[FileExtension];
    }

    private SenderDocumentFileFormat.Extension GetFileFormat(string contentType)
    {
        SenderDocumentFileFormat.Extension result = SenderDocumentFileFormat.Extension.Pdf;

        switch (contentType)
        {
            case "image/jpeg":
                result = SenderDocumentFileFormat.Extension.jpg;
                break;
            case "application/pdf":
                result = SenderDocumentFileFormat.Extension.Pdf;
                break;
            case "application/msword":
                result = SenderDocumentFileFormat.Extension.doc;
                break;
            case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
                result = SenderDocumentFileFormat.Extension.docx;
                break;
            case "image/png":
                result = SenderDocumentFileFormat.Extension.png;
                break;
            case "image/gif":
                result = SenderDocumentFileFormat.Extension.gif;
                break;
            case "image/tiff":
                result = SenderDocumentFileFormat.Extension.tiff;
                break;
            case "image/bmp":
                result = SenderDocumentFileFormat.Extension.bmp;
                break;
            case "image/x-windows-bmp":
                result = SenderDocumentFileFormat.Extension.bmp;
                break;

            case "application/postscript":
                result = SenderDocumentFileFormat.Extension.eps;
                break;

            case "image/RAW":
                result = SenderDocumentFileFormat.Extension.raw;
                break;

            case "application/octet-stream":
                result = SenderDocumentFileFormat.Extension.pict;
                break;

            case "application/oxps":
                result = SenderDocumentFileFormat.Extension.xps;
                break;

            case "application/vnd.ms-xpsdocument":
                result = SenderDocumentFileFormat.Extension.xps;
                break;
            case "text/plain":
                result = SenderDocumentFileFormat.Extension.Txt;
                break;
            default:
                break;
        }

        return result;
    }

    protected void btnViewDocument_OnClick(object sender, EventArgs e)
    {
        Guid senderDocumentId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));

        pSenderDocument.LoadUrl(string.Format("/ISV/TU/SenderDocument/SenderDocumentForm.aspx?recid={0}", senderDocumentId));
        wSenderDocument.Show();
    }

}
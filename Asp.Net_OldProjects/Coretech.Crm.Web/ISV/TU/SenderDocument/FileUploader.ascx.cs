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
using TuFactory.Sender;

public partial class SenderDocument_FileUploaderUC : UserControl
{

    protected void Page_Load(object sender, EventArgs e)
    {
        Guid senderDocumentId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
        SenderDocumentService documentService = new SenderDocumentService();
        senderDocumentFile.Value = documentService.GetCorporatedSenderDocumentFileName(senderDocumentId);


        //var senderIdField = (Page.FindControl("new_SenderId_Container") as ComboField);
        //var senderId = senderIdField.Value;

        SenderAfterSaveDb senderAfterSave = new SenderAfterSaveDb();

        //var senderInfo = senderAfterSave.GetSenderCustAccountTypeInfo(ValidationHelper.GetGuid(senderId));

        //var corporatedTypeId = senderInfo.Rows[0]["new_CorporatedTypeId"].ToString();
        string sfdsf = "sdf";
        if (string.IsNullOrEmpty(sfdsf))
        {

            var saveButton = Page.FindControl("btnSave_Container") as ToolbarButton;
            var btnAction = Page.FindControl("btnAction_Container") as ToolbarButton;
            var saveAsCopyButton = Page.FindControl("btnSaveAsCopy_Container") as ToolbarButton;
            var deleteButton = Page.FindControl("btnDelete_Container") as ToolbarButton;
            var btnSaveAndClose = Page.FindControl("btnSaveAndClose_Container") as ToolbarButton;
            var btnSaveAndNew = Page.FindControl("btnSaveAndNew_Container") as ToolbarButton;
            var refreshButton = Page.FindControl("btnRefresh_Container") as ToolbarButton;
            var btnPassive = Page.FindControl("btnPassive_Container") as ToolbarButton;

            refreshButton.SetVisible(false);
            refreshButton.SetDisabled(true);
            btnPassive.SetVisible(false);
            btnPassive.SetDisabled(true);
            saveButton.SetVisible(false);
            saveButton.SetDisabled(true);
            btnAction.SetVisible(false);
            btnAction.SetDisabled(true);
            btnSaveAndNew.SetVisible(false);
            btnSaveAndNew.SetDisabled(true);
            saveAsCopyButton.SetVisible(false);
            saveAsCopyButton.SetDisabled(true);
            deleteButton.SetVisible(false);
            deleteButton.SetDisabled(true);
            btnSaveAndClose.SetDisabled(true);
            btnSaveAndClose.SetVisible(false);
        }
    }
    protected override void OnInit(EventArgs e)
    {
        var p = this.Page as BasePage;
        if (p != null)
        {
            p.beforeSaveHandler += p_BeforeSaveHandler;
            p.AfterSaveHandler += p_AfterSaveHandler;
        }
    }
    private void p_BeforeSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool IsUpdate)
    {
        
    }

    private void p_AfterSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool IsUpdate)
    {
        try
        {
            if (senderDocumentFile.HasFile)
            {
                if (!CheckContentType(senderDocumentFile.PostedFile.ContentType))
                {
                    throw new CrmException("Lütfen geçerli formatta doküman tanımlayın.");
                }
                else
                {
                    SenderDocumentService documentService = new SenderDocumentService();
                    var fileName = documentService.GenerateCorporatedSenderDocumentFileName(recId);
                    CorporatedSenderDocumentWriterFactory documentFactory = new CorporatedSenderDocumentWriterFactory(GetFileFormat(senderDocumentFile.PostedFile.ContentType), fileName, recId);
                    //senderDocumentFile.PostedFile.ContentType == "application/pdf" ? SenderDocumentFileFormat.Extension.Pdf : (senderDocumentFile.PostedFile.ContentType == "application/ms-word" ? SenderDocumentFileFormat.Extension.doc : SenderDocumentFileFormat.Extension.docx)
                    var path = documentFactory.CreateDocument(senderDocumentFile.FileBytes);
                    documentService.UpdateCorporatedSenderDocument(recId, fileName, path, senderDocumentFile.PostedFile.ContentType);
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
    }

    protected void btnDownload_OnClick(object sender, EventArgs e)
    {
        Guid senderDocumentId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
        SenderDocumentService documentService = new SenderDocumentService();
        string path = documentService.GetCorporatedDocumentPath(senderDocumentId);
        try
        {

            Response.Buffer = true;
            Response.Clear();


            //response.AddHeader("Content-Length", fileInfo.Length.ToString());

            if (path.StartsWith("\\"))
            {
                using (var impersonator = new Impersonator())
                {
                    SenderDocumentParameters parameters = new SenderDocumentParameters().GetParameter();
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

            case "application/vnd.ms-xpsdocument":
                result = SenderDocumentFileFormat.Extension.xps;
                break;

            default:
                break;
        }

        return result;
    }
}
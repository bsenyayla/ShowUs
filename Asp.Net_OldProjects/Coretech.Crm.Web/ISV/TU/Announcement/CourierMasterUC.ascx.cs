using System;
using System.Web.UI;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using TuFactory.CustAccount.Object.Common;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Utility.Util;
using System.Collections.Generic;
using RefleXFrameWork;
using TuFactory.Announcement;
using TuFactory.Domain.Api.Models;

public partial class CourierMasterUC : UserControl
{
    Guid recId = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
    FileUpload document;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // var NotificationStatus = (Page.FindControl("new_NotificationStatus_Container") as ComboField);

            if (recId == Guid.Empty)
            {
                btnTakeDownAnnoucement.Visible = false;

                //  NotificationStatus.SetVisible(false);
            }
            else
            {
                btnTakeDownAnnoucement.Visible = true;

                //  NotificationStatus.SetVisible(true);
            }
        }
    }

    protected override void OnInit(EventArgs e)
    {
        var p = this.Page as BasePage;
        if (p != null)
        {

            p.beforeSaveHandler += p_BeforeSaveHandler;
        }
    }

    private void p_BeforeSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool IsUpdate)
    {
        document = Page.FindControl("new_Document_Container") as FileUpload;
        try
        {
            if (document.HasFile)
            {
                if (!CheckContentType(document.PostedFile.ContentType))
                {
                    throw new CrmException("Lütfen geçerli formatta doküman tanımlayın.");
                }
            }
        }
        catch (Exception ex)
        {

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

            case "application/oxps":
                result = SenderDocumentFileFormat.Extension.xps;
                break;

            case "application/vnd.ms-xpsdocument":
                result = SenderDocumentFileFormat.Extension.xps;
                break;

            default:
                break;
        }

        return result;
    }


    //Kurye Adres Güncelle
    protected void TakeDownAnnoucement(object sender, AjaxEventArgs e)
    {
        var m = new MessageBox { Width = 500, Height = 250 };
        try
        {
            TuFactory.CourierManager.CourierFactory fn = new TuFactory.CourierManager.CourierFactory();
            ServiceResponse<String> rec = fn.CourierAdressUpdatePlugin_ButtonClick(recId.ToString());
            MessageBox msg = new MessageBox();
            if (rec.Code == 1)
            {
                m.Show("Success", "KuryeNet e yeni adres bilgisi gönderildi.");
            }
            else {
                m.Show("", "Hata:" + rec.Message);
            }
        }
        catch (Exception ex)
        {
        }

    }

    protected void CourierCancel(object sender, AjaxEventArgs e)
    {
        var m = new MessageBox { Width = 500, Height = 250 };
        try
        {
            TuFactory.CourierManager.CourierFactory fn = new TuFactory.CourierManager.CourierFactory();
            ServiceResponse<String> rec = fn.CourierCancel(recId.ToString());

            MessageBox msg = new MessageBox();
            if (rec.Code == 1)
            {
                m.Show("Success", "Kurye iptal talebi gönderildi.");
            }
            else
            {
                m.Show("", "Hata:" + rec.Message);
            }
        }
        catch (Exception ex)
        {

        }

    }
}

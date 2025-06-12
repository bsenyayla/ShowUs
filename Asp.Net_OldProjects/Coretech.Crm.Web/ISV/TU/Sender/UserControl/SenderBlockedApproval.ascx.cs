using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Web.UI;
using TuFactory.Object;
using TuFactory.Sender;
using TuFactory.Sender.CorporateAccountSender;
using TuFactory.Sender.CorporateAccountSender.Model;
using TuFactory.SenderBlocked;
using static TuFactory.Fraud.FraudScanFactory;

public partial class Sender_UserControl_SenderBlockedApproval : UserControl
{
    Guid recId = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
    private DynamicSecurity DynamicSecurity;

    protected override void OnInit(EventArgs e)
    {
        try
        {
            DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_CorporatedBlockedApproval.GetHashCode(), null);

            string sourceFormType = ValidationHelper.GetString(QueryHelper.GetString("SourceFormType"));
            var statusField = Page.FindControl("new_Status_Container") as ComboField;
            string status = statusField.Value.ToString();

            if (sourceFormType == "ApprovalList")
            {
                BtnAccept.Visible = true;
                BtnReject.Visible = true;
            }
            else
            {
                BtnAccept.Visible = false;
                BtnReject.Visible = false;
            }


            //durum onay bekliyor değilse.butonları gizle
            if (status != "1")
            {
                BtnAccept.Visible = false;
                BtnReject.Visible = false;
            }

            //yetkisi yoksa butonları her şartta gizle
            if (!DynamicSecurity.PrvAppend)
            {
                BtnAccept.Visible = false;
                BtnReject.Visible = false;
            }


            base.OnInit(e);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Sender_UserControl_SenderBlockedApproval.OnInit", "Exception");
            throw ex;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {

        try
        {
            if (!RefleX.IsAjxPostback)
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


                string islem = QueryHelper.GetString("islem");
                if (islem == "islemOnayTamam")
                {
                    ScriptManager.RegisterClientScriptBlock(this, typeof(Page), "Script", "alert('İlgili işlem onaylandı.');window.top.R.WindowMng.getActiveWindow().hide();", true);
                }
                else if (islem == "islemRedTamam")
                {
                    ScriptManager.RegisterClientScriptBlock(this, typeof(Page), "Script", "alert('İlgili işlem reddedildi.');window.top.R.WindowMng.getActiveWindow().hide();", true);
                }
            }
            
       }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Sender_UserControl_SenderBlockedApproval.Page_Load", "Exception");
        }


    }

    protected void Confirm(object sender, AjaxEventArgs e)
    {


        try
        {
            var customerType = Page.FindControl("new_CustomerType_Container") as ComboField;
            var transactionType =  Page.FindControl("new_TransactionType_Container") as ComboField;

            int corporateTypeId = Convert.ToInt32( customerType.Value);
            int transactionTypeVal = Convert.ToInt32(transactionType.Value);
            Guid systemUserId = App.Params.CurrentUser.SystemUserId;
            int confirmStatus = 2;


            SenderBlockedFactory set = new SenderBlockedFactory();
            set.Confirm(recId, corporateTypeId, transactionTypeVal, confirmStatus, systemUserId);

           Guid refId = ValidationHelper.GetGuid( QueryHelper.GetString("recId"));

            BtnAccept.SetVisible(false);
            BtnReject.SetVisible(false);

            //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            //ms.Show(".", "İlgili işlem onaylandı.");

            string defaulteditpageid = "1433D224-D027-EA11-A76F-A01D480B4D85";
            string config = "/CrmPages/AutoPages/EditReflex.aspx?ObjectId=201900037&recId=" + refId + "&defaulteditpageid=" + defaulteditpageid + "&SourceFormType=ApprovalList&islem=islemOnayTamam";
            Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);

            //BasePage.QScript("window.top.R.WindowMng.getActiveWindow().hide();");

            //ScriptManager.RegisterClientScriptBlock(this, typeof(Page), "Script", "alert('22');window.top.R.WindowMng.getActiveWindow().hide();", true);

        }
        catch (Exception ex)
        {
            BtnAccept.Visible = true;
            BtnReject.Visible = true;

            var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Hata!! İşlem Yapılamadı");

            LogUtil.WriteException(ex, "Sender_UserControl_SenderBlockedApproval.Confirm", "Exception");
        }

    }

    protected void Reject(object sender, AjaxEventArgs e)
    {
        try
        {
            var customerType = Page.FindControl("new_CustomerType_Container") as ComboField;
            var transactionType = Page.FindControl("new_TransactionType_Container") as ComboField;

            int corporateTypeId = Convert.ToInt32(customerType.Value);
            int transactionTypeVal = Convert.ToInt32(transactionType.Value);
            Guid systemUserId = App.Params.CurrentUser.SystemUserId;
            int confirmStatus = 3;


            SenderBlockedFactory set = new SenderBlockedFactory();
            set.Confirm(recId, corporateTypeId, transactionTypeVal, confirmStatus, systemUserId);

            BtnAccept.Visible = false;
            BtnReject.Visible = false;

            //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            //ms.Show(".", "İlgili işlem reddedildi.");

            Guid refId = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
            string defaulteditpageid = "1433D224-D027-EA11-A76F-A01D480B4D85";
            string config = "/CrmPages/AutoPages/EditReflex.aspx?ObjectId=201900037&recId=" + refId + "&defaulteditpageid=" + defaulteditpageid + "&SourceFormType=ApprovalList&islem=islemRedTamam";
            Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
        }
        catch (Exception ex)
        {
            BtnAccept.Visible = true;
            BtnReject.Visible = true;

            var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", "Hata!! İşlem Yapılamadı");
            LogUtil.WriteException(ex, "Sender_UserControl_SenderBlockedApproval.Reject", "Exception");
        }
    }

    
}

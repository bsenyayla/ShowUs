using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using RefleXFrameWork;
using System;
using System.Web.UI;
using TuFactory.Object;

public partial class Sender_UserControl_SenderBlocked : UserControl
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
            

            base.OnInit(e);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Sender_UserControl_SenderBlocked.OnInit", "Exception");
            throw ex;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {

        try
        {
            //Guid recId = Guid.Empty;
            //var recIdField = Page.FindControl("hdnRecid_Container") as TextField;

            //if (recIdField != null)
            //     recId = ValidationHelper.GetGuid(recIdField.Value.ToString());


            if (!RefleX.IsAjxPostback)
            {
                if (recId != Guid.Empty)
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

                    //BasePage.QScript("window.top.R.WindowMng.getActiveWindow().hide();");
                }
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Sender_UserControl_SenderBlocked.Page_Load", "Exception");
            throw ex;
        }


    }
    

    
}

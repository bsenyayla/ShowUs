using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;
using System.Web.UI;

public partial class Sender_UserControl_SenderServiceInfoControl : UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

        if (!RefleX.IsAjxPostback)
        {
            var IsComeFromService = Page.FindControl("new_IsComeFromService_Container") as CheckField;

            if (ValidationHelper.GetBoolean(IsComeFromService.Value))
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
    }
}

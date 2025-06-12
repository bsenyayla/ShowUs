using System;
using System.Web.UI;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using RefleXFrameWork;
using Coretech.Crm.Utility.Util;

public partial class Office_UserControl_CorporationDefaultEditForm : UserControl
{
 
    protected void Page_Load(object sender, EventArgs e)
    {
        chc_BeforeWsbiMemberChange(sender, null);
    }
    protected override void OnInit(EventArgs e)
    {
        /*
        var p = this.Page as BasePage;

        if (p != null)
        {
            p.AfterSaveHandler += p_AfterSaveHandler;

        }
        */

        try
        {

            var btnPassive = Page.FindControl("btnPassive_Container") as ToolbarButton;
            var btnActive = Page.FindControl("btnActive_Container") as ToolbarButton;
            var btnDelete = Page.FindControl("btnDelete_Container") as ToolbarButton;
            var chcIsWsbiMember = Page.FindControl("new_IsWsbiMember_Container") as CheckField;

            if (btnActive != null)
                btnActive.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(btn_BeforActiveClick);

            if (btnPassive != null)
                btnPassive.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(btn_BeforePassiveClick);

            if (btnDelete != null)
                btnDelete.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(btn_BeforeDeleteClick);

            if (chcIsWsbiMember != null)
                chcIsWsbiMember.AjaxEvents.Change.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(chc_BeforeWsbiMemberChange);

            

        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Office_UserControl_CorporationDefaultEditForm.OnInit", "Exception");
        }

    }
    private void p_AfterSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool IsUpdate)
    {
    }

    void chc_BeforeWsbiMemberChange(object sender, RefleXFrameWork.AjaxEventArgs e)
    {
        var chcWsbiMember = Page.FindControl("new_IsWsbiMember_Container") as CheckField;
        var chcWsbiUptPoolUsageStatus = Page.FindControl("new_WsbiUptPoolUsageStatus_Container") as ComboField;

        bool wsbiMemberValue = false;
        if (chcWsbiMember != null)
            wsbiMemberValue = ValidationHelper.GetBoolean(chcWsbiMember.Value);

        if (chcWsbiUptPoolUsageStatus != null)
        {
            if (wsbiMemberValue)
            {
                chcWsbiUptPoolUsageStatus.SetVisible(true);
            }
            else
            {
                chcWsbiUptPoolUsageStatus.SetVisible(false);
            }
        }
    }

    void btn_BeforePassiveClick(object sender, RefleXFrameWork.AjaxEventArgs e)
    {
        Guid recId = Guid.Empty;
        var hdnRecId = Page.FindControl("hdnRecid_Container") as Hidden;
        if (hdnRecId != null )
         recId = ValidationHelper.GetGuid (hdnRecId.Value);
        
        var btnPassive = Page.FindControl("btnPassive_Container") as ToolbarButton;

        if (btnPassive != null)
        {
            var corporatioAfterSaveDb = new TuFactory.Corporation.CorporationFactory();
            corporatioAfterSaveDb.CorporationUserPassive(recId, true);
        }
    }

    void btn_BeforActiveClick(object sender, RefleXFrameWork.AjaxEventArgs e)
    {
        Guid recId = Guid.Empty;
        var hdnRecId = Page.FindControl("hdnRecid_Container") as Hidden;
        if (hdnRecId != null)
            recId = ValidationHelper.GetGuid(hdnRecId.Value);

        
        var btnActive = Page.FindControl("btnActive_Container") as ToolbarButton;

        if (btnActive != null )
        {
            var corporatioAfterSaveDb = new TuFactory.Corporation.CorporationFactory();
            corporatioAfterSaveDb.CorporationUserPassive(recId, false);
        }
    }

    void btn_BeforeDeleteClick(object sender, RefleXFrameWork.AjaxEventArgs e)
    {
        Guid recId = Guid.Empty;
        var hdnRecId = Page.FindControl("hdnRecid_Container") as Hidden;
        if (hdnRecId != null)
            recId = ValidationHelper.GetGuid(hdnRecId.Value);


        var btnActive = Page.FindControl("btnDelete_Container") as ToolbarButton;

        if (btnActive != null)
        {
            var corporatioAfterSaveDb = new TuFactory.Corporation.CorporationFactory();
            corporatioAfterSaveDb.CorporationUserDelete(recId);
        }
    }

}

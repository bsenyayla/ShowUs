using ApiFactory.SystemUserManager;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Data;
using System.Data.Common;
using TuFactory.Sender;
using TuFactory.SenderPerson;

public partial class Sender_SenderPersonApprovalList : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            CreateViewGrid();
        }
    }

    protected override void OnInit(EventArgs e)
    {
        CreateViewGrid();
        base.OnInit(e);
    }
    public void CreateViewGrid()
    {
        SenderPersonFactory senderPersonFactory = new SenderPersonFactory();

        var t = senderPersonFactory.GetSenderPersonPendingApprovalSelectSql(new_E_Mail.Value, new_SenderIdendificationNumber1.Value
            , ValidationHelper.GetGuid(new_SenderId.Value));

        GpSenderPersonApprovalList.DataSource = t;
        GpSenderPersonApprovalList.DataBind();
    }

    protected void GpSenderPersonApprovalListReload(object sender, AjaxEventArgs e)
    {
        CreateViewGrid();
    }

    protected void RowDblClickOnEvent(object sender, AjaxEventArgs e)
    {

        var senderpersonId = ValidationHelper.GetGuid(hdnSenderPersonApproveID.Value);
        var actionType = ValidationHelper.GetString(hdnActionType.Value);

        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/SenderPersonAccount/SenderPersonApproval.aspx?senderpersonApproveId=" + senderpersonId + "&actionType="+actionType+"', {title: 'Gönderici Yetkilisi Onay İşlemleri', maximized: false, width: 1200, height: 600, resizable: true, modal: false, maximizable: true });");
    }
}



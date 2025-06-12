using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Fraud;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class Detail_Detail_ReadOnly : BasePage
{
    //CRM.NEW_FRAUDLOG_BTN__REJECT
    //
    //
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private DynamicSecurity DynamicSecurity;
    FraudFactory ff = new FraudFactory();
    private void TranslateMessages()
    {

        ToolbarButtonMd.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL");
    }
   
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_FraudLog.GetHashCode(), null);


        if (!RefleX.IsAjxPostback)
        {


            TranslateMessages();

            hdnRecId.Value = QueryHelper.GetString("recid");

            hdnEntityId.Value = App.Params.CurrentEntity[TuEntityEnum.New_FraudLog.GetHashCode()].EntityId.ToString();
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", ""},
                                {"ObjectId", TuEntityEnum.New_FraudLog.GetHashCode().ToString()},
                                {"recid", hdnRecId.Value}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            PanelIframe.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            hiddenUrl.Value = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
 
        }

    }

     
}
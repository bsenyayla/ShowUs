using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.TuUser;
using TuFactory.Integration3rd;
using Coretech.Crm.PluginData;
using System.Data.Common;
using TuFactory.Data;

public partial class Operation_Detail_Refund : BasePage
{
    //CRM.NEW_TRANSACTIONCONFIRM_REJECT
    //
    //
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    MessageBox ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private void TranslateMessages()
    {
        ToolbarButtonRefund.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REFUND");


    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        //_activeUser = ufFactory.GetActiveUser();

        if (!RefleX.IsAjxPostback)
        {

            TranslateMessages();
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnRecId.Value = QueryHelper.GetString("recid");
            var readonlyform = string.Empty;
            switch (ValidationHelper.GetInteger(hdnObjectId.Value))
            {
                case (int)TuEntityEnum.New_Transfer:
                    readonlyform =
                        ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));
                    break;
            }
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecId.Value}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            PanelIframe.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);

        }

    }

    protected void Refund(object sender, AjaxEventArgs e)
    {
        var cf = new ConfirmFactory();
        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value));
        if (ts != TuConfirmStatus.OdemeOnayli && ts != TuConfirmStatus.GonderimOnayRedEdildiParaIadesiBekleniyor)
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
            return;
        }
        try
        {
            if (ts == TuConfirmStatus.GonderimOnayRedEdildiParaIadesiBekleniyor)
            {
                ConfirmDb cdb = new ConfirmDb();
                
                try
                {
                    cf.ConfirmRefund(ValidationHelper.GetGuid(hdnRecId.Value), ValidationHelper.GetInteger(hdnObjectId.Value, 0));
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
        }
        catch (TuException ex)
        {
            ms.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception ex)
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return;
        }
        QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REFUNDED") + "');");
        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }

}
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
using Coretech.Crm.PluginData;
using System.Data;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using System.Data.Common;
using TuFactory.Data;
using UPT.Shared.Service.User.Service;


public partial class Operation_Detail_IntegrationRefund : BasePage
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
        ToolbarButtonRefundCancel.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REFUND_CANCEL");
        //lblOperationDescription.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REFUND_INTEGRATION_DESC");

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
                    DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
                    DynamicEntity de = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(QueryHelper.GetString("recid")), new string[] { "new_IntegrationChannel" });
                    //ToolbarButtonRefundCancel.Visible = de.GetLookupValue("new_IntegrationChannel") == Guid.Empty;
                    readonlyform =
                        ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));
                    break;
            }

            //Kullanıcı, kendi ofisine ait kayıtların iptal/iade/düzeltme işlemlerini yapabilir.
            if (_userApproval.OfficeCancelReturnEditPermit)
            {
                TransferDb transferService = new TransferDb();
                UserService userService = new UserService();
                Guid transferOfficeID = transferService.GetTransferOfficeID(ValidationHelper.GetGuid(hdnRecId.Value));
                Guid userOfficeID = userService.GetOfficeID(App.Params.CurrentUser.SystemUserId, null);

                //Kullanıcı ofisi, transferin ofisi ile aynı değilse işlem devam etmez.
                if (userOfficeID != transferOfficeID)
                {
                    ToolbarButtonRefund.Visible = false;
                    ToolbarButtonRefundCancel.Visible = false;
                }
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
        if (ts != TuConfirmStatus.GonderimIslemiKurumdanIadesiIsteniyor)
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
            return;
        }

        try
        {
            cf.ConfirmIntegrationRefund(ValidationHelper.GetGuid(hdnRecId.Value));

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

        var query = new Dictionary<string, string>
                            {
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecId.Value},
                            };

        string urlparam = QueryHelper.RefreshUrl(query);
        Response.Redirect(Page.ResolveClientUrl("~/ISV/TU/Refund/RefundTransfer/_RefundTransferRequest.aspx" + urlparam));
    }


    protected void NotRefund(object sender, AjaxEventArgs e)
    {
        Guid transferId = ValidationHelper.GetGuid(hdnRecId.Value);
        string sql = "spTUAutomatedRefundCancel";
        var sd = new StaticData();
        DbTransaction tran = sd.GetDbTransaction();
        try
        {
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            sd.AddParameter("TransferId", DbType.Guid, transferId);
            sd.ExecuteNonQuerySp(sql, tran);
            StaticData.Commit(tran);
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_AUTOMATED_REFUND_CANCEL") + "');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
        catch (Exception ex)
        {
            StaticData.Rollback(tran);
            QScript("alert('" + ex.Message + "');");
        }
    }
}
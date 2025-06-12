using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.Reports;
using TuFactory.TuUser;

public partial class Operation_Detail_Transfer3rdErrorContinue : BasePage
{
    private readonly ConfirmFactory cf = new ConfirmFactory();
    private readonly MessageBox ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUserApproval _userApproval = null;

    private void TranslateMessages()
    {
        ToolbarButtonSend.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDTOCONFIRM");
        ToolbarButtonLog.Text = CrmLabel.TranslateMessage("CRM.MENU.LOG");
        hdnOnayMessage.Value = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRMED");
        ToolbarButtonMd.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL");
        ToolbarButtonTalimat.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_TALIMAT_FORMU");
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        var dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_TransferEdit.GetHashCode(), null);

        if (!RefleX.IsAjxPostback)
        {
            TranslateMessages();
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdndoReceipt.Value = QueryHelper.GetString("doReceipt");
            hdndoReceiptEdit.Value = QueryHelper.GetString("doReceiptEdit");
            hdnpoolId.Value = QueryHelper.GetString("PoolId");

            var poolId = QueryHelper.GetInteger("PoolId", 0);
            var readonlyform = string.Empty;
            switch (ValidationHelper.GetInteger(hdnObjectId.Value))
            {
                case (int)TuEntityEnum.New_Transfer:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));
                    hdnEntityId.Value = App.Params.CurrentEntity[TuEntityEnum.New_Transfer.GetHashCode()].EntityId.ToString();
                    break;
            }
            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform},
                                {"ObjectId", hdnObjectId.Value},
                                {"recid", hdnRecid.Value}
                            };
            string urlparam = QueryHelper.RefreshUrl(query);
            PanelIframe.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);

            string transactionType;
            var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
             ValidationHelper.GetGuid(hdnRecid.Value), null, out transactionType);

            hdnReportId.Value = ValidationHelper.GetString(TuReports.GetReportId(TuReportTypeEnum.TalepFormu,
                                                          TuEntityEnum.New_Transfer,
                                                          ValidationHelper.GetGuid(hdnRecid.Value)));

        }
    }

    protected void ToolbarButtonSendOnEvent(object sender, AjaxEventArgs e)
    {
        var confirmFactory = new ConfirmFactory();
        var ts = confirmFactory.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                            ValidationHelper.GetGuid(hdnRecid.Value));
        switch (ts)
        {

            case TuConfirmStatus.GonderimYeniKayitHataAldiBekliyor:

                break;

            default:
                ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                return;
        }


        try
        {

            switch (ts)
            {
                case TuConfirmStatus.GonderimYeniKayitHataAldiBekliyor:
                    var cf = new ConfirmFactory();
                    var df = new DynamicFactory(ERunInUser.CalingUser);
                    var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnRecid.Value), DynamicFactory.RetrieveAllColumns);
                    var config = new Coretech.Crm.Objects.Crm.Plugin.PluginBaseConfig { ActivePage = Page, DynamicEntity = de };
                    cf.CreateConfirmLine(config);
                    break;
            }
        }
        catch (TuException ex)
        {
            ex.Show();
            //ms.Show(".", ex.ErrorMessage);
            return;
        }
        catch (Exception)
        {
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return;
        }


        //QScript("ShowClientSideWindow();");
        //QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
    }


}
using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Data;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.TransactionManagers.Cancel;
using TuFactory.TransactionManagers.Cancel.Domains;
using TuFactory.TransactionManagers.Cancel.Result;
using TuFactory.TuUser;
using Coretech.Crm.PluginData;
using System.Data;
using Integration3rd.NKolay;
using Integration3rd.NKolay.Domain;

public partial class Operation_Detail_Cancel : BasePage
{
    //CRM.NEW_TRANSACTIONCONFIRM_REJECT
    //
    //
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private void TranslateMessages()
    {
        ToolbarButtonConfirm.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_CONFIRM");
        ToolbarButtonReject.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_REJECT");
        ToolbarButtonReject1.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_REJECT");
        windowReject.Title = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_REJECT");
    }
    private void ReConfigureButtons()
    {
        if (!_userApproval.ApprovalConfirm)
            ToolbarButtonConfirm.Visible = false;

        if (!_userApproval.ApprovalReject)
            ToolbarButtonReject.Visible = false;
    }
    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessages();
        }
        base.OnPreInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        //_activeUser = ufFactory.GetActiveUser();i
        if (new_ConfirmReasonId.DataContainer.DataSource.Columns.Count > 0)
        {
            new_ConfirmReasonId.DataContainer.DataSource.Columns[0].Title = "Red Sebebi";
        }

        if (!RefleX.IsAjxPostback)
        {

            ReConfigureButtons();

            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnRecId.Value = QueryHelper.GetString("recid");
            var readonlyform = string.Empty;
            switch (ValidationHelper.GetInteger(hdnObjectId.Value))
            {
                case (int)TuEntityEnum.New_Transfer:

                    StaticData data2 = new StaticData();
                    data2.AddParameter("TransferId", DbType.Guid, ValidationHelper.GetGuid(hdnRecId.Value));
                    DataTable dt2 = data2.ReturnDataset(@"SELECT cf.new_Code StatusCode
                                                   FROM vNew_Transfer T (NoLock) 
                                                    left outer join vNew_ConfirmStatus cf on cf.New_ConfirmStatusId = T.new_ConfirmStatus
                                                WHERE T.New_TransferId = @TransferId ").Tables[0];


                    string statusCode = dt2.Rows[0]["StatusCode"].ToString();

                    if (statusCode == TuConfirmStatus.GonderimIptalOnayBekliyor)
                        readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE_CANCEL"));
                    else
                        readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("TRANSFER_READONLY_PAGE"));

                    break;
                case (int)TuEntityEnum.New_Payment:
                    readonlyform = ValidationHelper.GetString(ParameterFactory.GetParameterValue("PAYMENT_READONLY_PAGE"));

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
    private TuConfirmList GetConfirmList()
    {
        return new TuConfirmList()
        {
            ConfirmReasonId = ValidationHelper.GetGuid(new_ConfirmReasonId.Value),
            Description = new_ConfirmReasonDescription.Value,
            ObjectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0),
            RecId = ValidationHelper.GetGuid(hdnRecId.Value),
            ActivePage = Page
        };
    }
    private bool SetConfirm_old(List<TuConfirmList> cl)
    {
        var cf = new ConfirmFactory();

        List<TuConfirmList> new_ConfirmList = new List<TuConfirmList>();
        bool hasOutFile = false;
        foreach (var confirmList in cl)
        {
            if (confirmList.ObjectId == (int)TuEntityEnum.New_Transfer && confirmList.Approval == ETuUserApproval.Confirm)
            {
                var trs = cf.GetTransactionStatus(confirmList.ObjectId, confirmList.RecId);
                if (trs == TuConfirmStatus.GonderimIptalOnayBekliyor)
                {
                    ConfirmDb cdb = new ConfirmDb();
                    var isOut = cdb.GetTransferIsCancelFileOut(confirmList.RecId);
                    if (!isOut)
                    {
                        new_ConfirmList.Add(confirmList);
                    }
                    else
                    {
                        if (_userApproval.RunAsManuel)
                        {
                            new_ConfirmList.Add(confirmList);
                        }
                        else
                        {
                            hasOutFile = true;
                        }
                    }
                }
            }
            else //Odeme iptallerinde hata aliyorduk, eskisi gibi calismasi icin bunu ekledim.
            {
                new_ConfirmList.Add(confirmList);
            }
        }
        if (hasOutFile)
        {
            //_msg.Height = 100;
            //_msg.Show("Onaylamaya çalıştığınız kayıtların içinde iptal dosyası kuruma gönderilmiş kayıt var, bu kayıtları onaylama yetkiniz yok.");
            //_msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
        }

        var ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecId.Value));
        switch (ts)
        {
            case TuConfirmStatus.GonderimIptalOnayBekliyor:
            case TuConfirmStatus.GonderimIptalAltOnayBekliyor:

            case TuConfirmStatus.OdemeIptalOnayBekliyor:
            case TuConfirmStatus.OdemeIptalAltOnayBekliyor:

            case TuConfirmStatus.IadeOdemeIptalOnayBekliyor:
            case TuConfirmStatus.IadeOdemeIptalAltOnayBekliyor:

                break;
            default:
                _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                return false;
        }
        try
        {
            if (new_ConfirmList.Count > 0)
            {
                cf.Confirm(new_ConfirmList);
                cf.AfterConfirm(new_ConfirmList, ETuConfirmType.TransactionCancel);
            }
            else
            {
                _msg.Show(".", ".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOU_HAVENOT_CANCELFILECONFIRMAUTHORY"));
                return false;
            }

        }
        catch (TuException ex)
        {
            _msg.Show(".", ".", ex.ErrorMessage);
            return false;
        }
        catch (Exception ex)
        {

            _msg.Show(".", ".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return false;
        }
        return true;
    }

    private bool SetConfirm(TuConfirmList confirm)
    {
        var cf = new ConfirmFactory();

        TransactionDto transferDto = new TransactionDto(confirm, ExecutionChannel.WEBUI, OperationType.Confirm);
        var transactionCancelManager = new TransactionCancelManager<bool, bool, bool>(transferDto);

        if (confirm.ObjectId == (int)TuEntityEnum.New_Transfer && confirm.Approval == ETuUserApproval.Confirm)
        {

            string confirmStatus = cf.GetTransactionStatus(TuEntityEnum.New_Transfer.GetHashCode(), confirm.RecId);

            if (confirmStatus == TuConfirmStatus.GonderimIptalOnayBekliyor) //nkolay gönderim iptal süreci
            {
                var sd2 = new StaticData();
                DataTable dt = new DataTable();
                sd2.AddParameter("TransferId", DbType.Guid, ValidationHelper.GetGuid(confirm.RecId));
                dt = sd2.ReturnDataset("Select new_CorporationId, TransferTuRef,  new_confirmstatusname, ISNULL(new_Channel,0) Channel from vNew_Transfer(NoLock) Where New_TransferId = @TransferId ").Tables[0];

                if (dt.Rows.Count > 0)
                {
                    var corporationId = ValidationHelper.GetGuid(dt.Rows[0]["new_CorporationId"]);
                    var transferTuref = ValidationHelper.GetString(dt.Rows[0]["TransferTuRef"]);

                    var NKolayCorporationId = ValidationHelper.GetGuid(App.Params.GetConfigKeyValue("TK_NKOLAY_ID"));
                    if (NKolayCorporationId == corporationId)
                    {
                        string retData = string.Empty;
                        ServiceManager serviceManagerNKolay = new ServiceManager();
                        var result = serviceManagerNKolay.UpdateTransferStatus(ValidationHelper.GetGuid(confirm.RecId), transferTuref, State.Iptal, 0, string.Empty, true, out retData);
                    }
                }
            }


            if (transferDto.TransactionStatus == TuConfirmStatus.GonderimIptalOnayBekliyor)
            {
                ConfirmDb cdb = new ConfirmDb();
                var isOut = cdb.GetTransferIsCancelFileOut(transferDto.TransactionId);
                if (isOut || _userApproval.RunAsManuel == false)
                {
                    _msg.Show(".", ".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOU_HAVENOT_CANCELFILECONFIRMAUTHORY"));
                    return false;
                }
            }
        }

        try
        {
            Either<bool, List<Error>> confirmResult = transactionCancelManager.Confirm();
            EvaluateResult(confirmResult.GetError());
            if (confirmResult.GetError().Count > 0)
            {
                return false;
            }

        }
        catch (TuException ex)
        {
            _msg.Show(".", ".", ex.ErrorMessage);
            return false;
        }
        catch (Exception ex)
        {
            _msg.Show(".", ".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            return false;
        }
        return true;
    }

    private void EvaluateResult(List<Error> list)
    {
        if (list != null)
        {
            foreach (var item in list)
            {
                switch (item.ErrorType)
                {
                    case ErrorType.Script:
                        QScript(item.ErrorMessage);
                        break;
                    case ErrorType.String:
                    case ErrorType.TuException:
                        var message = item.TuException == null ? item.ErrorMessage : item.TuException.ErrorMessage;
                        _msg.Show(".", message);
                        break;
                    default:
                        break;
                }
            }
        }
    }

    protected void Confirm(object sender, AjaxEventArgs e)
    {

        var cl = new List<TuConfirmList>();
        var clitem = GetConfirmList();
        clitem.Approval = ETuUserApproval.Confirm;
        cl.Add(clitem);
        //var ret = SetConfirm(cl);
        var ret = SetConfirm(clitem);
        if (ret)
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_CONFIRMED") + "');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }

    }

    protected void Reject(object sender, AjaxEventArgs e)
    {
        var cl = new List<TuConfirmList>();
        var clitem = GetConfirmList();
        clitem.Approval = ETuUserApproval.Reject;
        cl.Add(clitem);
        var ret = SetConfirm_old(cl);
        if (ret)
        {
            QScript("alert('" + CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CANCEL_REJECTED") + "');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
    }
}
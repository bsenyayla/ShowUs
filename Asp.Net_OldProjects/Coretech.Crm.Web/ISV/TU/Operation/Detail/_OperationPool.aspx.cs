using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.TuUser;
using TuFactory.Refund;
using TuFactory.Data;
using System.Linq;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using TuFactory.TransactionManagers.Cancel.Result;
using TuFactory.TransactionManagers.Cancel.Domains;
using TuFactory.TransactionManagers.Cancel;

public partial class Operation_Detail_OperationPool : BasePage
{
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    private MessageBox messageBox = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 160 };

    private void TranslateMessage()
    {
        btnConfirm.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRM");
        pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_SEARCH");
        btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);

        var all = CrmLabel.TranslateMessage("CRM.ENTITY_ALL");
        new_CorporationId.EmptyText = all;
        new_OfficeId.EmptyText = all;
        new_FormConfirmStatusId.EmptyText = all;
        new_OperationType.EmptyText = all;
        new_RecipientFullName.EmptyText = all;
        new_SenderId.EmptyText = all;
        new_FormSourceTransactionTypeID.EmptyText = all;
        new_PayingCorporationId.EmptyText = all;
        new_RecipientCorporationId.EmptyText = all;
        new_PayingOfficeId.EmptyText = all;


    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();

        //if (!_userApproval.ApprovalConfirm)
        //    btnConfirm.visible = false;
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
            CreateViewGrid();
            FillLogInfo();
            new_CorporationId.Value = _activeUser.CorporationId.ToString();
            new_OfficeId.Value = _activeUser.OfficeId.ToString();
            if (new_FormTransactionDate1.Value != null)
            {
                new_FormTransactionDate2.Value = new_FormTransactionDate1.Value;
            }

        }

    }
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("PROCESSMONITORING", GridPanelMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;

        var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(hdnPoolId.Value), ValidationHelper.GetGuid(strSelected), new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
        List<GridColumns> lstAddetColumn = GridPanelMonitoring.ColumnModel.Columns.ToList();
        GridPanelMonitoring.ClearColumns();

        foreach (GridColumns item in lstAddetColumn)
        {
            var count = (from c in getColumnList
                         where c.AttributeName == item.Header && c.Hide == true
                         select c).Count();
            if (count == 0)
                GridPanelMonitoring.AddColumn(item);
        }
        GridPanelMonitoring.ReConfigure();
    }
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        try
        {
            var sort = GridPanelMonitoring.ClientSorts();
            if (sort == null)
                sort = string.Empty;
            var sd = new StaticData();
            string strSql =
                @"
        	Select Mt.ProcessMonitoring AS VALUE ,Mt.New_ProcessMonitoringId AS ID ,Mt.ProcessMonitoring,Mt.new_TransactionItemId,Mt.new_TransactionItemIdName,Mt.new_TransactionDate,Mt.new_TransactionDateUtcTime ,Mt.new_TransactionAmount,Mt.new_TransactionAmountCurrencyName AS new_TransactionAmount_CurrencyName,Mt.new_TransactionAmountCurrency,Mt.new_TransactionAmountCurrencyName,Mt.new_CostAmount,Mt.new_CostAmountCurrencyName AS new_CostAmount_CurrencyName,Mt.new_CostAmountCurrency,Mt.new_CostAmountCurrencyName,
                    Mt.new_SenderId,Mt.new_SenderIdName,
                    Mt.new_SenderNumber,
                    Mt.new_SenderIdentificationCardNumber,Mt.new_RecipientFullName,Mt.new_RecipientCountry,Mt.new_RecipientCountryName,Mt.OwningUser,Mt.OwningUserName,ObjectId, 
                    Mt.new_TransactionConfirmId,
                    Mt.new_TransactionConfirmIdName,
                    Mt.new_ConfirmStatus,
                    Mt.new_ConfirmStatusName ,
                    Mt.new_OperationType,
                    Mt.new_OperationTypeName,
                    Mt.new_SourceTransactionTypeID,
                    Mt.new_SourceTransactionTypeIDName,
                    Mt.new_TargetTransactionTypeID,
                    Mt.new_TargetTransactionTypeIDName,
                    Mt.new_ReceivedAmount1,
                    Mt.new_ReceivedAmount1Currency,
                    Mt.new_ReceivedAmount1CurrencyName,
                    Mt.new_ReceivedAmount2,
                    Mt.new_ReceivedAmount2Currency,
                    Mt.new_ReceivedAmount2CurrencyName,
                    Mt.new_TotalReceivedAmount,
                    Mt.new_TotalReceivedAmountCurrency,
                    Mt.new_TotalReceivedAmountCurrencyName,
                    Mt.new_ReceivedAmount1CurrencyName as new_ReceivedAmount1_CurrencyName,
                    Mt.new_ReceivedAmount2CurrencyName as new_ReceivedAmount2_CurrencyName,
                    Mt.new_TotalReceivedAmountCurrencyName as new_TotalReceivedAmount_CurrencyName,
                    Mt.new_UpdateUserId,
                    Mt.new_UpdateUserIdName,
                    Mt.new_UpdateConfirmRejectUserId,
                    Mt.new_UpdateConfirmRejectUserIdName,
                    Mt.new_CorporationId,
                    Mt.new_CorporationIdName,
                    Mt.new_OfficeId,
                    Mt.new_OfficeIdName,
                    Mt.new_PayingCorporationId,
                    Mt.new_PayingCorporationIdName,
                    Mt.new_RecipientCorporationId,
                    Mt.new_RecipientCorporationIdName,
                    Mt.new_PayingOfficeId,
                    Mt.new_PayingOfficeIdName,
                    Mt.new_PayingUserId,
                    Mt.new_PayingUserIdName,
                    Mt.new_PaymentDate,
                    Mt.new_PaymentDateUtcTime,
                    new_TransferPaymentId,
                    new_TransferPaymentIdName,
                    new_FileTransactionNumber,
                    new_CountryName,
                    Mt.new_TransferIdName,
                    Mt.new_TransferId,
                    Mt.new_NationalityID,
                    Mt.new_NationalityIDName,
                    Mt.new_SenderCountryIDName,
                    Mt.new_SenderCountryID,
                    Mt.new_CancelDate,
                    Mt.new_CancelDateUtcTime,
                    Mt.new_RecipientGsm,
                    Mt.new_TransferRecipient,
                    Mt.new_SerialNumber,
                Mt.new_ReceivedPaymentAmount,
                Mt.new_ReceivedPaymentAmountCurrency,
                Mt.new_ReceivedPaymentAmountCurrencyName,
                Mt.new_ReceivedPaymentAmountCurrencyName AS new_ReceivedPaymentAmount_CurrencyName,Mt.new_SenderIdendificationNumber1,
                new_SenderOfficeBranchNo,
                new_PaidOfficeBranchNo,
                new_InstructionStartCorporationIdName
            from  dbo.tvNew_ProcessMonitoring(@SystemUserId) as Mt
            left Join nltvNew_TransactionConfirm(@SystemUserId) as Tc on Tc.new_TransactionConfirmId=Mt.new_TransactionConfirmId 
            left Join vNew_ApprovalLevel as Al (NOLOCK) on Al.new_ApprovalLevelID=Tc.new_ApprovalLevelID
            left outer join vNew_ConfirmStatus cs (NOLOCK) on cs.New_ConfirmStatusId=mt.New_ConfirmStatus
            left join vSystemUser as  u (NOLOCK) on (u.SystemUserId = @SystemuserId and u.IsDisabled = 0)
            left join vNew_ApprovalLevel as ual (NOLOCK) on u.new_ApprovalLevelID=ual.New_ApprovalLevelId
            Where 1=1 And 
            (
                (
                    ual.new_LevelNumber>= ISNULL(Al.new_LevelNumber,0)
                    and not exists (select 1 from vNew_TransactionConfirmDetail det (nolock) where det.new_TransactionConfirmId=mt.new_TransactionConfirmId and new_TransactionUserId=@SystemUserId)
                    and 
                    (
                         Mt.New_ConfirmStatus IN (Select New_ConfirmStatusId From vNew_ConfirmStatus(NOLOCK) WHERE DeletionStateCode=0 AND new_Code IN('PA002','PA003','TR002','TR003','PA002C','PA003C','TR002C','TR003C','IP002','IP003','IP002C','IP003C'))
                        
                    )
                )
            ";

            TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();

            if (_userApproval.ApprovalRefund)
            {
                strSql += " OR ( Mt.New_ConfirmStatus IN (Select New_ConfirmStatusId From vNew_ConfirmStatus(NOLOCK) WHERE DeletionStateCode=0 AND new_Code ='IT000' ) AND Mt.OwningUser <> @SystemUserId)"; // AND Mt.OwningUser <> @SystemUserId
                //strSql += " OR (cs.new_Code in ('IT000') and cs.DeletionStateCode=0)";
            }

            if (_userApproval.ApprovalEditTransfer)
            {
                strSql += " OR (Mt.New_ConfirmStatus IN (Select New_ConfirmStatusId From vNew_ConfirmStatus(NOLOCK) WHERE DeletionStateCode=0 AND new_Code in ('TRE002U','TRE003U')) AND Mt.ModifiedBy <> @SystemUserId)";
            }

            strSql += ")";

            //if(_userApproval.ApprovalConfirm)
            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING");
            var spList = new List<CrmSqlParameter>();

            if (new_CorporationId.Value != "")
            {
                strSql += " And MT.new_CorporationId=@new_CorporationId";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_CorporationId",
                    Value = ValidationHelper.GetGuid(new_CorporationId.Value)
                });
            }
            if (new_OfficeId.Value != "")
            {
                strSql += " And MT.new_OfficeId=@new_OfficeId";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_OfficeId",
                    Value = ValidationHelper.GetGuid(new_OfficeId.Value)
                });
            }
            if (new_PayingCorporationId.Value != "")
            {
                strSql += " And MT.new_PayingCorporationId=@new_PayingCorporationId";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_PayingCorporationId",
                    Value = ValidationHelper.GetGuid(new_PayingCorporationId.Value)
                });
            }
            if (new_PayingOfficeId.Value != "")
            {
                strSql += " And MT.new_PayingOfficeId=@new_PayingOfficeId";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_PayingOfficeId",
                    Value = ValidationHelper.GetGuid(new_PayingOfficeId.Value)
                });
            }
            if (new_FormTransactionDate1.Value != null)
            {

                strSql += " And new_TransactionDateUtcTime>=@new_FormTransactionDate1";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.DateTime,
                    Paramname = "new_FormTransactionDate1",
                    Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate1.Value), App.Params.CurrentUser.SystemUserId)
                });
            }
            if (new_FormTransactionDate2.Value != null)
            {
                strSql += " And new_TransactionDateUtcTime<(@new_FormTransactionDate2)";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.DateTime,
                    Paramname = "new_FormTransactionDate2",
                    Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate2.Value).AddDays(1), App.Params.CurrentUser.SystemUserId)
                });
            }
            if (new_FormAmount1.Value != null)
            {
                strSql += " And MT.new_TransactionAmount>=@new_FormAmount1";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Decimal,
                    Paramname = "new_FormAmount1",
                    Value = ValidationHelper.GetDecimal(new_FormAmount1.Value, 0)
                });
            }
            if (new_RecipientCorporationId.Value != "")
            {
                strSql += " And new_RecipientCorporationId=@new_RecipientCorporationId";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_RecipientCorporationId",
                    Value = ValidationHelper.GetGuid(new_RecipientCorporationId.Value)
                });
            }
            if (new_FormAmount2.Value != null)
            {
                strSql += " And MT.new_TransactionAmount<=@new_FormAmount2";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Decimal,
                    Paramname = "new_FormAmount2",
                    Value = ValidationHelper.GetDecimal(new_FormAmount2.Value, 0)
                });
            }
            if (new_FormTransactionAmountCurrency.Value != "")
            {
                strSql += " And MT.new_TransactionAmountCurrency=@new_FormTransactionAmountCurrency";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_FormTransactionAmountCurrency",
                    Value = ValidationHelper.GetGuid(new_FormTransactionAmountCurrency.Value)
                });
            }
            if (new_FormConfirmStatusId.Value != "")
            {
                strSql += " And MT.new_ConfirmStatus=@new_FormConfirmStatusId";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_FormConfirmStatusId",
                    Value = ValidationHelper.GetGuid(new_FormConfirmStatusId.Value)
                });
            }
            if (new_SenderId.Value != "")
            {
                strSql += " And MT.new_SenderIdName Like '%'+@new_SenderIdName +'%'";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.String,
                    Paramname = "new_SenderIdName",
                    Value = ValidationHelper.GetDBString(SqlCreater.GetLikeText(new_SenderId.Value))
                });
            }
            if (ProcessMonitoring.Value != "")
            {
                //strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
                strSql += " And MT.ProcessMonitoring = @ProcessMonitoring";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.String,
                    Paramname = "ProcessMonitoring",
                    Value = ValidationHelper.GetString(ProcessMonitoring.Value)
                });
            }
            if (new_SerialNumber.Value != "")
            {
                //strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
                strSql += " And MT.new_SerialNumber = @new_SerialNumber";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.String,
                    Paramname = "new_SerialNumber",
                    Value = ValidationHelper.GetString(new_SerialNumber.Value)
                });
            }
            if (new_OperationType.Value != "")
            {
                strSql += " And MT.new_OperationType = @new_OperationType ";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Int32,
                    Paramname = "new_OperationType",
                    Value = ValidationHelper.GetInteger(new_OperationType.Value)
                });
            }
            if (new_RecipientFullName.Value != "")
            {
                strSql += " And MT.new_RecipientFullName like '%'+@new_RecipientFullName +'%'";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.String,
                    Paramname = "new_RecipientFullName",
                    Value = cryptor.EncryptInString(ValidationHelper.GetString(new_RecipientFullName.Value))
                });
            }
            if (new_PaymentDate2.Value != null)
            {
                strSql += " And (new_PaymentDateUtcTime>=@new_PaymentDate)";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.DateTime,
                    Paramname = "new_PaymentDate",
                    Value =
                    sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_PaymentDate2.Value), App.Params.CurrentUser.SystemUserId)
                });
            }
            if (new_PaymentDate3.Value != null)
            {
                strSql += " And (new_PaymentDateUtcTime< @new_PaymentDate2)";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.DateTime,
                    Paramname = "new_PaymentDate2",
                    Value =
                    sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_PaymentDate3.Value).AddDays(1), App.Params.CurrentUser.SystemUserId)
                });
            }
            if (new_FormSourceTransactionTypeID.Value != "")
            {
                strSql += " And new_SourceTransactionTypeID=@new_FormSourceTransactionTypeID";
                spList.Add(new CrmSqlParameter()
                {
                    Dbtype = DbType.Guid,
                    Paramname = "new_FormSourceTransactionTypeID",
                    Value = ValidationHelper.GetGuid(new_FormSourceTransactionTypeID.Value)
                });
            }

            Logger(spList);

            var gpc = new GridPanelCreater();

            var cnt = 0;
            var start = GridPanelMonitoring.Start();
            var limit = GridPanelMonitoring.Limit();
            var dtb = new DataTable();
            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
            GridPanelMonitoring.TotalCount = cnt;

            List<string> fields = new List<string>() { "new_RecipientFullName", "new_TransferRecipient" };
            t = cryptor.DecryptFieldsInFilterData(fields, t);

            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                if (!_userApproval.ReferenceCanBeSeen)
                {
                    DataTable maskedData = new DataTable();
                    maskedData = dtb.Clone();

                    foreach (DataRow item in dtb.Rows)
                    {
                        string tu_Ref = item.Field<string>("ProcessMonitoring");
                        var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref);

                        item["ProcessMonitoring"] = masked_tu_ref;
                        item["new_TransferIdName"] = masked_tu_ref;
                        if (!string.IsNullOrEmpty(item["new_TransferPaymentIdName"].ToString()))
                            item["new_TransferPaymentIdName"] = masked_tu_ref;
                        item["VALUE"] = masked_tu_ref;

                        maskedData.ImportRow(item);
                    }

                    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
                    gpw.Export(maskedData);
                }
                else
                {
                    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
                    gpw.Export(dtb);
                }
            }

            if (!_userApproval.ReferenceCanBeSeen)
            {
                List<Dictionary<string, object>> maskedList = new List<Dictionary<string, object>>();

                foreach (var item in t)
                {
                    string tu_Ref = item.Where(x => x.Key.Equals("ProcessMonitoring")).Select(x => x.Value).FirstOrDefault().ToString();
                    var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref); // string.Concat(tu_Ref.Substring(0, 3), "".PadRight(8, 'X'));

                    item["ProcessMonitoring"] = masked_tu_ref;
                    item["new_TransferIdName"] = masked_tu_ref;
                    if (!string.IsNullOrEmpty(item["new_TransferPaymentIdName"].ToString()))
                        item["new_TransferPaymentIdName"] = masked_tu_ref;
                    item["VALUE"] = masked_tu_ref;

                    maskedList.Add(item);
                }

                GridPanelMonitoring.DataSource = maskedList;
                GridPanelMonitoring.DataBind();
            }
            else
            {
                GridPanelMonitoring.DataSource = t;
                GridPanelMonitoring.DataBind();
            }
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    protected void BtnConfirmClick_old(object sender, AjaxEventArgs e)
    {
        if (!_userApproval.ApprovalConfirm && !_userApproval.ApprovalRefund)
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION"));

            return;
        }

        var degerler = ((CheckSelectionModel)GridPanelMonitoring.SelectionModel[0]);
        if (degerler != null && degerler.SelectedRows != null)
        {
            var refundTransferConfirmList = new List<Guid>();
            var confirmList = new List<TuConfirmList>();
            var cf = new ConfirmFactory();

            try
            {
                foreach (var row in degerler.SelectedRows)
                {
                    var transactionConfirmId = ValidationHelper.GetString(row.new_TransactionConfirmId);
                    var objectId = ValidationHelper.GetInteger(row.ObjectId);
                    var processMonitoringId = ValidationHelper.GetGuid(row.ID);
                    string ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(objectId, 0), ValidationHelper.GetGuid(processMonitoringId));

                    switch (ts)
                    {
                        case TuConfirmStatus.GonderimOnayiBekliyor:
                        case TuConfirmStatus.GonderimAltOnayBekleniyor:
                        case TuConfirmStatus.OdemeOnayBekliyor:
                        case TuConfirmStatus.OdemeAltOnayBekliyor:
                        case TuConfirmStatus.IadeOdemeOnayBekliyor:
                        case TuConfirmStatus.IadeOdemeAltOnayBekliyor:
                        case TuConfirmStatus.GonderimDuzeltmeAltOnayBekleniyor:
                        case TuConfirmStatus.GonderimDuzeltmeOnayiBekliyor:
                        case TuConfirmStatus.IadeGonderimOnayBekliyor:
                        case TuConfirmStatus.GonderimIptalOnayBekliyor:
                        case TuConfirmStatus.GonderimIptalAltOnayBekliyor:
                        case TuConfirmStatus.IadeOdemeIptalOnayBekliyor:

                            break;
                        default:
                            var ms = new MessageBox();
                            ms.MessageType = EMessageType.Information;
                            ms.Modal = true;
                            ms.Height = 160;
                            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));

                            return;

                    }



                    switch (ts)
                    {
                        case TuConfirmStatus.GonderimDuzeltmeAltOnayBekleniyor:
                        case TuConfirmStatus.GonderimDuzeltmeOnayiBekliyor:
                            var df = new DynamicFactory(ERunInUser.CalingUser);
                            var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), processMonitoringId,
                                        new string[] { "new_TransferEditId" });
                            objectId = TuEntityEnum.New_TransferEdit.GetHashCode();
                            processMonitoringId = de.GetLookupValue("new_TransferEditId");
                            break;
                        case TuConfirmStatus.IadeGonderimOnayBekliyor:
                            refundTransferConfirmList.Add(ValidationHelper.GetGuid(row.new_TransferId));
                            break;
                    }

                    if (ts != TuConfirmStatus.IadeGonderimOnayBekliyor)
                    {
                        confirmList.Add(new TuConfirmList() { Approval = ETuUserApproval.Confirm, Description = "", ObjectId = objectId, RecId = processMonitoringId, ConfirmReasonId = Guid.Empty });
                    }

                }
                if (confirmList.Count > 0 || refundTransferConfirmList.Count > 0)
                {
                    //TODO:Aynı transaction içinde yapmaca.

                    List<TuConfirmList> new_ConfirmList = new List<TuConfirmList>();
                    bool hasOutFile = false;
                    foreach (var confirmListitem in confirmList)
                    {
                        if (confirmListitem.ObjectId == (int)TuEntityEnum.New_Transfer && confirmListitem.Approval == ETuUserApproval.Confirm)
                        {
                            var trs = cf.GetTransactionStatus(confirmListitem.ObjectId, confirmListitem.RecId);
                            if (trs == TuConfirmStatus.GonderimIptalOnayBekliyor)
                            {
                                ConfirmDb cdb = new ConfirmDb();
                                var isOut = cdb.GetTransferIsCancelFileOut(confirmListitem.RecId);
                                if (!isOut)
                                {
                                    new_ConfirmList.Add(confirmListitem);
                                }
                                else
                                {
                                    if (_userApproval.RunAsManuel)
                                    {
                                        new_ConfirmList.Add(confirmListitem);
                                    }
                                    else
                                    {
                                        hasOutFile = true;
                                    }
                                }
                            }
                            else
                            {
                                new_ConfirmList.Add(confirmListitem);
                            }
                        }
                        else
                        {
                            new_ConfirmList.Add(confirmListitem);
                        }
                    }

                    if (new_ConfirmList.Count > 0)
                    {
                        cf.Confirm(new_ConfirmList);
                    }

                    var new_refundTransferConfirmList = new List<Guid>();
                    try
                    {

                        foreach (var refundtransferItem in refundTransferConfirmList)
                        {
                            ConfirmDb cdb = new ConfirmDb();
                            var isOut = cdb.GetRefundTransferIsFileOut(refundtransferItem);
                            if (!isOut)
                            {
                                new_refundTransferConfirmList.Add(refundtransferItem);
                            }
                            else
                            {
                                if (_userApproval.RunAsManuel)
                                {
                                    new_refundTransferConfirmList.Add(refundtransferItem);
                                }
                                else
                                {
                                    hasOutFile = true;
                                }
                            }
                        }
                        if (new_refundTransferConfirmList.Count > 0)
                        {
                            new RefundFactory().CreateRefundTransferConfirm(new_refundTransferConfirmList);
                        }

                    }
                    catch (TuException ex)
                    {
                        throw new TuException() { ErrorMessage = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_PARTIALCONFIRM") + "<br />" + ex.ErrorMessage };
                    }

                    if (new_ConfirmList.Count == 0 && new_refundTransferConfirmList.Count == 0 && (confirmList.Count > 0 || refundTransferConfirmList.Count > 0))
                    {
                        var ms = new MessageBox();
                        ms.MessageType = EMessageType.Information;
                        ms.Modal = true;
                        ms.Height = 160;
                        ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOU_HAVENOT_CANCELFILECONFIRMAUTHORY"));
                    }
                    else
                    {
                        var ms = new MessageBox();
                        ms.MessageType = EMessageType.Information;
                        ms.Modal = true;
                        ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRMED"));
                    }

                }

            }
            catch (InvalidOperationException ioe)
            {
                BasePage.QScript("alert('" + ioe.Message + "');");
            }
            catch (TuException ex)
            {
                GridPanelMonitoring.ClearSelection();
                var ms = new MessageBox();
                ms.MessageType = EMessageType.Information;
                ms.Modal = true;
                ms.Show(".", "", ex.ErrorMessage);

            }
            catch (Exception ex)
            {
                GridPanelMonitoring.ClearSelection();
                var ms = new MessageBox();
                ms.MessageType = EMessageType.Information;
                ms.Modal = true;
                ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            }
            GridPanelMonitoring.ClearSelection();
            GridPanelMonitoring.Reload();
        }
        else
        {
            var ms = new MessageBox();
            ms.MessageType = EMessageType.Information;
            ms.Modal = true;
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PLACE_SELECT_RECORD"));
        }

    }

    protected void BtnConfirmClick(object sender, AjaxEventArgs e)
    {
        if (!_userApproval.ApprovalConfirm && !_userApproval.ApprovalRefund)
        {
            messageBox.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION"));

            return;
        }

        var degerler = ((CheckSelectionModel)GridPanelMonitoring.SelectionModel[0]);
        if (degerler != null && degerler.SelectedRows != null)
        {
            var refundTransferConfirmList = new List<Guid>();
            var confirmList = new List<TuConfirmList>();
            var cancelConfirmList = new List<TuConfirmList>();
            var cf = new ConfirmFactory();

            try
            {
                foreach (var row in degerler.SelectedRows)
                {
                    var transactionConfirmId = ValidationHelper.GetString(row.new_TransactionConfirmId);
                    var objectId = ValidationHelper.GetInteger(row.ObjectId);
                    var processMonitoringId = ValidationHelper.GetGuid(row.ID);

                    #region statü kontrol
                    string ts = cf.GetTransactionStatus(ValidationHelper.GetInteger(objectId, 0), ValidationHelper.GetGuid(processMonitoringId));

                    switch (ts)
                    {
                        case TuConfirmStatus.GonderimOnayiBekliyor:
                        case TuConfirmStatus.GonderimAltOnayBekleniyor:
                        case TuConfirmStatus.OdemeOnayBekliyor:
                        case TuConfirmStatus.OdemeAltOnayBekliyor:
                        case TuConfirmStatus.IadeOdemeOnayBekliyor:
                        case TuConfirmStatus.IadeOdemeAltOnayBekliyor:
                        case TuConfirmStatus.GonderimDuzeltmeAltOnayBekleniyor:
                        case TuConfirmStatus.GonderimDuzeltmeOnayiBekliyor:
                        case TuConfirmStatus.IadeGonderimOnayBekliyor:
                        case TuConfirmStatus.GonderimIptalOnayBekliyor:
                        case TuConfirmStatus.GonderimIptalAltOnayBekliyor:
                        case TuConfirmStatus.IadeOdemeIptalOnayBekliyor:

                            break;
                        default:
                            messageBox.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                            return;
                    }

                    #endregion

                    switch (ts)
                    {
                        case TuConfirmStatus.GonderimDuzeltmeAltOnayBekleniyor:
                        case TuConfirmStatus.GonderimDuzeltmeOnayiBekliyor:
                            var df = new DynamicFactory(ERunInUser.CalingUser);
                            var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), processMonitoringId,
                                        new string[] { "new_TransferEditId" });
                            objectId = TuEntityEnum.New_TransferEdit.GetHashCode();
                            processMonitoringId = de.GetLookupValue("new_TransferEditId");
                            break;
                        case TuConfirmStatus.IadeGonderimOnayBekliyor:
                            refundTransferConfirmList.Add(ValidationHelper.GetGuid(row.new_TransferId));
                            break;
                    }

                    if (ts != TuConfirmStatus.IadeGonderimOnayBekliyor)
                    {
                        if (ts == TuConfirmStatus.GonderimIptalOnayBekliyor)
                        {
                            cancelConfirmList.Add(new TuConfirmList() { Approval = ETuUserApproval.Confirm, Description = "", ObjectId = objectId, RecId = processMonitoringId, ConfirmReasonId = Guid.Empty });
                        }
                        else
                        {
                            confirmList.Add(new TuConfirmList() { Approval = ETuUserApproval.Confirm, Description = "", ObjectId = objectId, RecId = processMonitoringId, ConfirmReasonId = Guid.Empty });
                        }
                    }

                }
                if (confirmList.Count > 0 || refundTransferConfirmList.Count > 0 || cancelConfirmList.Count > 0)
                {
                    //TODO:Aynı transaction içinde yapmaca.

                    List<TuConfirmList> new_ConfirmList = new List<TuConfirmList>();
                    List<TuConfirmList> new_CancelConfirmList = new List<TuConfirmList>();

                    AddToConfirmList(confirmList, new_ConfirmList);
                    AddToConfirmList(cancelConfirmList, new_CancelConfirmList);

                    if (new_ConfirmList.Count > 0)
                    {
                        cf.Confirm(new_ConfirmList);

                        
                    }

                    //TransactionCancelManager
                    foreach (var item in new_CancelConfirmList)
                    {
                        TransactionDto transferDto = new TransactionDto(item, ExecutionChannel.WEBUI, OperationType.Confirm);
                        var transactionCancelManager = new TransactionCancelManager<bool, bool, bool>(transferDto);

                        var confirmResult = transactionCancelManager.Confirm(fromPoolPage: true);
                        EvaluateResult(confirmResult.GetError());
                    }

                    #region Refund Transfer

                    var new_refundTransferConfirmList = new List<Guid>();
                    try
                    {

                        foreach (var refundtransferItem in refundTransferConfirmList)
                        {
                            ConfirmDb cdb = new ConfirmDb();
                            var isOut = cdb.GetRefundTransferIsFileOut(refundtransferItem);
                            if (!isOut)
                            {
                                new_refundTransferConfirmList.Add(refundtransferItem);
                            }
                            else
                            {
                                if (_userApproval.RunAsManuel)
                                {
                                    new_refundTransferConfirmList.Add(refundtransferItem);
                                }
                            }
                        }
                        if (new_refundTransferConfirmList.Count > 0)
                        {
                            new RefundFactory().CreateRefundTransferConfirm(new_refundTransferConfirmList);
                        }

                    }
                    catch (TuException ex)
                    {
                        throw new TuException() { ErrorMessage = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_PARTIALCONFIRM") + "<br />" + ex.ErrorMessage };
                    }
                    #endregion

                    if (new_ConfirmList.Count == 0 && new_refundTransferConfirmList.Count == 0 && new_CancelConfirmList.Count == 0
                        && (confirmList.Count > 0 || refundTransferConfirmList.Count > 0 || cancelConfirmList.Count > 0))
                    {
                        messageBox.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOU_HAVENOT_CANCELFILECONFIRMAUTHORY"));
                    }
                    else
                    {
                        messageBox.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_CONFIRMED"));
                    }
                }

            }
            catch (InvalidOperationException ioe)
            {
                BasePage.QScript("alert('" + ioe.Message + "');");
            }
            catch (TuException ex)
            {
                GridPanelMonitoring.ClearSelection();
                messageBox.Show(".", "", ex.ErrorMessage);

            }
            catch (Exception ex)
            {
                GridPanelMonitoring.ClearSelection();
                messageBox.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            }
            GridPanelMonitoring.ClearSelection();
            GridPanelMonitoring.Reload();
        }
        else
        {
            messageBox.Show(".", CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PLACE_SELECT_RECORD"));
        }
    }

    private void AddToConfirmList(List<TuConfirmList> confirmList, List<TuConfirmList> new_ConfirmList)
    {
        var cf = new ConfirmFactory();

        foreach (var confirmListitem in confirmList)
        {
            if (confirmListitem.ObjectId == (int)TuEntityEnum.New_Transfer && confirmListitem.Approval == ETuUserApproval.Confirm)
            {
                var trs = cf.GetTransactionStatus(confirmListitem.ObjectId, confirmListitem.RecId);
                if (trs == TuConfirmStatus.GonderimIptalOnayBekliyor)
                {
                    ConfirmDb cdb = new ConfirmDb();
                    var isOut = cdb.GetTransferIsCancelFileOut(confirmListitem.RecId);
                    if (!isOut)
                    {
                        new_ConfirmList.Add(confirmListitem);
                    }
                    else
                    {
                        if (_userApproval.RunAsManuel)
                        {
                            new_ConfirmList.Add(confirmListitem);
                        }
                    }
                }
                else
                {
                    new_ConfirmList.Add(confirmListitem);
                }
            }
            else
            {
                new_ConfirmList.Add(confirmListitem);
            }
        }
    }

    private void EvaluateResult(List<Error> list)
    {
        if (list != null)
        {
            if (list.Count > 0)
            {
                GridPanelMonitoring.ClearSelection();
            }

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
                        messageBox.Show(".", message);
                        break;
                    default:
                        break;
                }
            }
        }
    }
    private void Logger(List<CrmSqlParameter> spList)
    {
        var de = new DynamicEntity(TuEntityEnum.New_ProcessMonitoring.GetHashCode());
        var deRetrived = new DynamicEntity(de.ObjectId);

        foreach (var parameter in spList)
        {
            if (parameter.Dbtype == DbType.String)
            {
                var masked_tu_ref = string.Empty;
                if (parameter.Paramname.Equals("ProcessMonitoring"))
                {
                    masked_tu_ref = TuFactory.Utility.Masker.MaskReference(parameter.Value.ToString());
                    de.AddStringProperty(parameter.Paramname, ValidationHelper.GetString(masked_tu_ref));
                }
                else
                {
                    de.AddStringProperty(parameter.Paramname, ValidationHelper.GetString(parameter.Value));
                }
            }
            if (parameter.Dbtype == DbType.Guid)
            {
                de.AddLookupProperty(parameter.Paramname, "", ValidationHelper.GetGuid(parameter.Value));
            }
            if (parameter.Dbtype == DbType.DateTime)
            {
                if (parameter.Paramname.Equals("new_FormTransactionDate1"))
                {
                    de.AddDateTimeProperty(parameter.Paramname, ValidationHelper.GetDate(parameter.Value).AddDays(1));
                }
                else
                {
                    de.AddDateTimeProperty(parameter.Paramname, ValidationHelper.GetDate(parameter.Value));
                }
            }
            if (parameter.Dbtype == DbType.Decimal)
            {
                de.AddDecimalProperty(parameter.Paramname, ValidationHelper.GetDecimal(parameter.Value, 0));
            }
            if (parameter.Paramname.Equals("new_FormAmount2"))
            {
                de.AddMoneyProperty(parameter.Paramname, decimal.Parse(parameter.Value.ToString()), new Lookup("TL", ValidationHelper.GetGuid(new_FormTransactionAmountCurrency.Value)));
            }
        }

        DynamicFactory df = new DynamicFactory(Coretech.Crm.Objects.Crm.WorkFlow.ERunInUser.SystemAdmin);
        var db = new Coretech.Crm.Data.Crm.Dynamic.DynamicDb();

        var recId = Guid.Empty;
        if (string.IsNullOrEmpty(hdnRecid.Value) || hdnRecid.Value.Equals(Guid.Empty))
        {
            var gdKey = GuidHelper.Newfoid(de.ObjectId);
            var logsql = "";
            List<CrmSqlParameter> logspList;

            var baseEntity = TuFactory.Data.LogDb.GetBaseEntityId(TuEntityEnum.New_ProcessMonitoring.ToString());
            TuFactory.Data.LogDb.CreateLogSql(out logsql, out logspList, deRetrived, de, Guid.Parse(hdnEntityId.Value), gdKey, baseEntity);

            if (logspList.Count > 0)
                db.Exec(logsql, App.Params.CurrentUser.SystemUserId, logspList);

            hdnRecid.SetValue(gdKey);
        }
        else
        {
            de.AddKeyProperty("New_ProcessMonitoringId", Guid.Parse(hdnRecid.Value));

            var logsql = "";
            List<CrmSqlParameter> logspList;
            var baseEntity = TuFactory.Data.LogDb.GetBaseEntityId(TuEntityEnum.New_ProcessMonitoring.ToString());
            TuFactory.Data.LogDb.CreateLogSql(out logsql, out logspList, deRetrived, de, Guid.Parse(hdnEntityId.Value), Guid.Parse(hdnRecid.Value), baseEntity);

            if (logspList.Count > 0)
                db.Exec(logsql, App.Params.CurrentUser.SystemUserId, logspList);
        }
    }
    protected void new_RecipientCorporationLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"Select c.New_CorporationCode As new_CorporationCode, c.New_CorporationId AS ID, c.CorporationName AS CorporationName, c.CorporationName AS VALUE from nltvNew_Corporation(@SystemUserId) c
                        Where c.DeletionStateCode = 0 And statuscode = 1";

        StaticData sd = new StaticData();

        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        if (_userApproval.AllRecipientCorporation)
        {
            sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid("00000000-AAAA-BBBB-CCCC-000000000001"));
        }
        else
        {
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        }

        var like = ((CrmComboComp)sender).Query();
        if (!string.IsNullOrEmpty(like))
        {
            strSql += @" AND c.CorporationName LIKE '%' + @CorporationName + '%' ";
            sd.AddParameter("CorporationName", DbType.String, like);
        }

        strSql += " ORDER BY c.CorporationName";

        BindCombo(((CrmComboComp)sender), sd, strSql);
    }
    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql)
    {
        var start = combo.Start() - 1;
        var limit = combo.Limit();

        if (start < 0)
        {
            start = 0;
        }

        BindCombo(combo, sd, strSql, start, limit);
    }
    private void BindCombo(CrmComboComp combo, StaticData sd, string strSql, int start, int limit)
    {
        var t = sd.ReturnDataset(strSql).Tables[0];

        DataTable t2 = t.Clone();

        var end = start + limit > t.Rows.Count ? t.Rows.Count : start + limit;

        for (int i = start; i < end; i++)
        {
            DataRow dr = t2.NewRow();
            dr.ItemArray = t.Rows[i].ItemArray;
            t2.Rows.Add(dr);
        }

        combo.TotalCount = t.Rows.Count;
        combo.DataSource = t2;
        combo.DataBind();
    }
    private void FillLogInfo()
    {
        var id = Guid.Parse("5f83384d-c2e9-4388-8d65-0fb7c9c7e8ec");
        var recId = new TuFactory.Data.LogDb().GetLastRecordId(id);

        hdnEntityId.SetValue(id);
        hdnRecid.SetValue(recId);
    }
}
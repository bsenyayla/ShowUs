using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using System.Linq;
using TuFactory.Data;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;

public partial class Operation_Detail_CancelPool : BasePage
{
    private TuUserApproval _userApproval = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUser _activeUser = null;
    private void TranslateMessages()
    {

        var all = CrmLabel.TranslateMessage("CRM.ENTITY_ALL");

        new_CorporationId.EmptyText = all;
        new_OfficeId.EmptyText = all;
        new_SenderId.EmptyText = all;
        new_RecipientFullName.EmptyText = all;

        new_SenderCountryID.EmptyText = all;
        new_FormTransactionTypeID.EmptyText = all;
        new_FormSourceTransactionTypeID.EmptyText = all;
        new_FormReceiverCountryId.EmptyText = all;
        new_FormCustomerNumber.EmptyText = all;
        new_PayingCorporationId.EmptyText = all;
        new_RecipientCorporationId.EmptyText = all;
        new_PayingOfficeId.EmptyText = all;
    }
    protected void btnInformationOnEvent(object sender, AjaxEventArgs e)
    {
        var infoList = Info.GetEntityHelpsByName("MONITORING", this);
        if (infoList == null) return;
        var b = HttpContext.Current;
        b.Response.ClearContent();
        b.Response.ClearHeaders();
        b.Response.Clear();
        var f = new FileInfo(Server.MapPath(infoList.Command));
        var fs = File.Open(Server.MapPath(infoList.Command), FileMode.Open);

        var ms = new MemoryStream();
        fs.CopyTo(ms);

        var buffer = ms.ToArray();

        b.Response.AddHeader("Content-Disposition", string.Format(CultureInfo.InvariantCulture, "attachment; filename=\"{0}\"", new object[] { f.Name }));
        var length = buffer.Length;
        b.Response.AddHeader("ContentLength", length.ToString(CultureInfo.InvariantCulture));
        if (buffer.Length > 0)
        {
            b.Response.BinaryWrite(buffer);
        }
        b.Response.Flush();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();

        if (!RefleX.IsAjxPostback)
        {
            TranslateMessages();
            FillLogInfo();
            new_CorporationId.Value = _activeUser.CorporationId.ToString();
            new_OfficeId.Value = _activeUser.OfficeId.ToString();
            if (new_FormTransactionDate1.Value != null)
            {
                new_FormTransactionDate2.Value = new_FormTransactionDate1.Value;
            }

            if (!_userApproval.ShowCancelPool)
            {
                Response.End();
            }

            if (!_userApproval.CancelStartOldDate)
            {
                RxM.Disabled = true;
            }
            pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_SEARCH");
            CreateViewGrid();
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


    private string GetFilterValidation()
    {
        string errMsg = string.Empty;

        if (!string.IsNullOrEmpty(ProcessMonitoring.Value))
        {
            return errMsg;
        }
        else
        {
            errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_REF_NOT_NULL");
        }
        return errMsg;
    }

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql = @"
        	Select Mt.ProcessMonitoring AS VALUE ,Mt.New_ProcessMonitoringId AS ID ,Mt.ProcessMonitoring,Mt.new_TransactionItemId,Mt.new_TransactionItemIdName,Mt.new_TransactionDate,Mt.new_TransactionDateUtcTime ,Mt.new_TransactionAmount,Mt.new_TransactionAmountCurrencyName AS new_TransactionAmount_CurrencyName,Mt.new_TransactionAmountCurrency,Mt.new_TransactionAmountCurrencyName,Mt.new_CostAmount,Mt.new_CostAmountCurrencyName AS new_CostAmount_CurrencyName,Mt.new_CostAmountCurrency,Mt.new_CostAmountCurrencyName,Mt.new_SenderId,Mt.new_SenderIdName,Mt.new_SenderIdentificationCardNumber,Mt.new_RecipientFullName,Mt.new_RecipientCountry,Mt.new_RecipientCountryName,Mt.OwningUser,Mt.OwningUserName,ObjectId 
, Mt.new_TransactionConfirmId,
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
Mt.new_PayingOfficeId,
Mt.new_PayingOfficeIdName,
Mt.new_RecipientCorporationId,
Mt.new_RecipientCorporationIdName,
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
                Mt.new_Channel,
                Mt.new_ChannelName,
                Mt.new_TransferRecipient,
Mt.new_SerialNumber,
                Mt.new_ReceivedPaymentAmount,
                Mt.new_ReceivedPaymentAmountCurrency,
                Mt.new_ReceivedPaymentAmountCurrencyName,
                Mt.new_ReceivedPaymentAmountCurrencyName AS new_ReceivedPaymentAmount_CurrencyName,Mt.new_SenderIdendificationNumber1
from  dbo.tvNew_ProcessMonitoring(@SystemUserId) as Mt
Where 
    Mt.New_ConfirmStatus IN (Select New_ConfirmStatusId From vNew_ConfirmStatus(NOLOCK) WHERE DeletionStateCode=0 AND new_Code IN('TR001','PA001','IP001','TR002','PA002','IP002','TR005','TR004A','PA005','PA004A','IP005','TR004','PA004','IP004','TR010','PA010','IP010','IT002','TR012','TR000E'))";
         


        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();

        bool isParameterUsed = false;


        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING");
        var spList = new List<CrmSqlParameter>();
        if (new_SenderCountryID.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_SenderCountryID=@new_Country";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_Country",
                Value = ValidationHelper.GetGuid(new_SenderCountryID.Value)
            });
        }
        if (new_CorporationId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_CorporationId=@new_CorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_CorporationId",
                Value = ValidationHelper.GetGuid(new_CorporationId.Value)
            });
        }
        if (new_OfficeId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_OfficeId=@new_OfficeId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_OfficeId",
                Value = ValidationHelper.GetGuid(new_OfficeId.Value)
            });
        }
        if (new_PayingCorporationId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_PayingCorporationId=@new_PayingCorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_PayingCorporationId",
                Value = ValidationHelper.GetGuid(new_PayingCorporationId.Value)
            });
        }

        if (new_PayingOfficeId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_PayingOfficeId=@new_PayingOfficeId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_PayingOfficeId",
                Value = ValidationHelper.GetGuid(new_PayingOfficeId.Value)
            });
        }

        if (new_FormTransactionDate1.Value != null)
        {
            isParameterUsed = true;
            strSql += " And new_TransactionDateUtcTime>=@new_FormTransactionDate1";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_FormTransactionDate1",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate1.Value), App.Params.CurrentUser.SystemUserId)
            });
        }
        if (new_RecipientCorporationId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_RecipientCorporationId=@new_RecipientCorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_RecipientCorporationId",
                Value = ValidationHelper.GetGuid(new_RecipientCorporationId.Value)
            });
        }
        if (new_FormTransactionDate2.Value != null)
        {
            isParameterUsed = true;
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
            isParameterUsed = true;
            strSql += " And new_TransactionAmount>=@new_FormAmount1";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Decimal,
                Paramname = "new_FormAmount1",
                Value = ValidationHelper.GetDecimal(new_FormAmount1.Value, 0)
            });
        }
        if (new_FormAmount2.Value != null)
        {
            isParameterUsed = true;
            strSql += " And new_TransactionAmount<=@new_FormAmount2";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Decimal,
                Paramname = "new_FormAmount2",
                Value = ValidationHelper.GetDecimal(new_FormAmount2.Value, 0)
            });
        }
        if (new_FormTransactionAmountCurrency.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_TransactionAmountCurrency=@new_FormTransactionAmountCurrency";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormTransactionAmountCurrency",
                Value = ValidationHelper.GetGuid(new_FormTransactionAmountCurrency.Value)
            });
        }
        if (new_FormTransactionTypeID.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_TargetTransactionTypeID=@new_FormTransactionTypeID";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormTransactionTypeID",
                Value = ValidationHelper.GetGuid(new_FormTransactionTypeID.Value)
            });
        }
        if (new_FormSourceTransactionTypeID.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_SourceTransactionTypeID=@new_FormSourceTransactionTypeID";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormSourceTransactionTypeID",
                Value = ValidationHelper.GetGuid(new_FormSourceTransactionTypeID.Value)
            });
        }
        if (new_FormCustomerNumber.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_SenderIdentificationCardNumber=@new_FormCustomerNumber";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_FormCustomerNumber",
                Value = ValidationHelper.GetString(new_FormCustomerNumber.Value)
            });
        }
        if (new_FormReceiverCountryId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And new_RecipientCountry=@new_FormReceiverCountryId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormReceiverCountryId",
                Value = ValidationHelper.GetGuid(new_FormReceiverCountryId.Value)
            });
        }
        if (ProcessMonitoring.Value != "")
        {
            isParameterUsed = true;
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
            isParameterUsed = true;
            //strSql += " And MT.ProcessMonitoring like '%'+@ProcessMonitoring +'%'";
            strSql += " And MT.new_SerialNumber = @new_SerialNumber";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SerialNumber",
                Value = ValidationHelper.GetString(new_SerialNumber.Value)
            });
        }
        if (new_SenderId.Value != "")
        {
            isParameterUsed = true;
            strSql += " And MT.new_SenderIdName Like '%'+@new_SenderIdName +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SenderIdName",
                Value = ValidationHelper.GetDBString(SqlCreater.GetLikeText(new_SenderId.Value))
            });
        }
        if (new_RecipientFullName.Value != "")
        {
            isParameterUsed = true;
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
            isParameterUsed = true;
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
            isParameterUsed = true;
            strSql += " And (new_PaymentDateUtcTime< @new_PaymentDate2)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_PaymentDate2",
                Value =
                sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_PaymentDate3.Value).AddDays(1), App.Params.CurrentUser.SystemUserId)
            });
        }

        if (!isParameterUsed)
        {
            string filtermsg = GetFilterValidation();
            if (!string.IsNullOrEmpty(filtermsg))
            {
                var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", filtermsg);

                GridPanelMonitoring.DataBind();
                return;
            }
        }

        Logger(spList);

        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        GridPanelMonitoring.TotalCount = cnt;

        List<string> fields = new List<string>() { "new_RecipientFullName" };
        t = cryptor.DecryptFieldsInFilterData(fields, t);

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

    protected void ToolbarButtonTransferClick(object sender, AjaxEventArgs e)
    {

    }
    protected void ToolbarButtonPaymentClick(object sender, AjaxEventArgs e)
    {
    }

    private void HoldResume(ETuHoldResume action)
    {
        if (!_userApproval.ApprovalHoldResume)
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true };
            ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_YOUHAVENOT_PERMISSION"));

            return;
        }

        var degerler = ((RowSelectionModel)GridPanelMonitoring.SelectionModel[0]);
        if (degerler != null && degerler.SelectedRows != null)
        {

            try
            {
                var objectId = ValidationHelper.GetInteger(degerler.SelectedRows.ObjectId);
                var processMonitoringId = ValidationHelper.GetGuid(degerler.SelectedRows.ID);
                var cf = new ConfirmFactory();

                cf.ConfirmHoldResume(action, objectId, processMonitoringId);
                if (action == ETuHoldResume.Hold)
                    _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_HOLD_OK"));
                else if (action == ETuHoldResume.Resume)
                    _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_RESUME_OK"));

                QScript("ToolbarButtonFind.click();");
            }
            catch (TuException ex)
            {
                _msg.Show(".", ex.ErrorMessage);

            }
            catch (Exception ex)
            {

                _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_UNKNOWN_ERROR"));
            }


            //GridPanelMonitoring.Reload();
        }
        else
        {
            _msg.Show(".", CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PLACE_SELECT_RECORD"));
        }
    }
    protected void BtnHoldClick(object sender, AjaxEventArgs e)
    {
        HoldResume(ETuHoldResume.Hold);


    }
    protected void BtnResumeClick(object sender, AjaxEventArgs e)
    {
        HoldResume(ETuHoldResume.Resume);
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
    private void FillLogInfo()
    {
        var id = Guid.Parse("caa07ae3-b1e8-410b-be1f-63ede1aa6862");
        var recId = new TuFactory.Data.LogDb().GetLastRecordId(id);

        hdnEntityId.SetValue(id);
        hdnRecid.SetValue(recId);
    }

    protected void new_CountryLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"/* DECLARE @SystemUserId UNIQUEIDENTIFIER =  '00000001-2211-44A8-BAAA-89AC131336A9' */
            DECLARE @LangId AS INT
            DECLARE @TempLangId AS INT
            SELECT @LangId = LanguageId FROM vSystemUser
            WHERE SystemUserId = @SystemUserId     
            SELECT		
                        c.new_CountryID AS ID, 
						cE.new_TelephoneCode,
                        CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END AS CountryName,
                        CASE @TempLangId 
                             WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                             ELSE cl.Value
                        END AS VALUE
            FROM New_CountryBase c
            INNER JOIN New_CountryLabel cl
            ON c.New_CountryId = cl.New_CountryId AND cl.LangId = @LangId
			INNER JOIN New_CountryExtension cE
			ON c.New_CountryId = cE.New_CountryId
                 WHERE 
			C.DeletionStateCode = 0
			AND cE.new_TelephoneCode IS NOT NULL
			";

        StaticData sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        //var like = new_SenderCountryID.Query();
        var like = ((CrmComboComp)sender).Query();
        if (!string.IsNullOrEmpty(like))
        {
            strSql += @" AND (CASE @TempLangId 
                                WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                                ELSE cl.Value
                                END LIKE '%' + @CountryName + '%' OR CASE @TempLangId 
                                WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                                ELSE cl.Value
                                END LIKE '%' + UPPER(@CountryNameTR COLLATE SQL_Latin1_General_CP1_CI_AS) + '%' )";

            sd.AddParameter("CountryName", DbType.String, like.Replace("İ", "I"));
            like = like.Replace("i", "İ");
            like = like.Replace("ı", "I");
            sd.AddParameter("CountryNameTR", DbType.String, like);
        }

        strSql += " ORDER BY CountryName";

        BindCombo(((CrmComboComp)sender), sd, strSql);
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

}
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
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
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using TuFactory.Data;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;

public class EArchiveRequest
{
    public Guid SystemuserId { get; set; }
    public string TransferTuRef { get; set; }
    public int? OperationTypeId { get; set; }
    public int? TransactionStatus { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public Guid SenderCountryID { get; set; }
    public Guid CorporationId { get; set; }
    public Guid OfficeId { get; set; }
    public Guid PayingCorporationId { get; set; }
    public Guid PayingOfficeId { get; set; }
    public decimal FormAmount1 { get; set; }
    public decimal FormAmount2 { get; set; }
    public Guid FormTransactionAmountCurrency { get; set; }
    public Guid FormTransactionTypeID { get; set; }
    public Guid FormReceiverCountryId { get; set; }
    public Guid RecipientCorporationId { get; set; }
    public string RecipientFullName { get; set; }
    public Guid SenderId { get; set; }
    public Guid FormConfirmStatusId { get; set; }
    public string FileTransactionNumber { get; set; }
    public DateTime PaymentDate2 { get; set; }
    public DateTime PaymentDate3 { get; set; }
    public string FormTransactionTypeEft { get; set; }
    public Guid InstructionStartCorporationId { get; set; }
    public int StartRow { get; set; }
    public int Limit { get; set; }

}
public partial class _EArchivePool_Monitoring : BasePage
{
    private TuUser _activeUser = null;
    private DynamicSecurity _dynamicSecurityPayment;
    private DynamicSecurity _dynamicSecurityTransfer;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUserApproval _userApproval = null;
    private Guid QueryId = Guid.Empty;
    public void CreateViewGrid()
    {

       
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

        if (!RefleX.IsAjxPostback)
        {
            new_FormTransactionDate2.SetValue(DateTime.Now.ToString("dd.MM.yyyy"));
        }
    }

    private string GetFilterValidation()
    {
        string errMsg = string.Empty;

        int TransferDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("TRANSFERDATE_PERIOD"), 30);
        int PaymentDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("PAYMENTDATE_PERIOD"), 30);
        int CancelDatePeriod = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("CANCELDATE_PERIOD"), 30);

        if (!string.IsNullOrEmpty(ProcessMonitoring.Value) || !string.IsNullOrEmpty(new_FileTransactionNumber.Value))
        {
            return errMsg;
        }
        else
        {


            if ((new_PaymentDate2.Value != null && new_PaymentDate3.Value != null))
            {
                return errMsg;
            }
            else if ((new_PaymentDate2.Value != null && new_PaymentDate3.Value == null))
            {
                errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MUST_ENTER_ENDPAYMENTDATE");
                return errMsg;
            }
            else if ((new_PaymentDate2.Value == null && new_PaymentDate3.Value != null))
            {
                errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MUST_ENTER_STARTPAYMENTDATE");
                return errMsg;
            }

            if ((new_FormTransactionDate1.Value == null || new_FormTransactionDate2.Value == null))
            {
                errMsg = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_REF_AND_DATE_NOT_NULL");
            }
            else
            {
                double dateDiff = (ValidationHelper.GetDate(new_FormTransactionDate2.Value) - ValidationHelper.GetDate(new_FormTransactionDate1.Value)).TotalDays;

                if (string.IsNullOrEmpty(new_RecipientCorporationId.Value) && string.IsNullOrEmpty(new_CorporationId.Value))
                {
                    if (string.IsNullOrEmpty(new_SenderId.Value) && string.IsNullOrEmpty(new_RecipientFullName.Value))
                    {

                        if (dateDiff > TransferDatePeriod)
                        {
                            if (string.IsNullOrEmpty(new_RecipientCorporationId.Value) && string.IsNullOrEmpty(new_CorporationId.Value))
                            {
                                errMsg = string.Format(CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_NO_REF_MAX_N_DAY"), TransferDatePeriod);
                            }
                        }
                    }
                    else
                    {
                        /*Gönderici veya alıcı girildiyse 90 gün yapabilsin.*/

                        if (dateDiff > 90)
                        {
                            if (string.IsNullOrEmpty(new_RecipientCorporationId.Value) && string.IsNullOrEmpty(new_CorporationId.Value))
                            {
                                errMsg = string.Format(CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_NO_REF_MAX_N_DAY"), 90);
                            }
                        }
                    }
                }
            }
        }


        return errMsg;
    }

    private string GetFilters(out List<CrmSqlParameter> spList)
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        var sd = new StaticData();
        string strSql = string.Empty;
        spList = new List<CrmSqlParameter>();
        if (new_SenderCountryID.Value != "")
        {
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
            strSql += " And new_TransactionDateUtcTime<=(@new_FormTransactionDate2)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_FormTransactionDate2",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate2.Value), App.Params.CurrentUser.SystemUserId)
            });
        }
        if (new_FormAmount1.Value != null)
        {
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
            strSql += " And new_TransactionAmountCurrency=@new_FormTransactionAmountCurrency";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormTransactionAmountCurrency",
                Value = ValidationHelper.GetGuid(new_FormTransactionAmountCurrency.Value)
            });
        }


        if (new_FormReceiverCountryId.Value != "")
        {
            strSql += " And new_RecipientCountry=@new_FormReceiverCountryId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormReceiverCountryId",
                Value = ValidationHelper.GetGuid(new_FormReceiverCountryId.Value)
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


        if (new_RecipientFullName.Value != "")
        {
            strSql += " And REPLACE(new_RecipientFullName,' ','')  like '%'+@new_RecipientFullName +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_RecipientFullName",
                Value = cryptor.EncryptInString(ValidationHelper.GetString(new_RecipientFullName.Value.Replace(" ", "")))
            });
        }
        if (new_SenderId.Value != "")
        {
            strSql += " And REPLACE(new_SenderIdName,' ','')  Like '%'+@new_SenderIdName +'%'";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SenderIdName",
                Value = ValidationHelper.GetDBString(SqlCreater.GetLikeText(new_SenderId.Value.Replace(" ", "")))
            });
        }
        if (new_FormConfirmStatusId.Value != "")
        {
            strSql += " And new_ConfirmStatus=@new_FormConfirmStatusId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_FormConfirmStatusId",
                Value = ValidationHelper.GetGuid(new_FormConfirmStatusId.Value)
            });
        }

        //if (new_OperationType.Value != "")
        //{
        //    strSql += " And MT.new_OperationType = @new_OperationType ";
        //    spList.Add(new CrmSqlParameter()
        //    {
        //        Dbtype = DbType.Int32,
        //        Paramname = "new_OperationType",
        //        Value = ValidationHelper.GetInteger(new_OperationType.Value)
        //    });
        //}

        if (new_FileTransactionNumber.Value != "")
        {
            strSql += " And new_FileTransactionNumber = @new_FileTransactionNumber ";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_FileTransactionNumber",
                Value = new_FileTransactionNumber.Value
            });
        }

        if (new_PaymentDate2.Value != null)
        {

            strSql += " And (new_PaymentDateUtcTime>=@new_PaymentDate)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_PaymentDate",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_PaymentDate2.Value), App.Params.CurrentUser.SystemUserId)

            });
        }
        if (new_PaymentDate3.Value != null)
        {
            strSql += " And (new_PaymentDateUtcTime<@new_PaymentDate2)";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.DateTime,
                Paramname = "new_PaymentDate2",
                Value = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_PaymentDate3.Value).AddDays(1), App.Params.CurrentUser.SystemUserId)
            });
        }


         
        if (!String.IsNullOrEmpty( new_InstructionStartCorporationId.Value))
        {
            strSql += " And new_InstructionStartCorporationId=@new_InstructionStartCorporationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_InstructionStartCorporationId",
                Value = ValidationHelper.GetGuid(new_InstructionStartCorporationId.Value)
            });
        }
        return strSql;

    }
    
    protected void DocumentHistory(object sender, AjaxEventArgs e)
    {
        string filtermsg = GetFilterValidation();
        if (!string.IsNullOrEmpty(filtermsg))
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", filtermsg);

            GridPanelConfirmHistory.DataBind();
            return;
        }

        List<CrmSqlParameter> spList = new List<CrmSqlParameter>();
        //string filtre = " AND EXISTS (SELECT 1 FROM dbo.tvNew_ProcessMonitoring_20181127(@SystemuserId) MT WHERE MT.ID = TTD.TransferId" + GetFilters(out spList) +")";
        string filtre = GetFilters(out spList);

        var sd = new StaticData();

        int? operationType = null;
        int? transactionStatus = null;

        string transferTuRef = null;
        DateTime? startDate= null;
        DateTime? endDate = null;

        if (!String.IsNullOrEmpty(ProcessMonitoring.Value))
            transferTuRef = ProcessMonitoring.Value;

        if (!String.IsNullOrEmpty(cmbEArchiveOperationType.Value) )
            operationType = Convert.ToInt32(cmbEArchiveOperationType.Value);

        if (!String.IsNullOrEmpty(cmbEArchiveTransactionStatus.Value))
            transactionStatus = Convert.ToInt32(cmbEArchiveTransactionStatus.Value);

        if (!String.IsNullOrEmpty(new_FormTransactionDate1.Value.ToString()))
            startDate = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate1.Value), App.Params.CurrentUser.SystemUserId);

        if (!String.IsNullOrEmpty(new_FormTransactionDate2.Value.ToString()))
            endDate = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate2.Value), App.Params.CurrentUser.SystemUserId);


        sd.AddParameter("TransferTuRef", DbType.String, transferTuRef);
        sd.AddParameter("OperationTypeId", DbType.Int32, operationType);
        sd.AddParameter("TransactionStatusCode", DbType.Int32, transactionStatus);
        sd.AddParameter("StartDate", DbType.DateTime, ValidationHelper.GetDate( startDate));
        sd.AddParameter("EndDate", DbType.DateTime, ValidationHelper.GetDate(endDate));
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        foreach (var crmSqlParameter in spList)
        {
            sd.AddParameter(crmSqlParameter.Paramname, crmSqlParameter.Dbtype, crmSqlParameter.Value);
        }

        DataTable dt = sd.ReturnDataset(@"SELECT TTD.*
                                         FROM [dbo].[fnspMobileDocumentGetPoolList](@SystemUserId,@TransferTuRef,@OperationTypeId,@TransactionStatusCode,@StartDate,@EndDate) TTD
                                          WHERE 1=1 " + filtre  + "").Tables[0];

        GridPanelConfirmHistory.TotalCount = dt.Rows.Count;
        GridPanelConfirmHistory.DataSource = dt;
        GridPanelConfirmHistory.DataBind();

        
    }

    protected void EArchivePoolList(object sender, AjaxEventArgs e)
    {
        string filtermsg = GetFilterValidation();
        if (!string.IsNullOrEmpty(filtermsg))
        {
            var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
            ms.Show(".", filtermsg);

            GridPanelConfirmHistory.DataBind();
            return;
        }

        //string filtre = " AND EXISTS (SELECT 1 FROM dbo.tvNew_ProcessMonitoring_20181127(@SystemuserId) MT WHERE MT.ID = TTD.TransferId" + GetFilters(out spList) +")";

        var sd = new StaticData();

        int? operationType = null;
        int? transactionStatus = null;

        string transferTuRef = null;
        DateTime? startDate = null;
        DateTime? endDate = null;

        if (!String.IsNullOrEmpty(ProcessMonitoring.Value))
            transferTuRef = ProcessMonitoring.Value;

        if (!String.IsNullOrEmpty(cmbEArchiveOperationType.Value))
            operationType = Convert.ToInt32(cmbEArchiveOperationType.Value);

        if (!String.IsNullOrEmpty(cmbEArchiveTransactionStatus.Value))
            transactionStatus = Convert.ToInt32(cmbEArchiveTransactionStatus.Value);

        if (!String.IsNullOrEmpty(new_FormTransactionDate1.Value.ToString()))
            startDate = ValidationHelper.GetDate(new_FormTransactionDate1.Value);

        //startDate = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate1.Value), App.Params.CurrentUser.SystemUserId);

        if (!String.IsNullOrEmpty(new_FormTransactionDate2.Value.ToString()))
            endDate = ValidationHelper.GetDate(new_FormTransactionDate2.Value);

        //endDate = sd.FnLocalTimeToUtcForUser(ValidationHelper.GetDate(new_FormTransactionDate2.Value ), App.Params.CurrentUser.SystemUserId);


        Guid systemUserId = App.Params.CurrentUser.SystemUserId;

        EArchiveRequest req = new EArchiveRequest();
        req.SystemuserId = systemUserId;
        req.TransferTuRef = transferTuRef;
        req.OperationTypeId = operationType;
        req.TransactionStatus = transactionStatus;
        req.StartDate =  startDate.Value;
        req.EndDate = endDate.Value;
        req.SenderCountryID = ValidationHelper.GetGuid(new_SenderCountryID.Value);
        req.CorporationId = ValidationHelper.GetGuid(new_CorporationId.Value);
        req.OfficeId = ValidationHelper.GetGuid(new_OfficeId.Value);
        req.PayingCorporationId = ValidationHelper.GetGuid(new_PayingCorporationId.Value);
        req.PayingOfficeId = ValidationHelper.GetGuid(new_PayingOfficeId.Value);
        req.FormAmount1 = ValidationHelper.GetDecimal(new_FormAmount1.Value,0);
        req.FormAmount2 = ValidationHelper.GetDecimal(new_FormAmount2.Value,0);
        req.FormTransactionAmountCurrency = ValidationHelper.GetGuid(new_FormTransactionAmountCurrency.Value);
        req.FormReceiverCountryId = ValidationHelper.GetGuid(new_FormReceiverCountryId.Value);
        req.RecipientCorporationId = ValidationHelper.GetGuid(new_RecipientCorporationId.Value);
        req.RecipientFullName = new_RecipientFullName.Value;
        req.SenderId = ValidationHelper.GetGuid(new_SenderId.Value);
        req.FormConfirmStatusId = ValidationHelper.GetGuid(new_FormConfirmStatusId.Value);
        req.FileTransactionNumber = new_FileTransactionNumber.Value;
        req.PaymentDate2 = ValidationHelper.GetDate(new_PaymentDate2.Value);
        req.PaymentDate3 = ValidationHelper.GetDate(new_PaymentDate3.Value);
        req.InstructionStartCorporationId = ValidationHelper.GetGuid(new_InstructionStartCorporationId.Value);
        req.StartRow = GridPanelConfirmHistory.Start();
        req.Limit = GridPanelConfirmHistory.Limit();

        DataSet ds = GetEArchivePoolList(req);
        DataTable dt = ds.Tables[0];


        GridPanelConfirmHistory.TotalCount = ds.Tables[1].Rows[0].Field<int>("ROW_COUNT");
        GridPanelConfirmHistory.DataSource = dt;
        GridPanelConfirmHistory.DataBind();


    }

    public DataSet GetEArchivePoolList(EArchiveRequest req)
    {
        DataSet dt = null;
        try
        {
            var sd = new StaticData();
            sd.ClearParameters();
            sd.AddParameter("SystemuserId", DbType.Guid, ValidationHelper.GetGuid(req.SystemuserId, Guid.Empty));
            sd.AddParameter("TransferTuRef", DbType.String, req.TransferTuRef);
            sd.AddParameter("OperationTypeId ", DbType.Int32, req.OperationTypeId);
            sd.AddParameter("TransactionStatus ", DbType.Int32, req.TransactionStatus);
            sd.AddParameter("StartDate ", DbType.DateTime, ValidationHelper.GetDate(req.StartDate));
            sd.AddParameter("EndDate ", DbType.DateTime, ValidationHelper.GetDate(req.EndDate));
            sd.AddParameter("SenderCountryID", DbType.Guid, ValidationHelper.GetGuid(req.SenderCountryID, Guid.Empty));
            sd.AddParameter("CorporationId", DbType.Guid, ValidationHelper.GetGuid(req.CorporationId, Guid.Empty));
            sd.AddParameter("OfficeId", DbType.Guid, ValidationHelper.GetGuid(req.OfficeId, Guid.Empty));
            sd.AddParameter("PayingCorporationId", DbType.Guid, ValidationHelper.GetGuid(req.PayingCorporationId, Guid.Empty));
            sd.AddParameter("PayingOfficeId", DbType.Guid, ValidationHelper.GetGuid(req.PayingOfficeId, Guid.Empty));
            sd.AddParameter("FormAmount1", DbType.Decimal, req.FormAmount1);
            sd.AddParameter("FormAmount2", DbType.Decimal, req.FormAmount2);
            sd.AddParameter("FormTransactionAmountCurrency", DbType.Guid, ValidationHelper.GetGuid(req.FormTransactionAmountCurrency, Guid.Empty));
            sd.AddParameter("FormReceiverCountryId", DbType.Guid, ValidationHelper.GetGuid(req.FormReceiverCountryId, Guid.Empty));
            sd.AddParameter("RecipientCorporationId", DbType.Guid, ValidationHelper.GetGuid(req.RecipientCorporationId, Guid.Empty));
            sd.AddParameter("RecipientFullName", DbType.String, req.RecipientFullName);
            sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetGuid(req.SenderId, Guid.Empty));
            sd.AddParameter("FormConfirmStatusId", DbType.Guid, ValidationHelper.GetGuid(req.FormConfirmStatusId, Guid.Empty));
            sd.AddParameter("FileTransactionNumber", DbType.String, req.FileTransactionNumber);
            sd.AddParameter("PaymentDate2 ", DbType.DateTime, ValidationHelper.GetDate(req.PaymentDate2));
            sd.AddParameter("PaymentDate3 ", DbType.DateTime, ValidationHelper.GetDate(req.PaymentDate3));
            sd.AddParameter("InstructionStartCorporationId", DbType.Guid, ValidationHelper.GetGuid(req.InstructionStartCorporationId, Guid.Empty));
            sd.AddParameter("StartRow", DbType.Int32, req.StartRow);
            sd.AddParameter("Limit", DbType.Int32, req.Limit);

            //dt = sd.ReturnDatasetSp("spMobileDocumentGetPoolList").Tables[0];
            dt = sd.ReturnDatasetSp("spMobileDocumentGetPoolList");

        }
        catch (Exception ex)
        {
            dt = null;
            LogUtil.WriteException(ex, "EArchiveRequest.GetEArchivePoolList");
        }
        return dt;
    }


    private void TranslateMessages()
    {
        //ToolbarButtonTransfer.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_BTN_NEW_TRANSFER_RECORD");
        //ToolbarButtonPayment.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_BTN_NEW_PAYMENT_RECORD");

        //btnHold.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_HOLD");
        //btnResume.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_RESUME");
        
        pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_SEARCH");
        
        
        var all = CrmLabel.TranslateMessage("CRM.ENTITY_ALL");
        new_SenderCountryID.EmptyText = all;
        new_CorporationId.EmptyText = all;
        new_RecipientCorporationId.EmptyText = all;
        new_OfficeId.EmptyText = all;
        new_FormConfirmStatusId.EmptyText = all;
        new_FileTransactionNumber.EmptyText = all;
        //new_OperationType.EmptyText = all;
        
        //new_FormSourceTransactionTypeID.EmptyText = all;
        new_FormReceiverCountryId.EmptyText = all;
        //new_FormCustomerNumber.EmptyText = all;
        new_SenderId.EmptyText = all;
        new_RecipientFullName.EmptyText = all;
        new_PayingCorporationId.EmptyText = all;
        //new_Channel.EmptyText = all;
        new_PayingOfficeId.EmptyText = all;
        new_InstructionStartCorporationId.EmptyText = all;
    }

    private void FillLogInfo()
    {
        var entityId = TuFactory.Data.LogDb.GetBaseEntityId(TuEntityEnum.New_ProcessMonitoring.ToString());
        var recId = new TuFactory.Data.LogDb().GetLastRecordId(entityId);

        hdnEntityId.SetValue(entityId);
        hdnRecid.SetValue(recId);
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
                                END LIKE '%' + @CountryName + '%' 
                                OR CASE @TempLangId 
                                WHEN 1055 THEN UPPER(cl.Value COLLATE SQL_Latin1_General_CP1_CI_AS)
                                ELSE cl.Value
                                END LIKE '%' + UPPER(@CountryNameTR COLLATE SQL_Latin1_General_CP1_CI_AS) + '%' ) ";

            sd.AddParameter("CountryName", DbType.String, like.Replace("İ", "I"));
            like = like.Replace("i", "İ");
            like = like.Replace("ı", "I");

            sd.AddParameter("CountryNameTR", DbType.String, like);
        }

        strSql += " ORDER BY CountryName";

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
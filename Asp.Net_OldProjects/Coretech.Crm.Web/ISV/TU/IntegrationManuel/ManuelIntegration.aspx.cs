using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Reflection;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Data;
using TuFactory.Integration3rd;
using TuFactory.Integrationd3rdLayer.Object;
using TuFactory.Object;
using TuFactory.Object.Integration3Rd;
using TuFactory.Object.User;
using TuFactory.Sender;
using TuFactory.TransactionManagers.Transfer;

public partial class IntegrationManuel_ManuelIntegration : BasePage
{
    private TuUserApproval _userApproval = null;

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {

        }
        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

        if (App.Params.CurrentUser.SystemUserId != ValidationHelper.GetGuid("00000000-AAAA-BBBB-CCCC-000000000001"))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Role PrvCreate,PrvDelete,PrvWrite");
        }
    }

    protected void BtnControlClick(object sender, EventArgs e)
    {
        var sd = new StaticData();

        var selct = @"select New_TransferId, TransferTuRef from vNew_Transfer where TransferTuRef = @TransferTuRef";
        sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
        var ds = sd.ReturnDataset(selct);

        if (ds.Tables[0].Rows.Count == 0)
        {
            QScript("alert('Transfer Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        var transferId = Guid.Parse(ds.Tables[0].Rows[0]["New_TransferId"].ToString());
        var trans = (new StaticData()).GetDbTransaction();

        string IntegrationStatus = GetIntegrationStatus(transferId, trans);


        var sort = GrdTransfer.ClientSorts();
        if (sort == null)
            sort = string.Empty;


        string strSql = @"select  TransferTuRef AS VALUE
            ,CreatedOn 
            ,TransferTuRef
            ,New_TransferId AS ID,new_Confirmstatus,
                            new_ConfirmStatusName,new_TransactionItemId,new_TransactionItemIdName,
                            new_FileTransactionNumber,new_IntegrationChannel,new_IntegrationChannelName,";
        strSql += IntegrationStatus == string.Empty ? "'Unknown'" : "'" + IntegrationStatus + "'";
        strSql += @" AS IntegrationStatus
                            from vNew_Transfer where TransferTuRef = @TransferTuRef";
        var spList = new List<CrmSqlParameter>();
        spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "TransferTuRef", Value = TransferTuRef.Value });

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("ManuelIntegrationView");


        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GrdTransfer.Start();
        var limit = GrdTransfer.Limit();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        GrdTransfer.TotalCount = cnt;

        GrdTransfer.DataSource = t;
        GrdTransfer.DataBind();




    }

    protected void BtnConfirmClick(object sender, AjaxEventArgs e)
    {
        Integration3Rd integration = new Integration3Rd();

        var sd = new StaticData();

        var selct = @"select New_TransferId, TransferTuRef from vNew_Transfer where TransferTuRef = @TransferTuRef";
        sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
        var ds = sd.ReturnDataset(selct);

        if (ds.Tables[0].Rows.Count == 0)
        {
            QScript("alert('Transfer Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        var transferId = Guid.Parse(ds.Tables[0].Rows[0]["New_TransferId"].ToString());
        var trans = (new StaticData()).GetDbTransaction();

        try
        {
            //TuFactory.Domain.Transfer transfer = new TransferManager().GetTransfer(transferId);
            integration.IntegrateTransferConfirm(transferId,null, trans);
            StaticData.Commit(trans);
            QScript("alert('İşlem Başarı ile gerçekleştirildi.');");

        }
        catch (TuException ex)
        {
            QScript("alert('" + ex.ErrorMessage + "');");
            StaticData.Rollback(trans);
        }

        // Kankam Ellerinden Öper */

    }

    protected void BtnGetTotalDetail(object sender, AjaxEventArgs e)
    {
        StaticData sd = new StaticData();
        DbTransaction tr;
        DataTable dt = sd.ReturnDatasetSp(@"spGetCorporationGetTotalDetail").Tables[0];

        DataTable result = new DataTable();
        result.Columns.Add("TransferTuRef");
        result.Columns.Add("State");
        result.Columns.Add("Kurum");

        DataRow dr;
        foreach (DataRow item in dt.Rows)
        {
            dr = result.NewRow();
            dr["TransferTuRef"] = item["TransferTuRef"];
            dr["Kurum"] = item["Kurum"];

            try
            {
                var i3Rd = new Integration3Rd();
                var e3Rdl = new Entegration3rdList();

                e3Rdl = i3Rd.IntegrateGetDetail(ValidationHelper.GetGuid(item["new_TransferId"]), null);

                if (!string.IsNullOrEmpty(e3Rdl.tState))
                {
                    var tdb = new TransferDb();
                    tdb.UpdateConfirmStatusByIntegratorCode(ValidationHelper.GetGuid(item["new_TransferId"]), null, e3Rdl.tState, ValidationHelper.GetDate(e3Rdl.tPaidDate), App.Params.CurrentUser.SystemUserId);

                    dr["State"] = e3Rdl.tStateName;
                }
                else
                {
                    dr["State"] = "Başarısız";
                }
                result.Rows.Add(dr);

            }
            catch (Exception ex)
            {
                dr["State"] = ex.Message;
                result.Rows.Add(dr);
            }

        }


        GridPanel1.DataSource = result;
        GridPanel1.DataBind();
    }

    protected void BtnRequestClick(object sender, AjaxEventArgs e)
    {
        Integration3Rd integration = new Integration3Rd();
        var sd = new StaticData();

        var selct = @"select New_TransferId, TransferTuRef from vNew_Transfer where TransferTuRef = @TransferTuRef";
        sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
        var ds = sd.ReturnDataset(selct);

        if (ds.Tables[0].Rows.Count == 0)
        {
            QScript("alert('Transfer Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        var transferId = Guid.Parse(ds.Tables[0].Rows[0]["New_TransferId"].ToString());
        var trans = (new StaticData()).GetDbTransaction();

        try
        {
            TuFactory.Domain.Transfer transfer = new TransferManager().GetTransfer(transferId);

            integration.IntegrateTransferRequest(transferId, transfer, trans);
            StaticData.Commit(trans);
            QScript("alert('İşlem Başarı ile gerçekleştirildi.');");
        }
        catch (TuException ex)
        {
            QScript("alert('" + ex.ErrorMessage + "');");
            StaticData.Rollback(trans);
        }
    }

    protected void BtnCheckCorporation(object sender, AjaxEventArgs e)
    {
        StaticData sd = new StaticData();

        DataTable dt = sd.ReturnDatasetSp(@"spGetCancelledTransfer").Tables[0];

        DataTable result = new DataTable();
        result.Columns.Add("TransferTuRef");
        result.Columns.Add("State");
        result.Columns.Add("Kurum");

        DataRow dr;
        foreach (DataRow item in dt.Rows)
        {
            dr = result.NewRow();
            dr["TransferTuRef"] = item["TransferTuRef"];
            dr["Kurum"] = item["Kurum"];

            try
            {
                var i3Rd = new Integration3Rd();
                var e3Rdl = new Entegration3rdList();

                e3Rdl = i3Rd.IntegrateGetDetail(ValidationHelper.GetGuid(item["new_TransferId"]), null);

                dr["State"] = e3Rdl.tState + "-" + e3Rdl.tStateName;

                result.Rows.Add(dr);

            }
            catch (Exception ex)
            {
                dr["State"] = ex.Message;
                result.Rows.Add(dr);

            }

        }

        GridPanel1.DataSource = result;
        GridPanel1.DataBind();
    }

    protected void BtnCancelCorporation(object sender, AjaxEventArgs e)
    {
        StaticData sd = new StaticData();

        DataTable dt = sd.ReturnDatasetSp(@"spGetCancelledTransfer").Tables[0];

        DataTable result = new DataTable();
        result.Columns.Add("TransferTuRef");
        result.Columns.Add("State");
        result.Columns.Add("Kurum");

        DataRow dr;
        foreach (DataRow item in dt.Rows)
        {
            dr = result.NewRow();
            dr["TransferTuRef"] = item["TransferTuRef"];
            dr["Kurum"] = item["Kurum"];

            try
            {
                var i3Rd = new Integration3Rd();
                var e3Rdl = new Entegration3rdList();
                //TuFactory.Domain.Transfer transfer = new TransferManager().GetTransfer(ValidationHelper.GetGuid(item["new_TransferId"]));
                i3Rd.IntegrateTransferCancel(ValidationHelper.GetGuid(item["new_TransferId"]), null);

                dr["State"] = "Başarılı";

                result.Rows.Add(dr);

            }
            catch (Exception ex)
            {
                dr["State"] = ex.Message;
                result.Rows.Add(dr);
            }

        }

        GridPanel1.DataSource = result;
        GridPanel1.DataBind();
    }


    protected void BtnConfirmPaymentCorporation(object sender, AjaxEventArgs e)
    {
        StaticData sd = new StaticData();
        DbTransaction tr = sd.GetDbTransaction();
        DataTable dt = sd.ReturnDatasetSp(@"spGetCorporationPaymentConfirm").Tables[0];

        DataTable result = new DataTable();
        result.Columns.Add("TransferTuRef");
        result.Columns.Add("State");
        result.Columns.Add("Kurum");

        DataRow dr;
        foreach (DataRow item in dt.Rows)
        {
            dr = result.NewRow();
            dr["TransferTuRef"] = item["TransferTuRef"];
            dr["Kurum"] = item["Kurum"];

            try
            {
                var i3Rd = new Integration3Rd();
                var e3Rdl = new Entegration3rdList();

                i3Rd.IntegratePaymentConfirm(ValidationHelper.GetGuid(item["new_TransferId"]), ValidationHelper.GetGuid(item["new_PaymentId"]), tr);

                dr["State"] = "Başarılı";

                result.Rows.Add(dr);

            }
            catch (Exception ex)
            {
                dr["State"] = ex.Message;
                result.Rows.Add(dr);
            }

        }
        StaticData.Commit(tr);

        GridPanel1.DataSource = result;
        GridPanel1.DataBind();
    }


    protected void BtnGetLocationCatalogByFTP(object sender, AjaxEventArgs e)
    {
        //Location location = new Location();
        ////location.GetLocationsFromService();

        //location.GetInsertCommission();
    }

    protected void BtnGetRequirements(object sender, AjaxEventArgs e)
    {
        //Location location = new Location();
        //location.GetRequirements();
    }

    protected void BtnGetRates(object sender, AjaxEventArgs e)
    {
        var ret = new CurrencyRateReturnType();

        var i3rd = new TuFactory.Integration3rd.Integration3Rd();
        TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = i3rd.GetIntegratorByRecipientCorporationId(ValidationHelper.GetGuid("0BFC8B02-2253-4D83-9311-CCFEE14178CB"));

        ret = Integrator.GetCurrencyRate(new IntagrateRateInput()
        {
            Amount = ValidationHelper.GetDecimal(100, 0),
            FromCurrencyCode = "EUR",
            ToCurrencyCode = "USD",
            ExchangeDate = DateTime.Now
        });


        //ExchanceRate exchanceRate = new ExchanceRate();
        //var ret = exchanceRate.GetExchanceRate(new IntegrateInput() { RateDate = DateTime.Now });

    }


    protected void BtnVirtualIbanUpdate(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();
        var ds = sd.ReturnDatasetSp("spTuGetCustAccountForVirtualIban");

        if (ds.Tables[0].Rows.Count == 0)
        {
            QScript("alert('Ibanı olmayan hesap yok');");
            return;
        }
        else
        {
            SenderAfterSaveDb service = new SenderAfterSaveDb();
            string iban = string.Empty;
            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                try
                {
                    iban = string.Empty;
                    iban = service.getVirtualIban(ds.Tables[0].Rows[i]["Sender"].ToString(), ds.Tables[0].Rows[i]["CurrencyCode"].ToString(), ds.Tables[0].Rows[i]["CustAccountNumber"].ToString(),string.Empty);
                    if (!string.IsNullOrEmpty(iban))
                    {
                        sd.ClearParameters();
                        sd.AddParameter("CustAccountId", DbType.Guid, ValidationHelper.GetGuid(ds.Tables[0].Rows[i]["CustAccountsId"]));
                        sd.AddParameter("Iban", DbType.String, iban);
                        sd.ExecuteNonQuerySp("spTuUpdateCustAccountForVirtualIban");
                    }
                }
                catch (Exception ex)
                {
                    LogUtil.WriteException(ex, "ManuelIntegration.getVirtualIban", "VirtualIban");
                }
               
            }
        }

    }

    protected void BtnGetLocalRates(object sender, AjaxEventArgs e)
    {
        var ret = new CurrencyRateReturnType();

        var i3rd = new TuFactory.Integration3rd.Integration3Rd();
        TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = i3rd.GetIntegratorByRecipientCorporationId(ValidationHelper.GetGuid("0BFC8B02-112B-4490-9498-21D7A206845C"));

        ret = Integrator.GetCurrencyRate(new IntagrateRateInput()
        {
            Amount = ValidationHelper.GetDecimal(100, 0),
            FromCurrencyCode = "EUR",
            ToCurrencyCode = "USD",
            ExchangeDate = DateTime.Now
        });


        //ExchanceRate exchanceRate = new ExchanceRate();
        //var ret = exchanceRate.GetExchanceRate(new IntegrateInput() { RateDate = DateTime.Now });

    }

    protected void BtnPaymentRequestClick(object sender, AjaxEventArgs e)
    {
        Integration3Rd integration = new Integration3Rd();
        var sd = new StaticData();

        var selct = @"select New_TransferId,new_PaymentId, TransferTuRef from vNew_Transfer where TransferTuRef = @TransferTuRef ";
        sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
        var ds = sd.ReturnDataset(selct);

        if (ds.Tables[0].Rows.Count == 0)
        {
            QScript("alert('Ödeme Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        if (ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_PaymentId"], Guid.Empty) == Guid.Empty)
        {
            QScript("alert('Ödeme Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        var transferId = Guid.Parse(ds.Tables[0].Rows[0]["New_TransferId"].ToString());
        var paymentId = ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_PaymentId"].ToString(), Guid.Empty);
        var trans = (new StaticData()).GetDbTransaction();

        try
        {
            integration.IntegratePaymentRequest(transferId, paymentId, trans);
            StaticData.Commit(trans);
            QScript("alert('İşlem Başarı ile gerçekleştirildi.');");
        }
        catch (TuException ex)
        {
            QScript("alert('" + ex.ErrorMessage + "');");
            StaticData.Rollback(trans);
        }
    }

    protected void BtnPaymentConfirmClick(object sender, AjaxEventArgs e)
    {
        Integration3Rd integration = new Integration3Rd();
        var sd = new StaticData();

        var selct = @"select New_TransferId,new_PaymentId, TransferTuRef from vNew_Transfer where TransferTuRef = @TransferTuRef ";
        sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
        var ds = sd.ReturnDataset(selct);

        if (ds.Tables[0].Rows.Count == 0)
        {
            QScript("alert('Ödeme Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        if (ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_PaymentId"], Guid.Empty) == Guid.Empty)
        {
            QScript("alert('Ödeme Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        var transferId = Guid.Parse(ds.Tables[0].Rows[0]["New_TransferId"].ToString());
        var paymentId = ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_PaymentId"].ToString(), Guid.Empty);
        var trans = (new StaticData()).GetDbTransaction();

        try
        {
            integration.IntegratePaymentConfirm(transferId, paymentId, trans);
            StaticData.Commit(trans);
            QScript("alert('İşlem Başarı ile gerçekleştirildi.');");
        }
        catch (TuException ex)
        {
            QScript("alert('" + ex.ErrorMessage + "');");
            StaticData.Rollback(trans);
        }
    }

    protected void BtnPaymentCancelClick(object sender, AjaxEventArgs e)
    {
        Integration3Rd integration = new Integration3Rd();
        var sd = new StaticData();

        var selct = @"select New_TransferId,new_PaymentId, TransferTuRef from vNew_Transfer where TransferTuRef = @TransferTuRef ";
        sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
        var ds = sd.ReturnDataset(selct);

        if (ds.Tables[0].Rows.Count == 0)
        {
            QScript("alert('Ödeme Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        if (ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_PaymentId"], Guid.Empty) == Guid.Empty)
        {
            QScript("alert('Ödeme Yok yada Entegrasyon Kanalına Sahip Değil.');");
            return;
        }
        var transferId = Guid.Parse(ds.Tables[0].Rows[0]["New_TransferId"].ToString());
        var paymentId = ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_PaymentId"].ToString(), Guid.Empty);
        var trans = (new StaticData()).GetDbTransaction();

        try
        {
            integration.IntegratePaymentCancel(transferId, paymentId, trans);
            StaticData.Commit(trans);
            QScript("alert('İşlem Başarı ile gerçekleştirildi.');");
        }
        catch (TuException ex)
        {
            QScript("alert('" + ex.ErrorMessage + "');");
            StaticData.Rollback(trans);
        }
    }

    public string GetIntegrationStatus(Guid transferId, DbTransaction trans)
    {
        string ret = "";
        DataListReturnType _3rdrecord = null;
        TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = GetIntegratorByTransferId(transferId, trans);

        if (Integrator != null && Integrator.CanGetDetail)
        {
            var tdb = new TransferDb();
            try
            {
                _3rdrecord = Integrator.GetDetail(new IntegrateInput() { Trans = trans, SystemUserId = App.Params.CurrentUser.SystemUserId, TransferId = transferId });
            }
            catch (Exception exc)
            {
                //var errCode = LogUtil.WriteException(exc, "TuFactory.Integration3rd.Integration3Rd	006", "Exception");
                //throw new TuException(exc.Message, errCode.ToString()) { ErrorId = errCode };
                ret = "";
            }
            if (_3rdrecord != null)
            {
                if (_3rdrecord.OutputStatus.RESPONSE == IntegrationStatus.response.Error)
                {
                    ret = "";
                }
                else if (_3rdrecord.OutputStatus.RESPONSE == IntegrationStatus.response.Success)
                {
                    ret = _3rdrecord.Data.Tables[0].Rows[0]["trnState"].ToString();
                    ret = tdb.GetIntegratorCode(Integrator.IntegrationChannelId, ret);
                }
            }
            else
            {
                ret = "";
            }

        }
        else
        {
            ret = "";
        }
        return ret;



    }

    private TuFactory.Integrationd3rdLayer.Integrationd3rd GetIntegratorByTransferId(Guid transferId, DbTransaction trans)
    {
        TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = null;
        Guid integrationChannelId = Guid.Empty;
        string strClass = GetTransferIntegrationClass(transferId, trans, out integrationChannelId);
        string[] str = strClass.Split(",".ToCharArray());
        if (str.Length == 2)
        {
            Assembly assembly = Assembly.Load(str[1].Trim());
            if (assembly != null)
            {
                Type type = assembly.GetType(str[0].Trim());
                Integrator = Activator.CreateInstance(type) as TuFactory.Integrationd3rdLayer.Integrationd3rd;
                Integrator.IntegrationChannelId = integrationChannelId;
            }
        }
        return Integrator;

    }

    private string GetTransferIntegrationClass(Guid transferId, DbTransaction trans, out Guid integrationChannel)
    {
        var tdb = new TransferDb();
        var strClass = tdb.GetIntegrationClass(transferId, trans, out integrationChannel);
        return strClass;
    }


}
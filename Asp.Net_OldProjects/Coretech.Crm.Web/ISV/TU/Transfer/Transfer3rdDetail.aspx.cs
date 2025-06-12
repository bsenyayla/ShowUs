using System;
using System.Collections.Generic;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Integration3rd;
using TuFactory.Object.Integration3Rd;
using TuFactory.Data;
using Coretech.Crm.Factory;
using TuFactory.Object;
using TuFactory.WebServicesRemote;
using TuFactory.Object.CorpIntegration;
using System.Data.Common;
using Coretech.Crm.PluginData;
using TuFactory.Integrationd3rdLayer.Object;
using System.Data;
using System.Linq;



public partial class Transfer_Transfer3rdDetail : BasePage
{
    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
            ButtonConfirm.Text = CrmLabel.TranslateMessage("CRM.NEW_CONFIRMSTATUS_NEW_CONFIRMTYPE_ONAY");
            ConfirmPnl.Hidden = true;
            ConfirmPnl.Hide();
          
            //CreateViewGrid();
        }

    }

    //public void CreateViewGrid()
    //{
    //    var gpc = new GridPanelCreater();
    //    gpc.CreateViewGrid("PROCESSMONITORING_DETAIL", GridPanelMonitoring);
    //    string strSelected;
    //    strSelected = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING_DETAIL").ToString();
    //    hdnViewList.Value = strSelected;

    //    if (string.IsNullOrEmpty(strSelected))
    //        return;
    //    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
    //    var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
    //    hdnViewDefaultEditPage.Value = DefaultEditPage;


    //}
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {

        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;

        var recId = QueryHelper.GetString("RecordId");

        var i3Rd = new Integration3Rd();
        var lst = new List<object>();

        var e3Rdl = new Entegration3rdList();
        try
        {
            e3Rdl = i3Rd.IntegrateGetDetail(ValidationHelper.GetGuid(recId), null);
        }
        catch (TuException exc)
        {
            exc.Show();
            return;
        }
        catch (Exception)
        {
            throw;
        }

        //var abc = new Integrationd3rd.Russlavbank.Factory.Action.OutgoingSent();
        //abc.GoOutgoingSent();


        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_TSTATE"), Value = e3Rdl.tStateName });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_PAIDDATE"), Value = e3Rdl.tPaidDate });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_CANCELDATE"), Value = e3Rdl.tCancelDate });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BNAME"), Value = e3Rdl.bName });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BLASTNAME"), Value = e3Rdl.bLastName });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BSURNAME"), Value = e3Rdl.bSurName });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BBIRTHDAY"), Value = e3Rdl.bBirthDay });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BCOUNTRY"), Value = e3Rdl.bCountry });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BZIPCODE"), Value = e3Rdl.bZipCode });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BREGION"), Value = e3Rdl.bRegion });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BCITY"), Value = e3Rdl.bCity });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BADRESS"), Value = e3Rdl.bAddress });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BPHONE"), Value = e3Rdl.bPhone });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BIDTYPE"), Value = e3Rdl.bIDtype });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BIDNUMBER"), Value = e3Rdl.bIDnumber });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BIDDATE"), Value = e3Rdl.bIDdate });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BIDWHOM"), Value = e3Rdl.bIDwhom });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BIDEXPIREDATE"), Value = e3Rdl.bIDexpireDate });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BSHOWEDIDTYPE"), Value = e3Rdl.bShowedIDtype });
        lst.Add(new { ColumnName = CrmLabel.TranslateMessage("CRM.NEW_INTEGRATIONCHANNEL_BSHOWEDIDNUMBER"), Value = e3Rdl.bShowedIDnumber });

        lst.Add(e3Rdl);
        GridPanelMonitoring.DataSource = lst;
        GridPanelMonitoring.DataBind();

        TransferDb tdb = new TransferDb();

        if (!ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("CORPPAYMENT_AUTO_ACCOUNTING", "false")))
        {
            tdb = new TransferDb();
            tdb.UpdateConfirmStatusByIntegratorCode(ValidationHelper.GetGuid(recId), null, e3Rdl.tState, ValidationHelper.GetDate(e3Rdl.tPaidDate), App.Params.CurrentUser.SystemUserId);
        }
        else
        {
            tdb = new TransferDb();

            if (tdb.CheckTransferIsPaidByPartnerStatus(e3Rdl.IntegrationChannelId, e3Rdl.tState))
            {
                DbTransaction tr = StaticData.GetDbStaticTransaction();
                try
                {

                    Guid paymentId;
                    string paymentRef;
                    string TuRefNumber;


                    tdb.GetTransferAndPayment(ValidationHelper.GetGuid(recId), tr, out TuRefNumber, out paymentId, out paymentRef);


                    /*Ödeme için Akustik çağrılacak*/
                    #region Accounting Request

                    var arequest = new Accounting();
                    var aRequestdata = new WSAccounting { TU_REFERANS = TuRefNumber, ISLEM = "O", PaymentId = paymentId };

                    aRequestdata = arequest.TransferAccounting(aRequestdata, false, tr);
                    if (aRequestdata.AccStatus.RESPONSE == WsStatus.response.Error)
                    {
                        var exc = new TuException
                        {
                            ErrorMessage = aRequestdata.AccStatus.RESPONSE_DATA
                        };
                        throw exc;
                    }
                    if (aRequestdata.AccStatus.RESPONSE == WsStatus.response.Success)
                    {
                        tdb.PaymentAccountingAfterRequest(aRequestdata, tr);
                    }
                    #endregion

                    #region Accounting Confirm

                    string bankaIslemNoOut;

                    var cdb = new ConfirmDb();
                    cdb.GetPaymentTuref(ValidationHelper.GetString(paymentRef), tr, out bankaIslemNoOut, out paymentId);
                    var acRequestdata = new WSAccounting { BANKA_ISLEM_NO_OUT = bankaIslemNoOut, ISLEM = "O", PaymentId = paymentId };
                    var aconfirm = new AccountingConfirm();
                    //confirm gonderiminden ne gelirse gelsin bizi ilgilendirmez.
                    try
                    {
                        cdb.SetMutabakatIslemTarihi(TuEntityEnum.New_Payment.GetHashCode(), paymentId, tr);
                        var result = aconfirm.TransferAccountingConfirm(acRequestdata, tr);
                        if (result.AccStatus.RESPONSE == WsStatus.response.Error)
                        {
                            var exc = new TuException
                            {
                                ErrorMessage = result.AccStatus.RESPONSE_DATA
                            };
                            throw exc;
                        }
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }

                    #endregion

                    tdb.UpdateConfirmStatusByIntegratorCodeWithTran(ValidationHelper.GetGuid(recId), null, e3Rdl.tState, App.Params.CurrentUser.SystemUserId, tr);

                    StaticData.Commit(tr);
                }
                catch (Exception)
                {
                    StaticData.Rollback(tr);
                }

            }
        }

        LoadItems(e3Rdl.tStateName);




    }

    protected void LoadItems(string corpStatus)
    {
        var transferId = QueryHelper.GetString("RecordId");
        var staticData = new StaticData();
        staticData.ClearParameters();
        staticData.AddParameter("@TransferId", DbType.Guid, ValidationHelper.GetGuid(ValidationHelper.GetGuid(transferId)));
        staticData.AddParameter("@CorpStatus", DbType.String, corpStatus);
        DataSet dataSet = staticData.ReturnDataset(@"SELECT 		
	    icc.new_CodeDefinition	AS PartnerStatusCode,
	    cs.new_Code As TuStatusCode
		FROM
	    vNew_Transfer tr (nolock) 
	    INNER JOIN vNew_ConfirmStatus (NOLOCK) cs ON cs.New_ConfirmStatusId=tr.new_ConfirmStatus
		INNER JOIN vNew_Corporation crp ON crp.New_CorporationId = tr.new_RecipientCorporationId  AND crp.DeletionStateCode=0
		INNER JOIN vNew_IntegrationChannel ic ON ic.New_IntegrationChannelId= crp.new_IntegrationChannelId  AND ic.DeletionStateCode=0
        LEFT JOIN vNew_IntegrationChannelCodes icc ON icc.new_IntegrationChannelId= ic.New_IntegrationChannelId   AND icc.DeletionStateCode=0
	    WHERE  tr.New_TransferId=@TransferId AND ( icc.IntegrationChannelCode=@CorpStatus or icc.new_Name=@CorpStatus )");

        if (dataSet != null && dataSet.Tables.Count > 0)
        {
            if (dataSet.Tables[0].Rows.Count > 0)
            {
                string PartnerStatusCode = ValidationHelper.GetString(dataSet.Tables[0].Rows[0]["PartnerStatusCode"]);
                string TuStatusCode = ValidationHelper.GetString(dataSet.Tables[0].Rows[0]["TuStatusCode"]);

                if (new[] { "TR010", "TR012" }.Contains(TuStatusCode) && PartnerStatusCode == "3")
                {                  
                    ConfirmPnl.Hidden = false;
                    ConfirmPnl.Show();
                }
                else
                {

                    ConfirmPnl.Hidden = true;
                    ConfirmPnl.Hide();
                }
            }
        }
        else
        {

            ConfirmPnl.Hidden = true;
            ConfirmPnl.Hide();
        }


    }

    protected void BtnConfirmClick(object sender, AjaxEventArgs e)
    {
        try
        {
            var i3Rd = new Integration3Rd();
            var transferId = QueryHelper.GetString("RecordId");
            TransferReturnType result = null;

            result = i3Rd.IntegrateTransferConfirm(ValidationHelper.GetGuid(transferId), null, null);
            if (result != null && result.OutputStatus != null)
            {
                if (result.OutputStatus.RESPONSE == IntegrationStatus.response.Success)
                {
                    msg.Show("", ". ", " İşlem başarı ile tamamlandı");
                }
                else
                {
                    msg.Show("", "Hata ", result.OutputStatus.RESPONSE_DATA);
                }
            }
        }
        catch (TuException exc)
        {
            exc.Show();
        }
        catch (Exception ex)
        {
            msg.Show("", ex.Message);
        }

    }
}
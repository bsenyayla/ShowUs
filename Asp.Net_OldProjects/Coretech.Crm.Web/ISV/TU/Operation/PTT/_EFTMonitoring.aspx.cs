using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
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

public partial class Operation_PTT_EFT_Monitoring : BasePage
{
    private DynamicSecurity _dynamicSecurityTransfer;
    private DynamicSecurity _dynamicSecurityPayment;
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private void TranslateMessages()
    {
        //ToolbarButtonTransfer.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_BTN_NEW_TRANSFER_RECORD");
        //ToolbarButtonPayment.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_BTN_NEW_PAYMENT_RECORD");

        //btnHold.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_HOLD");
        //btnResume.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_TO_RESUME");
        //btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        //pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_SEARCH");
        //BtnSb1.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_LIST_TOTAL");
        //windowTotal.Title = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_LIST_TOTAL");
        //var all = CrmLabel.TranslateMessage("CRM.ENTITY_ALL");
        //new_SenderCountryID.EmptyText = all;
        //new_CorporationId.EmptyText = all;
        //new_RecipientCorporationId.EmptyText = all;
        //new_OfficeId.EmptyText = all;
        //new_FormConfirmStatusId.EmptyText = all;
        //new_FileTransactionNumber.EmptyText = all;
        //new_OperationType.EmptyText = all;
        //new_FormTransactionTypeID.EmptyText = all;
        //new_FormSourceTransactionTypeID.EmptyText = all;
        //new_FormReceiverCountryId.EmptyText = all;
        //new_FormCustomerNumber.EmptyText = all;
        //new_SenderId.EmptyText = all;
        //new_RecipientFullName.EmptyText = all;
        //new_PayingCorporationId.EmptyText = all;
        //new_Channel.EmptyText = all;
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
            //pnl1.Title = "EFT İşlemleri";
        }
        //else pnl1. = "drdrdrdrdr";
        DateFieldBegin.SetValue(DateTime.Now);

        FillField();

        FillGrid();
    }


    public void ButtonFindClick(object sender, AjaxEventArgs e)
    {
        FillField();

        FillGrid();

    }


    public void GoldenCrownDeneme(object sender, AjaxEventArgs e)
    {
        //TuFactory.WebServicesRemote.AktifNoktaIntegrations AktifNoktaTestCode = new TuFactory.WebServicesRemote.AktifNoktaIntegrations();
        //AktifNoktaTestCode.IntegrateLocations();

        //TuFactory.WebServicesRemote.GoldenCrownIntegrations goldenCrownTestCode = new TuFactory.WebServicesRemote.GoldenCrownIntegrations();
        //goldenCrownTestCode.IntegrateCities();

        //TuFactory.WebServicesRemote.PttIntegrations pttIntegrationsss = new TuFactory.WebServicesRemote.PttIntegrations();
        //pttIntegrationsss.IntegratePttAllOffices(Guid.Parse("00000000-AAAA-BBBB-CCCC-000000000001"));

        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        string encData = cryptor.EncryptInString(denemeTextInput.Value);
        denemeTextField.Value = encData;
        denemeTextField.SetIValue(encData);
        denemeTextField.SetValue(encData);
    }

    public void GoldenCrownDeneme2(object sender, AjaxEventArgs e)
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        string decData = cryptor.DecryptInString(denemeTextField.Value);
        TextField1.Value = decData;
        TextField1.SetIValue(decData);
        TextField1.SetValue(decData);
    }

    public void GoldenCrownDeneme3(object sender, AjaxEventArgs e)
    {
        ////<add key="AktifBankUserName" value="TRUNION_USER" />
        ////<add key="AktifBankPassword" value="326b1650c9f4c3dd91d25a16665636e916730c61" />
        ////<add key="AktifBankLanguage" value="en" />
        ////<add key="AktifBankChannel" value="TRUNION" />

        //TuFactory.MarketingServices.CustomerApp_PortTypeClient client = new TuFactory.MarketingServices.CustomerApp_PortTypeClient();
        //string sessionId = client.LOGIN("TRUNION_USER", "326b1650c9f4c3dd91d25a16665636e916730c61", "en", "TRUNION");
        //TuFactory.MarketingServices.WEBEXT_CUSTOMER_APP_GET_MARKETING_PERMISSION_LISTResponse__LIST[] LIST = new TuFactory.MarketingServices.WEBEXT_CUSTOMER_APP_GET_MARKETING_PERMISSION_LISTResponse__LIST[0];
        ////string response = client.WEBEXT_CUSTOMER_APP_GET_MARKETING_PERMISSION_LIST(new Services.HEADER() { SESSION_ID = sessionId }, "22399693496", "", "", "", "TR", "EUPT", out RESPONSE_DATA, out LIST);
        //string response = string.Empty;
        //string RESPONSE_DATA = string.Empty;
        //response = client.WEBEXT_CUSTOMER_APP_GET_MARKETING_PERMISSION_LIST(new TuFactory.MarketingServices.HEADER() { SESSION_ID = sessionId }, TextField1.Value, "", "", "", "TR", "EUPT", out RESPONSE_DATA, out LIST);

        //string result = string.Empty;

        //result = DateTime.Now.ToString();
        //result += " -*- Response:   " + response;
        //result += " -*- Data:   " + RESPONSE_DATA;
        //result += " -*- List Count:" + LIST.Length.ToString();
        //if (LIST.Length > 0)
        //{
        //    for (int indexOfLIST = 0; indexOfLIST < LIST.Length; indexOfLIST++)
        //    {
        //        result += " -*- F_MAIL: " + LIST[indexOfLIST].F_MAIL;
        //        result += " -*- F_SMS: " + LIST[indexOfLIST].F_SMS;
        //        result += " -*- F_TELEFON: " + LIST[indexOfLIST].F_TELEFON;
        //        result += " -*- KANAL_KOD: " + LIST[indexOfLIST].KANAL_KOD;
        //    }
        //}
        TuFactory.WebServicesRemote.Marketing marketing = new TuFactory.WebServicesRemote.Marketing();
        TuFactory.WebServicesRemote.Marketing market = new TuFactory.WebServicesRemote.Marketing();
        //TuFactory.WebService.MarketingSrv marketing = new TuFactory.WebService.MarketingSrv();
        WSMarketingRequest request = new WSMarketingRequest();
        request.TCKN = TextField2.Value;
        request.COUNTRY_CODE = "TR";
        request.CHANNEL = "EUPT";
        string result = marketing.GetMarketing(request).LIST[0].F_MAIL;
        TextField3.SetIValue(result);

    }

    protected void FillGrid()
    {
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;

        string strSqlMain = @"
SELECT * FROM vNew_PTTTransactions";

        var sd = new StaticData();
        DataTable dt;

        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING");
        //var gpc = new GridPanelCreater();
        //var cnt = 0;
        //var start = GridPanelMonitoring.Start();
        //var limit = GridPanelMonitoring.Limit();
        //DataTable dtb;
        //List<CrmSqlParameter> spList = new List<CrmSqlParameter>();
        //var t = gpc.GetFilterData(strSqlMain, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        //GridPanelMonitoring.TotalCount = cnt;
        try
        {
            dt = sd.ReturnDataset(strSqlMain).Tables[0];
        }
        catch (Exception)
        {
            throw;
        }

        GridPanelMonitoring.TotalCount = dt.Rows.Count;
        GridPanelMonitoring.DataSource = dt;
        GridPanelMonitoring.DataBind();
    }

    protected void FillField()
    {
        var sd = new StaticData();

        /*ScreenType;
        1: EFT
        2: Ödeme
        3: YPUPT
        4: İade         */
        sd.AddParameter("@ScreenType", DbType.Int32, 1);
        sd.AddParameter("@TransactionDateBegin", DbType.Date, DateFieldBegin.Value);
        //sd.AddParameter("@TransactionDateEnd", DbType.Date, DateFieldEnd.Value); Bu geeceğe yönelik kondu. Tarih aralığı istendiğinde devreye alınacak.
        sd.AddParameter("@TransactionDateEnd", DbType.Date, DBNull.Value);
        DataTable dt;

        try
        {
            dt = sd.ReturnDatasetSp("SpPTTAgreementMonitorTable").Tables[0];
        }
        catch (Exception)
        {
            throw;
        }

        if (dt != null && dt.Rows.Count > 0)
        {
            System.Globalization.CultureInfo culInfo = new System.Globalization.CultureInfo("tr-TR");
            NumberStyles styla = new NumberStyles();

            //TRY PTT Bank
            TextBox_Data1_GidUITop0.Text = dt.Rows[0]["GidenUPTIslemToplam"].ToString() != String.Empty ? dt.Rows[0]["GidenUPTIslemToplam"].ToString() : "0";
            TextBox_Data1_GidUMTop0.Text = dt.Rows[0]["GidenUPTMasrafToplam"].ToString() != String.Empty ? dt.Rows[0]["GidenUPTMasrafToplam"].ToString() : "0";
            TextBox_Data1_GidUGTop0.Text = dt.Rows[0]["GidenUPTGenelToplam"].ToString() != String.Empty ? dt.Rows[0]["GidenUPTGenelToplam"].ToString() : "0";
            TextBox_Data1_GidUIAded0.Text = dt.Rows[0]["GidenUPTIslemAdet"].ToString() != String.Empty ? dt.Rows[0]["GidenUPTIslemAdet"].ToString() : "0";
            TextBox_Data1_IpGidUTop0.Text = dt.Rows[0]["IptalGidenUPTToplam"].ToString() != String.Empty ? dt.Rows[0]["IptalGidenUPTToplam"].ToString() : "0";
            TextBox_Data1_IpGidUMasTop0.Text = dt.Rows[0]["IptalGidenUPTMasrafToplam"].ToString() != String.Empty ? dt.Rows[0]["IptalGidenUPTMasrafToplam"].ToString() : "0";
            TextBox_Data1_IpGidUAded0.Text = dt.Rows[0]["IptalGidenUPTAdet"].ToString() != String.Empty ? dt.Rows[0]["IptalGidenUPTAdet"].ToString() : "0";
            TextBox_Data1_Borc0.Text = dt.Rows[0]["BORC"].ToString() != String.Empty ? dt.Rows[0]["BORC"].ToString() : "0";
            //TRY UPT
            TextBox_Data1_GidUITop1.Text = dt.Rows[1]["GidenUPTIslemToplam"].ToString() != String.Empty ? dt.Rows[1]["GidenUPTIslemToplam"].ToString() : "0";
            TextBox_Data1_GidUMTop1.Text = dt.Rows[1]["GidenUPTMasrafToplam"].ToString() != String.Empty ? dt.Rows[1]["GidenUPTMasrafToplam"].ToString() : "0";
            TextBox_Data1_GidUGTop1.Text = dt.Rows[1]["GidenUPTGenelToplam"].ToString() != String.Empty ? dt.Rows[1]["GidenUPTGenelToplam"].ToString() : "0";
            TextBox_Data1_GidUIAded1.Text = dt.Rows[1]["GidenUPTIslemAdet"].ToString() != String.Empty ? dt.Rows[1]["GidenUPTIslemAdet"].ToString() : "0";
            TextBox_Data1_IpGidUTop1.Text = dt.Rows[1]["IptalGidenUPTToplam"].ToString() != String.Empty ? dt.Rows[1]["IptalGidenUPTToplam"].ToString() : "0";
            TextBox_Data1_IpGidUMasTop1.Text = dt.Rows[1]["IptalGidenUPTMasrafToplam"].ToString() != String.Empty ? dt.Rows[1]["IptalGidenUPTMasrafToplam"].ToString() : "0";
            TextBox_Data1_IpGidUAded1.Text = dt.Rows[1]["IptalGidenUPTAdet"].ToString() != String.Empty ? dt.Rows[1]["IptalGidenUPTAdet"].ToString() : "0";
            TextBox_Data1_Borc1.Text = dt.Rows[1]["BORC"].ToString() != String.Empty ? dt.Rows[1]["BORC"].ToString() : "0";
        }
    }

    //protected void btnEft(object sender, AjaxEventArgs e)
    //{
    //    pnl1.Title = "EFT İşlemleri";

    //    ColumnLayoutEUR.SetVisible(false);
    //    ColumnLayoutUSD.SetVisible(false);
    //}

    //protected void btnYpUpt(object sender, AjaxEventArgs e)
    //{
    //    pnl1.Title = "YPUPT İşlemleri";

    //    ColumnLayoutEUR.SetVisible(true);
    //    ColumnLayoutUSD.SetVisible(true);
    //}

    //protected void btnPayment(object sender, AjaxEventArgs e)
    //{
    //    pnl1.Title = "Ödeme İşlemleri";

    //    ColumnLayoutEUR.SetVisible(true);
    //    ColumnLayoutUSD.SetVisible(true);
    //}

    //protected void btnCancels(object sender, AjaxEventArgs e)
    //{
    //    pnl1.Title = "İade Ödeme İşlemleri";

    //    ColumnLayoutEUR.SetVisible(true);
    //    ColumnLayoutUSD.SetVisible(true);
    //}

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;

        string strSqlMain = @"";

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("PROCESSMONITORING");
        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        DataTable dtb;
        List<CrmSqlParameter> spList;
        //string strSql = GetFilters(out spList);
        //var t = gpc.GetFilterData(strSqlMain + strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelMonitoring.TotalCount = cnt;

        try
        {
            //if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            //{
            //    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
            //    gpw.Export(dtb);

            //}

        }
        catch (Exception)
        {

            throw;
        }
        //GridPanelMonitoring.DataSource = t;
        //GridPanelMonitoring.DataBind();




    }
    protected void ToolbarButtonTotal(object sender, AjaxEventArgs e)
    {
        List<CrmSqlParameter> spList;
        //string strSql = GetFilters(out spList);

        string strTotal = @" ";

        //var sd = new StaticData();
        //sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        //foreach (var crmSqlParameter in spList)
        //{
        //    sd.AddParameter(crmSqlParameter.Paramname, crmSqlParameter.Dbtype, crmSqlParameter.Value);
        //}
        //var ret = sd.ReturnDataset(strTotal);

        //GridPanelTotal.DataSource = ret.Tables[0];
        //GridPanelTotal.DataBind();



    }
    void FillSecurity()
    {
        _dynamicSecurityTransfer = DynamicFactory.GetSecurity(TuEntityEnum.New_Transfer.GetHashCode(), null);
        _dynamicSecurityPayment = DynamicFactory.GetSecurity(TuEntityEnum.New_Payment.GetHashCode(), null);
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
}
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

public partial class Operation_PTT_Payment_Monitoring : BasePage
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
            //ColumnLayoutEUR.SetVisible(false);
            //ColumnLayoutUSD.SetVisible(false);

            //pnl1.Title = "EFT İşlemleri";
        }
        DateFieldBegin.SetValue(DateTime.Now);


        FillField();

        FillGrid();
    }


    public void ButtonFindClick(object sender, AjaxEventArgs e)
    {
        FillField();

        FillGrid();

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
        sd.AddParameter("@ScreenType", DbType.Int32, 2);
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
            System.Globalization.CultureInfo  culInfo = new System.Globalization.CultureInfo("tr-TR");
            NumberStyles styla = new NumberStyles();

            //TRY PTT Bank
            TextBox_Data1_GelUYITop0.Text = dt.Rows[0]["GelenUPTYPIslemToplamı"].ToString() != String.Empty ? dt.Rows[0]["GelenUPTYPIslemToplamı"].ToString() : "0";
            TextBox_Data1_GelUYIAdet0.Text = dt.Rows[0]["GelenUPTYPIslemAdet"].ToString() != String.Empty ? dt.Rows[0]["GelenUPTYPIslemAdet"].ToString() : "0";
            TextBox_Data1_IpGelUYITop0.Text = dt.Rows[0]["IptalGelenUPTYPToplam"].ToString() != String.Empty ? dt.Rows[0]["IptalGelenUPTYPToplam"].ToString() : "0";
            TextBox_Data1_IpGelUYIAdet0.Text = dt.Rows[0]["IptalGelenUPTYPAdet"].ToString() != String.Empty ? dt.Rows[0]["IptalGelenUPTYPAdet"].ToString() : "0";
            TextBox_Data1_GelUTITop0.Text = dt.Rows[0]["GelenUPTTLIslemToplam"].ToString() != String.Empty ? dt.Rows[0]["GelenUPTTLIslemToplam"].ToString() : "0";
            TextBox_Data1_GelUTIAdet0.Text = dt.Rows[0]["GelenUPTTLIslemAdet"].ToString() != String.Empty ? dt.Rows[0]["GelenUPTTLIslemAdet"].ToString() : "0";
            TextBox_Data1_IpGelUTITop0.Text = dt.Rows[0]["IptalGelenUPTTLToplam"].ToString() != String.Empty ? dt.Rows[0]["IptalGelenUPTTLToplam"].ToString() : "0";
            TextBox_Data1_IpGelUTIAdet0.Text = dt.Rows[0]["IptalGelenUPTTLAdet"].ToString() != String.Empty ? dt.Rows[0]["IptalGelenUPTTLAdet"].ToString() : "0";
            TextBox_Data1_Borc0.Text = dt.Rows[0]["BORC"].ToString() != String.Empty ? dt.Rows[0]["BORC"].ToString() : "0";
            //TRY UPT
            TextBox_Data1_GelUYITop1.Text = dt.Rows[1]["GelenUPTYPIslemToplamı"].ToString() != String.Empty ? dt.Rows[1]["GelenUPTYPIslemToplamı"].ToString() : "0";
            TextBox_Data1_GelUYIAdet1.Text = dt.Rows[1]["GelenUPTYPIslemAdet"].ToString() != String.Empty ? dt.Rows[1]["GelenUPTYPIslemAdet"].ToString() : "0";
            TextBox_Data1_IpGelUYITop1.Text = dt.Rows[1]["IptalGelenUPTYPToplam"].ToString() != String.Empty ? dt.Rows[1]["IptalGelenUPTYPToplam"].ToString() : "0";
            TextBox_Data1_IpGelUYIAdet1.Text = dt.Rows[1]["IptalGelenUPTYPAdet"].ToString() != String.Empty ? dt.Rows[1]["IptalGelenUPTYPAdet"].ToString() : "0";
            TextBox_Data1_GelUTITop1.Text = dt.Rows[1]["GelenUPTTLIslemToplam"].ToString() != String.Empty ? dt.Rows[1]["GelenUPTTLIslemToplam"].ToString() : "0";
            TextBox_Data1_GelUTIAdet1.Text = dt.Rows[1]["GelenUPTTLIslemAdet"].ToString() != String.Empty ? dt.Rows[1]["GelenUPTTLIslemAdet"].ToString() : "0";
            TextBox_Data1_IpGelUTITop1.Text = dt.Rows[1]["IptalGelenUPTTLToplam"].ToString() != String.Empty ? dt.Rows[1]["IptalGelenUPTTLToplam"].ToString() : "0";
            TextBox_Data1_IpGelUTIAdet1.Text = dt.Rows[1]["IptalGelenUPTTLAdet"].ToString() != String.Empty ? dt.Rows[1]["IptalGelenUPTTLAdet"].ToString() : "0";
            TextBox_Data1_Borc1.Text = dt.Rows[1]["BORC"].ToString() != String.Empty ? dt.Rows[1]["BORC"].ToString() : "0";

            //EUR PTT Bank
            TextBox_Data2_GelUYITop0.Text = dt.Rows[2]["GelenUPTYPIslemToplamı"].ToString() != String.Empty ? dt.Rows[2]["GelenUPTYPIslemToplamı"].ToString() : "0";
            TextBox_Data2_GelUYIAdet0.Text = dt.Rows[2]["GelenUPTYPIslemAdet"].ToString() != String.Empty ? dt.Rows[2]["GelenUPTYPIslemAdet"].ToString() : "0";
            TextBox_Data2_IpGelUYITop0.Text = dt.Rows[2]["IptalGelenUPTYPToplam"].ToString() != String.Empty ? dt.Rows[2]["IptalGelenUPTYPToplam"].ToString() : "0";
            TextBox_Data2_IpGelUYIAdet0.Text = dt.Rows[2]["IptalGelenUPTYPAdet"].ToString() != String.Empty ? dt.Rows[2]["IptalGelenUPTYPAdet"].ToString() : "0";
            //Pasif alanlar: bunlar zaten sp den NULL dönüyorlar
            //TextBox_Data2_GelUTITop0.Text = dt.Rows[2]["GelenUPTTLIslemToplam"].ToString() != String.Empty ? dt.Rows[2]["GelenUPTTLIslemToplam"].ToString() : "0";
            //TextBox_Data2_GelUTIAdet0.Text = dt.Rows[2]["GelenUPTTLIslemAdet"].ToString() != String.Empty ? dt.Rows[2]["GelenUPTTLIslemAdet"].ToString() : "0";
            //TextBox_Data2_IpGelUTITop0.Text = dt.Rows[2]["IptalGelenUPTTLToplam"].ToString() != String.Empty ? dt.Rows[2]["IptalGelenUPTTLToplam"].ToString() : "0";
            //TextBox_Data2_IpGelUTIAdet0.Text = dt.Rows[2]["IptalGelenUPTTLAdet"].ToString() != String.Empty ? dt.Rows[2]["IptalGelenUPTTLAdet"].ToString() : "0";
            TextBox_Data2_Borc0.Text = dt.Rows[2]["BORC"].ToString() != String.Empty ? dt.Rows[2]["BORC"].ToString() : "0";
            //EUR UPT
            TextBox_Data2_GelUYITop1.Text = dt.Rows[3]["GelenUPTYPIslemToplamı"].ToString() != String.Empty ? dt.Rows[3]["GelenUPTYPIslemToplamı"].ToString() : "0";
            TextBox_Data2_GelUYIAdet1.Text = dt.Rows[3]["GelenUPTYPIslemAdet"].ToString() != String.Empty ? dt.Rows[3]["GelenUPTYPIslemAdet"].ToString() : "0";
            TextBox_Data2_IpGelUYITop1.Text = dt.Rows[3]["IptalGelenUPTYPToplam"].ToString() != String.Empty ? dt.Rows[3]["IptalGelenUPTYPToplam"].ToString() : "0";
            TextBox_Data2_IpGelUYIAdet1.Text = dt.Rows[3]["IptalGelenUPTYPAdet"].ToString() != String.Empty ? dt.Rows[3]["IptalGelenUPTYPAdet"].ToString() : "0";
            //Pasif alanlar: bunlar zaten sp den NULL dönüyorlar
            //TextBox_Data2_GelUTITop1.Text = dt.Rows[3]["GelenUPTTLIslemToplam"].ToString() != String.Empty ? dt.Rows[3]["GelenUPTTLIslemToplam"].ToString() : "0";
            //TextBox_Data2_GelUTIAdet1.Text = dt.Rows[3]["GelenUPTTLIslemToplam"].ToString() != String.Empty ? dt.Rows[3]["GelenUPTTLIslemToplam"].ToString() : "0";
            //TextBox_Data2_IpGelUTITop1.Text = dt.Rows[3]["IptalGelenUPTTLToplam"].ToString() != String.Empty ? dt.Rows[3]["IptalGelenUPTTLToplam"].ToString() : "0";
            //TextBox_Data2_IpGelUTIAdet1.Text = dt.Rows[3]["IptalGelenUPTTLAdet"].ToString() != String.Empty ? dt.Rows[3]["IptalGelenUPTTLAdet"].ToString() : "0";
            TextBox_Data2_Borc1.Text = dt.Rows[3]["BORC"].ToString() != String.Empty ? dt.Rows[3]["BORC"].ToString() : "0";

            //USD PTT Bank
            TextBox_Data3_GelUYITop0.Text = dt.Rows[4]["GelenUPTYPIslemToplamı"].ToString() != String.Empty ? dt.Rows[4]["GelenUPTYPIslemToplamı"].ToString() : "0";
            TextBox_Data3_GelUYIAdet0.Text = dt.Rows[4]["GelenUPTYPIslemAdet"].ToString() != String.Empty ? dt.Rows[4]["GelenUPTYPIslemAdet"].ToString() : "0";
            TextBox_Data3_IpGelUYITop0.Text = dt.Rows[4]["IptalGelenUPTYPToplam"].ToString() != String.Empty ? dt.Rows[4]["IptalGelenUPTYPToplam"].ToString() : "0";
            TextBox_Data3_IpGelUYIAdet0.Text = dt.Rows[4]["IptalGelenUPTYPAdet"].ToString() != String.Empty ? dt.Rows[4]["IptalGelenUPTYPAdet"].ToString() : "0";
            //Pasif alanlar: bunlar zaten sp den NULL dönüyorlar
            //TextBox_Data3_GelUTITop0.Text = dt.Rows[4]["GelenUPTTLIslemToplam"].ToString() != String.Empty ? dt.Rows[4]["GelenUPTTLIslemToplam"].ToString() : "0";
            //TextBox_Data3_GelUTIAdet0.Text = dt.Rows[4]["GelenUPTTLIslemAdet"].ToString() != String.Empty ? dt.Rows[4]["GelenUPTTLIslemAdet"].ToString() : "0";
            //TextBox_Data3_IpGelUTITop0.Text = dt.Rows[4]["IptalGelenUPTTLToplam"].ToString() != String.Empty ? dt.Rows[4]["IptalGelenUPTTLToplam"].ToString() : "0";
            //TextBox_Data3_IpGelUTIAdet0.Text = dt.Rows[4]["IptalGelenUPTTLAdet"].ToString() != String.Empty ? dt.Rows[4]["IptalGelenUPTTLAdet"].ToString() : "0";
            TextBox_Data3_Borc0.Text = dt.Rows[4]["BORC"].ToString() != String.Empty ? dt.Rows[4]["BORC"].ToString() : "0";
            //USD UPT
            TextBox_Data3_GelUYITop1.Text = dt.Rows[5]["GelenUPTYPIslemToplamı"].ToString() != String.Empty ? dt.Rows[5]["GelenUPTYPIslemToplamı"].ToString() : "0";
            TextBox_Data3_GelUYIAdet1.Text = dt.Rows[5]["GelenUPTYPIslemAdet"].ToString() != String.Empty ? dt.Rows[5]["GelenUPTYPIslemAdet"].ToString() : "0";
            TextBox_Data3_IpGelUYITop1.Text = dt.Rows[5]["IptalGelenUPTYPToplam"].ToString() != String.Empty ? dt.Rows[5]["IptalGelenUPTYPToplam"].ToString() : "0";
            TextBox_Data3_IpGelUYIAdet1.Text = dt.Rows[5]["IptalGelenUPTYPAdet"].ToString() != String.Empty ? dt.Rows[5]["IptalGelenUPTYPAdet"].ToString() : "0";
            //Pasif alanlar: bunlar zaten sp den NULL dönüyorlar
            //TextBox_Data3_GelUTITop1.Text = dt.Rows[5]["GelenUPTTLIslemToplam"].ToString() != String.Empty ? dt.Rows[5]["GelenUPTTLIslemToplam"].ToString() : "0";
            //TextBox_Data3_GelUTIAdet1.Text = dt.Rows[5]["GelenUPTTLIslemAdet"].ToString() != String.Empty ? dt.Rows[5]["GelenUPTTLIslemAdet"].ToString() : "0";
            //TextBox_Data3_IpGelUTITop1.Text = dt.Rows[5]["IptalGelenUPTTLToplam"].ToString() != String.Empty ? dt.Rows[5]["IptalGelenUPTTLToplam"].ToString() : "0";
            //TextBox_Data3_IpGelUTIAdet1.Text = dt.Rows[5]["IptalGelenUPTTLAdet"].ToString() != String.Empty ? dt.Rows[5]["IptalGelenUPTTLAdet"].ToString() : "0";
            TextBox_Data3_Borc1.Text = dt.Rows[5]["BORC"].ToString() != String.Empty ? dt.Rows[5]["BORC"].ToString() : "0";
        }
    }

    protected void btnEft(object sender, AjaxEventArgs e)
    {
        pnl1.Title = "EFT İşlemleri";

        ColumnLayoutEUR.SetVisible(false);
        ColumnLayoutUSD.SetVisible(false);
    }

    protected void btnYpUpt(object sender, AjaxEventArgs e)
    {
        pnl1.Title = "YPUPT İşlemleri";

        ColumnLayoutEUR.SetVisible(true);
        ColumnLayoutUSD.SetVisible(true);
    }

    protected void btnPayment(object sender, AjaxEventArgs e)
    {
        pnl1.Title = "Ödeme İşlemleri";

        ColumnLayoutEUR.SetVisible(true);
        ColumnLayoutUSD.SetVisible(true);
    }

    protected void btnCancels(object sender, AjaxEventArgs e)
    {
        pnl1.Title = "İade Ödeme İşlemleri";

        ColumnLayoutEUR.SetVisible(true);
        ColumnLayoutUSD.SetVisible(true);
    }

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
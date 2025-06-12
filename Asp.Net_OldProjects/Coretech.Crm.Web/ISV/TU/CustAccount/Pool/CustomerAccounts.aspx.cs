using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using TuFactory.CustAccount.Business;
using TuFactory.CustAccount.Object;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class CustAccount_Pool_CustomerAccounts : BasePage
{
    private TuUserApproval _userApproval = null;
    private DataTable _dtCustAccounts = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

            new_CorporatedConfirmStatus.SetVisible(false);


            if (!_userApproval.CreateIOMCustomer)
            {
                btnCreateIOMCustomer.Visible = false;
                btnSenderEditUpdate.Visible = true;
            }
            else
            {
                btnCreateIOMCustomer.Visible = true;
                btnSenderEditUpdate.Visible = false;
            }

            if (_userApproval.CreateCorporatedCustomer)
            {
                btnCorporatedCustomerCreate.Visible = true;
            }
            else
            {
                btnCorporatedCustomerCreate.Visible = false;
            }

            RR.RegisterIcon(Icon.Add);
            CreateViewGrid();
            AddMessages();
        }
    }
    protected override void OnInit(EventArgs e)
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGridModels(GetListName(), gpCustAccounts, true);
        base.OnInit(e);
    }

    private void AddMessages()
    {
        new_CustAccountTypeId.EmptyText =
        new_NationalityID.EmptyText =
        new_CustAccountTypeId.EmptyText =
        new_CustAccountCurrencyId.EmptyText =
         CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
        btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");
        Sender.FieldLabel = CrmLabel.TranslateMessage("CRM.NEW_SENDER_FULLNAME");
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid(GetListName(), gpCustAccounts, true);
    }

    private string GetListName()
    {
        return "ACCOUNT_CUSTOMERS_SENDER_VIEW";
    }

    //DataTable dtCustAccounts
    //{
    //    get
    //    {
    //        return Session["CustomerAccounts"] as DataTable;
    //    }
    //    set
    //    {
    //        Session["CustomerAccounts"] = value;
    //    }
    //}

    protected void ExportToExcel(object sender, AjaxEventArgs e)
    {
        GpCustAccountsReload(sender,  e);
        //var prmc = new ParameterCollection();
        //prmc.Add(new Parameter() { Name = "Excel", Value = 1, Mode = EpMode.Value });
        //e.ExtraParams = prmc;

        //var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        //var gpw = new GridPanelView(TuFactory.Object.TuEntityEnum.New_Sender.GetHashCode(), viewqueryid);

        //GpCustAccountsReload(sender, e);
        //if (_dtCustAccounts.Rows.Count > 0)
        //{
        //    var n = string.Format("MusteriHesapları_{0:yyyy_MM_dd_hh_mm_ss}.xls", DateTime.Now);
        //    gpw.Export(n, _dtCustAccounts, null);


        //    //Export.ExportDownloadData(_dtCustAccounts, n);
        //}
    }
    protected void GpCustAccountsReload(object sender, AjaxEventArgs e)
    {
        TuFactory.CustAccount.Business.CustAccountOperations custAccountService = new TuFactory.CustAccount.Business.CustAccountOperations();
        var sort = gpCustAccounts.ClientSorts() ?? string.Empty;
        string strSql = custAccountService.GetCustAccountSelectSql(CardNumber.Value, ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value));
        var spList = custAccountService.GetCustAccountSelectParameters(ValidationHelper.GetGuid(new_CustAccountTypeId.Value), new_SenderNumber.Value, new_SenderIdendificationNumber1.Value
            , ValidationHelper.GetGuid(new_NationalityID.Value), Sender.Value, CardNumber.Value
            , ValidationHelper.GetGuid(new_CustAccountCurrencyId.Value),
            ValidationHelper.GetGuid(new_SenderSegmentationID.Value),
            ValidationHelper.GetInteger(new_FraudStatus.Value, 0),
             ValidationHelper.GetInteger(new_CorporatedConfirmStatus.Value, 0), cfShowMobileCustomer.Checked,
            ref strSql);

        var gpc = new GridPanelCreater();

        int cnt;
        var start = gpCustAccounts.Start();
        var limit = gpCustAccounts.Limit();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
        DataTable dtb;
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb, false);
        gpCustAccounts.TotalCount = cnt;

        _dtCustAccounts = dtb;

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null &&
            ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var fileName = string.Format("MusteriHesapları_{0:yyyy_MM_dd_hh_mm_ss}.xls", DateTime.Now);
            var gpw = new GridPanelView(TuFactory.Object.TuEntityEnum.New_Sender.GetHashCode(), ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(fileName, dtb,new List<string>());
        }

        gpCustAccounts.DataSource = t;
        gpCustAccounts.DataBind();
    }

    protected void RowDblClickOnEvent(object sender, AjaxEventArgs e)
    {
        Guid companyAccountTypeID = new CustInfoFactory().GetAccountTypeID(CustAccountType.TUZEL);
        bool isCompanyAccount;
        isCompanyAccount = ValidationHelper.GetGuid(hdnAccountTypeID.Value) == companyAccountTypeID ? true : false;

        string readonlyFormID = isCompanyAccount == true ? ValidationHelper.GetString(ParameterFactory.GetParameterValue("CUSTACCOUNT_SENDERS_COMPANY_READONLY")) : ValidationHelper.GetString(ParameterFactory.GetParameterValue("CUSTACCOUNT_SENDERS_REAL_READONLY"));

        var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyFormID},
                                {"ObjectId",( (int)TuEntityEnum.New_Sender).ToString()},
                                {"recid", hdnSenderID.Value},
                                {"cddStatus", hdnCddStatus.Value},
                                {"mode", "1"}
                            };
        var urlparam = QueryHelper.RefreshUrl(query);
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx" + urlparam + "', { maximized: false, width: 1100, height: "
           + (isCompanyAccount == true ? "670" : "500") + ", resizable: true, modal: false, maximizable: true });");
    }

    protected void btnSenderEditUpdate_Click(object sender, AjaxEventArgs e)
    {
        //if (string.IsNullOrEmpty(newCustAccountType.Value))
        //{
        //    e.Message = ShowRequiredFields(newCustAccountType.FieldLabel);
        //    e.Success = false;
        //    return;
        //}
        //var CustTypeCode = UPT.Shared.CacheProvider.Service.CustAccountTypeService.GetCustAccountTypeByTypeId(ValidationHelper.GetGuid(newCustAccountType.Value)).ExtCode;
        string accountCurrencyList = string.Empty;

        if ((checkEur).Checked)
        {
            accountCurrencyList = "EUR+";
        }
        if (checkUsd.Checked)
        {
            accountCurrencyList += "USD+";
        }
        if (checkTry.Checked)
        {
            accountCurrencyList += "TRY";
        }

        var query = new Dictionary<string, string>
        {
            {"ObjectId", ((int) TuEntityEnum.New_Sender).ToString()},
            {"fromCustomerAccountScreen", "1"},
            {"gridpanelid", ""},
            {
                "defaulteditpageid", "5d08acf8-39ad-e511-9f11-28e347b36ba3"
            },
            { "SourceForm", "CustomerAccount" },
            {"AccountCurrencyList",accountCurrencyList }
        };

        var urlparam = QueryHelper.RefreshUrl(query);
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx" + urlparam + "', { maximized: false, width: 1100, height: 500, resizable: true, modal: true, maximizable: false });");
    }

    protected void btnTuzelSenderEditUpdate_Click(object sender, AjaxEventArgs e)
    {
        //string accountCurrencyList = string.Empty;

        //if ((checkTEur).Checked)
        //{
        //    accountCurrencyList = "EUR+";
        //}
        //if (checkTUsd.Checked)
        //{
        //    accountCurrencyList += "USD+";
        //}
        //if (checkTTry.Checked)
        //{
        //    accountCurrencyList += "TRY";
        //}

        var query = new Dictionary<string, string>
        {
            {"ObjectId", ((int) TuEntityEnum.New_Sender).ToString()},
            {"fromCustomerAccountScreen", "1"},
            {"gridpanelid", ""},
            {
                "defaulteditpageid", "D6A1D26B-5B8D-4740-8F29-9F170405AFAC"
            },
            { "SourceForm", "CustomerAccount" }
            //,{"AccountCurrencyList",accountCurrencyList }
        };

        var urlparam = QueryHelper.RefreshUrl(query);
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx" + urlparam + "', { maximized: false, width: 1100, height: 500, resizable: true, modal: true, maximizable: false });");
    }

    protected void btnIOM_Customer_Click(object sender, AjaxEventArgs e)
    {
        var query = new Dictionary<string, string>
        {
            {"ObjectId", ((int) TuEntityEnum.New_Sender).ToString()},
            {"fromCustomerAccountScreen", "1"},
            {"gridpanelid", ""},
            {
                "defaulteditpageid", "40F0738D-9D3A-E911-ADBD-80000B33DF55"
            },
            { "SourceForm", "CustomerAccount" },
            { "CustomerType", "IOM" }
        };

        var urlparam = QueryHelper.RefreshUrl(query);
        QScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/CrmPages/AutoPages/EditReflex.aspx" + urlparam + "', { maximized: false, width: 1100, height: 500, resizable: true, modal: true, maximizable: false });");

    }

    private string ShowRequiredFields(string myLabel)
    {
        var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
        var m = new MessageBox { Width = 400 };
        return string.Format(msg, myLabel);
    }

    protected void new_CustAccountTypeChangeOnEvent(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(new_CustAccountTypeId.Value) && new_CustAccountTypeId.Value == "5aca7e23-5ea2-e511-a26c-848f69c4a66c")
        {
            new_CorporatedConfirmStatus.SetVisible(true);
        }
        else
        {
            new_CorporatedConfirmStatus.SetVisible(false);
            new_CorporatedConfirmStatus.SetValue(0);
        }
    }

}
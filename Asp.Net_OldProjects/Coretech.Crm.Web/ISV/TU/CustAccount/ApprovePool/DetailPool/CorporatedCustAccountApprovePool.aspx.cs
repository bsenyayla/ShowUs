using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
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

namespace Coretech.Crm.Web.ISV.TU.CustAccount.ApprovePool.DetailPool
{
    ///*private TuUserApproval _userApproval = null*/;
    public partial class CorporatedCustAccountApprovePool : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
             
                CreateViewGrid();
                AddMessages();
            }
        }

        public void CreateViewGrid()
        {
            var gpc = new GridPanelCreater();
            gpc.CreateViewGrid(GetListName(), gpCustAccounts, true);
        }

        private void AddMessages()
        {      
            new_NationalityID.EmptyText =          
            CrmLabel.TranslateMessage("CRM.ENTITY_FILTER_EMPTY_TEXT");
            btnRefresh.Text = CrmLabel.TranslateMessage("CRM_TOOLSEARCH");
            Sender.FieldLabel = CrmLabel.TranslateMessage("CRM.NEW_SENDER_FULLNAME");
        }

        private string GetListName()
        {
            return "ACCOUNT_CUSTOMERS_SENDER_VIEW";
        }

        protected void GpCustAccountsReload(object sender, AjaxEventArgs e)
        {
            TuFactory.CustAccount.Business.CustAccountOperations custAccountService = new TuFactory.CustAccount.Business.CustAccountOperations();
            var sort = gpCustAccounts.ClientSorts() ?? string.Empty;
            string strSql = custAccountService.GetCorporatedCustAccountSelectSql();
            var spList = custAccountService.GetCorporatedCustAccountSelectParameters( new_SenderNumber.Value, new_SenderIdendificationNumber1.Value
                , ValidationHelper.GetGuid(new_NationalityID.Value), Sender.Value,
               
                ref strSql);

            var gpc = new GridPanelCreater();

            int cnt;
            var start = gpCustAccounts.Start();
            var limit = gpCustAccounts.Limit();
            var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetListName());
            DataTable dtb;
            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb, false);
            gpCustAccounts.TotalCount = cnt;

            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null &&
                ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                gpw.Export(dtb);
            }
            gpCustAccounts.DataSource = t;
            gpCustAccounts.DataBind();
        }

        protected void RowDblClickOnEvent(object sender, AjaxEventArgs e)
        {
            Guid companyAccountTypeID = new CustInfoFactory().GetAccountTypeID(CustAccountType.TUZEL);
            bool isCompanyAccount;
            isCompanyAccount = ValidationHelper.GetGuid(hdnAccountTypeID.Value) == companyAccountTypeID ? true : false;

            string readonlyFormID = "276C45E5-40AD-E911-ADC7-80000B33DF55";

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

        protected override void OnInit(EventArgs e)
        {
            var gpc = new GridPanelCreater();
            gpc.CreateViewGridModels(GetListName(), gpCustAccounts, true);
            base.OnInit(e);
        }
    }
}
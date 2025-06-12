using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;

public partial class AccountMonitoring_AccountActivity : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (RefleX.IsAjxPostback) return;
        Translate();
        new_EndDate.Value = DateTime.Today;
        new_StartDate.Value = DateTime.Today.AddDays(-7);
    }

    private void Translate()
    {
        BtnSearch.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_BTN_SEARCH");

        GridPanelMainAccount.ColumnModel.Columns[0].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_ACCOUNTNAME");
        GridPanelMainAccount.ColumnModel.Columns[1].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_ACCOUNTTYPE");
        GridPanelMainAccount.ColumnModel.Columns[2].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_CURRENCY");
        GridPanelMainAccount.ColumnModel.Columns[3].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_DATE");
        GridPanelMainAccount.ColumnModel.Columns[4].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_NEW_ACTIVITYTYPE");
        GridPanelMainAccount.ColumnModel.Columns[5].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_AMOUNT");
        GridPanelMainAccount.ColumnModel.Columns[6].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_BALANCE");
        GridPanelMainAccount.ColumnModel.Columns[7].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_DESCRIPTION");
    }

    protected void LoadAccounts(object sender, AjaxEventArgs e)
    {
        const string strSql = @"Select new_AccountId as New_AccountsId, ID, new_AccountIdName as AccountNumber, VALUE from GetCorpAccountsAsTable(@SystemuserId)";

        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("AccountForCorpAccountMonitoring");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_AccountId.Start();
        var limit = new_AccountId.Limit();
        var splist = new List<CrmSqlParameter>
        {
            new CrmSqlParameter
            {
                Dbtype = DbType.Guid,
                Paramname = "UserId",
                Value = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId)
            }
        };

        var t = gpc.GetFilterData(strSql, viewqueryid, sort, splist, start, limit, out cnt);
        new_AccountId.TotalCount = cnt;
        new_AccountId.DataSource = t;
        new_AccountId.DataBind();
    }

    protected void SearchOnEvent(object sender, AjaxEventArgs e)
    {
        if ((new_EndDate.Value.Value - new_StartDate.Value.Value).TotalDays > ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("CORP_ACTIVITY_REPORT_DATE_FILTER_MAX_RANGE"), 30))
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            m.Show("", "", String.Format(ValidationHelper.GetString(App.Params.GetConfigKeyValue("CRM.NEW_CORPACCOUNTMONITORING_ACTIVITY_DATE_FILTER_MAX_RANGE", "Tarih aralığı {0} günden fazla olamaz")), ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("CORP_ACTIVITY_REPORT_DATE_FILTER_MAX_RANGE"), 30)));
            return;
        }

        FillGrid();
    }
    protected void GridPanelMainAccountOnEvent(object sender, AjaxEventArgs e)
    {
        FillGrid();
    }

    private void FillGrid()
    {
        var sd = new StaticData();
        sd.AddParameter("systemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("AccountId", DbType.Guid, ValidationHelper.GetGuid(new_AccountId.Value));
        sd.AddParameter("ActivityType", DbType.Int32, ValidationHelper.GetInteger(new_ActivityType.Value));
        sd.AddParameter("startDate", DbType.DateTime, new_StartDate.Value);
        sd.AddParameter("endDate", DbType.DateTime, new_EndDate.Value);

        var dt = sd.ReturnDatasetSp("spCorpGetAccountActivities").Tables[0];

        GridPanelMainAccount.DataSource = dt;
        GridPanelMainAccount.TotalCount = dt.Rows.Count;
        GridPanelMainAccount.DataBind();
    }
}
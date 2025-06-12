using System;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;

public partial class AccountMonitoring_AccountBalance : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (RefleX.IsAjxPostback) return;
        Translate();
    }

    protected void GridPanelMainAccountOnEvent(object sender, AjaxEventArgs e)
    {
        FillGrid();
    }

    private void Translate()
    {
        GridPanelMainAccount.ColumnModel.Columns[0].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_ACCOUNTNUMBER");
        GridPanelMainAccount.ColumnModel.Columns[1].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_ACCOUNTNAME");
        GridPanelMainAccount.ColumnModel.Columns[2].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_ACCOUNTTYPE");
        GridPanelMainAccount.ColumnModel.Columns[3].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_CURRENCY");
        GridPanelMainAccount.ColumnModel.Columns[4].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_CURRENTBALANCE");
        GridPanelMainAccount.ColumnModel.Columns[5].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_BLOCKEDBALANCE");
        GridPanelMainAccount.ColumnModel.Columns[6].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CORPACCOUNTMONITORING_GRID_AVAILABLEBALANCE");

    }
    private void FillGrid()
    {
        var sd = new StaticData();
        sd.AddParameter("systemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        
        var dt = sd.ReturnDatasetSp("spCorpGetAccountBalances").Tables[0];

        GridPanelMainAccount.DataSource = dt;
        GridPanelMainAccount.TotalCount = dt.Rows.Count;
        GridPanelMainAccount.DataBind();
    }
}
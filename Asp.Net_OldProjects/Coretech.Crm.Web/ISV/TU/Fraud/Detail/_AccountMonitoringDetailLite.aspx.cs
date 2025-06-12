using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;

public partial class Fraud_Detail_AccountMonitoringDetailLite : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
            CreateViewGrid();

        }
    }
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("CUSTACCOUNTFRAUD_CONFIRM_LOG", GridPanelAccountMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("CUSTACCOUNTFRAUD_CONFIRM_LOG").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;
    }

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelAccountMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql = @"
SELECT
Mt.New_CustAccountFraudConfirmLogId AS ID
,Mt.CustAccountFraudConfirmLogName AS VALUE
,Mt.New_CustAccountFraudConfirmLogId
,Mt.CustAccountFraudConfirmLogName
,Mt.CreatedOn
,Mt.CreatedOnUtcTime
,Mt.ModifiedOn
,Mt.ModifiedOnUtcTime
,Mt.CreatedBy
,Mt.CreatedByName
,Mt.ModifiedBy
,Mt.ModifiedByName
,Mt.OwningUser
,Mt.OwningUserName
,Mt.OwningBusinessUnit
,Mt.OwningBusinessUnitName
,Mt.DeletionStateCode
,Mt.statuscode
,Mt.statuscodeName
,Mt.new_FraudActionReasonText
,Mt.new_FraudConfirmStatusIdName
,Mt.new_FraudConfirmStatusId
,Mt.new_CustAccountFraudLogId
,Mt.new_CustAccountFraudLogIdName
,Mt.new_CustAccountFraudActionReasonIdName
,Mt.new_CustAccountFraudActionReasonId
from  dbo.tvNew_CustAccountFraudConfirmLog(@SystemUserId) as Mt
WHERE 1=1 
";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CUSTACCOUNTFRAUD_CONFIRM_LOG");
        var spList = new List<CrmSqlParameter>();
        var processMonitoringId = QueryHelper.GetString("recid");
        strSql += " And MT.new_CustAccountFraudLogId = @new_FraudLogId";
        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.Guid,
            Paramname = "new_FraudLogId",
            Value = ValidationHelper.GetGuid(processMonitoringId)
        });
        var gpc = new GridPanelCreater();


        var cnt = 0;
        var start = GridPanelAccountMonitoring.Start();
        var limit = GridPanelAccountMonitoring.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelAccountMonitoring.TotalCount = cnt;

        try
        {
            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
                gpw.Export(dtb);

            }

        }
        catch (Exception)
        {

            throw;
        }
        GridPanelAccountMonitoring.DataSource = t;
        GridPanelAccountMonitoring.DataBind();
    }
}
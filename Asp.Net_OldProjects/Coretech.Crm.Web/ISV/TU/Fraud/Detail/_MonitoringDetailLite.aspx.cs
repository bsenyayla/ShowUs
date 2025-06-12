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

public partial class Fraud_Detail_MonitoringDetailLite : BasePage
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
        gpc.CreateViewGrid("FRAUD_CONFIRM_LOG", GridPanelMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("FRAUD_CONFIRM_LOG").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;


    }
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        string strSql = @"
Select Mt.FraudConfirmLogName AS VALUE ,
Mt.New_FraudConfirmLogId AS ID 
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
,Mt.new_FraudLogId
,Mt.new_FraudLogIdName
,Mt.new_FraudActionReasonIdName
,Mt.new_FraudActionReasonId
,Mt.new_FraudActionReasonText
,Mt.new_FraudConfirmStatusIdName
,Mt.new_FraudConfirmStatusId
from  dbo.tvNew_FraudConfirmLog(@SystemUserId) as Mt
            Where 1=1
        ";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("FRAUD_CONFIRM_LOG");
        var spList = new List<CrmSqlParameter>();
        var processMonitoringId = QueryHelper.GetString("recid");
        strSql += " And MT.new_FraudLogId = @new_FraudLogId";
        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.Guid,
            Paramname = "new_FraudLogId",
            Value = ValidationHelper.GetGuid(processMonitoringId)
        });

        var gpc = new GridPanelCreater();


        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelMonitoring.TotalCount = cnt;

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
        GridPanelMonitoring.DataSource = t;
        GridPanelMonitoring.DataBind();

    }


}
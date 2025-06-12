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
using TuFactory.Object.User;
using System.Linq;
using TuFactory.TuUser;
using Coretech.Crm.Factory;

public partial class GsmWaybill_GsmPaymentHistoryMonitoring : BasePage
{
    private TuUserApproval _userApproval = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        if (!RefleX.IsAjxPostback)
        {
            btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
            CreateViewGrid();
        }
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("gsmPaymentHistoryView", GridPanelMonitoring);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("gsmPaymentHistoryView").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;


    }

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        try
        {
            var sort = GridPanelMonitoring.ClientSorts();
            if (sort == null)
                sort = string.Empty;
            string strSql = @"
        	";

            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("gsmPaymentHistoryView");
            var spList = new List<CrmSqlParameter>();
            var gsmPaymentId = QueryHelper.GetString("recid");
            strSql += @"Select New_GsmPaymentHistoryId,New_GsmPaymentHistoryId AS ID,Reference ,Reference AS VALUE,
new_GsmPaymentId,new_GsmPaymentIdName,
DATEADD(hour,3,CreatedOn) AS CreatedOn,
CreatedOn AS CreatedOnUtcTime,
DATEADD(hour,3,ModifiedOn) AS ModifiedOn,
ModifiedOn AS ModifiedOnUtcTime,
CreatedBy,
CreatedByName,
ModifiedBy,
ModifiedByName,
new_LoadStatus,
GPHL.Label AS new_LoadStatusName
From vNew_GsmPaymentHistory(NOLOCK) GPH
INNER JOIN new_PLNew_GsmPaymentHistory_new_LoadStatus GPHL ON GPHL.Value=GPH.new_LoadStatus
WHERE DeletionStateCode = 0  And new_GsmPaymentId = @GsmPaymentId ";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "GsmPaymentId",
                Value = ValidationHelper.GetGuid(gsmPaymentId)
            });

            var gpc = new GridPanelCreater();
            
            var cnt = 0;
            var start = GridPanelMonitoring.Start();
            var limit = GridPanelMonitoring.Limit();
            var dtb = new DataTable();
            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
            GridPanelMonitoring.TotalCount = cnt;


            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
                gpw.Export(dtb);

            }
            GridPanelMonitoring.DataSource = t;
            GridPanelMonitoring.DataBind();

        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}
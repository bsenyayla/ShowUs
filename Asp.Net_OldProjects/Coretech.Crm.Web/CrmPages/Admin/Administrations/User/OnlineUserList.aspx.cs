using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;

public partial class CrmPages_Admin_Administrations_User_OnlineUserList : AdminPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!RefleX.IsAjxPostback)
            {
                CreateViewGrid();
            }
        }
    }
    public CrmPages_Admin_Administrations_User_OnlineUserList()
    {
        ObjectId = EntityEnum.Systemuser.GetHashCode();
    }
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("User_Master", GridPanelMonitoring);
        
    }
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        var sd = new StaticData();
        string strSql =
            @"Select Mt.FullName AS VALUE ,Mt.SystemUserId AS ID ,*
from  dbo.nltvSystemUser(@SystemUserId) as Mt
Where 1=1 and LastLoginDateUtcTime>=dateadd(mi,@OnlineUserMinute,GETUTCDATE()) 
        	";

        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("User_Master");
        var spList = new List<CrmSqlParameter>();
        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.Int32,
            Paramname = "OnlineUserMinute",
            Value = -1*ValidationHelper.GetInteger(
                App.Params.GetConfigKeyValue("OnlineUserMinute"),
                10)
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
                var gpw = new GridPanelView(0, viewqueryid);
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
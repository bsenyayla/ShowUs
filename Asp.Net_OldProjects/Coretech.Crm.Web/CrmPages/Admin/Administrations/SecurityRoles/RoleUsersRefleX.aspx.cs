using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using Coretech.Crm.Web.UI.RefleX;

public partial class CrmPages_Admin_Administrations_SecurityRoles_RoleUsersRefleX : AdminPage
{
    public CrmPages_Admin_Administrations_SecurityRoles_RoleUsersRefleX()
    {
        ObjectId = EntityEnum.Role.GetHashCode();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        //if (!(DynamicSecurity.PrvWrite))
        //{
        //    Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Role PrvCreate,PrvDelete,PrvWrite");
        //}
        if (!RefleX.IsAjxPostback)
        {
            hdnRoleId.Value = QueryHelper.GetString("recid");
            CreateViewGrid();
        }
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("User_Master", GridPanelUsers);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("User_Master").ToString();
        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

    }

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelUsers.ClientSorts();
        if (sort == null)
            sort = string.Empty;
        var sd = new StaticData();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("User_Master");
        var spList = new List<CrmSqlParameter>();
        string strSql =
            @"
        	Select Mt.FullName AS VALUE ,Mt.SystemUserId AS ID ,* from dbo.tvSystemUser(@SystemUserId) Mt
Where Mt.SystemUserId in (
select  SystemUserId from (select us.SystemUserId ,RoleId,BusinessUnitId,BusinessUnitIdName from UserRole  ur
Inner join vSystemUser us on us.SystemUserId=ur.SystemUserId
where isnull (StartDate ,'1753-01-01') <=GETUTCDATE()  and ISNULL(EndDate,'9999-12-31')>GETUTCDATE() 
union ALL
select Bu.SystemUserId, Bur.RoleId,Bu.BusinessUnitId,Bu.BusinessUnitIdName  from dbo.vUserBusinessUnit Bu
Inner join UserBusinessUnitRole Bur on Bu.UserBusinessUnitId=Bur.UserBusinessUnitId
Inner join vSystemUser us on us.SystemUserId=Bu.SystemUserId 
and isnull (Bur.StartDate ,'1753-01-01') <=GETUTCDATE()  and ISNULL(Bur.EndDate,'9999-12-31')>GETUTCDATE() 
And isnull(Bu.DeletionStateCode,0)=0 and  isnull(Bur.DeletionStateCode,0)=0
)a
Where RoleId=@RoleId
)";

        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.Guid,
            Paramname = "RoleId",
            Value = ValidationHelper.GetGuid(hdnRoleId.Value)
        });


        var gpc = new GridPanelCreater();

        var cnt = 0;
        var start = GridPanelUsers.Start();
        var limit = GridPanelUsers.Limit();
        var dtb = new DataTable();
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelUsers.TotalCount = cnt;

        try
        {
            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                gpw.Export(dtb);

            }

        }
        catch (Exception)
        {

            throw;
        }
        GridPanelUsers.DataSource = t;
        GridPanelUsers.DataBind();

    }
}
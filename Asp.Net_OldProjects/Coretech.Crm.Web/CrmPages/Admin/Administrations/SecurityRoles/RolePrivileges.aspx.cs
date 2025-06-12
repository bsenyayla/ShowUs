using System;
using System.Collections.Generic;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Objects.Crm.Dynamic.Security;

public partial class CrmPages_Admin_Administrations_SecurityRoles_RolePrivileges : AdminPage
{
    public CrmPages_Admin_Administrations_SecurityRoles_RolePrivileges()
    {
        base.ObjectId = EntityEnum.Systemuser.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Systemuser PrvCreate,PrvDelete,PrvWrite");
        }
        if (!Ext.IsAjaxRequest)
        {
            hdnRoleId.Value = QueryHelper.GetString("RoleId");
            rolelist.Reload();
        }
    }

    protected void Store2OnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        if (!string.IsNullOrEmpty(hdnRoleId.Value.ToString())
         )
        {
            var scr = new SecurityFactory();
            store2.DataSource = scr.GetRolePrivileges(new Guid(hdnRoleId.Value.ToString()));
            store2.DataBind();
        }
    }

    protected void SubmitGrids(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);
            var pl = new List<RolePrivilege>();

            foreach (var t in degerler)
            {
                var item = new RolePrivilege
                               {
                                   RoleId = new Guid(hdnRoleId.Value.ToString()),
                                   PrivilegeDepthMask =
                                       ValidationHelper.GetInteger(t["ReadPrivilegeValue"]),
                                   PrivilegeId = new Guid(t["ReadPrivilegeId"])
                               };
                pl.Add(item);

                item = new RolePrivilege
                           {
                               RoleId = new Guid(hdnRoleId.Value.ToString()),
                               PrivilegeDepthMask =
                                   ValidationHelper.GetInteger(t["WritePrivilegeValue"]),
                               PrivilegeId = new Guid(t["WritePrivilegeId"])
                           };
                pl.Add(item);

                item = new RolePrivilege
                           {
                               RoleId = new Guid(hdnRoleId.Value.ToString()),
                               PrivilegeDepthMask =
                                   ValidationHelper.GetInteger(t["AppendPrivilegeValue"]),
                               PrivilegeId = new Guid(t["AppendPrivilegeId"])
                           };
                pl.Add(item);

                item = new RolePrivilege
                           {
                               RoleId = new Guid(hdnRoleId.Value.ToString()),
                               PrivilegeDepthMask =
                                   ValidationHelper.GetInteger(t["AppendToPrivilegeValue"]),
                               PrivilegeId = new Guid(t["AppendToPrivilegeId"])
                           };
                pl.Add(item);

                item = new RolePrivilege
                           {
                               RoleId = new Guid(hdnRoleId.Value.ToString()),
                               PrivilegeDepthMask =
                                   ValidationHelper.GetInteger(t["CreatePrivilegeValue"]),
                               PrivilegeId = new Guid(t["CreatePrivilegeId"])
                           };
                pl.Add(item);

                item = new RolePrivilege
                           {
                               RoleId = new Guid(hdnRoleId.Value.ToString()),
                               PrivilegeDepthMask =
                                   ValidationHelper.GetInteger(t["DeletePrivilegeValue"]),
                               PrivilegeId = new Guid(t["DeletePrivilegeId"])
                           };
                pl.Add(item);

                item = new RolePrivilege
                           {
                               RoleId = new Guid(hdnRoleId.Value.ToString()),
                               PrivilegeDepthMask =
                                   ValidationHelper.GetInteger(t["SharePrivilegeValue"]),
                               PrivilegeId = new Guid(t["SharePrivilegeId"])
                           };
                pl.Add(item);

                item = new RolePrivilege
                           {
                               RoleId = new Guid(hdnRoleId.Value.ToString()),
                               PrivilegeDepthMask =
                                   ValidationHelper.GetInteger(t["AssignPrivilegeValue"]),
                               PrivilegeId = new Guid(t["AssignPrivilegeId"])
                           };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value.ToString()),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["ShowMenuPrivilegeValue"]),
                    PrivilegeId = new Guid(t["ShowMenuPrivilegeId"])
                };
                pl.Add(item);
            }

            var scr = new SecurityFactory();
            scr.SetRolePrivilege(pl, null);
            rolelist.Reload();
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

}
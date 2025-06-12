using System;
using System.Collections.Generic;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Users;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;

public partial class CrmPages_Admin_Administrations_SecurityRoles_RolePrivilegesRefleX : AdminPage
{
    public CrmPages_Admin_Administrations_SecurityRoles_RolePrivilegesRefleX()
    {
        ObjectId = EntityEnum.Systemuser.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Systemuser PrvCreate,PrvDelete,PrvWrite");
        }
        if (!RefleX.IsAjxPostback)
        {
            hdnRoleId.Value = QueryHelper.GetString("RoleId");


            //ComboFieldBu.load
        }
    }
    protected void ComboFieldBuOnRefreshData(object sender, AjaxEventArgs e)
    {
        var uf = new UsersFactory();
        ComboFieldBu.DataSource = uf.GetBusinessUnitList();
        ComboFieldBu.DataBind();

    }

    protected void Store2OnRefreshData(object sender, AjaxEventArgs e)
    {
        if (!string.IsNullOrEmpty(hdnRoleId.Value)
         )
        {
            var scr = new SecurityFactory();
            rolelist.DataSource = scr.GetRolePrivileges(new Guid(hdnRoleId.Value));
            rolelist.DataBind();
        }
    }

    protected void SubmitGrids(object sender, AjaxEventArgs e)
    {
        try
        {
            var sel = rolelist.AllRows;
            if (sel == null)
                return;
            var pl = new List<RolePrivilege>();

            foreach (var t in sel)
            {
                var item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["ReadPrivilegeValue"]),
                    PrivilegeId = new Guid(t["ReadPrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["WritePrivilegeValue"]),
                    PrivilegeId = new Guid(t["WritePrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["AppendPrivilegeValue"]),
                    PrivilegeId = new Guid(t["AppendPrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["AppendToPrivilegeValue"]),
                    PrivilegeId = new Guid(t["AppendToPrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["CreatePrivilegeValue"]),
                    PrivilegeId = new Guid(t["CreatePrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["DeletePrivilegeValue"]),
                    PrivilegeId = new Guid(t["DeletePrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["SharePrivilegeValue"]),
                    PrivilegeId = new Guid(t["SharePrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["AssignPrivilegeValue"]),
                    PrivilegeId = new Guid(t["AssignPrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["ShowMenuPrivilegeValue"]),
                    PrivilegeId = new Guid(t["ShowMenuPrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);

                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["MultiLanguagePrivilegeValue"]),
                    PrivilegeId = new Guid(t["MultiLanguagePrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);
                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["ApprovalPrivilegeValue"]),
                    PrivilegeId = new Guid(t["ApprovalPrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);
                item = new RolePrivilege
                {
                    RoleId = new Guid(hdnRoleId.Value),
                    PrivilegeDepthMask =
                        ValidationHelper.GetInteger(t["SetActivePassivePrivilegeValue"]),
                    PrivilegeId = new Guid(t["SetActivePassivePrivilegeId"]),
                    BusinessUnitId = ValidationHelper.GetGuid(t["BusinessUnitId"]),
                    IsMasterBusinessUnit = ValidationHelper.GetBoolean(t["IsMasterBusinessUnit"])
                };
                pl.Add(item);
            }

            var scr = new SecurityFactory();
            if(ValidationHelper.GetBoolean(Coretech.Crm.Factory.App.Params.GetConfigKeyValue("ROLE_PRIVILEGE_CONFIRM", "false")))
            {
                scr.SetRolePrivilege(pl, Coretech.Crm.Factory.App.Params.CurrentUser.SystemUserId);
            }
            else
            {
                scr.SetRolePrivilege(pl);
            }
            rolelist.Reload();
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
        }
    }
    protected void BtnWindowImportClickOnEvent(object sender, AjaxEventArgs e)
    {
        var scr = new SecurityFactory();
        if (ValidationHelper.GetGuid(RoleCrmLookupComp.Value) != Guid.Empty)
        {
            scr.CopyRole(ValidationHelper.GetGuid(RoleCrmLookupComp.Value), ValidationHelper.GetGuid(hdnRoleId.Value));
            rolelist.Reload();
            WindowImport.Hide();
        }
    }
}
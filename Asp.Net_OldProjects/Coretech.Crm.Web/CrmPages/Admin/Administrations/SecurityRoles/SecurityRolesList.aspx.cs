using System;
using System.Collections.Generic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;

public partial class CrmPages_Admin_Administrations_SecurityRoles_SecurityRolesList : AdminPage
{
    public CrmPages_Admin_Administrations_SecurityRoles_SecurityRolesList()
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
        }
    }

    protected void StoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var scr = new SecurityFactory();
        store1.DataSource = scr.GetRoles();
        store1.DataBind();
    }

    protected void RowSelectOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);
            RoleName.Text = degerler[0]["Name"];
            hdnRoleId.Value = degerler[0]["RoleId"];
            RoleName.ReadOnly = true;
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }


    protected void NewOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            hdnRoleId.Clear();
            RoleName.Clear();
            RoleName.ReadOnly = false;
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

    protected void AddOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(RoleName.Value.ToString()) &&
                string.IsNullOrEmpty(hdnRoleId.Value.ToString())
                )
            {
                var typ = new Role
                {
                    Name = RoleName.Value.ToString()
                };

                var scr = new SecurityFactory();
                var rid = scr.SetRole(typ);;
                hdnRoleId.Value = rid.ToString();
                RoleName.ReadOnly = true;
                _grdsma.Reload();
            }
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

    protected void DeleteOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(hdnRoleId.Value.ToString()))
            {
                var typ = new Role
                {
                    Name = RoleName.Value.ToString(),
                    RoleId = new Guid(hdnRoleId.Value.ToString())
                };

                var scr = new SecurityFactory();
                scr.DeleteRole(typ); ;
                NewOnEvent(sender, e);
                _grdsma.Reload();
            }
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}

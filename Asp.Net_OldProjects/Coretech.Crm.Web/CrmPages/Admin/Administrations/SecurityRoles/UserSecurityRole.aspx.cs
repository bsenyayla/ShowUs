using System;
using System.Collections.Generic;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Crm.Dynamic;


public partial class CrmPages_Admin_Administrations_SecurityRoles_UserSecurityRole : AdminPage
{
    public CrmPages_Admin_Administrations_SecurityRoles_UserSecurityRole()
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
        var dt = scr.GetUserRoles(ValidationHelper.GetGuid(QueryHelper.GetString("RecordId")));
        store1.DataSource = dt;
        store1.DataBind();

        var sm = _grdsma.SelectionModel.Primary as RowSelectionModel;

        if (sm != null)
        {
            sm.SelectedRows.Clear();
            sm.UpdateSelection();
            sm.SelectedRow = new SelectedRow();
            foreach (var t in dt.Where(t => t.Selected))
            {
                sm.SelectedRows.Add(new SelectedRow(t.RoleId.ToString()));
            }
            sm.UpdateSelection();
        }
    }

    protected void RollAddOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);

            var datas = degerler.Select(t => new UserSecurity
                                                 {
                                                     RoleId = ValidationHelper.GetGuid(t["RoleId"]),
                                                     SystemUserId = ValidationHelper.GetGuid(QueryHelper.GetString("RecordId")),
                                                     EndDate = ValidationHelper.ParseObj2NullDateTime(t["EndDate"]),
                                                     StartDate = ValidationHelper.ParseObj2NullDateTime(t["StartDate"]),
                                                 }).ToList();

            var sf = new SecurityFactory();
            sf.SaveUserSecurityRoll(datas, ValidationHelper.GetGuid(QueryHelper.GetString("RecordId")));
            _grdsma.Reload();
            
            MessageShow( CrmLabel.TranslateMessage(LabelEnum.USER_ROLES_SAVED));
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}
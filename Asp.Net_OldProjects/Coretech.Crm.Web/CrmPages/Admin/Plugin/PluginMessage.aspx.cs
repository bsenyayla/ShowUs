using System;
using System.Collections.Generic;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Objects.Crm.Plugin;

public partial class CrmPages_Admin_Plugin_PluginMessage : AdminPage
{
    public CrmPages_Admin_Plugin_PluginMessage()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!Ext.IsAjaxRequest)
        {
            hdnPluginId.Value = QueryHelper.GetString("PluginId");
        }
    }

    protected void EntityStoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var ef = new EntityFactory();
        entitystore.DataSource = ef.GetEntityList();
        entitystore.DataBind();
    }

    protected void MessageTypeStoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var pf = new PluginFactory();
        messagetype.DataSource = pf.GetPluginMessageType();
        messagetype.DataBind();
    }

    protected void MessageListStoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var pf = new PluginFactory();
        messagelist.DataSource = pf.GetPluginMessageList(ValidationHelper.GetGuid(hdnPluginId.Value));
        messagelist.DataBind();
    }

    protected void RowSelectOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);

            cmbmessagetype.Value = degerler[0]["MessageTypeId"];
            Entity.Value = degerler[0]["ObjectId"];
            RunInUser.Value = degerler[0]["RunInUser"];
            chkbefore.Checked = ValidationHelper.GetBoolean(degerler[0]["Before"]);
            chkafter.Checked = ValidationHelper.GetBoolean(degerler[0]["After"]);
            hdnPluginMessageId.Value = degerler[0]["PluginMessageId"];
            ExecutionOrder.Number = ValidationHelper.GetDouble(degerler[0]["ExecutionOrder"], 0);
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
            cmbmessagetype.ClearValue();
            Entity.ClearValue();
            RunInUser.ClearValue();
            chkbefore.Checked = false;
            chkafter.Checked = false;
            ExecutionOrder.Clear();
            hdnPluginMessageId.Clear();

            var sm = _grdsma.SelectionModel.Primary as RowSelectionModel;
            if (sm != null)
            {
                sm.SelectedRows.Clear();
                sm.UpdateSelection();
            }
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
            var pf = new PluginFactory();
            var pm = new PluginMessage
                         {
                             After = ValidationHelper.GetBoolean(chkafter.Checked),
                             Before = ValidationHelper.GetBoolean(chkbefore.Checked),
                             ExecutionOrder = ValidationHelper.GetInteger(ExecutionOrder.Number),
                             RunInUser = ValidationHelper.GetInteger(RunInUser.SelectedItem.Value),
                             ObjectId = ValidationHelper.GetInteger(Entity.SelectedItem.Value),
                             PluginId = ValidationHelper.GetGuid(hdnPluginId.Value),
                             MessageTypeId = ValidationHelper.GetGuid(cmbmessagetype.SelectedItem.Value),
                             PluginMessageId = ValidationHelper.GetGuid(hdnPluginMessageId.Value)
                         };
            pf.SavePluginMessage(pm,null);

            _grdsma.Reload();

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
            if (string.IsNullOrEmpty(hdnPluginMessageId.Value.ToString()))
                return;
            var pf = new PluginFactory();
            pf.DeletePluginMessage(ValidationHelper.GetGuid(hdnPluginMessageId.Value));
            NewOnEvent(sender, e);
            _grdsma.Reload();
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

}
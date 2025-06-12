using System;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Labels;
public partial class CrmPages_Admin_Plugin_PluginMessageReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Plugin_PluginMessageReflex()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessages()
    {
      
        New.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        Add.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        Delete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        chkbefore.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_BEFORE);
        chkafter.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_AFTER);
        ExecutionOrder.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_PLUGIN_EXECUTION_ORDER);
        RunInUser.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_PLUGIN_RUN_IN_USER);
        cmbmessagetype.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_MESSAGES_TYPE);
        Entity.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_ENTITY);
        _grdsma.ColumnModel.Columns[5].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_NAME);
        _grdsma.ColumnModel.Columns[6].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_BEFORE);
        _grdsma.ColumnModel.Columns[7].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_AFTER);
      
    }
    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        base.OnPreInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!RefleXFrameWork.RefleX.IsAjxPostback)
        {
            hdnPluginId.Value = QueryHelper.GetString("PluginId");
        }
    }

    protected void EntityStoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var ef = new EntityFactory();
        Entity.DataSource = ef.GetEntityList();
        Entity.DataBind();
    }

    protected void MessageTypeStoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var pf = new PluginFactory();
        cmbmessagetype.DataSource = pf.GetPluginMessageType();
        cmbmessagetype.DataBind();
    }

    protected void MessageListStoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var pf = new PluginFactory();
        _grdsma.DataSource = pf.GetPluginMessageList(ValidationHelper.GetGuid(hdnPluginId.Value));
        _grdsma.DataBind();
    }

    protected void RowSelectOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var degerler = _grdsma.SelectionModel[0] as RowSelectionModel;

            cmbmessagetype.SetIValue(degerler.SelectedRows["MessageTypeId"]);
            Entity.SetIValue(degerler.SelectedRows["ObjectId"]);
            RunInUser.SetIValue(degerler.SelectedRows["RunInUser"]);
           
            chkbefore.SetValue(ValidationHelper.GetBoolean(degerler.SelectedRows["Before"]));
            chkafter.SetValue(ValidationHelper.GetBoolean(degerler.SelectedRows["After"]));

            hdnPluginMessageId.SetIValue(degerler.SelectedRows["PluginMessageId"]);
            ExecutionOrder.SetIValue(ValidationHelper.GetDouble(degerler.SelectedRows["ExecutionOrder"], 0));
        }
        catch (Exception ex)
        {
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

    protected void NewOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            cmbmessagetype.Clear();
            Entity.Clear();
            RunInUser.Clear();
            chkbefore.SetIValue(false);
            chkafter.SetIValue(false);
            ExecutionOrder.Clear();
            hdnPluginMessageId.Clear();
            var sm = _grdsma.SelectionModel[0] as RowSelectionModel;
        }
        catch (Exception ex)
        {
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
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
                             ExecutionOrder = ValidationHelper.GetInteger(ExecutionOrder.Value),
                             RunInUser = ValidationHelper.GetInteger(RunInUser.Value),
                             ObjectId = ValidationHelper.GetInteger(Entity.Value),
                             PluginId = ValidationHelper.GetGuid(hdnPluginId.Value),
                             MessageTypeId = ValidationHelper.GetGuid(cmbmessagetype.Value),
                             PluginMessageId = ValidationHelper.GetGuid(hdnPluginMessageId.Value)
                         };
            pf.SavePluginMessage(pm,null);

            _grdsma.Reload();

        }
        catch (Exception ex)
        {
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
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
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

}
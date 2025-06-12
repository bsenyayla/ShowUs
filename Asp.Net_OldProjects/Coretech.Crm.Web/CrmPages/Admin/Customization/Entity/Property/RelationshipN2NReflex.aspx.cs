using System;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Objects.Crm.Attributes;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Labels;

public partial class CrmPages_Admin_Customization_Entity_Property_RelationshipN2NReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_RelationshipN2NReflex()
    {
        ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessages()
    {
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        btnAdd.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        DisplayName.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DISPLAY_NAME);
        Entity.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_ENTITY);
        Name.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_NAME);
        txtDescription.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DESCRIPTION);
        _grdsma.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_ATTRIBUTE_NAME);
        _grdsma.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DISPLAY_NAME);
        _grdsma.ColumnModel.Columns[4].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_NAME);
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
        if (!RefleX.IsAjxPostback)
        {
            if (!string.IsNullOrEmpty(QueryHelper.GetString("ObjectId","")))
            {
                var ef = new EntityFactory();
                var eo = ef.GetEntityFromObjectId(QueryHelper.GetInteger("ObjectId", 0));
                hdnentityid.Value = eo.EntityId.ToString();

                var eaf = new EntityAttributeFactory();
                var eao = eaf.GetEntityAttributesByObjectId(QueryHelper.GetInteger("ObjectId", 0));

                objectid.Value = QueryHelper.GetString("ObjectId", "");
            }
        }
    }

    protected void StoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var ef = new AttributeAdd();
        _grdsma.DataSource = ef.GetLookupNtoN(new Guid(hdnentityid.Value));
        _grdsma.DataBind();
    }

    protected void EntityStoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var ef = new EntityFactory();
        Entity.DataSource = ef.GetEntityList();
        Entity.DataBind();
    }

    protected void NewOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            hdnattributeid.Clear();
            DisplayName.Clear();
            Entity.Clear();
            Name.Clear();
            Name.ReadOnly = false;
        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

    protected void AddOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var lu = new AttributeAdd();
            var data = new FLookup
                           {
                               AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                               ObjectId = ValidationHelper.GetInteger(objectid.Value,0),
                               ToEntityId = new Guid(hdnentityid.Value),
                               DisplayName = DisplayName.Value,
                               Name = Name.Value,
                               ReferencedObjectId = ValidationHelper.GetInteger(Entity.Value, 0),
                               Description = txtDescription.Value
                           };
            hdnattributeid.Value = lu.SetLookupNtoN(data).ToString();
            _grdsma.Reload();
        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

    protected void DeleteOnEvent(object sender, AjaxEventArgs e)
    {
        var degerler = _grdsma.SelectionModel[0] as RowSelectionModel;

        if (degerler != null)
        {
            Name.Value = ValidationHelper.GetString(degerler.SelectedRows["AttributeName"]);
            DisplayName.Value = ValidationHelper.GetString(degerler.SelectedRows["DisplayName"]);
            Entity.Value = ValidationHelper.GetString(degerler.SelectedRows["FromObjectId"]);
            hdnattributeid.Value = ValidationHelper.GetString(degerler.SelectedRows["ToAttributeId"]);
            txtDescription.Value = ValidationHelper.GetString(degerler.SelectedRows["Description"]);
        }
        try
        {
            if (!string.IsNullOrEmpty(hdnattributeid.Value))
            {
                var atr = new AttributeAdd();
                atr.DeleteAttribute(new Guid(hdnattributeid.Value), new Guid(hdnentityid.Value));
                NewOnEvent(sender, e);
                _grdsma.Reload();
            }
        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

    protected void RowSelectOnEvent(object sender, AjaxEventArgs e)
    {

    }
}

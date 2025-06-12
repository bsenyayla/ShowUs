using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Objects.Crm.Attributes;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Labels;

public partial class CrmPages_Admin_Customization_Entity_Property_RelationshipListReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_RelationshipListReflex()
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
        Format.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_FORMAT);
        txtDescription.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DESCRIPTION);
        _grdsma.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_ATTRIBUTE_NAME);
        _grdsma.ColumnModel.Columns[4].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DISPLAY_NAME);
        _grdsma.ColumnModel.Columns[5].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_NAME);
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
            var atr = Enum.GetNames(typeof(EFormatLookup));

            for (var i = 8; i < 8 + atr.Length; i++)
            {
                var li = new ListItem { Value = i.ToString(), Text = atr[i - 8] };
                Format.Items.Add(li);
            }
            Format.Value = EFormatLookup.LookupCombo.GetHashCode().ToString();

            if (!string.IsNullOrEmpty(QueryHelper.GetString("ObjectId", "")))
            {
                var ef = new EntityFactory();
                var eo = ef.GetEntityFromObjectId(QueryHelper.GetInteger("ObjectId", 0));
                hdnentityid.Value = eo.EntityId.ToString();

                var eaf = new EntityAttributeFactory();
                var eao = eaf.GetEntityAttributesByObjectId(QueryHelper.GetInteger("ObjectId", 0));

                objectid.Value = QueryHelper.GetString("ObjectId", "");
            }

            var ctypes = Enum.GetNames(typeof(ERelationshipBehavior));
            for (int i = 0; i < ctypes.Length; i++)
            {
                var li = new ListItem { Value = i.ToString(), Text = ctypes[i] };
                if (i < 3)
                {
                    CShare.Items.Add(li);
                    CUnShare.Items.Add(li);
                    CAssing.Items.Add(li);

                }
                if (i != 1)
                    CDelete.Items.Add(li);
            }
            CShare.Value = ERelationshipBehavior.CascadeNone.GetHashCode().ToString();
            CUnShare.Value = ERelationshipBehavior.CascadeNone.GetHashCode().ToString();
            CAssing.Value = ERelationshipBehavior.CascadeNone.GetHashCode().ToString();
            CDelete.Value = ERelationshipBehavior.CascadeNone.GetHashCode().ToString();
        }
    }

    protected void StoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var ef = new AttributeAdd();
        _grdsma.DataSource = ef.GetLookup(new Guid(hdnentityid.Value));
        _grdsma.DataBind();
    }

    protected void EntityStoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var ef = new EntityFactory();
        var ds = new List<object>();
        foreach (var o in ef.GetEntityListFromApplication())
        {
            ds.Add(new { o.ObjectId, Label = o.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId) });
        }
        Entity.DataSource = ds;
        Entity.DataBind();
    }

    protected void NewOnEvent(object sender, AjaxEventArgs e)
    {

        try
        {
            Name.SetDisabled(false);
            Entity.SetDisabled(false);

            hdnattributeid.Clear();
            DisplayName.Clear();
            Entity.Clear();
            Name.Clear();
            
            var sm = _grdsma.SelectionModel[0] as RowSelectionModel;
            if (sm != null) sm.Attributes.Clear();
            CShare.SetValue( ERelationshipBehavior.CascadeNone.GetHashCode().ToString());
            CUnShare.SetValue(ERelationshipBehavior.CascadeNone.GetHashCode().ToString());
            CAssing.SetValue(ERelationshipBehavior.CascadeNone.GetHashCode().ToString());
            CDelete.SetValue(ERelationshipBehavior.CascadeNone.GetHashCode().ToString());
            _grdsma.Reload();
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
            if (
                 string.IsNullOrEmpty(Name.Value)
                 )
            {
                var msg = new MessageBox();
                msg.Show("Zorunlu Alanları Giriniz!");
                return;
            }
            var lu = new AttributeAdd();
            var data = new FLookup
                           {
                               AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                               ObjectId = ValidationHelper.GetInteger(objectid.Value, 0),
                               ToEntityId = new Guid(hdnentityid.Value),
                               DisplayName = DisplayName.Value,
                               Name = Name.Value,
                               LookupType = (EFormatLookup)Enum.Parse(typeof(EFormatLookup), Format.Value),
                               ReferencedObjectId = ValidationHelper.GetInteger(Entity.Value, 0),
                               Description = txtDescription.Value,
                               CAssing = (ERelationshipBehavior)ValidationHelper.GetInteger(CAssing.Value,0),
                               CDelete = (ERelationshipBehavior)ValidationHelper.GetInteger(CDelete.Value,0),
                               CShare = (ERelationshipBehavior)ValidationHelper.GetInteger(CShare.Value,0),
                               CUnShare = (ERelationshipBehavior)ValidationHelper.GetInteger(CUnShare.Value,0),
                               IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value, false)
                           };
            hdnattributeid.Value = lu.SetLookup(data).ToString();
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

        Name.Value = ValidationHelper.GetString(degerler.SelectedRows["AttributeName"]);
        DisplayName.Value = ValidationHelper.GetString(degerler.SelectedRows["DisplayName"]);
        Entity.Value = ValidationHelper.GetString(degerler.SelectedRows["FromObjectId"]);
        Name.ReadOnly = true;
        hdnattributeid.Value = ValidationHelper.GetString(degerler.SelectedRows["ToAttributeId"]);
        txtDescription.Value = ValidationHelper.GetString(degerler.SelectedRows["Description"]);
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
        try
        {
            var degerler = _grdsma.SelectionModel[0] as RowSelectionModel;

            Name.SetValue(ValidationHelper.GetString(degerler.SelectedRows["AttributeName"]));
            DisplayName.SetValue(ValidationHelper.GetString(degerler.SelectedRows["DisplayName"]));
            Entity.SetValue(ValidationHelper.GetString(degerler.SelectedRows["FromObjectId"]));
            Name.SetDisabled(true);
            Entity.SetDisabled(true);

            Format.SetValue(ValidationHelper.GetString(degerler.SelectedRows["LookupTypeValue"]));
            hdnattributeid.SetValue(ValidationHelper.GetGuid(degerler.SelectedRows["ToAttributeId"]).ToString());
            txtDescription.SetValue(ValidationHelper.GetString(degerler.SelectedRows["Description"]));

            CShare.SetValue(ValidationHelper.GetString(degerler.SelectedRows["CShare"]));
            CUnShare.SetValue(ValidationHelper.GetString(degerler.SelectedRows["CUnShare"]));
            CAssing.SetValue(ValidationHelper.GetString(degerler.SelectedRows["CAssing"]));
            CDelete.SetValue(ValidationHelper.GetString(degerler.SelectedRows["CDelete"]));

            IsLoggable.SetIValue(ValidationHelper.GetBoolean(degerler.SelectedRows["IsLoggable"]));
        }
        catch (Exception ex)
        {
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

}

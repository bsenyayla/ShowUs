using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using System.Collections.Generic;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Labels;
using System.Linq;
using Coretech.Crm.Factory.Site;
using Coretech.Crm.Objects.Site;
using Coretech.Crm.Objects.Crm;

public partial class CrmPages_Admin_Customization_Entity_Property_EntityPropertyReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_EntityPropertyReflex()
    {
        ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessages()
    {
        Save.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        Delete.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        DisplayName.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DISPLAY_NAME);
        UniqueName.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ENTITY_PROPERTY_UNIQUE_NAME);
        PrimaryName.FieldLabel= Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ENTITY_PROPERTY_PRIMARY_NAME);
        PrimaryDisplayName.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ENTITY_PROPERTY_PRIMARY_LABEL);
        IsHierarchicalModel.FieldLabel= Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ENTITY_PROPERTY_ISHIERARCHICALMODEL);
        IsMultipleLanguage.FieldLabel= Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ENTITY_PROPERTY_ISMULTIPLELANGUAGE);
        txtDescription.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DESCRIPTION);
        _grdsma.ColumnModel.Columns[1].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_LABEL);
        EnableLogging.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ENTITY_PROPERTY_ENABLE_LOGGING);
        IsDataExportable.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ENTITY_PROPERTY_ISDATAEXPORTABLE);
        NotShareable.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ENTITY_PROPERTY_NOTSHAREABLE);
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
            if (!string.IsNullOrEmpty(QueryHelper.GetString("ObjectId", "")))
            {
                objectid.Value = QueryHelper.GetString("ObjectId", "");
                GetData();
                GetSmaData();
            }
            else
            {
                GetSmaData();
            }
        }
    }

    private void GetData()
    {
        var ef = new EntityFactory();
        var eo = ef.GetEntityFromObjectId(ValidationHelper.GetInteger(objectid.Value, 0));

        DisplayName.Value = eo.Label;
        foreach (var abc in
            App.Params.CurrentEntityAttribute.ToArray().Where(abc => abc.Value.EntityId == eo.EntityId).Where(abc => abc.Value.IsValueAttribute))
        {
            PrimaryName.Value = abc.Value.UniqueName;
            PrimaryDisplayName.Value = abc.Value.GetLabel(App.Params.CurrentUser.LanguageId);
        }

        UniqueName.Value = eo.UniqueName;
        UniqueName.Disabled = true;
        PrimaryName.Disabled = true;
        PrimaryDisplayName.Disabled = true;
        DisplayName.Disabled = true;
        EnableLogging.Checked = eo.EnableLogging;
        IsHierarchicalModel.Checked = eo.IsHierarchicalModel;
        IsHierarchicalModel.Disabled = true;
        IsMultipleLanguage.Disabled = true;
        IsMultipleLanguage.Checked = eo.IsMultipleLanguage;
        IsDataExportable.Checked = eo.IsDataExportable;
        NotShareable.Checked = eo.NotShareable;
        entityid.Value = eo.EntityId.ToString();
        txtDescription.Value = eo.Description;
    }

    private void GetSmaData()
    {

        var mf = new ModulesFactory();
        var dt = mf.GetUserModules(false);
        _grdsma.DataSource = dt;
        _grdsma.DataBind();

        if (!string.IsNullOrEmpty(objectid.Value))
        {
            var sma = mf.GetEntitySiteMapArea(ValidationHelper.GetInteger(objectid.Value, 0));
            _grdsma.ClearSelection();
            for (int i = 0; i < dt.Count; i++)
            {
                var sitem = dt[i];
                foreach (var item in sma)
                {
                    if (sitem.SiteMapId != item.SiteMapId) continue;
                    _grdsma.SetSelectedRowsIndex(i);
                    continue;
                }

            }
        }
    }

    protected void SaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var ent = new Entity
                          {
                              UniqueName = UniqueName.Value,
                              PrimaryName = PrimaryName.Value,
                              Label = DisplayName.Value,
                              PrimaryDisplayName = PrimaryDisplayName.Value,
                              EnableLogging = EnableLogging.Checked,
                              IsHierarchicalModel = IsHierarchicalModel.Checked,
                              IsMultipleLanguage = IsMultipleLanguage.Checked,
                              Description = txtDescription.Value,
                              NotShareable=NotShareable.Checked,
                              IsDataExportable = IsDataExportable.Checked,
                          };
            var ef = new EntityFactory();
            if (string.IsNullOrEmpty(objectid.Value))
            {
                var objid = ef.CreateEntity(ent);
                objectid.Value = objid.ToString();
            }
            else
            {
                ent.ObjectId = ValidationHelper.GetInteger(objectid.Value, 0);
                ef.UpdateEntity(ent);
            }

            var eo = ef.GetEntityFromObjectId(ValidationHelper.GetInteger(objectid.Value, 0));
            entityid.Value = eo.EntityId.ToString();

            var mf = new ModulesFactory();
            var sm = (CheckSelectionModel)_grdsma.SelectionModel[0];
            var areas = new List<SiteMapArea>();
            if (sm != null)
            {
                if (sm.SelectedRows != null)
                {
                    foreach (var t in sm.SelectedRows)
                    {
                        areas.Add(new SiteMapArea
                                      {
                                          SiteMapId = new Guid(t.SiteMapId),
                                          SiteMapAreaId = Guid.NewGuid(),
                                          EntityId = eo.EntityId
                                      }
                            );

                    }
                }
            }
            if (ValidationHelper.GetInteger(objectid.Value, 0) != 0)
            {
                ef.PublisFromObjectId(ValidationHelper.GetInteger(objectid.Value, 0));
                Coretech.Crm.Provider.CrmApplication.LoadApplicationData();
                mf.SaveEntitySiteMapArea(areas, ValidationHelper.GetInteger(objectid.Value, 0));


                ef.PublisFromObjectId(ValidationHelper.GetInteger(objectid.Value, 0));
                Coretech.Crm.Provider.CrmApplication.LoadApplicationData();
            }
            var msg = new MessageBox();
            msg.Show("Kaydedildi.");

        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

    protected void DeleteOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var ef = new EntityFactory();
            if (!string.IsNullOrEmpty(objectid.Value))
            {
                ef.DeleteEntity(ValidationHelper.GetInteger(objectid.Value, 0));
            }
            entityid.Clear();
            objectid.Clear();
            DisplayName.Clear();
            PrimaryDisplayName.Clear();
            UniqueName.Clear();
            PrimaryName.Clear();
            var msg = new MessageBox();
            msg.Show("Silindi.");
        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }
    protected void tbbPublish_OnClikc(object sender, AjaxEventArgs e)
    {
        if (objectid.Value == string.Empty) return;
        var ef = new EntityFactory();
        ef.PublisFromObjectId(ValidationHelper.GetInteger(objectid.Value, 0));
        Coretech.Crm.Provider.CrmApplication.LoadApplicationData();
        var msg = new MessageBox();
        msg.Show("Publish Completed ");
    }
}

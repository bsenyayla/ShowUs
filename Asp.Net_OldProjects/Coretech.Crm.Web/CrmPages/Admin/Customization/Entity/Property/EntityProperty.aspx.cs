using System;
using System.Collections.Generic;
using System.Linq;
using Coretech.Crm.Factory.Site;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Site;
using Coretech.Crm.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory;
using Coretech.Crm.Objects.Crm;

public partial class CrmPages_Admin_Customization_Entity_Property_EntityProperty : AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_EntityProperty()
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
            if (!string.IsNullOrEmpty(QueryHelper.GetString("ObjectId")))
            {
                var ef = new EntityFactory();
                var eo = ef.GetEntityFromObjectId(QueryHelper.GetInteger("ObjectId"));
                DisplayName.Text = eo.Label;
                foreach (var abc in
                    App.Params.CurrentEntityAttribute.ToArray().Where(abc => abc.Value.EntityId == eo.EntityId).Where(abc => abc.Value.IsValueAttribute))
                {
                    PrimaryName.Text = abc.Value.UniqueName;
                    PrimaryDisplayName.Text = abc.Value.GetLabel(App.Params.CurrentUser.LanguageId);
                }

                UniqueName.Text = eo.UniqueName;
                UniqueName.Disabled = true;
                PrimaryName.Disabled = true;
                PrimaryDisplayName.Disabled = true;
                DisplayName.Disabled = true;
                EnableLogging.Checked = eo.EnableLogging;
                IsHierarchicalModel.Checked = eo.IsHierarchicalModel;
                IsHierarchicalModel.Disabled = true;
                IsMultipleLanguage.Disabled = true;
                IsDataExportable.Checked = eo.IsDataExportable;
                NotShareable.Checked = eo.NotShareable;
                IsMultipleLanguage.Checked = eo.IsMultipleLanguage;
                entityid.Value = eo.EntityId.ToString();
                objectid.Value = QueryHelper.GetString("ObjectId");
                txtDescription.Text = eo.Description;
            }
        }
    }


    protected void SmaOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var mf = new ModulesFactory();
        var sma = mf.GetEntitySiteMapArea(ValidationHelper.GetInteger(objectid.Value, 0));
        var dt = mf.GetUserModules(false);
        smastore.DataSource = dt;

        var sm = _grdsma.SelectionModel.Primary as RowSelectionModel;

        if (sm != null)
        {
            sm.SelectedRows.Clear();
            sm.UpdateSelection();
            sm.SelectedRow = new SelectedRow();

            foreach (var modules in
                from modules in dt
                where modules != null
                from t in sma.Where(t => t.SiteMapId == modules.SiteMapId)
                select modules)
            {
                sm.SelectedRows.Add(new SelectedRow(modules.SiteMapId.ToString()));
            }

            sm.UpdateSelection();
        }
    }

    protected void SaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var ent = new Entity
                          {
                              UniqueName = UniqueName.Text,
                              PrimaryName = PrimaryName.Text,
                              Label = DisplayName.Text,
                              PrimaryDisplayName = PrimaryDisplayName.Text,
                              EnableLogging = EnableLogging.Checked,
                              IsHierarchicalModel = IsHierarchicalModel.Checked,
                              IsMultipleLanguage = IsMultipleLanguage.Checked,
                              Description = txtDescription.Text,
                              IsDataExportable = IsDataExportable.Checked,
                              NotShareable = NotShareable.Checked
                          };
            var ef = new EntityFactory();
            if (string.IsNullOrEmpty(objectid.Value.ToString()))
            {
                var objid = ef.CreateEntity(ent);
                objectid.Value = objid.ToString();
            }
            else
            {
                ent.ObjectId = ValidationHelper.GetInteger(objectid.Value.ToString(), 0);
                ef.UpdateEntity(ent);
            }

            var eo = ef.GetEntityFromObjectId(ValidationHelper.GetInteger(objectid.Value.ToString(), 0));
            entityid.Value = eo.EntityId.ToString();

            var mf = new ModulesFactory();
            var sm = _grdsma.SelectionModel.Primary as RowSelectionModel;
            var areas = new List<SiteMapArea>();
            if (sm != null)
            {
                areas = sm.SelectedRows.Select(t => new SiteMapArea
                                                           {
                                                               SiteMapId = new Guid(t.RecordID),
                                                               SiteMapAreaId = Guid.NewGuid(),
                                                               EntityId = eo.EntityId
                                                           }).ToList();

            }
            if (ValidationHelper.GetInteger(objectid.Value, 0) != 0)
            {
                ef.PublisFromObjectId(ValidationHelper.GetInteger(objectid.Value, 0));
                Coretech.Crm.Provider.CrmApplication.LoadApplicationData();
                mf.SaveEntitySiteMapArea(areas, ValidationHelper.GetInteger(objectid.Value, 0));


                ef.PublisFromObjectId(ValidationHelper.GetInteger(objectid.Value, 0));
                Coretech.Crm.Provider.CrmApplication.LoadApplicationData();
            }

            MessageShow("Kaydetme Tamamlandı.");
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
            var ef = new EntityFactory();
            if (!string.IsNullOrEmpty(objectid.Value.ToString()))
            {
                ef.DeleteEntity(ValidationHelper.GetInteger(objectid.Value, 0));
            }

            entityid.Clear();
            objectid.Clear();
            DisplayName.Clear();
            PrimaryDisplayName.Clear();
            UniqueName.Clear();
            PrimaryName.Clear();

            MessageShow("Silme Tamamlandı.");
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}

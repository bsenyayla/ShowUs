using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Objects.Crm.Attributes;
using System.Collections.Generic;

public partial class CrmPages_Admin_Customization_Entity_Property_RelationshipN2N : AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_RelationshipN2N()
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
                hdnentityid.Value = eo.EntityId.ToString();
            }
        }
    }

    protected void StoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var ef = new AttributeAdd();
        store1.DataSource = ef.GetLookupNtoN(new Guid(hdnentityid.Value.ToString()));
        store1.DataBind();
    }

    protected void EntityStoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var ef = new EntityFactory();
        //List<Entity> entities= App.Params.CurrentEntity.Values.ToList();
        entitystore.DataSource = ef.GetEntityList();
        entitystore.DataBind();
    }

    protected void NewOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            hdnattributeid.Clear();
            DisplayName.Clear();
            Entity.ClearValue();
            Name.Clear();
            Name.ReadOnly = false;
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
            if (string.IsNullOrEmpty(Entity.SelectedItem.Value) ||
                string.IsNullOrEmpty(Name.Value.ToString())
                )
            {
                MessageShow("Zorunlu Alanları Giriniz!");
                return;
            }

            var lu = new AttributeAdd();
            var data = new FLookup
                           {
                               AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                               ObjectId = QueryHelper.GetInteger("ObjectId"),
                               ToEntityId = new Guid(hdnentityid.Value.ToString()),
                               DisplayName = DisplayName.Value.ToString(),
                               Name = Name.Value.ToString(),
                               ReferencedObjectId = ValidationHelper.GetInteger(Entity.SelectedItem.Value, 0),
                               Description = txtDescription.Text
                           };
            hdnattributeid.Value = lu.SetLookupNtoN(data).ToString();
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
            if (!string.IsNullOrEmpty(hdnattributeid.Value.ToString()))
            {
                var atr = new AttributeAdd();
                atr.DeleteAttribute(new Guid(hdnattributeid.Value.ToString()), new Guid(hdnentityid.Value.ToString()));
                NewOnEvent(sender, e);
                _grdsma.Reload();
            }
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

    protected void RowSelectOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);
            Name.Text = degerler[0]["AttributeName"];
            DisplayName.Text = degerler[0]["DisplayName"];
            Entity.Value = degerler[0]["FromObjectId"];
            Name.ReadOnly = true;
            hdnattributeid.Value = degerler[0]["ToAttributeId"];
            txtDescription.Text = degerler[0]["Description"];
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}

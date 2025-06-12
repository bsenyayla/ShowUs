using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Provider;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_Customization_Entity_EntityEditReflex : AdminPage
{
    public CrmPages_Admin_Customization_Entity_EntityEditReflex()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!Page.IsPostBack)
        {
            hdnObjectId.Text = QueryHelper.GetString("ObjectId");
            MenuPanel1.Disabled = string.IsNullOrEmpty(hdnObjectId.Text);
            Panel2.AutoLoad.Url = "Property/EntityProperty.aspx?ObjectId=" + hdnObjectId.Text;
        }
    }

    protected void mnPublish_OnClikc(object sender, AjaxEventArgs e)
    {
        if (hdnObjectId.Text != string.Empty)
        {
            var ef = new EntityFactory();
            ef.PublisFromObjectId(ValidationHelper.GetInteger(hdnObjectId.Text, 0));
            CrmApplication.LoadApplicationData();
            MessageShow("Publish Completed ");
        }
    }
}
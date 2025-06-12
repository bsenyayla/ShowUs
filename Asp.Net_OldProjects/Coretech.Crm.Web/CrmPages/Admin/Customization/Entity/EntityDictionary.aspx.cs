using System;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;

public partial class CrmPages_Admin_Customization_Entity_EntityDictionary : AdminPage
{
    public CrmPages_Admin_Customization_Entity_EntityDictionary()
    {
        ObjectId = EntityEnum.Language.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            btImport.Text = CrmLabel.TranslateMessage("CRM.ENTITY_LABEL_IMPORT_LABEL");
        }
        if (!DynamicSecurity.PrvWrite)
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Language PrvWrite");
        }
    }

    protected void DataLoad(object sender, AjaxEventArgs e)
    {
        var ef = new EntityFactory();
        GridPanel1.DataSource = ef.GetEntityList();
        GridPanel1.DataBind();
    }
   
}
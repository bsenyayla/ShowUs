using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;

using Coretech.Crm.Web.UI.RefleX.View;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
public partial class CrmPages_Admin_Customization_Entity_Property_FormAndViewReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_FormAndViewReflex()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessage()
    {
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        GridPanel1.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_VIEW_NAME);
        GridPanel1.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DESCRIPTION);
    }
    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessage();
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
            hdnObjectId.Value = QueryHelper.GetString("ObjectId", "");
            TranslateMessage();
        }
    }

    protected void Store1_Refresh(object sender, AjaxEventArgs e)
    {
        var vf = new ViewFactory();
        GridPanel1.DataSource = vf.GetViewListByObjectId(ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        GridPanel1.DataBind();
    }
    protected void DeleteViewQuery(object sender, AjaxEventArgs e)
    {
        var vf = new ViewFactory();

        var degerler = GridPanel1.SelectionModel[0] as RowSelectionModel;

        var viewQueryId = string.Empty;

        if (degerler == null)
        {
            return;
        }
        else
        {
            foreach (var rows in degerler.SelectedRows)
            {
                viewQueryId += rows.ViewQueryId + ",";
            }
        }

        try
        {
            if (!string.IsNullOrEmpty(viewQueryId))
            {
                vf.DeleteViewQuery(viewQueryId);

                GridPanel1.Reload();
            }
        }
        catch (Exception ex)
        {
            var mb = new MessageBox();
            mb.Show(ex.Message);

        }

    }
}

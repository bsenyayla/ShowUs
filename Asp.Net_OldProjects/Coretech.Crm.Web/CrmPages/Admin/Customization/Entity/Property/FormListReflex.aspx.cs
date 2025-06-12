using System;
using System.Collections.Generic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm.Form;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Factory.Crm;
public partial class CrmPages_Admin_Customization_Entity_Property_FormListReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_FormListReflex()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessage()
    {
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        DeleteButton.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        GridPanelReflex1.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_FORM_NAME);
        GridPanelReflex1.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DESCRIPTION);
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

        if (!RefleXFrameWork.RefleX.IsAjxPostback)
        {
            hdnObjectReflexId.Value = QueryHelper.GetString("ObjectId", "");
            TranslateMessage();
        }

    }

    protected void Store1_Refresh(object sender, AjaxEventArgs e)
    {
        var vf = new FormFactory();
        var flist = vf.GetFormListByObjectId(ValidationHelper.GetInteger(hdnObjectReflexId.Value, 0));
        var tlist = new List<object>();

        foreach (var form in flist)
        {
            tlist.Add(new { form.Name, form.FormId, form.Description });
        }
        GridPanelReflex1.DataSource = tlist;
        GridPanelReflex1.DataBind();
    }

    protected void DeleteForm(object sender, AjaxEventArgs e)
    {
        var vf = new FormFactory();

        var degerler = GridPanelReflex1.SelectionModel[0] as RowSelectionModel;

        var formId = string.Empty;

        if (degerler == null)
        {
            return;
        }
        else
        {
            foreach (var rows in degerler.SelectedRows)
            {
                formId += rows.FormId + ","; // dictionary["FormId"] + ",";
            }

        }

        try
        {
            if (!string.IsNullOrEmpty(formId))
            {
                vf.DeleteForms(formId);
                GridPanelReflex1.Reload();
            }
        }
        catch (Exception ex)
        {
            var msgbx = new MessageBox();
            msgbx.Show(ex.Message);
        }

    }
}
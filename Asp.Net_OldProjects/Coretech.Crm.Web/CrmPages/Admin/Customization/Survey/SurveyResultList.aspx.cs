using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.Survey;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;

public partial class CrmPages_Admin_Customization_Survey_SurveyResultList : AdminPage
{
    public CrmPages_Admin_Customization_Survey_SurveyResultList()
    {
        base.ObjectId = EntityEnum.Survey.GetHashCode();
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvRead ))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Survey PrvRead");
        }
        if (!Ext.IsAjaxRequest)
        {
            mnuExportExcelAll.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
            hdnHeaderId.Value = QueryHelper.GetString("HeaderId");
        }
    }

    protected void StoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var sr = new SurveyFactory();
        if (!string.IsNullOrEmpty(e.Parameters["FileName"]))
        {
            var filename = e.Parameters["FileName"];
            var dt = Export.PrepareExcel(store1, _grdsma, sr.GetSurveyResultsDt(ValidationHelper.GetGuid(hdnHeaderId.Value)));
            Export.ExportData(dt, filename);
        }

        store1.DataSource = sr.GetSurveyResults(ValidationHelper.GetGuid(hdnHeaderId.Value));
        store1.DataBind();
    }


}
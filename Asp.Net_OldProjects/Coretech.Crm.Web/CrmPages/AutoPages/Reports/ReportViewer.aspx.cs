using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Reporting;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Crm;

public partial class CrmPages_AutoPages_Reports_ReportViewer : BasePage
{
    private DynamicSecurity _dynamicSecurity;


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hdnReportId.Text = QueryHelper.GetString("ReportsId");
            var _dynamicSecurity = DynamicFactory.GetSecurity(EntityEnum.Reports.GetHashCode(),
                                                        ValidationHelper.GetGuid(hdnReportId.Value));
            if (!_dynamicSecurity.PrvRead)
            {
                Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Reports PrvRead");
            }
            RedirectOptions();
            ReportTab.AutoLoad.Url = "ShowReport.aspx?ReportId=" + hdnReportId.Text;
            if (!string.IsNullOrEmpty(hdnReportId.Text))
            {
                fillPage();
            }

        }
    }
    private void RedirectOptions()
    {
        var de = new DynamicEntity(EntityEnum.Reports.GetHashCode());
        DynamicFactory df = new DynamicFactory(ERunInUser.SystemAdmin);
        de = df.RetrieveWithOutPlugin(EntityEnum.Reports.GetHashCode(), ValidationHelper.GetGuid(hdnReportId.Value),
                                 new string[] { });
        if (!de.GetBooleanValue("ShowFilter"))
        {
            Response.Redirect("ShowReport.aspx?ReportId=" + hdnReportId.Value);
        }
    }
    private void fillPage()
    {
        var gdReport = ValidationHelper.GetGuid(hdnReportId.Text);
        var rf = new ReportsFactory();
        var myReport = rf.GetReport(gdReport);
        CBuilder.ObjectId = EntityFactory.GetEntityObjectId(myReport.Entity).ToString();
        if (!string.IsNullOrEmpty(myReport.Filter))
        {
            var filterEntity = ViewAction.GetFilterEntity(myReport.Filter);
            CBuilder.ParseFilterEntity(filterEntity);
        }
        //myReport.Entity;

    }

    //protected void BtnSave_Click(object sender, AjaxEventArgs e)
    //{
    //    var json = e.ExtraParams["Values"];
    //}
    [AjaxMethod(ShowMask = true)]
    public void UpdateView(string xmlData)
    {
        var rf = new ReportsFactory();
        var gdReport = ValidationHelper.GetGuid(hdnReportId.Text);
        rf.UpdateFilter(xmlData, gdReport);
    }
}
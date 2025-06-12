using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Reporting;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using RefleXFrameWork;
using Coretech.Crm.Web.UI.RefleX;
public partial class CrmPages_AutoPages_Reports_ReportList : AdminPage
{
    public CrmPages_AutoPages_Reports_ReportList()
    {
        base.ObjectId = EntityEnum.Reports.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvRead))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Reports PrvRead");
        }
    }
    protected void Store1_Refresh(object sender, AjaxEventArgs e)
    {

        var rf = new ReportsFactory();
        GridPanel1.DataSource = rf.GetReportList();
        GridPanel1.DataBind();
    }
    protected override void OnPreInit(EventArgs e)
    {
        var ulang = App.Params.CurrentUser.LanguageId;
        for (int i = 0; i < GridPanel1.ColumnModel.Columns.Count; i++)
        {
            var gridColumns = GridPanel1.ColumnModel.Columns[i];
            switch (gridColumns.DataIndex)
            {
                case "ReportName":
                    var reportNameId = EntityAttributeFactory.GetAttributeIdFromUniqueName("ReportName", EntityEnum.Reports.GetHashCode());
                    gridColumns.Header = App.Params.CurrentEntityAttribute[reportNameId].GetLabel(ulang);

                    break;
                case "Description":
                    var descriptionId = EntityAttributeFactory.GetAttributeIdFromUniqueName("Description", EntityEnum.Reports.GetHashCode());
                    gridColumns.Header = App.Params.CurrentEntityAttribute[descriptionId].GetLabel(ulang);

                    break;
                case "EntityName":
                    var entityId = EntityAttributeFactory.GetAttributeIdFromUniqueName("Entity", EntityEnum.Reports.GetHashCode());
                    gridColumns.Header = App.Params.CurrentEntityAttribute[entityId].GetLabel(ulang);

                    break;
            }
        }
        base.OnPreInit(e);
    }
}
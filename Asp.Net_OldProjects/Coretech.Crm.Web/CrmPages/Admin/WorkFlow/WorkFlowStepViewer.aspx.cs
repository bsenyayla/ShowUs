using System;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;

using Coretech.Crm.Web.UI.RefleX.View;

public partial class CrmPages_Admin_WorkFlow_WorkFlowStepViewer : BasePage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            CreateWorkFlowGrid();
            hdnRecordId.Value = QueryHelper.GetString("RecordId");

        }
    }
   

    public void CreateWorkFlowGrid()
    {

        var strSelected = string.Empty;
        strSelected = ViewFactory.GetViewIdbyUniqueName("WORKFLOW_OPERATIONS_MASTER").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var WorkFlowObjectId = EntityEnum.WorkflowOperationMaster.GetHashCode();
        var gpw = new GridPanelView(WorkFlowObjectId, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnWorkFlowDefaultEditPage.Value = DefaultEditPage;
        var gpwer = gpw.GetGridPanelViwer();

        if (!string.IsNullOrEmpty(strSelected))
        {
            if (gpw.View.ExtenderType != 0)
            {
                var sp = new RowExpander
                {
                    Collapsed = gpw.View.ExtenderType == 2 ? true : false,
                    Template = "<table>"
                };

                foreach (var t in
                    gpwer.GridColumns.Where(t => !string.IsNullOrEmpty(t.ExtenderName)))
                {
                    sp.Template += "<tr><td style='width:120px'><b>" + t.Column.Header + "</b></td><td><b>:&nbsp;</b></td><td>{" + t.ExtenderName + "}</td></tr>";
                }
                sp.Template += "</table>";

                sp.CssName = ".x-grid3-row-body table";
                sp.CssStyle = "line-height:15px;padding:0 0 12px;margin: 5px 5px 10px !important;";
                GridPanelWorkFlowViewer.SpecialSettings.Add(sp);
            }
        }

        GridPanelWorkFlowViewer.EmptyData();
        GridPanelWorkFlowViewer.ClearColumns();
        GridPanelWorkFlowViewer.DataContainer.DataSource.DataUrl = Page.ResolveUrl("~/Data/jsonCreater.ashx");
        foreach (var c in gpwer.GridColumns)
        {

            GridPanelWorkFlowViewer.AddColumn(c.Column);
        }

        foreach (var item in gpw.View.ColumnSet.Where(item => item.OrderNumber != null).OrderBy(item => item.OrderNumber))
        {
            var ea = App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(item.AttributeId)];
            GridPanelWorkFlowViewer.DataContainer.Sorts.Add(string.IsNullOrEmpty(ea.ReferencedLookupName)
                                                        ? new DataSorts(ea.UniqueName,
                                                                        item.Direction == "0"
                                                                            ? SortDirection.Asc
                                                                            : SortDirection.Desc)
                                                        : new DataSorts(ea.ReferencedLookupName,
                                                                        item.Direction == "0"
                                                                            ? SortDirection.Asc
                                                                            : SortDirection.Desc));
        }
        GridPanelWorkFlowViewer.ReConfigure();
        if (RefleXFrameWork.RefleX.IsAjxPostback)
            GridPanelWorkFlowViewer.Reload();
    }
}
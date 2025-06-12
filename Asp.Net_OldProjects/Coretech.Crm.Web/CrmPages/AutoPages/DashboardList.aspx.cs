using System;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;

public partial class CrmPages_AutoPages_DashboardList : BasePage
{
    private DynamicSecurity _dynamicSecurity;
    void TranslateMessage()
    {
        btnExportCurrentPage.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL);
        btnExportAllPage.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        btnAssign.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN);
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            hdnViewQueryId.Value = QueryHelper.GetString("ViewQueryId", "");
            hdnObjectId.Value = QueryHelper.GetString("ObjectId", "");
            GridPanelViewer.DataContainer.DataSource.DataUrl = Page.ResolveUrl("~/Data/jsonCreater.ashx");
            FillData(sender, null);
            _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0), null);
            TranslateMessage();
            if (!_dynamicSecurity.PrvCreate)
                btnNew.Disabled = true;
            if(!_dynamicSecurity.PrvDelete)
                btnDelete.Disabled = true;
            
        }
    }

    public void FillData(object sender, AjaxEventArgs e)
    {
        var strSelected = hdnViewQueryId.Value;
        var gpw = new GridPanelView(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(strSelected));
        hdnDefaultEditPage.Value = gpw.View.DefaultEditPage.ToString();
        hdnObjectId.Value = gpw.View.ObjectId.ToString();
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
                    sp.Template += "<tr><td style='width:120px'><b>" + t.Column.Header + "</b></td><td>{" + t.ExtenderName + "}</td></tr>";
                }
                sp.Template += "</table>";

                sp.CssName = ".x-grid3-row-body table";
                sp.CssStyle = "line-height:15px;padding:0 0 12px;margin: 5px 5px 10px !important;";


                GridPanelViewer.SpecialSettings.Add(sp);
            }
        }

        GridPanelViewer.ClearColumns();
        GridPanelViewer.DataContainer.DataSource.DataUrl = Page.ResolveUrl("~/Data/jsonCreater.ashx");
        foreach (var c in gpwer.GridColumns)
        {
            GridPanelViewer.AddColumn(c.Column);
        }

        foreach (var item in gpw.View.ColumnSet.Where(item => item.OrderNumber != null).OrderBy(item => item.OrderNumber))
        {
            var ea = App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(item.AttributeId)];
            GridPanelViewer.DataContainer.Sorts.Add(string.IsNullOrEmpty(ea.ReferencedLookupName)
                                                        ? new DataSorts(item.UniqueName,
                                                                        item.Direction == "0"
                                                                            ? SortDirection.Asc
                                                                            : SortDirection.Desc)
                                                        : new DataSorts(ea.ReferencedLookupName,
                                                                        item.Direction == "0"
                                                                            ? SortDirection.Asc
                                                                            : SortDirection.Desc));
        }
        GridPanelViewer.ReConfigure();
        GridPanelViewer.Reload();
        HideViewButtonFromPage(this, gpw.View.Buttons, hdnObjectId.Value);
    }
}
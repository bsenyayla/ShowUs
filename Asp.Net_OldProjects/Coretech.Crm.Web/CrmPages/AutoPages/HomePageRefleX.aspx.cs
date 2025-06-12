using System;
using System.Collections.Generic;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.ExcelImport;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using ListItem = RefleXFrameWork.ListItem;
using Coretech.Crm.Web.UI.RefleX.View;
using SortDirection = RefleXFrameWork.SortDirection;
using Newtonsoft.Json;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;

public partial class CrmPages_AutoPages_HomePageRefleX : BasePage
{
    private void TranslateMessage()
    {
        btnExportCurrentPage.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL);
        btnExportAllPage.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        btnAssign.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN);
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        BtnClear.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_TOOLCLEAR);
        BtnFilterSearch.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_TOOLSEARCH);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        FilterText.EmptyText = CrmLabel.TranslateMessage(LabelEnum.CRM_HOMEPAGE_FILTERTEXT_EMPTY);
        Label1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_HOMEPAGE_VIEW_LABEL);
        btnImportExcel.Text = CrmLabel.TranslateMessage("CRM.IMPORTDEFINATION_IMPORTEXCELFILE");
        _BtnClear.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_TOOLCLEAR);
        _BtnFilter.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_TOOLSEARCH);
        lblInfo.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_HELP);
        Page.ClientScript.RegisterClientScriptBlock(GetType(), "EXCELMSG", string.Format("var ListEmptyMsg = {0};", JsonConvert.SerializeObject(CrmLabel.TranslateMessage(LabelEnum.CRM_VIEW_NOT_SELECTED))), true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            GridPanelViewer.AutoLoad = ValidationHelper.GetBoolean(ParameterFactory.GetParameterValue("HOMEPAGE_GRID_AUTOLOAD"), false);
            GridPanelViewerSearch.Collapsed = ValidationHelper.GetBoolean(ParameterFactory.GetParameterValue("HOMEPAGE_ADVANCED_SEARCH_EXPAND"), true);
            if (!GridPanelViewer.AutoLoad)
            {
                GridPanelViewer.AutoLoad = ValidationHelper.GetBoolean(QueryHelper.GetString("AutoLoad"), false);
            }
            CmbPageSize.Value = "50";

            GridPanelViewer.DataContainer.DataSource.DataUrl = Page.ResolveUrl("~/Data/jsonCreater.ashx");

            var eif = new ExcelImportFactory();
            var li = new List<ExcelImportItem>();
            try
            {
                li = eif.GetImportDefinationList(ValidationHelper.GetInteger(hdnObjectId.Value, 0));
            }
            catch (Exception)
            { }
            if (li.Count == 0)
                btnImportExcel.Visible = false;

            TranslateMessage();
            var infoList = Info.GetEntityHelps(Guid.Empty, ValidationHelper.GetGuid(CmbViewList.Value), this);
            if (infoList.Count == 0)
            {
                lblInfo.Visible = false;
            }
            else
            {
                SerialiseHelp(infoList);
            }
            FillData();
            showDefaultEditPageByRecId();
        }
    }

    private void showDefaultEditPageByRecId()
    {
        if (QueryHelper.GetString("recid") != string.Empty)
        {
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdnDefaultEditPage.Value = QueryHelper.GetString("defaulteditpageid");
            QScript("showDefaultEditPageByRecId();");
        }
    }
    public void CmbViewListSelect(object sender, AjaxEventArgs e)
    {
        var strSelected = CmbViewList.Value;
        if (string.IsNullOrEmpty(strSelected))
            return;
        var view = App.Params.CurrentView[ValidationHelper.GetGuid(strSelected)];
        if (!string.IsNullOrEmpty(view.UserControl))
        {
            RedirectForm(strSelected);
        }
        else
        {
            if (hdnSelectedViewQueryId.Value != CmbViewList.Value)
            {
                if (App.Params.CurrentView[ValidationHelper.GetGuid(hdnSelectedViewQueryId.Value)].UserControl
                    != App.Params.CurrentView[ValidationHelper.GetGuid(CmbViewList.Value)].UserControl)
                {
                    RedirectForm(CmbViewList.Value);
                }
            }
            hdnSelectedViewQueryId.Value = CmbViewList.Value;
            FillData();
        }
    }

    private void RedirectForm(string strSelected)
    {
        var query = new Dictionary<string, string> { { "SelectedViewQueryId", strSelected } };
        Response.Redirect(QueryHelper.AddUpdateString(query));
    }
    public void FillData()
    {
        var strSelected = hdnViewQueryId.Value;
        if (string.IsNullOrEmpty(strSelected))
            strSelected = hdnSelectedViewQueryId.Value;

        if (string.IsNullOrEmpty(strSelected))
        {
            strSelected = CmbViewList.Value;
        }
        var gpw = new GridPanelView(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
            ValidationHelper.GetGuid(strSelected));

        hdnDefaultEditPage.SetValue(gpw.View.DefaultEditPage.ToString());

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
                    sp.Template += "<tr><td style='width:120px'><b>" + t.Column.Header +
                                   "</b></td><td><b>:&nbsp;</b></td><td>{" + t.ExtenderName + "}</td></tr>";
                }
                sp.Template += "</table>";

                sp.CssName = ".x-grid3-row-body table";
                sp.CssStyle = "line-height:15px;padding:0 0 12px;margin: 5px 5px 10px !important;";

                GridPanelViewer.SpecialSettings.Add(sp);
            }
        }

        GridPanelViewer.EmptyData();
        GridPanelViewer.ClearColumns();
        GridPanelViewer.DataContainer.DataSource.DataUrl = Page.ResolveUrl("~/Data/jsonCreater.ashx");
        foreach (var c in gpwer.GridColumns)
        {
            c.Column.Hidden = c.Column.Width == 0 ? true : c.Column.Hidden;
            GridPanelViewer.AddColumn(c.Column);
        }

        foreach (
            var item in gpw.View.ColumnSet.Where(item => item.OrderNumber != null).OrderBy(item => item.OrderNumber))
        {
            var ea = App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(item.AttributeId)];
            GridPanelViewer.DataContainer.Sorts.Add(string.IsNullOrEmpty(ea.ReferencedLookupName)
                ? new DataSorts(ea.UniqueName,
                    item.Direction == "0"
                        ? SortDirection.Asc
                        : SortDirection.Desc)
                : new DataSorts(ea.ReferencedLookupName,
                    item.Direction == "0"
                        ? SortDirection.Asc
                        : SortDirection.Desc));
        }
        HideViewButtonFromPage(this, gpw.View.Buttons, hdnObjectId.Value);
        GridPanelViewer.ReConfigure();
        //GridPanelViewer.AutoLoad = ValidationHelper.GetBoolean(ParameterFactory.GetParameterValue("HOMEPAGE_GRID_AUTOLOAD"), false);
        if (RefleX.IsAjxPostback || (!string.IsNullOrEmpty(hdnSelectedViewQueryId.Value) && GridPanelViewer.AutoLoad))
            GridPanelViewer.Reload();
    }

    protected override void OnPreInit(EventArgs e)
    {
        InsertFilters();
        base.OnPreInit(e);
    }
    protected override void OnInit(EventArgs e)
    {
        var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
        var objectId = QueryHelper.GetInteger("ObjectId", 0);
        var de = new DynamicEntity(objectId);

        if (!RefleX.IsAjxPostback)
        {
            hdnObjectId.Value = QueryHelper.GetString("ObjectId", "");
            hdnViewQueryId.Value = QueryHelper.GetString("ViewQueryId", "");
            hdnSelectedViewQueryId.Value = QueryHelper.GetString("SelectedViewQueryId", "");
        }
        string selectedval;
        if (RefleX.IsAjxPostback && !string.IsNullOrEmpty(CmbViewList.Value))
        {
            selectedval = string.IsNullOrEmpty(hdnSelectedViewQueryId.Value) ? CmbViewList.Value : hdnSelectedViewQueryId.Value;
        }
        else
        {
            LoadCmbViewList();
            selectedval = CmbViewList.Value;
            if (string.IsNullOrEmpty(QueryHelper.GetString("SelectedViewQueryId", "")))
            {
                var query = new Dictionary<string, string> { { "SelectedViewQueryId", selectedval } };
                Response.Redirect(QueryHelper.AddUpdateString(query));
            }
        }

        if (!string.IsNullOrEmpty(selectedval))
        {
            if (CmbViewList.Value == QueryHelper.GetString("SelectedViewQueryId", ""))
            {
                var view = App.Params.CurrentView[ValidationHelper.GetGuid(selectedval)];
                if (!string.IsNullOrEmpty(view.UserControl))
                {
                    var customControl = this.Page.LoadControl(view.UserControl);
                    customControl.ID = "CustomViewControl";
                    Page.Controls.Add(customControl);
                }
            }
        }

        dynamicFactory.ExecPlugin(PluginMsgType.ListInit, objectId, ref de,
                                      false);
        base.OnInit(e);
        dynamicFactory.ExecPlugin(PluginMsgType.ListInit, objectId, ref de,
                                      true);
    }
    private void InsertFilters()
    {
        if (!RefleX.IsAjxPostback)
        {
            GridPanelViewerSearch.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_FILTER);
            var objectId = QueryHelper.GetInteger("ObjectId", 0);

            var gpw = new GridPanelView();
            var fields = gpw.GetFilterFields(objectId);
            var cl1 = new ColumnLayout { EnableViewState = false, ID = "ClFilter1", ColumnLayoutLabelWidth = 30, ColumnWidth = "49%" };
            var cl2 = new ColumnLayout { EnableViewState = false, ID = "ClFilter2", ColumnLayoutLabelWidth = 30, ColumnWidth = "49%" };
            var Rl1 = new RowLayout { ID = "RLfilter1" };
            var Rl2 = new RowLayout { ID = "RLfilter2" };
            int i = 0;
            foreach (var item in fields)
            {
                if (i++ % 2 == 0)
                    Rl1.BodyControls.Add(item);
                else
                    Rl2.BodyControls.Add(item);
            }
            cl1.Rows.Add(Rl1);
            cl2.Rows.Add(Rl2);
            GridPanelViewerSearch.BodyControls.Add(cl1);
            GridPanelViewerSearch.BodyControls.Add(cl2);
            if (i == 0)
                GridPanelViewerSearch.Visible = false;
        }
    }
    private void LoadCmbViewList()
    {
        var vf = new ViewFactory();
        var myViewList = vf.GetViewListByObjectIdForUser(ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        string defaultvalue = string.Empty;
        if (string.IsNullOrEmpty(hdnViewQueryId.Value))
        {
            foreach (var li in from view in myViewList
                               where (view.QueryType != 2 && view.QueryType != 4 && view.QueryType != 3)
                               select new ListItem { Text = view.Name, Value = view.ViewQueryId.ToString() })
            {
                CmbViewList.AddItem(li);
            }
        }
        else
        {
            var li = new ListItem { Text = "", Value = hdnViewQueryId.Value };
            CmbViewList.AddItem(li);
            CmbViewList.Disabled = true;
        }

        if (myViewList.Count > 0)
        {
            if (!string.IsNullOrEmpty(hdnSelectedViewQueryId.Value))
            {
                CmbViewList.SetIValue(hdnSelectedViewQueryId.Value.ToLower());
                CmbViewList.Value = hdnSelectedViewQueryId.Value.ToLower();
            }
            else
            {
                if (defaultvalue != string.Empty)
                {
                    CmbViewList.SetIValue(defaultvalue);
                    CmbViewList.Value = defaultvalue;
                }
                else
                {
                    CmbViewList.SetIValue(CmbViewList.Items[0].Value);
                    CmbViewList.Value = CmbViewList.Items[0].Value;
                }
            }
        }
    }

}
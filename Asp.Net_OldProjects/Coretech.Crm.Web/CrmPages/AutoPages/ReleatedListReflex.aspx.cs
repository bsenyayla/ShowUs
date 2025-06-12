using System;
using System.Linq;
using System.Xml;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.WorkFlow;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX.View;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using AjaxPro;

public partial class CrmPages_AutoPages_ReleatedListReflex : BasePage
{

    [AjaxMethod]
    public DynamicFactory.OperationReturnType GlobalDelete(string order, string recordId, string objectId)
    {
        var df = new DynamicFactory(ERunInUser.CalingUser);
        return df.GlobalDelete(order, recordId, objectId);
    }

    private string _objectid;
    private string _sortattributeid;
    private string _viewqueryid;
    private DynamicSecurity _dynamicSecurity;
    protected void Page_Load(object sender, EventArgs e)
    {

        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            //Utility.RegisterTypeForAjax(typeof(AjaxMethods));
            var gpw = new GridPanelView(ValidationHelper.GetInteger(ValidationHelper.GetInteger(hdnObjectId.Value, 0), 0), ValidationHelper.GetGuid(ViewQuery.Value));
            _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0), null);
            HideViewButtonFromPage(this, gpw.View.Buttons, hdnObjectId.Value);
            if (!_dynamicSecurity.PrvCreate)
                btnNew.Disabled = true;
            if (!_dynamicSecurity.PrvDelete)
                btnDelete.Disabled = true;
        }
    }

    private void ParseXml()
    {
        string strFetchXml = FetchXML.Value;
        var xdoc = new XmlDocument();
        xdoc.LoadXml(strFetchXml);
        var xnod = xdoc.FirstChild;
        _objectid = ValidationHelper.GetXmlAttribute(xnod, "objectid");
        _viewqueryid = ValidationHelper.GetXmlAttribute(xnod, "viewqueryid");
        _sortattributeid = ValidationHelper.GetXmlAttribute(xnod, "sortattributeid");


        /*Bu alan Degisecek Unutma*/
        //_viewQueryid = "9EB65A85-4549-4D3A-8563-85A24F7932BA";

        ScriptCreater.AddInstanceScript("var objectid='" + _objectid + "';");
        ScriptCreater.AddInstanceScript("var viewqueryid='" + _viewqueryid + "';");
        ScriptCreater.AddInstanceScript("var sortattributeid='" + _sortattributeid + "';");

        if (ValidationHelper.GetGuid(_sortattributeid) != Guid.Empty)
        {
            btnSaveSort.Visible = true;
            RowSelectionModel1.RowDragable = true;
            GridPanelViewer.PostAllData = true;
        }
        else
        {
            btnSaveSort.Visible = false;
            RowSelectionModel1.RowDragable = false;
        }
        var infoList = Info.GetEntityHelps(Guid.Empty, ValidationHelper.GetGuid(_viewqueryid), this);
        if (infoList.Count == 0)
        {
            lblInfo.Visible = false;
        }
        else
        {
            SerialiseHelp(infoList);
        }

        ViewQuery.Value = _viewqueryid;
    }

    protected override void OnPreInit(EventArgs e)
    {

        TranslateMessage();
        FetchXML.Value = QueryHelper.GetString("FetchXML");
        MapXML.Value = QueryHelper.GetString("MapXML");

        ParseXml();
        GetGridPanel();
        base.OnPreInit(e);
    }

    private void GetGridPanel()
    {
        var gpw = new GridPanelView(ValidationHelper.GetInteger(_objectid, 0), ValidationHelper.GetGuid(ViewQuery.Value));
        hdnDefaultEditPage.Value = gpw.View.DefaultEditPage.ToString();
        hdnObjectId.Value = gpw.View.ObjectId.ToString();
        var gpwer = gpw.GetGridPanelViwer();

        if (!string.IsNullOrEmpty(ViewQuery.Value))
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

        foreach (var gc in gpwer.GridColumns.Select(c => new GridColumns
                                                             {
                                                                 Width = c.Column.Width,
                                                                 ColumnId = c.Column.ColumnId,
                                                                 DataIndex = c.Column.DataIndex,
                                                                 Sortable = c.Column.Sortable,
                                                                 Renderer = { Handler = c.Column.Renderer.Handler },
                                                                 Header = c.Column.Header,
                                                                 Align = c.Column.Align,
                                                                 Hidden = c.Column.Width == 0 ? true : c.Column.Hidden,
                                                                 MenuDisabled = c.Column.MenuDisabled,
                                                                 Resizeable = c.Column.Resizeable,
                                                                 ColumnType = c.Column.ColumnType,
                                                                 Editable = false
                                                             }))
        {
            GridPanelViewer.ColumnModel.Columns.Add(gc);
        }
        //GridPanelViewer.ClearColumns();
        //foreach (var c in gpwer.GridColumns)
        //{

        //    GridPanelViewer.AddColumn(c.Column);
        //}

        GridPanelViewer.DataContainer.DataSource.DataUrl = Page.ResolveUrl("~/Data/jsonCreater.ashx");
        GridPanelViewer.DataContainer.Parameters.Add(new Parameter("start", "1", EpMode.Value));
        GridPanelViewer.DataContainer.Parameters.Add(new Parameter("limit", "50", EpMode.Value));
        GridPanelViewer.AutoLoad = true;
        GridPanelViewer.DataContainer.DataSource.Columns.Add(new Column("RowNum", EDataType.String));

        foreach (var c in gpw.GetStoreData())
        {
            GridPanelViewer.DataContainer.DataSource.Columns.Add(c);
        }

    }
    protected override void OnInit(EventArgs e)
    {
        if (App.Params.CurrentView.ContainsKey(ValidationHelper.GetGuid(_viewqueryid)))
        {
            var viewobject = App.Params.CurrentView[ValidationHelper.GetGuid(_viewqueryid)];
            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page, };
            var objectId = viewobject.ObjectId;
            var de = new DynamicEntity(objectId);
            de.AddStringProperty("viewqueryid", viewobject.ViewQueryId.ToString());
            de.AddStringProperty("uniquename", viewobject.UniqueName);
       
            dynamicFactory.ExecPlugin(PluginMsgType.ListInit, objectId, ref de,
                                          false);
            base.OnInit(e);
            dynamicFactory.ExecPlugin(PluginMsgType.ListInit, objectId, ref de,
                                          true);
        }
    }
    private void TranslateMessage()
    {
        btnExportCurrentPage.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL);
        btnExportAllPage.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        btnAssign.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN);
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        FilterText.EmptyText = CrmLabel.TranslateMessage(LabelEnum.CRM_HOMEPAGE_FILTERTEXT_EMPTY);
        lblInfo.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_HELP);
    }

    protected void SaveSorting(object sender, AjaxEventArgs e)
    {
        var orderId = "";
        foreach (var row in GridPanelViewer.AllRows)
        {
            orderId += row.ID + ",";
        }
        if (!string.IsNullOrEmpty(orderId))
        {
            orderId = orderId.Substring(0, orderId.Length - 1);
            var sf = new SortingFactory();
            sf.ParseAndSaveSorting(orderId, _sortattributeid);
        }

    }
}

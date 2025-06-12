using System;
using System.Xml;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Web.UI.View;

public partial class CrmPages_AutoPages_ReleatedList : BasePage
{
    private string _objectid;
    private string _sortattributeid;
    private string _viewqueryid;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            var Hp = new HttpProxy();
            Hp.Url = Page.ResolveUrl("~/Data/jsonCreater.ashx");
            StoreViewer.Proxy.Add(Hp);

            mnuExportExcel.Text = MenuItem1.Text = CrmLabel.TranslateMessage("Export_to_Excel");
            mnuExportExcelAll.Text = MenuItem2.Text = CrmLabel.TranslateMessage("Export_To_Excel_(All_Page)");

            FetchXML.Text = QueryHelper.GetString("FetchXML");
            MapXML.Text = QueryHelper.GetString("MapXML");

            ParseXml();
            GetGridPanel();
            TranslateMessage();
        }
    }

    private void ParseXml()
    {
        string strFetchXml = FetchXML.Text;
        var xdoc = new XmlDocument();
        xdoc.LoadXml(strFetchXml);
        XmlNode xnod = xdoc.FirstChild;
        _objectid = ValidationHelper.GetXmlAttribute(xnod, "objectid");
        _viewqueryid = ValidationHelper.GetXmlAttribute(xnod, "viewqueryid");
        _sortattributeid = ValidationHelper.GetXmlAttribute(xnod, "sortattributeid");


        /*Bu alan Degisecek Unutma*/
        //_viewQueryid = "9EB65A85-4549-4D3A-8563-85A24F7932BA";

        ActiveScriptManager.RegisterClientScriptBlock("objectid", "var objectid='" + _objectid + "';");
        ActiveScriptManager.RegisterClientScriptBlock("viewqueryid", "var viewqueryid='" + _viewqueryid + "';");
        ActiveScriptManager.RegisterClientScriptBlock("sortattributeid",
                                                      "var sortattributeid='" + _sortattributeid + "';");


        if (ValidationHelper.GetGuid(_sortattributeid) != Guid.Empty)
        {
            btnSaveSort.Visible = true;
        }
        else
        {
            btnSaveSort.Visible = false;
        }


        ViewQuery.Text = _viewqueryid;
    }

    private void GetGridPanel()
    {
        var Gpw = new GridPanelView(ValidationHelper.GetInteger(_objectid, 0), ValidationHelper.GetGuid(ViewQuery.Text));
        var Gpwer = new GridPanelView.GridPanelViewer();
        hdnDefaultEditPage.Text = Gpw.View.DefaultEditPage.ToString();
        hdnObjectId.Text = Gpw.View.ObjectId.ToString();
        Gpwer = Gpw.GetGridPanelViwer();
        try
        {
            for (int i = 0; i < 30; i++)
                GridPanelViewer.RemoveColumn(0);
        }
        catch
        {
        }
        foreach (GridPanelView.CrmColumnBase c in Gpwer.GridColumns)
        {
            GridPanelViewer.AddColumn(c.Column);
        }

        StoreViewer.RemoveFields();
        foreach (RecordField Rf in Gpw.GetStoreData())
        {
            StoreViewer.AddField(Rf);
        }
        StoreViewer.AddField(new RecordField("RowNum", RecordFieldType.String));
        StoreViewer.Sort(Gpw.View.ColumnSet[0].UniqueName, SortDirection.DESC);
    }

    [AjaxMethod(ShowMask = true)]
    public string UpdateSorting(string strSortingXml)
    {
        try
        {
            var sf = new SortingFactory();
            sf.ParseAndSaveSorting(strSortingXml);
        }
        catch (Exception exception)
        {
            ErrorMessageShow(exception);
        }
        return "";
    }

    private void TranslateMessage()
    {
        mnuExportExcel.Text = MenuItem1.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL);
        mnuExportExcelAll.Text = MenuItem2.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        mnuAssign.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN);
        BtnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        BtnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
    }
}
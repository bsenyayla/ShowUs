using System;
using System.Linq;
using System.Xml;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Web.UI.View;
using System.Collections.Generic;

public partial class CrmPages_AutoPages_LookUp : BasePage
{
    private string _filtertext;
    private string _framename;
    private string _lookup;
    private string _objectid;
    private string _type;
    private string _viewqueryid;
    private string _pawinid = "";
    private DynamicSecurity _dynamicSecurity;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            var hp = new HttpProxy {Url = Page.ResolveUrl("~/Data/jsonCreater.ashx")};
            StoreViewer.Proxy.Add(hp);

            FetchXML.Text = QueryHelper.GetString("FetchXML");
            ParseXml();
            GetGridPanel();
            _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(_objectid, 0), null);

            if (!_dynamicSecurity.PrvCreate)
            {
                btnNew.Disabled = true;
            }
        }
    }

    private void ParseXml()
    {
        var strFetchXml = FetchXML.Text;
        var xdoc = new XmlDocument();
        xdoc.LoadXml(strFetchXml);
        var xnod = xdoc.FirstChild;
        _framename = xnod.Attributes["framename"].Value;
        _lookup = xnod.Attributes["lookup"].Value;
        _objectid = xnod.Attributes["objectid"].Value;
        _viewqueryid = xnod.Attributes["viewqueryid"].Value;
        _filtertext = xnod.Attributes["filtertext"].Value;
        _type = xnod.Attributes["type"].Value;
        _pawinid = QueryHelper.GetString("pawinid");
        if (_viewqueryid == "||")
            _viewqueryid = GetLookupViewQueryIdByObjectId(_objectid);
        /*Bu alan Degisecek Unutma*/
        //_viewqueryid = "9EB65A85-4549-4D3A-8563-85A24F7932BA";

        ActiveScriptManager.RegisterClientScriptBlock("lframename", "var lframename='" + _framename + "';");
        ActiveScriptManager.RegisterClientScriptBlock("lookup", "var lookup='" + _lookup + "';");
        ActiveScriptManager.RegisterClientScriptBlock("objectid", "var objectid='" + _objectid + "';");
        ActiveScriptManager.RegisterClientScriptBlock("viewqueryid", "var viewqueryid='" + _viewqueryid + "';");
        ActiveScriptManager.RegisterClientScriptBlock("type", "var type='" + _type + "';");
        ActiveScriptManager.RegisterClientScriptBlock("awinid", "var awinid='" + _pawinid + "';");

        ActiveScriptManager.RegisterOnReadyScript("wonload();");
        ViewQuery.Text = _viewqueryid;
        FilterText.Text = _filtertext;
    }

    private void GetGridPanel()
    {
        var gpw = new GridPanelView(ValidationHelper.GetInteger(_objectid,0), ValidationHelper.GetGuid(ViewQuery.Text));
        var gpwer = gpw.GetGridPanelViwer();
        var sDisableSerch = "";
       
        try
        {
            for (var i = 0; i < 30; i++)
                GridPanelViewer.RemoveColumn(0);
        }
        catch
        {
        }
        foreach (var c in gpwer.GridColumns)
        {
            if (!c.IsSearchable)
            {
                sDisableSerch += "," + c.Column.DataIndex;
            }
            GridPanelViewer.AddColumn(c.Column);
        }

        StoreViewer.RemoveFields();
        
        foreach (var rf in gpw.GetStoreData())
        {
            StoreViewer.AddField(rf);
        }
        StoreViewer.AddField(new RecordField("RowNum", RecordFieldType.String));
        if (sDisableSerch.Length > 1)
        {
            QScript(@"GridPanelViewer.plugins[0].disableIndexes = '" + sDisableSerch.Substring(1) + "';");
            QScript(@"GridPanelViewer.plugins[0].reconf();");

        }
        #region Varsayýlan Sýralamanýn Gridde gösterilmesi Eklentisi
        var sorts = new List<object>();

        foreach (var item in gpw.View.ColumnSet.Where(item => item.OrderNumber != null).OrderBy(item => item.OrderNumber))
        {
            var ea = App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(item.AttributeId)];
            if (string.IsNullOrEmpty(ea.ReferencedLookupName))
                sorts.Add(new { direction = item.Direction == "0" ? "ASC" : "DESC", field = item.UniqueName });
            else
                sorts.Add(new { direction = item.Direction == "0" ? "ASC" : "DESC", field = ea.ReferencedLookupName });
        }

        var sortState = JSON.Serialize(sorts);

        QScript(@"StoreViewer.sortState = " + sortState + ";");
        #endregion

    }

    public string GetLookupViewQueryIdByObjectId(string strobjectId)
    {
        var vf = new ViewFactory();
        var viewQueryId = vf.GetLookupViewQueryIdByObjectId(ValidationHelper.GetInteger(strobjectId, 0));
        return ValidationHelper.GetString(viewQueryId);
    }
}
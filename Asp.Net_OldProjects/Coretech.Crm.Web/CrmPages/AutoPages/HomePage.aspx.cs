using System;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Web.UI.View;
using System.Collections.Generic;
using Coretech.Crm.Factory;

public partial class CrmPages_AutoPages_HomePage : BasePage
{
    private DynamicSecurity _dynamicSecurity;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hdnObjectId.Value = QueryHelper.GetString("ObjectId", "");
            hdnViewQueryId.Value = QueryHelper.GetString("ViewQueryId", "");

            LoadCmbViewList();
            var hp = new HttpProxy { Url = Page.ResolveUrl("~/Data/jsonCreater.ashx") };
            StoreViewer.Proxy.Add(hp);
            CmbViewList_Select(null, null);
            _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0), null);
            mnuExportExcel.Text = MenuItem1.Text = CrmLabel.TranslateMessage(  LabelEnum.EXPORT_TO_EXCEL);
            mnuExportExcelAll.Text = MenuItem2.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
            mnuAssign.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN);
            BtnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW );
            TranslateMessage();
            if (!_dynamicSecurity.PrvCreate)
                BtnNew.Disabled = true;
        }
    }
    private void LoadCmbViewList()
    {
        var vf = new ViewFactory();
        var myViewList = vf.GetViewListByObjectIdForUser(ValidationHelper.GetInteger(hdnObjectId.Text, 0));

        if (string.IsNullOrEmpty(hdnViewQueryId.Value.ToString()))
        {
            foreach (var li in from view in myViewList
                               where view.QueryType != 2
                               select new ListItem {Text = view.Name, Value = view.ViewQueryId.ToString()})
            {
                CmbViewList.Items.Add(li);
            }
            
        }
        else
        {
            var li = new ListItem { Text = "", Value = hdnViewQueryId.Value.ToString() };
            CmbViewList.Items.Add(li);
            CmbViewList.Disabled = true;
        }

        if (myViewList.Count > 0)
        {
            //CmbViewList.Value = ;
            CmbViewList.SelectedItem.Value = myViewList[0].ViewQueryId.ToString();
            CmbViewList.SelectedIndex = 0;
        }
    }
    public void CmbViewList_Select(object sender, AjaxEventArgs e)
    {
        var strSelected = CmbViewList.SelectedItem.Value;
        var gpw = new GridPanelView(ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(strSelected));
        hdnDefaultEditPage.Text = gpw.View.DefaultEditPage.ToString();
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

        #region Varsayılan Sıralamanın Gridde gösterilmesi Eklentisi
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

        GridPanelViewer.Reload();
    }
    void TranslateMessage()
    {
        mnuExportExcel.Text = MenuItem1.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL);
        mnuExportExcelAll.Text = MenuItem2.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        mnuAssign.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN);
        BtnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        BtnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
    }
}
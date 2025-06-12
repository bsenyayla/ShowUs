using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Exporter;
using RefleXFrameWork;

public partial class CrmPages_AutoPages_LogViewer : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Ext.IsAjaxRequest)
        {
            QScript("window.top.R.WindowMng.getActiveWindow().setTitle(" + ScriptCreater.SerializeString(CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_LOGWIEVER_TITLE)) + ");");
            _grd.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_LOGWIEVER_ATTRIBUTE);
            _grd.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_LOGWIEVER_CREATEDON);
            _grd.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_LOGWIEVER_CREATEDBY);
            _grd.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_LOGWIEVER_OLDVALUE);
            _grd.ColumnModel.Columns[4].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_LOGWIEVER_NEWVALUE);
            mnuExportExcelAll.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
            _rowExpander1.Template.Text = @"
                    <table>
                        </br>
                    </table>                    
                        <table>
                        <tr>
                            <td style='width:80px'><b>Old Value</b></td>
                            <td style='width:10px'><b>:</b></td>
                            <td style='word-wrap: break-word;'>{OldValue}</td>
                        </tr>
                        <tr height='5'></tr>
                        <tr>
                            <td style='width:80px'><b>New Value</b></td>
                            <td style='width:10px'><b>:</b></td>
                            <td style='word-wrap: break-word;'>{NewValue}</td>
                        </tr>
                    </table>
                    <table>
                        </br>
                    </table>  
                ";
        }
    }

    protected void StoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var lf = new LogViewerFactory();
        if (!string.IsNullOrEmpty(e.Parameters["FileName"]))
        {
            var filename = e.Parameters["FileName"];
            var dt = Export.PrepareExcel(store1, _grd, lf.GetRecordLogsDt(ValidationHelper.GetGuid(QueryHelper.GetString("EntityId")), ValidationHelper.GetGuid(QueryHelper.GetString("RecordId"))));
            Export.ExportData(dt, filename);
        }

        store1.DataSource = lf.GetRecordLogs(ValidationHelper.GetGuid(QueryHelper.GetString("EntityId")), ValidationHelper.GetGuid(QueryHelper.GetString("RecordId")));
        store1.DataBind();
    }
}
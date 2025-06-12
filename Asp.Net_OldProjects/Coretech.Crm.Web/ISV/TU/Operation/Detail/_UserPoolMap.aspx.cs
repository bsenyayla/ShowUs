using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using TuFactory.Data;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class Operation_Detail_UserPoolMap : BasePage
{
    private TuUserApproval _userApproval = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private TuUser _activeUser = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();
        FillGrid();
                
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
            
        }
    }

    void TranslateMessage()
    {
        ColumnModel cm =  GridPanelMonitoring.ColumnModel;
        cm.Columns[1].Header = CrmLabel.TranslateMessage("CRM.ENTITY_ATTRIBUTENAME");
        cm.Columns[2].Header = CrmLabel.TranslateMessage("CRM.ENTITY_HIDE");
        QScript("window.top.R.WindowMng.getActiveWindow().setTitle('" + CrmLabel.TranslateMessage("CRM.ENTITY_ATTRIBUTELIST") + "');");
    }

    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        FillGrid();
    }

    private void FillGrid()
    {
        var viewQueryId = ValidationHelper.GetGuid(QueryHelper.GetString("viewQueryId"));
        Int32 poolId = Convert.ToInt32(QueryHelper.GetString("poolId"));

        var obj = App.Params.CurrentView[viewQueryId];
        var lColumns = new UserPoolMapDb().getColumnSet(obj.ColumnSetXml);

        string attributeList = string.Empty;
        foreach (var item in lColumns)
        {
            if (item.Width > 0)
                attributeList += item.AttributeId + ";";
        }

        if (attributeList.Length > 0)
            attributeList = attributeList.Remove(attributeList.Length - 1);

        GridPanelMonitoring.DataSource = new UserPoolMapDb().GetColumnList(poolId,viewQueryId, attributeList);
        GridPanelMonitoring.DataBind();
    }


    protected void BtnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        RowSelectionModel rw = GridPanelMonitoringRowSelectionModel1;
        //var viewQueryId = ValidationHelper.GetGuid(QueryHelper.GetString("viewQueryId"));
        //var poolId = Convert.ToInt32(QueryHelper.GetString("poolId"));

        //try
        //{
        //    new UserPoolMapDb().AddUserPoolMap(poolId,viewQueryId, rw.SelectedRows.Hide, ValidationHelper.GetGuid(rw.SelectedRows.AttributeId));
        //}
        //catch (Exception ex)
        //{
        //    _msg.Show(ex.Message);
        //}
    }

    protected void RowClickOnEvent(object sender, AjaxEventArgs e)
    {
        RowSelectionModel rw = GridPanelMonitoringRowSelectionModel1;
        var viewQueryId = ValidationHelper.GetGuid(QueryHelper.GetString("viewQueryId"));
        var poolId = Convert.ToInt32(QueryHelper.GetString("poolId"));

        try
        {
            new UserPoolMapDb().AddUserPoolMap(poolId,viewQueryId, rw.SelectedRows.Hide, ValidationHelper.GetGuid(rw.SelectedRows.AttributeId));
        }
        catch (Exception ex)
        {
            _msg.Show(ex.Message);
        }
    }
}
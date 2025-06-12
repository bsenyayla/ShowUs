using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.DuplicateDetection;
using Coretech.Crm.Objects.Crm.DuplicateDetection;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;

public partial class CrmPages_AutoPages_DDReflex : BasePage
{
    private DuplicateDetection _activeDd;
    private void translateMessages()
    {
        btnSaveNewRecord.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DD_CONTINUE_SAVERECORD);
        btnSaveSelectedRecord.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DD_UPDATE_SELECTED_RECORD);

        GridPanelMonitoring.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_DD_FOUND_MESSAGE);
        QScript("window.top.R.WindowMng.getActiveWindow().setTitle(" + SerializeString(CrmLabel.TranslateMessage(LabelEnum.CRM_DD_TITLE)) + ");");
    }
    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            translateMessages();
        }
        base.OnPreInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
           
            duplicateDetectionRuleId.Value = QueryHelper.GetString("duplicateDetectionRuleId");
            duplicateDetectionResultId.Value = QueryHelper.GetString("duplicateDetectionResultId");
            ParentAction.Value = QueryHelper.GetString("ParentAction");
            
        }
        
        _activeDd = App.Params.CurrentDuplicateDetections[ValidationHelper.GetGuid(duplicateDetectionRuleId.Value)];

        if (!RefleX.IsAjxPostback)
        {
            if (!_activeDd .AllowDuplicate)
            {
                btnSaveNewRecord.Hidden = true;
            }
            if (!_activeDd.AllowUpdateSelectedRecord)
            {
                btnSaveSelectedRecord.Hidden = true;
            }

            CreateViewGrid();
        }
        
    }
    public void CreateViewGrid()
    {
        var rduplicateDetectionRuleId = ValidationHelper.GetGuid(duplicateDetectionRuleId.Value);

        if (rduplicateDetectionRuleId != Guid.Empty)
        {
            var gpc = new GridPanelCreater();
            var addColumns = new List<GridPanelView.CrmColumnBase>();
            
            gpc.CreateViewGrid(_activeDd.ViewQueryId, GridPanelMonitoring);
        }

    }
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;

        var dd = new DuplicateDetectionFactory();
        var strSql = dd.GetDuplicateDedectionSql(_activeDd);
        var spList = new List<CrmSqlParameter>();

        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.Guid,
            Paramname = "DuplicateDetectionResultId",
            Value = ValidationHelper.GetGuid(duplicateDetectionResultId.Value)
        });
        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        var t = gpc.GetFilterData(strSql, _activeDd.ViewQueryId, sort, spList, start, limit, out cnt);
        GridPanelMonitoring.TotalCount = cnt;

        GridPanelMonitoring.DataSource = t;
        GridPanelMonitoring.DataBind();
    }
}
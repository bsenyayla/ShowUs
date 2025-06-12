using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.ExcelImport;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Segmentation;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class Sender_SenderSegmentation : BasePage
{
    private DynamicSecurity _dynamicSecurity;
    private void TranslateMessages()
    {
        //ToolbarButtonTransfer.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_BTN_NEW_TRANSFER_RECORD");
        //ToolbarButtonPayment.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_BTN_NEW_PAYMENT_RECORD");

        BtnSb1.Text = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_FILE_UPLOAD");
        ButtonTemplate.Text = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_TEMPLATE");
        btnDownload.Text = CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL_ALL_PAGE);
        pnl1.Title = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_SEARCH");
        windowImport.Title = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_IMPORT_WINDOW");
        ExcelFileUpload.FieldLabel = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_IMPORT");
        btnUpload.Text = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_UPLOAD");
        btnSave.Text = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_SAVE");
        WindowEdit.Title = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_WINDOWEDIT");
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessages();
            CreateViewGrid();
            FillSecurity();
            if (!_dynamicSecurity.PrvCreate)
                Response.End();
            
        }

    }
    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("SENDERSEGMENTATIONUPDATE", GridPanelMonitoring);
        string strSelected = ViewFactory.GetViewIdbyUniqueName("SENDERSEGMENTATIONUPDATE").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var defaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = defaultEditPage;
    }

    private string GetFilters(out List<CrmSqlParameter> spList)
    {
        string strSql = string.Empty;
        spList = new List<CrmSqlParameter>();

        if (new_SenderId.Value != "")
        {
            strSql += " And MT.new_SenderId=@new_SenderId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_SenderId",
                Value = ValidationHelper.GetGuid(new_SenderId.Value)
            });
        }
        if (new_SenderSegmentationId.Value != "")
        {
            strSql += " And MT.new_SenderSegmentationId=@new_SenderSegmentationId";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_SenderSegmentationId",
                Value = ValidationHelper.GetGuid(new_SenderSegmentationId.Value)
            });
        }
        if (new_SenderNumber.Value != "")
        {
            strSql += " And MT.new_SenderNumber=@new_SenderNumber";
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SenderNumber",
                Value = new_SenderNumber.Value
            });
        }
        return strSql;
    }
    protected void btnUploadClick(object sender, AjaxEventArgs e)
    {

        MessageBox msg = new MessageBox();
        msg.Modal = true;
        string tpl = CrmLabel.TranslateMessage("CRM.NEW_SENDERSEGMENTATIONUPDATE_COMPLETED");  
        var ixl = new ImportXlsFile();
        try
        {
            if (ExcelFileUpload.HasFile)
            {
                string[] strFileNamesp = ExcelFileUpload.PostedFile.FileName.Split('\\');
                string strFileName = strFileNamesp[strFileNamesp.Length - 1];



                ixl.FileName = strFileName;
                ixl.ImportXlsFileId = GuidHelper.New();
                var strLocalFileName = Path.Combine(ExcelImportFactory.ImportPath, ixl.ImportXlsFileId + strFileName);
                ExcelFileUpload.PostedFile.SaveAs(strLocalFileName);
                var sf = new SegmentationFactory();
                sf.ImportSegmentData(strLocalFileName);

                msg.Show(tpl);
               
            }

        }
        catch (CrmException ex)
        {
            msg.MsgType = MessageBox.EMsgType.Html;
            msg.MessageType = EMessageType.Error;
            msg.Show("", "", ex.ErrorMessage);
        }
        catch (Exception ex)
        {
            msg.Show(ex.Message);
            throw;
        }
        ExcelFileUpload.Value = "";

    }

    protected void btnUpdateClick(object sender, AjaxEventArgs e)
    {
        var ssf = new SegmentationFactory();
        var segmentationUpdate = new SenderSegmentationUpdate
        {
            new_SenderId = ValidationHelper.GetGuid(nSender.Value),
            new_SenderSegmentationID = ValidationHelper.GetGuid(nSenderSegmentationId.Value),
            New_SenderSegmentationUpdateId = ValidationHelper.GetGuid(nHdnSelectedRowId.Value),

        };
        ssf.UpdateSegmentationToSender(segmentationUpdate);
        GridPanelMonitoring.Reload();

    }
    protected void ToolbarButtonFindClick(object sender, AjaxEventArgs e)
    {
        var sort = GridPanelMonitoring.ClientSorts();
        if (sort == null)
            sort = string.Empty;

        string strSqlMain = @"
Select Mt.SenderSegmentationUpdateName AS VALUE ,Mt.New_SenderSegmentationUpdateId AS ID , Mt.*
  From dbo.tvNew_SenderSegmentationUpdate(@SystemUserId) as Mt
Where 1=1
        ";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("SENDERSEGMENTATIONUPDATE");

        var gpc = new GridPanelCreater();
        var cnt = 0;
        var start = GridPanelMonitoring.Start();
        var limit = GridPanelMonitoring.Limit();
        DataTable dtb;
        List<CrmSqlParameter> spList;
        string strSql = GetFilters(out spList);
        var t = gpc.GetFilterData(strSqlMain + strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb);
        GridPanelMonitoring.TotalCount = cnt;

        try
        {
            if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
            {
                var gpw = new GridPanelView(0, ValidationHelper.GetGuid(hdnViewList.Value));
                gpw.Export(dtb);

            }

        }
        catch (Exception)
        {

            throw;
        }
        GridPanelMonitoring.DataSource = t;
        GridPanelMonitoring.DataBind();




    }
    void FillSecurity()
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_SenderSegmentationUpdate.GetHashCode(), null);
       
    }



}
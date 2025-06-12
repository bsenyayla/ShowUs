using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm.Factory.Crm.CustomControl;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.ExcelImport;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using ListItem = RefleXFrameWork.ListItem;
using System.Data;

public partial class CrmPages_Admin_ExcelImport_Import : AdminPage
{
    public CrmPages_Admin_ExcelImport_Import()
    {
        ObjectId = EntityEnum.ExcelImportDefaination.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            TranslateMessages();
            BindeData();
        }

    }
    void TranslateMessages()
    {
        //Button1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        BtnUpload.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.IMPORTDEFINATION_UPLOAD");
        BtnTemplate.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.IMPORTDEFINATION_TEMPLATE");
        ExcelFileUpload.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.IMPORTDEFINATION_IMPORT_FILE");
        ImportDefinationId.FieldLabel = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.IMPORTDEFINATION_IMPORT_SHEMA");
        GridPanelMonitoring.ColumnModel.Columns[0].Header = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.IMPORTDEFINATION_ERRORDESCRIPTION");
        btnRefresh.Text = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_EDITSCREEN_REFRESH);

    }
    private void BindeData()
    {
        var objeid = QueryHelper.GetString("ObjectId");
        var eif = new ExcelImportFactory();
        var li = eif.GetImportDefinationList(ValidationHelper.GetInteger(objeid, 0));
        for (int index = 0; index < li.Count; index++)
        {
            var excelImportItem = li[index];
            ImportDefinationId.AddItem(new ListItem(excelImportItem.ImportDefinationId.ToString(),
                                                    excelImportItem.ImportDefinationName));
            if (index == 0)
                ImportDefinationId.SetValue(excelImportItem.ImportDefinationId.ToString());
        }

    }

    protected void BtnUploadClick(object sender, AjaxEventArgs e)
    {

        var defID = ValidationHelper.GetGuid(ImportDefinationId.Value);
        if (defID == Guid.Empty)
            return;
        MessageBox msg = new MessageBox();
        msg.Modal = true;


        string tpl = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.IMPORTDEFINATION_IMPORTCOMPLATED");
        string ntld = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.IMPORTDEFINATION_PLEASE_CHOOSE_FILE");
        var ixl = new ImportXlsFile();
        var importXlsFileId = GuidHelper.New();
        var impf = new ExcelImportFactory();
        try
        {
            if (ExcelFileUpload.HasFile)
            {
                string[] strFileNamesp = ExcelFileUpload.PostedFile.FileName.Split('\\');
                string strFileName = strFileNamesp[strFileNamesp.Length - 1];

                DataTable importFileInfo = impf.GetImportXlsFile(strFileName);
                if (importFileInfo.Rows.Count > 0)
                {
                    /* Dosya bulundu Statusune göre gereken uyarılar verilecek*/
                    var status = ValidationHelper.GetInteger(importFileInfo.Rows[0]["Status"], 0);
                    if (status == 2)
                    {
                        msg.MsgType = MessageBox.EMsgType.Html;
                        msg.MessageType = EMessageType.Information;
                        msg.Show("", "", "Dosya daha önce aktarılmış.");
                        return;
                    }
                    if (status == 1)
                    {
                        msg.MsgType = MessageBox.EMsgType.Html;
                        msg.MessageType = EMessageType.Information;
                        msg.Show("", "", "Dosya şuanda aktarılıyor. Lütfen bir süre sonra [Masraf Parametreleri] ekranından kontrol ediniz.");
                        return;
                    }
                }

                ixl.FileName = strFileName;
                ixl.ImportXlsFileId = importXlsFileId;
                ixl.ImportDefinationId = ValidationHelper.GetGuid(ImportDefinationId.Value);
                if (ExcelImportFactory.ImportPath.StartsWith(@"\\"))
                {
                    using (var impersonator = new Impersonator())
                    {
                        impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                        LogUtil.Write("File BeforeSaving :" + Path.Combine(ExcelImportFactory.ImportPath, ixl.ImportXlsFileId + strFileName));
                        ExcelFileUpload.PostedFile.SaveAs(Path.Combine(ExcelImportFactory.ImportPath, ixl.ImportXlsFileId + strFileName));
                        LogUtil.Write("File Saved :" + Path.Combine(ExcelImportFactory.ImportPath, ixl.ImportXlsFileId + strFileName));
                        impf.InsertImportXlsFile(ixl);
                        LogUtil.Write("File Imported :" + ixl.ImportXlsFileId);
                        impf.ImportData(ixl);
                        LogUtil.Write("Data Imported:" + ixl.ImportXlsFileId);
                    }
                }
                else
                {
                    LogUtil.Write("File BeforeSaving :" + Path.Combine(ExcelImportFactory.ImportPath, ixl.ImportXlsFileId + strFileName));

                    ExcelFileUpload.PostedFile.SaveAs(Path.Combine(ExcelImportFactory.ImportPath, ixl.ImportXlsFileId + strFileName));

                    LogUtil.Write("File Saved :" + Path.Combine(ExcelImportFactory.ImportPath, ixl.ImportXlsFileId + strFileName));
                    impf.InsertImportXlsFile(ixl);
                    LogUtil.Write("File Imported :" + ixl.ImportXlsFileId);
                    impf.ImportData(ixl);
                    LogUtil.Write("Data Imported:" + ixl.ImportXlsFileId);
                }
                impf.ImportXlsFileStatuUpdate(ixl.ImportXlsFileId);
                msg.MsgType = MessageBox.EMsgType.Html;
                msg.MessageType = EMessageType.Information;
                msg.Show("", "", tpl);
            }
            else
            {
                impf.ImportXlsFileStatuUpdate(ixl.ImportXlsFileId);
                msg.MsgType = MessageBox.EMsgType.Html;
                msg.MessageType = EMessageType.Information;
                msg.Show("", "", ntld);
            }


        }
        catch (CrmException ex)
        {
            msg.MsgType = MessageBox.EMsgType.Html;
            msg.MessageType = EMessageType.Error;
            msg.Show("", "", Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(ex.ErrorMessage).Replace(System.Environment.NewLine, "<br>"));
            LogUtil.WriteException(ex);
        }
        catch (Exception ex)
        {
            msg.Show(ex.Message);
            LogUtil.WriteException(ex);
        }
        GridPanelMonitoring.DataSource = impf.GetResultData(importXlsFileId).Tables[0];
        GridPanelMonitoring.DataBind();
    }
    protected void BtnTemplateClick(object sender, AjaxEventArgs e)
    {
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        var de = df.Retrieve(EntityEnum.ExcelImportDefaination.GetHashCode(),
                             ValidationHelper.GetGuid(ImportDefinationId.Value), DynamicFactory.RetrieveAllColumns);
        if (de.Properties.Contains("Template"))
        {
            var temp = de.GetStringValue("Template");
            if (!string.IsNullOrEmpty(temp))
            {
                QScript(string.Format("window.location = '{0}';", Page.ResolveClientUrl(temp)));
            }
        }
    }

}
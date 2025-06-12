using System;
using System.Data;
using System.IO;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Crm.Labels;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class CrmPages_Admin_Customization_Entity_EntityDictionaryImport : AdminPage
{
    public CrmPages_Admin_Customization_Entity_EntityDictionaryImport()
    {
        ObjectId = EntityEnum.Language.GetHashCode();
    }

    private Guid _sequenceId;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!DynamicSecurity.PrvWrite)
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Language PrvWrite");
        }
        if (!RefleX.IsAjxPostback)
        {
            ImportFile.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_IMPORT_SELECT_FILE);
            BtnUpload.Text = CrmLabel.TranslateMessage("CRM.ENTITY_LABEL_IMPORT_LABEL");
            _sequenceId = GuidHelper.New();
            hdnSequenceId.Value = ValidationHelper.GetString(_sequenceId);

            var lf = new LangFactory();
            var ll = lf.GetLanguages(true);

            foreach (var t in ll)
            {
                Language.AddItem(new ListItem(t.LangId.ToString(), t.RegionName));
            }
        }
        else
        {
            _sequenceId = ValidationHelper.GetGuid(hdnSequenceId.Value);
        }
    }

    protected void DataLoad(object sender, AjaxEventArgs e)
    {
        var ls = new LabelsFactory();
        var data = ls.GetLabelImportTemplate(_sequenceId);
        GridPanel1.TotalCount = data.Count;
        GridPanel1.DataSource = data;
        GridPanel1.DataBind();
    }
    protected void BtnUploadClick(object sender, AjaxEventArgs e)
    {
        var msg = new MessageBox { Modal = true };

        const string tpl = "Uploaded file: {0}<br/>Size: {1} bytes";
        try
        {
            if (ImportFile.HasFile && ValidationHelper.GetInteger(Language.Value, 0) != 0)
            {
                var strFileNamesp = ImportFile.PostedFile.FileName.Split('\\');
                var strFileName = strFileNamesp[strFileNamesp.Length - 1];
                var filePath = Path.Combine(ExcelImportFactory.ImportPath, _sequenceId + strFileName);
                var impf = new ExcelImportFactory();
                var data = new DataTable();
                if (ExcelImportFactory.ImportPath.StartsWith(@"\\"))
                {
                    using (var impersonator = new Impersonator())
                    {
                        impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                        ImportFile.PostedFile.SaveAs(filePath);
                        data = impf.ReadDataFromXls(filePath);
                    }
                }
                else
                {
                    ImportFile.PostedFile.SaveAs(filePath);
                    data = impf.ReadDataFromXls(filePath);
                }
                var ls = new LabelsFactory();
                ls.SaveExcelTemplate(_sequenceId, data, ValidationHelper.GetInteger(Language.Value, 0));

                msg.Show(string.Format(tpl, ImportFile.PostedFile.FileName, ImportFile.PostedFile.ContentLength));
                QScript("GridPanel1.getData();");
            }
            else
            {
                msg.Show(CrmLabel.TranslateMessage("CRM.ENTITY_LABEL_FILL_REQUARED_FIELDS"));
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
    }
    protected void GridPanel1AddUpdateLabelClick(object sender, AjaxEventArgs e)
    {
        var ls = new LabelsFactory();
        ls.LabelImportTemplateToLive(_sequenceId);
        var msg = new MessageBox { Modal = true };
        msg.Show(CrmLabel.TranslateMessage("CRM.ENTITY_LABEL_IMPORT_COMPLATED"));
    }
}
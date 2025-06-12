using System;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;
using System.IO;
using Coretech.Crm.Factory.Crm.CustomControl;
using Coretech.Crm.Objects.Crm.CustomControl;

public partial class CrmPages_Admin_CustomControl_CustomControlDllEditReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_CustomControl_CustomControlDllEditReflex()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    void TranslateMessages()
    {
        TxtDllName.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_NAME);
        ChkDataBase.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_PLUGIN_DATABASE);
        FileUpload1.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CHOOSE_FILE);
        btnSave.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        btnReset.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_RESET);
    }
    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        base.OnPreInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!RefleXFrameWork.RefleX.IsAjxPostback)
        {
            var dllId = QueryHelper.GetString("CustomControlDllId");
            TxtDllName.Disabled = true;
            if (!string.IsNullOrEmpty(dllId))
            {
                hCustomControlDllId.Value = dllId;
                FillDefaultData();
            }
            else
            {
                hCustomControlDllId.Value = Guid.NewGuid().ToString();
            }

        }
    }
    void FillDefaultData()
    {
        var gdCustomControlId = ValidationHelper.GetGuid(hCustomControlDllId.Value);
        var pf = new CustomControlFactory();
        var pdll = pf.GetCustomControlDll(gdCustomControlId);
        TxtDllName.Value = pdll.Name;
        if (pdll.Location == CustomControlLocation.Database)
            ChkDataBase.Checked = true;
    }

    protected void UploadClick(object sender, AjaxEventArgs e)
    {
        const string tpl = "Uploaded file: {0}<br/>Size: {1} bytes";
        var pdll = new CustomControlDll
                       {
                           CustomControlDllId = ValidationHelper.GetGuid(hCustomControlDllId.Value),
                           Name = ValidationHelper.GetString(TxtDllName.Value)
                       };
        //Pdll.FilePath

        if (FileUpload1.HasFile)
        {
            string[] strFileNamesp = FileUpload1.PostedFile.FileName.Split('\\');
            string strFileName = strFileNamesp[strFileNamesp.Length - 1];

            if (ChkDataBase.Checked)
            {
                pdll.Location = CustomControlLocation.Database;


                var binBuffer = new byte[FileUpload1.PostedFile.InputStream.Length];
                var base64ArraySize = (int)Math.Ceiling(FileUpload1.PostedFile.InputStream.Length / 3d) * 4;
                var charBuffer = new char[base64ArraySize];

                FileUpload1.PostedFile.InputStream.Read(binBuffer, 0,
                                                                      (int)
                                                                      FileUpload1.PostedFile.InputStream.
                                                                          Length);
                Convert.ToBase64CharArray(binBuffer, 0, binBuffer.Length, charBuffer, 0);
                pdll.BinaryDll = new String(charBuffer);
            }
            else
            {
                pdll.Location = CustomControlLocation.Disk;
                pdll.FilePath = strFileName;
                FileUpload1.PostedFile.SaveAs(Path.Combine(LoadAssemblyFactory.AssemblyFolder, strFileName));
                //LoadAssemblyFactory
            }


        }


        MessageBox msg = new MessageBox();
        var pf = new CustomControlFactory();
        try
        {
            pf.AddUpdateCustomControlDll(pdll);
            msg.Show(string.Format(tpl, FileUpload1.PostedFile.FileName, FileUpload1.PostedFile.ContentLength));
        }
        catch (Exception ex)
        {
            msg.Show(ex.Message);
        }
    }
    protected void ResetClick(object sender, AjaxEventArgs e)
    {
        try
        {
            if (FileUpload1.Value != null)
                FileUpload1.Clear();
            FileUpload1.SetIValue("");
        }
        catch (Exception ex)
        {
            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

}
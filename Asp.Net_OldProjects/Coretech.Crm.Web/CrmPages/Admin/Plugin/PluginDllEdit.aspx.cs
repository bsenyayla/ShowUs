using System;
using Coolite.Ext.Web;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Objects.Crm.Plugin;
using System.IO;
using Coretech.Crm.Factory.Crm.Plugin;

public partial class CrmPages_Admin_Plugin_PluginDllEdit : AdminPage
{
    public CrmPages_Admin_Plugin_PluginDllEdit()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
         if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!Page.IsPostBack)
        {
            var dllId = QueryHelper.GetString("PluginDllId");
            TxtDllName.Disabled = true;
            if (!string.IsNullOrEmpty(dllId))
            {
                hPluginDllId.Value = dllId;
                FillDefaultData();
            }
            else
            {
                hPluginDllId.Value = Guid.NewGuid().ToString();
            }

        }
    }
    void FillDefaultData()
    {
        var gdPluginId = ValidationHelper.GetGuid(hPluginDllId.Value);
        var pf = new PluginFactory();
        var pdll = pf.GetPluginDll(gdPluginId);
        TxtDllName.Value = pdll.Name;
        if (pdll.Location == PluginLocation.Database)
            ChkDataBase.Checked = true;
    }

    protected void UploadClick(object sender, AjaxEventArgs e)
    {
        const string tpl = "Uploaded file: {0}<br/>Size: {1} bytes";
        var pdll = new PluginDll
                       {
                           PluginDllId = ValidationHelper.GetGuid(hPluginDllId.Value),
                           Name = ValidationHelper.GetString(TxtDllName.Value)
                       };
        //Pdll.FilePath

        if (FileUploadField1.HasFile)
        {
            string[] strFileNamesp = FileUploadField1.PostedFile.FileName.Split('\\');
            string strFileName = strFileNamesp[strFileNamesp.Length - 1];

            if (ChkDataBase.Checked)
            {
                pdll.Location = PluginLocation.Database;


                var binBuffer = new byte[FileUploadField1.PostedFile.InputStream.Length];
                var base64ArraySize = (int)Math.Ceiling(FileUploadField1.PostedFile.InputStream.Length / 3d) * 4;
                var charBuffer = new char[base64ArraySize];

                FileUploadField1.PostedFile.InputStream.Read(binBuffer, 0,
                                                                      (int)
                                                                      FileUploadField1.PostedFile.InputStream.
                                                                          Length);
                Convert.ToBase64CharArray(binBuffer, 0, binBuffer.Length, charBuffer, 0);
                pdll.BinaryDll = new String(charBuffer);
            }
            else
            {
                pdll.Location = PluginLocation.Disk;
                pdll.FilePath = strFileName;
                FileUploadField1.PostedFile.SaveAs(Path.Combine(LoadAssemblyFactory.AssemblyFolder, strFileName));
                //LoadAssemblyFactory
            }


        }



        var pf = new PluginFactory();
        try
        {
            pf.AddUpdatePluginDll(pdll,null);
            MessageShow(string.Format(tpl, FileUploadField1.PostedFile.FileName, FileUploadField1.PostedFile.ContentLength));
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

}
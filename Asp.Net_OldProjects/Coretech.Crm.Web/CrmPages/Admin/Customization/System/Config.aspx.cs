using System;
using System.Configuration;
using System.Web.Configuration;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;

public partial class CrmPages_Admin_Customization_Config : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Customization_Config()
    {
        ObjectId = EntityEnum.Admin.GetHashCode();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!DynamicSecurity.PrvCreate && !DynamicSecurity.PrvWrite)
            Response.End();
    }
    protected void BtnEncryptClickOnEvent(object sender, AjaxEventArgs e)
    {
        var root = System.Web.Hosting.HostingEnvironment.ApplicationVirtualPath;
        EncryptDecrypt(root, true);
    }
    protected void BtnDecryptClickOnEvent(object sender, AjaxEventArgs e)
    {
        var root = System.Web.Hosting.HostingEnvironment.ApplicationVirtualPath;
        EncryptDecrypt(root, false);
    }
    public void EncryptDecrypt(String ApplicationPath, bool Encryptaction)
    {
        Configuration config = WebConfigurationManager.OpenWebConfiguration(ApplicationPath);
        var values = Config.GetKeyValue("EncryptSections", "").Split(';');
        foreach (var ssection in values)
        {
            ConfigurationSection section = config.GetSection(ssection);
            if (Encryptaction)
            {
                if (!section.SectionInformation.IsProtected)
                    section.SectionInformation.ProtectSection("RsaProtectedConfigurationProvider");
            }
            else
            {
                if (section.SectionInformation.IsProtected)
                    section.SectionInformation.UnprotectSection();
            }
        }

        config.Save();

    }



}
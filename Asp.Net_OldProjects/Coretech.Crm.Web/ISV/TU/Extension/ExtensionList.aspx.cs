using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Coretech.Crm.Web.ISV.TU.Extension
{
    public partial class ExtensionList : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            this.Page.Title = "";
        }

        protected void GetData(object sender, AjaxEventArgs e)
        {
            DataTable dt = new TuFactory.ExtensionManager.ExtensionDb().GetExtensionMapping();
            gpExtensionMapping.DataSource = dt;
            gpExtensionMapping.DataBind();
        }

        protected void ExtensionMappingDelete(object sender, AjaxEventArgs e)
        {
            if (ValidationHelper.GetInteger(hdnSelectedId.Value, 0) == 0)
            {
                QScript("alert('Lütfen silmek istediğiniz kaydı seçiniz');");
                return;
            }
            new TuFactory.ExtensionManager.ExtensionDb().ExtensionMappingDelete(ValidationHelper.GetInteger(hdnSelectedId.Value, 0));
            gpExtensionMapping.Reload();
        }

        protected void GetToken(object sender, AjaxEventArgs e)
        {

        }

    }
}
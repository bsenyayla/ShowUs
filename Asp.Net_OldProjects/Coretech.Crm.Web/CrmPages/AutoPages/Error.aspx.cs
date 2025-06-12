using System;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_AutoPages_Error : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LblError.Text = QueryHelper.GetString("message");
    }
}
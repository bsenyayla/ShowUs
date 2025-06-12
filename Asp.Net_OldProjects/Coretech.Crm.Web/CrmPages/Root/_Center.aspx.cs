using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm.Factory.Pages;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Root_center : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect(PageFactory.GetAppHomePageUrl(Page));
    }
}

using System;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.DynamicUrl;
using Coretech.Crm.Utility.Util;

public partial class CrmPages_AutoPages_DashboardDynamicUrl : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var dynamicUrlId = QueryHelper.GetString("DynamicUrlId");
        if(!string.IsNullOrEmpty(dynamicUrlId))
        {

            var df = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId);
            var url=df.GetUrl(ValidationHelper.GetGuid(dynamicUrlId), 0, Guid.Empty);
            Response.Redirect(url);
        }
    }
}
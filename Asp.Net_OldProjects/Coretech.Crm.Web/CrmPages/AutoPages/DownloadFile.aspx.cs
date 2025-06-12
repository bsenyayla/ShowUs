using System;
using System.Web.UI;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;

public partial class CrmPages_AutoPages_DownloadFile : Page
{
    private DynamicSecurity _dynamicSecurity;
    protected void Page_Load(object sender, EventArgs e)
    {
       

    }
    protected override void OnPreRender(EventArgs e)
    {
            var recid = QueryHelper.GetString("recid");
            var objectid = QueryHelper.GetString("objectid");
            var attributeid  = QueryHelper.GetString("attributeid");
            _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(objectid, 0),
                                                     (string.IsNullOrEmpty(recid)
                                                          ? (Guid?)null
                                                          : ValidationHelper.GetGuid(recid)));

            if(!_dynamicSecurity.PrvRead)
            {
                Response.End();
            }
            else
            {
                Response.Clear();
                FileUploadFactory.DownloadFile(ValidationHelper.GetInteger(objectid, 0), ValidationHelper.GetGuid(recid), ValidationHelper.GetGuid(attributeid));
            }
        
        base.OnPreInit(e);
    }
}
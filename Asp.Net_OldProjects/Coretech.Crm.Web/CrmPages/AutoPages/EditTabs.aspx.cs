using System;
using RefleXFrameWork;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;

public partial class CrmPages_AutoPages_EditTabs : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            Tab1.Url = HTTPUtil.GetWebAppRoot() + "/CrmPages/AutoPages/EditRefleX.aspx?" +
                "rnd=" + Guid.NewGuid() +
                "&defaulteditpageid=" + QueryHelper.GetString("defaulteditpageid") +
                       "&ObjectId=" + QueryHelper.GetString("ObjectId") +
                       "&framename=" + QueryHelper.GetString("framename") +
                       "&gridpanelid=" + QueryHelper.GetString("gridpanelid") +
                       "&pframename=" + QueryHelper.GetString("pframename") +
                       "&recid=" + QueryHelper.GetString("recid") +
                       "&FetchXML=" + QueryHelper.GetString("FetchXML");

            Tabpanel1.LoadUrl();
        }
    }
}
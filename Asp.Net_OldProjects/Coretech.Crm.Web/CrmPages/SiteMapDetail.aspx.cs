using System;
using Coretech.Crm.Factory.Pages;
using RefleXFrameWork;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Factory;

public partial class CrmPages_SiteMapDetail : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleXFrameWork.RefleX.IsAjxPostback)
        {
            dataview1.Template.Text = @"
                                <div class='thumb-wrap' id='id{SiteMapAreaDetailId}' url='{Url}' >
			                        <div class='thumb'>
                                        <table>
                                            <tr>
                                                <td width='128px'>
                                                </td>
                                                <td width='200px' align='left'>
                                                    <b><span class='x-editable'>{PageName}</span></b>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width='128px'>
                                                    <img src='{ImgUrl}'>
                                                </td>
                                                <td width='200px'>
                                                   <span class='x-editable'>{Description}</span>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
		                        </div>
";

            var pf = new PageFactory();
            dataview1.DataSource = pf.GetSiteMapAreaDetails(ValidationHelper.GetGuid(QueryHelper.GetString("SiteMapAreaId")));
            dataview1.DataBind();
            dataview1.Reload();
        }
    }

    protected void IISResetOnEvent(object sender, AjaxEventArgs e)
    {
        var impersonator = new Impersonator();
        impersonator.Impersonate(App.Params.GetConfigKeyValue("ImporterUser"), App.Params.GetConfigKeyValue("ImporterDomain"), App.Params.GetConfigKeyValue("ImporterPwd"), LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);

        System.Diagnostics.Process.Start(@"C:\Windows\System32\iisreset.exe");
        e.Success = true;
    }
}
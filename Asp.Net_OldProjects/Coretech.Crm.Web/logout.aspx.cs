using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Provider;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;

public partial class logout : RefleXPage
{
    public int LangId = 1055;
    protected void Page_Load(object sender, EventArgs e)
    {
        Session.Abandon();
        Response.Cookies.Add(new HttpCookie("ASP.NET_SessionId", ""));

        var df= new DynamicFactory(ERunInUser.SystemAdmin);
        df.AfterLogout();
        if (App.Params.GetConfigKeyValue("authentication", "") == "windows" && QueryHelper.GetString("dologin") == "0")
        {
            MessageShow(CrmLabel.TranslateMessageNotLogin("INVALID_USERNAME_OR_PASSWORD", LangId));
        }
        if (App.Params.GetConfigKeyValue("authentication", "") == "webgatesso" )
        {
            WebgateSsoLoOut();
        }
    }
    public static void MessageShow(String message)
    {
        ScriptCreater.AddInstanceScript(@"R.MessageBox('Error', '" + message.Replace("'", "\"").Replace("\r", "").Replace("\n", "") + "', '', true, R.MessageType.Warning, R.ButtonType.OK, function (btn) { }, false);");
    }
    protected override void OnPreInit(EventArgs e)
    {
        var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
        LangId = ValidationHelper.GetInteger(loginLangId, 1055);
        base.OnPreInit(e);
    }
    private void WebgateSsoLoOut()
    {
        try
        {
            Response.Redirect(App.Params.GetConfigKeyValue("logouturl", "login.aspx"));
        }
        catch (Exception)
        {
             
        }

        Response.Redirect("login.aspx");
    }
}
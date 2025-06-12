using System;
using System.Data;
using System.Reflection;
using System.Web.SessionState;
using System.Web.UI.HtmlControls;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Users;
using Coretech.Crm.PluginData;
using Coretech.Crm.Provider.Security;
using System.Web;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System.Security.Principal;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class Coretech_Login : RefleXPage
{
    void TranslateMessage()
    {
        txtUsername.FieldLabel = "<b>" + CrmLabel.TranslateMessageNotLogin("LOGIN_USERNAME", LangId) + "</b>";
        txtPassword.FieldLabel = "<b>" + CrmLabel.TranslateMessageNotLogin("LOGIN_PASSWORD", LangId) + "</b>";
        BtnReminder.Text = "<b>" + CrmLabel.TranslateMessageNotLogin("LOGIN_REMINDPASSWORD", LangId) + "</b>";
        RWindow.Title = CrmLabel.TranslateMessageNotLogin("LOGIN_REMINDPASSWORD", LangId);
        btnLogin.Text = "<b>" + CrmLabel.TranslateMessageNotLogin("LOGIN_LOGIN", LangId) + "</b>";
        question.Value = CrmLabel.TranslateMessageNotLogin("LOGIN_CHANGE_PASSWORD_ARE_YOU_SURE", LangId);
        btnLogin.AjaxEvents.Click.EventMask.Msg = CrmLabel.TranslateMessageNotLogin("LOGIN_LOGING", LangId);
        RegisterResources.RedirectText = CrmLabel.TranslateMessageNotLogin("CRM_REDIRECTING_TEXT", LangId);
        CompanyLogo.Text = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>" + CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_HEADER_UPT_USER_LOGIN", LangId) + "</B>";
    }

    public int LangId = 1055;

    protected void LanguageOnEvent(object sender, AjaxEventArgs e)
    {
        RefleX.DeleteCookie("CrmLanguage");
        RefleX.SetCookie("CrmLanguage", e.ExtraParams["LangId"], 365);
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (App.Params.CurrentUser != null)
            App.Params.CurrentUser = null;
        var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
        LangId = ValidationHelper.GetInteger(loginLangId, 1055);
        if (loginLangId == string.Empty)
        {

            var lf = new LangFactory();
            var ll = lf.GetLanguages(true);
            for (int i = 0; i < ll.Count; i++)
            {
                var td = new HtmlTableCell();
                var lbl = new Label
                              {
                                  ID = "flagtd_" + i,
                                  CustomCss = "x-label-icon-rev",
                                  Width = 20,
                                  ToolTip = ll[i].RegionName
                              };
                lbl.AjaxEvents.Click.Event += LanguageOnEvent;
                lbl.AjaxEvents.Click.ExtraParams.Add(new Parameter("LangId", ll[i].LangId.ToString(), EpMode.Value));
                lbl.AjaxEvents.Click.Success = "document.location.href =document.location.href;";
                if (ll[i].Flag != null)
                    lbl.Icon = (Icon)ll[i].Flag;
                td.Controls.Add(lbl);
                FlagsTr.Cells.Add(td);
            }
        }

        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (App.Params.GetConfigKeyValue("authentication", "") == "webgatesso" && QueryHelper.GetString("dologin") != "0")
        {
            WebgateSsoLogin();
        }
        if (App.Params.GetConfigKeyValue("authentication", "") == "cosmocall" && QueryHelper.GetString("dologin") != "0")
        {
            CosmoCallLogin();
        }
        if (App.Params.GetConfigKeyValue("authentication", "") == "windows" && QueryHelper.GetString("dologin") != "0")
        {
            WindowsLogin();
        }
        else if (App.Params.GetConfigKeyValue("authentication", "") == "windows" || App.Params.GetConfigKeyValue("authentication", "") == "webgatesso")
        {
            Response.Redirect("logout.aspx");

        }

        if (!IsPostBack && !RefleX.IsAjxPostback)
        {
            ClientScript.RegisterClientScriptBlock(typeof(string), "GetWebAppRoot", "var GetWebAppRoot='" + HTTPUtil.GetWebAppRoot() + "';", true);
            
            Session.Abandon();
            Response.Cookies.Add(new HttpCookie("ASP.NET_SessionId", ""));

            var cookie = Request.Cookies["CrmLanguage"];
            if (cookie != null)
            {
                try
                {
                    LangId = Convert.ToInt32(cookie.Value);
                }
                catch (Exception)
                {
                    RefleX.DeleteCookie("CrmLanguage");
                }
                var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
                if (loginLangId != string.Empty)
                    LangId = ValidationHelper.GetInteger(loginLangId, 1055);
            }

            TranslateMessage();
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetValidUntilExpires(false);
            HttpContext.Current.Session.Abandon();
            ScriptCreater.AddInstanceScript("txtUsername.focus();");
            ScriptCreater.AddInstanceScript("PnlWindow.setTitle ( '" + App.Params.GetConfigKeyValue("ApplicationName") + "');");
            //CompanyLogo.ImageUrl = App.Params.GetConfigKeyValue("CompanyLogo");
        }
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        if (QueryHelper.GetString("dologin") == "0")
        {
            df.AfterLogout();
        }
        else
        {
            df.BeforeLogin();
        }
    }

    void RegenerateId()
    {
        var manager = new SessionIDManager();
        var oldId = manager.GetSessionID(Context);
        var newId = manager.CreateSessionID(Context);
        bool isAdd, isRedir;
        manager.SaveSessionID(Context, newId, out isRedir, out isAdd);
        var ctx = HttpContext.Current.ApplicationInstance;
        var mods = ctx.Modules;
        var ssm = (SessionStateModule)mods.Get("Session");
        var fields = ssm.GetType().GetFields(BindingFlags.NonPublic | BindingFlags.Instance);
        SessionStateStoreProviderBase store = null;
        FieldInfo rqIdField = null, rqLockIdField = null, rqStateNotFoundField = null;
        foreach (var field in fields)
        {
            if (field.Name.Equals("_store")) store = (SessionStateStoreProviderBase)field.GetValue(ssm);
            if (field.Name.Equals("_rqId")) rqIdField = field;
            if (field.Name.Equals("_rqLockId")) rqLockIdField = field;
            if (field.Name.Equals("_rqSessionStateNotFound")) rqStateNotFoundField = field;
        }
        if (rqLockIdField != null)
        {
            var lockId = rqLockIdField.GetValue(ssm);
            if ((lockId != null) && (oldId != null))
                if (store != null) store.ReleaseItemExclusive(Context, oldId, lockId);
        }
        if (rqStateNotFoundField != null) rqStateNotFoundField.SetValue(ssm, true);
        if (rqIdField != null) rqIdField.SetValue(ssm, newId);
    }

    protected void BtnLoginClick(object sender, AjaxEventArgs e)
    {
        var username = txtUsername.Value;
        var password = txtPassword.Value;
        var us = new UserSecurity();
        DynamicFactory df = new DynamicFactory(ERunInUser.SystemAdmin);
        
        User usr;
        try
        {
           
            usr = us.Login(App.Params.CurrentUser.SessionID, username, password);
        }
        catch (CrmException exc)
        {
            MessageShow(CrmLabel.TranslateMessageNotLogin(exc.ErrorMessage, LangId));
            return;
        }

        if (usr != null)
        {
            RegenerateId();
         
            df.AfterLogin();
            Response.Write(CrmLabel.TranslateMessage(LabelEnum.ACCOUNT));
            Response.Redirect(App.Params.GetConfigKeyValue("ApplicationMainForm") != null
                                  ? Page.ResolveClientUrl("~/" +
                                                          App.Params.GetConfigKeyValue("ApplicationMainForm"))
                                  : Page.ResolveClientUrl("~/CrmPages/Main.aspx"));
        }
        else
        {
            MessageShow(CrmLabel.TranslateMessageNotLogin("INVALID_USERNAME_OR_PASSWORD", LangId));
        }
       
       
    }

    public static void MessageShow(String message)
    {
        ScriptCreater.AddInstanceScript(@"R.MessageBox('Error', '" + message.Replace("'", "\"").Replace("\r", "").Replace("\n", "") + "', '', true, R.MessageType.Warning, R.ButtonType.OK, function (btn) {txtUsername.focus(); }, false);");
    }
    private void WindowsLogin()
    {
        WindowsIdentity identity;
        // get the current user's identity
        identity = (WindowsIdentity)(Context.User.Identity);

        var us = new UserSecurity();
        var uname = identity.Name.Split('\\');


        if (us.Login(App.Params.CurrentUser.SessionID, uname[uname.Length - 1]) != null)
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            df.AfterLogin();

            Response.Write(CrmLabel.TranslateMessage(LabelEnum.ACCOUNT));

            Response.Redirect(App.Params.GetConfigKeyValue("ApplicationMainForm") != null
                                  ? Page.ResolveClientUrl("~/" +
                                                          App.Params.GetConfigKeyValue("ApplicationMainForm"))
                                  : Page.ResolveClientUrl("~/CrmPages/Main.aspx"));
        }
        else
        {
            MessageShow(CrmLabel.TranslateMessageNotLogin("INVALID_USERNAME_OR_PASSWORD", LangId));
            Response.Redirect("logout.aspx?dologin=0");
        }
    }
    private void CosmoCallLogin()
    {
        var sd = new StaticData();
        sd.AddParameter("new_CosmoUserId", DbType.AnsiString, QueryHelper.GetString("CosmoId"));
        var userName = ValidationHelper.GetString(sd.ExecuteScalar(@"
            Select UserName from vSystemUser where DeletionStateCode = 0 and new_CosmoUserId = @new_CosmoUserId
        "));
        var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
        LangId = ValidationHelper.GetInteger(loginLangId, 1055);
        var us = new UserSecurity();
        if (us.Login(App.Params.CurrentUser.SessionID, userName) != null)
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            df.AfterLogin();

            Response.Redirect(App.Params.GetConfigKeyValue("ApplicationMainForm") != null
                                  ? Page.ResolveClientUrl("~/" +
                                                          App.Params.GetConfigKeyValue("ApplicationMainForm"))
                                  : Page.ResolveClientUrl("~/CrmPages/Main.aspx"));
        }
        else
        {
            MessageShow(CrmLabel.TranslateMessageNotLogin("INVALID_USERNAME_OR_PASSWORD", LangId));
            Response.Redirect(Page.ResolveClientUrl("~/logout.aspx?dologin=0"));
        }
    }

    private void WebgateSsoLogin()
    {

        var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
        LangId = ValidationHelper.GetInteger(loginLangId, 1055);
        var us = new UserSecurity();
        var uname = Request.Headers["user"];
        if (us.Login(App.Params.CurrentUser.SessionID, uname) != null)
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            df.AfterLogin();

            Response.Redirect(App.Params.GetConfigKeyValue("ApplicationMainForm") != null
                                   ? Page.ResolveClientUrl("~/" +
                                                           App.Params.GetConfigKeyValue("ApplicationMainForm"))
                                   : Page.ResolveClientUrl("~/CrmPages/Main.aspx"));
        }
        else
        {
            MessageShow(CrmLabel.TranslateMessageNotLogin("INVALID_USERNAME_OR_PASSWORD", LangId));
            Response.Redirect(Page.ResolveClientUrl("~/logout.aspx?dologin=0"));
        }
    }
}
<%@ Application Language="C#" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Import Namespace="Coretech.Crm.Factory.Crm.Dynamic" %>
<%@ Import Namespace="Coretech.Crm.Factory.Crm.Parameters" %>
<%@ Import Namespace="Coretech.Crm.Objects.Crm.WorkFlow" %>
<%@ Import Namespace="RefleXFrameWork" %>
<%@ Import Namespace="Coretech.Crm.Provider" %>
<%@ Import Namespace="Coretech.Crm.Provider.Security" %>
<%@ Import Namespace="Coretech.Crm.Utility.Util" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Threading" %>
<%@ Import Namespace="Coretech.Crm.Web.Hangfire" %>
<%@ Import Namespace="Plus.Logging" %>
<script RunAt="server">

    protected void Application_PreRequestHandlerExecute(object sender, EventArgs e)
    {
        try
        {
            // Determine request source
            //1. Webform i.e. aspx page
            //2. Any other resource requested. for e.g gif,js,css,jpg
            //3. Whether this request is generated from report viewer using refrsh button
            //4. whether it is auto-generated for keeping session alive.

            if ((!Request.Url.ToString().Contains("Reserved.ReportViewerWebControl.axd") && Request.Url.ToString().Contains(".aspx"))
                 || (Request.Url.ToString().Contains("Reserved.ReportViewerWebControl.axd") && !Request.Url.ToString().Contains("&OpType=SessionKeepAlive")))
            {

                // Make a dummy datetime variable to explicitely store last user request.
                if (Session["LastRequestDateTime"] != null)
                {
                    // If the time elapsed is greater than Session Timeout, explicitely clear the session, forcing it to timeout.
                    // Else update the dummy session variable.
                    if ((DateTime)Session["LastRequestDateTime"] > DateTime.Now.AddMinutes(-Session.Timeout))
                    {
                        Session["LastRequestDateTime"] = DateTime.Now;
                    }
                    else
                    {
                        Session.Clear();
                    }
                }
                else
                {
                    Session["LastRequestDateTime"] = DateTime.Now;
                }

            }
        }
        catch (Exception ex)
        {
            // As non .Net resouces (gif,js,css,jpg) does not provide session object in context.
            if (ex.Message != "Session state is not available in this context.")
            {
                // Error logging logic     
                throw ex;
            }
        }
    }

    public override void Init()
    {
        base.Init();
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        df.ApplicationInit();
    }

    private void Application_BeginRequest(object sender, EventArgs e)
    {
        //System.Threading.Thread.CurrentThread.CurrentUICulture =
        //System.Threading.Thread.CurrentThread.CurrentCulture = 
        //new CultureInfo(App.Settings["CMS.Website.CMSDefaultCultureCode"]);
        //HttpUrlRewriter.Process();
    }

    private void Application_EndRequest(object sender, EventArgs e)
    {
        var ishttps = HttpContext.Current.Request.ServerVariables["HTTPS"].ToUpper() == "OFF" ? false : true;

        if (Response.Cookies.Count > 0 && ishttps)
        {
            foreach (string s in Response.Cookies.AllKeys)
            {
                if (s == FormsAuthentication.FormsCookieName || s.ToLower(new CultureInfo("en-US", false)) == "asp.net_sessionid")
                {
                    Response.Cookies[s].Secure = true;
                }
            }
        }
    }

    private static void OnlineUserUpdate(HttpApplication app, List<OnlineUsers> ou)
    {
        //if (app.Context.Session == null) return;
        //if (ou.Count == 0 && (app.Request.AppRelativeCurrentExecutionFilePath != "~/Login.aspx" && app.Request.AppRelativeCurrentExecutionFilePath != "~/Reminder.aspx"))
        //{
        //    app.Response.Redirect("~/Login.aspx");
        //    return;
        //}
        //var sameUser = false;
        //foreach (var t in ou)
        //{
        //    if (t.SessionID == app.Context.Session.SessionID)
        //    {
        //        if (t.SystemUserId == App.Params.CurrentUser.SystemUserId)
        //        {
        //            if (!sameUser)
        //            {
        //                if (t.AccessTime.AddMinutes(t.Timeout) > DateTime.Now)
        //                {
        //                    t.AccessTime = DateTime.Now;
        //                }
        //                else
        //                {
        //                    app.Response.Redirect("~/Login.aspx");
        //                }
        //            }
        //            else
        //            {
        //                ou.Remove(t);
        //                app.Response.Redirect("~/Login.aspx");
        //                return;
        //            }
        //        }
        //    }
        //    else
        //    {
        //        if (t.SystemUserId == App.Params.CurrentUser.SystemUserId)
        //        {
        //            sameUser = true;
        //        }
        //    }
        //}
    }

    private void Application_Start(object sender, EventArgs e)
    {
        //System.Net.ServicePointManager.SecurityProtocol = 
        //    (System.Net.SecurityProtocolType)48 | //Ssl3
        //    (System.Net.SecurityProtocolType)192 | //Tls
        //    (System.Net.SecurityProtocolType)768 | //Tls11
        //    (System.Net.SecurityProtocolType)3072; //Tls12

        //Application["OnlineUserList"] = new List<OnlineUsers>();
        //HttpRedirect.OnlineUserUpdate += OnlineUserUpdate;
        try
        {
            CrmApplication.LoadApplicationData();
            HangfireBootstrapper.Instance.Start();
            //Logger.Configure();
        }
        catch (System.Data.SqlClient.SqlException ex)
        {
            Response.Clear();
            Response.Write("Database Connection Error");
            //throw;
        }

        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        df.ApplicationStart();
        //SiteFactory.UpdateCurrentSiteStatus("RUNNING");
    }

    private void Application_End(object sender, EventArgs e)
    {
        //SiteFactory.UpdateCurrentSiteStatus("STOPPED");
        HangfireBootstrapper.Instance.Stop();
    }

    private void Application_Error(object sender, EventArgs e)
    {
        try
        {

            if (ValidationHelper.GetBoolean(ParameterFactory.GetParameterValue("DisableApplicationErrorLog")))
                return;

            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            df.ApplicationError();
            LogUtil.WriteException(Server.GetLastError());


        }
        catch (System.Exception)
        {
            //Response.Clear();

        }

    }

    private void Session_Start(object sender, EventArgs e)
    {
        //Code that runs when a new session is started
        HttpCookie cookie = Request.Cookies[UserSecurity.SessionidCookiename];
        HttpCookie cookieReferrer = Request.Cookies[UserSecurity.ReferrerCookiename];
        if (cookie == null)
        {
            string sessionID = Guid.NewGuid().ToString();
            //UserSecurity.WriteSessionIdToCookie(sessionID);
        }
        else
        {
            Session[UserSecurity.SessionidCookiename] = cookie.Value;
        }

        if (cookieReferrer != null)
        {
            Session[UserSecurity.ReferrerCookiename] = cookieReferrer.Value;
            Session["UseReferrer"] = "1";
        }
        else
        {
            Session["UseReferrer"] = "0";
            Session[UserSecurity.ReferrerCookiename] = "0";
        }
        //Session.Timeout = 10;
        //UserSecurity.Remember(Session[UserSecurity.SessionidCookiename].ToString(),
        //                      Session[UserSecurity.ReferrerCookiename].ToString(), Session["UseReferrer"].ToString());
    }


</script>

using SharedCRCMS.Service;
using SharedCRCMS.Service.LogManager;
using System;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using System.Linq;
using SharedCRCMS.Enums;

namespace Counter
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception exception = Server.GetLastError();
            if (exception != null)
            {
                LogMan.SetGlobalContext("Module", "CounterNew");
                LogMan.Error("SERVER LAST ERROR!!!!!: ", exception);
            }
        }
        protected void Application_Start()
        {
            ApplicationNames.IntitializeLog4Net(ApplicationNames.COUNTER_NEW);

            /* Open FirstChanceException just for debugging purpose..
            AppDomain.CurrentDomain.FirstChanceException += (sender, eventArgs) =>
            {
                LogMan.Error(eventArgs.Exception.ToString());
            };
            */
            LogMan.SetGlobalContext("Module", "CounterNew");
            LogMan.Info("COUNTER_NEW service has started!");

            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }
        /*
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception exception = Server.GetLastError();
            if (exception != null)
            {
                LogMan.Error("SERVER LAST ERROR!!!!!: ", exception);
            }

            Response.Clear();

            if (exception is HttpException)
            {
                string action = "HttpError";

                // clear error on server
                Server.ClearError();

                Response.Redirect(String.Format("~/Error/{0}", action));
            }
        }
        */

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            
        }
        protected void Application_AuthenticateRequest(Object sender, EventArgs e)
        {
            if (IsAuthenticated)
            {
                StandartLibrary.Models.DataModels.UserPreferences userPreferences = new StandartLibrary.Models.DataModels.UserPreferences();

                using (SharedCRCMS.Models.CRCMSEntities db = new SharedCRCMS.Models.CRCMSEntities())
                {
                    userPreferences = (from p in db.UserPreferences
                                       where p.PreferenceName == StandartLibrary.Models.Enums.UserPreferencesEnum.Language.ToString()
                                       && p.UserCode.ToUpper() == User.Identity.Name.ToUpper()
                                       select p).FirstOrDefault();

                }

                var lang = (userPreferences != null && !string.IsNullOrEmpty(userPreferences.PreferenceValue)) ? userPreferences.PreferenceValue : AppSettingService.AppSetting.JSContent.DefaultLanguage;

                var cultureInfo = new CultureInfo(lang);
                cultureInfo.DateTimeFormat.ShortDatePattern = "dd.MM.yyyy";
                cultureInfo.DateTimeFormat.ShortTimePattern = "HH:mm:ss";
                cultureInfo.DateTimeFormat.LongDatePattern = "dd.MM.yyyy";
                cultureInfo.DateTimeFormat.LongTimePattern = "HH:mm:ss";
                Thread.CurrentThread.CurrentUICulture = cultureInfo;
                Thread.CurrentThread.CurrentCulture = cultureInfo;
            }
        }
        public bool IsAuthenticated
        {
            get
            {
                return User != null &&
                       User.Identity != null &&
                       User.Identity.IsAuthenticated;
            }
        }
    }
}

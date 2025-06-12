using Coretech.Crm.Web.Hangfire;
using Hangfire;
using Hangfire.Dashboard;
using Hangfire.SqlServer;
using Microsoft.Owin;
using Owin;

[assembly: OwinStartup(typeof(Coretech.Crm.Web.Startup))]
namespace Coretech.Crm.Web
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            GlobalConfiguration.Configuration.UseSqlServerStorage("DefaultConnection");

            var options = new DashboardOptions()
            {
                Authorization = new[]
                {
                    new UptHangfireAuthorization()
                }
            };

            app.UseHangfireDashboard("/bankServiceJobs", options);
            app.UseHangfireServer();
        }
    }
}
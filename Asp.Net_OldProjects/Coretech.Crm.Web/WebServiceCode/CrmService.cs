using System;
using System.Web.Services;
using System.Web.Services.Protocols;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Provider.Security;
using Coretech.Crm.Scheduler.Factory;

/// <summary>
/// Summary description for CrmService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]

public class CrmService : System.Web.Services.WebService
{
    public WsSystemUserInfo UserInfo;
    public CrmService()
    {
    }
    [SoapHeader("UserInfo")]
    [WebMethod(EnableSession = true)]
    public DynamicEntity Retrieve(string entityName, Guid recordId, string[] retrieveColumn)
    {
        var us = new UserSecurity();
        var gdRet = Guid.Empty;
        if (us.Login(Guid.NewGuid().ToString(), UserInfo.Username, UserInfo.Password) != null)
        {

            var df = new DynamicFactory(ERunInUser.CalingUser);
            var d = df.Retrieve(entityName, recordId, retrieveColumn);
            return d;
        }
        return new DynamicEntity();

    }
    [SoapHeader("UserInfo")]
    [WebMethod(EnableSession = true)]
    public Guid Create(DynamicEntity entity)
    {
        var us = new UserSecurity();
        var gdRet = Guid.Empty;
        if (us.Login(Guid.NewGuid().ToString(), UserInfo.Username, UserInfo.Password) != null)
        {
            var df = new DynamicFactory(ERunInUser.CalingUser);
            gdRet = df.Create(entity.Name, entity);
        }
        return gdRet;
    }

    [WebMethod(EnableSession = true)]
    public void ExecScheduler(Guid scheduleId)
    {
        SchedulerWebFactory.ExecScheduler(scheduleId);
    }



}

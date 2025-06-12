using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Serialization;
using Coretech.Crm.Email.Factory;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Email;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Plugin;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Provider.Security;
using Coretech.Crm.WorkFlow;

/// <summary>
/// Summary description for DynamicWebService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class DynamicWebService : System.Web.Services.WebService {
    public WsSystemUserInfo UserInfo; 
    public DynamicWebService () {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    
//    [WebMethod]
//    public string GetActivityCount(string ErpPartnerNo)
//    {
//        string strsql = @"select count(*) as CNT from vnew_contact c 
//        Inner Join vNew_case c1 on c1.new_ContactId=c.New_contactId 
//        Inner Join vNew_activity a on a.new_CaseId=c1.New_caseId
//        where c.new_OmvContactCode=@OmvContactCode";
//        StaticData sd = new StaticData();
//        sd.AddParameter("OmvContactCode", DbType.String, ErpPartnerNo);
//        var ds = sd.ReturnDataset(strsql);
//        return serializeDataTable(ds.Tables[0]);
//    }
    //internal string serializeDataTable(DataTable table)
    //{
    //    var writer = new System.IO.StringWriter();

    //    var mySerializer = new XmlSerializer(typeof(DataTable));
    //    var tw = new StringWriter();
    //    mySerializer.Serialize(tw, table);
    //    return tw.ToString();

    //}

    [SoapHeader("UserInfo")] 
    [WebMethod(EnableSession = true)]
    public void RunWorkflowService(string sessionId, string username, string password)
    {
        var us = new UserSecurity();
        if (us.Login(Guid.NewGuid().ToString(), UserInfo.Username, UserInfo.Password) != null)
        {
            var wfm = new WorkFlowMaster();
            wfm.ExecWf(App.Params.CurrentUser.SystemUserId);
        }
    }
    
    
    [SoapHeader("UserInfo")] 
    [WebMethod(EnableSession = true)]
    public void SendMail()
    { 
        var us = new UserSecurity();
        if (us.Login(Guid.NewGuid().ToString(), UserInfo.Username, UserInfo.Password) != null)
        {
            var ef = new EmailFactory();
            ef.Execute();

        }
    }
    [SoapHeader("UserInfo")]
    [WebMethod(EnableSession = true)]
    public void ExecPlugin(PluginMsgType pluginMsgType, string entityName, Guid pluginId, DynamicEntity dynamicEntity)
    {   var us = new UserSecurity();
        if (us.Login(Guid.NewGuid().ToString(), UserInfo.Username, UserInfo.Password) != null)
        {
            var df = new DynamicFactory(ERunInUser.CalingUser);
            df.ExecPlugin(pluginMsgType, entityName, pluginId, ref dynamicEntity);
        }
    }
    
    


}

using System;
using AjaxPro;
using Coretech.Crm.PluginData;
using System.Data;
using Coretech.Crm.Web.UI.RefleX;
using TuFactory.CustAccount.Object;
using Coretech.Crm.Factory.Network;
using System.IO;
using System.Collections.Generic;
using Coretech.Crm.Utility.Util;
using TuFactory.CustAccount.Business.Service;
using RefleXFrameWork;

public partial class SenderDocument_CorporatedSenderDocument : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Utility.RegisterTypeForAjax(typeof(AjaxMethods));
        QScript("PageLoad();");
    }
    
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {
        [AjaxMethod()]
        public void UpdateDocumentReceivedFlg(Guid SenderDocumentID)
        {
            StaticData sd = new StaticData();
            sd.AddParameter("SenderDocumentID", DbType.Guid, SenderDocumentID);
            sd.ExecuteNonQuerySp("spTUSenderDocumentUpdateReceivedFlg");
        }
    }



}
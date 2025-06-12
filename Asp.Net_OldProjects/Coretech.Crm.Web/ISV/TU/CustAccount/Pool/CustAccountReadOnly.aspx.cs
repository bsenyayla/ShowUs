using System;
using System.Collections.Generic;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.CustAccount.Business;

public partial class CustAccount_Pool_CustAccountReadOnly : BasePage
{
    private static string _blankurl = "about:blank";
    private static Guid _recid = Guid.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        _recid = QueryHelper.GetGuid("recid");

        if (!RefleX.IsAjxPostback)
        {
            var readonlyForm = CustAccountOperations.GetCustAccountOperationsReadOnlyPageId(_recid);
            var query = new Dictionary<string, string>
            {
                {"ObjectId", TuEntityEnum.New_CustAccountOperations.GetHashCode().ToString()},
                {"defaulteditpageid", readonlyForm.ToString()},
                {"recid", _recid.ToString()},
            };

            var url = QueryHelper.AddUpdateString(this, HTTPUtil.GetEditpage(), query);

            CustAccountOperationsDetail.AutoLoad.Url = url;

        }
    }

   
}
using Coretech.Crm.PluginData;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Coretech.Crm.Web.ISV.TU.Operation
{
    public partial class ShowAccountBalances : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                SearchOnEvent(null, null);
            }
        }

        protected void SearchOnEvent(object sender, AjaxEventArgs e)
        {
            AccountsOnLoad(sender, e);
        }

        protected void AccountsOnLoad(object sender, AjaxEventArgs e)
        {
            DataTable dt = GetData();
            gpAccounts.DataSource = dt;
            gpAccounts.TotalCount = dt.Rows.Count;
            gpAccounts.DataBind();
        }

        private System.Data.DataTable GetData()
        {
            StaticData sd = new StaticData();
            if (!string.IsNullOrEmpty(tAccountNo.Value))
            {
                sd.AddParameter("AccountNo", System.Data.DbType.String, tAccountNo.Value.Trim());
            }
            System.Data.DataSet ds = sd.ReturnDatasetSp("spGetAccountBalances");

            return ds.Tables[0];
        }
    }
}
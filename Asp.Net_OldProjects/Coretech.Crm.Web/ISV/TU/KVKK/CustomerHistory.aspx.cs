using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.CustomerData;

namespace Coretech.Crm.Web.ISV.TU.KVKK
{
    public partial class CustomerHistory : BasePage
    {
        private Guid CustomerId
        {
            get
            {
                return ValidationHelper.GetGuid(Request.QueryString["CustomerId"]);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                HistoryDataLoad(null, null);
            }
        }

        protected void HistoryDataLoad(object sender, AjaxEventArgs e)
        {
            DataTable dt = CustomerDataProtectionService.GetCustomerDataPermissionLogs(this.CustomerId);
            gpHistory.DataSource = dt;
            gpHistory.TotalCount = dt.Rows.Count;
            gpHistory.DataBind();
        }
    }
}
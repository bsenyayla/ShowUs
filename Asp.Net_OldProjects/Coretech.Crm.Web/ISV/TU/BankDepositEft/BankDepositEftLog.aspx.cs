using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.Data;

namespace Coretech.Crm.Web.ISV.TU.BankDepositEft
{
    public partial class BankDepositEftLog : BasePage
    {
        Guid LogId = Guid.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            LogId = ValidationHelper.GetGuid(QueryHelper.GetGuid("LogId"), Guid.Empty);
            if (!RefleX.IsAjxPostback)
            {

            }
        }



        protected void ToolbarButtonFindBankDepositEftLogClick(object sender, AjaxEventArgs e)
        {
            var sd = new StaticData();
            sd.AddParameter("LogId", DbType.Guid, LogId);
            DataTable dt = sd.ReturnDatasetSp("spGetBankDepositEftLog").Tables[0];

            GrdBankDepositEftLog.DataSource = dt;
            GrdBankDepositEftLog.DataBind();

        }
    }
}
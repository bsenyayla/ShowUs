using System;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using TuFactory.Transfer;
using System.Data;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_LogoTotal : BasePage
    {
        //private TuUserApproval _userApproval = null;
        //MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

        private void TranslateMessage()
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
            TranslateMessage();

            hdnStartDate.Value = QueryHelper.GetString("StartDate");
            hdnEndDate.Value = QueryHelper.GetString("EndDate");

            //var ufFactory = new TuUserFactory();
            //_userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

            GetReconciliationData();
        }

        private void GetReconciliationData()
        {
            DateTime startDate = ValidationHelper.GetDate(hdnStartDate.Value);
            DateTime endDate = ValidationHelper.GetDate(hdnEndDate.Value);
            DataTable dt = LogoReconciliationFactory.Instance.GetLogoReconciliationTotalData(startDate, endDate.AddDays(1), false);
            GrdTotalReConciliation.DataSource = dt;
            GrdTotalReConciliation.DataBind();
        }
    }
}
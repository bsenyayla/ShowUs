using System;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Transfer;
using TuFactory.Object.User;
using System.Data;
using Coretech.Crm.Factory.Exporter;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_UptBankTotalCheck : BasePage
    {
        DataTable result
        {
            get
            {
                return Session["ReconciliationData"] as DataTable;
            }
            set
            {
                Session["ReconciliationData"] = value;
            }
        }

        private TuUserApproval _userApproval = null;

        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

        protected void Page_Load(object sender, EventArgs e)
        {
            //TranslateMessage();
            //HdnReportId.Value = ValidationHelper.GetString(ParameterFactory.GetParameterValue("MUTABAKAT_RAPOR_ID"));

            //HdnReConciliationId.Value = QueryHelper.GetString("ReconciliationId");

            //var ufFactory = new TuUserFactory();
            //_userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

            //if (!string.IsNullOrEmpty(HdnReConciliationId.Value))
            //{
            //    GetReconciliationData(ValidationHelper.GetGuid(HdnReConciliationId.Value));
            //}
        }

        protected void GetReConciliationClick(object sender, AjaxEventArgs e)
        {
            this.result = ReConciliationFactory.Instance.ReconciliateUptBankTotals(new_StartDate.Value.Value, new_EndDate.Value.Value);
            GrdTotalReConciliation.DataSource = this.result;
            GrdTotalReConciliation.DataBind();
        }

        protected void ExportToExcel(object sender, AjaxEventArgs e)
        {
            var n = string.Format("Mutabakat_{0:yyyy_MM_dd_hh_mm_ss}.xls", DateTime.Now);
            Export.ExportDownloadData(result, n);
        }

        private void TranslateMessage()
        {
            //GetReConciliation.Text = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_GET_AB_DATA");
        }

        protected void Process(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)GrdTotalReConciliation.SelectionModel[0]);
            string reference = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].REFERANS);
            lblTransaction.Clear();
            lblTransaction.SetValue(string.Format(@"<a href=""../../Operation/TransactionDetail.aspx?Reference={0}"">{0}</a>", reference));
            windowOpenReceipt.Show();
        }
    }
}
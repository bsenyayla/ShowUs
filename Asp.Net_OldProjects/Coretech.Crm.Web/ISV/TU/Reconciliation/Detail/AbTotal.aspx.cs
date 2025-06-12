using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Transfer;
using TuFactory.Object.User;
using TuFactory.TuUser;
using System.Data;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_AbTotal : BasePage
    {
        private TuUserApproval _userApproval = null;

        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

        protected void Page_Load(object sender, EventArgs e)
        {
            TranslateMessage();
            HdnReportId.Value = ValidationHelper.GetString(ParameterFactory.GetParameterValue("MUTABAKAT_RAPOR_ID"));

            HdnReConciliationId.Value = QueryHelper.GetString("ReconciliationId");

            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

            if (!string.IsNullOrEmpty(HdnReConciliationId.Value))
            {
                GetReconciliationData(ValidationHelper.GetGuid(HdnReConciliationId.Value));
            }
        }



        private void GetReconciliationData(Guid ReconciliationId)
        {
            DataTable dt = ReConciliationFactory.Instance.ReconciliateTotals(ReconciliationId);
            //DataTable dt = new DataTable();

            //dt.Columns.Add("TrType");
            //dt.Columns.Add("TuTlCount");
            //dt.Columns.Add("TuTlAmount");
            //dt.Columns.Add("AbTlCount");
            //dt.Columns.Add("AbTlAmount");

            //dt.Columns.Add("TuEurCount");
            //dt.Columns.Add("TuEurAmount");
            //dt.Columns.Add("AbEurCount");
            //dt.Columns.Add("AbEurAmount");

            //dt.Columns.Add("TuUsdCount");
            //dt.Columns.Add("TuUsdAmount");
            //dt.Columns.Add("AbUsdCount");
            //dt.Columns.Add("AbUsdAmount");


            //DataRow dr = dt.NewRow();

            //dr["TrType"] = "Toplam Gönderim";
            //dr["TuTlCount"] = "5";
            //dr["TuTlAmount"] = "3750 TL";
            //dr["AbTlCount"] = "6";
            //dr["AbTlAmount"] = "3800 TL";

            //dr["TuEurCount"] = "8";
            //dr["TuEurAmount"] = "3750 EUR";
            //dr["AbEurCount"] = "6";
            //dr["AbEurAmount"] = "3800 EUR";

            //dr["TuUsdCount"] = "5";
            //dr["TuUsdAmount"] = "3750 USD";
            //dr["AbUsdCount"] = "6";
            //dr["AbUsdAmount"] = "3800 USD";

            //dt.Rows.Add(dr);

            //dr = dt.NewRow();

            //dr["TrType"] = "Toplam Ödeme";
            //dr["TuTlCount"] = "5";
            //dr["TuTlAmount"] = "3750 TL";
            //dr["AbTlCount"] = "6";
            //dr["AbTlAmount"] = "3800 TL";

            //dr["TuEurCount"] = "8";
            //dr["TuEurAmount"] = "3750 EUR";
            //dr["AbEurCount"] = "6";
            //dr["AbEurAmount"] = "3800 EUR";

            //dr["TuUsdCount"] = "5";
            //dr["TuUsdAmount"] = "3750 USD";
            //dr["AbUsdCount"] = "6";
            //dr["AbUsdAmount"] = "3800 USD";

            //dt.Rows.Add(dr);
            //dr = dt.NewRow();

            //dr["TrType"] = "Toplam İade";
            //dr["TuTlCount"] = "5";
            //dr["TuTlAmount"] = "3750 TL";
            //dr["AbTlCount"] = "6";
            //dr["AbTlAmount"] = "3800 TL";

            //dr["TuEurCount"] = "8";
            //dr["TuEurAmount"] = "3750 EUR";
            //dr["AbEurCount"] = "6";
            //dr["AbEurAmount"] = "3800 EUR";

            //dr["TuUsdCount"] = "5";
            //dr["TuUsdAmount"] = "3750 USD";
            //dr["AbUsdCount"] = "6";
            //dr["AbUsdAmount"] = "3800 USD";

            //dt.Rows.Add(dr);
            //dr = dt.NewRow();

            //dr["TrType"] = "Toplam İade Bekleyen";
            //dr["TuTlCount"] = "5";
            //dr["TuTlAmount"] = "3750 TL";
            //dr["AbTlCount"] = "6";
            //dr["AbTlAmount"] = "3800 TL";

            //dr["TuEurCount"] = "8";
            //dr["TuEurAmount"] = "3750 EUR";
            //dr["AbEurCount"] = "6";
            //dr["AbEurAmount"] = "3800 EUR";

            //dr["TuUsdCount"] = "5";
            //dr["TuUsdAmount"] = "3750 USD";
            //dr["AbUsdCount"] = "6";
            //dr["AbUsdAmount"] = "3800 USD";

            //dt.Rows.Add(dr);

            //dr = dt.NewRow();

            //dr["TrType"] = "Toplam İptal";
            //dr["TuTlCount"] = "5";
            //dr["TuTlAmount"] = "3750 TL";
            //dr["AbTlCount"] = "6";
            //dr["AbTlAmount"] = "3800 TL";

            //dr["TuEurCount"] = "8";
            //dr["TuEurAmount"] = "3750 EUR";
            //dr["AbEurCount"] = "6";
            //dr["AbEurAmount"] = "3800 EUR";

            //dr["TuUsdCount"] = "5";
            //dr["TuUsdAmount"] = "3750 USD";
            //dr["AbUsdCount"] = "6";
            //dr["AbUsdAmount"] = "3800 USD";

            //dt.Rows.Add(dr);

            GrdTotalReConciliation.DataSource = dt;
            GrdTotalReConciliation.DataBind();
        }

        private void TranslateMessage()
        {
            //GetReConciliation.Text = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_GET_AB_DATA");

        }
    }
}
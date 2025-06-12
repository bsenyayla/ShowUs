using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Transfer;
using TuFactory.Object.User;
using TuFactory.TuUser;
using System.Data;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Ab : BasePage
    {
        private TuUserApproval _userApproval = null;

        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        
        private void TranslateMessage()
        {
            GetReConciliation.Text = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_GET_AB_DATA");
            Button1.Text = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_REPORT");
        }
        
        protected void Page_Load(object sender, EventArgs e)
        {
            TranslateMessage();
            HdnReportId.Value = ValidationHelper.GetString(ParameterFactory.GetParameterValue("MUTABAKAT_RAPOR_ID"));

            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

        }
        protected void Process(object sender, AjaxEventArgs e)
        {
            //var xx = new TuException() {ErrorMessage = "dsadsa"};
            //xx .Show();
            var degerler = ((RowSelectionModel)GrdReConciliation.SelectionModel[0]);
            if (degerler != null && degerler.SelectedRows != null)
            {

                try
                {
                    var reconciliationOperationHistoryId = ValidationHelper.GetGuid(degerler.SelectedRows[0].RECONCILIATIONOPERATIONHISTORYID);
                    var processid = ValidationHelper.GetInteger(degerler.SelectedRows[0].PROCESSID);
                    var transferId = ValidationHelper.GetString(degerler.SelectedRows[0].TRANSFERID);
                    var paymentid = ValidationHelper.GetString(degerler.SelectedRows[0].PAYMENTID);
                    var refundpaymentid = ValidationHelper.GetString(degerler.SelectedRows[0].REFUNDPAYMENTID);
                    var tuDurum = ValidationHelper.GetString(degerler.SelectedRows[0].TU_DURUM);
                    var tuIslemturu = ValidationHelper.GetString(degerler.SelectedRows[0].TU_ISLEMTURU);
                    var turef = ValidationHelper.GetString(degerler.SelectedRows[0].TRANSFER_TU_REF);
                    var bankaislemno = ValidationHelper.GetString(degerler.SelectedRows[0].BANKA_ISLEM_NO);

                    ReConciliationFactory.Instance.ReConciliate(reconciliationOperationHistoryId, processid, transferId, paymentid, refundpaymentid, tuDurum, tuIslemturu, turef, bankaislemno);
                    msg.Show("", ". ", " İşlem başarı ile tamamlandı. İşlemin listeden kalkması için mutabakat servisini tekrar güncelleyebilirsiniz.");

                }
                catch (TuException exc)
                {
                    exc.Show();
                }
                catch (Exception ex)
                {
                }
            }
        }
        protected void DeleteProcess(object sender, AjaxEventArgs e)
        {
            //var xx = new TuException() {ErrorMessage = "dsadsa"};
            //xx .Show();
            var degerler = ((RowSelectionModel)GrdReConciliation.SelectionModel[0]);
            if (degerler != null && degerler.SelectedRows != null)
            {

                try
                {
                    var ReconciliationOperationHistoryId = ValidationHelper.GetGuid(degerler.SelectedRows[0].RECONCILIATIONOPERATIONHISTORYID);

                    ReConciliationFactory.Instance.DeleteReConciliate(ReconciliationOperationHistoryId);


                    msg.Show("", ". ", "Kayıt Kaldırma işlemi başarı ile tamamlandı. İşlemin listeden kalkması için mutabakat servisini tekrar güncelleyebilirsiniz.");

                }
                catch (TuException exc)
                {
                    exc.Show();
                }
                catch (Exception ex)
                {
                }
            }
        }

        protected void GetReConciliationClick(object sender, AjaxEventArgs e)
        {
            var gd = Guid.NewGuid();
            /*Yeni bir Guid degeri alinir ve Reconciliation datasi olarak yaratilir.*/
            
            HdnReConciliationId.SetValue(gd.ToString());
            
            try
            {
                ReConciliationFactory.Instance.GetReconciliationData(gd);
            }
            catch (TuException exc)
            {

                exc.Show();
            }

            var dt = ReConciliationFactory.Instance.ExecReConciliation(gd);

            if (!_userApproval.ReferenceCanBeSeen)
            {
                DataTable maskedData = new DataTable();
                maskedData = dt.Clone();

                foreach (DataRow item in dt.Rows)
                {
                    string tu_Ref = item.Field<string>("TRANSFER_TU_REF");
                    var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref);  //string.Concat(tu_ref.Substring(0, 3), "".PadRight(10, 'X'));

                    item["TRANSFER_TU_REF"] = masked_tu_ref;
                    item["TU_REF"] = masked_tu_ref;

                    maskedData.ImportRow(item);
                }

                GrdReConciliation.DataSource = maskedData;
                GrdReConciliation.DataBind();
            }
            else
            {
                GrdReConciliation.DataSource = dt;
                GrdReConciliation.DataBind();
            }
        }
    }
}
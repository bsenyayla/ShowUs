using Coretech.Crm.Web.UI.RefleX;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_GsmPaymentReconcliation : BasePage
    {
        /*
        private TuUserApproval _userApproval = null;

        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        protected void BtnActionClick(object sender, AjaxEventArgs e)
        {
            if (!string.IsNullOrEmpty(HdnChTransferId.Value) && !string.IsNullOrEmpty(HdnActionId.Value))
            {
                try
                {
                    //ReConciliationFactory.Instance.Reconcilate3Rd(ValidationHelper.GetGuid(HdnChTransferId.Value), ValidationHelper.GetInteger(HdnActionId.Value, 0));
                    //msg.Show("", ". ", " İşlem başarı ile tamamlandı. İşlemin listeden kalkması için mutabakat servisini tekrar güncelleyebilirsiniz.");
                }
                catch (TuException exc)
                {
                    exc.Show();
                }
                catch (Exception ex)
                {
                    msg.Show("", ex.Message);
                }
            }
        }

        protected void GetReConciliationClick(object sender, AjaxEventArgs e)
        {
            GsmTransactionService service = new GsmTransactionService();

            List<TransactionListItem> list = service.GetTransactionList("TRNSFTO", (DateTime)new_StartDate.Value, (DateTime)new_EndDate.Value);

            GrdReConciliation.DataSource = list;
            GrdReConciliation.DataBind();

        }

        protected void Page_Load(object sender, EventArgs e)
        {
            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);

            if (!RefleX.IsAjxPostback)
            {
                TranslateMessage();
                new_StartDate.Value = DateTime.Now;
                new_EndDate.Value = DateTime.Now;
            }

        }

        private void TranslateMessage()
        {
            GetReConciliation.Text = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_GET_AB_DATA");
        }

        //protected void DeleteProcess(object sender, AjaxEventArgs e)
        //{
        //    //var xx = new TuException() {ErrorMessage = "dsadsa"};
        //    //xx .Show();
        //    var degerler = ((RowSelectionModel)GrdReConciliation.SelectionModel[0]);
        //    if (degerler != null && degerler.SelectedRows != null)
        //    {

        //        try
        //        {
        //            var ReconciliationOperationHistoryId = ValidationHelper.GetGuid(degerler.SelectedRows[0].RECONCILIATIONOPERATIONHISTORYID);
        //            var rf = new ReConciliationFactory();
        //            rf.DeleteReConciliate(ReconciliationOperationHistoryId);


        //            msg.Show("", ". ", "Kayıt Kaldırma işlemi başarı ile tamamlandı. İşlemin listeden kalkması için mutabakat servisini tekrar güncelleyebilirsiniz.");

        //        }
        //        catch (TuException exc)
        //        {
        //            exc.Show();
        //        }
        //        catch (Exception ex)
        //        {
        //        }
        //    }
        //}
        */
    }
}
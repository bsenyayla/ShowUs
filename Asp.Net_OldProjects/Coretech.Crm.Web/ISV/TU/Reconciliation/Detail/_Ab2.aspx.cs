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
using System.Text;
using TuFactory.Reconciliation;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Ab2 : BasePage
    {
        private TuUserApproval _userApproval = null;

        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

        protected void Page_Load(object sender, EventArgs e)
        {
            TranslateMessage();
            HdnReportId.Value = ValidationHelper.GetString(ParameterFactory.GetParameterValue("MUTABAKAT_RAPOR_ID"));

            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
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

            bool isBatchRun = false;
            Guid ReConciliationId = Guid.Empty;
            DateTime ReConciliationDate = new DateTime();

            DataTable rdt = ReConciliationFactory.Instance.GetLastReconcliation();
            if (rdt.Rows.Count > 0)
            {
                ReConciliationId = ValidationHelper.GetGuid(rdt.Rows[0]["New_ReConciliationId"]);
                ReConciliationDate = ValidationHelper.GetDate(rdt.Rows[0]["CreatedOn"]);

                if (ReConciliationId != Guid.Empty && ReConciliationDate.Date == DateTime.Now.Date)
                {
                    isBatchRun = true;
                }

                if (isBatchRun)
                {
                    ReConciliationFactory.Instance.GetExternalReConciliation(ReConciliationId);

                    var dt = ReConciliationFactory.Instance.ExecReConciliation(ReConciliationId);

                    if (!_userApproval.ReferenceCanBeSeen)
                    {
                        DataTable maskedData = new DataTable();
                        maskedData = dt.Clone();

                        foreach (DataRow item in dt.Rows)
                        {
                            string tu_Ref = item.Field<string>("TRANSFER_TU_REF");
                            var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref);

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
                    return;
                }
            }
            

            if (!isBatchRun)
            {
                var gd = Guid.NewGuid();

                /*Yeni bir Guid degeri alinir ve Reconciliation datasi olarak yaratilir.*/
                HdnReConciliationId.SetValue(gd.ToString());
                try
                {
                    ReConciliationFactory.Instance.GetReconciliationData(gd);
                    ReConciliationFactory.Instance.GetExternalReConciliation(gd);

                    var dt = ReConciliationFactory.Instance.ExecReConciliation(gd);

                    //var exdt = rf.ExecExternalReConciliation(gd);
                    //dt.Merge(exdt);

                    if (!_userApproval.ReferenceCanBeSeen)
                    {
                        DataTable maskedData = new DataTable();
                        maskedData = dt.Clone();

                        foreach (DataRow item in dt.Rows)
                        {
                            string tu_Ref = item.Field<string>("TRANSFER_TU_REF");
                            var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref);

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
                catch (TuException ex)
                {
                    ex.Show();
                }
            }





            
        }

        protected void Process(object sender, AjaxEventArgs e)
        {
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
                    var tuIslemkodu = ValidationHelper.GetString(degerler.SelectedRows[0].TU_ISLEMKODU);
                    var tuIslemturu = ValidationHelper.GetString(degerler.SelectedRows[0].TU_ISLEMTURU);
                    var turef = ValidationHelper.GetString(degerler.SelectedRows[0].MASTER_TRANSFER_TU_REF);
                    var bankaislemno = ValidationHelper.GetString(degerler.SelectedRows[0].BANKA_ISLEM_NO);

                    ReconciliationResult result = ReConciliationFactory.Instance.ReConciliate(reconciliationOperationHistoryId, processid, transferId, paymentid, refundpaymentid, tuDurum, tuIslemkodu, tuIslemturu, turef, bankaislemno);
                    if (result.Status.RESPONSE == WsStatus.response.Success)
                    {
                        msg.Show("", ". ", " Mutabakat servisi çalıştırılmıştır. İşlem durumunu görüntülemek için mutabakat servisini tekrar güncelleyebilirsiniz.");
                    }
                    else
                    {
                        msg.Show("", ". ", result.Status.RESPONSE_DATA);
                    }

                }
                catch (TuException exc)
                {
                    exc.Show();
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
        }

        protected void ShowDetail(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)GrdReConciliation.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                msg.Height = 500;
                msg.Width = 500;
                StringBuilder builder = new StringBuilder();
                string innerhtml = string.Empty;

                string tuIslemkodu = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].TU_ISLEMKODU);
                string TuRef = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].MASTER_TRANSFER_TU_REF);
                if (TuRef.Equals(string.Empty))
                {
                    TuRef = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].BANKA_ISLEM_NO);
                }

                DataTable dt = ReConciliationFactory.Instance.GetExternalReConciliationDetail(TuRef, tuIslemkodu);
                if (dt.Rows.Count > 0)
                {
                    innerhtml += "<table>";
                    innerhtml += "<tr><td><b>Mutabakatsız İşlem Bazlı Hareketler</b></td></tr>";
                    innerhtml += "<tr><td>&nbsp</td></tr>";

                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        innerhtml +=
                            "<tr><td><b>Referans No   :</b> " + dt.Rows[i]["ReferenceNo"].ToString() + "</td></tr>" +
                            "<tr><td><b>Gönderen Hesap:</b> " + dt.Rows[i]["new_SenderAccountIdName"].ToString() + "</td></tr>" +
                            "<tr><td><b>Gönderen Tutar:</b> " + dt.Rows[i]["new_Amount"].ToString() + "</td></tr>" +
                            "<tr><td><b>Gönderen Tutar Döviz Cinsi:</b> " + dt.Rows[i]["new_SenderAccountCurrencyIdName"].ToString() + "</td></tr>" +
                            "<tr><td><b>Alıcı Hesap   :</b> " + dt.Rows[i]["new_RecipientAccountIdName"].ToString() + "</td></tr>" +
                            "<tr><td><b>Alıcı Tutar   :</b> " + dt.Rows[i]["new_TransferedAmount"].ToString() + "</td></tr>" +
                            "<tr><td><b>Alıcı Tutar Döviz Cinsi:</b> " + dt.Rows[i]["new_RecipientAccountCurrencyIdName"].ToString() + "</td></tr>" +
                            "<tr><td><b>Banka İşlem No:</b> " + dt.Rows[i]["new_BankTransactionNumber"].ToString() + "</td></tr>" +
                            "<tr><td><b>İşlem Açıklaması:</b> " + dt.Rows[i]["new_Description"].ToString() + "</td></tr>";

                        innerhtml += "<tr><td>&nbsp</td></tr>";
                    }

                    innerhtml += "</table>";

                    msg.Show("", "", innerhtml);
                    return;
                }
                else
                {
                    msg.Show("", "", "Kayda ait gösterilebilecek bir detay yoktur.");
                    return;
                }
            }
        }

        private void TranslateMessage()
        {
            GetReConciliation.Text = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_GET_AB_DATA");
            Button1.Text = CrmLabel.TranslateMessage("CRM.NEW_RECONCILIATION_REPORT");
            btnAbTotal.Text = "Mutabakat Liste Toplamları";
        }

        protected void btnShowTotal(object sender, AjaxEventArgs e)
        {
            QScript("ShowTotalWindow('" + HdnReConciliationId.Value + "');");
            //Page.Response.Redirect(Page.ResolveClientUrl("~/ISV/TU/Reconciliation/Detail/AbTotal.aspx"));
        }


    }
}
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.CustomApproval;
using TuFactory.Object;
using TuFactory.Reconciliation;
using TuFactory.Reconciliation.Objects;
using TuFactory.Reconciliation.Objects.Logo;
using TuFactory.Transfer;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Detail_PreAccounting : BasePage
    {
        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                dStartDate.Value = DateTime.Today;
                dEndDate.Value = DateTime.Today;
            }
        }

        protected void GetReConciliationClick(object sender, AjaxEventArgs e)
        {
            GetReconcliationData();
        }

        private void GetReconcliationData()
        {
            if (dStartDate.Value.HasValue && dEndDate.Value.HasValue)
            {
                GrdReConciliation.DataSource = PreAccountingReconciliationFactory.Instance.GetPreAccountingReconciliationData(ReconcliationType.PreAccounting, dStartDate.Value.Value, dEndDate.Value.Value);
                GrdReConciliation.DataBind();
            }
            else
            {
                MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                msg.Show("", "", " Lütfen tarih seçiniz.");
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
                msg.Show("", "", ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].StatusDescriptionDetail));
                return;
            }
        }

        protected void Process(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)GrdReConciliation.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                try
                {
                    PreAccountingReconciliationStatus status = (PreAccountingReconciliationStatus)ValidationHelper.GetInteger(rowSelectionModel.SelectedRows[0].Status);
                    string transactionType = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].TransactionType);
                    string reference = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].Reference);


                    if (!PreAccountingReconciliationFactory.Instance.CheckPreAccountingQueue(reference, transactionType))
                    {
                        MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                        msg1.Show("", "", "İlgili işlem mutabakat için kuyrukta bekliyor, kuyruktan ilerletilmeden aksiyon alamazsınız!");
                        return;
                    }

                    switch (status)
                    {
                        case PreAccountingReconciliationStatus.TR_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.TRC_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.PY_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.PYC_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.RP_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.RPC_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.RT_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.RTC_HESAP_HAREKETI_OLUSMAYAN_KAYIT:

                        case PreAccountingReconciliationStatus.GSM_TR_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.GSM_TRC_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.GSM_PY_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.GSM_PYC_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.CD_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.CW_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.AD_HESAP_HAREKETI_OLUSMAYAN_KAYIT:
                        case PreAccountingReconciliationStatus.AW_HESAP_HAREKETI_OLUSMAYAN_KAYIT:

                            string operationType = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].OperationType);
                            if (!string.IsNullOrEmpty(reference) && !string.IsNullOrEmpty(operationType))
                            {
                                PreAccountingReconciliationFactory.Instance.HistoryReconciliate(reference, operationType);
                                msg.Show("", ". ", " İşlem başarı ile tamamlandı.");
                                GetReconcliationData();
                            }
                            else
                            {
                                MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                                msg1.Show("", "", "İlgili işlemde eksik bir bilgi var, lütfen sistem yöneticinizle görüşün.");
                            }

                            break;

                        case PreAccountingReconciliationStatus.BILINMEYEN_MUTABAKAT:
                            pnlDetail.LoadUrl(string.Format("/ISV/TU/Reconciliation/Detail/ManualPreaccountingDetail.aspx?reference={0}&transactionType={1}", reference, transactionType));
                            windowOpenReceipt.Show();
                            //MessageBox msg2 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                            //msg2.Show("", "", "İlgili işlemler için mutabakat çalıştıramazsınız! Sistem yöneticinizle görüşün. ");
                            break;
                        default:
                            break;
                    }
                }
                catch (TuException exc)
                {
                    exc.Show();
                }
                catch (Exception ex)
                {
                    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                    msg.Show("", "", "İşlem sırasında hata oluştu, Lütfen daha sonra tekrar deneyiniz." + " Hata:" + ex.Message);
                }
            }
        }
    }
}
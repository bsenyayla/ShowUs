using AjaxPro;
using Coretech.Crm.Factory;
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
using TuFactory.AccountTransactions;
using TuFactory.LogoTiger.Objects;
using TuFactory.Object;
using TuFactory.Reconciliation.Objects;
using TuFactory.Reconciliation.Objects.OnlineUpt;
using TuFactory.Transfer;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Detail_OnlineUPT : BasePage
    {
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
            if (dStartDate.Value.HasValue && dEndDate.Value.HasValue)
            {
                string onlineUptCorporationCode = App.Params.GetConfigKeyValue("ONLINEUPT_CORPORATION_CODE");

                var dt = OnlineUPTReconciliationFactory.Instance.GetOnlineUPTReconciliationData(ReconcliationType.OnlineUpt, onlineUptCorporationCode, dStartDate.Value.Value, dEndDate.Value.Value.AddDays(1));
                if (dt != null)
                {
                    GrdReConciliation.DataSource = dt;
                    GrdReConciliation.DataBind();
                }

            }
            else
            {
                MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                msg.Show("", "", " Lütfen tarih seçiniz.");
            }
        }

        protected void Process(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)GrdReConciliation.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                try
                {
                    string transactionType = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].TransactionType);
                    if (transactionType == "TRANSFER")
                    {
                        string uptReferenceNo = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].UptReference);
                        OnlineUptReconciliationStatus status = (OnlineUptReconciliationStatus)ValidationHelper.GetInteger(rowSelectionModel.SelectedRows[0].ReconciliationStatus);

                        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information, Height = 200, Width = 500 };

                        bool reload = false;

                        switch (status)
                        {
                            case OnlineUptReconciliationStatus.BILINMEYEN_UPT_STATUSU: //OK
                                msg.Show("", ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].ReconciliationStatusDescription) + " Mutabakatsızlığın çözümü için işlem havuzları kontrol edilmelidir.");
                                break;

                            case OnlineUptReconciliationStatus.BILINMEYEN_ONLINEUPT_STATUSU: //OK
                                msg.Show("", ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].ReconciliationStatusDescription) + " Mutabakatsızlığın çözümü için BT ekibi ile irtibata geçiniz.");
                                break;

                            case OnlineUptReconciliationStatus.UPTDE_OLAN_ONLINEUPTDE_OLMAYAN_TRANSFER: //OK
                                msg.Show("", "İşlem; UPT'de bulunmakta, ancak Online UPT'de bulunmamaktadır. Mutabakatsızlığın çözümü için BT ekibi ile irtibata geçiniz.");
                                break;

                            case OnlineUptReconciliationStatus.UPTDE_OLMAYAN_ONLINEUPTDE_OLAN_TRANSFER: //OK
                                msg.Show("", "İşlem; Online UPT'de bulunmakta, ancak UPT'de bulunmamaktadır. Mutabakatsızlığın çözümü için BT ekibi ile irtibata geçiniz.");
                                break;

                            case OnlineUptReconciliationStatus.UPTDE_TAMAMLANDI_ONLINEUPTDE_IPTAL_OLAN_TRANSFER: //OK
                                OnlineUPTReconciliationFactory.Instance.CancelUptTransfer(uptReferenceNo);
                                reload = true;
                                msg.Show("", "UPT işlemi iptal edilmiştir.");
                                break;

                            case OnlineUptReconciliationStatus.UPTDE_IPTAL_ONLINEUPTDE_TAMAMLANDI_OLAN_TRANSFER: //OK
                                OnlineUPTReconciliationFactory.Instance.CancelOnlineUptTransfer(uptReferenceNo, false);
                                reload = true;
                                msg.Show("", "Online UPT işlemi iptal edilmiştir.");
                                break;

                            case OnlineUptReconciliationStatus.UPTDE_IADE_ONLINEUPTDE_TAMAMLANDI_OLAN_TRANSFER: //OK
                                OnlineUPTReconciliationFactory.Instance.CancelOnlineUptTransfer(uptReferenceNo, true);
                                reload = true;
                                msg.Show("", "Online UPT işlemi iptal edilmiştir.");
                                break;

                            case OnlineUptReconciliationStatus.UPTDE_TAMAMLANMAMIS_ONLINEUPTDE_TAMAMLANDI_OLAN_TRANSFER: //OK
                                OnlineUPTReconciliationFactory.Instance.SendRequestConfirmUptTransfer(uptReferenceNo);
                                reload = true;
                                msg.Show("", "UPT işlemi tamamlanmıştır.");
                                break;

                            //case OnlineUPTReconciliationFactory.OnlineUptReconciliationStatus.UPTDE_TAMAMLANDI_ONLINEUPTDE_OLMAYAN_TRANSFER:
                            //    reFac.CancelUptTransfer(uptReferenceNo);
                            //    reload = true;
                            //    msg.Show("", "UPT işlemi iptal edilmiştir.");
                            //    break;

                            default:
                                break;
                        }

                        if (reload)
                        {
                            GetReConciliationClick(null, null);
                        }
                    }
                    else
                    {
                        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                        msg.Show("", "", "Nakit yatırma & çekme ve üyeler arası transfer ile ilgili mutabakat çalışması devam ediyor.");
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

        protected void DontShowAgain(object sender, AjaxEventArgs e)
        {

            //OnlineUPTReconciliationFactory reFac = new OnlineUPTReconciliationFactory();
            var rowSelectionModel = ((RowSelectionModel)GrdReConciliation.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                try
                {
                    string uptReferenceNo = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].UptReference);
                    string onlineUptReferenceNo = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].OnlineUptReference);

                    if (!String.IsNullOrEmpty(uptReferenceNo))
                    {
                        OnlineUPTReconciliationFactory.Instance.DontShowTransactionAgain(uptReferenceNo, ReconcliationType.OnlineUpt.GetHashCode(), NotShownSource.UPT.GetHashCode());
                    }
                    else
                    {
                        OnlineUPTReconciliationFactory.Instance.DontShowTransactionAgain(onlineUptReferenceNo, ReconcliationType.OnlineUpt.GetHashCode(), NotShownSource.External.GetHashCode());
                    }

                    GetReConciliationClick(null, null);
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


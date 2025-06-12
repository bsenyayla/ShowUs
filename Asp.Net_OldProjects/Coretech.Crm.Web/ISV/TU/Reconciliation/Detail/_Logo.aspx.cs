using Coretech.Crm.Factory;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using TuFactory.AccountTransactions;
using TuFactory.Object;
using TuFactory.Reconciliation.Objects;
using TuFactory.Reconciliation.Objects.Logo;
using TuFactory.Transfer;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Detail_Logo : BasePage
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
                if (App.Params.CurrentUser.SystemUserId == ValidationHelper.GetGuid("00000000-AAAA-BBBB-CCCC-000000000001"))
                {
                    GrdReConciliation.DataSource = LogoReconciliationFactory.Instance.GetLogoReconciliationData(ReconcliationType.Logo, dStartDate.Value.Value, dEndDate.Value.Value, true);
                }
                else
                {
                    GrdReConciliation.DataSource = LogoReconciliationFactory.Instance.GetLogoReconciliationData(ReconcliationType.Logo, dStartDate.Value.Value, dEndDate.Value.Value, false);
                }

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
                    LogoReconciliationStatus status = (LogoReconciliationStatus)ValidationHelper.GetInteger(rowSelectionModel.SelectedRows[0].Status);

                    if (status == LogoReconciliationStatus.MUTABIK_KAYIT)
                    {
                        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                        msg.Show("", "", " İşlem Logo'ya aktarılmış, mutabakat çalıştırmaya gerek yok.");
                        return;
                    }
                    else if (status == LogoReconciliationStatus.VERITABANINDA_OLMAYAN_LOGODA_OLAN_KAYIT)
                    {
                        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                        msg.Show("", "", " Veritabanında  olmayan bir işlem. Logo kontrol edilmelidir.");
                        return;
                    }

                    else
                    {
                        string reference = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].Reference);

                        if (AccountTransactionFactory.Instance.UndoLogoTransactionFromUpt(reference))
                        {
                            MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };

                            var response = LogoReconciliationFactory.Instance.LogoReconciliate(reference);
                            if (response.Status.ResponseCode == "000")
                            {
                                msg.Show("", "", " Mutabakat sağlanması için Logo’ya bilgi geçildi.");
                                return;
                            }
                            else
                            {
                                msg.Show("", "", "İşlem sırasında hata oluştu, Lütfen daha sonra tekrar deneyiniz." + " Hata:" + response.Status.ResponseCode);
                                return;
                            }
                        }
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

            //ReConciliationFactory reFac = new ReConciliationFactory();
            var rowSelectionModel = ((RowSelectionModel)GrdReConciliation.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                try
                {
                    string referenceNo = ValidationHelper.GetString(rowSelectionModel.SelectedRows[0].Reference);
                    LogoReconciliationStatus status = (LogoReconciliationStatus)ValidationHelper.GetInteger(rowSelectionModel.SelectedRows[0].Status);

                    if (status == LogoReconciliationStatus.VERITABANINDA_OLMAYAN_LOGODA_OLAN_KAYIT)
                    {
                        LogoReconciliationFactory.Instance.DontShowTransactionAgain(referenceNo, ReconcliationType.Logo.GetHashCode(), NotShownSource.External.GetHashCode());
                    }
                    else
                    {
                        LogoReconciliationFactory.Instance.DontShowTransactionAgain(referenceNo, ReconcliationType.Logo.GetHashCode(), NotShownSource.UPT.GetHashCode());
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

        protected void btnShowTotal(object sender, AjaxEventArgs e)
        {
            QScript("ShowTotalWindow('" + dStartDate.Value + "', '" + dEndDate.Value + "');");
            //Page.Response.Redirect(Page.ResolveClientUrl("~/ISV/TU/Reconciliation/Detail/AbTotal.aspx"));
        }
    }
}


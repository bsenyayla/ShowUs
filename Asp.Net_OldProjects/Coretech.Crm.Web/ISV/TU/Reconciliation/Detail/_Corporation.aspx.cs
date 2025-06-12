using System;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Transfer;
using Coretech.Crm.Factory;
using System.Data;
using TuFactory.TuUser;
using TuFactory.Object.User;
using TuFactory.Reconciliation.Objects;
using System.Collections.Generic;
using TuFactory.Integrationd3rdLayer.Object;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Web.UI.RefleX.View;
using Coretech.Crm.Objects.Db;
using TuFactory.Reconciliation.ReconciliationManager;
using Upt.GsmPayment.Reconciliation;

namespace Reconciliation.Detail
{
    public partial class Reconciliation_Corporation : BasePage
    {
        private TuUserApproval _userApproval = null;

        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        protected void BtnActionClick(object sender, AjaxEventArgs e)
        {
            if (!string.IsNullOrEmpty(HdnChTransferId.Value) && !string.IsNullOrEmpty(HdnActionId.Value))
            {
                try
                {
                    var integrationChannelType = new_IntegrationChannelId.SelectedItems[0]["IntegrationChannelType"];
                    var integratorCode = new_IntegrationChannelId.SelectedItems[0]["ExtCode"];

                    
                    if (integrationChannelType == "001")
                    {
                        TransferReturnType result = ReConciliationFactory.Instance.Reconcilate3Rd(ValidationHelper.GetGuid(HdnChTransferId.Value), ValidationHelper.GetInteger(HdnActionId.Value, 0));
                        if (result != null && result.OutputStatus != null)
                        {
                            if (result.OutputStatus.RESPONSE == IntegrationStatus.response.Success)
                            {
                                msg.Show("", ". ", " İşlem başarı ile tamamlandı. İşlemin listeden kalkması için mutabakat servisini tekrar güncelleyebilirsiniz.");
                            }
                            else
                            {
                                msg.Show("", "Hata ", result.OutputStatus.RESPONSE_DATA);
                            }
                        }
                    }
                    else if (integrationChannelType == "002")
                    {
                        GsmReconciliationFactory gsmfactory = new GsmReconciliationFactory();
                        gsmfactory.Reconcilate3Rd(ValidationHelper.GetGuid(HdnChTransferId.Value), ValidationHelper.GetInteger(HdnActionId.Value, 0));

                        msg.Show("", ". ", " İşlem başarı ile tamamlandı. İşlemin listeden kalkması için mutabakat servisini tekrar güncelleyebilirsiniz.");
                    }                  


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
            var gd = Guid.NewGuid();
            /*Yeni bir Guid degeri alinir ve Reconciliation datasi olarak yaratilir.*/
            HdnReConciliationId.SetValue(gd.ToString());

            var integrationChannelType = new_IntegrationChannelId.SelectedItems[0]["IntegrationChannelType"];
            var integratorCode = new_IntegrationChannelId.SelectedItems[0]["ExtCode"];


            List<ChReconciliationProcessDetail> resultList = null;
            if (integrationChannelType == "001")
            {
                resultList = ReConciliationFactory.Instance.ChReconciliate(integrationChannelType, gd, new_StartDate.Value, new_EndDate.Value, ValidationHelper.GetGuid(new_IntegrationChannelId.Value), ChReconciliationProcessType.Ekran);

            }
            else if (integrationChannelType == "002")/**/
            {
                GsmReconciliationFactory gsmfactory = new GsmReconciliationFactory();
                resultList = gsmfactory.GsmReconciliation(gd, (DateTime)new_StartDate.Value, (DateTime)new_EndDate.Value, integratorCode, ChReconciliationProcessType.Ekran);
            }



            if (!_userApproval.ReferenceCanBeSeen)
            {
                foreach (ChReconciliationProcessDetail item in resultList)
                {
                    var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(item.TRANSFER_TU_REF);
                    item.TRANSFER_TU_REF = masked_tu_ref;
                    item.TU_REF = masked_tu_ref;
                }

                GrdReConciliation.DataSource = resultList;
                GrdReConciliation.DataBind();
            }
            else
            {
                GrdReConciliation.DataSource = resultList;
                GrdReConciliation.DataBind();
            }




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
            btnGetBatchReconciliation.Text = "Batch Datalarını getir.";
        }



        protected void GetBatchData(object sender, AjaxEventArgs e)
        {

            Guid IntegrationChannelId = ValidationHelper.GetGuid(new_IntegrationChannelId.Value);

            Guid gd = ReConciliationFactory.Instance.GetBatchChReconcliation(IntegrationChannelId, (DateTime)new_StartDate.Value);

            if (gd != Guid.Empty)
            {

                DataTable ReconciliationDt = ReConciliationFactory.Instance.Get3RdteReconciliationList(gd, App.Params.CurrentUser.SystemUserId);

                List<ChReconciliationDetail> chReconciliationList = ReConciliationFactory.Instance.GetChReconciliationDetailList(ReconciliationDt);

                List<TuOperation> uptReconciliationList = ReConciliationFactory.Instance.GetUptReconciliationList(ReConciliationFactory.Instance.Get3RdteReconciliationUptList(gd, App.Params.CurrentUser.SystemUserId));

                List<ChReconciliationProcessDetail> resultList = ReConciliationFactory.Instance.ProcessChUptReconciliation(chReconciliationList, uptReconciliationList);

                if (!_userApproval.ReferenceCanBeSeen)
                {
                    foreach (ChReconciliationProcessDetail item in resultList)
                    {
                        var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(item.TRANSFER_TU_REF);
                        item.TRANSFER_TU_REF = masked_tu_ref;
                        item.TU_REF = masked_tu_ref;
                    }

                    GrdReConciliation.DataSource = resultList;
                    GrdReConciliation.DataBind();
                }
                else
                {
                    GrdReConciliation.DataSource = resultList;
                    GrdReConciliation.DataBind();
                }







                //var dt = ReConciliationFactory.Instance.Exec3RdteReconciliation(gd, App.Params.CurrentUser.SystemUserId);

                //if (!_userApproval.ReferenceCanBeSeen)
                //{
                //    DataTable maskedData = new DataTable();
                //    maskedData = dt.Clone();

                //    foreach (DataRow item in dt.Rows)
                //    {
                //        string tu_Ref = item.Field<string>("TRANSFER_TU_REF");
                //        var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref);  //string.Concat(tu_ref.Substring(0, 3), "".PadRight(10, 'X'));

                //        item["TRANSFER_TU_REF"] = masked_tu_ref;
                //        item["TU_REF"] = masked_tu_ref;

                //        maskedData.ImportRow(item);
                //    }

                //    GrdReConciliation.DataSource = maskedData;
                //    GrdReConciliation.DataBind();
                //}
                //else
                //{
                //    GrdReConciliation.DataSource = dt;
                //    GrdReConciliation.DataBind();
                //}
            }
            else
            {
                msg.Show("", ". ", "Batchin çalıştırdığı bir mutabakat bulunamadı.");
            }


        }


        protected void new_IntegrationChannelLoad(object sender, AjaxEventArgs e)
        {


            string strSql = @"Select New_IntegrationChannelId AS ID,New_IntegrationChannelId,ChannelName AS VALUE,ChannelName,new_ExtCode AS ExtCode, '001' AS IntegrationChannelType 
From vNew_IntegrationChannel (NOLOCK) WHERE DeletionStateCode=0
UNION ALL
Select New_GsmEntegrationChannelId AS ID,New_GsmEntegrationChannelId AS New_IntegrationChannelId,EntegratorName AS VALUE,EntegratorName AS ChannelName ,new_ExtCode AS ExtCode,'002' AS IntegrationChanneltype 
From vNew_GsmEntegrationChannel(NOLOCK) WHERE DeletionStateCode=0";
            const string sort = "";
            var viewqueryid = ViewFactory.GetViewIdbyUniqueName("IntegrationChannelComboView");
            var gpc = new GridPanelCreater();
            int cnt;
            var start = new_IntegrationChannelId.Start();
            var limit = new_IntegrationChannelId.Limit();
            var spList = new List<CrmSqlParameter>();




            var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
            new_IntegrationChannelId.TotalCount = cnt;
            new_IntegrationChannelId.DataSource = t;
            new_IntegrationChannelId.DataBind();

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
    }
}
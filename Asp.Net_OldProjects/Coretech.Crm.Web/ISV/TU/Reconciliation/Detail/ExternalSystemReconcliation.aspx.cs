using System;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using TuFactory.Transfer;
using System.Data;
using System.Web.UI;
using RefleXFrameWork;
using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using TuFactory.ExtensionManager;
using TuFactory.ExtensionManager.Services;
using TuFactory.Reconciliation;
using System.Collections.Generic;
using TuFactory.ExtensionManager.Model.Request;
using TuFactory.ExtensionManager.Model.Base;
using System.Linq;
using TuFactory.Exceptions;
using TuFactory.ExtensionManager.Model;
using TuFactory.ExtensionManager.Database;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;

namespace Reconciliation.Detail
{
    public partial class ExternalSystemReconcliation : BasePage
    {
        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                new_StartDate.Value = DateTime.Now;
            }


        }

        private string table = @"<table id='table-style'>
<thead>
    <tr>
        <th data-field='state' data-checkbox='true'></th>
        <th data-field='id'>Item ID</th>
    </tr>
    <tr>
        <td>
            <input type='checkbox' />
        </td>
        <td>5</td>
    </tr>
    <tr>
        <td>
            <input type='checkbox' />
        </td>
        <td>15</td>
    </tr>
    <tr>
        <td>
            <input type='checkbox' />
        </td>
        <td>10</td>
    </tr>
</thead>
</table>
";

        protected void Process(object sender, AjaxEventArgs e)
        {
            var responseBase = new ResponseBase();
            var degerler = ((RowSelectionModel)gpReconclationData.SelectionModel[0]);

            if (degerler != null && degerler.SelectedRows != null)
            {
                try
                {
                    var methodName = ValidationHelper.GetString(degerler.SelectedRows[0].MethodName);
                    var recordId = ValidationHelper.GetGuid(degerler.SelectedRows[0].RecordId);
                    var transactionTypeCode = (TransactionTypeCodeEnum)Enum.Parse(typeof(TransactionTypeCodeEnum), degerler.SelectedRows[0].TransactionTypeCode);
                    var externalSystemCashTransactionId = ValidationHelper.GetGuid(degerler.SelectedRows[0].ExternalSystemCashTransactionId);

                    if (new ExtensionDb().IsTransactionReconclationWasDone(externalSystemCashTransactionId))
                    {
                        msg.Show("", ". ", "Bu işlem için aksiyon aldınız. Yeniden mutabakat çalıştırdığınızda listeden kalkacatır.");
                        return;
                    }

                    switch (transactionTypeCode)
                    {
                        case TransactionTypeCodeEnum.TR:
                            if (ValidationHelper.GetString(methodName) == "Reversal")
                            {
                                var transferTR = new TuFactory.Business.Data.Transfer().GetTransfer(recordId, false);
                                var transactionServiceTR = new TransactionService<TuFactory.Domain.Transfer>(TransactionTypeCodeEnum.TR, CustomerAmountDirectionEnum._Positive, TuFactory.ExtensionManager.Model.Operation.Reversal);
                                responseBase = transactionServiceTR.ReconclationReversal(transferTR);
                                break;
                            }
                            else
                            {
                                var transferTR = new TuFactory.Business.Data.Transfer().GetTransfer(recordId, false);
                                var transactionServiceTR = new TransactionService<TuFactory.Domain.Transfer>(TransactionTypeCodeEnum.TR, CustomerAmountDirectionEnum._Negative, TuFactory.ExtensionManager.Model.Operation.BeforeTransactionConfirm);
                                responseBase = transactionServiceTR.ReconclationConfirm(transferTR);
                                break;
                            }
                        case TransactionTypeCodeEnum.TRC:
                            var transferTRC = new TuFactory.Business.Data.Transfer().GetTransfer(recordId, false);
                            var transactionServiceTRC = new TransactionService<TuFactory.Domain.Transfer>(TransactionTypeCodeEnum.TRC, CustomerAmountDirectionEnum._Positive, TuFactory.ExtensionManager.Model.Operation.TransferCancelConfirm);
                            responseBase = transactionServiceTRC.ReconclationConfirm(transferTRC);
                            break;
                        case TransactionTypeCodeEnum.PY:
                            var transferPY = new TuFactory.Business.Data.Payment().GetPayment(recordId, true);
                            var transactionServicePY = new TransactionService<TuFactory.Domain.Payment>(TransactionTypeCodeEnum.PY, CustomerAmountDirectionEnum._Positive, TuFactory.ExtensionManager.Model.Operation.Payment);
                            responseBase = transactionServicePY.ReconclationConfirm(transferPY);
                            break;
                        case TransactionTypeCodeEnum.PYC:
                            var transferPYC = new TuFactory.Business.Data.Payment().GetPayment(recordId, true);
                            var transactionServicePYC = new TransactionService<TuFactory.Domain.Payment>(TransactionTypeCodeEnum.PYC, CustomerAmountDirectionEnum._Negative, TuFactory.ExtensionManager.Model.Operation.PaymentCancelConfirm);
                            responseBase = transactionServicePYC.ReconclationConfirm(transferPYC);
                            break;
                        case TransactionTypeCodeEnum.RP:
                            var transferRP = new TuFactory.Business.Data.Refund().GetRefundPayment(recordId);
                            var transactionServiceRP = new TransactionService<TuFactory.Domain.Refund.RefundPayment>(TransactionTypeCodeEnum.RP, CustomerAmountDirectionEnum._Positive, TuFactory.ExtensionManager.Model.Operation.RefundPaymentConfirm);
                            responseBase = transactionServiceRP.ReconclationConfirm(transferRP);
                            break;
                        case TransactionTypeCodeEnum.RPC:
                            var transferRPC = new TuFactory.Business.Data.Refund().GetRefundPayment(recordId);
                            var transactionServiceRPC = new TransactionService<TuFactory.Domain.Refund.RefundPayment>(TransactionTypeCodeEnum.RPC, CustomerAmountDirectionEnum._Negative, TuFactory.ExtensionManager.Model.Operation.RefundPaymentCancel);
                            responseBase = transactionServiceRPC.ReconclationConfirm(transferRPC);
                            break;
                        case TransactionTypeCodeEnum.RT:
                            break;
                        case TransactionTypeCodeEnum.RTC:
                            break;
                        default:
                            break;
                    }

                    if (responseBase.ReturnCode)
                    {
                        msg.Show("", ". ", "İşlem başarıyla tamamlandı.");

                    }
                    else
                    {
                        msg.Show("", ". ", "HATA," + responseBase.ReturnCode + " - " + responseBase.ReturnData);
                    }
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

        protected void Delete(object sender, AjaxEventArgs e)
        {
            var responseBase = new ResponseBase();
            var degerler = ((RowSelectionModel)gpReconclationData.SelectionModel[0]);

            if (degerler != null && degerler.SelectedRows != null)
            {
                try
                {
                    var methodName = ValidationHelper.GetString(degerler.SelectedRows[0].MethodName);
                    var recordId = ValidationHelper.GetGuid(degerler.SelectedRows[0].RecordId);
                    var transactionTypeCode = (TransactionTypeCodeEnum)Enum.Parse(typeof(TransactionTypeCodeEnum), degerler.SelectedRows[0].TransactionTypeCode);
                    var externalSystemCashTransactionId = ValidationHelper.GetGuid(degerler.SelectedRows[0].ExternalSystemCashTransactionId);

                    if (new ExtensionDb().IsTransactionReconclationWasDone(externalSystemCashTransactionId))
                    {
                        msg.Show("", ". ", "Bu işlem için aksiyon aldınız. Yeniden mutabakat çalıştırdığınızda listeden kalkacatır.");
                        return;
                    }

                    var sd = new StaticData();
                    sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
                    sd.AddParameter("ExternalSystemCashTransactionId", DbType.Guid, externalSystemCashTransactionId);
                    sd.ExecuteNonQuerySp("spExtensionManagerReconclationCustomUpdateStatus");

                    msg.Show("", ". ", "Bu işlem kontrollü bir şekilde kaldırılmıştır.");
                    QScript("var element = document.getElementById('row" + degerler.SelectedRows[0].RowNumber + "gpReconclationData');element.remove();");
                    return;

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

        protected void Continue(object sender, AjaxEventArgs e)
        {
            var reconclationDb = new ReconclationDb();
            var reconcliationService = new ReconcliationService(TuFactory.ExtensionManager.Model.Operation.ReconclationClose);
            var data = reconcliationService.RunReconcliationClose(ValidationHelper.GetDate(new_StartDate.Value), ValidationHelper.GetGuid(new_OptionalCorporationId.Value));


            var isSuccess = reconclationDb.InsertReconclationClose(ValidationHelper.GetGuid(new_OptionalCorporationId.Value), ValidationHelper.GetDate(new_StartDate.Value), data.ReturnCode, data.ReturnData);
            if (isSuccess && data.ReturnCode)
            {
                QScript("alert('Mutabakat kapama işlemi başarılı bir şekilde tamamlandı.');return true;");
            }
            else
            {
                QScript("alert('Oopps! Mutabakat kapatma esnasında hata oluştu. :" + data.ReturnData + "');return true;");
            }
        }

        protected void RunReconcliationClose(object sender, AjaxEventArgs e)
        {
            var reconclationDb = new ReconclationDb();
            var result = reconclationDb.IsReconclationClose(ValidationHelper.GetDate(new_StartDate.Value), ValidationHelper.GetGuid(new_OptionalCorporationId.Value));

            if (result)
            {
                QScript("messagePanel.show();return true;");
            }
            else
            {
                var reconcliationService = new ReconcliationService(TuFactory.ExtensionManager.Model.Operation.ReconclationClose);
                var data = reconcliationService.RunReconcliationClose(ValidationHelper.GetDate(new_StartDate.Value), ValidationHelper.GetGuid(new_OptionalCorporationId.Value));


                var isSuccess = reconclationDb.InsertReconclationClose(ValidationHelper.GetGuid(new_OptionalCorporationId.Value), ValidationHelper.GetDate(new_StartDate.Value), data.ReturnCode, data.ReturnData);
                if (isSuccess && data.ReturnCode)
                {
                    QScript("alert('Mutabakat kapama işlemi başarılı bir şekilde tamamlandı.');return true;");
                }
                else
                {
                    QScript("alert('Oopps! Mutabakat kapatma esnasında hata oluştu. :" + data.ReturnData + "');return true;");
                }
            }
        }

        protected void RunReconcliation(object sender, AjaxEventArgs e)
        {

            if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WITH_EXTENSION_MANAGER")) == true)
            {
                bool isCorporationAvailable = new ExtensionDb().GetExtensionMappingByCorporationId(ValidationHelper.GetGuid(new_OptionalCorporationId.Value));
                if (isCorporationAvailable == true)
                {
                    var dbReconclationData = new ExtensionManagerFactory().GetReconclationData(ValidationHelper.GetDate(new_StartDate.Value), ValidationHelper.GetGuid(new_OptionalCorporationId.Value));
                    var uptReconclationDataList = PrepareUptReconclationData(dbReconclationData);

                    if (uptReconclationDataList.Count == 0)
                    {
                        MessageBox messageBox = new MessageBox();
                        messageBox.Height = 300;
                        messageBox.Show("UPT tarafında mutabakat datası bulunamadı.");
                        return;
                    }

                    var reconcliationService = new ReconcliationService(TuFactory.ExtensionManager.Model.Operation.ReconclationDetail);
                    var responseReconcliation = reconcliationService.RunReconcliation(ValidationHelper.GetDate(new_StartDate.Value), ValidationHelper.GetGuid(new_OptionalCorporationId.Value));

                    if (responseReconcliation.ReturnCode)
                    {
                        PrepareData(((ReconclationBase)responseReconcliation).transaction, uptReconclationDataList);
                    }
                    else
                    {
                        MessageBox messageBox = new MessageBox();
                        messageBox.Show(string.Format("{0} - {1}", responseReconcliation.ReturnCode.ToString(), responseReconcliation.ReturnData));
                    }
                }
            }
        }



        private List<UptReconclationData> PrepareUptReconclationData(DataTable dt)
        {
            var UptReconclationDataList = new List<UptReconclationData>();

            if (dt.Rows.Count > 0)
            {
                foreach (DataRow item in dt.Rows)
                {
                    var uptReconclationData = new UptReconclationData();

                    uptReconclationData.CustomerAmount = ValidationHelper.GetDecimal(item["new_CustomerAmount"], 0);
                    uptReconclationData.CustomerAmountCurrency = ValidationHelper.GetString(item["CustomerAmountCurrency"]);
                    uptReconclationData.ExternalCode1 = ValidationHelper.GetString(item["new_ExternalCode1"]);
                    if (ValidationHelper.GetDecimal(item["new_CustomerAmount2"], 0) > 0)
                    {
                        uptReconclationData.CustomerAmount2 = ValidationHelper.GetDecimal(item["new_CustomerAmount2"], 0);
                        uptReconclationData.CustomerAmount2Currency = ValidationHelper.GetString(item["CustomerAmount2Currency"]);
                        uptReconclationData.ExternalCode2 = ValidationHelper.GetString(item["new_ExternalCode2"]);
                    }
                    uptReconclationData.CustomerAmountDirection = ValidationHelper.GetInteger(item["new_CustomerAmountDirection"], 0);
                    uptReconclationData.ExternalSystemCashTransactionId = ValidationHelper.GetGuid(item["New_ExternalSystemCashTransactionId"]);
                    uptReconclationData.MethodName = ValidationHelper.GetString(item["new_MethodName"]);
                    uptReconclationData.TransactionTypeCode = ValidationHelper.GetString(item["new_TransactionTypeCode"]);
                    uptReconclationData.TransferIdName = ValidationHelper.GetString(item["new_TransferIdName"]);
                    uptReconclationData.IsServiceSuccess = ValidationHelper.GetBoolean(item["new_IsServiceSuccess"]);
                    uptReconclationData.CreatedOn = ValidationHelper.GetString(item["CreatedOn"]);
                    uptReconclationData.TransferId = ValidationHelper.GetGuid(item["new_TransferId"]);
                    uptReconclationData.RecordId = ValidationHelper.GetGuid(item["new_RecordId"]);
                    uptReconclationData.CorporationId = ValidationHelper.GetGuid(item["new_CorporationId"]);
                    uptReconclationData.Comment = ValidationHelper.GetString(item["new_Comment"]);
                    UptReconclationDataList.Add(uptReconclationData);
                }

                // Reversal ile Payment özel durumunun ayrıştırılması
                var tempList = UptReconclationDataList;
                for (int i = 0; i < tempList.Count; i++)
                {
                    if (tempList[i].MethodName == "Reversal")
                    {
                        var data = (from tr in tempList
                                    where tr.MethodName == "BeforeTransactionConfirm" &&
                                          tr.TransferIdName == tempList[i].TransferIdName &&
                                          tr.TransactionTypeCode == tempList[i].TransactionTypeCode
                                    select tr).ToList<UptReconclationData>();

                        if (data.Count > 0)
                        {
                            UptReconclationDataList.Remove(data[0]);
                            continue;
                        }
                    }

                    if (tempList[i].MethodName == "PaymentCancelConfirm")
                    {
                        var data = (from tr in tempList
                                    where tr.MethodName == "Payment" &&
                                          tr.TransferIdName == tempList[i].TransferIdName &&
                                          tr.TransactionTypeCode == tempList[i].TransactionTypeCode
                                    select tr).ToList<UptReconclationData>();

                        if (data.Count > 0)
                        {
                            UptReconclationDataList.Remove(data[0]);
                            continue;
                        }
                    }
                }

            }

            return UptReconclationDataList;
        }

        private void PrepareData(List<TransactionIn> serviceReconclationDataList, List<UptReconclationData> uptReconclationDataList)
        {
            List<UptReconclationData> ActionList = new List<UptReconclationData>();
            int i = 0;
            //Upt Islem Listesi
            foreach (UptReconclationData reconclationData in uptReconclationDataList)
            {
                var matches = (from item in serviceReconclationDataList
                               where item.TransactionReference == reconclationData.TransferIdName
                               && item.TransactionTypeCode == reconclationData.TransactionTypeCode
                               select item).ToList<TransactionIn>();

                if (matches.Count > 0)
                {

                    // Kurum başarılı çağırılan reversallar için data dönmüyor. Eğer data dönmüşse bu transfer datasıdır. Bizde reversal çağırılması gerekir
                    if (reconclationData.MethodName == "Reversal")
                    {
                        reconclationData.Comment += Environment.NewLine + "İşlemin Reversal'ı hatalı ya da daha önce çağırılmamış";
                        reconclationData.RowNumber = i;
                        ActionList.Add(reconclationData);
                        continue;
                    }

                    // Böyle bir case mantıken oluşmamalı. Oluşma durumu şu olur servis bize success donup external refleri dönmez ise.
                    // Böyle bir durumda biz. External Reflerimizi update ediyoruz kasamıza ve mutabakat listesine eklemiyoruz.
                    if (reconclationData.IsServiceSuccess == true && reconclationData.ExternalCode1 == "" ||
                        reconclationData.IsServiceSuccess == true && reconclationData.ExternalCode1 == "" && reconclationData.ExternalCode2 == "")
                    {
                        matches[0].TransferId = reconclationData.TransferId;
                        matches[0].CorporationId = reconclationData.CorporationId;
                        matches[0].CustomerAmountDirection = reconclationData.CustomerAmountDirection == 0 ? "-" : "+";

                        var transactionBase = new TransactionBase();
                        transactionBase.ReturnCode = true;
                        transactionBase.ReturnData += Environment.NewLine + "Kurumda işlem bulundu fakat bizim tarafta referans kod bilgisi boş.";
                        transactionBase.transaction = matches[0];

                        new ExtensionSystemCashTransactionDb().Update(transactionBase, true);
                        continue;
                    }

                    // Böyle bir case mantıken oluşmamalı. Oluşma durumu şu olur servis bize success donup external refleri dönmez ise.
                    // Böyle bir durumda biz. External Reflerimizi update ediyoruz kasamıza ve mutabakat listesine eklemiyoruz.
                    if (reconclationData.IsServiceSuccess == false && reconclationData.ExternalCode1 == "" ||
                        reconclationData.IsServiceSuccess == false && reconclationData.ExternalCode1 == "" && reconclationData.ExternalCode2 == "")
                    {
                        reconclationData.Comment += Environment.NewLine + "Kuruma bildirim esnasında hata oluştu.";
                        ActionList.Add(reconclationData);
                        reconclationData.RowNumber = i;
                        continue;
                    }
                }
                else
                {
                    if (reconclationData.MethodName != "Reversal")
                    {
                        reconclationData.Comment += Environment.NewLine + "İşlem karşı kurumda bulunamadı.";
                        ActionList.Add(reconclationData);
                        reconclationData.RowNumber = i;
                        continue;
                    }
                }
                i++;
            }

            gpReconclationData.DataSource = ActionList;
            gpReconclationData.DataBind();
        }

        private void BindCombo(CrmComboComp combo, StaticData sd, string strSql)
        {
            var start = combo.Start() - 1;
            var limit = combo.Limit();

            if (start < 0)
            {
                start = 0;
            }

            BindCombo(combo, sd, strSql, start, limit);
        }

        private void BindCombo(CrmComboComp combo, StaticData sd, string strSql, int start, int limit)
        {
            var t = sd.ReturnDataset(strSql).Tables[0];

            //var start = combo.Start() - 1;
            //var limit = combo.Limit();

            DataTable t2 = t.Clone();

            var end = start + limit > t.Rows.Count ? t.Rows.Count : start + limit;

            for (int i = start; i < end; i++)
            {
                DataRow dr = t2.NewRow();
                dr.ItemArray = t.Rows[i].ItemArray;
                t2.Rows.Add(dr);
            }

            combo.TotalCount = t.Rows.Count;
            combo.DataSource = t2;
            combo.DataBind();
        }

        protected void new_OptionalCountryLoad(object sender, AjaxEventArgs e)
        {
            string strSql = @"Select DISTINCT C.New_CorporationId ID, C.CorporationName VALUE,C.CorporationName ,C.new_CorporationCode
from TBL_EXTENSION_MAPPING (NoLock) CID
Inner Join vNew_Corporation (NoLock) C
ON CID.CORPORATION_ID = c.New_CorporationId
Where C.DeletionStateCode = 0";

            StaticData sd = new StaticData();

            var like = new_OptionalCorporationId.Query();
            if (!string.IsNullOrEmpty(like))
            {
                strSql += @" AND CorporationName LIKE '%' + @CorporationName + '%' ";
                sd.AddParameter("CorporationName", DbType.String, like);
            }

            strSql += " ORDER BY CorporationName";

            BindCombo(new_OptionalCorporationId, sd, strSql);
        }

        public class UptReconclationData
        {
            public int RowNumber { get; set; }
            public Guid ExternalSystemCashTransactionId { get; set; }
            public string TransferIdName { get; set; }
            public string TransactionTypeCode { get; set; }
            public int CustomerAmountDirection { get; set; }
            public decimal CustomerAmount { get; set; }
            public string CustomerAmountCurrency { get; set; }
            public string ExternalCode1 { get; set; }
            public decimal CustomerAmount2 { get; set; }
            public string CustomerAmount2Currency { get; set; }
            public string ExternalCode2 { get; set; }
            public string MethodName { get; set; }
            public bool IsServiceSuccess { get; set; }
            public string Comment { get; set; }
            public string CreatedOn { get; set; }
            /// <summary>
            /// Bunu grid üzerinde actionbutton property için ekledim
            /// </summary>
            public string Action { get; set; }
            public Guid TransferId { get; set; }
            /// <summary>
            /// EntityIdsi
            /// </summary>
            public Guid RecordId { get; set; }

            public Guid CorporationId { get; set; }
        }

        public class ReconclationData
        {
            public bool Status { get; set; }
            public string RecordIdName { get; set; }
            public string TransactionTypeCode { get; set; }
            public int CustomerAmountDirection { get; set; }
            public decimal CustomerAmount1 { get; set; }
            public string CustomerAmount1Currency { get; set; }
            public decimal CustomerAmount2 { get; set; }
            public string CustomerAmount2Currency { get; set; }
            public string MethodName { get; set; }
            public string ExternalReference { get; set; }


        }
    }
}
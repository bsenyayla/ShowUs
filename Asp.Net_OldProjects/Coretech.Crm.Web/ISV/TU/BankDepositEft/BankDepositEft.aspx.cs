using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.BankDepositEft;
using System.Globalization;
using Coretech.Crm.Factory;
using TuFactory.Integration3rd;
using TuFactory.Integrationd3rdLayer.Object;
using Coretech.Crm.Factory.Exporter;

public partial class BankDepositEft : BasePage
{

    private static DataTable _depositEft;
    protected void GetData(object sender, AjaxEventArgs e)
    {
        if (_depositEft != null)
            _depositEft.Dispose();
        _depositEft = new BankDepositEftFactory().GetBankDepositEftData(txtCorrespondentRef.Value, txtTransferTuRef.Value,
            ValidationHelper.GetDate(StartDate.Value), ValidationHelper.GetDate(EndDate.Value));
        gpBankDepositEft.DataSource = _depositEft;
        gpBankDepositEft.DataBind();
        gpBankDepositEft.TotalCount = _depositEft.Rows.Count;
    }

    protected void GridRowClickOnEvent(object sender, AjaxEventArgs e)
    {
        var transferTuRef = hdnSelectedId.Value;
        var correspondentRef = hdnCorrespondent.Value;
        if ((string.IsNullOrWhiteSpace(transferTuRef) && string.IsNullOrWhiteSpace(correspondentRef)))
        {
            new MessageBox { Width = 300, Height=150 }.Show("İlgili kayda ait referanslar oluşmamıştır.\nDetay görüntülenmeyecektir!");
            return;
        }
        using (DataTable dt = new BankDepositEftFactory().GetBankDepositEftDataSingleRow(correspondentRef, transferTuRef))
        {
            if (dt.Rows.Count < 1)
            {
                new MessageBox { Width = 300, Height = 150 }.Show("İlgili kayda ait gösterilecek bir detay kaydı yoktur!");
                return;
            }
            try
            {
                new_CorrespondentRef.Value = ValidationHelper.GetString(dt.Rows[0]["new_CorrespondentRef"]);
                new_CorrespondentRef.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_CorrespondentRef"]));

                new_Pin.Value = ValidationHelper.GetString(dt.Rows[0]["new_Pin"]);
                new_Pin.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_Pin"]));

                new_SenderName.Value = ValidationHelper.GetString(dt.Rows[0]["new_SenderName"]);
                new_SenderName.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_SenderName"]));

                new_SenderSurname.Value = ValidationHelper.GetString(dt.Rows[0]["new_SenderSurname"]);
                new_SenderSurname.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_SenderSurname"]));

                new_SenderIdType.Value = ValidationHelper.GetString(dt.Rows[0]["new_SenderIdType"]);
                new_SenderIdType.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_SenderIdType"]));

                new_SenderIdNo.Value = ValidationHelper.GetString(dt.Rows[0]["new_SenderIdNo"]);
                new_SenderIdNo.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_SenderIdNo"]));

                new_SenderCountryCode.Value = ValidationHelper.GetString(dt.Rows[0]["new_SenderCountryCode"]);
                new_SenderCountryCode.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_SenderCountryCode"]));

                new_SenderNationality.Value = ValidationHelper.GetString(dt.Rows[0]["new_SenderNationality"]);
                new_SenderNationality.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_SenderNationality"]));

                if (ValidationHelper.GetDate(dt.Rows[0]["new_SenderBirthdate"]) != DateTime.MinValue)
                {
                    CultureInfo ci = new CultureInfo(App.Params.CurrentUser.CultureCode);
                    DateTime myDate = new DateTime();
                    myDate = ValidationHelper.GetDate(dt.Rows[0]["new_SenderBirthdate"]);
                    // Bunu Componentin mask yapısından dolayı yaptım. 
                    var datePattern = ci.DateTimeFormat.ShortDatePattern.Replace("d", "dd").Replace("M", "MM").Replace("MMMM", "MM").Replace("dddd", "dd");
                    string us = myDate.Date.ToString(datePattern, ci);

                    new_SenderBirthdate.SetValue(us);
                    new_SenderBirthdate.SetIValue(ValidationHelper.GetDate(dt.Rows[0]["new_SenderBirthdate"]));
                }

                new_Message.Value = ValidationHelper.GetString(dt.Rows[0]["new_Message"]);
                new_Message.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_Message"]));

                new_BeneficiaryName.Value = ValidationHelper.GetString(dt.Rows[0]["new_BeneficiaryName"]);
                new_BeneficiaryName.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_BeneficiaryName"]));

                new_BeneficiarySurname.Value = ValidationHelper.GetString(dt.Rows[0]["new_BeneficiarySurname"]);
                new_BeneficiarySurname.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_BeneficiarySurname"]));

                new_BeneficiaryCountryCode.Value = ValidationHelper.GetString(dt.Rows[0]["new_BeneficiaryCountryCode"]);
                new_BeneficiaryCountryCode.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_BeneficiaryCountryCode"]));

                new_BeneficiaryIban.Value = ValidationHelper.GetString(dt.Rows[0]["new_BeneficiaryIban"]);
                new_BeneficiaryIban.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_BeneficiaryIban"]));

                new_Amount.Items[0].SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_Amount"]));
                new_Amount.Items[1].SetIValue(ValidationHelper.GetGuid(dt.Rows[0]["new_AmountCurrency"]));

                new_Status.Value = ValidationHelper.GetString(dt.Rows[0]["new_Status"]);
                new_Status.SetIValue(ValidationHelper.GetString(dt.Rows[0]["new_Status"]));

                RecordId.Value = ValidationHelper.GetString(dt.Rows[0]["new_TransferId"]);

                new_TransferStatusId.SetIValue(dt.Rows[0]["new_ConfirmStatus"]);
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.BankDepositEft.BankDepositEft.GridRowClickOnEvent");
                throw ex;
            }
        }
        QScript("DetailPage.show();");  
    }

    protected void RowDoubleClickOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            GridRowClickOnEvent(sender, e);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.BankDepositEft.BankDepositEft.RowDoubleClickOnEvent");
            throw ex;
        }
    }

    protected void Retry(object sender, AjaxEventArgs e)
    {
        #region OldCode
        //int requeuedProccessCount = 0;
        //if (_depositEft != null)
        //{
        //    for (int i = 0; i < _depositEft.Rows.Count; i++)
        //    {
        //        if (!(ValidationHelper.GetString(_depositEft.Rows[i]["new_Status"], string.Empty) == BankDepositEnums.BANKDEPOSIT_ERROR || ValidationHelper.GetString(_depositEft.Rows[i]["new_Status"], string.Empty) == BankDepositEnums.BANKDEPOSIT_RETRY))
        //            continue;
        //        var orderNo = ValidationHelper.GetString(_depositEft.Rows[i]["new_CorrespondentRef"], string.Empty);
        //        var transferId = ValidationHelper.GetGuid(_depositEft.Rows[i]["new_TransferId"], Guid.Empty);
        //        if (!string.IsNullOrWhiteSpace(orderNo))
        //        {
        //            try
        //            {
        //                /* Önceki eft işleminin filetransactionNuber bilgisi değiştirilerek set edildi. */
        //                //if (transferId != Guid.Empty)
        //                //new BankDepositEftFactory().UpdateFileTransactionNumberForBankDepositEft(transferId, orderNo);
        //                BankDepositManager.PaymentOrderQueue(orderNo);
        //                //BankDepositRepository.UpdatePaymentOrderStatus(orderNo, BankDepositEnums.BANKDEPOSIT_RETRY);
        //                requeuedProccessCount++;
        //            }
        //            catch (Exception ex)
        //            {
        //                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.BankDepositEft.Retry");
        //                throw ex;
        //            }
        //        }
        //    }
        //}
        //QScript("alert('" + ((requeuedProccessCount > 0) ? string.Format("{0} adet işlem tekrar denendi.", requeuedProccessCount) : "Uygun işlem bulunamadı!") + "');return true;");
        #endregion
        var selectedRows = ((RowSelectionModel)gpBankDepositEft.SelectionModel[0]).SelectedRows;
        if (selectedRows == null)
        {
            new MessageBox { Width = 300, Height = 150 }.Show("Lütfen tekrar denemek istediğiniz kayıtları seçiniz!");
            return;
        }
        var requeuedProccessCount = 0;
        for (int i = 0; i < selectedRows.Length; i++)
        {
            if (!(ValidationHelper.GetString(selectedRows[i]["new_Status"], string.Empty) == BankDepositEnums.BANKDEPOSIT_ERROR || ValidationHelper.GetString(selectedRows[i]["new_Status"], string.Empty) == BankDepositEnums.BANKDEPOSIT_RETRY))
                continue;
            var orderNo = ValidationHelper.GetString(selectedRows[i]["new_CorrespondentRef"], string.Empty);
            var transferId = ValidationHelper.GetGuid(selectedRows[i]["new_TransferId"], Guid.Empty);
            if (string.IsNullOrWhiteSpace(orderNo))
                continue;
            try
            {
                /* Önceki eft işleminin filetransactionNuber bilgisi değiştirilerek set edildi. */
                //if (transferId != Guid.Empty)
                //new BankDepositEftFactory().UpdateFileTransactionNumberForBankDepositEft(transferId, orderNo);
                BankDepositManager.PaymentOrderQueue(orderNo);
                requeuedProccessCount++;
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.BankDepositEft.Retry");
                throw ex;
            }
        }
        QScript("alert('" + ((requeuedProccessCount > 0) ? string.Format("{0} adet işlem tekrar denendi.", requeuedProccessCount) : "Uygun işlem bulunamadı!") + "');return true;");
    }

    protected void ExcelExport(object sender, AjaxEventArgs e)
    {
        if ((_depositEft != null) && (_depositEft.Rows.Count > 0))
        {
            var fileName = string.Format("BankDepositEft-Export-{0:yyyy-MM-dd_HH-mm-ss-tt}.xls", DateTime.Now);
            Export.ExportDownloadData(_depositEft, fileName);
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            StartDate.Value = DateTime.Now.Date;
            EndDate.Value = DateTime.Now.Date;
        }
    }
}

using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.CustomApproval;
using TuFactory.Object;

public partial class FreeAccounting_ManuelAbAccounting : CustomApprovalPage<ManualBankAccountingApproval>
{
    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
        }
        base.OnPreInit(e);
    }

    protected override void SetApprovalData()
    {
        ManualBankAccountingApproval item = base.Approval;

        TransferTuRef.Value = item.Reference;
        OperationType.SetValue(item.OperationTypeLabel);

        TransferTuRef.Disabled = true;
        OperationType.Disabled = true;
        btnControl.Visible = false;
        Button1.Visible = false;
        BtnControlClick(null, null);
    }    

    protected void Page_Load(object sender, EventArgs e)
    {
        DynamicSecurity dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_ReConciliation.GetHashCode(), null);
        if (!(dynamicSecurity.PrvWrite && dynamicSecurity.PrvCreate && dynamicSecurity.PrvDelete && dynamicSecurity.PrvAppend))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Reconciliation PrvCreate,PrvDelete,PrvWrite,PrvAppend");
        }

        if (!RefleX.IsAjxPostback)
        {
            string mode = QueryHelper.GetString("mode");
            if (mode.ToLower() != "approval")
            {
                TransferTuRef.Value = QueryHelper.GetString("reference");
            }
        }        
    }

    protected void BtnControlClick(object sender, EventArgs e)
    {
        var sd = new StaticData();

        var sort = GrdTransfer.ClientSorts();
        if (sort == null)
            sort = string.Empty;

        TransferId.Value = string.Empty;
        PaymentId.Value = string.Empty;
        RefundpaymentId.Value = string.Empty;
        TransferReference.Value = string.Empty;
        TransactionType.Value = string.Empty;


        string strSql = @"SELECT new_TransferId,new_PaymentId,new_RefundPaymentId,TransferTuRef AS TuRef,new_FileTransactionNumber AS FileTransactionNumber,new_ConfirmStatusName AS ConfirmStatusName,
                        new_BANKA_ISLEM_NO AS BankTransactionNumber,new_CorporationIDName AS CorporationName,CAST(t.CreatedOn AS DATE) AS CreatedOn,tt.new_ExtCode  AS TransactionTypeCode
                         FROM vNew_Transfer (NOLOCK) t 
						 INNER JOIN vNew_TransactionType tt ON tt.New_TransactionTypeId = t.new_TargetTransactionTypeID
						 WHERE TransferTuRef= @TransferTuRef";

        sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
        var ds = sd.ReturnDataset(strSql);

        GrdTransfer.DataSource = ds.Tables[0];
        GrdTransfer.DataBind();

        Guid transferId = ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_TransferId"]);
        Guid paymentId = ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_PaymentId"], Guid.Empty);
        Guid refudnpaymentId = ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["new_RefundPaymentId"], Guid.Empty);
        string transactionType = ValidationHelper.GetString(ds.Tables[0].Rows[0]["TransactionTypeCode"]);

        TransferId.Value = transferId.ToString();
        TransferId.SetValue(transferId.ToString());
        PaymentId.Value = paymentId.ToString();
        PaymentId.SetValue(paymentId.ToString());
        RefundpaymentId.Value = refudnpaymentId.ToString();
        RefundpaymentId.SetValue(refudnpaymentId.ToString());
        TransferReference.Value = TransferTuRef.Value;
        TransferReference.SetValue(TransferTuRef.Value);
        TransactionType.Value = transactionType;
        TransactionType.SetValue(transactionType);

        if (paymentId != Guid.Empty)
        {
            strSql = @"SELECT new_TransferId,new_PaymentId,new_TransferIDName AS TuRef,'' AS FileTransactionNumber,new_ConfirmStatusName AS ConfirmStatusName,
                        new_BANKA_ISLEM_NO AS BankTransactionNumber,new_PaidByCorporationName AS CorporationName,CAST(CreatedOn AS DATE) AS CreatedOn
                         FROM vNew_Payment (NOLOCK) WHERE new_PaymentId= @PaymentId";

            sd.ClearParameters();
            sd.AddParameter("PaymentId", DbType.Guid, paymentId);
            ds = sd.ReturnDataset(strSql);

            GrdPayment.DataSource = ds.Tables[0];
            GrdPayment.DataBind();
        }

        if (refudnpaymentId != Guid.Empty)
        {
            strSql = @"SELECT new_TransferId,new_RefundPaymentId,new_TransferIDName AS TuRef,'' AS FileTransactionNumber,new_ConfirmStatusIdName AS ConfirmStatusName,
                        new_BANKA_ISLEM_NO AS BankTransactionNumber,new_RefundByCorporationName AS CorporationName,CAST(CreatedOn AS DATE) AS CreatedOn
                         FROM vNew_RefundPayment (NOLOCK) WHERE new_RefundPaymentId= @RefundPaymentId";

            sd.ClearParameters();
            sd.AddParameter("RefundPaymentId", DbType.Guid, refudnpaymentId);
            ds = sd.ReturnDataset(strSql);

            GrpRefundPayment.DataSource = ds.Tables[0];
            GrpRefundPayment.DataBind();
        }
    }

    protected void BtnAccountClick(object sender, EventArgs e)
    {
        var operationTypeLabel = OperationType.Value;
        string islem = string.Empty;
        bool isCancel = false;
        Guid transactionId = Guid.Empty;

        if (string.IsNullOrEmpty(TransferId.Value))
        {
            MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
            msg1.Show("Uyarı", "Aksiyon alınacak işlem bulunamadı. ");
            return;
        }

        if (!string.IsNullOrEmpty(operationTypeLabel))
        {
            if (operationTypeLabel == "1" || operationTypeLabel == "4")
            {
                switch (TransactionType.Value)
                {
                    case "001":
                    case "011":
                    case "015":
                        islem = "G";
                        isCancel = operationTypeLabel == "1" ? false : true;
                        transactionId = ValidationHelper.GetGuid(TransferId.Value);
                        break;
                    case "002":
                    case "021":
                        islem = "G";
                        isCancel = operationTypeLabel == "1" ? false : true;
                        transactionId = ValidationHelper.GetGuid(TransferId.Value);

                        break;
                    case "003":
                        islem = "S";
                        isCancel = operationTypeLabel == "1" ? false : true;
                        transactionId = ValidationHelper.GetGuid(TransferId.Value);

                        break;
                    default:
                        break;
                }
            }
            else if (operationTypeLabel == "2" || operationTypeLabel == "5")
            {
                if (string.IsNullOrEmpty(PaymentId.Value))
                {
                    MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                    msg1.Show("Uyarı", "Aksiyon alınacak ödeme bulunamadı. ");
                    return;
                }

                islem = "O";
                isCancel = operationTypeLabel == "2" ? false : true;
                transactionId = ValidationHelper.GetGuid(PaymentId.Value);
            }
            else if (operationTypeLabel == "3" || operationTypeLabel == "6")
            {
                if (string.IsNullOrEmpty(RefundpaymentId.Value))
                {
                    MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                    msg1.Show("Uyarı", "Aksiyon alınacak iade ödeme bulunamadı. ");
                    return;
                }

                islem = "I";
                isCancel = operationTypeLabel == "3" ? false : true;
                transactionId = ValidationHelper.GetGuid(RefundpaymentId.Value);
            }
            try
            {
                if (!string.IsNullOrEmpty(islem) && !string.IsNullOrEmpty(TransferReference.Value) && transactionId != Guid.Empty)
                {
                    ManualBankAccountingApproval approval = new ManualBankAccountingApproval()
                    {
                        ApprovalKey = TransferReference.Value,
                        Reference = TransferReference.Value,
                        TransactionId = transactionId,
                        CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                        OperationType = islem,
                        OperationTypeLabel = operationTypeLabel,
                        TransactionType = TransactionType.Value,
                        IsCancel = isCancel
                    };

                    string saveRet = approval.Save();
                    if (string.IsNullOrEmpty(saveRet))
                    {
                        MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                        msg1.Show("", "", "İşleminiz onaya gönderildi.");
                        return;
                    }
                    else
                    {
                        MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                        msg1.Show(saveRet);
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
                msg1.Show("Hata", "İşlem sırasında hata oluştu. " + ex.Message);
                return;
            }
        }
        else
        {
            MessageBox msg1 = new MessageBox() { Modal = true, MessageType = EMessageType.Error };
            msg1.Show("", "", "İşlem tipi bilgisi doldurulmalıdır.");
            return;
        }
    }

    protected override void AfterApprove()
    {
        try
        {
            BtnControlClick(null, null);
        }
        catch
        { }
    }
}
using System;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Payment;
using TuFactory.Refund;

public partial class Payment_WelcomeTestQuestion : BasePage
{
    DynamicEntity _deTransfer = new DynamicEntity(TuEntityEnum.New_Transfer.GetHashCode());
    DynamicEntity _deSender = new DynamicEntity(TuEntityEnum.New_Sender.GetHashCode());
    MessageBox messageBox = new MessageBox();
    private string _confirmStatus;

    protected void Page_Load(object sender, EventArgs e)
    {
        messageBox.Modal = true;
        if (!RefleX.IsAjxPostback)
        {
            hdnTransferId.Value = QueryHelper.GetString("TransferId");
        }
        GetTransferData();

        /*Bu alan Her bir Request de calişacaği için Mantılı bir yerder.*/
        switch (_confirmStatus)
        {
            case TuConfirmStatus.GonderimTamamlandi:
                if (!RefleX.IsAjxPostback)
                {
                    new_RecipientName.FillDynamicEntityData(_deTransfer);
                    new_RecipientLastName.FillDynamicEntityData(_deTransfer);
                    new_SenderID.Value = ((Lookup) _deTransfer["new_SenderID"]).name;
                    FillData();
                }
                break;
            case TuConfirmStatus.GOnderimIadeSurecinde:
                FillSenderData();
                break;
            default:
                Alert(CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_STATUS_ERROR"));
                QScript("top.R.WindowMng.getActiveWindow().hide();");
                return;
        }
    }
    
    void GetTransferData()
    {
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        _deTransfer = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnTransferId.Value), new string[] { "new_TestQuestionID", "new_TestQuestionReply", "TransferTuRef", "new_RecipientName", "new_RecipientLastName", "new_SenderID" });
        var cf = new ConfirmFactory();
        _confirmStatus = cf.GetTransactionStatus(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnTransferId.Value));
    }

    void FillSenderData()
    {
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        _deSender = df.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), _deTransfer.GetLookupValue("new_SenderID"), new string[] { "new_Name", "new_LastName", "New_SenderId" });

        new_RecipientName.Value = _deSender.GetStringValue("new_Name");
        new_RecipientLastName.Value = _deSender.GetStringValue("new_LastName");

        new_TestQuestion.Visible = false;
        new_TestAnswer.Visible = false;
        hdnUseTestQuestion.Value = "0";
    }

    void FillData()
    {
        var gd = _deTransfer.GetLookupValue("new_TestQuestionID");
        if (gd != Guid.Empty)
        {
            new_TestQuestion.Value = gd.ToString();
            hdnUseTestQuestion.Value = "1";

        }
        else
        {
            new_TestQuestion.Visible = false;
            new_TestAnswer.Visible = false;
            hdnUseTestQuestion.Value = "0";
        }
    }

    protected void BtnSaveNextOnClick(object sender, AjaxEventArgs e)
    {
        messageBox.Show("NOT IMPLEMENTED");

        //if (_confirmStatus == TuConfirmStatus.GonderimTamamlandi)
        //{
        //    var turef = _deTransfer.GetStringValue("TransferTuRef");
        //    var wpe = new WSPaymentRequest();
        //    wpe.TU_REFERANS = turef;
        //    wpe.TEST_SORU_CEVAP = new_TestAnswer.Value;
        //    var objTrans = new PaymentWSRequestFactory();
        //    var retVal = objTrans.PaymentRequestCheckTestQuestion(wpe); /* Ilk once Kaydi Check Edeceksin*/
        //    if (retVal.PaymentRequestStatus.RESPONSE == WsStatus.response.Error)
        //    {
        //        messageBox.Show(retVal.PaymentRequestStatus.RESPONSE_DATA);
        //        return;
        //    }


        //    var pf = new PaymentFactory();
        //    try
        //    {
        //        var paymentId = pf.ConvertTransfertoPayment(ValidationHelper.GetGuid(hdnTransferId.Value));
        //        if (paymentId == Guid.Empty)
        //        {
        //            messageBox.Show(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CREATE_ERROR"));
        //        }
        //        else
        //        {
        //            hdnPaymentId.SetValue(paymentId.ToString());

        //        }
        //    }
        //    catch (TuException ex)
        //    {
        //        messageBox.Show(CrmLabel.TranslateMessage(ex.ErrorMessage));

        //    }
        //}
        //else if (_confirmStatus == TuConfirmStatus.GOnderimIadeSurecinde)/*Iade islemlerinin yapilacaği yer*/
        //{
        //    var rf = new RefundFactory();
        //    try
        //    {
        //        var refundPaymentId = rf.CreateRefundPayment(ValidationHelper.GetGuid(hdnTransferId.Value),string.Empty, (int)TuChannelTypeEnum.Ekran);
        //        if (refundPaymentId == Guid.Empty)
        //        {
        //            messageBox.Show(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CREATE_ERROR"));
        //        }
        //        else
        //        {
        //            hdnrefundPaymentId.SetValue(refundPaymentId.ToString());

        //        }
        //    }
        //    catch (TuException ex)
        //    {
        //        messageBox.Show(CrmLabel.TranslateMessage(ex.ErrorMessage));

        //    }
            
        //}
    }

    private void TranslateMessage()
    {
        TEST_SORUSU.Title = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_TESTSORUSU_BASLIK");
        btnSaveNext.Text = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_BTN_NEXT");
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
        }
        base.OnPreInit(e);
    }
}
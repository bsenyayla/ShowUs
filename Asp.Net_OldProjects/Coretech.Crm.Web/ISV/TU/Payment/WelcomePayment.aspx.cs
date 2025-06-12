using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using Coretech.Crm.PluginData;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.Payment;
using TuFactory.Refund;
using TuFactory.TuUser;
using TuFactory.TransactionManagers.Payment;
using TuFactory.Business.Transfer;
using TuFactory.Data;
using TuFactory.Transfer;
using TuFactory.TransactionManagers.Refund.RefundPayment;
using TuFactory.Domain.Refund;
using TuFactory.TransactionManagers.Refund;

public partial class Payment_WelcomePayment : BasePage
{
    private Guid _newCorporationCountryId;
    private Guid _newCorporationId;
    private TuUserApproval _userApproval = null;
    MessageBox messageBox = new MessageBox();
    Postman postman = new Postman();
    DynamicEntity _deTransfer = new DynamicEntity(TuEntityEnum.New_Transfer.GetHashCode());


    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        ToolbarButtonCheck.Visible = _userApproval.CheckExternalTransfers;

        if (!RefleX.IsAjxPostback)
        {
            CreateViewGrid();
            FillLogInfo();

            //var ufFactory = new TuUserFactory();
            //var _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
            //ToolbarButtonCheck.Visible = _userApproval.CheckExternalTransfers;
        }
        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        var dt =
            sd.ReturnDataset(
                @"
select u.new_CorporationID,t.new_CountryID,u.new_OfficeID,t.new_IsUsedSecurityQuestion from vSystemUser u
inner join vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
inner join vNew_Country t on t.New_CountryId = c.new_CountryID
where SystemUserId = @SystemUserId
")
                .Tables[0];

        if (dt.Rows.Count > 0)
        {
            _newCorporationCountryId = ValidationHelper.GetGuid(dt.Rows[0]["new_CountryID"]);
            _newCorporationId = ValidationHelper.GetGuid(dt.Rows[0]["new_CorporationID"]);
            ValidationHelper.GetGuid(dt.Rows[0]["new_CorporationID"]);
            ValidationHelper.GetGuid(dt.Rows[0]["new_OfficeID"]);
            new_IsUsedSecurityQuestion.Value = dt.Rows[0]["new_IsUsedSecurityQuestion"].ToString();
        }


    }

    private string _confirmStatus;

    void GetTransferData()
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        _deTransfer = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnTransferId.Value), new string[] { "new_TestQuestionID", "new_TestQuestionReply", "TransferTuRef", "new_RecipientName", "new_RecipientLastName", "new_SenderID" });
        List<string> fields = new List<string>() { "new_RecipientName", "new_RecipientLastName" };
        _deTransfer = cryptor.DecryptFieldsInDynamicEntity(fields, _deTransfer);
        var cf = new ConfirmFactory();
        _confirmStatus = cf.GetTransactionStatus(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnTransferId.Value));
    }

    protected void ToolbarButtonCheckOnClick(object sender, AjaxEventArgs e)
    {

        var i3rd = new TuFactory.Integration3rd.Integration3Rd();
        string err;

        string referenceNumber = new_RefNumber.Value.Trim();

        if (!string.IsNullOrEmpty(referenceNumber))
        {
            /*Golden işlemleri için bazı refleri başında 00 ile gönderirlerse temizliyoruz 0 ları.*/
            if (referenceNumber.Length == 11 && referenceNumber.StartsWith("00"))
            {
                //referenceNumber = referenceNumber.Substring(2, referenceNumber.Length - 2);
                new_RefNumber.Value = referenceNumber;
            }

            string ownOfficeCode = new OfficeDb().GetUserOwnOfficeCode(App.Params.CurrentUser.SystemUserId);
            string msg;

            if (i3rd.CheckPayableTransfer(referenceNumber, ownOfficeCode, out err))
            {
                msg = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CAN_BE_MADE");
            }
            else
            {
                msg = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CANNOT_BE_MADE") + "<br />" + err;
            }

            postman.MessageList.Add(msg);
            messageBox.Height = postman.MessageBoxHeightCalculator();
            messageBox.Show(string.Empty, string.Empty, postman.ProcessMessage());

            //messageBox.Height = MessageBoxHeightCalculator(msg);
            //messageBox.Show(msg);
        }
        return;
    }

    protected void RowDblClickOnEvent(object sender, AjaxEventArgs e)
    {
        if (new_IsUsedSecurityQuestion.Value == "False")
        {
            GetTransferData();
            if (_confirmStatus == TuConfirmStatus.GonderimTamamlandi || _confirmStatus == TuConfirmStatus.GonderimOdemeOnProvizyon)
            {
                TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
                var df = new DynamicFactory(ERunInUser.SystemAdmin);
                _deTransfer = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnTransferId.Value), new string[] { "new_TestQuestionID", "new_TestQuestionReply", "TransferTuRef", "new_RecipientName", "new_RecipientLastName", "new_SenderID" });
                List<string> fields = new List<string>() { "new_RecipientName", "new_RecipientLastName" };
                _deTransfer = cryptor.DecryptFieldsInDynamicEntity(fields, _deTransfer);
                var turef = _deTransfer.GetStringValue("TransferTuRef");
                var wpe = new WSPaymentRequest { TU_REFERANS = turef, TEST_SORU_CEVAP = "" };
                var objTrans = new PaymentWSRequestFactory();
                var retVal = objTrans.PaymentRequestCheckTestQuestion(wpe); /* Ilk once Kaydi Check Edeceksin*/
                if (retVal.PaymentRequestStatus.RESPONSE == WsStatus.response.Error)
                {
                    messageBox.Show(retVal.PaymentRequestStatus.RESPONSE_DATA);
                    //postman.MessageList.Add(retVal.PaymentRequestStatus.RESPONSE_DATA);
                    return;
                }
                var pf = new PaymentFactory();
                try
                {
                    PaymentManager pManager = new PaymentManager();

                    TransferService s = new TransferService();
                    TuFactory.Domain.Transfer transfer = s.Get(ValidationHelper.GetGuid(hdnTransferId.Value));

                    PaymentRequestResponse response = pManager.SavePayment(transfer);

                    if (response.ResponseCode == PaymentRequestResponseCodes.TransactionCompleted && response.Payment != null && response.Payment.PaymentId != null)
                    {
                        hdnPaymentId.SetIValue(response.Payment.PaymentId.ToString());

                        DynamicSecurity DynamicSecurity;
                        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_Payment.GetHashCode(), null);

                        if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
                        {
                            messageBox.Height = 200;
                            messageBox.Show(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_YIM_CAN_ONLY_MAKE_REFUND_PAYMENT_ERROR"));
                        }
                        else
                        {
                            QScript("ShowPayment();");
                        }
                    }
                    else
                    {
                        messageBox.Show(string.Format("{0} {1}", CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CREATE_ERROR"),
                            !string.IsNullOrEmpty(response.ResponseMessage) ? CrmLabel.TranslateMessage(response.ResponseMessage) : ""));
                    }
                }
                catch (TuException ex)
                {
                    postman.MessageList.Add(CrmLabel.TranslateMessage(ex.ErrorMessage));
                    messageBox.Height = postman.MessageBoxHeightCalculator();
                    messageBox.Show(postman.ProcessMessage());
                }
            }
            else if (_confirmStatus == TuConfirmStatus.GOnderimIadeSurecinde)/*Iade islemlerinin yapilacaği yer*/
            {
                var rf = new RefundFactory();
                try
                {
                    RefundPaymentManager refundPaymentManager = new RefundPaymentManager();
                    CreateRefundPaymentResponse createRefundPaymentResponse = new RefundPaymentHelper().CreateRefundPaymentByTransferId(ValidationHelper.GetGuid(hdnTransferId.Value));

                    if (string.IsNullOrEmpty(createRefundPaymentResponse.ResponseMessage))
                    {
                        RefundPayment refundPayment = createRefundPaymentResponse.RefundPayment;
                        refundPayment.Channel = (int)TuChannelTypeEnum.Ekran;
                        RefundResponse response = refundPaymentManager.RefundPaymentRequest(refundPayment);

                        if (response.ResponseCode == RefundResponseCodes.Error)
                        {
                            messageBox.Show(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CREATE_ERROR"));
                        }
                        else
                        {
                            hdnrefundPaymentId.SetIValue(refundPayment.RefundPaymentId.ToString());
                            QScript("ShowPayment();");
                        }
                    }
                    else
                    {
                        messageBox.Show(createRefundPaymentResponse.ResponseMessage);
                    }
                }
                catch (TuException ex)
                {
                    postman.MessageList.Add(CrmLabel.TranslateMessage(ex.ErrorMessage));
                    messageBox.Height = postman.MessageBoxHeightCalculator();
                    messageBox.Show(postman.ProcessMessage());
                }
            }
            else if (_confirmStatus == TuConfirmStatus.GonderimOdemeAmlGecti)
            {

                TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
                var df = new DynamicFactory(ERunInUser.SystemAdmin);
                _deTransfer = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(hdnTransferId.Value), new string[] { "new_TestQuestionID", "new_TestQuestionReply", "TransferTuRef", "new_RecipientName", "new_RecipientLastName", "new_SenderID" });
                List<string> fields = new List<string>() { "new_RecipientName", "new_RecipientLastName" };
                _deTransfer = cryptor.DecryptFieldsInDynamicEntity(fields, _deTransfer);
                var turef = _deTransfer.GetStringValue("TransferTuRef");
                var wpe = new WSPaymentRequest { TU_REFERANS = turef, TEST_SORU_CEVAP = "" };
                var objTrans = new PaymentWSRequestFactory();
                var retVal = objTrans.PaymentRequestCheckTestQuestion(wpe); /* Ilk once Kaydi Check Edeceksin*/
                if (retVal.PaymentRequestStatus.RESPONSE == WsStatus.response.Error)
                {
                    messageBox.Show(retVal.PaymentRequestStatus.RESPONSE_DATA);
                    //postman.MessageList.Add(retVal.PaymentRequestStatus.RESPONSE_DATA);
                    return;
                }


                var pf = new PaymentFactory();
                var paymentId = pf.GetPaymentIdFromTransferForAml(ValidationHelper.GetGuid(hdnTransferId.Value));

                if (paymentId == Guid.Empty)
                {
                    messageBox.Show(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CREATE_ERROR"));
                }
                else
                {
                    hdnPaymentId.SetIValue(paymentId.ToString());
                    DynamicSecurity DynamicSecurity;
                    DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_Payment.GetHashCode(), null);

                    if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
                    {
                        messageBox.Height = 200;
                        messageBox.Show(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_YIM_CAN_ONLY_MAKE_REFUND_PAYMENT_ERROR"));
                    }
                    else
                    {
                        QScript("ShowPayment();");
                    }
                }
            }
            else
            {
                messageBox.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_ACTION_STATUS_ERROR"));
            }
        }
        else
        {
            QScript("ShowCheckWindow(GridPanelPayments.selectedRecord.ID);");
        }
    }

    private void TranslateMessage()
    {
        ToolbarButtonFind.Text = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_BTNARA");
        ToolbarButtonClear.Text = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_BTNTEMIZLE");
        pnlSEARCHGeneral.Title = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_ODEME_ARAMA_EKRANI");
        //btnRefund.Text = CrmLabel.TranslateMessage("CRM.NEW_REFUNDTRANSFER_IADESINEBASLA");


    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("PAYMENT_LIST", GridPanelPayments);
        string strSelected;
        strSelected = ViewFactory.GetViewIdbyUniqueName("PAYMENT_LIST").ToString();
        hdnViewList.Value = strSelected;

        if (string.IsNullOrEmpty(strSelected))
            return;
        var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));
        var DefaultEditPage = gpw.View.DefaultEditPage.ToString();
        hdnViewDefaultEditPage.Value = DefaultEditPage;


    }

    protected void BtnAraClick(object sender, AjaxEventArgs e)
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        var sort = GridPanelPayments.ClientSorts();
        bool IsOtherPool = false;
        if (sort == null)
            sort = string.Empty;

        string referenceNumber = new_RefNumber.Value.Trim();
        //string name = new_Name.Value.Trim();
        //string lastName = new_LastName.Value.Trim();
        //string middleName = new_MiddleName.Value.Trim();

        if (string.IsNullOrEmpty(referenceNumber)
            // && !(!string.IsNullOrEmpty(lastName) && !string.IsNullOrEmpty(name) && !string.IsNullOrEmpty(new_SenderCountry.Value))
            )
        {
            Alert(CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_SEARCH_EMPTY"));
        }

        Guid PaymentConfirmReqIdentifier = PaymentLogManager.LogStart(null, null, null, "WelcomePayment.Search", referenceNumber);


        /*Golden işlemleri için bazı refleri başında 00 ile gönderirlerse temizliyoruz 0 ları.*/
        //if (referenceNumber.Length == 11 && referenceNumber.StartsWith("00"))
        //{
        //    referenceNumber = referenceNumber.Substring(2, referenceNumber.Length - 2);
        //    new_RefNumber.Value = referenceNumber;
        //}

        string TU_REF = string.Empty;

        bool IsAmlRecord = false;
        TransferWSTransferInfoFactory objTrans = new TransferWSTransferInfoFactory();

        //PTT için geliştirildi. Gelen Ref AML havuzunda ise işlemi durduyoruz */

        DataTable statusDt = objTrans.GetAmlRecordStatus(referenceNumber);
        if (statusDt != null && statusDt.Rows.Count > 0)
        {
            if (!string.IsNullOrEmpty(statusDt.Rows[0]["Referans"].ToString()))
            {
                if (statusDt.Rows[0]["StatusCode"].ToString() == "TR003A")
                {
                    IsAmlRecord = true;
                    postman.MessageList.Add(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_OPERATION_STATUS_IS_TR003A_PLEASE_TRY_AGAIN_LATER"));
                }
                else if (statusDt.Rows[0]["StatusCode"].ToString() == "TR004A")
                {
                    referenceNumber = statusDt.Rows[0]["Referans"].ToString();
                    new_RefNumber.Value = referenceNumber;
                }
                else if (statusDt.Rows[0]["StatusCode"].ToString() == "TR011")
                {
                    IsAmlRecord = true;
                    postman.MessageList.Add(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_OPERATION_STATUS_IS_TR011_PLEASE_CHECK_THE_PROCESS"));
                }
            }
        }

        if (!IsAmlRecord)
        {
            TransferDb tdb = new TransferDb();
            TU_REF = referenceNumber;

            var spList = new List<CrmSqlParameter>();
            if (!string.IsNullOrEmpty(TU_REF))
            {
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.String, Paramname = "new_RefNumber", Value = ValidationHelper.GetDBString(TU_REF) });
            }
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "new_RecipientCountryID", Value = _newCorporationCountryId });
            spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "new_RecipientCorporationId", Value = _newCorporationId });

            PaymentManager paymentManager = new PaymentManager();
            GetTransferInfoResponse response = paymentManager.GetTransferInfo
            (
                new GetTransferInfoInput()
                {
                    Reference = TU_REF,
                    Channel = (int)TuChannelTypeEnum.Ekran
                }
            );

            if (response.ResponseCode == GetTransferInfoResponseCodes.TransferFound)
            {
                PaymentFactory paymentFactory = new PaymentFactory();

                List<Dictionary<string, object>> data = new List<Dictionary<string, object>>();
                DataSet ds = response.TransferData;
                if (ds != null)
                {
                    for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                    {
                        DataRow dr = ds.Tables[0].Rows[i];
                        Dictionary<string, object> rowData = new Dictionary<string, object>();
                        rowData.Add("VALUE", dr["TU_REFERANS"]);
                        rowData.Add("CreatedOn", ValidationHelper.GetDate(dr["GONDERIM_TARIHI"]).ToString("dd.MM.yyyy HH:mm:ss"));
                        rowData.Add("TransferTuRef", dr["TU_REFERANS"]);
                        rowData.Add("ID", dr["NEW_TRANSFERID"]);

                        if (paymentFactory.IsBeneficiaryNameMaskKvvkCheck(ValidationHelper.GetGuid(dr["NEW_TRANSFERID"])))
                        {
                            rowData.Add("new_RecipientName", paymentFactory.BeneficiaryNameMask(ValidationHelper.GetString(dr["ALICI_AD"]).Trim()));
                            rowData.Add("new_RecipientMiddleName", paymentFactory.BeneficiaryNameMask(ValidationHelper.GetString(dr["ALICI_ORTAAD"]).Trim()));
                            rowData.Add("new_RecipientLastName", paymentFactory.BeneficiaryNameMask(ValidationHelper.GetString(dr["ALICI_SOYAD"]).Trim()));
                        }
                        else
                        {
                            rowData.Add("new_RecipientName", ValidationHelper.GetString(dr["ALICI_AD"]));
                            rowData.Add("new_RecipientMiddleName", ValidationHelper.GetString(dr["ALICI_ORTAAD"]));
                            rowData.Add("new_RecipientLastName", ValidationHelper.GetString(dr["ALICI_SOYAD"]));
                        }

                        if (!ValidationHelper.GetBoolean(dr["IADE"]))
                        {
                            rowData.Add("new_SenderIDName", dr["GONDEREN_ADSOYAD"]);
                        }
                        else
                        {
                            rowData.Add("new_SenderIDName", dr["ALICI_ADSOYAD"]);
                        }
                        rowData.Add("new_CorporationIDName", dr["GONDEREN_KURUM_ADI"]);
                        rowData.Add("new_Amount", ValidationHelper.GetDecimal(dr["GONDERILEN_TUTAR"], 0).ToString("#,###0.00"));
                        rowData.Add("new_Amount_CurrencyName", dr["GONDERILEN_TUTAR_PARAKOD"]);
                        rowData.Add("new_ConfirmStatusName", dr["GONDERIM_DURUMU"]);
                        rowData.Add("new_SenderCountryIDName", dr["GONDEREN_ULKE_ADI"]);
                        rowData.Add("new_RecipientFatherName", dr["ALICI_BABAAD"]);
                        //rowData.Add("new_RecipientBirthDate", dr["ALICI_DOGTAR"]);
                        data.Add(rowData);
                    }
                }

                var gpc = new GridPanelCreater();
                var cnt = 0;
                var start = GridPanelPayments.Start();
                var limit = GridPanelPayments.Limit();
                var t = data;
                cnt = data.Count;
                GridPanelPayments.TotalCount = cnt;
                List<string> fields = new List<string>() { "new_RecipientName", "new_RecipientMiddleName", "new_RecipientLastName" };
                t = cryptor.DecryptFieldsInFilterData(fields, t);

                //check if user have permission to see tu references.
                if (!_userApproval.ReferenceCanBeSeen)
                {
                    List<Dictionary<string, object>> maskedList = new List<Dictionary<string, object>>();

                    foreach (var item in t)
                    {
                        string tu_Ref = item.Where(x => x.Key.Equals("TransferTuRef")).Select(x => x.Value).FirstOrDefault().ToString();
                        var masked_tu_ref = TuFactory.Utility.Masker.MaskReference(tu_Ref); // string.Concat(tu_Ref.Substring(0, 3), "".PadRight(10, 'X'));

                        item["TransferTuRef"] = masked_tu_ref;
                        item["VALUE"] = masked_tu_ref;

                        maskedList.Add(item);
                    }

                    GridPanelPayments.DataSource = maskedList;
                    GridPanelPayments.DataBind();
                }
                else
                {
                    GridPanelPayments.DataSource = t;
                    GridPanelPayments.DataBind();
                }

                Guid transferId = tdb.GetTransferId(TU_REF);
                PaymentLogManager.LogEnd(PaymentConfirmReqIdentifier, TU_REF, transferId, null, TU_REF);
            }
            else
            {
                GridPanelPayments.DataSource = new List<Dictionary<string, object>>();
                GridPanelPayments.DataBind();
                GridPanelPayments.TotalCount = 0;
                if (!string.IsNullOrEmpty(response.ResponseMessage))
                {
                    postman.MessageList.Add(response.ResponseMessage);
                }
                else
                {
                    postman.MessageList.Add(CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_RECORDNOTFOUND"));
                }

                PaymentLogManager.LogEnd(PaymentConfirmReqIdentifier, null, null, null, TU_REF);
            }

            try
            {
                var de = new DynamicEntity(TuEntityEnum.New_WelcomePaymentHistory.GetHashCode());
                de.AddStringProperty("new_TransferTuRef", TU_REF);
                var df = new DynamicFactory(ERunInUser.CalingUser);
                df.Create(de.ObjectId, de);
            }
            catch (Exception)
            {
            }

            string msg = postman.ProcessMessage();
            if (GridPanelPayments.TotalCount == 0 && !string.IsNullOrEmpty(msg))
            {
                messageBox.Height = postman.MessageBoxHeightCalculator();
                messageBox.Show(string.Empty, string.Empty, msg);
            }
        }
        else
        {
            string msg = postman.ProcessMessage();
            messageBox.Height = postman.MessageBoxHeightCalculator();
            messageBox.Show(string.Empty, string.Empty, msg);
            GridPanelPayments.DataBind();
        }
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
        }
        base.OnPreInit(e);
    }

    private string GetPayableTransferFromPartner(string ReferenceNumber)
    {

        #region [3rdEntegrasyon] kontrolu icin Ilk once <islemin> entegrasyon yapılacak kurumun web servisinden kontrolu yapilir.
        var i3rd = new TuFactory.Integration3rd.Integration3Rd();
        try
        {
            string ownOfficeCode = new OfficeDb().GetUserOwnOfficeCode(App.Params.CurrentUser.SystemUserId);

            /*İlgili ref no entegrasyon kurumlarında ödenebilir durumdamı sorgular, ödenebilirse upt havuzuna gönderim kaydı açılır.*/
            string TU_REF = i3rd.IntegratePayableTransfer(ReferenceNumber, ownOfficeCode);
            return TU_REF;

        }
        catch (TuException ex)
        {
            postman.MessageList.Add(CrmLabel.TranslateMessage(ex.ErrorMessage));
            return string.Empty;
        }
        catch (Exception ex)
        {
            postman.MessageList.Add(CrmLabel.TranslateMessage(ex.Message));
            return string.Empty;
        }
        #endregion


    }

    private void Logger(List<CrmSqlParameter> spList)
    {
        var de = new DynamicEntity(TuEntityEnum.New_WelcomePayment.GetHashCode());
        var deRetrived = new DynamicEntity(de.ObjectId);

        foreach (var parameter in spList)
        {
            if (parameter.Dbtype == DbType.String)
            {
                de.AddStringProperty(parameter.Paramname, ValidationHelper.GetString(parameter.Value));
            }
            if (parameter.Dbtype == DbType.Guid)
            {
                de.AddLookupProperty(parameter.Paramname, "", ValidationHelper.GetGuid(parameter.Value));
            }
        }

        DynamicFactory df = new DynamicFactory(Coretech.Crm.Objects.Crm.WorkFlow.ERunInUser.SystemAdmin);
        var db = new Coretech.Crm.Data.Crm.Dynamic.DynamicDb();

        var recId = Guid.Empty;
        if (string.IsNullOrEmpty(hdnRecid.Value) || hdnRecid.Value.Equals(Guid.Empty))
        {
            var gdKey = GuidHelper.Newfoid(de.ObjectId);
            var logsql = "";
            List<CrmSqlParameter> logspList;

            var baseEntity = TuFactory.Data.LogDb.GetBaseEntityId(TuEntityEnum.New_WelcomePayment.ToString());
            TuFactory.Data.LogDb.CreateLogSql(out logsql, out logspList, deRetrived, de, Guid.Parse(hdnEntityId.Value), gdKey);

            if (logspList.Count > 0)
                db.Exec(logsql, App.Params.CurrentUser.SystemUserId, logspList);

            hdnRecid.SetValue(gdKey);
        }
        else
        {
            //de.AddKeyProperty("New_ProcessMonitoringId", Guid.Parse(hdnRecid.Value));

            var logsql = "";
            List<CrmSqlParameter> logspList;
            var baseEntity = TuFactory.Data.LogDb.GetBaseEntityId(TuEntityEnum.New_WelcomePayment.ToString());
            TuFactory.Data.LogDb.CreateLogSql(out logsql, out logspList, deRetrived, de, Guid.Parse(hdnEntityId.Value), Guid.Parse(hdnRecid.Value));

            if (logspList.Count > 0)
                db.Exec(logsql, App.Params.CurrentUser.SystemUserId, logspList);
        }
    }

    private void FillLogInfo()
    {
        var id = TuFactory.Data.LogDb.GetBaseEntityId(TuEntityEnum.New_WelcomePayment.ToString());
        var recId = new TuFactory.Data.LogDb().GetLastRecordId(id);

        hdnEntityId.SetValue(id);
        hdnRecid.SetValue(recId);
    }

}

public class Postman
{
    public Postman()
    {
        MessageList = new List<string>();
    }

    public List<string> MessageList { get; set; }

    public int MessageBoxHeightCalculator()
    {
        return 192 + ((ProcessMessage().Length / 40) * 16);
    }

    public string ProcessMessage()
    {
        String MessageText = string.Empty;

        for (int indexOfMessages = MessageList.Count - 1; indexOfMessages >= 0; indexOfMessages--)
        {
            MessageText += MessageList[indexOfMessages];
            if (MessageList.Count - indexOfMessages < MessageList.Count)
            {
                //MessageText += "/r/n----------------------------------------/r/n";
                MessageText += "<br/>";
            }
        }

        return MessageText;
    }
}
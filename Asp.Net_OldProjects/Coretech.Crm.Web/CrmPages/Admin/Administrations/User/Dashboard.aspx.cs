using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Factory.Site;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using TuFactory.Announcement;
using TuFactory.Business.Transfer;
using TuFactory.Confirm;
using TuFactory.Data;
using TuFactory.Domain.Refund;
using TuFactory.Encryption;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Payment;
using TuFactory.Refund;
using TuFactory.TransactionManagers.Payment;
using TuFactory.TransactionManagers.Refund;
using TuFactory.TransactionManagers.Refund.RefundPayment;
using TuFactory.Transfer;

namespace Coretech.Crm.Web.CrmPages.Admin.Administrations.User
{
    public partial class Dashboard : System.Web.UI.Page
    {
        DynamicEntity _deTransfer = new DynamicEntity(TuEntityEnum.New_Transfer.GetHashCode());

        private string _confirmStatus;
        protected void Page_Load(object sender, EventArgs e)
        {
            //var menuStr = GenerateMenuHtml();
            if (!IsPostBack)
            {

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
                    new_IsUsedSecurityQuestion.Value = dt.Rows[0]["new_IsUsedSecurityQuestion"].ToString();
                }

                GetAnnouncementList(sender, e);
            }
        }

        public void QScript(string script)
        {
            Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", script, true);
        }

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

        public string GetPageParameters()
        {
            return string.Format("{0};{1};{2};{3};{4};{5};{6};{7};{8}",
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_FREQUENTLY_USED_TRANSACTIONS"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_SEND_MONEY"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_PAYMENT_MONEY"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_PLEASE_ENTER_THE_REFERENCE_CODE"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_SEARCH_IN_CORPORATION_POOL"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_PAY_MONEY"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_DAILY_UPT_CHARTS"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_SENDING_AND_PAYMENT_TRACKING_HOURLY"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_TIME")
                );
        }

        string GenerateMenuHtml()
        {
            StringBuilder menuHtml = new StringBuilder();
            StringBuilder tempModule = new StringBuilder();
            StringBuilder tempMenu = new StringBuilder();
            StringBuilder tempSubMenu = new StringBuilder();
            var modules = (new ModulesFactory()).GetUserModules(true);

            foreach (var module in modules)
            {

                var menus = (new ModulesFactory()).GetUserSiteMapArea(module.SiteMapId);

                if (menus != null && menus.Count > 0)
                {
                    for (int i = 0; i < menus.Count; i++)
                    {
                        // Alt menü bul
                        var subMenus = menus.Where(x => x.ParentSiteMapAreaId == menus[i].SiteMapAreaId).ToList();

                        if (subMenus != null && subMenus.Count > 0)
                        {
                            foreach (var subMenu in subMenus)
                            {
                                if (subMenu.SiteMapAreaId != menus[i].SiteMapAreaId)
                                {
                                    tempSubMenu.Append(string.Format(@"<li><a onclick=""{0}"">{1}</a></li>", "Navigate('" + menus[i].IsvLabel + "', '" + ResolveUrl(menus[i].IsvHref) + "');", subMenu.IsvLabel));
                                }
                            }
                            tempMenu.Append(string.Format(@"<li><a href= ""{0}"">{1}</a><ul>{2}</ul></li>", "#", menus[i].IsvLabel, tempSubMenu.ToString()));
                            tempSubMenu.Clear();
                            continue;
                        }

                        tempMenu.Append(string.Format(@"<li><a onclick=""{0}"">{1}</a></li>", "Navigate('" + menus[i].IsvLabel + "', '" + ResolveUrl(menus[i].IsvHref) + "');", menus[i].IsvLabel));
                    }


                }

                menuHtml.Append(string.Format(@"<li><h3><a href=""#""><i class=""fa fa-lg fa-tasks""></i>" + module.Label + "</a></h3><ul>{0}</ul></li>", tempMenu.ToString()));
                tempMenu.Clear();
            }


            return menuHtml.ToString();
        }

        [WebMethod]
        public static string GetHomePageParameters()
        {
            return string.Format("{0};{1};{2};{3};{4};{5};{6};{7};{8}",
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_FREQUENTLY_USED_TRANSACTIONS"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_SEND_MONEY"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_PAYMENT_MONEY"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_PLEASE_ENTER_THE_REFERENCE_CODE"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_SEARCH_IN_CORPORATION_POOL"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_PAY_MONEY"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_DAILY_UPT_CHARTS"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_SENDING_AND_PAYMENT_TRACKING_HOURLY"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_TIME")
                );
        }

        [WebMethod]
        public static string TestMethod(string referenceNumber)
        {
            return "The message" + referenceNumber;
        }

        [System.Web.Services.WebMethod]
        public static string PaymentExternalPoolCheck(string referenceNumber)
        {
            if (referenceNumber == "0")
            {
                return CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_SEARCH_EMPTY");
            }

            var i3rd = new TuFactory.Integration3rd.Integration3Rd();
            string err;
            string msg = string.Empty;

            if (!string.IsNullOrEmpty(referenceNumber))
            {
                string ownOfficeCode = new OfficeDb().GetUserOwnOfficeCode(App.Params.CurrentUser.SystemUserId);

                if (i3rd.CheckPayableTransfer(referenceNumber, ownOfficeCode, out err))
                {
                    msg = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CAN_BE_MADE");
                }
                else
                {
                    msg = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CANNOT_BE_MADE") + "<br />" + err;
                }
            }
            return msg;
        }

        public class CreatePaymentResult
        {
            public bool IsSuccess { get; set; }
            public string Message { get; set; }
            public string Method { get; set; }
            public Guid TransferId { get; set; }
            public Guid PaymentId { get; set; }
            public Guid RefundPaymentId { get; set; }
        }

        [System.Web.Services.WebMethod]
        public static CreatePaymentResult CreatePayment(string referenceNumber, bool isUsedSecurityQuestion)
        {
            var result = new CreatePaymentResult();
            if (referenceNumber == "0")
            {
                result.IsSuccess = false;
                result.Message = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_SEARCH_EMPTY");
                return result;
            }
            else
            {
                ValidationCryptFactory cryptor = new ValidationCryptFactory();

                try
                {
                    var de = new DynamicEntity(TuEntityEnum.New_WelcomePaymentHistory.GetHashCode());
                    de.AddStringProperty("new_TransferTuRef", referenceNumber);
                    var df = new DynamicFactory(ERunInUser.CalingUser);
                    df.Create(de.ObjectId, de);

                    bool IsAmlRecord = false;
                    TransferWSTransferInfoFactory objTrans = new TransferWSTransferInfoFactory();

                    DataTable statusDt = objTrans.GetAmlRecordStatus(referenceNumber);

                    if (statusDt != null && statusDt.Rows.Count > 0)
                    {
                        if (!string.IsNullOrEmpty(statusDt.Rows[0]["Referans"].ToString()))
                        {
                            if (statusDt.Rows[0]["StatusCode"].ToString() == "TR003A")
                            {
                                IsAmlRecord = true;
                                result.IsSuccess = false;
                                result.Message = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_OPERATION_STATUS_IS_TR003A_PLEASE_TRY_AGAIN_LATER");
                                return result;
                            }
                            else if (statusDt.Rows[0]["StatusCode"].ToString() == "TR004A")
                            {
                                referenceNumber = statusDt.Rows[0]["Referans"].ToString();
                            }
                            else if (statusDt.Rows[0]["StatusCode"].ToString() == "TR011")
                            {
                                IsAmlRecord = true;
                                result.IsSuccess = false;
                                result.Message = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_OPERATION_STATUS_IS_TR011_PLEASE_CHECK_THE_PROCESS");
                                return result;
                            }
                        }
                    }

                    if (!IsAmlRecord)
                    {
                        TransferDb tdb = new TransferDb();

                        PaymentManager paymentManager = new PaymentManager();
                        GetTransferInfoResponse response = paymentManager.GetTransferInfo
                        (
                            new GetTransferInfoInput()
                            {
                                Reference = referenceNumber,
                                Channel = (int)TuChannelTypeEnum.Ekran
                            }
                        );

                        if (response.ResponseCode == GetTransferInfoResponseCodes.TransferFound)
                        {

                            DataTable dt = response.TransferData.Tables[0];

                            if (dt != null && dt.Rows.Count == 1)
                            {
                                // Yapılacaklar
                                result.TransferId = ValidationHelper.GetGuid(dt.Rows[0]["NEW_TRANSFERID"]);

                                #region Eski yapıdaki rowdblclick yapısı

                                var cf = new ConfirmFactory();
                                string confirmStatus = cf.GetTransactionStatus(TuEntityEnum.New_Transfer.GetHashCode(), result.TransferId);

                                if (confirmStatus == TuConfirmStatus.GonderimTamamlandi || confirmStatus == TuConfirmStatus.GonderimOdemeOnProvizyon)
                                {
                                    #region Check Test Question
                                    var wpe = new WSPaymentRequest { TU_REFERANS = referenceNumber, TEST_SORU_CEVAP = "" };
                                    var paymentWSRequestFactory = new PaymentWSRequestFactory();
                                    var retVal = paymentWSRequestFactory.PaymentRequestCheckTestQuestion(wpe);
                                    if (retVal.PaymentRequestStatus.RESPONSE == WsStatus.response.Error)
                                    {
                                        result.IsSuccess = false;
                                        result.Message = retVal.PaymentRequestStatus.RESPONSE_DATA;
                                        return result;
                                    }
                                    #endregion

                                    #region PaymentManeger

                                    try
                                    {
                                        PaymentManager pManager = new PaymentManager();
                                        TransferService transferService = new TransferService();
                                        TuFactory.Domain.Transfer transfer = transferService.Get(result.TransferId);
                                        PaymentRequestResponse paymentResponse = pManager.SavePayment(transfer);

                                        if (paymentResponse.ResponseCode == PaymentRequestResponseCodes.TransactionCompleted
                                            && paymentResponse.Payment != null && paymentResponse.Payment.PaymentId != null)
                                        {
                                            result.PaymentId = paymentResponse.Payment.PaymentId;

                                            var DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_Payment.GetHashCode(), null);

                                            if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
                                            {
                                                result.IsSuccess = false;
                                                result.Message = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_YIM_CAN_ONLY_MAKE_REFUND_PAYMENT_ERROR");
                                                return result;
                                            }
                                            else
                                            {
                                                result.Method = "ShowPayment();";
                                                result.IsSuccess = true;
                                                return result;
                                            }
                                        }
                                        else
                                        {
                                            result.IsSuccess = false;
                                            result.Message = string.Format("{0} {1}", CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CREATE_ERROR"),
                            !string.IsNullOrEmpty(response.ResponseMessage) ? CrmLabel.TranslateMessage(response.ResponseMessage) : "");
                                            return result;
                                        }
                                    }
                                    catch (TuException ex)
                                    {

                                        result.IsSuccess = false;
                                        result.Message = ex.ErrorMessage;
                                        return result;

                                    }

                                    #endregion
                                }
                                else if (confirmStatus == TuConfirmStatus.GOnderimIadeSurecinde)
                                {
                                    try
                                    {
                                        RefundPaymentManager refundPaymentManager = new RefundPaymentManager();
                                        CreateRefundPaymentResponse createRefundPaymentResponse = new RefundPaymentHelper().CreateRefundPaymentByTransferId(result.TransferId);

                                        if (string.IsNullOrEmpty(createRefundPaymentResponse.ResponseMessage))
                                        {
                                            RefundPayment refundPayment = createRefundPaymentResponse.RefundPayment;
                                            refundPayment.Channel = (int)TuChannelTypeEnum.Ekran;
                                            RefundResponse refundResponse = refundPaymentManager.RefundPaymentRequest(refundPayment);

                                            if (refundResponse.ResponseCode == RefundResponseCodes.Error)
                                            {
                                                result.IsSuccess = false;
                                                result.Message = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CREATE_ERROR");
                                                return result;
                                            }
                                            else
                                            {

                                                result.RefundPaymentId = refundPayment.RefundPaymentId;
                                                result.Method = "ShowPayment();";
                                                result.IsSuccess = true;
                                                return result;
                                            }
                                        }
                                        else
                                        {
                                            result.IsSuccess = false;
                                            result.Message = createRefundPaymentResponse.ResponseMessage;
                                            return result;
                                        }
                                    }
                                    catch (TuException ex)
                                    {
                                        result.IsSuccess = false;
                                        result.Message = ex.ErrorMessage;
                                        return result;
                                    }
                                }
                                else if (confirmStatus == TuConfirmStatus.GonderimOdemeAmlGecti)
                                {
                                    #region Check Test Question
                                    var wpe = new WSPaymentRequest { TU_REFERANS = referenceNumber, TEST_SORU_CEVAP = "" };
                                    var paymentWSRequestFactory = new PaymentWSRequestFactory();
                                    var retVal = paymentWSRequestFactory.PaymentRequestCheckTestQuestion(wpe);
                                    if (retVal.PaymentRequestStatus.RESPONSE == WsStatus.response.Error)
                                    {
                                        result.IsSuccess = false;
                                        result.Message = retVal.PaymentRequestStatus.RESPONSE_DATA;
                                        return result;
                                    }
                                    #endregion

                                    var pf = new PaymentFactory();
                                    var paymentId = pf.GetPaymentIdFromTransferForAml(result.TransferId);

                                    if (paymentId == Guid.Empty)
                                    {
                                        result.IsSuccess = false;
                                        result.Message = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_CREATE_ERROR");
                                        return result;
                                    }
                                    else
                                    {
                                        var DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_Payment.GetHashCode(), null);

                                        if (!(DynamicSecurity.PrvCreate || DynamicSecurity.PrvRead || DynamicSecurity.PrvWrite))
                                        {
                                            result.IsSuccess = false;
                                            result.Message = CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_PAYMENT_YIM_CAN_ONLY_MAKE_REFUND_PAYMENT_ERROR");
                                            return result;
                                        }
                                        else
                                        {
                                            result.Method = "ShowPayment();";
                                            result.IsSuccess = true;
                                            return result;
                                        }
                                    }
                                }
                                else
                                {
                                    result.IsSuccess = false;
                                    result.Message = CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_ACTION_STATUS_ERROR");
                                    return result;
                                }

                                #endregion
                            }
                            else if (dt != null && dt.Rows.Count > 1)
                            {
                                result.IsSuccess = false;
                                result.Message = "Lütfen bu işlem için menüdeki ödeme karşılama ekranını kullanınız.";
                                return result;
                            }
                            else if (dt != null && dt.Rows.Count == 0)
                            {
                                result.IsSuccess = false;
                                result.Message = CrmLabel.TranslateMessage("CRM.NEW_WELCOMEPAYMENT_RECORDNOTFOUND");
                                return result;
                            }
                        }
                        else
                        {
                            result.IsSuccess = false;
                            result.Message = response.ResponseMessage;
                            return result;
                        }
                    }
                }
                catch (Exception ex)
                {
                    result.IsSuccess = false;
                    result.Message = ex.Message;
                    return result;
                }
            }

            return result;
        }

        protected void GetAnnouncementList(object sender, EventArgs e)
        {
            var sd = new StaticData();
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            DataTable dt = sd.ReturnDatasetSp(@"spTuGetAnnouncementList").Tables[0];

            if (dt.Rows.Count > 0)
            {
                var mainAnnouncement = dt.Rows[0];
                MainAnnouncement.InnerHtml =
                           "<div style='border-style: solid; border-color: red;height: 250px; overflow-y:auto;'><p><h4><b>"
                           + mainAnnouncement[1].ToString() + "</b></h4></p></hr><p>"
                           + mainAnnouncement[2].ToString() + "</p><p><a download='"
                           + mainAnnouncement[5].ToString() + "' href='data:"
                           + mainAnnouncement[4].ToString() + "; base64,"
                           + mainAnnouncement[3].ToString() + "'>"
                           + mainAnnouncement[5].ToString() + "</a></p></div>";

                string tablestring = "";

                tablestring = tablestring + @"<table id=""example"" class=""table table-striped"" cellspacing=""0"" width=""100%""><thead><tr><th><h4><b>DUYURULAR</b></h4></th></tr></thead><tbody>";
                if (dt.Rows.Count > 1)
                {
                    foreach (DataRow dr in dt.Rows)
                    {

                        if(!string.IsNullOrEmpty(dr[7].ToString())) //tarihi geçen duyurular pasif ediliyor
                        {
                            var endDate = ValidationHelper.GetDate(dr[7].ToString());

                            if(endDate< DateTime.Now)
                            {
                                UpdateAnnouncementStatus(ValidationHelper.GetGuid(dr[0].ToString()));
                                continue;
                            }
                        }

                        tablestring = tablestring +
                            "<tr><td><a href = javascript:AnnouncementDetail('"
                            + dr[0].ToString() + "');> "
                            + dr[1].ToString() + "</a></td></tr>";
                    }

                    tablestring = tablestring + "</tbody></table>";
                    Grid.InnerHtml = tablestring;
                }
            }
        }

        private void UpdateAnnouncementStatus(Guid recId)
        {
            AnnouncementFactory announcement = new AnnouncementFactory();

            announcement.TakeDownAnnoucement(recId);
        }
    }
}
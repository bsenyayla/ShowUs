using System;
using System.Collections.Generic;
using System.Web.UI;
using AjaxPro;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Newtonsoft.Json;
using RefleXFrameWork;
using TuFactory.KpsAps;
using TuFactory.Object.AjaxObject;
using TuFactory.Sender;
using TuFactory.Object;
using Coretech.Crm.Factory;
using TuFactory.SenderDocument;
using TuFactory.CustAccount.Object;
using TuFactory.CustAccount.Business;
using TuFactory.CreditCheck;
using UPTCache = UPT.Shared.CacheProvider.Service;
using UPT.Shared.CacheProvider.Model;
using TuFactory.CustAccount;
using Coretech.Crm.PluginData;
using TuFactory.UptCard.Business;
using TuFactroy.CustAccount.WebService.Domain;
using TuFactroy.CustAccount.WebService.Domain.Base;
using System.Linq;
using System.Data.Common;
using static TuFactory.Fraud.FraudScanFactory;
using TuFactory.Domain;
using TuFactory.Domain.Enums;
using TuFactory.Data;

public partial class Sender_Sender : BasePage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            CustInfoFactory custFactory = new CustInfoFactory();
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage", "var NEW_TRANSFER_SENDER_VALIDDATEOFIDENDITY_NOT_VALID="
                + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_SENDER_VALIDDATEOFIDENDITY_NOT_VALID")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "InvalidGsm", "var InvalidGsm="
                  + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_PHONENUMBER_INVALID_EMPTY")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage1", "var NEW_SENDER_KPSZORUNLU="
                           + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_KPSZORUNLU")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage2", "var NEW_SENDER_KPS_HATALI="
                                      + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_KPS_HATALI")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage3", "var NEW_SENDER_IDENDITYNO_MUST_BE_NUMBER="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_IDENDITYNO_MUST_BE_NUMBER")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage4", "var NEW_SENDER_IDENDITYNO_MUST_BE_ELEVEN_CHAR="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_IDENDITYNO_MUST_BE_ELEVEN_CHAR")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage5", "var CRM_NEW_SENDER_SINGULARITY_CONFIRM="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_SINGULARITY_CONFIRM")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage6", "var CRM_NEW_SENDER_MULTIPLESINGULARITY_CONFIRM="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_MULTIPLESINGULARITY_CONFIRM")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText2", "var CRM_NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage7", "var CRM_NEW_SENDER_CREDIT_CREATE_SENDER_INFO="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_CREDIT_CREATE_SENDER_INFO")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "NationTurkeyParam", "var TurkeyID="
               + JsonConvert.SerializeObject(SenderNationalityID.Turkey) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText1", "var CRM_NEW_SENDER_IDENTIFICATION_NUMBER="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_SENDERIDENTIFICATIONNUMBER1")) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "RealCustType", "var RealCustType="
                + JsonConvert.SerializeObject(custFactory.GetAccountTypeID(TuFactory.CustAccount.Object.CustAccountType.GERCEK)) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "CorpCustType", "var CorpCustType="
                + JsonConvert.SerializeObject(custFactory.GetAccountTypeID(TuFactory.CustAccount.Object.CustAccountType.TUZEL)) + ";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "ControlTCNumeric", "var ControlTCNumeric="
                + JsonConvert.SerializeObject(ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("TK_CONTROL_TC_SENDERIDENTIFICATION_NUMERIC", "false"))) + ";", true);
            QScript("DisableToolbarIfCalledByTransferScreen();");
            QScript("TransferScreenSetSenderValues();");
            QScript("CustomerAccountScreenSetSenderID();");
            QScript("NationalID_onChange();");
            var customerAccountScreen = Request.QueryString["fromCustomerAccountScreen"];
            if (customerAccountScreen != null && customerAccountScreen != "" && customerAccountScreen == "1")
            {
                QScript("SetRealCustomerAccountType();");
                QScript("InsertSenderDocuments();");
            }

            //Kredi Ödemesi için Gönderici Yaratılması:
            var fromCheckCredit = Request.QueryString["fromCheckCredit"];
            if (fromCheckCredit != null && fromCheckCredit != "" && fromCheckCredit == "1")
            {
                CreditCheckFactory ccf = new CreditCheckFactory();
                string senderIdentificationNum = ccf.GetTempCreditTcknInfo(ValidationHelper.GetGuid(QueryHelper.GetString("creditDataID")));
                if (!String.IsNullOrEmpty(senderIdentificationNum))
                {
                    QScript(String.Format("FillNationIdAndSenderIdentification('{0}','{1}');", senderIdentificationNum, SenderNationalityID.Turkey));
                }
            }
        }
    }

    #region AjaxMethods
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {

        [AjaxMethod()]
        public AjxKpsPerson GetKpsData(string senderIdendificationNumber1, string nationalityId)
        {
            var ret = new AjxKpsPerson();
            var sf = new SenderFactory();
            try
            {
                ret = sf.GetKpsData(senderIdendificationNumber1, ValidationHelper.GetGuid(nationalityId));
            }
            catch (Exception)
            {
                ret.new_cameFromKps = false;
            }

            return ret;
        }
        [AjaxMethod()]
        public AjxAddress GetApsData(string senderIdendificationNumber1, string nationalityId)
        {
            var ret = new AjxAddress();
            var sf = new KpsApsFactory();
            try
            {
                ret = sf.GetApsData(senderIdendificationNumber1, ValidationHelper.GetGuid(nationalityId));
            }
            catch (Exception)
            {

            }

            return ret;
        }

        [AjaxMethod()]
        public string DirectToCreditPayment(string senderID, string creditDataID)
        {
            var query = new Dictionary<string, string>
            {
                {"ObjectId", ((int) TuEntityEnum.New_Transfer).ToString()},
                {"mode", "-1"},
                {"creditDataID", creditDataID},
                {"gridpanelid", "GridPanelViewer"},
                {"defaulteditpageid", "67b76827-666a-492c-9ec9-a7d03c8ae6f0"},
                {"rlistframename","Frame_PnlCenter"},
                {"senderID",senderID},
                {"fromCreateSender","1"},
                {"fromCheckCredit","1"}
            };

            var urlPage = "/isv/tu/transfer/TransferMain.aspx";
            var urlparam = QueryHelper.RefreshUrl(query);
            return urlPage + urlparam;
        }

        [AjaxMethod()]
        public bool IsCurrentUserForeign()
        {
            SenderFactory senderService = new SenderFactory();
            string countryCode = senderService.GetUserCountryCode();
            if (countryCode == CountryShortCode.Turkey)
                return false;
            else
                return true;
        }

        [AjaxMethod()]
        public string CheckIdentificationCardNo(string senderIdentificationCardNo)
        {
            SenderFactory sService = new SenderFactory();
            string validateMsg = sService.checkIdentificationCardNo(senderIdentificationCardNo);
            return validateMsg;

        }

        [AjaxMethod()]
        public string CheckGsmSingularity(string senderGsm, string senderId)
        {
            SenderFactory sService = new SenderFactory();

            string validateMsg = sService.CheckSenderPhoneSingularity(senderGsm, string.IsNullOrEmpty(senderId) ? Guid.Empty : ValidationHelper.GetGuid(senderId));
            return string.IsNullOrEmpty(validateMsg) ? string.Empty : CrmLabel.TranslateMessage("CRM.NEW_SENDER_GSMNO_ISUSED") + validateMsg;

        }

        [AjaxMethod()]
        public bool UpdateIsDomesticValue()
        {
            SenderFactory senderService = new SenderFactory();
            string countryCode = senderService.GetUserCountryCode();
            if (countryCode == CountryShortCode.Turkey)
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        [AjaxMethod()]
        public AjxChannelCorpObj GetChannelCorpValues(string recID)
        {
            Guid senderID;
            if (recID == string.Empty)
                senderID = Guid.Empty;
            else
                senderID = new Guid(recID);
            SenderFactory sc = new SenderFactory();
            return sc.GetLocalCorpChannelValues(senderID);
        }

        [AjaxMethod()]
        public SingularityControlReponse CheckSenderSingularity(Guid NationalityID, string IdentificationNumber, Guid IdentificationCardTypeID, string IdentificationNo, bool cameFromKps, string firstName, string middleName, string lastName, string birthDate)
        {

            SenderSingularityControl senderControl = new SenderSingularityControl
            {
                NationalityID = ValidationHelper.GetGuid(NationalityID, Guid.Empty),
                IdentificationCardTypeID = ValidationHelper.GetGuid(IdentificationCardTypeID, Guid.Empty),
                IdentificationNumber = ValidationHelper.GetString(IdentificationNumber, ""),
                IdentityNo = ValidationHelper.GetString(IdentificationNo, ""),
                FirstName = ValidationHelper.GetString(firstName, ""),
                MiddleName = ValidationHelper.GetString(middleName, ""),
                LastName = ValidationHelper.GetString(lastName, ""),
                Birthdate = ValidationHelper.GetDate(birthDate)

            };
            SenderFactory senderService = new SenderFactory();


            return senderService.CheckIfSingularityExists(senderControl, cameFromKps);
        }

        [AjaxMethod()]
        public void InsertSenderDocumentsIfNecessary(Guid senderID, Guid custTypeID, Guid nationID)
        {
            SenderDocumentFactory docService = new SenderDocumentFactory();
            try
            {
                docService.InsertSenderDocumentsIfNecessary(senderID, custTypeID, nationID);
            }
            catch
            {
                throw;
            }
        }

        [AjaxMethod()]
        public string GetMultipleSingularityWindowUrlParams(string NationalityID, string IdentificationNumber, string IdentificationCardTypeID, string IdentificationNo, string firstName, string middleName, string lastName)
        {
            SenderSingularityControl senderControl = new SenderSingularityControl
            {
                FirstName = ValidationHelper.GetString(firstName, ""),
                MiddleName = ValidationHelper.GetString(middleName, ""),
                LastName = ValidationHelper.GetString(lastName, "")
            };

            Dictionary<string, string> query;
            query = new Dictionary<string, string>
                            {
                                {"NationalityID", NationalityID},
                                {"IdentificationNumber",IdentificationNumber},
                                {"IdentificationCardTypeID",IdentificationCardTypeID},
                                {"IdentificationNo",IdentificationNo},
                                {"FullName",senderControl.FullName }
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            return urlparam;
        }

        [AjaxMethod()]
        public int GetSenderType(Guid NationalityID, string IdentificationNumber, Guid IdentificationCardTypeID, string IdentificationNo, string firstName, string middleName, string lastName, string birthDate)
        {
            if (NationalityID != Guid.Empty && NationalityID != null)
            {
                UPT.Shared.CacheProvider.Model.Nationality nationality = UPTCache.NationalityService.GetNationalityByNationalityId(NationalityID);
                if (nationality.ExtCode == "TR")
                {
                    if (!string.IsNullOrEmpty(IdentificationNumber) && !string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))  // && !string.IsNullOrEmpty(birthDate))
                    {
                        return 1;
                    }
                    else
                    {
                        if (new OfficeDb().GetUserOfficeCountryCode(App.Params.CurrentUser.Office.OfficeId) != "TR" && IdentificationCardTypeID != Guid.Empty && !string.IsNullOrEmpty(IdentificationNo) && !string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
                        {
                            return 1;
                        }
                        else
                        {
                            return 2;
                        }

                    }
                }
                else
                {
                    if (IdentificationCardTypeID != Guid.Empty && !string.IsNullOrEmpty(IdentificationNo) && !string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName)) // && !string.IsNullOrEmpty(birthDate))
                    {
                        return 1;
                    }
                    else
                    {
                        return 2;
                    }
                }
            }
            else
            {
                return 2;
            }


        }
        [AjaxMethod()]
        public Guid GetCustAccountType()
        {
            /*Ekrandan girilen tüm göndericiler çerçek olarak kaydedilecek.*/

            return ValidationHelper.GetGuid(UPTCache.CustAccountTypeService.GetCustAccountTypeByExtCode("001").CustAccountTypeId); //Gerçek
        }

        [AjaxMethod()]
        public Guid GetCorporatedCustAccountType()
        {
            /*Ekrandan girilen tüm göndericiler çerçek olarak kaydedilecek.*/

            return ValidationHelper.GetGuid(UPTCache.CustAccountTypeService.GetCustAccountTypeByExtCode("002").CustAccountTypeId); //Tüzel
        }




        [AjaxMethod()]
        public string IOMCustomerAutomation(Guid senderId, Guid nationalityId, string cardNumber)
        {
            bool custAccount = false;
            bool uptCard = false;
            bool customerFraudCheck = true;
            string cardResult = string.Empty;


            string nationalityCode = UPT.Shared.CacheProvider.Service.NationalityService.GetNationalityByNationalityId(nationalityId).ExtCode;
            var TryCurrencyId = UPT.Shared.CacheProvider.Service.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId;
            //UPT.Shared.CacheProvider.Model.IdentificatonCardType cardType = UPT.Shared.CacheProvider.Service.IdentificatonCardTypeService.GetIdentificatonCardTypeByExtCode("IOM");

            //Guid IomCardTypeId = cardType != null ? cardType.IdentificatonCardTypeId : Guid.Empty;
            int fraudStatus;

            var sd = new StaticData();
            var tr = sd.GetDbTransaction();
            try
            {
                var senderAfterSaveDb = new TuFactory.Sender.SenderAfterSaveDb();

                /*IOM müşteri segmenti*/
                //senderAfterSaveDb.UpdateIomSender(senderId, IomCardTypeId, ValidationHelper.GetGuid("AB3C328E-F63B-E911-80BE-005056B200B3"));
                senderAfterSaveDb.UpdateIomSender(senderId, ValidationHelper.GetGuid("AB3C328E-F63B-E911-80BE-005056B200B3"));

                fraudStatus = senderAfterSaveDb.GetSenderFraudStatus(senderId);

                if (fraudStatus == CustomerFraudStatus.NotFraud.GetHashCode())
                {
                    customerFraudCheck = senderAfterSaveDb.CustomerFraudCheck(senderId);
                }
                else if (fraudStatus == CustomerFraudStatus.FraudWaiting.GetHashCode() || fraudStatus == CustomerFraudStatus.FraudRejected.GetHashCode())
                {
                    customerFraudCheck = false;
                }
                else if (fraudStatus == CustomerFraudStatus.FraudConfirmed.GetHashCode())
                {
                    customerFraudCheck = true;
                }

                var IsExistsCustAccount = senderAfterSaveDb.GetIsCustAccount(senderId, TryCurrencyId);
                if (!IsExistsCustAccount && customerFraudCheck)
                {
                    /*  CustAccount Tablosuna Kayıt eklenir*/
                    var custAccountId = senderAfterSaveDb.CreateCustAccount(senderId, TryCurrencyId, App.Params.CurrentUser.CorporationId, App.Params.CurrentUser.Office.OfficeId, tr);
                    custAccount = true;

                }

                StaticData.Commit(tr);

                if (!string.IsNullOrEmpty(cardNumber) && customerFraudCheck)
                {
                    var IsExistsUptCard = senderAfterSaveDb.GetIsUptCard(senderId, cardNumber);

                    /*TL hesap için Upt Card tanımlanır, Aktif değil olarak işaretlenir. */
                    uptCard = SaveUptCard(cardNumber, senderId, false);
                    if (uptCard)
                    {

                        /*Sender için içleri boş dokümanlar eklenir.   */
                        CustAccountDb custAccountDb = new CustAccountDb();
                        custAccountDb.CreateIOMCustAccountCardDocument(senderId, nationalityCode);
                    }
                }



                if (!customerFraudCheck)
                {
                    return "Müşteri AML onayında beklemektedir, Onaylandıktan sonra kart tanımı yapabilirsiniz.";
                }


                if (custAccount && uptCard)
                {

                    //var formId = "AC1D3BAE-F995-E611-A984-54442FE8720D";
                    //Response.Redirect(string.Format("~/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid={0}&ObjectId=201100052&mode=1&recid={1}", formId, senderId));
                    //return "Müşteri hesabı ve Kartı açıldı.";

                    return "ok";
                }
                else if (custAccount && !uptCard)
                {
                    return "Müşteri hesabı açıldı, kart oluşturma sırasında hata aldı, Kart Hata: " + cardResult;
                }
                else
                {
                    return "Hesap ve Kart açılması sırasında hata oluştu.";
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex);
                StaticData.Rollback(tr);
                return ex.Message;
                //throw ex;
            }


        }




        private string CreateUptCard(string cardNumber, Guid senderId)
        {
            string result = string.Empty;
            CardClientService _cardClientService = new CardClientService();

            ResponseWrapper<PrepaidApplicationResponse> response = _cardClientService.DoPrepaidApplication(cardNumber,
                                                            senderId,
                                                            App.Params.CurrentUser.SystemUserId,
                                                            UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
                                                            string.Empty,
                                                            null);


            if (response.ResponseStatus == ServiceResponseStatus.Success)
            {
                try
                {
                    var saveResult = SaveUptCard(cardNumber, senderId, true);

                    if (saveResult)
                    {
                        _cardClientService = new CardClientService();
                        var cardInfo = _cardClientService.GetCardInfo(_cardClientService.GetCardId(cardNumber).ServiceResponse);

                        SenderDocumentFactory docService = new SenderDocumentFactory();
                        docService.InsertCardDocumentsIfNecessary(senderId, cardInfo.ServiceResponse.RequiredDocumentCodes);

                    }
                    else
                    {
                        result = "Kart kaydetme sırasında hata oluştu.";
                    }
                }
                catch (Exception ex)
                {
                    LogUtil.WriteException(ex, "SaveUptCard", "UPT Card Operations");
                    result = ex.Message;
                    ShowMessage(ex.Message, EMessageType.Error, ServiceErrorType.ClientError.ToFriendlyErrorType());

                }
            }
            else
            {
                ShowMessage(response.RETURN_DESCRIPTION, EMessageType.Warning, response.ErrorType.ToFriendlyErrorType());
                result = response.RETURN_DESCRIPTION;
            }

            return result;
        }


        private bool SaveUptCard(string cardNumber, Guid senderId, bool isActive)
        {
            bool result = true;

            CardClientService _cardClientService = new CardClientService();

            //var requiredDocs = bankResponse.DOCUMENT_LIST.Where(x => x.IS_OWNER == "H").ToList();

            //string requiredDocuments = string.Empty;

            //if (requiredDocs.Count > 0)
            //{
            //    requiredDocuments = string.Join("#", requiredDocs.Select(x => x.DOC_CODE).ToArray());
            //}

            ResponseWrapper<bool> response = _cardClientService.SaveUptCard(cardNumber,
                3000, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
                10, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
                 0, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
                 0, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
                senderId,
                string.Empty,
                string.Empty,
                string.Empty,
                isActive

                );

            if (!response.ServiceResponse)
            {
                result = false;
                ShowMessage(response.RETURN_DESCRIPTION, EMessageType.Warning, response.ErrorType.ToFriendlyErrorType());
            }
            return result;
        }


        private void ShowMessage(string message, EMessageType messageType, string title)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.MessageType = messageType;
            msgBox.Title = title;
            msgBox.MsgType = MessageBox.EMsgType.Html;
            msgBox.Modal = true;
            msgBox.Show(title, "", message);
        }
    }
    #endregion
}
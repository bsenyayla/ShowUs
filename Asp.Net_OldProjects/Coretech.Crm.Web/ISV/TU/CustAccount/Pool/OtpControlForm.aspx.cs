using Coretech.Crm.Factory;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.OtpManager;
using UPT.SingleServicePoint.Interface;
using UPT.SingleServicePoint.Sms;
using UPTCache = UPT.Shared.CacheProvider.Service;

namespace Coretech.Crm.Web.ISV.TU.CustAccount.Pool
{
    public partial class OtpControlForm : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                hdnSenderId.Value = QueryHelper.GetString("senderId");
                hdnSenderId.SetIValue(QueryHelper.GetString("senderId"));

                hdnSenderpersonId.Value = QueryHelper.GetString("senderPersonId");
                hdnSenderpersonId.SetIValue(QueryHelper.GetString("senderPersonId"));

                hdnCustAccountType.Value = QueryHelper.GetString("custAccountTypeId");
                hdnCustAccountType.SetIValue(QueryHelper.GetString("custAccountTypeId"));

                OtpFactory otp = new OtpFactory();

                DataTable senderDt = new DataTable();

                if (hdnCustAccountType.Value == "001")
                {
                    senderDt = otp.GetSenderById(ValidationHelper.GetGuid(hdnSenderId.Value));
                }
                else if (hdnCustAccountType.Value == "002")
                {
                    senderDt = otp.GetSenderPersonById(ValidationHelper.GetGuid(hdnSenderpersonId.Value));
                }

                if (senderDt.Rows.Count > 0)
                {
                    var phone = ValidationHelper.GetString(senderDt.Rows[0]["new_GSM"]).Trim().Replace(" ", "");
                    var gsmCountryId = ValidationHelper.GetGuid(senderDt.Rows[0]["new_GSMCountryId"]);

                    var gsmCountry = UPTCache.CountryService.GetCountryByCountryId(gsmCountryId);

                    if (gsmCountry == null || gsmCountry.CountryShortCode != "TR")
                    {
                        QScript(String.Format("alert('Otp mesajı gönderilemedi. Gönderici telefon ülke kodu Türkiye olmalıdır.');", ""));
                    }
                    else
                    {

                        if (string.IsNullOrEmpty(phone))
                        {
                            QScript(String.Format("alert('Otp mesajı gönderilemedi. Gönderici GSM bilgisi boş olamaz.');", ""));
                        }
                        else
                        {
                            hdnSenderPhone.Value = phone;
                            hdnSenderPhone.SetIValue(phone);
                            //otp.SendOtp(phone);

                            ISmsFactory smsFactory = new SmsFactory();
                            var sms = smsFactory.Creator(App.Params.CurrentUser.CompanyId.ToString());
                            sms.SendOtpSmsQuickly(phone, otp.GetOtpTextWithCode(phone));


                        }
                    }
                }
                else
                {
                    QScript(String.Format("alert('Otp mesajı gönderilemedi. Gönderici bilgisi bulunamadı.');", ""));
                }

            }
        }

        protected void btnContinue_Click(object sender, AjaxEventArgs e)
        {

            var otpCode = ValidationHelper.GetInteger(senderOtpCode.Value, 0);

            OtpFactory otp = new OtpFactory();

            var result = false;

            result = otp.CheckOtp(hdnSenderPhone.Value, otpCode);

            if (result)
            {
                QScript(String.Format("alert('Doğrulama işleminiz başarı ile tamamlandı. İşleminize devam edebilirsiniz.');", ""));
                QScript("window.parent[1]._new_IsOtpConfirm.checked =1;window.parent.top.R.WindowMng.getActiveWindow().hide();");
            }
            else
            {
                QScript(String.Format("alert('Doğrulama yapılamadı. Yanlış yada geçersiz kod. Lütfen tekrar kod alıp deneyiniz.');", ""));
            }

        }

        protected void btnSendOtp_Click(object sender, AjaxEventArgs e)
        {
            OtpFactory otp = new OtpFactory();
            DataTable senderDt = new DataTable();

            if (string.IsNullOrEmpty(hdnSenderPhone.Value))
            {
                if (hdnCustAccountType.Value == "001")
                {
                    senderDt = otp.GetSenderById(ValidationHelper.GetGuid(hdnSenderId.Value));
                }
                else if (hdnCustAccountType.Value == "002")
                {
                    senderDt = otp.GetSenderPersonById(ValidationHelper.GetGuid(hdnSenderpersonId.Value));
                }

                if (senderDt.Rows.Count > 0)
                {
                    var phone = ValidationHelper.GetString(senderDt.Rows[0]["new_GSM"]).Trim().Replace(" ", "");
                    var gsmCountryId = ValidationHelper.GetGuid(senderDt.Rows[0]["new_GSMCountryId"]);

                    var gsmCountry = UPTCache.CountryService.GetCountryByCountryId(gsmCountryId);

                    if (gsmCountry == null || gsmCountry.CountryShortCode != "TR")
                    {
                        QScript(String.Format("alert('Otp mesajı gönderilemedi. Gönderici telefon ülke kodu Türkiye olmalıdır.');", ""));
                    }
                    else
                    {
                        if (string.IsNullOrEmpty(phone))
                        {
                            QScript(String.Format("alert('Otp mesajı gönderilemedi. Gönderici GSM bilgisi boş olamaz.');", ""));
                        }
                        else
                        {
                            hdnSenderPhone.Value = phone;
                            hdnSenderPhone.SetIValue(phone);
                            //var result = otp.SendOtp(phone);

                            ISmsFactory smsFactory = new SmsFactory();
                            var sms = smsFactory.Creator(App.Params.CurrentUser.CompanyId.ToString());
                            sms.SendOtpSmsQuickly(phone, otp.GetOtpTextWithCode(phone));

                            QScript(String.Format("alert('Otp mesajı yeniden gönderildi.');", ""));
                        }
                    }
                }
                else
                {
                    QScript(String.Format("alert('Otp mesajı gönderilemedi. Gönderici bilgisi bulunamadı.');", ""));
                }
            }
            else
            {
                //otp.SendOtp(hdnSenderPhone.Value);

                ISmsFactory smsFactory = new SmsFactory();
                var sms = smsFactory.Creator(App.Params.CurrentUser.CompanyId.ToString());
                sms.SendOtpSmsQuickly(hdnSenderPhone.Value, otp.GetOtpTextWithCode(hdnSenderPhone.Value));

                QScript(String.Format("alert('Otp mesajı yeniden gönderildi.');", ""));
            }

            QScript(String.Format("RepeatFunction();", ""));

        }
    }
}
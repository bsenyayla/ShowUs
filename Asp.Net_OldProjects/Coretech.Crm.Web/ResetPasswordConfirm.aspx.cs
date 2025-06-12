using Coretech.Crm.Data.Users;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.Data;

namespace Coretech.Crm.Web
{
    public partial class ResetPasswordConfirm : RefleXPage 
    {
        public int LangId = 1055;
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack && !RefleX.IsAjxPostback)
            {
                var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
                LangId = ValidationHelper.GetInteger(loginLangId, 1055);
                btnFinish.Text = CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_BUTTON_FINISH", LangId);
                txtActivationCode.FieldLabel = CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_TEXTBOX_ACTIVATION_CODE", LangId);
                txtUsername.FieldLabel = CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_TEXTBOX_USERNAME", LangId);
                txtUsername.SetValue(QueryHelper.GetString("ID"));
                lblInformation.Text = "<b>" + CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_PLEASE_ENTER_TO_ACTIVATION_CODE", LangId) + "</b>";
            }
        }

        protected void BtnFinishClick(object sender, AjaxEventArgs e)
        {

            var msg = new MessageBox()
            {
                Fn = @"function(btn){window.top.location=window.top.location;}"
            };
            msg.Height = 200;

            if (string.IsNullOrEmpty(txtActivationCode.Value))
            {
                new MessageBox(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_MESSAGE_ACTIVATION_CODE_REQUIRED", LangId));
                return;
            }

            try
            {
                var OtpCreatedOn = TuFactory.Data.SecurityFactory.GetActivationCodeCreatedDateByUsername(txtUsername.Value);
                if (OtpCreatedOn == DateTime.MinValue)
                {
                    MessageBox msgUser = new MessageBox();
                    msgUser.Show(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_MESSAGE_NO_GSM_INFO_FOR_USER_WAS_FOUND", LangId));
                    return;
                }
                else
                {
                    TimeSpan ts = new TimeSpan();
                    ts = DateTime.UtcNow - OtpCreatedOn;
                    int minutes = ts.Minutes;

                    if (minutes > ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("OTP_PASSWORD_TIMEOUT")))
                    {
                        MessageBox msgUser = new MessageBox();
                        msgUser.Show(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_MESSAGE_YOUR_ACTIVATION_CODE_HAS_EXPIRED", LangId));
                        return;
                    }
                }

                DataTable dt = UserDB.UserOtpActivationCodeCheck(txtUsername.Value, ValidationHelper.GetInteger(txtActivationCode.Value, 0));

                if(ValidationHelper.GetInteger(dt.Rows[0]["RESULT"],0)==0)
                {
                    new MessageBox(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_MESSAGE_ACTIVATION_CODE_INVALID", LangId));
                    return;
                }
                if (ValidationHelper.GetInteger(dt.Rows[0]["RESULT"], 0) == -1)
                {
                    msg.Show(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_MESSAGE_YOU_ENTERED_YOUR_ACTIVATION_CODE_3_TIMES_INCORRECTLY", LangId));
                    return;
                }
                SecurityFactory.UserSendPasswordLinkForOtp(txtUsername.Value);
                msg.Show(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_PASSWORD_SENT_TO_YOUR_EMAIL_ADDRESS", LangId));
            }
            catch (Exception ex)
            {
                new MessageBox(ex.Message);
            }
            return;
        }
    }
}
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
    public partial class ResetPassword : RefleXPage
    {
        public int LangId = 1055;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && !RefleX.IsAjxPostback)
            {
                var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
                LangId = ValidationHelper.GetInteger(loginLangId, 1055);
                btnConfirm.Text = CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_BUTTON_CONFIRM", LangId);
                txtUsername.FieldLabel = CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_TEXTBOX_USERNAME", LangId);
                txtMail.FieldLabel = CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_TEXTBOX_MAIL", LangId);
                txtUsername.SetValue(QueryHelper.GetString("ID"));
                RWindow.Title = CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_RESET_PASSWORD_CONFIRM_HEADER_RESET_PASSWORD_CONFIRM", LangId);
                CompanyLogo.Text = "<b>" + CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_RESET_PASSWORD_HEADER_RESET_PASSWORD", LangId) + "</b>";
            }
        }

        protected void BtnConfirmClick(object sender, AjaxEventArgs e)
        {
            if (string.IsNullOrEmpty(txtUsername.Value))
            {
                MessageShow(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_MESSAGE_USERNAME_REQUIRED", LangId));
                return;
            }
            if (string.IsNullOrEmpty(txtMail.Value))
            {
                MessageShow(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_MESSAGE_MAIL_REQUIRED", LangId));
                return;
            }

            try
            {
                DataTable dt = UserDB.UserOtpCheckAndSendSms(txtUsername.Value, txtMail.Value, LangId).Tables[0];
                if(ValidationHelper.GetInteger(dt.Rows[0]["STATUS"],0) != 1)
                {
                    MessageShow(CrmLabel.TranslateMessageNotLogin(ValidationHelper.GetString(dt.Rows[0]["DESCRIPTION"]), LangId));
                    return;
                }
                else
                {
                    if(ValidationHelper.GetString(dt.Rows[0]["DESCRIPTION"]) == "MAIL")
                    {
                        SecurityFactory.UserSendPasswordLinkForOtp(txtUsername.Value);
                        MessageShowSuccess(CrmLabel.TranslateMessageNotLogin("CRM.NEW_CUSTOMMESSAGE_PASSWORD_SENT_TO_YOUR_EMAIL_ADDRESS", LangId));
                        return;
                    }
                    RunJavaScript("RWindow.setUrl('ResetPasswordConfirm.aspx?ID='+txtUsername.getValue()); RWindow.show();");
                }
            }
            catch (Exception ex)
            {
                MessageShow(ex.Message);
            }
            return;
        }

        public static void RunJavaScript(String message)
        {
            ScriptCreater.AddInstanceScript(message);
        }


        public static void MessageShow(String message)
        {
            ScriptCreater.AddInstanceScript(@"R.MessageBox('Error', '" + message.Replace("'", "\"").Replace("\r", "").Replace("\n", "") + "', '', true, R.MessageType.Warning, R.ButtonType.OK, function (btn) {txtUsername.focus(); }, false,400,200);");
        }

        public static void MessageShowSuccess(String message)
        {
            ScriptCreater.AddInstanceScript(@"R.MessageBox('Information', '" + message.Replace("'", "\"").Replace("\r", "").Replace("\n", "") + "', '', true, R.MessageType.Success, R.ButtonType.OK, function (btn) {txtUsername.focus(); }, false,400,200);");
        }
    }
}
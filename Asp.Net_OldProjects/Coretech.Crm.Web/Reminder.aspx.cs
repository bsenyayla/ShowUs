using System;
using Coretech.Crm.Factory;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Users;

public partial class Reminder : RefleXPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && !RefleX.IsAjxPostback)
        {
            var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
            LangId = ValidationHelper.GetInteger(loginLangId, 1055);
            btnLogin.Text = CrmLabel.TranslateMessageNotLogin("LOGIN_LOGIN", LangId);
            txtUsername.FieldLabel = CrmLabel.TranslateMessageNotLogin("LOGIN_USERNAME", LangId);
            txtQuestion.FieldLabel = CrmLabel.TranslateMessageNotLogin("LOGIN_SECURITYQUESTION", LangId);
            txtAnswer.FieldLabel = CrmLabel.TranslateMessageNotLogin("LOGIN_SECURITYANSWER", LangId);
            txtUsername.SetValue(QueryHelper.GetString("ID"));
            txtQuestion.SetValue(UsersFactory.GetSecurityQuestion(QueryHelper.GetString("ID")));
            ScriptCreater.AddInstanceScript("txtAnswer.focus();"); 
        }       
    }
    public int LangId = 1055;

    protected void UserOnEvent(object sender, AjaxEventArgs e)
    {
        txtQuestion.SetValue(UsersFactory.GetSecurityQuestion(txtUsername.Value));
    }

    protected void BtnLoginClick(object sender, AjaxEventArgs e)
    {
        if (string.IsNullOrEmpty(txtUsername.Value))
        {
            new MessageBox(CrmLabel.TranslateMessageNotLogin("KULLANICI_ADINI_GIRINIZ", LangId));
            return;
        }
        if (string.IsNullOrEmpty(txtAnswer.Value))
        {
            new MessageBox(CrmLabel.TranslateMessageNotLogin("GUVENLIK_CEVABINI_GIRINIZ", LangId));
            return;
        }
        try
        {
            var msg = new MessageBox
                          {
                              Fn = @"function(btn){window.top.location=window.top.location;}"
                          };
            
            msg.Show(CrmLabel.TranslateMessageNotLogin("SIFRENIZ_MAILINIZE_GONDERILMISTIR", LangId));
        }
        catch (Exception ex)
        {
            new MessageBox(ex.Message);
        }
        return;
    }

}
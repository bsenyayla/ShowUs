using System.Web.UI.HtmlControls;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.PluginData;
using System.Web;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using System;
using System.Data;
using Coretech.Crm.Factory.Users;

public partial class CreatePassword : RefleXPage
{
    void TranslateMessage(int languageId)
    {
        txtUsername.FieldLabel = CrmLabel.TranslateMessageNotLogin("CRM_USERNAME", languageId);
        txtPassword.FieldLabel = CrmLabel.TranslateMessageNotLogin("CRM_PASSWORDNEW", languageId);
        txtPasswordAgain.FieldLabel = CrmLabel.TranslateMessageNotLogin("CRM_PASSWORDCONTROL", languageId);
        RWindow.Title = CrmLabel.TranslateMessageNotLogin("LOGIN_REMINDPASSWORD", languageId);
        btnLogin.Text = CrmLabel.TranslateMessageNotLogin("LOGIN_LOGIN", languageId);
        question.Value = CrmLabel.TranslateMessageNotLogin("LOGIN_CHANGE_PASSWORD_ARE_YOU_SURE", languageId);
        btnLogin.AjaxEvents.Click.EventMask.Msg = CrmLabel.TranslateMessageNotLogin("LOGIN_LOGING", languageId);
        RegisterResources.RedirectText = CrmLabel.TranslateMessageNotLogin("CRM_REDIRECTING_TEXT", languageId);
    }

    public int LangId = 1055;
    private Guid SystemUserId;
    private string CodeParameter;

    protected void LanguageOnEvent(object sender, AjaxEventArgs e)
    {
        RefleX.DeleteCookie("CrmLanguage");
        RefleX.SetCookie("CrmLanguage", e.ExtraParams["LangId"], 365);
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (App.Params.CurrentUser != null)
            App.Params.CurrentUser = null;
        var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
        LangId = ValidationHelper.GetInteger(loginLangId, 1055);
        if (loginLangId == string.Empty)
        {

            var lf = new LangFactory();
            var ll = lf.GetLanguages(true);
            for (int i = 0; i < ll.Count; i++)
            {
                var td = new HtmlTableCell();
                var lbl = new Label
                {
                    ID = "flagtd_" + i,
                    CustomCss = "x-label-icon-rev",
                    Width = 20,
                    ToolTip = ll[i].RegionName
                };
                lbl.AjaxEvents.Click.Event += LanguageOnEvent;
                lbl.AjaxEvents.Click.ExtraParams.Add(new Parameter("LangId", ll[i].LangId.ToString(), EpMode.Value));
                lbl.AjaxEvents.Click.Success = "document.location.href =document.location.href;";
                if (ll[i].Flag != null)
                    lbl.Icon = (Icon)ll[i].Flag;
                td.Controls.Add(lbl);
                FlagsTr.Cells.Add(td);
            }
        }

        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        CodeParameter = Request.QueryString["Content"];
        StaticData sd = new StaticData();
        string sql = "SELECT new_SystemUserId from new_CreatePasswordHistory where new_UrlCode = @Code AND new_IsUsed = 0";
        sd.AddParameter("@Code", DbType.String, CodeParameter);
        SystemUserId = ValidationHelper.GetGuid(sd.ExecuteScalar(sql), Guid.Empty);
        if (SystemUserId == Guid.Empty)
        {
            MessageBox msgError = new MessageBox()
            {
                Fn = @"function(btn){document.location.href = '" + HTTPUtil.GetWebAppRoot().ToString() + "/Login.aspx?dologin=0';}"
            };
            msgError.Show("INVALID LINK");
        }

        sd = new StaticData();
        sql = "SELECT LanguageId FROM vSystemUser WHERE SystemUserId = @UserId  AND DeletionStateCode = 0";
        sd.AddParameter("@UserId", DbType.Guid, SystemUserId);
        int UserLangId = ValidationHelper.GetInteger(sd.ExecuteScalar(sql), 1055);

        if (!IsPostBack && !RefleX.IsAjxPostback)
        {
            hdnIsFromOtpChannel.SetValue(QueryHelper.GetString("FromOtpChannel"));
            ClientScript.RegisterClientScriptBlock(typeof(string), "GetWebAppRoot", "var GetWebAppRoot='" + HTTPUtil.GetWebAppRoot() + "';", true);

            Session.Abandon();
            Response.Cookies.Add(new HttpCookie("ASP.NET_SessionId", ""));

            var cookie = Request.Cookies["CrmLanguage"];
            if (cookie != null)
            {
                try
                {
                    LangId = Convert.ToInt32(cookie.Value);
                }
                catch (Exception)
                {
                    RefleX.DeleteCookie("CrmLanguage");
                }
                var loginLangId = App.Params.GetConfigKeyValue("LoginLangId", "");
                if (loginLangId != string.Empty)
                    LangId = ValidationHelper.GetInteger(loginLangId, 1055);
            }

            TranslateMessage(UserLangId);
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetValidUntilExpires(false);
            HttpContext.Current.Session.Abandon();
            ScriptCreater.AddInstanceScript("txtUsername.focus();");

        }
    }

    protected void BtnLoginClick(object sender, AjaxEventArgs e)
    {
        try
        {

            if (!string.IsNullOrEmpty(txtUsername.Value))
            {
                Guid UserId = TuFactory.Data.SecurityFactory.GetUserIdByUsername(txtUsername.Value);
                if (UserId != SystemUserId)
                {
                    MessageBox msgUser = new MessageBox();
                    msgUser.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_WRONGUSERNAME));// "Hatalı Kullanıcı");
                    return;
                }
                if (txtPassword.Value != txtPasswordAgain.Value)
                    throw new Exception(CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORD_DOES_NOT_MATCH));

                var uf = new UsersFactory();
                uf.SaveUserPassword(UserId, txtPassword.Value);
                MessageBox msg = new MessageBox(CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORD_CHANGED));
            }
            else
            {
                MessageBox msgUser = new MessageBox();
                msgUser.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_WRONGUSERNAME));// "Hatalı Kullanıcı");
                return;
            }
            StaticData sd = new StaticData();
            string sqlStr = "update new_CreatePasswordHistory set new_IsUsed = 1,	ReturnDate = GETUTCDATE() where new_SystemUserId = @SystemUserId AND new_UrlCode = @CodeParameter";
            sd.AddParameter("@SystemUserId", DbType.Guid, SystemUserId);
            sd.AddParameter("@CodeParameter", DbType.String, CodeParameter);
            sd.ExecuteNonQuery(sqlStr);
            MessageBox msgError = new MessageBox()
            {
                Fn = @"function(btn){document.location.href = '" + HTTPUtil.GetWebAppRoot().ToString() + "/Login.aspx?dologin=0';}"
            };
            msgError.Show("PASSWORD SAVED");
        }
        catch (Exception ex)
        {
            var messageBox = new MessageBox();
            messageBox.Height = 200;
            messageBox.Width = 400;
            messageBox.Show(ex.Message);
        }
    }

}






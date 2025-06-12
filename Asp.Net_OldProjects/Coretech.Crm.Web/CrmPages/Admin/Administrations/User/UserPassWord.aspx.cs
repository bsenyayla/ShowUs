using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Parameters;
using Coretech.Crm.Factory.Users;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;


public partial class CrmPages_Admin_Administrations_User_UserPassWord : AdminPage
{
    void TranslateMessages()
    {
        UserCmp.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_USERNAME);
        password1.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORD);
        password2.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORDNEW);
        password3.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORDCONTROL);
        Save.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        panel1.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORD_CHANGE);
    }
    protected Guid SystemUserId;
    public CrmPages_Admin_Administrations_User_UserPassWord()
    {
        ObjectId = EntityEnum.Systemuser.GetHashCode();
    }

    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

        if (!Page.IsPostBack)
        {
            if (!RefleX.IsAjxPostback)
            {
                DynamicSecurity = DynamicFactory.GetSecurity(ObjectId, App.Params.CurrentUser.SystemUserId);
                if (!(DynamicSecurity.PrvAppend))
                {
                    Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Systemuser DynamicSecurity_PrvAppend");
                }

                UserCmp.Disabled = true;
               
                UserCmp.SetValue(Guid.NewGuid(),App.Params.CurrentUser.FullName);
                var df = new DynamicFactory(ERunInUser.SystemAdmin);
                var de = df.Retrieve((int)EntityEnum.Systemuser, App.Params.CurrentUser.SystemUserId,
                            new string[] { "SecurityPolicyId" });
                var recid = de.GetLookupValue("SecurityPolicyId");
                //EntityEnum.SecurityPolicy
                var readonlyform = ParameterFactory.GetParameterValue("SECURITY_POLICY_READONLYFORM");
                if (ValidationHelper.GetGuid(readonlyform) != Guid.Empty)
                {
                    HiddenSecurityPolicy.AutoLoad.Url =
                        Page.ResolveClientUrl(string.Format("~/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid={0}&ObjectId={1}&recid={2}", readonlyform, (int)EntityEnum.SecurityPolicy, recid));
                }
                else
                {
                    HiddenSecurityPolicy.Visible = false;
                }

            }
        }
    }


    protected void SaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            DynamicSecurity = DynamicFactory.GetSecurity(ObjectId, App.Params.CurrentUser.SystemUserId);
            if (!(DynamicSecurity.PrvAppend))
            {
                Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Systemuser DynamicSecurity_PrvAppend");
            }

            if (!string.IsNullOrEmpty(password1.Value))
            {
                if (password2.Value != password3.Value)
                    throw new Exception(CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORD_DOES_NOT_MATCH));
                var uf = new UsersFactory();
                uf.SaveUserPassword(App.Params.CurrentUser.SystemUserId, password1.Value,password2.Value);
                QScript("alert('" + CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORD_CHANGED) + "');");
                
                QScript(string.Format("top.window.location='{0}';", Page.ResolveClientUrl("~/" + App.Params.GetConfigKeyValue("ApplicationMainForm"))));
            }

        }
        catch (Exception ex)
        {
            var messageBox = new MessageBox();
            messageBox.Show(ex.Message);
        }
    }
}
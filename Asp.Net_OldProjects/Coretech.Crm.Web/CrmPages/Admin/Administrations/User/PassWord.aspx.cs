using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Users;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;

public partial class CrmPages_Admin_Administrations_User_PassWord : AdminPage
{

    void TranslateMessages()
    {
        UserCmp.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_USERNAME);
        password2.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORDNEW);
        password3.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORDCONTROL);
    }
    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        base.OnPreInit(e);
    }

    protected Guid SystemUserId;
    public CrmPages_Admin_Administrations_User_PassWord()
    {
        ObjectId = EntityEnum.Systemuser.GetHashCode();
    }
    void CheckUser()
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete && DynamicSecurity.PrvAppend))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Systemuser PrvCreate,PrvDelete,PrvWrite,PrvAppend");
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var systemUserId = ValidationHelper.GetGuid(QueryHelper.GetString("SystemUserId"));
        
        if (systemUserId == Guid.Empty)
        {    
            systemUserId = App.Params.CurrentUser.SystemUserId;
        }
        else
        {
            UserCmp.Disabled = true;
        }

        DynamicSecurity = DynamicFactory.GetSecurity(ObjectId, systemUserId);
        CheckUser();
        if (!Page.IsPostBack)
        {
            if (!RefleX.IsAjxPostback)
            {
                if (systemUserId != Guid.Empty)
                {
                    var df = new DynamicFactory(ERunInUser.CalingUser);
                    var user = df.Retrieve(EntityEnum.Systemuser.GetHashCode(), systemUserId, new string[] { "FullName", "SystemUserId" });
                    UserCmp.SetValue(systemUserId.ToString().ToUpper(), user.GetStringValue("FullName"));
                }

            }
        }
    }

    protected void SaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var messageBox = new MessageBox();

            Guid systemUserId = ValidationHelper.GetGuid(UserCmp.Value);
            

            DynamicSecurity = DynamicFactory.GetSecurity(ObjectId, ValidationHelper.GetGuid(UserCmp.Value));
            CheckUser();
            if (!string.IsNullOrEmpty(UserCmp.Value))
            {
                if (!string.IsNullOrEmpty(password2.Value))
                {
                    if (password2.Value != password3.Value)
                        throw new Exception(CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORD_DOES_NOT_MATCH));

                    var uf = new UsersFactory();
                    uf.SaveUserPassword(ValidationHelper.GetGuid(UserCmp.Value), password2.Value);

                    messageBox.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORD_CHANGED));
                }
            }
        }
        catch (Exception ex)
        {
            var messageBox = new MessageBox();
            messageBox.Show(ex.Message);
        }
    }
}
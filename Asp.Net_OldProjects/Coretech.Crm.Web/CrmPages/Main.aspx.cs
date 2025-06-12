using System;
using System.Configuration;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Users;

public partial class CrmPages_Main : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack )
        {
            //var myMenuList = MenuFactory.GetNewList();
            TranslateMessages();
            UserCmp.Value = App.Params.CurrentUser.SystemUserId.ToString();
            //foreach (var listMenu in myMenuList)
            //{
            //    var mi = new MenuItem {Text = listMenu.Label};
            //    mi.Listeners.Click.Handler = "ShowEditWindow('','','{" + listMenu.FormId + "}'," + listMenu.ObjectId +
            //                                 ");";
            //    New_menu.Items.Add(mi);
            //}
            Welcome.Text = App.Params.CurrentUser.BusinessUnitIdName + " / " + App.Params.CurrentUser.FullName;
        }
    }
    void TranslateMessages() {
        //Button1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        PnlWest.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_NAVIGATION_NMENU);
        PnlCenter.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_PNLCENTER);
        btnLogout.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_LOGOUT);
        WindowDeleteList.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETELIST);
        BtnDeleteOk.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        WindowAssignList.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGNLIST);
        BtnAssignOk.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN);
        UserCmp.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.SYSTEMUSER_USERNAME);
        MainTitle.Text = App.Params.GetConfigKeyValue("ApplicationName");
        pchange.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_USERPASSWORDCHANGE);
    }
    public class DeleteReturnType
    {
        public string Order;
        public string Result;
        public string ErrorMessage;

    }
    [AjaxMethod(ShowMask = false)]
    public DeleteReturnType GlobalDelete(string order, string recordId, string objectId)
    {
        var ret = new DeleteReturnType {ErrorMessage = "",Order =order, Result = "1"};
        try
        {
            var dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(objectId,0),
                                                     ValidationHelper.GetGuid(recordId));
            if (!dynamicSecurity.PrvDelete)
            {   ret.Result = "0";
                ret.ErrorMessage = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE_NOT_PRV);
            }
            else
            {
                var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);
                dynamicFactory.Delete(ValidationHelper.GetInteger(objectId, 0), ValidationHelper.GetGuid(recordId),false);
                return ret;
            }
        }
        catch (Exception exception)
        {
            ret.Result = "0";
            ret.ErrorMessage = exception.Message;
        }
        return ret;
    }
    protected void StoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var uf = new UsersFactory();
        StoreUser.DataSource = uf.GetUserList();
        StoreUser.DataBind();
    }

    [AjaxMethod(ShowMask = false)]
    public DeleteReturnType GlobalAssign(string order, string recordId, string objectId,string assignTo)
    {
        var ret = new DeleteReturnType { ErrorMessage = "", Order = order, Result = "1" };
        try
        {
            var dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(objectId, 0),
                                                     ValidationHelper.GetGuid(recordId));
            if (!dynamicSecurity.PrvAssign)
            {
                ret.Result = "0";
                ret.ErrorMessage = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN_NOT_PRV);
            }
            else
            {
                var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);
                dynamicFactory.Assign(ValidationHelper.GetInteger(objectId, 0), ValidationHelper.GetGuid(recordId),
                                      ValidationHelper.GetGuid(assignTo));
                return ret;
            }
        }
        catch (Exception exception)
        {
            ret.Result = "0";
            ret.ErrorMessage = exception.Message;
        }
        return ret;
    }
}

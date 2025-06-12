using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using RefleXFrameWork;
using System;
using System.Web.UI;
using TuFactory.Object;

public partial class UserControl_MobileTransactionTypeFormControl : UserControl
{
    Guid recId = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
    private DynamicSecurity DynamicSecurity;

    protected override void OnInit(EventArgs e)
    {
        try
        {
            //DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_CorporatedBlockedApproval.GetHashCode(), null);

            base.OnInit(e);
        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "UserControl_MobileTransactionTypeFormControl.OnInit", "Exception");
            throw ex;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {

        try
        {

            var typeField = Page.FindControl("new_Type_Container") as ComboField;
            var transactionTypeField = Page.FindControl("new_TransactionTypeId_Container") as ComboField;
            var custAccountOperationTypeField = Page.FindControl("new_CustAccountOperationTypeId_Container") as ComboField;

            Guid recId = Guid.Empty;
            var recIdField = Page.FindControl("hdnRecid_Container") as TextField;

            if (recIdField != null)
                 recId = ValidationHelper.GetGuid(recIdField.Value.ToString());

            if (recId != Guid.Empty)
            {
                

                string type = typeField.Value.ToString();

                if (type == "1")
                {
                    transactionTypeField.SetVisible(false);
                    custAccountOperationTypeField.SetVisible(true);
                }
                else if (type == "2")
                {
                    transactionTypeField.SetVisible(true);
                    custAccountOperationTypeField.SetVisible(false);
                }
                else
                {
                    transactionTypeField.SetVisible(false);
                    custAccountOperationTypeField.SetVisible(false);
                }
            }

            typeField.Listeners.Change.Handler = @" var deger = new_Type.value;
                                                    
                                                    if(deger == 1)
                                                   {
                                                        
                                                        document.getElementById('new_TransactionTypeId_Container').style.display = 'block'; 
                                                        document.getElementById('new_CustAccountOperationTypeId_Container').style.display = 'none'; 
                                                        new_CustAccountOperationTypeId.setValue('');
                                                        ExtCode.setValue('');
                                                   }else if(deger == 2){
                                                        document.getElementById('new_TransactionTypeId_Container').style.display = 'none'; 
                                                        document.getElementById('new_CustAccountOperationTypeId_Container').style.display = 'block'; 
                                                        new_TransactionTypeId.setValue('');
                                                        ExtCode.setValue('');
                                                   }else{
                                                        document.getElementById('new_TransactionTypeId_Container').style.display = 'none'; 
                                                        document.getElementById('new_CustAccountOperationTypeId_Container').style.display = 'none';    
                                                        new_TransactionTypeId.setValue('');
                                                        new_CustAccountOperationTypeId.setValue('');
                                                        ExtCode.setValue('');                                          
                                                    } ";

            transactionTypeField.Listeners.Change.Handler = "ExtCode.setValue(_new_TransactionTypeId.value); ";
            custAccountOperationTypeField.Listeners.Change.Handler = "ExtCode.setValue(_new_CustAccountOperationTypeId.value); ";

            /*
            if (!RefleX.IsAjxPostback)
            {
                if (recId != Guid.Empty)
                {
                    var saveButton = Page.FindControl("btnSave_Container") as ToolbarButton;
                    var btnAction = Page.FindControl("btnAction_Container") as ToolbarButton;
                    var saveAsCopyButton = Page.FindControl("btnSaveAsCopy_Container") as ToolbarButton;
                    var deleteButton = Page.FindControl("btnDelete_Container") as ToolbarButton;
                    var btnSaveAndClose = Page.FindControl("btnSaveAndClose_Container") as ToolbarButton;
                    var btnSaveAndNew = Page.FindControl("btnSaveAndNew_Container") as ToolbarButton;
                    var refreshButton = Page.FindControl("btnRefresh_Container") as ToolbarButton;
                    var btnPassive = Page.FindControl("btnPassive_Container") as ToolbarButton;

                    refreshButton.SetVisible(false);
                    refreshButton.SetDisabled(true);
                    btnPassive.SetVisible(false);
                    btnPassive.SetDisabled(true);
                    saveButton.SetVisible(false);
                    saveButton.SetDisabled(true);
                    btnAction.SetVisible(false);
                    btnAction.SetDisabled(true);
                    btnSaveAndNew.SetVisible(false);
                    btnSaveAndNew.SetDisabled(true);
                    saveAsCopyButton.SetVisible(false);
                    saveAsCopyButton.SetDisabled(true);
                    deleteButton.SetVisible(false);
                    deleteButton.SetDisabled(true);
                    btnSaveAndClose.SetDisabled(true);
                    btnSaveAndClose.SetVisible(false);

                    //BasePage.QScript("window.top.R.WindowMng.getActiveWindow().hide();");
                }
            }
            */





        }
        catch (Exception ex)
        {
            LogUtil.WriteException(ex, "UserControl_MobileTransactionTypeFormControl.Page_Load", "Exception");
            throw ex;
        }


    }


}

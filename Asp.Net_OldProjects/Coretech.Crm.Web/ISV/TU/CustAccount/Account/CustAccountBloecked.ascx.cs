using System;
using System.Web.UI;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using TuFactory.Object;
using Coretech.Crm.Web.UI.RefleX;
using System.Web.UI.HtmlControls;
using TuFactory.CustAccount.Business;
using TuFactory.TuUser;
using Coretech.Crm.Factory;
using TuFactory.Object.User;

public partial class CustAccount_Account_CustAccountBloecked : System.Web.UI.UserControl
{
    Guid _recid = Guid.Empty;
    
    protected void Page_Load(object sender, EventArgs e)
    {

        if (!RefleX.IsAjxPostback)
        {
            var deleteButton = Page.FindControl("btnDelete_Container") as ToolbarButton;
            deleteButton.SetVisible(false);
            deleteButton.SetDisabled(true);
            
            if (_recid != Guid.Empty)
            {
                DynamicFactory df = new DynamicFactory(ERunInUser.SystemAdmin);
                DynamicEntity de = df.Retrieve(TuEntityEnum.New_CustAccounts.GetHashCode(), _recid, new[] { "new_BlockedStartDate", "statuscode", "new_IsBlocked", "New_CustAccountsId" });
                if (de.GetDateTimeValue("new_BlockedStartDate") == null || de.GetDateTimeValue("new_BlockedStartDate") == DateTime.MinValue)
                {
                    BlockedType.Value = "1";
                    BlockedAmount.Value = 0;
                    BlockedStartDate.Value = DateTime.Now;
                }


            }
        }
    }
    protected void BlockedTypeChanged(object sender, AjaxEventArgs e)
    {
        if (BlockedType.Value == "1")
        {
            BlockedAmount.SetValue(0);
            BlockedAmount.SetRequirementLevel(RLevel.None);
            BlockedAmount.SetDisabled(true);

        } if (BlockedType.Value == "2")
        {
            BlockedAmount.SetDisabled(false);
            BlockedAmount.SetRequirementLevel(RLevel.BusinessRequired);
        }
    }
    protected void windowBlockedBtnOkClick(object sender, AjaxEventArgs e)
    {
        if (_recid != Guid.Empty)
        {
            DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
            DynamicEntity dem = df.Retrieve(TuEntityEnum.New_CustAccounts.GetHashCode(), _recid, new[] { 
            "new_CustAccountCurrencyId", "new_CorporationId", "new_OfficeId","new_SenderId","new_BlockedStartDate","new_BlockedEndDate","new_BlockedAmount","new_BlockedType","new_CustAccountTypeId"
            }
               );
            var de = new DynamicEntity(TuEntityEnum.New_CustAccountBlockedApproval.GetHashCode());
            de.AddDateTimeProperty("new_BlockedStartDate", BlockedStartDate.Value);
            if (BlockedEndDate.Value.HasValue)
                de.AddDateTimeProperty("new_BlockedEndDate", BlockedEndDate.Value);
            else
                de.AddDateTimeProperty("new_BlockedEndDate", null);

            de.AddDecimalProperty("new_BlockedAmount", BlockedAmount.Value.Value);
            de.AddPicklistProperty("new_BlockedType", ValidationHelper.GetInteger(BlockedType.Value, 1));
            de.AddBooleanProperty("new_IsBlocked", true);
            de.AddLookupProperty("new_CustAccountsId", "", _recid);
            de["new_CustAccountCurrencyId"] = dem["new_CustAccountCurrencyId"];
            de["new_CorporationId"] = dem["new_CorporationId"];
            de["new_OfficeId"] = dem["new_OfficeId"];
            de["new_CustAccountTypeId"] = dem["new_CustAccountTypeId"];
            de["new_SenderId"] = dem["new_SenderId"];
            de.AddStringProperty("new_OperationDescription",BlockDescription.Value);
            de.AddPicklistProperty("new_BlockedConfirmStatus", 1);
            de.AddPicklistProperty("new_BlockedActionType", 1);
            df.Create(TuEntityEnum.New_CustAccountBlockedApproval.GetHashCode(), de);
            BasePage.Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_WAITINGAPPROVAL"));
            //BasePage.Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_BLOCKEDSUCCESSFULL"));
            BasePage.QScript("RefreshParetnGrid(true);");

        }

    }
    protected void windowUnBlockedBtnOkClick(object sender, AjaxEventArgs e)
    {
        if (_recid != Guid.Empty)
        {
            DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
            var de = new DynamicEntity(TuEntityEnum.New_CustAccountBlockedApproval.GetHashCode());

            DynamicEntity dem = df.Retrieve(TuEntityEnum.New_CustAccounts.GetHashCode(), _recid, new[] { 
                "new_CustAccountCurrencyId", "new_CorporationId", "new_OfficeId","new_SenderId","new_BlockedStartDate","new_BlockedEndDate","new_BlockedAmount","new_BlockedDescription","new_BlockedType","new_CustAccountTypeId"
            });

            de.AddBooleanProperty("new_IsBlocked", false);
            de["new_BlockedStartDate"] = dem["new_BlockedStartDate"];
            de["new_BlockedEndDate"] = dem["new_BlockedEndDate"];
            de["new_BlockedAmount"] = dem["new_BlockedAmount"];
            de["new_BlockedType"] = dem["new_BlockedType"];
            de["new_CustAccountCurrencyId"] = dem["new_CustAccountCurrencyId"];
            de["new_CorporationId"] = dem["new_CorporationId"];
            de["new_OfficeId"] = dem["new_OfficeId"];
            de["new_CustAccountTypeId"] = dem["new_CustAccountTypeId"];
            de["new_SenderId"] = dem["new_SenderId"];
            de.AddStringProperty("new_OperationDescription",RBlockDescription.Value);
            de.AddPicklistProperty("new_BlockedConfirmStatus", 1);
            de.AddPicklistProperty("new_BlockedActionType", 2);
            de.AddLookupProperty("new_CustAccountsId", "", _recid);
            df.Create(TuEntityEnum.New_CustAccountBlockedApproval.GetHashCode(), de);
            BasePage.Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_WAITINGAPPROVAL"));
            //BasePage.Alert(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_UNBLOCKEDSUCCESSFULL"));
            BasePage.QScript("RefreshParetnGrid(true);");

        }
    }
    private TuUserApproval _userApproval = null;

    protected override void OnInit(EventArgs e)
    {
        _recid = QueryHelper.GetGuid("recid");
        

        if (!RefleX.IsAjxPostback)
        {
            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
            if (_recid != Guid.Empty)
            {
                DynamicFactory df = new DynamicFactory(ERunInUser.SystemAdmin);
                DynamicEntity de = df.Retrieve(TuEntityEnum.New_CustAccounts.GetHashCode(), _recid, new[] { "statuscode", "new_IsBlocked", "New_CustAccountsId", "new_BlockedAmount", 
                "new_BlockedStartDate", "new_BlockedEndDate", "new_BlockedType", "new_CustAccountCurrencyId","new_SenderId" });


                if (de.GetPicklistValue("statuscode") == 1)
                {
                    RefleXFrameWork.ToolBar editToolbar = Page.FindControl("EditToolbar_Container") as RefleXFrameWork.ToolBar;
                    RefleXFrameWork.ToolbarButton statusButton = new RefleXFrameWork.ToolbarButton();
                    if (editToolbar != null)
                    {
                        #region BlockAccount
                        if (!de.GetBooleanValue("new_IsBlocked"))
                        {
                            statusButton.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_BLOCKED");
                            statusButton.ID = "btnBlocked";
                            statusButton.Listeners.Click.Handler = "showWindowBlocked();";
                            statusButton.Icon = Icon.CoinsDelete;

                        }
                        else
                        {
                            statusButton.Text = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_UNBLOCKED");
                            statusButton.ID = "btnUnBlocked";
                            statusButton.Icon = Icon.CoinsAdd;
                            statusButton.Listeners.Click.Handler = "showWindowUnBlocked();";

                            RBlockedAmount.Value = de.GetDecimalValue("new_BlockedAmount");
                            RBlockedStartDate.Value = de.GetDateTimeValue("new_BlockedStartDate");
                            if (de.GetDateTimeValue("new_BlockedEndDate") != null && de.GetDateTimeValue("new_BlockedEndDate") > DateTime.MinValue)
                                RBlockedEndDate.Value = de.GetDateTimeValue("new_BlockedEndDate");
                            RBlockedType.Value = de.GetPicklistValue("new_BlockedType").ToString();
                            var msg = Page.FindControl("MessageBar") as HtmlControl;
                            if (msg != null)
                            {
                                if (RBlockedType.Value == "1")
                                    pmessage.InnerHtml = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_ACCOUNTISBLOCKED");
                                if (RBlockedType.Value == "2")
                                    pmessage.InnerHtml = CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_ACCOUNTISPARTIALBLOCKED");

                                pmessage.Attributes.Add("class", "warning");
                                msg.Controls.Add(pmessage);
                                msg.Style.Add("display", "block");
                            }
                        }
                        var waitingConfirm = CustAccountBlocked.IsWaitingBlockedConfirm(_recid);
                        if (!waitingConfirm)
                        {
                            if (_userApproval.CustAccountBlockOperator)
                                editToolbar.Items.Insert(editToolbar.Items.Count - 5, statusButton);
                        }
                        else
                        {
                            if (pmessage.InnerHtml != string.Empty)
                                pmessage.InnerHtml += "<br>";
                            pmessage.InnerHtml += CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTS_THEREAREAPPROVAL");
                            pmessage.Attributes.Add("class", "warning");
                            var msg = Page.FindControl("MessageBar") as HtmlControl;
                            msg.Controls.Add(pmessage);
                            msg.Style.Add("display", "block");
                        }
                        #endregion
                        
                    }


                }

            }
        }
        base.OnInit(e);
    }
}
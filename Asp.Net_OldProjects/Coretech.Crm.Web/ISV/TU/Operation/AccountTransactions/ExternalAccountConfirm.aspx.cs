using System;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Object.User;
using TuFactory.TuUser;
using TuFactory.ExternalAccountTransactions;
using TuFactory.Data;
using TuFactory.ExternalAccountTransactions.Objects;
using TuFactory.AccountTransactions;
using TuFactory.AccountTransactions.Objects;

public partial class Operation_External_Account_Confirm : BasePage
{
    #region Variables
    private DynamicSecurity _dynamicSecurityTransfer;
    private DynamicSecurity _dynamicSecurityPayment;
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    private Guid ExternalAccountTransactionId = Guid.Empty;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    #endregion

    private void TranslateMessages()
    { }

    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        _activeUser = ufFactory.GetActiveUser();

        ExternalAccountTransactionId = Guid.Parse(Request.QueryString["recId"].ToString());

        if (!RefleX.IsAjxPostback)
        {
            new_RefNo.SetVisible(false);
            new_RecipientAccountId.SetVisible(false);
            new_SenderAccountId.SetVisible(false);
        }
    }

    public void ButtonConfirmClick(object sender, AjaxEventArgs e)
    {
        try
        {
            //AccountTransactionFactory factory = new AccountTransactionFactory();
            AccountTransactionDb acDb = new AccountTransactionDb();

            QScript("SetCurrentPage();");
            switch (new_ActionType.Value)
            {
                case "1": //Talimatlı İşlem Aktarımı
                    ExternalAccountTransactionFactory.Instance.IntegrateExternalAccountToAccountTransaction(ExternalAccountTransactionId, new_RefNo.Value);

                    break;
                case "2": //Alt Hesaba Para Aktarımı
                    /*Burayı düzeltmek gerekiyot,*/
                    if (new_RecipientAccountId.SelectedItems != null)
                    {
                        if (string.IsNullOrEmpty(new_AccountTransactionTypeId.Value))
                        {
                            ExternalAccountTransactionFactory.Instance.IntegrateExternalAccountToCorporationAccountTransaction(ExternalAccountTransactionId, new_RecipientAccountId.SelectedItems[0]["VALUE"], new_Explanation.Value, Guid.Empty);

                        }
                        else
                        {
                            ExternalAccountTransactionFactory.Instance.IntegrateExternalAccountToCorporationAccountTransaction(ExternalAccountTransactionId, new_RecipientAccountId.SelectedItems[0]["VALUE"], new_Explanation.Value, ValidationHelper.GetGuid(new_AccountTransactionTypeId.Value));

                        }
                    }
                    else
                    {
                        throw new Exception("Lütfen Alıcı hesap seçimlerini yapınız.!");
                    }

                    break;
                case "3": //Upt hesaplarından Alt hesaplara aktarım.
                    if (new_SenderAccountId.SelectedItems != null && new_RecipientAccountId.SelectedItems != null)
                    {
                        ExternalAccountTransactionFactory.Instance.IntegrateExternalAccountToProtectedAccountTransaction(ExternalAccountTransactionId, new_SenderAccountId.SelectedItems[0]["VALUE"], new_RecipientAccountId.SelectedItems[0]["VALUE"]);
                    }
                    else
                    {
                        throw new Exception("Lütfen Hesap seçimlerini yapınız.");
                    }
                    break;

                case "4":
                    throw new Exception("Henüz bu işlemleri yapamazsınız!");

                case "5":
                    throw new Exception("Henüz bu işlemleri yapamazsınız!");

                case "6":
                    throw new Exception("Henüz bu işlemleri yapamazsınız!");

                case "7":
                    ExternalAccountTransactionDb externalAccountTransactionDb = new ExternalAccountTransactionDb();
                    externalAccountTransactionDb.UpdateExternalAccountTransactionOnlyConfirmStatus(ExternalAccountTransactionId, CrmLabel.TranslateMessage("CRM.NEW_EXTERNALACCOUNTTRANSACTION_NO_ACTION"), ExternalAccountConfirmStatus.AksiyonAlınamaz);
                    break;

                case "8": //Kasaya para yükleme
                    ExternalAccountTransactionFactory.Instance.IntegrateExternalAccountToCashAccountTransaction(ExternalAccountTransactionId, new_RefNo.Value);
                    break;

                case "9": //Kasa devri
                    ExternalAccountTransactionFactory.Instance.IntegrateExternalAccountToCashSubmitAccountTransaction(ExternalAccountTransactionId, new_RefNo.Value);
                    break;


                default:
                    throw new Exception(CrmLabel.TranslateMessage("CRM.NEW_EXTERNALACCOUNTTRANSACTION_TRANSFER_FAILED"));

            }

            var result = ExternalAccountTransactionFactory.Instance.GetExternalAccountTransactionDetail(ExternalAccountTransactionId);
            //var result = factory.GetExternalAccountTransactionDetail(ExternalAccountTransactionId);
            var m = new MessageBox { Width = 400, Height = 180 };
            m.Show(result.TransferResult);

            QScript("RefreshParetnGridForExternalAccount(true);");
            //QScript("RefreshParetnGrid(true);");
        }
        catch (Exception ex)
        {
            var m = new MessageBox { Width = 400, Height = 180 };
            m.Show(CrmLabel.TranslateMessage("CRM.NEW_EXTERNALACCOUNTTRANSACTION_TRANSFER_FAILED"), ex.Message);
            return;
        }
    }

    public void ComboField_ActionTypeChange(object sender, AjaxEventArgs e)
    {
        new_RefNo.SetVisible(false);
        new_RecipientAccountId.SetVisible(false);
        new_SenderAccountId.SetVisible(false);
        new_Explanation.SetVisible(false);

        switch (new_ActionType.Value)
        {
            case "1":
            case "8":
            case "9":
                new_RefNo.SetVisible(true);
                new_RecipientAccountId.Clear();
                new_SenderAccountId.Clear();
                new_RecipientAccountId.SetVisible(false);
                new_SenderAccountId.SetVisible(false);
                new_Explanation.SetVisible(false);
                break;
            case "2":
                new_RefNo.SetVisible(false);
                new_RecipientAccountId.Clear();
                new_SenderAccountId.Clear();
                new_SenderAccountId.SetVisible(false);
                new_RecipientAccountId.SetVisible(true);
                new_Explanation.SetVisible(true);
          
                break;
            case "3":
                new_RefNo.SetVisible(false);
                new_RecipientAccountId.Clear();
                new_SenderAccountId.Clear();
                new_RecipientAccountId.SetVisible(true);
                new_SenderAccountId.SetVisible(true);
                new_Explanation.SetVisible(false);

                break;
        }
    }

    protected void RecipientAccountLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"spTuGetProblemExternalAccountTransactionAccountList";

        var like = new_RecipientAccountId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("AccountLookupView");
        var gpc = new GridPanelCreater();

        var start = new_RecipientAccountId.Start();
        var limit = new_RecipientAccountId.Limit();

        StaticData sd = new StaticData();
        sd.AddParameter("ExternalAccountTransactionId", DbType.Guid, ValidationHelper.GetGuid(ExternalAccountTransactionId));
        sd.AddParameter("ActionType", DbType.Int32, ValidationHelper.GetInteger(new_ActionType.Value, 2));

        DataSet ds = sd.ReturnDatasetSp(strSql);
        if (ds.Tables.Count > 0)
        {
            new_RecipientAccountId.TotalCount = ds.Tables[0].Rows.Count;
            new_RecipientAccountId.DataSource = ds.Tables[0];
            new_RecipientAccountId.DataBind();
        }
    }

    protected void SenderAccountLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"spTuGetUptPrivilegeAccounts";

        var like = new_SenderAccountId.Query();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("AccountLookupView");
        var gpc = new GridPanelCreater();

        var start = new_SenderAccountId.Start();
        var limit = new_SenderAccountId.Limit();

        StaticData sd = new StaticData();
        sd.AddParameter("ExternalAccountTransactionId", DbType.Guid, ValidationHelper.GetGuid(ExternalAccountTransactionId));
        sd.AddParameter("AccountType", DbType.Int32, 7 /*7 Upt Koruma Hesabı*/);

        DataSet ds = sd.ReturnDatasetSp(strSql);
        if (ds.Tables.Count > 0)
        {
            new_SenderAccountId.TotalCount = ds.Tables[0].Rows.Count;
            new_SenderAccountId.DataSource = ds.Tables[0];
            new_SenderAccountId.DataBind();
        }
    }

    protected void AccountTransactionTypeLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"spTuGetAccountTransactionTypeByCode";

        var like = new_AccountTransactionTypeId.Query();
        var gpc = new GridPanelCreater();

        var start = new_SenderAccountId.Start();
        var limit = new_SenderAccountId.Limit();

        StaticData sd = new StaticData();
        sd.AddParameter("Code", DbType.String, "HH07");
        DataSet ds = sd.ReturnDatasetSp(strSql);
        if (ds.Tables.Count > 0)
        {
            new_AccountTransactionTypeId.TotalCount = ds.Tables[0].Rows.Count;
            new_AccountTransactionTypeId.DataSource = ds.Tables[0];
            new_AccountTransactionTypeId.DataBind();
        }
    }

    protected void AccountChangeOnEvent(object sender, AjaxEventArgs e)
    {
        PrivilegedAccount RecipientAccount = AccountTransactionFactory.Instance.GetPrivilegedAccountDetail(new_RecipientAccountId.Value);

        /*AccountType = 9 -> Upt Gelir hesapları , ActionType = 2 -> Upt Alt hesaplarına aktarım*/
        if ((RecipientAccount.AccountType == 9) && new_ActionType.Value == "2")
        {
            new_AccountTransactionTypeId.SetVisible(true);

            string strSql = @"spTuGetAccountTransactionTypeByCode";
            StaticData sd = new StaticData();
            sd.AddParameter("Code", DbType.String, "HH07");
            DataSet ds = sd.ReturnDatasetSp(strSql);
            if (ds.Tables.Count > 0)
            {
                new_AccountTransactionTypeId.SetValue(ValidationHelper.GetGuid(ds.Tables[0].Rows[0]["ID"]));
            }

        }
        else
        {
            new_AccountTransactionTypeId.Clear();
            new_AccountTransactionTypeId.SetVisible(false);
        }
    }
}
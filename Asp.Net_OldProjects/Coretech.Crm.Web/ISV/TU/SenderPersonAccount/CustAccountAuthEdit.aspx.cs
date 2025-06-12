using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.SenderPerson;

public partial class Sender_CustAccountAuthEdit : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ValidationHelper.GetInteger(new_AuthType.Value) != 3)
        {
            btnAddTransactionType.SetVisible(false);
        }
        else
        {
            btnAddTransactionType.SetVisible(true);
        }

        if (!RefleX.IsAjxPostback)
        {


            if (!string.IsNullOrEmpty(QueryHelper.GetString("CustAccountAuthId")))
            {
                CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();
                Guid CustAccountAuthId = ValidationHelper.GetGuid(QueryHelper.GetString("CustAccountAuthId"));

                var data = custAccountAuthFactory.GetCustAccountAuth(CustAccountAuthId);

                hdnCustAccountAuthID.SetValue(CustAccountAuthId);
                hdnConfirmStatus.SetValue(data.ConfirmStatus);
                new_SenderId.SetValue(data.SenderId);
                new_CustAccountId.SetValue(data.CustAccountId);
                new_AuthType.SetValue(data.AuthType);
                new_SenderPersonId.SetValue(data.SenderPersonId);


                var authType = ValidationHelper.GetInteger(data.AuthType);

                if (authType != 3)
                {
                    GridPanelTransactionType.SetVisible(false);
                }
            }
            else
            {
                Guid custAccountId = ValidationHelper.GetGuid(QueryHelper.GetString("custAccountId"));
                Guid senderId = ValidationHelper.GetGuid(QueryHelper.GetString("senderId"));
                Guid senderPersonId = ValidationHelper.GetGuid(QueryHelper.GetString("senderPersonId"));

                new_SenderId.SetValue(senderId);
                new_CustAccountId.SetValue(custAccountId);
                new_SenderPersonId.SetValue(senderPersonId);
            }

           
        }
    }

    protected void btnSave_Click(object sender, AjaxEventArgs e)
    {
        CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();
        try
        {
            var sd = new StaticData();
            var tr = sd.GetDbTransaction();
            if (string.IsNullOrEmpty(hdnCustAccountAuthID.Value))
            {

                var custAccountAuthId = custAccountAuthFactory.CreateCustAccountAuth(new TuFactory.Object.CustAccountAuth.CustAccountAuth
                {
                    AuthType = ValidationHelper.GetInteger(new_AuthType.Value, 0),
                    CustAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value),
                    SenderId = ValidationHelper.GetGuid(new_SenderId.Value),
                    SenderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value)
                }, tr);

                 var custAccountAuthApprovePoolId = custAccountAuthFactory.CreateCustAccountAuthApprovePool(custAccountAuthId, 1, 2, ValidationHelper.GetInteger(new_AuthType.Value, 0), tr);

                tr.Commit();

                hdnCustAccountAuthID.SetValue(custAccountAuthId.ToString());

                if (ValidationHelper.GetInteger(new_AuthType.Value) == 3)
                {
                    windowTransactionsInfo.Show();
                }
            }
            else
            {
                if (ValidationHelper.GetInteger(hdnConfirmStatus.Value) == 3) //bilgi güncelleme
                {
                    custAccountAuthFactory.CreateCustAccountAuthApprovePool(ValidationHelper.GetGuid(hdnCustAccountAuthID.Value), 3, 2, ValidationHelper.GetInteger(new_AuthType.Value, 0), tr);
                }
                else //bilgi düzenleme
                {
                    custAccountAuthFactory.CreateCustAccountAuthApprovePool(ValidationHelper.GetGuid(hdnCustAccountAuthID.Value), 2, 2, ValidationHelper.GetInteger(new_AuthType.Value, 0), tr);
                }
                custAccountAuthFactory.UpdateCustAccountAuthStatus(2, ValidationHelper.GetGuid(hdnCustAccountAuthID.Value), tr);
                tr.Commit();

                //BasePage.QScript("window.top.R.WindowMng.getActiveWindow().hide();");

                MessageBox msgBox = new MessageBox();
                msgBox.Show("Kayıt Güncellendi, Yeniden onaya gönderildi.");
            }
        }
        catch (Exception ex)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }
    }

    protected void btnNew_Click(object sender, AjaxEventArgs e)
    {
        new_AuthType.Clear();
        new_CustAccountId.Clear();
        new_SenderId.Clear();
        new_SenderPersonId.Clear();
        hdnCustAccountAuthID.Clear();
        hdnCustAccountAuthID.Value = "";
        GridPanelTransactionType.Clear();
    }

    protected void GrdTransactionTypeList(object sender, AjaxEventArgs e)
    {
        CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();

        DataTable dt = custAccountAuthFactory.GetCustAccountAuthDetail(ValidationHelper.GetGuid(hdnCustAccountAuthID.Value));

        GridPanelTransactionType.DataSource = dt;
        GridPanelTransactionType.DataBind();
    }

    protected void GrdTransactionAllTypeList(object sender, AjaxEventArgs e)
    {

        CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();
        var sd = new StaticData();

        DataTable dt = custAccountAuthFactory.GetTransactionTypeList();

        GridPanelAllTransactionTypes.DataSource = dt;
        GridPanelAllTransactionTypes.DataBind();

    }

    protected void AuthTypeChange(object sender, AjaxEventArgs e)
    {
        var custAccountAuthId = ValidationHelper.GetString(hdnCustAccountAuthID.Value);    
        var actionType = ValidationHelper.GetInteger(new_AuthType.Value);

        if (actionType == 3 && !string.IsNullOrEmpty(custAccountAuthId))
        {
            btnAddTransactionType.SetVisible(true);
            btnAddTransactionType.Visible = true;
            GridPanelTransactionType.Reload();
            GridPanelTransactionType.SetVisible(true);
        }
        else
        {
            btnAddTransactionType.SetVisible(false);
            btnAddTransactionType.Visible = false;
            GridPanelTransactionType.Clear();
        }

    }

    protected void btnInsertCustAccountDetails_Click(object sender, AjaxEventArgs e)
    {
        CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();

        try
        {
           var custAccountAuthId = ValidationHelper.GetGuid(hdnCustAccountAuthID.Value);
           //var authType = custAccountAuthFactory.GetCustAccountAuthType(custAccountAuthId);

           // if(authType !=3)
           // {
           //     MessageBox msgBox = new MessageBox();
           //     msgBox.Show("Lütfen bu işlem için önce ana kaydı güncelleyin.");
           //     return;
           // }

            var degerler = ((CheckSelectionModel)GridPanelAllTransactionTypes.SelectionModel[0]).SelectedRows;

            if (degerler != null)
            {
                var sd = new StaticData();
                var tr = sd.GetDbTransaction();

                custAccountAuthFactory.DeleteCustAccountAuthDetails(ValidationHelper.GetGuid(custAccountAuthId), tr); //önceki yetkilendirmelerin tümü siliniyor

                foreach (var row in degerler) //seçilen tüm kayıtlar insert ediliyor
                {
                    var TransactionTypeId = ValidationHelper.GetGuid(row.ID);
                    custAccountAuthFactory.CreateCustAccountAuthDetail(custAccountAuthId, TransactionTypeId, tr);
                }

                if (ValidationHelper.GetInteger(hdnConfirmStatus.Value) == 3) //bilgi güncelleme
                {
                    custAccountAuthFactory.CreateCustAccountAuthApprovePool(ValidationHelper.GetGuid(hdnCustAccountAuthID.Value), 3, 2, ValidationHelper.GetInteger(new_AuthType.Value, 0), tr);
                }
                else //bilgi düzenleme
                {
                    custAccountAuthFactory.CreateCustAccountAuthApprovePool(ValidationHelper.GetGuid(hdnCustAccountAuthID.Value), 2, 2, ValidationHelper.GetInteger(new_AuthType.Value, 0), tr);
                }

                tr.Commit();
            }

            GridPanelAllTransactionTypes.ClearSelection();
            GridPanelTransactionType.Reload();
        }
        catch (Exception ex)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }
        
    }

    protected void btnDelete_Click(object sender, AjaxEventArgs e)
    {
        if (string.IsNullOrEmpty(hdnCustAccountAuthID.Value))
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show("Kayıt Bulunamadı");
        }
        else
        {
            CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();
            var sd = new StaticData();
            var tr = sd.GetDbTransaction();
            custAccountAuthFactory.DeleteCustAccountAuth(ValidationHelper.GetGuid(hdnCustAccountAuthID.Value), tr);

            tr.Commit();

            MessageBox msgBox = new MessageBox();
            msgBox.Show("Kayıt Silindi");
        }

    }

    protected void btnAddTransactionType_OnClick(object sender, AjaxEventArgs e)
    {
        windowTransactionsInfo.Show();
    }

}
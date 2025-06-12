using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.Object.CustAccountAuth;
using TuFactory.SenderPerson;

public partial class Sender_CustAccountAuthApprove : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            var custAccountAuthApproveId = QueryHelper.GetGuid("CustAccountAuthApproveId");
            CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();

            var data = custAccountAuthFactory.GetCustAccountAuthApprove(custAccountAuthApproveId);

            hdnCustAccountAuthApproveId.SetValue(custAccountAuthApproveId);
            hdnConfirmStatus.SetValue(data.ConfirmStatus);
            hdnCustAccountAuthId.SetValue(data.CustAccountAuthId);
            hdnActionType.SetValue(data.ActionType);
            new_SenderId.SetValue(data.SenderId);
            new_CustAccountId.SetValue(data.CustAccountId);
            new_AuthType.SetValue(data.AuthType);
            new_SenderPersonId.SetValue(data.SenderPersonId);
            CreatedBy.SetValue(data.CreatedBy);

            var authType = ValidationHelper.GetInteger(data.AuthType);

            if (authType != 3)
            {
                GridPanelTransactionType.SetVisible(false);
            }
        }
    }

    protected void btnReject_Click(object sender, AjaxEventArgs e)
    {
        //if (ValidationHelper.GetGuid(CreatedBy.Value) == App.Params.CurrentUser.SystemUserId)
        //{
        //    MessageBox msgBox = new MessageBox();
        //    msgBox.Show("Bu işlemi yapmaya yetkiniz yoktur.");
        //    return;
        //}


        var sd = new StaticData();

        var tr = sd.GetDbTransaction();


        try
        {
            CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();

            custAccountAuthFactory.UpdateCustAccountAuthStatus(4, ValidationHelper.GetGuid(hdnCustAccountAuthId.Value), tr);

            custAccountAuthFactory.ConfirmApprove(ValidationHelper.GetGuid(hdnCustAccountAuthApproveId.Value), ValidationHelper.GetInteger(hdnActionType.Value, 0), 4, tr);

            tr.Commit();

            btnApprove.SetVisible(false);
            btnReject.SetVisible(false);

            MessageBox msgBox = new MessageBox();
            msgBox.Show("Talep Reddedildi");
        }
        catch (Exception ex)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }
    }

    protected void btnApprove_Click(object sender, AjaxEventArgs e)
    {
        MessageBox msgBox = new MessageBox();

        //if (ValidationHelper.GetGuid(CreatedBy.Value) == App.Params.CurrentUser.SystemUserId)
        //{
        //    msgBox.Show("Bu işlemi yapmaya yetkiniz yoktur.");
        //    return;
        //}

        try
        {
            var sd = new StaticData();

            CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();

            var tr = sd.GetDbTransaction();
            var authType = ValidationHelper.GetInteger(new_AuthType.Value,0);
            switch (ValidationHelper.GetInteger(hdnActionType.Value))
            {
                case 1: //kayıt oluşturma onayı

                    custAccountAuthFactory.UpdateCustAccountAuthStatus(3, ValidationHelper.GetGuid(hdnCustAccountAuthId.Value), tr);

                    custAccountAuthFactory.ConfirmApprove(ValidationHelper.GetGuid(hdnCustAccountAuthApproveId.Value), 1, 3, tr);

                    tr.Commit();

                    msgBox.Show("Oluşturma Kaydı Onaylandı.");

                    btnApprove.SetVisible(false);
                    btnReject.SetVisible(false);

                    break;
                case 2: //bilgi düzenleme onayı

                    if (authType != 3)
                    {
                        custAccountAuthFactory.DeleteCustAccountAuthDetails(ValidationHelper.GetGuid(hdnCustAccountAuthId.Value), tr);
                    }

                    custAccountAuthFactory.ConfirmApprove(ValidationHelper.GetGuid(hdnCustAccountAuthApproveId.Value), 2, 3, tr);

                    custAccountAuthFactory.UpdateCustAccountAuthStatus(3, ValidationHelper.GetGuid(hdnCustAccountAuthId.Value), tr);

                    custAccountAuthFactory.UpdateCustAccountAuth(new CustAccountAuth { AuthType = authType, CustAccountAuthId = ValidationHelper.GetGuid(hdnCustAccountAuthId.Value) }, tr);

                    tr.Commit();

                    msgBox.Show("Düzenlenen Kayıt Onaylandı.");

                    btnApprove.SetVisible(false);
                    btnReject.SetVisible(false);

                    break;
                case 3: //bilgi güncelleme onayı

                    if (authType != 3)
                    {
                        custAccountAuthFactory.DeleteCustAccountAuthDetails(ValidationHelper.GetGuid(hdnCustAccountAuthId.Value), tr);
                    }

                    custAccountAuthFactory.UpdateCustAccountAuthStatus(3, ValidationHelper.GetGuid(hdnCustAccountAuthId.Value), tr);

                    custAccountAuthFactory.ConfirmApprove(ValidationHelper.GetGuid(hdnCustAccountAuthApproveId.Value), 3, 3, tr);

                    custAccountAuthFactory.UpdateCustAccountAuth(new CustAccountAuth { AuthType = authType, CustAccountAuthId = ValidationHelper.GetGuid(hdnCustAccountAuthId.Value) }, tr);
                    tr.Commit();

                    msgBox.Show("Güncellenen Kayıt Onaylandı.");

                    btnApprove.SetVisible(false);
                    btnReject.SetVisible(false);

                    break;
            }
        }
        catch (Exception ex)
        {
            msgBox.Show(ex.Message);
        }
    }
    protected void GrdTransactionTypeList(object sender, AjaxEventArgs e)
    {
        CustAccountAuthFactory custAccountAuthFactory = new CustAccountAuthFactory();

        DataTable dt = custAccountAuthFactory.GetCustAccountAuthDetail(ValidationHelper.GetGuid(hdnCustAccountAuthId.Value));

        GridPanelTransactionType.DataSource = dt;
        GridPanelTransactionType.DataBind();
    }
}
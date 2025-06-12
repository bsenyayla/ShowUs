using System;
using Coretech.Crm.Web.UI.RefleX;

using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Factory.Crm.Dynamic;
using TuFactory.Object;
using RefleXFrameWork;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using TuFactory.Confirm;

public partial class TransferEdit_TransferEditMessage3rd : BasePage
{
    private void TranslateMessage()
    {
        //btnSenderEditUpdate.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_BTN_SENDEREDIT");

    }

    private DynamicSecurity DynamicSecurity;
    protected void Page_Load(object sender, EventArgs e)
    {
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_Transfer.GetHashCode(), null);
        if (!(DynamicSecurity.PrvAppend))
            Response.End();

        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
            New_TransferId.Value = QueryHelper.GetString("recid");

            SetWindowTitle("CRM.NEW_TRANSFER_EDITMESSAGEPAGE");
            LoadData();

        }
    }

    protected void LoadData()
    {
        if (!string.IsNullOrEmpty(New_TransferId.Value))
        {
            var df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
            var tr = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(),
                                              ValidationHelper.GetGuid(New_TransferId.Value),
                                              DynamicFactory.RetrieveAllColumns);


            new_EditMessage3rd.FillDynamicEntityData(tr);
            TransferTuRef.FillDynamicEntityData(tr);
            

        }

    }

    protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var de = new DynamicEntity(TuEntityEnum.New_Transfer.GetHashCode());

            if (!string.IsNullOrEmpty(New_TransferId.Value))
                de.AddKeyProperty("New_TransferId", ValidationHelper.GetGuid(New_TransferId.Value));

            de.AddStringProperty("new_EditMessage3rd", ValidationHelper.GetString(new_EditMessage3rd.Value));
            var df = new DynamicFactory(ERunInUser.CalingUser);
            df.UpdateWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), de);

            var confirm = new ConfirmFactory();
            confirm.TransferEditMessage(ValidationHelper.GetGuid(New_TransferId.Value));



        }
        catch (CrmException ex)
        {
            e.Message = ex.ErrorMessage;
            e.Success = false;
        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }
}
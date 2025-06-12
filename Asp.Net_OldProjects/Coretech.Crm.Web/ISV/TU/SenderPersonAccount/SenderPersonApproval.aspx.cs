using ApiFactory.SystemUserManager;
using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data.Common;
using TuFactory.SenderPerson;

public partial class Sender_SenderPersonApproval : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            var senderpersonApproveId = QueryHelper.GetString("senderpersonApproveId");
            var actionType = QueryHelper.GetString("actionType");

            SenderPersonFactory senderpersonfactory = new SenderPersonFactory();

            var dt = senderpersonfactory.GetSenderPersonPendingApproval(ValidationHelper.GetGuid(senderpersonApproveId));

            New_SenderPersonApprovePoolId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["New_SenderPersonApprovePoolId"]));
            new_NationalityID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_NationalityID"]));
            new_SenderIdendificationNumber1.Value = ValidationHelper.GetString(dt.Rows[0]["new_SenderIdendificationNumber1"]);
            new_Name.Value = ValidationHelper.GetString(dt.Rows[0]["new_Name"]);
            new_MiddleName.Value = ValidationHelper.GetString(dt.Rows[0]["new_MiddleName"]);
            new_LastName.Value = ValidationHelper.GetString(dt.Rows[0]["new_LastName"]);
            new_GSM.Value = ValidationHelper.GetString(dt.Rows[0]["new_GSM"]);
            new_E_Mail.Value = ValidationHelper.GetString(dt.Rows[0]["new_E_Mail"]);
            new_GSMCountryId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_GSMCountryId"]));
            new_SenderPersonId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_SenderPersonId"]));
            new_HomeCountry.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_HomeCountry"]));
            new_ConfirmStatus.Value = ValidationHelper.GetString(dt.Rows[0]["new_ConfirmStatus"]);
            new_MobilUserId.Value = ValidationHelper.GetString(dt.Rows[0]["new_MobilUserId"]);
            UserName.Value = ValidationHelper.GetString(dt.Rows[0]["UserName"]);
            CreatedBy.Value = ValidationHelper.GetString(dt.Rows[0]["CreatedBy"]);
            new_ActionType.Value = actionType;
        }
    }

    protected void btnReject_Click(object sender, AjaxEventArgs e)
    {
        if(ValidationHelper.GetGuid(CreatedBy.Value) == App.Params.CurrentUser.SystemUserId)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show("Bu işlemi yapmaya yetkiniz yoktur.");
            return;
        }


        var sd = new StaticData();

        var tr = sd.GetDbTransaction();


        try
        {
            SenderPersonFactory senderpersonfactory = new SenderPersonFactory();

            senderpersonfactory.UpdateSenderpersonStatus(4, ValidationHelper.GetGuid(new_SenderPersonId.Value), tr);

            senderpersonfactory.ConfirmApprove(ValidationHelper.GetGuid(New_SenderPersonApprovePoolId.Value), ValidationHelper.GetInteger(new_ActionType.Value), 4, tr);

            tr.Commit();

            btnApprove.SetVisible(false);
            btnReject.SetVisible(false);

            MessageBox msgBox = new MessageBox();
            msgBox.Show("Talep Rededildi");
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

        if (ValidationHelper.GetGuid(CreatedBy.Value) == App.Params.CurrentUser.SystemUserId)
        {
            msgBox.Show("Bu işlemi yapmaya yetkiniz yoktur.");
            return;
        }

        var sd = new StaticData();

        SenderPersonFactory senderpersonfactory = new SenderPersonFactory();

        var tr = sd.GetDbTransaction();
      
        try
        {
            switch (ValidationHelper.GetInteger(new_ActionType.Value))
            {
                case 1: //kullanıcı oluşturma onayı
                    if (string.IsNullOrEmpty(UserName.Value))
                    {
                        var systemUserId = CreateUser(new TuFactory.Object.SenderPerson.SenderPerson
                        {
                            Email = new_E_Mail.Value,
                            Gsm = new_GSM.Value,
                            Name = new_Name.Value,
                            MiddleName = new_MiddleName.Value,
                            LastName = new_LastName.Value,
                            HomeCountryId = ValidationHelper.GetGuid(new_HomeCountry.Value)
                        }, tr);

                        senderpersonfactory.UpdateSenderPersonMobileUserId(ValidationHelper.GetGuid(new_SenderPersonId.Value), systemUserId, tr);
                    }

                    senderpersonfactory.UpdateSenderpersonStatus(3, ValidationHelper.GetGuid(new_SenderPersonId.Value), tr);

                    senderpersonfactory.ConfirmApprove(ValidationHelper.GetGuid(New_SenderPersonApprovePoolId.Value), 1, 3, tr);

                    tr.Commit();
             
                    msgBox.Show("Kullanıcı Oluşturma Kaydı Onaylandı.");

                    btnApprove.SetVisible(false);
                    btnReject.SetVisible(false);

                    break;
                case 2: //bilgi düzenleme onayı

                    senderpersonfactory.UpdateSenderPerson(new TuFactory.Object.SenderPerson.SenderPerson
                    {
                        SenderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value),
                        Email = new_E_Mail.Value,
                        Gsm = new_GSM.Value,
                        LastName = new_LastName.Value,
                        MiddleName = new_MiddleName.Value,
                        Name = new_Name.Value,
                        SenderIdendificationNumber1 = new_SenderIdendificationNumber1.Value,
                        GSMCountryId = ValidationHelper.GetGuid(new_GSMCountryId.Value),
                        NationalityId = ValidationHelper.GetGuid(new_NationalityID.Value),
                        HomeCountryId = ValidationHelper.GetGuid(new_HomeCountry.Value),
                    }, tr);


                    if (string.IsNullOrEmpty(UserName.Value))
                    {
                        var systemUserId = CreateUser(new TuFactory.Object.SenderPerson.SenderPerson
                        {
                            Email = new_E_Mail.Value,
                            Gsm = new_GSM.Value,
                            Name = new_Name.Value,
                            MiddleName = new_MiddleName.Value,
                            LastName = new_LastName.Value,
                            HomeCountryId = ValidationHelper.GetGuid(new_HomeCountry.Value)
                        }, tr);

                        senderpersonfactory.UpdateSenderPersonMobileUserId(ValidationHelper.GetGuid(new_SenderPersonId.Value), systemUserId, tr);
                    }

                    senderpersonfactory.ConfirmApprove(ValidationHelper.GetGuid(New_SenderPersonApprovePoolId.Value), 2, 3, tr);

                    senderpersonfactory.UpdateSenderpersonStatus(3, ValidationHelper.GetGuid(new_SenderPersonId.Value), tr);

                    tr.Commit();

                    msgBox.Show("Kullanıcı Kaydı Onaylandı.");

                    btnApprove.SetVisible(false);
                    btnReject.SetVisible(false);

                    break;
                case 3: //bilgi güncelleme onayı

                    senderpersonfactory.UpdateSenderPerson(new TuFactory.Object.SenderPerson.SenderPerson
                    {
                        SenderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value),
                        Email = new_E_Mail.Value,
                        Gsm = new_GSM.Value,
                        LastName = new_LastName.Value,
                        MiddleName = new_MiddleName.Value,
                        Name = new_Name.Value,
                        SenderIdendificationNumber1 = new_SenderIdendificationNumber1.Value,
                        GSMCountryId = ValidationHelper.GetGuid(new_GSMCountryId.Value),
                        NationalityId = ValidationHelper.GetGuid(new_NationalityID.Value),
                        HomeCountryId = ValidationHelper.GetGuid(new_HomeCountry.Value),
                    }, tr);

                    senderpersonfactory.UpdateSenderPersonMobileUserInfo(new TuFactory.Object.SenderPerson.SenderPerson
                    {
                        SenderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value),
                        LastName = new_LastName.Value,
                        MiddleName = new_MiddleName.Value,
                        Name = new_Name.Value,
                        Email = new_E_Mail.Value,
                        Gsm = new_GSM.Value
                    }, tr);

                    senderpersonfactory.UpdateSenderpersonStatus(3, ValidationHelper.GetGuid(new_SenderPersonId.Value), tr);
                    senderpersonfactory.ConfirmApprove(ValidationHelper.GetGuid(New_SenderPersonApprovePoolId.Value), 3, 3, tr);

                    tr.Commit();

                    msgBox.Show("Güncelleme Kaydı Onaylandı.");

                    btnApprove.SetVisible(false);
                    btnReject.SetVisible(false);

                    break;
                case 4: //iptal Onayı
                    senderpersonfactory.DeleteSenderPersonMobileUser(ValidationHelper.GetGuid(new_SenderPersonId.Value), tr);
                    senderpersonfactory.UpdateSenderpersonStatus(4, ValidationHelper.GetGuid(new_SenderPersonId.Value), tr);
                    senderpersonfactory.ConfirmApprove(ValidationHelper.GetGuid(New_SenderPersonApprovePoolId.Value), 4, 3, tr);
                    tr.Commit();

                    msgBox.Show("İptal Kaydı Onaylandı.");

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

    private Guid CreateUser(TuFactory.Object.SenderPerson.SenderPerson senderPerson, DbTransaction tr)
    {
        SenderPersonFactory senderpersonfactory = new SenderPersonFactory();
        SystemUserFactory systemUserFactory = new SystemUserFactory();

        var userCode = senderpersonfactory.GenerateUserName(tr);

        var user = systemUserFactory.AddOrUpdate(new TuFactory.Domain.Api.Models.SystemUser
        {
            FirstName = senderPerson.Name,
            MiddleName = senderPerson.MiddleName,
            LastName = senderPerson.LastName,
            InternalEMailAddress = senderPerson.Email,
            MobilePhone = senderPerson.Gsm,
            new_UserCountryId = senderPerson.HomeCountryId,
            UserName = userCode,
            LanguageId = 1033, //şimdilik sadece türkçe destekliyor değiştirilecek
            CustomerTypeId = ValidationHelper.GetGuid("5ACA7E23-5EA2-E511-A26C-848F69C4A66C")//tüzel
        }, tr);

        var systemUserId = ValidationHelper.GetGuid(user.Rows[0]["SystemUserId"].ToString());

        if (systemUserId == Guid.Empty)
        {
            throw new Exception(user.Rows[0]["Message"].ToString());
        }

        UserName.SetValue(userCode);
        new_MobilUserId.SetValue(systemUserId);

        return systemUserId;
    }
}



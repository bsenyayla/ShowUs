using ApiFactory.SystemUserManager;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data.Common;
using TuFactory.Data;
using TuFactory.Object.SenderPerson;
using TuFactory.Sender;
using TuFactory.SenderPerson;

public partial class Sender_SenderPersonEdit : BasePage
{
    private string recid;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            recid = QueryHelper.GetString("recid");

            if (!string.IsNullOrEmpty(recid))
            {
                var senderPersonId = ValidationHelper.GetGuid(recid);

                SenderPersonFactory senderpersonfactory = new SenderPersonFactory();

                var dt = senderpersonfactory.GetSenderPerson(senderPersonId);

                new_NationalityID.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_NationalityID"]));
                new_SenderIdendificationNumber1.Value = ValidationHelper.GetString(dt.Rows[0]["new_SenderIdendificationNumber1"]);
                new_Name.Value = ValidationHelper.GetString(dt.Rows[0]["new_Name"]);
                new_MiddleName.Value = ValidationHelper.GetString(dt.Rows[0]["new_MiddleName"]);
                new_LastName.Value = ValidationHelper.GetString(dt.Rows[0]["new_LastName"]);
                new_GSM.Value = ValidationHelper.GetString(dt.Rows[0]["new_GSM"]);
                new_SenderId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_SenderId"]));
                new_E_Mail.Value = ValidationHelper.GetString(dt.Rows[0]["new_E_Mail"]);
                new_GSMCountryId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_GSMCountryId"]));
                new_SenderPersonId.SetValue(ValidationHelper.GetGuid(senderPersonId));
                new_HomeCountry.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["new_HomeCountry"]));
                new_ConfirmStatus.Value = ValidationHelper.GetString(dt.Rows[0]["new_ConfirmStatus"]);
                new_MobilUserId.Value = ValidationHelper.GetString(dt.Rows[0]["new_MobilUserId"]);
                UserName.Value = ValidationHelper.GetString(dt.Rows[0]["UserName"]);
                IsDisabled.Value = ValidationHelper.GetString(dt.Rows[0]["IsDisabled"]);

                var confirmStatus = ValidationHelper.GetInteger(dt.Rows[0]["new_ConfirmStatus"]);

                if (confirmStatus == 2)
                {
                    btnDisable.Visible = false;
                }

                if (confirmStatus == 3)
                {
                    btnSendMail.Visible = true;
                }   
            }
        }
    }

    protected void btnSearch_Click(object sender, AjaxEventArgs e)
    {
        var sf = new SenderFactory();
        new_Name.Clear();
        new_MiddleName.Clear();
        new_LastName.Clear();

        if(string.IsNullOrEmpty(new_SenderIdendificationNumber1.Value) || string.IsNullOrEmpty(new_NationalityID.Value))
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show("sorgulama için kimlik no ve uyru zorunludur");
            return;
        }

        try
        {
            var person = sf.GetKpsData(new_SenderIdendificationNumber1.Value, ValidationHelper.GetGuid(new_NationalityID.Value));

            new_SenderIdendificationNumber1.SetValue(person.new_SenderIdendificationNumber1);
            new_Name.SetValue(person.new_Name);
            new_MiddleName.SetValue(person.new_MiddleName);
            new_LastName.SetValue(person.new_LastName);
            hdnComeFromKps.SetValue(person.new_cameFromKps);
        }
        catch (Exception ex)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }
    }

    protected void btnSave_Click(object sender, AjaxEventArgs e)
    {
        SenderPersonFactory senderpersonfactory = new SenderPersonFactory();

        try
        {

            var validationResult = ValidateSenderPerson();

            if (!validationResult)
            {
                throw new Exception("Lütfen Tüm Zorunlu alanları doldurun.");
            }

            var sd = new StaticData();
            var tr = sd.GetDbTransaction();

            if (string.IsNullOrEmpty(ValidationHelper.GetString(new_SenderPersonId.Value)))
            {

                var senderPersonId = senderpersonfactory.SaveSenderPerson(new SenderPerson
                {
                    Email = new_E_Mail.Value,
                    Gsm = new_GSM.Value,
                    LastName = new_LastName.Value,
                    MiddleName = new_MiddleName.Value,
                    Name = new_Name.Value,
                    SenderId = ValidationHelper.GetGuid(new_SenderId.Value),
                    SenderIdendificationNumber1 = new_SenderIdendificationNumber1.Value,
                    GSMCountryId = ValidationHelper.GetGuid(new_GSMCountryId.Value),
                    ComeFromKps = ValidationHelper.GetBoolean(hdnComeFromKps.Value, false),
                    NationalityId = ValidationHelper.GetGuid(new_NationalityID.Value),
                    HomeCountryId = ValidationHelper.GetGuid(new_HomeCountry.Value)
                }, tr);


                senderpersonfactory.SendApprove(senderPersonId, 1, 2, new_Name.Value, new_MiddleName.Value, new_LastName.Value, new_E_Mail.Value, new_GSM.Value, tr);

                tr.Commit();

                new_SenderPersonId.SetValue(senderPersonId);

               // BasePage.QScript("window.top.R.WindowMng.getActiveWindow().hide();");

                MessageBox msgBox = new MessageBox();
                msgBox.Show("Kaydetme İşlemi Başarılı");
              
            }
            else
            {
                if(string.IsNullOrEmpty(UserName.Value)) //bilgi düzenleme
                {
                    senderpersonfactory.SendApprove(ValidationHelper.GetGuid(new_SenderPersonId.Value), 2, 2, new_Name.Value, new_MiddleName.Value, new_LastName.Value, new_E_Mail.Value, new_GSM.Value, tr);

                }
                else //bilgi güncelleme
                {
                    senderpersonfactory.SendApprove(ValidationHelper.GetGuid(new_SenderPersonId.Value), 3, 2, new_Name.Value, new_MiddleName.Value, new_LastName.Value, new_E_Mail.Value, new_GSM.Value, tr);
                }

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
        new_NationalityID.Clear();
        new_SenderIdendificationNumber1.Clear();
        new_Name.Clear();
        new_MiddleName.Clear();
        new_LastName.Clear();
        new_GSM.Clear();
        new_SenderId.Clear();
        new_E_Mail.Clear();
        new_GSMCountryId.Clear();
        new_SenderPersonId.Clear();
        new_ConfirmStatus.Clear();
        new_HomeCountry.Clear();
        UserName.Clear();
    }

    protected void btnDisable_Click(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();

        var tr = sd.GetDbTransaction();

        try
        {
            SenderPersonFactory senderpersonfactory = new SenderPersonFactory();

            senderpersonfactory.SendApprove(ValidationHelper.GetGuid(new_SenderPersonId.Value), 4, 2, new_Name.Value, new_MiddleName.Value, new_LastName.Value, new_E_Mail.Value, new_GSM.Value, tr);

            tr.Commit();

            btnDisable.SetVisible(false);

            MessageBox msgBox = new MessageBox();
            msgBox.Show("Kullanıcı iptal işlemi onaya gönderildi");
        }
        catch (Exception ex)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }        
    }

    protected void btnSendMail_Click(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();

        try
        {

            if (string.IsNullOrEmpty(UserName.Value))
            {
                throw new Exception("Bu kayıta ait kullanıcı bulunamadı.");
            }

            SecurityFactory.UserSendPasswordLink(UserName.Value, false);

        }
        catch (Exception ex)
        {
            MessageBox msgBox = new MessageBox();
            msgBox.Show(ex.Message);
        }
    }

    private bool ValidateSenderPerson()
    {
        if (string.IsNullOrEmpty(new_Name.Value))
        {
            return false;
        }
        if (string.IsNullOrEmpty(new_LastName.Value))
        {
            return false;
        }
        if (string.IsNullOrEmpty(new_E_Mail.Value))
        {
            return false;
        }
        if (string.IsNullOrEmpty(new_GSM.Value))
        {
            return false;
        }
        if (string.IsNullOrEmpty(new_HomeCountry.Value))
        {
            return false;
        }
        if (string.IsNullOrEmpty(new_SenderIdendificationNumber1.Value))
        {
            return false;
        }
        if (string.IsNullOrEmpty(new_SenderId.Value))
        {
            return false;
        }
        if (string.IsNullOrEmpty(new_GSMCountryId.Value))
        {
            return false;
        }
        return true;
    }

}



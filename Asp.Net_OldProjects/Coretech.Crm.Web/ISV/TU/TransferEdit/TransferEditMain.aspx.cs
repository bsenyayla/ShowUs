using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Plugin;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Object;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using Coretech.Crm.PluginData;
using TuFactory.Integration;

public partial class Transfer_TransferEditMain : BasePage
{
    private void TranslateMessage()
    {
        btnSenderEditUpdate.Text = CrmLabel.TranslateMessage("CRM.NEW_TRANSFER_BTN_SENDEREDIT");

    }
    private DynamicSecurity DynamicSecurity;

    protected void Page_Load(object sender, EventArgs e)
    {
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_TransferEdit.GetHashCode(), null);
        if (!(DynamicSecurity.PrvAppend))
            Response.End();

        if (!RefleX.IsAjxPostback)
        {
            TranslateMessage();
            New_TransferId.Value = QueryHelper.GetString("recid");
            New_TransferEditId.Value = QueryHelper.GetString("New_TransferEditId");
            //SetWindowTitle("CRM.NEW_TRANSFEREDIT_EDITPAGE");
            LoadData();
            new_RecipientGSMCountryId.Listeners.Change.Handler = "document.getElementById('_new_RecipientGSM').value = new_RecipientGSMCountryId.selectedRecord.new_TelephoneCode;";
        }
    }

    protected void new_TransactionTargetOptionIDOnEvent(object sender, AjaxEventArgs e)
    {
        const string strSql = @"
select distinct 
    new_TransactionTargetOptionId as ID, 
    new_TransactionTargetOptionId, 
    new_TransactionTargetOptionIdName as VALUE, 
    new_TransactionTargetOptionIdName as TransactionTargetOption
    from tvNew_TargetOptionTransactionType(@systemuser) t
    Where 1=1
and t.DeletionStateCode = 0
        ";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("HEDEF_ISLEM_SECENEGI_LOOKUP");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_TransactionTargetOptionID.Start();
        var limit = new_TransactionTargetOptionID.Limit();
        var spList = new List<CrmSqlParameter>
                         {
                                 new CrmSqlParameter
                                     {
                                         Dbtype = DbType.Guid,
                                         Paramname = "systemuser",
                                         Value = App.Params.CurrentUser.SystemUserId
                                     }
                         };
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_TransactionTargetOptionID.TotalCount = cnt;
        new_TransactionTargetOptionID.DataSource = t;
        new_TransactionTargetOptionID.DataBind();
    }

    protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        var df = new DynamicFactory(ERunInUser.CalingUser);
        try
        {
            //SENDER50KARAKTER
            if (string.IsNullOrEmpty(ValidationHelper.GetString(new_EftBranch.Value, string.Empty)))
            {
                switch (fieldValidator())
                {
                    case -1: //alıcı adı 50den fazla
                        CrmException exR = new CrmException(CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_RECIPIENTNAME_MUST_LESS_THEN_50"));
                        var mR = new MessageBox { Height = 220 };
                        mR.Show(exR.Message);
                        throw exR;
                        break;
                    case -2: //gönderici adı 50den fazla
                        CrmException exS = new CrmException(CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_SENDER_NAME_TOO_LONG"));
                        var mS = new MessageBox { Height = 220 };
                        mS.Show(exS.Message);
                        throw exS;
                        break;
                    default:
                        break;
                }
                int fieldValidatorResult = fieldValidator();
                if (fieldValidatorResult != 0)
                {
                    if (fieldValidatorResult == -1)
                    {

                    }
                }
            }
            var i3rd = new TuFactory.Integration3rd.Integration3Rd();
            TuFactory.Integrationd3rdLayer.Integrationd3rd Integrator = i3rd.GetIntegratorByTransferId(ValidationHelper.GetGuid(New_TransferId.Value));
            if (Integrator != null && !Integrator.CanIntegrateChangeTransfer)
            {
                var m = new MessageBox { Height = 220 };
                m.Show(CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_NO_EDITING_PROCESS_DEFINED_FOR_THIS_CORPORATION"));
                return;
            }

            //if (string.IsNullOrEmpty(new_RecipientMotherName.Value) && string.IsNullOrEmpty(new_RecipientFatherName.Value))
            //{
            //    var msg = CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED");
            //    var m = new MessageBox { Width = 400 };
            //    m.Show(string.Format(msg, new_RecipientMotherName.FieldLabel + "/" + new_RecipientFatherName.FieldLabel));
            //    return;
            //}


            string key = App.Params.GetConfigKeyValue("CORPORATION_FTP_AKB_CODES", string.Empty);
            if (!string.IsNullOrEmpty(key))
            {
                StaticData data = new StaticData();
                data.AddParameter("new_IsTransactionFileEditOut", DbType.Boolean, false);
                data.AddParameter("new_TransferId", DbType.Guid, ValidationHelper.GetGuid(New_TransferId.Value));
                DataTable dt = data.ReturnDataset(@"Select new_CorporationCode,new_IsTransactionFileOut from vNew_Transfer(nolock) t
                                    inner join vNew_Corporation(nolock) co
                                    on t.new_RecipientCorporationId = co.New_CorporationId
                                    where t.New_TransferId = @new_TransferId").Tables[0];
                if (dt.Rows.Count > 0)
                {
                    if (key.Contains(dt.Rows[0]["new_CorporationCode"].ToString()))
                    {
                        if (!Convert.ToBoolean(dt.Rows[0]["new_IsTransactionFileOut"]))
                        {
                            var msg = CrmLabel.TranslateMessage("CRM.NEW_TRANSFEREDIT_FATE_DOES_NOT_FILE");
                            var m = new MessageBox { Width = 400 };
                            m.Show(string.Format(msg));
                            return;
                        }
                    }
                }
            }
            if (new_RecipientBirthDate.Value != null)
            {
                int yas = 0;
                yas = getYas(ValidationHelper.GetDate(new_RecipientBirthDate.Value));

                if (yas < 18)
                {
                    var msg = string.Format(CrmLabel.TranslateMessage("CRM.NEW_PAYMENT_BIRTHDATE_ERROR"), 18);
                    var m = new MessageBox { Width = 400 };
                    m.Show(string.Format(msg));
                    return;
                }
            }



            StaticData data2 = new StaticData();
            data2.AddParameter("TransferId", DbType.Guid, ValidationHelper.GetGuid(New_TransferId.Value));
            DataTable dt2 = data2.ReturnDataset(@"SELECT new_RecipientName,new_RecipientMiddleName,new_RecipientLastName,new_RecipientGSM
                                                   FROM vNew_Transfer T (NoLock) 
                                                WHERE T.New_TransferId = @TransferId ").Tables[0];


            string recipientName        = dt2.Rows[0]["new_RecipientName"].ToString();
            string recipientMiddleName  = dt2.Rows[0]["new_RecipientMiddleName"].ToString();
            string recipientLastName    = dt2.Rows[0]["new_RecipientLastName"].ToString();
            string recipientGSM         = dt2.Rows[0]["new_RecipientGSM"].ToString();

            var trans = (new StaticData()).GetDbTransaction();
            var de = new DynamicEntity(TuEntityEnum.New_TransferEdit.GetHashCode());
            TuFactory.Encryption.ValidationCryptFactory crypt = new TuFactory.Encryption.ValidationCryptFactory();

            if (!string.IsNullOrEmpty(New_TransferEditId.Value))
            {
                de.AddKeyProperty("New_TransferEditId", ValidationHelper.GetGuid(New_TransferEditId.Value));
            }

            de.AddLookupProperty("new_TransferId", "", ValidationHelper.GetGuid(New_TransferId.Value));
            de.AddLookupProperty("new_EftCity", "", ValidationHelper.GetGuid(new_EftCity.Value));
            de.AddLookupProperty("new_EftBank", "", ValidationHelper.GetGuid(new_EftBank.Value));
            de.AddLookupProperty("new_EftBranch", "", ValidationHelper.GetGuid(new_EftBranch.Value));
            de.AddBooleanProperty("new_IbanisNotKnown", ValidationHelper.GetBoolean(new_IbanisNotKnown.Checked));
            de.AddStringProperty("new_RecipientIBAN", ValidationHelper.GetString(new_RecipientIBAN.Value));
            de.AddStringProperty("new_RecipientAccountNumber", ValidationHelper.GetString(new_RecipientAccountNumber.Value));
            de.AddStringProperty("new_RecipientGSM", ValidationHelper.GetString(new_RecipientGSM.Value));
            de.AddStringProperty("new_RecipientFatherName", ValidationHelper.GetString(new_RecipientFatherName.Value));
            de.AddStringProperty("new_RecipientMotherName", ValidationHelper.GetString(new_RecipientMotherName.Value));
            //de.AddStringProperty("new_RecipientHomeTelephone", ValidationHelper.GetString(new_RecipientHomeTelephone.Value));
            //de.AddStringProperty("new_RecipientWorkTelephone", ValidationHelper.GetString(new_RecipientWorkTelephone.Value));
            de.AddStringProperty("new_RecipientName", crypt.EncryptInString(ValidationHelper.GetString(new_RecipientName.Value)));
            de.AddStringProperty("new_RecipientMiddleName", crypt.EncryptInString(ValidationHelper.GetString(new_RecipientMiddleName.Value)));
            de.AddStringProperty("new_RecipientLastName", crypt.EncryptInString(ValidationHelper.GetString(new_RecipientLastName.Value)));
            de.AddStringProperty("new_RecipientEmail", ValidationHelper.GetString(new_RecipientEmail.Value));
            de.AddStringProperty("new_RecipienNickName", crypt.EncryptInString(ValidationHelper.GetString(new_RecipienNickName.Value)));
            de.AddStringProperty("new_RecipientAddress", ValidationHelper.GetString(new_RecipientAddress.Value));
            de.AddLookupProperty("new_RecipientCountryID", "", ValidationHelper.GetGuid(new_RecipientCountryID.Value));
            de.AddLookupProperty("new_RecipientGSMCountryId", "", ValidationHelper.GetGuid(new_RecipientGSMCountryId.Value));
            de.AddStringProperty("new_RecipientCardNumber", ValidationHelper.GetString(new_RecipientCardNumber.Value));
            de.AddDateTimeProperty("new_RecipientBirthDate", ValidationHelper.GetDate(new_RecipientBirthDate.Value));
            de.AddLookupProperty("new_EftPaymentMethodID", "", ValidationHelper.GetGuid(new_EftPaymentMethodID.Value));
            de.AddLookupProperty("new_TransactionTargetOptionID", "", ValidationHelper.GetGuid(new_TransactionTargetOptionID.Value));
            de.AddLookupProperty("new_SenderID", "", ValidationHelper.GetGuid(new_SenderID.Value));
            de.AddStringProperty("new_SerialNumber", GetTransferSerialNumber(ValidationHelper.GetGuid(New_TransferId.Value)));



            de.AddStringProperty("new_RecipientNameOld", ValidationHelper.GetString(recipientName));
            de.AddStringProperty("new_RecipientMiddleNameOld", ValidationHelper.GetString(recipientMiddleName));
            de.AddStringProperty("new_RecipientLastNameOld", ValidationHelper.GetString(recipientLastName));
            de.AddStringProperty("new_RecipientGSMOld", ValidationHelper.GetString(recipientGSM));

            df.GetBeginTrans(trans);
            Guid retId = Guid.Empty;
            if (string.IsNullOrEmpty(New_TransferEditId.Value))
            {
                retId = df.Create("New_TransferEdit", de);

                New_TransferEditId.SetValue(retId);
                //var det = new DynamicEntity(TuEntityEnum.New_Transfer.GetHashCode());
                //det.AddLookupProperty("new_TransferEditId", "new_TransferEditId", retId);
                //det.AddKeyProperty("New_TransferId", ValidationHelper.GetGuid(New_TransferId.Value));
                //df.UpdateWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), det);
            }
            else
            {
                df.Update("New_TransferEdit", de);
            }
            /* Aynı işlem başka kullanıcı tarafından ikinci kez düzeltildiğinde Onay havuzunda kendi düzetmesinini görüyordu.
             * Üstteki kod böyleydi. Şuan her seferinde modifiedBy set edilsin diye update dışa alındı */
            
            var det = new DynamicEntity(TuEntityEnum.New_Transfer.GetHashCode());
            det.AddLookupProperty("new_TransferEditId", "new_TransferEditId", (retId == Guid.Empty ? ValidationHelper.GetGuid(New_TransferEditId.Value) : retId));
            det.AddKeyProperty("New_TransferId", ValidationHelper.GetGuid(New_TransferId.Value));
            df.UpdateWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), det);

            /* Otomasyon için transfer tekrar güncelleniyor */
            StaticData sd = new StaticData();
            sd.AddParameter("new_IsTransactionFileEditOut", DbType.Boolean, false);
            sd.AddParameter("new_TransferId", DbType.Guid, ValidationHelper.GetGuid(New_TransferId.Value));
            sd.ExecuteNonQuery("Update vNew_Transfer Set new_IsTransactionFileEditOut = @new_IsTransactionFileEditOut Where new_TransferId = @new_TransferId", trans);

            var cf = new ConfirmFactory();

            var config = new PluginBaseConfig { ActivePage = Page, DynamicEntity = de };

            cf.CreateConfirmLineAmlChecked(config, trans);

            df.CommitTrans();

            StaticData sdt = new StaticData();
            sdt.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            sdt.AddParameter("TransferId", DbType.Guid, ValidationHelper.GetGuid(New_TransferId.Value));
            sdt.AddParameter("ConfirmStatusId", DbType.Guid, Guid.Empty);
            sdt.AddParameter("PaymentId", DbType.Guid, DBNull.Value);
            sdt.AddParameter("TransferEditId", DbType.Guid, ValidationHelper.GetGuid(String.IsNullOrEmpty(New_TransferEditId.Value) ? retId.ToString() : New_TransferEditId.Value));
            sdt.ExecuteNonQuerySp("spTUCreateTransactionHistory");

            TuFactory.Utility.ReportParamWriter.UpdateReportRecipientParameter(
            ValidationHelper.GetGuid(New_TransferId.Value),
            (ValidationHelper.GetString(new_RecipientName.Value) + " " + (string.IsNullOrEmpty(ValidationHelper.GetString(new_RecipientMiddleName.Value)) ? string.Empty :
                ValidationHelper.GetString(new_RecipientMiddleName.Value) + " ") + ValidationHelper.GetString(new_RecipientLastName.Value)),
            trans);

        }
        catch (CrmException ex)
        {
            df.RollbackTrans();
            e.Message = ex.ErrorMessage;
            e.Success = false;
        }
        catch (Exception ex)
        {
            df.RollbackTrans();
            e.Message = ex.Message;
            e.Success = false;
        }
    }


    /* Bu Methodu yazmamın nedeni Transferin Seri Nosu ile TransferEdit' in aynı olmasından kaynaklı */
    private string GetTransferSerialNumber(Guid transferId)
    {
        string result = string.Empty;
        try
        {
            var sd = new StaticData();
            sd.AddParameter("new_TransferId", DbType.Guid, transferId);
            result = sd.ReturnDataset("Select new_SerialNumber from vNew_Transfer(Nolock) t Where t.New_TransferId=@new_TransferId").Tables[0].Rows[0][0].ToString();
        }
        catch (Exception)
        {
        }
        return result;
    }


    protected void LoadData()
    {
        TuFactory.Encryption.ValidationCryptFactory cryptor = new TuFactory.Encryption.ValidationCryptFactory();
        if (!string.IsNullOrEmpty(New_TransferEditId.Value))
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin) { ActivePage = Page };
            var tr = df.RetrieveWithOutPlugin(TuEntityEnum.New_TransferEdit.GetHashCode(), ValidationHelper.GetGuid(New_TransferEditId.Value), DynamicFactory.RetrieveAllColumns);
       
            new_RecipientCountryID.FillDynamicEntityData(tr);
            new_TransactionTargetOptionID.FillDynamicEntityData(tr);

            new_RecipientGSM.FillDynamicEntityData(tr);
            new_RecipientFatherName.FillDynamicEntityData(tr);
            new_RecipientMotherName.FillDynamicEntityData(tr);
            //new_RecipientHomeTelephone.FillDynamicEntityData(tr);
            //new_RecipientWorkTelephone.FillDynamicEntityData(tr);
            new_RecipientName.FillDynamicEntityData(tr);
            new_RecipientMiddleName.FillDynamicEntityData(tr);
            //new_ConfirmStatus.FillDynamicEntityData(tr);
            new_RecipientLastName.FillDynamicEntityData(tr);
            new_RecipientEmail.FillDynamicEntityData(tr);
            new_RecipienNickName.FillDynamicEntityData(tr);
            new_RecipientAddress.FillDynamicEntityData(tr);
            new_RecipientBirthDate.FillDynamicEntityData(tr);
            new_IbanisNotKnown.FillDynamicEntityData(tr);
            new_EftPaymentMethodID.FillDynamicEntityData(tr);
            new_RecipientGSMCountryId.FillDynamicEntityData(tr);
            new_EftCity.FillDynamicEntityData(tr);
            new_EftBank.FillDynamicEntityData(tr);
            new_EftBranch.FillDynamicEntityData(tr);
            new_RecipientIBAN.FillDynamicEntityData(tr);
            new_RecipientAccountNumber.FillDynamicEntityData(tr);
            new_SenderID.FillDynamicEntityData(tr);
            new_RecipientIDChangeOnEvent(null, new AjaxEventArgs());

            new_RecipienNickName.SetValue(cryptor.DecryptInString(new_RecipienNickName.Value));
            new_RecipientLastName.SetValue(cryptor.DecryptInString(new_RecipientLastName.Value));
            new_RecipientMiddleName.SetValue(cryptor.DecryptInString(new_RecipientMiddleName.Value));
            new_RecipientName.SetValue(cryptor.DecryptInString(new_RecipientName.Value));
            return;
        }
        if (!string.IsNullOrEmpty(New_TransferId.Value))
        {
            var df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
            var tr = df.RetrieveWithOutPlugin(TuEntityEnum.New_Transfer.GetHashCode(), ValidationHelper.GetGuid(New_TransferId.Value), DynamicFactory.RetrieveAllColumns);

            new_RecipientCountryID.FillDynamicEntityData(tr);
            new_TransactionTargetOptionID.FillDynamicEntityData(tr);
            //new_ConfirmStatus.FillDynamicEntityData(tr);
            new_RecipientGSM.FillDynamicEntityData(tr);
            new_RecipientFatherName.FillDynamicEntityData(tr);
            new_RecipientMotherName.FillDynamicEntityData(tr);
            //new_RecipientHomeTelephone.FillDynamicEntityData(tr);
            //new_RecipientWorkTelephone.FillDynamicEntityData(tr);
            new_RecipientName.FillDynamicEntityData(tr);
            new_RecipientMiddleName.FillDynamicEntityData(tr);
            new_RecipientLastName.FillDynamicEntityData(tr);
            new_RecipientEmail.FillDynamicEntityData(tr);
            new_RecipienNickName.FillDynamicEntityData(tr);
            new_RecipientAddress.FillDynamicEntityData(tr);
            new_RecipientBirthDate.FillDynamicEntityData(tr);
            new_IbanisNotKnown.FillDynamicEntityData(tr);
            new_RecipientGSMCountryId.FillDynamicEntityData(tr);
            new_EftPaymentMethodID.FillDynamicEntityData(tr);
            new_EftCity.FillDynamicEntityData(tr);
            new_EftBank.FillDynamicEntityData(tr);
            new_EftBranch.FillDynamicEntityData(tr);
            new_RecipientIBAN.FillDynamicEntityData(tr);
            new_RecipientAccountNumber.FillDynamicEntityData(tr);
            new_SenderID.FillDynamicEntityData(tr);

            new_RecipienNickName.SetValue(cryptor.DecryptInString(new_RecipienNickName.Value));
            new_RecipientLastName.SetValue(cryptor.DecryptInString(new_RecipientLastName.Value));
            new_RecipientMiddleName.SetValue(cryptor.DecryptInString(new_RecipientMiddleName.Value));
            new_RecipientName.SetValue(cryptor.DecryptInString(new_RecipientName.Value));

            new_RecipientIDChangeOnEvent(null, new AjaxEventArgs());
        }
    }

    private const string IsmeGonderim = "0bfc8b29-1ff7-459d-aafc-5a2e151180e8";
    private const string HesabaGonderim = "0bfc8b29-ae93-4226-ba23-4bc659890ab4";
    private const string KartaGonderim = "0bfc8b29-63b6-438d-9919-c0b0794cb0c3";

    public void ClearRequirementLevel()
    {
        new_RecipientIBAN.SetRequirementLevel(RLevel.None);
        new_EftBank.SetRequirementLevel(RLevel.None);
        new_EftCity.SetRequirementLevel(RLevel.None);
        new_EftBranch.SetRequirementLevel(RLevel.None);
        new_RecipientCardNumber.SetRequirementLevel(RLevel.None);
        new_RecipientAccountNumber.SetRequirementLevel(RLevel.None);
        new_EftPaymentMethodID.SetRequirementLevel(RLevel.None);
    }

    protected void new_RecipientIDChangeOnEvent(object sender, AjaxEventArgs e)
    {
        ClearRequirementLevel();

        if (string.IsNullOrEmpty(new_TransactionTargetOptionID.Value))
        {
            new_EftBank.SetVisible(true);
            new_EftCity.SetVisible(true);
            new_EftBranch.SetVisible(true);
            new_RecipientCardNumber.SetVisible(true);
            new_RecipientAccountNumber.SetVisible(true);
            new_IbanisNotKnown.SetVisible(true);
            new_RecipientIBAN.SetVisible(true);
            new_EftPaymentMethodID.SetValue(true);
        }

        if (new_TransactionTargetOptionID.Value == IsmeGonderim)//İsme
        {
            new_EftBank.SetVisible(false);
            new_EftCity.SetVisible(false);
            new_EftBranch.SetVisible(false);
            new_RecipientCardNumber.SetVisible(false);
            new_RecipientAccountNumber.SetVisible(false);
            new_IbanisNotKnown.SetVisible(false);
            new_RecipientIBAN.SetVisible(false);
            new_EftPaymentMethodID.SetVisible(false);

            //new_RecipientMotherName.SetRequirementLevel(RLevel.BusinessRecommend);
            //new_RecipientFatherName.SetRequirementLevel(RLevel.BusinessRecommend);

            ClearRequirementLevel();
        }
        if (new_TransactionTargetOptionID.Value == HesabaGonderim)//Hesaba
        {
            new_EftBank.SetVisible(true);
            new_EftCity.SetVisible(true);
            new_EftBranch.SetVisible(true);
            new_RecipientAccountNumber.SetVisible(true);
            new_RecipientCardNumber.SetVisible(false);
            new_IbanisNotKnown.SetVisible(true);
            new_RecipientIBAN.SetVisible(true);
            new_EftPaymentMethodID.SetValue(true);

            //new_RecipientMotherName.SetRequirementLevel(RLevel.None);
            //new_RecipientFatherName.SetRequirementLevel(RLevel.None);
        }

        if (new_TransactionTargetOptionID.Value == KartaGonderim)//KrediKartı
        {
            new_EftBank.SetVisible(true);
            new_EftCity.SetVisible(true);
            new_EftBranch.SetVisible(true);
            new_RecipientAccountNumber.SetVisible(false);
            new_RecipientCardNumber.SetVisible(true);
            new_IbanisNotKnown.SetVisible(false);
            new_RecipientIBAN.SetVisible(false);
            new_EftPaymentMethodID.SetVisible(true);

            new_RecipientIBAN.SetRequirementLevel(RLevel.None);
            new_EftBank.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftCity.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftBranch.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientCardNumber.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientAccountNumber.SetRequirementLevel(RLevel.None);
            new_EftPaymentMethodID.SetRequirementLevel(RLevel.BusinessRequired);

            //new_RecipientMotherName.SetRequirementLevel(RLevel.None);
            //new_RecipientFatherName.SetRequirementLevel(RLevel.None);
        }

        if (new_TransactionTargetOptionID.Value == HesabaGonderim)
            new_IbanisNotKnownOnEvent(sender, e);


    }

    protected void new_IbanisNotKnownOnEvent(object sender, AjaxEventArgs e)
    {
        if (new_IbanisNotKnown.Checked)
        {
            new_RecipientIBAN.SetVisible(false);
            new_EftBank.SetVisible(true);
            new_EftCity.SetVisible(true);
            new_EftBranch.SetVisible(true);
            new_RecipientCardNumber.SetVisible(false);
            new_RecipientAccountNumber.SetVisible(true);
            new_EftPaymentMethodID.SetVisible(false);

            new_RecipientIBAN.SetRequirementLevel(RLevel.None);
            new_EftBank.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftCity.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftPaymentMethodID.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftBranch.SetRequirementLevel(RLevel.BusinessRequired);
            new_RecipientCardNumber.SetRequirementLevel(RLevel.None);
            new_RecipientAccountNumber.SetRequirementLevel(RLevel.BusinessRequired);

            if (sender != null)
            {
                new_EftBank.Clear();
                new_EftCity.Clear();
                new_EftBranch.Clear();
                new_EftPaymentMethodID.Clear();
            }

        }
        else
        {
            new_RecipientIBAN.SetVisible(true);
            new_EftBank.SetVisible(false);
            new_EftCity.SetVisible(false);
            new_EftBranch.SetVisible(false);
            new_RecipientCardNumber.SetVisible(false);
            new_RecipientAccountNumber.SetVisible(false);
            new_EftPaymentMethodID.SetValue(false);

            new_RecipientIBAN.SetRequirementLevel(RLevel.BusinessRequired);
            new_EftBank.SetRequirementLevel(RLevel.None);
            new_EftCity.SetRequirementLevel(RLevel.None);
            new_EftBranch.SetRequirementLevel(RLevel.None);
            new_RecipientCardNumber.SetRequirementLevel(RLevel.None);
            new_RecipientAccountNumber.SetRequirementLevel(RLevel.None);
            new_EftPaymentMethodID.SetRequirementLevel(RLevel.None);

            if (sender != null)
            {
                new_EftBank.Clear();
                new_EftCity.Clear();
                new_EftBranch.Clear();
                new_EftPaymentMethodID.Clear();
            }
        }
    }

    // return
    // -1 : Alıcı adı 50den fazla
    // -2: Gönderici adı 50den fazla
    protected int fieldValidator()
    {
        int validationResult = 0;

        //Alıcı adı 50 karakter kontrolü
        string FullRecipientName = new_RecipientName.Value + ' '
            + (string.IsNullOrEmpty(new_RecipientMiddleName.Value) ? string.Empty : new_RecipientMiddleName.Value) + ' '
            + new_RecipientLastName.Value;

        if (FullRecipientName.Length > 50)
        {
            validationResult = -1;
        }

        //Gönderen adı 50 karakter kontrolü
        var staticData = new StaticData();
        staticData.ClearParameters();
        staticData.AddParameter("@SenderId", DbType.Guid, ValidationHelper.GetGuid(new_SenderID.Value));
        DataTable dataTable = staticData.ReturnDataset(@"Select Sender from vNew_Sender(nolock)
Where New_SenderId=@SenderId and DeletionStateCode = 0").Tables[0];
        string FullSenderName = ValidationHelper.GetString(dataTable.Rows[0]["Sender"]);
        //new_SenderName.Value + ' '
        //+ (string.IsNullOrEmpty(new_SenderMiddleName.Value) ? string.Empty : new_SenderMiddleName.Value) + ' '
        //+ new_SenderLastName.Value;

        if (FullSenderName.Length > 50)
        {
            validationResult = -2;
        }

        return validationResult;
    }

    private int getYas(DateTime birthdate)
    {
        try
        {
            int yas = 0;

            TimeSpan t = new TimeSpan();
            t = DateTime.Now.Date.Subtract(birthdate);
            int gun = Convert.ToInt32(t.TotalDays);
            yas = gun / 365;

            return yas;
        }
        catch (Exception)
        {

            throw;
        }

    }
}
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.Corporation;
using TuFactory.LimitApproverManagement;
using TuFactory.SenderBlocked;
using TuFactory.SenderPerson;

namespace Coretech.Crm.Web.ISV.TU.LimitApproverManagement
{
    public partial class LimitApproverManagementDetail : BasePage
    {
        Guid senderId = Guid.Empty;
        LimitApproverManagementConfirmFactory fac = new LimitApproverManagementConfirmFactory();
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!RefleX.IsAjxPostback)
            {
                hdnRecId.Value = QueryHelper.GetString("RecordId");
                //string islem = QueryHelper.GetString("SourceFormType");
                string islemTip = QueryHelper.GetString("islemTip");

                hdnTransactionType.Value = islemTip;

                if (islemTip == "yeniKayit")
                    hdnTransactionTypeId.Value = "1";
                else if (islemTip == "duzeltme")
                    hdnTransactionTypeId.Value = "2";
                else if (islemTip == "guncelleme")
                    hdnTransactionTypeId.Value = "3";

                if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
                {
                    newSenderLoad(null, null);
                    new_SenderId.SetDisabled(true);

                    LimitAndApproverManagementHeader rec = fac.GetLimitAndApproverHeaderConfirm(ValidationHelper.GetGuid(hdnRecId.Value));

                    new_SenderId.SetValue(rec.SenderId);
                    new_SenderId.Value = rec.SenderId.ToString();
                    newSenderPersonLoad(null,null);
                    //new_SenderId.Text = dt.Rows[0]["new_SenderIdName"].ToString();
                    senderId = ValidationHelper.GetGuid(new_SenderId.Value);

                    new_SenderPersonId.SetValue(rec.SenderPersonId);
                    new_SenderPersonId.Value = rec.SenderPersonId.ToString();

                    new_CurrencyId.SetValue(rec.CurrencyId);
                    new_IsMaxAmountLimit.Checked = rec.IsMaxAmountLimit;
                    new_LimitAmount.SetValue(rec.LimitAmount);
                    hdnTransactionType.SetValue(rec.TransactionType);
                    hdnStatus.SetValue(rec.Status);
                    new_Status.SetValue(rec.Status);
                    new_Status.Value = rec.Status.ToString();
                    
                    new_RejectDescription.SetValue(rec.RejectDescription);

                    chcIsMaxAmountLimitChecked(null, null);
                    new_Status.SetReadOnly(true);
                    new_RejectDescription.SetReadOnly(true);
                    

                    //yenikayıtta Header alanında alanlar düzenlenemesin.
                    if (rec.Status > 0 && islemTip == "yeniKayit")
                        DisableField();

                    //kayıt tamamlanmadıysa bazı alanları gizle
                    if (rec.Status <=0)
                    {
                        new_Status.SetVisible(true);
                        new_RejectDescription.SetVisible(true);
                    }

                    //işlem yeni kayıt değilse "Kayıt tamamla" butonunu gizle
                    if (islemTip != "yeniKayit")
                    {
                        BtnAccept.SetVisible(false);
                        BtnRecordUpdate.SetVisible(true);
                    }

                    if (rec.Status == 3 || rec.Status < 1)
                    {
                        BtnRecordUpdate.SetVisible(false);
                    }

                    if(rec.Status == 4)
                    {
                        new_RejectDescription.SetVisible(true);
                    }

                    LimitApproverList();
                }
            }
        }

        protected void DisableField()
        {
            new_SenderId.SetReadOnly(true);
            new_SenderPersonId.SetReadOnly(true);
            new_CurrencyId.SetReadOnly(true);
            new_IsMaxAmountLimit.SetReadOnly(true);
            new_LimitAmount.SetReadOnly(true);
            new_Status.SetReadOnly(true);
            new_RejectDescription.SetReadOnly(true);

            BtnDelete.SetVisible(false);
            pnlDataRow.SetVisible(false);
            BtnAccept.SetVisible(false);
        }

        //kaydı tamamla
        protected void Complete(object sender, AjaxEventArgs e)
        {
            try
            {
                Guid refId = ValidationHelper.GetGuid(  hdnRecId.Value);

                //set.Confirm(refId, corporateTypeId, transactionTypeVal, confirmStatus, systemUserId);

                int status = 2;
                int? transactionType = ValidationHelper.GetInteger( hdnTransactionTypeId.Value);
                Guid systemUserId = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId);
                bool result = fac.UpdateHeaderConfirmStatus(refId, status, transactionType, "",systemUserId);

                //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                //ms.Show(".", "İlgili işlem, onaya gönderildi.");

                if (result)
                {
                    var config = "/ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?RecordId=" + refId + "&islem=kayitTamamla&islemTip=" + hdnTransactionType.Value;
                    Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                }else
                {
                    throw new Exception("Kayıt güncellenemedi.");
                }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementHeader.Complete", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }

        protected void ClearValue()
        {
            new_FirstAmount.Clear();
            new_SecondAmount.Clear();
            new_FirstApproverId.Clear();
            new_SecondApproverId.Clear();
            new_TransactionTypeId.Clear();
        }

        protected void AddRows(object sender, AjaxEventArgs e)
        {
            try
            {                
                double firstAmount = ValidationHelper.GetDouble(new_FirstAmount.Value, 0);
                double secondAmount = ValidationHelper.GetDouble(new_SecondAmount.Value, 0);
                Guid firstApproverId = ValidationHelper.GetGuid(new_FirstApproverId.Value);
                Guid secondApproverId = ValidationHelper.GetGuid(new_SecondApproverId.Value);
                Guid transactionTypeId = ValidationHelper.GetGuid(new_TransactionTypeId.Value);

                string hataMesaj = "";

                if (transactionTypeId == Guid.Empty)
                {
                    hataMesaj += "İşlem tipi seçmelisiniz";
                }

                if (secondAmount<=0)
                {
                    hataMesaj += "Tutar aralığı girmelisiniz";
                }

                if (secondAmount <= firstAmount)
                {
                    hataMesaj += "İlk tutar ikinci tutardan küçük olamaz";
                }

                if(firstApproverId == Guid.Empty)
                {
                    hataMesaj += "1.onaycıyı seçmelisiniz";
                }

                if (hataMesaj!="")
                {
                    var ms = new MessageBox();
                    ms.MessageType = EMessageType.Error;
                    ms.Modal = true;
                    ms.Height = 160;
                    ms.Show(".", hataMesaj);

                    return;
                }


                LimitAndApproverManagementDetail record = new LimitAndApproverManagementDetail();
                record.LimitApproverManagementId = ValidationHelper.GetGuid( hdnRecId.Value);
                record.FirstAmount = firstAmount;
                record.SecondAmount = secondAmount;
                record.FirstApproverId = firstApproverId;
                record.SecondApproverId = secondApproverId;
                record.TransactionTypeId = transactionTypeId;

                Guid recId = fac.InsertDetailConfirm(record);

                if (recId != Guid.Empty)
                {
                    ClearValue();
                    LimitApproverList();
                    var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                    ms.Show(".", "Kayıt Eklendi");
                    new_TransactionTypeId.Focus();
                }
                else
                {
                    var ms = new MessageBox();
                    ms.MessageType = EMessageType.Error;
                    ms.Modal = true;
                    ms.Height = 160;
                    //ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                    ms.Show(".", "Hata! Kayıt eklenemedi.");
                }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementHeader.AddRows", "Exception");
            }
        }

        protected void RecordUpdate(object sender, AjaxEventArgs e)
        {
            try
            {
                Guid senderId = ValidationHelper.GetGuid(new_SenderId.Value);
                Guid senderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value);
                Guid currencyId = ValidationHelper.GetGuid(new_CurrencyId.Value);
                bool isMaxAmountLimit = ValidationHelper.GetBoolean(new_IsMaxAmountLimit.Checked, false);
                double limitAmount = ValidationHelper.GetDouble(new_LimitAmount.Value, 0);
                Guid systemUserId = App.Params.CurrentUser.SystemUserId;


                string hataMesaj = "";

                if (senderId == Guid.Empty)
                {
                    hataMesaj += "Müşteri seçiniz";
                }

                if (senderPersonId == Guid.Empty)
                {
                    hataMesaj += "Yetkili seçiniz";
                }

                if (currencyId == Guid.Empty)
                {
                    hataMesaj += "Para birimini seçiniz";
                }

                if (hataMesaj != "")
                {
                    var ms = new MessageBox();
                    ms.MessageType = EMessageType.Error;
                    ms.Modal = true;
                    ms.Height = 160;
                    ms.Show(".", hataMesaj);

                    return;
                }

                LimitAndApproverManagementHeader record = new LimitAndApproverManagementHeader();
                record.LimitApproverManagementId = ValidationHelper.GetGuid(hdnRecId.Value);
                record.SenderId = senderId;
                record.SenderPersonId = senderPersonId;
                record.CurrencyId = currencyId;
                record.IsMaxAmountLimit = isMaxAmountLimit;
                record.LimitAmount = limitAmount;
                record.Status = 2;
                //kayıt reddedildi ise işlem tipi Düzeltme, yoksa güncelleme olacak
                record.TransactionType = (ValidationHelper.GetInteger( hdnStatus.Value) == 4) ? 2 : 3;
                record.SystemUserId = systemUserId;

                bool reult = fac.UpdateHeaderConfirm(record);

                if (reult)
                {
                    var config = "/ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?RecordId=" + hdnRecId.Value + "&islemTip=" + hdnTransactionType.Value;
                    Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                }
                else
                {
                    var ms = new MessageBox();
                    ms.MessageType = EMessageType.Error;
                    ms.Modal = true;
                    ms.Height = 160;
                    //ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                    ms.Show(".", "Hata! Kayıt eklenemedi.");
                }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementHeader.AddRows", "Exception");
            }
        }
        protected void DeleteDetail(object sender, AjaxEventArgs e)
        {
            try
            {
                var systemUserId = App.Params.CurrentUser.SystemUserId;
                var degerler = ((CheckSelectionModel)GridPanelSenderPerson.SelectionModel[0]);
                if (degerler != null && degerler.SelectedRows != null)
                {
                    
                    Guid refId = Guid.Empty;
                    foreach (var row in degerler.SelectedRows)
                    {
                        refId = ValidationHelper.GetGuid(row.New_LimitApproverManagementDetailConfirmId);
                        var result = fac.DeleteLimitAndApproverDetailConfirmRow(refId, systemUserId);

                        if (result == false)
                        {
                            var ms = new MessageBox();
                            ms.MessageType = EMessageType.Error;
                            ms.Modal = true;
                            ms.Height = 160;
                            ms.Show(".", "Hata! İşlem yapılamadı.");
                            break;
                        }
                    }
                }
                else
                {
                    var ms = new MessageBox();
                    ms.MessageType = EMessageType.Error;
                    ms.Modal = true;
                    ms.Height = 160;
                    //ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                    ms.Show(".", "İşlem yapılacak kayıtları seçmelisiniz!");
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementHeader.DeleteDetail", "Exception");
            }
        }

        protected void newSenderLoad(object sender, AjaxEventArgs e)
        {
            try
            {
                string strSql = @"SELECT 
                                s.new_SenderId ID,
	                            s.Sender VALUE,
                                new_SenderId,
                                Sender,
	                            new_Name,
                                new_MiddleName,
                                new_LastName,
                                new_GenderID,
                                new_GenderIDName,
                                new_BirthPlace,
                                new_IdendificationCardTypeID,
                                new_IdendificationCardTypeIDName,
                                new_IdentityNo,
                                new_SenderIdendificationNumber1,
                                new_SenderIdendificationNumber2
                            From vNew_Sender S (NoLock)
                            WHERE DeletionStateCode=0 AND S.new_CustAccountTypeIdName = 'Tüzel'
								  AND EXISTS(SELECT 1 FROM vNew_SenderPerson P (NoLock) WHERE P.new_SenderId = s.New_SenderId)
                                  AND EXISTS(SELECT 1 FROM vNew_CustAccountAuth A (NoLock) WHERE A.new_SenderId = s.New_SenderId AND A.new_ConfirmStatus = 3)
                            ORDER BY new_Name asc";

                StaticData sd = new StaticData();
                DataSet ds = sd.ReturnDataset(strSql);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    new_SenderId.TotalCount = ds.Tables[0].Rows.Count;
                    new_SenderId.DataSource = ds.Tables[0];
                    new_SenderId.DataBind();
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementDetail.newSenderLoad", "Exception");
            }
        }


        protected void newSenderPersonLoad(object sender, AjaxEventArgs e)
        {
            try
            {
                string strSql = @"SELECT 
                                s.new_SenderPersonId ID,
	                            s.FullName VALUE,
                                new_SenderPersonId,
                                s.FullName,
                                s.new_SenderId,
                                s.new_SenderIdName,
	                            new_Name,
                                new_MiddleName,
                                new_LastName,
                                new_GenderID,
                                new_GenderIDName,
                                new_BirthPlace,
                                new_IdendificationCardTypeID,
                                new_IdendificationCardTypeIDName,
                                new_IdentityNo,
                                new_SenderIdendificationNumber1,
                                new_SenderIdendificationNumber2,
                                S.new_E_Mail,
                                S.new_GSM,
                                S.new_TaxNo,
                                S.new_NationalityIDName,
								S.new_NationalityIDName,
								S.new_HomeCountryName,
                                S.new_ConfirmStatus
                            From  nltvNew_SenderPerson(@SystemUserId) S
                            WHERE DeletionStateCode=0 
									AND S.new_SenderId = @SenderId
                                    AND EXISTS(SELECT 1 FROM vNew_CustAccountAuth A (NoLock) 
                                                WHERE A.new_SenderPersonId = s.New_SenderPersonId 
                                                    AND A.new_ConfirmStatus = 3)
                            ORDER BY new_Name asc";

                StaticData sd = new StaticData();
                sd.ClearParameters();
                sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetGuid(new_SenderId.Value));
                sd.AddParameter("SystemUserId", DbType.Guid, ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId));
                DataSet ds = sd.ReturnDataset(strSql);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    new_SenderPersonId.TotalCount = ds.Tables[0].Rows.Count;
                    new_SenderPersonId.DataSource = ds.Tables[0];
                    new_SenderPersonId.DataBind();
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementDetail.newSenderPersonLoad", "Exception");
            }
        }

        protected void chcIsMaxAmountLimitChecked(object sender, AjaxEventArgs e)
        {
            new_LimitAmount.SetDisabled(!new_IsMaxAmountLimit.Checked);
        }

        protected void GrdLimitApproverList(object sender, AjaxEventArgs e)
        {
            LimitApproverList();
        }

        private void LimitApproverList()
        {
            try
            {
                DataTable dt;

                Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
                dt = fac.GetLimitAndApproverDetailConfirm(recId);

                GridPanelSenderPerson.DataSource = dt;
                GridPanelSenderPerson.DataBind();
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementDetail.LimitApproverList", "Exception");
            }
        }

    }
}
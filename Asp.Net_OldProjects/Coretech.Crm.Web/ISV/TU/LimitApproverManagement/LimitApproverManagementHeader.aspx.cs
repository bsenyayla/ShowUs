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
    public partial class LimitApproverManagementHeader : BasePage
    {
        Guid senderId = Guid.Empty;
        LimitApproverManagementConfirmFactory fac = new LimitApproverManagementConfirmFactory();
        protected void Page_Load(object sender, EventArgs e)
        {
            hdnRecId.Value = QueryHelper.GetString("RecordId");
            string islem = QueryHelper.GetString("SourceFormType");

            BtnAccept.SetVisible(false);

            if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
            {
                newSenderLoad(null, null);
                newSenderPersonLoad(null,null);

                new_SenderId.SetDisabled(true);
                BtnSave.SetVisible(false);

                if (islem== "ApprovalList")
                    BtnAccept.SetVisible(true);
                
                SenderBlockedFactory set = new SenderBlockedFactory();
                DataTable dt = set.GetCorporatedBlockedApprovalHeader(ValidationHelper.GetGuid(hdnRecId.Value));
                
                
                new_SenderId.SetValue(dt.Rows[0]["new_SenderId"].ToString());
                new_SenderId.Text = dt.Rows[0]["new_SenderIdName"].ToString();
                senderId = ValidationHelper.GetGuid(dt.Rows[0]["new_SenderId"].ToString());
                //new_SenderId.SetValue(dt.Rows[0]["new_SenderIdName"].ToString());

                //SenderPersonList();  
            }

        }

        protected void Confirm(object sender, AjaxEventArgs e)
        {
            try
            {
                Guid refId = ValidationHelper.GetGuid(  hdnRecId.Value);
                
                //tüzel
                int corporateTypeId = 2;
                int transactionId = 0;
                Guid systemUserId = App.Params.CurrentUser.SystemUserId;
                int confirmStatus = 2;

                SenderBlockedFactory set = new SenderBlockedFactory();
                //set.Confirm(refId, corporateTypeId, transactionTypeVal, confirmStatus, systemUserId);

                BtnAccept.SetVisible(true);

                var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "İlgili işlem onaylandı.");

                var config = "/ISV/TU/Sender/SenderBlocked/SenderPersonBlockedForm.aspx?RecordId=" + refId + "&islem=islemTamamOnay";
                Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);

                //BasePage.QScript("window.top.R.WindowMng.getActiveWindow().hide();");

                //ScriptManager.RegisterClientScriptBlock(this, typeof(Page), "Script", "alert('22');window.top.R.WindowMng.getActiveWindow().hide();", true);

            }
            catch (Exception ex)
            {
                BtnAccept.SetVisible(false);

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");

                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Sender.SenderBlocked.SenderPersonBlockedForm.Confirm", "Exception");
            }

        }
        protected void AddRecord(object sender, AjaxEventArgs e)
        {
            try
            {
                
                

                Guid senderId   = ValidationHelper.GetGuid(new_SenderId.Value);
                Guid senderPersonId = ValidationHelper.GetGuid(new_SenderPersonId.Value);
                Guid currencyId = ValidationHelper.GetGuid(new_CurrencyId.Value);
                bool isMaxAmountLimit = ValidationHelper.GetBoolean(new_IsMaxAmountLimit.Checked, false);
                double limitAmount = ValidationHelper.GetDouble(new_LimitAmount.Value,0);
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
                record.SenderId = senderId;
                record.SenderPersonId = senderPersonId;
                record.CurrencyId = currencyId;
                record.IsMaxAmountLimit = isMaxAmountLimit;
                record.LimitAmount = limitAmount;
                record.SystemUserId = systemUserId;

                Guid recId = fac.InsertHeaderConfirm(record);

                if (recId != Guid.Empty)
                {
                    var config = "/ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?RecordId=" + recId + "&islemTip=yeniKayit";
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


                /*
                var degerler = ((CheckSelectionModel)GridPanelSenderPerson.SelectionModel[0]);
                if (degerler != null && degerler.SelectedRows != null)
                {
                    //Guid refId = set.CorporatedBlockedApprovalDbInsert(transactionId, customerType, blockedReasonId, description, senderId, systemUserId);

                    Guid refId = Guid.Empty;
                    foreach (var row in degerler.SelectedRows)
                    {
                        var senderPersonId = ValidationHelper.GetGuid(row.ID);
                        set.CorporatedBlockedSenderPersonDbInsert(refId,senderPersonId,systemUserId);
                    }

                    var config = "/ISV/TU/Sender/SenderBlocked/SenderPersonBlockedForm.aspx?RecordId=" + refId + "&islem=islemTamam";
                    Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);

                }
                else
                {
                    var ms = new MessageBox();
                    ms.MessageType = EMessageType.Error;
                    ms.Modal = true;
                    ms.Height = 160;
                    //ms.Show(".", CrmLabel.TranslateMessage("CRM.NEW_TRANSACTIONCONFIRM_STATUS_CHANCED_ERROR"));
                    ms.Show(".", "İşlem yapılacak personel seçmelisiniz!");
                }
                */

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementHeader.AddRecord", "Exception");
            }
        }


        protected void chcIsMaxAmountLimitChecked(object sender, AjaxEventArgs e)
        {
            new_LimitAmount.SetDisabled(!new_IsMaxAmountLimit.Checked);
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
                                WHERE DeletionStateCode=0 
                                      AND S.new_CustAccountTypeIdName = 'Tüzel'
								      AND EXISTS(SELECT 1 FROM vNew_SenderPerson P WHERE P.new_SenderId = s.New_SenderId)
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
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Sender.SenderBlocked.SenderPersonBlockedForm.newSenderLoad", "Exception");
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

        protected void GrdSenderPersonList(object sender, AjaxEventArgs e)
        {
            new_SenderPersonId.SetValue("");
            newSenderPersonLoad(null,null);
            //SenderPersonList();
        }

    }
}
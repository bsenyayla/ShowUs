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
    public partial class LimitApproverManagementDetailConfirmScreen : BasePage
    {
        Guid senderId = Guid.Empty;
        LimitApproverManagementConfirmFactory fac = new LimitApproverManagementConfirmFactory();
        protected void Page_Load(object sender, EventArgs e)
        {
            
            hdnRecId.Value = QueryHelper.GetString("RecordId");
            //string islem = QueryHelper.GetString("SourceFormType");
            string islemTip = QueryHelper.GetString("IslemTip");

            hdnTransactionType.Value = islemTip;

            if (islemTip == "yeniKayit")
                hdnTransactionTypeId.Value = "1";
            else if (islemTip == "duzeltme")
                hdnTransactionTypeId.Value = "2";
            else if (islemTip == "guncelleme")
                hdnTransactionTypeId.Value = "3";

            if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
            {
                BtnDelete.SetVisible(false);
                newSenderLoad(null, null);
                new_SenderId.SetDisabled(true);

                LimitAndApproverManagementHeader rec = fac.GetLimitAndApproverHeaderConfirm(ValidationHelper.GetGuid(hdnRecId.Value));
               
                new_SenderId.SetValue(rec.SenderId);
                //new_SenderId.Text = dt.Rows[0]["new_SenderIdName"].ToString();
                senderId = ValidationHelper.GetGuid(new_SenderId.Value);

                new_SenderPersonId.SetValue(rec.SenderPersonId);
                new_CurrencyId.SetValue(rec.CurrencyId);
                new_IsMaxAmountLimit.Checked = rec.IsMaxAmountLimit;
                new_LimitAmount.SetValue(rec.LimitAmount);
                hdnTransactionType.SetValue(rec.TransactionType);
                hdnStatus.SetValue(rec.Status);

                if (rec.Status!=2)
                {
                    BtnAccept.SetVisible(false);
                    BtnRejected.SetVisible(false);
                }

                LimitApproverList();  
            }

        }


        //reddedildi
        protected void Rejected(object sender, AjaxEventArgs e)
        {
            try
            {
                Guid refId = ValidationHelper.GetGuid(hdnRecId.Value);

                int status = 4;
                int? transactionType = ValidationHelper.GetInteger(hdnTransactionTypeId.Value);
                Guid systemUserId = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId);
                string rejectDescription = ValidationHelper.GetString(new_RejectDescription.Value);
                fac.UpdateHeaderConfirmStatus(refId, status, transactionType, rejectDescription, systemUserId);
                windowReject.Hide();
                //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                //ms.Show(".", "İlgili işlem, reddedildi");

                var config = "/ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?RecordId=" + refId + "&islem=islemTamamOnay&IslemTip=" + hdnTransactionType.Value.ToString();
                Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementHeader.Denied", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }

        protected void RejectedWindow(object sender, AjaxEventArgs e)
        {
            try
            {
                windowReject.Show();

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementHeader.Denied", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }

        //onaylandı
        protected void Approve(object sender, AjaxEventArgs e)
        {
            try
            {
                Guid refId = ValidationHelper.GetGuid(hdnRecId.Value);

                int status = 3;
                int? transactionType = ValidationHelper.GetInteger(hdnTransactionTypeId.Value);
                Guid systemUserId = ValidationHelper.GetGuid(App.Params.CurrentUser.SystemUserId);
                fac.UpdateHeaderConfirmApprove(refId, status, transactionType, systemUserId);

                var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "İlgili işlem, onaylandı");

                var config = "/ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?RecordId=" + refId + "&islem=islemTamamOnay&IslemTip=" + hdnTransactionType.Value.ToString();
                Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.LimitApproverManagement.LimitApproverManagementHeader.Approve", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
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
                            WHERE DeletionStateCode=0 
                                  AND S.new_CustAccountTypeIdName = 'Tüzel'
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
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Sender.SenderBlocked.SenderPersonBlockedForm.newSenderLoad", "Exception");
            }
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
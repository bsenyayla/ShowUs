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
using TuFactory.SenderBlocked;
using TuFactory.SenderPerson;

namespace Coretech.Crm.Web.ISV.TU.Sender.SenderBlocked
{
    public partial class SenderPersonBlockedForm : BasePage
    {
        Guid senderId = Guid.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            hdnRecId.Value = QueryHelper.GetString("RecordId");
            string islem = QueryHelper.GetString("SourceFormType");

            BtnAccept.SetVisible(false);

            if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
            {
                newSenderLoad(null, null);
                new_TransactionType.SetReadOnly(true);
                new_TransactionType.SetDisabled(true);
                new_SenderId.SetDisabled(true);
                new_CorporatedBlockedReasonId.SetReadOnly(true);
                new_CorporatedBlockedReasonId.SetDisabled(true);
                new_Description.SetReadOnly(true);
                BtnSave.SetVisible(false);

                if (islem== "ApprovalList")
                    BtnAccept.SetVisible(true);
                
                SenderBlockedFactory set = new SenderBlockedFactory();
                DataTable dt = set.GetCorporatedBlockedApprovalHeader(ValidationHelper.GetGuid(hdnRecId.Value));
                
                new_TransactionType.SetValue(dt.Rows[0]["new_TransactionType"].ToString());
                new_SenderId.SetValue(dt.Rows[0]["new_SenderId"].ToString());
                new_SenderId.Text = dt.Rows[0]["new_SenderIdName"].ToString();
                senderId = ValidationHelper.GetGuid(dt.Rows[0]["new_SenderId"].ToString());
                //new_SenderId.SetValue(dt.Rows[0]["new_SenderIdName"].ToString());
                new_CorporatedBlockedReasonId.SetValue(dt.Rows[0]["new_CorporatedBlockedReasonId"].ToString());
                new_Description.SetValue(dt.Rows[0]["new_Description"].ToString());
                SenderPersonList();  
            }

        }

        protected void Confirm(object sender, AjaxEventArgs e)
        {
            try
            {
                Guid refId = ValidationHelper.GetGuid(  hdnRecId.Value);
                
                //tüzel
                int corporateTypeId = 2;
                int transactionTypeVal = Convert.ToInt32(new_TransactionType.Value);
                Guid systemUserId = App.Params.CurrentUser.SystemUserId;
                int confirmStatus = 2;

                SenderBlockedFactory set = new SenderBlockedFactory();
                set.Confirm(refId, corporateTypeId, transactionTypeVal, confirmStatus, systemUserId);

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
                SenderBlockedFactory set = new SenderBlockedFactory();
                Guid senderId   = ValidationHelper.GetGuid(new_SenderId.Value);
                int  transactionId = ValidationHelper.GetInteger( new_TransactionType.Value,0);
                Guid blockedReasonId = ValidationHelper.GetGuid(new_CorporatedBlockedReasonId.Value);
                string description = ValidationHelper.GetString(new_Description.Value);
                int customerType = 2;//tüzel
                Guid systemUserId = App.Params.CurrentUser.SystemUserId;

                var degerler = ((CheckSelectionModel)GridPanelSenderPerson.SelectionModel[0]);
                if (degerler != null && degerler.SelectedRows != null)
                {
                    Guid refId = set.CorporatedBlockedApprovalDbInsert(transactionId, customerType, blockedReasonId, description, senderId, systemUserId);
                    

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

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Sender.SenderBlocked.SenderPersonBlockedForm.AddRecord", "Exception");
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
								  AND EXISTS(SELECT 1 FROM vNew_SenderPerson P WHERE P.new_SenderId = s.New_SenderId)
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
        protected void GrdSenderPersonList(object sender, AjaxEventArgs e)
        {

            SenderPersonList();
        }

        private void SenderPersonList()
        {
            try
            {
                DataTable dt;

                if (ValidationHelper.GetGuid(hdnRecId.Value) == Guid.Empty)
                {
                    SenderPersonFactory fc = new SenderPersonFactory();
                    senderId = ValidationHelper.GetGuid(new_SenderId.Value);
                    dt = fc.GetSenderPersonList(senderId);
                }
                else
                {
                    SenderBlockedFactory fc = new SenderBlockedFactory();
                    Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
                    dt = fc.GetSenderPersonBlockedList(senderId, recId);
                }



                GridPanelSenderPerson.DataSource = dt;
                GridPanelSenderPerson.DataBind();
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Sender.SenderBlocked.SenderPersonBlockedForm.SenderPersonList", "Exception");
            }
        }

    }
}
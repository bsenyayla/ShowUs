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
using TuFactory.SweepInstructions;
using Integration3rd.Cloud.Domain.Response;
using UPT.Shared.Service.Office.Service;
using UPTCache = UPT.Shared.CacheProvider.Service;
using UPTCacheObjects = UPT.Shared.CacheProvider.Model;
using Integration3rd.Cloud.Domain;
using TuFactory.Domain.SweepInstructions;
using TuFactory.Domain.SweepInstructions.Enums;
using TuFactory.CustomApproval;
using Newtonsoft.Json;
using TuFactory.Domain;
using TuFactory.Object;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;

namespace Coretech.Crm.Web.ISV.TU.SweepInstructionsList
{
    public partial class SweepInstructionsListDetail : BasePage
    {

        SweepInstructionsFactory fac = new SweepInstructionsFactory();

        protected override void OnInit(EventArgs e)
        {
            
            base.OnInit(e);
        }

        
        protected void Page_Load(object sender, EventArgs e)
        {
            hdnRecId.Value = QueryHelper.GetString("RecordId");
            bool readonlyStatus = true;
            bool disableStatus = true;
            DynamicFactory df;
 
            df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
          
            var tr = df.Retrieve(TuEntityEnum.New_SweepInstructions.GetHashCode(),
                                   ValidationHelper.GetGuid(hdnRecId.Value),
                                   DynamicFactory.RetrieveAllColumns);


            //string islem = QueryHelper.GetString("SourceFormType");
            
            if (!RefleX.IsAjxPostback)
            {
                BtnDelete.SetVisible(false);
                BtnShowHistory.SetVisible(false);
                mfDays.SetVisible(false);
                new_InstructionsDayType.SetVisible(false);
                new_TransferTime.SetVisible(false);
                SweepTime.SetVisible(false);
                new_SweepAmount.SetVisible(false);
                new_SweepLevelAmount.SetVisible(false);
                if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
                {   
                    
                    BtnShowHistory.SetVisible(true);
                    new_CorporationId.SetReadOnly(readonlyStatus);
                    new_SenderAccountId.SetReadOnly(readonlyStatus);
                    new_RecipientCorparationAccountId.SetReadOnly(readonlyStatus);

                    new_CorporationId.SetDisabled(disableStatus);
                    new_SenderAccountId.SetDisabled(disableStatus);
                    new_RecipientCorparationAccountId.SetDisabled(disableStatus);

                    //newSenderUptAccountLoad(null, null);

                    DataTable rec = fac.GetSweepInstructionsDataTable(ValidationHelper.GetGuid(hdnRecId.Value));
                    
                    if (rec.Rows.Count <= 0)
                        return;

                    
                    int? sweepType = ValidationHelper.GetInteger(rec.Rows[0]["new_SweepType"].ToString());
                    int? transferTime = ValidationHelper.GetInteger(rec.Rows[0]["new_TransferTime"].ToString());
                    
                    new_CorporationId.Value  = rec.Rows[0]["new_CorporationId"].ToString();
                    new_CorporationId.SetValue(ValidationHelper.GetGuid(rec.Rows[0]["new_CorporationId"].ToString()));


                    new_SenderAccountId.SetValue(rec.Rows[0]["new_SenderAccountId"].ToString());
                    new_SenderAccountId.Value = rec.Rows[0]["new_SenderAccountId"].ToString();
                    new_SenderAccountId.Text = rec.Rows[0]["new_SenderAccountIdName"].ToString();

                    newRecipientCorpAccountLoad(null, null);
                    new_RecipientCorparationAccountId.FillDynamicEntityData(tr);

                    new_SweepBalance.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_SweepBalance"].ToString()));
                    new_SweepBalance.Value = rec.Rows[0]["new_SweepBalance"].ToString();

                    new_SweepAmount.SetValue( rec.Rows[0]["new_SweepAmount"].ToString() );
                    new_SweepLevelAmount.SetValue(rec.Rows[0]["new_SweepLevelAmount"].ToString());
                    //new_SweepType.SetValue(sweepType);
                    new_SweepType.Value = sweepType.ToString();
                    new_InstructionsDayType.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_InstructionsDayType"].ToString()));
                    new_TransferTime.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_TransferTime"].ToString()));
                    new_SweepHour.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SweepHour"].ToString()));
                    new_SweepMinute.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SweepMinute"].ToString()));
                    new_InstructionsStatus.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_InstructionsStatus"].ToString()));
                    new_InstructionsConfirmStatus.Value =  rec.Rows[0]["new_InstructionsConfirmStatus"].ToString();

                    if (Convert.ToInt32(new_SweepBalance.Value) == (int)SweepBalanceEnum.BAKIYE_BELLI_TUTARA_ULASTIGINDA)
                    {
                        new_SweepAmount.SetVisible(true);
                        new_SweepLevelAmount.SetVisible(true);
                    }

                    SweepTypeEnum sweepTypeEnum = (SweepTypeEnum)System.Enum.Parse(typeof(SweepTypeEnum), sweepType.ToString());
                    TransferTimeEnum transferTimeEnum = (TransferTimeEnum)System.Enum.Parse(typeof(TransferTimeEnum), transferTime.ToString());
                    if (sweepTypeEnum == SweepTypeEnum.GUNLUK)
                    {
                        new_InstructionsDayType.SetVisible(true);
                        new_TransferTime.SetVisible(true);

                        if(transferTimeEnum == TransferTimeEnum.SUPURME_SAATI)
                        {
                            SweepTime.SetVisible(true);
                        }

                    }else
                    {
                        SweepTime.SetVisible(true);
                    }
                    
                    if (!String.IsNullOrEmpty(rec.Rows[0]["new_ScheduledTime"].ToString()))
                        new_ScheduledTime.Value = ValidationHelper.GetDate( rec.Rows[0]["new_ScheduledTime"].ToString());

                    string instructionsDay = ValidationHelper.GetString(rec.Rows[0]["new_InstructionsDay"].ToString());

                    string[] days = instructionsDay.Split(',');

                    chcPazartesi.Checked = (days.Where(x => x.Contains("1") == true).Count() > 0) ? true : false;
                    chcSali.Checked = (days.Where(x => x.Contains("2") == true).Count() > 0) ? true : false;
                    chcCarsamba.Checked = (days.Where(x => x.Contains("3") == true).Count() > 0) ? true : false;
                    chcPersembe.Checked = (days.Where(x => x.Contains("4") == true).Count() > 0) ? true : false;
                    chcCuma.Checked = (days.Where(x => x.Contains("5") == true).Count() > 0) ? true : false;
                    chcCumartesi.Checked = (days.Where(x => x.Contains("6") == true).Count() > 0) ? true : false;
                    chcPazar.Checked = (days.Where(x => x.Contains("7") == true).Count() > 0) ? true : false;

                    if (ValidationHelper.GetInteger(rec.Rows[0]["new_InstructionsDayType"].ToString()) == 2)
                        mfDays.SetVisible(true);

                    
   
                    if ( ValidationHelper.GetInteger( new_InstructionsConfirmStatus.Value) == 0)
                    {
                        BtnSave.SetVisible(false);
                        BtnDelete.SetVisible(false);
                        //new_CorporationId.SetReadOnly(readonlyStatus);
                        //new_SenderAccountId.SetReadOnly(readonlyStatus);
                        //new_RecipientAccountId.SetReadOnly(readonlyStatus);
                        new_SweepBalance.SetReadOnly(readonlyStatus);
                        new_SweepAmount.SetReadOnly(readonlyStatus);
                        new_SweepLevelAmount.SetReadOnly(readonlyStatus);
                        new_SweepType.SetReadOnly(readonlyStatus);
                        new_InstructionsDayType.SetReadOnly(readonlyStatus);
                        new_TransferTime.SetReadOnly(readonlyStatus);
                        new_SweepHour.SetReadOnly(readonlyStatus);
                        new_SweepMinute.SetReadOnly(readonlyStatus);
                        new_InstructionsStatus.SetReadOnly(readonlyStatus);
                        new_InstructionsConfirmStatus.SetReadOnly(readonlyStatus);
                        new_ScheduledTime.SetReadOnly(readonlyStatus);

                        //new_CorporationId.SetDisabled(disableStatus);
                        //new_SenderAccountId.SetDisabled(disableStatus);
                        //new_RecipientAccountId.SetDisabled(disableStatus);
                        new_SweepBalance.SetDisabled(disableStatus);
                        new_SweepType.SetDisabled(disableStatus);
                        new_InstructionsDayType.SetDisabled(disableStatus);
                        new_TransferTime.SetDisabled(disableStatus);
                        new_InstructionsStatus.SetDisabled(disableStatus);
                        new_ScheduledTime.SetDisabled(disableStatus);
                        new_SweepAmount.SetDisabled(disableStatus);
                        new_SweepHour.SetDisabled(disableStatus);
                        new_SweepMinute.SetDisabled(disableStatus);

                    }else
                    {
                        BtnDelete.SetVisible(true);
                    }

                }
            }
            
        }


        protected void newSenderUptAccountLoad(object sender, AjaxEventArgs e)
        {
            try
            {

                Guid corporationId = ValidationHelper.GetGuid(new_CorporationId.Value);   
                DataSet ds = fac.GetUptAccountLoadList(App.Params.CurrentUser.SystemUserId, corporationId, Guid.Empty);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    new_SenderAccountId.TotalCount = ds.Tables[0].Rows.Count;
                    new_SenderAccountId.DataSource = ds.Tables[0];
                    new_SenderAccountId.DataBind();
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsListDetail.newSenderUptAccountLoad", "Exception");
            }
        }


        protected void newRecipientCorpAccountLoad(object sender, AjaxEventArgs e)
        {
            Guid currenctId = Guid.Empty;
            string action = "Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsListDetail.newRecipientCorpAccountLoad";
            try
            {
                Guid sweepInstructionsId = ValidationHelper.GetGuid(hdnRecId.Value);
                Guid senderAccountId = ValidationHelper.GetGuid(new_SenderAccountId.Value);
                if (senderAccountId != Guid.Empty)
                {

                    //var senderAccount = UPTCache.AccountService.GetAccountByAccountId(senderAccountId);
                    var senderAccount = fac.GetAccountInfo(senderAccountId);
                    if (senderAccount == null)
                    {
                        var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                        ms.Show(".", "Cache Üzerinde müşteri hesabı bulunamadı");

                        LogUtil.WriteException(new Exception("Cache üzerinde müşteri hesabı bulunamadı"), action, "Exception");
                        return;
                    }

                    if (senderAccount.Currency != null)
                        currenctId = ValidationHelper.GetGuid(senderAccount.Currency.CurrencyId);

                    Guid corporationId = ValidationHelper.GetGuid(new_CorporationId.Value.ToString());

                    DataSet ds = fac.GetCorpAccountLoadList(App.Params.CurrentUser.SystemUserId, currenctId, corporationId, (int)OfficeAccountOperationType.TALIMAT_HESABI, sweepInstructionsId);
                    DataTable dt;

                    var searchtext = this.Context.Items["query"] != null ? this.Context.Items["query"].ToString() : "";

                    //string searchSqlExt = " and  ac.new_AccountNo like '%{0}%' ";

                    if (!string.IsNullOrEmpty(searchtext))
                    {
                        var list = from customer in ds.Tables[0].AsEnumerable()
                                   where customer.Field<string>("VALUE").IndexOf(searchtext) >0
                                   select customer;

                        if (list.ToList().Count > 0)
                            dt = list.CopyToDataTable();
                        else
                            dt = new DataTable();
                    }
                    else
                    {
                        dt = ds.Tables[0];
                    }


                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        new_RecipientCorparationAccountId.TotalCount = ds.Tables[0].Rows.Count;
                        new_RecipientCorparationAccountId.DataSource = dt;
                        new_RecipientCorparationAccountId.DataBind();
                    }
                    
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, action, "Exception");
            }
        }

        protected void SweepBalanceEvent(object sender, AjaxEventArgs e)
        {
            try
            {

                //int transferTime = ValidationHelper.GetInteger( IsSelectTransferTime.Value,0);
                int sweepBalance = ValidationHelper.GetInteger(new_SweepBalance.Value, 0);

                if (sweepBalance == 3)
                {
                    new_SweepLevelAmount.SetVisible(true);
                    new_SweepAmount.SetVisible(true);
                }
                else
                {
                    new_SweepLevelAmount.SetVisible(false);
                    new_SweepAmount.SetVisible(false);

                    new_SweepLevelAmount.Value =0;
                    new_SweepAmount.Value = 0;

                    new_SweepLevelAmount.SetValue("0");
                    new_SweepAmount.SetValue("0");
                }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "SweepBalanceEvent");
            }

        }

        protected void SweepTypeEvent(object sender, AjaxEventArgs e)
        {
            try
            {

                //int transferTime = ValidationHelper.GetInteger( IsSelectTransferTime.Value,0);
                int sweepType = ValidationHelper.GetInteger(new_SweepType.Value, 0);

                if (sweepType == 1)
                {
                    SweepTime.SetVisible(false);
                    new_TransferTime.SetVisible(true);
                    new_InstructionsDayType.SetVisible(true);

                    TransferTimeEvent(null,null);
                    InstructionsDayTypeEvent(null,null);
                }
                else
                {
                    SweepTime.SetVisible(true);
                    new_TransferTime.SetVisible(false);
                    new_InstructionsDayType.SetVisible(false);
                }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "MobileDocument.Report");
            }

        }

        protected void InstructionsDayTypeEvent(object sender, AjaxEventArgs e)
        {
            try
            {

                //int transferTime = ValidationHelper.GetInteger( IsSelectTransferTime.Value,0);
                int instructionsDayType = ValidationHelper.GetInteger(new_InstructionsDayType.Value, 0);

                if (instructionsDayType == 2)
                    mfDays.SetVisible(true);
                else
                    mfDays.SetVisible(false);

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "InstructionsDayTypeEvent");
            }

        }


        protected void TransferTimeEvent(object sender, AjaxEventArgs e)
        {
            try
            {

                //int transferTime = ValidationHelper.GetInteger( IsSelectTransferTime.Value,0);
                int transferTime = ValidationHelper.GetInteger(new_TransferTime.Value, 0);

                if (transferTime == 2)
                    SweepTime.SetVisible(true);
                else
                    SweepTime.SetVisible(false);

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "TransferTimeEvent");
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
                //string rejectDescription = ValidationHelper.GetString(new_RejectDescription.Value);
                
                //windowReject.Hide();
                //var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                //ms.Show(".", "İlgili işlem, reddedildi");

                var config = "/ISV/TU/LimitApproverManagement/LimitApproverManagementDetail.aspx?RecordId=" + refId + "&islem=islemTamamOnay&IslemTip=" + hdnTransactionType.Value.ToString();
                Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionList.Denied", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }

        protected void SaveOnEvent(object sender, AjaxEventArgs e)
        {
            string resultStr ="";
            Guid senderAccountCurrencyId = Guid.Empty;
            string senderAccountName, recipientAccountName;
            try
            {
                if (ValidationHelper.GetGuid( new_CorporationId.Value) == Guid.Empty )
                {
                    ShowMessage("Kurum seçimi yapmalısınız!");
                    new_CorporationId.Focus();
                    return;
                }

                if (ValidationHelper.GetGuid(new_SenderAccountId.Value) == Guid.Empty)
                {
                    ShowMessage("Gönderen hesap seçimi yapmalısınız!");
                    new_SenderAccountId.Focus();
                    return;
                }

                if (ValidationHelper.GetGuid(new_RecipientCorparationAccountId.Value) == Guid.Empty)
                {
                    ShowMessage("Alıcı hesap seçimi yapmalısınız!");
                    new_RecipientCorparationAccountId.Focus();
                    return;
                }

                if (String.IsNullOrEmpty( new_SweepBalance.Value))
                {
                    ShowMessage("Süpürülecek Bakiye seçimi yapmalısınız!");
                    new_SweepBalance.Focus();
                    return;
                }

                if (String.IsNullOrEmpty(new_SweepType.Value))
                {
                    ShowMessage("Süpürme Tipini seçimi yapmalısınız!");
                    new_SweepType.Focus();
                    return;
                }

                if(String.IsNullOrEmpty(new_InstructionsStatus.Value))
                {
                    ShowMessage("Talimat Durmu seçimi yapmalısınız!");
                    new_InstructionsStatus.Focus();
                    return;
                }


                Guid recId = ValidationHelper.GetGuid( hdnRecId.Value);

                string instructionsDay = null;

                instructionsDay += chcPazartesi.Checked ? "1," : "";
                instructionsDay += chcSali.Checked ? "2," : "";
                instructionsDay += chcCarsamba.Checked ? "3," : "";
                instructionsDay += chcPersembe.Checked ? "4," : "";
                instructionsDay += chcCuma.Checked ? "5," : "";
                instructionsDay += chcCumartesi.Checked ? "6," : "";
                instructionsDay += chcPazar.Checked ? "7," : "";

                if (String.IsNullOrEmpty(instructionsDay))
                    instructionsDay = null;

                /*
                 
                selected_new_SenderAccountId


                [{"ID":"af789464-6fb8-4172-8c4d-e735c79c24ff","VALUE":"120815 - UPT Kurum USD","New_AccountsId":"af789464-6fb8-4172-8c4d-e735c79c24ff","new_AccountNo":"1636607","new_BalanceCurrency":"00000014-cc12-4c0b-b400-453c1224a189","new_BalanceCurrencyName":"USD","new_Description":"120815 - UPT Kurum USD","new_Balance":0,"new_MinimumBalance":0,"new_Limit":0,"new_UsableBalance":0,"IBAN":""}]
                 */


                //string test = this.Context.Items["selected_new_SenderAccountId"].ToString();
                //var s = JsonConvert.DeserializeObject<dynamic>(test);

                Guid senderAccountId = ValidationHelper.GetGuid(new_SenderAccountId.Value.ToString());
                Guid senderAccountParentId = Guid.Empty;
                Guid recipientCorparationAccountId = ValidationHelper.GetGuid(new_RecipientCorparationAccountId.Value.ToString());

                //gönderen hesap için başka talimat var mı, varsa hata ver
                var accountControl = fac.SenderAccountControl(senderAccountId, recId);
                if (accountControl)
                {
                    ShowMessage("Gönderen hesap için tanımlı talimat bulunmaktadır!");
                    return;
                }

                //var senderAccount = UPTCache.AccountService.GetAccountByAccountId(senderAccountId);
                var senderAccount = fac.GetAccountInfo(senderAccountId);
                recipientAccountName = AccountDescription(recipientCorparationAccountId);

                if (senderAccount != null)
                {
                    senderAccountCurrencyId = senderAccount.Currency.CurrencyId;
                    senderAccountName = senderAccount.AccountName;
                    senderAccountParentId = fac.GetAccountInfo(senderAccountId).ParentAccountId;
                }
                else
                {
                    ShowMessage("Gönderici hesap bilgisi bulunamadı.");
                    return;
                }

                if (String.IsNullOrEmpty( recipientAccountName ))
                {
                     ShowMessage("Alıcı hesap bilgisi bulunamadı.");
                    return;
                }

                SweepInstructions req = new SweepInstructions();
                req.Name = senderAccountName + "/" + recipientAccountName;
                req.SweepInstructionsId = recId;
                req.CorporationId = ValidationHelper.GetGuid(new_CorporationId.Value.ToString());
                req.SenderAccountId = senderAccountId;
                req.SenderAccountParentId = senderAccountParentId;
                req.SweepAmountCurrencyId = senderAccountCurrencyId;
                req.RecipientCorparationAccountId = recipientCorparationAccountId;
                req.SweepBalance = (SweepBalanceEnum) System.Enum.Parse(typeof(SweepBalanceEnum), new_SweepBalance.Value);
                req.SweepLevelAmount = ValidationHelper.GetDecimal(new_SweepLevelAmount.Value, 0);
                req.SweepAmount = ValidationHelper.GetDecimal( new_SweepAmount.Value,0);
                req.SweepType = (SweepTypeEnum)System.Enum.Parse(typeof(SweepTypeEnum), new_SweepType.Value);
                if (!String.IsNullOrEmpty( new_InstructionsDayType.Value))
                    req.InstructionsDayType = (InstructionsDayTypeEnum)System.Enum.Parse(typeof(InstructionsDayTypeEnum), new_InstructionsDayType.Value);

                req.InstructionsDay = instructionsDay;

                if (!String.IsNullOrEmpty(new_TransferTime.Value))
                    req.TransferTime = (TransferTimeEnum)System.Enum.Parse(typeof(TransferTimeEnum), new_TransferTime.Value);
               

                if (req.TransferTime.GetHashCode() == 2 || req.SweepType != SweepTypeEnum.GUNLUK)
                {
                    req.SweepHour = ValidationHelper.GetString(new_SweepHour.Value);
                    req.SweepMinute = ValidationHelper.GetString(new_SweepMinute.Value);
                }
                req.InstructionsStatus = (InstructionsStatusEnum)System.Enum.Parse(typeof(InstructionsStatusEnum), new_InstructionsStatus.Value);
                req.ScheduledTime = ValidationHelper.GetDate(new_ScheduledTime.Value);
                SweepInstructions ret = fac.AddSweepInstructions(req);

                if (recId == Guid.Empty)
                    recId = ret.SweepInstructionsId;

                if (ret.SweepInstructionsId != Guid.Empty)
                {

                    SweepInstructionsApproval approval = new SweepInstructionsApproval()
                    {
                        ApprovalKey = recId.ToString(),
                        CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                        SweepInstructionsId = recId,
                        DeletionState = 0
                    };
                    resultStr = approval.Save();
                    if (string.IsNullOrEmpty(resultStr))
                    {

                        var config = "/ISV/TU/SweepInstructions/SweepInstructionsListDetail.aspx?RecordId=" + recId.ToString() + "&islem=islemOnay";
                        Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                    }
                    else
                    {
                        ShowMessage(resultStr);
                        LogUtil.WriteException(new Exception(resultStr), "Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionList.SaveOnEvent Approval.Save", "Exception");
                    }
                }else
                {
                    ShowMessage("İşlem referans numarası bilgisi girilmelidir.");
                    return;
                }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.CloudAccountTransaction.CloudAccountTransactionList.SaveOnEvent", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }

        protected void DeletionOnEvent(object sender, AjaxEventArgs e)
        {
            string resultStr = "";
            try
            {
 

                Guid recId = ValidationHelper.GetGuid(hdnRecId.Value);
                
 
                var result = fac.UpdateSweeInstructionConfirmStatus(recId, InstructionsConfirmStatusEnum.ONAY_BEKLIYOR);

                if (result)
                {
                    SweepInstructionsApproval approval = new SweepInstructionsApproval()
                    {
                        ApprovalKey = recId.ToString(),
                        CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                        SweepInstructionsId = recId,
                        DeletionState = 1
                    };
                    resultStr = approval.Save();
                    if (string.IsNullOrEmpty(resultStr))
                    {

                        var config = "/ISV/TU/SweepInstructions/SweepInstructionsListDetail.aspx?RecordId=" + recId.ToString() + "&islem=islemOnay";
                        Response.Redirect(HTTPUtil.GetWebAppRoot().ToString() + config);
                    }
                    else
                    {
                        ShowMessage(resultStr);
                    }
                }

            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsListDetail.DeletionOnEvent", "Exception");

                var ms = new MessageBox { MessageType = EMessageType.Error, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", "Hata!! İşlem Yapılamadı");
            }
        }

        public string AccountDescription(Guid AccountId)
        {
            string searchtext = "";
            string action = "Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsListDetail.AccountDescription";
            try
            {
                string test = this.Context.Items["selected_new_RecipientCorparationAccountId"].ToString();
                var s = JsonConvert.DeserializeObject<List<AccountListView>>(test);
                searchtext = s[0].VALUE;
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, action, "Exception");
            }
            return searchtext;
        }

        void ShowMessage(string messageText)
        {
            MessageBox messageBox = new MessageBox();
            messageBox.Width = 400;
            messageBox.Height = 200;
            messageBox.Show(messageText);
        }

    }
}
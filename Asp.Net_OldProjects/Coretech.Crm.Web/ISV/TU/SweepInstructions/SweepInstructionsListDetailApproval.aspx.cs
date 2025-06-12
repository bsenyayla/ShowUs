using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Integration3rd.Cloud.Domain;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using TuFactory.CustomApproval;
using TuFactory.Domain.SweepInstructions.Enums;
using TuFactory.Object;
using TuFactory.SweepInstructions;
using UPTCache = UPT.Shared.CacheProvider.Service;

namespace Coretech.Crm.Web.ISV.TU.SweepInstructionsList
{
    public partial class SweepInstructionsListDetailApproval : CustomApprovalPage<SweepInstructionsApproval>
    {
        SweepInstructionsFactory fac = new SweepInstructionsFactory();

        protected override void SetApprovalData()
        {

            hdnRecId.Value = ValidationHelper.GetString(this.Approval.SweepInstructionsId.ToString());
            int? deletionState = this.Approval.DeletionState;

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

                if (deletionState == 1)
                    lCancelTransaction.SetVisible(true);
                else
                    lCancelTransaction.SetVisible(false);

                mfDays.SetVisible(false);
                new_InstructionsDayType.SetVisible(false);
                new_TransferTime.SetVisible(false);
                SweepTime.SetVisible(false);
                new_SweepAmount.SetVisible(false);
                new_SweepLevelAmount.SetVisible(false);
                if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
                {

                    
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

                    new_CorporationId.Value = rec.Rows[0]["new_CorporationId"].ToString();
                    new_CorporationId.SetValue(ValidationHelper.GetGuid(rec.Rows[0]["new_CorporationId"].ToString()));


                    new_SenderAccountId.SetValue(rec.Rows[0]["new_SenderAccountId"].ToString());
                    new_SenderAccountId.Value = rec.Rows[0]["new_SenderAccountId"].ToString();
                    new_SenderAccountId.Text = rec.Rows[0]["new_SenderAccountIdName"].ToString();

                    newRecipientCorpAccountLoad(null, null);
                    new_RecipientCorparationAccountId.FillDynamicEntityData(tr);

                    new_SweepBalance.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_SweepBalance"].ToString()));
                    new_SweepBalance.Value = rec.Rows[0]["new_SweepBalance"].ToString();

                    new_SweepAmount.SetValue(rec.Rows[0]["new_SweepAmount"].ToString());
                    new_SweepLevelAmount.SetValue(rec.Rows[0]["new_SweepLevelAmount"].ToString());
                    //new_SweepType.SetValue(sweepType);
                    new_SweepType.Value = sweepType.ToString();
                    new_InstructionsDayType.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_InstructionsDayType"].ToString()));
                    new_TransferTime.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_TransferTime"].ToString()));
                    new_SweepHour.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SweepHour"].ToString()));
                    new_SweepMinute.SetValue(ValidationHelper.GetString(rec.Rows[0]["new_SweepMinute"].ToString()));
                    new_InstructionsStatus.SetValue(ValidationHelper.GetInteger(rec.Rows[0]["new_InstructionsStatus"].ToString()));
                    new_InstructionsConfirmStatus.Value = rec.Rows[0]["new_InstructionsConfirmStatus"].ToString();

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

                        if (transferTimeEnum == TransferTimeEnum.SUPURME_SAATI)
                        {
                            SweepTime.SetVisible(true);
                        }

                    }
                    else
                    {
                        SweepTime.SetVisible(true);
                    }

                    if (!String.IsNullOrEmpty(rec.Rows[0]["new_ScheduledTime"].ToString()))
                        new_ScheduledTime.Value = ValidationHelper.GetDate(rec.Rows[0]["new_ScheduledTime"].ToString());

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



                    if (ValidationHelper.GetInteger(new_InstructionsConfirmStatus.Value) == 0)
                    {
                        
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

                    }

                    //if (rec.Rows[0]["new_IsNkolayRepresentative"].ToString() != null)
                    //    new_IsNkolayRepresentative.SetValue(ValidationHelper.GetBoolean(rec.Rows[0]["new_IsNkolayRepresentative"].ToString()));

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
                    //new_SenderAccountId.TotalCount = ds.Tables[0].Rows.Count;
                    //new_SenderAccountId.DataSource = ds.Tables[0];
                    //new_SenderAccountId.DataBind();
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
                    var senderAccount =  fac.GetAccountInfo(senderAccountId);
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
                                   where customer.Field<string>("VALUE").IndexOf(searchtext) > 0
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

                    TransferTimeEvent(null, null);
                    InstructionsDayTypeEvent(null, null);
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

                    new_SweepLevelAmount.Value = 0;
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
        protected void TransferTimeEvent(object sender, AjaxEventArgs e)
        {
            //try
            //{
            //    int transferTime = ValidationHelper.GetInteger(new_InstructionsDayType.Value, 0);

            //    if (transferTime == 2)
            //        mfDays.SetVisible(true);
            //    else
            //        mfDays.SetVisible(false);

            //}
            //catch (Exception ex)
            //{
            //    LogUtil.WriteException(ex, "MobileDocument.Report");
            //}

        }
    }
}
using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Confirm;
using TuFactory.Fraud;
using TuFactory.Object;
using TuFactory.Object.Confirm;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.PluginData;
using System.Data;
using TuFactory.Data;
using Integration3rd.NKolay;
using Integration3rd.NKolay.Domain;
using Upt.GsmPayment.Business;
using System.Data.Common;
using Upt.GsmPayment.Domain;
using TuFactory.ExtensionManager.Services;
using TuFactory.ExtensionManager.Model.Request;
using TuFactory.ExtensionManager;

public partial class Detail_Detail_Confirm : BasePage
{
    //CRM.NEW_FRAUDLOG_BTN__REJECT
    //
    //
    private TuUserApproval _userApproval = null;
    private TuUser _activeUser = null;
    MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };
    private DynamicSecurity DynamicSecurity;
    FraudFactory ff = new FraudFactory();
    private void TranslateMessages()
    {

        ToolbarButtonContinue.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_CONTINUE");
        ToolbarButtonContinue1.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_CONTINUE");
        ToolbarButtonCancel.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_INTERRUPT");
        ToolbarButtonCancel1.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_INTERRUPT");

        ToolbarButtonConfirm.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_CONFIRM");

        ToolbarButtonReturn.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_RETURN");
        ToolbarButtonReturn1.Text = CrmLabel.TranslateMessage("CRM.NEW_FRAUDLOG_BTN_RETURN");
        ToolbarButtonMd.Text = CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_PROCESS_MONITORING_DETAIL");




    }
    private void ReConfigureButtons()
    {
        var ret = string.Empty;
        var result = ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);

        ToolbarButtonContinue.Visible = false;
        ToolbarButtonContinue1.Visible = false;
        ToolbarButtonCancel.Visible = false;
        ToolbarButtonCancel1.Visible = false;
        ToolbarButtonConfirm.Visible = false;
        ToolbarButtonReturn.Visible = false;
        ToolbarButtonReturn1.Visible = false;

        switch (result)
        {
            case FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_BEKLIYOR:
            case FraudConfirmStatus.ISLEM_KESILME_ONAYI_BEKLIYOR:
                if (_userApproval.ApprovalFraud)
                {
                    ToolbarButtonConfirm.Visible = true;
                    ToolbarButtonReturn.Visible = true;
                    ToolbarButtonReturn1.Visible = true;
                }
                break;
            case FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_GERI_CEVRILDI:
            case FraudConfirmStatus.ISLEM_KESILME_ONAYI_GERI_CEVRILDI:
            case FraudConfirmStatus.ISLEM_OTOMATIK_KESILDI:
            case "":
                if (DynamicSecurity.PrvAppend)
                {
                    ToolbarButtonContinue.Visible = true;
                    ToolbarButtonContinue1.Visible = true;
                    ToolbarButtonCancel.Visible = true;
                    ToolbarButtonCancel1.Visible = true;
                }
                break;

        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var ufFactory = new TuUserFactory();
        _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_FraudLog.GetHashCode(), null);


        if (!RefleX.IsAjxPostback)
        {

            hdnEntityId.Value = App.Params.CurrentEntity[TuEntityEnum.New_FraudLog.GetHashCode()].EntityId.ToString();

            TranslateMessages();

            hdnRecId.Value = QueryHelper.GetString("recid");


            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", ""},
                                {"ObjectId", TuEntityEnum.New_FraudLog.GetHashCode().ToString()},
                                {"recid", hdnRecId.Value}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            PanelIframe.AutoLoad.Url = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            hiddenUrl.Value = Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);

            ReConfigureButtons();
        }

    }

    protected void Continue(object sender, AjaxEventArgs e)
    {
        if (!DynamicSecurity.PrvAppend)
            return;

        bool reqSuccess = ff.AmlConfirmRequest(ValidationHelper.GetGuid(hdnRecId.Value), new_FraudContinueReason.Value, ValidationHelper.GetGuid(new_FraudContinueReasonId.Value), true);
        if (reqSuccess)
        {
            var ret = string.Empty;
            ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);

            ContinueConfirm();
        }
        else
        {
            QScript("alert('Onay işlemi devam ettirilemedi, onay başka bir kullanıcı tarafından sürdürülüyor olabilir.');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
            return;
        }

        /*Islem Devam ettirildiğinde otomatik olarak onaylanacak*/
        /* if (!string.IsNullOrEmpty(ret))
         {
             QScript("alert('" + ret + "');");
             QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
         }
         */

    }
    protected void ContinueConfirm()
    {
        if (!_userApproval.ApprovalFraud)
            return;
        var confirm = false;
        var statusTypeName = string.Empty;
        var staus = ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out statusTypeName);

        var df = new DynamicFactory(ERunInUser.SystemAdmin);

        var retrec = df.RetrieveWithOutPlugin((int)TuEntityEnum.New_FraudLog, ValidationHelper.GetGuid(hdnRecId.Value), new string[] { "new_TransferID", "new_PaymentID", "new_GsmPaymentId", "OwningUser" });
        var objectId = 0;
        Guid tpid = new Guid();
        if (retrec.GetLookupValue("new_TransferID") != Guid.Empty)
        {
            objectId = (int)TuEntityEnum.New_Transfer;
            tpid = retrec.GetLookupValue("new_TransferID");
        }
        else if (retrec.GetLookupValue("new_PaymentID") != Guid.Empty)
        {
            objectId = (int)TuEntityEnum.New_Payment;
            tpid = retrec.GetLookupValue("new_PaymentID");
        }
        else if (retrec.GetLookupValue("new_GsmPaymentId") != Guid.Empty)
        {
            objectId = (int)TuEntityEnum.New_GsmPayment;
            tpid = retrec.GetLookupValue("new_GsmPaymentId");
        }
        var owningUser = retrec.GetOwnerValue("OwningUser");
        string sql = string.Empty;
        string corporationCode = string.Empty;
        string SourceTransactionTypeIDName = string.Empty;
        string channel = string.Empty;
        StaticData sd = new StaticData();
        if (objectId == TuEntityEnum.New_Transfer.GetHashCode())
        {
            sql = @"SELECT new_SourceTransactionTypeIDName, ISNULL(new_Channel,0), c.new_CorporationCode
                        FROM vNew_Transfer t
                        INNER JOIN vNew_Corporation c
                        ON t.new_CorporationID = c.New_CorporationId
                        WHERE New_TransferId = @PARAMETERNAME";
            sd.AddParameter("PARAMETERNAME", DbType.Guid, tpid);
            DataTable dtParam = sd.ReturnDataset(sql).Tables[0];

            SourceTransactionTypeIDName = dtParam.Rows[0][0].ToString();
            channel = dtParam.Rows[0][1].ToString();
            corporationCode = dtParam.Rows[0][2].ToString();
        }

        if (objectId == TuEntityEnum.New_Payment.GetHashCode())
        {
            sql = @"SELECT  ISNULL(new_Channel,0), c.new_CorporationCode
                        FROM vNew_Payment (NOLOCK) t
                        INNER JOIN vNew_Corporation (NOLOCK) c
                        ON t.new_PaidByCorporation = c.New_CorporationId
                        WHERE New_PaymentId = @PARAMETERNAME";
            sd.AddParameter("PARAMETERNAME", DbType.Guid, tpid);
            DataTable dtParam = sd.ReturnDataset(sql).Tables[0];

            channel = dtParam.Rows[0][0].ToString();
            corporationCode = dtParam.Rows[0][1].ToString();
        }

        if (_userApproval.ApprovalFraud)
        {
            string onlineUptCorporationCode = App.Params.GetConfigKeyValue("ONLINEUPT_CORPORATION_CODE");
            if (corporationCode == onlineUptCorporationCode)
            {
                QScript("alert('Online UPT işlemi devam ettirilemez.');");
                return;
            }

            if (staus == FraudConfirmStatus.ISLEM_KESILME_ONAYI_BEKLIYOR)
            {
                confirm = ff.AmlInterruptConfirm(ValidationHelper.GetGuid(hdnRecId.Value));
            }
            else if (staus == FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_BEKLIYOR)
            {
                if ((SourceTransactionTypeIDName == "Dosya" || channel == "4" || channel == "3") && objectId != TuEntityEnum.New_Payment.GetHashCode())
                {
                    /* Döviz Cinsi ve Tutar Kurum Onay Mekanizmasına Takılırsa Normal İşlem Yapılacak */

                    StaticData sd2 = new StaticData();
                    string sql2 = string.Empty;
                    if (objectId == TuEntityEnum.New_Transfer.GetHashCode())
                    {
                        sql2 = @"Select ad.* from vNew_Transfer t 
                                        inner join vSystemUser u on t.OwningUser = u.SystemUserId
                                        inner join vNew_ApprovalMechanizm a on t.new_CorporationID = a.new_CorporationID
                                        inner join vNew_ApprovalMechanizmDetail ad on a.New_ApprovalMechanizmId = ad.new_ApprovalMechanizmID
                                        inner join vnew_ApprovalLevel ual on ual.New_ApprovalLevelId=u.new_ApprovalLevelID
                                        inner join vnew_ApprovalLevel aal on aal.New_ApprovalLevelId=ad.new_ApprovalLevelID
                                        Where t.New_TransferId = @TransferId 
                                        and (a.new_TransactionTypeIDName = 'Dosya' OR t.new_Channel = 4 OR t.new_Channel = 3)
                                        and a.new_CurrencyID = t.new_AmountCurrency and 
                                        t.new_Amount <= ad.new_Amount
                                        AND (ual.new_LevelNumber>=aal.new_LevelNumber)
                                        And t.DeletionStateCode = 0
                                        and a.DeletionStateCode = 0
                                        and ad.DeletionStateCode = 0
                                        and u.DeletionStateCode = 0";

                        sd2.AddParameter("@TransferId", DbType.Guid, tpid);
                    }


                    DataTable dtParam2 = sd2.ReturnDataset(sql2).Tables[0];
                    var cf = new ConfirmFactory();
                    if (dtParam2.Rows.Count > 0)
                    {
                        confirm = ff.AmlConfirm(ValidationHelper.GetGuid(hdnRecId.Value));

                        if (confirm)
                        {
                            List<TuConfirmList> cl = new List<TuConfirmList>();

                            TuConfirmList tuConfirmList = new TuConfirmList()
                            {
                                ObjectId = objectId,
                                RecId = ValidationHelper.GetGuid(tpid)
                            };

                            cl.Add(tuConfirmList);

                            cf.Confirm(cl);
                            //cf.AfterConfirm(cl[0]);

                            /*cf.ConfirmPrintedWidthTrans(ValidationHelper.GetInteger(cl[0].ObjectId, 0),
                                                        ETuConfirmType.Transaction,
                                                        ValidationHelper.GetGuid(cl[0].RecId));*/
                        }
                    }
                    else
                    {
                        StaticData sd3 = new StaticData();
                        sd3.AddParameter("@Prm1", DbType.String, FraudConfirmStatus.ISLEM_KULLANICI_TARAFINDAN_DEVAM_ETTIRILDI);
                        DataTable dt = sd3.ReturnDataset("Select New_FraudConfirmStatusId from vNew_FraudConfirmStatus Where new_ExtCode = @Prm1").Tables[0];
                        if (dt.Rows.Count > 0)
                        {
                            sd3.AddParameter("@Prm2", DbType.Guid, Guid.Parse(dt.Rows[0][0].ToString()));
                            sd3.AddParameter("@Prm3", DbType.Guid, tpid);
                            sd3.ExecuteNonQuery("Update vNew_FraudLog set new_FraudConfirmStatusId=@Prm2 Where new_TransferID=@Prm3");
                            var cd = new ConfirmDb();
                            cd.CreateTransactionConfirmLine(objectId, tpid, owningUser, null);
                            ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out statusTypeName);
                            QScript("alert('" + statusTypeName + "');");
                            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
                        }
                    }
                }
                else if (objectId == TuEntityEnum.New_Payment.GetHashCode())
                {
                    confirm = ff.AmlPaymentConfirm(ValidationHelper.GetGuid(hdnRecId.Value));
                    if (confirm)
                    {
                        QScript("alert('Ödeme işlemi devam ettirildi,tekrar ödeme karşılamadan ödeyebilirsiniz.');");
                        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
                        return;
                    }
                }
                else if (objectId == TuEntityEnum.New_GsmPayment.GetHashCode())
                {
                    confirm = AmlGsmPaymentConfirm(ValidationHelper.GetGuid(hdnRecId.Value));
                    if (confirm)
                    {
                        QScript("alert('Kontör yükleme işlemi devam ettirildi');");
                        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
                        return;
                    }
                }
                else
                {
                    confirm = ff.AmlConfirm(ValidationHelper.GetGuid(hdnRecId.Value));
                }
            }
        }
        else
        {
            return;
        }

        if (!confirm)
        {
            QScript("alert('Onay işlemi devam ettirilemedi, onay başka bir kullanıcı tarafından sürdürülüyor olabilir.');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
            return;
        }

        ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out statusTypeName);
        if (!string.IsNullOrEmpty(statusTypeName))
        {
            QScript("alert('" + statusTypeName + "');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
    }

    protected void Confirm(object sender, AjaxEventArgs e)
    {
        if (!_userApproval.ApprovalFraud)
            return;
        var confirm = false;
        var statusTypeName = string.Empty;
        var staus = ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out statusTypeName);

        var df = new DynamicFactory(ERunInUser.SystemAdmin);

        var retrec = df.RetrieveWithOutPlugin((int)TuEntityEnum.New_FraudLog, ValidationHelper.GetGuid(hdnRecId.Value), new string[] { "new_TransferID", "new_PaymentID", "new_GsmPaymentId", "OwningUser" });
        var objectId = 0;
        Guid tpid = new Guid();

        if (retrec.GetLookupValue("new_TransferID") != Guid.Empty)
        {
            objectId = (int)TuEntityEnum.New_Transfer;
            tpid = retrec.GetLookupValue("new_TransferID");
        }
        else if (retrec.GetLookupValue("new_PaymentID") != Guid.Empty)
        {
            objectId = (int)TuEntityEnum.New_Payment;
            tpid = retrec.GetLookupValue("new_PaymentID");
        }
        else if (retrec.GetLookupValue("new_GsmPaymentId") != Guid.Empty)
        {
            objectId = (int)TuEntityEnum.New_GsmPayment;
            tpid = retrec.GetLookupValue("new_GsmPaymentId");
        }
        var owningUser = retrec.GetOwnerValue("OwningUser");

        StaticData sd = new StaticData();
        string sql = string.Empty;
        string corporationCode = string.Empty;
        if (objectId == TuEntityEnum.New_Transfer.GetHashCode())
        {
            sql = @"SELECT new_SourceTransactionTypeIDName, ISNULL(new_Channel,0), c.new_CorporationCode
                        FROM vNew_Transfer t
                        INNER JOIN vNew_Corporation c
                        ON t.new_CorporationID = c.New_CorporationId
                        WHERE New_TransferId = @PARAMETERNAME";

            sd.AddParameter("PARAMETERNAME", DbType.Guid, tpid);
            DataTable dtParam = sd.ReturnDataset(sql).Tables[0];

            string SourceTransactionTypeIDName = dtParam.Rows[0][0].ToString();
            string channel = dtParam.Rows[0][1].ToString();
            corporationCode = dtParam.Rows[0][2].ToString();
        }

        if (_userApproval.ApprovalFraud)
        {
            string onlineUptCorporationCode = App.Params.GetConfigKeyValue("ONLINEUPT_CORPORATION_CODE");
            if (corporationCode == onlineUptCorporationCode)
            {
                QScript("alert('Online UPT işlemi devam ettirilemez.');");
                return;
            }

            if (staus == FraudConfirmStatus.ISLEM_KESILME_ONAYI_BEKLIYOR)
            {
                confirm = ff.AmlInterruptConfirm(ValidationHelper.GetGuid(hdnRecId.Value));

                if (confirm)
                {
                    /* NKolay AML kesilmelerini de kendilerine bildirmemizi istedi */
                    var sd2 = new StaticData();
                    DataTable dt = new DataTable();
                    var corporationId = Guid.Empty;
                    var TransferId = Guid.Empty;
                    string transferTuref = string.Empty;

                    if (objectId == (int)TuEntityEnum.New_Transfer)
                    {
                        sd2.AddParameter("TransferId", DbType.Guid, ValidationHelper.GetGuid(tpid));
                        dt = sd2.ReturnDataset("Select new_CorporationId, TransferTuRef, ISNULL(new_Channel,0) Channel from vNew_Transfer(NoLock) Where New_TransferId = @TransferId ").Tables[0];
                        TransferId = tpid;

                        // Extension Manager
                        // Aml Interrupt Confirm ();
                        // senkron
                        if (ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("WITH_EXTENSION_MANAGER")) == true)
                        {
                            bool isCorporationAvailable = new ExtensionDb().GetExtensionMappingByCorporationId(ValidationHelper.GetGuid(dt.Rows[0]["new_CorporationId"]));
                            if (ValidationHelper.GetString(dt.Rows[0]["Channel"]) == "1" && isCorporationAvailable == true)
                            {
                                var commonService = new CommonService();
                                var transaction = commonService.GetTransfer(TransferId);
                                var transactionService = new TransactionService<TuFactory.Domain.Transfer>(TuFactory.ExtensionManager.Model.TransactionTypeCodeEnum.TRC, TuFactory.ExtensionManager.Model.CustomerAmountDirectionEnum._Positive, TuFactory.ExtensionManager.Model.Operation.AmlInterruptConfirmTransfer);
                                var responseBase = transactionService.Confirm(transaction);
                                if(!responseBase.ReturnCode)
                                {
                                    LogUtil.Write(responseBase.ReturnData, "_Confirm.aspx");
                                }
                            }
                        }
                    }
                    else if (objectId == (int)TuEntityEnum.New_Payment)
                    {
                        sd2.AddParameter("PaymentId", DbType.Guid, ValidationHelper.GetGuid(tpid));
                        dt = sd2.ReturnDataset("Select new_PaidByCorporation new_CorporationId, new_TransferID TransferId, new_TransferIDName TransferTuRef from vNew_Payment(NoLock) Where New_PaymentId = @PaymentId ").Tables[0];
                        TransferId = ValidationHelper.GetGuid(dt.Rows[0]["TransferId"]);
                    }
                    //else if (objectId == (int)TuEntityEnum.New_GsmPayment)
                    //{
                    //    GsmTransactionService service = new GsmTransactionService();
                    //    service.UpdateGsmTransactionLoadStatus(GsmLoadStatus.Yukleme_Upt_Merkezi_Onayi_Reddedildi, tpid, App.Params.CurrentUser.SystemUserId, null);
                    //}

                    if (dt.Rows.Count > 0)
                    {
                        corporationId = ValidationHelper.GetGuid(dt.Rows[0]["new_CorporationId"]);
                        transferTuref = ValidationHelper.GetString(dt.Rows[0]["TransferTuRef"]);


                        var IsContinueNKolayService = ValidationHelper.GetBoolean(App.Params.GetConfigKeyValue("IS_CONTINUE_EFT_IADE_NKOLAY_SERVICE"), false);
                        if (IsContinueNKolayService)
                        {
                            var NKolayCorporationId = ValidationHelper.GetGuid(App.Params.GetConfigKeyValue("TK_NKOLAY_ID"));
                            if (NKolayCorporationId == corporationId)
                            {
                                string retData = string.Empty;
                                ServiceManager serviceManagerNKolay = new ServiceManager();
                                var result = serviceManagerNKolay.UpdateTransferStatus(ValidationHelper.GetGuid(TransferId), transferTuref, State.NKolay, 0, string.Empty, false, out retData);
                                if (!result)
                                {
                                    LogUtil.Write(string.Format("Statü = {0} {1} {2}", "State.NKolayaGecti", transferTuref, retData));
                                }
                            }
                        }
                    }
                }

            }
            else if (staus == FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_BEKLIYOR)
            {
                if (objectId == TuEntityEnum.New_Payment.GetHashCode())
                {
                    if (ff.AmlPaymentConfirm(ValidationHelper.GetGuid(hdnRecId.Value)))
                    {
                        QScript("alert('Ödeme işlemi devam ettirildi,tekrar ödeme karşılamadan ödeyebilirsiniz.');");
                        return;
                    }
                }
                else if (objectId == TuEntityEnum.New_GsmPayment.GetHashCode())
                {
                    confirm = AmlGsmPaymentConfirm(ValidationHelper.GetGuid(hdnRecId.Value));
                    if (confirm)
                    {


                        QScript("alert('Kontör yükleme işlemi devam ettirildi');");
                        QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
                        return;
                    }
                }
                else
                {
                    confirm = ff.AmlConfirm(ValidationHelper.GetGuid(hdnRecId.Value));
                }
            }
        }
        else
        {
            return;
        }
        if (!confirm)
            return;
        ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out statusTypeName);
        if (!string.IsNullOrEmpty(statusTypeName))
        {
            QScript("alert('" + statusTypeName + "');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
    }

    protected void Cancel(object sender, AjaxEventArgs e)
    {
        if (!DynamicSecurity.PrvAppend)
            return;

        bool reqSuccess = ff.AmlConfirmRequest(ValidationHelper.GetGuid(hdnRecId.Value), new_FraudCancelReason.Value, ValidationHelper.GetGuid(new_FraudCancelReasonId.Value), false);
        if (reqSuccess)
        {
            var ret = string.Empty;
            ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);
            if (_userApproval.ApprovalFraud)
            {

            }
            if (!string.IsNullOrEmpty(ret))
            {
                QScript("alert('" + ret + "');");
                QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
            }
        }
        else
        {
            QScript("alert('Onay işlemi devam ettirilemedi, onay başka bir kullanıcı tarafından sürdürülüyor olabilir.');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
            return;
        }
    }
    protected void ConfirmCancel(object sender, AjaxEventArgs e)
    {

        if (!_userApproval.ApprovalFraud)
            return;

        var ret = string.Empty;
        var staus = ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);

        if (_userApproval.ApprovalFraud)
        {
            if (staus == FraudConfirmStatus.ISLEM_KESILME_ONAYI_BEKLIYOR)
            {
                ff.AmlStatusChange(ValidationHelper.GetGuid(hdnRecId.Value), FraudConfirmStatus.ISLEM_KESILME_ONAYI_GERI_CEVRILDI, new_FraudConfirmCancelReason.Value, ValidationHelper.GetGuid(new_FraudConfirmCancelReasonId.Value));
            }
            else if (staus == FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_BEKLIYOR)
            {
                ff.AmlStatusChange(ValidationHelper.GetGuid(hdnRecId.Value), FraudConfirmStatus.ISLEM_DEVAM_ETTIRME_ONAYI_GERI_CEVRILDI, new_FraudConfirmCancelReason.Value, ValidationHelper.GetGuid(new_FraudConfirmCancelReasonId.Value));
            }
        }
        else
        {
            return;
        }


        ff.GetAmlStatus(ValidationHelper.GetGuid(hdnRecId.Value), out ret);
        if (!string.IsNullOrEmpty(ret))
        {
            QScript("alert('" + ret + "');");
            QScript("Frame_PanelIframe.SpecialCloseRefreshParentGrid();");
        }
    }




    /*Kontor projesinde TuFactory referans olarak ekli oyüzden bu metodu TuFactory'de yazamıyorum, Circle Referans oluyor, buyüzden metodu burda bıraktım. Ö.Y. 27.09.2017*/
    public bool AmlGsmPaymentConfirm(Guid recId)
    {
        StaticData sd = new StaticData();
        DbTransaction tr = sd.GetDbTransaction();
        var aml = new AmlDb();
        try
        {
            var tpid = Guid.Empty;
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            df.GetBeginTrans(tr);
            var retrec = df.RetrieveWithOutPlugin((int)TuEntityEnum.New_FraudLog, recId, new string[] { "new_GsmPaymentId" });
            if (retrec.GetLookupValue("new_GsmPaymentId") != Guid.Empty)
            {
                tpid = retrec.GetLookupValue("new_GsmPaymentId");

                var ret = aml.AmlConfirm(recId, App.Params.CurrentUser.SystemUserId, TuEntityEnum.New_GsmPayment.GetHashCode(), tr);
                if (ret)
                {
                    sd.AddParameter("GsmPaymentId", System.Data.DbType.Guid, tpid);
                    sd.AddParameter("SystemUserId", System.Data.DbType.Guid, App.Params.CurrentUser.SystemUserId);
                    sd.ExecuteNonQuerySp("spTuConfirmGsmPaymentAml", tr);


                    GsmTransactionService service = new GsmTransactionService();
                    GsmTransaction transaction = service.GetGsmPayment(tpid);

                    service.FraudConfirm(transaction, null, tr);

                    StaticData.Commit(tr);
                    return true;
                }
                else
                {
                    StaticData.Rollback(tr);
                    return false;
                }
            }
            else
            {
                StaticData.Rollback(tr);
                return false;
            }

        }
        catch (TuException ex)
        {
            StaticData.Rollback(tr);
            new MessageBox("Error", ".", ex.ErrorMessage);
            return false;
        }
        catch (Exception ex)
        {
            StaticData.Rollback(tr);
            throw ex;
        }
    }
}
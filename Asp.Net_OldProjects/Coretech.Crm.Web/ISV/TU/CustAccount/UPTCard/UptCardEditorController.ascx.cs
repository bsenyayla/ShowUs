using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Web.UI;
using TuFactory.CustAccount.Business;
using TuFactory.Profession;
using TuFactory.UptCard.Business;
using TuFactory.UptCard.Object;
using TuFactroy.CustAccount.WebService.Domain;
using TuFactroy.CustAccount.WebService.Domain.Base;
using UPT.Shared.Service.Name.Service;
using UPTCache = UPT.Shared.CacheProvider.Service;
using System.ComponentModel.DataAnnotations;
using TuFactory.SenderDocument;
using TuFactory.Domain;
using TuFactory.Domain.Enums;
using TransactionDetail = TuFactroy.CustAccount.WebService.Domain.TransactionDetail;
using Coretech.Crm.Factory.Crm;

public partial class CustAccount_UPTCard_UptCardEditorController : UserControl
{
    Guid senderID = ValidationHelper.GetGuid(QueryHelper.GetString("senderID"));
    string custAccountType = string.Empty;
    NumericField txtNew_MinimumCardBalance, txtNew_AutomaticTopUpAmount, txtNew_MinimumTopUpAmount, txtNew_MaximumTopUpAmount;
    ToolbarButton btnSaveAndClose, saveAsCopyButton, saveButton, deleteButton, refreshButton, btnSaveAndNew, btnAction;
    ComboField senderController, currencyMinimumCardBalance, currencyMinimumTopUpAmount, currencyMaximumTopUpAmount, currencyAutomaticTopUpAmount;
    TextField txtNew_CardNumber, txtnew_Email;
    private CardClientService _cardClientService;
    private Guid _cardId;

    protected override void OnInit(EventArgs e)
    {
        _cardId = QueryHelper.GetGuid("recid");

        txtNew_MinimumCardBalance = Page.FindControl("new_MinimumCardBalance_Container") as NumericField;

        txtNew_AutomaticTopUpAmount = Page.FindControl("new_AutomaticTopUpAmount_Container") as NumericField;
        txtNew_MinimumTopUpAmount = Page.FindControl("new_MinimumTopUpAmount_Container") as NumericField;
        txtNew_MaximumTopUpAmount = Page.FindControl("new_MaximumTopUpAmount_Container") as NumericField;
        txtNew_CardNumber = Page.FindControl("CardNumber_Container") as TextField;
        txtnew_Email = Page.FindControl("new_Email_Container") as TextField;
        btnSaveAndClose = Page.FindControl("btnSaveAndClose_Container") as ToolbarButton;
        senderController = Page.FindControl("new_SenderID_Container") as ComboField;


        if (!txtNew_MaximumTopUpAmount.Value.HasValue)
        {
            txtNew_MaximumTopUpAmount.Value = UPTCache.UptCardParametersService.GetUptCardParametersByCode("001").Amount;
        }
        if (!txtNew_MinimumTopUpAmount.Value.HasValue)
        {
            txtNew_MinimumTopUpAmount.Value = UPTCache.UptCardParametersService.GetUptCardParametersByCode("002").Amount;
        }

        this.txtNew_MaximumTopUpAmountChange(null, null);
        this.txtNew_MinimumTopUpAmountChange(null, null);

        txtNew_MinimumTopUpAmount.AjaxEvents.Change.Event += txtNew_MinimumTopUpAmountChange;
        txtNew_MaximumTopUpAmount.AjaxEvents.Change.Event += txtNew_MaximumTopUpAmountChange;
        txtNew_AutomaticTopUpAmount.AjaxEvents.Change.Event += txtNew_AutomaticTopUpAmountChange;
        txtNew_MinimumCardBalance.AjaxEvents.Change.Event += txtNew_MinimumCardBalanceChange;

        if (senderID == Guid.Empty)
        {
            _cardClientService = new CardClientService();
            senderID = _cardClientService.GetSenderId(GetCardId()).ServiceResponse;
        }

        _cardClientService = new CardClientService();
        custAccountType = _cardClientService.GetCustAccountType(senderID).ServiceResponse;

        //UptCardList.SenderId = senderID;

        base.OnInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            //if(string.IsNullOrEmpty(txtnew_Email.Value))
            //{
            //    _cardClientService = new CardClientService();

            //    var senderInfo = _cardClientService.GetSenderInfo(senderID);

            //    if(senderInfo.ServiceResponse != null)
            //    {
            //        txtnew_Email.SetValue(senderInfo.ServiceResponse.Email);
            //    }
            //}

            var activeFlg = Page.FindControl("new_IsActive_Container") as CheckField;
            activeFlg.Checked = true;

            saveButton = Page.FindControl("btnSave_Container") as ToolbarButton;
            saveAsCopyButton = Page.FindControl("btnSaveAsCopy_Container") as ToolbarButton;
            deleteButton = Page.FindControl("btnDelete_Container") as ToolbarButton;
            refreshButton = Page.FindControl("btnRefresh_Container") as ToolbarButton;
            btnSaveAndClose = Page.FindControl("btnSaveAndClose_Container") as ToolbarButton;
            btnSaveAndNew = Page.FindControl("btnSaveAndNew_Container") as ToolbarButton;
            btnAction = Page.FindControl("btnAction_Container") as ToolbarButton;


            txtNew_MinimumCardBalance = Page.FindControl("new_MinimumCardBalance_Container") as NumericField;
            txtNew_AutomaticTopUpAmount = Page.FindControl("new_AutomaticTopUpAmount_Container") as NumericField;
            txtNew_MinimumTopUpAmount = Page.FindControl("new_MinimumTopUpAmount_Container") as NumericField;
            txtNew_MaximumTopUpAmount = Page.FindControl("new_MaximumTopUpAmount_Container") as NumericField;
            currencyMinimumCardBalance = Page.FindControl("new_MinimumCardBalanceCurrency_Container") as ComboField;
            currencyMinimumTopUpAmount = Page.FindControl("new_MinimumTopUpAmountCurrency_Container") as ComboField;
            currencyMaximumTopUpAmount = Page.FindControl("new_MaximumTopUpAmountCurrency_Container") as ComboField;
            currencyAutomaticTopUpAmount = Page.FindControl("new_AutomaticTopUpAmountCurrency_Container") as ComboField;

            currencyMinimumCardBalance.SetDisabled(true);
            currencyAutomaticTopUpAmount.SetDisabled(true);
            currencyMinimumTopUpAmount.SetDisabled(false);
            currencyMaximumTopUpAmount.SetDisabled(false);

            saveButton.SetVisible(false);
            saveButton.SetDisabled(true);
            btnSaveAndNew.SetVisible(false);
            btnSaveAndNew.SetDisabled(true);
            refreshButton.SetVisible(false);
            refreshButton.SetDisabled(true);
            saveAsCopyButton.SetVisible(false);
            saveAsCopyButton.SetDisabled(true);
            deleteButton.SetVisible(false);
            deleteButton.SetDisabled(true);
            btnSaveAndClose.SetDisabled(true);
            btnSaveAndClose.SetVisible(false);
            //btnAction.SetVisible(false);
            //btnAction.SetDisabled(true);
            senderController.SetValue(senderID);

            if (_cardId == null || _cardId == Guid.Empty)
            {
                btnCancel.SetVisible(false);
                btnFinish.SetVisible(false);
                pnlDocuments.SetVisible(false);
                btnUpdate.SetVisible(false);
                btnShowDocument.SetVisible(false);
            }
            else
            {
                _cardClientService = new CardClientService();
                var cardInfo = _cardClientService.GetCardInfo(GetCardId());

                //UptCardList.RequiredDocuments = cardInfo.ServiceResponse.RequiredDocumentCodes;
                //UptCardList.CreateDocumentsIfNecessary();

                SenderDocumentFactory docService = new SenderDocumentFactory();
                docService.InsertCardDocumentsIfNecessary(ValidationHelper.GetGuid(senderID), cardInfo.ServiceResponse.RequiredDocumentCodes);

                UpdateUI(cardInfo.ServiceResponse.ApplicationStatus);
            }
        }
    }


    private void UpdateUI(ApplicationStatus status)
    {
        if (status == ApplicationStatus.Completed)
        {
            txtNew_CardNumber.SetDisabled(false);
            //txtnew_Email.SetDisabled(false);
            btnCancel.SetVisible(false);
            btnFinish.SetVisible(false);
            btnStart.SetVisible(false);
            btnShowDocument.SetVisible(true);
            btnUpdate.SetVisible(true);
        }

        if (status == ApplicationStatus.Canceled)
        {
            txtNew_CardNumber.SetDisabled(false);
            //txtnew_Email.SetDisabled(false);
            btnCancel.SetVisible(false);
            btnFinish.SetVisible(false);
            btnStart.SetVisible(false);
            btnShowDocument.SetVisible(true);
            btnUpdate.SetVisible(false);
        }

        if (status == ApplicationStatus.Started)
        {
            txtNew_CardNumber.SetDisabled(false);
            //txtnew_Email.SetDisabled(false);
            btnCancel.SetVisible(true);

            //if (ValidationHelper.GetInteger(_cardClientService.GetCardCustAccountCreatedChannel(_cardId).Rows[0]["Channel"]) == 0)
            //{
            //    btnFinish.SetVisible(true);
            //}
            //else
            //{
            btnFinish.SetVisible(false);
            //}

            btnStart.SetVisible(false);
            btnShowDocument.SetVisible(true);
            btnUpdate.SetVisible(false);
        }
    }


    #region Button Events

    protected void SaveUptCard(object sender, AjaxEventArgs e)
    {
        var professionDb = new ProfessionDb();
        if (!professionDb.ExistsSenderProfessionInfo(ValidationHelper.GetGuid(senderID)) && custAccountType == "001")
        {
            BasePage.QScript(string.Format("ShowProfession('{0}','{1}');", senderID, CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_CONTROL_FORM")));
            return;
        }


        var bankResponse = StartCardApplicationViaBank();

        if (bankResponse.ResponseStatus == ServiceResponseStatus.Success)
        {
            try
            {
                var saveResult = SaveUptCard(bankResponse.ServiceResponse);

                if (saveResult)
                {
                    ScriptCreater.AddInstanceScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/CustAccount/UPTCard/ShowDocument.aspx?&ApplicationNo="
                        + bankResponse.ServiceResponse.APPLICATION_NO
                        + "', { maximized: false, width: 890, height: 600, resizable: true, modal: true, maximizable: false });");
                    btnFinish.SetVisible(false);
                    btnCancel.SetVisible(true);
                    btnStart.SetVisible(false);

                    List<string> documentList = bankResponse.ServiceResponse.DOCUMENT_LIST.Where(x => x.IS_OWNER == "H").Select(y => y.DOC_CODE).ToList();

                    SenderDocumentFactory docService = new SenderDocumentFactory();
                    docService.InsertCardDocumentsIfNecessary(ValidationHelper.GetGuid(senderID), documentList);


                    pnlDocuments.SetVisible(true);
                    btnShowDocument.SetVisible(true);
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "SaveUptCard", "UPT Card Operations");
                ShowMessage(ex.Message, EMessageType.Error, ServiceErrorType.ClientError.ToFriendlyErrorType());
            }

        }
        else
        {
            ShowMessage(bankResponse.RETURN_DESCRIPTION, EMessageType.Warning, bankResponse.ErrorType.ToFriendlyErrorType());
        }

    }

    protected void UploadDocuments(object sender, AjaxEventArgs e)
    {
        string validation = ValidateInputs();

        _cardClientService = new CardClientService();

        var cardInfo = _cardClientService.GetCardInfo(GetCardId());

        string uploadDocumentErrors = string.Empty;

        if (string.IsNullOrEmpty(validation))
        {
            uploadDocumentErrors = SendDocuments(cardInfo, uploadDocumentErrors);

            if (string.IsNullOrEmpty(uploadDocumentErrors))
            {
                var updateStatusResult = _cardClientService.UpdateUptCardStatus(cardInfo.ServiceResponse.UptCardID, ApplicationStatus.Completed);

                if (updateStatusResult.ResponseStatus == ServiceResponseStatus.Success)
                {
                    BasePage.QScript("LogCurrentPage();");
                    BasePage.QScript("alert(" + BasePage.SerializeString("Kart tanımla işlemi tamamlandı") + "); ");
                    //ShowMessage("Kart tanımla işlemi tamamlandı", EMessageType.Information, "İşlem Başarılı");
                    BasePage.QScript("closePage();");
                }
                else
                {
                    ShowMessage(updateStatusResult.RETURN_DESCRIPTION, EMessageType.Error, updateStatusResult.ErrorType.ToFriendlyErrorType());
                }
            }
            else
            {
                ShowMessage(uploadDocumentErrors, EMessageType.Warning, ServiceErrorType.ServerValidation.ToFriendlyErrorType());
            }
        }
        else
        {
            ShowMessage(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_DOCUMENT_REQUIRED"), EMessageType.Warning, ServiceErrorType.ClientValidation.ToFriendlyErrorType());
        }
    }

    private string SendDocuments(ResponseWrapper<CardInfo> cardInfo, string errorMessages)
    {
        foreach (var item in cardInfo.ServiceResponse.RequiredDocumentCodes)
        {
            var response = _cardClientService.UploadDocuments(cardInfo.ServiceResponse.ApplicationRefNo, item, cardInfo.ServiceResponse.SenderID, cardInfo.ServiceResponse.AccountNumber);

            if (response.ResponseStatus != ServiceResponseStatus.Success)
            {
                errorMessages += response.RETURN_DESCRIPTION + "</br>";
            }
        }

        return errorMessages;
    }

    protected void UpdateCard(object sender, AjaxEventArgs e)
    {
        _cardClientService = new CardClientService();

        ResponseWrapper<bool> response = _cardClientService.UpdateUptCard(GetCardId(),
            txtNew_MaximumTopUpAmount.Value.Value, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
            txtNew_MinimumTopUpAmount.Value.Value, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
            txtNew_MinimumCardBalance.Value.HasValue ? txtNew_MinimumCardBalance.Value.Value : 0, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
            txtNew_AutomaticTopUpAmount.Value.HasValue ? txtNew_AutomaticTopUpAmount.Value.Value : 0, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId);

        if (!response.ServiceResponse)
        {
            ShowMessage(string.Format("UpdateCard işleminde hata: {0}", response.RETURN_DESCRIPTION), EMessageType.Error, response.ErrorType.ToFriendlyErrorType());
        }
        else
        {
            BasePage.QScript("LogCurrentPage();");
            BasePage.QScript("alert(" + BasePage.SerializeString("Kart düzenleme işlemi tamamlandı") + "); ");
            BasePage.QScript("closePage();");
        }
    }

    protected void CancelCard(object sender, AjaxEventArgs e)
    {
        _cardClientService = new CardClientService();

        ResponseWrapper<CardInfo> cardInfo = null;

        cardInfo = _cardClientService.GetCardInfo(GetCardId());

        if (cardInfo.ResponseStatus == ServiceResponseStatus.Success && cardInfo.ServiceResponse.ApplicationStatus != ApplicationStatus.Completed)
        {
            var cancelResponse = _cardClientService.CancelApplication(GetCardId(), senderID, cardInfo.ServiceResponse.ApplicationRefNo, (int)CancelReason.CustomerRequest);

            if (cancelResponse.ResponseStatus == ServiceResponseStatus.Success)
            {
                var senderName = new NameService().ParseFullName(cardInfo.ServiceResponse.SenderName);

                CustomerInfo custInfo = new CustomerInfo()
                {
                    CustomerName = senderName.FirstName + ' ' + senderName.MiddleName,
                    CustomerSurname = senderName.LastName
                };
                var closeResponse = _cardClientService.CloseCardForCancel(GetCardId(), custInfo, cardInfo.ServiceResponse.ApplicationRefNo, (int)CancelReason.CustomerRequest);
                if (closeResponse.ServiceResponse)
                {
                    BasePage.QScript("LogCurrentPage();");
                    ShowMessage("Kart başvuru işlemi iptal edilmiştir.", EMessageType.Information, cardInfo.ErrorType.ToFriendlyErrorType());
                    BasePage.QScript("closePage();");
                }
            }
            else
            {
                ShowMessage(cancelResponse.RETURN_DESCRIPTION, EMessageType.Warning, cardInfo.ErrorType.ToFriendlyErrorType());
            }
        }
        else
        {
            ShowMessage("Bu aşamada kart başvuru iptali yapılamaz!", EMessageType.Warning, cardInfo.ErrorType.ToFriendlyErrorType());
        }
    }


    protected void ConfirmHistory(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();
        sd.AddParameter("CardId", DbType.Guid, GetCardId());
        DataTable dt = sd.ReturnDatasetSp("spGetCardConfirmHistory").Tables[0];

        GridPanelConfirmHistory.DataSource = dt;
        GridPanelConfirmHistory.DataBind();
    }

    protected void GetBalance(object sender, AjaxEventArgs e)
    {
        var cardBalance = _cardClientService.GetCardBalance(txtNew_CardNumber.Value,
                                                                App.Params.CurrentUser.SystemUserId,
                                                                 null);


        if (cardBalance.ResponseStatus == ServiceResponseStatus.Success && cardBalance.ServiceResponse.LIST != null && cardBalance.ServiceResponse.LIST.Count > 0)
        {
            MessageBox msg = new MessageBox();
            msg.Show("Kart bakiyesi: " + cardBalance.ServiceResponse.LIST[0].HOST_BALANCE + " TL");
        }
    }

    protected void ShowDocument(object sender, AjaxEventArgs e)
    {
        ResponseWrapper<CardInfo> card = new ResponseWrapper<CardInfo>();
        _cardClientService = new CardClientService();

        card = _cardClientService.GetCardInfo(GetCardId());

        ScriptCreater.AddInstanceScript("window.top.newWindowRefleX(window.top.GetWebAppRoot + '/ISV/TU/CustAccount/UPTCard/ShowDocument.aspx?&ApplicationNo= " + card.ServiceResponse.ApplicationRefNo
                        + "', { maximized: false, width: 890, height: 600, resizable: true, modal: true, maximizable: false });");
    }


    protected void btnPdfWatch_OnClick(object sender, AjaxEventArgs e)
    {
        CustAccountStatementFactory casf = new CustAccountStatementFactory();
        var reportID = casf.GetReportId();
        Guid uptCardId = GetCardId();
        if (reportID == Guid.Empty)
        {
            BasePage.QScript("alert('[Müşteri Hesap Ekstresi] adlı rapor yok ya da artık görüntülenemiyor.');");
        }
        else
        {
            if (!checkMandotaryFields(false))
            {
                BasePage.QScript("alert('Lütfen zorunlu alanları doldurarak extre oluşturmayı deneyiniz');");
                return;
            }
            else
            {
                /*Burda bankadan ekstre çekilip gösterilecek*/


                _cardClientService = new CardClientService();

                var cardTransactions = _cardClientService.GetCardTransactions(txtNew_CardNumber.Value,
                                                                ValidationHelper.GetDate(cmbStatementDateStart.Value).ConvertToBirthDate(),
                                                                ValidationHelper.GetDate(cmbStatementDateEnd.Value).ConvertToBirthDate(),
                                                                ValidationHelper.GetDecimal(numMinAmount.Value, 0).ToString("##"),
                                                                ValidationHelper.GetDecimal(numMaxAmount.Value, 999999999).ToString("##"),
                                                                App.Params.CurrentUser.SystemUserId,
                                                                 null);

                var cardProvisions = _cardClientService.GetCardProvision(txtNew_CardNumber.Value,
                                                               ValidationHelper.GetDate(cmbStatementDateStart.Value).ConvertToBirthDate(),
                                                               ValidationHelper.GetDate(cmbStatementDateEnd.Value).ConvertToBirthDate(),
                                                               App.Params.CurrentUser.SystemUserId,
                                                                null);




                string[] extreColumn = null;
                extreColumn = new string[] { "TXN_NAME", "TXN_DATE", "TXN_AMOUNT", "TXN_AMOUNT", "TXN_CURR", "TXN_DESC", "TXN_STATE" };


                if (cardTransactions.ResponseStatus == ServiceResponseStatus.Success)
                {
                    if (cardTransactions.ServiceResponse != null && cardTransactions.ServiceResponse.ALL_TXN_LIST != null)
                    {
                        DataTable dt = ConvertToDataTable<TransactionDetail>(cardTransactions.ServiceResponse.ALL_TXN_LIST, extreColumn);

                        DataTable dtp = ConvertToDataTable<TransactionDetail>(cardProvisions.ServiceResponse.ALL_PROVISION_LIST, extreColumn);

                        dt.Merge(dtp);


                        var n = string.Format("Kart_Extre_{0:yyyy_MM_dd_hh_mm_ss}.xls", DateTime.Now);
                        Export.ExportDownloadData(dt, n);
                    }
                }


                //BasePage.QScript(string.Format("hdnReportId.setValue('{0}');", reportID));
                //BasePage.QScript("ShowAccountStatementReport(1);");
            }
        }
    }

    #endregion



    #region Private Methods

    private bool checkMandotaryFields(bool isEmailMand)
    {
        if (cmbStatementDateStart.RequirementLevel == RLevel.BusinessRequired && cmbStatementDateStart.Value == null)
        {
            return false;
        }
        if (cmbStatementDateEnd.RequirementLevel == RLevel.BusinessRequired && cmbStatementDateEnd.Value == null)
        {
            return false;
        }
        //if (crmMinAmount.RequirementLevel == RLevel.BusinessRequired && crmMinAmount.Value == null)
        //{
        //    return false;
        //}
        //if (crmMaxAmount.RequirementLevel == RLevel.BusinessRequired && crmMaxAmount.Value == null)
        //{
        //    return false;
        //}
        return true;
    }

    //private void ShowErrorMessage(AjaxEventArgs e, string message)
    //{
    //    e.Success = false;
    //    e.Message = message;
    //}

    private Guid GetCardId()
    {
        _cardClientService = new CardClientService();

        if (_cardId == null || _cardId == Guid.Empty)
        {
            _cardId = _cardClientService.GetCardId(txtNew_CardNumber.Value).ServiceResponse;
        }

        return _cardId;
    }

    private void ShowMessage(string message, EMessageType messageType, string title)
    {
        MessageBox msgBox = new MessageBox();
        msgBox.MessageType = messageType;
        msgBox.Title = title;
        msgBox.MsgType = MessageBox.EMsgType.Html;
        msgBox.Modal = true;
        msgBox.Show(title, "", message);
    }

    private ResponseWrapper<PrepaidApplicationResponse> StartCardApplicationViaBank()
    {
        _cardClientService = new CardClientService();

        return _cardClientService.DoPrepaidApplication(txtNew_CardNumber.Value,
                                                        ValidationHelper.GetGuid(senderController.Value),
                                                        App.Params.CurrentUser.SystemUserId,
                                                        UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
                                                        string.Empty, null);
    }

    private bool SaveUptCard(PrepaidApplicationResponse bankResponse)
    {
        bool result = true;
        _cardClientService = new CardClientService();

        var requiredDocs = bankResponse.DOCUMENT_LIST.Where(x => x.IS_OWNER == "H").ToList();

        string requiredDocuments = string.Empty;

        if (requiredDocs.Count > 0)
        {
            requiredDocuments = string.Join("#", requiredDocs.Select(x => x.DOC_CODE).ToArray());
        }

        ResponseWrapper<bool> response = _cardClientService.SaveUptCard(txtNew_CardNumber.Value,
            txtNew_MaximumTopUpAmount.Value.Value, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
            txtNew_MinimumTopUpAmount.Value.Value, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
            txtNew_MinimumCardBalance.Value.HasValue ? txtNew_MinimumCardBalance.Value.Value : 0, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
            txtNew_AutomaticTopUpAmount.Value.HasValue ? txtNew_AutomaticTopUpAmount.Value.Value : 0, UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId,
            ValidationHelper.GetGuid(senderController.Value),
            requiredDocuments,
            bankResponse.APPLICATION_NO,
            string.Empty,
            true

            );

        if (!response.ServiceResponse)
        {
            result = false;
            ShowMessage(response.RETURN_DESCRIPTION, EMessageType.Warning, response.ErrorType.ToFriendlyErrorType());
        }
        return result;
    }

    private string ValidateInputs()
    {
        _cardClientService = new CardClientService();
        return _cardClientService.CheckCardDocumentUploaded(senderID).RETURN_DESCRIPTION;
    }


    public DataTable ConvertToDataTable<T>(IList<T> data, string[] exportPropList)
    {
        PropertyDescriptorCollection properties =
           TypeDescriptor.GetProperties(typeof(T));
        DataTable table = new DataTable();
        foreach (PropertyDescriptor prop in properties)
        {
            if (exportPropList == null || exportPropList.Contains(prop.Name))
            {
                table.Columns.Add(prop.Name, Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType);
            }

        }
        foreach (T item in data)
        {
            DataRow row = table.NewRow();
            foreach (PropertyDescriptor prop in properties)
            {
                if (exportPropList == null || exportPropList.Contains(prop.Name))
                {
                    row[prop.Name] = prop.GetValue(item) ?? DBNull.Value;
                }

            }
            table.Rows.Add(row);
        }
        return table;

    }

    #endregion

    #region events
    protected void txtNew_AutomaticTopUpAmountChange(object sender, AjaxEventArgs e)
    {
        var currency = Page.FindControl("new_AutomaticTopUpAmountCurrency_Container") as ComboField;
        currency.SetValue(UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId);
    }

    protected void txtNew_MinimumCardBalanceChange(object sender, AjaxEventArgs e)
    {
        var currency = Page.FindControl("new_MinimumCardBalanceCurrency_Container") as ComboField;
        currency.SetValue(UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId);
    }

    protected void txtNew_MaximumTopUpAmountChange(object sender, AjaxEventArgs e)
    {
        var currency = Page.FindControl("new_MaximumTopUpAmountCurrency_Container") as ComboField;
        currency.SetValue(UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId);
    }

    protected void txtNew_MinimumTopUpAmountChange(object sender, AjaxEventArgs e)
    {
        var currency = Page.FindControl("new_MinimumTopUpAmountCurrency_Container") as ComboField;
        currency.SetValue(UPTCache.CurrencyService.GetCurrencyByCurrencyCode("TRY").CurrencyId);
    }
    #endregion
}

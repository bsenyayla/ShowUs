var win = window.parent;
var recId = win.hdnRecid.getValue();
function ShowOdenmemisHavaleler() {
    var strFilter = "OperationDate1;OperationDate2;OperationAmount1;OperationAmount2;Country1;Corporation1;Office;OperationCurrencyId;OperationStatus"
    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_OperationAmount1.getValue(),
     win.new_OperationAmount2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationStatus.getValue(),
    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowSettlement2KurumRaporu2() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;OperationType";

    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     "",
     "",
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationType.getValue()
    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowSettlement2KurumRaporu() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;OperationType";

    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationType.getValue()

    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowActivity2KurumRaporu() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;OperationType;UserId";

    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     "",
     "",
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationType.getValue(),
     win.new_SystemUser.getValue()
    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowActivity2KurumRaporu() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;OperationType;UserId";

    var strValues =
        [
            win.new_OperationDate1.getValue(),
            win.new_OperationDate2.getValue(),
            "",
            "",
            win.new_Office.getValue(),
            win.new_OperationCurrencyId.getValue(),
            win.new_OperationType.getValue(),
            win.new_SystemUser.getValue()
        ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowActivityKurumRaporu() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;OperationType;UserId";

    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationType.getValue(),
     win.new_SystemUser.getValue()
    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowSettlementKurumRaporu() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;OperationType";

    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationType.getValue(),

    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowSettlementRaporu() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;OperationType";

    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationType.getValue(),

    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowAktiviteRaporu() {
    var strFilter = "OperationDate1;OperationDate2;OperationAmount1;OperationAmount2;Country1;Corporation1;Office;OperationCurrencyId;OperationStatus";

    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_OperationAmount1.getValue(),
     win.new_OperationAmount2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationStatus.getValue(),
    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}
function ShowAktivitelerRaporuKurum() {
    var strFilter = "OperationDate1;OperationDate2;OperationAmount1;OperationAmount2;Country1;Corporation1;Office;OperationCurrencyId;OperationStatus";
    
    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_OperationAmount1.getValue(),
     win.new_OperationAmount2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationStatus.getValue(),
    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}
function ShowPerformansAbReport() {
    var strFilter = "BeginDate;EndDate;Country;Corporation";
    var strValues = [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue()
    ];

    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);
}
function ShowPazarlamaReport() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;TargetTransaction";
    var strValues = [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_TransactionTargetOptionId.getValue()
    ];

    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);
}
function ShowKomisyonKurGelirRaporu() {
    var strFilter = "BeginDate;EndDate;Country;Corporation;Office;Currency;OperationType";
    
    var strValues =
    [
     win.new_OperationDate1.getValue(),
     win.new_OperationDate2.getValue(),
     win.new_Country1.getValue(),
     win.new_Corporation1.getValue(),
     win.new_Office.getValue(),
     win.new_OperationCurrencyId.getValue(),
     win.new_OperationType.getValue(),
     
    ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}
function ShowKasaBakiyeleriRaporu() {
    var strFilter = "Office";

    var strValues =
    [    
     win.new_Office.getValue()
    ];
    
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowAnaKasaMutabakatRaporu() {
    var strFilter = "EndDate;Office";

    var strValues =
    [
     win.new_OperationDate2.getValue(),
     win.new_Office.getValue()
    ];

    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}
function ShowCorpOfficeProcess() {
    var strFilter = "CorporationId;OfficeId;AmountCurrenyId;StartDate;EndDate";

    var strValues =
    [
    win.new_Corporation1.getValue(),
    win.new_Office.getValue(),
    win.new_OperationCurrencyId.getValue(),
    win.new_OperationDate1.getValue(),
    win.new_OperationDate2.getValue()
    ];

    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowCorpOfficeProcessNoneCommission() {
    var strFilter = "CorporationId;OfficeId;AmountCurrenyId;StartDate;EndDate";

    var strValues =
    [
    win.new_Corporation1.getValue(),
    win.new_Office.getValue(),
    win.new_OperationCurrencyId.getValue(),
    win.new_OperationDate1.getValue(),
    win.new_OperationDate2.getValue()
    ];

    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowCashTransactionReconciliation() {
    var strFilter = "CorporationId;StartDate;EndDate";

    var strValues =
    [
    win.new_Corporation1.getValue(),
    win.new_OperationDate1.getValue(),
    win.new_OperationDate2.getValue()
    ];

    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}

function ShowUptMobilMonitoringRapor() {
    var strFilter = "BeginDate;EndDate";

    var strValues =
        [
            win.new_OperationDate1.getValue(),
            win.new_OperationDate2.getValue()          
        ];
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}
function ShowUptionRapor() {
    var strFilter = "BeginDate;EndDate;Amount1;Amount2;CurrencyId;CustAccountTypeId;MobileTransactionTypeId;SenderCountryId;ReceiverCountryId;CorporationId;RecipientId;SenderId;SenderIdendificationNumber1";

    var strValues =
        [
            win.new_FormTransactionDate1.getValue(),
            win.new_FormTransactionDate2.getValue(),
            win.new_FormAmount1.getValue(),
            win.new_FormAmount2.getValue(),
            win.new_OperationCurrencyId.getValue(),
            win.new_CustAccountTypeId.getValue(),           
            win.new_MobileTransactionType.getValue(),
            win.new_Country1.getValue(),
            win.new_FormReceiverCountryId.getValue(),
            win.new_Corporation1.getValue(),
            win.new_RecipientId.getValue(),
            win.new_SenderId.getValue(),
            win.new_SenderIdendificationNumber1.getValue(),
        ];
  
    window.top.ShowReportWithParameters(win.new_ReportId.getValue(), win.hdnRecid.getValue(), strFilter, strValues);

}
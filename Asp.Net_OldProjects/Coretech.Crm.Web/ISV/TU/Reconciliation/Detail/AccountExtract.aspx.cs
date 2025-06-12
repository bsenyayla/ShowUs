using AjaxPro;
using Coretech.Crm.Factory.Crm.ExcelImport;
using Coretech.Crm.Factory.Exporter;
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
using TuFactory.AccountTransactions;
using TuFactory.LogoTiger.Objects;
using TuFactory.Object;
using TuFactory.Reconciliation.Objects;
using TuFactory.Reconciliation.Objects.Logo;
using TuFactory.Transfer;

namespace Reconciliation.Detail
{
    public class Transaction
    {
        public string Type { get; set; }

        public Guid TransactionId { get; set; }

        public string TransactionReference { get; set; }

        public string ConfirmStatusCode { get; set; }

        public string ConfirmStatusName { get; set; }

        public string TransactionType { get; set; }

        public bool IsIntegratedTransaction { get; set; }

        public Guid CorporationId { get; set; }

        //public string CorporationCode { get; set; }

        //public Guid? OfficeId { get; set; }

        public Guid CreatedBy { get; set; }

        public DateTime CreatedOn { get; set; }

        public string BankTransactionNumber { get; set; }
    }

    public class AccountExtractReconciliationFactory
    {
        DataTable CreateReconciliationTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add(new DataColumn("Source"));
            dt.Columns.Add(new DataColumn("TransactionReference"));
            dt.Columns.Add(new DataColumn("OperationType"));
            dt.Columns.Add(new DataColumn("BankTransactionNumber"));
            dt.Columns.Add(new DataColumn("Amount"));
            dt.Columns.Add(new DataColumn("Status"));
            dt.Columns.Add(new DataColumn("StatusDetail")); 
            dt.Columns.Add(new DataColumn("Date"));
            return dt;
        }

        string GetDateListString(List<DateTime> dateList)
        {
            if (dateList == null)
            {
                throw new InvalidDataException("Tarih değerleri geçersizdir. [1]");
            }

            if (dateList.Count == 0)
            {
                throw new InvalidDataException("Tarih değerleri geçersizdir. [2]");
            }

            string dateStr = string.Empty;

            for (int i = 0; i < dateList.Count; i++)
            {
                if (i < dateList.Count - 1)
                {
                    dateStr += string.Format("'{0}', ", dateList[i].ToString("yyyy-MM-dd"));
                }
                else
                {
                    dateStr += string.Format("'{0}'", dateList[i].ToString("yyyy-MM-dd"));
                }
            }

            return dateStr;
        }

        public List<DateTime> GetReconciliationDates(DataTable dtExtract)
        {
            List<DateTime> list = new List<DateTime>();
            if (dtExtract != null)
            {
                for (int i = 0; i < dtExtract.Rows.Count; i++)
                {
                    if (!list.Contains(ValidationHelper.GetDate(dtExtract.Rows[i]["İşlem Tarihi"]).Date))
                    {
                        list.Add(ValidationHelper.GetDate(dtExtract.Rows[i]["İşlem Tarihi"]).Date);
                    }
                }
            }
            return list;
        }

        public DataTable Reconciliate(Guid corporationId, DataTable dtExtract, bool checkAmount)
        {
            DataTable dtReconciliation = CreateReconciliationTable();

            List<DateTime> dateList = GetReconciliationDates(dtExtract);

            for (int i = 0; i < dateList.Count; i++)
            {
                Reconcilate(dtReconciliation, corporationId, dateList[i], dtExtract, checkAmount);
            }

            for (int i = 0; i < dtExtract.Rows.Count; i++)
            {
                DataRow drReconciliation = dtReconciliation.NewRow();
                drReconciliation["Source"] = "Banka Hesap Hareketleri";
                drReconciliation["TransactionReference"] = string.Empty;                
                drReconciliation["OperationType"] = string.Empty;
                drReconciliation["BankTransactionNumber"] = dtExtract.Rows[i]["İşlem No"];
                drReconciliation["Amount"] = dtExtract.Rows[i]["Tutar"];
                drReconciliation["Status"] = "Banka hareketlerinde olan işlem, ön muhasebede yok ya da başka tarihte.";
                drReconciliation["StatusDetail"] = dtExtract.Rows[i]["Banka Açıklama"];
                drReconciliation["Date"] = dtExtract.Rows[i]["İşlem Tarihi"];
                dtReconciliation.Rows.Add(drReconciliation);
            }

            System.Data.DataView dv = dtReconciliation.DefaultView;
            dv.Sort = "BankTransactionNumber";
            DataTable sortedReconciliationTable = dv.ToTable();

            return sortedReconciliationTable;
        }

        void CheckExtract(DataTable dtExtract, DataTable dtPreaccounting, Transaction transaction, bool checkAmount)
        {
            //bool extractTransactionFound = false;

            DataRow[] drsPreaccountingByTransactionId = dtPreaccounting.Select(string.Format("new_MasterTransactionReferenceId = '{0}'", transaction.TransactionId));

            for (int i = 0; i < drsPreaccountingByTransactionId.Length; i++)
            {
                //extractTransactionFound = false;

                DataRow[] drsExtract = dtExtract.Select(string.Format("[İşlem No] = '{0}'", drsPreaccountingByTransactionId[i]["new_BankTransactionNumber"]));
                if (drsExtract != null && drsExtract.Length > 0)
                {
                    if (checkAmount) //Tutar kontrolu yapiliyor.
                    {
                        for (int j = 0; j < drsExtract.Length; j++)
                        {
                            if (ValidationHelper.GetDecimal(drsPreaccountingByTransactionId[i]["new_Amount"], 0) == ValidationHelper.GetDecimal(drsExtract[j]["Tutar"], 0))
                            {
                                //extractTransactionFound = true;

                                dtExtract.Rows.Remove(drsExtract[j]);
                                dtPreaccounting.Rows.Remove(drsPreaccountingByTransactionId[i]);
                                
                                break;
                            }
                        }
                    }
                    else
                    {
                        //extractTransactionFound = true;

                        for (int j = 0; j < drsPreaccountingByTransactionId.Length; j++)
                        {
                            dtPreaccounting.Rows.Remove(drsPreaccountingByTransactionId[j]);
                        }

                        for (int j = 0; j < drsExtract.Length; j++)
                        {
                            dtExtract.Rows.Remove(drsExtract[j]);
                        }

                        break;
                    }
                }
            }
        }

        void CheckCancelExtract(DataTable dtExtract, DataTable dtPreaccounting, Transaction transaction, bool checkAmount)
        {
            DataRow[] drsPreaccountingByTransactionId = dtPreaccounting.Select(string.Format("new_MasterTransactionReferenceId = '{0}'", transaction.TransactionId));

            List<DateTime> preaaccountingDates = new List<DateTime>();

            for (int i = 0; i < drsPreaccountingByTransactionId.Length; i++)
            {
                DateTime date = ValidationHelper.GetDate(drsPreaccountingByTransactionId[i]["CreatedOn"]).ToLocalTime().Date;
                if (!preaaccountingDates.Contains(date))
                {
                    preaaccountingDates.Add(date);
                }
            }

            if (preaaccountingDates.Count == 1)
            {
                for (int i = 0; i < drsPreaccountingByTransactionId.Length; i++)
                {
                    DataRow[] drsExtract = dtExtract.Select(string.Format("[İşlem No] = '{0}'", drsPreaccountingByTransactionId[i]["new_BankTransactionNumber"]));
                    if (drsExtract.Length == 0)
                    {
                        dtPreaccounting.Rows.Remove(drsPreaccountingByTransactionId[i]);
                    }
                }
            }
            else
            {
                CheckExtract(dtExtract, dtPreaccounting, transaction, checkAmount);
            }
        }

        void AddPreaccountingCheckRow(DataTable dtReconciliation, Transaction transaction, string operationType)
        {
            DataRow drReconciliation = dtReconciliation.NewRow();
            drReconciliation["Source"] = "Ön Muhasebe Hareketleri";
            drReconciliation["TransactionReference"] = transaction.TransactionReference;
            drReconciliation["OperationType"] = operationType;
            drReconciliation["BankTransactionNumber"] = transaction.BankTransactionNumber;
            drReconciliation["Status"] = "İşlemin ön muhasebede hareketleri eksik";
            drReconciliation["Date"] = transaction.CreatedOn;
            dtReconciliation.Rows.Add(drReconciliation);
        }

        void CheckTransactionPreaccounting
        (
            DataTable dtReconciliation,
            DataTable dtExtract, 
            DataTable dtPreaccounting, 
            Dictionary<Guid, Dictionary<string, int>> preaccountingHistoryData, 
            Transaction transaction, 
            string operationType,
            bool checkAmount
        )
        {
            string cancelOperationType = operationType + "C";

            if (preaccountingHistoryData.ContainsKey(transaction.TransactionId) && preaccountingHistoryData[transaction.TransactionId].ContainsKey(operationType))
            {
                if (preaccountingHistoryData[transaction.TransactionId].ContainsKey(cancelOperationType))
                {
                    if (preaccountingHistoryData[transaction.TransactionId][operationType] - preaccountingHistoryData[transaction.TransactionId][cancelOperationType] != 1)
                    {
                        AddPreaccountingCheckRow(dtReconciliation, transaction, operationType);
                    }
                    else
                    {
                        //Ön muhasebe hareketleri uygun
                        CheckExtract(dtExtract, dtPreaccounting, transaction, checkAmount);
                    }
                }
                else
                {
                    if (preaccountingHistoryData[transaction.TransactionId][operationType] != 1)
                    {
                        AddPreaccountingCheckRow(dtReconciliation, transaction, operationType);
                    }
                    else
                    {
                        //Ön muhasebe hareketleri uygun
                        CheckExtract(dtExtract, dtPreaccounting, transaction, checkAmount);
                    }
                }
            }
            else
            {
                AddPreaccountingCheckRow(dtReconciliation, transaction, operationType);
            }
        }

        void CheckTransactionCancelPreaccounting
        (
            DataTable dtReconciliation,
            DataTable dtExtract,
            DataTable dtPreaccounting,
            Dictionary<Guid, Dictionary<string, int>> preaccountingHistoryData,
            Transaction transaction,
            string operationType,
            bool checkAmount
        )
        {
            string cancelOperationType = operationType + "C";

            if (preaccountingHistoryData[transaction.TransactionId].ContainsKey(operationType) && preaccountingHistoryData[transaction.TransactionId].ContainsKey(cancelOperationType))
            {
                if (preaccountingHistoryData[transaction.TransactionId][cancelOperationType] != preaccountingHistoryData[transaction.TransactionId][operationType])
                {
                    AddPreaccountingCheckRow(dtReconciliation, transaction, operationType);
                }
                else
                {
                    //Ön muhasebe hareketleri uygun
                    CheckCancelExtract(dtExtract, dtPreaccounting, transaction, checkAmount);
                }
            }
            else
            {
                AddPreaccountingCheckRow(dtReconciliation, transaction, operationType);
            }
        }

        void Reconcilate(DataTable dtReconciliation, Guid corporationId, DateTime date, DataTable dtExtract, bool checkAmount)
        {
            DataTable dtPreaccounting = GetPreaccountingData(corporationId, date.Date.ToUniversalTime(), date.Date.AddDays(1).ToUniversalTime());

            Dictionary<Guid, Dictionary<string, int>> preaccountingHistoryData = GetPreaccountingHistoryData(corporationId, date.Date.ToUniversalTime(), date.Date.AddDays(1).ToUniversalTime());

            bool hasAccountTransactions = false;
            bool statusCheckDone = false;

            List<Transaction> list = GetTransactionList(corporationId, date.Date, date.Date.AddDays(1));

            for (int i = 0; i < list.Count; i++)
            {
                hasAccountTransactions = preaccountingHistoryData.ContainsKey(list[i].TransactionId);
                statusCheckDone = false;

                switch (list[i].Type)
                {
                    case "TRANSFER":
                        if
                        (
                            list[i].ConfirmStatusCode == "TR000R" || //Gönderim İadesi İsteniyor(Kurum Entegrasyon)
                            list[i].ConfirmStatusCode == "TR001E" || //Gönderim Ödeme Reservli
                            list[i].ConfirmStatusCode == "TR002C" || //Gönderim İptal Onayı Bekliyor
                            list[i].ConfirmStatusCode == "TR008" || //Gönderim Askıda
                            list[i].ConfirmStatusCode == "TR010" || //Gönderim Tamamlandı
                            list[i].ConfirmStatusCode == "TR011" || //Gönderim Tamam (Ödemesi Yapıldı)
                            list[i].ConfirmStatusCode == "TR012" || //Gönderim Tamam (Kuruma İletildi)
                            list[i].ConfirmStatusCode == "TR001R" || //Gönderim İade Sürecinde 
                            list[i].ConfirmStatusCode == "TR003R" || //Gönderim İade Tamamlandı  
                            list[i].ConfirmStatusCode == "TRE002U" //Gönderim Düzeltme Onay Bekliyor 
                        )
                        {
                            statusCheckDone = true;
                            CheckTransactionPreaccounting(dtReconciliation, dtExtract, dtPreaccounting, preaccountingHistoryData, list[i], "TR", checkAmount);
                        }
                        else if
                        (
                            list[i].ConfirmStatusCode == "TR004C" || //Gönderim İptal Edildi
                            list[i].ConfirmStatusCode == "TR005C" //Gönderim İptal Edildi-Dekont Basıldı
                        )
                        {
                            statusCheckDone = true;
                            CheckTransactionCancelPreaccounting(dtReconciliation, dtExtract, dtPreaccounting, preaccountingHistoryData, list[i], "TR", checkAmount);
                        }
                        break;
                    case "PAYMENT":
                        if
                        (
                            list[i].ConfirmStatusCode == "PA010" || //Ödeme Tamamlandı
                            list[i].ConfirmStatusCode == "PA012" //Ödeme Tamam (Kuruma Ödendi)
                        )
                        {
                            statusCheckDone = true;
                            CheckTransactionPreaccounting(dtReconciliation, dtExtract, dtPreaccounting, preaccountingHistoryData, list[i], "PY", checkAmount);
                        }
                        else if
                        (
                            list[i].ConfirmStatusCode == "PA005C" //Ödeme İptal Edildi -Dekont Basıldı-
                        )
                        {
                            statusCheckDone = true; 
                            CheckTransactionCancelPreaccounting(dtReconciliation, dtExtract, dtPreaccounting, preaccountingHistoryData, list[i], "PY", checkAmount);
                        }
                        break;
                    case "REFUNDTRANSFER":
                        if (list[i].TransactionType == "002" || list[i].TransactionType == "003")
                        {
                            if
                            (
                                list[i].ConfirmStatusCode == "IT000" //İade Gönderim Yeni Kayıt
                            )
                            {
                                statusCheckDone = true;

                                if (!(preaccountingHistoryData[list[i].TransactionId].ContainsKey("RT") && preaccountingHistoryData[list[i].TransactionId]["RT"] == 1))
                                {
                                    AddPreaccountingCheckRow(dtReconciliation, list[i], "RT");
                                }
                                else
                                {
                                    //Ön muhasebe hareketleri uygun
                                    CheckExtract(dtExtract, dtPreaccounting, list[i], checkAmount);
                                }
                            }
                            else if
                            (
                                list[i].ConfirmStatusCode == "IT002" || //İade Gönderim Tamamlandı
                                list[i].ConfirmStatusCode == "IT011" //İade Gönderim Tamamlandı (Ödemesi Yapıldı)
                            )
                            {
                                statusCheckDone = true;

                                if (!(preaccountingHistoryData[list[i].TransactionId].ContainsKey("RT") && preaccountingHistoryData[list[i].TransactionId]["RT"] == 2)) //RA olarak değiştireceğim.
                                {
                                    AddPreaccountingCheckRow(dtReconciliation, list[i], "RT");
                                }
                                else
                                {
                                    //Ön muhasebe hareketleri uygun
                                    CheckExtract(dtExtract, dtPreaccounting, list[i], checkAmount);
                                }
                            }
                        }
                        break;
                    case "REFUNDPAYMENT":
                        if
                        (
                            list[i].ConfirmStatusCode == "IP010" //İade Ödeme Tamamlandı
                        )
                        {
                            statusCheckDone = true;
                            CheckTransactionPreaccounting(dtReconciliation, dtExtract, dtPreaccounting, preaccountingHistoryData, list[i], "RP", checkAmount);
                        }
                        else if
                        (
                            list[i].ConfirmStatusCode == "IP005C" //İade Ödeme İptal Edildi -Dekont Basıldı-
                        )
                        {
                            statusCheckDone = true;
                            CheckTransactionCancelPreaccounting(dtReconciliation, dtExtract, dtPreaccounting, preaccountingHistoryData, list[i], "RP", checkAmount);
                        }
                        break;
                }

                if (hasAccountTransactions && !statusCheckDone)
                {
                    DataRow drReconciliation = dtReconciliation.NewRow();
                    drReconciliation["Source"] = "Ön Muhasebe Hareketleri";
                    drReconciliation["TransactionReference"] = list[i].TransactionReference;
                    drReconciliation["OperationType"] = list[i].TransactionType;
                    drReconciliation["BankTransactionNumber"] = list[i].BankTransactionNumber;
                    drReconciliation["Status"] = "Bilinmeyen statüdeki işlemin ön muhasebe hareketleri var";
                    drReconciliation["Date"] = list[i].CreatedOn;
                    dtReconciliation.Rows.Add(drReconciliation);
                }
            }

            for (int i = 0; i < dtPreaccounting.Rows.Count; i++)
            {
                DataRow drReconciliation = dtReconciliation.NewRow();
                drReconciliation["Source"] = "Ön Muhasebe Hareketleri";
                drReconciliation["TransactionReference"] = dtPreaccounting.Rows[i]["new_MasterTransactionReference"];
                drReconciliation["OperationType"] = dtPreaccounting.Rows[i]["new_MasterOperationType"];
                drReconciliation["BankTransactionNumber"] = dtPreaccounting.Rows[i]["new_BankTransactionNumber"];
                drReconciliation["Amount"] = dtPreaccounting.Rows[i]["new_Amount"];
                drReconciliation["Status"] = "Ön muhasebede olan işlem, banka hesap hareketlerinde yok ya da başka tarihte";
                drReconciliation["Date"] = dtPreaccounting.Rows[i]["CreatedOn"];
                dtReconciliation.Rows.Add(drReconciliation);
            }
        }

        List<Transaction> GetTransactionList(Guid corporationId, DateTime startDate, DateTime endDate)
        {
            List<Transaction> list = new List<Transaction>();
            DataTable dt = GetTransactions(corporationId, startDate.ToUniversalTime(), endDate.ToUniversalTime());
            if (dt != null && dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Transaction transaction = new Transaction();
                    transaction.Type = dt.Rows[i]["Type"].ToString();
                    transaction.TransactionId = ValidationHelper.GetGuid(dt.Rows[i]["TransactionId"]);
                    transaction.TransactionReference = dt.Rows[i]["TransactionReference"].ToString();
                    transaction.ConfirmStatusCode = dt.Rows[i]["ConfirmStatusCode"].ToString();
                    transaction.ConfirmStatusName = dt.Rows[i]["ConfirmStatusName"].ToString();
                    transaction.TransactionType = dt.Rows[i]["TransactionType"].ToString();
                    transaction.CorporationId = ValidationHelper.GetGuid(dt.Rows[i]["CorporationId"]);
                    transaction.IsIntegratedTransaction = ValidationHelper.GetBoolean(dt.Rows[i]["IsIntegratedTransaction"].ToString());
                    transaction.CreatedBy = ValidationHelper.GetGuid(dt.Rows[i]["CreatedBy"]);
                    transaction.CreatedOn = ValidationHelper.GetDate(dt.Rows[i]["CreatedOn"]);
                    transaction.BankTransactionNumber = ValidationHelper.GetString(dt.Rows[i]["BankTransactionNumber"]);
                    list.Add(transaction);
                }
            }
            return list;
        }

        DataTable GetTransactions(Guid corporationId, DateTime startDate, DateTime endDate)
        {
            StaticData sd = new StaticData();
            string sql = @"SELECT * FROM
                            (
	                            SELECT
		                            'TRANSFER' AS [Type],
		                            T.New_TransferId TransactionId, 
		                            T.TransferTuRef AS TransactionReference, 
		                            CS.new_Code AS ConfirmStatusCode,
		                            CS.ConfirmStatusName AS ConfirmStatusName,
                                    CASE 
                                        WHEN T.new_IntegrationChannel IS NULL THEN 0
		                                ELSE 1
	                                END AS IsIntegratedTransaction,
		                            TT.new_ExtCode AS TransactionType, 
		                            T.new_CorporationID AS CorporationId,
		                            C.new_CorporationCode AS CorporationCode,
		                            T.new_OfficeID AS OfficeId,
                                    T.CreatedBy AS CreatedBy,
		                            T.CreatedOn AS CreatedOn,
                                    ISNULL(T.new_BANKA_ISLEM_NO, '') AS BankTransactionNumber
	                            FROM vNew_Transfer T (NOLOCK)
	                            INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                            ON T.new_ConfirmStatus = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                            INNER JOIN vNew_TransactionType TT (NOLOCK)
	                            ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                            INNER JOIN vNew_Corporation C
	                            ON T.new_CorporationID = C.New_CorporationId AND C.DeletionStateCode = 0
	                            WHERE 
	                            T.DeletionStateCode = 0
	                            AND T.CreatedOn BETWEEN @StartDate AND @EndDate
                                AND T.new_CorporationId = @CorporationId

	                            UNION
                                
	                            SELECT 
		                            'PAYMENT' AS [Type],
		                            P.New_PaymentId TransactionId, 
		                            P.new_TransferIDName AS TransactionReference, 
		                            CS.new_Code AS ConfirmStatusCode,
		                            CS.ConfirmStatusName AS ConfirmStatusName,
                                    0 AS IsIntegratedTransaction,
		                            TT.new_ExtCode AS TransactionType,  
		                            P.new_PaidByCorporation AS CorporationId,
		                            C.new_CorporationCode AS CorporationCode,
		                            P.new_PaidByOffice AS OfficeId,
                                    P.CreatedBy AS CreatedBy,
		                            P.CreatedOn AS CreatedOn,
                                    ISNULL(P.new_BANKA_ISLEM_NO, '') AS BankTransactionNumber
	                            FROM vNew_Payment P (NOLOCK)
	                            INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                            ON P.new_ConfirmStatus = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                            INNER JOIN vNew_TransactionType TT (NOLOCK)
	                            ON P.new_TransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                            INNER JOIN vNew_Corporation C
	                            ON P.new_PaidByCorporation = C.New_CorporationId AND C.DeletionStateCode = 0
	                            WHERE 
	                            P.DeletionStateCode = 0
	                            AND P.CreatedOn BETWEEN @StartDate AND @EndDate
                                AND P.new_PaidByCorporation = @CorporationId
                                
	                            UNION
                                
	                            SELECT
		                            'REFUNDPAYMENT' AS [Type], 
		                            RP.New_RefundPaymentId TransactionId, 
		                            RP.new_TransferIDName AS TransactionReference, 
		                            CS.new_Code AS ConfirmStatusCode,
		                            CS.ConfirmStatusName AS ConfirmStatusName,
                                    0 AS IsIntegratedTransaction,  
		                            TT.new_ExtCode AS TransactionType,
		                            RP.new_RefundByCorporation AS CorporationId,
		                            C.new_CorporationCode AS CorporationCode,
		                            RP.new_RefundByOffice AS OfficeId,
                                    RP.CreatedBy AS CreatedBy,
		                            RP.CreatedOn AS CreatedOn,
                                    ISNULL(RP.new_BANKA_ISLEM_NO, '') AS BankTransactionNumber
	                            FROM vNew_RefundPayment RP (NOLOCK)
	                            INNER JOIN vNew_Transfer T (NOLOCK)
	                            ON RP.new_TransferId = T.New_TransferId
	                            INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                            ON RP.new_ConfirmStatusId = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                            INNER JOIN vNew_TransactionType TT (NOLOCK)
	                            ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                            INNER JOIN vNew_Corporation C
	                            ON RP.new_RefundByCorporation = C.New_CorporationId AND C.DeletionStateCode = 0
	                            WHERE 
	                            RP.DeletionStateCode = 0
	                            AND RP.CreatedOn BETWEEN @StartDate AND @EndDate
                                AND RP.new_RefundByCorporation = @CorporationId                                

	                            UNION
                                
	                            SELECT
		                            'REFUNDTRANSFER' AS [Type],  
		                            RT.New_RefundTransferId TransactionId, 
		                            RT.new_TransferIDName AS TransactionReference, 
		                            CS.new_Code AS ConfirmStatusCode,
		                            CS.ConfirmStatusName AS ConfirmStatusName,
                                    0 AS IsIntegratedTransaction, 
		                            TT.new_ExtCode AS TransactionType, 
		                            RT.new_CorporationId AS CorporationId,
		                            C.new_CorporationCode AS CorporationCode,
		                            RT.new_OfficeId AS OfficeId,
                                    RT.CreatedBy AS CreatedBy,
		                            RT.CreatedOn AS CreatedOn,
                                    ISNULL(RT.new_BANKA_ISLEM_NO, '') AS BankTransactionNumber
	                            FROM vNew_RefundTransfer RT (NOLOCK)
	                            INNER JOIN vNew_Transfer T (NOLOCK)
	                            ON RT.new_TransferId = T.New_TransferId
	                            INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                            ON RT.new_ConfirmStatusId = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                            INNER JOIN vNew_TransactionType TT (NOLOCK)
	                            ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                            INNER JOIN vNew_Corporation C
	                            ON RT.new_CorporationId = C.New_CorporationId AND C.DeletionStateCode = 0
	                            WHERE 
	                            RT.DeletionStateCode = 0
	                            AND RT.CreatedOn BETWEEN @StartDate AND @EndDate
                                AND RT.new_CorporationId = @CorporationId 
                            ) AS TBL
                            ORDER BY CreatedOn";

            sd.AddParameter("StartDate", DbType.DateTime, startDate);
            sd.AddParameter("EndDate", DbType.DateTime, endDate);
            sd.AddParameter("CorporationId", DbType.Guid, corporationId);
            return sd.ReturnDataset(sql).Tables[0];
        }

        Dictionary<Guid, Dictionary<string, int>> GetPreaccountingHistoryData(Guid corporationId, DateTime startDate, DateTime endDate)
        {
            Dictionary<Guid, Dictionary<string, int>> historyData = new Dictionary<Guid, Dictionary<string, int>>();

            DataTable dt = GetPreaccountingHistoryTable(corporationId, startDate, endDate);

            if (dt != null && dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Guid transactionReferenceId = ValidationHelper.GetGuid(dt.Rows[i]["TransactionId"]);
                    if(!historyData.ContainsKey(transactionReferenceId))
                    {
                        historyData.Add(transactionReferenceId, new Dictionary<string, int>());
                    }
                    historyData[transactionReferenceId][dt.Rows[i]["OperationType"].ToString()] = ValidationHelper.GetInteger(dt.Rows[i]["TransactionCount"], 0);
                }
            }

            return historyData;
        }

        DataTable GetPreaccountingHistoryTable(Guid corporationId, DateTime startDate, DateTime endDate)
        {
            StaticData sd = new StaticData();
            string sql = @"SELECT 
                                TransactionId,
                                OperationType,
                                COUNT(*) AS TransactionCount  
                            FROM AccountTransactionHistory WHERE TransactionId IN
                            (
	                            SELECT
		                            T.New_TransferId TransactionId
	                            FROM vNew_Transfer T (NOLOCK)
	                            INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                            ON T.new_ConfirmStatus = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                            INNER JOIN vNew_TransactionType TT (NOLOCK)
	                            ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                            INNER JOIN vNew_Corporation C
	                            ON T.new_CorporationID = C.New_CorporationId AND C.DeletionStateCode = 0
	                            WHERE 
	                            T.DeletionStateCode = 0
	                            AND T.CreatedOn BETWEEN @StartDate AND @EndDate
                                AND T.new_CorporationId = @CorporationId

	                            UNION
                                
	                            SELECT
		                            P.New_PaymentId TransactionId
	                            FROM vNew_Payment P (NOLOCK)
	                            INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                            ON P.new_ConfirmStatus = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                            INNER JOIN vNew_TransactionType TT (NOLOCK)
	                            ON P.new_TransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                            INNER JOIN vNew_Corporation C
	                            ON P.new_PaidByCorporation = C.New_CorporationId AND C.DeletionStateCode = 0
	                            WHERE 
	                            P.DeletionStateCode = 0
	                            AND P.CreatedOn BETWEEN @StartDate AND @EndDate
                                AND P.new_PaidByCorporation = @CorporationId
                                
	                            UNION
                                
	                            SELECT
		                            RP.New_RefundPaymentId TransactionId
	                            FROM vNew_RefundPayment RP (NOLOCK)
	                            INNER JOIN vNew_Transfer T (NOLOCK)
	                            ON RP.new_TransferId = T.New_TransferId
	                            INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                            ON RP.new_ConfirmStatusId = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                            INNER JOIN vNew_TransactionType TT (NOLOCK)
	                            ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                            INNER JOIN vNew_Corporation C
	                            ON RP.new_RefundByCorporation = C.New_CorporationId AND C.DeletionStateCode = 0
	                            WHERE 
	                            RP.DeletionStateCode = 0
	                            AND RP.CreatedOn BETWEEN @StartDate AND @EndDate
                                AND RP.new_RefundByCorporation = @CorporationId                                

	                            UNION
                                
	                            SELECT 
		                            RT.New_RefundTransferId TransactionId
	                            FROM vNew_RefundTransfer RT (NOLOCK)
	                            INNER JOIN vNew_Transfer T (NOLOCK)
	                            ON RT.new_TransferId = T.New_TransferId
	                            INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                            ON RT.new_ConfirmStatusId = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                            INNER JOIN vNew_TransactionType TT (NOLOCK)
	                            ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                            INNER JOIN vNew_Corporation C
	                            ON RT.new_CorporationId = C.New_CorporationId AND C.DeletionStateCode = 0
	                            WHERE 
	                            RT.DeletionStateCode = 0
	                            AND RT.CreatedOn BETWEEN @StartDate AND @EndDate
                                AND RT.new_CorporationId = @CorporationId 
                            )
                            GROUP BY TransactionId, OperationType";

            sd.AddParameter("StartDate", DbType.DateTime, startDate);
            sd.AddParameter("EndDate", DbType.DateTime, endDate);
            sd.AddParameter("CorporationId", DbType.Guid, corporationId);
            return sd.ReturnDataset(sql).Tables[0];
        }

        public DataTable GetPreaccountingData(Guid corporationId, DateTime startDate, DateTime endDate)
        {
            var sql = @"SELECT 
                        AT.New_AccountTransactionsId,
                        AT.new_MasterTransactionReferenceId,
                        AT.new_MasterTransactionReference,
                        AT.new_MasterOperationType,
                        CASE AT.new_Direction
                            WHEN 'A' THEN AT.new_Amount
                            ELSE -1 * AT.new_Amount
                        END AS new_Amount,
                        AT.new_Direction,
                        AT.new_BankTransactionNumber,
                        AT.CreatedOn
                    FROM vNew_AccountTransactions AT (NOLOCK)
                    INNER JOIN vNew_Accounts A (NOLOCK)
                    ON AT.new_AccountId = A.New_AccountsId 
					INNER JOIN vNew_CorporationAccount CA (NOLOCK)
					ON A.New_AccountsId = CA.new_AccountId
					WHERE 
					AT.DeletionStateCode = 0 AND
					CA.new_OperationType IN (7, 9) AND
					CA.new_CorparationID = @CorporationId AND
                    new_MasterTransactionReferenceId IN
                    (
                        SELECT
		                    T.New_TransferId TransactionId
	                    FROM vNew_Transfer T (NOLOCK)
	                    INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                    ON T.new_ConfirmStatus = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                    INNER JOIN vNew_TransactionType TT (NOLOCK)
	                    ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                    INNER JOIN vNew_Corporation C
	                    ON T.new_CorporationID = C.New_CorporationId AND C.DeletionStateCode = 0
	                    WHERE 
	                    T.DeletionStateCode = 0
	                    AND T.CreatedOn BETWEEN @StartDate AND @EndDate
                        AND T.new_CorporationId = @CorporationId

	                    UNION
                        
	                    SELECT
		                    P.New_PaymentId TransactionId
	                    FROM vNew_Payment P (NOLOCK)
	                    INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                    ON P.new_ConfirmStatus = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                    INNER JOIN vNew_TransactionType TT (NOLOCK)
	                    ON P.new_TransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                    INNER JOIN vNew_Corporation C
	                    ON P.new_PaidByCorporation = C.New_CorporationId AND C.DeletionStateCode = 0
	                    WHERE 
	                    P.DeletionStateCode = 0
	                    AND P.CreatedOn BETWEEN @StartDate AND @EndDate
                        AND P.new_PaidByCorporation = @CorporationId
                        
	                    UNION
                        
	                    SELECT
		                    RP.New_RefundPaymentId TransactionId
	                    FROM vNew_RefundPayment RP (NOLOCK)
	                    INNER JOIN vNew_Transfer T (NOLOCK)
	                    ON RP.new_TransferId = T.New_TransferId
	                    INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                    ON RP.new_ConfirmStatusId = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                    INNER JOIN vNew_TransactionType TT (NOLOCK)
	                    ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                    INNER JOIN vNew_Corporation C
	                    ON RP.new_RefundByCorporation = C.New_CorporationId AND C.DeletionStateCode = 0
	                    WHERE 
	                    RP.DeletionStateCode = 0
	                    AND RP.CreatedOn BETWEEN @StartDate AND @EndDate
                        AND RP.new_RefundByCorporation = @CorporationId                                

	                    UNION
                        
	                    SELECT 
		                    RT.New_RefundTransferId TransactionId
	                    FROM vNew_RefundTransfer RT (NOLOCK)
	                    INNER JOIN vNew_Transfer T (NOLOCK)
	                    ON RT.new_TransferId = T.New_TransferId
	                    INNER JOIN vNew_ConfirmStatus CS (NOLOCK)
	                    ON RT.new_ConfirmStatusId = CS.New_ConfirmStatusId AND CS.DeletionStateCode = 0
	                    INNER JOIN vNew_TransactionType TT (NOLOCK)
	                    ON T.new_TargetTransactionTypeID = TT.New_TransactionTypeId AND TT.DeletionStateCode = 0
	                    INNER JOIN vNew_Corporation C
	                    ON RT.new_CorporationId = C.New_CorporationId AND C.DeletionStateCode = 0
	                    WHERE 
	                    RT.DeletionStateCode = 0
	                    AND RT.CreatedOn BETWEEN @StartDate AND @EndDate
                        AND RT.new_CorporationId = @CorporationId
                    )";

            StaticData sd = new StaticData();
            sd.AddParameter("StartDate", DbType.DateTime, startDate);
            sd.AddParameter("EndDate", DbType.DateTime, endDate);
            sd.AddParameter("CorporationId", DbType.Guid, corporationId);
            return sd.ReturnDataset(sql).Tables[0];
        }
    }


    public partial class Reconciliation_Detail_AccountExtract : BasePage
    {
        DataTable result
        {
            get
            {
                return Session["ReconciliationData"] as DataTable;
            }
            set
            {
                Session["ReconciliationData"] = value;
            }
        }

        MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                //dStartDate.Value = DateTime.Today;
                //dEndDate.Value = DateTime.Today;                
            }
        }

        protected void CorporationLoad(object sender, AjaxEventArgs e)
        {
            string sql = @"SELECT 
                            c.New_CorporationId, 
                            c.new_CorporationCode,
                            c.CorporationName
                        FROM vNew_Corporation c 
                        WHERE DeletionStateCode = 0 
                    AND new_AccountStructure = 2 
                    ORDER BY 3";

            StaticData sd = new StaticData();
            DataTable dt = sd.ReturnDataset(sql).Tables[0];
            cfCorporation.DataSource = dt;
            cfCorporation.DataBind();
        }

        protected void GetReConciliationClick(object sender, AjaxEventArgs e)
        {
            if (cfCorporation.SelectedItems != null)
            {
                string corporationCode = cfCorporation.SelectedItems[0]["new_CorporationCode"];
                Guid corporationId = ValidationHelper.GetGuid(cfCorporation.Value);

                DataTable excelData = new DataTable();
                GetExcelData(excelData, upExtract1, corporationCode, "1");
                GetExcelData(excelData, upExtract2, corporationCode, "2");
                GetExcelData(excelData, upExtract3, corporationCode, "3");
                GetExcelData(excelData, upExtract4, corporationCode, "4");
                GetExcelData(excelData, upExtract5, corporationCode, "5");
                GetExcelData(excelData, upExtract6, corporationCode, "6");

                result = new AccountExtractReconciliationFactory().Reconciliate(corporationId, excelData, ValidationHelper.GetBoolean(chCheckAmount.Value));

                GrdReConciliation.DataSource = result;
                GrdReConciliation.DataBind();
            }
        }

        void GetExcelData(DataTable excelData, RefleXFrameWork.FileUpload upExtract, string corporationCode, string code)
        {
            if (upExtract.PostedFile.FileName != string.Empty)
            {
                string[] str = upExtract.PostedFile.FileName.Split(".".ToCharArray());
                string path = Path.Combine
                    (
                        ExcelImportFactory.ImportPath,
                        string.Format("AccountExtract/{0}_{1}_{2}_{3}.{4}", corporationCode, code, DateTime.Today.ToString("yyyyMMdd"), Guid.NewGuid().ToString("N"), str[str.Length - 1])
                    );
                upExtract.PostedFile.SaveAs(path);

                var impf = new ExcelImportFactory();
                var data = new DataTable();

                excelData.Merge(impf.ReadDataFromXls(path));
            }
        }

        private void GetReconcliationData()
        {
            //if (dStartDate.Value.HasValue && dEndDate.Value.HasValue)
            //{ 
            //    GrdReConciliation.DataSource = PreAccountingReconciliationFactory.Instance.GetPreAccountingReconciliationData(ReconcliationType.PreAccounting, dStartDate.Value.Value, dEndDate.Value.Value);
            //    GrdReConciliation.DataBind();
            //}
            //else
            //{
            //    MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
            //    msg.Show("", "", " Lütfen tarih seçiniz.");
            //}
        }

        protected void ExportToExcel(object sender, AjaxEventArgs e)
        {
            var n = string.Format("Mutabakat-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
            Export.ExportDownloadData(result, n);
        }

        protected void Reset(object sender, AjaxEventArgs e)
        {
            Response.Redirect(Request.RawUrl);
        }
    }
}


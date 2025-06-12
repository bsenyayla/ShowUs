using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using TuFactory.BankingChannelTransaction;

public partial class BankingChannel_BankingChannelTransaction : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            new_StartDate.Value = DateTime.Now.Date;
            new_EndDate.Value = DateTime.Now.Date;
        }

    }

    protected void GetBankingChannelTransactionHistory(object sender, AjaxEventArgs e)
    {
        string sqlExtend = string.Empty;
        string sql = @"Declare @LangId int
                        Select @LangId = LanguageId from vSystemUser Where SystemUserId = @SystemUserId And DeletionStateCode = 0

                        Select FORMAT(BCTH.CreatedOn,'dd.MM.yyyy hh:mm:dd') As CreatedOn,BCTH.CreatedByName,BCTH.new_TransactionResult,BCTHPL.Label Channel from vNew_BankingChannelTranHistory(NoLock) BCTH
                        Inner Join new_PLNew_BankingChannelTranHistory_new_Channel(NoLock) BCTHPL
                        On ISNULL(BCTH.new_Channel,0) = BCTHPL.Value
                        Where new_BankingChannelTransactionId = @Id And BCTHPL.LangId = @LangId order by CreatedOn Desc";

        var sd = new StaticData();
        sd.AddParameter("Id", DbType.Guid, ValidationHelper.GetGuid(RowId.Value,Guid.Empty));
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        DataTable dt = sd.ReturnDataset(sql).Tables[0];

        GrdBankingChannelTransactionHistory.DataSource = dt;
        GrdBankingChannelTransactionHistory.DataBind();
    }

    protected void GetBankingChannelTransaction(object sender, AjaxEventArgs e)
    {
        string sqlExtend = string.Empty;
        string sql = @"Declare @LangId int
                        Select @LangId = LanguageId from vSystemUser Where SystemUserId = @SystemUserId And DeletionStateCode = 0
                        Select 
	                        New_BankingChannelTransactionId,
                            FORMAT(dbo.fnUTCToLocalTimeForUser(bct.CreatedOn,@SystemUserId),'dd.MM.yyyy hh:mm:dd') As CreatedOn,
                            CreatedByName,
	                        SWIFT_ID,
	                        new_TransferIdName,                       
	                        new_GBANKA_REFERANS,
	                        new_TUTAR,
	                        new_DOVIZ_KODU,
	                        new_GONDEREN_BILGI,
	                        new_GONDEREN_ADI,
	                        new_ALICI_ADI,
	                        new_ALICI_BILGI,
	                        PLBCT.Label AS new_IsCommitted,
                            PLBCT.Value AS new_CommittedValue,
	                        PLBCT2.Label AS Channel,
	                        new_TRANSACTIONRESULT
                        From vNew_BankingChannelTransaction(NoLock) BCT
                        Inner Join new_PLNew_BankingChannelTransaction_new_IsCommitted(NoLock) PLBCT
                        On ISNULL(BCT.new_IsCommitted,0) = PLBCT.Value
                        Inner Join new_PLNew_BankingChannelTransaction_new_Channel(NoLock) PLBCT2
                        On ISNULL(BCT.new_Channel,0) = PLBCT2.Value 
                        Where 
	                        BCT.DeletionStateCode = 0 AND PLBCT.LangId = @LangId AND PLBCT2.LangId = @LangId";

        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        if (!string.IsNullOrEmpty(SwiftNo.Value))
        {
            sqlExtend += " AND BCT.SWIFT_ID = @SwiftId";
            sd.AddParameter("SwiftId", DbType.String, SwiftNo.Value);
        }

        if (!string.IsNullOrEmpty(TransferTuRef.Value))
        {
            sqlExtend += " AND BCT.new_TransferIdName = @TransferTuRef";
            sd.AddParameter("TransferTuRef", DbType.String, TransferTuRef.Value);
        }

        if (new_StartDate.Value != null)
        {
            sqlExtend += " AND Cast(BCT.CreatedOn as date) >= @StartDate";
            sd.AddParameter("StartDate", DbType.DateTime, new_StartDate.Value);
        }

        if (new_EndDate.Value != null)
        {
            sqlExtend += " AND Cast(BCT.CreatedOn as date) <= @EndDate";
            sd.AddParameter("EndDate", DbType.DateTime, new_EndDate.Value);
        }

        if (!string.IsNullOrEmpty(new_IsCommitted.Value))
        {
            sqlExtend += " AND BCT.new_IsCommitted = @CommittedType";
            sd.AddParameter("CommittedType", DbType.String, new_IsCommitted.Value);
        }

        DataTable dt = sd.ReturnDataset(sql + sqlExtend + " Order By PLBCT.Label").Tables[0];

        GrdBankingChannelTransaction.DataSource = dt;
        GrdBankingChannelTransaction.TotalCount = dt.Rows.Count;
        GrdBankingChannelTransaction.DataBind();
    }

    protected void Process(object sender, AjaxEventArgs e)
    {
        List<string> lString = new List<string>();
        //var degerler = ((RowSelectionModel)GrdBankingChannelTransaction.SelectionModel[0]);
        //if (degerler != null && degerler.SelectedRows != null)

        if (SelectedCommittedTypeCode.Value == "4")
        {
            QScript("alert('Dikkat. Bu kayıt için daha önceden transfer oluşturldu. Lütfen uygun kaydı seçiniz.');");
            return;
        }

        if(!string.IsNullOrEmpty(MainGridSelectedRow.Value))
        {
            lString.Add(MainGridSelectedRow.Value);
        }
        else
        {
            return;
        }

        BankingChannelManager manager = new BankingChannelManager();
        manager.GenerateBankChannelTransactions(lString, ProcessorType.Screen);
        QScript("alert('İşleminiz Gerçekleşti. İşlem durumunu gözlemleyebilirsiniz.');");
        GetBankingChannelTransaction(null, null);
        
    }
}
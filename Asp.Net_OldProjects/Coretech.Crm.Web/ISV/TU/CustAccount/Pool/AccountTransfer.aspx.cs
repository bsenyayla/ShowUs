using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using Newtonsoft.Json;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.TuUser;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Objects.Crm.WorkFlow;

public partial class CustAccount_Pool_AccountTransfer : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            RecId.Value = QueryHelper.GetString("recid");

            CustAccountOperationsHeaderRef.ReadOnly = true;
            new_SenderCustAccountOperationsId.ReadOnly = true;
            new_ReceiverCustAccountOperationsId.ReadOnly = true;
            new_SenderAccountId.ReadOnly = true;
            new_ReceiverAccountId.ReadOnly = true;
            new_SenderAccountId.ReadOnly = true;
            new_RecipientAmount.ReadOnly = true;
            new_SendAmount.ReadOnly = true;
            SSenderId.ReadOnly = true;
            RSenderId.ReadOnly = true;
            LoadData();

        }

    }

    private void LoadData()
    {
        if (!string.IsNullOrEmpty(RecId.Value))
        {
            DynamicFactory df;

            df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };



            var tr = df.Retrieve(TuEntityEnum.New_CustAccountOperationsHeader.GetHashCode(),
                                          ValidationHelper.GetGuid(RecId.Value),
                                          DynamicFactory.RetrieveAllColumns);


            CustAccountOperationsHeaderRef.FillDynamicEntityData(tr);
            new_SenderCustAccountOperationsId.FillDynamicEntityData(tr);
            new_ReceiverCustAccountOperationsId.FillDynamicEntityData(tr);
            new_SenderAccountId.FillDynamicEntityData(tr);
            new_ReceiverAccountId.FillDynamicEntityData(tr);
            new_SenderAccountId.FillDynamicEntityData(tr);
            new_RecipientAmount.FillDynamicEntityData(tr);
            new_SendAmount.FillDynamicEntityData(tr);













            StaticData sd = new StaticData();
            sd.AddParameter("CustAccountOperationHeaderId", DbType.Guid, ValidationHelper.GetGuid(RecId.Value));
            DataTable dt = sd.ReturnDataset(@"Select CustAccountOperationsHeaderRef,new_SenderCustAccountOperationsIdName,new_ReceiverCustAccountOperationsIdName,new_SenderAccountIdName,new_ReceiverAccountIdName,
new_SendAmount,new_SendAmountCurrency,new_SendAmountCurrencyName,new_RecipientAmount,
new_RecipientAmountCurrency,new_RecipientAmountCurrencyName,new_OriginalParity,new_MarginParity,new_TransferType ,
sca.new_SenderId AS SSenderId,sca.new_SenderIdName AS SSenderIdName,rca.new_SenderId AS RSenderId,rca.new_SenderIdName AS RSenderIdName
From vNew_CustAccountOperationsHeader(nolock) caoh
INNER JOIN vNew_CustAccountOperations(nolock) scao ON scao.New_CustAccountOperationsId=caoh.new_SenderCustAccountOperationsId
INNER JOIN vNew_CustAccountOperations(nolock) rcao ON rcao.New_CustAccountOperationsId=caoh.new_ReceiverCustAccountOperationsId
INNER JOIN vNew_CustAccounts(nolock) sca ON sca.New_CustAccountsId = scao.new_CustAccountId
INNER JOIN vNew_CustAccounts(nolock) rca ON rca.New_CustAccountsId = rcao.new_CustAccountId
WHERE New_CustAccountOperationsHeaderId =@CustAccountOperationHeaderId").Tables[0];

            if (dt.Rows.Count > 0)
            {
                SSenderId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["SSenderId"]), ValidationHelper.GetString(dt.Rows[0]["SSenderIdName"]));
                RSenderId.SetValue(ValidationHelper.GetGuid(dt.Rows[0]["RSenderId"]), ValidationHelper.GetString(dt.Rows[0]["RSenderIdName"]));
            }

        }
    }















}
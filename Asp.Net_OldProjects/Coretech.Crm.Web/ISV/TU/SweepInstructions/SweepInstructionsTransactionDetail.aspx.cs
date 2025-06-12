using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory.Crm.Dynamic;
using TuFactory.Object;
using Coretech.Crm.Objects.Crm.WorkFlow;
using TuFactory.SweepInstructions;

public partial class SweepInstructionsTransactionDetail : BasePage
{

        
    protected void Page_Load(object sender, EventArgs e)
    {
        hdnRecId.Value = QueryHelper.GetString("RecordId");

        DynamicFactory df;
        df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };

        var tr = df.Retrieve(TuEntityEnum.New_SweepInstructionsTransaction.GetHashCode(),
                                ValidationHelper.GetGuid(hdnRecId.Value),
                                DynamicFactory.RetrieveAllColumns);
       
        if (ValidationHelper.GetGuid(hdnRecId.Value) != Guid.Empty)
        {
               
            Reference.FillDynamicEntityData(tr);
            CreatedOn.FillDynamicEntityData(tr);
            new_SweepInstructionsId.FillDynamicEntityData(tr);
            new_CorporationId.FillDynamicEntityData(tr);
            new_SenderAccountId.FillDynamicEntityData(tr);
            new_RecipientInstructionsCorpAccountId.FillDynamicEntityData(tr);
            new_RecipientInstructionsAccountNo.FillDynamicEntityData(tr);
            new_RecipientInstructionsAccountIBAN.FillDynamicEntityData(tr);
            new_Amount.FillDynamicEntityData(tr);
            new_AmountCurrency.FillDynamicEntityData(tr);
            new_VirmanId.FillDynamicEntityData(tr);
            new_BankReferenceGuid.FillDynamicEntityData(tr);
            new_BankTransactionRefNo.FillDynamicEntityData(tr);
            new_ErrorStatus.FillDynamicEntityData(tr);
            new_ErrorExplanation.FillDynamicEntityData(tr);
            new_TransactionStatus.FillDynamicEntityData(tr);
        }

    }

}

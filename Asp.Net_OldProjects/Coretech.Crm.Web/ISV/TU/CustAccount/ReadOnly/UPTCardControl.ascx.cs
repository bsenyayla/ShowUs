using System;
using System.Web.UI;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm;

public partial class CustAccount_ReadOnly_UPTCardControl : UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            var custTotalPayAmount = Page.FindControl("new_CustTotalPayAmount_Container") as NumericField;
            custTotalPayAmount.SetFieldLabel(CrmLabel.TranslateMessage("CRM.NEW_CUSTACCOUNTOPERATIONS_UPT_CARD_TRANSFER_AMOUNT"));
        }
    }
}
using System;
using AjaxPro;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Transfer;


public partial class Transfer_Transfer : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));

        }
    }
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {

        [AjaxMethod()]
        public TransferCalculate CalculateData(
            string recordId, string property, decimal propertyAmount, string propertyAmountCurrency

            )
        {
            var tpc = new TransferPageCalculateFactory();
            var ret = tpc.Calculate(ValidationHelper.GetGuid(recordId), property, propertyAmount, ValidationHelper.GetGuid(propertyAmountCurrency));

            return ret;
        }

        //[AjaxMethod()]
        //public AjaxFindeSender FindeSenderbyIdentificationNumber(string identificationNumber)
        //{
        //    var tpf = new TransferPageFactory();
        //    var ret = tpf.FindeSenderbyIdentificationNumber(identificationNumber);
        //    return ret;
        //}
    }
}
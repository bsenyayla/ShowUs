using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;

namespace Coretech.Crm.Web.ISV.TU.Reports
{
    public partial class UptionReportDateControl : System.Web.UI.UserControl
    {
        double Period = 30;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                if (new_FormTransactionDate1.Value != null)
                {
                    new_FormTransactionDate2.Value = new_FormTransactionDate1.Value;
                }
            }

        }
        public void FormTransactionDate1OnEvent(object sender, AjaxEventArgs e)
        {
            string filtermsg = GetFilterValidation();
            if (!string.IsNullOrEmpty(filtermsg))
            {
                var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", filtermsg);
                var Value = ValidationHelper.GetDate(new_FormTransactionDate2.Value).AddDays(-Period).ToString("dd.MM.yyyy");
                new_FormTransactionDate1.SetValue(Value);
                return;
            }
        }
        public void FormTransactionDate2OnEvent(object sender, AjaxEventArgs e)
        {
            string filtermsg = GetFilterValidation();
            if (!string.IsNullOrEmpty(filtermsg))
            {
                var ms = new MessageBox { MessageType = EMessageType.Information, Modal = true, Height = 200, Width = 400 };
                ms.Show(".", filtermsg);
                new_FormTransactionDate2.SetValue(ValidationHelper.GetDate(new_FormTransactionDate1.Value).AddDays(Period).ToString("dd.MM.yyyy"));               
                return;
            }
        }
        private string GetFilterValidation()
        {
            string errMsg = string.Empty;


            if (!(new_FormTransactionDate1.Value == null || new_FormTransactionDate2.Value == null))
            {
                double dateDiff = (ValidationHelper.GetDate(new_FormTransactionDate2.Value) - ValidationHelper.GetDate(new_FormTransactionDate1.Value)).TotalDays;
                if (dateDiff > Period)
                {
                    errMsg = string.Format(CrmLabel.TranslateMessage("Maksimimum 30 günlük arama yapabilirsiniz."), Period);
                }
            }

            return errMsg;
        }
    }
}
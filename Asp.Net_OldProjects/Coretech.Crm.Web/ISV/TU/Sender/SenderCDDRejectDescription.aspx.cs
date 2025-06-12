using System;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Sender;

public partial class Sender_SenderCDDRejectDescription : BasePage
{

    protected void Page_Load(object sender, EventArgs e)
    {
      
    }

    protected void btnRejectClick(object sender, AjaxEventArgs e)
    {

        Guid senderID = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
        SenderFactory senderF = new SenderFactory();

        try
        {

            if(string.IsNullOrEmpty(new_Description.Value))
            {
                throw new Exception("CDD Red işleminde açıklama alanı zorunludur.");
            }

            string result = senderF.ComplateConfirmSenderCDD(senderID, 4);
            senderF.CreateSenderCDDHistory(senderID, 4, ValidationHelper.GetString(new_Description.Value));

            MessageBox msg = new MessageBox();
            msg.Show(result);
        }
        catch (Exception ex)
        {

            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }


    protected void btnAcceptClick(object sender, AjaxEventArgs e)
    {

        Guid senderID = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));
        SenderFactory senderF = new SenderFactory();

        try
        {
            string result = senderF.ComplateConfirmSenderCDD(senderID, 3);
            senderF.CreateSenderCDDHistory(senderID, 3, string.Empty);

            MessageBox msg = new MessageBox();
            msg.Show(result);
        }
        catch (Exception ex)
        {

            MessageBox msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

}
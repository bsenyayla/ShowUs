using System;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm;

public partial class FtpFileTransfer_FileTransferMain : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            FILETRANSFERINPUT.Title = CrmLabel.TranslateMessage("CRM.ENTITY_FILETRANSFERINPUT");
            FILETRANSFEROUTPUT.Title = CrmLabel.TranslateMessage("CRM.ENTITY_FILETRANSFEROUTPUT");
            FTPSENDTRANSFER.Title = CrmLabel.TranslateMessage("CRM.ENTITY_FILETRANSFER_CORP");

            FILETRANSFEROUTPUT.Url = "_FileTransfer/_FileTransferOutput.aspx";
            FILETRANSFERINPUT.Url = "_FileTransfer/_FileTransferInput.aspx";
            FTPSENDTRANSFER.Url = "_FileTransfer/_FTPSendTransfer.aspx";
            TabPanel1.LoadUrl();
        }
    }
}
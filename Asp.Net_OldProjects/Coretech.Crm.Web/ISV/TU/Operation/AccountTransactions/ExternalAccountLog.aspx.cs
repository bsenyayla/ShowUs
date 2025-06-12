using System;
using System.Data;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.ExternalAccountTransactions;

public partial class ExternalAccountLogPage : BasePage
{
    //private DynamicSecurity _dynamicSecurityTransfer;
    //private DynamicSecurity _dynamicSecurityPayment;
    //private TuUserApproval _userApproval = null;
    //private TuUser _activeUser = null;
    //private Guid ExternalAccountTransactionId = Guid.Empty;
    //MessageBox _msg = new MessageBox { MessageType = EMessageType.Information, Modal = true };

    protected void Page_Load(object sender, EventArgs e)
    {
        //var ufFactory = new TuUserFactory();
        //_userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
        //_activeUser = ufFactory.GetActiveUser();
        gvLog.ReConfigure();
    }

    protected void LogDataBind(object sender, AjaxEventArgs e)
    {
        Guid externalAccountTransactionId = Guid.Parse(Request.QueryString["recId"].ToString());
        DataTable dt = ExternalAccountTransactionFactory.Instance.GetExternalAccountTransactionLog(externalAccountTransactionId);
        gvLog.DataSource = dt;
        gvLog.DataBind();
    }
} 
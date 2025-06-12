using Coretech.Crm.Factory;
using RefleXFrameWork;
using System;
using System.Web.UI;
using TuFactory.Object.User;
using TuFactory.TuUser;

public partial class CustAccount_Account_CustAccountBalanceView : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var objd = Page.FindControl("new_Balance_Container") as DisplayField;
        TuUserApproval userApproval = new TuUserFactory().GetApproval(App.Params.CurrentUser.SystemUserId);
        //Bakiye görme yetkisi yoksa
        if (!userApproval.CustAccountBalanceView)
        {
            objd.Hide();
        }
    }
}
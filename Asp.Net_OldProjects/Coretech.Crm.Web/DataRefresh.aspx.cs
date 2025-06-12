using System;
using System.Web.UI;
using TuFactory.Integration3rd;

namespace Coretech.Crm.Web
{
    public partial class DataRefresh : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                if (Request.Form["pwd"] == "uptDataRfrsh13!")
                {
                    string type = Request.QueryString["type"];
                    switch (type)
                    {
                        case "account":
                            RefreshAccounts();
                            break;
                        default:
                            Response.StatusCode = 406;
                            Response.End();
                            break;
                    }
                }
                else
                {
                    Response.StatusCode = 401;
                    Response.End();
                }
            }
        }

        void RefreshAccounts()
        {
            TuFactory.PreAccounting.Business.Accounts.AccountManager.SetAccounts();
        }
    }
}
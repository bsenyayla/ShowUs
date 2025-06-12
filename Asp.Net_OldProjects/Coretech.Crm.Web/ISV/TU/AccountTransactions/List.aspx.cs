using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.PluginData;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;
using TuFactory.Object;

namespace Coretech.Crm.Web.ISV.TU.AccountTransactions
{
    public partial class List : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var DynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_AccountTransactions.GetHashCode(), null);
            if (!(DynamicSecurity.PrvShowMenu))
            {
                Response.Redirect("~/MessagePages/_PrivilegeError.aspx");
            }
        }

        void ShowMessage(string messageText)
        {
            MessageBox messageBox = new MessageBox();
            messageBox.Width = 400;
            messageBox.Height = 200;
            messageBox.Show(messageText);
        }

        protected void Search(object sender, AjaxEventArgs e)
        {
            string reference = tReference.Value.Trim();
            if (!string.IsNullOrEmpty(reference))
            {
                gpItems.DataSource = GetData(reference);
                gpItems.DataBind();
            }
            else
            {
                ShowMessage("Arama için referans bilgisi girilmelidir.");
            }
        }

        protected void ExportToExcel(object sender, AjaxEventArgs e)
        {
            string reference = tReference.Value.Trim();
            if (!string.IsNullOrEmpty(reference))
            {
                DataTable dt = GetData(reference);
                if (dt.Rows.Count > 0)
                {
                    var n = string.Format("AccountTransactions-Export-{0:yyyy-MM-dd_hh-mm-ss-tt}.xls", DateTime.Now);
                    Export.ExportDownloadData(dt, n);
                }
            }
            else
            {
                ShowMessage("Arama için referans bilgisi girilmelidir.");
            }
        }

        DataTable GetData(string reference)
        {
            StaticData sd = new StaticData();
            sd.AddParameter("Reference", System.Data.DbType.String, reference);
            return sd.ReturnDatasetSp("spGetAccountTransactions").Tables[0];
        }
    }
}
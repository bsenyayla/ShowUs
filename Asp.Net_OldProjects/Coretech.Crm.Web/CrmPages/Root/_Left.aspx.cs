using System;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Root_Left : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack) {
            var mui = new ModulesUi();
            FitLayoutPanel.BodyControls.Add(mui);
        }
    }
}

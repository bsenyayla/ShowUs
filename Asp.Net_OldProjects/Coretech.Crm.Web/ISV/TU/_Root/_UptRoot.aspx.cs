using System;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Web.UI.RefleX;

public partial class _Root_UptRoot : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Page.Header.Controls.Add(
    new LiteralControl(
        @"<style type='text/css'>
                /*type selector*/
                html
                {
                    width: 100%;
                    height: 100%;
                    background: url(../../../" + App.Params.GetConfigKeyValue("CompanyLogo") + @") center center no-repeat;
                }
                </style>
            "
        )
);
    }
}
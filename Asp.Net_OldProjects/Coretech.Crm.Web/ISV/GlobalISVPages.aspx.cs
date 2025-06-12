using System;
using Coretech.Crm.Factory.Crm.CustomControl;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;


public partial class ISV_GlobalISVPages : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
    }
 
    protected override void OnInit(EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            var controlId = QueryHelper.GetString("CustomControlId");
            if (ValidationHelper.GetGuid(controlId) != Guid.Empty)
            {

                var  newc = CustomControlFactory.GetCustomContorl(ValidationHelper.GetGuid(controlId));
                 newc.ID = "newc";
                 form1.Controls.Add(newc);
            }
            else
            {
                throw new Exception("You Must Select CustomControlId");
            }
            base.OnPreInit(e);
        }
    } 
 
}
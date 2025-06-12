using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Coretech.Crm.Web.ISV.TU.StepByStep
{
    public partial class StepPage : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {

                hdnCurrentPageNumber.Value = "1";
                hdnFinishPageNumber.Value = "3";

                ///<summary>
                ///Burda kaç panel varsa toolTip 1 olan hariç gizleniyor. 
                ///</summary>
                foreach (Control item in this.form1.Controls)
                {
                    if (item.GetType() == typeof(RefleXFrameWork.PanelX))
                    {
                        if (((RefleXFrameWork.PanelX)item).ToolTip != "1")
                        {
                            ((RefleXFrameWork.PanelX)item).Hide();
                        }
                    }
                }
            }
        }

        protected void Previus(object sender, AjaxEventArgs e)
        {
            int currentStepNumber = ValidationHelper.GetInteger(hdnCurrentPageNumber.Value,0);
            if(currentStepNumber == 1)
            {
                return;
            }
            else
            {

            }
        }

        protected void NextFinish(object sender, AjaxEventArgs e)
        {

        }

    }
}
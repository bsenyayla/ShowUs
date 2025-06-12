using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TuFactory.Profession;

namespace Coretech.Crm.Web.ISV.TU.Profession
{
    public partial class Profession : BasePage
    {
       
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                hdnSenderId.Value = QueryHelper.GetString("senderId");
                hdnSenderId.SetIValue(QueryHelper.GetString("senderId"));

                var professionDb = new ProfessionDb();
                DataTable dt = professionDb.GetProfessionAndWorkingStyleInfo(ValidationHelper.GetGuid(QueryHelper.GetString("senderId")));
                if(dt.Rows.Count > 0)
                {
                    new_WorkingStyleId.SetIValue(dt.Rows[0]["new_WorkingStyleId"]);
                    new_WorkingStyleId.SetValue(dt.Rows[0]["new_WorkingStyleId"]);
                    if (ValidationHelper.GetGuid(dt.Rows[0]["new_WorkingStyleId"],Guid.Empty) != Guid.Empty)
                    {
                        new_WorkingStyleId.SetDisabled(true);
                    }

                    new_ProfessionID.SetIValue(dt.Rows[0]["new_ProfessionID"]);
                    new_ProfessionID.SetValue(dt.Rows[0]["new_ProfessionID"]);

                    if (ValidationHelper.GetGuid(dt.Rows[0]["new_ProfessionID"], Guid.Empty) != Guid.Empty)
                    {
                        new_ProfessionID.SetDisabled(true);
                    }
                }
                QScript(string.Format("document.getElementById('bId').innerHTML = '{0}';", CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_WARNING_MESSAGE")));
            }
        }
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
        }

        protected void btnSenderProfessionUpdate_Click(object sender, AjaxEventArgs e)
        {
            var professionDb = new ProfessionDb();
            professionDb.UpdateProfessionOnSender(ValidationHelper.GetGuid(hdnSenderId.Value), ValidationHelper.GetGuid(new_ProfessionID.Value),
                ValidationHelper.GetGuid(new_WorkingStyleId.Value));
            QScript(String.Format("alert('Kaydetme işleminiz başarı ile tamamlandı. İşleminize devam edebilirsiniz.');", CrmLabel.TranslateMessage("CRM.NEW_PROFESSION_SAVE_MESSAGE")));
            QScript("window.top.R.WindowMng.getActiveWindow().hide();");
        }
    }
}
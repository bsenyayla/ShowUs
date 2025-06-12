using AjaxPro;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Newtonsoft.Json;
using RefleXFrameWork;
using System;
using System.Data;
using System.Web.UI;
using TuFactory.KpsAps;
using TuFactory.Object;
using TuFactory.Object.AjaxObject;
using TuFactory.Sender;

public partial class Sender_SenderPersonAccount : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Utility.RegisterTypeForAjax(typeof(AjaxMethods));
        Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText2", "var CRM_NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL="
              + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_FOREIGNIDENTIFICATIONID_LABEL")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage1", "var NEW_SENDER_KPSZORUNLU="
                           + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_KPSZORUNLU")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "InvalidGsm", "var InvalidGsm="
                  + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_PHONENUMBER_INVALID_EMPTY")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage2", "var NEW_SENDER_KPS_HATALI="
                                  + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_KPS_HATALI")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage3", "var NEW_SENDER_IDENDITYNO_MUST_BE_NUMBER="
          + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_IDENDITYNO_MUST_BE_NUMBER")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage4", "var NEW_SENDER_IDENDITYNO_MUST_BE_ELEVEN_CHAR="
          + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_IDENDITYNO_MUST_BE_ELEVEN_CHAR")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "KeyMessage5", "var CRM_NEW_SENDER_SINGULARITY_CONFIRM="
          + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_SINGULARITY_CONFIRM")) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "NationTurkeyParam", "var TurkeyID="
               + JsonConvert.SerializeObject(SenderNationalityID.Turkey) + ";", true);
        Page.ClientScript.RegisterStartupScript(typeof(string), "LabelText1", "var CRM_NEW_SENDER_IDENTIFICATION_NUMBER="
             + JsonConvert.SerializeObject(CrmLabel.TranslateMessage("CRM.NEW_SENDER_NEW_SENDERIDENDIFICATIONNUMBER1_UYRUK 1 KIMLIK NO")) + ";", true);
        QScript("DisableToolbar();");
        QScript("NationalID_onChange();");
        QScript("SetSenderID();");
    }

    #region AjaxMethods
    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {
        [AjaxMethod()]
        public AjxKpsPerson GetKpsData(string senderIdendificationNumber1, string nationalityId)
        {
            var ret = new AjxKpsPerson();
            var sf = new SenderFactory();
            try
            {
                ret = sf.GetKpsData(senderIdendificationNumber1, ValidationHelper.GetGuid(nationalityId));
            }
            catch (Exception)
            {
                ret.new_cameFromKps = false;
            }

            return ret;
        }

        [AjaxMethod()]
        public AjxAddress GetApsData(string senderIdendificationNumber1, string nationalityId)
        {
            var ret = new AjxAddress();
            var sf = new KpsApsFactory();
            try
            {
                ret = sf.GetApsData(senderIdendificationNumber1, ValidationHelper.GetGuid(nationalityId));
            }
            catch (Exception)
            {

            }

            return ret;
        }

        [AjaxMethod()]
        public void UpdateSenderId(Guid senderId, Guid senderPersonId)
        {
            try
            {
                string strSql = @"spTUSenderPersonUpdateSenderId";

                StaticData sd = new StaticData();
                sd.AddParameter("SenderId", DbType.Guid, ValidationHelper.GetGuid(senderId));
                sd.AddParameter("SenderPersonId", DbType.Guid, ValidationHelper.GetGuid(senderPersonId));

                sd.ExecuteNonQuerySp(strSql);
            }
            catch (Exception ex)
            {
                var m = new MessageBox { Width = 400, Height = 120 };
                var msg2 = CrmLabel.TranslateMessage(ex.Message);
                m.Show("", msg2);
                return;
            }

        }
    }
    #endregion
}
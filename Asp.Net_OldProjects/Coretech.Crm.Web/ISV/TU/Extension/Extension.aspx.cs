using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
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
using TuFactory.ExtensionManager;
using TuFactory.Object;

namespace Coretech.Crm.Web.ISV.TU.Extension
{
    public partial class Extension : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                TranslateControlName();
                HdnRecId.SetIValue(QueryHelper.GetInteger("recordId"));
                HdnRecId.Value = ValidationHelper.GetInteger(QueryHelper.GetInteger("recordId"), 0).ToString();

                if(ValidationHelper.GetInteger(HdnRecId.Value,0) > 0)
                {
                    ShowData(new TuFactory.ExtensionManager.ExtensionDb().GetExtensionMapping(ValidationHelper.GetInteger(HdnRecId.Value, 0)));
                }
            }
        }

        private void ShowData(DataTable dt)
        {
            new_CorporationId.Value = ValidationHelper.GetString(dt.Rows[0]["CORPORATIONID"]);
            New_ExtensionId.Value = ValidationHelper.GetString(dt.Rows[0]["EXTENSIONID"]);
            New_ExtensionTokenId.Value = ValidationHelper.GetString(dt.Rows[0]["EXTENSION_TOKEN_ID"]);
            txtUrl.Value = ValidationHelper.GetString(dt.Rows[0]["URL"]);
            Asynchronous.Value = ValidationHelper.GetBoolean(dt.Rows[0]["ASYNC"]);
            iscash.Value = ValidationHelper.GetBoolean(dt.Rows[0]["ISCASH"]);

        }

        void TranslateControlName()
        {
            New_ExtensionId.FieldLabel = "<b>Extension</b>";
            New_ExtensionTokenId.FieldLabel = "<b>Token</b>";
            new_CorporationId.FieldLabel = "<b>Corporation</b>";
            iscash.FieldLabel = "<b>Cash</b>";
        }
        protected void Save_Event(object sender, AjaxEventArgs e)
        {
            var extensionDb = new ExtensionDb();
            var result = extensionDb.SaveExtensionMapping(ValidationHelper.GetInteger(HdnRecId.Value, 0), ValidationHelper.GetGuid(New_ExtensionId.Value), ValidationHelper.GetGuid(New_ExtensionTokenId.Value),
                ValidationHelper.GetGuid(new_CorporationId.Value), ValidationHelper.GetBoolean(Asynchronous.Value), txtUrl.Value, ValidationHelper.GetBoolean(iscash.Value));

            if (result)
            {
                ShowMessage("The operation completed successfully");
            }
            else
            {
                if (result)
                {
                    ShowMessage("ERROR, the operation cannot be completed");
                }
            }
        }




        ExtensionInfo GetExtensionInfo(Guid extensionId)
        {
            ExtensionInfo extensionInfo = null;
            DataTable dt = new TuFactory.ExtensionManager.ExtensionDb().GetExtension(extensionId);

            try
            {
                if (dt.Rows.Count > 0)
                {
                    extensionInfo = new ExtensionInfo();
                    extensionInfo.ExtensionId = ValidationHelper.GetGuid(dt.Rows[0]["New_ExtensionId"]);
                    extensionInfo.Inheritable = ValidationHelper.GetBoolean(dt.Rows[0]["new_IsInheritable"]);
                    extensionInfo.Asynchronous = ValidationHelper.GetBoolean(dt.Rows[0]["new_asynchronous"]);
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex);
            }

            return extensionInfo;
        }

        protected void ExtensionChange_Event(object sender, AjaxEventArgs e)
        {
            var extensionInfo = GetExtensionInfo(ValidationHelper.GetGuid(New_ExtensionId.Value));
            if (extensionInfo != null)
            {
                if (extensionInfo.Inheritable)
                {
                    Asynchronous.Checked = extensionInfo.Asynchronous;
                    Asynchronous.SetValue(extensionInfo.Asynchronous);
                    Asynchronous.SetDisabled(false);
                }
                else
                {
                    Asynchronous.Checked = extensionInfo.Asynchronous;
                    Asynchronous.SetValue(extensionInfo.Asynchronous);
                    Asynchronous.SetDisabled(true);
                }
            }
        }

        protected void BtnShowInformationPAge(object sender, AjaxEventArgs e)
        {
            var readonlyform = new TuFactory.ExtensionManager.ExtensionDb().GetFormIdByFormName("ExtensionFrm");

            var query = new Dictionary<string, string>
                            {
                                {"defaulteditpageid", readonlyform.ToString()},
                                {"ObjectId",( (int)TuEntityEnum.New_Extension).ToString()},
                                {"recid", New_ExtensionId.Value},
                                {"mode", "3"}
                            };
            var urlparam = QueryHelper.RefreshUrl(query);
            Panel_Extension.AutoLoad.Url =
                Page.ResolveClientUrl("~/CrmPages/AutoPages/EditReflex.aspx" + urlparam);
            Panel_Extension.LoadUrl(Panel_Extension.AutoLoad.Url);
            QScript(" R.reSize();");
        }

        void ShowMessage(string messageText)
        {
            MessageBox messageBox = new MessageBox();
            messageBox.Modal = true;
            messageBox.Width = 400;
            messageBox.Height = 200;
            messageBox.Show(messageText);
        }



        public class ExtensionInfo
        {
            public Guid ExtensionId { get; set; }
            public bool Inheritable { get; set; }
            public bool Asynchronous { get; set; }
        }


    }
}
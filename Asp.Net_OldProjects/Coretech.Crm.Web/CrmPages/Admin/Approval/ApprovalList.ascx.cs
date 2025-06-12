using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web.UI;
using AjaxPro;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Approval;
using Coretech.Crm.Factory.Crm.DuplicateDetection;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.DynamicUrl;
using Coretech.Crm.Factory.Crm.Form;
using Coretech.Crm.Factory.Crm.Info;
using Coretech.Crm.Factory.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm.Plugin;
using Newtonsoft.Json;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Attributes;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Form;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using Coretech.Crm.Web.UI.RefleX;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using Coretech.Crm.Factory.Crm.Reporting;
using JavaScriptSerializer = System.Web.Script.Serialization.JavaScriptSerializer;
using Coretech.Crm.Messenger;

namespace Coretech.Crm.Web.CrmPages.Admin.Approval
{
    public partial class ApprovalList : System.Web.UI.UserControl
    {
        private GridPanel gridPanel;

        private void TranslateMessages()
        {
            BtnConfirm.AjaxEvents.Click.EventMask.Msg = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVING);
            BtnConfirm.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_CONFIRM);
            BtnReject.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_REJECT);
            BtnRejectReal.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_REJECT);
            windowReject.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_REJECT);
        }
        DynamicSecurity GetDynamicSecurity(Guid recid)
        {
            /*Security ApprovalRecord kaydına göre yapılacaktır.*/
            return DynamicFactory.GetSecurity(EntityEnum.ApprovalRecord.GetHashCode(), recid);
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack && !RefleX.IsAjxPostback)
            {
                TranslateMessages();

                var toolbar = Page.FindControl("toolbar1_Container") as ToolBar;
                if (toolbar != null)
                {
                    gridPanel.AjaxPostable = true;
                    toolbar.Items.Insert(0, BtnConfirm);
                    toolbar.Items.Insert(1, BtnReject);
                    toolbar.Items.Insert(2, new ToolbarSeparator() { ID = "btnsplit1" });
                }
            }

        }
        void SetApproval(bool confirm)
        {
            List<dynamic> approvalRecors = GetSelectedApprovalRecors(gridPanel);
            var starttime = DateTime.Now;
            var approvalFactory = new ApprovalFactory(App.Params.CurrentUser.SystemUserId);
            bool somerecordcannotapproval = false;
            foreach (var item in approvalRecors)
            {



                try
                {

                    if (confirm)
                    {
                        /*Confirm Isleminin yapildigi Yer*/
                        approvalFactory.SetConfirmApproval(ValidationHelper.GetGuid(item.ID));
                    }
                    else
                    {
                        /*Reject Isleminin yapildigi yer*/
                        approvalFactory.SetRejectApproval(ValidationHelper.GetGuid(item.ID), Comment.Value);
                    }

                }
                catch (CrmException ex)
                {
                    somerecordcannotapproval = true;
                    MessengerFactory.PushMessage(ex.ErrorMessage,Objects.Crm.Messenger.MessageType.Error);
                }

            }

            MessengerFactory.ShowMessages();
            gridPanel.ClearSelection();
            gridPanel.SetSelectedRowsIndex(0);
            windowReject.Hide();
            gridPanel.Reload();
        }
        protected void BtnConfirmClick(object sender, AjaxEventArgs e)
        {
            SetApproval(true);
        }
        protected void BtnRejectClick(object sender, AjaxEventArgs e)
        {
            SetApproval(false);
        }

        protected override void OnInit(EventArgs e)
        {
            var page = this.Page as BasePage;
            if (page != null)
            {
                var toolbar = page.FindControl("toolbar1_Container") as ToolBar;
                gridPanel = page.FindControl("GridPanelViewer_Container") as GridPanel;
                gridPanel.AjaxPostable = true;
                //gridPanel.SelectionModel[0] = new CheckSelectionModel();
            }

            base.OnInit(e);
        }

        private List<dynamic> GetSelectedApprovalRecors(GridPanel gridPanel)
        {
            try
            {
                return ((IEnumerable<dynamic>)(gridPanel.SelectionModel[0] as RowSelectionModel).SelectedRows).Where(x => !string.IsNullOrEmpty(x.ID)).ToList();

            }
            catch
            {
                BasePage.QScript("Alert('seçim yapılmalıdır!'); return false;");
                return null;
            }
        }
    }
}
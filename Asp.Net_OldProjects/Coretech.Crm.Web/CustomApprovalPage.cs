using Coretech.Crm.Factory;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using TuFactory.CustomApproval;
using TuFactory.Object.User;
using TuFactory.TuUser;

namespace Coretech.Crm.Web
{   
    public abstract class CustomApprovalPage<T> : BasePage where T : Approval
    {
        RefleXFrameWork.ToolBar approvalPanel = null;

        private T approval;
        protected T Approval
        {
            get
            {
                if (approval == null)
                {
                    approval = GetApprovalData();
                }
                return approval;
            }
        }

        protected Guid ApprovalId
        {
            get
            {
                string approvalId = QueryHelper.GetString("approvalId");
                return Guid.Parse(approvalId);
            }
        }

        protected abstract void SetApprovalData();

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            string mode = QueryHelper.GetString("mode");
            if (mode.ToLower() == "approval")
            {
                if (!CheckApprovalAuthorization())
                {
                    SetApprovalData();
                    return;
                }                

                if (this.Approval.ApprovalStatus == ApprovalStatuses.Created)
                {
                    approvalPanel = new RefleXFrameWork.ToolBar() { ID = "approvalPanel" };

                    RefleXFrameWork.ToolbarButton btnReject = new RefleXFrameWork.ToolbarButton()
                    {
                        Text = "Reddet",
                        ID = "btnReject",
                        Icon = RefleXFrameWork.Icon.Decline
                    };
                    btnReject.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(RejectClicked);
                    btnReject.AjaxEvents.Click.Before = "return confirm('Bu işlemi reddetmek istediğinize emin misiniz?');";
                    approvalPanel.Items.Add(btnReject);

                    RefleXFrameWork.ToolbarButton btnApprove = new RefleXFrameWork.ToolbarButton()
                    {
                        Text = "Onay Ver",
                        ID = "btnApprove",
                        Icon = RefleXFrameWork.Icon.Accept
                    };
                    btnApprove.AjaxEvents.Click.Event += new RefleXFrameWork.AjaxComponentListener.AjaxEventHandler(ApproveClicked);
                    btnApprove.AjaxEvents.Click.Before = "return confirm('Bu işlemi onaylamak istediğinize emin misiniz?');";
                    approvalPanel.Items.Add(btnApprove);

                    this.Controls.AddAt(0, approvalPanel);
                }
                if (!RefleX.IsAjxPostback)
                {
                    SetApprovalData();
                }
            }
        }

        bool CheckApprovalAuthorization()
        {
            if (this.Approval.CreateUser.SystemUserId != App.Params.CurrentUser.SystemUserId)
            {
                TuUserFactory ufFactory = new TuUserFactory();
                TuUserApproval userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
                return userApproval.ManualAccountingApproval;
            }
            return false;
        }

        T GetApprovalData()
        {
            ApprovalManager approvalManager = new ApprovalManager();
            return (T)approvalManager.GetApproval(this.ApprovalId);
        }

        void ApproveClicked(object sender, AjaxEventArgs e)
        {
            ApprovalManager approvalManager = new ApprovalManager();
            string result = approvalManager.Confirm(this.Approval, App.Params.CurrentUser.SystemUserId);
            if (string.IsNullOrEmpty(result))
            {
                MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                msg.Show("İşlem onaylandı.");

                approvalPanel.SetVisible(false);

                AfterApprove();
            }
            else
            {
                MessageBox msg = new MessageBox() { Width = 500, Height = 300, Modal = true, MessageType = EMessageType.Error };
                msg.Show(result);
            }
        }

        void RejectClicked(object sender, AjaxEventArgs e)
        {
            ApprovalManager approvalManager = new ApprovalManager();
            string result = approvalManager.Reject(this.ApprovalId, App.Params.CurrentUser.SystemUserId);

            if (string.IsNullOrEmpty(result))
            {
                MessageBox msg = new MessageBox() { Modal = true, MessageType = EMessageType.Information };
                msg.Show("İşlem reddedildi.");
            }
            else
            {
                MessageBox msg = new MessageBox() { Width = 500, Height = 300, Modal = true, MessageType = EMessageType.Error };
                msg.Show(result);
            }

            approvalPanel.SetVisible(false);
        }

        protected virtual void AfterApprove()
        {}
    }
}
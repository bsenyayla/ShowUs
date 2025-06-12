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
using Coretech.Crm.Objects.Crm.Approval;

public partial class CrmPages_Admin_Approval_ApprovalView : ConfirBasePage
{
    private EditPageConfirm _ep;
    private DynamicEntity _confirmEntity = null;
    private DynamicSecurity _dynamicSecurity;
    private DateTime _requestBeginTime;
    public string Ieopacity = "";
    public string Otheropacity = "";
    private ApprovalRecordTransactionType _transactionType;
    private void TranslateMessages()
    {
        BtnConfirm.AjaxEvents.Click.EventMask.Msg = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVING);
        BtnConfirm.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_CONFIRM);
        BtnReject.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_REJECT);
        BtnRejectReal.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_REJECT);
        windowReject.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_REJECT);
        BtnEdit.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_EDIT_PAGE);
        RegisterClientScriptBlock("CRM_APPROVALRECORD_THIS_RECORD_WILL_BE_DELETE", string.Format("var {0}={1};", "CRM_APPROVALRECORD_THIS_RECORD_WILL_BE_DELETE", BasePage.SerializeString(CrmLabel.TranslateMessage("CRM.APPROVALRECORD_THIS_RECORD_WILL_BE_DELETE"))));
    }
    void FillSecurity()
    {
        /*Security ApprovalRecord kaydına göre yapılacaktır.*/
        _dynamicSecurity = DynamicFactory.GetSecurity(EntityEnum.ApprovalRecord.GetHashCode(),
                                                          (string.IsNullOrEmpty(QueryHelper.GetString("recid"))
                                                               ? (Guid?)null
                                                               : ValidationHelper.GetGuid(QueryHelper.GetString("recid"))));
    }

    protected override void OnInit(EventArgs e)
    {
        var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
        dynamicFactory.ExecPlugin(PluginMsgType.FormInit, _ep.ObjectId, ref _ep.DynamicEntity,
                                      false);
        base.OnInit(e);
        dynamicFactory.ExecPlugin(PluginMsgType.FormInit, _ep.ObjectId, ref _ep.DynamicEntity,
                                      true);

         _confirmEntity = dynamicFactory.RetrieveWithOutPlugin(EntityEnum.ApprovalRecord.GetHashCode(), QueryHelper.GetGuid("recid"),
            new string[] { "TransactionType", "ConfirmStatus" });
        _transactionType = (ApprovalRecordTransactionType)_confirmEntity.GetPicklistValue("TransactionType");

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));
            CreateRequestObject();
            hdnRecid.Value = _ep.RecId.ToString();
            hdnObjectId.Value = _ep.ObjectId.ToString();
            hdnEntityId.Value = App.Params.CurrentEntity[_ep.ObjectId].EntityId.ToString();

            Page.Title =
                App.Params.CurrentEntity[_ep.ObjectId].GetLabel(
                    App.Params.CurrentUser.LanguageId) + " " +
                    CrmLabel.TranslateMessage(LabelEnum.CRM_EDIT_PAGE) + " ";

            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };

            if (hdnRecid.Value != "")
            {

                _ep.DataBind();
                if (_ep.DynamicEntity != null)
                {
                    Page.Title += " ... ";
                    hdnRecidName.Value =
                        _ep.DynamicEntity.GetStringValue(
                            EntityAttributeFactory.GetAttributeValString(
                                _ep.ObjectId));
                    if (hdnRecidName.Value.Length > 50)
                    {
                        hdnRecidName.Value = hdnRecidName.Value.Substring(0, 50) + "...";
                        Page.Title += hdnRecidName.Value;
                    }
                    else
                    {
                        Page.Title += hdnRecidName.Value;
                    }

                    var statuscode = _confirmEntity.GetPicklistValue("ConfirmStatus");
                    if (statuscode == 2 || statuscode == 3)
                    {
                        BtnConfirm.Visible = false;
                        BtnReject.Visible = false;
                        BtnEdit.Visible = false;
                    }
                    if (_transactionType == ApprovalRecordTransactionType.Delete)
                        BtnEdit.Visible = false;

                }

            }
            /*Data Yuklendikten sonta bir islemi kontrol edelim.*/
            dynamicFactory.ExecPlugin(PluginMsgType.FormLoad, _ep.ObjectId, ref _ep.DynamicEntity,
                                      false);
            if (App.Params.CurrentForms[_ep.FormId].LabelMessageId != Guid.Empty)
                hdnTitle.Value = CrmLabel.TranslateLabelMessage(App.Params.CurrentForms[_ep.FormId].LabelMessageId) + " ... " + hdnRecidName.Value;

            if (QueryHelper.GetString("mode") == "1")
                QScript("try{Tabpanel1.setactiveTabTitle(hdnTitle.getValue()!=''? hdnTitle.getValue():window.document.title);} catch(e){}");
            else
            {
                if (QueryHelper.GetString("mode") == "2")
                    QScript("try{parent.Tabpanel1.setactiveTabTitle(hdnTitle.getValue()!=''? hdnTitle.getValue():window.document.title);} catch(e){}");
            }


            if (_ep.MyForm.DisableToolbar)
            {
                EditToolbar.Visible = false;

            }

            SetClientScript();


            FillSecurity();

            if (EditToolbar.Visible)
            {
                if (hdnRecid.Value != "")
                {
                    if (!_dynamicSecurity.prvApproval)
                    {
                        if (BtnConfirm.Visible)
                            BtnConfirm.SetDisabled(true);

                        if (BtnReject.Visible)
                            BtnReject.SetDisabled(true);

                    }


                }


            }



        }



    }

    private void SetClientScript()
    {
        var beforeScript = "";
        var successScript = "";
        var onloadScript = "";
        if (_ep.MyForm.FormScript != null)
        {
            foreach (var formScript in _ep.MyForm.FormScript.FormScripts)
            {
                if (formScript.UseScript)
                {
                    switch (formScript.Type)
                    {
                        case FormScriptType.Onload:
                            onloadScript += formScript.Script;
                            break;
                        case FormScriptType.BeforeSave:
                            beforeScript += formScript.Script;
                            break;
                        case FormScriptType.AfterSave:
                            successScript += formScript.Script;
                            break;
                    }
                }
                switch (formScript.Type)
                {
                    case FormScriptType.Onload:
                        if (formScript.ClientWorkflowId != Guid.Empty)
                        {
                            var replacerEntity = _ep.DynamicEntity ?? _ep.GetDynamicEntity();
                            var wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId)
                            {
                                ActivePage = Page,
                                ReplacerEntity = replacerEntity
                            };
                            var script = wf.ExecAndAddQscripts(formScript.ClientWorkflowId,
                                                  _ep.ObjectId, replacerEntity, _ep.FormId);
                            QScript(script);
                        }
                        break;
                    case FormScriptType.BeforeSave:

                        break;
                    case FormScriptType.AfterSave:

                        break;
                }
            }

            if (_ep.MyForm.FormScript.UseIframe && !string.IsNullOrEmpty(_ep.MyForm.FormScript.IframeUrl))
            {
                var strScriptUrl = _ep.MyForm.FormScript.IframeUrl;

                if (strScriptUrl.Substring(0, 1) == "~")
                {
                    strScriptUrl = Page.ResolveClientUrl(strScriptUrl);
                }
                var url = QueryHelper.AddUpdateString(this, strScriptUrl, new Dictionary<string, string>()) +
                             "&newSession=" + Guid.NewGuid();
                var onloadscript = string.Empty;
                foreach (var formScript in _ep.MyForm.FormScript.FormScripts.Where(formScript => formScript.UseScript))
                {
                    switch (formScript.Type)
                    {
                        case FormScriptType.Onload:
                            onloadscript += formScript.Script;
                            break;
                    }
                }

                var scr = "onload='try{AjaxScriptPanel_IFrame.FormLoadComplated=true;}catch(e){}";
                scr += string.Format("{0}", string.IsNullOrEmpty(onloadscript) ? "'" : "AjaxScriptPanel_IFrame." + onloadscript + ";'");

                var li = new LiteralControl(string.Format("<Iframe  style='display:none'  id='AjaxScriptPanel_IFrame' {0} name='AjaxScriptPanel_IFrame' src ='" + url + "'  ></Iframe>", scr));


                ScriptIframe.Controls.Add(li);
            }
            else
            {
                QScript("setTimeout(new Function(\"SetMaskScreen(false);\"),100);");
                QScript(onloadScript);
            }
        }
        beforeScript += "return CrmValidateForm(msg,e);";

        BtnConfirm.AjaxEvents.Click.Success = "RefreshParetnGrid(true);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";
        BtnRejectReal.AjaxEvents.Click.Success = "RefreshParetnGrid(true);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";


    }
    protected override void OnPreRenderComplete(EventArgs e)
    {
        TimeSpan diffResult = DateTime.Now - _requestBeginTime;
        if (_ep.MyForm != null)
        {

            Page.ClientScript.RegisterStartupScript(typeof(string), "EditReflexName", "var EditReflexName=\"" + _ep.MyForm.Name + "\";", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "EditReflexGenerateTime", "var EditReflexGenerateTime=" + diffResult.Milliseconds + ";", true);
        }
        base.OnPreRenderComplete(e);
    }

    protected override void OnPreInit(EventArgs e)
    {
        _requestBeginTime = DateTime.Now;
        TranslateMessages();
        _ep = new EditPageConfirm(ValidationHelper.GetGuid(QueryHelper.GetString("recid")));

        PnlMain.BodyControls.Add(_ep);

        hdnDefaultEditPageId.Value = _ep.FormId.ToString();
        if (QueryHelper.GetString("mode") == "1")
        {
            if (App.Params.CurrentForms[_ep.FormId].DisableToolbar)
            {
                EditToolbar.Style.Add("top", "3px");
                Container.Style.Add("padding-top", "3px");
                Container.Style.Add("position", "releative");
            }
            else
            {
                EditToolbar.Style.Add("top", "30px");
                Container.Style.Add("padding-top", "30px");
                Container.Style.Add("position", "releative");

            }

            FirstTab.BodyControls.Add(Container);

        }
        else
        {
            if (QueryHelper.GetString("mode") == "2")
            {
                Container.Style.Add("padding-top", "30px");
                Container.Style.Add("position", "releative");
            }
            Tabpanel1.Visible = false;
        }
        if (ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("LoadingOpacity", "10")) >= 100)
        {

            Ieopacity = App.Params.GetConfigKeyValue("LoadingOpacity", "10");
            Otheropacity = "1";
        }
        else
        {
            Ieopacity = App.Params.GetConfigKeyValue("LoadingOpacity", "10");
            Otheropacity = "0." + Ieopacity;
        }
        base.OnPreInit(e);
    }

    protected void BtnConfirmClick(object sender, AjaxEventArgs e)
    {
        var starttime = DateTime.Now;

        FillSecurity();
        /*Ic Yetki Kontrolu*/
        if (!_dynamicSecurity.prvApproval)
        {
            return;
        }


        try
        {
            new ApprovalFactory(App.Params.CurrentUser.SystemUserId).SetConfirmApproval(ValidationHelper.GetGuid(QueryHelper.GetString("recid")));
            MessengerFactory.ShowMessages();

        }
        catch (CrmException ex)
        {
            var msg = new MessageBox();
            if (ex.MessageType == CrmException.EMessageTpe.Error)
            {
                msg.MessageType = EMessageType.Error;
            }
            msg.Modal = true;
            if (string.IsNullOrEmpty(ex.ErrorMessage) && ex.ErrorId > 0)
            {
                //msg.Show("", " ", string.Format(CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR), ex.ErrorId));
                QScript(string.Format("alert('{0}');", string.Format(CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR), ex.ErrorId)));
            }
            else
            {
                //msg.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE), " ", ex.ErrorMessage);
                QScript(string.Format("alert({0});", ScriptCreater.SerializeString(ex.ErrorMessage)));
            }
            return;

        }


        TimeSpan endtime = DateTime.Now - starttime;
        if (GlobalConfig.Settings.PageRenderTime)
            QScript("ShowDebugger();top.window[\"Debugger_RenderTime\"].addDebug('Saving -- ' , " + endtime.Milliseconds + ");");

    }
    protected void BtnRejectClick(object sender, AjaxEventArgs e)
    {
        var starttime = DateTime.Now;

        FillSecurity();
        /*Ic Yetki Kontrolu*/
        if (!_dynamicSecurity.prvApproval)
        {
            return;
        }


        try
        {
            new ApprovalFactory(App.Params.CurrentUser.SystemUserId).SetRejectApproval(ValidationHelper.GetGuid(QueryHelper.GetString("recid")), Comment.Value);
            MessengerFactory.ShowMessages();
        }
        catch (CrmException ex)
        {
            var msg = new MessageBox();
            if (ex.MessageType == CrmException.EMessageTpe.Error)
            {
                msg.MessageType = EMessageType.Error;
            }
            msg.Modal = true;
            if (string.IsNullOrEmpty(ex.ErrorMessage) && ex.ErrorId > 0)
            {
                msg.Show("", " ", string.Format(CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR), ex.ErrorId));
            }
            else
            {
                msg.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE), " ", ex.ErrorMessage);
            }
            //return;

        }


        TimeSpan endtime = DateTime.Now - starttime;
        if (GlobalConfig.Settings.PageRenderTime)
            QScript("ShowDebugger();top.window[\"Debugger_RenderTime\"].addDebug('Saving -- ' , " + endtime.Milliseconds + ");");

    }

    protected void BtnEditClick(object sender, AjaxEventArgs e)
    {
        var starttime = DateTime.Now;

        var Apf = new ApprovalFactory(App.Params.CurrentUser.SystemUserId);
        var dynamicEntityRecord = Apf.GetDynamicEntityFromApprovalRecord(QueryHelper.GetGuid("recid"));

        var Urllocation = new Dictionary<string, string>  {
            { "ObjectId" ,dynamicEntityRecord.ObjectId.ToString()},
            { "ApprovalRecordId" ,QueryHelper.GetString("recid")},
            { "recid" ,string.Empty},
            { "defaulteditpageid" ,string.Empty},
        };
        if (_transactionType == ApprovalRecordTransactionType.Update)
        {
            var _recid = dynamicEntityRecord
                .GetKeyValue(EntityAttributeFactory.GetAttributePkString(dynamicEntityRecord.ObjectId)).ToString();
            if (!Urllocation.ContainsKey("recid"))
            {
                Urllocation.Add("recid", _recid);
            }
            else
            {
                Urllocation["recid"] = _recid;
            }

        }

        var url = QueryHelper.AddUpdateString(this, "~/CrmPages/AutoPages/EditReflex.aspx", Urllocation);
        Response.Redirect(url);   


        TimeSpan endtime = DateTime.Now - starttime;
        if (GlobalConfig.Settings.PageRenderTime)
            QScript("ShowDebugger();top.window[\"Debugger_RenderTime\"].addDebug('Saving -- ' , " + endtime.Milliseconds + ");");


    }



    private void CreateRequestObject()
    {
        if (!RefleX.IsAjxPostback)
        {
            var active = false;

            var sb = new StringBuilder("var  Request={");
            foreach (var keys in Request.QueryString.AllKeys)
            {
                sb.AppendLine(keys + ": " + new JavaScriptSerializer().Serialize(QueryHelper.GetString(keys)));
                sb.Append(",");
                active = true;
            }
            if (active)
                sb.Remove(sb.Length - 1, 1);
            sb.Append("};");
            Page.ClientScript.RegisterStartupScript(typeof(string), "Request", sb.ToString(), true);
        }
    }
    /*Coolite Olmadan silme isleminin gitmesi gereken yer.*/

}
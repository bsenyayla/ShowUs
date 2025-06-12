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
using System.Threading;

using Coretech.Crm.Objects.Crm.Approval;

public partial class CrmPages_AutoPages_EditRefleX : BasePage
{


    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {
        [AjaxMethod]
        public DynamicFactory.OperationReturnType GlobalDelete(string order, string recordId, string objectId)
        {
            var df = new DynamicFactory(ERunInUser.CalingUser);
            return df.GlobalDelete(order, recordId, objectId);
        }
        [AjaxMethod]
        public string GetTranslateMessage(string messageName)
        {
            return CrmLabel.TranslateMessage(messageName);
        }
    }


    private DynamicSecurity _dynamicSecurity;
    private DateTime _requestBeginTime;
    public string Ieopacity = "";
    public string Otheropacity = "";
    private void TranslateMessages()
    {
        btnSave.AjaxEvents.Click.EventMask.Msg = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVING);
        btnSave.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        btnSaveAndNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE_AND_NEW);
        btnSaveAndClose.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE_AND_CLOSE);
        btnRefresh.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_EDITSCREEN_REFRESH);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        btnAction.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ACTION);
        lblError.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_YOUCANNOTUPDATE);
        btnReport.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_REPORTMENU);
        btnMlValues.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_MULTIPELANGUAGE);
        btnSaveAsCopy.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE_AS_COPY);
        btnPassive.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_PASSIVE);
        btnActive.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_ACTIVE);
        lblInfo.ToolTip = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_HELP);
    }
    void FillSecurity()
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                          (string.IsNullOrEmpty(hdnRecid.Value)
                                                               ? (Guid?)null
                                                               : ValidationHelper.GetGuid(hdnRecid.Value)));

        if (QueryHelper.GetString("mode", "") == "3")
        {
            _dynamicSecurity.PrvCreate =
                _dynamicSecurity.PrvDelete = _dynamicSecurity.PrvShare = _dynamicSecurity.PrvAppend =
                                                                         _dynamicSecurity.PrvAssign =
                                                                         _dynamicSecurity.PrvWrite =
                                                                         _dynamicSecurity.PrvAppendTo =
                                                                         _dynamicSecurity.PrvRead = _dynamicSecurity.PrvMultiLanguage = false;

        }
    }

    protected override void OnInit(EventArgs e)
    {
        var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };
        dynamicFactory.ExecPlugin(PluginMsgType.FormInit, _ep.ObjectId, ref _ep.DynamicEntity,
                                      false);
        base.OnInit(e);
        dynamicFactory.ExecPlugin(PluginMsgType.FormInit, _ep.ObjectId, ref _ep.DynamicEntity,
                                      true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            Utility.RegisterTypeForAjax(typeof(AjaxMethods));
            CreateRequestObject();
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnEntityId.Value = App.Params.CurrentEntity[QueryHelper.GetInteger("objectid")].EntityId.ToString();
            FetchXML.Value = QueryHelper.GetString("FetchXML");
            hdnApprovalRecordId.Value = QueryHelper.GetString("ApprovalRecordId");


            Page.Title =
                App.Params.CurrentEntity[ValidationHelper.GetInteger(hdnObjectId.Value, 0)].GetLabel(
                    App.Params.CurrentUser.LanguageId) + " " +
                    CrmLabel.TranslateMessage(LabelEnum.CRM_EDIT_PAGE) + " ";
            lblError.Visible = false;

            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };

            if (FetchXML.Value != string.Empty && hdnRecid.Value == "")
            {
                _ep.DataBindeFeatchXml(FetchXML.Value);
            }
            if (hdnRecid.Value != "")
            {
                _ep.RecId = ValidationHelper.GetGuid(hdnRecid.Value);
                _ep.DataBind();
                if (_ep.DynamicEntity != null)
                {

                    hdnRecidName.Value =
                        _ep.DynamicEntity.GetStringValue(
                            EntityAttributeFactory.GetAttributeValString(
                                ValidationHelper.GetInteger(hdnObjectId.Value, 0)));
                    if (hdnRecidName.Value.Length > 50)
                    {
                        hdnRecidName.Value = hdnRecidName.Value.Substring(0, 50) + "...";
                    }

                    if (!hdnRecidName.Value.StartsWith("878"))
                    {
                        Page.Title += " ... ";
                        Page.Title += hdnRecidName.Value;
                    }

                    var statuscode = _ep.DynamicEntity.GetPicklistValue("statuscode");
                    var approvalCannotUpdate = ApprovalFactory.CheckApprovalByRecordId(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                        ValidationHelper.GetGuid(hdnRecid.Value));


                    if (statuscode == 2)
                    {
                        lblError.Visible = true;
                        btnSave.Visible = false;
                        btnSaveAndNew.Visible = false;
                        btnSaveAndClose.Visible = false;
                        btnSaveAsCopy.Visible = false;
                        btnDelete.Visible = false;
                        btnPassive.Visible = false;
                        btnAction.Visible = false;

                    }
                    else
                    {
                        btnActive.Visible = false;
                    }

                    if (approvalCannotUpdate)
                    {
                        lblError.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_APPROVAL_CANNOT_UPDATE);
                        lblError.Visible = true;
                        btnSave.Visible = false;
                        btnSaveAndNew.Visible = false;
                        btnSaveAndClose.Visible = false;
                        btnSaveAsCopy.Visible = false;
                        btnDelete.Visible = false;
                        btnPassive.Visible = false;
                        btnActive.Visible = false;
                        btnAction.Visible = false;
                    }
                }
                if (_ep.Tp.Tabs.Count > 0)
                    Related.Controls.Add(_ep.Tp);
            }

            if (!string.IsNullOrEmpty(hdnApprovalRecordId.Value))
            {
                var deApproval = (new ApprovalFactory(App.Params.CurrentUser.SystemUserId)).GetDynamicEntityFromApprovalRecord(ValidationHelper.GetGuid(hdnApprovalRecordId.Value));
                _ep.DynamicEntity = deApproval;
                _ep.FillData();

                lblError.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_APPROVAL_CANNOT_UPDATE);
                lblError.Visible = false;

                btnSave.Visible = true;
                btnSaveAndNew.Visible = true;
                btnSaveAndClose.Visible = true;
                btnSaveAsCopy.Visible = true;
                btnDelete.Visible = true;
                btnPassive.Visible = true;
                btnActive.Visible = true;
                btnAction.Visible = true;

            }

            /*Data Yuklendikten sonta bir islemi kontrol edelim.*/
            dynamicFactory.ExecPlugin(PluginMsgType.FormLoad, _ep.ObjectId, ref _ep.DynamicEntity,
                                      false);

            if (App.Params.CurrentForms[_ep.FormId].LabelMessageId != Guid.Empty)
            {
                hdnTitle.Value = CrmLabel.TranslateLabelMessage(App.Params.CurrentForms[_ep.FormId].LabelMessageId) +
                    (!(hdnRecidName.Value != null && hdnRecidName.Value.StartsWith("878")) ? (" ... " + hdnRecidName.Value) : string.Empty);
            }

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
                lblError.Visible = false;
            }
            if (hdnRecid.Value == "")
            {
                foreach (EntityAttribute ea in App.Params.CurrentEntityAttribute.Values)
                {
                    if (ea.ObjectId == ValidationHelper.GetInteger(hdnObjectId.Value))
                    {
                        if (ea.SequenceKey != string.Empty)
                        {
                            var objC = ActiveScriptManager.FindControl(ea.UniqueName);

                            if (objC != null && objC.GetType() == typeof(CrmTextFieldComp))
                            {
                                ((CrmTextFieldComp)objC).Value = SequenceCreater.NewId(ea.SequenceKey);
                                ((CrmTextFieldComp)objC).ReadOnly = true;
                            }
                        }
                    }
                }
            }
            SetClientScript();


            FillSecurity();
            AddActionList();
            AddReportList();
            btnMlValues.Visible = false;
            if (EditToolbar.Visible)
            {
                if (hdnRecid.Value != "")
                {
                    if (!_dynamicSecurity.PrvWrite)
                    {
                        if (btnSave.Visible)
                            btnSave.SetDisabled(true);

                        if (btnSaveAndNew.Visible)
                            btnSaveAndNew.SetDisabled(true);

                        if (btnSaveAndClose.Visible)
                            btnSaveAndClose.SetDisabled(true);
                    }
                    else
                    {
                        if (App.Params.CurrentEntity[ValidationHelper.GetInteger(hdnObjectId.Value, 0)].IsMultipleLanguage)
                        {
                            if (_dynamicSecurity.PrvMultiLanguage && !btnMlValues.Visible)
                                btnMlValues.Visible = true;
                        }
                    }

                    if (!_dynamicSecurity.PrvDelete)
                    {
                        if (btnDelete.Visible)
                            btnDelete.SetDisabled(true);
                    }
                }
                else
                {

                    if (!_dynamicSecurity.PrvCreate)
                    {
                        if (btnSave.Visible)
                            btnSave.SetDisabled(true);

                        if (btnSaveAndNew.Visible)
                            btnSaveAndNew.SetDisabled(true);
                        if (btnSaveAndClose.Visible)
                            btnSaveAndClose.SetDisabled(true);
                    }
                    btnDelete.SetVisible(false);
                    btnActive.SetVisible(false);
                    btnPassive.SetVisible(false);
                    btnSaveAsCopy.SetVisible(false);
                }

                if (!_dynamicSecurity.PrvCreate)
                {
                    if (btnSaveAsCopy.Visible)
                        btnSaveAsCopy.SetDisabled(true);
                    if (btnSaveAndNew.Visible)
                        btnSaveAndNew.SetDisabled(true);
                }
                if (!_dynamicSecurity.PrvSetActivePassive)
                {
                    if (btnPassive.Visible)
                        btnPassive.SetVisible(false);
                    if (btnActive.Visible)
                        btnActive.SetVisible(false);
                }
            }

            foreach (var attribureId in _ep.MyForm.ColumnSetList)
            {
                if (App.Params.CurrentEntityAttribute.ContainsKey(attribureId) &&
                    App.Params.CurrentEntityAttribute[attribureId].AttributeTypeId ==
                    ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Owner)))
                {
                    var c =
                        (Component)
                        (ActiveScriptManager.FindControl(
                            App.Params.CurrentEntityAttribute[attribureId].ReferencedLookupName));
                    if (c != null)
                    {
                        if (!_dynamicSecurity.PrvAssign)
                        {
                            c.SetDisabled(true);
                        }
                    }
                }
            }

            dynamicFactory.ExecPlugin(PluginMsgType.FormLoad, _ep.ObjectId, ref _ep.DynamicEntity,
                                      true);
            var infoList = Info.GetEntityHelps(_ep.FormId, Guid.Empty, this);
            if (infoList.Count == 0)
            {
                lblInfo.Visible = false;
            }
            else
            {
                SerialiseHelp(infoList);
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
                                                  ValidationHelper.GetInteger(hdnObjectId.Value, 0), replacerEntity, _ep.FormId);
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

        btnSave.AjaxEvents.Click.Before = beforeScript;
        btnSave.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";

        btnDDSave.AjaxEvents.Click.Before = beforeScript;
        btnDDSave.AjaxEvents.Click.Success = btnSave.AjaxEvents.Click.Success;

        btnSaveAsCopy.AjaxEvents.Click.Before = beforeScript;
        btnSaveAsCopy.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){ window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";

        btnSaveAndNew.AjaxEvents.Click.Before = beforeScript;
        btnSaveAndNew.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!='' ){" + successScript + " window.location=R.htmlDecode(UpdatedUrl.getValue());}";

        btnSaveAndClose.AjaxEvents.Click.Before = beforeScript;
        btnSaveAndClose.AjaxEvents.Click.Success = "if(UpdatedUrl.getValue()!='' ){" + successScript + " RefreshParetnGrid(true);}";


        btnActive.AjaxEvents.Click.Before = beforeScript;
        btnActive.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";

        btnPassive.AjaxEvents.Click.Before = beforeScript;
        btnPassive.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";

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
        _ep = new EditPage
        {
            FormId = ValidationHelper.GetGuid(QueryHelper.GetString("defaulteditpageid")),
            ObjectId = ValidationHelper.GetInteger(QueryHelper.GetString("objectid"), 0),
            RecId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"))
        };
        PnlMain.BodyControls.Add(_ep);
        if (_ep.FormId == Guid.Empty)
            foreach (var form in App.Params.CurrentForms.Values.Where(f => f.ObjectId == _ep.ObjectId && f.IsDefaultEditForm))
            {
                _ep.FormId = form.FormId;
            }
        hdnDefaultEditPageId.Value = _ep.FormId.ToString();
        if (_ep.FormId == Guid.Empty || !App.Params.CurrentForms.ContainsKey(_ep.FormId))
        {
            try
            {
                Response.End();
            }
            catch (ThreadAbortException)
            {

            }
            catch (Exception)
            {


            }
        }



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

    protected void BtnSaveClick(object sender, AjaxEventArgs e)
    {
        var starttime = DateTime.Now;

        FillSecurity();
        /*Ic Yetki Kontrolu*/
        if (hdnRecid.Value != "")
        {
            if (!_dynamicSecurity.PrvWrite)
            {
                return;
            }
        }
        else
        {
            if (!_dynamicSecurity.PrvCreate)
            {
                return;
            }

        }
        var objectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0);
        if (e.ExtraParams["Action"] != null)
        {
            var action = ValidationHelper.GetInteger(e.ExtraParams["Action"], 0);
            var parntAction = ValidationHelper.GetInteger(e.ExtraParams["ParentAction"], 0);

            var orginalAction = action;
            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };

            DynamicEntity dynamicEntity = _ep.GetDynamicEntity();
            try
            {
                if (!string.IsNullOrEmpty(hdnApprovalRecordId.Value))
                {
                    var deApprovalRecord = new DynamicFactory(ERunInUser.SystemAdmin).Retrieve(EntityEnum.ApprovalRecord.GetHashCode(), ValidationHelper.GetGuid(hdnApprovalRecordId.Value), new[] { "ApprovalRecordId", "ConfirmStatus" }, true);
                    if ((ApprovalRecordConfirmStatus)deApprovalRecord.GetPicklistValue("ConfirmStatus") !=
                        ApprovalRecordConfirmStatus.WaitingConfirm)
                    {

                        throw new CrmException(CrmLabel.TranslateMessage("CRM.APPROVALRECORD_YOUCANTCREATEORUPDATE"));
                    }
                    else
                    {
                        /*Update islemi sonrasinda eski kayit tamamen silinecektir.*/
                        deApprovalRecord.AddPicklistProperty("ConfirmStatus", ApprovalRecordConfirmStatus.Declined.GetHashCode());
                        new DynamicFactory(ERunInUser.SystemAdmin).UpdateWithOutPlugin(EntityEnum.ApprovalRecord.GetHashCode(),
                            deApprovalRecord,
                             false);

                    }

                }
                ExecClientWf(FormScriptType.BeforeSave, dynamicEntity);

                var oldrecId = ValidationHelper.GetGuid(hdnRecid.Value);
                if (action == 4)
                {
                    hdnRecid.Value = string.Empty;
                    dynamicEntity.AddKeyProperty(EntityAttributeFactory.GetAttributePkString(objectId), GuidHelper.Newfoid(objectId));
                    action = 1;
                    /*Seqkey lerin Nullanmasi*/
                    foreach (var entityAttribute in
                        App.Params.CurrentEntityAttribute.Values.Where(entityAttribute => !string.IsNullOrEmpty(entityAttribute.SequenceKey)).Where(entityAttribute => entityAttribute.ObjectId == objectId))
                    {
                        if (dynamicEntity.Properties.Contains(entityAttribute.Name))
                        {
                            dynamicEntity.Properties.Remove(entityAttribute.Name);
                        }
                    }
                }
                var ddf = new DuplicateDetectionFactory();
                Guid duplicateDetectionResultId;
                Guid duplicateDetectionRuleId;
                Guid firstDeleatedRecordId;
                var ddfRet = ddf.CheckDuplicateDedection(dynamicEntity, out duplicateDetectionResultId, out duplicateDetectionRuleId, out firstDeleatedRecordId);

                if (ddfRet && action <= 4)
                {
                    if (duplicateDetectionRuleId != Guid.Empty)
                    {
                        var dd = App.Params.CurrentDuplicateDetections[duplicateDetectionRuleId];
                        if (dd.CheckDeletedRecords && dd.AutoActiveDeletedRecord && firstDeleatedRecordId != Guid.Empty)
                        {
                            if (hdnRecid.Value == string.Empty)
                            {
                                dynamicEntity.AddKeyProperty(EntityAttributeFactory.GetAttributePkString(objectId), firstDeleatedRecordId);
                                dynamicEntity.AddNumberProperty("DeletionStateCode", 0);
                                hdnRecid.Value = firstDeleatedRecordId.ToString();
                            }

                        }
                        else
                        {
                            QScript("UpdatedUrl.setValue('');");
                            QScript(string.Format("ShowDDwindow('{0}','{1}','{2}');", duplicateDetectionRuleId, duplicateDetectionResultId, orginalAction));
                            return;
                        }
                    }
                }
                if (action == 5 || action == 6)
                {
                    dynamicEntity.AddNumberProperty("DeletionStateCode", 0);
                    action = parntAction;
                }



                if (hdnRecid.Value != string.Empty)
                {
                    dynamicEntity.AddKeyProperty(EntityAttributeFactory.GetAttributePkString(objectId), ValidationHelper.GetGuid(hdnRecid.Value));

                    OnBeforeSaveEvent(ValidationHelper.GetGuid(hdnRecid.Value), dynamicFactory, dynamicEntity, true);
                    dynamicFactory.Update(objectId, dynamicEntity);
                    OnAfterSaveEvent(ValidationHelper.GetGuid(hdnRecid.Value), dynamicFactory, dynamicEntity, true);
                }
                else
                {
                    OnBeforeSaveEvent(Guid.Empty, dynamicFactory, dynamicEntity, false);
                    var gdNew = dynamicFactory.Create(objectId, dynamicEntity, orginalAction);
                    if (gdNew == Guid.Empty)
                    {
                        /*Ekranı kapat.*/
                        QScript("RefreshParetnGrid(true);");
                    }
                    OnAfterSaveEvent(gdNew, dynamicFactory, dynamicEntity, false);
                    if (orginalAction == 4 && objectId == (int)EntityEnum.Role)
                    {
                        /*Role Detay Kopyalma*/

                        var sdData = new StaticData();
                        sdData.AddParameter("FromRoleId", DbType.Guid, oldrecId);
                        sdData.AddParameter("ToRoleId", DbType.Guid, gdNew);
                        sdData.ExecuteNonQuery("EXEC spCopyRole @FromRoleId,@ToRoleId");
                        /*Role Detay Kopyalama*/
                    }
                    hdnRecid.Value = gdNew.ToString();
                    hdnRecid.SetValue(gdNew.ToString());

                }

            }
            catch (CrmException ex)
            {
                var msg = new MessageBox();
                if (ex.MessageType == CrmException.EMessageTpe.Error)
                    msg.MessageType = EMessageType.Error;
                msg.Modal = true;
                if (string.IsNullOrEmpty(ex.ErrorMessage) && ex.ErrorId > 0)
                    msg.Show("", " ", string.Format(CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR), ex.ErrorId));
                else
                    msg.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE), " ", ex.ErrorMessage);
                //Chrome tabanlı tarayıcılarda açılan windowda metin ve butonlar gözükmediği için eklendi.
                BasePage.QScript(@"setTimeout(function() { var activeWindow = window.top.R.WindowMng.getActiveWindow().src.querySelector('.x-window-body'); activeWindow.classList.remove('x-window-body'); 
                                                            setTimeout(function() { activeWindow.classList.add('x-window-body'); })}, 500);");
                return;
            }


            var query = new Dictionary<string, string>();
            var workFlowFactory = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
            QScript(workFlowFactory.returnQscripts(dynamicFactory.GlobalWorkflowResults, _ep.FormId));

            /*Ha. Html Encode & parametreleri yarattiği için devre disi birakildi. */
            string url;

            switch (action)
            {
                case 1:
                case 4:
                    query.Add("recid", hdnRecid.Value);
                    url = QueryHelper.AddUpdateString(query);
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(url)));
                    break;
                case 2:
                case 3:
                    query.Add("recid", "");
                    url = QueryHelper.AddUpdateString(query);
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(url)));
                    break;
            }

            try
            {
                ExecClientWf(FormScriptType.AfterSave, dynamicEntity);
            }
            catch (CrmException ex)
            {
                var msg = new MessageBox();
                if (ex.MessageType == CrmException.EMessageTpe.Error)
                    msg.MessageType = EMessageType.Error;
                msg.Modal = true;
                if (string.IsNullOrEmpty(ex.ErrorMessage) && ex.ErrorId > 0)
                    msg.Show("", " ", string.Format(CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR), ex.ErrorId));
                else
                    msg.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE), " ", ex.ErrorMessage);
                return;

            }


        }
        TimeSpan endtime = DateTime.Now - starttime;
        if (GlobalConfig.Settings.PageRenderTime)
            QScript("ShowDebugger();top.window[\"Debugger_RenderTime\"].addDebug('Saving -- ' , " + endtime.Milliseconds + ");");

    }

    private void StatusChange(int statuscode)
    {
        if (hdnRecid.Value != string.Empty)
        {
            DynamicEntity dynamicEntity = _ep.GetDynamicEntity();
            dynamicEntity.AddPicklistProperty("statuscode", statuscode);
            var objectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0);


            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);
            dynamicFactory.SetStatus(objectId, dynamicEntity);
            var query = new Dictionary<string, string> { { "recid", hdnRecid.Value } };
            var url = QueryHelper.AddUpdateString(query);
            QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(url)));
        }

    }

    protected void BtnActiveClick(object sender, AjaxEventArgs e)
    {
        StatusChange(1);
    }
    protected void BtnPassiveClick(object sender, AjaxEventArgs e)
    {
        StatusChange(2);
    }


    void ExecClientWf(FormScriptType scriptType, DynamicEntity dynamicEntity)
    {
        var wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId) { ReplacerEntity = dynamicEntity };
        foreach (var formScript in _ep.MyForm.FormScript.FormScripts.Where(ea => ea.Type == scriptType))
        {
            if (formScript.Type == FormScriptType.AfterSave && formScript.ClientWorkflowId != Guid.Empty)
            {
                var script = wf.ExecAndAddQscripts(formScript.ClientWorkflowId,
                                                   ValidationHelper.GetInteger(hdnObjectId.Value, 0), dynamicEntity, _ep.FormId);
                QScript(script);
                return;
            }
            if (formScript.Type == FormScriptType.BeforeSave && formScript.ClientWorkflowId != Guid.Empty)
            {
                var script = wf.ExecAndAddQscripts(formScript.ClientWorkflowId,
                                                   ValidationHelper.GetInteger(hdnObjectId.Value, 0), dynamicEntity, _ep.FormId);

                QScript(script);
            }
        }
    }
    void AddActionList()
    {
        var ff = new FormFactory();
        var myActionlist = ff.GetFormActionList(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                             (string.IsNullOrEmpty(hdnRecid.Value)
                                  ? Guid.Empty
                                  : ValidationHelper.GetGuid(hdnRecid.Value))
            );
        foreach (var action in myActionlist)
        {
            var mi = new MenuItem(action.Label);
            mi.Listeners.Click.Handler = action.ActionScript;
            mi.ID = action.ActionId.ToString().Replace("-", "_");
            ActionMenu.Items.Add(mi);
        }
        if (myActionlist.Count == 0)
            btnAction.Visible = false;
    }
    void AddReportList()
    {
        var rf = new ReportsFactory();
        var rl = rf.GetReportListForForm(ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        foreach (var report in rl)
        {
            if (hdnRecid.Value != string.Empty)
            {

                var mi = new MenuItem(report.ReportName);
                mi.Listeners.Click.Handler = "ShowReport('" + report.ReportsId + "','" + hdnRecid.Value + "')";
                mi.ID = report.ReportsId.ToString().Replace("-", "_");
                ReportMenu.Items.Add(mi);
            }

        }
        if (ReportMenu.Items.Count == 0)
            btnReport.Visible = false;
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


    [RefleXFrameWork.AjaxMethods]
    public string GetDynamicUrl(string dynamicUrlId)
    {
        var de = _ep.GetDynamicEntity();
        var duf = new DynamicUrlFactory(App.Params.CurrentUser.SystemUserId) { ReplacerEntity = de };
        var strUrl = duf.GetUrl(ValidationHelper.GetGuid(dynamicUrlId), ValidationHelper.GetInteger(hdnObjectId.Value, 0), ValidationHelper.GetGuid(hdnRecid.Value));
        if (strUrl != string.Empty)
        {
            var strnewUrl = strUrl.Substring(0, 1) == "~"
                                                           ? HTTPUtil.GetWebAppRoot() + strUrl.Substring(1)
                                                          : strUrl;
            return strnewUrl;
        }
        return "";
    }


}
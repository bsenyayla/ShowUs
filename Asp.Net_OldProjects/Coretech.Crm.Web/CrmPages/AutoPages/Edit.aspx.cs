using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Form;
using Coretech.Crm.Factory.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Attributes;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Form;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
//using Coretech.Crm.Web.UI.AjaxCT.AutoGenerate;
using Coretech.Crm.Web.UI.AutoGenerate;
//using Coretech.Crm.Web.UI.AutoGenerate;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class CrmPages_AutoPages_Edit : BasePage
{
    private EditPage _ep = new EditPage();
    private DynamicSecurity _dynamicSecurity;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !Ext.IsAjaxRequest)
        {

            //QScript("var Inputelements = document.getElementsByTagName('INPUT'); for(i=0;i<Inputelements.length;i++){if(Inputelements[i].disabled==true){Inputelements[i].disabled='';Inputelements[i].readonly=true;}};");
            translateMessages();
            hdnDefaultEditPageId.Text = QueryHelper.GetString("defaulteditpageid");
            hdnRecid.Text = QueryHelper.GetString("recid");
            hdnObjectId.Text = QueryHelper.GetString("objectid");
            hdnEntityId.Text = App.Params.CurrentEntity[QueryHelper.GetInteger("objectid")].EntityId.ToString();
            FetchXML.Text = QueryHelper.GetString("FetchXML");

            _ep.FormId = ValidationHelper.GetGuid(hdnDefaultEditPageId.Text);

            Page.Title =
                App.Params.CurrentEntity[ValidationHelper.GetInteger(hdnObjectId.Value, 0)].GetLabel(
                    App.Params.CurrentUser.LanguageId) + " " +
                    CrmLabel.TranslateMessage(LabelEnum.CRM_EDIT_PAGE) + " ";

            if (FetchXML.Text != string.Empty && hdnRecid.Text == "")
            {
                _ep.DataBindeFeatchXml(FetchXML.Text);
            }

            //Logviewer.Disabled = string.IsNullOrEmpty(hdnRecid.Text) ? true : false;

            if (hdnRecid.Text != "")
            {
                _ep.RecId = ValidationHelper.GetGuid(hdnRecid.Text);
                _ep.DataBind();
                if (_ep.DynamicEntity != null)
                {
                    Page.Title += " ... ";
                    hdnRecidName.Value =
                         _ep.DynamicEntity.GetStringValue(
                                       EntityAttributeFactory.GetAttributeValString(
                                           ValidationHelper.GetInteger(hdnObjectId.Text, 0)));
                    Page.Title += hdnRecidName.Value;
                    QScript("top.Ext.WindowMgr.getActive().setTitle(window.document.title);");
                }
                BlMain.South.Items.Add(_ep.Tp);

            }
            if (_ep.MyForm.DisableToolbar)
                EditToolbar.Visible = false;
            if (hdnRecid.Text == "")
            {
                foreach (EntityAttribute ea in App.Params.CurrentEntityAttribute.Values)
                {
                    if (ea.ObjectId == ValidationHelper.GetInteger(hdnObjectId.Text))
                    {
                        if (ea.SequenceKey != string.Empty)
                        {
                            var objC = ActiveScriptManager.FindControl(ea.UniqueName);

                            if (objC != null && objC.GetType() == typeof(CrmTextFieldComp))
                            {
                                ((CrmTextFieldComp)objC).Text = SequenceCreater.NewId(ea.SequenceKey);
                                ((CrmTextFieldComp)objC).ReadOnly = true;
                            }
                        }
                    }
                }
            }
            SetClientScript();

        }
        _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                     (string.IsNullOrEmpty(hdnRecid.Text)
                                                          ? (Guid?)null
                                                          : ValidationHelper.GetGuid(hdnRecid.Text)));
        AddActionList();
        if (hdnRecid.Text != "") /*PrvWrite*/
        {
            if (!_dynamicSecurity.PrvWrite)
            {
                btnSave.Disabled = true;
                btnSaveAndNew.Disabled = true;
                btnSaveAndClose.Disabled = true;
            }
            if (!_dynamicSecurity.PrvDelete)
            {
                btnDelete.Disabled = true;
            }
        }
        else /*Create*/
        {
            if (!_dynamicSecurity.PrvCreate)
            {
                btnSave.Disabled = true;
                btnSaveAndNew.Disabled = true;
                btnSaveAndClose.Disabled = true;
            }
            btnDelete.Disabled = true;
        }
        foreach (var attribureId in _ep.MyForm.ColumnSetList)
        {
            if (App.Params.CurrentEntityAttribute.ContainsKey(attribureId) && App.Params.CurrentEntityAttribute[attribureId].AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Owner)))
            {
                var c = (Component)(ActiveScriptManager.FindControl(App.Params.CurrentEntityAttribute[attribureId].ReferencedLookupName));
                if (c != null)
                {
                    if (!_dynamicSecurity.PrvAssign)
                    {
                        c.Disabled = true;
                    }
                }
            }
        }

    }
    void AddActionList()
    {
        var ff = new FormFactory();
        var myActionlist = ff.GetFormActionList(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                             (string.IsNullOrEmpty(hdnRecid.Text)
                                  ? Guid.Empty
                                  : ValidationHelper.GetGuid(hdnRecid.Text))
            );
        foreach (var action in myActionlist)
        {
            var mi = new MenuItem(action.Label);
            mi.Listeners.Click.Handler = action.ActionScript;
            mi.ID = action.ActionId.ToString().Replace("-", "_");
            ActionMenu.Items.Add(mi);
        }

    }

    private void SetClientScript()
    {
        //ActiveScriptManager.RegisterOnReadyScript("top.Ext.WindowMgr.getActive().body.mask('Yükleniyor', 'loading-mask');");
        var beforeScript = "CheckListName();";
        var successScript = "RefreshParetnGrid();";
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
                WorkFlowFactory wf;
                switch (formScript.Type)
                {
                    case FormScriptType.Onload:

                        if (formScript.ClientWorkflowId != Guid.Empty)
                        {
                            wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
                            var script = wf.ExecAndAddQscripts(formScript.ClientWorkflowId,
                                                  ValidationHelper.GetInteger(hdnObjectId.Value, 0), _ep.DynamicEntity, _ep.FormId);
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
                var li = new LiteralControl("<Iframe style='display:none' id='AjaxScriptPanel_IFrame' name='AjaxScriptPanel_IFrame' src ='" + url + "'  >");
                var scr = "try{AjaxScriptPanel_IFrame.FormLoadComplated=true;}catch(e){}";
                scr += string.Format("{0}", string.IsNullOrEmpty(onloadscript) ? "" : "AjaxScriptPanel_IFrame." + onloadscript + ";");
                ActiveScriptManager.RegisterOnReadyScript(scr);

                Controls.Add(li);
            }
            else
            {
                ActiveScriptManager.RegisterOnReadyScript(@"SetMaskScreen(false);");
                ActiveScriptManager.RegisterOnReadyScript(onloadScript);
            }

        }

        beforeScript += "CrmValidateForm();";

        btnSave.AjaxEvents.Click.Before = beforeScript;
        btnSave.AjaxEvents.Click.Success = successScript + "navigate(UpdatedUrl.getValue());";

        btnSaveAndNew.AjaxEvents.Click.Before = beforeScript;
        btnSaveAndNew.AjaxEvents.Click.Success = successScript + "navigate(UpdatedUrl.getValue());";

        btnSaveAndClose.AjaxEvents.Click.Before = beforeScript;
        btnSaveAndClose.AjaxEvents.Click.Success = successScript + "top.Ext.WindowMgr.getActive().close();";


    }
    protected override void OnPreInit(EventArgs e)
    {
        _ep = new EditPage
        {
            FormId = ValidationHelper.GetGuid(QueryHelper.GetString("defaulteditpageid")),
            ObjectId = ValidationHelper.GetInteger(QueryHelper.GetString("objectid"), 0),
            RecId = ValidationHelper.GetGuid(QueryHelper.GetString("recid"))
        };


        PnlMain.BodyControls.Add(_ep);


        base.OnPreInit(e);
    }
    protected override void OnInit(EventArgs e)
    {

        base.OnInit(e);

        //form1.Controls.Add(_ep);
    }

    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        if (e.ExtraParams["Action"] != null)
        {
            var action = ValidationHelper.GetInteger(e.ExtraParams["Action"], 0);
            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);
            dynamicFactory.ActivePage = this;
            var dynamicEntity = _ep.GetDynamicEntity();
            if (hdnRecid.Text != string.Empty)
            {
                dynamicFactory.Update(ValidationHelper.GetInteger(hdnObjectId.Text, 0), dynamicEntity);


            }
            else
            {
                var gdNew = dynamicFactory.Create(ValidationHelper.GetInteger(hdnObjectId.Text, 0), dynamicEntity);
                hdnRecid.Text = gdNew.ToString();


            }
            var query = new Dictionary<string, string>();
            var workFlowFactory = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
            QScript(workFlowFactory.returnQscripts(dynamicFactory.GlobalWorkflowResults, _ep.FormId));

            switch (action)
            {
                case 1:
                    query.Add("recid", hdnRecid.Text);
                    UpdatedUrl.Value = QueryHelper.AddUpdateString(query);
                    break;
                case 2:
                    query.Add("recid", "");
                    UpdatedUrl.Value = QueryHelper.AddUpdateString(query);
                    break;
                case 3:
                    query.Add("recid", "");
                    UpdatedUrl.Value = QueryHelper.AddUpdateString(query);
                    break;
            }
        }

        //Ext.Msg.Alert("AjaxEvent", string.Format("Item - {0}", e.ExtraParams["Item"])).Show();
    }
    void translateMessages()
    {
        btnSave.AjaxEvents.Click.EventMask.Msg = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVING);
        btnSave.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        btnSaveAndNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE_AND_NEW);
        btnSaveAndClose.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE_AND_CLOSE);
        btnAction.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ACTION);
        btnRefresh.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_EDITSCREEN_REFRESH);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);


    }
}
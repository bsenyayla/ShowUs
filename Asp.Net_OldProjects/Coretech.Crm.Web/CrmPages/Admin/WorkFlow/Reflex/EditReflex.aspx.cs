using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Serialization;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.DuplicateDetection;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Template;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Attributes;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using Newtonsoft.Json;
using RefleXFrameWork;
using Coretech.Crm.Factory.Crm;
using Picklist = Coretech.Crm.Objects.Crm.Attributes.Picklist;
using Coretech.Crm.Provider;
using System.Threading;

public partial class CrmPages_Admin_WorkFlow_Reflex_EditReflex : AdminPage
{
    private DynamicSecurity _dynamicSecurity;
    void FillSecurity()
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(EntityEnum.Workflow.GetHashCode(), 0),
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
    enum treedataType : int
    {
        text = 0, id = 1, objectid = 2, objectId = 3, leftjoin = 4, type = 5, attributeid = 6, entityobjectid = 7, conditionvalue = 8, clausevalue = 9, clausetext = 10, conditiontype = 11, clausevalue2 = 12
    }
    enum WitemDataType : int
    {
        text = 0, id = 1, Type = 2, ClauseValue = 3, ClauseText = 4, data = 5, DynamicUrlId, IsStopWorkflow, PluginMessageId, RedirectFormId, WorkflowId
    }

    enum FilterEntityType : int { And, Or, Attribute, Entity }
    enum valueConditiontype : int
    {
        IsTextField = 0,
        IsLookupField = 1,
        IsNumericField = 2,
        IsDecimalField = 3,
        IsDateField = 4,
        IsPicklistField = 5
    }
    enum formobjecttype { attribute, iframe, button }

    private  WorkFlowFactory _wff ;
    private DynamicFactory _df ;
    private EditPageMode _pageMode;
    private WorkFlow _wf = new WorkFlow();
    public CrmPages_Admin_WorkFlow_Reflex_EditReflex()
    {
        base.ObjectId = EntityEnum.Workflow.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Workflow PrvCreate,PrvDelete,PrvWrite");
        }
        hdnRecid.Value = QueryHelper.GetString("recid");
        _pageMode = hdnRecid.Value != string.Empty ? EditPageMode.EditUpdate : EditPageMode.New;

        if (!RefleX.IsAjxPostback)
        {
            AddDynamicValueRoot();
            AddValueSelectorTreeGridRoot();
            this.RR.RegisterIcon(Icon.Application);
            this.RR.RegisterIcon(Icon.FolderHome);
            this.RR.RegisterIcon(Icon.BulletOrange);
            this.RR.RegisterIcon(Icon.ArrowJoin);
            this.RR.RegisterIcon(Icon.ArrowSwitch);
            this.RR.RegisterIcon(Icon.ArrowRotateAnticlockwise);
            this.RR.RegisterIcon(Icon.Time);
            this.RR.RegisterIcon(Icon.ApplicationAdd);
            this.RR.RegisterIcon(Icon.ApplicationEdit);
            this.RR.RegisterIcon(Icon.LinkEdit);
            this.RR.RegisterIcon(Icon.CommentAdd);
            this.RR.RegisterIcon(Icon.ScriptGear);
            this.RR.RegisterIcon(Icon.Stop);
            this.RR.RegisterIcon(Icon.Reload);
            this.RR.RegisterIcon(Icon.Plugin);
            this.RR.RegisterIcon(Icon.ChartOrganisation);

            if (_pageMode == EditPageMode.New)
            {
                DisableOnCreate(_pageMode);
                AddWItemsRoot();
            }
            else
            {
                DisableOnCreate(_pageMode);
                SetEntityValue();
            }
            BatchScriptFormLoad();
            UpdateRecordAttributeLoad();
            CreateRecordAttributeLoad();
            DynamicUrlLoad();
            RedirectFormLoad();
            PluginMessageLoad();
            WorkflowLoad();
            var beforeScript = string.Empty;
            var successScript = string.Empty;
            beforeScript += "ValidateBeforeForm(msg,e); ";
            beforeScript += "WItems.allNodesPost = true;";

            btnSave.AjaxEvents.Click.Before = beforeScript;
            btnSave.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";

            btnDDSave.AjaxEvents.Click.Before = beforeScript;
            btnDDSave.AjaxEvents.Click.Success = btnSave.AjaxEvents.Click.Success;

            btnSaveAsCopy.AjaxEvents.Click.Before = beforeScript;
            btnSaveAsCopy.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){ window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";

            btnSaveAndNew.AjaxEvents.Click.Before = beforeScript;
            btnSaveAndNew.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!='' ){" + successScript + "window.location=R.htmlDecode(UpdatedUrl.getValue());}";

            btnSaveAndClose.AjaxEvents.Click.Before = beforeScript;
            btnSaveAndClose.AjaxEvents.Click.Success = "if(UpdatedUrl.getValue()!='' ){" + successScript + " RefreshParetnGrid(true);}";

        }
        FillSecurity();
    }
    private void SetEntityValue()
    {
        _wff=new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
        _df=new DynamicFactory(ERunInUser.SystemAdmin);
        var de = _df.Retrieve(EntityEnum.Workflow.GetHashCode(), ValidationHelper.GetGuid(hdnRecid.Value), DynamicFactory.RetrieveAllColumns);
        if (de != null)
        {
            StartCreate.FillDynamicEntityData(de);
            StartDelete.FillDynamicEntityData(de);
            StartChange.FillDynamicEntityData(de);
            WorkflowName.FillDynamicEntityData(de);
            IsOnDemandWorkflow.FillDynamicEntityData(de);
            RunInUser.FillDynamicEntityData(de);
            IsClientWorkflow.FillDynamicEntityData(de);
            EntityCrmLookupComp.FillDynamicEntityData(de);

            _wf = _wff.FillWorkFlow(de);

            var des = WorkFlow.XmlDeSerializeSteps(_wf.Rules);
            if (des.Id != Guid.Empty)
            {
                WItems.Root.Nodes.Add(WitemsAddNodes(des));
            }
            else
            {
                AddWItemsRoot();
            }

            //if (!_wf.StartChange)
            //    btnChangeItems.Hidden = true;

            foreach (Entity entity in App.Params.CurrentEntity.Values)
            {
                if (entity.EntityId == _wf.Entity)
                    hdnObjectId.Value = entity.ObjectId.ToString();
            }
            ChangedColumnsLoad(_wf);
            //FillStoreGrdChangeAttribute();
            //var objectId = ValidationHelper.GetInteger(hdnObjectId.Text, 0);
            //foreach (var value in App.Params.CurrentDynamicUrl.Values.Where(value => value.ObjectId == objectId))
            //{
            //    cmbDynamicUrl.Items.Add(new ListItem(value.Name, value.DynamicUrlId.ToString()));
            //}
            //foreach (var value in App.Params.CurrentForms.Values.Where(value => value.ObjectId == objectId))
            //{
            //    cmbRedirectForm.Items.Add(new ListItem(value.Name, value.FormId.ToString()));
            //}

            //foreach (var cpm in App.Params.CurrentPluginMessages.Where(pm => pm.ObjectId == objectId))
            //{
            //    cmbcallPlugin.Items.Add(new ListItem(cpm.ClassName, cpm.PluginMessageId.ToString()));
            //}


        }
    }
    void ChangedColumnsLoad(Coretech.Crm.Objects.Crm.WorkFlow.WorkFlow ws)
    {


        var lang = App.Params.CurrentUser.LanguageId;
        var list = new List<object>();
        var selected = new List<int>();
        var i = 0;
        foreach (var o in App.Params.CurrentEntityAttribute.Values.Where(
            value => value.ObjectId == ValidationHelper.GetInteger(hdnObjectId.Value)
                && value.AttributeOf == Guid.Empty).OrderBy(t => t.GetLabelWithUniqueName(lang)))
        {
            var row = new { Label = o.GetLabelWithUniqueName(lang), o.AttributeId };
            list.Add(row);
            foreach (var guid in ws.ChangeColumn)
            {
                if (row.AttributeId == guid)
                    selected.Add(i);
            }
            i++;
        }

        GridChangedColumns.DataSource = list;
        GridChangedColumns.DataBind();
        foreach (var i1 in selected)
        {
            GridChangedColumns.SetSelectedRowsIndex(i1);
        }

    }
    TreeNode WitemsAddNodes(WorkflowStep workflowStep)
    {

        var tnMain = new TreeNode
        {
            Expanded = true,
            Icon = Icon.Folder,
            Leaf = true,
            CustomAttributes = new List<ConfigItem>
                                               {
                        new ConfigItem("text",workflowStep.Text ,EpMode.Value),
                        new ConfigItem("id",workflowStep.Id.ToString(),EpMode.Value),
                        new ConfigItem("Type",workflowStep.Type.GetHashCode().ToString(),EpMode.Value),
                        new ConfigItem("ClauseValue",workflowStep.ClauseValue,EpMode.Value),
                        new ConfigItem("ClauseText",workflowStep.ClauseText,EpMode.Value),
                        //new ConfigItem("DynamicUrlId"       ,workflowStep.DynamicUrlId.ToString(),EpMode.Value),
                        //new ConfigItem("IsStopWorkflow"     ,workflowStep.IsStopWorkflow.ToString(),EpMode.Value),
                        //new ConfigItem("PluginMessageId"    ,workflowStep.PluginMessageId.ToString(),EpMode.Value),
                        //new ConfigItem("RedirectFormId"     ,workflowStep.RedirectFormId.ToString(),EpMode.Value),
                                               }
        };
        string data = string.Empty;

        switch (workflowStep.Type)
        {
            case WorkflowStepType.Root:
                tnMain.Icon = Icon.Folder;
                tnMain.Leaf = false;

                break;
            case WorkflowStepType.IfCondition:
                tnMain.Icon = Icon.ArrowRotateAnticlockwise;
                data = SerializeObject(workflowStep.FilterEntity);
                tnMain.Leaf = false;
                break;
            case WorkflowStepType.WaitCondition:
                tnMain.Icon = Icon.Time;
                data = SerializeObject(workflowStep.FilterEntity);
                tnMain.Leaf = false;
                break;

            case WorkflowStepType.Create:
                tnMain.Icon = Icon.ApplicationAdd;
                data = SerializeObject(workflowStep.AddUpdateEntity);

                break;
            case WorkflowStepType.Update:
                tnMain.Icon = Icon.ApplicationEdit;
                data = SerializeObject(workflowStep.AddUpdateEntity);

                break;
            case WorkflowStepType.ShowMessage:
                data = SerializeObject(workflowStep.WfCallBackMessage);
                tnMain.Icon = Icon.CommentAdd;

                break;
            case WorkflowStepType.BatchScript:
                tnMain.Icon = Icon.ScriptGear;
                ReconfigureBatchScript(workflowStep.WfBatchScript);
                data = SerializeObject(workflowStep.WfBatchScript);

                break;

            case WorkflowStepType.DynamicUrl:
                data = SerializeObject(workflowStep);
                tnMain.Icon = Icon.LinkEdit;

                break;
            case WorkflowStepType.StopWorkFlow:
                data = SerializeObject(workflowStep);
                tnMain.Icon = Icon.Stop;

                break;
            case WorkflowStepType.RedirectForm:
                data = SerializeObject(workflowStep);
                tnMain.Icon = Icon.Reload;
                break;
            case WorkflowStepType.Plugin:
                data = SerializeObject(workflowStep);
                tnMain.Icon = Icon.Plugin;
                break;
            case WorkflowStepType.Workflow:
                data = SerializeObject(workflowStep);
                tnMain.Icon = Icon.ChartOrganisation;
                break;

            default:
                break;

        }
        tnMain.CustomAttributes.Add(new ConfigItem("data", data, EpMode.Value));

        foreach (WorkflowStep Vs in workflowStep.WorkflowSteps)
        {
            tnMain.Nodes.Add(WitemsAddNodes(Vs));
        }
        return tnMain;
    }

    public string SerializeObject(object o)
    {
        var mySerializer = new XmlSerializer(o.GetType());
        TextWriter tw = new StringWriter();
        mySerializer.Serialize(tw, o);
        return tw.ToString();
    }
    private void DisableOnCreate(EditPageMode mode)
    {
        if (mode == EditPageMode.New)
        {
            BtnDetailAction.Visible = false;

            //WItems.Visible = false; 
        }
        else
        {
            EntityCrmLookupComp.Disabled = true;
        }

    }
    private void AddWItemsRoot()
    {
        var id = Guid.NewGuid().ToString();

        var t = new TreeNode
        {
            Expanded = true,
            Leaf = false,
            Icon = Icon.Folder,
            CustomAttributes = new List<ConfigItem>
                                               {
                                                   new ConfigItem("text",EntityCrmLookupComp.Text,EpMode.Value),
                                                   new ConfigItem("id",id,EpMode.Value),
                                                   
                        new ConfigItem("Type",ValidationHelper.GetInteger(WorkflowStepType.Root, 0).ToString(),EpMode.Value),
                        new ConfigItem("ClauseValue","",EpMode.Value),
                        new ConfigItem("ClauseText","",EpMode.Value),
                        new ConfigItem("data","",EpMode.Value)

                                                       
                                               }
        };


        WItems.Root.Nodes.Add(t);
    }
    protected void BtnSaveClick(object sender, AjaxEventArgs e)
    {
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
        var objectId = EntityEnum.Workflow.GetHashCode();
        if (e.ExtraParams["Action"] != null)
        {
            var action = ValidationHelper.GetInteger(e.ExtraParams["Action"], 0);
            var parntAction = ValidationHelper.GetInteger(e.ExtraParams["ParentAction"], 0);

            var orginalAction = action;
            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);

            DynamicEntity dynamicEntity = GetDynamicEntity();
            var oldrecId = ValidationHelper.GetGuid(hdnRecid.Value);
            //if(hdnRecid.Value==string.Empty)
            //{
            //    hdnRecid.Value =
            //        EntityFactory.GetEntityFromEntityId(ValidationHelper.GetGuid(EntityCrmLookupComp.Value)).ObjectId.
            //            ToString();

            //}

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
            //if (!ret)
            //    return;
            try
            {
                if (hdnRecid.Value != string.Empty)
                {
                    dynamicEntity.AddKeyProperty(EntityAttributeFactory.GetAttributePkString(objectId), ValidationHelper.GetGuid(hdnRecid.Value));
                    dynamicFactory.UpdateWithOutPlugin(objectId, dynamicEntity);
                }
                else
                {
                    var gdNew = dynamicFactory.CreateWithOutPlugin(objectId, dynamicEntity);

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
                    msg.Show("", " ", string.Format(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR), ex.ErrorId));
                else
                    msg.Show(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE), " ", ex.ErrorMessage);
                return;

            }


            var query = new Dictionary<string, string>();

            switch (action)
            {
                case 1:
                    query.Add("recid", hdnRecid.Value);
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(QueryHelper.AddUpdateString(query))));
                    break;
                case 2:
                    query.Add("recid", "");
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(QueryHelper.AddUpdateString(query))));
                    break;
                case 3:
                    query.Add("recid", "");
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(QueryHelper.AddUpdateString(query))));
                    break;
                case 4:
                    query.Add("recid", hdnRecid.Value);
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(QueryHelper.AddUpdateString(query))));
                    break;
            }

        }



    }
    protected void btnPublishClickOnEvent(object sender, AjaxEventArgs e)
    {
        CrmApplication.LoadApplicationData();
        new MessageBox("Publish Completed");
    }
    DynamicEntity GetDynamicEntity()
    {
        Guid gdWorkflow = GuidHelper.Newfoid((int)EntityEnum.Workflow);
        var dynamicEntity = new DynamicEntity((int)EntityEnum.Workflow);

        if (_pageMode == EditPageMode.New)
        {



            dynamicEntity.AddKeyProperty("WorkflowId", gdWorkflow);
            dynamicEntity.AddLookupProperty("Entity", "Entity", ValidationHelper.GetGuid(EntityCrmLookupComp.Value));
            dynamicEntity.AddStringProperty("workflowname", WorkflowName.Value.ToString());

            // var id = _df.CreateWithOutPlugin((int)EntityEnum.Workflow, dynamicEntity);

        }
        else if (_pageMode == EditPageMode.EditUpdate)
        {
            _wf.ChangeColumn = new List<Guid>();
            _wf.StartCreate = ValidationHelper.GetBoolean(StartCreate.Value);
            _wf.StartDelete = ValidationHelper.GetBoolean(StartDelete.Value);
            _wf.StartChange = ValidationHelper.GetBoolean(StartChange.Value);

            _wf.IsClientWorkflow = ValidationHelper.GetBoolean(IsClientWorkflow.Value);
            _wf.IsOnDemandWorkflow = ValidationHelper.GetBoolean(IsOnDemandWorkflow.Value);
            _wf.RunInUser = ValidationHelper.GetInteger(RunInUser.Value, 0);

            if (_wf.StartChange)
            {
                var sm = GridChangedColumns.SelectionModel[0] as CheckSelectionModel;
                if (sm != null)
                    foreach (var row in sm.SelectedRows)
                    {
                        _wf.ChangeColumn.Add(ValidationHelper.GetGuid(row.AttributeId));
                    }
            }
            dynamicEntity.AddKeyProperty("WorkflowId", ValidationHelper.GetGuid(hdnRecid.Value));
            dynamicEntity.AddStringProperty("workflowname", WorkflowName.Value.ToString());
            _wf.ChangeColumnXml = WorkFlow.XmlSerializeChangeColumn(_wf.ChangeColumn);
            dynamicEntity.AddStringProperty("ChangeColumnXml", _wf.ChangeColumnXml);
            dynamicEntity.AddLookupProperty("Entity", "Entity", ValidationHelper.GetGuid(EntityCrmLookupComp.Value));
            //var entityId = EntityCrmLookupComp.GetValue();
            //var objectId=EntityFactory.GetEntityObjectId(entityId);
            //var ValidationHelper.GetString();
            var wfsteps = GetWorkflowItems(WItems.AllNodes);
            dynamicEntity.AddStringProperty("Rules", SerializeObject(wfsteps));

            dynamicEntity.AddBooleanProperty("StartCreate", _wf.StartCreate);
            dynamicEntity.AddBooleanProperty("StartDelete", _wf.StartDelete);
            dynamicEntity.AddBooleanProperty("StartChange", _wf.StartChange);
            dynamicEntity.AddBooleanProperty("IsClientWorkflow", _wf.IsClientWorkflow);
            dynamicEntity.AddBooleanProperty("IsOnDemandWorkflow", _wf.IsOnDemandWorkflow);
            dynamicEntity.AddPicklistProperty("RunInUser", _wf.RunInUser);

            //_df.UpdateWithOutPlugin((int)EntityEnum.Workflow, dynamicEntity);
            //Response.Redirect(QueryHelper.AddUpdateString(query));
        }
        return dynamicEntity;
    }
    WorkflowStep GetWorkflowItems(TreeNode node)
    {
        var wf = new WorkflowStep();
        var id = node.CustomAttributes[WitemDataType.id.GetHashCode()].Value;
        var text = node.CustomAttributes[WitemDataType.text.GetHashCode()].Value;
        var type = (WorkflowStepType)ValidationHelper.GetInteger(node.CustomAttributes[WitemDataType.Type.GetHashCode()].Value, 0);
        var clauseValue = node.CustomAttributes[WitemDataType.ClauseValue.GetHashCode()].Value;
        var clauseText = node.CustomAttributes[WitemDataType.ClauseText.GetHashCode()].Value;
        var data = node.CustomAttributes[WitemDataType.data.GetHashCode()].Value;

        wf.Id = ValidationHelper.GetGuid(id);
        wf.Text = ValidationHelper.GetString(text);
        wf.Type = type;
        wf.ClauseText = clauseText;
        wf.ClauseValue = clauseValue;

        switch (type)
        {
            case WorkflowStepType.Root:

                break;
            case WorkflowStepType.IfCondition:
                wf.FilterEntity = FilterEntity.DeserializeFilterEntity(data);

                break;
            case WorkflowStepType.WaitCondition:
                wf.FilterEntity = FilterEntity.DeserializeFilterEntity(data);

                break;

            case WorkflowStepType.Create:
                wf.AddUpdateEntity = AddUpdateEntity.DeserializeAddUpdateEntity(data);
                break;
            case WorkflowStepType.Update:
                wf.AddUpdateEntity = AddUpdateEntity.DeserializeAddUpdateEntity(data);
                //tnMain.Icon = Icon.ApplicationEdit;)
                break;
            case WorkflowStepType.DynamicUrl:
                wf.DynamicUrlId = WorkflowStep.DeserializeWorkflowStep(data).DynamicUrlId;

                break;
            case WorkflowStepType.ShowMessage:
                wf.WfCallBackMessage = CallBackMessage.DeserializeCallBackMessage(data);
                //tnMain.Icon = Icon.CommentAdd;)
                break;
            case WorkflowStepType.BatchScript:
                wf.WfBatchScript = BatchScript.DeserializeBatchScript(data);
                break;
            case WorkflowStepType.StopWorkFlow:
                wf.IsStopWorkflow = true;
                break;
            case WorkflowStepType.RedirectForm:
                wf.RedirectFormId = WorkflowStep.DeserializeWorkflowStep(data).RedirectFormId;
                break;
            case WorkflowStepType.Plugin:
                wf.PluginMessageId = WorkflowStep.DeserializeWorkflowStep(data).PluginMessageId;
                break;
            case WorkflowStepType.Workflow:
                wf.WorkflowId = WorkflowStep.DeserializeWorkflowStep(data).WorkflowId;
                break;

            default:
                break;

        }


        wf.WorkflowSteps = new List<WorkflowStep>();
        foreach (var treeNode in node.Nodes)
        {

            wf.WorkflowSteps.Add(GetWorkflowItems(treeNode));
        }
        return wf;
    }
    #region If Condition
    protected void CmbIfAttribute_OnEvent(object sender, AjaxEventArgs e)
    {
        var objList = new List<object>();
        foreach (var value in App.Params.CurrentEntityAttribute.Values.Where(value => value.ObjectId == ValidationHelper.GetInteger(IfconditionHdnObjectId.Value)))
        {
            objList.Add(new { Id = value.AttributeId, Name = value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId) });
        }
        CmbIfAttribute.DataSource = objList.OrderBy(t => TypeHelper.GetPropertyValue(t, "Name")).ToList();
        CmbIfAttribute.DataBind();
    }
    protected void CmbIfCondition_OnEvent(object sender, AjaxEventArgs e)
    {
        var vf = new ViewFactory();
        var attribute =
            App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(CmbIfAttribute.Value)];
        var vlist = vf.GetAttributeConditionListByTypeId(attribute.AttributeTypeId);
        CmbIfCondition.DataSource = vlist.OrderBy(t => t.Value).ToList();
        CmbIfCondition.DataBind();
    }
    protected void CmbIfReleatedEntity_OnEvent(object sender, AjaxEventArgs e)
    {
        var objList = new List<object>();

        foreach (var value in App.Params.CurrentEntityAttribute.Values.Where(
            value => value.ObjectId == ValidationHelper.GetInteger(IfconditionHdnObjectId.Value)
                && value.ReferencedEntityId != Guid.Empty
                && value.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Lookup))
            ))
        {
            objList.Add(new { Id = value.AttributeId, Name = value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId), ObjectId = value.ReferencedObjectId.ToString() });
        }
        CmbIfReleatedEntity.DataSource = objList.OrderBy(t => TypeHelper.GetPropertyValue(t, "Name")).ToList();
        CmbIfReleatedEntity.DataBind();
    }


    AttributeCondition GetAttributeCondition(Guid attributeId, Guid conditionId)
    {
        var aa = new AttributeCondition();
        var node = TreeIfConditions.SelectedNode;
        //var conditionId = ValidationHelper.GetGuid(node[8].Value);
        if (node != null)
        {
            //   var attributeId = ValidationHelper.GetGuid(node[6].Value);
            foreach (var attributeCondition in
                           App.Params.CurrentAttributeCondition.Where(
                               t =>
                               t.AttributeConditionId == conditionId &&
                               t.AttributeTypeId == App.Params.CurrentEntityAttribute[attributeId].AttributeTypeId))
            {
                return attributeCondition;
            }
        }
        return aa;
    }
    private void ClerConditionValues()
    {
        IfcValuesTextField.Clear();
        IfcValuesNumericField.Clear();
        IfcValuesDecimalField.Clear();
        IfcValuesDateField.Clear();
        IfcValuesLookupField.Clear();
        IfcValuesPicklistField.Clear();
        IfcDynamicValuesTextField.Clear();

    }
    protected void btnIfConditionAddClick_OnEvent(object sender, AjaxEventArgs e)
    {
        //text = 0, id = 1, objectid = 2, objectId = 3, leftjoin = 4, type = 5, attributeid = 6, entityobjectid = 7, conditionvalue = 8, clausevalue = 9, clausetext = 10, conditiontype = 11, clausevalue2 = 12
        var node = TreeIfConditions.SelectedNode;
        if (string.IsNullOrEmpty(CmbIfAttribute.Value))
        {
            Alert("Attribute Alanı Zorunludur.");
            return;
        }
        if (string.IsNullOrEmpty(CmbIfCondition.Value))
        {
            Alert("Condition Alanı Zorunludur.");
            return;
        }

        if (node != null && node.Count > 0)
        {
            var attributeId = ValidationHelper.GetGuid(CmbIfAttribute.Value);
            var conditionId = ValidationHelper.GetGuid(CmbIfCondition.Value);
            var ea = App.Params.CurrentEntityAttribute[attributeId];
            var tt = new TreeNode()
                         {
                             Expanded = true,
                             Leaf = true,
                             Icon = Icon.BulletOrange
                         };
            var text = string.Format("{0}  {1}  {2}", (CmbIfAttribute.SelectedItems[0]).Name,
                                     (CmbIfCondition.SelectedItems[0]).Description, LblIfConditionClausetext.Value);


            tt.CustomAttributes.Add(new ConfigItem(treedataType.text.ToString(), text, EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.id.ToString(), Guid.NewGuid().ToString(), EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.objectid.ToString(), ea.ObjectId.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.objectId.ToString(), ea.ObjectId.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.leftjoin.ToString(), "", EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.type.ToString(), FilterEntityType.Attribute.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.attributeid.ToString(), attributeId.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.entityobjectid.ToString(), ea.ObjectId.ToString(),
                                                   EpMode.Value));

            tt.CustomAttributes.Add(new ConfigItem(treedataType.conditionvalue.ToString(), conditionId.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.clausevalue.ToString(), IfConditionClauseValue.Value,
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.clausetext.ToString(), LblIfConditionClausetext.Value,
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.conditiontype.ToString(),
                                                   IfConditionConditionType.Value, EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.clausevalue2.ToString(), "", EpMode.Value));

            if (node[treedataType.type.GetHashCode()].Value == FilterEntityType.Attribute.ToString())
            {
                TreeIfConditions.UpdateSelectedNode(tt);
            }
            else
            {
                TreeIfConditions.AddTreeNode(tt);

            }
        }
        else if (node != null && node.Count == 0)
        {
            Alert("Lütfen listeden bir node seçiniz.");
        }
    }

    protected void IfConditionGetAttributeData_OnEvent(object sender, AjaxEventArgs e)
    {
        ClerConditionValues();
        var node = TreeIfConditions.SelectedNode;
        if (node != null)
        {
            var attributeId = ValidationHelper.GetGuid(node[6].Value);

            CmbIfAttribute.Value = attributeId.ToString();
            CmbIfAttribute.SetValue(attributeId,
                                    App.Params.CurrentEntityAttribute[attributeId].GetLabelWithUniqueName(
                                        App.Params.CurrentUser.LanguageId));

            var conditionId = ValidationHelper.GetGuid(node[8].Value);
            var ea = App.Params.CurrentEntityAttribute[attributeId];

            var nodeShow = 0;

            var se = GetAttributeCondition(attributeId, conditionId);
            if (se.IsTextField || se.IsNumericField || se.IsDecimalField || se.IsDateField || se.IsLookupField ||
                se.IsPicklistField)
                nodeShow = 1;
            if (se.IsTextField)
                IfcValuesTextField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
            if (se.IsNumericField)
                IfcValuesNumericField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
            if (se.IsDecimalField)
                IfcValuesDecimalField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
            if (se.IsDateField)
                IfcValuesDateField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
            if (se.IsLookupField)
            {

                IfcValuesLookupField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value, node[treedataType.clausetext.GetHashCode()].Value);
            }
            if (se.IsPicklistField)
            {
                IfcValuesPicklistField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value, node[treedataType.clausetext.GetHashCode()].Value);
            }


            CmbIfCondition.Value = conditionId.ToString();
            //CmbIfCondition_OnEvent(sender, e);
            CmbIfCondition.SetValue(conditionId, App.Params.CurrentAttributeConditionBase[conditionId].Description);
            QScript("IFCondition.ConditionChanged(" + nodeShow + ");");
            IfconditionHdnObjectId.SetValue(node[treedataType.objectId.GetHashCode()].Value);

            LblIfConditionClausetext.SetValue(node[treedataType.clausetext.GetHashCode()].Value);
            IfConditionClauseValue.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);

            if (node[treedataType.conditiontype.GetHashCode()].Value == ConditionType.Dynamic.ToString())
            {
                IfcDynamicValuesTextField.SetValue(node[treedataType.clausetext.GetHashCode()].Value);
                IfcDynamicValuesHiddenField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
                IfcValuesConditionType.SetValue(ConditionType.Dynamic.ToString());
                IfConditionConditionType.SetValue(ConditionType.Dynamic.ToString());
            }
            else
            {

                IfcDynamicValuesTextField.SetValue("");
                IfcDynamicValuesHiddenField.SetValue("");
                IfConditionConditionType.SetValue(ConditionType.Default.ToString());
                IfcValuesConditionType.SetValue(ConditionType.Default.ToString());
            }

        }
    }
    protected void IfConditionValuesEdit_OnEvent(object sender, AjaxEventArgs e)
    {
        var node = TreeIfConditions.SelectedNode;
        if (node != null)
        {

            var attributeId = ValidationHelper.GetGuid(CmbIfAttribute.Value);
            var conditionId = ValidationHelper.GetGuid(CmbIfCondition.Value);
            var nodeShow = 0;
            var ea = App.Params.CurrentEntityAttribute[attributeId];

            {

                var se = GetAttributeCondition(attributeId, conditionId);
                if (se.IsTextField || se.IsNumericField || se.IsDecimalField || se.IsDateField || se.IsLookupField || se.IsPicklistField)
                {

                    var lbl = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);

                    if (se.IsTextField)
                    {
                        hdnWindowIfcValuType.SetValue("0");
                        IfcValuesTextField.Show();
                    }
                    else
                        IfcValuesTextField.Hide();

                    if (se.IsLookupField)
                    {
                        hdnWindowIfcValuType.SetValue("1");
                        IfcValuesLookupField.Show();
                        IfcValuesLookupField.UniqueName = ea.UniqueName;
                        IfcValuesLookupField.ObjectId = ea.ObjectId.ToString();
                        IfcValuesLookupField.ReCreateLookup();

                    }
                    else
                        IfcValuesLookupField.Hide();


                    if (se.IsNumericField)
                    {
                        hdnWindowIfcValuType.SetValue("2");
                        IfcValuesNumericField.Show();
                    }
                    else
                        IfcValuesNumericField.Hide();

                    if (se.IsDecimalField)
                    {
                        hdnWindowIfcValuType.SetValue("3");
                        IfcValuesDecimalField.Show();
                    }
                    else
                        IfcValuesDecimalField.Hide();

                    if (se.IsDateField)
                    {
                        hdnWindowIfcValuType.SetValue("4");
                        IfcValuesDateField.Show();
                    }
                    else
                        IfcValuesDateField.Hide();



                    if (se.IsPicklistField)
                    {
                        hdnWindowIfcValuType.SetValue("5");
                        IfcValuesPicklistField.Show();
                        //IfcValuesPicklistField.Clear();


                    }
                    else
                        IfcValuesPicklistField.Hide();

                    IfcValuesTextField.SetFieldLabel(lbl);
                    IfcValuesNumericField.SetFieldLabel(lbl);
                    IfcValuesDecimalField.SetFieldLabel(lbl);
                    IfcValuesDateField.SetFieldLabel(lbl);
                    IfcValuesLookupField.SetFieldLabel(lbl);
                    IfcValuesPicklistField.SetFieldLabel(lbl);
                    IfcDynamicValuesTextField.SetFieldLabel(lbl);

                    if (IfConditionConditionType.Value == ConditionType.Dynamic.ToString())
                    {
                        TreeGridDynamicValue.Show();
                        IfcDynamicValuesTextField.Show();

                        IfcValuesTextField.Hide();
                        IfcValuesNumericField.Hide();
                        IfcValuesDecimalField.Hide();
                        IfcValuesDateField.Hide();
                        IfcValuesLookupField.Hide();
                        IfcValuesPicklistField.Hide();


                    }
                    else
                    {
                        TreeGridDynamicValue.Hide();
                        IfcDynamicValuesTextField.Hide();

                    }



                    nodeShow = 1;
                }
            }

            QScript("IFCondition.ConditionChanged(" + nodeShow + ");");
        }
    }
    protected void IfcValuesPicklistField_OnEvent(object sender, AjaxEventArgs e)
    {
        var attributeId = ValidationHelper.GetGuid(CmbIfAttribute.Value);

        var pf = new PicklistFactory();
        List<PicklistValue> pv = pf.GetPicklistValueList(ValidationHelper.GetGuid(attributeId));
        IfcValuesPicklistField.DataSource = pv;
        IfcValuesPicklistField.DataBind();
    }

    protected void IfcValuesConditionTypeChange_OnEvent(object sender, AjaxEventArgs e)
    {

        var attributeId = ValidationHelper.GetGuid(CmbIfAttribute.Value);
        var conditionId = ValidationHelper.GetGuid(CmbIfCondition.Value);

        var se = GetAttributeCondition(attributeId, conditionId);


        if (IfcValuesConditionType.Value == ConditionType.Dynamic.ToString())
        {
            IfcValuesTextField.Hide();
            IfcValuesNumericField.Hide();
            IfcValuesDecimalField.Hide();
            IfcValuesDateField.Hide();
            IfcValuesLookupField.Hide();
            IfcValuesPicklistField.Hide();
            TreeGridDynamicValue.Show();
            IfcDynamicValuesTextField.Show();
        }
        if (IfcValuesConditionType.Value == ConditionType.Default.ToString())
        {
            TreeGridDynamicValue.Hide();
            IfcDynamicValuesTextField.Hide();
            if (se.IsTextField)
                IfcValuesTextField.Show();
            if (se.IsNumericField)
                IfcValuesNumericField.Show();
            if (se.IsDecimalField)
                IfcValuesDecimalField.Show();
            if (se.IsDateField)
                IfcValuesDateField.Show();
            if (se.IsLookupField)
                IfcValuesLookupField.Show();
            if (se.IsPicklistField)
                IfcValuesPicklistField.Show();
        }
        if (IfcValuesConditionType.Value == ConditionType.None.ToString())
        {
            TreeGridDynamicValue.Hide();
            IfcDynamicValuesTextField.Hide();
            if (se.IsTextField)
                IfcValuesTextField.Show();
            if (se.IsNumericField)
                IfcValuesNumericField.Show();
            if (se.IsDecimalField)
                IfcValuesDecimalField.Show();
            if (se.IsDateField)
                IfcValuesDateField.Show();
            if (se.IsLookupField)
                IfcValuesLookupField.Show();
            if (se.IsPicklistField)
                IfcValuesPicklistField.Show();
        }


    }
    protected void IfConditionSave_OnClickEvent(object sender, AjaxEventArgs e)
    {
        var xx = TreeIfConditions.AllNodes;
        var aa = ConvertNodeToFilterEntity(xx);
        var se = SerializeObject(aa);
        QScript(string.Format("IFCondition.Save({0});", RefleX.Serialize(se)));

    }



    #endregion

    #region DynamicValues
    protected void DynamicValue_NodeLoad(object sender, AjaxEventArgs e)
    {
        var nodelist = new List<TreeNode>();
        var activeAttributeId = CmbIfAttribute.Value; //TreeGridDynamicValue.SelectedNode[1].Value;
        var AttributePath = TreeGridDynamicValue.SelectedNode[3].Value;
        var TargetObjectId = TreeGridDynamicValue.SelectedNode[2].Value;
        var ParentName = TreeGridDynamicValue.SelectedNode[4].Value;
        //TxtAddDays.Visible = false;
        var objectId = ValidationHelper.GetInteger(TargetObjectId, ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        var attributeId = ValidationHelper.GetGuid(activeAttributeId);

        var eaList = App.Params.CurrentEntityAttribute.Values.Where
            (ea => ((ea.ObjectId == objectId && ea.AttributeOf == Guid.Empty && ea.ReferencedObjectId > 0))
            ||
            (ea.IsPKAttribute && (ea.ObjectId == EntityEnum.SystemConditionConstants.GetHashCode()) && AttributePath == string.Empty)
            );


        foreach (var ea in eaList.OrderBy(val => val.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)))
        {
            if (ea.ReferencedEntityId != Guid.Empty || ea.ObjectId == EntityEnum.SystemConditionConstants.GetHashCode())
            {
                var asyncNode = new TreeNode();
                asyncNode.Leaf = false;
                asyncNode.Icon = Icon.Folder;
                asyncNode.Text = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);

                asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId), EpMode.Value));
                asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", ea.AttributeId.ToString(), EpMode.Value));
                if (ea.ObjectId == EntityEnum.SystemConditionConstants.GetHashCode())
                {
                    asyncNode.Icon = Icon.FolderHome;
                    if (ea.ReferencedObjectId == 0) /* */
                    {
                        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ObjectId.ToString(), EpMode.Value));
                    }
                    else
                    {
                        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ReferencedObjectId.ToString(), EpMode.Value));

                    }
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + ea.AttributeId + "|" + ((ea.ReferencedEntityId == Guid.Empty) ? ea.EntityId : ea.ReferencedEntityId) + "]", EpMode.Value));
                }
                else
                {
                    asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ReferencedObjectId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + ea.AttributeId + "|" + ea.ReferencedEntityId + "]", EpMode.Value));
                }

                asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + asyncNode.Text + ")", EpMode.Value));
                asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", ea.ObjectId.ToString(), EpMode.Value));

                //nodelist.Add(asyncNode);
                TreeGridDynamicValue.AddTreeNode(asyncNode);
            }
        }
        var IsWorkFlow = true;
        if (IsWorkFlow)
        {
            foreach (var call in App.Params.CurrentWebServiceMethodCall.Values)
            {
                if (call.ObjectId == ValidationHelper.GetInteger(objectId, 0))
                {

                    var asyncNode = new TreeNode();
                    asyncNode.Text = call.Name;
                    //asyncNode.NodeID = Guid.NewGuid().ToString();
                    asyncNode.Icon = Icon.PluginLink;
                    asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", call.Name, EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", call.MethodCallId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", call.ReferencedObjectId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + call.MethodCallId + "|" + App.Params.CurrentEntity[call.ReferencedObjectId].EntityId + "]", EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + asyncNode.Text + ")", EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", call.ObjectId.ToString(), EpMode.Value));
                    //nodelist.Add(asyncNode);
                    TreeGridDynamicValue.AddTreeNode(asyncNode);

                }

            }
        }
        try
        {
            var activeEa = new EntityAttribute();
            if (App.Params.CurrentEntityAttribute.ContainsKey(attributeId))
            {
                activeEa = App.Params.CurrentEntityAttribute[attributeId];
                //objectId = activeEa.ObjectId;
            }
            else if (string.IsNullOrEmpty(activeAttributeId))
            {
                activeEa = new EntityAttribute()
                {
                    AttributeTypeId =
                        ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Nvarchar))
                };
            }


            foreach (var ea in App.Params.CurrentEntityAttribute.Values.Where(ea =>
                ea.ObjectId == objectId && ea.AttributeOf == Guid.Empty
                && (
                    (ea.ReferencedObjectId == activeEa.ReferencedObjectId && ea.AttributeTypeId == activeEa.AttributeTypeId)
                    ||
                    (activeEa.ReferencedObjectId == ea.ObjectId && ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Primarykey)))
                    ||
                    (activeEa.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.NText)) ||
                     activeEa.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Html)) ||
                     activeEa.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Nvarchar))
                    )
                   )


                   ).OrderBy(ea => ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId))
                )
            {


                var treeNode = new TreeNode();
                treeNode.Icon = Icon.BulletOrange;
                treeNode.Text = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);
                //treeNode.NodeID = Guid.NewGuid().ToString();

                treeNode.CustomAttributes.Add(new ConfigItem("NodeName", treeNode.Text, EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("AttributeId", ea.AttributeId.ToString(), EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "", EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "." + ea.AttributeId, EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + treeNode.Text + ")", EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", ea.ObjectId.ToString(), EpMode.Value));


                treeNode.Leaf = true;
                TreeGridDynamicValue.AddTreeNode(treeNode);
                //nodelist.Add(treeNode);
            }
        }
        catch (Exception)
        {


        }
        //TreeGridDynamicValue.AddTreeNode(nodelist);


    }
    void AddDynamicValueRoot()
    {
        var asyncNode = new TreeNode { Text = "" };
        asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", "Root", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", hdnObjectId.Value, EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", "", EpMode.Value));
        //TreeGridDynamicValue.Root.AsyncLoadNode = true;
        //TreeGridDynamicValue.Root.NodeLoad += DynamicValue_NodeLoad;
        //TreeGridDynamicValue.FillRoot(new List<TreeNode>() { asyncNode });
        asyncNode.Leaf = false;
        TreeGridDynamicValue.Root.Nodes.Add(asyncNode);
    }
    #endregion


    #region Batch Script Bolumu

    protected void ReconfigureBatchScript(BatchScript batchScript)
    {
        for (int i = 0; i < batchScript.BatchScriptDetail.Count; i++)
        {
            var list = batchScript.BatchScriptDetail[i];
            var label = string.Empty;
            var uniqueName = string.Empty;
            foreach (var myForms in App.Params.CurrentForms.Values.Where(frm => frm.FormId == batchScript.FormId))
            {
                var sectionLabel = "";
                foreach (var formSection in myForms.Layout.FormTabs[0].Viewer)
                {
                    sectionLabel = formSection.Sectionname;
                    if (formSection.FormSectionId == list.AttributeId)
                    {
                        batchScript.BatchScriptDetail[i].Label = formSection.Sectionname;
                        if (!string.IsNullOrEmpty(formSection.SectionId))
                            batchScript.BatchScriptDetail[i].UniqueNama = formSection.SectionId;
                        else
                            batchScript.BatchScriptDetail[i].UniqueNama = "p_" + formSection.FormSectionId.ToString().Replace("-", "");
                    }

                    foreach (var column in formSection.FormColumnList)
                    {
                        foreach (var ealist in column.EntityAttributeList)
                        {
                            if (ealist.AttributeId != list.AttributeId)
                                continue;
                            switch (ealist.Type)
                            {
                                case "":
                                case "attribute":
                                    if (!App.Params.CurrentEntityAttribute.ContainsKey(ealist.AttributeId))
                                        continue;
                                    label =
                                        App.Params.CurrentEntityAttribute[list.AttributeId].GetLabelWithUniqueName(
                                            App.Params.CurrentUser.LanguageId);
                                    uniqueName = App.Params.CurrentEntityAttribute[list.AttributeId].UniqueName;
                                    break;
                                case "iframe":
                                    label = ealist.IframeName;
                                    uniqueName = ealist.IframeName;
                                    break;
                                case "button":
                                    label = ealist.ButtonCaption;
                                    uniqueName = ealist.ButtonName;
                                    break;
                            }
                            label = sectionLabel + "..." + label;
                            batchScript.BatchScriptDetail[i].Label = label;
                            batchScript.BatchScriptDetail[i].UniqueNama = uniqueName;
                        }
                    }
                }
            }
        }
    }
    protected void BatchScriptFormLoad()
    {
        var list = new List<object>();
        foreach (var form in App.Params.CurrentForms.Values.Where(t => t.ObjectId == ValidationHelper.GetInteger(hdnObjectId.Value)))
        {
            BatchScriptForm.Items.Add(new ListItem(form.FormId.ToString(), form.Name));
            //list.Add(new {FormId= form.FormId.ToString(), form.Name});
        }
    }
    protected void BatchScriptPropertyFormElementOnEvent(object sender, AjaxEventArgs e)
    {
        var list = new List<object>();
        foreach (var myForms in App.Params.CurrentForms.Values.Where(frm => frm.FormId == ValidationHelper.GetGuid(BatchScriptForm.Value)))
        {

            var sectionLabel = "";
            foreach (var formSection in myForms.Layout.FormTabs[0].Viewer)
            {
                sectionLabel = formSection.Sectionname;
                list.Add(new { AttributeId = formSection.FormSectionId, Label = formSection.Sectionname, Type = "section" });


                foreach (var column in formSection.FormColumnList)
                {
                    foreach (var ealist in column.EntityAttributeList)
                    {
                        var label = "";
                        var AttributeId = Guid.Empty;

                        switch (ealist.Type)
                        {
                            case "":
                            case "attribute":
                                if (!App.Params.CurrentEntityAttribute.ContainsKey(ealist.AttributeId))
                                    continue;
                                label =
                                    App.Params.CurrentEntityAttribute[ealist.AttributeId].GetLabelWithUniqueName(
                                        App.Params.CurrentUser.LanguageId);
                                break;
                            case "iframe":
                                label = ealist.IframeName;
                                break;
                            case "button":
                                label = ealist.ButtonCaption;
                                break;
                        }
                        label = sectionLabel + "..." + label;
                        list.Add(new { AttributeId = ealist.AttributeId, Label = label, Type = ealist.Type });

                    }
                }

            }

        }
        BatchScriptPropertyFormElement.DataSource = list;
        BatchScriptPropertyFormElement.DataBind();
    }
    protected void BatchScriptSave_OnClickEvent(object sender, AjaxEventArgs e)
    {
        var tf = new TemplateFactory();

        var b = new BatchScript
                    {
                        BatchScriptId = Guid.NewGuid(),
                        FormId = ValidationHelper.GetGuid(BatchScriptForm.Value),
                        Name = BatchScriptName.Value,
                        ObjectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                        ResetDefault = ValidationHelper.GetBoolean(BatchScriptReset.Value, false),
                        BatchScriptDetail = new List<BatchScriptDetail>(),
                        CreatedScript = string.Empty
                    };
        var rws = GridBatchScript.AllRows;
        foreach (var rw in rws)
        {
            var strxml = string.Empty;
            tf.HtmlToXml(rw.ConditionValue, ref strxml);
            var bcd = new BatchScriptDetail
                          {
                              Label = rw.Label,
                              AttributeId = ValidationHelper.GetGuid(rw.AttributeId),
                              ConditionSetNullValue = ValidationHelper.GetBoolean(rw.ConditionSetNullValue),
                              ConditionSetValue = ValidationHelper.GetBoolean(rw.ConditionSetValue),
                              ConditionText = rw.ConditionText,
                              ConditionType = EnumConverter.GetConditionType(rw.ConditionType),
                              ConditionValue = rw.ConditionValue,
                              ConditionValueXml = strxml,
                              DisableLevelId = EnumConverter.GetDisableLevel(rw.DisableLevelId),
                              ReadOnlyLevelId = EnumConverter.GetReadOnlyLevel(rw.ReadOnlyLevelId),
                              RequirementLevelId = EnumConverter.GetRequarementLevel(rw.RequirementLevelId),
                              ShowHideId = EnumConverter.GetEShowHide(rw.ShowHideId),
                              Type = rw.Type,
                              UniqueNama = rw.UniqueNama
                          };
            b.BatchScriptDetail.Add(bcd);
        }
        ReconfigureBatchScript(b); /*Uniquenameler labellar eklendi*/
        foreach (var bcd in b.BatchScriptDetail)
        {
            b.CreatedScript += GetCreatedScript(bcd);
        }
        var se = SerializeObject(b);
        QScript(string.Format("BatchScript.Save({0});", RefleX.Serialize(se)));

    }
    public string GetCreatedScript(BatchScriptDetail batchScriptDetail)
    {
        var cs = string.Empty;
        var uniqueName = batchScriptDetail.UniqueNama;
        EntityAttribute ea = null;
        Type myType = typeof(string);
        if (App.Params.CurrentEntityAttribute.ContainsKey(batchScriptDetail.AttributeId))
        {
            ea = App.Params.CurrentEntityAttribute[batchScriptDetail.AttributeId];
            myType = DynamicFactory.GetDynamicAttributeType(ea);
        }

        if (batchScriptDetail.RequirementLevelId != ELevel.None)
        {
            cs += "" + uniqueName + ".setRequirementLevel(" + (int)batchScriptDetail.RequirementLevelId + ");";
        }
        if (batchScriptDetail.ReadOnlyLevelId != ReadOnlyLevel.None)
        {
            if (batchScriptDetail.ReadOnlyLevelId == ReadOnlyLevel.Enable)
                cs += "" + uniqueName + ".setReadOnly(false);";
            else
            {
                cs += "" + uniqueName + ".setReadOnly(true);";
            }

        }
        if (batchScriptDetail.DisableLevelId != DisableLevel.None)
        {
            if (batchScriptDetail.DisableLevelId == DisableLevel.Enable)
                cs += "" + uniqueName + ".setDisabled(false);";
            else
            {
                cs += "" + uniqueName + ".setDisabled(true);";
            }

        }


        switch (batchScriptDetail.ShowHideId)
        {

            case EShowHide.Show:
                cs += "" + uniqueName + ((myType == typeof(CrmMoney) || myType == typeof(CrmUom)) ? "field" : "") + ".show();";
                break;
            case EShowHide.Hide:
                cs += "" + uniqueName + ((myType == typeof(CrmMoney) || myType == typeof(CrmUom)) ? "field" : "") + ".hide();";
                break;
        }


        if (batchScriptDetail.ConditionSetValue)
        {

            if ((batchScriptDetail.ConditionType == ConditionType.Default || batchScriptDetail.ConditionSetNullValue))
            {
                if (myType == typeof(Lookup) || myType == typeof(Owner))
                {
                    if (batchScriptDetail.ConditionSetNullValue)
                    {
                        cs += "" + uniqueName + ".clear();";
                    }
                    else
                    {
                        var fetchToDynamicEntity = new FetchToDynamicEntity();
                        var ret = fetchToDynamicEntity.GetRefValue(ea,
                                                                   ValidationHelper.GetGuid(
                                                                       batchScriptDetail.
                                                                           ConditionValue),
                                                                   myType);
                        cs += "" + uniqueName + ".setValue('" +
                                                       ret.Value.ToString() + "','" +
                                                       StringUtil.ReplaceBadChar(ret.name) + "');";
                    }
                }
                else if (myType == typeof(Picklist))
                {
                    if (batchScriptDetail.ConditionSetNullValue)
                    {
                        cs += "" + uniqueName + ".clear();";
                    }
                    else
                    {
                        cs += "" + uniqueName + ".setValue(" +
                                                       batchScriptDetail.ConditionValue + ");";
                    }
                }
                else if (myType == typeof(CrmBoolean))
                {
                    if (batchScriptDetail.ConditionSetNullValue)
                    {
                        cs += "" + uniqueName + ".setValue(0);";
                    }
                    else
                    {
                        cs += "" + uniqueName + ".setValue(" +
                                                       batchScriptDetail.ConditionValue + ");";
                    }
                }
                else
                {
                    if (batchScriptDetail.ConditionSetNullValue)
                    {
                        cs += "" + uniqueName + ".setValue('');";
                    }
                    else
                    {
                        cs += "" + uniqueName + ".setValue('" +
                                                       StringUtil.ReplaceBadChar(
                                                           batchScriptDetail.ConditionValue) + "');";
                    }
                }
            }
        }
        return cs;
    }
    #endregion

    #region WindowValueSelector
    AttributeCondition GetAttributeCondition(Guid attributeId)
    {
        var ac = new AttributeCondition();
        if (!App.Params.CurrentEntityAttribute.ContainsKey(attributeId))
            return ac;
        var ea = App.Params.CurrentEntityAttribute[attributeId];
        if (ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.NText)) ||
                     ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Html)) ||
                     ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Nvarchar)))
        {
            ac.IsTextField = true;
        }
        else if (ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Lookup))
           || ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Primarykey))
           || ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Owner))
           )
        {
            ac.IsLookupField = true;
        }
        else if (ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Picklist))
            || ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Bit)))
        {
            ac.IsPicklistField = true;
        }
        else if (ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.DateTime)))
        {
            ac.IsDateField = true;
        }
        else if (ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Decimal))
            || ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Money))
            || ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Float)))
        {
            ac.IsDecimalField = true;
        }
        else if (ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Integer)))
        {
            ac.IsNumericField = true;
        }

        return ac;
    }
    protected void WindowValueSelectorShow_ClickOnEvent(object sender, AjaxEventArgs e)
    {
        ValueSelectorValueType.SetValue(hdnValueSelectorValuType.Value);
        ValueSelectorValueType.Value = hdnValueSelectorValuType.Value;
        ValueSelectorSetValue();
        ValueSelectorValueTypeChange_OnEvent(sender, e);
        WindowValueSelector.Show();
        QScript("ValueSelectorTreeGrid.emptyNodes();");
        //QScript("WindowValueSelector.resize();");

    }

    void ValueSelectorHideValues()
    {
        ValueSelectorTextField.Hide();
        ValueSelectorNumericField.Hide();
        ValueSelectorDecimalField.Hide();
        ValueSelectorDateField.Hide();
        ValueSelectorLookupField.Hide();
        ValueSelectorPicklistField.Hide();
        ValueSelectorTreeGrid.Hide();
        IfcDynamicValuesTextField.Hide();
    }
    void ValueSelectorSetLabel(string lbl)
    {
        ValueSelectorTextField.SetFieldLabel(lbl);
        ValueSelectorNumericField.SetFieldLabel(lbl);
        ValueSelectorDecimalField.SetFieldLabel(lbl);
        ValueSelectorDateField.SetFieldLabel(lbl);
        ValueSelectorLookupField.SetFieldLabel(lbl);
        ValueSelectorPicklistField.SetFieldLabel(lbl);
        IfcDynamicValuesTextField.SetFieldLabel(lbl);
    }
    void ValueSelectorSetValue()
    {
        var attributeId = ValidationHelper.GetGuid(hdnValueSelectorAttributeId.Value);
        var ac = GetAttributeCondition(attributeId);
        if (App.Params.CurrentEntityAttribute.ContainsKey(attributeId))
        {
            var label = App.Params.CurrentEntityAttribute[attributeId].GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);
            ValueSelectorSetLabel(label);
        }
        if (ValueSelectorValueType.Value == ConditionType.Dynamic.ToString())
        {
            var str = hdnValueSelectorValueField.Value;
            if (str.IndexOf("version:01012013") == -1)
            {
                str = str.Replace("'", "|=~=|").Replace("\"", "'").Replace("|=~=|", "\"");
            }
            //ValueSelectorDynamicTextField.SetReadOnly(!ac.IsTextField);
            ValueSelectorDynamicTextField.SetValue(str);
        }
        if (ValueSelectorValueType.Value == ConditionType.Default.ToString() || string.IsNullOrEmpty(ValueSelectorValueType.Value))
        {
            if (ac.IsTextField)
            {
                ValueSelectorTextField.SetValue(hdnValueSelectorTextField.Value);
            }
            if (ac.IsNumericField)
                ValueSelectorNumericField.SetValue(hdnValueSelectorTextField.Value);
            if (ac.IsDecimalField)
                ValueSelectorDecimalField.SetValue(hdnValueSelectorTextField.Value);
            if (ac.IsDateField)
                ValueSelectorDateField.SetValue(hdnValueSelectorTextField.Value);
            if (ac.IsLookupField)
            {
                var ea = App.Params.CurrentEntityAttribute[attributeId];
                ValueSelectorLookupField.UniqueName = ea.UniqueName;
                ValueSelectorLookupField.ObjectId = ea.ObjectId.ToString();
                ValueSelectorLookupField.ReCreateLookup();
                ValueSelectorLookupField.SetValue(hdnValueSelectorValueField.Value, hdnValueSelectorTextField.Value);
            }
            if (ac.IsPicklistField)
                ValueSelectorPicklistField.SetValue(hdnValueSelectorValueField.Value, hdnValueSelectorTextField.Value);

        }

    }

    protected void ValueSelectorValueTypeChange_OnEvent(object sender, AjaxEventArgs e)
    {
        ValueSelectorHideValues();
        var attributeId = ValidationHelper.GetGuid(hdnValueSelectorAttributeId.Value);
        var ac = GetAttributeCondition(attributeId);

        if (ValueSelectorValueType.Value == ConditionType.Dynamic.ToString())
        {
            ValueSelectorTextField.Hide();
            ValueSelectorNumericField.Hide();
            ValueSelectorDecimalField.Hide();
            ValueSelectorDateField.Hide();
            ValueSelectorLookupField.Hide();
            ValueSelectorPicklistField.Hide();
            ValueSelectorTreeGrid.Show();
            ValueSelectorDynamicTextField.Show();
        }
        if (ValueSelectorValueType.Value == ConditionType.Default.ToString() || string.IsNullOrEmpty(ValueSelectorValueType.Value) || ValueSelectorValueType.Value == ConditionType.None.ToString())
        {
            ValueSelectorTreeGrid.Hide();
            ValueSelectorDynamicTextField.Hide();
            if (ac.IsTextField)
                ValueSelectorTextField.Show();
            if (ac.IsNumericField)
                ValueSelectorNumericField.Show();
            if (ac.IsDecimalField)
                ValueSelectorDecimalField.Show();

            if (ac.IsDateField)
                ValueSelectorDateField.Show();

            if (ac.IsLookupField)
                ValueSelectorLookupField.Show();

            if (ac.IsPicklistField)
                ValueSelectorPicklistField.Show();

        }

    }

    protected void ValueSelectorPicklistField_OnEvent(object sender, AjaxEventArgs e)
    {
        var attributeId = ValidationHelper.GetGuid(hdnValueSelectorAttributeId.Value);
        var pf = new PicklistFactory();
        List<PicklistValue> pv = pf.GetPicklistValueList(ValidationHelper.GetGuid(attributeId));
        ValueSelectorPicklistField.DataSource = pv;
        ValueSelectorPicklistField.DataBind();
    }
    protected void ValueSelectorTreeGrid_NodeLoad(object sender, AjaxEventArgs e)
    {
        var nodelist = new List<TreeNode>();
        var activeAttributeId = hdnValueSelectorAttributeId.Value;
        var AttributePath = ValueSelectorTreeGrid.SelectedNode[3].Value;
        var TargetObjectId = ValueSelectorTreeGrid.SelectedNode[2].Value;
        var ParentName = ValueSelectorTreeGrid.SelectedNode[4].Value;

        var objectId = ValidationHelper.GetInteger(TargetObjectId, ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        var attributeId = ValidationHelper.GetGuid(activeAttributeId);

        var eaList = App.Params.CurrentEntityAttribute.Values.Where
            (ea => ((ea.ObjectId == objectId && ea.AttributeOf == Guid.Empty && ea.ReferencedObjectId > 0))
            ||
            (ea.IsPKAttribute && (ea.ObjectId == EntityEnum.SystemConditionConstants.GetHashCode()) && AttributePath == string.Empty)
            );


        foreach (var ea in eaList.OrderBy(val => val.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)))
        {
            if (ea.ReferencedEntityId != Guid.Empty || ea.ObjectId == EntityEnum.SystemConditionConstants.GetHashCode())
            {
                var asyncNode = new TreeNode();
                asyncNode.Leaf = false;
                asyncNode.Icon = Icon.Folder;
                asyncNode.Text = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);

                asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId), EpMode.Value));
                asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", ea.AttributeId.ToString(), EpMode.Value));
                if (ea.ObjectId == EntityEnum.SystemConditionConstants.GetHashCode())
                {
                    asyncNode.Icon = Icon.FolderHome;
                    if (ea.ReferencedObjectId == 0) /* */
                    {
                        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ObjectId.ToString(), EpMode.Value));
                    }
                    else
                    {
                        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ReferencedObjectId.ToString(), EpMode.Value));

                    }
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + ea.AttributeId + "|" + ((ea.ReferencedEntityId == Guid.Empty) ? ea.EntityId : ea.ReferencedEntityId) + "]", EpMode.Value));
                }
                else
                {
                    asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ReferencedObjectId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + ea.AttributeId + "|" + ea.ReferencedEntityId + "]", EpMode.Value));
                }

                asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + asyncNode.Text + ")", EpMode.Value));
                asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", ea.ObjectId.ToString(), EpMode.Value));

                //nodelist.Add(asyncNode);
                ValueSelectorTreeGrid.AddTreeNode(asyncNode);
            }
        }
        var IsWorkFlow = true;
        if (IsWorkFlow)
        {
            foreach (var call in App.Params.CurrentWebServiceMethodCall.Values)
            {
                if (call.ObjectId == ValidationHelper.GetInteger(objectId, 0))
                {

                    var asyncNode = new TreeNode();
                    asyncNode.Text = call.Name;
                    //asyncNode.NodeID = Guid.NewGuid().ToString();
                    asyncNode.Icon = Icon.PluginLink;
                    asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", call.Name, EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", call.MethodCallId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", call.ReferencedObjectId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + call.MethodCallId + "|" + App.Params.CurrentEntity[call.ReferencedObjectId].EntityId + "]", EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + asyncNode.Text + ")", EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", call.ObjectId.ToString(), EpMode.Value));
                    //nodelist.Add(asyncNode);
                    ValueSelectorTreeGrid.AddTreeNode(asyncNode);

                }

            }
        }
        try
        {
            var activeEa = new EntityAttribute();
            if (App.Params.CurrentEntityAttribute.ContainsKey(attributeId))
            {
                activeEa = App.Params.CurrentEntityAttribute[attributeId];
                //objectId = activeEa.ObjectId;
            }
            else if (string.IsNullOrEmpty(activeAttributeId))
            {
                activeEa = new EntityAttribute()
                {
                    AttributeTypeId =
                        ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Nvarchar))
                };
            }


            foreach (var ea in App.Params.CurrentEntityAttribute.Values.Where(ea =>
                ea.ObjectId == objectId && ea.AttributeOf == Guid.Empty
                && (
                    (ea.ReferencedObjectId == activeEa.ReferencedObjectId && ea.AttributeTypeId == activeEa.AttributeTypeId)
                    ||
                    (activeEa.ReferencedObjectId == ea.ObjectId && ea.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Primarykey)))
                    ||
                    (activeEa.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.NText)) ||
                     activeEa.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Html)) ||
                     activeEa.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Nvarchar))
                    )
                   )


                   ).OrderBy(ea => ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId))
                )
            {


                var treeNode = new TreeNode();
                treeNode.Icon = Icon.BulletOrange;
                treeNode.Text = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);
                //treeNode.NodeID = Guid.NewGuid().ToString();

                treeNode.CustomAttributes.Add(new ConfigItem("NodeName", treeNode.Text, EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("AttributeId", ea.AttributeId.ToString(), EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "", EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "." + ea.AttributeId, EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + treeNode.Text + ")", EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", ea.ObjectId.ToString(), EpMode.Value));


                treeNode.Leaf = true;
                ValueSelectorTreeGrid.AddTreeNode(treeNode);
                //nodelist.Add(treeNode);
            }
        }
        catch (Exception)
        {


        }
        //ValueSelectorTreeGrid.AddTreeNode(nodelist);


    }
    void AddValueSelectorTreeGridRoot()
    {
        var asyncNode = new TreeNode { Text = "" };
        asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", "Root", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", hdnObjectId.Value, EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", "", EpMode.Value));
        asyncNode.Leaf = false;
        ValueSelectorTreeGrid.Root.Nodes.Add(asyncNode);
    }
    protected void WindowValueSelectorSave_ClickOnEvent(object sender, AjaxEventArgs e)
    {
        var attributeId = ValidationHelper.GetGuid(hdnValueSelectorAttributeId.Value);
        var ac = GetAttributeCondition(attributeId);
        hdnValueSelectorValuType.SetValue(ValueSelectorValueType.Value);
        if (ValueSelectorValueType.Value == ConditionType.Dynamic.ToString())
        {
            hdnValueSelectorValueField.SetValue(ValueSelectorDynamicTextField.Value);
            hdnValueSelectorTextField.SetValue(ValueSelectorDynamicTextField.Value);
            var strxml = string.Empty;
            var tf = new TemplateFactory();
            tf.HtmlToXml(ValueSelectorDynamicTextField.Value, ref strxml);
            hdnValueSelectorConditionValueXml.SetValue(strxml);
        }
        if (ValueSelectorValueType.Value == ConditionType.Default.ToString())
        {
            if (ac.IsTextField)
            {
                hdnValueSelectorValueField.SetValue(ValueSelectorTextField.Value);
                hdnValueSelectorTextField.SetValue(ValueSelectorTextField.Value);

            }
            if (ac.IsNumericField)
            {
                hdnValueSelectorValueField.SetValue(ValueSelectorNumericField.Value);
                hdnValueSelectorTextField.SetValue(ValueSelectorNumericField.Value);

            }
            if (ac.IsDecimalField)
            {

                hdnValueSelectorValueField.SetValue(ValueSelectorDecimalField.Value);
                hdnValueSelectorTextField.SetValue(ValueSelectorDecimalField.Value);

            }
            if (ac.IsDateField)
            {
                if (ValueSelectorDateField.Value.HasValue)
                {

                    hdnValueSelectorValueField.SetValue(ValueSelectorDateField.Value.Value.ToString("dd'.'MM'.'yyyy"));
                    hdnValueSelectorTextField.SetValue(ValueSelectorDateField.Value.Value.ToString("dd'.'MM'.'yyyy"));
                }
            }
            if (ac.IsLookupField)
            {
                hdnValueSelectorValueField.SetValue((ValueSelectorLookupField.SelectedItems[0]).ID);
                hdnValueSelectorTextField.SetValue((ValueSelectorLookupField.SelectedItems[0]).VALUE);


            }
            if (ac.IsPicklistField)
            {
                hdnValueSelectorValueField.SetValue(ValueSelectorPicklistField.SelectedItems[0].Value);
                hdnValueSelectorTextField.SetValue(ValueSelectorPicklistField.SelectedItems[0].Label);

            }
        }
        QScript("setTimeout(new Function(\" " + hdnValueSelectorAfterScript.Value + " \"),100);");
        WindowValueSelector.Hide();

    }
    #endregion

    #region Update Attrbute

    protected void UpdateRecordPropertyFormElementOnEvent(object sender, AjaxEventArgs e)
    {
        var lang = App.Params.CurrentUser.LanguageId;
        var attributeId = ValidationHelper.GetGuid(UpdateRecordAttribute.Value);
        var ea = App.Params.CurrentEntityAttribute[attributeId];
        int objId;
        objId = ea.ReferencedObjectId == 0 ? ea.ObjectId : ea.ReferencedObjectId;
        var list = new List<object>();
        foreach (var value in App.Params.CurrentEntityAttribute.Values.Where(
             value => value.ObjectId == ValidationHelper.GetInteger(objId)
                 && value.AttributeOf == Guid.Empty
                 && !value.IsPKAttribute))
        {
            list.Add(new { AttributeId = value.AttributeId, Label = value.GetLabelWithUniqueName(lang) });
        }

        UpdateRecordPropertyFormElement.DataSource = list;
        UpdateRecordPropertyFormElement.DataBind();
    }
    protected void UpdateRecordSave_OnClickEvent(object sender, AjaxEventArgs e)
    {

        var b = new AddUpdateEntity
        {
            Name = UpdateRecordName.Value,
            ObjectId = 0,
            //ObjectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0),
            OpenWindow = ValidationHelper.GetBoolean(UpdateRecordOpenWindow.Value),
            DisablePlugin = ValidationHelper.GetBoolean(UpdateRecordDisablePlugin.Value, false),
            DisableWf = ValidationHelper.GetBoolean(UpdateRecordDisableWf.Value, false),
            AddUpdateEntityList = new List<AddUpdateEntityList>(),
            EntityObjectAttributeId = ValidationHelper.GetGuid(UpdateRecordAttribute.Value)
        };
        var rws = GridUpdateRecord.AllRows;
        var tf = new TemplateFactory();


        foreach (var rw in rws)
        {
            var strxml = string.Empty;
            tf.HtmlToXml(rw.ConditionValue, ref strxml);

            var aue = new AddUpdateEntityList
            {
                AttributeId = ValidationHelper.GetGuid(rw.AttributeId),
                AttributeIdName = App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(rw.AttributeId)].GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                ConditionText = ValidationHelper.GetString(rw.ConditionText),
                ConditionType = EnumConverter.GetConditionType(rw.ConditionType),
                ConditionValue = ValidationHelper.GetString(rw.ConditionValue),
                ConditionValueXml = strxml,

            };
            b.AddUpdateEntityList.Add(aue);
        }
        var se = SerializeObject(b);
        QScript(string.Format("UpdateRecord.Save({0});", RefleX.Serialize(se)));

    }

    protected void UpdateRecordAttributeLoad()
    {
        foreach (var ea in App.Params.CurrentEntityAttribute.Values.Where(t => t.ObjectId == ValidationHelper.GetInteger(hdnObjectId.Value) && ((t.AttributeOf == Guid.Empty && t.ReferencedObjectId > 0) || t.IsPKAttribute)))
        {
            UpdateRecordAttribute.Items.Add(new ListItem(ea.AttributeId.ToString(), ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)));
        }
    }
    #endregion

    #region Create

    protected void CreateRecordPropertyFormElementOnEvent(object sender, AjaxEventArgs e)
    {
        var lang = App.Params.CurrentUser.LanguageId;
        var objId = ValidationHelper.GetGuid(CreateRecordEntity.Value);

        var list = new List<object>();
        foreach (var value in App.Params.CurrentEntityAttribute.Values.Where(
             value => value.EntityId == objId
                 && value.AttributeOf == Guid.Empty
                 && !value.IsPKAttribute))
        {
            list.Add(new { AttributeId = value.AttributeId, Label = value.GetLabelWithUniqueName(lang) });
        }

        CreateRecordPropertyFormElement.DataSource = list;
        CreateRecordPropertyFormElement.DataBind();
    }
    protected void CreateRecordSave_OnClickEvent(object sender, AjaxEventArgs e)
    {

        var b = new AddUpdateEntity
        {
            Name = CreateRecordName.Value,
            ObjectId = 0,
            OpenWindow = ValidationHelper.GetBoolean(CreateRecordOpenWindow.Value),
            DisablePlugin = ValidationHelper.GetBoolean(CreateRecordDisablePlugin.Value, false),
            DisableWf = ValidationHelper.GetBoolean(CreateRecordDisableWf.Value, false),
            AddUpdateEntityList = new List<AddUpdateEntityList>(),
            EntityObjectAttributeId = ValidationHelper.GetGuid(CreateRecordEntity.Value)
        };
        var rws = GridCreateRecord.AllRows;
        var tf = new TemplateFactory();

        foreach (var rw in rws)
        {
            var strxml = string.Empty;
            tf.HtmlToXml(rw.ConditionValue, ref strxml);

            var aue = new AddUpdateEntityList
            {
                AttributeId = ValidationHelper.GetGuid(rw.AttributeId),
                AttributeIdName = App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(rw.AttributeId)].GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                ConditionText = ValidationHelper.GetString(rw.ConditionText),
                ConditionType = EnumConverter.GetConditionType(rw.ConditionType),
                ConditionValue = ValidationHelper.GetString(rw.ConditionValue),
                ConditionValueXml = strxml,

            };
            b.AddUpdateEntityList.Add(aue);
        }
        var se = SerializeObject(b);
        QScript(string.Format("CreateRecord.Save({0});", RefleX.Serialize(se)));

    }

    protected void CreateRecordAttributeLoad()
    {
        foreach (var e in App.Params.CurrentEntity.Values.OrderBy(t => t.Label))
        {
            CreateRecordEntity.Items.Add(new ListItem(e.EntityId.ToString(), e.Label));
        }
    }
    #endregion

    #region Message

    protected void MessageSave_OnClickEvent(object sender, AjaxEventArgs e)
    {
        var strHtml = MessageBody.Value;
        string strXml = "";
        var tf = new TemplateFactory();
        tf.HtmlToXml(strHtml, ref strXml);

        var b = new CallBackMessage()
        {
            Name = CreateRecordName.Value,
            ObjectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0),
            CallBackMessageId = Guid.NewGuid(),
            HtmlValue = strHtml,
            MessageType = EnumConverter.GetCallBackMessageType(MessageType.Value),
            ReplaceXml = strXml

        };
        var se = SerializeObject(b);
        QScript(string.Format("Message.Save({0});", RefleX.Serialize(se)));
    }

    #endregion
    #region Dynamic Url
    void DynamicUrlLoad()
    {
        foreach (var value in App.Params.CurrentDynamicUrl.Values.Where(value => value.ObjectId == ValidationHelper.GetInteger(hdnObjectId.Value)))
        {
            DynamicUrlId.Items.Add(new ListItem(value.DynamicUrlId.ToString(), value.Name));
        }
    }
    protected void DynamicUrlSave_OnClickEvent(object sender, AjaxEventArgs e)
    {
    
        var b = new WorkflowStep()
        {
            Id = Guid.NewGuid(),
            Text = (DynamicUrlId.SelectedItems[0]).Text,
            DynamicUrlId = ValidationHelper.GetGuid(DynamicUrlId.Value),
            ClauseText = (DynamicUrlId.SelectedItems[0]).Text,
            Type = WorkflowStepType.DynamicUrl,
        };
        var se = SerializeObject(b);
        QScript(string.Format("DynamicUrl.Save({0});", RefleX.Serialize(se)));
    }

    #endregion

    #region Redirect Form
    void RedirectFormLoad()
    {
        foreach (var value in App.Params.CurrentForms.Values.Where(value => value.ObjectId == ValidationHelper.GetInteger(hdnObjectId.Value)))
        {
            RedirectFormId.Items.Add(new ListItem(value.FormId.ToString(), value.Name));
        }

    }
    protected void RedirectFormSave_OnClickEvent(object sender, AjaxEventArgs e)
    {
     
        var b = new WorkflowStep()
        {
            Id = Guid.NewGuid(),
            Text = (RedirectFormId.SelectedItems[0]).Text,
            RedirectFormId = ValidationHelper.GetGuid(RedirectFormId.Value),
            ClauseText = (RedirectFormId.SelectedItems[0]).Text,
            Type = WorkflowStepType.RedirectForm,
        };
        var se = SerializeObject(b);
        QScript(string.Format("RedirectForm.Save({0});", RefleX.Serialize(se)));
    }

    #endregion


    #region WorkFlow
    void WorkflowLoad()
    {
        Guid entityId = EntityFactory.GetEntity(ValidationHelper.GetInteger(hdnObjectId.Value,0)).EntityId;
        foreach (var cpm in App.Params.CurrentWorkFlow.Values.Where(pm => pm.Entity == entityId))
        {
            WorkflowId.Items.Add(new ListItem(cpm.WorkflowId.ToString(), cpm.WorkflowName));
        }

    }

    protected void WorkFlowSave_OnClickEvent(object sender, AjaxEventArgs e)
    {
        var b = new WorkflowStep()
        {
            Id = Guid.NewGuid(),
            Text = (WorkflowId.SelectedItems[0]).Text,
            WorkflowId = ValidationHelper.GetGuid(WorkflowId.Value),
            ClauseText = (WorkflowId.SelectedItems[0]).Text,
            Type = WorkflowStepType.Plugin,
        };
        var se = SerializeObject(b);
        QScript(string.Format("SubWorkflow.Save({0});", RefleX.Serialize(se)));
    }

    #endregion
    #region Plugin Message
    void PluginMessageLoad()
    {
        foreach (var cpm in App.Params.CurrentPluginMessages.Where(pm => pm.ObjectId == ValidationHelper.GetInteger(hdnObjectId.Value)))
        {
            PluginMessageId.Items.Add(new ListItem(cpm.PluginMessageId.ToString(), cpm.ClassName));
        }

    }

    protected void PluginMessageSave_OnClickEvent(object sender, AjaxEventArgs e)
    {
      
        var b = new WorkflowStep()
        {
            Id = Guid.NewGuid(),
            Text = (PluginMessageId.SelectedItems[0]).Text,
            PluginMessageId = ValidationHelper.GetGuid(PluginMessageId.Value),
            ClauseText = (PluginMessageId.SelectedItems[0]).Text,
            Type = WorkflowStepType.Plugin,
        };
        var se = SerializeObject(b);
        QScript(string.Format("PluginMessage.Save({0});", RefleX.Serialize(se)));
    }

    #endregion
    public object ConvertNodeToFilterEntity(TreeNode allNodes)
    {
        object rootObj = null;
        var type = allNodes.CustomAttributes[treedataType.type.GetHashCode()].Value;
        if (type == FilterEntityType.Entity.ToString() || type == FilterEntityType.And.ToString() || type == FilterEntityType.Or.ToString())
        {
            rootObj = new FilterEntity
                                  {
                                      FilterAttributeList = new List<FilterAttribute>(),
                                      FilterEntityList = new List<FilterEntity>(),
                                      type = type,
                                      text = allNodes.CustomAttributes[treedataType.text.GetHashCode()].Value,
                                      attributeid = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.attributeid.GetHashCode()].Value),
                                      id = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.id.GetHashCode()].Value),
                                      leftjoin = ValidationHelper.GetBoolean(allNodes.CustomAttributes[treedataType.leftjoin.GetHashCode()].Value),
                                      objectid = ValidationHelper.GetInteger(allNodes.CustomAttributes[treedataType.objectid.GetHashCode()].Value, 0),
                                  };
        }
        else
        {
            rootObj = new FilterAttribute()
            {
                type = type,
                text = allNodes.CustomAttributes[treedataType.text.GetHashCode()].Value,
                attributeid = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.attributeid.GetHashCode()].Value),
                id = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.id.GetHashCode()].Value),
                clausetext = ValidationHelper.GetString(allNodes.CustomAttributes[treedataType.clausetext.GetHashCode()].Value),
                clausevalue = ValidationHelper.GetString(allNodes.CustomAttributes[treedataType.clausevalue.GetHashCode()].Value),
                clausevalue2 = ValidationHelper.GetString(allNodes.CustomAttributes[treedataType.clausevalue2.GetHashCode()].Value),
                conditiontype = EnumConverter.GetConditionType(allNodes.CustomAttributes[treedataType.conditiontype.GetHashCode()].Value),
                conditionvalue = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.conditionvalue.GetHashCode()].Value),
                entityobjectid = ValidationHelper.GetInteger(allNodes.CustomAttributes[treedataType.entityobjectid.GetHashCode()].Value, 0),
                objectId = ValidationHelper.GetInteger(allNodes.CustomAttributes[treedataType.objectId.GetHashCode()].Value, 0),
            };
        }

        foreach (var node in allNodes.Nodes)
        {
            var ret = ConvertNodeToFilterEntity(node);
            if (ret.GetType() == typeof(FilterEntity))
                ((FilterEntity)rootObj).FilterEntityList.Add(((FilterEntity)ret));
            else
                ((FilterEntity)rootObj).FilterAttributeList.Add(((FilterAttribute)ret));

        }
        return rootObj;
    }
    public static class TypeHelper
    {
        public static object GetPropertyValue(object obj, string name)
        {
            return obj == null ? null : obj.GetType()
                                           .GetProperty(name)
                                           .GetValue(obj, null);
        }
    }
}

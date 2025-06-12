using System;
using System.Collections.Generic;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Web.UI.AutoGenerate;

public partial class CrmPages_Admin_WorkFlow_Edit : AdminPage
{
    private readonly List<object> _storeGrdChangeData = new List<object>();
    private readonly WorkFlowFactory _wff = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
    private readonly DynamicFactory _df = new DynamicFactory(ERunInUser.CalingUser);
    private EditPageMode _pageMode;
    private WorkFlow _wf = new WorkFlow();
    public CrmPages_Admin_WorkFlow_Edit()
    {
        base.ObjectId = EntityEnum.Workflow.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Workflow PrvCreate,PrvDelete,PrvWrite");
        }
        hdnRecid.Text = QueryHelper.GetString("recid");
        _pageMode = hdnRecid.Text != string.Empty ? EditPageMode.EditUpdate : EditPageMode.New;
        if (!Page.IsPostBack)
        {
            PnlMain.Add(new Label { Icon = Icon.Folder, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.ArrowRotateAnticlockwise, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.Time, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.ApplicationEdit, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.ApplicationAdd, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.CommentAdd, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.Stop, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.LinkEdit, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.ScriptGear, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.Reload, Hidden = true });
            PnlMain.Add(new Label { Icon = Icon.Plugin, Hidden = true });
            

            hdnDefaultEditPageId.Text = QueryHelper.GetString("defaulteditpageid");
            //hdnObjectId.Text = QueryHelper.GetString("objectid");
            FetchXML.Text = QueryHelper.GetString("FetchXML");
            Mf1.FieldLabel = StartChange.FieldLabel;
            FillEntity();
            if (_pageMode == EditPageMode.New)
            {
                DisableOnCreate(true);
                btnChangeItems.Visible = false;
            }
            else
            {
                DisableOnCreate(false);
                SetEntityValue();
                
            }
            AddWItemsRoot();
            CheckPrv();
        }
    }

    private void DisableOnCreate(bool isDisable)
    {
        StartCreate.Disabled = isDisable;
        StartDelete.Disabled = isDisable;
        StartChange.Disabled = isDisable;
        btnChangeItems.Disabled = isDisable;
        IsClientWorkflow.Disabled = isDisable;
        IsOnDemandWorkflow.Disabled = isDisable;
        //PnlDetail.Visible = !isDisable;
        WItems.Disabled = isDisable;
        //WorkflowName.Disabled = !isDisable;
        EntityCrmLookupComp.Disabled = !isDisable;
    }

    private void SetEntityValue()
    {
        var de = _df.Retrieve(10, ValidationHelper.GetGuid(hdnRecid.Text), DynamicFactory.RetrieveAllColumns);
        if (de != null)
        {
            StartCreate.DynamicEntity = de;
            StartCreate.DataBind();

            StartDelete.DynamicEntity = de;
            StartDelete.DataBind();

            StartChange.DynamicEntity = de;
            StartChange.DataBind();

            WorkflowName.DynamicEntity = de;
            WorkflowName.DataBind();

            IsOnDemandWorkflow.DynamicEntity = de;
            IsOnDemandWorkflow.DataBind();

            RunInUser.DynamicEntity = de;
            RunInUser.DataBind();

            IsClientWorkflow.DynamicEntity = de;
            IsClientWorkflow.DataBind();

            EntityCrmLookupComp.Value = de.GetLookupValue("Entity").ToString();
            EntityCrmLookupComp.DataBind();
            _wf = _wff.FillWorkFlow(de);
            var des = WorkFlow.XmlDeSerializeSteps(_wf.Rules);
            if (des.Id!=Guid.Empty)
            {
                WItems.Root.Add(addNodes(des));
            }
            
            if(!_wf .StartChange)
                btnChangeItems.Hidden = true;

            foreach (Entity entity in App.Params.CurrentEntity.Values)
            {
                if (entity.EntityId == _wf.Entity)
                    hdnObjectId.Value = entity.ObjectId.ToString();
            }
            FillStoreGrdChangeAttribute();
            var objectId = ValidationHelper.GetInteger(hdnObjectId.Text, 0);
            foreach (var value in App.Params.CurrentDynamicUrl.Values.Where(value => value.ObjectId == objectId))
            {
                cmbDynamicUrl.Items.Add(new ListItem(value.Name, value.DynamicUrlId.ToString()));
            }
            foreach (var value in App.Params.CurrentForms.Values.Where(value => value.ObjectId == objectId))
            {
                cmbRedirectForm.Items.Add(new ListItem(value.Name, value.FormId.ToString()));
            }

            foreach (var cpm in App.Params.CurrentPluginMessages.Where(pm=>pm.ObjectId==objectId))
            {
                cmbcallPlugin.Items.Add(new ListItem(cpm.ClassName, cpm.PluginMessageId.ToString()));        
            }
            
            
        }
    }
    private void FillEntity()
    {
        foreach (var entity in App.Params.CurrentEntity.Values.OrderBy(val=> val.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId) ))
        {
            EntityCrmLookupComp.Items.Add( new ListItem(entity.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),entity.EntityId.ToString()));
            
        }
        

    }
    private void FillStoreGrdChangeAttribute()
    {
        _storeGrdChangeData.Clear();
        if (_wf.Entity != Guid.Empty)
        {
            var vf = new ViewFactory();
            List<ViewEntityAttribute> vlist = vf.GetViewAttributeList(ValidationHelper.GetInteger(hdnObjectId.Text, 0));

            foreach (ViewEntityAttribute v in vlist) /*o entity nin kayitlari arasinda donecek*/
            {
                _storeGrdChangeData.Add(new
                                            {
                                                v.AttributeId,
                                                Label =
                                            App.Params.CurrentEntityAttribute[v.AttributeId].GetLabelWithUniqueName(
                                                App.Params.CurrentUser.LanguageId)
                                            }
                    );
            }
            StoreGrdChangeAttribute.DataSource = _storeGrdChangeData;
            StoreGrdChangeAttribute.DataBind();
            var sm = GrdChangeAttribute.SelectionModel.Primary as RowSelectionModel;
            foreach (Guid item in _wf.ChangeColumn)
            {
                if (sm != null) sm.SelectedRows.Add(new SelectedRow(item.ToString()));
            }
        }
    }

    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        var query = new Dictionary<string, string>();
        var workFlowItemsXml = ValidationHelper.GetString( e.ExtraParams["WorkFlowItemsXml"]);

        if (_pageMode == EditPageMode.New)
        {
            Guid gdWorkflow = GuidHelper.Newfoid((int)EntityEnum.Workflow);
            var dynamicEntity = new DynamicEntity((int)EntityEnum.Workflow);


            dynamicEntity.AddKeyProperty("workflowId", gdWorkflow);
            dynamicEntity.AddLookupProperty("Entity", "Entity", ValidationHelper.GetGuid(EntityCrmLookupComp.SelectedItem.Value));
            dynamicEntity.AddStringProperty("workflowname", WorkflowName.Value.ToString());
            
            var id=_df.CreateWithOutPlugin((int)EntityEnum.Workflow, dynamicEntity);
            query.Add("recid", id.ToString());
            Response.Redirect(QueryHelper.AddUpdateString(query));
        }
        else if (_pageMode == EditPageMode.EditUpdate)
        {
            _wf.ChangeColumn = new List<Guid>();
            _wf.StartCreate = ValidationHelper.GetBoolean(StartCreate.Value);
            _wf.StartDelete = ValidationHelper.GetBoolean(StartDelete.Value);
            _wf.StartChange = ValidationHelper.GetBoolean(StartChange.Value);

            _wf.IsClientWorkflow = ValidationHelper.GetBoolean(IsClientWorkflow.Value);
            _wf.IsOnDemandWorkflow = ValidationHelper.GetBoolean(IsOnDemandWorkflow.Value);
            _wf.RunInUser = ValidationHelper.GetInteger(RunInUser.SelectedItem.Value, 0);
            
            if (_wf.StartChange)
            {
                var sm = GrdChangeAttribute.SelectionModel.Primary as RowSelectionModel;
                if (sm != null)
                    foreach (var row in sm.SelectedRows)
                    {
                        _wf.ChangeColumn.Add(ValidationHelper.GetGuid(row.RecordID));
                    }
            }
            var dynamicEntity = new DynamicEntity((int)EntityEnum.Workflow);
            dynamicEntity.AddKeyProperty("workflowId", ValidationHelper.GetGuid(hdnRecid.Value));
            dynamicEntity.AddStringProperty("workflowname", WorkflowName.Value.ToString());
            _wf.ChangeColumnXml = WorkFlow.XmlSerializeChangeColumn(_wf.ChangeColumn);
            dynamicEntity.AddStringProperty("ChangeColumnXml", _wf.ChangeColumnXml);
            
            //var entityId = EntityCrmLookupComp.GetValue();
            //var objectId=EntityFactory.GetEntityObjectId(entityId);
            //var ValidationHelper.GetString();
            //dynamicEntity.AddStringProperty("Rules", WorkFlow.XmlSerializeSteps(_wff.GetStepsFromXml(workFlowItemsXml)));

            dynamicEntity.AddBooleanProperty("StartCreate", _wf.StartCreate);
            dynamicEntity.AddBooleanProperty("StartDelete", _wf.StartDelete);
            dynamicEntity.AddBooleanProperty("StartChange", _wf.StartChange);
            dynamicEntity.AddBooleanProperty("IsClientWorkflow", _wf.IsClientWorkflow);
            dynamicEntity.AddBooleanProperty("IsOnDemandWorkflow", _wf.IsOnDemandWorkflow);
            dynamicEntity.AddPicklistProperty("RunInUser", _wf.RunInUser);

            _df.UpdateWithOutPlugin((int)EntityEnum.Workflow, dynamicEntity);
            Response.Redirect(QueryHelper.AddUpdateString(query));
        }
    }

    Coolite.Ext.Web.TreeNode addNodes(WorkflowStep workflowStep)
    {

        var tnMain = new TreeNode(workflowStep.Id.ToString(), workflowStep.Text, Icon.Folder);
        tnMain.CustomAttributes.Add(new ConfigItem("id", "'" + workflowStep.Id + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("text", "'" + workflowStep.Text + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("Type", "'" + (int)workflowStep.Type + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("ClauseValue", "'"+workflowStep.ClauseValue+"'"));
        tnMain.CustomAttributes.Add(new ConfigItem("ClauseText", "'" + workflowStep.ClauseText + "'"));
        switch (workflowStep.Type)
        {
            case WorkflowStepType.Root:
                tnMain.Icon = Icon.Folder;
                break;
            case WorkflowStepType.IfCondition:
                tnMain.Icon = Icon.ArrowRotateAnticlockwise;
                break;
            case WorkflowStepType.WaitCondition:
                tnMain.Icon = Icon.Time;
                break;
                
            case WorkflowStepType.Create:
                tnMain.Icon = Icon.ApplicationAdd;
                break;
            case WorkflowStepType.Update:
                tnMain.Icon = Icon.ApplicationEdit;
                break;
            case WorkflowStepType.DynamicUrl:
                tnMain.Icon = Icon.LinkEdit;
                break;
            case WorkflowStepType.ShowMessage:
                tnMain.Icon = Icon.CommentAdd;
                break;
            case WorkflowStepType.BatchScript:
                tnMain.Icon = Icon.ScriptGear;
                break;
            case WorkflowStepType.StopWorkFlow:
                tnMain.Icon = Icon.Stop;
                break;
            case WorkflowStepType.RedirectForm:
                tnMain.Icon = Icon.Reload;
                break;
            case WorkflowStepType.Plugin:
                tnMain.Icon = Icon.Plugin;
                break;

            default:
                break;
        }
        foreach (WorkflowStep Vs in workflowStep.WorkflowSteps)
        {
            tnMain.Nodes.Add(addNodes( Vs));
        }
        return tnMain;
    }
    private void AddWItemsRoot()
    {
        var id = Guid.NewGuid().ToString();

        TreeNode Tn = new TreeNode(id , EntityCrmLookupComp.SelectedItem.Text,Icon.Folder);
        Tn.CustomAttributes.Add(new ConfigItem("id", "'" + id + "'"));
        Tn.CustomAttributes.Add(new ConfigItem("text", "'" + EntityCrmLookupComp.SelectedItem.Text + "'"));
        Tn.CustomAttributes.Add(new ConfigItem("Type", "'" + ValidationHelper.GetInteger(WorkflowStepType.Root,0) + "'"));
        Tn.CustomAttributes.Add(new ConfigItem("ClauseValue", "''"));
        Tn.CustomAttributes.Add(new ConfigItem("ClauseText", "''"));
        
        

        WItems.Root.Add(Tn);
    }

    private void CheckPrv()
    {
        DynamicSecurity dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(10, 0),
                                                                     (hdnRecid.Text == string.Empty
                                                                          ? (Guid?) null
                                                                          : ValidationHelper.GetGuid(hdnRecid.Text)));

        if (_pageMode == EditPageMode.EditUpdate)
        {
            if (!dynamicSecurity.PrvWrite)
            {
                btnSave.Disabled = true;
                btnSaveAndNew.Disabled = true;
                btnSaveAndClose.Disabled = true;
            }
        }
        if (_pageMode == EditPageMode.New)
        {
            if (!dynamicSecurity.PrvCreate)
            {
                btnSave.Disabled = true;
                btnSaveAndNew.Disabled = true;
                btnSaveAndClose.Disabled = true;
            }
        }
    }
}
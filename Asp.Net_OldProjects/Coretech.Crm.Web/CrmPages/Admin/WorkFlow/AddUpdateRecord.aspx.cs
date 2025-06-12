using System;
using System.Collections.Generic;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Attributes;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Template;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.AutoGenerate;
using Coretech.Crm.Factory.Crm.WorkFlow;

public partial class CrmPages_Admin_WorkFlow_AddUpdateRecord : AdminPage
{
    public CrmPages_Admin_WorkFlow_AddUpdateRecord()
    {
        base.ObjectId = EntityEnum.Workflow.GetHashCode();
    }
    EditPageMode Mode;
    int ObjectId = int.MinValue;
    int Type = int.MinValue;
    int Action = int.MinValue;

    string _framename = "";
    string _objectid = "";
    string _action = "";
    string _type = "";
    string _pawinid = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Workflow PrvCreate,PrvDelete,PrvWrite");
        }
        //WorkflowStepType.
        ObjectId = QueryHelper.GetInteger("objectid");
        Type = QueryHelper.GetInteger("type");
        Action = QueryHelper.GetInteger("action");

        _framename = QueryHelper.GetString("framename");
        _pawinid = QueryHelper.GetString("pawinid");
        _objectid = QueryHelper.GetString("objectid");
        _action = QueryHelper.GetString("action");
        _type = QueryHelper.GetString("type");
        if(_action=="1")
            Mode=EditPageMode.New;
        else if(_action=="2")
            Mode=EditPageMode.EditUpdate;
                
        if (!Page.IsPostBack)
        {
            WhereClauseLookup.Listeners.Change.Handler = WhereClauseLookup.Listeners.Change.Handler.Replace(Guid.Empty.ToString(), "||");
            WhereClauseLookup.Listeners.TriggerClick.Handler = WhereClauseLookup.Listeners.TriggerClick.Handler.Replace(Guid.Empty.ToString(), "||");
            _WorkFlowId.Value = QueryHelper.GetString("WorkFlowId");   
            xmlTemplateId.Value = QueryHelper.GetString("xmlTemplateId");

            ActiveScriptManager.RegisterClientScriptBlock("lframename", "var lframename='" + _framename + "';");
            ActiveScriptManager.RegisterClientScriptBlock("objectid", "var lobjectid='" + _objectid + "';");
            ActiveScriptManager.RegisterClientScriptBlock("action", "var laction='" + _action + "';");
            ActiveScriptManager.RegisterClientScriptBlock("type", "var type='" + _type + "';");
            ActiveScriptManager.RegisterClientScriptBlock("awinid", "var awinid='" + _pawinid + "';");

            if (string.IsNullOrEmpty(xmlTemplateId.Value.ToString()))
            {
                xmlTemplateId.Value = GuidHelper.New();
            }

            StoreLoad();
        }
    }
    public void StoreLoad() {
        if (Mode == EditPageMode.EditUpdate && ValidationHelper.GetGuid(xmlTemplateId.Value) != Guid.Empty)
        {
            WorkFlowFactory Wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
            var aue = Wf.GetAddUpdateEntity( ValidationHelper.GetGuid(xmlTemplateId.Value));
            EntityObjectAttributeList.Value = aue.EntityObjectAttributeId.ToString();
            EntityObjectAttributeList.SetValueAndFireSelect(aue.EntityObjectAttributeId.ToString());
            CreateUpdateName.Value = aue.Name;
            OpenWindow.Value = aue.OpenWindow;
            DisablePlugin.Value = aue.DisablePlugin;
            DisableWf.Value = aue.DisableWf;

            var objects = new List<object>();
            foreach (var list in aue.AddUpdateEntityList)
            {
                objects.Add(new { AttributeId = list.AttributeId, AttributeIdName = list.AttributeIdName, ConditionType = (int)list.ConditionType, ConditionText = list.ConditionText, ConditionValue = list.ConditionValue });
            }
            strGrdDefault.DataSource = objects;
            strGrdDefault.DataBind();
        }

        var vf = new ViewFactory();
        if (Type == (int)WorkflowStepType.Update) {
            var objects = new List<object>();
            var selectedValue = Guid.Empty;
            foreach (var item in
                App.Params.CurrentEntityAttribute.Values.Where(item => item.ObjectId == ObjectId && 
                    (item.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Owner)) 
                    || item.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Lookup)) 
                    || item.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Primarykey)))).OrderBy(t=>t.Label))
            {
                var innerObjectId = 0;
                if (item.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Primarykey)))
                {
                    selectedValue = item.AttributeId;
                    innerObjectId = item.ObjectId;
                }
                else
                {
                    innerObjectId = item.ReferencedObjectId;
                }
                var obj = new { ObjectId = innerObjectId, Label = item.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId), UniqueName = item.UniqueName, AttributeId = item.AttributeId, ReferencedObjectId = item.ReferencedObjectId };
               
                objects.Add(obj);
                
            }
            StoreEntityObjectAttributeList.DataSource = objects;
            EntityObjectAttributeList.FieldLabel = "Update";
            if(Action==1)//Create islemi ise 
            {
                EntityObjectAttributeList.Value = selectedValue.ToString();
                EntityObjectAttributeList.SetValueAndFireSelect(selectedValue.ToString());//.Value = selectedValue.ToString();
                
            }
        }
        else if (Type == (int)WorkflowStepType.Create) {
            EntityObjectAttributeList.FieldLabel = "Create";
            var objects= new List<object>();
            foreach (var item in App.Params.CurrentEntity.Values)
            {
                objects.Add(new { ObjectId = item.ObjectId, Label = item.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId), UniqueName = item.UniqueName, AttributeId = item.EntityId, ReferencedObjectId = item.ObjectId });
            }
            StoreEntityObjectAttributeList.DataSource = objects;
        }
        StoreEntityObjectAttributeList.DataBind();

        var ef = new EntityFactory();

        foreach (var e in ef.GetEntityList())
        {
            var s = new Store();
            var jr = new JsonReader();
            jr.ReaderID = "AttributeId";
            jr.Fields.Add(new[] { "AttributeId", "Label", "UniqueName", "AttributeTypeDescription", "ReferencedObjectId" });

            s.Reader.Add(jr);
            var mylist = new List<object>();
            foreach (var ea in
                App.Params.CurrentEntityAttribute.Values.Where(ea => ea.ObjectId == e.ObjectId && ea.AttributeOf == Guid.Empty).OrderBy(x => x.Label))
            {
                mylist.Add(new
                {
                    AttributeId = ea.AttributeId,
                    Label = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                    UniqueName = ea.UniqueName,
                    AttributeTypeDescription = ea.AttributeTypeIdname,
                    ReferencedObjectId = ea.ReferencedObjectId
                });
            }

            s.DataSource = mylist;
            s.DataBind();
            s.ID = "Store_" + e.ObjectId;
            Controls.Add(s);
        }
    }
    
    protected void WhereClauseComboStore_Refresh(object sender, StoreRefreshDataEventArgs e)
    {
        var attributeId = e.Parameters["AttributeId"];
        if (!string.IsNullOrEmpty(attributeId))
        {
            var pf = new PicklistFactory();
            List<PicklistValue> pv = pf.GetPicklistValueList(ValidationHelper.GetGuid(attributeId));

            WhereClauseComboStore.DataSource = pv;
            WhereClauseComboStore.DataBind();
        }
    }

    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        var XmlValue = e.ExtraParams["XmlValue"];
        if (!string.IsNullOrEmpty(XmlValue))
        {
            var _objectid = ObjectId;
            xmlTemplate xTemp = new xmlTemplate();
            xTemp.ObjectId = ValidationHelper.GetInteger(_objectid, 0);
            xTemp.TemplateType = TemplateType.WorkflowCreateUpdateEntity;
            xTemp.Xml = XmlValue;
            xTemp.xmlTemplateId = ValidationHelper.GetGuid(xmlTemplateId.Value);
            xTemp.GroupId = ValidationHelper.GetGuid(_WorkFlowId.Value);
            WorkFlowFactory Wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
            Wf.AddUpdateEntitySave(xTemp);
        }
        var hede = "";

    }
}
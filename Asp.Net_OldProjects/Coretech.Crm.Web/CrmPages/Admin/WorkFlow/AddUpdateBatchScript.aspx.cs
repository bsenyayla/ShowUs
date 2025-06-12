using System;
using System.Collections.Generic;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Template;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Web.UI.AutoGenerate;
using Coretech.Crm.Factory.Crm.WorkFlow;
using ListItem = Coolite.Ext.Web.ListItem;

public partial class CrmPages_Admin_WorkFlow_AddUpdateBatchScript : AdminPage
{
    public CrmPages_Admin_WorkFlow_AddUpdateBatchScript()
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
        ObjectId = QueryHelper.GetInteger("objectid");
        Type = QueryHelper.GetInteger("type");
        Action = QueryHelper.GetInteger("action");

        _framename = QueryHelper.GetString("framename");
        _pawinid = QueryHelper.GetString("pawinid");
        _objectid = QueryHelper.GetString("objectid");
        _action = QueryHelper.GetString("action");
        _type = QueryHelper.GetString("type");
        if (_action == "1")
            Mode = EditPageMode.New;
        else if (_action == "2")
            Mode = EditPageMode.EditUpdate;

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
    public void StoreLoad()
    {
        if (Mode == EditPageMode.EditUpdate && ValidationHelper.GetGuid(xmlTemplateId.Value) != Guid.Empty)
        {
            var Wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
            var aue = Wf.GetBatchScript(ValidationHelper.GetGuid(xmlTemplateId.Value));

            ResetDefault.Value = aue.ResetDefault;
            BatchScriptName.Text = aue.Name;
            if (aue.FormId != Guid.Empty)
            {
                CmbFormList.Value = aue.FormId.ToString();
                CmbFormList.SetValueAndFireSelect(aue.FormId.ToString());
            }
            var objects = new List<object>();
            foreach (var list in aue.BatchScriptDetail)
            {
                var label = string.Empty;
                var uniqueName = string.Empty;
                foreach (var myForms in App.Params.CurrentForms.Values.Where(frm => frm.FormId == aue.FormId))
                {
                    foreach (var formSection in myForms.Layout.FormTabs[0].Viewer)
                    {
                        if (formSection.FormSectionId == list.AttributeId)
                        {
                            uniqueName = "p_" + formSection.FormSectionId.ToString().Replace("-", "");
                            objects.Add(new
                            {
                                AttributeId = list.AttributeId,
                                AttributeIdName = formSection.Sectionname,
                                ShowHideId = (int)list.ShowHideId,
                                ShowHideIdName = list.ShowHideIdName,
                                RequirementLevelId = (int)list.RequirementLevelId,
                                RequirementLevelIdName = list.RequirementLevelIdName,
                                UniqueName = uniqueName,
                                Type = list.Type,
                                ConditionType = "",
                                ConditionText = "",
                                ConditionValue = "",
                                ConditionSetValue = false,
                                ConditionSetNullValue = false,
                                ReadOnlyLevelId = (int)list.ReadOnlyLevelId,
                                ReadOnlyLevelIdName = list.ReadOnlyLevelIdName,
                                DisableLevelId = (int)list.DisableLevelId,
                                DisableLevelIdName = list.DisableLevelIdName

                            });
                        }

                        foreach (var column in formSection.FormColumnList)
                        {
                            foreach (var ealist in column.EntityAttributeList)
                            {
                                if (ealist.AttributeId != list.AttributeId)
                                    continue;
                                var strType = ealist.Type;
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
                                label = "..." + label;
                                objects.Add(new
                                                {
                                                    AttributeId = list.AttributeId,
                                                    AttributeIdName = label,
                                                    ShowHideId = (int)list.ShowHideId,
                                                    ShowHideIdName = list.ShowHideIdName,
                                                    RequirementLevelId = (int)list.RequirementLevelId,
                                                    RequirementLevelIdName = list.RequirementLevelIdName,
                                                    UniqueName = uniqueName,
                                                    Type = list.Type,
                                                    ConditionType = ((int)list.ConditionType).ToString(),
                                                    ConditionText = list.ConditionText,
                                                    ConditionValue = list.ConditionValue,
                                                    ConditionSetNullValue = list.ConditionSetNullValue,
                                                    ConditionSetValue = list.ConditionSetValue,
                                                    ReadOnlyLevelId = (int)list.ReadOnlyLevelId,
                                                    ReadOnlyLevelIdName = list.ReadOnlyLevelIdName,
                                                    DisableLevelId = (int)list.DisableLevelId,
                                                    DisableLevelIdName = list.DisableLevelIdName
                                                });
                            }
                        }
                    }
                }
            }
            strGrdDefault.DataSource = objects;
            strGrdDefault.DataBind();
        }

        /*Form Listesi*/
        foreach (var myForms in App.Params.CurrentForms.Values.Where(frm => frm.ObjectId == ValidationHelper.GetInteger(_objectid)))
        {
            CmbFormList.Items.Add(new ListItem(myForms.Name, myForms.FormId.ToString()));

            var s = new Store();
            var jr = new JsonReader();
            jr.ReaderID = "AttributeId";
            jr.Fields.Add(new[] { "AttributeId", "Label", "UniqueName", "Type", "AttributeTypeDescription", "ReferencedObjectId" });

            s.Reader.Add(jr);
            var mylist = new List<object>();
            if (myForms.Layout.FormTabs == null)
                continue;
            foreach (var formSection in myForms.Layout.FormTabs[0].Viewer
                )
            {

                mylist.Add(new
                {
                    AttributeId = formSection.FormSectionId,
                    Label = formSection.Sectionname,
                    Type = "section",
                    UniqueName = "p_" + formSection.FormSectionId.ToString().Replace("-", ""),
                    AttributeTypeDescription = "",
                    ReferencedObjectId = "0"
                });
                foreach (var column in formSection.FormColumnList)
                {
                    foreach (var ealist in column.EntityAttributeList)
                    {
                        var label = string.Empty;
                        var uniqueName = string.Empty;
                        var type = string.Empty;
                        var attributeTypeDescription = string.Empty;
                        var referencedObjectId = string.Empty;
                        switch (ealist.Type)
                        {
                            case null:
                            case "":
                            case "attribute":
                                if (!App.Params.CurrentEntityAttribute.ContainsKey(ealist.AttributeId))
                                    continue;
                                label =
                                        App.Params.CurrentEntityAttribute[ealist.AttributeId].GetLabelWithUniqueName(
                                            App.Params.CurrentUser.LanguageId);
                                uniqueName = App.Params.CurrentEntityAttribute[ealist.AttributeId].UniqueName;
                                type = "attribute";
                                referencedObjectId = App.Params.CurrentEntityAttribute[ealist.AttributeId].ReferencedObjectId.ToString();
                                attributeTypeDescription = App.Params.CurrentEntityAttribute[ealist.AttributeId].AttributeTypeIdname.ToString();
                                break;
                            case "iframe":
                                label = ealist.IframeName;
                                uniqueName = ealist.IframeName;
                                type = "iframe";
                                break;
                            case "button":
                                label = ealist.ButtonCaption;
                                uniqueName = ealist.ButtonName;
                                type = "button";
                                break;
                        }
                        label = "..." + label;
                        mylist.Add(new
                                       {
                                           AttributeId = ealist.AttributeId.ToString(),
                                           Label = label,
                                           UniqueName = uniqueName,
                                           Type = type,
                                           AttributeTypeDescription = attributeTypeDescription,
                                           ReferencedObjectId = referencedObjectId
                                       });

                    }
                }
            }

            s.DataSource = mylist;
            s.DataBind();
            s.ID = "Store_" + myForms.FormId.ToString().Replace("-", "");
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
        var xmlValue = e.ExtraParams["XmlValue"];
        if (!string.IsNullOrEmpty(xmlValue))
        {
            var xTemp = new xmlTemplate
                            {
                                ObjectId = ValidationHelper.GetInteger(ObjectId, 0),
                                TemplateType = TemplateType.WorkflowCreateUpdateEntity,
                                Xml = xmlValue,
                                xmlTemplateId = ValidationHelper.GetGuid(xmlTemplateId.Value),
                                GroupId = ValidationHelper.GetGuid(_WorkFlowId.Value)
                            };
            var wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
            wf.BatchScriptSave(xTemp);
        }


    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using CrmObject = Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Objects.Crm;
public partial class CrmPages_Admin_WorkFlow_ConditionBuilder : System.Web.UI.UserControl
{
    public bool IsWorkFlow { get; set; }
    public string ObjectId { get; set; }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hdnObjectId.Text = string.IsNullOrEmpty(ObjectId) ? QueryHelper.GetString("ObjectId") : ObjectId;
            AddStores();
            ((BasePage)this.Page).ActiveScriptManager.RegisterClientInitScript("ClientId", "_C_ClientId='" + this.ClientID.ToString() + "';");
            hdnClientId.Value = ClientID;
            WhereClauseLookup.Listeners.Change.Handler = WhereClauseLookup.Listeners.Change.Handler.Replace(Guid.Empty.ToString(), "||");
            WhereClauseLookup.Listeners.TriggerClick.Handler = WhereClauseLookup.Listeners.TriggerClick.Handler.Replace(Guid.Empty.ToString(), "||");

            AddRootNode();
        }

    }
    public void WhereTree_OnClick(object obj, AjaxEventArgs e)
    {
        string strType = e.ExtraParams["Type"];
        string objectId = e.ExtraParams["ObjectId"];
        string attributeId = e.ExtraParams["AttributeId"];
        var vf = new ViewFactory();
        if (strType == "Entity")
        {
            //StoreWhereAttribute.DataSource = vf.getViewAttributeList(ValidationHelper.GetInteger(ObjectId, 0));
            //StoreWhereAttribute.DataBind();
            WhereEntityObjectAttributeList.SetValue(null);
            WhereEntityAttributeList.SetValue(null);
            WhereClause.SetValue(null);
        }
        else
        {

            WhereEntityAttributeList.SetValue(null);
            WhereClause.SetValue(null);

        }
        /*Releated Entitylerin DolduguYer*/

        var objects = new List<object>();
        var l = vf.GetViewReleatedAttributeList(ValidationHelper.GetInteger(objectId, 0));
        foreach (var o in l)
        {
            objects.Add(new { o.AttributeId, o.Label, o.UniqueName, o.ReferencedObjectId });

        }
        var pkkey = Guid.Empty;
        foreach (var Key in App.Params.CurrentEntityAttribute.Values.Where(xx => xx.ObjectId == ValidationHelper.GetInteger(objectId, 0) && xx.IsPKAttribute))
        {
            objects.Add(new { Key.AttributeId, Key.Label, Key.UniqueName, ReferencedObjectId = Key.ObjectId });
        }

        if (IsWorkFlow)
        {
            foreach (var call in App.Params.CurrentWebServiceMethodCall.Values)
            {
                if (call.ObjectId == ValidationHelper.GetInteger(objectId, 0))
                    objects.Add(
                        new
                        {
                            AttributeId = call.MethodCallId,
                            Label = "[" + call.Name + "]",
                            UniqueName = call.Name,
                            call.ReferencedObjectId
                        });

            }
        }
        StoreEntityObjectAttributeList.DataSource = objects;

        StoreEntityObjectAttributeList.DataBind();


    }
    void AddRootNode()
    {
        var ef = new EntityFactory();
        CrmObject.Entity e;
        e = ef.GetEntityFromObjectId(ValidationHelper.GetInteger(hdnObjectId.Text, 0));
        var tn = new TreeNode(e.EntityId.ToString(), e.Label, Icon.Folder);
        tn.Text = e.Label;
        tn.CustomAttributes.Add(new ConfigItem("Type", "'Entity'", ParameterMode.Raw));
        tn.CustomAttributes.Add(new ConfigItem("ObjectId", "'" + e.ObjectId + "'"));
        tn.CustomAttributes.Add(new ConfigItem("AttributeId", "''"));
        tn.CustomAttributes.Add(new ConfigItem("LeftJoin", "'false'"));
        tn.CustomAttributes.Add(new ConfigItem("ObjectAlias", "'Mt'"));
        tn.CustomAttributes.Add(new ConfigItem("UnSecure", "'false'"));


        WhereTree.Root.Add(tn);
        //StoreViewAttributeLoad(new List<ViewEntityAttribute>());
    }

    protected void AddStores()
    {
        #region WhereConditionStores

        ViewFactory vf = new ViewFactory();
        List<ConditionListAttributeType> t = vf.GetConditionListAttributeType();
        foreach (ConditionListAttributeType tid in t)
        {
            var s = new Store();
            var jr = new JsonReader();
            jr.ReaderID = "AttributeConditionId";
            jr.Fields.Add(new[]
                              {
                                  "AttributeConditionId", "IsTextField", "IsLookupField", "IsNumericField"
                                  , "IsDecimalField", "IsDateField", "IsPicklistField", "Description", "Value", "Type"
                              });

            s.Reader.Add(jr);
            var ds = vf.GetAttributeConditionListByTypeId(tid.AttributeTypeId);
            s.DataSource = ds;

            s.DataBind();
            s.ID = "Store_" + tid.Description;
            Controls.Add(s);
        }
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

            mylist.Add(new
            {
                AttributeId = GuidHelper.GetWorkflowExecutingTimeId,
                AttributeTypeDescription = "datetime",
                DisplayOrder = 1,
                IsSearchable = false,
                Label = "Workflow Executing Time",
                ReferencedObjectId = 0,
                UniqueName = "WorkflowExecutingTime",
                Width = 100
            });

            s.DataSource = mylist;
            s.DataBind();
            s.ID = "Store_" + e.ObjectId;
            Controls.Add(s);
        }

        #endregion


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

            if (e.Parameters["SelectedValue"] != null)
            {
                if (!string.IsNullOrEmpty(e.Parameters["SelectedValue"]))
                {
                    var selectedValue = ValidationHelper.GetInteger(e.Parameters["SelectedValue"], -1);
                    BasePage.QScript(WhereClauseCombo.ClientID + @".setValue(" + selectedValue + ");");
                }
            }
        }
    }

    public void ParseFilterEntity(FilterEntity filterEntity)
    {
        WhereTree.Root.Add(addNodes(filterEntity));
    }

    public void ParseXml(string strxml)
    {

    }

    Coolite.Ext.Web.TreeNode addNodes(FilterEntity f)
    {

        var tnMain = new TreeNode(Guid.NewGuid().ToString(), f.text, Icon.Folder);
        tnMain.CustomAttributes.Add(new ConfigItem("Type", "'" + f.type + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("ObjectId", "'" + f.objectid + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("EntityObjectId", "'" + f.objectid + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("AttributeId", "'" + f.attributeid + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("LeftJoin", "'" + f.leftjoin + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("ObjectAlias", "'" + f.objectAlias + "'"));
        tnMain.CustomAttributes.Add(new ConfigItem("UnSecure", "'" + f.unsecure + "'"));
        if (f.FilterAttributeList != null)
            foreach (FilterAttribute f1 in f.FilterAttributeList)
            {
                var tn = new TreeNode(Guid.NewGuid().ToString(), f1.text, Icon.Add);
                tn.CustomAttributes.Add(new ConfigItem("Type", "'" + f1.type + "'"));
                tn.CustomAttributes.Add(new ConfigItem("ObjectId", "'" + f1.objectId + "'"));
                tn.CustomAttributes.Add(new ConfigItem("AttributeId", "'" + f1.attributeid + "'"));
                tn.CustomAttributes.Add(new ConfigItem("ClauseValue", "'" + f1.clausevalue + "'"));
                tn.CustomAttributes.Add(new ConfigItem("ConditionValue", "'" + f1.conditionvalue + "'"));
                tn.CustomAttributes.Add(new ConfigItem("EntityObjectId", "'" + f1.entityobjectid + "'"));
                tn.CustomAttributes.Add(new ConfigItem("ConditionType", "'" + (int)f1.conditiontype + "'"));
                tn.CustomAttributes.Add(new ConfigItem("ClauseText", "'" + f1.clausetext + "'"));

                //tn.CustomAttributes.Add(new ConfigItem("text", f1.text.ToString()));
                tnMain.Nodes.Add(tn);
            }
        if (f.FilterEntityList != null)
            foreach (FilterEntity fe in f.FilterEntityList)
            {
                var tn = new TreeNode(fe.id.ToString(), fe.text, Icon.Folder);
                tnMain.Nodes.Add(addNodes(fe));
            }

        return tnMain;
    }


}
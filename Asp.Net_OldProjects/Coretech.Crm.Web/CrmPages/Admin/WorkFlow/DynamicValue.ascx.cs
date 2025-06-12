using System;
using System.Linq;
using System.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Attributes;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;

public partial class CrmPages_Admin_WorkFlow_DynamicValue : System.Web.UI.UserControl
{
    public bool IsWorkFlow { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hdnObjectId.Text = QueryHelper.GetString("ObjectId");
            ((BasePage)this.Page).ActiveScriptManager.RegisterClientInitScript("ClientId1", "_D_ClientId='" + this.ClientID.ToString() + "';");
            AddRoot();
        }
    }
    void AddRoot()
    {
        var asyncNode = new AsyncTreeNode();
        asyncNode.Text = "";
        asyncNode.NodeID = Guid.NewGuid().ToString();
        asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", "''"));
        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "'" + hdnObjectId.Text + "'"));
        asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", "''"));
        asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", "''"));
        asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", "''"));
        //TreeDynamic.Root = asyncNode;
        TreeDynamic.Root.Add(asyncNode);
    }
    protected void NodeLoad(object sender, NodeLoadEventArgs e)
    {
        var prefix = e.ExtraParams["ObjectId"] ?? "";
        var activeAttributeId = e.ExtraParams["ActiveAttributeId"] ?? "";
        var AttributePath = e.ExtraParams["AttributePath"] ?? "";
        var CurrentObjectId = e.ExtraParams["CurrentObjectId"] ?? "";
        var ParentName = e.ExtraParams["ParentName"] ?? "";
        TxtAddDays.Visible = false;
        var objectId = ValidationHelper.GetInteger(prefix, 0);
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
                var asyncNode = new AsyncTreeNode();
                asyncNode.Text = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);
                asyncNode.NodeID = Guid.NewGuid().ToString();

                if (ea.ObjectId == EntityEnum.SystemConditionConstants.GetHashCode())
                {

                    if (ea.ReferencedObjectId == 0) /* */
                    {
                        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "'" + ea.ObjectId + "'"));
                    }
                    else 
                    {
                        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "'" + ea.ReferencedObjectId + "'"));

                    }
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", "'" + AttributePath + "||[" + ea.AttributeId + "|" + ((ea.ReferencedEntityId == Guid.Empty) ? ea.EntityId : ea.ReferencedEntityId) + "]'"));
                    asyncNode.Icon = Icon.HouseLink;
                }
                else
                {
                    asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "'" + ea.ReferencedObjectId + "'"));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", "'" + AttributePath + "||[" + ea.AttributeId + "|" + ea.ReferencedEntityId + "]'"));
                }
                asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", "'" + ea.AttributeId + "'"));
                asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", "'" + ea.ObjectId + "'"));
                asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", "'" + ParentName + ".(" + asyncNode.Text + ")" + "'"));


                e.Nodes.Add(asyncNode);
            }
        }
        if (IsWorkFlow)
        {
            foreach (var call in App.Params.CurrentWebServiceMethodCall.Values)
            {
                if (call.ObjectId == ValidationHelper.GetInteger(objectId, 0))
                {

                    var asyncNode = new AsyncTreeNode();
                    asyncNode.Text = call.Name;
                    asyncNode.NodeID = Guid.NewGuid().ToString();
                    asyncNode.Icon = Icon.PluginLink;

                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", "'" + call.MethodCallId + "'"));
                    asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", "'" + call.ObjectId + "'"));
                    asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "'" + call.ReferencedObjectId + "'"));
                    asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", "'" + ParentName + ".(" + asyncNode.Text + ")" + "'"));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", "'" + AttributePath + "||[" + call.MethodCallId + "|" + App.Params.CurrentEntity[call.ReferencedObjectId].EntityId + "]'"));

                    e.Nodes.Add(asyncNode);

                }

            }
        }
        try
        {
            var activeEa = new EntityAttribute();
            //if (attributeId == GuidHelper.GetWorkflowExecutingTimeId)
            //{    activeEa = new EntityAttribute()
            //                   {
            //                       AttributeId = GuidHelper.GetWorkflowExecutingTimeId,
            //                       UniqueName = "WorkflowExecutingTime",
            //                       AttributeTypeId = ValidationHelper.GetGuid(StringEnum.GetStringValue(Types.DateTime)) 

            //                   };
            //}
            //else
            //{
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

            //}

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


                var treeNode = new Coolite.Ext.Web.TreeNode();
                treeNode.Text = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);
                treeNode.NodeID = Guid.NewGuid().ToString();
                treeNode.CustomAttributes.Add(new ConfigItem("AttributeId", "'" + ea.AttributeId + "'"));
                treeNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", "'" + ea.ObjectId + "'"));
                treeNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "''"));
                treeNode.CustomAttributes.Add(new ConfigItem("ParentName", "'" + ParentName + ".(" + treeNode.Text + ")" + "'"));
                treeNode.CustomAttributes.Add(new ConfigItem("AttributePath", "'" + AttributePath + "." + ea.AttributeId + "'"));
                treeNode.Leaf = true;
                e.Nodes.Add(treeNode);

            }
        }
        catch (Exception)
        {


        }


    }

}
using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Provider;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class CrmPages_Admin_Customization_Entity_EntityList : AdminPage
{
    #region NodeType enum

    public enum NodeType
    {
        Root = 0,
        Entity = 1,
        EntityProperty = 2,
        ViewList = 3,
        FormList = 4,
        EntityLabels = 5,
        AttributeRoot = 6,
        AttributeNto1 = 7,
        AttributeNtoN = 8,
        Attribute = 9
    }

    #endregion

    public CrmPages_Admin_Customization_Entity_EntityList()
    {
        ObjectId = EntityEnum.Entity.GetHashCode();
    }

    private void TranslateMessage()
    {
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!DynamicSecurity.PrvRead)
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=PrvRead");
        }

        if (!RefleX.IsAjxPostback)
        {
            hdnObjectId.Value = QueryHelper.GetString("ObjectId", "");
            hdnViewQueryId.Value = QueryHelper.GetString("ViewQueryId", "");
            TranslateMessage();
        }
    }

    protected void PublishAll_Click(object sender, AjaxEventArgs e)
    {
        CrmApplication.LoadApplicationData();
        new MessageBox("Publish Completed");
    }

    public void FillNodes()
    {
        FillEntityNodes();
    }

    protected override void OnPreInit(EventArgs e)
    {
        FillNodes();
        base.OnPreInit(e);
    }

    public void FillEntityNodes()
    {
        var treeNodeRoot = new TreeNode();

        AddDataType(0, "All Entity", ref treeNodeRoot, NodeType.Root);
        treeNodeRoot.Icon = Icon.PageGo;
        var ef = new EntityFactory();

        foreach (var vEntity in ef.GetEntityList())
        {
            if (!string.IsNullOrEmpty(FilterText.Value) &&  vEntity.UniqueName.IndexOf(FilterText.Value) == -1)
                continue;
            var nodeEntity = new TreeNode();
            AddDataType(vEntity.ObjectId, vEntity.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                        ref nodeEntity, NodeType.Entity);
            treeNodeRoot.Nodes.Add(nodeEntity);

            var nodeGeneralInfo = AddSpecialNodeTypes(vEntity.ObjectId, NodeType.EntityProperty);
            nodeEntity.Nodes.Add(nodeGeneralInfo);

            var nodeForms = AddSpecialNodeTypes(vEntity.ObjectId, NodeType.FormList);
            nodeEntity.Nodes.Add(nodeForms);

            var nodeView = AddSpecialNodeTypes(vEntity.ObjectId, NodeType.ViewList);
            nodeEntity.Nodes.Add(nodeView);

            var nodeAttributes = AddSpecialNodeTypes(vEntity.ObjectId, NodeType.AttributeRoot);
            nodeEntity.Nodes.Add(nodeAttributes);

            var nodeMessages = AddSpecialNodeTypes(vEntity.ObjectId, NodeType.EntityLabels);
            nodeEntity.Nodes.Add(nodeMessages);
        }
        TreeGridEntity.Root.Nodes.Add(treeNodeRoot);
        TreeGridEntity.Root.Listeners.Click.Handler = "Navigate()"; //bakılacak
    }

    public TreeNode AddSpecialNodeTypes(int ObjectId, NodeType nodeType)
    {
        var node = new TreeNode();
        var label = string.Empty;
        switch (nodeType)
        {
            case NodeType.EntityProperty:
                label = "Entity Property"; //CrmLabel.TranslateMessage(LabelEnum.ent)
                node.Icon = Icon.Application;
                node.Leaf = true;
                break;
            case NodeType.Root:
                label = "Root"; //CrmLabel.TranslateMessage(LabelEnum.ent)
                node.Icon = Icon.Folder;
                node.Expanded = true;
                break;
            case NodeType.ViewList:
                label = "View";
                node.Icon = Icon.ApplicationViewList;
                node.Leaf = true;
                break;
            case NodeType.FormList:
                label = "Form";
                node.Icon = Icon.ApplicationForm;
                node.Leaf = true;
                break;
            case NodeType.EntityLabels:
                label = "Messages";
                node.Icon = Icon.Mail;
                node.Leaf = true;
                break;
            case NodeType.AttributeRoot:
                label = "AttributeRoot";
                node.Icon = Icon.ApplicationFormEdit;
                var anode = AddSpecialNodeTypes(ObjectId, NodeType.Attribute);
                var nto1Node = AddSpecialNodeTypes(ObjectId, NodeType.AttributeNto1);
                var ntonnode = AddSpecialNodeTypes(ObjectId, NodeType.AttributeNtoN);
                node.Nodes.Add(anode);
                node.Nodes.Add(nto1Node);
                node.Nodes.Add(ntonnode);

                break;
            case NodeType.AttributeNto1:
                label = "AttributeNto1";
                node.Icon = Icon.ChartOrganisation;
                node.Leaf = true;
                break;
            case NodeType.AttributeNtoN:
                label = "AttributeNtoN";
                node.Icon = Icon.ChartLineLink;
                node.Leaf = true;
                break;
            case NodeType.Attribute:
                label = "Attribute";
                node.Icon = Icon.ApplicationFormEdit;
                node.Leaf = true;
                break;

            default:
                break;
        }
        AddDataType(ObjectId, label, ref node, nodeType);
        return node;
    }

    public void AddDataType(int objectId, string label, ref TreeNode node, NodeType nodeType)
    {
        node.CustomAttributes.Add(new ConfigItem {Mode = EpMode.Value, Name = "ObjectId", Value = objectId.ToString()});
        node.CustomAttributes.Add(new ConfigItem {Mode = EpMode.Value, Name = "Label", Value = label});
        node.CustomAttributes.Add(new ConfigItem
                                      {
                                          Mode = EpMode.Value,
                                          Name = "NodeType",
                                          Value = nodeType.GetHashCode().ToString()
                                      });
    }
}
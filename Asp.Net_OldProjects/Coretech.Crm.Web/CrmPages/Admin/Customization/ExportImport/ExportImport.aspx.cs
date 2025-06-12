using System;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Objects.Crm.ExportImport;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TreeNode = RefleXFrameWork.TreeNode;

public partial class CrmPages_Admin_Customization_Entity_ExportImport_ExportImport : BasePage
{
    public CrmPages_Admin_Customization_Entity_ExportImport_ExportImport()
    {
        //  base.ObjectId = EntityEnum.Entity.GetHashCode();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        //if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        //{
        //    Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        //}

    }
    public void FillNodes()
    {

        var dtm = new DataType()
                      {
                          Id = Guid.Empty.ToString(),
                          Name = "Root",
                          UniqueName = "Root",
                          NodeType = NodeType.Root,
                          SelectedAllChilde = false
                      };
        var rootNode = GetNode(dtm);

        FillEntityNodes(ref rootNode);
        FillPluginNodes(ref rootNode);
        ExportList.Root.Nodes.Add(rootNode);

    }
    protected override void OnPreInit(EventArgs e)
    {
        FillNodes();
        base.OnPreInit(e);
    }
    public void FillEntityNodes(ref TreeNode rootNode)
    {

        var dtm = new DataType()
                      {
                          Id = Guid.Empty.ToString(),
                          Name = "All Entity",
                          UniqueName = "All Entity",
                          NodeType = NodeType.AllEntity,
                          SelectedAllChilde = false
                      };
        var treeNodeEntity = GetNode(dtm);

        foreach (var vEntity in App.Params.CurrentEntity.Values.Where(t => t.IsCustomizable))
        {
            var dtme = new DataType()
            {
                Id = Guid.Empty.ToString(),
                Name = vEntity.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                UniqueName = vEntity.UniqueName,
                NodeType = NodeType.Entity,
                SelectedAllChilde = false
            };

            var nodeEntity = GetNode(dtme);

            AddForms(ref nodeEntity, vEntity);
            AddViews(ref nodeEntity, vEntity);
            AddAttributes(ref nodeEntity, vEntity);
            AddWf(ref nodeEntity, vEntity);
            treeNodeEntity.Nodes.Add(nodeEntity);

        }

        rootNode.Nodes.Add(treeNodeEntity);
    }
    public void FillPluginNodes(ref TreeNode rootNode)
    {

        var dtm = new DataType()
        {
            Id = Guid.Empty.ToString(),
            Name = "All Plugin",
            UniqueName = "All Plugin",
            NodeType = NodeType.AllPlugin,
            SelectedAllChilde = false
        };
        var treeNodeAllPlugin = GetNode(dtm);

        foreach (var pluginDll in App.Params.CurrentPlugins.Values)
        {
            var dtme = new DataType()
            {
                Id = pluginDll.ToString(),
                Name = pluginDll.Name,
                UniqueName = pluginDll.Name,
                NodeType = NodeType.Entity,
                SelectedAllChilde = false
            };

            var nodePlugin = GetNode(dtme);
            treeNodeAllPlugin.Nodes.Add(nodePlugin);

        }

        rootNode.Nodes.Add(treeNodeAllPlugin);
    }
    public void AddForms(ref TreeNode node, Coretech.Crm.Objects.Crm.Entity vEntity)
    {
        var dtmf = new DataType()
        {
            Id = vEntity.EntityId.ToString(),
            Name = "Forms",
            UniqueName = "Forms",
            NodeType = NodeType.AllForm,
            SelectedAllChilde = false
        };
        var fNode = GetNode(dtmf);
        foreach (var form in App.Params.CurrentForms.Values.Where(t => t.ObjectId == vEntity.ObjectId))
        {
            var dtmfa = new DataType()
            {
                Id = form.FormId.ToString(),
                Name = form.Name,
                UniqueName = form.Name,
                NodeType = NodeType.Form,
                SelectedAllChilde = false
            };
            var fNodea = GetNode(dtmfa);

            fNode.Nodes.Add(fNodea);
        }
        node.Nodes.Add(fNode);
    }
    public void AddViews(ref TreeNode node, Coretech.Crm.Objects.Crm.Entity vEntity)
    {

        var dtmav = new DataType()
        {
            Id = vEntity.EntityId.ToString(),
            Name = "Views",
            UniqueName = "Views",
            NodeType = NodeType.AllView,
            SelectedAllChilde = false
        };
        var vNode = GetNode(dtmav);

        foreach (var view in App.Params.CurrentView.Values.Where(t => t.ObjectId == vEntity.ObjectId))
        {
            var dtmfa = new DataType()
            {
                Id = view.ViewQueryId.ToString(),
                Name = view.Name,
                UniqueName = view.Name,
                NodeType = NodeType.Form,
                SelectedAllChilde = false
            };
            var vNodea = GetNode(dtmfa);
            vNode.Nodes.Add(vNodea);
        }
        node.Nodes.Add(vNode);
    }
    public void AddAttributes(ref TreeNode node, Coretech.Crm.Objects.Crm.Entity vEntity)
    {
        var dtmf = new DataType()
        {
            Id = vEntity.EntityId.ToString(),
            Name = "Attributes",
            UniqueName = "Attributes",
            NodeType = NodeType.EntityAttribute,
            SelectedAllChilde = false
        };
        var aNode = GetNode(dtmf);
        node.Nodes.Add(aNode);
    }
    public void AddLabels(ref TreeNode node, Coretech.Crm.Objects.Crm.Entity vEntity)
    {
        var dtmf = new DataType()
        {
            Id = vEntity.EntityId.ToString(),
            Name = "Label",
            UniqueName = "Label",
            NodeType = NodeType.Label,
            SelectedAllChilde = false
        };
        var lNode = GetNode(dtmf);
        node.Nodes.Add(lNode);
    }
    public void AddWf(ref TreeNode node, Coretech.Crm.Objects.Crm.Entity vEntity)
    {
        var dtmAwf = new DataType()
        {
            Id = vEntity.EntityId.ToString(),
            Name = "All Wf",
            UniqueName = "All Wf",
            NodeType = NodeType.AllWf,
            SelectedAllChilde = false
        };
        var wfaNode = GetNode(dtmAwf);
        foreach (var wf in App.Params.CurrentWorkFlow.Values.Where(t => t.Entity == vEntity.EntityId))
        {
            var dtmwf = new DataType()
            {
                Id = wf.WorkflowId.ToString(),
                Name = wf.WorkflowName,
                UniqueName = wf.WorkflowName,
                NodeType = NodeType.Wf,
                SelectedAllChilde = false
            };
            var wfNodea = GetNode(dtmwf);

            wfaNode.Nodes.Add(wfNodea);
        }
        node.Nodes.Add(wfaNode);
    }

    public TreeNode GetNode(DataType dataType)
    {
        var node = new TreeNode {Checked = false};

        AddDataType(dataType, ref node);
        switch (dataType.NodeType)
        {
            case NodeType.Root:
                node.Icon = Icon.PageGo;
                break;
            case NodeType.Entity:
                node.Icon = Icon.Table;
                break;
            case NodeType.EntityAttribute:
                node.Icon = Icon.TextIndent;
                node.Leaf = true;
                break;
            case NodeType.Form:
                node.Icon = Icon.ApplicationForm;
                node.Leaf = true;
                break;
            case NodeType.AllForm:
                node.Icon = Icon.ApplicationFormAdd;
                node.Leaf = false;
                break;
            case NodeType.AllEntity:
                node.Icon = Icon.PageGo;
                break;
            case NodeType.View:
                node.Icon = Icon.ApplicationForm;
                node.Leaf = true;
                break;
            case NodeType.AllView:
                node.Icon = Icon.ApplicationViewList;
                node.Leaf = false;
                break;
            case NodeType.Wf:
                node.Icon = Icon.ArrowLeft;
                node.Leaf = true;
                break;
            case NodeType.AllWf:
                node.Icon = Icon.ArrowLeft;
                node.Leaf = false;
                break;
            case NodeType.Label:
                node.Icon = Icon.PageWhiteText;
                node.Leaf = true;
                break;
            case NodeType.AllPlugin:
                node.Icon = Icon.PluginEdit;
                node.Leaf = false;
                break;
            case NodeType.Plugin:
                node.Icon = Icon.Plugin;
                node.Leaf = true;
                break;
            case NodeType.SecurityRole:
                break;
            default:
                throw new ArgumentOutOfRangeException();
        }

        return node;
    }
    public void AddDataType(DataType dt, ref TreeNode node)
    {
        node.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "Id", Value = dt.Id });
        node.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "Name", Value = dt.Name });
        node.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "UniqueName", Value = dt.UniqueName });
        node.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "NodeType", Value = dt.NodeType.ToString() });
    }
}
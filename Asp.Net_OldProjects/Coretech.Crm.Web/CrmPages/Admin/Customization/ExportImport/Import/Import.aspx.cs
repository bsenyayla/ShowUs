using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Template;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.ExportImport;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.Template;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TreeNode = RefleXFrameWork.TreeNode;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class CrmPages_Admin_Customization_ExportImport_Import_Import : AdminPage
{
    private ExportImportWidthScript _selectedSchema;
    private void TranslateMessage()
    {
        ImportFile.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_IMPORT_SELECT_FILE);
        BtnUpload.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_IMPORT_FILE_UPLOAD);
        BtnImport.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_IMPORT_SCHEMA);


    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            TranslateMessage();
            hdnImportId.Value = GuidHelper.Newfoid(EntityEnum.ExportPackage.GetHashCode()).ToString();
        }

    }
    protected void BtnUploadClick(object sender, AjaxEventArgs e)
    {

        var str = Uploadfile(ImportFile.PostedFile);
        var xTemp = new xmlTemplate();
        xTemp.ObjectId = EntityEnum.ExportPackage.GetHashCode();
        xTemp.TemplateType = TemplateType.ExportFile;
        xTemp.Xml = str;
        xTemp.xmlTemplateId = ValidationHelper.GetGuid(hdnImportId.Value);
        xTemp.GroupId = ValidationHelper.GetGuid(GuidHelper.GetImportTemplateId);
        var tf = new TemplateFactory();
        tf.AddUpdateXmlTemplate(xTemp);
        _selectedSchema = ExportImportWidthScript.XmlDeSerializeExportImportWidthScript(xTemp.Xml);

        if (_selectedSchema != null)
        {
            FillImportList();
        }

    }
    protected void BtnImportClick(object sender, AjaxEventArgs e)
    {
        var tf = new TemplateFactory();
        var xTemp = tf.GetXmlTemplate(ValidationHelper.GetGuid(hdnImportId.Value));
        _selectedSchema = ExportImportWidthScript.XmlDeSerializeExportImportWidthScript(xTemp.Xml);
        var myMessage = new MessageBox();
        myMessage.Modal = true;
        if (_selectedSchema != null)
        {
            var ifa = new ExportImportFactory();
            try
            {
                ifa.Import(_selectedSchema);
                myMessage.Show("Import Completed");
            }
            catch (Exception exc)
            {
                myMessage.MsgType = MessageBox.EMsgType.Html;
                myMessage.MessageType = EMessageType.Error;
                myMessage.Show("", "", exc.Message);



            }

        }
    }

    private void FillImportList()
    {
        var dtm = new DataType
        {
            Id = Guid.Empty.ToString(),
            Name = _selectedSchema.ExportImport.Name,
            UniqueName = _selectedSchema.ExportImport.Name,
            NodeType = NodeType.Root,
            SelectedAllChilde = false
        };
        var tnl = new List<TreeNode>();
        TreeNode rootNode = GetNode(dtm);
        FillEntityNodes(ref rootNode);
        FillPluginNodes(ref rootNode);
        FillReportsNodes(ref rootNode);
        FillRoleNodes(ref rootNode);
        tnl.Add(rootNode);
        ImportList.FillRoot(tnl);


    }
    public void FillEntityNodes(ref TreeNode rootNode)
    {
        var dtm = new DataType
        {
            Id = Guid.Empty.ToString(),
            Name = "All Entity",
            UniqueName = "All Entity",
            NodeType = NodeType.AllEntity,
            SelectedAllChilde = false
        };
        TreeNode treeNodeEntity = GetNode(dtm);

        foreach (var vExportEntity in _selectedSchema.ExportImport.EntityList)
        {
            var vEntity = vExportEntity.EEntity;
            var dtme = new DataType
            {
                Id = vEntity.ObjectId.ToString(),
                Name = vEntity.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                UniqueName = vEntity.UniqueName,
                NodeType = NodeType.Entity,
                SelectedAllChilde = false
            };

            TreeNode nodeEntity = GetNode(dtme);
            if (vExportEntity.EFormList.Count > 0)
                AddForms(ref nodeEntity, vExportEntity.EFormList, vEntity.ObjectId);
            if (vExportEntity.EViewList.Count > 0)
                AddViews(ref nodeEntity, vExportEntity.EViewList, vEntity.ObjectId);
            if (vExportEntity.EeAttribute.EaList.Count > 0)
                AddAttributes(ref nodeEntity, vEntity.ObjectId);
            if (vExportEntity.ELabelMessage.Count > 0 || vExportEntity.EntityLabelList.Count > 0)
                AddLabels(ref nodeEntity, vEntity.ObjectId);

            if (vExportEntity.EWorkFlowList.Count > 0)
                AddWf(ref nodeEntity, vExportEntity.EWorkFlowList, vEntity.ObjectId);
            if (vExportEntity.EDataList.Count > 0)
                AddData(ref nodeEntity, vEntity.ObjectId, vExportEntity.EDataList);
            treeNodeEntity.Nodes.Add(nodeEntity);
        }

        rootNode.Nodes.Add(treeNodeEntity);
    }
    public void AddForms(ref TreeNode node, List<DynamicEntity> eFormList, int objectId)
    {
        var dtmf = new DataType
        {
            Id = objectId.ToString(),
            Name = "Forms",
            UniqueName = "Forms",
            NodeType = NodeType.AllForm,
            SelectedAllChilde = false
        };
        TreeNode fNode = GetNode(dtmf);
        foreach (var form in eFormList)
        {

            var dtmfa = new DataType
            {
                Id = form.GetKeyValue("FormId").ToString(),
                Name = form.GetStringValue("Name"),
                UniqueName = form.GetStringValue("Name"),
                NodeType = NodeType.Form,
            };
            TreeNode fNodea = GetNode(dtmfa);

            fNode.Nodes.Add(fNodea);
        }
        node.Nodes.Add(fNode);
    }
    public void AddViews(ref TreeNode node, List<DynamicEntity> eViewList, int objectId)
    {
        var dtmav = new DataType
        {
            Id = objectId.ToString(),
            Name = "Views",
            UniqueName = "Views",
            NodeType = NodeType.AllView,
            SelectedAllChilde = false
        };
        TreeNode vNode = GetNode(dtmav);

        foreach (var view in eViewList)
        {
            var dtmfa = new DataType
            {
                Id = view.GetKeyValue("ViewQueryId").ToString(),
                Name = view.GetStringValue("Name"),
                UniqueName = view.GetStringValue("Name"),
                NodeType = NodeType.View,
                SelectedAllChilde = false
            };
            TreeNode vNodea = GetNode(dtmfa);
            vNode.Nodes.Add(vNodea);
        }
        node.Nodes.Add(vNode);
    }
    public void AddAttributes(ref TreeNode node, int objectId)
    {
        var dtmf = new DataType
        {
            Id = objectId.ToString(),
            Name = "Attributes",
            UniqueName = "Attributes",
            NodeType = NodeType.EntityAttribute,
            SelectedAllChilde = false
        };
        TreeNode aNode = GetNode(dtmf);
        node.Nodes.Add(aNode);
    }
    public void AddLabels(ref TreeNode node, int objectId)
    {
        var dtmf = new DataType
        {
            Id = objectId.ToString(),
            Name = "Label",
            UniqueName = "Label",
            NodeType = NodeType.Label,
            SelectedAllChilde = false
        };
        TreeNode lNode = GetNode(dtmf);
        node.Nodes.Add(lNode);
    }
    public void AddData(ref TreeNode node, int objectId,List<DynamicEntity> EdataList)
    {
        var dtmf = new DataType
        {
            Id = objectId.ToString(),
            Name = "Data",
            UniqueName = "Data",
            NodeType = NodeType.AllData,
            SelectedAllChilde = false
        };
        TreeNode aNode = GetNode(dtmf);
        foreach (var wf in EdataList)
        {
            var pro=wf.Properties.ToArray();
            var dtmwf = new DataType
            {
                
                Id = ((KeyProperty)pro[0]).Value.Value.ToString(),
                Name = ((StringProperty)pro[1]).Value.Value,
                UniqueName = ((KeyProperty)pro[0]).Value.Value.ToString(),
                NodeType = NodeType.DataItem,
                SelectedAllChilde = false
            };
            TreeNode wfNodea = GetNode(dtmwf);

            aNode.Nodes.Add(wfNodea);
        }
        node.Nodes.Add(aNode);
    }
    public void AddWf(ref TreeNode node, List<DynamicEntity> eWorkFlowList, int objectId)
    {
        var dtmAwf = new DataType
        {
            Id = objectId.ToString(),
            Name = "All Wf",
            UniqueName = "All Wf",
            NodeType = NodeType.AllWf,
            SelectedAllChilde = false
        };
        TreeNode wfaNode = GetNode(dtmAwf);
        foreach (var wf in eWorkFlowList)
        {
            var dtmwf = new DataType
            {
                Id = wf.GetKeyValue("WorkflowId").ToString(),
                Name = wf.GetStringValue("workflowname"),
                UniqueName = wf.GetStringValue("workflowname"),
                NodeType = NodeType.Wf,
                SelectedAllChilde = false
            };
            TreeNode wfNodea = GetNode(dtmwf);

            wfaNode.Nodes.Add(wfNodea);
        }
        node.Nodes.Add(wfaNode);
    }
    public void FillPluginNodes(ref TreeNode rootNode)
    {
        var dtm = new DataType
        {
            Id = Guid.Empty.ToString(),
            Name = "All Plugin",
            UniqueName = "All Plugin",
            NodeType = NodeType.AllPlugin,
            SelectedAllChilde = false
        };
        TreeNode treeNodeAllPlugin = GetNode(dtm);

        foreach (var pluginDll in _selectedSchema.ExportImport.PluginList)
        {
            var dtme = new DataType
            {
                Id = pluginDll.PDll.PluginDllId.ToString(),
                Name = pluginDll.PDll.Name,
                UniqueName = pluginDll.PDll.Name,
                NodeType = NodeType.Entity,
                SelectedAllChilde = false
            };

            TreeNode nodePlugin = GetNode(dtme);
            treeNodeAllPlugin.Nodes.Add(nodePlugin);
        }

        rootNode.Nodes.Add(treeNodeAllPlugin);
    }
    public void FillReportsNodes(ref TreeNode rootNode)
    {
        var dtm = new DataType
        {
            Id = Guid.Empty.ToString(),
            Name = "All Reports",
            UniqueName = "All Reports",
            NodeType = NodeType.AllReports,
            SelectedAllChilde = false
        };
        TreeNode treeNodeAllPlugin = GetNode(dtm);

        foreach (var report in _selectedSchema.ExportImport.ReportList)
        {
            var dtme = new DataType
            {
                Id = report.ActiveReport.ReportsId.ToString(),
                Name = report.ActiveReport.ReportName,
                UniqueName = report.ActiveReport.ReportsId.ToString(),
                NodeType = NodeType.Report,
                SelectedAllChilde = false
            };

            TreeNode nodePlugin = GetNode(dtme);
            treeNodeAllPlugin.Nodes.Add(nodePlugin);
        }

        rootNode.Nodes.Add(treeNodeAllPlugin);
    }
    public void FillRoleNodes(ref TreeNode rootNode)
    {
        var dtm = new DataType
        {
            Id = Guid.Empty.ToString(),
            Name = "All Roles",
            UniqueName = "All Roles",
            NodeType = NodeType.AllSecurityRole,
            SelectedAllChilde = false
        };
        TreeNode treeNodeAllPlugin = GetNode(dtm);
        foreach (var report in _selectedSchema.ExportImport.SecurityRoleList)
        {
            var dtme = new DataType
            {
                Id = report.SecurityRole.GetKeyValue("RoleId").ToString(),
                Name = report.SecurityRole.GetStringValue("Name"),
                UniqueName = report.SecurityRole.GetKeyValue("RoleId").ToString(),
                NodeType = NodeType.Report,
                SelectedAllChilde = false
            };

            TreeNode nodePlugin = GetNode(dtme);
            treeNodeAllPlugin.Nodes.Add(nodePlugin);
        }

        rootNode.Nodes.Add(treeNodeAllPlugin);
    }
    public TreeNode GetNode(DataType dataType)
    {
        var node = new TreeNode();

        AddDataType(dataType, ref node);
        switch (dataType.NodeType)
        {
            case NodeType.Root:
                node.Icon = Icon.PageGo;
                break;
            case NodeType.AllEntity:
                node.Icon = Icon.PageGo;
                break;
            case NodeType.Entity:
                node.Icon = Icon.Table;
                break;
            case NodeType.EntityAttribute:
                node.Icon = Icon.TextIndent;
                node.Leaf = true;

                break;
            case NodeType.AllForm:
                node.Icon = Icon.ApplicationFormAdd;
                node.Leaf = false;

                break;

            case NodeType.Form:
                node.Icon = Icon.ApplicationForm;
                node.Leaf = true;

                break;
            case NodeType.AllView:
                node.Icon = Icon.ApplicationViewList;
                node.Leaf = false;

                break;
            case NodeType.View:
                node.Icon = Icon.ApplicationForm;
                node.Leaf = true;

                break;
            case NodeType.AllWf:
                node.Icon = Icon.ArrowLeft;
                node.Leaf = false;

                break;
            case NodeType.Wf:
                node.Icon = Icon.ArrowLeft;
                node.Leaf = true;

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
            case NodeType.AllReports:
                node.Icon = Icon.ReportEdit;
                node.Leaf = false;

                break;
            case NodeType.Report:
                node.Icon = Icon.Report;
                node.Leaf = true;
                break;
            case NodeType.AllSecurityRole:
                node.Icon = Icon.UserKey;
                node.Leaf = false;

                break;
            case NodeType.SecurityRole:
                node.Icon = Icon.UserB;
                node.Leaf = true;

                break;
            case NodeType.AllData:
                node.Icon = Icon.Database;
                node.Leaf = false;

                break;
            case NodeType.DataItem:
                node.Icon = Icon.DatabaseKey;
                node.Leaf = true;

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
        node.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "NodeType", Value = ((int)dt.NodeType).ToString() });
    }
    private static string Uploadfile(HttpPostedFile postedFile)
    {

        var ef = new ExportImportFactory();
        var _before = new List<ExecScript>();
        var _after = new List<ExecScript>();
        var ret = ef.UnZip(postedFile.InputStream, out _before, out _after);


        var eiscript = new ExportImportWidthScript
                          {
                              ExportImport = ExportImport.XmlDeSerializeExportImport(ret),
                              AfterScript = _after,
                              BeforeScript = _before
                          };

        ret = ExportImportWidthScript.SerializeExportImportWidthScript(eiscript);

        /*if (postedFile != null && postedFile.ContentLength > 0 && postedFile.ContentType == "text/xml")
        {
            var srContent1 = new StreamReader(postedFile.InputStream);
            var strContent1 = string.Empty;

            strContent1 = srContent1.ReadToEnd();
            return strContent1;
        }*/

        return ret;
    }
}
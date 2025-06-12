using System;
using System.Collections.Generic;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Reporting;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.ExportImport;
using Coretech.Crm.Objects.Crm.Form;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.Plugin;
using Coretech.Crm.Objects.Crm.Reporting;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class CrmPages_Admin_Customization_ExportImport_Export_ExportEdit : AdminPage
{
    private string _PackageXml = string.Empty;
    private DynamicEntity _exportData = new DynamicEntity(EntityEnum.ExportPackage.GetHashCode());
    private ExportImportSchema _selectedSchema = new ExportImportSchema();

    public CrmPages_Admin_Customization_ExportImport_Export_ExportEdit()
    {
        base.ObjectId = EntityEnum.ExportPackage.GetHashCode();
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            hdnRecid.Value = QueryHelper.GetString("recid");
            if (!string.IsNullOrEmpty(hdnRecid.Value))
            {
                _exportData = GetDatas();
                _PackageXml = _exportData.GetStringValue("PackageXml");
                if (!string.IsNullOrEmpty(_PackageXml))
                    _selectedSchema = ExportImportSchema.XmlDeSerializeExportImportSchema(_PackageXml);
                FillNodes();
            }
            SetDefaultValues();
        }
        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleXFrameWork.RefleX.IsAjxPostback)
        {
            hdnDefaultEditPageId.Value = QueryHelper.GetString("defaulteditpageid");
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            hdnEntityId.Value = App.Params.CurrentEntity[QueryHelper.GetInteger("objectid")].EntityId.ToString();
            FetchXML.Value = QueryHelper.GetString("FetchXML");
        }
    }

    protected void BtnSaveClick(object sender, AjaxEventArgs e)
    {
        DateTime starttime = DateTime.Now;


        /*Ic Yetki Kontrolu*/
        if (hdnRecid.Value != "")
        {
            if (!DynamicSecurity.PrvWrite)
            {
                return;
            }
        }
        else
        {
            if (!DynamicSecurity.PrvCreate)
            {
                return;
            }
        }

        if (e.ExtraParams["Action"] != null)
        {
            int action = ValidationHelper.GetInteger(e.ExtraParams["Action"], 0);
            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);
            DynamicEntity dynamicEntity = FillEntity();


            try
            {
                if (hdnRecid.Value != string.Empty)
                {
                    dynamicFactory.Update(ValidationHelper.GetInteger(hdnObjectId.Value, 0), dynamicEntity);
                }
                else
                {
                    Guid gdNew = dynamicFactory.Create(ValidationHelper.GetInteger(hdnObjectId.Value, 0), dynamicEntity);
                    hdnRecid.Value = gdNew.ToString();
                }
            }
            catch (CrmException ex)
            {
                var msg = new MessageBox();
                if (ex.MessageType == CrmException.EMessageTpe.Error)
                    msg.MessageType = EMessageType.Error;
                msg.Modal = true;
                msg.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE), " ", ex.ErrorMessage);
                return;
            }


            var query = new Dictionary<string, string>();
            switch (action)
            {
                case 1:
                    query.Add("recid", hdnRecid.Value);
                    QScript("UpdatedUrl.setValue(\"" + QueryHelper.AddUpdateString(query) + "\");");
                    break;
                case 2:
                    query.Add("recid", "");
                    QScript("UpdatedUrl.setValue(\"" + QueryHelper.AddUpdateString(query) + "\");");
                    break;
                case 3:
                    query.Add("recid", "");
                    QScript("UpdatedUrl.setValue(\"" + QueryHelper.AddUpdateString(query) + "\");");
                    break;
            }
        }
        TimeSpan endtime = DateTime.Now - starttime;
        if (GlobalConfig.Settings.PageRenderTime)
            QScript("ShowDebugger();top.window[\"Debugger_RenderTime\"].addDebug('Saving -- ' , " + endtime.Milliseconds +
                    ");");
    }

    private void SetDefaultValues()
    {
        PackageName.Value = _exportData.GetStringValue("PackageName");


        const string beforeScript = "return CrmValidateForm(msg,e);";
        btnSave.AjaxEvents.Click.Before = beforeScript;
        btnSave.AjaxEvents.Click.Success =
            "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ if(RedirectType.getValue()=='1'){ window.location=UpdatedUrl.getValue();}else{ShowSaveMessage()}}";


        btnSaveAndClose.AjaxEvents.Click.Before = beforeScript;
        btnSaveAndClose.AjaxEvents.Click.Success = "if(UpdatedUrl.getValue()!='' ){RefreshParetnGrid(true);}";
    }

    private DynamicEntity GetDatas()
    {
        var myEntity = new DynamicEntity(EntityEnum.ExportPackage.GetHashCode());
        var df = new DynamicFactory(ERunInUser.CalingUser);
        myEntity = df.Retrieve(myEntity.ObjectId, ValidationHelper.GetGuid(hdnRecid.Value),
                               DynamicFactory.RetrieveAllColumns);
        return myEntity;
    }

    private DynamicEntity FillEntity()
    {
        var myEntity = new DynamicEntity(EntityEnum.ExportPackage.GetHashCode());
        myEntity.AddStringProperty("PackageName", PackageName.Value);
        if (hdnRecid.Value != "")
            myEntity.AddKeyProperty("ExportPackageId", ValidationHelper.GetGuid(hdnRecid.Value));
        object nactiveObject = new ExportImportSchema();
        ConvertCheckedNodes(ExportList.CheckedNodes, ref nactiveObject);
        string strSxml = ExportImportSchema.SerializeExportImportSchema((ExportImportSchema)nactiveObject);
        myEntity.AddStringProperty("PackageXml", strSxml);
        return myEntity;
    }

    public void FillNodes()
    {
        var dtm = new DataType
                      {
                          Id = Guid.Empty.ToString(),
                          Name = "Import",
                          UniqueName = "Import",
                          NodeType = NodeType.Root,
                          SelectedAllChilde = false
                      };
        TreeNode rootNode = GetNode(dtm);

        FillEntityNodes(ref rootNode);
        FillPluginNodes(ref rootNode);
        FillReportNodes(ref rootNode);
        FillRoleNodes(ref rootNode);
        ExportList.Root.Nodes.Add(rootNode);
    }

    public void FillEntityNodes(ref TreeNode rootNode)
    {
        var dtm = new DataType
                      {
                          Id = Guid.Empty.ToString(),
                          Name = "All Entities",
                          UniqueName = "All Entities",
                          NodeType = NodeType.AllEntity,
                          SelectedAllChilde = false
                      };
        TreeNode treeNodeEntity = GetNode(dtm);

        foreach (Entity vEntity in App.Params.CurrentEntity.Values.Where(t => t.IsCustomizable).OrderBy(t => t.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)))
        {
            var dtme = new DataType
                           {
                               Id = vEntity.ObjectId.ToString(),
                               Name = vEntity.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                               UniqueName = vEntity.UniqueName,
                               NodeType = NodeType.Entity,
                               SelectedAllChilde = false
                           };

            TreeNode nodeEntity = GetNode(dtme);

            AddForms(ref nodeEntity, vEntity);
            AddViews(ref nodeEntity, vEntity);
            AddAttributes(ref nodeEntity, vEntity);
            AddLabels(ref nodeEntity, vEntity);
            AddWf(ref nodeEntity, vEntity);
            if (vEntity.IsDataExportable)
                AddData(ref nodeEntity, vEntity);
            treeNodeEntity.Nodes.Add(nodeEntity);
        }

        rootNode.Nodes.Add(treeNodeEntity);
    }

    public void FillReportNodes(ref TreeNode rootNode)
    {
        var dtm = new DataType
        {
            Id = Guid.Empty.ToString(),
            Name = "All Reports",
            UniqueName = "All Reports",
            NodeType = NodeType.AllReports,
            SelectedAllChilde = false,
            
        };
        TreeNode treeNodeAllPlugin = GetNode(dtm);

        var reportlist = new ReportsFactory();

        foreach (var report in reportlist.GetAllReportList())
        {
            var dtme = new DataType
                {
                    Id = report.ReportsId.ToString(),
                    Name = report.Description,
                    UniqueName = report.ReportName,
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

        var securityFactory = new SecurityFactory();

        foreach (var role in securityFactory.GetRoles())
        {
            var dtme = new DataType
            {
                Id = role.RoleId.ToString(),
                Name = role.Name,
                UniqueName = role.RoleId.ToString(),
                NodeType = NodeType.SecurityRole,
                SelectedAllChilde = false
            };

            TreeNode nodePlugin = GetNode(dtme);
            treeNodeAllPlugin.Nodes.Add(nodePlugin);
        }

        rootNode.Nodes.Add(treeNodeAllPlugin);
    }
    public void FillPluginNodes(ref TreeNode rootNode)
    {
        var dtm = new DataType
                      {
                          Id = Guid.Empty.ToString(),
                          Name = "All Plugins",
                          UniqueName = "All Plugins",
                          NodeType = NodeType.AllPlugin,
                          SelectedAllChilde = false
                      };
        TreeNode treeNodeAllPlugin = GetNode(dtm);

        foreach (PluginDll pluginDll in App.Params.CurrentPlugins.Values)
        {
            var dtme = new DataType
                           {
                               Id = pluginDll.PluginDllId.ToString(),
                               Name = pluginDll.Name,
                               UniqueName = pluginDll.Name,
                               NodeType = NodeType.Plugin,
                               SelectedAllChilde = false
                           };

            TreeNode nodePlugin = GetNode(dtme);
            treeNodeAllPlugin.Nodes.Add(nodePlugin);
        }

        rootNode.Nodes.Add(treeNodeAllPlugin);
    }

    public void AddForms(ref TreeNode node, Entity vEntity)
    {
        var dtmf = new DataType
                       {
                           Id = vEntity.ObjectId.ToString(),
                           Name = "Forms",
                           UniqueName = "Forms",
                           NodeType = NodeType.AllForm,
                           SelectedAllChilde = false
                       };
        TreeNode fNode = GetNode(dtmf);
        foreach (Form form in App.Params.CurrentForms.Values.Where(t => t.ObjectId == vEntity.ObjectId))
        {
            var dtmfa = new DataType
                            {
                                Id = form.FormId.ToString(),
                                Name = form.Name,
                                UniqueName = form.Name,
                                NodeType = NodeType.Form,
                                SelectedAllChilde = false
                            };
            TreeNode fNodea = GetNode(dtmfa);

            fNode.Nodes.Add(fNodea);
        }
        node.Nodes.Add(fNode);
    }

    public void AddViews(ref TreeNode node, Entity vEntity)
    {
        var dtmav = new DataType
                        {
                            Id = vEntity.ObjectId.ToString(),
                            Name = "Views",
                            UniqueName = "Views",
                            NodeType = NodeType.AllView,
                            SelectedAllChilde = false
                        };
        TreeNode vNode = GetNode(dtmav);

        foreach (View view in App.Params.CurrentView.Values.Where(t => t.ObjectId == vEntity.ObjectId))
        {
            var dtmfa = new DataType
                            {
                                Id = view.ViewQueryId.ToString(),
                                Name = view.Name,
                                UniqueName = view.Name,
                                NodeType = NodeType.View,
                                SelectedAllChilde = false
                            };
            TreeNode vNodea = GetNode(dtmfa);
            vNode.Nodes.Add(vNodea);
        }
        node.Nodes.Add(vNode);
    }

    public void AddAttributes(ref TreeNode node, Entity vEntity)
    {
        var dtmf = new DataType
                       {
                           Id = vEntity.ObjectId.ToString(),
                           Name = "Attributes",
                           UniqueName = "Attributes",
                           NodeType = NodeType.EntityAttribute,
                           SelectedAllChilde = false
                       };
        TreeNode aNode = GetNode(dtmf);
        node.Nodes.Add(aNode);
    }

    public void AddLabels(ref TreeNode node, Entity vEntity)
    {
        var dtmf = new DataType
                       {
                           Id = vEntity.ObjectId.ToString(),
                           Name = "Label",
                           UniqueName = "Label",
                           NodeType = NodeType.Label,
                           SelectedAllChilde = false
                       };
        TreeNode lNode = GetNode(dtmf);
        node.Nodes.Add(lNode);
    }

    public void AddWf(ref TreeNode node, Entity vEntity)
    {
        var dtmAwf = new DataType
                         {
                             Id = vEntity.ObjectId.ToString(),
                             Name = "All Wfs",
                             UniqueName = "All Wfs",
                             NodeType = NodeType.AllWf,
                             SelectedAllChilde = false
                         };
        TreeNode wfaNode = GetNode(dtmAwf);
        foreach (WorkFlow wf in App.Params.CurrentWorkFlow.Values.Where(t => t.Entity == vEntity.EntityId))
        {
            var dtmwf = new DataType
                            {
                                Id = wf.WorkflowId.ToString(),
                                Name = wf.WorkflowName,
                                UniqueName = wf.WorkflowName,
                                NodeType = NodeType.Wf,
                                SelectedAllChilde = false
                            };
            TreeNode wfNodea = GetNode(dtmwf);

            wfaNode.Nodes.Add(wfNodea);
        }
        node.Nodes.Add(wfaNode);
    }
    public void AddData(ref TreeNode node, Entity vEntity)
    {
        var dynamicFactory = new DynamicFactory(ERunInUser.SystemAdmin);
            
        var dtmData = new DataType
        {
            Id = vEntity.ObjectId.ToString(),
            Name = "All Data",
            UniqueName = "All Data",
            NodeType = NodeType.AllData,
            SelectedAllChilde = false
        };
        TreeNode wfaNode = GetNode(dtmData);
        foreach (Lookup lkp in dynamicFactory.GetAllDataLookupFromEntity(vEntity.ObjectId))
        {
            var dtmwf = new DataType
            {
                Id = lkp.Value.ToString(),
                Name = lkp.name,
                UniqueName = "Data Item",
                NodeType = NodeType.DataItem,
                SelectedAllChilde = false
            };
            TreeNode wfNodea = GetNode(dtmwf);

            wfaNode.Nodes.Add(wfNodea);
        }
        node.Nodes.Add(wfaNode);
    }
    public TreeNode GetNode(DataType dataType)
    {
        var node = new TreeNode { Checked = false };

        AddDataType(dataType, ref node);
        switch (dataType.NodeType)
        {
            case NodeType.Root:
                node.Icon = Icon.PageGo;
                break;
            case NodeType.AllEntity:
                if (_selectedSchema.EntityList != null && _selectedSchema.EntityList.Count > 0)
                    node.Checked = true;
                node.Icon = Icon.PageGo;
                break;
            case NodeType.Entity:
                node.Icon = Icon.Table;
                foreach (
                    ExportEntitySchema vare in
                        _selectedSchema.EntityList.Where(e => e.EEntity == ValidationHelper.GetInteger(dataType.Id)))
                {
                    node.Checked = true;
                }

                break;
            case NodeType.EntityAttribute:
                node.Icon = Icon.TextIndent;
                node.Leaf = true;
                foreach (
                    ExportEntitySchema vare in
                        _selectedSchema.EntityList.Where(e => e.EEntity == ValidationHelper.GetInteger(dataType.Id)))
                {
                    node.Checked = vare.EaList;
                }
                break;
            case NodeType.AllForm:
                node.Icon = Icon.ApplicationFormAdd;
                node.Leaf = false;

                foreach (
                    ExportEntitySchema vare in
                        _selectedSchema.EntityList.Where(e => e.EEntity == ValidationHelper.GetInteger(dataType.Id)))
                {
                    if (vare.EFormList != null && vare.EFormList.Count > 0)
                        node.Checked = true;
                }
                break;

            case NodeType.Form:
                node.Icon = Icon.ApplicationForm;
                node.Leaf = true;
                foreach (ExportEntitySchema vare in from vare in _selectedSchema.EntityList
                                                    from guid in
                                                        vare.EFormList.Where(
                                                            ea => ea == ValidationHelper.GetGuid(dataType.Id))
                                                    select vare)
                {
                    node.Checked = true;
                }
                break;
            case NodeType.AllView:
                node.Icon = Icon.ApplicationViewList;
                node.Leaf = false;
                foreach (
                    ExportEntitySchema vare in
                        _selectedSchema.EntityList.Where(e => e.EEntity == ValidationHelper.GetInteger(dataType.Id)))
                {
                    if (vare.EViewList != null && vare.EViewList.Count > 0)
                        node.Checked = true;
                }
                break;
            case NodeType.View:
                node.Icon = Icon.ApplicationForm;
                node.Leaf = true;
                foreach (ExportEntitySchema vare in from vare in _selectedSchema.EntityList
                                                    from guid in
                                                        vare.EViewList.Where(
                                                            ea => ea == ValidationHelper.GetGuid(dataType.Id))
                                                    select vare)
                {
                    node.Checked = true;
                }
                break;
            case NodeType.AllWf:
                node.Icon = Icon.ArrowLeft;
                node.Leaf = false;
                foreach (
                    ExportEntitySchema vare in
                        _selectedSchema.EntityList.Where(e => e.EEntity == ValidationHelper.GetInteger(dataType.Id)))
                {
                    if (vare.EWorkFlowList != null && vare.EWorkFlowList.Count > 0)
                        node.Checked = true;
                }
                break;
            case NodeType.Wf:
                node.Icon = Icon.ArrowLeft;
                node.Leaf = true;
                foreach (ExportEntitySchema vare in from vare in _selectedSchema.EntityList
                                                    from guid in
                                                        vare.EWorkFlowList.Where(
                                                            ea => ea == ValidationHelper.GetGuid(dataType.Id))
                                                    select vare)
                {
                    node.Checked = true;
                }
                break;
            case NodeType.Label:
                node.Icon = Icon.PageWhiteText;
                node.Leaf = true;
                foreach (
                    ExportEntitySchema vare in
                        _selectedSchema.EntityList.Where(
                            e => e.EEntity == ValidationHelper.GetInteger(dataType.Id) && e.ELabelMessage))
                {
                    node.Checked = true;
                }
                break;
            case NodeType.AllPlugin:
                node.Icon = Icon.PluginEdit;
                node.Leaf = false;
                if (_selectedSchema.PluginList != null && _selectedSchema.PluginList.Count > 0)
                {
                    node.Checked = true;
                }
                break;
            case NodeType.Plugin:
                node.Icon = Icon.Plugin;
                node.Leaf = true;
                foreach (ExportPluginSchema exportPluginSchema in
                    _selectedSchema.PluginList.Where(eps => eps.PDll == ValidationHelper.GetGuid(dataType.Id)))
                {
                    node.Checked = true;
                }
                break;
            case NodeType.AllReports:
                node.Icon = Icon.ReportEdit;
                node.Leaf = false;
                if (_selectedSchema.ReportList != null && _selectedSchema.ReportList.Count > 0)
                {
                    node.Checked = true;
                }
                break;

            case NodeType.Report:
                node.Icon = Icon.Report;
                node.Leaf = true;
                foreach (Report report in
                    _selectedSchema.ReportList.Where(r => r.ReportsId == ValidationHelper.GetGuid(dataType.Id)))
                {
                    node.Checked = true;
                }
                break;
            case NodeType.AllSecurityRole:
                node.Icon = Icon.UserKey;
                node.Leaf = false;
                if (_selectedSchema.SecurityRoleList != null && _selectedSchema.SecurityRoleList.Count > 0)
                {
                    node.Checked = true;
                }
                break;
            case NodeType.SecurityRole:
                node.Icon = Icon.UserB;
                node.Leaf = true;
                foreach (Guid sr in
                    _selectedSchema.SecurityRoleList.Where(r => r == ValidationHelper.GetGuid(dataType.Id)))
                {
                    node.Checked = true;
                }
                break;
            case NodeType.AllData:
                node.Icon = Icon.Database;
                node.Leaf = false;
                foreach (
                    ExportEntitySchema vare in
                        _selectedSchema.EntityList.Where(e => e.EEntity == ValidationHelper.GetInteger(dataType.Id)))
                {
                    if (vare.EData)
                        node.Checked = true;
                }
                break;
            case NodeType.DataItem:
                node.Icon = Icon.DatabaseKey;
                node.Leaf = true;
                foreach (ExportEntitySchema vare in  _selectedSchema.EntityList)
                {
                    foreach (Guid guid in vare.EDataList.Where(guid => guid.ToString().ToUpper()==dataType.Id.ToUpper()))
                    {
                        node.Checked = true;
                    }
                        
                }
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

    public DataType GetDataType(List<ConfigItem> items)
    {
        var ret = new DataType();
        foreach (ConfigItem configItem in items)
        {
            switch (configItem.Name)
            {
                case "Id":
                    ret.Id = configItem.Value;
                    break;
                case "Name":
                    ret.Name = configItem.Value;
                    break;
                case "UniqueName":
                    ret.UniqueName = configItem.Value;
                    break;
                case "NodeType":
                    ret.NodeType = (NodeType)ValidationHelper.GetInteger(configItem.Value);
                    break;
            }
        }
        return ret;
    }

    private void ConvertCheckedNodes(IEnumerable<TreeGrid.CheckedNodesCls> checkedNodesCls, ref object parentExportNode)
    {
        foreach (TreeGrid.CheckedNodesCls item in checkedNodesCls)
        {
            DataType dataType = GetDataType(item.ConfigItems);
            object activeObject = null;
            switch (dataType.NodeType)
            {
                case NodeType.Root:

                    object nactiveObject = null;

                    nactiveObject = parentExportNode;
                    ((ExportImportSchema)nactiveObject).Name = PackageName.Value;
                    ((ExportImportSchema)nactiveObject).ExportDate = DateTime.UtcNow;


                    activeObject = nactiveObject;
                    break;
                case NodeType.AllEntity:
                    ((ExportImportSchema)parentExportNode).EntityList = new List<ExportEntitySchema>();
                    activeObject = ((ExportImportSchema)parentExportNode).EntityList;

                    break;
                case NodeType.Entity:

                    var entityList = (List<ExportEntitySchema>)parentExportNode;
                    var newNode = new ExportEntitySchema();
                    newNode.EEntity = ValidationHelper.GetInteger(dataType.Id, 0);
                    entityList.Add(newNode);
                    activeObject = newNode;

                    break;
                case NodeType.EntityAttribute:

                    var myEntity = (ExportEntitySchema)parentExportNode;
                    myEntity.EaList = true;

                    break;
                case NodeType.AllForm:

                    var myEntityForm = (ExportEntitySchema)parentExportNode;
                    myEntityForm.EFormList = new List<Guid>();
                    activeObject = myEntityForm.EFormList;

                    break;
                case NodeType.Form:
                    var formList = (List<Guid>)parentExportNode;
                    formList.Add(ValidationHelper.GetGuid(dataType.Id));
                    break;

                case NodeType.AllView:
                    var myEntityView = (ExportEntitySchema)parentExportNode;
                    myEntityView.EViewList = new List<Guid>();
                    activeObject = myEntityView.EViewList;
                    break;

                case NodeType.View:
                    var viewList = (List<Guid>)parentExportNode;
                    viewList.Add(ValidationHelper.GetGuid(dataType.Id));
                    break;
                case NodeType.AllWf:
                    var myWfEntity = (ExportEntitySchema)parentExportNode;
                    myWfEntity.EWorkFlowList = new List<Guid>();
                    activeObject = myWfEntity.EWorkFlowList;
                    break;
                case NodeType.Wf:
                    var wfList = (List<Guid>)parentExportNode;
                    wfList.Add(ValidationHelper.GetGuid(dataType.Id));
                    break;

                case NodeType.Label:
                    var myLabelEntity = (ExportEntitySchema)parentExportNode;
                    myLabelEntity.ELabelMessage = true;
                    break;
                case NodeType.AllPlugin:
                    ((ExportImportSchema)parentExportNode).PluginList = new List<ExportPluginSchema>();
                    activeObject = ((ExportImportSchema)parentExportNode).PluginList;
                    break;

                case NodeType.Plugin:
                    var plist = (List<ExportPluginSchema>)parentExportNode;
                    var nplugin = new ExportPluginSchema
                                      {
                                          PDll = ValidationHelper.GetGuid(dataType.Id),
                                      };

                    plist.Add(nplugin);

                    break;
                case NodeType.AllReports:
                    ((ExportImportSchema)parentExportNode).ReportList = new List<Report>();
                    activeObject = ((ExportImportSchema)parentExportNode).ReportList;
                    break;

                case NodeType.Report:
                    var rlist = (List<Report>)parentExportNode;
                    var rlistItem = new Report
                                      {
                                          ReportsId = ValidationHelper.GetGuid(dataType.Id),
                                      };

                    rlist.Add(rlistItem);

                    break;
                case NodeType.AllSecurityRole:
                    ((ExportImportSchema)parentExportNode).SecurityRoleList = new List<Guid>();
                    activeObject = ((ExportImportSchema)parentExportNode).SecurityRoleList;
                    break;
                case NodeType.SecurityRole:
                    var srl = (List<Guid>)parentExportNode;
                    srl.Add(ValidationHelper.GetGuid(dataType.Id));
                    break;
                case NodeType.AllData:
                    var myEntityD = (ExportEntitySchema)parentExportNode;
                    myEntityD.EData = true;
                    myEntityD.EDataList=new List<Guid>();
                    activeObject = myEntityD.EDataList;
                    break;
                case NodeType.DataItem:
                    var myData =  (List<Guid>)parentExportNode;
                    myData.Add(ValidationHelper.GetGuid(dataType.Id));
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
            if (activeObject != null)
                ConvertCheckedNodes(item.Nodes, ref activeObject);
        }
    }
}
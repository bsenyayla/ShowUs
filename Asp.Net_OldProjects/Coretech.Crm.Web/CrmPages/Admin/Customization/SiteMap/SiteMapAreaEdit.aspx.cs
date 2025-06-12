using System;
using System.Collections.Generic;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Site;
using Coretech.Crm.Objects.Crm.ExportImport;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Site;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;

public partial class CrmPages_Admin_Customization_SiteMap_SiteMapAreaEdit : Coretech.Crm.Web.UI.RefleX.BasePage
{
    private void TranslateMessage()
    {
        New.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_NEW);
        Save.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_SAVE);
        Delete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_DELETE);

        SiteMap.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_SITEMAP);
        SiteMapAreaHref.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_SITEMAPAREAHREF);
        SiteMapAreaLabelName.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_LABELNAME);
        ParentSiteMapArea.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_PARENTSITEMAPAREA);
        SiteMapAreaDisplayOrder.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_SITEMAPAREADISPLAYORDER);
        EntityList.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_ENTITYLIST);
        PriEntityList.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_PRIVLEGEENTITYLIST);
        ImageHref.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_IMAGEHREF);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (RefleX.IsAjxPostback)
        {
            TranslateMessage();
        }
    }

    public void AddDataType(int objectId, string label, ref TreeNode node, NodeType nodeType)
    {
        node.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapTitle", Value = objectId.ToString() });
        node.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapAreaTitle", Value = label });
        node.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "IsvHref", Value = label });
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            GetTree();
        }
        base.OnPreInit(e);
    }
    private List<Guid> AddedList = new List<Guid>();
    private void GetSubTree(Guid ParentSiteMapAreaId, IEnumerable<SiteMapArea> m, TreeNode treeNodeRoot)
    {
        foreach (var me in m)
        {
            if (me.ParentSiteMapAreaId == ParentSiteMapAreaId)
            {
                var subNode = new TreeNode();

                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapTitle", Value = me.IsvLabel });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "IsvHref", Value = me.IsvHref });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "EntityId", Value = me.EntityId.ToString() });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "PrivilegeEntityId", Value = me.PrivilegeEntityId.ToString() });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapId", Value = me.SiteMapId.ToString() });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "DisplayOrder", Value = me.DisplayOrder.ToString() });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "LabelName", Value = me.LabelName });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapAreaId", Value = me.SiteMapAreaId.ToString() });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "ParentSiteMapArea", Value = me.ParentSiteMapAreaId.ToString() });
                subNode.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "ImageHref", Value = me.ImageHref.ToString() });

                foreach (var siteMapArea in m)
                {
                    if (siteMapArea.ParentSiteMapAreaId == me.SiteMapAreaId && !AddedList.Contains(me.SiteMapAreaId))
                    {
                        AddedList.Add(me.SiteMapAreaId);
                        GetSubTree(me.SiteMapAreaId, m, subNode);
                    }

                }

                treeNodeRoot.Nodes.Add(subNode);

            }

        }
    }

    private void GetTree()
    {
        var mlist = (new ModulesFactory()).GetUserModules(false);

        var tRoot = new TreeNode { Icon = Icon.ApplicationViewList };

        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapTitle", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "IsvHref", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "EntityId", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "PrivilegeEntityId", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapId", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "DisplayOrder", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "LabelName", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapAreaId", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "ParentSiteMapArea", Value = "" });
        tRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "ImageHref", Value = "" });

        for (int i = mlist.Count - 1; i >= 0; i--)
        {
            var m = mlist[i];
            var treeNodeRoot = new TreeNode { Icon = Icon.Page };

            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapTitle", Value = m.Label });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "IsvHref", Value = "" });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "EntityId", Value = "" });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "PrivilegeEntityId", Value = "" });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapId", Value = "" });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "DisplayOrder", Value = "" });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "LabelName", Value = "" });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "SiteMapAreaId", Value = "" });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "ParentSiteMapArea", Value = "" });
            treeNodeRoot.CustomAttributes.Add(new ConfigItem { Mode = EpMode.Value, Name = "ImageHref", Value = "" });

            GetSubTree(Guid.Empty, m.SiteMapAreas, treeNodeRoot);

            tRoot.Nodes.Add(treeNodeRoot);
        }
        TreeGrid1.Root.Nodes.Add(tRoot);
    }




    protected void RowClickOnEvent(object sender, AjaxEventArgs e)
    {
        SiteMapAreaId.Clear();
        EntityList.Clear();
        PriEntityList.Clear();
        ParentSiteMapArea.Clear();
        SiteMap.Clear();
        SiteMapAreaHref.Clear();
        SiteMapAreaDisplayOrder.Clear();
        SiteMapAreaLabelName.Clear();
        SiteMapAreaLabelName.SetDisabled(true);

        SiteMapAreaHref.SetValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[1].Value));
        EntityList.SetIValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[2].Value));
        PriEntityList.SetIValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[3].Value));
        SiteMap.SetIValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[4].Value));
        SiteMapAreaDisplayOrder.SetValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[5].Value));
        SiteMapAreaLabelName.SetValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[6].Value));
        SiteMapAreaId.SetValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[7].Value));
        ParentSiteMapArea.SetIValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[8].Value));
        ImageHref.SetIValue(ValidationHelper.GetString(TreeGrid1.SelectedNode[9].Value));
    }

    protected void SaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(SiteMap.Value))
            {
                var mf = new ModulesFactory();
                mf.SaveSiteMapAreaItem(
                    ValidationHelper.GetGuid(SiteMapAreaId.Value),
                    ValidationHelper.GetGuid(SiteMap.Value),
                    ValidationHelper.GetGuid(EntityList.Value),
                    ValidationHelper.GetGuid(PriEntityList.Value),
                    ValidationHelper.GetGuid(ParentSiteMapArea.Value),
                    ValidationHelper.GetInteger(SiteMapAreaDisplayOrder.Value, 0),
                    string.IsNullOrEmpty(EntityList.Value) ? false : true,
                    ValidationHelper.GetString(ImageHref.Value), 
                    ValidationHelper.GetString(SiteMapAreaHref.Value),
                    ValidationHelper.GetString(SiteMapAreaLabelName.Value)
                    );
                NewOnEvent(null, e);
            }
            else
            {
                new MessageBox(CrmLabel.TranslateMessage(LabelEnum.CRM_SITEMAP_SITEMAP) + " " + CrmLabel.TranslateMessage("CRM_FIELD_REQUIRED"));
            }
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
        }
    }

    protected void DeleteOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(SiteMapAreaId.Value))
            {
                var mf = new ModulesFactory();
                mf.DeleteSiteMapAreaItem(ValidationHelper.GetGuid(SiteMapAreaId.Value));
                NewOnEvent(null, e);
            }
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
        }
    }

    protected void NewOnEvent(object sender, AjaxEventArgs e)
    {
        SiteMapAreaId.Clear();
        EntityList.Clear();
        PriEntityList.Clear();
        ParentSiteMapArea.Clear();
        SiteMap.Clear();
        SiteMapAreaHref.Clear();
        SiteMapAreaDisplayOrder.Clear();
        SiteMapAreaLabelName.Clear();
        ImageHref.Clear();
        SiteMapAreaLabelName.SetDisabled(false);
    }
    protected void GetPriEntityListData(object sender, AjaxEventArgs e)
    {
        var ef = new EntityFactory();
        PriEntityList.DataSource = ef.GetEntityList();
        PriEntityList.DataBind();
    }
    protected void GetEntityListData(object sender, AjaxEventArgs e)
    {
        var ef = new EntityFactory();
        EntityList.DataSource = ef.GetEntityList();
        EntityList.DataBind();
    }
    protected void GetParentSiteMapAreaData(object sender, AjaxEventArgs e)
    {
        var mf = new ModulesFactory();
        ParentSiteMapArea.DataSource = mf.GetUserAllSiteMapArea(ValidationHelper.GetGuid(SiteMap.Value));
        ParentSiteMapArea.DataBind();
    }

    protected void GetSiteMapData(object sender, AjaxEventArgs e)
    {
        var mf = new ModulesFactory();
        SiteMap.DataSource = mf.GetUserSiteMapCombo(false);
        SiteMap.DataBind();
    }
}
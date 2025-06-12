using System;
using System.Collections.Generic;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Labels;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Users;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Crm.Form;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;

public partial class CrmPages_Admin_Customization_Entity_Property_ViewEdit : AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_ViewEdit()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!Page.IsPostBack && !Ext.IsAjaxRequest)
        {
            hdnObjectId.Text = QueryHelper.GetString("ObjectId");
            hdnFormEditType.Text = QueryHelper.GetString("Id") != string.Empty ? "1" : "0";

            hdnId.Text = (QueryHelper.GetString("Id") != string.Empty)
                             ? QueryHelper.GetString("Id")
                             : Guid.NewGuid().ToString();
            if (hdnFormEditType.Text == "1")
            {
                FillPage();
            }
            else
            {
                //AddRootNode();
                //FillAdministrationBase();
            }
            FillViewLabel();
        }
    }

    private void FillPage()
    {
        var vf = new ViewFactory();
        var view = vf.GetView(ValidationHelper.GetGuid(hdnId.Text));
        var vb = vf.GetAllViewButtons();
        if (view != null)
        {
            NewViewName.Text = view.Name;
            UniqueName.Text = view.UniqueName;
            ViewType.Value = view.QueryType.ToString();
            ExtenderType.Value = view.ExtenderType.ToString();
            txtDisplayOrder.Number = ValidationHelper.GetInteger(view.DisplayOrder, 0);
            txtUserControl.Text = ValidationHelper.GetString(view.UserControl);
            if (view.DefaultEditPage != Guid.Empty)
                cmbDefaultEditPage.Value = view.DefaultEditPage.ToString();
            if (view.LabelMessageId != Guid.Empty)
                CmbViewLabel.Value = view.LabelMessageId.ToString();
            DefaultView.Checked = view.IsSysyemView;
            UseNolock.Checked = view.UseNolock;
            StoreViewAttributeLoad(view.FilterEntity, view.ColumnSet);
            StoreOrderByLoad(view.ColumnSet);
            CBuilder.ParseFilterEntity(view.FilterEntity);
            UpdateBttonDataSource(vb, view.Buttons);

            //cmbOwningUser.Value = view.OwningUser.ToString();
            //cmbOwningBusinessUnit.Value = view.OwningBusinessUnit.ToString();

        }
        StoreGrdButtons.DataSource = vb;
        StoreGrdButtons.DataBind();

    }
    void UpdateBttonDataSource(List<ViewButton> vb, string strXml)
    {
        var vbr = ViewButton.XmlDeSerializeViewButtonList(strXml);
        foreach (var item in vbr)
        {
            for (int i = 0; i < vb.Count; i++)
            {
                if (item.ButtonId == vb[i].ButtonId)
                {
                    vb[i].IsHide = true;
                    break;
                }
            }
        }
    }
    protected void StorecmbDefaultEditPage_OnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var formFactory = new FormFactory();
        var nflist = formFactory.GetFormListByObjectId(ValidationHelper.GetInteger(hdnObjectId.Text, 0));
        var l = new List<object>();
        foreach (var form in nflist)
        {
            l.Add(new { FormId = form.FormId, Name = form.Name });
        }
        StorecmbDefaultEditPage.DataSource = l;
        StorecmbDefaultEditPage.DataBind();
    }


    private void StoreOrderByLoad(IEnumerable<ViewEntityAttribute> vea)
    {
        var vlist = new List<object>();

        foreach (var item in vea.Where(item => item.OrderNumber != null).OrderBy(item => item.OrderNumber))
        {
            vlist.Add(new
            {
                item.AttributeId,
                item.Label,
                item.Direction,
                item.UniqueName,
                DirectionLabel = item.Direction == "0" ? "ASC" : "DESC"
            }
                );
        }

        storeOrderBy.DataSource = vlist;
        storeOrderBy.DataBind();
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="femain">Entity Hierarchy </param>
    /// <param name="vea">Selected Attribute </param>
    private void StoreViewAttributeLoad(FilterEntity femain, List<ViewEntityAttribute> vea)
    {
        var vlist = new List<ViewEntityAttribute>();
        GetSubEntities(femain, ref vlist);
        for (int i = 0; i < vea.Count; i++)
        {
            vea[i].Label = "(" + vea[i].ObjectAlias + ")" +
                   App.Params.CurrentEntityAttribute[vea[i].AttributeId].GetLabelWithUniqueName(
                       App.Params.CurrentUser.LanguageId);

        }
        if (vea.Count == 0)
        {
            StoreViewAttribute.DataSource = vlist;
            StoreViewAttribute.DataBind();
        }
        else
        {
            var selectetItemCol = new List<ViewEntityAttribute>();

            for (int i = 0; i < vea.Count; i++)
            {
                var item1 = vea[i];
                var selectList =
                    from s in vlist
                    where s.AttributeId == item1.AttributeId && s.ObjectAlias == item1.ObjectAlias
                    select s;
                selectetItemCol.AddRange(selectList);
            }
            foreach (var item in selectetItemCol)
            {
                vlist.Remove(item);
            }

            StoreViewAttributeSelected.DataSource = vea;
            StoreViewAttributeSelected.DataBind();
            StoreViewAttribute.DataSource = vlist;
            StoreViewAttribute.DataBind();
        }
    }

    void GetSubEntities(FilterEntity fe, ref List<ViewEntityAttribute> vea)
    {
        if (fe.type == "Entity")
        {

            var vf = new ViewFactory();

            if (vea == null)
                vea = new List<ViewEntityAttribute>();

            var vlist = vf.GetViewAttributeList(fe.objectid);
            foreach (var item in vlist)
            {
                item.Label = "(" + fe.objectAlias + ")" +
                   App.Params.CurrentEntityAttribute[item.AttributeId].GetLabelWithUniqueName(
                       App.Params.CurrentUser.LanguageId);

                item.ObjectAlias = fe.objectAlias;
            }
            vea.AddRange(vlist);
            foreach (var filterEntity in fe.FilterEntityList)
            {
                GetSubEntities(filterEntity, ref vea);
            }
        }

    }
    protected void SubmitData(object sender, StoreSubmitDataEventArgs e)
    {
        string a = NewViewName.Text;
        string json = e.Json;
        var xml = e.Xml;
        var ViewEntit = e.Object<ViewEntityAttribute>();
    }
    protected void StoreUOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        //var uf = new UsersFactory();
        //StoreUser.DataSource = uf.GetUserList();
        //StoreUser.DataBind();
    }
    protected void StoreBuOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        //var uf = new UsersFactory();
        //StoreBu.DataSource = uf.GetBusinessUnitList();
        //StoreBu.DataBind();
    }
    //public void FillAdministrationBase()
    //{
    //    cmbOwningUser.Value = App.Params.CurrentUser.SystemUserId.ToString();
    //    cmbOwningBusinessUnit.Value = App.Params.CurrentUser.BusinessUnitId.ToString();
    //    btnShare.Disabled = false;
    //}
    protected void BtnCopyView_OnClikc(object sender, AjaxEventArgs e)
    {
        if (hdnId.Text != string.Empty)
        {
            var vf = new ViewFactory();
            var view = vf.GetView(ValidationHelper.GetGuid(hdnId.Text));
            view.Name = "cc_" + view.Name;
            view.UniqueName = "";
            view.ViewQueryId = GuidHelper.Newfoid(EntityEnum.ViewQuery.GetHashCode());
            var rt = vf.InsertUpdateView(view);
            Response.Redirect(string.Format("ViewEdit.aspx?ObjectId={0}&Id={1}", view.ObjectId, view.ViewQueryId));
        }
    }
    public void FillViewLabel()
    {
        var labelsFactory = new LabelsFactory();
        var llist = labelsFactory.GetLabelMessagebyObjectId(ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        foreach (var labelMessage in llist)
        {
            CmbViewLabel.Items.Add(new ListItem(labelMessage.LabelName, labelMessage.LabelMessageId.ToString()));
        }
    }
    [AjaxMethod(ShowMask = true)]
    public string UpdateView(string gpXml, string tpXml, string btnXml)
    {
        var view = new View
        {
            ColumnSetXml = gpXml,
            ObjectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0),
            QueryType = ValidationHelper.GetInteger(QueryType.PublicView, 0),
            ViewQueryId = ValidationHelper.GetGuid(hdnId.Value),
            Name = NewViewName.Text,
            UniqueName = ValidationHelper.GetString(UniqueName.Value),
            DisplayOrder = ValidationHelper.GetInteger(txtDisplayOrder.Value),
            FetchXml = tpXml,
            IsSysyemView = DefaultView.Checked,
            OwningBusinessUnit = App.Params.CurrentUser.BusinessUnitId,//ValidationHelper.GetGuid(cmbOwningBusinessUnit.SelectedItem.Value),
            OwningUser = App.Params.CurrentUser.SystemUserId,//ValidationHelper.GetGuid(cmbOwningUser.SelectedItem.Value),
            LabelMessageId = ValidationHelper.GetGuid(CmbViewLabel.SelectedItem.Value),
            UseNolock = UseNolock.Checked
        };
        view.QueryType = ValidationHelper.GetInteger(ViewType.SelectedItem.Value, 0); /*0-2 */
        view.ExtenderType = ValidationHelper.GetInteger(ExtenderType.SelectedItem.Value, 0); /*0-2 */

        var vf = new ViewFactory();
        view.Buttons = ViewButton.XmlSerializeViewButtonList(vf.ConvertXmlToViewButton(btnXml));
        vf.InsertUpdateView(view);


        string s = gpXml;

        return s;
    }
}
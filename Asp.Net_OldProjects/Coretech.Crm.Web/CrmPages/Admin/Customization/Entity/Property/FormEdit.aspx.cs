using System;
using System.Collections.Generic;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Form;
using Coretech.Crm.Factory.Crm.Labels;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Form;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Provider;

public partial class CrmPages_Admin_Customization_Entity_Property_FormEdit : AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_FormEdit()
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
            hdnFormId.Text = QueryHelper.GetString("FormId");
            hdnObjectId.Text = QueryHelper.GetString("ObjectId");
            if (string.IsNullOrEmpty(hdnFormId.Text))
                hdnFormId.Text = Guid.NewGuid().ToString();

            hdnFormEditType.Text = QueryHelper.GetString("FormId") != string.Empty ? "1" : "0";

            if (hdnFormEditType.Text == "1")
            {
                FillPage();
            }
            else
            {
                FillStoreViewAttribute();
                FillAdministrationBase();
            }
            SetActivityProperty();
            FillSectionLabel();
        }
    }
    private void SetActivityProperty()
    {
        var objectId = ValidationHelper.GetInteger(hdnObjectId.Text, 0);
        var ff = new FormFactory();
        if (App.Params.CurrentEntity[objectId].IsActivity)
        {
            cmbActivityType.Visible = true;
            foreach (var act in ff.GetActivityType(ValidationHelper.GetGuid(hdnFormId.Text)))
            {
                cmbActivityType.Items.Add(new ListItem(act.ActivitytypeName, act.ActivitytypeId.ToString()));
            }
        }
        else
        {
            cmbActivityType.Visible = false;
        }

    }
    private void FillPage()
    {
        var objectId = ValidationHelper.GetInteger(hdnObjectId.Text, 0);
        var myForm = new Form { FormId = ValidationHelper.GetGuid(hdnFormId.Text) };
        var ff = new FormFactory();
        myForm = ff.GetFormByFormId(myForm.FormId, objectId);
        txtFormName.Text = myForm.Name;
        nmbReleatedListHeigth.Value = ValidationHelper.GetDouble(myForm.ReleatedListHeigth);
        txrCustomEditForm.Value = myForm.CustomFormUrl;
        chkIsDefaultEditForm.Checked = myForm.IsDefaultEditForm;
        ChkDisableToolbar.Checked = myForm.DisableToolbar;
        if (myForm.LabelMessageId != Guid.Empty)
            CmbFormLabel.Value = myForm.LabelMessageId.ToString();
        storeSectionList.DataSource = myForm.Layout.FormTabs[0].LayoutXmlType;
        storeSectionList.DataBind();
        cmbOwningUser.Value = myForm.OwningUser.ToString();
        cmbOwningBusinessUnit.Value = myForm.OwningBusinessUnit.ToString();

        if (myForm.ActivitytypeId != Guid.Empty)
        {
            cmbActivityType.Value = myForm.ActivitytypeId.ToString();
        }
        var DeletedList = new List<object>();
        foreach (var guid in myForm.ColumnSetList)
        {
            if (App.Params.CurrentEntityAttribute.ContainsKey(guid))
            {
                DeletedList.Add(
                    new
                        {
                            AttributeId = guid,
                            Label =
                        App.Params.CurrentEntityAttribute[guid].GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                            UniqueName = App.Params.CurrentEntityAttribute[guid].Name
                        });
            }
        }
        StoreViewAttributeDeleted.DataSource = DeletedList;
        StoreViewAttributeDeleted.DataBind();

        var gridReleatedListData = new List<object>();
        foreach (var formReleatedList in myForm.ReleatedList)
        {

            gridReleatedListData.Add(new
                                         {
                                             formReleatedList.EntityRelationShipId,
                                             FilterList =
                                         formReleatedList.FilterList ?? new List<FormEntityAttributeFilter>(),
                                             FilterListXml = formReleatedList.FilterListXml ?? "",
                                             formReleatedList.IsEntity,
                                             Label = formReleatedList.Label ?? "",
                                             formReleatedList.LabelMessageId,
                                             LabelMessageIdName = formReleatedList.LabelMessageIdName ?? "",
                                             formReleatedList.ReleatedListId,
                                             formReleatedList.SortAttributeId,
                                             SortAttributeName = formReleatedList.SortAttributeName ?? "",
                                             Url = formReleatedList.Url ?? "",
                                             formReleatedList.ViewQueryId,
                                             ViewQueryIdName = formReleatedList.ViewQueryIdName ?? "",
                                             Name = formReleatedList.Name
                                         });
        }
        StoreGridReleatedList.DataSource = gridReleatedListData;
        StoreGridReleatedList.DataBind();

        chkUseIframeScript.Value = myForm.FormScript.UseIframe;
        txtIframeScriptUrl.Value = myForm.FormScript.IframeUrl;
        foreach (var formScript in myForm.FormScript.FormScripts)
        {
            switch (formScript.Type)
            {
                case FormScriptType.Onload:
                    chkOnLoadScript.Value = formScript.UseScript;
                    txtOnLoadScript.Value = formScript.Script;
                    OnloadClientWorkflow.Value = formScript.ClientWorkflowId.ToString();
                    break;
                case FormScriptType.BeforeSave:
                    chkBeforeSave.Value = formScript.UseScript;
                    txtBeforeSaveScript.Value = formScript.Script;
                    BeforeSaveClientWorkflow.Value = formScript.ClientWorkflowId.ToString();
                    break;
                case FormScriptType.AfterSave:
                    chkAfterSave.Value = formScript.UseScript;
                    txtAfterSaveScript.Value = formScript.Script;
                    AfterSaveClientWorkflow.Value = formScript.ClientWorkflowId.ToString();
                    break;
            }
        }
        FillStoreViewAttribute();

    }

    private void FillStoreViewAttribute()
    {
        var objectId = ValidationHelper.GetInteger(hdnObjectId.Text, 0);
        var vlist = new List<object>();

        foreach (var entityAttribute in
            App.Params.CurrentEntityAttribute.Values.Where(
                entityAttribute => entityAttribute.ObjectId == objectId && entityAttribute.AttributeOf == Guid.Empty))
        {
            vlist.Add(new
            {
                AttributeId = entityAttribute.AttributeId,
                Label = entityAttribute.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                UniqueName = entityAttribute.UniqueName
            });
        }


        StoreViewAttribute.DataSource = vlist;
        StoreViewAttribute.DataBind();

        StoreFromAttribute.DataSource = vlist;
        StoreFromAttribute.DataBind();

        /*Formlarin altindaki gosterilecek listerlerin releatin tablosundan cekilmesi*/
        var vf = new ViewFactory();
        StoreReleatedList.DataSource = vf.GetViewListReleatedByObjectId(ValidationHelper.GetInteger(hdnObjectId.Text, 0));
        StoreReleatedList.DataBind();


        foreach (var o in Enum.GetValues(typeof(RefleXFrameWork.Icon)))
        {
            cmbButtonImage.Items.Add(new ListItem(o.ToString(), o.GetHashCode().ToString()));
            cmbLabelImage.Items.Add(new ListItem(o.ToString(), o.GetHashCode().ToString()));
        }

        foreach (var value in App.Params.CurrentDynamicUrl.Values.Where(value => value.ObjectId == objectId))
        {
            cmbDynamicUrl.Items.Add(new ListItem(value.Name, value.DynamicUrlId.ToString()));
            cmbButtonUrl.Items.Add(new ListItem(value.Name, value.DynamicUrlId.ToString()));
        }
        foreach (var value in App.Params.CurrentWebServiceMethodCall.Values.Where(value => value.ObjectId == objectId))
        {
            cmbButtonWebService.Items.Add(new ListItem(value.Name, value.MethodCallId.ToString()));
        }
        foreach (var value in App.Params.CurrentWorkFlow.Values.Where(value => value.IsOnDemandWorkflow))
        {
            if (objectId == EntityFactory.GetEntityObjectId(value.Entity))
                cmbButtonOnDemandWorkflow.Items.Add(new ListItem(value.WorkflowName, value.WorkflowId.ToString()));
        }
        foreach (var value in App.Params.CurrentWorkFlow.Values.Where(value => value.IsClientWorkflow))
        {
            if (objectId == EntityFactory.GetEntityObjectId(value.Entity))
            {
                cmbClientWorkflow.Items.Add(new ListItem(value.WorkflowName, value.WorkflowId.ToString()));
                OnloadClientWorkflow.Items.Add(new ListItem(value.WorkflowName, value.WorkflowId.ToString()));
                BeforeSaveClientWorkflow.Items.Add(new ListItem(value.WorkflowName, value.WorkflowId.ToString()));
                AfterSaveClientWorkflow.Items.Add(new ListItem(value.WorkflowName, value.WorkflowId.ToString()));
            }
        }

    }

    protected void StoreViewerList_OnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var l = new List<object>();
        var strAttributeId = ValidationHelper.GetString(e.Parameters["attributeId"]);
        if (!string.IsNullOrEmpty(strAttributeId))
        {
            if (App.Params.CurrentEntityAttribute.ContainsKey(ValidationHelper.GetGuid(strAttributeId)))
            {
                var ea = App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(strAttributeId)];
                var refobjectId = ea.ReferencedObjectId;
                var attributeTypeIdname = ea.AttributeTypeIdname;
                var fv = new ViewFactory();
                if (attributeTypeIdname == "money")
                {
                    refobjectId = EntityEnum.Currency.GetHashCode();
                }
                else if (attributeTypeIdname == "uom")
                {
                    refobjectId = EntityEnum.Uom.GetHashCode();
                }
                if (refobjectId > 0)
                {
                    var readed = fv.GetViewListByObjectId(refobjectId);

                    foreach (var item in readed)
                    {
                        l.Add(new { Name=string.Format("({0})",item.ObjectId)+ item.Name, item.ViewQueryId });
                    }
                }


                foreach (var value in App.Params.CurrentView.Values) /*Amac-- Id si set edelin herhangi bir view in de listeden secilebilir olmasi*/
                {
                    var clist = value.ColumnSet;
                    var val = value;
                    if (value.ColumnSet == null)
                    {
                        clist = value.ColumnSet;
                    }
                    if (clist != null)
                    {
                        foreach (var viewEntityAttribute in clist) /*Linque Cevirme*/
                        {
                            if (viewEntityAttribute.IsIdColumn && App.Params.CurrentEntityAttribute[viewEntityAttribute.AttributeId].ReferencedObjectId == refobjectId)
                            {
                                l.Add(new { Name = string.Format("({0})", value.ObjectId) + value.Name, value.ViewQueryId });

                                break;
                            }
                        }
                    }
                }
            }
        }
        StoreViewerList.DataSource = l;
        StoreViewerList.DataBind();
    }

    protected void StoreMappathToAttribute_OnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var list = new List<object>();
        var viewId = ValidationHelper.GetGuid(e.Parameters["ViewId"]);
        if (viewId != Guid.Empty && App.Params.CurrentView.ContainsKey(viewId))
        {
            var objectId = App.Params.CurrentView[viewId].ObjectId;
            if (objectId > 0)
            {
                foreach (var entityAttribute in
                    App.Params.CurrentEntityAttribute.Where(
                        entityAttribute => entityAttribute.Value.ObjectId == objectId))
                {
                    list.Add(new
                    {
                        entityAttribute.Value.AttributeId,
                        Label =
                    entityAttribute.Value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                        entityAttribute.Value.UniqueName
                    });
                }
            }
        }
        StoreMappathToAttribute.DataSource = list;
        StoreMappathToAttribute.DataBind();
    }

    protected void StoreToAttribute_OnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var list = new List<object>();
        var attributeId = ValidationHelper.GetGuid(e.Parameters["EaId"]);
        var viewId = ValidationHelper.GetGuid(e.Parameters["ViewId"]);
        if (/*attributeId != Guid.Empty && */ viewId != Guid.Empty)
        {
            //var ea = App.Params.CurrentEntityAttribute[attributeId];
            //if (ea.ReferencedObjectId > 0)
            //{
            var sview = App.Params.CurrentView[viewId];
            foreach (var entityAttribute in
                App.Params.CurrentEntityAttribute.Where(
                    entityAttribute => entityAttribute.Value.ObjectId == sview.ObjectId))
            {
                list.Add(new
                             {
                                 entityAttribute.Value.AttributeId,
                                 Label =
                             entityAttribute.Value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                                 entityAttribute.Value.UniqueName
                             });
            }
            //}
        }
        StoreToAttribute.DataSource = list;
        StoreToAttribute.DataBind();
    }

    protected void StoreCmbSort_OnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var list = new List<object>();
        var viewQueryId = ValidationHelper.GetGuid(e.Parameters["ViewQueryId"]);

        if (viewQueryId != Guid.Empty)
        {
            var vq = new ViewFactory();
            var v = vq.GetView(viewQueryId);

            if (v.ObjectId > 0)
            {
                foreach (var entityAttribute in
                    App.Params.CurrentEntityAttribute.Where(
                        entityAttribute =>
                        entityAttribute.Value.ObjectId == v.ObjectId &&
                        entityAttribute.Value.AttributeTypeIdname == "int"))
                {
                    list.Add(new
                                 {
                                     entityAttribute.Value.AttributeId,
                                     Label =
                                 entityAttribute.Value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId),
                                     entityAttribute.Value.UniqueName
                                 })
                        ;
                }
            }
        }
        StoreCmbSort.DataSource = list;
        StoreCmbSort.DataBind();
    }
    public void FillAdministrationBase()
    {
        cmbOwningUser.Value = App.Params.CurrentUser.SystemUserId.ToString();
        cmbOwningBusinessUnit.Value = App.Params.CurrentUser.BusinessUnitId.ToString();
        btnShare.Disabled = false;
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
    public void FillSectionLabel()
    {
        var labelsFactory = new LabelsFactory();
        var llist = labelsFactory.GetLabelMessagebyObjectId(ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        foreach (var labelMessage in llist)
        {
            CmbSectionLabel.Items.Add(new ListItem(labelMessage.LabelName, labelMessage.LabelMessageId.ToString()));
            CmbFormLabel.Items.Add(new ListItem(labelMessage.LabelName, labelMessage.LabelMessageId.ToString()));
            CmbReleatedViewLabel.Items.Add(new ListItem(labelMessage.LabelName, labelMessage.LabelMessageId.ToString()));
            cmbButtonLabel.Items.Add(new ListItem(labelMessage.LabelName, labelMessage.LabelMessageId.ToString()));
            cmbLabelLabel.Items.Add(new ListItem(labelMessage.LabelName, labelMessage.LabelMessageId.ToString()));
        }

    }
    [AjaxMethod(ShowMask = true)]
    public string UpdateFormEdit(string strLayoutXml)
    {
        var myForm = new Form
                         {
                             FormId = ValidationHelper.GetGuid(hdnFormId.Text),
                             Name = txtFormName.Text,
                             LayoutXml = strLayoutXml,
                             ObjectId = ValidationHelper.GetInteger(hdnObjectId.Text, 0),
                             DisableToolbar = ChkDisableToolbar.Checked,
                             IsDefaultEditForm = chkIsDefaultEditForm.Checked,
                             ReleatedListHeigth = ValidationHelper.GetInteger(nmbReleatedListHeigth.Value, 200),
                             CustomFormUrl = ValidationHelper.GetString(txrCustomEditForm.Value),
                             OwningBusinessUnit = ValidationHelper.GetGuid("00000000-0000-0000-0000-000000000001"),
                             OwningUser = ValidationHelper.GetGuid("00000000-AAAA-BBBB-CCCC-000000000001"),
                             LabelMessageId = ValidationHelper.GetGuid(CmbFormLabel.SelectedItem.Value)
                         };
        if (cmbActivityType.SelectedItem != null)
            myForm.ActivitytypeId = ValidationHelper.GetGuid(cmbActivityType.SelectedItem.Value);

        var ff = new FormFactory();
        try
        {
            ff.InsertUpdateForm(myForm);
        }
        catch (Exception exception)
        {
            ErrorMessageShow(exception);
        }


        return "";
    }
    protected void BtnCopyForm_OnClikc(object sender, AjaxEventArgs e)
    {
        if (hdnFormId.Text != string.Empty)
        {
            var ff = new FormFactory();
            var myform = ff.GetFormByFormId(ValidationHelper.GetGuid(hdnFormId.Text));
            myform.Name = "cc_" + myform.Name;
            myform.FormId = GuidHelper.Newfoid(EntityEnum.Form.GetHashCode());
            var rt = ff.InsertUpdateForm(myform);
            Response.Redirect(string.Format("FormEdit.aspx?ObjectId={0}&FormId={1}", rt.ObjectId, rt.FormId));
        }
    }
    protected void btnPublish_OnClikc(object sender, AjaxEventArgs e)
    {
        CrmApplication.LoadApplicationData();
        QScript("alert('publish Completed');");
    }


}
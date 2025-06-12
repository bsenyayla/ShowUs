using System;
using System.Collections.Generic;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.ExcelImport;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class CrmPages_Admin_ExcelImport_Edit : AdminPage
{
    private DynamicEntity _excelImportData = new DynamicEntity(EntityEnum.ExcelImportDefaination.GetHashCode());

    public CrmPages_Admin_ExcelImport_Edit()
    {
        ObjectId = EntityEnum.ExcelImportDefaination.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            BindeData();
        }
    }
    private void SetDefaultValues()
    {
        MenuItem1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        MenuItem2.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        const string beforeScript = "return CrmValidateForm(msg,e);";
        btnSave.AjaxEvents.Click.Before = beforeScript;
        btnSave.AjaxEvents.Click.Success =
            "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ if(RedirectType.getValue()=='1'){ window.location=UpdatedUrl.getValue();}else{ShowSaveMessage()}}";
        btnSaveAndClose.AjaxEvents.Click.Before = beforeScript;
        btnSaveAndClose.AjaxEvents.Click.Success = "if(UpdatedUrl.getValue()!='' ){RefreshParetnGrid(true);}";
    }

    private void BindeData()
    {
        ImportDefinationName.FillDynamicEntityData(_excelImportData);
        EntityId.FillDynamicEntityData(_excelImportData);
        TransactionRollbackType.FillDynamicEntityData(_excelImportData);
        RecordOwner.FillDynamicEntityData(_excelImportData);
        FillList(_excelImportData.GetStringValue("ImportSchemaXml"));
        Template.FillDynamicEntityData(_excelImportData);
        
        //App.Params.CurrentPluginMessages.
      //  BeforeImportPlugin.

    }
    private DynamicEntity FillEntity()
    {
        var myEntity = new DynamicEntity(EntityEnum.ExcelImportDefaination.GetHashCode());
        var excelImport = GetExcelImport();
        myEntity.AddStringProperty("ImportDefinationName", excelImport.ImportDefinationName);
        if (excelImport.ImportDefinationId != Guid.Empty)
            myEntity.AddKeyProperty("ImportDefinationId", excelImport.ImportDefinationId);
        myEntity.AddLookupProperty("EntityId", "EntityId", excelImport.EntityId);
        myEntity.AddLookupProperty("RecordOwner", "RecordOwner", excelImport.RecordOwner);
        myEntity.AddPicklistProperty("TransactionRollbackType", (int)excelImport.TransactionRollbackType);
        myEntity.AddStringProperty("Template", Template.Value);
        string strSxml = ExcelImportBase.XmlSerialize(excelImport);
        myEntity.AddStringProperty("ImportSchemaXml", strSxml);

        return myEntity;
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
                    dynamicFactory.Update(ValidationHelper.GetInteger(EntityEnum.ExcelImportDefaination.GetHashCode(), 0), dynamicEntity);
                }
                else
                {
                    var gdNew = dynamicFactory.Create(ValidationHelper.GetInteger(EntityEnum.ExcelImportDefaination.GetHashCode(), 0), dynamicEntity);
                    hdnRecid.Value = gdNew.ToString();
                }
            }
            catch (CrmException ex)
            {
                var msg = new MessageBox();
                if (ex.MessageType == CrmException.EMessageTpe.Error)
                    msg.MessageType = EMessageType.Error;
                msg.Modal = true;
                if (string.IsNullOrEmpty(ex.ErrorMessage) && ex.ErrorId > 0)
                    msg.Show("", " ", string.Format(CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR), ex.ErrorId));
                else
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
    private DynamicEntity GetDatas()
    {
        var myEntity = new DynamicEntity(EntityEnum.ExcelImportDefaination.GetHashCode());
        var df = new DynamicFactory(ERunInUser.CalingUser);
        myEntity = df.Retrieve(myEntity.ObjectId, ValidationHelper.GetGuid(hdnRecid.Value),
                               DynamicFactory.RetrieveAllColumns);
        return myEntity;
    }
    protected override void OnPreInit(EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdnObjectId.Value = QueryHelper.GetString("ObjectId");
            if (!string.IsNullOrEmpty(hdnRecid.Value))
            {
                _excelImportData = GetDatas();


            }
            SetDefaultValues();
        }
        base.OnPreInit(e);
    }
    protected void ImportListStoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var pItems = new List<ExcelImportDetail>();
        ImportList.DataSource = pItems;
        ImportList.DataBind();
    }
    private void FillList(string strXml)
    {
        var xx = ExcelImportBase.XmlDeSerialize(strXml);
        var pItems = new List<object>();
        foreach (var item in xx.ImportSchema)
        {
            var CustomMapAtrributeIdName = "";
            var TargetAtrributeIdName = "";
            if (App.Params.CurrentEntityAttribute.ContainsKey(item.CustomMapAtrributeId))
                CustomMapAtrributeIdName =
                    App.Params.CurrentEntityAttribute[item.CustomMapAtrributeId].GetLabelWithUniqueName(
                        App.Params.CurrentUser.LanguageId);
            if (App.Params.CurrentEntityAttribute.ContainsKey(item.TargetAtrributeId))
                TargetAtrributeIdName =
                    App.Params.CurrentEntityAttribute[item.TargetAtrributeId].GetLabelWithUniqueName(
                        App.Params.CurrentUser.LanguageId);

            pItems.Add(new
            {
                item.ExcelColumnName,
                CustomMapAtrributeId = item.CustomMapAtrributeId.ToString(),
                TargetAtrributeId=item.TargetAtrributeId.ToString(),
                CustomMapAtrributeIdName,
                TargetAtrributeIdName,
                item.IsNotNullable

            });
           
        }
        ImportList.DataSource = pItems;
        ImportList.DataBind();
    }
    protected void EditTargetAtrributeIdOnRefreshData(object sender, AjaxEventArgs e)
    {
        var l = new List<object>();
        foreach (var value in EntityAttributeFactory.GetAttributFulleEditableName(ValidationHelper.GetGuid(EntityId.Value)).OrderBy(ea => ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)))
        {
            l.Add(
                new
                    {
                        EditTargetAtrributeId = value.AttributeId,
                        EditTargetAtrributeIdName = value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)
                    });
        }
        EditTargetAtrributeId.DataSource = l;
        EditTargetAtrributeId.DataBind();
    }
    protected void EditCustomMapAtrributeIdOnRefreshData(object sender, AjaxEventArgs e)
    {
        var l = new List<object>();
        var degerler = ((RowSelectionModel)ImportList.SelectionModel[0]);
        if (degerler != null && degerler.SelectedRows != null)
        {


            var mapid = ValidationHelper.GetGuid(degerler.SelectedRows[0]["TargetAtrributeId"]);
            if (mapid == Guid.Empty || !App.Params.CurrentEntityAttribute.ContainsKey(mapid))
            {
                EditCustomMapAtrributeId.DataSource = l;
                EditCustomMapAtrributeId.DataBind();
                return;
            }
            EntityAttribute mapColumn = App.Params.CurrentEntityAttribute[mapid];



            foreach (
                var value in
                    EntityAttributeFactory.GetAttributeEditableName(
                        ValidationHelper.GetGuid(mapColumn.ReferencedEntityId)).Where(
                            ea => ea.ReferencedEntityId == Guid.Empty).OrderBy(
                                ea => ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)))
            {
                l.Add(
                    new
                        {
                            EditCustomMapAtrributeId = value.AttributeId,
                            EditCustomMapAtrributeIdName =
                        value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)
                        });
            }
            EditCustomMapAtrributeId.DataSource = l;
            EditCustomMapAtrributeId.DataBind();
        }
    }
    private ExcelImport GetExcelImport()
    {
        var ret = new ExcelImport
                      {
                          ImportDefinationName = ImportDefinationName.Value,
                          ImportDefinationId = ValidationHelper.GetGuid(hdnRecid.Value),
                          EntityId = ValidationHelper.GetGuid(EntityId.Value),
                          RecordOwner = ValidationHelper.GetGuid(RecordOwner.Value),
                          TransactionRollbackType =
                              (ETransactionRollbackType)ValidationHelper.GetInteger(TransactionRollbackType.Value, 0),
                          ImportSchema = new List<ExcelImportDetail>(),
                          
                          
                      };


        var degerler = ImportList.AllRows;
        if (degerler != null)
        {
            foreach (var t in ImportList.AllRows)
            {
                ret.ImportSchema.Add(
                    new ExcelImportDetail()
                        {
                            CustomMapAtrributeId = ValidationHelper.GetGuid(t.CustomMapAtrributeId),
                            ExcelColumnName = ValidationHelper.GetString(t.ExcelColumnName),
                            TargetAtrributeId = ValidationHelper.GetGuid(t.TargetAtrributeId),
                            IsNotNullable = ValidationHelper.GetBoolean(t.IsNotNullable),
                            
                        }
                    );
            }
        }
        return ret;
    }
}
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Criteria;
using Coretech.Crm.Factory.Crm.DuplicateDetection;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Attributes;
using Coretech.Crm.Objects.Crm.Criteria;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using Newtonsoft.Json;
using RefleXFrameWork;

public partial class CrmPages_Admin_Criteria_CriteriaEditReflex : AdminPage
{
    private DynamicSecurity _dynamicSecurity;
    void FillSecurity()
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(EntityEnum.CriteriaGroups.GetHashCode(), 0),
                                                          (string.IsNullOrEmpty(hdnRecid.Value)
                                                               ? (Guid?)null
                                                               : ValidationHelper.GetGuid(hdnRecid.Value)));

        if (QueryHelper.GetString("mode", "") == "3")
        {
            _dynamicSecurity.PrvCreate =
                _dynamicSecurity.PrvDelete = _dynamicSecurity.PrvShare = _dynamicSecurity.PrvAppend =
                                                                         _dynamicSecurity.PrvAssign =
                                                                         _dynamicSecurity.PrvWrite =
                                                                         _dynamicSecurity.PrvAppendTo =
                                                                         _dynamicSecurity.PrvRead = _dynamicSecurity.PrvMultiLanguage = false;

        }
    }
    enum treedataType : int
    {
        text = 0, id = 1, objectid = 2, objectId = 3, leftjoin = 4, type = 5, attributeid = 6, entityobjectid = 7, conditionvalue = 8, clausevalue = 9, clausetext = 10, conditiontype = 11, clausevalue2 = 12
    }
    enum WitemDataType : int
    {
        text = 0, id = 1, Type = 2, ClauseValue = 3, ClauseText = 4, data = 5, DynamicUrlId, IsStopWorkflow, PluginMessageId, RedirectFormId
    }

    enum FilterEntityType : int { And, Or, Attribute, Entity }
    enum valueConditiontype : int
    {
        IsTextField = 0,
        IsLookupField = 1,
        IsNumericField = 2,
        IsDecimalField = 3,
        IsDateField = 4,
        IsPicklistField = 5
    }
    enum formobjecttype { attribute, iframe, button }

    private CriteriaFactory _wff = new CriteriaFactory();
    private DynamicFactory _df = null;
    private EditPageMode _pageMode;
    private CriteriaGroups _wf = new CriteriaGroups();
    public CrmPages_Admin_Criteria_CriteriaEditReflex()
    {
        base.ObjectId = EntityEnum.CriteriaGroups.GetHashCode();

    }
    protected override void OnInit(EventArgs e)
    {
        _df = new DynamicFactory(ERunInUser.CalingUser);
        base.OnInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        var xx = Page.GetType();

        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Workflow PrvCreate,PrvDelete,PrvWrite");
        }
        hdnRecid.Value = QueryHelper.GetString("recid");
        _pageMode = hdnRecid.Value != string.Empty ? EditPageMode.EditUpdate : EditPageMode.New;

        if (!RefleX.IsAjxPostback)
        {
            AddDynamicValueRoot();
            this.RR.RegisterIcon(Icon.Application);
            this.RR.RegisterIcon(Icon.FolderHome);
            this.RR.RegisterIcon(Icon.BulletOrange);
            this.RR.RegisterIcon(Icon.ArrowJoin);
            this.RR.RegisterIcon(Icon.ArrowSwitch);
            this.RR.RegisterIcon(Icon.ArrowRotateAnticlockwise);
            this.RR.RegisterIcon(Icon.Time);
            this.RR.RegisterIcon(Icon.ApplicationAdd);
            this.RR.RegisterIcon(Icon.ApplicationEdit);
            this.RR.RegisterIcon(Icon.LinkEdit);
            this.RR.RegisterIcon(Icon.CommentAdd);
            this.RR.RegisterIcon(Icon.ScriptGear);
            this.RR.RegisterIcon(Icon.Stop);
            this.RR.RegisterIcon(Icon.Reload);
            this.RR.RegisterIcon(Icon.Plugin);
            this.RR.RegisterIcon(Icon.Add);
            this.RR.RegisterIcon(Icon.Delete);

            if (_pageMode == EditPageMode.New)
            {
                DisableOnCreate(_pageMode);
                //AddWItemsRoot();
            }
            else
            {
                DisableOnCreate(_pageMode);
                SetEntityValue();
            }

            var beforeScript = string.Empty;
            var successScript = string.Empty;
            beforeScript += "ValidateBeforeForm(msg,e); ";
            beforeScript += "WItems.allNodesPost = true;";

            btnSave.AjaxEvents.Click.Before = beforeScript;
            btnSave.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";

            btnDDSave.AjaxEvents.Click.Before = beforeScript;
            btnDDSave.AjaxEvents.Click.Success = btnSave.AjaxEvents.Click.Success;

            btnSaveAsCopy.AjaxEvents.Click.Before = beforeScript;
            btnSaveAsCopy.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){ " + successScript + " if(RedirectType.getValue()=='1'){ window.location=R.htmlDecode(UpdatedUrl.getValue());}else{ShowSaveMessage()}}";

            btnSaveAndNew.AjaxEvents.Click.Before = beforeScript;
            btnSaveAndNew.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!='' ){" + successScript + "window.location=R.htmlDecode(UpdatedUrl.getValue());}";

            btnSaveAndClose.AjaxEvents.Click.Before = beforeScript;
            btnSaveAndClose.AjaxEvents.Click.Success = "if(UpdatedUrl.getValue()!='' ){" + successScript + " RefreshParetnGrid(true);}";

        }
        FillSecurity();
    }
    private void SetEntityValue()
    {
        var de = _df.Retrieve(EntityEnum.CriteriaGroups.GetHashCode(), ValidationHelper.GetGuid(hdnRecid.Value), DynamicFactory.RetrieveAllColumns);
        if (de != null)
        {
            GroupName.FillDynamicEntityData(de);
            EntityId.FillDynamicEntityData(de);
            AttributeId.FillDynamicEntityData(de);
            _wf = _wff.FillCriteriaGroup(de);

            var des = CriteriaGroups.XmlDeSerializeCriteriaGroupList(_wf.Rules);
            var rn = AddWItemsRoot();
            if (des != null)
            {
                WitemsAddNodes(rn, des);
                WItems.Root.Nodes.Add(rn);

            }
            else
            {
                WItems.Root.Nodes.Add(rn);

            }

            foreach (Entity entity in App.Params.CurrentEntity.Values)
            {
                if (entity.EntityId == _wf.EntityId)
                    hdnObjectId.Value = entity.ObjectId.ToString();
            }


        }
    }
    void WitemsAddNodes(TreeNode rootNode, IEnumerable<CriteriaGroup> criteriaGrouplst)
    {


        foreach (var criteriaGroup in criteriaGrouplst)
        {

            var tnMain = new RefleXFrameWork.TreeNode
            {
                Expanded = true,
                Icon = Icon.Folder,
                Leaf = true,
                CustomAttributes = new List<ConfigItem>
                                                   {
                            new ConfigItem("text",criteriaGroup.Text ,EpMode.Value),
                            new ConfigItem("id",criteriaGroup.Id.ToString(),EpMode.Value),
                            new ConfigItem("Type",criteriaGroup.Type.GetHashCode().ToString(),EpMode.Value),
                            new ConfigItem("ClauseValue",criteriaGroup.ClauseValue,EpMode.Value),
                            new ConfigItem("ClauseText",criteriaGroup.ClauseText,EpMode.Value),
                                                   }
            };
            switch (criteriaGroup.Type)
            {
                case CriteriaStepType.Root:
                    tnMain.Icon = Icon.Folder;
                    break;
                case CriteriaStepType.Add:
                    tnMain.Icon = Icon.Add;
                    break;
                case CriteriaStepType.Remove:
                    tnMain.Icon = Icon.Delete;
                    break;
                default:
                    tnMain.Icon = Icon.Folder;
                    break;
            }
            string data = string.Empty;
            data = SerializeObject(criteriaGroup.FilterEntity);
            tnMain.Leaf = true;

            tnMain.CustomAttributes.Add(new ConfigItem("data", data, EpMode.Value));
            rootNode.Nodes.Add(tnMain);
        }
    }

    public string SerializeObject(object o)
    {
        var mySerializer = new XmlSerializer(o.GetType());
        TextWriter tw = new StringWriter();
        mySerializer.Serialize(tw, o);
        return tw.ToString();
    }
    private void DisableOnCreate(EditPageMode mode)
    {
        if (mode == EditPageMode.New)
        {
            BtnDetailAction.Visible = false;

            //WItems.Visible = false; 
        }
        else
        {
            EntityId.Disabled = true;
        }

    }
    private TreeNode AddWItemsRoot()
    {
        var id = Guid.NewGuid().ToString();

        var t = new RefleXFrameWork.TreeNode
        {
            Expanded = true,
            Leaf = false,
            Icon = Icon.Folder,
            CustomAttributes = new List<ConfigItem>
                                               {
                                                   new ConfigItem("text",EntityId.Text,EpMode.Value),
                                                   new ConfigItem("id",id,EpMode.Value),
                                                   
                        new ConfigItem("Type",ValidationHelper.GetInteger(CriteriaStepType.Root, 0).ToString(),EpMode.Value),
                        new ConfigItem("ClauseValue","",EpMode.Value),
                        new ConfigItem("ClauseText","",EpMode.Value),
                        new ConfigItem("data","",EpMode.Value)

                                                       
                                               }
        };


        return t;
    }
    protected void BtnSaveClick(object sender, AjaxEventArgs e)
    {
        /*Ic Yetki Kontrolu*/
        if (hdnRecid.Value != "")
        {
            if (!_dynamicSecurity.PrvWrite)
            {
                return;
            }
        }
        else
        {
            if (!_dynamicSecurity.PrvCreate)
            {
                return;
            }

        }
        var objectId = EntityEnum.CriteriaGroups.GetHashCode();
        if (e.ExtraParams["Action"] != null)
        {
            var action = ValidationHelper.GetInteger(e.ExtraParams["Action"], 0);
            var parntAction = ValidationHelper.GetInteger(e.ExtraParams["ParentAction"], 0);

            var orginalAction = action;
            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);

            DynamicEntity dynamicEntity = GetDynamicEntity();
            var oldrecId = ValidationHelper.GetGuid(hdnRecid.Value);
            //if(hdnRecid.Value==string.Empty)
            //{
            //    hdnRecid.Value =
            //        EntityFactory.GetEntityFromEntityId(ValidationHelper.GetGuid(EntityId.Value)).ObjectId.
            //            ToString();

            //}

            if (action == 4)
            {
                hdnRecid.Value = string.Empty;
                dynamicEntity.AddKeyProperty(EntityAttributeFactory.GetAttributePkString(objectId), GuidHelper.Newfoid(objectId));
                action = 1;
                /*Seqkey lerin Nullanmasi*/
                foreach (var entityAttribute in
                    App.Params.CurrentEntityAttribute.Values.Where(entityAttribute => !string.IsNullOrEmpty(entityAttribute.SequenceKey)).Where(entityAttribute => entityAttribute.ObjectId == objectId))
                {
                    if (dynamicEntity.Properties.Contains(entityAttribute.Name))
                    {
                        dynamicEntity.Properties.Remove(entityAttribute.Name);
                    }
                }
            }
            var ddf = new DuplicateDetectionFactory();
            Guid duplicateDetectionResultId;
            Guid duplicateDetectionRuleId;
            Guid firstDeleatedRecordId;
            var ddfRet = ddf.CheckDuplicateDedection(dynamicEntity, out duplicateDetectionResultId, out duplicateDetectionRuleId, out firstDeleatedRecordId);

            if (ddfRet && action <= 4)
            {
                if (duplicateDetectionRuleId != Guid.Empty)
                {
                    var dd = App.Params.CurrentDuplicateDetections[duplicateDetectionRuleId];
                    if (dd.CheckDeletedRecords && dd.AutoActiveDeletedRecord && firstDeleatedRecordId != Guid.Empty)
                    {
                        if (hdnRecid.Value == string.Empty)
                        {
                            dynamicEntity.AddKeyProperty(EntityAttributeFactory.GetAttributePkString(objectId), firstDeleatedRecordId);
                            dynamicEntity.AddNumberProperty("DeletionStateCode", 0);
                            hdnRecid.Value = firstDeleatedRecordId.ToString();
                        }

                    }
                    else
                    {
                        QScript("UpdatedUrl.setValue('');");
                        QScript(string.Format("ShowDDwindow('{0}','{1}','{2}');", duplicateDetectionRuleId, duplicateDetectionResultId, orginalAction));
                        return;
                    }
                }
            }
            if (action == 5 || action == 6)
            {
                dynamicEntity.AddNumberProperty("DeletionStateCode", 0);
                action = parntAction;
            }
            //if (!ret)
            //    return;
            try
            {
                if (hdnRecid.Value != string.Empty)
                {
                    dynamicEntity.AddKeyProperty(EntityAttributeFactory.GetAttributePkString(objectId), ValidationHelper.GetGuid(hdnRecid.Value));
                    dynamicFactory.UpdateWithOutPlugin(objectId, dynamicEntity);
                }
                else
                {
                    var gdNew = dynamicFactory.CreateWithOutPlugin(objectId, dynamicEntity);

                    hdnRecid.Value = gdNew.ToString();
                    hdnRecid.SetValue(gdNew.ToString());

                }
            }
            catch (CrmException ex)
            {
                var msg = new MessageBox();
                if (ex.MessageType == CrmException.EMessageTpe.Error)
                    msg.MessageType = EMessageType.Error;
                msg.Modal = true;
                if (string.IsNullOrEmpty(ex.ErrorMessage) && ex.ErrorId > 0)
                    msg.Show("", " ", string.Format(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR), ex.ErrorId));
                else
                    msg.Show(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE), " ", ex.ErrorMessage);
                return;

            }


            var query = new Dictionary<string, string>();

            switch (action)
            {
                case 1:
                    query.Add("recid", hdnRecid.Value);
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(QueryHelper.AddUpdateString(query))));
                    break;
                case 2:
                    query.Add("recid", "");
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(QueryHelper.AddUpdateString(query))));
                    break;
                case 3:
                    query.Add("recid", "");
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(QueryHelper.AddUpdateString(query))));
                    break;
                case 4:
                    query.Add("recid", hdnRecid.Value);
                    QScript(string.Format("UpdatedUrl.setValue({0});", JsonConvert.SerializeObject(QueryHelper.AddUpdateString(query))));
                    break;
            }

        }
        var df = new DynamicFactory(ERunInUser.SystemAdmin);
        var de = df.Retrieve(EntityEnum.CriteriaGroups.GetHashCode(),
                                                                    ValidationHelper.GetGuid(hdnRecid.Value), DynamicFactory.RetrieveAllColumns, true);
        var c = FillCriteriaGroup(de);
        var criteriaGrouplist = CriteriaGroups.XmlDeSerializeCriteriaGroupList(c.Rules);
        foreach (var criteriaGroup in criteriaGrouplist)
        {
            var spList = new List<CrmSqlParameter>();
            var sql = GetSql(c.EntityId, c.AttributeId, criteriaGroup.FilterEntity, out  spList, criteriaGroup.Id, Guid.NewGuid(), criteriaGroup.Type);

            XmlSerializer xmlser = new XmlSerializer(typeof(List<CrmSqlParameter>));
            MemoryStream stream = new MemoryStream();

            xmlser.Serialize(stream, spList);

            stream.Position = 0;
            var sr = new StreamReader(stream);
            var myStr = sr.ReadToEnd();

            de.AddStringProperty("new_Sql", sql);
            de.AddStringProperty("new_SpList", myStr);
            df.Update("CriteriaGroups", de);
        }



    }

    public string GetSql(Guid entityId, Guid AttributeId, FilterEntity filterEntity, out List<CrmSqlParameter> spList, Guid CriteriaGroupsId, Guid StepId, CriteriaStepType StepType)
    {
        spList = new List<CrmSqlParameter>();
        var objectId = EntityFactory.GetEntityFromEntityId(entityId).ObjectId;
        const string sqlPlus = " INSERT INTO CriteriaGroupsResults (CriteriaGroupsResultsId,CriteriaGroupsId,StepId,ObjectId,ResultId)";
        const string sqlRemove = " Delete CriteriaGroupsResults Where ResultId ";
        const string sqlRemoveWhere = " AND CriteriaGroupsId=@_CriteriaGroupsId And StepId=@_StepId";

        var sql = new StringBuilder("Select newId(),@_CriteriaGroupsId,@_StepId,@_ObjectId, ");
        if (StepType == CriteriaStepType.Remove)
        {
            sql = new StringBuilder("  Select ");
        }
        const string mainTableName = SqlCreater.MainTableName;
        var selectedColumn = EntityAttributeFactory.GetAttributeUniqueName(AttributeId);

        var selectTable = "";
        if (App.Params.CurrentEntity.ContainsKey(objectId))
        {
            var e = App.Params.CurrentEntity[objectId];
            selectTable = e.SelectTable;
        }


        sql.Append(mainTableName).Append(".").Append(selectedColumn).Append(" AS ID ");

        sql.Append(" from  dbo.").Append(selectTable).Append("(@").Append(CrmSqlParameter._SystemUserId)
                        .Append(") as ").Append(mainTableName);



        var level = 0;


        var whereSql = new StringBuilder(" Where 1=1 ");



        SqlCreater.CreateFilterSql(ref level, ref sql, ref whereSql, mainTableName, filterEntity,
                        ref spList, 0, Guid.Empty, null, " AND ", App.Params.CurrentUser.SystemUserId);


        /* Where 1=1  AND  Mt.new_ConfirmStatus =@pw0  AND  Mt.new_RecipientCountryID =@pw1   AND  ()
        Where sorgusunu oluştururken sonunda 'AND  ()' kalıyor, onu temizlemek için yazıldı.*/

        string tempWhereSql = whereSql.ToString();
        whereSql.Clear();
        whereSql.Append(tempWhereSql.Replace("AND  ()", ""));

        sql.Append(whereSql);
        //ViewFactory.GetData("" + sql, query, sorts, likes, dir, start, limit, out totalCount, ref dt, spList, fieldssearch, View.ObjectId);
        var oursql = sql.ToString();
        switch (StepType)
        {
            case CriteriaStepType.Add:
                oursql = sqlPlus + oursql;
                break;
            case CriteriaStepType.Remove:
                oursql = sqlRemove + " IN ( Select * From (" + oursql + ") deletedSelect ) " + sqlRemoveWhere;
                break;
        }
        var refObjectId = App.Params.CurrentEntityAttribute[AttributeId].ReferencedObjectId;
        if (refObjectId == 0)
            refObjectId = objectId;
        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "_CriteriaGroupsId", Value = CriteriaGroupsId });
        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "_StepId", Value = StepId });
        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Int32, Paramname = "_ObjectId", Value = refObjectId });
        spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = CrmSqlParameter._SystemUserId, Value = App.Params.CurrentUser.SystemUserId });

        return oursql;
    }

    public CriteriaGroups FillCriteriaGroup(DynamicEntity de)
    {
        var ret = new CriteriaGroups()
        {
            EntityId = de.GetLookupValue("EntityId"),
            Rules = de.GetStringValue("Rules"),
            CriteriaGroupsId = de.GetKeyValue("CriteriaGroupsId"),
            GroupName = de.GetStringValue("GroupName"),
            AttributeId = de.GetLookupValue("AttributeId"),
        };

        return ret;
    }

    DynamicEntity GetDynamicEntity()
    {
        Guid gdWorkflow = GuidHelper.Newfoid((int)EntityEnum.CriteriaGroups);
        var dynamicEntity = new DynamicEntity((int)EntityEnum.CriteriaGroups);

        if (_pageMode == EditPageMode.New)
        {



            dynamicEntity.AddKeyProperty("CriteriaGroupsId", gdWorkflow);
            dynamicEntity.AddLookupProperty("EntityId", "EntityId", ValidationHelper.GetGuid(EntityId.Value));
            dynamicEntity.AddStringProperty("GroupName", GroupName.Value.ToString());
            dynamicEntity.AddLookupProperty("AttributeId", "AttributeId", ValidationHelper.GetGuid(AttributeId.Value));


            // var id = _df.CreateWithOutPlugin((int)EntityEnum.CriteriaGroups, dynamicEntity);

        }
        else if (_pageMode == EditPageMode.EditUpdate)
        {


            dynamicEntity.AddKeyProperty("CriteriaGroupsId", ValidationHelper.GetGuid(hdnRecid.Value));
            dynamicEntity.AddStringProperty("GroupName", GroupName.Value.ToString());
            dynamicEntity.AddLookupProperty("EntityId", "EntityId", ValidationHelper.GetGuid(EntityId.Value));
            dynamicEntity.AddLookupProperty("AttributeId", "AttributeId", ValidationHelper.GetGuid(AttributeId.Value));

            var wfsteps = GetCriteriaGroupList(WItems.AllNodes);
            dynamicEntity.AddStringProperty("Rules", SerializeObject(wfsteps));



        }
        return dynamicEntity;
    }

    private List<CriteriaGroup> GetCriteriaGroupList(RefleXFrameWork.TreeNode node)
    {
        var mylist = new List<CriteriaGroup>();
        foreach (var treeNode in node.Nodes)
        {

            mylist.Add(GetCriteriaGroup(treeNode));
        }
        return mylist;
    }

    CriteriaGroup GetCriteriaGroup(RefleXFrameWork.TreeNode node)
    {
        var wf = new CriteriaGroup();
        var id = node.CustomAttributes[WitemDataType.id.GetHashCode()].Value;
        var text = node.CustomAttributes[WitemDataType.text.GetHashCode()].Value;
        var type = (CriteriaStepType)ValidationHelper.GetInteger(node.CustomAttributes[WitemDataType.Type.GetHashCode()].Value, 0);
        var clauseValue = node.CustomAttributes[WitemDataType.ClauseValue.GetHashCode()].Value;
        var clauseText = node.CustomAttributes[WitemDataType.ClauseText.GetHashCode()].Value;
        var data = node.CustomAttributes[WitemDataType.data.GetHashCode()].Value;

        wf.Id = ValidationHelper.GetGuid(id);
        wf.Text = ValidationHelper.GetString(text);
        wf.Type = type;
        wf.FilterEntity = FilterEntity.DeserializeFilterEntity(data);


        return wf;
    }
    #region If Condition
    protected void CmbIfAttribute_OnEvent(object sender, AjaxEventArgs e)
    {
        var objList = new List<object>();
        foreach (var value in App.Params.CurrentEntityAttribute.Values.Where(value => value.ObjectId == ValidationHelper.GetInteger(IfconditionHdnObjectId.Value)))
        {
            objList.Add(new { Id = value.AttributeId, Name = value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId) });
        }
        CmbIfAttribute.DataSource = objList.OrderBy(t => TypeHelper.GetPropertyValue(t, "Name")).ToList();
        CmbIfAttribute.DataBind();
    }
    protected void CmbIfCondition_OnEvent(object sender, AjaxEventArgs e)
    {
        var vf = new ViewFactory();
        var attribute =
            App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(CmbIfAttribute.Value)];
        var vlist = vf.GetAttributeConditionListByTypeId(attribute.AttributeTypeId);
        CmbIfCondition.DataSource = vlist.OrderBy(t => t.Value).ToList();
        CmbIfCondition.DataBind();
    }
    protected void CmbIfReleatedEntity_OnEvent(object sender, AjaxEventArgs e)
    {
        var objList = new List<object>();

        foreach (var value in App.Params.CurrentEntityAttribute.Values.Where(
            value => value.ObjectId == ValidationHelper.GetInteger(IfconditionHdnObjectId.Value)
                && value.ReferencedEntityId != Guid.Empty
                && value.AttributeTypeId == ValidationHelper.GetGuid(StringEnum.GetStringValue(XTypes.Lookup))
            ))
        {
            objList.Add(new { Id = value.AttributeId, Name = value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId), ObjectId = value.ReferencedObjectId.ToString() });
        }
        CmbIfReleatedEntity.DataSource = objList.OrderBy(t => TypeHelper.GetPropertyValue(t, "Name")).ToList();
        CmbIfReleatedEntity.DataBind();
    }


    AttributeCondition GetAttributeCondition(Guid attributeId, Guid conditionId)
    {
        var aa = new AttributeCondition();
        var node = TreeIfConditions.SelectedNode;
        //var conditionId = ValidationHelper.GetGuid(node[8].Value);
        if (node != null)
        {
            //   var attributeId = ValidationHelper.GetGuid(node[6].Value);
            foreach (var attributeCondition in
                           App.Params.CurrentAttributeCondition.Where(
                               t =>
                               t.AttributeConditionId == conditionId &&
                               t.AttributeTypeId == App.Params.CurrentEntityAttribute[attributeId].AttributeTypeId))
            {
                return attributeCondition;
            }
        }
        return aa;
    }
    private void ClerConditionValues()
    {
        IfcValuesTextField.Clear();
        IfcValuesNumericField.Clear();
        IfcValuesDecimalField.Clear();
        IfcValuesDateField.Clear();
        IfcValuesLookupField.Clear();
        IfcValuesPicklistField.Clear();
        IfcDynamicValuesTextField.Clear();

    }
    protected void btnIfConditionAddClick_OnEvent(object sender, AjaxEventArgs e)
    {
        //text = 0, id = 1, objectid = 2, objectId = 3, leftjoin = 4, type = 5, attributeid = 6, entityobjectid = 7, conditionvalue = 8, clausevalue = 9, clausetext = 10, conditiontype = 11, clausevalue2 = 12
        var node = TreeIfConditions.SelectedNode;
        if (node != null)
        {
            var attributeId = ValidationHelper.GetGuid(CmbIfAttribute.Value);
            var conditionId = ValidationHelper.GetGuid(CmbIfCondition.Value);
            var ea = App.Params.CurrentEntityAttribute[attributeId];
            var tt = new RefleXFrameWork.TreeNode()
            {
                Expanded = true,
                Leaf = true,
                Icon = Icon.BulletOrange
            };
            var text = string.Format("{0}  {1}  {2}", (CmbIfAttribute.SelectedItems[0]).Name,
                                     (CmbIfCondition.SelectedItems[0]).Description, LblIfConditionClausetext.Value);


            tt.CustomAttributes.Add(new ConfigItem(treedataType.text.ToString(), text, EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.id.ToString(), Guid.NewGuid().ToString(), EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.objectid.ToString(), ea.ObjectId.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.objectId.ToString(), ea.ObjectId.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.leftjoin.ToString(), "", EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.type.ToString(), FilterEntityType.Attribute.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.attributeid.ToString(), attributeId.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.entityobjectid.ToString(), ea.ObjectId.ToString(),
                                                   EpMode.Value));

            tt.CustomAttributes.Add(new ConfigItem(treedataType.conditionvalue.ToString(), conditionId.ToString(),
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.clausevalue.ToString(), IfConditionClauseValue.Value,
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.clausetext.ToString(), LblIfConditionClausetext.Value,
                                                   EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.conditiontype.ToString(),
                                                   IfConditionConditionType.Value, EpMode.Value));
            tt.CustomAttributes.Add(new ConfigItem(treedataType.clausevalue2.ToString(), "", EpMode.Value));

            if (node[treedataType.type.GetHashCode()].Value == FilterEntityType.Attribute.ToString())
            {
                TreeIfConditions.UpdateSelectedNode(tt);
            }
            else
            {
                TreeIfConditions.AddTreeNode(tt);

            }
        }
    }

    protected void IfConditionGetAttributeData_OnEvent(object sender, AjaxEventArgs e)
    {
        ClerConditionValues();
        var node = TreeIfConditions.SelectedNode;
        if (node != null)
        {
            var attributeId = ValidationHelper.GetGuid(node[6].Value);

            CmbIfAttribute.Value = attributeId.ToString();
            CmbIfAttribute.SetValue(attributeId,
                                    App.Params.CurrentEntityAttribute[attributeId].GetLabelWithUniqueName(
                                        App.Params.CurrentUser.LanguageId));

            var conditionId = ValidationHelper.GetGuid(node[8].Value);
            var ea = App.Params.CurrentEntityAttribute[attributeId];

            var nodeShow = 0;

            var se = GetAttributeCondition(attributeId, conditionId);
            if (se.IsTextField || se.IsNumericField || se.IsDecimalField || se.IsDateField || se.IsLookupField ||
                se.IsPicklistField)
                nodeShow = 1;
            if (se.IsTextField)
                IfcValuesTextField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
            if (se.IsNumericField)
                IfcValuesNumericField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
            if (se.IsDecimalField)
                IfcValuesDecimalField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
            if (se.IsDateField)
                IfcValuesDateField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
            if (se.IsLookupField)
            {

                IfcValuesLookupField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value, node[treedataType.clausetext.GetHashCode()].Value);
            }
            if (se.IsPicklistField)
            {
                IfcValuesPicklistField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value, node[treedataType.clausetext.GetHashCode()].Value);
            }


            CmbIfCondition.Value = conditionId.ToString();
            //CmbIfCondition_OnEvent(sender, e);
            CmbIfCondition.SetValue(conditionId, App.Params.CurrentAttributeConditionBase[conditionId].Description);
            QScript("IFCondition.ConditionChanged(" + nodeShow + ");");
            IfconditionHdnObjectId.SetValue(node[treedataType.objectId.GetHashCode()].Value);

            LblIfConditionClausetext.SetValue(node[treedataType.clausetext.GetHashCode()].Value);
            IfConditionClauseValue.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);

            if (node[treedataType.conditiontype.GetHashCode()].Value == ConditionType.Dynamic.ToString())
            {
                IfcDynamicValuesTextField.SetValue(node[treedataType.clausetext.GetHashCode()].Value);
                IfcDynamicValuesHiddenField.SetValue(node[treedataType.clausevalue.GetHashCode()].Value);
                IfcValuesConditionType.SetValue(ConditionType.Dynamic.ToString());
                IfConditionConditionType.SetValue(ConditionType.Dynamic.ToString());
            }
            else
            {

                IfcDynamicValuesTextField.SetValue("");
                IfcDynamicValuesHiddenField.SetValue("");
                IfConditionConditionType.SetValue(ConditionType.Default.ToString());
                IfcValuesConditionType.SetValue(ConditionType.Default.ToString());
            }

        }
    }
    protected void IfConditionValuesEdit_OnEvent(object sender, AjaxEventArgs e)
    {
        var node = TreeIfConditions.SelectedNode;
        if (node != null)
        {

            var attributeId = ValidationHelper.GetGuid(CmbIfAttribute.Value);
            var conditionId = ValidationHelper.GetGuid(CmbIfCondition.Value);
            var nodeShow = 0;
            var ea = App.Params.CurrentEntityAttribute[attributeId];

            {

                var se = GetAttributeCondition(attributeId, conditionId);
                if (se.IsTextField || se.IsNumericField || se.IsDecimalField || se.IsDateField || se.IsLookupField || se.IsPicklistField)
                {

                    var lbl = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);

                    if (se.IsTextField)
                    {
                        hdnWindowIfcValuType.SetValue("0");
                        IfcValuesTextField.Show();
                    }
                    else
                        IfcValuesTextField.Hide();

                    if (se.IsLookupField)
                    {
                        hdnWindowIfcValuType.SetValue("1");
                        IfcValuesLookupField.Show();
                        IfcValuesLookupField.UniqueName = ea.UniqueName;
                        IfcValuesLookupField.ObjectId = ea.ObjectId.ToString();
                        IfcValuesLookupField.ReCreateLookup();

                    }
                    else
                        IfcValuesLookupField.Hide();


                    if (se.IsNumericField)
                    {
                        hdnWindowIfcValuType.SetValue("2");
                        IfcValuesNumericField.Show();
                    }
                    else
                        IfcValuesNumericField.Hide();

                    if (se.IsDecimalField)
                    {
                        hdnWindowIfcValuType.SetValue("3");
                        IfcValuesDecimalField.Show();
                    }
                    else
                        IfcValuesDecimalField.Hide();

                    if (se.IsDateField)
                    {
                        hdnWindowIfcValuType.SetValue("4");
                        IfcValuesDateField.Show();
                    }
                    else
                        IfcValuesDateField.Hide();



                    if (se.IsPicklistField)
                    {
                        hdnWindowIfcValuType.SetValue("5");
                        IfcValuesPicklistField.Show();
                        //IfcValuesPicklistField.Clear();


                    }
                    else
                        IfcValuesPicklistField.Hide();

                    IfcValuesTextField.SetFieldLabel(lbl);
                    IfcValuesNumericField.SetFieldLabel(lbl);
                    IfcValuesDecimalField.SetFieldLabel(lbl);
                    IfcValuesDateField.SetFieldLabel(lbl);
                    IfcValuesLookupField.SetFieldLabel(lbl);
                    IfcValuesPicklistField.SetFieldLabel(lbl);
                    IfcDynamicValuesTextField.SetFieldLabel(lbl);

                    if (IfConditionConditionType.Value == ConditionType.Dynamic.ToString())
                    {
                        TreeGridDynamicValue.Show();
                        IfcDynamicValuesTextField.Show();

                        IfcValuesTextField.Hide();
                        IfcValuesNumericField.Hide();
                        IfcValuesDecimalField.Hide();
                        IfcValuesDateField.Hide();
                        IfcValuesLookupField.Hide();
                        IfcValuesPicklistField.Hide();


                    }
                    else
                    {
                        TreeGridDynamicValue.Hide();
                        IfcDynamicValuesTextField.Hide();

                    }



                    nodeShow = 1;
                }
            }

            QScript("IFCondition.ConditionChanged(" + nodeShow + ");");
        }
    }
    protected void IfcValuesPicklistField_OnEvent(object sender, AjaxEventArgs e)
    {
        var attributeId = ValidationHelper.GetGuid(CmbIfAttribute.Value);

        var pf = new PicklistFactory();
        List<PicklistValue> pv = pf.GetPicklistValueList(ValidationHelper.GetGuid(attributeId));
        IfcValuesPicklistField.DataSource = pv;
        IfcValuesPicklistField.DataBind();
    }

    protected void IfcValuesConditionTypeChange_OnEvent(object sender, AjaxEventArgs e)
    {

        var attributeId = ValidationHelper.GetGuid(CmbIfAttribute.Value);
        var conditionId = ValidationHelper.GetGuid(CmbIfCondition.Value);

        var se = GetAttributeCondition(attributeId, conditionId);


        if (IfcValuesConditionType.Value == ConditionType.Dynamic.ToString())
        {
            IfcValuesTextField.Hide();
            IfcValuesNumericField.Hide();
            IfcValuesDecimalField.Hide();
            IfcValuesDateField.Hide();
            IfcValuesLookupField.Hide();
            IfcValuesPicklistField.Hide();
            TreeGridDynamicValue.Show();
            IfcDynamicValuesTextField.Show();
        }
        if (IfcValuesConditionType.Value == ConditionType.Default.ToString())
        {
            TreeGridDynamicValue.Hide();
            IfcDynamicValuesTextField.Hide();
            if (se.IsTextField)
                IfcValuesTextField.Show();
            if (se.IsNumericField)
                IfcValuesNumericField.Show();
            if (se.IsDecimalField)
                IfcValuesDecimalField.Show();
            if (se.IsDateField)
                IfcValuesDateField.Show();
            if (se.IsLookupField)
                IfcValuesLookupField.Show();
            if (se.IsPicklistField)
                IfcValuesPicklistField.Show();
        }
        if (IfcValuesConditionType.Value == ConditionType.None.ToString())
        {
            TreeGridDynamicValue.Hide();
            IfcDynamicValuesTextField.Hide();
            if (se.IsTextField)
                IfcValuesTextField.Show();
            if (se.IsNumericField)
                IfcValuesNumericField.Show();
            if (se.IsDecimalField)
                IfcValuesDecimalField.Show();
            if (se.IsDateField)
                IfcValuesDateField.Show();
            if (se.IsLookupField)
                IfcValuesLookupField.Show();
            if (se.IsPicklistField)
                IfcValuesPicklistField.Show();
        }


    }
    protected void IfConditionSave_OnClickEvent(object sender, AjaxEventArgs e)
    {
        var xx = TreeIfConditions.AllNodes;
        var aa = ConvertNodeToFilterEntity(xx);
        var se = SerializeObject(aa);
        QScript(string.Format("IFCondition.Save({0});", RefleX.Serialize(se)));

    }



    #endregion

    #region DynamicValues
    protected void DynamicValue_NodeLoad(object sender, AjaxEventArgs e)
    {
        var nodelist = new List<RefleXFrameWork.TreeNode>();
        var activeAttributeId = CmbIfAttribute.Value; //TreeGridDynamicValue.SelectedNode[1].Value;
        var AttributePath = TreeGridDynamicValue.SelectedNode[3].Value;
        var TargetObjectId = TreeGridDynamicValue.SelectedNode[2].Value;
        var ParentName = TreeGridDynamicValue.SelectedNode[4].Value;
        //TxtAddDays.Visible = false;
        var objectId = ValidationHelper.GetInteger(TargetObjectId, ValidationHelper.GetInteger(hdnObjectId.Value, 0));
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
                var asyncNode = new RefleXFrameWork.TreeNode();
                asyncNode.Leaf = false;
                asyncNode.Icon = Icon.Folder;
                asyncNode.Text = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);

                asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId), EpMode.Value));
                asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", ea.AttributeId.ToString(), EpMode.Value));
                if (ea.ObjectId == EntityEnum.SystemConditionConstants.GetHashCode())
                {
                    asyncNode.Icon = Icon.FolderHome;
                    if (ea.ReferencedObjectId == 0) /* */
                    {
                        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ObjectId.ToString(), EpMode.Value));
                    }
                    else
                    {
                        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ReferencedObjectId.ToString(), EpMode.Value));

                    }
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + ea.AttributeId + "|" + ((ea.ReferencedEntityId == Guid.Empty) ? ea.EntityId : ea.ReferencedEntityId) + "]", EpMode.Value));
                }
                else
                {
                    asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", ea.ReferencedObjectId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + ea.AttributeId + "|" + ea.ReferencedEntityId + "]", EpMode.Value));
                }

                asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + asyncNode.Text + ")", EpMode.Value));
                asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", ea.ObjectId.ToString(), EpMode.Value));

                //nodelist.Add(asyncNode);
                TreeGridDynamicValue.AddTreeNode(asyncNode);
            }
        }
        var IsWorkFlow = true;
        if (IsWorkFlow)
        {
            foreach (var call in App.Params.CurrentWebServiceMethodCall.Values)
            {
                if (call.ObjectId == ValidationHelper.GetInteger(objectId, 0))
                {

                    var asyncNode = new RefleXFrameWork.TreeNode();
                    asyncNode.Text = call.Name;
                    //asyncNode.NodeID = Guid.NewGuid().ToString();
                    asyncNode.Icon = Icon.PluginLink;
                    asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", call.Name, EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", call.MethodCallId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", call.ReferencedObjectId.ToString(), EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "||[" + call.MethodCallId + "|" + App.Params.CurrentEntity[call.ReferencedObjectId].EntityId + "]", EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + asyncNode.Text + ")", EpMode.Value));
                    asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", call.ObjectId.ToString(), EpMode.Value));
                    //nodelist.Add(asyncNode);
                    TreeGridDynamicValue.AddTreeNode(asyncNode);

                }

            }
        }
        try
        {
            var activeEa = new EntityAttribute();
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


                var treeNode = new RefleXFrameWork.TreeNode();
                treeNode.Icon = Icon.BulletOrange;
                treeNode.Text = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId);
                //treeNode.NodeID = Guid.NewGuid().ToString();

                treeNode.CustomAttributes.Add(new ConfigItem("NodeName", treeNode.Text, EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("AttributeId", ea.AttributeId.ToString(), EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", "", EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("AttributePath", AttributePath + "." + ea.AttributeId, EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("ParentName", ParentName + ".(" + treeNode.Text + ")", EpMode.Value));
                treeNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", ea.ObjectId.ToString(), EpMode.Value));


                treeNode.Leaf = true;
                TreeGridDynamicValue.AddTreeNode(treeNode);
                //nodelist.Add(treeNode);
            }
        }
        catch (Exception)
        {


        }
        //TreeGridDynamicValue.AddTreeNode(nodelist);


    }
    void AddDynamicValueRoot()
    {
        var asyncNode = new RefleXFrameWork.TreeNode { Text = "" };
        asyncNode.CustomAttributes.Add(new ConfigItem("NodeName", "Root", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("AttributeId", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("TargetObjectId", hdnObjectId.Value, EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("AttributePath", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("ParentName", "", EpMode.Value));
        asyncNode.CustomAttributes.Add(new ConfigItem("CurrentObjectId", "", EpMode.Value));
        //TreeGridDynamicValue.Root.AsyncLoadNode = true;
        //TreeGridDynamicValue.Root.NodeLoad += DynamicValue_NodeLoad;
        //TreeGridDynamicValue.FillRoot(new List<TreeNode>() { asyncNode });
        asyncNode.Leaf = false;
        TreeGridDynamicValue.Root.Nodes.Add(asyncNode);
    }
    #endregion


    public object ConvertNodeToFilterEntity(RefleXFrameWork.TreeNode allNodes)
    {
        object rootObj = null;
        var type = allNodes.CustomAttributes[treedataType.type.GetHashCode()].Value;
        if (type == FilterEntityType.Entity.ToString() || type == FilterEntityType.And.ToString() || type == FilterEntityType.Or.ToString())
        {
            rootObj = new FilterEntity
            {
                FilterAttributeList = new List<FilterAttribute>(),
                FilterEntityList = new List<FilterEntity>(),
                type = type,
                text = allNodes.CustomAttributes[treedataType.text.GetHashCode()].Value,
                attributeid = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.attributeid.GetHashCode()].Value),
                id = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.id.GetHashCode()].Value),
                leftjoin = ValidationHelper.GetBoolean(allNodes.CustomAttributes[treedataType.leftjoin.GetHashCode()].Value),
                objectid = ValidationHelper.GetInteger(allNodes.CustomAttributes[treedataType.objectid.GetHashCode()].Value, 0),
            };
        }
        else
        {
            rootObj = new FilterAttribute()
            {
                type = type,
                text = allNodes.CustomAttributes[treedataType.text.GetHashCode()].Value,
                attributeid = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.attributeid.GetHashCode()].Value),
                id = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.id.GetHashCode()].Value),
                clausetext = ValidationHelper.GetString(allNodes.CustomAttributes[treedataType.clausetext.GetHashCode()].Value),
                clausevalue = ValidationHelper.GetString(allNodes.CustomAttributes[treedataType.clausevalue.GetHashCode()].Value),
                clausevalue2 = ValidationHelper.GetString(allNodes.CustomAttributes[treedataType.clausevalue2.GetHashCode()].Value),
                conditiontype = EnumConverter.GetConditionType(allNodes.CustomAttributes[treedataType.conditiontype.GetHashCode()].Value),
                conditionvalue = ValidationHelper.GetGuid(allNodes.CustomAttributes[treedataType.conditionvalue.GetHashCode()].Value),
                entityobjectid = ValidationHelper.GetInteger(allNodes.CustomAttributes[treedataType.entityobjectid.GetHashCode()].Value, 0),
                objectId = ValidationHelper.GetInteger(allNodes.CustomAttributes[treedataType.objectId.GetHashCode()].Value, 0),
            };
        }

        foreach (var node in allNodes.Nodes)
        {
            var ret = ConvertNodeToFilterEntity(node);
            if (ret.GetType() == typeof(FilterEntity))
                ((FilterEntity)rootObj).FilterEntityList.Add(((FilterEntity)ret));
            else
                ((FilterEntity)rootObj).FilterAttributeList.Add(((FilterAttribute)ret));

        }
        return rootObj;
    }
    public static class TypeHelper
    {
        public static object GetPropertyValue(object obj, string name)
        {
            return obj == null ? null : obj.GetType()
                                           .GetProperty(name)
                                           .GetValue(obj, null);
        }
    }

    protected void BtnRunClick(object sender, AjaxEventArgs e)
    {

        CriteriaFactory cf = new CriteriaFactory();

        cf.ExecuteCriteriaWithSql(ValidationHelper.GetGuid(hdnRecid.Value), Guid.NewGuid());
    }

}
